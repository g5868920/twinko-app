import Foundation

// MARK: - Phase A LLM transport (2026-07-19, founder-approved)
//
// Provider-neutral transport layer only: neutral request/result models,
// one protocol, typed errors, and Phase A key loading. No prompts, no
// schema, no UI wiring, no streaming — the structured Tarot response
// schema and safety matrix arrive in later Phase A tasks. Keys load
// exclusively from the gitignored `LLMSecrets.plist` (see
// docs/features/llm/TWINKO_LLM_PHASE_A.md); a missing file means every
// service throws `.notConfigured` and the app behaves exactly as
// before. A server-side proxy is a HARD GATE before TestFlight or any
// external distribution.

/// Which vendor serves a request. Routing identity only — never used
/// to branch product behavior.
enum LLMProvider: String, Codable, CaseIterable {
    case anthropic
    case openai
}

/// Neutral request. Sampling parameters are deliberately not modeled
/// (current frontier models reject them; style is steered by prompt
/// content, which later tasks own).
struct LLMRequest: Equatable {
    var system: String
    var userContent: String
    var model: String
    /// Requested output ceiling; the transport clamps it to
    /// `LLMSafeguards.maxOutputTokensCap` — callers may ask for less,
    /// never more.
    var maxOutputTokens: Int
    /// Reserved for the Task 3 structured-output work. Currently maps
    /// to OpenAI's JSON object mode; Anthropic JSON enforcement will
    /// use a real schema (`output_config.format`) in Task 3 and this
    /// flag is a no-op there for now.
    var jsonMode: Bool = false
}

/// Neutral result with the operational metadata the evaluation harness
/// will need (latency, token usage). Content is never persisted by the
/// transport layer.
struct LLMResult: Equatable {
    let text: String
    let provider: LLMProvider
    let model: String
    let inputTokens: Int?
    let outputTokens: Int?
    let latencySeconds: Double
    let finishReason: String?
}

enum LLMError: Error, Equatable {
    /// No key configured for this provider (Phase A file absent or
    /// blank) — the caller falls back to the deterministic mocks.
    case notConfigured
    case network
    case timeout
    case rateLimited
    case httpStatus(Int)
    case decoding
    /// The provider declined the request for safety reasons — never
    /// retried by the transport.
    case safetyRefusal
    /// The local daily allowance would be exceeded (Phase A cost
    /// guard) — no request was sent.
    case budgetExceeded
}

/// The one seam every feature talks to. Concrete services live in
/// LLMServices.swift; mocks/stubs implement this in tests.
protocol LLMServing {
    var provider: LLMProvider { get }
    func complete(_ request: LLMRequest) async throws -> LLMResult
}

// MARK: - Phase A secrets loading

/// Loads prototype API keys from the optional, gitignored
/// `LLMSecrets.plist` copied into the bundle by a conditional build
/// phase (build succeeds when the file is absent). DEBUG builds only —
/// release builds always report unconfigured, so no key can ride an
/// archive. Keys never touch UserDefaults, JSONStore, or logs.
enum LLMSecrets {
    #if DEBUG
    private static func dictionary() -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: "LLMSecrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(
                  from: data, format: nil) as? [String: Any] else {
            return nil
        }
        return dict
    }
    #endif

    static func apiKey(for provider: LLMProvider) -> String? {
        switch provider {
        case .anthropic: return configValue("ANTHROPIC_API_KEY")
        case .openai: return configValue("OPENAI_API_KEY")
        }
    }

    /// Optional non-secret local config from the same Debug-only,
    /// gitignored plist (e.g. `TAROT_BENCHMARK_OPENAI_MODEL` for the
    /// step 7 benchmark). Blank values read as absent.
    static func configValue(_ name: String) -> String? {
        #if DEBUG
        guard let value = dictionary()?[name] as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
        #else
        return nil
        #endif
    }
}

// MARK: - Safeguard defaults (Phase A)

enum LLMSafeguards {
    /// Explicit per-request timeout.
    static let requestTimeout: TimeInterval = 30
    /// Hard ceiling on output tokens regardless of what a caller asks.
    static let maxOutputTokensCap = 2000
    /// At most one retry, transient failures only.
    static let maxRetries = 1
    /// Local daily spend allowance in USD (client-side guard; the
    /// provider-console limits remain the outer net).
    static let defaultDailyAllowanceUSD = 1.00
}

/// Conservative static price table (USD per 1M tokens) used only for
/// the local budget estimate — not billing truth. Unknown models fall
/// back to the conservative default so the guard can never
/// under-count.
struct LLMPriceTable {
    struct Price { let inputPerMTok: Double; let outputPerMTok: Double }

    static let `default` = LLMPriceTable(prices: [
        "claude-sonnet-5": Price(inputPerMTok: 3, outputPerMTok: 15),
        "claude-haiku-4-5": Price(inputPerMTok: 1, outputPerMTok: 5),
        "claude-opus-4-8": Price(inputPerMTok: 5, outputPerMTok: 25),
    ], fallback: Price(inputPerMTok: 5, outputPerMTok: 25))

    let prices: [String: Price]
    let fallback: Price

    func price(for model: String) -> Price {
        prices[model] ?? fallback
    }

    func estimatedCostUSD(model: String, inputTokens: Int, outputTokens: Int) -> Double {
        let p = price(for: model)
        return Double(inputTokens) / 1_000_000 * p.inputPerMTok
            + Double(outputTokens) / 1_000_000 * p.outputPerMTok
    }
}

// MARK: - Daily usage ledger (numbers only — never content)

/// Day-keyed usage totals per provider, persisted through the existing
/// JSONStore pattern. Stores request counts and token totals only:
/// never prompt text, response text, or keys.
struct LLMDailyUsage: Codable, Equatable {
    var dayKey: String
    var entries: [String: ProviderUsage] = [:]

    struct ProviderUsage: Codable, Equatable {
        var requests = 0
        var inputTokens = 0
        var outputTokens = 0
        var estimatedSpendUSD = 0.0
    }
}

final class LLMUsageLedger {
    static let fileName = "llm_usage"

    private let store: JSONStore
    private let calendar: Calendar
    private let now: () -> Date
    private let prices: LLMPriceTable
    let dailyAllowanceUSD: Double

    private(set) var usage: LLMDailyUsage

    init(store: JSONStore = JSONStore(),
         calendar: Calendar = .autoupdatingCurrent,
         now: @escaping () -> Date = { .now },
         prices: LLMPriceTable = .default,
         dailyAllowanceUSD: Double = LLMSafeguards.defaultDailyAllowanceUSD) {
        self.store = store
        self.calendar = calendar
        self.now = now
        self.prices = prices
        self.dailyAllowanceUSD = dailyAllowanceUSD
        usage = store.load(LLMDailyUsage.self, from: Self.fileName)
            ?? LLMDailyUsage(dayKey: "")
    }

    private func dayKey() -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: now())
        return String(format: "%04d-%02d-%02d",
                      parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// Rolls the ledger to the current local day (yesterday's totals
    /// are replaced — no history is kept).
    private func rolledToToday() -> LLMDailyUsage {
        let today = dayKey()
        if usage.dayKey == today { return usage }
        return LLMDailyUsage(dayKey: today)
    }

    var todaySpendUSD: Double {
        rolledToToday().entries.values.reduce(0) { $0 + $1.estimatedSpendUSD }
    }

    /// Pre-flight check: throws `.budgetExceeded` when today's
    /// estimated spend has already reached the allowance.
    func assertWithinBudget() throws {
        if todaySpendUSD >= dailyAllowanceUSD {
            throw LLMError.budgetExceeded
        }
    }

    /// Records one completed request (numbers only).
    func record(provider: LLMProvider, model: String,
                inputTokens: Int, outputTokens: Int) {
        var current = rolledToToday()
        var entry = current.entries[provider.rawValue] ?? .init()
        entry.requests += 1
        entry.inputTokens += inputTokens
        entry.outputTokens += outputTokens
        entry.estimatedSpendUSD += prices.estimatedCostUSD(
            model: model, inputTokens: inputTokens, outputTokens: outputTokens)
        current.entries[provider.rawValue] = entry
        usage = current
        store.save(current, as: Self.fileName)
    }
}

// MARK: - Privacy disclosure (Phase A step 9 — DRAFT wording)
//
// ⚠️ DRAFT — wording requires founder sign-off before live Tarot
// generation reaches the user flow (step 10). Single source for the
// LLM disclosure shown on the My Planet privacy page. The disclosure
// activates only in builds where a prototype key is actually
// configured; unconfigured builds keep the original local-only
// wording, which remains true for them. Claims here are deliberately
// verifiable: what is sent, what is not, and that the user controls
// what goes into a question.

enum LLMPrivacyDisclosure {
    /// True when this build can make live LLM calls at all.
    static var isActive: Bool {
        LLMProvider.allCases.contains { LLMSecrets.apiKey(for: $0) != nil }
    }

    static func title(_ lang: AppLanguage) -> String {
        lang == .english ? "AI interpretation (in testing)" : "AI 解讀（測試中）"
    }

    static func body(_ lang: AppLanguage) -> String {
        lang == .english
        ? "When AI interpretation is on, only what the response needs — your question, option notes, and the cards drawn — is sent to an external AI service over an encrypted connection to generate the reading. Twinko stores nothing outside this device. Your nickname, birthday, and profile are never sent. Please avoid typing private details you would not want transmitted into a question."
        : "啟用 AI 解讀時，產生回應所需的內容——你的提問、選項說明與抽到的牌——會以加密連線傳送給外部 AI 服務。Twinko 不會把任何內容儲存在這台裝置以外的地方；你的暱稱、生日等個人資料也不會被傳送。請避免在問題中輸入你不想傳出的私人資訊。"
    }

    /// Replaces the absolute "nothing is uploaded" claim when live
    /// calls are possible — the original wording stays in
    /// unconfigured builds.
    static func uploadRowBody(_ lang: AppLanguage) -> String {
        lang == .english
        ? "Outside of AI interpretation, nothing is uploaded, synced, or shared — and there is no account."
        : "除了 AI 解讀之外，沒有任何內容會被上傳、同步或分享，也沒有帳號。"
    }
}
