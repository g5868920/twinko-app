import Foundation

/// Bilingual copy for the Tarot surface (never both languages at
/// once). Canonical values live in enums; only display text localizes.
enum TarotStrings {
    static func title(_ l: AppLanguage) -> String { l == .english ? "Tarot" : "塔羅" }

    // Setup
    static func setupTitle(_ l: AppLanguage) -> String {
        l == .english ? "What would you like to explore today?" : "今天想聊哪個方向？"
    }
    static func questionLabel(_ l: AppLanguage) -> String {
        l == .english ? "Your question (optional)" : "想問的問題（可以不填）"
    }
    static func questionHint(_ l: AppLanguage) -> String {
        l == .english ? "Or try asking:" : "或試試這樣問："
    }
    static func next(_ l: AppLanguage) -> String { l == .english ? "Next" : "下一步" }

    // Spread
    static func spreadTitle(_ l: AppLanguage) -> String {
        l == .english ? "Choose your spread" : "想用哪一種牌陣？"
    }

    // Shuffle / reveal
    static func shuffling(_ l: AppLanguage) -> String {
        l == .english ? "Twinko is shuffling for you…" : "Twinko 正在為你洗牌⋯⋯"
    }
    static func revealSingle(_ l: AppLanguage) -> String {
        l == .english ? "This card is here for you today" : "這是今天陪你的牌"
    }
    static func revealThree(_ l: AppLanguage) -> String {
        l == .english ? "Left to right: Past · Present · Future" : "由左到右：過去・現在・未來"
    }
    static func revealGuidance(_ l: AppLanguage) -> String {
        l == .english ? "Your Guidance Card is ready" : "你的指引牌準備好了"
    }
    static func tapToFlip(_ l: AppLanguage) -> String {
        l == .english ? "Tap a card to turn it over" : "輕點牌面，把牌翻開"
    }
    static func seeReading(_ l: AppLanguage) -> String {
        l == .english ? "See what the cards say" : "看看牌想說什麼"
    }
    static func faceDownCard(_ l: AppLanguage) -> String {
        l == .english ? "Face-down card, double-tap to reveal" : "蓋著的牌，點兩下翻開"
    }

    // Result
    static func overallTitle(_ l: AppLanguage) -> String {
        l == .english ? "Reading it together" : "整體來看"
    }
    static func finalSummaryTitle(_ l: AppLanguage) -> String {
        l == .english ? "Twinko's final message" : "Twinko 想對你說"
    }
    static func guidancePrompt(_ l: AppLanguage) -> String {
        l == .english ? "Would you like to draw one Guidance Card?" : "想再抽一張指引牌嗎？"
    }
    static func guidanceAccept(_ l: AppLanguage) -> String {
        l == .english ? "Draw a Guidance Card" : "抽一張指引牌"
    }
    static func guidanceDecline(_ l: AppLanguage) -> String {
        l == .english ? "Finish without it" : "先這樣就好"
    }
    static func reflectionLabel(_ l: AppLanguage) -> String {
        l == .english ? "A little reflection" : "小小的反思"
    }
    static func shareText(_ l: AppLanguage) -> String {
        l == .english ? "Share reading" : "分享結果"
    }
    static func saveCard(_ l: AppLanguage) -> String {
        l == .english ? "Save summary card" : "儲存指引小卡"
    }
    static func drawAgain(_ l: AppLanguage) -> String { l == .english ? "Draw again" : "再抽一次" }
    static func backHome(_ l: AppLanguage) -> String { l == .english ? "Back to Home" : "回到首頁" }

    // Summary card
    static func summaryCardTitle(_ l: AppLanguage) -> String {
        l == .english ? "Twinko Tarot Guidance" : "Twinko 塔羅指引"
    }
    static func summaryCardShare(_ l: AppLanguage) -> String {
        l == .english ? "Share or save image" : "分享或儲存圖片"
    }
    static func done(_ l: AppLanguage) -> String { l == .english ? "Done" : "完成" }
}

// MARK: - Share text formatter

/// Formats a completed reading as clean share-sheet text.
enum TarotShareFormatter {
    static func text(for session: TarotReadingSession,
                     provider: TarotInterpretationProviding,
                     lang: AppLanguage) -> String {
        var lines: [String] = []
        lines.append(lang == .english ? "✦ Twinko Tarot" : "✦ Twinko 塔羅")
        lines.append(session.spread.title(lang) + (session.guidanceCard != nil
            ? (lang == .english ? " + Guidance" : "＋指引牌") : ""))
        let q = session.trimmedQuestion
        if !q.isEmpty {
            lines.append((lang == .english ? "Q: " : "問：") + q)
        }
        lines.append("")
        for drawn in session.allCards {
            var line = "· "
            if let position = drawn.position {
                line += lang == .english ? "\(position.label(lang)): " : "\(position.label(lang))｜"
            }
            line += lang == .english
                ? "\(drawn.card.displayNameEn) (\(drawn.orientation.label(lang)))"
                : "\(drawn.card.displayNameZh)（\(drawn.orientation.label(lang))）"
            lines.append(line)
        }
        lines.append("")
        lines.append(provider.combinedSummary(for: session, lang: lang))
        lines.append("")
        lines.append(lang == .english ? "— from TwinkoTalk" : "— 來自 TwinkoTalk")
        return lines.joined(separator: "\n")
    }
}
