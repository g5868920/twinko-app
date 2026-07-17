import XCTest
@testable import Twinko

@MainActor
final class ChatStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TwinkoChatTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    private var jsonStore: JSONStore { JSONStore(directory: tempDirectory) }

    private func makeSession(text: String) -> ChatSession {
        ChatSession(messages: [ChatMessage(sender: .user, text: text)])
    }

    // MARK: History local search (redesign 2026-07-17)

    /// Search matches display title and last-message preview only,
    /// case-insensitively, with trimmed queries; clearing the query
    /// restores the full collection; no-match yields an empty result
    /// (driving the no-results state, distinct from true empty).
    func testHistorySearchMatchesTitleAndPreviewAndClearsCleanly() {
        var work = ChatSession(messages: [ChatMessage(sender: .user, text: "最近工作好忙")])
        work.title = "壓力有點大的日子"
        var life = ChatSession(messages: [ChatMessage(sender: .user, text: "Today was a Good Day")])
        life.title = "Small joys"
        let sessions = [work, life]

        // Title match (zh) and preview match (zh).
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "壓力",
                                                lang: .traditionalChinese).map(\.id), [work.id])
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "工作",
                                                lang: .traditionalChinese).map(\.id), [work.id])
        // Case-insensitive EN title + preview matches.
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "small JOYS",
                                                lang: .english).map(\.id), [life.id])
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "good day",
                                                lang: .english).map(\.id), [life.id])
        // Outer whitespace trimmed.
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "  壓力  ",
                                                lang: .traditionalChinese).count, 1)
        // Empty / whitespace query returns the full collection.
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "",
                                                lang: .english).count, 2)
        XCTAssertEqual(ChatHistorySearch.filter(sessions, query: "   ",
                                                lang: .english).count, 2)
        // No match: empty result — never fabricated.
        XCTAssertTrue(ChatHistorySearch.filter(sessions, query: "旅行",
                                               lang: .traditionalChinese).isEmpty)
    }

    func testSessionsPersistAcrossStoreInstances() {
        let first = ChatStore(store: jsonStore)
        first.upsert(makeSession(text: "今天有點累"))
        XCTAssertEqual(first.sessions.count, 1)

        let second = ChatStore(store: jsonStore)
        XCTAssertEqual(second.sessions.count, 1)
        XCTAssertEqual(second.sessions.first?.messages.first?.text, "今天有點累")
    }

    func testDeleteRemovesSessionPermanently() {
        let first = ChatStore(store: jsonStore)
        let session = makeSession(text: "要刪掉的對話")
        first.upsert(session)
        first.delete(session.id)
        XCTAssertTrue(first.sessions.isEmpty)

        let second = ChatStore(store: jsonStore)
        XCTAssertTrue(second.sessions.isEmpty)
    }

    func testUpsertUpdatesExistingSessionInPlace() {
        let store = ChatStore(store: jsonStore)
        var session = makeSession(text: "第一句")
        store.upsert(session)

        session.messages.append(ChatMessage(sender: .twinko, text: "回覆"))
        session.updatedAt = .now
        store.upsert(session)

        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.messages.count, 2)
    }

    func testSessionsSortedByRecency() {
        let store = ChatStore(store: jsonStore)
        var older = makeSession(text: "舊的")
        older.updatedAt = Date(timeIntervalSinceNow: -3600)
        let newer = makeSession(text: "新的")
        store.upsert(older)
        store.upsert(newer)

        XCTAssertEqual(store.sessions.first?.messages.first?.text, "新的")
    }

    func testDisplayTitleFallsBackToTemporaryTitle() {
        let empty = ChatSession()
        XCTAssertEqual(empty.displayTitle(for: .traditionalChinese), "新對話")
        XCTAssertEqual(empty.displayTitle(for: .english), "New Conversation")

        var named = ChatSession()
        named.title = "工作壓力"
        XCTAssertEqual(named.displayTitle(for: .english), "工作壓力")
    }

    func testRenameSetsUserSourceAndPersists() {
        let store = ChatStore(store: jsonStore)
        let session = makeSession(text: "今天有點累")
        store.upsert(session)

        store.rename(session.id, to: "  我的對話  ")
        XCTAssertEqual(store.session(with: session.id)?.title, "我的對話")
        XCTAssertEqual(store.session(with: session.id)?.titleSource, .user)

        // Empty rename is rejected.
        store.rename(session.id, to: "   ")
        XCTAssertEqual(store.session(with: session.id)?.title, "我的對話")

        let reloaded = ChatStore(store: jsonStore)
        XCTAssertEqual(reloaded.session(with: session.id)?.title, "我的對話")
        XCTAssertEqual(reloaded.session(with: session.id)?.titleSource, .user)
    }

    func testAutoTitleGeneratedAfterFirstExchange() async {
        let store = ChatStore(store: jsonStore)
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.store = store
        viewModel.draftText = "我想聊聊今天發生的事，工作好累"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)

        let saved = store.session(with: viewModel.sessionID)
        XCTAssertNotNil(saved)
        let title = saved!.title
        XCTAssertFalse(title.isEmpty, "A topic title should be generated after the first exchange")
        XCTAssertEqual(saved!.titleSource, .auto)
        XCTAssertFalse(title.contains("我想聊聊"), "Greeting/filler prefix should be stripped")
        XCTAssertLessThanOrEqual(title.count, 14)
    }

    func testAutoTitleNeverOverwritesUserRename() async {
        let store = ChatStore(store: jsonStore)
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.store = store
        viewModel.draftText = "嗨"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)

        store.rename(viewModel.sessionID, to: "自訂標題")
        viewModel.draftText = "工作壓力好大"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(store.session(with: viewModel.sessionID)?.title, "自訂標題")
        XCTAssertEqual(store.session(with: viewModel.sessionID)?.titleSource, .user)
    }

    func testTitleGeneratorRules() {
        let generator = LocalChatTitleGenerator()
        func gen(_ user: String) -> String? {
            generator.title(for: [ChatMessage(sender: .user, text: user),
                                  ChatMessage(sender: .twinko, text: "回覆")])
        }
        // Needs a Twinko response before generating.
        XCTAssertNil(generator.title(for: [ChatMessage(sender: .user, text: "hi")]))
        // Strips emoji, quotes, and trailing punctuation.
        let title = gen("我最近有點喘不過氣 😮‍💨！")
        XCTAssertNotNil(title)
        XCTAssertFalse(title!.contains("😮‍💨"))
        XCTAssertFalse(title!.hasSuffix("！"))
        // Latin truncation ~30 chars.
        let long = gen("This is a very long sentence about my extremely busy work schedule")
        XCTAssertNotNil(long)
        XCTAssertLessThanOrEqual(long!.count, 30)
    }

    // MARK: Meditation intent + offer (Chat refinement 2026-07-16)

    func testMeditationIntentClassification() {
        for request in ["我想要冥想", "陪我冥想", "帶我做一段冥想", "我想靜一下",
                        "我想冷靜一下", "我需要放鬆", "I want to meditate",
                        "can you meditate with me", "help me calm down"] {
            XCTAssertEqual(MeditationIntentDetector.detect(request), .requestIntent,
                           "Should be a request: \(request)")
        }
        for topic in ["我昨天做冥想反而睡不著", "你覺得冥想有用嗎", "我不喜歡冥想",
                      "is meditation actually useful", "meditation didn't work for me yesterday"] {
            XCTAssertEqual(MeditationIntentDetector.detect(topic), .topicMention,
                           "Should be a topic mention: \(topic)")
        }
        XCTAssertEqual(MeditationIntentDetector.detect("今天天氣很好"), ChatMeditationIntent.none)
    }

    func testExplicitMeditationRequestRoutesBeforeFallback() async {
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.draftText = "我想要冥想"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)

        let reply = viewModel.messages.last
        XCTAssertEqual(reply?.sender, .twinko)
        XCTAssertFalse(reply?.text.contains("沒有完全聽懂") ?? true,
                       "Explicit meditation intent must never hit the misunderstanding fallback")
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.meditationOffer?.source, .explicitRequest)
        XCTAssertEqual(viewModel.meditationOffer?.messageID, reply?.id,
                       "The offer stays associated with the related Twinko message")
    }

    func testProactiveOfferOncePerConversationAndExplicitStillAllowed() async {
        let store = ChatStore(store: jsonStore)
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.store = store

        // First meaningful exchange → one proactive offer.
        viewModel.draftText = "我今天有點難過"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.meditationOffer?.source, .proactiveSuggestion)

        // Decline dismisses silently — no new message, no re-offer.
        let countBefore = viewModel.messages.count
        viewModel.declineMeditationOffer()
        XCTAssertNil(viewModel.meditationOffer)
        XCTAssertEqual(viewModel.messages.count, countBefore, "Decline must not add a reply")

        viewModel.draftText = "工作壓力也好大"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(viewModel.meditationOffer, "At most one proactive offer per conversation")

        // A later explicit request still opens a fresh confirmation.
        viewModel.draftText = "帶我冥想"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.meditationOffer?.source, .explicitRequest)

        // The proactive cap survives persistence.
        XCTAssertTrue(store.session(with: viewModel.sessionID)?.meditationProactiveOfferResolved ?? false)
    }

    func testChatMeditationContextAdapterSummarizesWithoutQuoting() {
        let messages = [
            ChatMessage(sender: .user, text: "最近工作壓力好大，老闆一直加東西"),
            ChatMessage(sender: .twinko, text: "辛苦你了"),
        ]
        let context = ChatMeditationContextAdapter.context(for: messages, lang: .traditionalChinese)
        XCTAssertEqual(context.sourceType, .chat)
        XCTAssertEqual(context.recommendedFocus, .releaseAnxiety)
        let summary = context.focusSummary ?? ""
        XCTAssertTrue(summary.contains("工作"), "Work-stress context should shape the focus")
        XCTAssertFalse(summary.contains("老闆一直加東西"), "Never quote the raw message")

        // Missing topic degrades to a gentle generic focus.
        let generic = ChatMeditationContextAdapter.context(
            for: [ChatMessage(sender: .user, text: "嗯")], lang: .english)
        XCTAssertNotNil(generic.focusSummary)
        XCTAssertEqual(generic.recommendedFocus, .calmDown)
    }

    func testTopicStyleTitlesAndManualLock() async {
        let generator = LocalChatTitleGenerator()
        let title = generator.title(for: [
            ChatMessage(sender: .user, text: "明天要面試，好緊張"),
            ChatMessage(sender: .twinko, text: "陪你"),
        ])
        XCTAssertEqual(title, "面試前的心情")
        XCTAssertFalse(title!.hasSuffix("。"))
        XCTAssertTrue((6...14).contains(title!.count))

        let english = generator.title(for: [
            ChatMessage(sender: .user, text: "I'm so stressed about work"),
            ChatMessage(sender: .twinko, text: "I'm here"),
        ])
        XCTAssertEqual(english, "Recent work stress")

        // Manual rename still locks out auto titles end-to-end.
        let store = ChatStore(store: jsonStore)
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.store = store
        viewModel.draftText = "明天要面試，好緊張"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)
        store.rename(viewModel.sessionID, to: "自訂名稱")
        viewModel.draftText = "還是好緊張"
        viewModel.send()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(store.session(with: viewModel.sessionID)?.title, "自訂名稱")
        XCTAssertEqual(store.session(with: viewModel.sessionID)?.titleSource, .user)
    }

    func testHistoryDateGrouping() {
        let calendar = Calendar.current
        let now = Date()
        func session(daysAgo: Int) -> ChatSession {
            var session = ChatSession()
            session.updatedAt = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
            return session
        }
        XCTAssertEqual(ChatHistoryGroup.group(for: now, now: now), .today)
        XCTAssertEqual(ChatHistoryGroup.group(for: session(daysAgo: 1).updatedAt, now: now), .yesterday)
        XCTAssertEqual(ChatHistoryGroup.group(for: session(daysAgo: 5).updatedAt, now: now), .previousSevenDays)
        XCTAssertEqual(ChatHistoryGroup.group(for: session(daysAgo: 30).updatedAt, now: now), .earlier)

        let grouped = ChatHistoryGroup.grouped(
            [session(daysAgo: 30), session(daysAgo: 0), session(daysAgo: 1), session(daysAgo: 0)],
            now: now)
        XCTAssertEqual(grouped.map(\.0), [.today, .yesterday, .earlier])
        XCTAssertEqual(grouped[0].1.count, 2)
        XCTAssertTrue(grouped[0].1[0].updatedAt >= grouped[0].1[1].updatedAt,
                      "Newest first inside each group")
    }

    func testMalformedFileLoadsAsEmpty() throws {
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        try Data("{broken".utf8).write(to: tempDirectory.appendingPathComponent("chat_sessions.json"))
        let store = ChatStore(store: jsonStore)
        XCTAssertTrue(store.sessions.isEmpty)
    }

    func testViewModelPersistsThroughStore() async {
        let store = ChatStore(store: jsonStore)
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.store = store
        viewModel.draftText = "嗨，我回來了"
        viewModel.send()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.messages.count, 2)

        let reloaded = ChatStore(store: jsonStore)
        XCTAssertEqual(reloaded.sessions.first?.messages.count, 2)
    }
}
