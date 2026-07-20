import XCTest
@testable import Twinko

/// Phase A Task 2 protection: schema decode + validation, safety
/// matrix behaviors, and the grounded prompt builder. No network.
final class TarotLLMSchemaTests: XCTestCase {

    private struct SeededRNG: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
    }

    private func makeSession(_ spreadID: TarotSpreadID = .coreClarityFour)
        -> TarotReadingSession {
        var engine = TarotDrawEngine(rng: SeededRNG(state: 7))
        var session = TarotReadingSession(spreadID: spreadID, topic: .growth,
                                          question: "我為什麼一直卡住？")
        session.cards = engine.draw(spreadID: spreadID)
        return session
    }

    private func validResponse(for session: TarotReadingSession) -> TarotLLMResponse {
        TarotLLMResponse(
            positions: session.cards.map { drawn in
                .init(positionId: drawn.positionID!.rawValue,
                      cardId: drawn.card.id,
                      interpretation: "這張牌可能反映了一種值得留意的狀態。",
                      reflectionPrompt: "今天有什麼小事呼應了它？")
            },
            crossCardPatterns: "整體元素偏向行動,值得留意平衡。",
            integratedSummary: "把牌放在一起看,是一個可以慢慢想的角度。",
            gentleNextStep: "先為自己做一件小小的事。",
            safetyCategory: .none)
    }

    // MARK: 1 — Schema decode + validation

    func testDecodeFromModelTextIncludingFencedJSON() throws {
        let session = makeSession()
        let response = validResponse(for: session)
        let json = String(data: try JSONEncoder().encode(response), encoding: .utf8)!

        XCTAssertEqual(TarotLLMResponse.decode(fromModelText: json), response)
        XCTAssertEqual(TarotLLMResponse.decode(
            fromModelText: "```json\n\(json)\n```"), response,
            "Fenced output must still decode")
        XCTAssertNil(TarotLLMResponse.decode(fromModelText: "not json at all"))
    }

    func testValidatorAcceptsAMatchingResponse() {
        let session = makeSession()
        let issues = TarotLLMResponseValidator.validate(validResponse(for: session),
                                                        for: session)
        XCTAssertTrue(issues.isEmpty, "\(issues)")
    }

    func testValidatorCatchesStructuralProblems() {
        let session = makeSession()
        let good = validResponse(for: session)

        // Missing a position.
        var missing = good
        missing = TarotLLMResponse(positions: Array(good.positions.dropLast()),
                                   crossCardPatterns: good.crossCardPatterns,
                                   integratedSummary: good.integratedSummary,
                                   gentleNextStep: good.gentleNextStep,
                                   safetyCategory: .none)
        XCTAssertTrue(TarotLLMResponseValidator.validate(missing, for: session)
            .contains(.positionCountMismatch(expected: 4, got: 3)))

        // Unknown position id.
        var wrongPositions = good.positions
        wrongPositions[0] = .init(positionId: "made_up", cardId: wrongPositions[0].cardId,
                                  interpretation: "x", reflectionPrompt: "y")
        let unknown = TarotLLMResponse(positions: wrongPositions,
                                       crossCardPatterns: good.crossCardPatterns,
                                       integratedSummary: good.integratedSummary,
                                       gentleNextStep: good.gentleNextStep,
                                       safetyCategory: .none)
        XCTAssertTrue(TarotLLMResponseValidator.validate(unknown, for: session)
            .contains(.unknownPosition("made_up")))

        // Card swapped between positions.
        var swapped = good.positions
        swapped[0] = .init(positionId: swapped[0].positionId,
                           cardId: good.positions[1].cardId,
                           interpretation: "x", reflectionPrompt: "y")
        let mismatch = TarotLLMResponse(positions: swapped,
                                        crossCardPatterns: good.crossCardPatterns,
                                        integratedSummary: good.integratedSummary,
                                        gentleNextStep: good.gentleNextStep,
                                        safetyCategory: .none)
        XCTAssertTrue(TarotLLMResponseValidator.validate(mismatch, for: session)
            .contains(.cardMismatch(positionId: swapped[0].positionId)))
    }

    func testValidatorLintsProhibitedLanguageInBothLanguages() {
        let session = makeSession()
        let good = validResponse(for: session)
        let banned = TarotLLMResponse(positions: good.positions,
                                      crossCardPatterns: good.crossCardPatterns,
                                      integratedSummary: "你們注定會在一起。",
                                      gentleNextStep: "You should choose A.",
                                      safetyCategory: .none)
        let issues = TarotLLMResponseValidator.validate(banned, for: session)
        XCTAssertTrue(issues.contains {
            if case .bannedLanguage(let field, _) = $0 { return field == "integrated_summary" }
            return false
        })
        XCTAssertTrue(issues.contains {
            if case .bannedLanguage(let field, _) = $0 { return field == "gentle_next_step" }
            return false
        })
    }

    // MARK: 2 — Safety matrix (draft v0.1)

    func testSafetyMatrixDraftBehaviors() {
        let none = TarotSafetyMatrix.action(for: .none)
        XCTAssertTrue(none.allowNormalInterpretation)
        XCTAssertTrue(none.allowGuidanceCardCTA)
        XCTAssertFalse(none.showStrongerDisclaimer)

        let crisis = TarotSafetyMatrix.action(for: .selfHarmCrisis)
        XCTAssertFalse(crisis.allowNormalInterpretation)
        XCTAssertTrue(crisis.replaceWithSupportiveResponse)
        XCTAssertFalse(crisis.allowGuidanceCardCTA)
        XCTAssertTrue(crisis.showProfessionalResources)

        let medical = TarotSafetyMatrix.action(for: .medicalDiagnosis)
        XCTAssertFalse(medical.allowNormalInterpretation)
        XCTAssertTrue(medical.showProfessionalResources)

        let legal = TarotSafetyMatrix.action(for: .legalDecision)
        XCTAssertTrue(legal.allowNormalInterpretation)
        XCTAssertTrue(legal.showStrongerDisclaimer)

        let mindReading = TarotSafetyMatrix.action(for: .relationshipMindReading)
        XCTAssertTrue(mindReading.allowNormalInterpretation)
        XCTAssertTrue(mindReading.showStrongerDisclaimer)

        // Supportive copy exists exactly where interpretation is replaced.
        for category in TarotLLMSafetyCategory.allCases {
            let action = TarotSafetyMatrix.action(for: category)
            for lang in AppLanguage.allCases {
                let copy = TarotSafetyMatrix.supportiveResponse(for: category, lang: lang)
                if action.replaceWithSupportiveResponse {
                    XCTAssertNotNil(copy, "\(category) \(lang)")
                    // Supportive copy itself passes the language lint.
                    XCTAssertNil(TarotLLMResponseValidator.lint(copy ?? ""))
                }
            }
        }
    }

    // MARK: 3 — Grounded prompt builder

    func testPromptGroundsRegistryKnowledgeAndContext() {
        var session = makeSession(.twoChoiceFive)
        session.decisionContext = "我正在比較兩個工作選擇"
        session.optionA = "留在目前公司"
        session.optionB = "接受新的工作邀請"

        let prompt = TarotPromptBuilder.build(for: session, lang: .traditionalChinese)

        // System: safety rules, schema, no fabricated persona.
        XCTAssertTrue(prompt.system.contains("Rider-Waite-Smith"))
        XCTAssertTrue(prompt.system.contains("safety_category"))
        XCTAssertTrue(prompt.system.contains("never declare a winner"))
        XCTAssertFalse(prompt.system.lowercased().contains("years of experience"),
                       "No invented credentials")

        // User: question, options, and every card's grounded data.
        XCTAssertTrue(prompt.user.contains("我正在比較兩個工作選擇"))
        XCTAssertTrue(prompt.user.contains("Option A: 留在目前公司"))
        for drawn in session.cards {
            XCTAssertTrue(prompt.user.contains(drawn.card.id))
            XCTAssertTrue(prompt.user.contains(drawn.positionID!.rawValue))
            let upright = drawn.orientation == .upright
            let keywords = upright ? drawn.card.keywordsUprightZh
                                   : drawn.card.keywordsReversedZh
            XCTAssertTrue(prompt.user.contains(keywords[0]),
                          "grounded keyword present for \(drawn.card.id)")
        }
        // The schema in the system prompt lists this spread's positions.
        XCTAssertTrue(prompt.system.contains("optionAState"))

        // English build carries English grounding, and the language
        // instruction differs.
        let en = TarotPromptBuilder.build(for: session, lang: .english)
        XCTAssertTrue(en.system.contains("natural, warm English"))
        XCTAssertTrue(en.user.contains(session.cards[0].card.displayNameEn))

        // Transport convenience uses jsonMode and respects the cap.
        let request = TarotPromptBuilder.request(for: session,
                                                 lang: .traditionalChinese,
                                                 model: "claude-sonnet-5")
        XCTAssertTrue(request.jsonMode)
        XCTAssertLessThanOrEqual(request.maxOutputTokens,
                                 LLMSafeguards.maxOutputTokensCap)
    }
}
