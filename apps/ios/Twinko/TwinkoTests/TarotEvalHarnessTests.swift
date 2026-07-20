import XCTest
@testable import Twinko

// MARK: - Stub services (no network)

/// Echoes a schema-valid response for whatever reading is in the
/// request by parsing the deterministic `position_id:` / `card_id:`
/// lines of the grounded prompt. Always reports safety "none".
private struct EchoStubLLMService: LLMServing {
    let provider: LLMProvider = .anthropic
    var latency: Double = 0.5

    func complete(_ request: LLMRequest) async throws -> LLMResult {
        func matches(_ pattern: String) -> [String] {
            let regex = try! NSRegularExpression(pattern: pattern)
            let range = NSRange(request.userContent.startIndex...,
                                in: request.userContent)
            return regex.matches(in: request.userContent, range: range).map {
                String(request.userContent[Range($0.range(at: 1),
                                                 in: request.userContent)!])
            }
        }
        let positions = matches("position_id: (\\w+)")
        let cards = matches("card_id: (\\w+)")
        let entries = zip(positions, cards).map { position, card in
            """
            {"position_id": "\(position)", "card_id": "\(card)",
             "interpretation": "這張牌可能反映一種值得留意的內在狀態。",
             "reflection_prompt": "今天有什麼小事呼應了它？"}
            """
        }
        let json = """
        {"positions": [\(entries.joined(separator: ","))],
         "cross_card_patterns": "整體能量偏向轉換，值得留意平衡。",
         "integrated_summary": "把牌放在一起看，是一個可以慢慢想的角度。",
         "gentle_next_step": "先為自己安排一件小小的事。",
         "safety_category": "none"}
        """
        return LLMResult(text: json, provider: provider, model: request.model,
                         inputTokens: 1200, outputTokens: 600,
                         latencySeconds: latency, finishReason: "end_turn")
    }
}

/// Returns text that is not schema JSON at all.
private struct GarbageStubLLMService: LLMServing {
    let provider: LLMProvider = .openai
    func complete(_ request: LLMRequest) async throws -> LLMResult {
        LLMResult(text: "The cards say you will definitely succeed!",
                  provider: provider, model: request.model,
                  inputTokens: 1200, outputTokens: 40,
                  latencySeconds: 0.2, finishReason: "stop")
    }
}

/// Always fails with a non-transient error.
private struct FailingStubLLMService: LLMServing {
    let provider: LLMProvider = .openai
    func complete(_ request: LLMRequest) async throws -> LLMResult {
        throw LLMError.notConfigured
    }
}

// MARK: - Harness tests (offline)

final class TarotEvalHarnessTests: XCTestCase {

    // MARK: 1 — Golden fixture integrity

    func testGoldenCasesBuildAndIDsAreUnique() {
        let cases = TarotGoldenCases.all
        XCTAssertEqual(cases.count, 12)
        XCTAssertEqual(Set(cases.map(\.id)).count, cases.count, "ids unique")

        for goldenCase in cases {
            guard let session = goldenCase.session() else {
                return XCTFail("\(goldenCase.id): session failed to build")
            }
            let definition = session.definition
            XCTAssertEqual(session.cards.count, definition.positionIDs.count,
                           goldenCase.id)
            XCTAssertEqual(session.cards.compactMap(\.positionID),
                           definition.positionIDs,
                           "\(goldenCase.id): canonical position order")
            // Pinned cards must be unique within a reading (deck rule).
            XCTAssertEqual(Set(session.cards.map(\.card.id)).count,
                           session.cards.count, goldenCase.id)
        }
    }

    func testGoldenCoverageMatchesApprovedDirection() {
        let cases = TarotGoldenCases.all
        let spreads = Set(cases.map(\.spreadID))
        XCTAssertEqual(spreads, Set(TarotSpreadID.allCases),
                       "every spread archetype is covered")

        func reversedCount(_ c: TarotGoldenCase) -> Int {
            c.cards.filter { $0.orientation == .reversed }.count
        }
        XCTAssertTrue(cases.contains { reversedCount($0) == $0.cards.count
                                        && $0.cards.count >= 3 },
                      "an all-reversed multi-card spread exists")
        XCTAssertTrue(cases.contains { goldenCase in
            goldenCase.cards.filter { $0.cardID.hasPrefix("major_") }.count >= 3
        }, "a Major Arcana concentration case exists")
        XCTAssertTrue(cases.contains { goldenCase in
            let suits = goldenCase.cards.compactMap {
                $0.cardID.split(separator: "_").first
            }
            return suits.count >= 3 && Set(suits).count == 1
                && suits.first != "major"
        }, "a repeated-suit case exists")
        XCTAssertTrue(cases.contains { goldenCase in
            let ranks = goldenCase.cards.compactMap {
                $0.cardID.split(separator: "_").last
            }
            return ranks.count >= 3 && Set(ranks).count == 1
        }, "a repeated-number case exists")

        let expectedCategories = Set(cases.map(\.expectedSafetyCategory))
        XCTAssertTrue(expectedCategories.isSuperset(of:
            [.selfHarmCrisis, .medicalDiagnosis, .relationshipMindReading]),
            "high-risk questions cover the key safety categories")
        XCTAssertTrue(cases.contains { $0.lang == .english },
                      "one English case exists")
        XCTAssertTrue(cases.contains { $0.contextKind == .dailyCheckIn },
                      "the daily check-in context is exercised")
    }

    // MARK: 2 — Mechanical evaluation

    func testEvaluateAcceptsValidResponseAndFlagsSafetyMismatch() async throws {
        // A "none" echo against the crisis golden: schema valid, but
        // the safety category must be flagged as a mismatch.
        let crisis = TarotGoldenCases.all.first { $0.id == "golden_04_action_crisis" }!
        let session = crisis.session()!
        let result = try await EchoStubLLMService().complete(
            TarotPromptBuilder.request(for: session, lang: crisis.lang,
                                       model: "stub-model"))
        let evaluation = TarotEvalHarness.evaluate(
            caseID: crisis.id, modelLabel: "model_a",
            goldenCase: crisis, session: session, result: result)

        XCTAssertTrue(evaluation.schemaValid, "\(evaluation.issues)")
        XCTAssertEqual(evaluation.reportedSafetyCategory, "none")
        XCTAssertFalse(evaluation.safetyCategoryMatches)
        XCTAssertFalse(evaluation.safetyActionMatches,
                       "none and self_harm_crisis trigger different actions")
        XCTAssertGreaterThan(evaluation.estimatedCostUSD, 0)

        // Same echo against a "none" golden: everything matches.
        let baseline = TarotGoldenCases.all.first!
        let baselineSession = baseline.session()!
        let baselineResult = try await EchoStubLLMService().complete(
            TarotPromptBuilder.request(for: baselineSession, lang: baseline.lang,
                                       model: "stub-model"))
        let ok = TarotEvalHarness.evaluate(
            caseID: baseline.id, modelLabel: "model_a",
            goldenCase: baseline, session: baselineSession, result: baselineResult)
        XCTAssertTrue(ok.schemaValid, "\(ok.issues)")
        XCTAssertTrue(ok.safetyCategoryMatches)
        XCTAssertTrue(ok.safetyActionMatches)
    }

    func testEvaluateFlagsUndecodableAndFailedRequests() async throws {
        let goldenCase = TarotGoldenCases.all.first!
        let session = goldenCase.session()!
        let garbage = try await GarbageStubLLMService().complete(
            TarotPromptBuilder.request(for: session, lang: goldenCase.lang,
                                       model: "stub-model"))
        let evaluation = TarotEvalHarness.evaluate(
            caseID: goldenCase.id, modelLabel: "model_b",
            goldenCase: goldenCase, session: session, result: garbage)
        XCTAssertFalse(evaluation.schemaValid)
        XCTAssertNil(evaluation.reportedSafetyCategory)

        let failure = TarotEvalHarness.evaluateFailure(
            caseID: goldenCase.id, modelLabel: "model_b",
            goldenCase: goldenCase, error: LLMError.notConfigured)
        XCTAssertEqual(failure.errorCategory, "notConfigured")
        XCTAssertFalse(failure.schemaValid)
        XCTAssertEqual(failure.estimatedCostUSD, 0)
    }

    // MARK: 3 — Benchmark runner (offline, stubbed)

    func testRunBenchmarkWritesBlindedArtifacts() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("tarot-eval-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }

        let cases = Array(TarotGoldenCases.all.prefix(3))
        let run = try await TarotEvalHarness.runBenchmark(
            cases: cases,
            arms: [.init(blindLabel: "model_a", service: EchoStubLLMService(),
                         model: "stub-echo"),
                   .init(blindLabel: "model_b", service: FailingStubLLMService(),
                         model: "stub-failing")],
            outputDirectory: directory)

        XCTAssertEqual(run.evaluations.count, cases.count * 2)
        XCTAssertTrue(run.evaluations
            .filter { $0.modelLabel == "model_a" }
            .allSatisfy(\.schemaValid))
        XCTAssertTrue(run.evaluations
            .filter { $0.modelLabel == "model_b" }
            .allSatisfy { $0.errorCategory == "notConfigured" })

        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        for goldenCase in cases {
            for label in ["model_a", "model_b"] {
                XCTAssertTrue(files.contains("\(goldenCase.id)__\(label).md"))
                XCTAssertTrue(files.contains("\(goldenCase.id)__\(label).json"))
            }
        }
        XCTAssertTrue(files.contains("summary.md"))
        XCTAssertTrue(files.contains("REVIEW_GUIDE.md"))
        XCTAssertTrue(files.contains("unblind.json"))

        // Review sheets are blinded: no provider name anywhere.
        for file in files where file.hasSuffix(".md") {
            let text = try String(contentsOf: directory.appendingPathComponent(file),
                                  encoding: .utf8)
            XCTAssertFalse(text.lowercased().contains("anthropic"), file)
            XCTAssertFalse(text.lowercased().contains("openai"), file)
        }
        // The unblind map is where providers are named.
        let unblind = try String(
            contentsOf: directory.appendingPathComponent("unblind.json"),
            encoding: .utf8)
        XCTAssertTrue(unblind.contains("anthropic"))
    }
}

// MARK: - Step 7 live benchmark (founder-run, key-gated)

/// The actual blind provider benchmark. Runs ONLY on the founder's
/// machine when Phase A keys and a console-verified OpenAI benchmark
/// model id are configured in LLMSecrets.plist — otherwise it skips.
/// Sequential live calls; the daily budget guard applies as usual.
final class TarotEvalBenchmarkTests: XCTestCase {

    func testRunBlindProviderBenchmark() async throws {
        guard LLMSecrets.apiKey(for: .anthropic) != nil,
              LLMSecrets.apiKey(for: .openai) != nil else {
            throw XCTSkip("Phase A keys not configured — live benchmark skipped.")
        }
        guard let openAIModel = LLMSecrets.configValue("TAROT_BENCHMARK_OPENAI_MODEL") else {
            throw XCTSkip("Set TAROT_BENCHMARK_OPENAI_MODEL in LLMSecrets.plist "
                + "(verify the exact model id in the OpenAI console first).")
        }
        let anthropicModel = LLMSecrets.configValue("TAROT_BENCHMARK_ANTHROPIC_MODEL")
            ?? "claude-sonnet-5"

        // Random blind assignment per run; unblind.json records it.
        let anthropicFirst = Bool.random()
        let arms: [TarotEvalHarness.BenchmarkArm] = [
            .init(blindLabel: anthropicFirst ? "model_a" : "model_b",
                  service: AnthropicLLMService(), model: anthropicModel),
            .init(blindLabel: anthropicFirst ? "model_b" : "model_a",
                  service: OpenAILLMService(), model: openAIModel),
        ].sorted { $0.blindLabel < $1.blindLabel }

        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("twinko-tarot-benchmark-\(UUID().uuidString.prefix(8))")
        let run = try await TarotEvalHarness.runBenchmark(
            cases: TarotGoldenCases.all, arms: arms, outputDirectory: directory)

        print("=== TAROT BLIND BENCHMARK ARTIFACTS ===")
        print(directory.path)
        print("Score the *.md sheets per REVIEW_GUIDE.md before opening unblind.json.")

        // The run is only useful if requests actually completed.
        let failed = run.evaluations.filter { $0.errorCategory != nil }
        XCTAssertTrue(failed.isEmpty,
                      "failed requests: \(failed.map { "\($0.caseID)/\($0.modelLabel): \($0.errorCategory!)" })")
    }
}
