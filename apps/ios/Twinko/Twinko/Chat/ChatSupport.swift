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
        // Approved welcome headline — no ending punctuation.
        lang == .english ? "I'm here with you" : "我在這裡陪你"
    }
    static func introLine2(_ lang: AppLanguage) -> String {
        lang == .english ? "What’s on your mind today?" : "今天想聊些什麼呢？"
    }

    static func starters(_ lang: AppLanguage) -> [String] {
        // "我最近有點喘不過氣" was replaced — breathing-difficulty
        // wording is reserved for safety routing, never a casual
        // prompt (CPO review 2026-07-16).
        switch lang {
        case .english:
            return ["I want to talk about my day",
                    "I've been under some pressure lately",
                    "I just want some company"]
        case .traditionalChinese:
            return ["我想聊聊今天發生的事",
                    "我最近壓力有點大",
                    "我只是想有人陪我"]
        }
    }

    // MARK: Meditation confirmation (shared by explicit + proactive)

    /// Twinko's short acknowledgment when the user explicitly asks to
    /// meditate — matched to the language the user wrote in.
    static func meditationAckMessage(for input: String) -> String {
        let isCJK = input.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
        return isCJK
            ? "好呀，我們可以一起靜下來一會兒。"
            : "Of course — let's take a quiet moment together."
    }

    static func meditationConfirm(_ lang: AppLanguage) -> String {
        lang == .english
            ? "Would you like me to create a personalized meditation based on what we just talked about?"
            : "好呀。要不要讓我根據我們剛剛聊的事情，為你準備一段專屬冥想？"
    }
    static func meditationConfirmAccept(_ lang: AppLanguage) -> String {
        lang == .english ? "Yes, prepare it for me" : "好，為我準備"
    }
    static func meditationConfirmDecline(_ lang: AppLanguage) -> String {
        lang == .english ? "Not now" : "先不用"
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
    /// Single-sentence delete confirmation (2026-07-17) — no separate
    /// warning subtitle.
    static func deleteConfirmTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "Delete this conversation permanently?"
                         : "確定要永久刪除這段對話嗎？"
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

// MARK: - Meditation intent detection

/// Conversation-level meditation intent for one user message.
enum ChatMeditationIntent {
    case requestIntent   // the user is asking to meditate now
    case topicMention    // meditation is discussed, not requested
    case none
}

/// Centralized deterministic intent matcher (EN + zh-Hant). This is
/// the single place feature-intent keywords live — replaceable by a
/// model later without touching views or the view model's routing.
enum MeditationIntentDetector {
    /// Phrases that clearly ask for a meditation / calming session.
    private static let requestPatterns = [
        // zh-Hant
        "想冥想", "想要冥想", "要冥想", "帶我冥想", "陪我冥想", "带我冥想",
        "做一段冥想", "來冥想", "冥想一下", "需要冥想", "一起冥想",
        "想靜一下", "想靜一靜", "想冷靜", "需要放鬆", "想放鬆一下", "需要冷靜",
        // en
        "want to meditate", "need to meditate", "meditate with me",
        "guide me through a meditation", "let's meditate", "lets meditate",
        "help me meditate", "i want a meditation", "help me calm down",
        "i need to relax", "i need to calm down",
    ]

    /// Markers that make a meditation keyword read as discussion, not
    /// a request (past tense, opinions, questions about meditation).
    private static let topicMarkers = [
        "昨天", "之前", "上次", "有用嗎", "有效嗎", "不喜歡", "覺得冥想",
        "你覺得", "怎麼看", "嗎？", "嗎?",
        "yesterday", "last time", "do you think", "is meditation",
        "don't like", "dont like", "didn't work", "didnt work",
    ]

    private static let meditationKeywords = ["冥想", "meditat"]

    static func detect(_ text: String) -> ChatMeditationIntent {
        let normalized = text.lowercased()
        let mentionsMeditation = meditationKeywords.contains { normalized.contains($0) }
        let matchesRequest = requestPatterns.contains { normalized.contains($0) }
        let matchesTopicMarker = topicMarkers.contains { normalized.contains($0) }

        if matchesRequest && !matchesTopicMarker {
            return .requestIntent
        }
        if mentionsMeditation {
            return .topicMention
        }
        return .none
    }
}

// MARK: - Meditation offer state

/// One conversation-level meditation confirmation offer. Explicit
/// requests and proactive suggestions share this single state — never
/// two cards at once, never separate competing implementations.
struct ChatMeditationOffer: Equatable {
    enum Source { case explicitRequest, proactiveSuggestion }
    let source: Source
    /// The Twinko message this offer follows.
    let messageID: UUID
}

// MARK: - Chat → Meditation context adapter

/// Centralized Chat-to-Meditation adaptation: derives a concise
/// reflective focus summary and a recommended theme from the recent
/// user messages — never the raw transcript, never verbatim quotes.
enum ChatMeditationContextAdapter {
    private struct Topic {
        let keywords: [String]
        let focus: MeditationFocus
        let zh: String
        let en: String
    }

    private static let topics: [Topic] = [
        Topic(keywords: ["工作", "加班", "上班", "老闆", "報告", "work", "job", "boss"],
              focus: .releaseAnxiety,
              zh: "最近因為工作壓力而感到焦慮，希望先安定下來，重新找回自己的節奏。",
              en: "Work pressure has felt heavy lately — you'd like to settle first and find your own pace again."),
        Topic(keywords: ["睡", "失眠", "sleep", "insomnia"],
              focus: .sleep,
              zh: "最近比較難放鬆入睡，希望讓身體和思緒慢慢安靜下來。",
              en: "Winding down has been hard lately — you'd like to let your body and mind quiet gently."),
        Topic(keywords: ["感情", "關係", "喜歡", "曖昧", "吵架", "relationship", "partner"],
              focus: .selfLove,
              zh: "關係裡有些心情放不下，希望先照顧好自己，再慢慢想清楚。",
              en: "Something in a relationship is sitting on your heart — you'd like to care for yourself first and think it through slowly."),
        Topic(keywords: ["焦慮", "緊張", "擔心", "不安", "壓力", "anxious", "anxiety", "stress", "nervous", "overwhelmed"],
              focus: .releaseAnxiety,
              zh: "最近心裡有些焦慮與緊繃，希望把它輕輕放下，安定下來。",
              en: "There's been some anxiety and tension lately — you'd like to set it down gently and feel steadier."),
        Topic(keywords: ["累", "疲憊", "疲累", "tired", "exhausted"],
              focus: .calmDown,
              zh: "最近覺得比較疲憊，希望給自己一段安靜的休息時間。",
              en: "You've been feeling worn out — you'd like a quiet stretch of rest for yourself."),
    ]

    static func context(for messages: [ChatMessage], lang: AppLanguage) -> MeditationSourceContext {
        let recentUserText = messages.suffix(8)
            .filter { $0.sender == .user }
            .map(\.text)
            .joined(separator: " ")
            .lowercased()

        let matched = topics.first { topic in
            topic.keywords.contains { recentUserText.contains($0) }
        }
        let summary = matched.map { lang == .english ? $0.en : $0.zh }
            ?? (lang == .english
                ? "Something has been on your mind — you'd like a quiet moment to settle and stay with yourself for a while."
                : "最近心裡有些事情放不下，希望能安靜下來，陪自己一會兒。")

        return MeditationSourceContext(
            sourceType: .chat,
            recentChatSummary: nil,
            tarotQuestion: nil,
            tarotSummary: nil,
            emotionalTone: nil,
            focusSummary: summary,
            recommendedFocus: matched?.focus ?? .calmDown)
    }
}

// MARK: - History date grouping

/// Localized Chat History date groups (Today / Yesterday / Previous 7
/// Days / Earlier), grouped by latest activity.
enum ChatHistoryGroup: Int, CaseIterable {
    case today, yesterday, previousSevenDays, earlier

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.today, .english): return "Today"
        case (.today, .traditionalChinese): return "今天"
        case (.yesterday, .english): return "Yesterday"
        case (.yesterday, .traditionalChinese): return "昨天"
        case (.previousSevenDays, .english): return "Previous 7 Days"
        case (.previousSevenDays, .traditionalChinese): return "過去 7 天"
        case (.earlier, .english): return "Earlier"
        case (.earlier, .traditionalChinese): return "更早"
        }
    }

    static func group(for date: Date, now: Date = .now,
                      calendar: Calendar = .current) -> ChatHistoryGroup {
        if calendar.isDate(date, inSameDayAs: now) { return .today }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) { return .yesterday }
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
           date >= calendar.startOfDay(for: weekAgo) { return .previousSevenDays }
        return .earlier
    }

    /// Ordered (group, sessions) pairs, newest first inside each group.
    static func grouped(_ sessions: [ChatSession],
                        now: Date = .now) -> [(ChatHistoryGroup, [ChatSession])] {
        let buckets = Dictionary(grouping: sessions) { group(for: $0.updatedAt, now: now) }
        return ChatHistoryGroup.allCases.compactMap { group in
            guard let items = buckets[group], !items.isEmpty else { return nil }
            return (group, items.sorted { $0.updatedAt > $1.updatedAt })
        }
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

    /// ChatGPT-style topic titles: concise core-topic phrasing per
    /// locale, matched from the first meaningful user messages. Falls
    /// back to the cleaned first message when no topic matches.
    private static let topicTitles: [(keywords: [String], zh: String, en: String)] = [
        (["面試", "interview"], "面試前的心情", "Nerves before an interview"),
        (["工作", "加班", "老闆", "上班", "work", "job", "boss"], "最近的工作壓力", "Recent work stress"),
        (["壓力", "stress", "pressure"], "壓力有點大的日子", "Feeling the pressure lately"),
        (["失眠", "睡不著", "睡不好", "sleep", "insomnia"], "睡眠與放鬆", "Sleep and winding down"),
        (["感情", "關係", "曖昧", "吵架", "relationship", "partner"], "關係裡的心情", "Feelings about a relationship"),
        (["陪我", "陪伴", "有人陪", "company", "lonely"], "想有人陪的時刻", "Wanting some company"),
        (["累", "疲憊", "疲累", "tired", "exhausted"], "最近總覺得很累", "Feeling tired lately"),
        (["難過", "低落", "傷心", "想哭", "sad", "down"], "心情低落的一天", "A heavy day"),
        (["焦慮", "緊張", "不安", "擔心", "anxious", "anxiety", "nervous"], "心裡的焦慮與不安", "Sitting with some anxiety"),
        (["自信", "做不到", "失敗", "沒用", "failure", "doubt"], "自我懷疑的心情", "Wrestling with self-doubt"),
    ]

    func title(for messages: [ChatMessage]) -> String? {
        // Need the first user message and at least one Twinko response.
        guard messages.contains(where: { $0.sender == .twinko }),
              let first = messages.first(where: {
                  $0.sender == .user &&
                  !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              }) else { return nil }

        // Topic-style title from the first meaningful user messages.
        let userText = messages.prefix(6)
            .filter { $0.sender == .user }
            .map(\.text)
            .joined(separator: " ")
        let isEnglish = !userText.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
        if let topic = Self.topicTitles.first(where: { entry in
            entry.keywords.contains { userText.localizedCaseInsensitiveContains($0) }
        }) {
            return isEnglish ? topic.en : topic.zh
        }

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
