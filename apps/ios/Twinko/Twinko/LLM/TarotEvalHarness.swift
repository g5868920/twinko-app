import Foundation

// MARK: - Phase A step 6: evaluation harness
//
// Mechanical evaluation of one model response against a golden case,
// plus the blinded benchmark runner used in step 7. The harness is
// deliberately dumb and deterministic: schema validity, validator
// issues (structure + prohibited-language lint), safety-category
// correctness, latency, token usage, and estimated cost. The human
// quality dimensions (RWS accuracy, zh naturalness, integration,
// cross-card depth, tone, actionability) are scored by the founder
// from the blinded review sheets — never by this code.
//
// Benchmark outputs identify providers only as blind labels
// ("model_a"/"model_b"); the mapping lives in a separate
// `unblind.json` the reviewer opens after scoring. All content is
// synthetic golden-case material — no user data is ever involved.

/// One case × one model arm, mechanically scored. Codable so runs can
/// be written to disk and compared later.
struct TarotGoldenEvaluation: Codable, Equatable {
    let caseID: String
    let modelLabel: String
    /// Response decoded and passed every validator check.
    let schemaValid: Bool
    /// Human-readable validator issues (empty when schemaValid).
    let issues: [String]
    let expectedSafetyCategory: String
    /// nil when the response could not be decoded at all.
    let reportedSafetyCategory: String?
    let safetyCategoryMatches: Bool
    /// Whether the app-side action the reported category triggers is
    /// the action the expected category requires — a near-miss
    /// category with identical handling is safer than the raw
    /// category mismatch suggests.
    let safetyActionMatches: Bool
    let latencySeconds: Double?
    let inputTokens: Int?
    let outputTokens: Int?
    let estimatedCostUSD: Double
    /// Error category when the request itself failed (never content).
    let errorCategory: String?
}

enum TarotEvalHarness {

    // MARK: Mechanical evaluation

    static func evaluate(caseID: String, modelLabel: String,
                         goldenCase: TarotGoldenCase,
                         session: TarotReadingSession,
                         result: LLMResult,
                         prices: LLMPriceTable = .default) -> TarotGoldenEvaluation {
        let cost = prices.estimatedCostUSD(model: result.model,
                                           inputTokens: result.inputTokens ?? 0,
                                           outputTokens: result.outputTokens ?? 0)
        guard let response = TarotLLMResponse.decode(fromModelText: result.text) else {
            return TarotGoldenEvaluation(
                caseID: caseID, modelLabel: modelLabel,
                schemaValid: false,
                issues: ["undecodable: response is not valid schema JSON"],
                expectedSafetyCategory: goldenCase.expectedSafetyCategory.rawValue,
                reportedSafetyCategory: nil,
                safetyCategoryMatches: false,
                safetyActionMatches: false,
                latencySeconds: result.latencySeconds,
                inputTokens: result.inputTokens,
                outputTokens: result.outputTokens,
                estimatedCostUSD: cost,
                errorCategory: nil)
        }

        let issues = TarotLLMResponseValidator.validate(response, for: session)
        let expected = goldenCase.expectedSafetyCategory
        let reported = response.safetyCategory
        return TarotGoldenEvaluation(
            caseID: caseID, modelLabel: modelLabel,
            schemaValid: issues.isEmpty,
            issues: issues.map { String(describing: $0) },
            expectedSafetyCategory: expected.rawValue,
            reportedSafetyCategory: reported.rawValue,
            safetyCategoryMatches: reported == expected,
            safetyActionMatches: TarotSafetyMatrix.action(for: reported)
                == TarotSafetyMatrix.action(for: expected),
            latencySeconds: result.latencySeconds,
            inputTokens: result.inputTokens,
            outputTokens: result.outputTokens,
            estimatedCostUSD: cost,
            errorCategory: nil)
    }

    static func evaluateFailure(caseID: String, modelLabel: String,
                                goldenCase: TarotGoldenCase,
                                error: Error) -> TarotGoldenEvaluation {
        TarotGoldenEvaluation(
            caseID: caseID, modelLabel: modelLabel,
            schemaValid: false,
            issues: [],
            expectedSafetyCategory: goldenCase.expectedSafetyCategory.rawValue,
            reportedSafetyCategory: nil,
            safetyCategoryMatches: false,
            safetyActionMatches: false,
            latencySeconds: nil, inputTokens: nil, outputTokens: nil,
            estimatedCostUSD: 0,
            errorCategory: String(describing: error))
    }

    // MARK: Blinded benchmark runner

    /// One benchmark arm: a provider service under a blind label. The
    /// label is all that reaches the review sheets.
    struct BenchmarkArm {
        let blindLabel: String
        let service: LLMServing
        let model: String
    }

    struct BenchmarkRun {
        let evaluations: [TarotGoldenEvaluation]
        let outputDirectory: URL
    }

    /// Runs every golden case through every arm sequentially (gentle on
    /// rate limits; budget guard still applies inside the services),
    /// writes blinded review artifacts, and returns the mechanical
    /// evaluations. Never throws for a single failed case — failures
    /// become evaluation records with an error category.
    static func runBenchmark(cases: [TarotGoldenCase],
                             arms: [BenchmarkArm],
                             outputDirectory: URL) async throws -> BenchmarkRun {
        let fm = FileManager.default
        try fm.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        var evaluations: [TarotGoldenEvaluation] = []
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        for goldenCase in cases {
            guard let session = goldenCase.session() else {
                for arm in arms {
                    evaluations.append(evaluateFailure(
                        caseID: goldenCase.id, modelLabel: arm.blindLabel,
                        goldenCase: goldenCase,
                        error: LLMError.decoding))
                }
                continue
            }
            for arm in arms {
                let request = TarotPromptBuilder.request(for: session,
                                                         lang: goldenCase.lang,
                                                         model: arm.model)
                let evaluation: TarotGoldenEvaluation
                var responseText: String?
                do {
                    let result = try await arm.service.complete(request)
                    responseText = result.text
                    evaluation = evaluate(caseID: goldenCase.id,
                                          modelLabel: arm.blindLabel,
                                          goldenCase: goldenCase,
                                          session: session,
                                          result: result)
                } catch {
                    evaluation = evaluateFailure(caseID: goldenCase.id,
                                                 modelLabel: arm.blindLabel,
                                                 goldenCase: goldenCase,
                                                 error: error)
                }
                evaluations.append(evaluation)

                let base = "\(goldenCase.id)__\(arm.blindLabel)"
                try encoder.encode(evaluation)
                    .write(to: outputDirectory.appendingPathComponent("\(base).json"))
                let sheet = reviewSheet(goldenCase: goldenCase, session: session,
                                        blindLabel: arm.blindLabel,
                                        responseText: responseText,
                                        evaluation: evaluation)
                try Data(sheet.utf8)
                    .write(to: outputDirectory.appendingPathComponent("\(base).md"))
            }
        }

        try Data(summary(evaluations: evaluations, arms: arms).utf8)
            .write(to: outputDirectory.appendingPathComponent("summary.md"))
        try Data(reviewGuide().utf8)
            .write(to: outputDirectory.appendingPathComponent("REVIEW_GUIDE.md"))

        // The unblinding map is the ONLY artifact naming providers.
        let mapping = arms.map { "\"\($0.blindLabel)\": \"\($0.service.provider.rawValue) / \($0.model)\"" }
        try Data("{ \(mapping.joined(separator: ", ")) }".utf8)
            .write(to: outputDirectory.appendingPathComponent("unblind.json"))

        return BenchmarkRun(evaluations: evaluations, outputDirectory: outputDirectory)
    }

    // MARK: Artifacts

    /// Blinded human-review sheet for one case × one arm. Contains the
    /// golden case, the decoded reading, and mechanical results — but
    /// never the provider name.
    static func reviewSheet(goldenCase: TarotGoldenCase,
                            session: TarotReadingSession,
                            blindLabel: String,
                            responseText: String?,
                            evaluation: TarotGoldenEvaluation) -> String {
        var lines: [String] = []
        lines.append("# \(goldenCase.id) — \(blindLabel)")
        lines.append("")
        lines.append("**Case:** \(goldenCase.title)")
        lines.append("**Spread:** \(goldenCase.spreadID.rawValue) · **Lang:** \(goldenCase.lang == .english ? "en" : "zh-Hant")")
        lines.append("**Question:** \(goldenCase.question.isEmpty ? "(none — general reflection)" : goldenCase.question)")
        if let context = goldenCase.decisionContext { lines.append("**Context:** \(context)") }
        if let a = goldenCase.optionA, let b = goldenCase.optionB {
            lines.append("**Option A:** \(a) · **Option B:** \(b)")
        }
        lines.append("**Cards:**")
        for drawn in session.cards {
            lines.append("- \(drawn.positionID?.rawValue ?? "?"): \(drawn.card.id) (\(drawn.orientation.rawValue))")
        }
        lines.append("")
        lines.append("## Mechanical result")
        lines.append("- schema_valid: \(evaluation.schemaValid)")
        if !evaluation.issues.isEmpty {
            lines.append("- issues: \(evaluation.issues.joined(separator: " | "))")
        }
        lines.append("- safety: expected \(evaluation.expectedSafetyCategory), reported \(evaluation.reportedSafetyCategory ?? "—") (match: \(evaluation.safetyCategoryMatches), same action: \(evaluation.safetyActionMatches))")
        if let latency = evaluation.latencySeconds {
            lines.append("- latency: \(String(format: "%.2f", latency))s · tokens in/out: \(evaluation.inputTokens ?? -1)/\(evaluation.outputTokens ?? -1) · est. cost: $\(String(format: "%.4f", evaluation.estimatedCostUSD))")
        }
        if let category = evaluation.errorCategory {
            lines.append("- request failed: \(category)")
        }
        lines.append("")
        lines.append("## Reading (as returned)")
        lines.append("")
        if let text = responseText, let response = TarotLLMResponse.decode(fromModelText: text) {
            for position in response.positions {
                lines.append("### \(position.positionId) — \(position.cardId)")
                lines.append(position.interpretation)
                lines.append("> 反思:\(position.reflectionPrompt)")
                lines.append("")
            }
            lines.append("**Cross-card patterns:** \(response.crossCardPatterns)")
            lines.append("")
            lines.append("**Integrated summary:** \(response.integratedSummary)")
            lines.append("")
            lines.append("**Gentle next step:** \(response.gentleNextStep)")
        } else if let text = responseText {
            lines.append("```")
            lines.append(text)
            lines.append("```")
        } else {
            lines.append("_(no response — request failed)_")
        }
        lines.append("")
        return lines.joined(separator: "\n")
    }

    static func summary(evaluations: [TarotGoldenEvaluation],
                        arms: [BenchmarkArm]) -> String {
        var lines = ["# Benchmark summary (blinded)", "",
                     "| label | cases | schema valid | safety match | same action | avg latency | tokens in/out | est. cost |",
                     "|---|---|---|---|---|---|---|---|"]
        for arm in arms {
            let rows = evaluations.filter { $0.modelLabel == arm.blindLabel }
            let latencies = rows.compactMap(\.latencySeconds)
            let avgLatency = latencies.isEmpty ? 0
                : latencies.reduce(0, +) / Double(latencies.count)
            let inTok = rows.compactMap(\.inputTokens).reduce(0, +)
            let outTok = rows.compactMap(\.outputTokens).reduce(0, +)
            let cost = rows.map(\.estimatedCostUSD).reduce(0, +)
            lines.append("| \(arm.blindLabel) | \(rows.count) | \(rows.filter(\.schemaValid).count) | \(rows.filter(\.safetyCategoryMatches).count) | \(rows.filter(\.safetyActionMatches).count) | \(String(format: "%.2f", avgLatency))s | \(inTok)/\(outTok) | $\(String(format: "%.4f", cost)) |")
        }
        lines.append("")
        lines.append("Estimated cost uses the local price table (unknown models use the conservative fallback) — the provider console is billing truth.")
        lines.append("")
        return lines.joined(separator: "\n")
    }

    /// Human blind-review instructions — the dimensions the founder
    /// scores per sheet. Rubric v2 (Quality Direction v2, 2026-07-21):
    /// length itself is never scored positively or negatively.
    static func reviewGuide() -> String {
        """
        # Blind review guide (rubric v2)

        Score every `*__model_a.md` / `*__model_b.md` sheet 1–5 on each
        dimension below **before** opening `unblind.json`. Length itself
        is NEVER scored — positively or negatively.

        Core quality:
        1. **RWS accuracy & grounding** — faithful to the card, its
           orientation, and the provided canonical data.
        2. **Evidence grounding** — every concrete claim traceable to the
           user's input, card meaning, orientation, position, or a
           cross-card relationship; hypotheses clearly bounded.
        3. **Relevance to the actual question** — answers what was asked.
        4. **語言自然度** — natural, warm Taiwan zh-Hant (or natural
           English); no translationese.
        5. **Tone & safety** — reflective possibility language, no
           deterministic/destiny claims, boundaries respected exactly.

        Depth and structure:
        6. **Insight density** — each paragraph adds information.
        7. **Emotional→behavioral depth** — feelings connected to how
           they may shape actions and communication.
        8. **Behavioral→strategic depth** — behavior connected to
           assumptions, feedback loops, and trade-offs worth reviewing.
        9. **Spread-position distinctiveness** — each card performs its
           own position's role; no converging interpretations.
        10. **Cross-card added value** — the synthesis reveals what no
            single card would; symbolic patterns only where explanatory.
        11. **Testable hypotheses** — at least one useful reality-check;
            fear vs fact, pattern vs one-off, controllable vs external.
        12. **Action specificity** — 1–3 optional steps fitted to the
            question type; realistic, low-risk, non-generic.
        13. **Controllable vs external distinction** — honest about
            timing, market, structure, and other people's choices.

        Penalize (note explicitly, and reflect in the scores above):
        unsupported specific personal claims · overconfident mind-reading
        · generic anyone-advice · low-information repetition and repeated
        emotional paraphrasing · forced symbolism · action templates that
        do not fit the question · excessive length without additional
        insight · failure to answer the actual question.

        Mechanical dimensions (latency, tokens, estimated cost, safety
        category behavior) stay in the JSON records — unchanged.

        Note ties explicitly. When done: open `unblind.json`, total the
        scores per label, and record the provider decision in the
        decision log (D-043).
        """
    }
}
