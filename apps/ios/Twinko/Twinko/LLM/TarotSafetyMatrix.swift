import Foundation

// MARK: - Phase A Task 2: Tarot safety action matrix (DRAFT v0.1)
//
// ⚠️ DRAFT — REQUIRES FOUNDER SIGN-OFF. Safety policy is a reserved
// decision: this matrix must be explicitly approved before live Tarot
// generation is connected to the normal user flow (approved step 4 →
// gate before step 10). The matrix is data, not scattered ifs, so the
// approved version replaces one table.
//
// Rule that applies to every category: when a category triggers, only
// the CATEGORY may be logged — never the user's original content.

/// What the app does when a safety category is triggered.
struct TarotSafetyAction: Equatable {
    /// Whether the normal card-by-card interpretation may be shown.
    let allowNormalInterpretation: Bool
    /// Whether the reading is replaced by a supportive response.
    let replaceWithSupportiveResponse: Bool
    /// Whether the optional Guidance Card CTA stays available.
    let allowGuidanceCardCTA: Bool
    /// Whether the stronger disclaimer variant is shown.
    let showStrongerDisclaimer: Bool
    /// Whether professional-resource pointers are shown.
    let showProfessionalResources: Bool
}

enum TarotSafetyMatrix {
    /// The draft matrix (v0.1). Founder-approved values replace this
    /// table verbatim.
    static func action(for category: TarotLLMSafetyCategory) -> TarotSafetyAction {
        switch category {
        case .none:
            return .init(allowNormalInterpretation: true,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: true,
                         showStrongerDisclaimer: false,
                         showProfessionalResources: false)
        case .selfHarmCrisis:
            // Never interpret cards about a crisis. Supportive response
            // only, no further drawing, resources front and center.
            return .init(allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .medicalDiagnosis:
            // No diagnosis or outcome content — supportive reframe
            // toward feelings + professional care.
            return .init(allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .legalDecision:
            // Reflective interpretation of the person's own state is
            // allowed; the model is instructed to avoid legal
            // conclusions, and the stronger disclaimer is shown.
            return .init(allowNormalInterpretation: true,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: true,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .financialDecision:
            return .init(allowNormalInterpretation: true,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: true,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: false)
        case .pregnancyDeathPrediction:
            // Never predicted, in either direction. Supportive
            // replacement, no further drawing.
            return .init(allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: false)
        case .relationshipMindReading:
            // The reading proceeds, but strictly in presented-state
            // language (prompt-enforced + linted), with the stronger
            // disclaimer.
            return .init(allowNormalInterpretation: true,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: true,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: false)
        }
    }

    /// Supportive replacement copy for categories where the normal
    /// interpretation is withheld. Warm, non-judgmental, and honest
    /// about what Tarot cannot do.
    static func supportiveResponse(for category: TarotLLMSafetyCategory,
                                   lang: AppLanguage) -> String? {
        switch (category, lang) {
        case (.selfHarmCrisis, .traditionalChinese):
            return "謝謝你願意把這麼重的心情帶到這裡。這件事比一次塔羅能承接的更重要——牌卡沒辦法回應此刻的你真正需要的支持。請讓一個信任的人知道你現在的狀態，或聯繫專業協助;在台灣可撥打安心專線 1925(24 小時)。Twinko 會在這裡陪你。"
        case (.selfHarmCrisis, .english):
            return "Thank you for bringing something this heavy here. This matters more than a Tarot reading can hold — the cards can't give you the support you actually need right now. Please let someone you trust know how you're doing, or reach out to professional help — you can call or text 988 (US) or your local crisis line. Twinko is here with you."
        case (.medicalDiagnosis, .traditionalChinese):
            return "身體的擔心值得被認真對待——而塔羅無法判斷健康狀況。牌可以陪你整理這份擔心帶來的心情，但關於身體本身，請交給專業的醫療人員。要不要先從「這份擔心讓你最在意的是什麼」開始?"
        case (.medicalDiagnosis, .english):
            return "A worry about your health deserves real care — and Tarot can't assess medical conditions. The cards can help you sit with the feelings this worry brings, but the body itself belongs with a medical professional. Would you like to start from what this worry touches most?"
        case (.pregnancyDeathPrediction, .traditionalChinese):
            return "這個問題觸及生命裡最深的事,而塔羅無法預測懷孕或生死——任何聲稱可以的解讀都不誠實。牌可以陪你面對這份等待或不安的心情;如果你願意,我們可以從此刻的感受開始。"
        case (.pregnancyDeathPrediction, .english):
            return "This question touches the deepest things in a life, and Tarot cannot predict pregnancy or death — any reading that claims to would be dishonest. The cards can keep you company in the waiting or the worry; if you'd like, we can start from how this feels right now."
        default:
            return nil
        }
    }
}
