import Foundation

// MARK: - Provider boundary

/// One card's interpretation block for the result screen: a short
/// always-visible core (2–3 sentences) and a longer detail revealed
/// behind "Show full interpretation".
struct TarotCardInterpretation: Equatable {
    let keywords: [String]
    let core: String
    let detail: String
    let reflectionPrompt: String
}

/// Clean boundary for the interpretation layer. The prototype ships a
/// local mock; production replaces this with an LLM-backed provider
/// that synthesizes from the full session context (user question,
/// topic, spread, positions, orientations, all cards, locale) instead
/// of reciting fixed card meanings. UI code only ever talks to this
/// protocol.
protocol TarotInterpretationProviding {
    func interpretation(for card: TarotDrawnCard,
                        in session: TarotReadingSession,
                        lang: AppLanguage) -> TarotCardInterpretation
    /// Cross-card synthesis for a completed three-card reading.
    func synthesis(for session: TarotReadingSession, lang: AppLanguage) -> String
    /// Final combined summary: single-card closing, or the 3(+1)
    /// overall message when a guidance card is present.
    func combinedSummary(for session: TarotReadingSession, lang: AppLanguage) -> String
    /// Twinko's short emotional closing with one practical or
    /// reflective next step — always distinct from the synthesis and
    /// combined summary (never the same string).
    func twinkoMessage(for session: TarotReadingSession, lang: AppLanguage) -> String
    func closingLine(lang: AppLanguage) -> String
}

// MARK: - Mock provider

/// Prototype mock: composes reflective, non-deterministic copy from
/// structured components (suit/arcana theme × orientation × position ×
/// topic), varied stably per card. No fixed one-answer-per-card table,
/// and nothing here is wired into UI directly — swap this type for the
/// future LLM provider without touching views.
struct MockTarotInterpretationProvider: TarotInterpretationProviding {

    // Stable per-card variant index (djb2 — String.hashValue is
    // process-seeded) so a card reads consistently without one
    // hardcoded answer per card.
    private func variant(_ card: TarotCardInfo, _ count: Int) -> Int {
        var hash: UInt64 = 5381
        for byte in card.id.utf8 { hash = (hash &* 33) ^ UInt64(byte) }
        return Int(hash % UInt64(max(count, 1)))
    }

    private func family(_ card: TarotCardInfo) -> String {
        card.arcanaType == "major" ? "major" : card.suit
    }

    // MARK: Theme fragments

    private func theme(_ card: TarotCardInfo, _ lang: AppLanguage) -> String {
        let zh: [String: [String]] = [
            "major": ["一段重要的內在旅程正在展開", "生命裡有個較大的主題正在轉動", "這是一個值得慢下來看的時刻"],
            "cups": ["感受與關係正在向你說話", "心裡的水流最近有些新的方向", "情感層面有值得溫柔對待的訊息"],
            "wands": ["行動力和熱情正在聚集", "有一股想開始什麼的能量", "創造與嘗試的火苗正在閃爍"],
            "swords": ["思緒與溝通是此刻的重點", "腦海裡的聲音需要被整理", "看清楚事情的樣子比急著行動更重要"],
            "pentacles": ["實際的步伐與累積正在成形", "日常的穩定值得被照顧", "身邊具體的事物有話想說"],
        ]
        let en: [String: [String]] = [
            "major": ["an important inner journey is unfolding", "a larger life theme is quietly turning", "this is a moment worth slowing down for"],
            "cups": ["feelings and connection are speaking to you", "the waters of the heart are finding a new direction", "there is an emotional message worth holding gently"],
            "wands": ["energy and enthusiasm are gathering", "something in you wants to begin", "a creative spark is flickering"],
            "swords": ["thoughts and communication take center stage", "the voices in your head could use some sorting", "seeing clearly matters more than rushing"],
            "pentacles": ["practical steps and steady effort are taking shape", "everyday stability deserves care", "the tangible things around you have something to say"],
        ]
        let table = lang == .english ? en : zh
        let options = table[family(card)] ?? table["major"]!
        return options[variant(card, options.count)]
    }

    private func orientationNuance(_ drawn: TarotDrawnCard, _ lang: AppLanguage) -> String {
        switch (drawn.orientation, lang) {
        case (.upright, .traditionalChinese):
            return "正位的「\(drawn.card.displayNameZh)」讓這股能量以比較順、比較外放的方式出現。"
        case (.reversed, .traditionalChinese):
            return "逆位的「\(drawn.card.displayNameZh)」提醒你，這股能量可能被擋住、轉向內在，或需要換個角度看。"
        case (.upright, .english):
            return "Upright, \(drawn.card.displayNameEn) lets this energy flow openly and outward."
        case (.reversed, .english):
            return "Reversed, \(drawn.card.displayNameEn) suggests this energy may be blocked, turned inward, or asking for a different angle."
        }
    }

    private func positionFrame(_ position: TarotPositionType?, _ lang: AppLanguage) -> String? {
        guard let position else { return nil }
        switch (position, lang) {
        case (.past, .traditionalChinese): return "在「過去」的位置，它說的是把你帶到此刻的那段路。"
        case (.present, .traditionalChinese): return "在「現在」的位置，它照著你此刻正身處的狀態。"
        case (.future, .traditionalChinese): return "在「未來」的位置，它指向一個可能的方向，而不是注定的結局。"
        case (.guidance, .traditionalChinese): return "作為「指引牌」，它想給整個牌陣一個溫柔的行動方向。"
        case (.past, .english): return "In the Past position, it speaks to the road that brought you here."
        case (.present, .english): return "In the Present position, it mirrors where you stand right now."
        case (.future, .english): return "In the Future position, it points to a possible direction — not a fixed ending."
        case (.guidance, .english): return "As the Guidance card, it offers the whole spread a gentle direction to act on."
        }
    }

    private func topicAngle(_ topic: TarotTopicType, _ lang: AppLanguage) -> String {
        switch (topic, lang) {
        case (.relationships, .traditionalChinese): return "放在感情與關係裡看，它可能在邀請你多聽聽彼此真正的需要。"
        case (.career, .traditionalChinese): return "放在工作與事業裡看，它可能在提醒你留意方向，而不只是速度。"
        case (.finance, .traditionalChinese): return "放在金錢與財務裡看，它可能在邀請你先看清自己的安心界線，再做決定。"
        case (.growth, .traditionalChinese): return "放在自我成長裡看，它可能在指向一個值得被你看見的內在角落。"
        case (.lifePath, .traditionalChinese): return "放在生活的整體裡看，它可能在邀請你重新安排自己的步調。"
        case (.other, .traditionalChinese): return "放在你心裡掛著的那件事上看，它可能在幫你把感覺說得更清楚一點。"
        case (.relationships, .english): return "Seen through your relationships, it may be inviting you to listen for what each of you truly needs."
        case (.career, .english): return "Seen through your career, it may be a reminder to watch your direction, not just your speed."
        case (.finance, .english): return "Seen through money matters, it may be inviting you to notice where you feel steady before deciding."
        case (.growth, .english): return "Seen through personal growth, it may be pointing to a part of you that deserves to be seen."
        case (.lifePath, .english): return "Seen through your life as a whole, it may be inviting you to re-set your own pace."
        case (.other, .english): return "Held next to what's on your mind, it may help you put the feeling into clearer words."
        }
    }

    private func keywords(_ drawn: TarotDrawnCard, _ lang: AppLanguage) -> [String] {
        let zh: [String: [[String]]] = [
            "major": [["轉變", "課題", "覺察"], ["旅程", "抉擇", "信任"]],
            "cups": [["感受", "連結", "溫柔"], ["直覺", "關係", "流動"]],
            "wands": [["行動", "熱情", "開始"], ["創造", "勇氣", "火花"]],
            "swords": [["思緒", "清晰", "溝通"], ["誠實", "界線", "洞察"]],
            "pentacles": [["踏實", "累積", "照顧"], ["日常", "耐心", "根基"]],
        ]
        let en: [String: [[String]]] = [
            "major": [["change", "lesson", "awareness"], ["journey", "choice", "trust"]],
            "cups": [["feeling", "connection", "tenderness"], ["intuition", "relationship", "flow"]],
            "wands": [["action", "passion", "beginnings"], ["creation", "courage", "spark"]],
            "swords": [["thought", "clarity", "communication"], ["honesty", "boundaries", "insight"]],
            "pentacles": [["groundedness", "steadiness", "care"], ["daily life", "patience", "roots"]],
        ]
        let table = lang == .english ? en : zh
        let sets = table[family(drawn.card)] ?? table["major"]!
        var words = sets[variant(drawn.card, sets.count)]
        if drawn.orientation == .reversed {
            words.append(lang == .english ? "inward turn" : "向內看")
        }
        return words
    }

    private func reflection(_ drawn: TarotDrawnCard, _ lang: AppLanguage) -> String {
        let zh = ["今天有哪一件小事，呼應了這張牌想說的話？",
                  "如果這張牌是一位朋友，你想回它什麼？",
                  "這張牌照見的部分，你想為它做一件什麼小事？"]
        let en = ["What small moment today echoes what this card is saying?",
                  "If this card were a friend, what would you say back to it?",
                  "What one small thing could you do for the part of you this card reflects?"]
        let options = lang == .english ? en : zh
        return options[variant(drawn.card, options.count)]
    }

    // MARK: Protocol

    func interpretation(for drawn: TarotDrawnCard,
                        in session: TarotReadingSession,
                        lang: AppLanguage) -> TarotCardInterpretation {
        // Core: position frame + theme, kept to 2–3 short sentences.
        var coreLines: [String] = []
        if let frame = positionFrame(drawn.position, lang) { coreLines.append(frame) }
        if lang == .english {
            coreLines.append("This card may reflect that \(theme(drawn.card, lang)).")
        } else {
            coreLines.append("這張牌或許在說，\(theme(drawn.card, lang))。")
        }
        // Detail: orientation nuance + topic angle, shown on expand.
        let detailLines = [orientationNuance(drawn, lang), topicAngle(session.topic, lang)]
        return TarotCardInterpretation(keywords: keywords(drawn, lang),
                                       core: coreLines.joined(separator: "\n"),
                                       detail: detailLines.joined(separator: "\n"),
                                       reflectionPrompt: reflection(drawn, lang))
    }

    func synthesis(for session: TarotReadingSession, lang: AppLanguage) -> String {
        guard session.cards.count == 3 else { return "" }
        let names = session.cards.map { $0.card.displayName(for: lang) }
        if lang == .english {
            return "Reading the three together: \(names[0]) tells the story that brought you here, \(names[1]) mirrors where you stand today, and \(names[2]) sketches one possible way forward. They are not verdicts — they are three angles to think with, and how you walk from here is always yours to choose."
        }
        return "把三張牌放在一起看：「\(names[0])」說的是把你帶到這裡的故事，「\(names[1])」照著你今天站的位置，「\(names[2])」則描了一個可能的走向。它們不是定論，而是三個幫你想事情的角度——接下來怎麼走，永遠由你自己決定。"
    }

    func combinedSummary(for session: TarotReadingSession, lang: AppLanguage) -> String {
        if session.spread == .single, let only = session.cards.first {
            let name = only.card.displayName(for: lang)
            let state = only.orientation.label(lang)
            if lang == .english {
                return "Today, \(name) (\(state)) keeps you company. Take its message as one gentle angle on your question — notice what it stirs, keep what helps, and let the rest go."
            }
            return "今天陪著你的是\(state)的「\(name)」。把它的訊息當成看待問題的一個溫柔角度——留意它勾起了什麼，把有幫助的留下，其餘的放下就好。"
        }
        guard let guidance = session.guidanceCard else {
            return synthesis(for: session, lang: lang)
        }
        let gName = guidance.card.displayName(for: lang)
        let gState = guidance.orientation.label(lang)
        if lang == .english {
            return "Bringing all four together: the Past–Present–Future story above sets the scene, and \(gName) (\(gState)) arrives as your guidance — a direction to act on, gently. Let it suggest one small next step rather than a final answer."
        }
        return "把四張牌合起來看：前面「過去—現在—未來」鋪出了整個故事，而\(gState)的「\(gName)」作為指引牌輕輕落下——它給的是一個可以行動的方向，不是最終答案。讓它幫你想出一小步，就很足夠了。"
    }

    func twinkoMessage(for session: TarotReadingSession, lang: AppLanguage) -> String {
        // Short, warm, one practical step — deliberately generated
        // from separate pools so it can never duplicate the synthesis
        // or combined summary (spec §10).
        let zh = [
            "不用急著把每個方向都想清楚，今天先為自己做一件小小的事就好。",
            "把牌給你的感覺記在心裡，然後泡杯溫的東西，慢慢來。",
            "留意今天心裡最常出現的那個念頭，睡前輕輕回看一眼就好。",
            "選一個此刻做得到的小步驟，其他的，先交給時間。",
        ]
        let en = [
            "You don't need every direction figured out today — just do one small kind thing for yourself.",
            "Keep the feeling this reading gave you, make something warm to drink, and take it slow.",
            "Notice the thought that visits you most today, and gently revisit it before sleep.",
            "Pick one small step you can take right now, and let time hold the rest.",
        ]
        let pool = lang == .english ? en : zh
        let seed = session.allCards.map(\.card.id).joined(separator: "|") + "|twinko-message"
        return pool[Int(stableHash(seed) % UInt64(pool.count))]
    }

    func closingLine(lang: AppLanguage) -> String {
        lang == .english
            ? "Whatever the cards say, Twinko is here with you."
            : "不管牌怎麼說，Twinko 都在這裡陪你。"
    }
}

// MARK: - Shared copy

enum TarotDisclaimer {
    /// Shown once, at the absolute bottom of the result page — never
    /// inside the Guidance Summary Card (redesign 2026-07-16).
    static func text(_ lang: AppLanguage) -> String {
        lang == .english
            ? "For reflection and entertainment only"
            : "內容僅供反思與娛樂"
    }
}
