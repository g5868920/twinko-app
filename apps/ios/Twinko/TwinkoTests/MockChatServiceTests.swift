import XCTest
@testable import Twinko

final class MockChatServiceTests: XCTestCase {
    func testScriptedKeywordReturnsSuccessResponse() {
        let service = MockChatService()
        let result = service.response(for: "我今天覺得好難過")

        switch result {
        case .success(let text):
            XCTAssertFalse(text.isEmpty)
        case .fallback:
            XCTFail("Expected a scripted success response for a known keyword")
        }
    }

    func testGreetingKeywordReturnsSuccessResponse() {
        let service = MockChatService()
        let result = service.response(for: "嗨嗨")

        switch result {
        case .success(let text):
            XCTAssertFalse(text.isEmpty)
        case .fallback:
            XCTFail("Expected a scripted success response for a greeting")
        }
    }

    func testErrorTriggerReturnsFallbackResponse() {
        let service = MockChatService()
        for trigger in ["let's run an error test", "測試錯誤"] {
            switch service.response(for: trigger) {
            case .fallback(let text):
                XCTAssertFalse(text.isEmpty)
            case .success:
                XCTFail("Expected a fallback response for the error trigger phrase: \(trigger)")
            }
        }
    }

    func testUnmatchedInputReturnsFallbackResponse() {
        let service = MockChatService()
        let result = service.response(for: "xyzzy quux plugh")

        switch result {
        case .fallback(let text):
            XCTAssertFalse(text.isEmpty)
        case .success:
            XCTFail("Expected a fallback response for unmatched input")
        }
    }

    func testResponsesAreDeterministic() {
        let service = MockChatService()
        XCTAssertEqual(service.response(for: "工作壓力好大"),
                       service.response(for: "工作壓力好大"))
    }
}
