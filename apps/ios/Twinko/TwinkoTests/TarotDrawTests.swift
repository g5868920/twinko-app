import XCTest
@testable import Twinko

/// Deterministic RNG for tests only (SplitMix64) — production draws
/// always use the system RNG.
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

final class TarotDrawTests: XCTestCase {

    // MARK: Registry

    func testRegistryLoadsAllSeventyEightCards() {
        XCTAssertEqual(TarotRegistry.cards.count, 78)
        XCTAssertEqual(Set(TarotRegistry.cards.map(\.id)).count, 78, "Card ids must be unique")
        XCTAssertEqual(TarotRegistry.cards.filter { $0.arcanaType == "major" }.count, 22)
        for card in TarotRegistry.cards {
            XCTAssertFalse(card.displayNameEn.isEmpty)
            XCTAssertFalse(card.displayNameZh.isEmpty)
            XCTAssertTrue(card.assetFileName.hasSuffix(".png"))
        }
    }

    // MARK: Draw engine (Task 2 §46B.1/.3 — counts, uniqueness, order)

    /// Every canonical MVP spread draws exactly its card count, with
    /// unique cards assigned in canonical position order, base role.
    func testDrawMatchesCanonicalCountUniquenessAndPositionOrder() {
        for spreadID in TarotSpreadID.allCases {
            let definition = TarotSpreadLibrary.definition(for: spreadID)
            var engine = TarotDrawEngine(rng: SeededRNG(state: 17))
            let cards = engine.draw(spreadID: spreadID)
            XCTAssertEqual(cards.count, definition.cardCount, "\(spreadID) count")
            XCTAssertEqual(Set(cards.map(\.card.id)).count, definition.cardCount,
                           "\(spreadID): no duplicate base cards")
            XCTAssertEqual(cards.map(\.positionID), definition.positionIDs.map { $0 },
                           "\(spreadID): canonical position order")
            XCTAssertTrue(cards.allSatisfy { $0.role == .basePosition })
        }
    }

    func testGuidanceDrawNeverDuplicatesReadingForAnySpread() {
        for spreadID in [TarotSpreadID.singleCard, .coreClarityFour,
                         .twoChoiceFive, .relationshipFive] {
            for seed in 0..<25 {
                var engine = TarotDrawEngine(rng: SeededRNG(state: UInt64(seed)))
                let base = engine.draw(spreadID: spreadID)
                let guidance = engine.drawGuidance(excluding: base)
                XCTAssertNotNil(guidance)
                XCTAssertEqual(guidance?.role, .guidance)
                XCTAssertNil(guidance?.positionID,
                             "Guidance Card is never a numbered position")
                XCTAssertFalse(base.map(\.card.id).contains(guidance!.card.id),
                               "Guidance card must come from the remaining deck (\(spreadID))")
            }
        }
    }

    func testOrientationIsRandomizedBothWaysOverManyDraws() {
        var engine = TarotDrawEngine(rng: SeededRNG(state: 7))
        var seen = Set<TarotOrientation>()
        for _ in 0..<40 {
            seen.formUnion(engine.draw(spreadID: .singleCard).map(\.orientation))
        }
        XCTAssertEqual(seen, [.upright, .reversed],
                       "Both orientations must occur — reversed cards are required")
    }

    func testDrawSpansTheFullDeckOverManyDraws() {
        var engine = TarotDrawEngine(rng: SeededRNG(state: 11))
        var seen = Set<String>()
        for _ in 0..<300 {
            seen.formUnion(engine.draw(spreadID: .timelineThree).map(\.card.id))
        }
        XCTAssertGreaterThan(seen.count, 70, "Unbiased draws should reach nearly all 78 cards")
    }

    func testSeededDrawIsDeterministicForTests() {
        var a = TarotDrawEngine(rng: SeededRNG(state: 42))
        var b = TarotDrawEngine(rng: SeededRNG(state: 42))
        let first = a.draw(spreadID: .timelineThree)
        let second = b.draw(spreadID: .timelineThree)
        XCTAssertEqual(first.map(\.card.id), second.map(\.card.id))
        XCTAssertEqual(first.map(\.orientation), second.map(\.orientation))
    }

    // MARK: Session stability (Task 2 §46B.2)

    private func makeSession(_ spreadID: TarotSpreadID, guidance: Bool = false,
                             seed: UInt64 = 5) -> TarotReadingSession {
        var engine = TarotDrawEngine(rng: SeededRNG(state: seed))
        var session = TarotReadingSession(spreadID: spreadID, topic: .relationships,
                                          question: "測試問題")
        session.cards = engine.draw(spreadID: spreadID)
        if guidance {
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)
        }
        return session
    }

    /// Card identity, orientation, position, and reveal state stay
    /// stable on the session through reveal marking and a guidance
    /// draw; only an explicit new session resets them.
    func testSessionStateStaysStableThroughRevealAndGuidance() {
        for spreadID in [TarotSpreadID.holisticCheckInThree, .coreClarityFour,
                         .twoChoiceFive] {
            var session = makeSession(spreadID)
            let ids = session.cards.map(\.card.id)
            let orientations = session.cards.map(\.orientation)
            let positions = session.cards.map(\.positionID)

            // Reveal marking is per-position, idempotent, and additive.
            for drawn in session.cards {
                session.markRevealed(drawn.positionID)
                session.markRevealed(drawn.positionID) // rapid re-tap
            }
            XCTAssertEqual(session.revealedPositionIDs,
                           Set(session.definition.positionIDs), "\(spreadID)")
            session.revealSeen = true

            var engine = TarotDrawEngine(rng: SeededRNG(state: 3))
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)

            XCTAssertEqual(session.cards.map(\.card.id), ids,
                           "Same cards — never redrawn (\(spreadID))")
            XCTAssertEqual(session.cards.map(\.orientation), orientations,
                           "Orientation unchanged (\(spreadID))")
            XCTAssertEqual(session.cards.map(\.positionID), positions,
                           "Positions unchanged (\(spreadID))")
            XCTAssertTrue(session.revealSeen)
            XCTAssertEqual(session.revealedPositionIDs.count,
                           session.definition.cardCount,
                           "Guidance draw never resets reveal state (\(spreadID))")

            // Only an explicit new reading resets — and gets a new ID.
            let restarted = TarotReadingSession(spreadID: spreadID)
            XCTAssertNotEqual(restarted.id, session.id)
            XCTAssertTrue(restarted.cards.isEmpty)
            XCTAssertTrue(restarted.revealedPositionIDs.isEmpty)
            XCTAssertFalse(restarted.revealSeen)
            XCTAssertNil(restarted.guidanceCard)
        }
    }

    func testGuidanceCardIsOneDrawPerReading() {
        var session = makeSession(.singleCard)
        XCTAssertTrue(session.canDrawGuidance)
        var engine = TarotDrawEngine(rng: SeededRNG(state: 9))
        session.guidanceCard = engine.drawGuidance(excluding: session.cards)
        XCTAssertNotNil(session.guidanceCard)
        XCTAssertFalse(session.canDrawGuidance,
                       "Once drawn, no further Guidance Card is offered")
    }

    /// The launch request copies validated inputs verbatim onto the
    /// session — never re-recommended, manual selection wins.
    func testSessionFromLaunchRequestCopiesValidatedInputs() {
        var draft = TarotReadingDraft(intent: .compareTwoChoices,
                                      refinement: nil, spreadID: .twoChoiceFive)
        draft.selectedSpreadID = .coreClarityFour   // manual change wins
        draft.question = "  這件事卡住的核心是什麼？  "
        draft.decisionContext = "我正在比較兩個工作選擇"
        draft.optionA = " 留在目前公司 "
        draft.optionB = "接受新的工作邀請"
        let session = TarotReadingSession(request: .init(draft: draft))
        XCTAssertEqual(session.spreadID, .coreClarityFour)
        XCTAssertEqual(session.intent, .compareTwoChoices)
        XCTAssertEqual(session.question, "這件事卡住的核心是什麼？")
        XCTAssertEqual(session.optionA, "留在目前公司")
        XCTAssertEqual(session.optionB, "接受新的工作邀請")
        XCTAssertTrue(session.cards.isEmpty, "No cards exist before the ritual draws")
    }

    // MARK: Interpretation provider

    func testInterpretationIsPositionAwarePerSpread() {
        let provider = MockTarotInterpretationProvider()
        // The same card in different positions must read differently
        // (position-aware, not one generic paragraph — §25).
        let session = makeSession(.coreClarityFour)
        let interps = session.cards.map {
            provider.interpretation(for: $0, in: session, lang: .traditionalChinese)
        }
        XCTAssertTrue(interps[0].core.contains("問題核心"))
        XCTAssertTrue(interps[1].core.contains("目前阻礙"))
        XCTAssertTrue(interps[2].core.contains("可行對策"))
        XCTAssertTrue(interps[3].core.contains("可運用的優勢"))
        for interp in interps {
            XCTAssertFalse(interp.reflectionPrompt.isEmpty)
        }

        // Relationship positions keep the presented-state wording and
        // never claim hidden-mind access (§28).
        let relationship = makeSession(.relationshipFive)
        let theirState = provider.interpretation(for: relationship.cards[2],
                                                 in: relationship,
                                                 lang: .traditionalChinese)
        XCTAssertTrue(theirState.core.contains("呈現"))
        for lang in AppLanguage.allCases {
            let text = provider.synthesis(for: relationship, lang: lang)
            for banned in ["一定會", "注定", "其實在欺騙", "真正的內心",
                           "will definitely", "destined", "secretly deceiving",
                           "true hidden feelings"] {
                XCTAssertFalse(text.contains(banned), "No certainty claim: \(banned)")
            }
        }
    }

    func testTwoChoiceSynthesisStaysNeutral() {
        let provider = MockTarotInterpretationProvider()
        var session = makeSession(.twoChoiceFive)
        session.optionA = "留在目前公司"
        session.optionB = "接受新的工作邀請"
        for lang in AppLanguage.allCases {
            let text = provider.synthesis(for: session, lang: lang)
            XCTAssertTrue(text.contains("留在目前公司") && text.contains("接受新的工作邀請"),
                          "Both option labels appear")
            for banned in ["你應該選", "A 比較好", "B 比較好", "才是正確答案",
                           "Choose A", "Choose B", "the right one is"] {
                XCTAssertFalse(text.contains(banned), "No winner language: \(banned)")
            }
        }
    }

    func testEverySpreadHasAnIntegratedSummary() {
        let provider = MockTarotInterpretationProvider()
        for spreadID in TarotSpreadID.allCases {
            let session = makeSession(spreadID)
            let summary = session.cards.count == 1
                ? provider.combinedSummary(for: session, lang: .traditionalChinese)
                : provider.synthesis(for: session, lang: .traditionalChinese)
            XCTAssertFalse(summary.isEmpty, "\(spreadID) integrated summary")
        }
    }

    func testCombinedSummaryExpandsWithGuidance() {
        let provider = MockTarotInterpretationProvider()
        for spreadID in [TarotSpreadID.singleCard, .timelineThree, .relationshipFive] {
            var session = makeSession(spreadID)
            let before = provider.combinedSummary(for: session, lang: .traditionalChinese)
            var engine = TarotDrawEngine(rng: SeededRNG(state: 11))
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)
            let after = provider.combinedSummary(for: session, lang: .traditionalChinese)
            XCTAssertNotEqual(before, after,
                              "整體來看 expands once the Guidance Card joins (\(spreadID))")
            XCTAssertTrue(after.contains(session.guidanceCard!.card.displayNameZh))
        }
    }

    func testTwinkoMessageIsDistinctFromSynthesisAndSummary() {
        let provider = MockTarotInterpretationProvider()
        for lang in AppLanguage.allCases {
            let three = makeSession(.timelineThree)
            let message = provider.twinkoMessage(for: three, lang: lang)
            XCTAssertFalse(message.isEmpty)
            XCTAssertNotEqual(message, provider.synthesis(for: three, lang: lang))
            XCTAssertNotEqual(message, provider.combinedSummary(for: three, lang: lang))
        }
    }

    func testInterpretationIsBilingualNeverMixed() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(.singleCard)
        let zh = provider.interpretation(for: session.cards[0], in: session,
                                         lang: .traditionalChinese)
        let en = provider.interpretation(for: session.cards[0], in: session, lang: .english)
        XCTAssertNotEqual(zh.core, en.core)
        XCTAssertFalse(en.core.contains("這張牌"), "English output must not contain Chinese copy")
        XCTAssertFalse(en.detail.contains("這股能量"), "English detail must not contain Chinese copy")
    }

    // MARK: Character asset mapping (founder review 2026-07-16)

    func testTwinkoStateAssetMapping() {
        XCTAssertEqual(TarotTwinkoState.idle.assetName, "twinko_tarot_idle_v1_transparent")
        XCTAssertEqual(TarotTwinkoState.magic.assetName, "twinko_tarot_magic_v1_transparent")
        XCTAssertEqual(TarotTwinkoState.gentleConcern.assetName,
                       "twinko_tarot_gentle_concern_v1_transparent")
        for state in [TarotTwinkoState.idle, .gentleConcern, .magic] {
            XCTAssertFalse(state.assetName.contains("summary"))
            XCTAssertFalse(state.assetName.contains("interpreting"))
        }
    }

    func testShuffleChoreographyIsolatesExactSelectionCount() {
        for pick in 1...5 {
            XCTAssertEqual(TarotShuffleChoreography
                .selectedIndices(fanCount: 14, pick: pick).count, pick)
        }
        XCTAssertTrue(TarotShuffleChoreography.selectedIndices(fanCount: 5, pick: 0).isEmpty)
    }

    // MARK: Tarot → Meditation adapter

    func testMeditationAdapterProducesCleanFocusSummary() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(.timelineThree, guidance: true)
        for lang in AppLanguage.allCases {
            let context = TarotMeditationContextAdapter.context(for: session,
                                                                provider: provider, lang: lang)
            XCTAssertEqual(context.sourceType, .tarot)
            XCTAssertEqual(context.tarotQuestion, "測試問題")
            XCTAssertNotNil(context.recommendedFocus)

            let summary = context.focusSummary ?? ""
            XCTAssertFalse(summary.isEmpty)
            for drawn in session.allCards {
                XCTAssertFalse(summary.contains(drawn.card.displayName(for: lang)),
                               "Focus summary must not list card names")
            }
            for banned in ["一定", "絕對", "注定", "will definitely", "destined", "guarantee"] {
                XCTAssertFalse(summary.contains(banned),
                               "No deterministic wording: \(banned)")
            }
        }
    }

    // MARK: Summary Card

    func testSummaryCardSelectsLayoutByBaseCardCount() {
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(.singleCard)), .single)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(.timelineThree)), .three)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(.twoChoiceFive)), .three)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(.singleCard, guidance: true)),
                       .singlePlusGuidance)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(.coreClarityFour,
                                                                guidance: true)),
                       .threePlusGuidance)
    }

    func testTarotExportGeometryMatchesHoroscope() {
        XCTAssertEqual(TarotSummaryCardView.designSize,
                       HoroscopeSummaryCardView.designSize,
                       "Tarot Summary Card exports at the Horoscope dimensions (360×480 @3x = 1080×1440)")
    }

    func testDisclaimerIsTheApprovedShortLine() {
        XCTAssertEqual(TarotDisclaimer.text(.traditionalChinese), "內容僅供反思與娛樂")
        XCTAssertEqual(TarotDisclaimer.text(.english),
                       "For reflection and entertainment only")
    }

    // MARK: Share formatter

    func testShareTextIncludesSpreadCardsOrientationAndQuestion() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(.timelineThree, guidance: true)
        let text = TarotShareFormatter.text(for: session, provider: provider,
                                            lang: .traditionalChinese)
        XCTAssertTrue(text.contains("事情的發展脈絡"))
        XCTAssertTrue(text.contains("測試問題"))
        XCTAssertTrue(text.contains("過去"))
        XCTAssertTrue(text.contains("指引"))
        for drawn in session.allCards {
            XCTAssertTrue(text.contains(drawn.card.displayNameZh))
        }
        XCTAssertTrue(text.contains("正位") || text.contains("逆位"))
        XCTAssertTrue(text.contains("TwinkoTalk"))
    }
}
