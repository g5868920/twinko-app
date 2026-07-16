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
        l == .english ? "Tap a card to reveal it." : "輕點牌面，把牌翻開。"
    }
    static func tapNextCard(_ l: AppLanguage) -> String {
        l == .english ? "Reveal the next card." : "繼續翻開下一張牌。"
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
        l == .english ? "Want one more card for practical guidance?" : "還想知道接下來可以怎麼做嗎？"
    }
    static func guidancePromptBody(_ l: AppLanguage) -> String {
        l == .english
            ? "This card offers one action or reflection to take with you."
            : "這張牌會提供一個可以帶走的行動提醒。"
    }
    static func guidanceAccept(_ l: AppLanguage) -> String {
        l == .english ? "Draw a Guidance Card" : "抽一張指引牌"
    }
    static func showFullInterpretation(_ l: AppLanguage) -> String {
        l == .english ? "Show full interpretation" : "展開完整解讀"
    }
    static func hideFullInterpretation(_ l: AppLanguage) -> String {
        l == .english ? "Hide full interpretation" : "收合完整解讀"
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
    static func startNewReading(_ l: AppLanguage) -> String {
        l == .english ? "Start a New Reading" : "開始新的占卜"
    }
    static func backHome(_ l: AppLanguage) -> String { l == .english ? "Back to Home" : "回到首頁" }
    static func meditationHelper(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko will use your question and the reading's main guidance to create a personalized meditation."
            : "Twinko 會根據你的問題與牌卡整體訊息，生成一段專屬冥想。"
    }

    // Summary card
    static func summaryCardTitle(_ l: AppLanguage) -> String {
        l == .english ? "Twinko Tarot Guidance" : "Twinko 塔羅指引"
    }
    static func summaryCardShare(_ l: AppLanguage) -> String {
        l == .english ? "Share or save image" : "分享或儲存圖片"
    }
    static func done(_ l: AppLanguage) -> String { l == .english ? "Done" : "完成" }
}

// MARK: - Tarot → Meditation context adapter

/// Centralized Tarot-to-Meditation adaptation (spec §15–16, §22):
/// summarizes the reading into a concise reflective focus, recommends
/// one theme and a duration, and strips deterministic wording. Never
/// passes raw interpretations or card-name lists to the Meditation
/// surface.
enum TarotMeditationContextAdapter {
    static func context(for session: TarotReadingSession,
                        provider: TarotInterpretationProviding,
                        lang: AppLanguage) -> MeditationSourceContext {
        MeditationSourceContext(
            sourceType: .tarot,
            recentChatSummary: nil,
            tarotQuestion: session.trimmedQuestion.isEmpty ? nil : session.trimmedQuestion,
            tarotSummary: provider.combinedSummary(for: session, lang: lang),
            emotionalTone: nil,
            focusSummary: focusSummary(for: session.topic, lang: lang),
            recommendedFocus: recommendedFocus(for: session.topic))
    }

    /// Twinko's recommended Meditation theme per Tarot topic.
    static func recommendedFocus(for topic: TarotTopicType) -> MeditationFocus {
        switch topic {
        case .love: return .selfLove
        case .career: return .releaseAnxiety
        case .growth: return .selfLove
        case .general: return .calmDown
        }
    }

    /// Concise adapted focus (2 short lines): emotional tension +
    /// desired state, in possibility language — no card names, no raw
    /// interpretation text, no predictions, no ellipsis.
    static func focusSummary(for topic: TarotTopicType, lang: AppLanguage) -> String {
        switch (topic, lang) {
        case (.love, .traditionalChinese):
            return "你正在關係裡尋找更多理解與安心，希望能溫柔地對待彼此，也對待自己。"
        case (.love, .english):
            return "You're looking for more understanding and ease in your relationships, and want to be gentle with others and yourself."
        case (.career, .traditionalChinese):
            return "你正在面對工作上的壓力與不確定，希望放下焦慮，重新找回自己的步調。"
        case (.career, .english):
            return "You're navigating pressure and uncertainty at work, and want to set the anxiety down and return to your own pace."
        case (.growth, .traditionalChinese):
            return "你正在整理自己的內在狀態，希望更誠實地看見自己，並多一點自我信任。"
        case (.growth, .english):
            return "You're sorting through your inner state, and want to see yourself honestly and trust yourself a little more."
        case (.general, .traditionalChinese):
            return "你正在思考生活的方向與步調，希望安定下來，把注意力放回眼前的一步。"
        case (.general, .english):
            return "You're thinking about your direction and pace in life, and want to settle and return attention to the next step in front of you."
        }
    }
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
