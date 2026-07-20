import Foundation

// MARK: - Phase A Task 2: provider-neutral structured Tarot response
//
// One schema for every provider (approved step 3). The model returns
// JSON matching `TarotLLMResponse`; the app validates it with
// `TarotLLMResponseValidator` BEFORE anything is rendered — free-form
// text is never the production contract. Nothing here is wired into
// the reading flow yet (that is step 10, after the benchmark and the
// founder's provider decision).

/// Structured safety classification the model must return (approved
/// step 4 categories). `none` means no category was triggered.
enum TarotLLMSafetyCategory: String, Codable, CaseIterable {
    case none
    case selfHarmCrisis = "self_harm_crisis"
    case harmToOthers = "harm_to_others"
    case abuseUnsafeRelationship = "abuse_unsafe_relationship"
    case medicalDiagnosis = "medical_diagnosis"
    case legalDecision = "legal_decision"
    case financialDecision = "financial_decision"
    case pregnancyDeathPrediction = "pregnancy_death_prediction"
    case relationshipMindReading = "relationship_mind_reading"
    case realityDistortion = "reality_distortion"
    case minorSexualSafety = "minor_sexual_safety"
    case substanceRisk = "substance_risk"
}

/// The provider-neutral structured response. Field names are the wire
/// contract (snake_case) shared by both vendors.
struct TarotLLMResponse: Codable, Equatable {
    struct PositionReading: Codable, Equatable {
        /// Canonical `TarotPositionID` raw value — never a translated
        /// label.
        let positionId: String
        /// Canonical card ID from the registry.
        let cardId: String
        let interpretation: String
        let reflectionPrompt: String

        enum CodingKeys: String, CodingKey {
            case positionId = "position_id"
            case cardId = "card_id"
            case interpretation
            case reflectionPrompt = "reflection_prompt"
        }
    }

    let positions: [PositionReading]
    /// Cross-card observations (majors concentration, repeated suits/
    /// numbers, elemental balance, reinforcement/tension, narrative).
    let crossCardPatterns: String
    let integratedSummary: String
    let gentleNextStep: String
    let safetyCategory: TarotLLMSafetyCategory

    enum CodingKeys: String, CodingKey {
        case positions
        case crossCardPatterns = "cross_card_patterns"
        case integratedSummary = "integrated_summary"
        case gentleNextStep = "gentle_next_step"
        case safetyCategory = "safety_category"
    }

    /// Decodes a raw model reply, tolerating a fenced ```json block.
    static func decode(fromModelText text: String) -> TarotLLMResponse? {
        var body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if body.hasPrefix("```") {
            body = body
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let data = body.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(TarotLLMResponse.self, from: data)
    }
}

// MARK: - Validation (the app-side gate before rendering)

enum TarotLLMValidationIssue: Equatable {
    case positionCountMismatch(expected: Int, got: Int)
    case unknownPosition(String)
    case positionOrderMismatch
    case cardMismatch(positionId: String)
    case emptyField(String)
    case bannedLanguage(field: String, phrase: String)
    case missingSafetyCategory
}

enum TarotLLMResponseValidator {
    /// Deterministic prohibited-language lint (zh + en). Reflective
    /// products never speak in certainties — matches the usage-spec
    /// safety rules; case-insensitive for English.
    static let bannedPhrases: [String] = [
        // zh — deterministic/destiny/mind-reading/winner language
        "一定會", "絕對會", "注定", "命中注定", "必然會",
        "你應該選", "他其實", "她其實", "對方其實", "他心裡其實", "祂的旨意",
        "保證", "百分之百",
        // en
        "will definitely", "definitely will", "guaranteed", "destined",
        "you should choose", "the right choice is", "they secretly",
        "their true hidden", "100% certain",
    ]

    static func lint(_ text: String) -> String? {
        let lowered = text.lowercased()
        return bannedPhrases.first { lowered.contains($0.lowercased()) }
    }

    /// Validates a decoded response against the session it was
    /// generated for. Empty result = safe to render.
    static func validate(_ response: TarotLLMResponse,
                         for session: TarotReadingSession) -> [TarotLLMValidationIssue] {
        var issues: [TarotLLMValidationIssue] = []
        let expected = session.definition.positionIDs

        if response.positions.count != expected.count {
            issues.append(.positionCountMismatch(expected: expected.count,
                                                 got: response.positions.count))
        }

        let expectedRaw = expected.map(\.rawValue)
        let gotRaw = response.positions.map(\.positionId)
        for raw in gotRaw where TarotPositionID(rawValue: raw) == nil {
            issues.append(.unknownPosition(raw))
        }
        if gotRaw.count == expectedRaw.count, gotRaw != expectedRaw,
           Set(gotRaw) == Set(expectedRaw) {
            issues.append(.positionOrderMismatch)
        }

        // Each position's card must be the card actually drawn there.
        let drawnByPosition = Dictionary(uniqueKeysWithValues:
            session.cards.compactMap { card in
                card.positionID.map { ($0.rawValue, card.card.id) }
            })
        for reading in response.positions {
            if let drawn = drawnByPosition[reading.positionId], drawn != reading.cardId {
                issues.append(.cardMismatch(positionId: reading.positionId))
            }
        }

        // Non-empty content everywhere.
        for reading in response.positions {
            if reading.interpretation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(.emptyField("interpretation(\(reading.positionId))"))
            }
            if reading.reflectionPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(.emptyField("reflection_prompt(\(reading.positionId))"))
            }
        }
        for (name, value) in [("cross_card_patterns", response.crossCardPatterns),
                              ("integrated_summary", response.integratedSummary),
                              ("gentle_next_step", response.gentleNextStep)]
        where value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.emptyField(name))
        }

        // Prohibited-language lint over every text field.
        var fields: [(String, String)] = [
            ("cross_card_patterns", response.crossCardPatterns),
            ("integrated_summary", response.integratedSummary),
            ("gentle_next_step", response.gentleNextStep),
        ]
        fields += response.positions.flatMap {
            [("interpretation(\($0.positionId))", $0.interpretation),
             ("reflection_prompt(\($0.positionId))", $0.reflectionPrompt)]
        }
        for (name, value) in fields {
            if let phrase = lint(value) {
                issues.append(.bannedLanguage(field: name, phrase: phrase))
            }
        }

        return issues
    }

    /// Compact schema description embedded in the prompt so both
    /// vendors produce the same wire shape (provider-native schema
    /// enforcement can be layered on top later without changing this
    /// contract).
    static func schemaDescription(positionIDs: [TarotPositionID]) -> String {
        let ids = positionIDs.map { "\"\($0.rawValue)\"" }.joined(separator: ", ")
        let categories = TarotLLMSafetyCategory.allCases.map { "\"\($0.rawValue)\"" }
            .joined(separator: ", ")
        return """
        Return ONLY a single JSON object, no markdown fences, no prose \
        outside the JSON, with exactly this shape:
        {
          "positions": [
            {"position_id": one of [\(ids)] in this exact order,
             "card_id": the card id given for that position,
             "interpretation": string,
             "reflection_prompt": string}
          ],
          "cross_card_patterns": string,
          "integrated_summary": string,
          "gentle_next_step": string,
          "safety_category": one of [\(categories)]
        }
        """
    }
}
