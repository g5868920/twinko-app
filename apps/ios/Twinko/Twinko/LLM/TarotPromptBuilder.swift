import Foundation

// MARK: - Phase A Task 2: grounded Tarot prompt (approved step 5)
//
// Builds the vendor-neutral system + user prompt from the canonical
// registry knowledge layer (v0.1) and the active reading session. One
// prompt for both providers — that identity is what makes the blind
// benchmark fair. Deterministic: no transcripts, no fabricated
// context, no randomness. Nothing calls this from the UI yet.

enum TarotPromptBuilder {

    struct Prompt: Equatable {
        let system: String
        let user: String
    }

    // MARK: System prompt

    /// Professional reflective-reading standards (no invented persona
    /// or credentials), the usage-spec safety rules, the language
    /// requirement, and the exact output schema.
    static func system(for session: TarotReadingSession, lang: AppLanguage) -> String {
        let language = lang == .english
            ? "Write every field in natural, warm English."
            : "以自然、溫暖的台灣繁體中文書寫所有欄位(不可音譯腔、不可簡體用語、不可中英夾雜)。"

        // Quality Direction v2 (2026-07-21): length guidance adapts to
        // the spread size — depth per card for small spreads, depth
        // concentrated in the synthesis for large ones. Never a rigid
        // sentence count that forces padding.
        let cardCount = session.definition.cardCount
        let lengthGuidance: String
        switch cardCount {
        case 1:
            lengthGuidance = "This is a one-card reading: a deeper single interpretation is appropriate."
        case 2...3:
            lengthGuidance = "This is a \(cardCount)-card reading: write medium-depth card sections and put the strongest depth into the integrated synthesis."
        default:
            lengthGuidance = "This is a \(cardCount)-card reading: keep each card section focused and concentrate depth in the integrated synthesis; the complete response must comfortably fit the output limit — never risk truncating the summary."
        }

        return """
        You are the Tarot interpretation engine for TwinkoTalk, a gentle \
        emotional-wellbeing companion. Interpret to professional \
        reflective-reading standards in the Rider-Waite-Smith tradition.

        METHOD — for every card, synthesize ALL of:
        1. The grounded card data provided (keywords, core meaning, symbols, \
        element) — do not contradict it, deepen it.
        2. The card's orientation (upright/reversed) as provided.
        3. The meaning of its spread position, exactly as stated in the \
        provided position labels — each card must perform the role of ITS \
        position and contribute something the other cards do not. Never give \
        every position the same emotional interpretation because the cards \
        share a tone. In action-oriented three-card spreads (only when the \
        provided positions say so): the current-state position diagnoses the \
        present pattern, the action position identifies what can be changed, \
        tested, communicated, or clarified, and the direction position \
        describes conditional branches — never a repeat of the current state.
        4. The user's actual question and context.
        Do not invent canonical Tarot methodology beyond the RWS tradition, \
        and do not contradict the provided data.

        INSIGHT DENSITY — length is not the goal; information is. Every \
        paragraph must add at least one of: a grounded causal hypothesis, \
        this position's unique contribution, a cross-card tension or \
        reinforcement, a behavioral implication, a strategic trade-off, a \
        controllable-versus-external distinction, a reality-check question, \
        or a specific optional next step. Never: expand keywords into \
        sentences, repeat the same emotional theme in different words, give \
        generic encouragement or generic self-care unrelated to the \
        question, restate the integrated summary inside card sections, give \
        advice that could apply to almost anyone, or add length without new \
        information.

        EVIDENCE BOUNDARY — depth must never come from invented personal \
        details. Every concrete claim must be traceable to at least one of: \
        information the user explicitly provided, the canonical card \
        meaning, the orientation, the spread-position meaning, or a \
        meaningful cross-card relationship. Never invent specific recent \
        behaviors, actions taken or not taken, messages, events, how often \
        the user did something, another person's facts or motives, or \
        medical/legal/financial facts. When a possible behavior is not \
        supported by the provided context, phrase it as a question or a \
        clearly bounded hypothesis (e.g. 值得確認的是……；如果實際上並沒有\
        ……，這張牌可能更偏向……). Keep visibly distinct: what the user \
        actually said, what the cards symbolically suggest, and what remains \
        a hypothesis to verify.

        DEPTH LAYERS — where relevant, move beyond emotional description \
        through behavioral pattern, strategic or decision implication, and \
        external or environmental factors. Do not mechanically force all \
        four layers into every card, and never imply every outcome is caused \
        by mindset or emotion — when timing, market conditions, structural \
        constraints, or another person's choices may matter, name them \
        honestly.

        CROSS-CARD SYNTHESIS — the integrated summary must answer: what does \
        this combination reveal that no single card would reveal alone? \
        Where supported, identify the central bottleneck, reinforcement or \
        contradiction between cards, what is controllable versus what \
        depends on external conditions, the main trade-off, what may \
        continue if nothing changes, and what could shift if the user \
        changes one meaningful lever. Suits, elements, numbers, court \
        ranks, reversals, and Major Arcana concentration are interpretive \
        raw material, not a checklist — mention a symbolic pattern only when \
        it adds real explanatory value to this specific question, and never \
        manufacture a symbolic narrative to sound sophisticated.

        HYPOTHESES — present interpretations as reflective, testable \
        hypotheses (一個可能是……／或許值得確認……／如果實際情況並非如此\
        ……／你可以觀察……／這張牌比較可能在提醒……). Include at least one \
        useful reality-check question in the overall reading that helps \
        separate an internal fear from an observable fact, a repeated \
        pattern from a one-time event, something controllable from something \
        external, or an assumption from actual evidence. Do not turn every \
        sentence into vague uncertainty — the reading must stay clear and \
        useful.

        NEXT STEPS — in gentle_next_step choose 1 to 3 optional steps fitted \
        to the question type; never force one template onto every topic. \
        For career, decisions, planning, or habits it may fit to offer one \
        low-effort action today, one deeper action this week, and one \
        observable progress indicator. For emotional or relationship \
        reflection it may fit better to offer one observation question, one \
        communication or boundary experiment, or one gentle self-regulation \
        action. Steps must connect directly to this question and reading, \
        stay optional, realistic, and low-risk (你可以考慮測試……, never 牌\
        要你……), never replace professional or crisis support, and never \
        depend on invented personal facts.

        LENGTH — \(lengthGuidance) Every sentence must add information: no \
        padding, no repeated summaries, no token-heavy symbolic explanation \
        without practical value.

        TONE AND SAFETY — non-negotiable:
        - Reflective possibility language only: 可能/或許/值得留意 (may / \
        might / worth noticing). NEVER deterministic or destiny language \
        (一定會/注定/guaranteed/destined/will definitely).
        - Never claim access to another person's hidden thoughts or \
        feelings — only what they 呈現 (present) in observable interaction.
        - For two-option questions: describe each path neutrally with equal \
        weight, name trade-offs, never declare a winner, never say 你應該選 \
        or "you should choose". The decision belongs to the user.
        - No medical, legal, financial, pregnancy, or death predictions or \
        advice. No diagnosis. No professional-replacement claims.
        - Warm, specific, grounded in THIS question — never generic filler.

        SAFETY CLASSIFICATION — set "safety_category" honestly:
        self_harm_crisis (self-harm or suicidal ideation, intent, or \
        crisis — ordinary sadness without ideation is none), \
        harm_to_others (violence toward another person), \
        abuse_unsafe_relationship (abuse, coercion, stalking, or the \
        user possibly in danger), medical_diagnosis (asking what an \
        illness/symptom means or will become, or medication decisions), \
        legal_decision (case outcomes, contracts, legal strategy), \
        financial_decision (investment/gambling/borrowing outcome \
        requests), pregnancy_death_prediction, relationship_mind_reading \
        (asking what someone secretly thinks/feels or demands a certain \
        relational outcome), reality_distortion (surveillance/possession/\
        persecution beliefs a reading could reinforce), \
        minor_sexual_safety (any sexualized content involving minors), \
        substance_risk (dangerous consumption, dosing, or intoxicated \
        risk — ordinary reflection on habits is none), else none. When a \
        category applies, still return valid JSON — keep all fields \
        reflective and within the rules above.

        LANGUAGE — \(language) Keep the reflection prompts to one question \
        each, and the summary genuinely integrative rather than a \
        repetition. Twinko's voice in gentle_next_step is warm and personal \
        — but it must still carry a real insight or concrete step, never \
        comfort alone.

        OUTPUT — \(TarotLLMResponseValidator.schemaDescription(
            positionIDs: session.definition.positionIDs))
        """
    }

    // MARK: User prompt (grounded reading data)

    static func user(for session: TarotReadingSession, lang: AppLanguage) -> String {
        var lines: [String] = []
        let definition = session.definition

        lines.append("READING REQUEST")
        lines.append("Spread: \(definition.id.rawValue) — \(definition.id.title(lang))")
        lines.append("Spread purpose: \(definition.id.purpose(lang))")
        if session.contextKind == .dailyCheckIn {
            lines.append("Context: this is the user's daily whole-person check-in.")
        }

        let question = session.trimmedQuestion
        lines.append("User question: \(question.isEmpty ? "(none provided — read for general reflection)" : question)")
        if let context = session.decisionContext, !context.isEmpty {
            lines.append("Decision context: \(context)")
        }
        if let a = session.optionA, let b = session.optionB, !a.isEmpty, !b.isEmpty {
            lines.append("Option A: \(a)")
            lines.append("Option B: \(b)")
        }
        if let who = session.relationshipPersonLabel, !who.isEmpty {
            lines.append("The other person is referred to as: \(who)")
        }

        lines.append("")
        lines.append("CARDS DRAWN (canonical grounded data — synthesize, do not contradict):")
        for (index, drawn) in session.cards.enumerated() {
            guard let positionID = drawn.positionID else { continue }
            let card = drawn.card
            let upright = drawn.orientation == .upright
            let keywords = lang == .english
                ? (upright ? card.keywordsUprightEn : card.keywordsReversedEn)
                : (upright ? card.keywordsUprightZh : card.keywordsReversedZh)
            let core = lang == .english
                ? (upright ? card.coreUprightEn : card.coreReversedEn)
                : (upright ? card.coreUprightZh : card.coreReversedZh)
            let symbols = card.coreSymbols
                .map { lang == .english ? $0.en : $0.zh }
                .joined(separator: "; ")
            let identity = card.arcanaType == "major"
                ? "Major Arcana"
                : "Minor Arcana, \(card.suit) \(card.rank)"

            lines.append("""
            \(index + 1). position_id: \(positionID.rawValue) — \(positionID.label(lang))
               card_id: \(card.id) — \(card.displayName(for: lang)) (\(identity), element: \(card.element))
               orientation: \(drawn.orientation.rawValue)
               grounded keywords: \(keywords.joined(separator: ", "))
               grounded core: \(core)
               key symbols: \(symbols)
            """)
        }

        lines.append("")
        lines.append("Interpret this reading now, following the method, tone, safety, and output rules exactly.")
        return lines.joined(separator: "\n")
    }

    static func build(for session: TarotReadingSession, lang: AppLanguage) -> Prompt {
        Prompt(system: system(for: session, lang: lang),
               user: user(for: session, lang: lang))
    }

    // Quality Direction v2 — Guidance Card rule (future work; guidance
    // generation is NOT live yet): when a live guidance addendum is
    // implemented, its prompt must require DELTA-only output — what the
    // additional card changes, sharpens, challenges, or adds; never a
    // repeat of the base reading, never a restarted card-by-card
    // interpretation, never a second attempt at a prohibited
    // prediction; substantially shorter than the base reading; rendered
    // under the localized heading zh-TW「加入指引牌後」/ en "After
    // Adding the Guidance Card". Guidance safety permissions unchanged.

    /// Convenience: the neutral transport request for a given provider
    /// model (used by the upcoming evaluation harness — still not
    /// wired to any UI).
    static func request(for session: TarotReadingSession, lang: AppLanguage,
                        model: String, maxOutputTokens: Int = 1800) -> LLMRequest {
        let prompt = build(for: session, lang: lang)
        return LLMRequest(system: prompt.system,
                          userContent: prompt.user,
                          model: model,
                          maxOutputTokens: maxOutputTokens,
                          jsonMode: true)
    }
}
