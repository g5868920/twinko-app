import XCTest
@testable import Twinko

final class MockChatServiceTests: XCTestCase {
    func testScriptedKeywordReturnsSuccessResponse() {
        let service = MockChatService()
        let result = service.response(for: "I'm feeling really sad today")

        switch result {
        case .success(let text):
            XCTAssertFalse(text.isEmpty)
        case .fallback:
            XCTFail("Expected a scripted success response for a known keyword")
        }
    }

    func testErrorTriggerReturnsFallbackResponse() {
        let service = MockChatService()
        let result = service.response(for: "let's run an error test")

        switch result {
        case .fallback(let text):
            XCTAssertFalse(text.isEmpty)
        case .success:
            XCTFail("Expected a fallback response for the error trigger phrase")
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
}
