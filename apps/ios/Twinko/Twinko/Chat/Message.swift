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

/// Whether a conversation title was generated automatically or set by
/// the user. Automatic generation may only ever overwrite `auto`.
enum TitleSource: String, Codable {
    case auto
    case user
}

/// One locally persisted conversation (D-054 Chat History).
struct ChatSession: Identifiable, Equatable, Codable {
    let id: UUID
    var createdAt: Date
    var updatedAt: Date
    var messages: [ChatMessage]
    /// Stored topic title; empty means "no title yet" and the UI shows
    /// the localized temporary title instead.
    var title: String
    var titleSource: TitleSource

    init(id: UUID = UUID(), createdAt: Date = .now, updatedAt: Date = .now,
         messages: [ChatMessage] = [], title: String = "",
         titleSource: TitleSource = .auto) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
        self.title = title
        self.titleSource = titleSource
    }

    /// Backward-compatible decoding: sessions saved before titles were
    /// stored load with an empty auto title.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        titleSource = try container.decodeIfPresent(TitleSource.self, forKey: .titleSource) ?? .auto
    }

    /// Title for display: the stored title, or the localized temporary
    /// title when none has been generated yet.
    func displayTitle(for lang: AppLanguage) -> String {
        title.isEmpty ? ChatStrings.temporaryTitle(lang) : title
    }

    /// Last message text, for history previews.
    var lastMessagePreview: String {
        messages.last?.text ?? ""
    }
}
