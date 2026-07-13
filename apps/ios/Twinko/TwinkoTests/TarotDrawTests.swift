import XCTest
@testable import Twinko

final class TarotDrawTests: XCTestCase {
    private let referenceDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 7, day: 14, hour: 10))!

    func testDrawIsDeterministicForSameInputs() {
        let first = TarotDrawer.draw(topic: .love, question: "關於這段關係，我可以多理解什麼？",
                                     spread: .three, on: referenceDate)
        let second = TarotDrawer.draw(topic: .love, question: "關於這段關係，我可以多理解什麼？",
                                      spread: .three, on: referenceDate)
        XCTAssertEqual(first.cards.map(\.id), second.cards.map(\.id))
    }

    func testDifferentQuestionsCanDrawDifferently() {
        let inputs = ["問題一", "問題二", "問題三", "問題四", "問題五"]
        let draws = inputs.map {
            TarotDrawer.draw(topic: .general, question: $0, spread: .single, on: referenceDate)
                .cards.map(\.id)
        }
        XCTAssertTrue(Set(draws).count > 1, "Different questions should not all draw identically")
    }

    func testSingleSpreadDrawsOneDistinctCard() {
        let draw = TarotDrawer.draw(topic: .growth, question: "test", spread: .single, on: referenceDate)
        XCTAssertEqual(draw.cards.count, 1)
    }

    func testThreeSpreadDrawsThreeDistinctCards() {
        let draw = TarotDrawer.draw(topic: .career, question: "工作", spread: .three, on: referenceDate)
        XCTAssertEqual(draw.cards.count, 3)
        XCTAssertEqual(Set(draw.cards.map(\.id)).count, 3)
    }

    func testStableHashIsStable() {
        XCTAssertEqual(stableHash("Twinko 塔羅"), stableHash("Twinko 塔羅"))
        XCTAssertNotEqual(stableHash("a"), stableHash("b"))
    }

    func testEveryCardHasReflectionForEveryTopic() {
        for card in TarotDeck.cards {
            for topic in TarotTopic.allCases {
                XCTAssertNotNil(card.reflections[topic],
                                "\(card.name) is missing a reflection for \(topic.rawValue)")
            }
        }
    }

    func testIntegratedSummaryOnlyForThreeCardSpread() {
        let single = TarotDrawer.draw(topic: .general, question: "q", spread: .single, on: referenceDate)
        XCTAssertNil(TarotInterpreter.integratedSummary(for: single))

        let three = TarotDrawer.draw(topic: .general, question: "q", spread: .three, on: referenceDate)
        XCTAssertNotNil(TarotInterpreter.integratedSummary(for: three))
    }

    func testInterpretationContainsPositionFrame() {
        let draw = TarotDrawer.draw(topic: .love, question: "q", spread: .three, on: referenceDate)
        let text = TarotInterpreter.interpretation(for: draw.cards[0], topic: .love,
                                                   position: .situation)
        XCTAssertTrue(text.contains("情境"))
    }
}
