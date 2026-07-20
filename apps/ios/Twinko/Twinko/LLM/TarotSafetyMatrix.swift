import Foundation

// MARK: - Tarot safety action matrix (DRAFT v0.2 — founder review PENDING)
//
// ⚠️ DRAFT — NOT founder-approved. Safety policy is a reserved
// decision; this table is a provisional implementation prepared for
// review and may be revised. The matrix is data, not scattered ifs,
// so the approved version replaces one table. The APP enforces the
// policy action deterministically — the model only classifies.
//
// v0.2 correction (2026-07-21 bounded audit): legal, financial, and
// relationship mind-reading no longer receive a normal interpretation
// with a disclaimer — they require a user-approved safe reframe
// before any reading renders (canonical spec §4 D/E/G, §7).
//
// Rule that applies to every category: when a category triggers, only
// the CATEGORY may be logged — never the user's original content.

/// The app-enforced policy action for a classified request.
enum TarotSafetyPolicyAction: Equatable {
    /// Full reflective interpretation.
    case allowReflectiveReading
    /// Reserved for the canonical spec's caution severity (constrained
    /// interpretation); no current category maps here until the
    /// category × severity matrix is founder-approved.
    case allowWithConstraints
    /// No reading until the user approves (or edits) a safe
    /// reflective reframe of the question — visible, never silent,
    /// never auto-submitted.
    case requireUserApprovedReframe
    /// The reading is replaced by a supportive response.
    case replaceWithSupport
    /// The request is refused outright (minor sexual safety). App
    /// behavior mirrors replacement (no reading, no Guidance), with
    /// refusal copy.
    case refuseRequest
}

/// What the app does when a safety category is triggered.
struct TarotSafetyAction: Equatable {
    /// The app-enforced policy action.
    let policy: TarotSafetyPolicyAction
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

// MARK: - Region-based crisis resources (2026-07-21 correction)
//
// Resource mapping is REGION-based, never UI-language-based: an
// English-language user in Taiwan gets Taiwan resources, never US 988.
// The region comes from the existing device locale setting (no
// location permission, nothing new collected). Unknown/unsupported
// regions get the phone-number-free fallback — an unverified number is
// never displayed. ALL numbers remain unverified for external release
// (FD-03); Phase A founder-local display only.

enum TarotCrisisRegion: Equatable {
    case taiwan
    case unitedStates
    case unknown

    /// Pure mapping from an ISO region identifier (testable).
    static func from(localeRegion: String?) -> TarotCrisisRegion {
        switch localeRegion?.uppercased() {
        case "TW": return .taiwan
        case "US": return .unitedStates
        default: return .unknown
        }
    }

    /// Device-locale region (existing system configuration — no
    /// location services).
    static var current: TarotCrisisRegion {
        from(localeRegion: Locale.autoupdatingCurrent.region?.identifier)
    }
}

enum TarotCrisisResources {
    /// The region-scoped resource sentence appended to supportive
    /// copy, or nil when no verified-enough mapping exists for the
    /// category in that region (the base copy already encourages
    /// trusted people / professional help).
    ///
    /// Taiwan: 1925 emotional crisis · 113 protection (abuse/minors)
    /// · 119 urgent medical danger. United States: 988 suicide/crisis
    /// only. Unknown region: explicit no-number fallback.
    /// Categories that warrant an explicit crisis-resource sentence.
    /// Medical/pregnancy replacement copy already directs to
    /// professional care in its body and gets no resource line.
    private static let crisisAdjacent: Set<TarotLLMSafetyCategory> = [
        .selfHarmCrisis, .harmToOthers, .abuseUnsafeRelationship,
        .realityDistortion, .minorSexualSafety, .substanceRisk,
    ]

    static func resourceLine(for category: TarotLLMSafetyCategory,
                             region: TarotCrisisRegion,
                             lang: AppLanguage) -> String? {
        guard crisisAdjacent.contains(category) else { return nil }
        switch (category, region) {
        case (.selfHarmCrisis, .taiwan), (.realityDistortion, .taiwan):
            return lang == .english
            ? " In Taiwan you can call the 1925 mental-health support line (24 hours)."
            : "在台灣可撥打安心專線 1925（24 小時）。"
        case (.selfHarmCrisis, .unitedStates):
            return lang == .english
            ? " In the US you can call or text 988 (Suicide & Crisis Lifeline)."
            : "在美國可撥打或傳訊 988（自殺與危機生命線）。"
        case (.abuseUnsafeRelationship, .taiwan), (.minorSexualSafety, .taiwan):
            return lang == .english
            ? " In Taiwan you can call the 113 protection hotline (24 hours)."
            : "在台灣可撥打 113 保護專線（24 小時）。"
        case (.substanceRisk, .taiwan), (.harmToOthers, .taiwan):
            return lang == .english
            ? " For immediate danger or a medical emergency in Taiwan, call 119."
            : "若有立即危險或醫療緊急狀況，在台灣請撥打 119。"
        default:
            // Unknown region, or no verified mapping for this category
            // in this region — never an unverified number.
            return unknownRegionFallback(lang)
        }
    }

    /// Phone-number-free fallback: local emergency services + a
    /// trusted person, and honesty that verified local mapping is not
    /// yet available.
    static func unknownRegionFallback(_ lang: AppLanguage) -> String {
        lang == .english
        ? " Please contact your local emergency services or a trusted person — verified local support-resource mapping for your region is not yet available in this prototype."
        : "請聯繫你所在地區的緊急服務或信任的人——此原型目前尚未提供你所在地區已查證的求助資源對照。"
    }
}

enum TarotSafetyMatrix {
    /// The draft matrix (v0.2, founder review pending). Approved
    /// values replace this table verbatim.
    static func action(for category: TarotLLMSafetyCategory) -> TarotSafetyAction {
        switch category {
        case .none:
            return .init(policy: .allowReflectiveReading,
                         allowNormalInterpretation: true,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: true,
                         showStrongerDisclaimer: false,
                         showProfessionalResources: false)
        case .selfHarmCrisis:
            // Never interpret cards about a crisis. Supportive response
            // only, no further drawing, resources front and center.
            // Never enters the reframe flow.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .medicalDiagnosis:
            // No diagnosis or outcome content — supportive replacement
            // toward feelings + professional care. Never the reframe
            // flow.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .legalDecision:
            // v0.2: no legal outcome/strategy/contract conclusions,
            // ever. The user must approve a safe reflective reframe
            // before any reading renders; Guidance stays unavailable
            // until then.
            return .init(policy: .requireUserApprovedReframe,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .financialDecision:
            // v0.2: no buy/sell/bet/borrow direction, no predicted
            // returns, no winner ranking, no invented probabilities.
            // User-approved reframe required; Guidance must never act
            // as a second attempt at a financial signal.
            return .init(policy: .requireUserApprovedReframe,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: false)
        case .pregnancyDeathPrediction:
            // Never predicted, in either direction. Supportive
            // replacement, no further drawing. Never the reframe flow.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: false)
        case .relationshipMindReading:
            // v0.2: no hidden-feelings/cheating/contact/destiny claims.
            // A reflective relationship reading proceeds only after the
            // user approves the presented-state reframe.
            return .init(policy: .requireUserApprovedReframe,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: false,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: false)
        case .harmToOthers:
            // Never help plan or validate violence; never predict
            // whether violence will occur. Severity distinctions
            // collapse to the safer replacement in v0.2.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .abuseUnsafeRelationship:
            // Cards never decide whether abuse is real or whether an
            // abusive person will change; physical safety and
            // real-world support come first. Never a spiritual-lesson
            // framing.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .realityDistortion:
            // Never validate surveillance/possession/persecution
            // beliefs as fact and never let cards reinforce them;
            // acknowledge the feeling, redirect to observable facts
            // and trusted support. No ridicule.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .minorSexualSafety:
            // Refused outright — no reading of any kind; suspected
            // abuse/exploitation routes to safety support.
            return .init(policy: .refuseRequest,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        case .substanceRisk:
            // No dosing/mixing advice, no Tarot-justified risky use;
            // overdose signals route to urgent support. Ordinary
            // reflection on habits/boundaries classifies as none.
            return .init(policy: .replaceWithSupport,
                         allowNormalInterpretation: false,
                         replaceWithSupportiveResponse: true,
                         allowGuidanceCardCTA: false,
                         showStrongerDisclaimer: true,
                         showProfessionalResources: true)
        }
    }

    /// Safe reflective reframe suggestion for reframe-required
    /// categories (visible + editable in the UI — never silently
    /// substituted, never auto-submitted). Provisional copy, founder
    /// review pending.
    static func reframeSuggestion(for category: TarotLLMSafetyCategory,
                                  lang: AppLanguage) -> String? {
        switch (category, lang) {
        case (.legalDecision, .traditionalChinese):
            return "在做出明智的決定之前，我想先釐清哪些優先順序與疑問？"
        case (.legalDecision, .english):
            return "What priorities and questions should I clarify before making an informed decision?"
        case (.financialDecision, .traditionalChinese):
            return "面對這個財務選擇，我的風險承受度和真正在意的是什麼？"
        case (.financialDecision, .english):
            return "What is my risk tolerance, and what really matters to me in this financial choice?"
        case (.relationshipMindReading, .traditionalChinese):
            return "從目前實際觀察到的互動裡，我能注意到什麼？我自己需要什麼？"
        case (.relationshipMindReading, .english):
            return "What can I notice about the interaction I currently observe, and what do I need?"
        default:
            return nil
        }
    }

    /// Supportive replacement copy for categories where the normal
    /// interpretation is withheld. Warm, non-judgmental, and honest
    /// about what Tarot cannot do. The empathy body is language-based;
    /// the crisis-resource sentence is REGION-based (§`TarotCrisisResources`)
    /// and appended separately — an English-language user in Taiwan
    /// gets Taiwan resources, never US 988.
    static func supportiveResponse(for category: TarotLLMSafetyCategory,
                                   lang: AppLanguage,
                                   region: TarotCrisisRegion = .current) -> String? {
        guard let base = supportiveBody(for: category, lang: lang) else { return nil }
        guard let resource = TarotCrisisResources.resourceLine(for: category,
                                                               region: region,
                                                               lang: lang) else {
            return base
        }
        return base + resource
    }

    private static func supportiveBody(for category: TarotLLMSafetyCategory,
                                       lang: AppLanguage) -> String? {
        switch (category, lang) {
        case (.selfHarmCrisis, .traditionalChinese):
            return "謝謝你願意把這麼重的心情帶到這裡。這件事比一次塔羅能承接的更重要——牌卡沒辦法回應此刻的你真正需要的支持。請讓一個信任的人知道你現在的狀態，或聯繫專業協助。Twinko 會在這裡陪你。"
        case (.selfHarmCrisis, .english):
            return "Thank you for bringing something this heavy here. This matters more than a Tarot reading can hold — the cards can't give you the support you actually need right now. Please let someone you trust know how you're doing, and reach out to professional help. Twinko is here with you."
        case (.medicalDiagnosis, .traditionalChinese):
            return "身體的擔心值得被認真對待——而塔羅無法判斷健康狀況。牌可以陪你整理這份擔心帶來的心情，但關於身體本身，請交給專業的醫療人員。要不要先從「這份擔心讓你最在意的是什麼」開始?"
        case (.medicalDiagnosis, .english):
            return "A worry about your health deserves real care — and Tarot can't assess medical conditions. The cards can help you sit with the feelings this worry brings, but the body itself belongs with a medical professional. Would you like to start from what this worry touches most?"
        case (.pregnancyDeathPrediction, .traditionalChinese):
            return "這個問題觸及生命裡最深的事,而塔羅無法預測懷孕或生死——任何聲稱可以的解讀都不誠實。牌可以陪你面對這份等待或不安的心情;如果你願意,我們可以從此刻的感受開始。"
        case (.pregnancyDeathPrediction, .english):
            return "This question touches the deepest things in a life, and Tarot cannot predict pregnancy or death — any reading that claims to would be dishonest. The cards can keep you company in the waiting or the worry; if you'd like, we can start from how this feels right now."
        case (.harmToOthers, .traditionalChinese):
            return "聽得出來這股憤怒或衝突真的很強烈。塔羅沒辦法告訴你要不要對誰採取行動，也無法預測會不會發生衝突——這不是牌能承接的事。在做任何事之前，請先讓自己安全地降溫，找一個信任的人或專業協助聊聊此刻的感受。"
        case (.harmToOthers, .english):
            return "That anger or conflict sounds truly intense. Tarot can't tell you whether to act against someone, and it can't predict whether violence will happen — this isn't something the cards can hold. Before anything else, please give yourself room to cool down safely, and talk this through with someone you trust or a professional."
        case (.abuseUnsafeRelationship, .traditionalChinese):
            return "你描述的情況涉及你的安全，這比任何一次塔羅都重要。牌卡無法判斷傷害是否存在、也無法預測對方會不會改變——請優先照顧自己的人身安全，讓信任的人知道你的處境，或聯繫專業協助。Twinko 會在這裡陪你。"
        case (.abuseUnsafeRelationship, .english):
            return "What you're describing touches your safety, and that matters more than any Tarot reading. The cards can't judge whether harm is real or predict whether someone will change — please put your physical safety first, let someone you trust know your situation, and reach professional support. Twinko is here with you."
        case (.realityDistortion, .traditionalChinese):
            return "這種感覺一定讓你很不安，這份不安是真實的、值得被好好對待。不過塔羅無法證實或否認有人在監視、控制或針對你——用牌卡去確認這件事對你並不公平。要不要先從「這份感覺此刻對你的影響」開始，也和一位你信任的人或專業人員聊聊看？"
        case (.realityDistortion, .english):
            return "This must feel deeply unsettling, and that distress is real and deserves care. But Tarot cannot confirm or deny that someone is watching, controlling, or targeting you — using cards to settle that wouldn't be fair to you. Could we start from how this feeling is affecting you right now, and could you also talk it through with someone you trust or a professional?"
        case (.minorSexualSafety, .traditionalChinese):
            return "這個請求涉及未成年人的安全，Twinko 無法以任何形式回應或解讀。如果你或你認識的未成年人可能正處於不安全的情況，請聯繫信任的大人或專業協助。"
        case (.minorSexualSafety, .english):
            return "This request involves the safety of a minor, and Twinko cannot respond to or interpret it in any form. If you or a minor you know may be in an unsafe situation, please contact a trusted adult or professional support."
        case (.substanceRisk, .traditionalChinese):
            return "關於物質使用的劑量、混用或風險，塔羅無法給出任何安全的答案——這些只能交給專業的醫療資訊。牌可以陪你思考的是你和這件事的關係，以及你想為自己尋求什麼支持。"
        case (.substanceRisk, .english):
            return "Tarot can't give any safe answer about substance amounts, mixing, or risk — only professional medical guidance can. What the cards can sit with is your relationship to this, and what support you might want for yourself."
        default:
            return nil
        }
    }

    // MARK: Deterministic pre-reading preflight (first safety layer)

    /// Conservative, precision-biased local classifier run BEFORE any
    /// base card is drawn (no network, no cost). It gates the clearly
    /// restricted phrasings; the model's own classification of the
    /// final generation remains the second enforcement layer. Benign
    /// reflective questions must pass — over-blocking ordinary use is
    /// itself a failure mode.
    static func preflightCategory(question: String,
                                  decisionContext: String? = nil,
                                  optionA: String? = nil,
                                  optionB: String? = nil,
                                  personLabel: String? = nil) -> TarotLLMSafetyCategory {
        let corpus = [question, decisionContext ?? "", optionA ?? "",
                      optionB ?? "", personLabel ?? ""]
            .joined(separator: " ").lowercased()
        guard !corpus.trimmingCharacters(in: .whitespaces).isEmpty else { return .none }

        func hits(_ patterns: [String]) -> Bool {
            patterns.contains { corpus.contains($0) }
        }

        // Ordered by stakes: crisis-level categories win ties.
        if hits(["想死", "不想活", "自殺", "自我了結", "傷害自己", "活不下去",
                 "如果我消失", "結束這一切", "結束自己", "kill myself", "suicide",
                 "end my life", "hurt myself", "self-harm"]) {
            return .selfHarmCrisis
        }
        if hits(["想殺", "殺了他", "殺了她", "傷害他", "傷害她", "讓他付出代價",
                 "報復他", "報復她", "kill him", "kill her", "hurt him", "hurt her",
                 "make them pay"]) {
            return .harmToOthers
        }
        if hits(["家暴", "他會打我", "她會打我", "打我", "威脅我", "跟蹤我",
                 "不敢離開他", "不敢離開她", "abuse", "abusive", "stalking",
                 "afraid to leave", "hits me", "threatens me"]) {
            return .abuseUnsafeRelationship
        }
        if hits(["監視我", "控制我的思想", "讀我的心", "附身", "針對我的陰謀",
                 "reading my thoughts", "controlling my mind", "possessed by",
                 "conspiracy against me"]) {
            return .realityDistortion
        }
        if hits(["未成年", "國中生交往", "minor sexual", "underage"]) {
            return .minorSexualSafety
        }
        if hits(["過量", "吸毒", "嗑藥", "混著吃", "藥混", "overdose",
                 "how much can i take", "mixing drugs"]) {
            return .substanceRisk
        }
        if hits(["得了什麼病", "是不是生病", "重病", "癌症", "是不是得了", "確診",
                 "停藥", "吃藥", "藥要不要", "diagnos", "do i have cancer",
                 "stop taking my medication", "is my illness"]) {
            return .medicalDiagnosis
        }
        if hits(["懷孕", "流產", "生育", "會不會死", "活多久", "死期", "壽命",
                 "am i pregnant", "will i die", "when will", "terminal"])
            && hits(["懷孕", "流產", "生育", "死", "壽命", "pregnant", "die",
                     "terminal"]) {
            return .pregnancyDeathPrediction
        }
        if hits(["官司", "訴訟", "勝訴", "敗訴", "會不會被告", "會被起訴", "被逮捕",
                 "合約該不該簽", "簽這份合約", "lawsuit", "sue", "arrested",
                 "sign this contract", "legal strategy", "win in court"]) {
            return .legalDecision
        }
        if hits(["股票", "買股", "加密貨幣", "比特幣", "虛擬貨幣", "會不會漲",
                 "該不該投資", "賭", "簽賭", "彩券", "樂透", "借錢", "貸款該不該",
                 "which stock", "crypto", "bitcoin", "should i invest", "bet",
                 "gamble", "lottery", "borrow money"]) {
            return .financialDecision
        }
        if hits(["他在想什麼", "她在想什麼", "心裡在想", "他還愛我", "她還愛我",
                 "還喜歡我嗎", "是不是偷吃", "偷吃", "劈腿", "外遇", "會不會聯絡我",
                 "會不會回來找我", "命中注定", "注定在一起", "secretly love",
                 "secretly like", "is he cheating", "is she cheating",
                 "will they contact me", "destined to be together",
                 "what is he thinking", "what is she thinking"]) {
            return .relationshipMindReading
        }
        return .none
    }
}
