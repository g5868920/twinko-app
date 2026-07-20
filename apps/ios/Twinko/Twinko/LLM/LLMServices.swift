import Foundation
import os

// MARK: - Shared HTTP engine (safeguards live here, once)
//
// Both providers share one engine: explicit timeout, output-token
// clamp, budget pre-check, exactly one retry for transient failures
// (network timeout, HTTP 5xx, 429), never for 4xx or safety refusals.
// Operational logging is numbers/categories only — never prompt text,
// response text, or keys.

/// Injectable transport seam so unit tests can stub HTTP without a
/// network.
protocol LLMHTTPTransporting {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

struct URLSessionLLMTransport: LLMHTTPTransporting {
    private let session: URLSession

    init(timeout: TimeInterval = LLMSafeguards.requestTimeout) {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        session = URLSession(configuration: config)
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw LLMError.network }
            return (data, http)
        } catch let error as LLMError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw LLMError.timeout
        } catch {
            throw LLMError.network
        }
    }
}

enum LLMEngine {
    static let log = Logger(subsystem: "studio.gina.twinko.prototype", category: "llm")

    /// Executes a provider request with the shared safeguards. The
    /// `perform` closure does one attempt; the engine owns budget
    /// check, retry policy, timing, ledger recording, and logging.
    static func run(provider: LLMProvider, model: String,
                    ledger: LLMUsageLedger,
                    attempt: () async throws -> LLMResult) async throws -> LLMResult {
        try ledger.assertWithinBudget()

        let start = Date()
        do {
            let result = try await attempt()
            finishLog(provider: provider, model: model, result: result, retried: false)
            ledger.record(provider: provider, model: model,
                          inputTokens: result.inputTokens ?? 0,
                          outputTokens: result.outputTokens ?? 0)
            return result
        } catch let error as LLMError where isTransient(error) {
            log.info("llm retrying provider=\(provider.rawValue, privacy: .public) after=\(String(describing: error), privacy: .public)")
            let result = try await attempt()
            finishLog(provider: provider, model: model, result: result, retried: true)
            ledger.record(provider: provider, model: model,
                          inputTokens: result.inputTokens ?? 0,
                          outputTokens: result.outputTokens ?? 0)
            return result
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            log.error("llm failed provider=\(provider.rawValue, privacy: .public) model=\(model, privacy: .public) elapsed=\(String(format: "%.2f", elapsed), privacy: .public) error=\(String(describing: error), privacy: .public)")
            throw error
        }
    }

    /// Transient = worth exactly one retry. 4xx validation errors and
    /// safety refusals are never retried.
    static func isTransient(_ error: LLMError) -> Bool {
        switch error {
        case .timeout, .network, .rateLimited:
            return true
        case .httpStatus(let code):
            return code >= 500
        case .notConfigured, .decoding, .safetyRefusal, .budgetExceeded:
            return false
        }
    }

    private static func finishLog(provider: LLMProvider, model: String,
                                  result: LLMResult, retried: Bool) {
        log.info("llm ok provider=\(provider.rawValue, privacy: .public) model=\(model, privacy: .public) latency=\(String(format: "%.2f", result.latencySeconds), privacy: .public) in=\(result.inputTokens ?? -1) out=\(result.outputTokens ?? -1) retried=\(retried)")
    }

    static func clampOutputTokens(_ requested: Int) -> Int {
        min(max(requested, 1), LLMSafeguards.maxOutputTokensCap)
    }

    /// Maps a non-2xx HTTP status to the neutral error space.
    static func statusError(_ code: Int) -> LLMError {
        code == 429 ? .rateLimited : .httpStatus(code)
    }
}

// MARK: - Anthropic (Messages API)

struct AnthropicLLMService: LLMServing {
    let provider: LLMProvider = .anthropic

    private let transport: LLMHTTPTransporting
    private let ledger: LLMUsageLedger
    private let apiKey: () -> String?

    init(transport: LLMHTTPTransporting = URLSessionLLMTransport(),
         ledger: LLMUsageLedger = LLMUsageLedger(),
         apiKey: @escaping () -> String? = { LLMSecrets.apiKey(for: .anthropic) }) {
        self.transport = transport
        self.ledger = ledger
        self.apiKey = apiKey
    }

    private struct RequestBody: Encodable {
        struct Message: Encodable { let role: String; let content: String }
        let model: String
        let max_tokens: Int
        let system: String
        let messages: [Message]
    }

    private struct ResponseBody: Decodable {
        struct Content: Decodable { let type: String; let text: String? }
        struct Usage: Decodable { let input_tokens: Int?; let output_tokens: Int? }
        let content: [Content]
        let stop_reason: String?
        let usage: Usage?
    }

    func complete(_ request: LLMRequest) async throws -> LLMResult {
        guard let key = apiKey() else { throw LLMError.notConfigured }
        return try await LLMEngine.run(provider: provider, model: request.model,
                                       ledger: ledger) {
            try await attempt(request, key: key)
        }
    }

    private func attempt(_ request: LLMRequest, key: String) async throws -> LLMResult {
        var urlRequest = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = LLMSafeguards.requestTimeout
        urlRequest.setValue(key, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // jsonMode: intentionally a no-op here for now — Anthropic JSON
        // enforcement arrives with the real Task 3 schema via
        // output_config.format.
        let body = RequestBody(
            model: request.model,
            max_tokens: LLMEngine.clampOutputTokens(request.maxOutputTokens),
            system: request.system,
            messages: [.init(role: "user", content: request.userContent)])
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let start = Date()
        let (data, response) = try await transport.send(urlRequest)
        guard (200..<300).contains(response.statusCode) else {
            throw LLMEngine.statusError(response.statusCode)
        }
        guard let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data) else {
            throw LLMError.decoding
        }
        if decoded.stop_reason == "refusal" { throw LLMError.safetyRefusal }
        let text = decoded.content.compactMap { $0.type == "text" ? $0.text : nil }
            .joined()
        return LLMResult(text: text,
                         provider: provider,
                         model: request.model,
                         inputTokens: decoded.usage?.input_tokens,
                         outputTokens: decoded.usage?.output_tokens,
                         latencySeconds: Date().timeIntervalSince(start),
                         finishReason: decoded.stop_reason)
    }
}

// MARK: - OpenAI (Chat Completions API)

struct OpenAILLMService: LLMServing {
    let provider: LLMProvider = .openai

    private let transport: LLMHTTPTransporting
    private let ledger: LLMUsageLedger
    private let apiKey: () -> String?

    init(transport: LLMHTTPTransporting = URLSessionLLMTransport(),
         ledger: LLMUsageLedger = LLMUsageLedger(),
         apiKey: @escaping () -> String? = { LLMSecrets.apiKey(for: .openai) }) {
        self.transport = transport
        self.ledger = ledger
        self.apiKey = apiKey
    }

    private struct RequestBody: Encodable {
        struct Message: Encodable { let role: String; let content: String }
        struct ResponseFormat: Encodable { let type: String }
        let model: String
        let max_completion_tokens: Int
        let messages: [Message]
        let response_format: ResponseFormat?
    }

    private struct ResponseBody: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String? }
            let message: Message
            let finish_reason: String?
        }
        struct Usage: Decodable { let prompt_tokens: Int?; let completion_tokens: Int? }
        let choices: [Choice]
        let usage: Usage?
    }

    func complete(_ request: LLMRequest) async throws -> LLMResult {
        guard let key = apiKey() else { throw LLMError.notConfigured }
        return try await LLMEngine.run(provider: provider, model: request.model,
                                       ledger: ledger) {
            try await attempt(request, key: key)
        }
    }

    private func attempt(_ request: LLMRequest, key: String) async throws -> LLMResult {
        var urlRequest = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = LLMSafeguards.requestTimeout
        urlRequest.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = RequestBody(
            model: request.model,
            max_completion_tokens: LLMEngine.clampOutputTokens(request.maxOutputTokens),
            messages: [.init(role: "system", content: request.system),
                       .init(role: "user", content: request.userContent)],
            response_format: request.jsonMode ? .init(type: "json_object") : nil)
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let start = Date()
        let (data, response) = try await transport.send(urlRequest)
        guard (200..<300).contains(response.statusCode) else {
            throw LLMEngine.statusError(response.statusCode)
        }
        guard let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data),
              let choice = decoded.choices.first else {
            throw LLMError.decoding
        }
        if choice.finish_reason == "content_filter" { throw LLMError.safetyRefusal }
        return LLMResult(text: choice.message.content ?? "",
                         provider: provider,
                         model: request.model,
                         inputTokens: decoded.usage?.prompt_tokens,
                         outputTokens: decoded.usage?.completion_tokens,
                         latencySeconds: Date().timeIntervalSince(start),
                         finishReason: choice.finish_reason)
    }
}
