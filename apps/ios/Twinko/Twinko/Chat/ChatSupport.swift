import Foundation

// MARK: - Day / night

/// Day/night selection for the Chat Twinko outfit (spec: 06:00–17:59
/// local time is Day). Derived at render time, never persisted.
enum ChatDayNight {
    static func isDay(_ date: Date = .now, calendar: Calendar = .current) -> Bool {
        // Test-only overrides for deterministic screenshots; there is
        // no user-facing toggle.
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uiTestForceDay") { return true }
        if args.contains("-uiTestForceNight") { return false }
        let hour = calendar.component(.hour, from: date)
        return (6...17).contains(hour)
    }

    static func twinkoAssetName(_ date: Date = .now) -> String {
        isDay(date) ? "twinko_chat_day_v1_transparent" : "twinko_chat_night_v1_transparent"
    }
}

// MARK: - Localized chat strings

/// Bilingual copy for the Chat surface. Canonical values live in code;
/// only display text is localized (DESIGN.md §21).
enum ChatStrings {
    static func title(_ lang: AppLanguage) -> String {
        lang == .english ? "Chat" : "聊天"
    }

    static func introLine1(_ lang: AppLanguage) -> String {
        lang == .english ? "I’m here with you." : "我在這裡陪你。"
    }
    static func introLine2(_ lang: AppLanguage) -> String {
        lang == .english ? "What’s on your mind today?" : "今天想聊些什麼呢？"
    }

    static func starters(_ lang: AppLanguage) -> [String] {
        switch lang {
        case .english:
            return ["I want to talk about my day",
                    "I feel a little overwhelmed",
                    "I just want some company"]
        case .traditionalChinese:
            return ["我想聊聊今天發生的事",
                    "我最近有點喘不過氣",
                    "我只是想有人陪我"]
        }
    }

    static func composerPlaceholder(_ lang: AppLanguage) -> String {
        lang == .english ? "Tell me what’s on your mind..." : "想跟我說些什麼呢？"
    }

    static func newChat(_ lang: AppLanguage) -> String {
        lang == .english ? "New Chat" : "新對話"
    }
    static func history(_ lang: AppLanguage) -> String {
        lang == .english ? "History" : "聊天紀錄"
    }
    static func temporaryTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "New Conversation" : "新對話"
    }

    static func rename(_ lang: AppLanguage) -> String {
        lang == .english ? "Rename" : "重新命名"
    }
    static func delete(_ lang: AppLanguage) -> String {
        lang == .english ? "Delete" : "刪除"
    }
    static func cancel(_ lang: AppLanguage) -> String {
        lang == .english ? "Cancel" : "取消"
    }
    static func save(_ lang: AppLanguage) -> String {
        lang == .english ? "Save" : "儲存"
    }
    static func deleteConfirmTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "Delete this conversation?" : "刪除這段對話？"
    }
    static func deleteConfirmBody(_ lang: AppLanguage) -> String {
        lang == .english ? "This can’t be undone." : "刪除後無法復原。"
    }
    static func discardDraftTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "Discard your unsent message?" : "捨棄尚未送出的訊息？"
    }
    static func discardDraft(_ lang: AppLanguage) -> String {
        lang == .english ? "Discard" : "捨棄"
    }
    static func keepWriting(_ lang: AppLanguage) -> String {
        lang == .english ? "Keep Writing" : "繼續輸入"
    }
    static func emptyHistoryTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "No conversations yet" : "還沒有聊天紀錄"
    }
    static func emptyHistoryBody(_ lang: AppLanguage) -> String {
        lang == .english
            ? "Chats with Twinko are kept quietly here, only on this device."
            : "跟 Twinko 聊過的話，會安安靜靜地收在這裡，只留在這台裝置上。"
    }
    static func errorRetry(_ lang: AppLanguage) -> String {
        lang == .english ? "Something went wrong. Tap to try again."
                         : "出了點問題，點一下再試一次。"
    }
    static func renameEmptyError(_ lang: AppLanguage) -> String {
        lang == .english ? "Title can’t be empty" : "標題不能是空白"
    }
}

// MARK: - Title generation

/// Small replaceable abstraction so an AI title service can slot in
/// later without touching call sites. No backend exists or is added.
protocol ChatTitleGenerating: Sendable {
    /// A concise topic title, or nil if not enough context yet.
    func title(for messages: [ChatMessage]) -> String?
}

/// Local fallback: derives a clean title from the first meaningful user
/// message — strips greetings/filler, emoji, and quotes, then truncates
/// (~30 Latin characters / ~14 Traditional Chinese characters).
struct LocalChatTitleGenerator: ChatTitleGenerating {
    private static let fillerPrefixes = [
        "嗨", "哈囉", "你好", "妳好", "欸", "嘿", "hi", "hello", "hey",
        "我想聊聊", "我想聊", "我想說", "我覺得", "就是",
        "i want to talk about", "i want to talk", "i just want",
        "i feel like", "i think", "well", "so", "um", "uh"
    ]

    func title(for messages: [ChatMessage]) -> String? {
        // Need the first user message and at least one Twinko response.
        guard messages.contains(where: { $0.sender == .twinko }),
              let first = messages.first(where: {
                  $0.sender == .user &&
                  !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              }) else { return nil }

        var text = first.text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip emoji, pictographs, ZWJ, and variation selectors.
        text = String(text.unicodeScalars.filter { scalar in
            if scalar.value == 0x200D || (0xFE00...0xFE0F).contains(scalar.value) { return false }
            if scalar.properties.isEmoji && scalar.value > 0x2100 { return false }
            return true
        })
        // Strip quotation marks.
        text = text.replacingOccurrences(of: "[\"'“”‘’「」『』]", with: "",
                                         options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Drop leading greeting/filler words (repeat once for chains).
        for _ in 0..<2 {
            let lowered = text.lowercased()
            for filler in Self.fillerPrefixes where lowered.hasPrefix(filler) {
                text = String(text.dropFirst(filler.count))
                text = text.trimmingCharacters(in: CharacterSet(charactersIn: " ，,。.!？?～~"))
                break
            }
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        // Truncate: ~14 CJK chars or ~30 Latin characters.
        let isCJKHeavy = text.unicodeScalars.filter { $0.value >= 0x4E00 && $0.value <= 0x9FFF }.count
            > text.count / 2
        let limit = isCJKHeavy ? 14 : 30
        if text.count > limit {
            text = String(text.prefix(limit)).trimmingCharacters(in: .whitespaces)
        }
        // No trailing punctuation.
        while let last = text.last, "，,。.!！？?～~；;：: ".contains(last) {
            text.removeLast()
        }
        return text.isEmpty ? nil : text
    }
}
