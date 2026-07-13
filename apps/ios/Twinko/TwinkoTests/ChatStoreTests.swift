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

        XCTAssertEqual(store.sessions.first?.title, "新的")
    }

    func testTitleRuleTruncatesSafely() {
        let long = ChatSession(messages: [
            ChatMessage(sender: .user, text: "這是一段非常非常長的訊息應該要被截斷才對喔")
        ])
        XCTAssertTrue(long.title.hasSuffix("…"))
        XCTAssertLessThanOrEqual(long.title.count, 15)

        let empty = ChatSession()
        XCTAssertEqual(empty.title, "新的對話")
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
