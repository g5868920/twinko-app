import Foundation

/// Deterministic, local-only response selection. No network access and
/// no live model call of any kind — see
/// docs/prototype/TWINKO_P0_APP_SHELL_MOCK_CHAT_SPEC.md §7.
enum MockChatResult: Equatable {
    case success(String)
    case fallback(String)
}

protocol MockChatServicing {
    func response(for input: String) -> MockChatResult
}

struct MockChatService: MockChatServicing {
    /// Local, development-only phrase that deterministically triggers the
    /// fallback/error state, per FR-P0-5's requirement for a simple way
    /// to exercise it without relying on chance keyword misses.
    static let errorTrigger = "error test"

    private let scriptedResponses: [(keywords: [String], response: String)] = [
        (["sad", "down", "upset"],
         "That sounds heavy. I'm here with you — want to tell me a bit more about what's going on?"),
        (["worried", "anxious", "nervous"],
         "It makes sense to feel that way. Would it help to talk through what's worrying you, or would you rather just sit with it for a moment?"),
        (["confidence", "proud", "did it"],
         "That's worth noticing. What part of this felt the best to you?"),
        (["hi", "hello", "hey"],
         "Hi, I'm glad you're here. How are you feeling right now?")
    ]

    private let fallbackResponse =
        "I may not have quite understood that. Could you say it a different way, or pick a simple word for how you're feeling right now?"

    func response(for input: String) -> MockChatResult {
        let normalized = input.lowercased()

        if normalized.contains(Self.errorTrigger) {
            return .fallback(fallbackResponse)
        }

        for entry in scriptedResponses where entry.keywords.contains(where: { normalized.contains($0) }) {
            return .success(entry.response)
        }

        return .fallback(fallbackResponse)
    }
}
