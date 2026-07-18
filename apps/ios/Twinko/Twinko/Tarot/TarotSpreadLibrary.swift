import Foundation

// MARK: - Canonical MVP spread library (Phase 1, 2026-07-19)
//
// One centralized definition source for the ten MVP standard spreads
// per `docs/features/tarot/TWINKOTALK_TAROT_USAGE_SPEC.md` (v2.0).
// Stable identifiers only — localized display copy lives in the
// `label(_:)`-style functions below and is never persisted or used as
// logic. Future premium / periodic spreads (weekly, monthly, yearly,
// Celtic Cross) are intentionally absent from this active MVP library.
// The legacy live flow keeps using `TarotSpreadType` until Task 2
// generalizes the draw engine; nothing here touches draw/reveal/result.

enum TarotSpreadID: String, Codable, CaseIterable, Identifiable {
    case singleCard
    case timelineThree
    case actionDirectionThree
    case blindSpotThree
    case holisticCheckInThree
    case thinkFeelActThree
    case directionPathThree
    case coreClarityFour
    case twoChoiceFive
    case relationshipFive

    var id: String { rawValue }
}

/// Stable position identifiers for every MVP spread position.
/// Semantically identical positions (可能走向) share one case; all
/// display strings localize through `label(_:)` / `previewLabel(_:)`.
enum TarotPositionID: String, Codable, CaseIterable {
    // singleCard
    case momentMessage
    // timelineThree (+ shared possibleDirection)
    case past, present, possibleDirection
    // actionDirectionThree
    case currentSituation, availableAction
    // blindSpotThree
    case currentUnderstanding, unseenPerspective, possibleReframe
    // holisticCheckInThree
    case bodySignal, thoughtsFeelings, innerCare
    // thinkFeelActThree
    case whatIThink, whatIFeel, howIRespond
    // directionPathThree
    case whereIAmNow, whereIWantToGo, howIMoveCloser
    // coreClarityFour
    case coreIssue, currentObstacle, possibleApproach, availableStrength
    // twoChoiceFive
    case optionAState, optionBState, optionADirection, optionBDirection, yourCurrentState
    // relationshipFive
    case myState, myFeelingsAttitude, theirPresentedState, theirPresentedAttitude,
         relationshipDirection

    func label(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.momentMessage, .english): return "A Message for This Moment"
        case (.momentMessage, .traditionalChinese): return "此刻的提醒"
        case (.past, .english): return "Past"
        case (.past, .traditionalChinese): return "過去"
        case (.present, .english): return "Present"
        case (.present, .traditionalChinese): return "現在"
        case (.possibleDirection, .english): return "Possible Direction"
        case (.possibleDirection, .traditionalChinese): return "可能走向"
        case (.currentSituation, .english): return "Current Situation"
        case (.currentSituation, .traditionalChinese): return "目前現況"
        case (.availableAction, .english): return "Available Action"
        case (.availableAction, .traditionalChinese): return "可以採取的行動"
        case (.currentUnderstanding, .english): return "My Current Understanding"
        case (.currentUnderstanding, .traditionalChinese): return "我目前的理解"
        case (.unseenPerspective, .english): return "An Unseen Perspective"
        case (.unseenPerspective, .traditionalChinese): return "尚未看見的面向"
        case (.possibleReframe, .english): return "A Possible Reframe"
        case (.possibleReframe, .traditionalChinese): return "可以重新思考的方向"
        case (.bodySignal, .english): return "What My Body Is Signaling"
        case (.bodySignal, .traditionalChinese): return "身體現在的感受"
        case (.thoughtsFeelings, .english): return "My Thoughts and Feelings"
        case (.thoughtsFeelings, .traditionalChinese): return "情緒與思緒的狀態"
        case (.innerCare, .english): return "The Care I May Need"
        case (.innerCare, .traditionalChinese): return "內在最需要的照顧"
        case (.whatIThink, .english): return "What I Think"
        case (.whatIThink, .traditionalChinese): return "我怎麼理解這件事"
        case (.whatIFeel, .english): return "What I Feel"
        case (.whatIFeel, .traditionalChinese): return "我真正感受到什麼"
        case (.howIRespond, .english): return "How I Am Responding"
        case (.howIRespond, .traditionalChinese): return "我正在如何回應"
        case (.whereIAmNow, .english): return "Where I Am Now"
        case (.whereIAmNow, .traditionalChinese): return "目前所在的位置"
        case (.whereIWantToGo, .english): return "Where I Want to Go"
        case (.whereIWantToGo, .traditionalChinese): return "真正想前往的方向"
        case (.howIMoveCloser, .english): return "How I May Move Closer"
        case (.howIMoveCloser, .traditionalChinese): return "可以如何靠近"
        case (.coreIssue, .english): return "Core Issue"
        case (.coreIssue, .traditionalChinese): return "問題核心"
        case (.currentObstacle, .english): return "Current Obstacle"
        case (.currentObstacle, .traditionalChinese): return "目前阻礙"
        case (.possibleApproach, .english): return "Possible Approach"
        case (.possibleApproach, .traditionalChinese): return "可行對策"
        case (.availableStrength, .english): return "Available Strength"
        case (.availableStrength, .traditionalChinese): return "可運用的優勢"
        case (.optionAState, .english): return "Option A — Current State"
        case (.optionAState, .traditionalChinese): return "選項 A 的狀態"
        case (.optionBState, .english): return "Option B — Current State"
        case (.optionBState, .traditionalChinese): return "選項 B 的狀態"
        case (.optionADirection, .english): return "Option A — Possible Direction"
        case (.optionADirection, .traditionalChinese): return "選擇 A 的可能走向"
        case (.optionBDirection, .english): return "Option B — Possible Direction"
        case (.optionBDirection, .traditionalChinese): return "選擇 B 的可能走向"
        case (.yourCurrentState, .english): return "Your Current State"
        case (.yourCurrentState, .traditionalChinese): return "你目前的狀態"
        case (.myState, .english): return "My Current State"
        case (.myState, .traditionalChinese): return "我的狀態"
        case (.myFeelingsAttitude, .english): return "My Feelings and Attitude"
        case (.myFeelingsAttitude, .traditionalChinese): return "我對對方的感情態度"
        case (.theirPresentedState, .english): return "The Other Person's Presented State"
        case (.theirPresentedState, .traditionalChinese): return "對方呈現的狀態"
        case (.theirPresentedAttitude, .english): return "Their Presented Attitude in the Relationship"
        case (.theirPresentedAttitude, .traditionalChinese): return "對方在關係中呈現的態度"
        case (.relationshipDirection, .english): return "Possible Relationship Direction"
        case (.relationshipDirection, .traditionalChinese): return "關係的可能走向"
        }
    }

    /// Short form for the compact spread preview; the full meaning
    /// stays available below the diagram and through accessibility.
    func previewLabel(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.momentMessage, .english): return "Message"
        case (.momentMessage, .traditionalChinese): return "提醒"
        case (.past, _), (.present, _): return label(l)
        case (.possibleDirection, .english): return "Direction"
        case (.possibleDirection, .traditionalChinese): return "走向"
        case (.currentSituation, .english): return "Situation"
        case (.currentSituation, .traditionalChinese): return "現況"
        case (.availableAction, .english): return "Action"
        case (.availableAction, .traditionalChinese): return "行動"
        case (.currentUnderstanding, .english): return "My View"
        case (.currentUnderstanding, .traditionalChinese): return "理解"
        case (.unseenPerspective, .english): return "Unseen"
        case (.unseenPerspective, .traditionalChinese): return "盲點"
        case (.possibleReframe, .english): return "Reframe"
        case (.possibleReframe, .traditionalChinese): return "新角度"
        case (.bodySignal, .english): return "Body"
        case (.bodySignal, .traditionalChinese): return "身體"
        case (.thoughtsFeelings, .english): return "Mind"
        case (.thoughtsFeelings, .traditionalChinese): return "心緒"
        case (.innerCare, .english): return "Care"
        case (.innerCare, .traditionalChinese): return "照顧"
        case (.whatIThink, .english): return "Think"
        case (.whatIThink, .traditionalChinese): return "想法"
        case (.whatIFeel, .english): return "Feel"
        case (.whatIFeel, .traditionalChinese): return "感受"
        case (.howIRespond, .english): return "Act"
        case (.howIRespond, .traditionalChinese): return "行動"
        case (.whereIAmNow, .english): return "Now"
        case (.whereIAmNow, .traditionalChinese): return "位置"
        case (.whereIWantToGo, .english): return "Goal"
        case (.whereIWantToGo, .traditionalChinese): return "方向"
        case (.howIMoveCloser, .english): return "Closer"
        case (.howIMoveCloser, .traditionalChinese): return "靠近"
        case (.coreIssue, .english): return "Core"
        case (.coreIssue, .traditionalChinese): return "核心"
        case (.currentObstacle, .english): return "Obstacle"
        case (.currentObstacle, .traditionalChinese): return "阻礙"
        case (.possibleApproach, .english): return "Approach"
        case (.possibleApproach, .traditionalChinese): return "對策"
        case (.availableStrength, .english): return "Strength"
        case (.availableStrength, .traditionalChinese): return "優勢"
        case (.optionAState, .english): return "A · State"
        case (.optionAState, .traditionalChinese): return "A 狀態"
        case (.optionBState, .english): return "B · State"
        case (.optionBState, .traditionalChinese): return "B 狀態"
        case (.optionADirection, .english): return "A · Direction"
        case (.optionADirection, .traditionalChinese): return "A 走向"
        case (.optionBDirection, .english): return "B · Direction"
        case (.optionBDirection, .traditionalChinese): return "B 走向"
        case (.yourCurrentState, .english): return "You"
        case (.yourCurrentState, .traditionalChinese): return "你的狀態"
        case (.myState, .english): return "Me"
        case (.myState, .traditionalChinese): return "我"
        case (.myFeelingsAttitude, .english): return "My Attitude"
        case (.myFeelingsAttitude, .traditionalChinese): return "我的態度"
        case (.theirPresentedState, .english): return "Them"
        case (.theirPresentedState, .traditionalChinese): return "對方"
        case (.theirPresentedAttitude, .english): return "Their Attitude"
        case (.theirPresentedAttitude, .traditionalChinese): return "對方態度"
        case (.relationshipDirection, .english): return "Direction"
        case (.relationshipDirection, .traditionalChinese): return "關係走向"
        }
    }
}

/// Which structured input a spread requires before the reading.
enum TarotInputKind: String, Codable {
    case generalQuestion
    case twoChoice
    case relationship
}

/// Preview-layout metadata for exactly the ten MVP spreads — not a
/// general-purpose layout engine.
enum TarotSpreadLayoutKind: String, Codable {
    case single
    case threeLinear
    case fourGrid
    case twoChoiceFive
    case relationshipFive
}

/// Question domains (usage spec §4) — eligibility/context signals only.
enum TarotDomain: String, Codable, CaseIterable {
    case romanticRelationship
    case careerWork
    case moneyFinance
    case familyFriendship
    case selfGrowth
    case wellbeingGeneral
    case generalLife
    case other

    static let all = Set(TarotDomain.allCases)
}

// MARK: - Intent model (landing entries)

/// The seven intent-oriented landing entries (Phase 1 §11–§12).
/// Recommendation is deterministic: one intent (+ optional refinement)
/// resolves to exactly one recommended spread ID.
enum TarotIntent: String, Codable, CaseIterable, Identifiable {
    case quickReflection
    case understandProgression
    case missingPerspective
    case nextStepOrDirection
    case understandMyself
    case compareTwoChoices
    case romanticRelationship

    var id: String { rawValue }

    /// Lightweight symbolic icon (code-based fallback; replaceable 1:1
    /// when approved icon assets arrive).
    var icon: String {
        switch self {
        case .quickReflection: return "sparkle"
        case .understandProgression: return "clock.arrow.circlepath"
        case .missingPerspective: return "eye"
        case .nextStepOrDirection: return "signpost.right"
        case .understandMyself: return "heart.circle"
        case .compareTwoChoices: return "arrow.triangle.branch"
        case .romanticRelationship: return "heart.fill"
        }
    }

    func title(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.quickReflection, .english): return "A quick reflection"
        case (.quickReflection, .traditionalChinese): return "快速獲得一個提醒"
        case (.understandProgression, .english): return "Understand how things developed"
        case (.understandProgression, .traditionalChinese): return "看看事情如何發展"
        case (.missingPerspective, .english): return "See what I may be missing"
        case (.missingPerspective, .traditionalChinese): return "看見可能忽略的面向"
        case (.nextStepOrDirection, .english): return "Find a next step or direction"
        case (.nextStepOrDirection, .traditionalChinese): return "找出下一步與方向"
        case (.understandMyself, .english): return "Understand myself more clearly"
        case (.understandMyself, .traditionalChinese): return "理解自己的狀態"
        case (.compareTwoChoices, .english): return "Compare two choices"
        case (.compareTwoChoices, .traditionalChinese): return "比較兩個選擇"
        case (.romanticRelationship, .english): return "Understand a romantic relationship"
        case (.romanticRelationship, .traditionalChinese): return "理解一段感情"
        }
    }

    func supportingCopy(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.quickReflection, .english):
            return "Use one card to focus on what may matter most right now"
        case (.quickReflection, .traditionalChinese):
            return "用一張牌看看此刻最值得留意的事"
        case (.understandProgression, .english):
            return "Reflect on the past, present, and possible direction"
        case (.understandProgression, .traditionalChinese):
            return "從過去、現在與可能走向整理這件事"
        case (.missingPerspective, .english):
            return "Explore your current view, an unseen perspective, and a possible reframe"
        case (.missingPerspective, .traditionalChinese):
            return "整理目前的理解、盲點與新的思考角度"
        case (.nextStepOrDirection, .english):
            return "Clarify what to do next, what is blocking you, or how to move toward a goal"
        case (.nextStepOrDirection, .traditionalChinese):
            return "釐清現在能做什麼、為什麼卡住，或如何靠近目標"
        case (.understandMyself, .english):
            return "Check in with your whole state or reflect on thoughts, feelings, and actions"
        case (.understandMyself, .traditionalChinese):
            return "看看整體狀態，或整理一件事中的想法、感受與行動"
        case (.compareTwoChoices, .english):
            return "Compare the state and possible direction of two clear options"
        case (.compareTwoChoices, .traditionalChinese):
            return "比較兩個明確選項的狀態與可能走向"
        case (.romanticRelationship, .english):
            return "Reflect on you, the other person, and the relationship dynamic"
        case (.romanticRelationship, .traditionalChinese):
            return "看看你、對方與目前的關係互動"
        }
    }

    /// Refinement options where one intent maps to several spreads.
    /// Empty means the intent maps directly to one spread.
    var refinements: [TarotIntentRefinement] {
        switch self {
        case .nextStepOrDirection:
            return [.practicalNextAction, .understandWhyStuck, .knownDirectionUnknownPath]
        case .understandMyself:
            return [.wholePersonCheckIn, .specificSituationReflection]
        default:
            return []
        }
    }
}

enum TarotIntentRefinement: String, Codable, CaseIterable, Identifiable {
    case practicalNextAction
    case understandWhyStuck
    case knownDirectionUnknownPath
    case wholePersonCheckIn
    case specificSituationReflection

    var id: String { rawValue }

    func title(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.practicalNextAction, .english): return "I want a practical next action"
        case (.practicalNextAction, .traditionalChinese): return "我想知道現在可以怎麼做"
        case (.understandWhyStuck, .english): return "I want to understand why I feel stuck"
        case (.understandWhyStuck, .traditionalChinese): return "我想找出真正卡住的原因"
        case (.knownDirectionUnknownPath, .english):
            return "I know where I want to go, but not how to move closer"
        case (.knownDirectionUnknownPath, .traditionalChinese):
            return "我知道想去哪裡，但不知道怎麼靠近"
        case (.wholePersonCheckIn, .english): return "Check in with my overall state today"
        case (.wholePersonCheckIn, .traditionalChinese): return "看看今天整體的身心狀態"
        case (.specificSituationReflection, .english):
            return "Reflect on my thoughts, feelings, and actions in one situation"
        case (.specificSituationReflection, .traditionalChinese):
            return "整理某件事中的想法、感受與行動"
        }
    }
}

// MARK: - Spread definition

struct TarotSpreadDefinition: Identifiable {
    let id: TarotSpreadID
    let cardCount: Int
    let positionIDs: [TarotPositionID]
    let inputKind: TarotInputKind
    let layoutKind: TarotSpreadLayoutKind
    let supportedDomains: Set<TarotDomain>
    let supportedIntents: Set<TarotIntent>
    /// Recorded for Task 2+; Guidance Card behavior is not implemented
    /// in Phase 1.
    let supportsGuidanceCard: Bool
}

// MARK: - Library (one canonical source)

enum TarotSpreadLibrary {
    /// Ordered as grouped in the Change Spread selector.
    static let orderedIDs: [TarotSpreadID] = [
        .singleCard,
        .timelineThree, .actionDirectionThree, .blindSpotThree,
        .holisticCheckInThree, .thinkFeelActThree, .directionPathThree,
        .coreClarityFour, .twoChoiceFive, .relationshipFive,
    ]

    static let definitions: [TarotSpreadID: TarotSpreadDefinition] = {
        let list: [TarotSpreadDefinition] = [
            .init(id: .singleCard, cardCount: 1,
                  positionIDs: [.momentMessage],
                  inputKind: .generalQuestion, layoutKind: .single,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.quickReflection],
                  supportsGuidanceCard: true),
            .init(id: .timelineThree, cardCount: 3,
                  positionIDs: [.past, .present, .possibleDirection],
                  inputKind: .generalQuestion, layoutKind: .threeLinear,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.understandProgression],
                  supportsGuidanceCard: true),
            .init(id: .actionDirectionThree, cardCount: 3,
                  positionIDs: [.currentSituation, .availableAction, .possibleDirection],
                  inputKind: .generalQuestion, layoutKind: .threeLinear,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.nextStepOrDirection],
                  supportsGuidanceCard: true),
            .init(id: .blindSpotThree, cardCount: 3,
                  positionIDs: [.currentUnderstanding, .unseenPerspective, .possibleReframe],
                  inputKind: .generalQuestion, layoutKind: .threeLinear,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.missingPerspective],
                  supportsGuidanceCard: true),
            .init(id: .holisticCheckInThree, cardCount: 3,
                  positionIDs: [.bodySignal, .thoughtsFeelings, .innerCare],
                  inputKind: .generalQuestion, layoutKind: .threeLinear,
                  supportedDomains: [.wellbeingGeneral, .selfGrowth, .generalLife, .other],
                  supportedIntents: [.understandMyself],
                  supportsGuidanceCard: true),
            .init(id: .thinkFeelActThree, cardCount: 3,
                  positionIDs: [.whatIThink, .whatIFeel, .howIRespond],
                  inputKind: .generalQuestion, layoutKind: .threeLinear,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.understandMyself],
                  supportsGuidanceCard: true),
            .init(id: .directionPathThree, cardCount: 3,
                  positionIDs: [.whereIAmNow, .whereIWantToGo, .howIMoveCloser],
                  inputKind: .generalQuestion, layoutKind: .threeLinear,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.nextStepOrDirection],
                  supportsGuidanceCard: true),
            .init(id: .coreClarityFour, cardCount: 4,
                  positionIDs: [.coreIssue, .currentObstacle, .possibleApproach, .availableStrength],
                  inputKind: .generalQuestion, layoutKind: .fourGrid,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.nextStepOrDirection],
                  supportsGuidanceCard: true),
            .init(id: .twoChoiceFive, cardCount: 5,
                  positionIDs: [.optionAState, .optionBState, .optionADirection,
                                .optionBDirection, .yourCurrentState],
                  inputKind: .twoChoice, layoutKind: .twoChoiceFive,
                  supportedDomains: TarotDomain.all,
                  supportedIntents: [.compareTwoChoices],
                  supportsGuidanceCard: true),
            .init(id: .relationshipFive, cardCount: 5,
                  positionIDs: [.myState, .myFeelingsAttitude, .theirPresentedState,
                                .theirPresentedAttitude, .relationshipDirection],
                  inputKind: .relationship, layoutKind: .relationshipFive,
                  supportedDomains: [.romanticRelationship],
                  supportedIntents: [.romanticRelationship],
                  supportsGuidanceCard: true),
        ]
        return Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }()

    static func definition(for id: TarotSpreadID) -> TarotSpreadDefinition {
        // The library covers every case of TarotSpreadID by construction.
        definitions[id]!
    }

    /// Deterministic prototype recommendation: one intent selection
    /// plus optional refinement resolves to one spread ID. No free-text
    /// classification, no randomness, no LLM.
    static func recommendedSpread(for intent: TarotIntent,
                                  refinement: TarotIntentRefinement?) -> TarotSpreadID? {
        switch intent {
        case .quickReflection: return .singleCard
        case .understandProgression: return .timelineThree
        case .missingPerspective: return .blindSpotThree
        case .compareTwoChoices: return .twoChoiceFive
        case .romanticRelationship: return .relationshipFive
        case .nextStepOrDirection:
            switch refinement {
            case .practicalNextAction: return .actionDirectionThree
            case .understandWhyStuck: return .coreClarityFour
            case .knownDirectionUnknownPath: return .directionPathThree
            default: return nil
            }
        case .understandMyself:
            switch refinement {
            case .wholePersonCheckIn: return .holisticCheckInThree
            case .specificSituationReflection: return .thinkFeelActThree
            default: return nil
            }
        }
    }

    /// Change Spread grouping (Phase 1 §21).
    enum SelectorGroup: String, CaseIterable, Identifiable {
        case quickReflection, threeCardPerspectives, deeperReflection

        var id: String { rawValue }

        var spreadIDs: [TarotSpreadID] {
            switch self {
            case .quickReflection:
                return [.singleCard]
            case .threeCardPerspectives:
                return [.timelineThree, .actionDirectionThree, .blindSpotThree,
                        .holisticCheckInThree, .thinkFeelActThree, .directionPathThree]
            case .deeperReflection:
                return [.coreClarityFour, .twoChoiceFive, .relationshipFive]
            }
        }

        func title(_ l: AppLanguage) -> String {
            switch (self, l) {
            case (.quickReflection, .english): return "Quick Reflection"
            case (.quickReflection, .traditionalChinese): return "快速反思"
            case (.threeCardPerspectives, .english): return "Three-Card Perspectives"
            case (.threeCardPerspectives, .traditionalChinese): return "三張牌視角"
            case (.deeperReflection, .english): return "Deeper Reflection"
            case (.deeperReflection, .traditionalChinese): return "深入反思"
            }
        }
    }
}

// MARK: - Localized spread display copy

extension TarotSpreadID {
    func title(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.singleCard, .english): return "One-Card Reflection"
        case (.singleCard, .traditionalChinese): return "一張牌提醒"
        case (.timelineThree, .english): return "Past, Present & Possible Direction"
        case (.timelineThree, .traditionalChinese): return "事情的發展脈絡"
        case (.actionDirectionThree, .english): return "Situation, Action & Possible Direction"
        case (.actionDirectionThree, .traditionalChinese): return "現況・行動・可能走向"
        case (.blindSpotThree, .english): return "Blind Spot Reflection"
        case (.blindSpotThree, .traditionalChinese): return "看見盲點"
        case (.holisticCheckInThree, .english): return "Body, Mind & Inner Care"
        case (.holisticCheckInThree, .traditionalChinese): return "身・心・內在"
        case (.thinkFeelActThree, .english): return "Thoughts, Feelings & Actions"
        case (.thinkFeelActThree, .traditionalChinese): return "想法・感受・行動"
        case (.directionPathThree, .english): return "Path Forward"
        case (.directionPathThree, .traditionalChinese): return "方向之路"
        case (.coreClarityFour, .english): return "Core Clarity"
        case (.coreClarityFour, .traditionalChinese): return "直指核心"
        case (.twoChoiceFive, .english): return "Two-Choice Reflection"
        case (.twoChoiceFive, .traditionalChinese): return "二選一抉擇"
        case (.relationshipFive, .english): return "Relationship Insight"
        case (.relationshipFive, .traditionalChinese): return "感情萬用"
        }
    }

    /// Short purpose (usage spec per-spread `Purpose`).
    func purpose(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.singleCard, .english):
            return "A quick reflection on what may matter most right now"
        case (.singleCard, .traditionalChinese):
            return "快速看看此刻最值得留意的訊息"
        case (.timelineThree, .english):
            return "Explore how the past and present may be shaping what comes next"
        case (.timelineThree, .traditionalChinese):
            return "從過去、現在與可能走向，整理事情如何發展到這裡"
        case (.actionDirectionThree, .english):
            return "Reflect on the current situation, an available next action, and the direction it may support"
        case (.actionDirectionThree, .traditionalChinese):
            return "整理現在的狀態、可以採取的下一步，以及行動後可能形成的方向"
        case (.blindSpotThree, .english):
            return "Reflect on your current understanding, an unseen perspective, and a possible reframe"
        case (.blindSpotThree, .traditionalChinese):
            return "整理你目前的理解、尚未看見的面向，以及可以重新思考的方向"
        case (.holisticCheckInThree, .english):
            return "Check in with the body, thoughts and emotions, and the care you may need today"
        case (.holisticCheckInThree, .traditionalChinese):
            return "感受身體、情緒與思緒，以及今天最需要的內在照顧"
        case (.thinkFeelActThree, .english):
            return "Explore how you understand a situation, what you feel, and how you are responding"
        case (.thinkFeelActThree, .traditionalChinese):
            return "理解你如何看待一件事、真正感受到什麼，以及目前正在如何回應"
        case (.directionPathThree, .english):
            return "Reflect on where you are, where you want to go, and how you may move closer"
        case (.directionPathThree, .traditionalChinese):
            return "看見目前的位置、真正想前往的方向，以及可以如何靠近"
        case (.coreClarityFour, .english):
            return "Understand the core issue, what is blocking you, what may help, and the strengths available to you"
        case (.coreClarityFour, .traditionalChinese):
            return "看清問題核心、目前阻礙、可行對策，以及你能運用的優勢"
        case (.twoChoiceFive, .english):
            return "Compare the current energy and possible direction of two choices while reflecting on your own state"
        case (.twoChoiceFive, .traditionalChinese):
            return "比較兩個選項的狀態與可能走向，也看看你目前的內在狀態"
        case (.relationshipFive, .english):
            return "Reflect on you, the other person, and the dynamics currently shaping the relationship"
        case (.relationshipFive, .traditionalChinese):
            return "理解你、對方，以及這段關係目前呈現的互動與可能走向"
        }
    }

    /// One concise recommendation reason (usage spec §16) — reflective,
    /// never "the only correct choice" or a guaranteed outcome.
    func recommendationReason(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.singleCard, .english):
            return "Right now a simple, focused reminder may be what you need most."
        case (.singleCard, .traditionalChinese):
            return "你現在比較需要一個簡單、聚焦的提醒。"
        case (.timelineThree, .english):
            return "You'd like to understand how things reached this point and where they may be heading."
        case (.timelineThree, .traditionalChinese):
            return "你想理解事情如何走到現在，以及接下來可能朝哪個方向發展。"
        case (.actionDirectionThree, .english):
            return "You're mainly looking for a grounded next step and the direction it may support."
        case (.actionDirectionThree, .traditionalChinese):
            return "你現在比較需要一個能落地的下一步，以及這個行動可能帶來的方向。"
        case (.blindSpotThree, .english):
            return "This may be less about an answer and more about noticing what hasn't been seen yet."
        case (.blindSpotThree, .traditionalChinese):
            return "這個問題可能不只需要答案，也適合看看目前有哪些面向還沒有被注意到。"
        case (.holisticCheckInThree, .english):
            return "It may help to first understand your overall state and how to care for yourself today."
        case (.holisticCheckInThree, .traditionalChinese):
            return "你現在比較需要先理解自己的整體狀態，以及今天可以怎麼照顧自己。"
        case (.thinkFeelActThree, .english):
            return "Your thoughts, feelings, and current responses around this may be worth sorting out together."
        case (.thinkFeelActThree, .traditionalChinese):
            return "你對這件事的想法、感受和正在採取的行動之間，可能值得一起整理。"
        case (.directionPathThree, .english):
            return "You already know where you want to go — this looks at where you are and how to move closer."
        case (.directionPathThree, .traditionalChinese):
            return "你已經知道想往哪裡走，這個牌陣適合看看目前的位置與可以如何靠近。"
        case (.coreClarityFour, .english):
            return "This feels like finding what's really stuck, and how you might move forward."
        case (.coreClarityFour, .traditionalChinese):
            return "這個問題比較像是想找出真正卡住的地方，以及你可以怎麼往前走。"
        case (.twoChoiceFive, .english):
            return "You have two clear options — this compares the state and possible direction of each path."
        case (.twoChoiceFive, .traditionalChinese):
            return "你已經有兩個明確選項，這個牌陣適合比較兩條路的狀態與可能走向。"
        case (.relationshipFive, .english):
            return "You'd like to understand this through you, the other person, and how the relationship is unfolding."
        case (.relationshipFive, .traditionalChinese):
            return "你想從你、對方與整段關係的互動，一起理解目前的狀態。"
        }
    }

    /// Spread-specific question guidance (usage spec `Prompt Guidance`).
    func questionGuidance(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.singleCard, .english): return "What would you like a little clarity on right now?"
        case (.singleCard, .traditionalChinese): return "你此刻最想得到什麼提醒？"
        case (.timelineThree, .english): return "What situation would you like to understand over time?"
        case (.timelineThree, .traditionalChinese): return "你想了解哪件事的發展脈絡？"
        case (.actionDirectionThree, .english): return "What situation would you like to take a next step on?"
        case (.actionDirectionThree, .traditionalChinese): return "你想釐清哪件事現在可以怎麼做？"
        case (.blindSpotThree, .english): return "What might you not be seeing clearly in this situation?"
        case (.blindSpotThree, .traditionalChinese): return "這件事裡，有什麼是你可能還沒看見的？"
        case (.holisticCheckInThree, .english): return "How would you like to check in with yourself today?"
        case (.holisticCheckInThree, .traditionalChinese): return "今天想怎麼看看自己的整體狀態？"
        case (.thinkFeelActThree, .english): return "Which situation would you like to reflect on?"
        case (.thinkFeelActThree, .traditionalChinese): return "你想整理哪件事裡的想法、感受與行動？"
        case (.directionPathThree, .english): return "What goal or direction would you like to move toward?"
        case (.directionPathThree, .traditionalChinese): return "你想靠近的方向或目標是什麼？"
        case (.coreClarityFour, .english): return "What situation would you like to understand more clearly?"
        case (.coreClarityFour, .traditionalChinese): return "你想看清哪個問題的核心與突破方向？"
        case (.twoChoiceFive, .english): return "Name the two options you are weighing — the cards reflect each path, not a winner."
        case (.twoChoiceFive, .traditionalChinese): return "寫下你正在衡量的兩個選項；牌會映照兩條路，而不是替你決定。"
        case (.relationshipFive, .english): return "What would you like to understand about this relationship?"
        case (.relationshipFive, .traditionalChinese): return "你想理解這段關係的哪個面向？"
        }
    }

    /// Spread-specific placeholder for the main text field (never one
    /// generic placeholder across spreads).
    func questionPlaceholder(_ l: AppLanguage) -> String {
        switch (self, l) {
        case (.singleCard, .english): return "The thing you'd like a reminder about…"
        case (.singleCard, .traditionalChinese): return "想被提醒的事…"
        case (.timelineThree, .english): return "The situation you'd like to trace…"
        case (.timelineThree, .traditionalChinese): return "想整理發展脈絡的事…"
        case (.actionDirectionThree, .english): return "The situation you'd like to act on…"
        case (.actionDirectionThree, .traditionalChinese): return "想找出下一步的事…"
        case (.blindSpotThree, .english): return "The situation that may hold a blind spot…"
        case (.blindSpotThree, .traditionalChinese): return "想看看盲點的事…"
        case (.holisticCheckInThree, .english): return "Anything on your mind today (optional focus)…"
        case (.holisticCheckInThree, .traditionalChinese): return "今天心裡掛著的事（可簡單寫）…"
        case (.thinkFeelActThree, .english): return "The event you'd like to reflect on…"
        case (.thinkFeelActThree, .traditionalChinese): return "想整理的那件事…"
        case (.directionPathThree, .english): return "The direction or goal on your mind…"
        case (.directionPathThree, .traditionalChinese): return "心裡想靠近的方向…"
        case (.coreClarityFour, .english): return "The situation that feels stuck…"
        case (.coreClarityFour, .traditionalChinese): return "感覺卡住的事…"
        case (.twoChoiceFive, .english): return "What this decision is about…"
        case (.twoChoiceFive, .traditionalChinese): return "這個決定是關於…"
        case (.relationshipFive, .english): return "What you'd like to understand about this relationship…"
        case (.relationshipFive, .traditionalChinese): return "想理解這段關係的哪個面向…"
        }
    }

    /// Two or three selectable example questions per spread (usage
    /// spec `Example Questions`) — reflective, never deterministic.
    func exampleQuestions(_ l: AppLanguage) -> [String] {
        switch (self, l) {
        case (.singleCard, .english):
            return ["What do I most need to notice today?",
                    "What mindset would support me right now?"]
        case (.singleCard, .traditionalChinese):
            return ["我現在最需要看見的是什麼？",
                    "今天我最需要保持什麼心態？"]
        case (.timelineThree, .english):
            return ["How did this situation become what it is, and where may it be heading?",
                    "What pattern from the past deserves my attention now?"]
        case (.timelineThree, .traditionalChinese):
            return ["這件事為什麼會變成現在這樣？接下來可能往哪裡走？",
                    "從過去到現在，有什麼模式值得我看見？"]
        case (.actionDirectionThree, .english):
            return ["What can I realistically do next in this situation?",
                    "What action is available to me now, and what may it support?"]
        case (.actionDirectionThree, .traditionalChinese):
            return ["這件事我現在可以實際做些什麼？",
                    "我目前能採取什麼行動？它可能帶來什麼方向？"]
        case (.blindSpotThree, .english):
            return ["What might I be missing in how I see this?",
                    "What assumption of mine deserves a second look?"]
        case (.blindSpotThree, .traditionalChinese):
            return ["我對這件事的看法，可能忽略了什麼？",
                    "我的哪個假設值得重新想想？"]
        case (.holisticCheckInThree, .english):
            return ["What does my body and mind most need today?",
                    "What kind of care would support me right now?"]
        case (.holisticCheckInThree, .traditionalChinese):
            return ["今天我的身心最需要什麼？",
                    "現在的我，最需要哪一種照顧？"]
        case (.thinkFeelActThree, .english):
            return ["How do my thoughts, feelings, and reactions around this fit together?",
                    "What am I really feeling underneath how I've been responding?"]
        case (.thinkFeelActThree, .traditionalChinese):
            return ["我對這件事的想法、感受和反應，是怎麼連在一起的？",
                    "在我的回應底下，我真正的感受是什麼？"]
        case (.directionPathThree, .english):
            return ["How can I move closer to where I want to be?",
                    "What small step would bring me toward this goal?"]
        case (.directionPathThree, .traditionalChinese):
            return ["我可以怎麼靠近我想去的地方？",
                    "有什麼小小的一步，能讓我更接近這個目標？"]
        case (.coreClarityFour, .english):
            return ["What is really keeping this stuck, and how might I move forward?",
                    "What obstacle and strength am I overlooking here?"]
        case (.coreClarityFour, .traditionalChinese):
            return ["這件事真正卡住的地方是什麼？我可以怎麼往前走？",
                    "我忽略了哪些阻礙與可運用的優勢？"]
        case (.twoChoiceFive, .english):
            return ["I'm weighing two work paths and want to see each clearly",
                    "I'm deciding between two living arrangements"]
        case (.twoChoiceFive, .traditionalChinese):
            return ["我正在比較兩個工作選擇",
                    "我正在決定下一步的生活安排"]
        case (.relationshipFive, .english):
            return ["Where does this relationship stand right now?",
                    "What in our current dynamic deserves a fresh look?",
                    "What direction might this relationship be moving toward?"]
        case (.relationshipFive, .traditionalChinese):
            return ["我和對方目前的關係處於什麼狀態？",
                    "我們目前的互動中，有哪些地方值得我重新理解？",
                    "這段關係接下來可能朝什麼方向發展？"]
        }
    }

    func cardCountLabel(_ l: AppLanguage) -> String {
        let count = TarotSpreadLibrary.definition(for: self).cardCount
        if l == .english {
            return count == 1 ? "1 card" : "\(count) cards"
        }
        return "\(count) 張牌"
    }
}
