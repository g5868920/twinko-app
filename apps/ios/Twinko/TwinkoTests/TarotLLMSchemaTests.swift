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
        XCTAssertEqual(none.policy, .allowReflectiveReading)
        XCTAssertTrue(none.allowNormalInterpretation)
        XCTAssertTrue(none.allowGuidanceCardCTA)
        XCTAssertFalse(none.showStrongerDisclaimer)

        let crisis = TarotSafetyMatrix.action(for: .selfHarmCrisis)
        XCTAssertEqual(crisis.policy, .replaceWithSupport)
        XCTAssertFalse(crisis.allowNormalInterpretation)
        XCTAssertTrue(crisis.replaceWithSupportiveResponse)
        XCTAssertFalse(crisis.allowGuidanceCardCTA)
        XCTAssertTrue(crisis.showProfessionalResources)

        let medical = TarotSafetyMatrix.action(for: .medicalDiagnosis)
        XCTAssertEqual(medical.policy, .replaceWithSupport)
        XCTAssertFalse(medical.allowNormalInterpretation)
        XCTAssertTrue(medical.showProfessionalResources)

        // v0.2: legal, financial, and mind-reading require a
        // user-approved reframe — no interpretation, no Guidance.
        for category in [TarotLLMSafetyCategory.legalDecision,
                         .financialDecision, .relationshipMindReading] {
            let action = TarotSafetyMatrix.action(for: category)
            XCTAssertEqual(action.policy, .requireUserApprovedReframe, "\(category)")
            XCTAssertFalse(action.allowNormalInterpretation, "\(category)")
            XCTAssertFalse(action.allowGuidanceCardCTA, "\(category)")
            XCTAssertTrue(action.showStrongerDisclaimer, "\(category)")
            // Each reframe category ships a lint-clean bilingual
            // suggestion; crisis/replacement categories never do.
            for lang in AppLanguage.allCases {
                let suggestion = TarotSafetyMatrix.reframeSuggestion(for: category,
                                                                     lang: lang)
                XCTAssertNotNil(suggestion, "\(category) \(lang)")
                XCTAssertNil(TarotLLMResponseValidator.lint(suggestion ?? ""))
            }
        }
        XCTAssertNil(TarotSafetyMatrix.reframeSuggestion(for: .selfHarmCrisis,
                                                         lang: .traditionalChinese),
                     "replacement categories never enter the reframe flow")

        // Full coverage (correction 3): every canonical category has a
        // complete action row; replacement/refusal categories carry
        // lint-clean bilingual supportive copy; the refusal category
        // never allows any reading or Guidance.
        XCTAssertEqual(TarotLLMSafetyCategory.allCases.count, 12,
                       "11 risk categories + none")
        for category in TarotLLMSafetyCategory.allCases {
            let action = TarotSafetyMatrix.action(for: category)
            if category != .none {
                XCTAssertTrue(action.showStrongerDisclaimer, "\(category)")
            }
            if action.policy == .replaceWithSupport || action.policy == .refuseRequest {
                XCTAssertFalse(action.allowNormalInterpretation, "\(category)")
                XCTAssertFalse(action.allowGuidanceCardCTA, "\(category)")
            }
            for lang in AppLanguage.allCases {
                let copy = TarotSafetyMatrix.supportiveResponse(for: category, lang: lang)
                if action.replaceWithSupportiveResponse {
                    XCTAssertNotNil(copy, "\(category) \(lang)")
                    // Supportive copy itself passes the language lint.
                    XCTAssertNil(TarotLLMResponseValidator.lint(copy ?? ""))
                }
            }
        }
        XCTAssertEqual(TarotSafetyMatrix.action(for: .minorSexualSafety).policy,
                       .refuseRequest)
    }

    // MARK: 2a — Table-driven Safety Matrix contract (all 12 categories)

    /// Policy-wiring contract: one row per canonical category. This
    /// verifies the matrix wiring, not classifier accuracy. `logID` is
    /// the stable snake_case value that category-only logging emits —
    /// never user content.
    func testSafetyMatrixContractCoversEveryCategory() {
        typealias P = TarotSafetyPolicyAction
        // (category, logID, policy, interp, reframe, replacement,
        //  guidance, resources)
        let table: [(TarotLLMSafetyCategory, String, P, Bool, Bool, Bool, Bool, Bool)] = [
            (.none, "none", .allowReflectiveReading, true, false, false, true, false),
            (.selfHarmCrisis, "self_harm_crisis", .replaceWithSupport,
             false, false, true, false, true),
            (.harmToOthers, "harm_to_others", .replaceWithSupport,
             false, false, true, false, true),
            (.abuseUnsafeRelationship, "abuse_unsafe_relationship", .replaceWithSupport,
             false, false, true, false, true),
            (.medicalDiagnosis, "medical_diagnosis", .replaceWithSupport,
             false, false, true, false, true),
            (.legalDecision, "legal_decision", .requireUserApprovedReframe,
             false, true, false, false, true),
            (.financialDecision, "financial_decision", .requireUserApprovedReframe,
             false, true, false, false, false),
            (.pregnancyDeathPrediction, "pregnancy_death_prediction", .replaceWithSupport,
             false, false, true, false, false),
            (.relationshipMindReading, "relationship_mind_reading", .requireUserApprovedReframe,
             false, true, false, false, false),
            (.realityDistortion, "reality_distortion", .replaceWithSupport,
             false, false, true, false, true),
            (.minorSexualSafety, "minor_sexual_safety", .refuseRequest,
             false, false, true, false, true),
            (.substanceRisk, "substance_risk", .replaceWithSupport,
             false, false, true, false, true),
        ]
        XCTAssertEqual(table.count, TarotLLMSafetyCategory.allCases.count,
                       "every canonical category has exactly one contract row")
        XCTAssertEqual(Set(table.map(\.0)), Set(TarotLLMSafetyCategory.allCases))

        for (category, logID, policy, interp, reframe, replace,
             guidance, resources) in table {
            let action = TarotSafetyMatrix.action(for: category)
            XCTAssertEqual(category.rawValue, logID,
                           "category-only logging emits this stable id")
            XCTAssertEqual(action.policy, policy, "\(category)")
            XCTAssertEqual(action.allowNormalInterpretation, interp, "\(category)")
            XCTAssertEqual(action.allowGuidanceCardCTA, guidance, "\(category)")
            XCTAssertEqual(action.replaceWithSupportiveResponse, replace, "\(category)")
            XCTAssertEqual(action.showProfessionalResources, resources, "\(category)")
            // Reframe availability exactly matches the policy: a
            // bilingual suggestion exists iff a reframe is permitted.
            for lang in AppLanguage.allCases {
                XCTAssertEqual(
                    TarotSafetyMatrix.reframeSuggestion(for: category, lang: lang) != nil,
                    reframe, "\(category) \(lang)")
                // Replacement/refusal behavior: supportive copy exists
                // exactly where the reading is withheld and replaced.
                XCTAssertEqual(
                    TarotSafetyMatrix.supportiveResponse(for: category, lang: lang,
                                                         region: .unknown) != nil,
                    replace, "\(category) \(lang)")
            }
        }
    }

    /// Region-based crisis resources: mapping follows REGION, never UI
    /// language. Taiwan never resolves to 988; US 988 stays scoped to
    /// self-harm crisis in the US; unknown regions never see a number.
    func testCrisisResourcesFollowRegionNotLanguage() {
        // An English-language user in Taiwan gets Taiwan resources.
        let enInTaiwan = TarotSafetyMatrix.supportiveResponse(
            for: .selfHarmCrisis, lang: .english, region: .taiwan)!
        XCTAssertTrue(enInTaiwan.contains("1925"))
        XCTAssertFalse(enInTaiwan.contains("988"),
                       "Taiwan must never resolve to US 988")

        // 988 is scoped to the United States only.
        let usCrisis = TarotSafetyMatrix.supportiveResponse(
            for: .selfHarmCrisis, lang: .english, region: .unitedStates)!
        XCTAssertTrue(usCrisis.contains("988"))
        for lang in AppLanguage.allCases {
            let zhTW = TarotSafetyMatrix.supportiveResponse(
                for: .selfHarmCrisis, lang: lang, region: .taiwan)!
            XCTAssertFalse(zhTW.contains("988"), "\(lang)")
        }

        // Taiwan protection/emergency mappings.
        XCTAssertTrue(TarotSafetyMatrix.supportiveResponse(
            for: .abuseUnsafeRelationship, lang: .traditionalChinese,
            region: .taiwan)!.contains("113"))
        XCTAssertTrue(TarotSafetyMatrix.supportiveResponse(
            for: .substanceRisk, lang: .traditionalChinese,
            region: .taiwan)!.contains("119"))

        // Unknown region: no digits, explicit no-mapping honesty.
        for category in [TarotLLMSafetyCategory.selfHarmCrisis,
                         .abuseUnsafeRelationship, .substanceRisk,
                         .minorSexualSafety, .harmToOthers, .realityDistortion] {
            for lang in AppLanguage.allCases {
                let copy = TarotSafetyMatrix.supportiveResponse(
                    for: category, lang: lang, region: .unknown)!
                XCTAssertNil(copy.rangeOfCharacter(from: .decimalDigits),
                             "\(category) \(lang): no unverified number for unknown regions")
            }
        }

        // US categories without a verified US mapping fall back to the
        // number-free wording (e.g. abuse) — never a borrowed number.
        let usAbuse = TarotSafetyMatrix.supportiveResponse(
            for: .abuseUnsafeRelationship, lang: .english, region: .unitedStates)!
        XCTAssertNil(usAbuse.rangeOfCharacter(from: .decimalDigits))

        // Pure region mapping.
        XCTAssertEqual(TarotCrisisRegion.from(localeRegion: "TW"), .taiwan)
        XCTAssertEqual(TarotCrisisRegion.from(localeRegion: "us"), .unitedStates)
        XCTAssertEqual(TarotCrisisRegion.from(localeRegion: "JP"), .unknown)
        XCTAssertEqual(TarotCrisisRegion.from(localeRegion: nil), .unknown)
    }

    // MARK: 2b — Deterministic pre-reading preflight (first layer)

    func testPreflightGatesRestrictedQuestionsAndPassesBenignOnes() {
        typealias M = TarotSafetyMatrix
        // Benign reflective questions must pass — over-blocking is a
        // failure mode too.
        XCTAssertEqual(M.preflightCategory(question: "我為什麼一直卡住？"), .none)
        XCTAssertEqual(M.preflightCategory(question: "今天的我，最需要留意什麼？"), .none)
        XCTAssertEqual(M.preflightCategory(question: ""), .none)
        XCTAssertEqual(M.preflightCategory(
            question: "What should I keep in mind about my work stress this week?"), .none)

        // High-stakes phrasings gate before any card is drawn.
        XCTAssertEqual(M.preflightCategory(
            question: "最近真的撐不下去了，常常想著如果我消失就好了。"), .selfHarmCrisis)
        XCTAssertEqual(M.preflightCategory(question: "我是不是得了重病？"), .medicalDiagnosis)
        XCTAssertEqual(M.preflightCategory(question: "這場官司我會勝訴嗎？"), .legalDecision)
        XCTAssertEqual(M.preflightCategory(question: "我該不該投資這支股票？"),
                       .financialDecision)
        XCTAssertEqual(M.preflightCategory(question: "我這個月會懷孕嗎？"),
                       .pregnancyDeathPrediction)
        XCTAssertEqual(M.preflightCategory(question: "他心裡在想什麼？是不是偷吃？"),
                       .relationshipMindReading)
        XCTAssertEqual(M.preflightCategory(question: "有人在監視我、控制我的思想"),
                       .realityDistortion)
        XCTAssertEqual(M.preflightCategory(question: "他會打我，我不敢離開他"),
                       .abuseUnsafeRelationship)
        XCTAssertEqual(M.preflightCategory(question: "Is he cheating on me?"),
                       .relationshipMindReading)

        // Context fields participate (Two-Choice financial options).
        XCTAssertEqual(M.preflightCategory(question: "哪個對我比較好？",
                                           optionA: "全部投入加密貨幣",
                                           optionB: "定存"), .financialDecision)
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

        // Quality Direction v2 contract (prompt-level, schema unchanged):
        // evidence boundary + invented-detail prohibition present.
        XCTAssertTrue(prompt.system.contains("EVIDENCE BOUNDARY"))
        XCTAssertTrue(prompt.system.contains("Never invent specific recent"))
        // Insight density block present.
        XCTAssertTrue(prompt.system.contains("INSIGHT DENSITY"))
        // Symbolic patterns are optional raw material, not a checklist.
        XCTAssertTrue(prompt.system.contains("not a checklist"))
        // Actions adapt to the question type — never one template.
        XCTAssertTrue(prompt.system.contains("never force one template"))
        // Card-count-aware length guidance: five-card concentrates depth
        // in the synthesis; one-card allows a deeper single reading.
        XCTAssertTrue(prompt.system.contains("concentrate depth in the integrated"))
        let single = TarotPromptBuilder.build(for: makeSession(.singleCard),
                                              lang: .traditionalChinese)
        XCTAssertTrue(single.system.contains("one-card reading: a deeper single"))
        // The rigid sentence count is gone (no padding-forcing rule).
        XCTAssertFalse(prompt.system.contains("3–5 sentences"))

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
