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
