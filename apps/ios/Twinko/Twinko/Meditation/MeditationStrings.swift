import Foundation

/// Bilingual copy for the Meditation surface — one language at a time.
enum MeditationStrings {
    static func title(_ l: AppLanguage) -> String {
        l == .english ? "Meditate" : "冥想"
    }
    static func heroTitle(_ l: AppLanguage) -> String {
        l == .english ? "What do you need right now?" : "你現在最需要什麼？"
    }
    /// Concise, warm setup subtitle (refinement 2026-07-17) — one
    /// calm line, never product-explainer copy.
    static func heroSubtitle(_ l: AppLanguage) -> String {
        l == .english
            ? "A meditation made for this moment."
            : "為此刻的你，準備一段專屬冥想"
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
    /// The one main Meditation CTA — identical for personalized and
    /// general entries (unified 2026-07-17).
    static func begin(_ l: AppLanguage) -> String {
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

    // Preparation (ritual-like, never technical — 2026-07-17)
    static func generating(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko is gathering a little starlight for you…"
            : "Twinko 正在為你收集此刻的星光⋯"
    }
    static func generatingSecondary(_ l: AppLanguage) -> String {
        l == .english
            ? "Preparing a gentle journey for this moment"
            : "為此刻的你，準備一段溫柔的旅程"
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
    // Exit modal — approved concise, reassuring copy (2026-07-17)
    static func endEarlyTitle(_ l: AppLanguage) -> String {
        l == .english ? "End this meditation?" : "要先結束冥想嗎？"
    }
    static func endEarlyBody(_ l: AppLanguage) -> String {
        l == .english
            ? "You can come back whenever you're ready."
            : "準備好時，隨時都能再回來。"
    }
    static func endSession(_ l: AppLanguage) -> String {
        l == .english ? "End Meditation" : "結束冥想"
    }
    static func keepGoing(_ l: AppLanguage) -> String {
        l == .english ? "Continue" : "繼續冥想"
    }
    /// Accessible countdown value for the session ring, e.g.
    /// "4 minutes 49 seconds remaining" / 「剩下 4 分 49 秒」.
    static func remainingAccessible(_ minutes: Int, _ seconds: Int,
                                    _ l: AppLanguage) -> String {
        l == .english
            ? "\(minutes) minutes \(seconds) seconds remaining"
            : "剩下 \(minutes) 分 \(seconds) 秒"
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

    /// Small neutral emotional glyphs from the system icon family —
    /// decorative alongside the label, never the only signal.
    var icon: String {
        switch self {
        case .calmer: return "sun.min.fill"
        case .aboutTheSame: return "cloud.fill"
        case .stillUnsettled: return "wind"
        }
    }
}
