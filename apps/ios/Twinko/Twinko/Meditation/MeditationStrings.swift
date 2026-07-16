import Foundation

/// Bilingual copy for the Meditation surface — one language at a time.
enum MeditationStrings {
    static func title(_ l: AppLanguage) -> String {
        l == .english ? "Meditate" : "冥想"
    }
    static func heroTitle(_ l: AppLanguage) -> String {
        l == .english ? "What do you need right now?" : "你現在最需要什麼？"
    }
    static func heroSubtitle(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko can create a meditation for what you're going through."
            : "Twinko 可以根據你正在經歷的事，陪你做一段專屬冥想。"
    }
    static func focusSection(_ l: AppLanguage) -> String {
        l == .english ? "Focus" : "想聚焦的方向"
    }
    static func durationSection(_ l: AppLanguage) -> String {
        l == .english ? "Duration" : "長度"
    }
    static func customInputLabel(_ l: AppLanguage) -> String {
        l == .english ? "What's on your mind? (optional)" : "想跟 Twinko 說的心事（可以不填）"
    }
    static func customInputPlaceholder(_ l: AppLanguage) -> String {
        l == .english
            ? "I'm feeling overwhelmed about work and want to feel more grounded."
            : "我最近對工作很焦慮，希望可以安定下來。"
    }
    /// Setup CTA — personalized entry (Chat / Tarot / check-in).
    static func startPersonalized(_ l: AppLanguage) -> String {
        l == .english ? "Begin My Meditation" : "開始專屬冥想"
    }
    /// Setup CTA — general entry.
    static func startGeneral(_ l: AppLanguage) -> String {
        l == .english ? "Begin Meditation" : "開始冥想"
    }
    static func useGeneralInstead(_ l: AppLanguage) -> String {
        l == .english ? "Use a general meditation instead" : "改用一般冥想"
    }
    static func recommendedTag(_ l: AppLanguage) -> String {
        l == .english ? "Recommended" : "建議"
    }
    static func twinkoRecommends(_ l: AppLanguage) -> String {
        l == .english ? "Twinko recommends:" : "Twinko 建議："
    }
    static func supplementLabel(_ l: AppLanguage) -> String {
        l == .english ? "Anything else you'd like to add? (Optional)" : "還有什麼想補充嗎？（選填）"
    }
    static func supplementPlaceholder(_ l: AppLanguage) -> String {
        l == .english
            ? "For example: I want to feel less anxious about the outcome…"
            : "例如：我希望可以更放下對結果的焦慮…"
    }

    // Source acknowledgment (subtle, no raw content)
    static func fromChat(_ l: AppLanguage) -> String {
        l == .english ? "Based on your recent Chat" : "根據你剛剛的聊天"
    }
    static func fromTarot(_ l: AppLanguage) -> String {
        l == .english ? "Based on your Tarot reading" : "根據你剛剛的塔羅解讀"
    }
    static func fromCheckIn(_ l: AppLanguage) -> String {
        l == .english ? "Based on today's check-in" : "根據今天的 Check-in"
    }
    static func focusSummaryLabel(_ l: AppLanguage) -> String {
        l == .english ? "Focus" : "這次的重點"
    }

    // Generating
    static func generating(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko is creating a meditation for what you're going through…"
            : "Twinko 正在根據你現在的狀態，準備一段專屬冥想⋯"
    }

    // Session (auto-progressing playback, 2026-07-17)
    static func segmentProgress(_ index: Int, _ total: Int, _ l: AppLanguage) -> String {
        l == .english ? "\(index) of \(total)" : "第 \(index)／\(total) 段"
    }
    static func pause(_ l: AppLanguage) -> String {
        l == .english ? "Pause" : "暫停"
    }
    static func resume(_ l: AppLanguage) -> String {
        l == .english ? "Resume" : "繼續"
    }
    static func narration(_ l: AppLanguage) -> String {
        l == .english ? "Voice guidance" : "語音引導"
    }
    static func ambientSound(_ l: AppLanguage) -> String {
        l == .english ? "Ambient sound" : "環境音"
    }
    static func remaining(_ minutesSeconds: String, _ l: AppLanguage) -> String {
        l == .english ? "\(minutesSeconds) left" : "剩下 \(minutesSeconds)"
    }
    static func next(_ l: AppLanguage) -> String {
        l == .english ? "Continue" : "繼續"
    }
    static func finish(_ l: AppLanguage) -> String {
        l == .english ? "Finish" : "完成"
    }
    static func endEarlyTitle(_ l: AppLanguage) -> String {
        l == .english ? "End this meditation for now?" : "要先結束這段冥想嗎？"
    }
    static func endEarlyBody(_ l: AppLanguage) -> String {
        l == .english
            ? "That's okay — you can come back whenever you're ready."
            : "沒關係，隨時準備好，都可以再回來。"
    }
    static func endSession(_ l: AppLanguage) -> String {
        l == .english ? "End session" : "結束冥想"
    }
    static func keepGoing(_ l: AppLanguage) -> String {
        l == .english ? "Continue meditation" : "繼續冥想"
    }

    // Completion
    /// Approved completion headline — no ending punctuation.
    static func completionTitle(_ l: AppLanguage) -> String {
        l == .english ? "You made a little space for yourself" : "你剛剛為自己留了一點空間"
    }
    static func moodQuestion(_ l: AppLanguage) -> String {
        l == .english ? "How do you feel now?" : "現在感覺怎麼樣？"
    }
    static func done(_ l: AppLanguage) -> String {
        l == .english ? "Done" : "完成"
    }

    // Errors
    static func generationFailed(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko couldn't finish preparing this one. Your choices are kept — try again?"
            : "這段冥想暫時沒有準備好，你的選擇都還在，再試一次好嗎？"
    }
    static func retry(_ l: AppLanguage) -> String {
        l == .english ? "Retry" : "再試一次"
    }

    // Chat offer / Tarot CTA
    // Chat offer copy moved to ChatStrings (shared confirmation card
    // for explicit + proactive triggers).
    static func tarotCTA(_ l: AppLanguage) -> String {
        l == .english ? "Turn this guidance into a meditation" : "把這份指引化成一段冥想"
    }
}

/// Completion mood options (feature spec §20) — all treated neutrally.
enum MeditationMood: String, CaseIterable, Identifiable {
    case calmer, aboutTheSame = "about_the_same", stillUnsettled = "still_unsettled"

    var id: String { rawValue }

    func label(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.calmer, .english): return "Calmer"
        case (.calmer, .traditionalChinese): return "比較平靜"
        case (.aboutTheSame, .english): return "About the same"
        case (.aboutTheSame, .traditionalChinese): return "差不多"
        case (.stillUnsettled, .english): return "Still unsettled"
        case (.stillUnsettled, .traditionalChinese): return "還是有點不安"
        }
    }
}
