import Foundation

// MARK: - Provider boundary

/// One card's interpretation block for the result screen: a short
/// always-visible core (2–3 sentences), a longer detail, and one
/// reflection sentence.
struct TarotCardInterpretation: Equatable {
    let keywords: [String]
    let core: String
    let detail: String
    let reflectionPrompt: String
}

/// Clean boundary for the interpretation layer. The prototype ships a
/// local deterministic mock; production replaces this with an
/// LLM-backed provider that synthesizes from the full session context
/// (question, structured inputs, spread, positions, orientations, all
/// cards, locale). UI code only ever talks to this protocol.
protocol TarotInterpretationProviding {
    func interpretation(for card: TarotDrawnCard,
                        in session: TarotReadingSession,
                        lang: AppLanguage) -> TarotCardInterpretation
    /// Integrated cross-card synthesis for any completed multi-card
    /// reading (spread-aware; neutral for Two-Choice, presented-state
    /// language for Relationship Insight).
    func synthesis(for session: TarotReadingSession, lang: AppLanguage) -> String
    /// Final combined summary: single-card closing, or the expanded
    /// whole-reading message once a Guidance Card is present.
    func combinedSummary(for session: TarotReadingSession, lang: AppLanguage) -> String
    /// Twinko's short emotional closing with one practical or
    /// reflective next step — always distinct from the synthesis and
    /// combined summary (never the same string).
    func twinkoMessage(for session: TarotReadingSession, lang: AppLanguage) -> String
    func closingLine(lang: AppLanguage) -> String
}

// MARK: - Mock provider

/// Prototype mock: composes reflective, non-deterministic copy from
/// structured components (suit/arcana theme × orientation ×
/// canonical position × topic flavor), varied stably per card. No
/// fixed one-answer-per-card table; deterministic and replaceable by
/// the future LLM provider without touching views.
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

    /// Position-aware frame for every canonical MVP position and the
    /// Guidance role (Task 2 §25). Relationship positions keep the
    /// canonical "presented" wording; Two-Choice positions stay
    /// neutral; nothing here is deterministic-future language.
    private func positionFrame(_ drawn: TarotDrawnCard, _ lang: AppLanguage) -> String? {
        if drawn.role == .guidance {
            return lang == .english
                ? "As the Guidance Card, it offers the whole reading one gentle direction to act on."
                : "作為「指引牌」，它想給整個牌陣一個溫柔的行動方向。"
        }
        guard let position = drawn.positionID else { return nil }
        if lang == .english {
            switch position {
            case .momentMessage: return "As the message for this moment, it speaks to what may matter most right now."
            case .past: return "In the Past position, it speaks to the road that brought you here."
            case .present: return "In the Present position, it mirrors where you stand right now."
            case .possibleDirection: return "In the Possible Direction position, it points to one way things may move — not a fixed ending."
            case .currentSituation: return "In the Current Situation position, it reflects the state of things as they are."
            case .availableAction: return "In the Available Action position, it suggests one step that may be within reach."
            case .currentUnderstanding: return "In the My Current Understanding position, it mirrors the way you currently see this."
            case .unseenPerspective: return "In the Unseen Perspective position, it offers an angle you may not have looked at — another perspective, not a hidden fact."
            case .possibleReframe: return "In the Possible Reframe position, it invites a different way of thinking this through."
            case .bodySignal: return "In the body position, it reflects what your body may be signaling today."
            case .thoughtsFeelings: return "In the thoughts-and-feelings position, it mirrors your current inner weather."
            case .innerCare: return "In the inner-care position, it points to the care that may support you most today."
            case .whatIThink: return "In the What I Think position, it reflects how you're understanding this event."
            case .whatIFeel: return "In the What I Feel position, it listens for what may sit underneath the thoughts."
            case .howIRespond: return "In the How I Am Responding position, it mirrors the way you're currently reacting."
            case .whereIAmNow: return "In the Where I Am Now position, it reflects your current footing."
            case .whereIWantToGo: return "In the Where I Want to Go position, it holds the direction you're drawn toward."
            case .howIMoveCloser: return "In the How I May Move Closer position, it sketches one possible way to approach it."
            case .coreIssue: return "In the Core Issue position, it points to what may sit at the heart of this."
            case .currentObstacle: return "In the Current Obstacle position, it reflects what may be standing in the way."
            case .possibleApproach: return "In the Possible Approach position, it suggests one way you might work with this."
            case .availableStrength: return "In the Available Strength position, it reminds you of a resource — inner or outer — you can draw on."
            case .optionAState: return "In the Option A current-state position, it reflects how this path presently feels."
            case .optionBState: return "In the Option B current-state position, it reflects how this path presently feels."
            case .optionADirection: return "In the Option A possible-direction position, it sketches where this path may lead — a possibility, not a verdict."
            case .optionBDirection: return "In the Option B possible-direction position, it sketches where this path may lead — a possibility, not a verdict."
            case .yourCurrentState: return "In the Your Current State position, it mirrors where you yourself stand between the two."
            case .myState: return "In the My Current State position, it reflects how you're arriving in this relationship right now."
            case .myFeelingsAttitude: return "In the My Feelings and Attitude position, it mirrors what you're carrying toward the other person."
            case .theirPresentedState: return "In the other person's presented-state position, it reflects what they are currently showing — not their hidden mind."
            case .theirPresentedAttitude: return "In their presented-attitude position, it reflects the stance they're presenting in the relationship, as far as it can be seen."
            case .relationshipDirection: return "In the Possible Relationship Direction position, it sketches one way the dynamic may move — never a destiny."
            }
        }
        switch position {
        case .momentMessage: return "作為「此刻的提醒」，它說的是現在最值得你留意的事。"
        case .past: return "在「過去」的位置，它說的是把你帶到此刻的那段路。"
        case .present: return "在「現在」的位置，它照著你此刻正身處的狀態。"
        case .possibleDirection: return "在「可能走向」的位置，它指向一個可能的方向，而不是注定的結局。"
        case .currentSituation: return "在「目前現況」的位置，它照著事情此刻真實的樣子。"
        case .availableAction: return "在「可以採取的行動」的位置，它提出一個此刻搆得到的步伐。"
        case .currentUnderstanding: return "在「我目前的理解」的位置，它照著你現在看待這件事的方式。"
        case .unseenPerspective: return "在「尚未看見的面向」的位置，它提供一個你可能還沒看過的角度——是另一種視角，不是被證實的真相。"
        case .possibleReframe: return "在「可以重新思考的方向」的位置，它邀請你換一種方式想想這件事。"
        case .bodySignal: return "在「身體」的位置，它反映身體今天可能想告訴你的訊息。"
        case .thoughtsFeelings: return "在「情緒與思緒」的位置，它照著你此刻的內在天氣。"
        case .innerCare: return "在「內在照顧」的位置，它指向今天最能支持你的那種照顧。"
        case .whatIThink: return "在「我怎麼理解這件事」的位置，它照著你目前理解這件事的方式。"
        case .whatIFeel: return "在「我真正感受到什麼」的位置，它傾聽想法底下真正的感受。"
        case .howIRespond: return "在「我正在如何回應」的位置，它照著你目前回應這件事的樣子。"
        case .whereIAmNow: return "在「目前所在的位置」，它反映你此刻站的地方。"
        case .whereIWantToGo: return "在「真正想前往的方向」的位置，它盛著你被吸引的那個方向。"
        case .howIMoveCloser: return "在「可以如何靠近」的位置，它描出一種可能的靠近方式。"
        case .coreIssue: return "在「問題核心」的位置，它指向可能真正位於中心的那件事。"
        case .currentObstacle: return "在「目前阻礙」的位置，它反映可能正擋在路上的東西。"
        case .possibleApproach: return "在「可行對策」的位置，它提出一種你可以嘗試的處理方式。"
        case .availableStrength: return "在「可運用的優勢」的位置，它提醒你一份可以倚靠的資源——可能在你之內，也可能在你身邊。"
        case .optionAState: return "在「選項 A 的狀態」的位置，它反映這條路目前呈現的樣子。"
        case .optionBState: return "在「選項 B 的狀態」的位置，它反映這條路目前呈現的樣子。"
        case .optionADirection: return "在「選擇 A 的可能走向」的位置，它描出這條路可能的發展——是可能性，不是定論。"
        case .optionBDirection: return "在「選擇 B 的可能走向」的位置，它描出這條路可能的發展——是可能性，不是定論。"
        case .yourCurrentState: return "在「你目前的狀態」的位置，它照著站在兩個選項之間的你自己。"
        case .myState: return "在「我的狀態」的位置，它反映你此刻走進這段關係的樣子。"
        case .myFeelingsAttitude: return "在「我對對方的感情態度」的位置，它照著你朝向對方的心意。"
        case .theirPresentedState: return "在「對方呈現的狀態」的位置，它反映的是對方目前呈現出來的樣子——不是對方心裡沒說的部分。"
        case .theirPresentedAttitude: return "在「對方在關係中呈現的態度」的位置，它反映對方目前在互動中呈現的姿態，以你所能看見的為限。"
        case .relationshipDirection: return "在「關係的可能走向」的位置，它描出互動可能移動的一種方向——從來不是注定。"
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
        if let frame = positionFrame(drawn, lang) { coreLines.append(frame) }
        if lang == .english {
            coreLines.append("This card may reflect that \(theme(drawn.card, lang)).")
        } else {
            coreLines.append("這張牌或許在說，\(theme(drawn.card, lang))。")
        }
        // Detail: orientation nuance + topic-flavor angle.
        let detailLines = [orientationNuance(drawn, lang), topicAngle(session.topic, lang)]
        return TarotCardInterpretation(keywords: keywords(drawn, lang),
                                       core: coreLines.joined(separator: "\n"),
                                       detail: detailLines.joined(separator: "\n"),
                                       reflectionPrompt: reflection(drawn, lang))
    }

    /// Integrated synthesis for any completed multi-card reading —
    /// spread-aware, position-referencing, always ending in agency.
    func synthesis(for session: TarotReadingSession, lang: AppLanguage) -> String {
        guard session.cards.count > 1 else { return "" }
        let names = session.cards.map { $0.card.displayName(for: lang) }

        switch session.spreadID {
        case .twoChoiceFive:
            // Neutral A/B comparison: no winner, no ranking, agency
            // stays with the user (Task 2 §27).
            let a = session.optionA ?? (lang == .english ? "Option A" : "選項 A")
            let b = session.optionB ?? (lang == .english ? "Option B" : "選項 B")
            if lang == .english {
                return "Reading the five together: \(names[0]) and \(names[2]) reflect how “\(a)” currently feels and where it may lead, while \(names[1]) and \(names[3]) do the same for “\(b)”. \(names[4]) mirrors where you yourself stand between them. Neither path is declared the right one — you may compare the different trade-offs each brings, notice which reflection stays with you, and the choice remains entirely yours."
            }
            return "把五張牌放在一起看：「\(names[0])」與「\(names[2])」反映「\(a)」目前的狀態與可能走向，「\(names[1])」與「\(names[3])」則映照「\(b)」這條路；「\(names[4])」照著站在兩者之間的你自己。牌沒有宣告哪一條才是對的——你可以比較兩個選項帶來的不同感受，留意哪個畫面在心裡停得比較久，決定永遠在你手上。"
        case .relationshipFive:
            // Presented-state relationship reflection (Task 2 §28).
            let who = session.relationshipPersonLabel
            if lang == .english {
                let other = who.map { "“\($0)”" } ?? "the other person"
                return "Reading the five together: \(names[0]) and \(names[1]) reflect how you're arriving and what you carry toward \(other); \(names[2]) and \(names[3]) reflect the state and attitude \(other) is currently presenting — as far as it can be seen, not their hidden mind. \(names[4]) sketches one possible direction for the dynamic. Based on the interaction you currently see, this may offer perspectives for reflection, not conclusions about anyone's private feelings."
            }
            let other = who.map { "「\($0)」" } ?? "對方"
            return "把五張牌放在一起看：「\(names[0])」與「\(names[1])」反映你走進這段關係的狀態與你朝向\(other)的心意；「\(names[2])」與「\(names[3])」反映的是\(other)目前呈現的狀態與態度——以你能看見的互動為限，不是對方心裡沒說的部分。「\(names[4])」描出這段互動可能的走向。從你目前看見的互動來說，這些是可以反思的角度，而不是對任何人內心的斷言。"
        case .coreClarityFour:
            if lang == .english {
                return "Reading the four together: \(names[0]) points to what may sit at the core, \(names[1]) reflects what may be blocking the way, \(names[2]) suggests one possible approach, and \(names[3]) reminds you of a strength or resource you can draw on. They are four angles to think with — how you use them is yours to decide."
            }
            return "把四張牌放在一起看：「\(names[0])」指向可能的核心，「\(names[1])」反映可能的阻礙，「\(names[2])」提出一種可行的方式，「\(names[3])」則提醒你一份可以倚靠的優勢或資源。它們是四個幫你想事情的角度——怎麼運用，由你自己決定。"
        default:
            // Generic three-card weave: position label → card name, in
            // canonical order, closing with agency.
            let pairs = session.cards.map { drawn -> String in
                let position = drawn.positionID?.label(lang) ?? ""
                let name = drawn.card.displayName(for: lang)
                return lang == .english ? "\(name) speaks to “\(position)”"
                                        : "「\(name)」說的是「\(position)」"
            }
            if lang == .english {
                return "Reading the cards together: \(pairs.joined(separator: ", ")). They are not verdicts — they are angles to think with, and how you walk from here is always yours to choose."
            }
            return "把牌放在一起看：\(pairs.joined(separator: "；"))。它們不是定論，而是幫你想事情的角度——接下來怎麼走，永遠由你自己決定。"
        }
    }

    /// The "reading it together" text for the CURRENT reading state.
    /// Adding a Guidance Card expands this summary (and only this
    /// summary) — the already-drawn cards' interpretations are never
    /// regenerated.
    func combinedSummary(for session: TarotReadingSession, lang: AppLanguage) -> String {
        if session.cards.count == 1, let only = session.cards.first {
            let name = only.card.displayName(for: lang)
            let state = only.orientation.label(lang)
            if let guidance = session.guidanceCard {
                let gName = guidance.card.displayName(for: lang)
                let gState = guidance.orientation.label(lang)
                if lang == .english {
                    return "Reading the two together: \(name) (\(state)) mirrors where you stand, and \(gName) (\(gState)) arrives as your guidance — one gentle direction to act on. Let them suggest a small next step, not a final answer."
                }
                return "把兩張牌放在一起看：\(state)的「\(name)」照著你此刻站的位置，而\(gState)的「\(gName)」作為指引牌輕輕落下——它給的是一個溫柔可行的方向。讓它們幫你想出一小步，就很足夠了。"
            }
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
        let spreadTitle = session.spreadID.title(lang)
        if lang == .english {
            return "Bringing the whole reading together: the “\(spreadTitle)” cards above set the scene, and \(gName) (\(gState)) arrives as your guidance — a direction to act on, gently. Let it suggest one small next step rather than a final answer."
        }
        return "把整個解讀合起來看：前面「\(spreadTitle)」的牌鋪出了整個故事，而\(gState)的「\(gName)」作為指引牌輕輕落下——它給的是一個可以行動的方向，不是最終答案。讓它幫你想出一小步，就很足夠了。"
    }

    func twinkoMessage(for session: TarotReadingSession, lang: AppLanguage) -> String {
        // Short, warm, one practical step — deliberately generated
        // from separate pools so it can never duplicate the synthesis
        // or combined summary.
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
