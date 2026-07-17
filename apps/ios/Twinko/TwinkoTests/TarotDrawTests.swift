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

    // MARK: Draw engine

    func testSingleDrawReturnsOneCardWithoutPosition() {
        var engine = TarotDrawEngine()
        let cards = engine.draw(spread: .single)
        XCTAssertEqual(cards.count, 1)
        XCTAssertNil(cards[0].position)
    }

    func testThreeDrawReturnsDistinctCardsWithPastPresentFuture() {
        var engine = TarotDrawEngine()
        let cards = engine.draw(spread: .three)
        XCTAssertEqual(cards.count, 3)
        XCTAssertEqual(Set(cards.map(\.card.id)).count, 3, "No duplicates within a reading")
        XCTAssertEqual(cards.map(\.position), [.past, .present, .future])
    }

    func testGuidanceDrawNeverDuplicatesReading() {
        for seed in 0..<50 {
            var engine = TarotDrawEngine(rng: SeededRNG(state: UInt64(seed)))
            let three = engine.draw(spread: .three)
            let guidance = engine.drawGuidance(excluding: three)
            XCTAssertNotNil(guidance)
            XCTAssertEqual(guidance?.position, .guidance)
            XCTAssertFalse(three.map(\.card.id).contains(guidance!.card.id),
                           "Guidance card must come from the remaining 75 cards")
        }
    }

    func testOrientationIsRandomizedBothWaysOverManyDraws() {
        var engine = TarotDrawEngine(rng: SeededRNG(state: 7))
        var seen = Set<TarotOrientation>()
        for _ in 0..<40 {
            seen.formUnion(engine.draw(spread: .single).map(\.orientation))
        }
        XCTAssertEqual(seen, [.upright, .reversed],
                       "Both orientations must occur — reversed cards are required")
    }

    func testDrawSpansTheFullDeckOverManyDraws() {
        var engine = TarotDrawEngine(rng: SeededRNG(state: 11))
        var seen = Set<String>()
        for _ in 0..<300 {
            seen.formUnion(engine.draw(spread: .three).map(\.card.id))
        }
        XCTAssertGreaterThan(seen.count, 70, "Unbiased draws should reach nearly all 78 cards")
    }

    func testSeededDrawIsDeterministicForTests() {
        var a = TarotDrawEngine(rng: SeededRNG(state: 42))
        var b = TarotDrawEngine(rng: SeededRNG(state: 42))
        let first = a.draw(spread: .three)
        let second = b.draw(spread: .three)
        XCTAssertEqual(first.map(\.card.id), second.map(\.card.id))
        XCTAssertEqual(first.map(\.orientation), second.map(\.orientation))
    }

    // MARK: Interpretation provider

    private func makeSession(spread: TarotSpreadType, guidance: Bool = false) -> TarotReadingSession {
        var engine = TarotDrawEngine(rng: SeededRNG(state: 5))
        var session = TarotReadingSession(topic: .relationships, question: "測試問題", spread: spread)
        session.cards = engine.draw(spread: spread)
        if guidance {
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)
        }
        return session
    }

    func testInterpretationSplitsCoreAndDetail() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(spread: .three)
        let first = session.cards[0]
        let interp = provider.interpretation(for: first, in: session, lang: .traditionalChinese)
        XCTAssertFalse(interp.core.isEmpty)
        XCTAssertFalse(interp.detail.isEmpty)
        XCTAssertFalse(interp.keywords.isEmpty)
        XCTAssertTrue(interp.core.contains("過去"), "Position frame belongs to the visible core")
        XCTAssertTrue(interp.detail.contains(first.orientation == .upright ? "正位" : "逆位"),
                      "Orientation nuance belongs to the expandable detail")
        XCTAssertNotEqual(interp.core, interp.detail)
    }

    func testTwinkoMessageIsDistinctFromSynthesisAndSummary() {
        let provider = MockTarotInterpretationProvider()
        for lang in AppLanguage.allCases {
            let three = makeSession(spread: .three)
            let message = provider.twinkoMessage(for: three, lang: lang)
            XCTAssertFalse(message.isEmpty)
            XCTAssertNotEqual(message, provider.synthesis(for: three, lang: lang))
            XCTAssertNotEqual(message, provider.combinedSummary(for: three, lang: lang))

            let withGuidance = makeSession(spread: .three, guidance: true)
            XCTAssertNotEqual(provider.twinkoMessage(for: withGuidance, lang: lang),
                              provider.combinedSummary(for: withGuidance, lang: lang))
        }
    }

    // MARK: Character asset mapping (founder review 2026-07-16)

    func testTwinkoStateAssetMapping() {
        XCTAssertEqual(TarotTwinkoState.idle.assetName, "twinko_tarot_idle_v1_transparent")
        XCTAssertEqual(TarotTwinkoState.magic.assetName, "twinko_tarot_magic_v1_transparent")
        XCTAssertEqual(TarotTwinkoState.gentleConcern.assetName,
                       "twinko_tarot_gentle_concern_v1_transparent")
        // The deprecated summary/interpreting poses are never resolved.
        for state in [TarotTwinkoState.idle, .gentleConcern, .magic] {
            XCTAssertFalse(state.assetName.contains("summary"))
            XCTAssertFalse(state.assetName.contains("interpreting"))
        }
    }

    func testShuffleChoreographyIsolatesExactSelectionCount() {
        XCTAssertEqual(TarotShuffleChoreography.selectedIndices(fanCount: 5, pick: 3).count, 3)
        XCTAssertEqual(TarotShuffleChoreography.selectedIndices(fanCount: 5, pick: 1).count, 1)
        XCTAssertEqual(TarotShuffleChoreography.selectedIndices(fanCount: 5, pick: 3), [1, 2, 3])
        XCTAssertEqual(TarotShuffleChoreography.selectedIndices(fanCount: 5, pick: 1), [2])
        XCTAssertTrue(TarotShuffleChoreography.selectedIndices(fanCount: 5, pick: 0).isEmpty)
    }

    // MARK: Tarot → Meditation adapter

    func testMeditationAdapterProducesCleanFocusSummary() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(spread: .three, guidance: true)
        for lang in AppLanguage.allCases {
            let context = TarotMeditationContextAdapter.context(for: session,
                                                                provider: provider, lang: lang)
            XCTAssertEqual(context.sourceType, .tarot)
            XCTAssertEqual(context.tarotQuestion, "測試問題")
            XCTAssertNotNil(context.recommendedFocus)

            let summary = context.focusSummary ?? ""
            XCTAssertFalse(summary.isEmpty)
            XCTAssertFalse(summary.contains("…"), "No accidental ellipsis")
            XCTAssertFalse(summary.contains("..."))
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

    func testMeditationAdapterRecommendsThemePerTopic() {
        XCTAssertEqual(TarotMeditationContextAdapter.recommendedFocus(for: .relationships), .selfLove)
        XCTAssertEqual(TarotMeditationContextAdapter.recommendedFocus(for: .career), .releaseAnxiety)
        XCTAssertEqual(TarotMeditationContextAdapter.recommendedFocus(for: .finance), .releaseAnxiety)
        XCTAssertEqual(TarotMeditationContextAdapter.recommendedFocus(for: .growth), .selfLove)
        XCTAssertEqual(TarotMeditationContextAdapter.recommendedFocus(for: .lifePath), .calmDown)
        XCTAssertEqual(TarotMeditationContextAdapter.recommendedFocus(for: .other), .calmDown)
    }

    // MARK: Redesign 2026-07-16

    func testSixApprovedTopicsWithExactEnglishLabels() {
        XCTAssertEqual(TarotTopicType.allCases,
                       [.relationships, .career, .finance, .growth, .lifePath, .other])
        XCTAssertEqual(TarotTopicType.allCases.map { $0.label(.english) },
                       ["Relationships", "Career", "Finance", "Growth", "Life Path", "Other"])
        XCTAssertEqual(TarotTopicType.allCases.map { $0.label(.traditionalChinese) },
                       ["愛情與關係", "工作與事業", "財務與投資", "自我成長", "生活方向", "其他"])
    }

    func testSuggestedQuestionsAreTopicSpecificAndLocalized() {
        for lang in AppLanguage.allCases {
            var seen = Set<String>()
            for topic in TarotTopicType.allCases {
                let suggestions = topic.suggestedQuestions(lang)
                XCTAssertEqual(suggestions.count, 2, "Two suggestions per topic")
                for s in suggestions {
                    XCTAssertTrue(seen.insert(s).inserted,
                                  "Suggestions must differ per topic: \(s)")
                }
            }
        }
        XCTAssertTrue(TarotTopicType.finance.suggestedQuestions(.traditionalChinese)
            .contains { $0.contains("金錢") })
        XCTAssertTrue(TarotTopicType.relationships.suggestedQuestions(.english)
            .contains { $0.contains("relationship") })
    }

    func testGuidanceCardIsOneDrawPerReading() {
        var session = makeSession(spread: .single)
        XCTAssertTrue(session.canDrawGuidance)
        var engine = TarotDrawEngine(rng: SeededRNG(state: 9))
        session.guidanceCard = engine.drawGuidance(excluding: session.cards)
        XCTAssertNotNil(session.guidanceCard)
        XCTAssertFalse(session.canDrawGuidance,
                       "Once drawn, no further Guidance Card is offered")
    }

    /// Result → Back must show the exact same face-up cards (§41):
    /// reveal state is session-owned, so within one active reading the
    /// card IDs, orientations, and positions never change and the
    /// face-up state is never lost — for one- and three-card flows.
    func testCompletedRevealStatePersistsWhenReturningFromResult() {
        for spread in TarotSpreadType.allCases {
            var session = makeSession(spread: spread)
            XCTAssertFalse(session.revealSeen, "A fresh draw starts face-down (\(spread))")

            let ids = session.cards.map(\.card.id)
            let orientations = session.cards.map(\.orientation)
            let positions = session.cards.map(\.position)

            // Entering the Result marks the session's reading revealed;
            // a later guidance draw must not disturb any of it.
            session.revealSeen = true
            var engine = TarotDrawEngine(rng: SeededRNG(state: 3))
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)

            XCTAssertTrue(session.revealSeen,
                          "Backward navigation re-enters reveal face-up (\(spread))")
            XCTAssertEqual(session.cards.map(\.card.id), ids,
                           "Same cards — never redrawn (\(spread))")
            XCTAssertEqual(session.cards.map(\.orientation), orientations,
                           "Orientation unchanged (\(spread))")
            XCTAssertEqual(session.cards.map(\.position), positions,
                           "Spread positions unchanged (\(spread))")

            // Only an explicit new reading resets the revealed state.
            let restarted = TarotReadingSession(topic: session.topic)
            XCTAssertFalse(restarted.revealSeen)
        }
    }

    func testStartNewReadingResetsToTopicSetupState() {
        let finished = makeSession(spread: .three, guidance: true)
        // Mirrors the flow's restart: a fresh session keeps the topic
        // but clears the reading, question, and Guidance Card.
        let restarted = TarotReadingSession(topic: finished.topic)
        XCTAssertEqual(restarted.topic, finished.topic)
        XCTAssertTrue(restarted.cards.isEmpty)
        XCTAssertNil(restarted.guidanceCard)
        XCTAssertTrue(restarted.trimmedQuestion.isEmpty)
        XCTAssertFalse(restarted.canDrawGuidance, "Nothing to guide before a draw")
    }

    func testSpreadSubtitlesUseApprovedShortCopy() {
        XCTAssertEqual(TarotSpreadType.single.subtitle(.traditionalChinese), "此刻最需要的提醒")
        XCTAssertEqual(TarotSpreadType.single.subtitle(.english), "Quick Insight")
        XCTAssertEqual(TarotSpreadType.three.subtitle(.traditionalChinese), "過去・現在・未來")
        XCTAssertEqual(TarotSpreadType.three.subtitle(.english), "Past · Present · Future")
    }

    func testShuffleCopyIsTheStarlightLine() {
        XCTAssertEqual(TarotStrings.shuffling(.traditionalChinese), "讓牌在星光中回應你的心意……")
        XCTAssertEqual(TarotStrings.cardsEmerged(.traditionalChinese), "你的牌已在星光中浮現")
    }

    // MARK: Summary Card V2

    func testSummaryCardSelectsCorrectLayoutMode() {
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(spread: .single)), .single)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(spread: .three)), .three)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(spread: .single, guidance: true)),
                       .singlePlusGuidance)
        XCTAssertEqual(TarotSummaryLayout.mode(for: makeSession(spread: .three, guidance: true)),
                       .threePlusGuidance)
    }

    func testTarotExportGeometryMatchesHoroscope() {
        XCTAssertEqual(TarotSummaryCardView.designSize,
                       HoroscopeSummaryCardView.designSize,
                       "Tarot Summary Card exports at the Horoscope dimensions (360×480 @3x = 1080×1440)")
    }

    func testCombinedSummaryExpandsWithGuidanceForBothSpreads() {
        let provider = MockTarotInterpretationProvider()
        for spread in TarotSpreadType.allCases {
            var session = makeSession(spread: spread)
            let before = provider.combinedSummary(for: session, lang: .traditionalChinese)
            var engine = TarotDrawEngine(rng: SeededRNG(state: 11))
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)
            let after = provider.combinedSummary(for: session, lang: .traditionalChinese)
            XCTAssertNotEqual(before, after,
                              "整體來看 expands once the Guidance Card joins (\(spread))")
            let gName = session.guidanceCard!.card.displayNameZh
            XCTAssertTrue(after.contains(gName),
                          "Expanded summary reads the guidance card (\(spread))")
            // Original card identities/orientations are untouched.
            XCTAssertEqual(session.cards.count, spread.cardCount)
        }
    }

    func testTwinkoMessageReflectsExpandedReading() {
        let provider = MockTarotInterpretationProvider()
        var session = makeSession(spread: .three)
        let before = provider.twinkoMessage(for: session, lang: .traditionalChinese)
        var engine = TarotDrawEngine(rng: SeededRNG(state: 21))
        session.guidanceCard = engine.drawGuidance(excluding: session.cards)
        let after = provider.twinkoMessage(for: session, lang: .traditionalChinese)
        // Deterministic seeds chosen so the expanded reading selects a
        // different closing message (the message derives from all
        // cards including the guidance card).
        XCTAssertNotEqual(before, after,
                          "Twinko 想對你說 reflects the expanded reading state")
        XCTAssertNotEqual(after, provider.combinedSummary(for: session, lang: .traditionalChinese),
                          "Message stays distinct from the expanded synthesis")
    }

    func testDisclaimerIsTheApprovedShortLine() {
        XCTAssertEqual(TarotDisclaimer.text(.traditionalChinese), "內容僅供反思與娛樂")
        XCTAssertEqual(TarotDisclaimer.text(.english),
                       "For reflection and entertainment only")
    }

    func testVortexPoolStillIsolatesExactSelectionCount() {
        // The vortex uses a 14-card visual pool; the converged set must
        // still be exactly the drawn count.
        XCTAssertEqual(TarotShuffleChoreography.selectedIndices(fanCount: 14, pick: 3).count, 3)
        XCTAssertEqual(TarotShuffleChoreography.selectedIndices(fanCount: 14, pick: 1).count, 1)
    }

    func testSynthesisOnlyForThreeCardReadings() {
        let provider = MockTarotInterpretationProvider()
        XCTAssertEqual(provider.synthesis(for: makeSession(spread: .single),
                                          lang: .traditionalChinese), "")
        XCTAssertFalse(provider.synthesis(for: makeSession(spread: .three),
                                          lang: .traditionalChinese).isEmpty)
    }

    func testCombinedSummaryCoversAllVariants() {
        let provider = MockTarotInterpretationProvider()
        let single = provider.combinedSummary(for: makeSession(spread: .single), lang: .english)
        XCTAssertFalse(single.isEmpty)

        let threePlusOne = makeSession(spread: .three, guidance: true)
        let combined = provider.combinedSummary(for: threePlusOne, lang: .traditionalChinese)
        XCTAssertTrue(combined.contains("指引"),
                      "3+1 summary should reference the guidance card")
        XCTAssertTrue(combined.contains(threePlusOne.guidanceCard!.card.displayNameZh))
    }

    func testInterpretationIsBilingualNeverMixed() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(spread: .single)
        let zh = provider.interpretation(for: session.cards[0], in: session,
                                         lang: .traditionalChinese)
        let en = provider.interpretation(for: session.cards[0], in: session, lang: .english)
        XCTAssertNotEqual(zh.core, en.core)
        XCTAssertFalse(en.core.contains("這張牌"), "English output must not contain Chinese copy")
        XCTAssertFalse(en.detail.contains("這股能量"), "English detail must not contain Chinese copy")
    }

    // MARK: Share formatter

    func testShareTextIncludesSpreadCardsOrientationAndQuestion() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(spread: .three, guidance: true)
        let text = TarotShareFormatter.text(for: session, provider: provider,
                                            lang: .traditionalChinese)
        XCTAssertTrue(text.contains("三張牌"))
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
