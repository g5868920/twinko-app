import Foundation

enum ChatState: Equatable {
    case idle
    case loading
    case success
    case error
}

/// Drives one Chat session. Messages live in memory while chatting and
/// are persisted through `ChatStore` (Codable JSON, local only) after
/// every exchange, so sessions survive relaunch per D-054.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage]
    @Published private(set) var state: ChatState = .idle
    @Published var draftText: String = ""

    /// Attached by the view; optional so unit tests can run pure
    /// in-memory conversations.
    weak var store: ChatStore?

    private let service: MockChatServicing
    private let loadingDelayNanoseconds: UInt64
    private var session: ChatSession

    nonisolated init(session: ChatSession = ChatSession(),
                     service: MockChatServicing = MockChatService(),
                     loadingDelayNanoseconds: UInt64 = 500_000_000) {
        self.session = session
        self.service = service
        self.loadingDelayNanoseconds = loadingDelayNanoseconds
        _messages = Published(initialValue: session.messages)
    }

    var sessionID: UUID { session.id }

    func send() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, state != .loading else { return }

        append(ChatMessage(sender: .user, text: trimmed))
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
            append(ChatMessage(sender: .twinko, text: text))
            state = .success
        case .fallback(let text):
            append(ChatMessage(sender: .twinko, text: text))
            state = .error
        }
    }

    private func append(_ message: ChatMessage) {
        messages.append(message)
        session.messages = messages
        session.updatedAt = .now
        store?.upsert(session)
    }
}
