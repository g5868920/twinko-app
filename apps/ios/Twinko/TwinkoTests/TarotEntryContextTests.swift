import XCTest
@testable import Twinko

/// Task 3 protection (nonvisual): shared context→draft mapping, Daily
/// completion + local-day rules, and completed-snapshot restoration.
final class TarotEntryContextTests: XCTestCase {

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

    // 1 — Shared context→draft boundary preserves source, kind,
    //     spread, and supported fields; fabricates nothing.
    func testContextToDraftMapping() {
        let chat = TarotEntryContext(source: .chat, kind: .standard,
                                     recommendedSpreadID: .coreClarityFour,
                                     draftQuestion: "這件事真正卡住的地方是什麼？",
                                     contextSummary: "summary")
        let chatDraft = TarotReadingDraft(context: chat)
        XCTAssertEqual(chatDraft.source, .chat)
        XCTAssertEqual(chatDraft.contextKind, .standard)
        XCTAssertEqual(chatDraft.recommendedSpreadID, .coreClarityFour)
        XCTAssertEqual(chatDraft.selectedSpreadID, .coreClarityFour)
        XCTAssertEqual(chatDraft.question, "這件事真正卡住的地方是什麼？")
        XCTAssertTrue(chatDraft.optionA.isEmpty && chatDraft.optionB.isEmpty,
                      "Missing structured fields are never fabricated")
        XCTAssertTrue(chatDraft.relationshipPersonLabel.isEmpty)

        // Daily: canonical spread, home source, dailyCheckIn kind.
        let daily = TarotEntryContext.daily(lang: .traditionalChinese)
        XCTAssertEqual(daily.recommendedSpreadID, .holisticCheckInThree)
        let dailyDraft = TarotReadingDraft(context: daily)
        XCTAssertEqual(dailyDraft.source, .home)
        XCTAssertEqual(dailyDraft.contextKind, .dailyCheckIn)
        XCTAssertFalse(dailyDraft.question.isEmpty, "Editable default question")

        // Source/kind flow into the Task 2 session via the launch
        // request — and a manual spread change keeps Daily ownership.
        var changed = dailyDraft
        changed.selectedSpreadID = .thinkFeelActThree
        let session = TarotReadingSession(request: .init(draft: changed))
        XCTAssertEqual(session.source, .home)
        XCTAssertEqual(session.contextKind, .dailyCheckIn)
        XCTAssertEqual(session.spreadID, .thinkFeelActThree)
    }

    // 1b — Deterministic Chat scenarios: canonical spreads, no
    //      invented options, no hidden-thought claims.
    func testChatScenariosAreDeterministicAndSafe() {
        let stuck = ChatTarotSuggestor.context(for: "我最近覺得工作卡住了",
                                               lang: .traditionalChinese)
        XCTAssertEqual(stuck?.recommendedSpreadID, .coreClarityFour)
        XCTAssertEqual(stuck?.source, .chat)

        let choice = ChatTarotSuggestor.context(for: "我在兩個選擇之間好煩惱",
                                                lang: .traditionalChinese)
        XCTAssertEqual(choice?.recommendedSpreadID, .twoChoiceFive)
        XCTAssertNil(choice?.optionA, "Never invents Option A")
        XCTAssertNil(choice?.optionB, "Never invents Option B")

        let love = ChatTarotSuggestor.context(for: "我的感情讓我睡不著",
                                              lang: .english)
        XCTAssertEqual(love?.recommendedSpreadID, .relationshipFive)
        XCTAssertNil(love?.relationshipPersonLabel,
                     "No label unless explicitly available")
        for text in [love?.contextSummary, love?.draftQuestion].compactMap({ $0 }) {
            for banned in ["hidden", "secretly", "destined", "definitely"] {
                XCTAssertFalse(text.lowercased().contains(banned))
            }
        }
        XCTAssertNil(ChatTarotSuggestor.context(for: "今天天氣不錯",
                                                lang: .traditionalChinese),
                     "No match → no offer, nothing classified")
    }

    // 2 — Daily completion: only completed dailyCheckIn sessions
    //     record; one per local day; a new day frees the entry.
    func testDailyCompletionAndLocalDayRules() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("daily-tarot-tests-\(UUID().uuidString)")
        var currentDate = Date(timeIntervalSince1970: 1_800_000_000) // fixed
        let store = DailyTarotStore(store: JSONStore(directory: directory),
                                    calendar: .init(identifier: .gregorian),
                                    now: { currentDate })

        XCTAssertFalse(store.isTodayCompleted)

        // A standard (non-daily) session never records.
        var standard = makeSession(.holisticCheckInThree)
        standard.source = .direct
        store.recordCompletion(of: standard)
        XCTAssertFalse(store.isTodayCompleted,
                       "Daily identity comes from context kind, not the spread")

        // A daily session with all cards drawn records once.
        var daily = makeSession(.holisticCheckInThree)
        daily.source = .home
        daily.contextKind = .dailyCheckIn
        store.recordCompletion(of: daily)
        XCTAssertTrue(store.isTodayCompleted)
        let firstID = store.todayRecord?.readingSnapshot.sessionID

        // Second same-day completion is ignored.
        var second = makeSession(.singleCard, seed: 99)
        second.contextKind = .dailyCheckIn
        store.recordCompletion(of: second)
        XCTAssertEqual(store.todayRecord?.readingSnapshot.sessionID, firstID,
                       "At most one Daily completion per local day")

        // Guidance updates the same record, never a new completion.
        var engine = TarotDrawEngine(rng: SeededRNG(state: 4))
        daily.guidanceCard = engine.drawGuidance(excluding: daily.cards)
        store.attachGuidance(from: daily)
        XCTAssertEqual(store.todayRecord?.readingSnapshot.sessionID, firstID)
        XCTAssertNotNil(store.todayRecord?.readingSnapshot.guidance)

        // New local day → uncompleted again; the stale record no
        // longer reads as today.
        currentDate = currentDate.addingTimeInterval(60 * 60 * 26)
        XCTAssertFalse(store.isTodayCompleted)
        XCTAssertNil(store.restoredTodaySession())

        // Restart-safe: a fresh store instance reloads the record.
        currentDate = currentDate.addingTimeInterval(-60 * 60 * 26)
        let reloaded = DailyTarotStore(store: JSONStore(directory: directory),
                                       calendar: .init(identifier: .gregorian),
                                       now: { currentDate })
        XCTAssertTrue(reloaded.isTodayCompleted)
    }

    // 3 — Snapshot restoration: identical cards, orientations,
    //     positions, reveal state, and Guidance Card; fail-safe nil
    //     for unknown cards.
    func testSnapshotRestoresExactReading() {
        var session = makeSession(.holisticCheckInThree)
        session.source = .home
        session.contextKind = .dailyCheckIn
        for card in session.cards { session.markRevealed(card.positionID) }
        session.revealSeen = true
        var engine = TarotDrawEngine(rng: SeededRNG(state: 8))
        session.guidanceCard = engine.drawGuidance(excluding: session.cards)

        let snapshot = TarotReadingSnapshot(session: session)
        let restored = snapshot.restoredSession()
        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.id, session.id)
        XCTAssertEqual(restored?.spreadID, session.spreadID)
        XCTAssertEqual(restored?.source, .home)
        XCTAssertEqual(restored?.contextKind, .dailyCheckIn)
        XCTAssertEqual(restored?.cards.map(\.card.id), session.cards.map(\.card.id))
        XCTAssertEqual(restored?.cards.map(\.orientation),
                       session.cards.map(\.orientation))
        XCTAssertEqual(restored?.cards.map(\.positionID),
                       session.cards.map(\.positionID))
        XCTAssertEqual(restored?.guidanceCard?.card.id, session.guidanceCard?.card.id)
        XCTAssertEqual(restored?.guidanceCard?.orientation,
                       session.guidanceCard?.orientation)
        XCTAssertEqual(restored?.revealedPositionIDs, session.revealedPositionIDs)
        XCTAssertEqual(restored?.revealSeen, true)
        XCTAssertEqual(restored?.question, session.question)
    }

    private func makeSession(_ spreadID: TarotSpreadID,
                             seed: UInt64 = 5) -> TarotReadingSession {
        var engine = TarotDrawEngine(rng: SeededRNG(state: seed))
        var session = TarotReadingSession(spreadID: spreadID, topic: .other,
                                          question: "今天我的身心最需要什麼？")
        session.cards = engine.draw(spreadID: spreadID)
        return session
    }
}
