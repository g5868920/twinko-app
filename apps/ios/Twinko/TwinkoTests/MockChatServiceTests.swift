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

// MARK: - Locale-aware responses (Chat polish 2026-07-17)

extension MockChatServiceTests {
    func testEnglishLocaleReturnsEnglishScriptedResponse() {
        let service = MockChatService()
        for input in ["I want to talk about my day", "work has been stressful"] {
            guard case .success(let text) = service.response(for: input, lang: .english) else {
                return XCTFail("Expected scripted response for \(input)")
            }
            XCTAssertFalse(text.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) },
                           "English locale must produce English replies: \(text)")
        }
    }

    func testTraditionalChineseLocaleReturnsChineseScriptedResponse() {
        let service = MockChatService()
        guard case .success(let text) = service.response(for: "我最近壓力有點大",
                                                         lang: .traditionalChinese) else {
            return XCTFail("Expected scripted response")
        }
        XCTAssertTrue(text.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) })
    }

    func testFallbackMatchesLocale() {
        let service = MockChatService()
        guard case .fallback(let en) = service.response(for: "xyzzy quux plugh", lang: .english),
              case .fallback(let zh) = service.response(for: "xyzzy quux plugh",
                                                        lang: .traditionalChinese) else {
            return XCTFail("Expected fallbacks")
        }
        XCTAssertFalse(en.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) })
        XCTAssertTrue(zh.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) })
    }

    func testQuickPromptsAndWelcomeAndDeleteCopyAreLocalized() {
        XCTAssertEqual(ChatStrings.introLine1(.traditionalChinese), "我在這裡陪你")
        XCTAssertEqual(ChatStrings.introLine1(.english), "I'm here with you")
        XCTAssertEqual(ChatStrings.starters(.english),
                       ["I want to talk about my day",
                        "I've been under some pressure lately",
                        "I just want some company"])
        XCTAssertEqual(ChatStrings.starters(.traditionalChinese),
                       ["我想聊聊今天發生的事", "我最近壓力有點大", "我只是想有人陪我"])
        XCTAssertEqual(ChatStrings.deleteConfirmTitle(.traditionalChinese),
                       "確定要永久刪除這段對話嗎？")
        XCTAssertEqual(ChatStrings.deleteConfirmTitle(.english),
                       "Delete this conversation permanently?")
    }

    @MainActor
    func testTabBarHiddenOnlyForActiveConversation() {
        XCTAssertFalse(ChatView.hidesTabBar(conversationActive: false),
                       "Chat landing keeps the bottom navigation")
        XCTAssertTrue(ChatView.hidesTabBar(conversationActive: true),
                      "Active conversation hides the bottom navigation")
    }
}
