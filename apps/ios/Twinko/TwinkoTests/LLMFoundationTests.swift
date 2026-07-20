import XCTest
@testable import Twinko

/// Phase A Task 1 protection: registry knowledge integrity, transport
/// safeguards (notConfigured, single-retry policy), and the local
/// daily budget guard. No network is touched — HTTP is stubbed through
/// the injectable transport seam.
final class LLMFoundationTests: XCTestCase {

    // MARK: 1 — Registry knowledge integrity (v0.1 draft)

    func testRegistryKnowledgeLayerIntegrity() throws {
        let cards = TarotRegistry.cards
        XCTAssertEqual(cards.count, 78)
        XCTAssertEqual(Set(cards.map(\.id)).count, 78, "Unique IDs")

        let validElements: Set<String> = ["fire", "water", "air", "earth"]
        for card in cards {
            XCTAssertTrue(validElements.contains(card.element), "\(card.id) element")
            for keywords in [card.keywordsUprightZh, card.keywordsUprightEn,
                             card.keywordsReversedZh, card.keywordsReversedEn] {
                XCTAssertTrue((3...5).contains(keywords.count),
                              "\(card.id) keyword count \(keywords.count)")
                XCTAssertTrue(keywords.allSatisfy { !$0.isEmpty })
            }
            XCTAssertTrue((2...3).contains(card.coreSymbols.count),
                          "\(card.id) symbols \(card.coreSymbols.count)")
            for symbol in card.coreSymbols {
                XCTAssertFalse(symbol.zh.isEmpty)
                XCTAssertFalse(symbol.en.isEmpty)
            }
            for core in [card.coreUprightZh, card.coreUprightEn,
                         card.coreReversedZh, card.coreReversedEn] {
                XCTAssertFalse(core.isEmpty, "\(card.id) core sentence")
            }
            // Existing shape unchanged: names/assets still present.
            XCTAssertFalse(card.displayNameEn.isEmpty)
            XCTAssertFalse(card.displayNameZh.isEmpty)
            XCTAssertTrue(card.assetFileName.hasSuffix(".png"))
        }

        // Minor-suit elements follow the classical attribution.
        for card in cards where card.arcanaType == "minor" {
            let expected = ["wands": "fire", "cups": "water",
                            "swords": "air", "pentacles": "earth"][card.suit]
            XCTAssertEqual(card.element, expected, card.id)
        }

        // The draft marker is present at the top level of the file.
        let url = try XCTUnwrap(Bundle(for: LLMFoundationTests.self)
            .url(forResource: "twinko_tarot_card_registry_v1", withExtension: "json")
            ?? Bundle.main.url(forResource: "twinko_tarot_card_registry_v1",
                               withExtension: "json"))
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(
            with: Data(contentsOf: url)) as? [String: Any])
        XCTAssertEqual(json["knowledge_version"] as? String, "0.1-draft-unreviewed")

        // Backward compatibility: a card without knowledge fields still
        // decodes (empty values, no crash).
        let legacy = """
        {"id":"x","asset_name":"x.png","display_name_en":"X",
         "display_name_zh_tw":"X","arcana_type":"minor","suit":"cups","rank":"02"}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(TarotCardInfo.self, from: legacy)
        XCTAssertTrue(decoded.keywordsUprightZh.isEmpty)
        XCTAssertEqual(decoded.element, "")
    }

    // MARK: 2 — Safeguards: notConfigured + single-retry policy

    /// Stub transport: returns scripted results in order.
    private final class StubTransport: LLMHTTPTransporting {
        enum Step { case fail(LLMError); case respond(Int, Data) }
        var steps: [Step]
        private(set) var calls = 0

        init(_ steps: [Step]) { self.steps = steps }

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            calls += 1
            guard !steps.isEmpty else { throw LLMError.network }
            switch steps.removeFirst() {
            case .fail(let error):
                throw error
            case .respond(let status, let data):
                let response = HTTPURLResponse(url: request.url!, statusCode: status,
                                               httpVersion: nil, headerFields: nil)!
                return (data, response)
            }
        }
    }

    private func ledger(allowance: Double = 10,
                        now: @escaping () -> Date = { Date(timeIntervalSince1970: 1_800_000_000) })
        -> LLMUsageLedger {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("llm-tests-\(UUID().uuidString)")
        return LLMUsageLedger(store: JSONStore(directory: dir),
                              calendar: .init(identifier: .gregorian),
                              now: now, dailyAllowanceUSD: allowance)
    }

    private static let anthropicOK = """
    {"content":[{"type":"text","text":"hello"}],"stop_reason":"end_turn",
     "usage":{"input_tokens":10,"output_tokens":5}}
    """.data(using: .utf8)!

    private func request() -> LLMRequest {
        LLMRequest(system: "s", userContent: "u", model: "claude-sonnet-5",
                   maxOutputTokens: 100)
    }

    func testMissingConfigThrowsNotConfiguredWithoutNetwork() async {
        let transport = StubTransport([])
        let service = AnthropicLLMService(transport: transport, ledger: ledger(),
                                          apiKey: { nil })
        do {
            _ = try await service.complete(request())
            XCTFail("Expected notConfigured")
        } catch let error as LLMError {
            XCTAssertEqual(error, .notConfigured)
        } catch { XCTFail("Unexpected \(error)") }
        XCTAssertEqual(transport.calls, 0, "No request may leave the device")
    }

    func testTransientFailureRetriesExactlyOnce() async throws {
        // 5xx then success → exactly two attempts, result returned.
        let transport = StubTransport([.respond(500, Data()),
                                       .respond(200, Self.anthropicOK)])
        let service = AnthropicLLMService(transport: transport, ledger: ledger(),
                                          apiKey: { "test-key" })
        let result = try await service.complete(request())
        XCTAssertEqual(result.text, "hello")
        XCTAssertEqual(result.inputTokens, 10)
        XCTAssertEqual(transport.calls, 2)

        // Two transient failures → error after exactly two attempts.
        let failing = StubTransport([.fail(.timeout), .fail(.timeout)])
        let failingService = AnthropicLLMService(transport: failing, ledger: ledger(),
                                                 apiKey: { "test-key" })
        do {
            _ = try await failingService.complete(request())
            XCTFail("Expected timeout")
        } catch let error as LLMError {
            XCTAssertEqual(error, .timeout)
        }
        XCTAssertEqual(failing.calls, 2, "Exactly one retry, never more")
    }

    func testValidationErrorsAndRefusalsAreNeverRetried() async {
        let transport = StubTransport([.respond(400, Data()),
                                       .respond(200, Self.anthropicOK)])
        let service = AnthropicLLMService(transport: transport, ledger: ledger(),
                                          apiKey: { "test-key" })
        do {
            _ = try await service.complete(request())
            XCTFail("Expected httpStatus(400)")
        } catch let error as LLMError {
            XCTAssertEqual(error, .httpStatus(400))
        } catch { XCTFail("Unexpected \(error)") }
        XCTAssertEqual(transport.calls, 1, "4xx must not be retried")
        XCTAssertFalse(LLMEngine.isTransient(.safetyRefusal))
        XCTAssertFalse(LLMEngine.isTransient(.decoding))
        XCTAssertTrue(LLMEngine.isTransient(.rateLimited))
        XCTAssertTrue(LLMEngine.isTransient(.httpStatus(503)))
    }

    func testOutputTokenClamp() {
        XCTAssertEqual(LLMEngine.clampOutputTokens(100), 100)
        XCTAssertEqual(LLMEngine.clampOutputTokens(999_999),
                       LLMSafeguards.maxOutputTokensCap)
        XCTAssertEqual(LLMEngine.clampOutputTokens(0), 1)
    }

    // MARK: 3 — Daily budget guard

    func testBudgetGuardAccumulatesAndBlocks() throws {
        var currentDate = Date(timeIntervalSince1970: 1_800_000_000)
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("llm-tests-\(UUID().uuidString)")
        let store = JSONStore(directory: dir)
        let guardLedger = LLMUsageLedger(
            store: store, calendar: .init(identifier: .gregorian),
            now: { currentDate },
            prices: LLMPriceTable(prices: [:],
                                  fallback: .init(inputPerMTok: 1, outputPerMTok: 1)),
            dailyAllowanceUSD: 1.0)

        try guardLedger.assertWithinBudget()
        // 0.6 USD spent (0.3M in + 0.3M out at $1/M-token equivalent).
        guardLedger.record(provider: .anthropic, model: "m",
                           inputTokens: 300_000, outputTokens: 300_000)
        XCTAssertEqual(guardLedger.todaySpendUSD, 0.6, accuracy: 0.001)
        try guardLedger.assertWithinBudget()

        guardLedger.record(provider: .openai, model: "m",
                           inputTokens: 300_000, outputTokens: 300_000)
        XCTAssertThrowsError(try guardLedger.assertWithinBudget()) { error in
            XCTAssertEqual(error as? LLMError, .budgetExceeded)
        }

        // Ledger persists (numbers only) and reloads.
        let reloaded = LLMUsageLedger(
            store: store, calendar: .init(identifier: .gregorian),
            now: { currentDate }, dailyAllowanceUSD: 1.0)
        XCTAssertEqual(reloaded.usage.entries[LLMProvider.anthropic.rawValue]?.requests, 1)

        // A new local day resets the allowance.
        currentDate = currentDate.addingTimeInterval(60 * 60 * 26)
        XCTAssertEqual(guardLedger.todaySpendUSD, 0, accuracy: 0.0001)
        try guardLedger.assertWithinBudget()
    }

    /// A blocked budget must prevent any network attempt.
    func testBudgetExceededBlocksBeforeAnyRequest() async {
        let transport = StubTransport([.respond(200, Self.anthropicOK)])
        let blocked = ledger(allowance: 0)
        let service = AnthropicLLMService(transport: transport, ledger: blocked,
                                          apiKey: { "test-key" })
        do {
            _ = try await service.complete(request())
            XCTFail("Expected budgetExceeded")
        } catch let error as LLMError {
            XCTAssertEqual(error, .budgetExceeded)
        } catch { XCTFail("Unexpected \(error)") }
        XCTAssertEqual(transport.calls, 0)
    }
}
