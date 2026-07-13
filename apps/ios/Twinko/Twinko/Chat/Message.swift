import Foundation

enum MessageSender: String, Codable, Equatable {
    case user
    case twinko
}

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let sender: MessageSender
    let text: String
    let sentAt: Date

    init(id: UUID = UUID(), sender: MessageSender, text: String, sentAt: Date = .now) {
        self.id = id
        self.sender = sender
        self.text = text
        self.sentAt = sentAt
    }
}

/// One locally persisted conversation (D-054 Chat History).
struct ChatSession: Identifiable, Equatable, Codable {
    let id: UUID
    var createdAt: Date
    var updatedAt: Date
    var messages: [ChatMessage]

    init(id: UUID = UUID(), createdAt: Date = .now, updatedAt: Date = .now,
         messages: [ChatMessage] = []) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
    }

    /// Deterministic title rule: the first meaningful user message,
    /// truncated safely; falls back to a generic label.
    var title: String {
        guard let first = messages.first(where: {
            $0.sender == .user &&
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else { return "新的對話" }
        let text = first.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count <= 14 { return text }
        return String(text.prefix(14)) + "…"
    }
}
