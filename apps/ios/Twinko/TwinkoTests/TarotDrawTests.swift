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
        var session = TarotReadingSession(topic: .love, question: "測試問題", spread: spread)
        session.cards = engine.draw(spread: spread)
        if guidance {
            session.guidanceCard = engine.drawGuidance(excluding: session.cards)
        }
        return session
    }

    func testInterpretationReflectsOrientationAndPosition() {
        let provider = MockTarotInterpretationProvider()
        let session = makeSession(spread: .three)
        let first = session.cards[0]
        let interp = provider.interpretation(for: first, in: session, lang: .traditionalChinese)
        XCTAssertFalse(interp.body.isEmpty)
        XCTAssertFalse(interp.keywords.isEmpty)
        XCTAssertTrue(interp.body.contains("過去"), "Past position frame should appear")
        XCTAssertTrue(interp.body.contains(first.orientation == .upright ? "正位" : "逆位"))
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
        XCTAssertNotEqual(zh.body, en.body)
        XCTAssertFalse(en.body.contains("這張牌"), "English output must not contain Chinese copy")
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
