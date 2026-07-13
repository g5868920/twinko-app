import Foundation

enum ChatState: Equatable {
    case idle
    case loading
    case success
    case error
}

/// All state here is in-memory only for the lifetime of this instance —
/// there is no persistence layer, so messages do not survive app
/// termination. See docs/prototype/TWINKO_P0_APP_SHELL_MOCK_CHAT_SPEC.md §7.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var state: ChatState = .idle
    @Published var draftText: String = ""

    private let service: MockChatServicing
    private let loadingDelayNanoseconds: UInt64

    nonisolated init(service: MockChatServicing = MockChatService(), loadingDelayNanoseconds: UInt64 = 500_000_000) {
        self.service = service
        self.loadingDelayNanoseconds = loadingDelayNanoseconds
    }

    func send() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(sender: .user, text: trimmed))
        draftText = ""
        state = .loading

        Task {
            try? await Task.sleep(nanoseconds: loadingDelayNanoseconds)
            respond(to: trimmed)
        }
    }

    private func respond(to input: String) {
        switch service.response(for: input) {
        case .success(let text):
            messages.append(ChatMessage(sender: .twinko, text: text))
            state = .success
        case .fallback(let text):
            messages.append(ChatMessage(sender: .twinko, text: text))
            state = .error
        }
    }
}
