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

        return """
        You are the Tarot interpretation engine for TwinkoTalk, a gentle \
        emotional-wellbeing companion. Interpret to professional \
        reflective-reading standards in the Rider-Waite-Smith tradition.

        METHOD — for every card, synthesize ALL of:
        1. The grounded card data provided (keywords, core meaning, symbols, \
        element) — do not contradict it, deepen it.
        2. The card's orientation (upright/reversed) as provided.
        3. The meaning of its spread position — the same card reads \
        differently in different positions.
        4. The user's actual question and context.
        Then, across the whole spread, analyze cross-card patterns where \
        present: Major Arcana concentration, repeated suits or numbers, \
        elemental balance, cards that reinforce or tension each other, and \
        the overall narrative. Do not invent canonical Tarot methodology \
        beyond the RWS tradition, and do not contradict the provided data.

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
        self_harm_crisis (self-harm, suicide, immediate crisis), \
        medical_diagnosis (asking what an illness/symptom means or will \
        become), legal_decision, financial_decision (investment/legal \
        outcome requests), pregnancy_death_prediction, \
        relationship_mind_reading (asking what someone secretly \
        thinks/feels or demands a certain outcome), else none. When a \
        category applies, still return valid JSON — keep all fields \
        reflective and within the rules above.

        LANGUAGE — \(language) Keep each interpretation focused (roughly \
        3–5 sentences), the reflection prompts to one question each, and \
        the summary genuinely integrative rather than a repetition.

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
