import Foundation

enum MessageSender: Equatable {
    case user
    case twinko
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let sender: MessageSender
    let text: String

    init(id: UUID = UUID(), sender: MessageSender, text: String) {
        self.id = id
        self.sender = sender
        self.text = text
    }
}
