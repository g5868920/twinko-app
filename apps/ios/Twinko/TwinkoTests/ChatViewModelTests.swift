import XCTest
@testable import Twinko

@MainActor
final class ChatViewModelTests: XCTestCase {
    func testSendAppendsUserMessageImmediatelyAndEntersLoading() {
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.draftText = "hello"
        viewModel.send()

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.sender, .user)
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertTrue(viewModel.draftText.isEmpty)
    }

    func testLoadingTransitionsToSuccessForScriptedInput() async {
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.draftText = "hello there"
        viewModel.send()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages.last?.sender, .twinko)
    }

    func testLoadingTransitionsToErrorForUnmatchedInput() async {
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.draftText = "let's run an error test"
        viewModel.send()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.state, .error)
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages.last?.sender, .twinko)
    }

    func testEmptyOrWhitespaceDraftDoesNotSend() {
        let viewModel = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        viewModel.draftText = "   "
        viewModel.send()

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testNewViewModelInstanceStartsWithNoMessages() {
        let first = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        first.draftText = "hello"
        first.send()
        XCTAssertFalse(first.messages.isEmpty)

        let second = ChatViewModel(service: MockChatService(), loadingDelayNanoseconds: 1_000_000)
        XCTAssertTrue(second.messages.isEmpty)
    }
}
