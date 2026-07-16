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
        l == .english
            ? "Let the cards answer your heart in the starlight…"
            : "讓牌在星光中回應你的心意……"
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
        l == .english ? "Tap a card to reveal it" : "輕點牌面，把牌翻開"
    }
    static func tapNextCard(_ l: AppLanguage) -> String {
        l == .english ? "Reveal the next card" : "繼續翻開下一張牌"
    }
    static func seeReading(_ l: AppLanguage) -> String {
        l == .english ? "See what the cards say" : "看看牌想說什麼"
    }
    static func viewFullReading(_ l: AppLanguage) -> String {
        l == .english ? "View Full Reading" : "查看完整解讀"
    }
    static func revealCompleted(_ l: AppLanguage) -> String {
        l == .english ? "These are the cards you drew" : "這就是你本次抽到的牌"
    }
    static func cardsEmerged(_ l: AppLanguage) -> String {
        l == .english ? "Your cards have emerged in the starlight" : "你的牌已在星光中浮現"
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
    static func saveCard(_ l: AppLanguage) -> String {
        l == .english ? "Save Guidance Card" : "儲存指引小卡"
    }
    static func startNewReading(_ l: AppLanguage) -> String {
        l == .english ? "Start a New Reading" : "開始新的占卜"
    }
    static func backHome(_ l: AppLanguage) -> String { l == .english ? "Back to Home" : "回到首頁" }

    // Flow exit (top-right X, 2026-07-17)
    static func exitConfirmTitle(_ l: AppLanguage) -> String {
        l == .english ? "Leave this reading for now?" : "要先離開這次占卜嗎？"
    }
    static func exitConfirmBody(_ l: AppLanguage) -> String {
        l == .english
            ? "This reading will end for now — you can start again anytime."
            : "這次的占卜流程會先結束，你之後可以再重新開始。"
    }
    static func exitConfirmStay(_ l: AppLanguage) -> String {
        l == .english ? "Continue reading" : "繼續占卜"
    }
    static func exitConfirmLeave(_ l: AppLanguage) -> String {
        l == .english ? "Leave reading" : "離開占卜"
    }
    // Personalized Meditation section (one merged cross-feature card)
    static func meditationSectionTitle(_ l: AppLanguage) -> String {
        l == .english ? "Turn this guidance into a meditation" : "把這份指引化成一段冥想"
    }
    static func meditationSectionBody(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko will use your question and the reading's overall message to prepare a personalized meditation."
            : "Twinko 會根據你的問題與牌卡整體訊息，為你準備一段專屬冥想。"
    }
    static func meditationSectionCTA(_ l: AppLanguage) -> String {
        l == .english ? "Create My Meditation" : "生成專屬冥想"
    }

    // Summary card (V2)
    static func summaryCardTitle(_ l: AppLanguage) -> String {
        l == .english ? "Tarot Guidance" : "塔羅指引"
    }
    static func overallMessage(_ l: AppLanguage) -> String {
        l == .english ? "Overall Message" : "整體訊息"
    }
    static func mainMessageLabel(_ l: AppLanguage) -> String {
        l == .english ? "Main Message" : "主訊息"
    }
    static func saveToPhotos(_ l: AppLanguage) -> String {
        l == .english ? "Save to Photos" : "儲存到照片"
    }
    static func shareImage(_ l: AppLanguage) -> String {
        l == .english ? "Share" : "分享"
    }
    static func close(_ l: AppLanguage) -> String { l == .english ? "Close" : "關閉" }
    static func savedToast(_ l: AppLanguage) -> String {
        l == .english ? "Saved to Photos" : "已儲存到照片"
    }
    static func saveDenied(_ l: AppLanguage) -> String {
        l == .english
            ? "Twinko needs permission to add photos. You can allow it in Settings."
            : "Twinko 需要新增照片的權限，可以到「設定」裡開啟。"
    }
    static func renderFailed(_ l: AppLanguage) -> String {
        l == .english
            ? "The card couldn't be prepared this time — try again?"
            : "小卡這次沒有準備好，再試一次好嗎？"
    }
    static func retry(_ l: AppLanguage) -> String { l == .english ? "Retry" : "再試一次" }
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
        case .relationships: return .selfLove
        case .career: return .releaseAnxiety
        case .finance: return .releaseAnxiety
        case .growth: return .selfLove
        case .lifePath: return .calmDown
        case .other: return .calmDown
        }
    }

    /// Concise adapted focus (2 short lines): emotional tension +
    /// desired state, in possibility language — no card names, no raw
    /// interpretation text, no predictions, no ellipsis.
    static func focusSummary(for topic: TarotTopicType, lang: AppLanguage) -> String {
        switch (topic, lang) {
        case (.relationships, .traditionalChinese):
            return "你正在關係裡尋找更多理解與安心，希望能溫柔地對待彼此，也對待自己。"
        case (.relationships, .english):
            return "You're looking for more understanding and ease in your relationships, and want to be gentle with others and yourself."
        case (.career, .traditionalChinese):
            return "你正在面對工作上的壓力與不確定，希望放下焦慮，重新找回自己的步調。"
        case (.career, .english):
            return "You're navigating pressure and uncertainty at work, and want to set the anxiety down and return to your own pace."
        case (.finance, .traditionalChinese):
            return "你正在為金錢的安排感到有些緊繃，希望可以安定下來，做出讓自己安心的決定。"
        case (.finance, .english):
            return "You're feeling some tension around money decisions, and want to settle and choose in a way that feels steady."
        case (.growth, .traditionalChinese):
            return "你正在整理自己的內在狀態，希望更誠實地看見自己，並多一點自我信任。"
        case (.growth, .english):
            return "You're sorting through your inner state, and want to see yourself honestly and trust yourself a little more."
        case (.lifePath, .traditionalChinese):
            return "你正在思考生活的方向與步調，希望安定下來，把注意力放回眼前的一步。"
        case (.lifePath, .english):
            return "You're thinking about your direction and pace in life, and want to settle and return attention to the next step in front of you."
        case (.other, .traditionalChinese):
            return "你心裡掛著一件還說不太清楚的事，希望先安定下來，聽聽自己真正的聲音。"
        case (.other, .english):
            return "Something hard to name is on your mind, and you want to settle first and hear your own voice."
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
