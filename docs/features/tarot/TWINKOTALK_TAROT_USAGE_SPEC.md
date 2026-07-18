# TwinkoTalk Tarot Usage Specification

**Status:** Canonical product and future LLM reference  
**Version:** 2.0  
**Target:** iOS-first MVP, expandable to backend-assisted LLM interpretation  
**Languages:** Traditional Chinese + English  
**Scope:** Tarot intent classification, spread selection, question guidance, cross-feature entry, draw rules, result interpretation, Guidance Card behavior, session state, future LLM contracts, periodic readings, and future premium entitlement rules  
**Design dependency:** `DESIGN(3).md` remains the global visual source of truth. This specification defines Tarot product logic and UX behavior; it does not introduce a separate visual language.

---

## 0. Purpose of This Specification

This document is the canonical reference for how Tarot should be used inside TwinkoTalk.

It is intended for:

- product and UX decisions
- Swift implementation
- Claude Code implementation work
- mock-data behavior
- future backend and LLM integration
- spread recommendation
- question rewriting and guidance
- structured Tarot interpretation
- regression testing

### Version 2.0 Additions

- expanded standard spread library with action, blind-spot, daily holistic check-in, thoughts/feelings/actions, and path-forward spreads
- canonical Daily Tarot Check-in behavior
- future Weekly, Monthly, Yearly, and Celtic Cross definitions
- Free + Companion Membership entitlement principles
- future quota, free-trial, no-reroll, and add-on rules

This specification separates three concepts that must not be conflated:

1. **Question domain** — what the user is asking about
2. **User intent** — what kind of clarity the user wants
3. **Tarot spread** — the perspective used to explore the question

A question domain does not map to only one spread.

For example, a relationship question may use:

- one card for a quick reflection
- three cards for progression over time
- four cards for root cause and next steps
- five cards for an explicit A/B decision
- the relationship-specific spread for a holistic view of both people and the relationship dynamic

The spread recommendation must therefore be based primarily on **intent and question structure**, with domain used as an eligibility and context signal.

---

# PART I — Product Principles

## 1. Tarot Product Role

Tarot in TwinkoTalk is a reflective guidance journey, not a deterministic prediction engine.

Its product role is to help the user:

- slow down and articulate a concern
- view a situation from a different perspective
- identify patterns, blockers, strengths, and possible directions
- compare trade-offs without outsourcing the decision
- reflect on relationship dynamics without claiming access to another person's hidden mind
- turn reflection into a small next step

Tarot must not:

- diagnose or treat a condition
- make guaranteed predictions
- tell the user what they must do
- claim factual knowledge of another person's private thoughts
- claim certainty about cheating, destiny, death, pregnancy, legal outcomes, medical outcomes, or financial outcomes
- replace professional medical, legal, financial, or mental-health support

Canonical disclaimer:

- Traditional Chinese: `內容僅供反思與娛樂`
- English: `For reflection and entertainment only`

The disclaimer must appear on every completed result page.

---

## 2. Core Recommendation Principle

The recommendation model is many-to-many.

```text
Domain × Intent × Question Structure × Required Inputs
→ Recommended Spread
```

The recommendation must not be implemented as:

```text
Relationship → Relationship Spread
Career → Core Clarity
```

Instead, the system should determine:

1. What topic is being discussed?
2. What kind of clarity does the user want?
3. Does the question contain explicit choices or a time dimension?
4. Which spreads are eligible?
5. Which spread is the best match?
6. Which one or two alternatives are still reasonable?
7. What information is missing before the reading can begin?

The user may always change the recommended spread before drawing.

---

## 3. Direct Entry vs. Contextual Entry

### 3.1 Direct Tarot Entry

When the user opens Tarot directly from Explore or another generic entry point, the flow is **intent-first**.

The user should not need to understand Tarot terminology or choose by card count.

Canonical flow:

```text
Tarot Landing
→ Choose what kind of clarity is needed
→ Recommended spread and short explanation
→ Spread-specific question guidance
→ Setup review
→ Preparation / shuffle / draw
→ Reveal
→ Result
→ Optional Guidance Card
```

### 3.2 Contextual Entry from Chat or Home

When the user enters Tarot from Chat or Home, the flow is **context-led**.

Canonical behavior:

- Twinko may recommend a spread based on available context.
- A draft question may be prefilled.
- Option A and Option B may be prefilled only when both are explicitly known.
- The user can edit the question and change the spread.
- The system must never automatically start drawing.
- The user must explicitly confirm the setup.
- Close returns to the logical source.

Contextual entry may bypass the generic intent-selection page and open directly into recommended setup/review.

---

# PART II — Canonical Taxonomy

## 4. Question Domains

Domains provide subject context and eligibility. They do not determine the spread by themselves.

Canonical domain identifiers:

```swift
enum TarotDomain: String, Codable {
    case romanticRelationship
    case careerWork
    case moneyFinance
    case familyFriendship
    case selfGrowth
    case wellbeingGeneral
    case generalLife
    case other
}
```

### 4.1 Romantic Relationship

Includes:

- dating
- romantic partners
- marriage
- ambiguity or situationships
- ex-partners
- romantic reconciliation
- romantic attraction
- intimacy and emotional partnership

Only this domain is eligible for the relationship-specific spread.

### 4.2 Career and Work

Includes:

- job search
- promotion
- team dynamics
- project direction
- role changes
- leadership decisions
- entrepreneurship

### 4.3 Money and Finance

Includes:

- budgeting
- financial habits
- spending decisions
- financial priorities
- career-related financial trade-offs

Tarot copy must not present investment, tax, legal, or financial outcomes as facts.

### 4.4 Family and Friendship

Includes:

- family relationships
- friendships
- peer conflict
- social boundaries

The relationship-specific spread is not used by default for this domain in MVP because its naming and positions are designed for romantic or intimate partnerships.

### 4.5 Self-Growth

Includes:

- identity
- motivation
- confidence
- habits
- emotional patterns
- life direction

### 4.6 Wellbeing and General State

Includes:

- feeling stuck
- emotional overload
- lack of direction
- need for rest or reflection

Tarot must not diagnose mental-health conditions.

### 4.7 General Life / Other

Used when the topic is broad, mixed, or not clearly categorized.

---

## 5. User Intents

Intent is the primary recommendation signal.

Canonical identifiers:

```swift
enum TarotIntent: String, Codable {
    case quickReflection
    case understandProgression
    case identifyCoreIssue
    case understandObstacle
    case findPossibleApproach
    case compareExplicitOptions
    case understandRelationshipDynamics
    case understandBothSides
    case explorePossibleDirection
    case generalGuidance
    case takeNextAction
    case identifyBlindSpot
    case holisticDailyCheckIn
    case alignThoughtFeelingAction
    case moveTowardGoal
    case periodicGuidance
    case deepComplexReading
}
```

The implementation may group closely related intents internally, but the product meaning must be preserved.

### 5.1 Quick Reflection

The user wants:

- one message
- one thing to notice
- a concise prompt
- a small amount of guidance

Best fit: One Card.

### 5.2 Understand Progression

The user wants to understand:

- how the situation developed
- what is happening now
- what direction it may be moving toward

Best fit: Three Cards.

### 5.3 Identify Core Issue / Obstacle / Approach

The user wants to understand:

- what the real problem is
- what is blocking progress
- what can be done
- what strengths or resources are available

Best fit: Four-Card Core Clarity.

### 5.4 Compare Explicit Options

The user has two concrete choices and wants to compare them.

Hard requirement:

- Option A exists
- Option B exists

Best fit: Five-Card Two-Choice Reflection.

### 5.5 Understand Relationship Dynamics / Both Sides

The user wants a holistic view of:

- their own state
- their feelings or attitude
- the other person's presented state
- the other person's presented attitude
- the relationship's possible direction

Best fit: Five-Card Relationship Insight.

This intent is not synonymous with all romantic questions.

---

## 6. Question Structure Signals

Question structure should be assessed independently from domain.

Canonical structure identifiers:

```swift
enum TarotQuestionStructure: String, Codable {
    case openGeneral
    case timeProgression
    case rootCauseAndAction
    case explicitTwoChoice
    case holisticRelationship
    case actionOriented
    case blindSpotReflection
    case holisticCheckIn
    case thoughtFeelingAction
    case goalDirection
    case periodicReview
    case complexMultiFactor
}
```

### 6.1 Open General

Examples:

- What do I need to notice right now?
- What might support me today?

Best fit: One Card.

### 6.2 Time Progression

Signals include:

- how did this become this way
- past / present / future
- what happens next
- how has this changed over time

Best fit: Three Cards.

### 6.3 Root Cause and Action

Signals include:

- why am I stuck
- what is blocking me
- what am I not seeing
- what can I do
- what strength can I use

Best fit: Four-Card Core Clarity.

### 6.4 Explicit Two Choice

Signals include:

- A or B
- stay or leave
- accept or decline
- continue or stop
- choose person A or person B

Best fit: Five-Card Two-Choice Reflection.

### 6.5 Holistic Relationship

Signals include:

- what is the current dynamic between us
- how are both of us showing up in this relationship
- what is this relationship teaching me
- what is the possible direction of this relationship

Best fit: Five-Card Relationship Insight.

---

# PART III — Canonical Spread Definitions

## 7. Spread Model

Canonical identifiers:

```swift
enum TarotSpreadID: String, Codable {
    // Standard / MVP-ready library
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

    // Future premium / periodic library — specified now, not in current MVP
    case weeklyGuidanceSeven
    case monthlyGuidanceFour
    case yearlyGuidanceTwelve
    case celticCrossTen
}
```

A spread definition should contain:

```swift
struct TarotSpreadDefinition: Codable, Identifiable {
    let id: TarotSpreadID
    let cardCount: Int
    let supportedDomains: Set<TarotDomain>
    let supportedIntents: Set<TarotIntent>
    let requiredInputs: Set<TarotInputRequirement>
    let positionIDs: [TarotPositionID]
    let supportsGuidanceCard: Bool
    let bestFor: [TarotUseCase]
    let notIdealFor: [TarotUseCase]
}
```

Localized title, purpose, labels, and examples should remain in localization resources rather than being persisted as data values.

---

## 8. One Card — One-Card Reflection

### 8.1 Identifier

`singleCard`

### 8.2 Titles

- Traditional Chinese: `一張牌提醒`
- English: `One-Card Reflection`

### 8.3 Purpose

- Traditional Chinese: `快速看看此刻最值得留意的訊息`
- English: `A quick reflection on what may matter most right now`

### 8.4 Position

1. `此刻的提醒` / `A Message for This Moment`

### 8.5 Supported Domains

All domains.

### 8.6 Best For

- quick reflection
- daily prompt
- one simple focus
- users who do not want a long reading
- broad or still-forming questions

### 8.7 Not Ideal For

- comparing two explicit choices
- understanding a complex relationship dynamic
- investigating several causes and actions
- detailed progression over time

### 8.8 Required Input

- one general question

### 8.9 Prompt Guidance

Traditional Chinese:

`你此刻最想得到什麼提醒？`

English:

`What would you like a little clarity on right now?`

### 8.10 Example Questions

Relationship:

- `我今天在這段關係中最需要留意什麼？`
- `我現在面對這段感情時，需要提醒自己什麼？`

Career:

- `我目前工作上最值得留意的是什麼？`
- `今天在求職上，我最需要保持什麼心態？`

Self-growth:

- `我現在最需要看見的是什麼？`

---

## 9. Three Cards — Past, Present & Possible Direction

### 9.1 Identifier

`timelineThree`

### 9.2 Titles

- Traditional Chinese: `事情的發展脈絡`
- English: `Past, Present & Possible Direction`

### 9.3 Purpose

- Traditional Chinese: `從過去、現在與可能走向，整理事情如何發展到這裡`
- English: `Explore how the past and present may be shaping what comes next`

### 9.4 Positions

1. `過去` / `Past`
2. `現在` / `Present`
3. `可能走向` / `Possible Direction`

Use `可能走向`, not guaranteed future or outcome.

### 9.5 Supported Domains

All domains.

### 9.6 Best For

- understanding progression
- reviewing how a situation developed
- reflecting on what may come next
- identifying continuity or change

### 9.7 Not Ideal For

- explicit A/B comparison
- detailed blocker/action analysis
- holistic two-person relationship overview

### 9.8 Required Input

- one general question

### 9.9 Prompt Guidance

Traditional Chinese:

`你想了解哪件事的發展脈絡？`

English:

`What situation would you like to understand over time?`

### 9.10 Example Questions

Relationship:

- `我們的關係為什麼會變成現在這樣？接下來可能往哪裡走？`
- `這段感情從過去到現在，有什麼模式值得我看見？`

Career:

- `我目前的求職狀況是如何發展到這裡的？接下來可能有什麼方向？`

Money:

- `我最近的財務壓力是如何形成的？目前最值得留意什麼？`

---

## 9A. Three Cards — Situation, Action & Possible Direction

### Identifier

`actionDirectionThree`

### Titles

- Traditional Chinese: `現況・行動・可能走向`
- English: `Situation, Action & Possible Direction`

### Purpose

- Traditional Chinese: `整理現在的狀態、可以採取的下一步，以及行動後可能形成的方向`
- English: `Reflect on the current situation, an available next action, and the direction that action may support`

### Positions

1. `目前現況` / `Current Situation`
2. `可以採取的行動` / `Available Action`
3. `可能走向` / `Possible Direction`

### Supported Domains

All domains.

### Best For

- the user wants a practical next step
- the question is action-oriented rather than diagnostic
- the user understands the issue but is unsure what to do next
- Chat or Home wants to recommend a small follow-through action

### Not Ideal For

- identifying a complex root cause
- comparing two explicit choices
- a holistic relationship overview
- questions requiring many external and internal factors

### Prompt Guidance

- Traditional Chinese: `你想釐清哪件事現在可以怎麼做？`
- English: `What situation would you like to take a next step on?`

### Recommendation Distinction

Recommend this spread when the primary need is **what to do next**.
Recommend `coreClarityFour` when the primary need is **why the user is stuck and what resources are available**.

---

## 9B. Three Cards — Blind Spot Reflection

### Identifier

`blindSpotThree`

### Titles

- Traditional Chinese: `看見盲點`
- English: `Blind Spot Reflection`

### Purpose

- Traditional Chinese: `整理你目前的理解、尚未看見的面向，以及可以重新思考的方向`
- English: `Reflect on your current understanding, an unseen perspective, and a possible reframe`

### Positions

1. `我目前的理解` / `My Current Understanding`
2. `尚未看見的面向` / `An Unseen Perspective`
3. `可以重新思考的方向` / `A Possible Reframe`

Do not label the second card as objective truth. Tarot may reveal another perspective, not verified facts.

### Supported Domains

All domains.

### Best For

- repeated patterns
- assumptions about a person or situation
- feeling that something important is being missed
- conflicting interpretations
- relationship or career blind spots

### Prompt Guidance

- Traditional Chinese: `這件事裡，有什麼是你可能還沒看見的？`
- English: `What might you not be seeing clearly in this situation?`

---

## 9C. Three Cards — Body, Mind & Inner Care

### Identifier

`holisticCheckInThree`

### Titles

- Traditional Chinese: `身・心・內在`
- English: `Body, Mind & Inner Care`

### Purpose

- Traditional Chinese: `感受身體、情緒與思緒，以及今天最需要的內在照顧`
- English: `Check in with the body, thoughts and emotions, and the care you may need today`

### Positions

1. `身體現在的感受` / `What My Body Is Signaling`
2. `情緒與思緒的狀態` / `My Thoughts and Feelings`
3. `內在最需要的照顧` / `The Care I May Need`

### Supported Domains

Primarily wellbeing, self-growth, and general-life reflection. It may also be used when relationship or work stress is affecting the user's overall state.

### Best For

- Daily Tarot Check-in
- emotional self-awareness
- noticing physical and mental load
- choosing a supportive next action
- contextual handoff to Chat, Meditation, or Music

### Daily Product Preset

This is the canonical spread for `Daily Tarot Check-in`.

- available at most once per local calendar day
- free for all users
- completion creates a result that can be revisited for the same day
- do not encourage repeated redraws during the same day
- Home may recommend it after emotional check-in when relevant
- Home should replace the invitation with `查看今日指引` / `View Today's Guidance` after completion
- no anxiety-inducing streak pressure or mandatory daily task language

The Daily Check-in product preset is an entry context around this spread, not a duplicate spread identifier.

---

## 9D. Three Cards — Thoughts, Feelings & Actions

### Identifier

`thinkFeelActThree`

### Titles

- Traditional Chinese: `想法・感受・行動`
- English: `Thoughts, Feelings & Actions`

### Purpose

- Traditional Chinese: `理解你如何看待一件事、真正感受到什麼，以及目前正在如何回應`
- English: `Explore how you understand a situation, what you feel, and how you are currently responding`

### Positions

1. `我怎麼理解這件事` / `What I Think`
2. `我真正感受到什麼` / `What I Feel`
3. `我正在如何回應` / `How I Am Responding`

### Supported Domains

All domains.

### Best For

- a specific event or relationship situation
- inner conflict
- misalignment between thoughts, feelings, and behavior
- Chat-led self-reflection

### Distinction from Daily Check-in

This spread is event-focused. `holisticCheckInThree` is whole-person and daily-state focused.
Do not present both as identical Daily Tarot options.

---

## 9E. Three Cards — Direction Path

### Identifier

`directionPathThree`

### Titles

- Traditional Chinese: `方向之路`
- English: `Path Forward`

### Purpose

- Traditional Chinese: `看見目前的位置、真正想前往的方向，以及可以如何靠近`
- English: `Reflect on where you are, where you want to go, and how you may move closer`

### Positions

1. `目前所在的位置` / `Where I Am Now`
2. `真正想前往的方向` / `Where I Want to Go`
3. `可以如何靠近` / `How I May Move Closer`

### Supported Domains

All domains.

### Best For

- career transitions
- relationship transitions
- personal goals
- habit change
- life-direction questions with a recognizable desired state

### Recommendation Distinction

Recommend this spread when the user has a desired direction or target state.
Recommend `actionDirectionThree` when the focus is one immediate action within a current situation.

---

## 10. Four Cards — Core Clarity

### 10.1 Identifier

`coreClarityFour`

### 10.2 Titles

- Traditional Chinese: `直指核心`
- English: `Core Clarity`

### 10.3 Purpose

- Traditional Chinese: `看清問題核心、目前阻礙、可行對策，以及你能運用的優勢`
- English: `Understand the core issue, what is blocking you, what may help, and the strengths available to you`

### 10.4 Positions

1. `問題核心` / `Core Issue`
2. `目前阻礙` / `Current Obstacle`
3. `可行對策` / `Possible Approach`
4. `可運用的優勢` / `Available Strength`

`可運用的優勢` may represent:

- internal strengths
- skills
- experience
- social support
- external resources
- existing conditions the user has overlooked

### 10.5 Supported Domains

All domains.

### 10.6 Best For

- feeling stuck
- identifying the real issue
- seeing blockers
- finding practical reflection points
- identifying strengths and resources

### 10.7 Not Ideal For

- a very quick one-message reading
- explicit A/B comparison
- a holistic view of both people in a romantic relationship

### 10.8 Required Input

- one general question

### 10.9 Prompt Guidance

Traditional Chinese:

`你想看清哪個問題的核心與突破方向？`

English:

`What situation would you like to understand more clearly?`

### 10.10 Example Questions

Relationship:

- `這段關係真正卡住的地方是什麼？我可以怎麼面對？`
- `我在這段感情中忽略了什麼阻礙與可運用的優勢？`

Career:

- `我求職一直卡住的核心原因是什麼？可以怎麼往前走？`
- `這個專案目前真正的阻礙是什麼？我有哪些資源可以運用？`

Self-growth:

- `我為什麼一直無法開始行動？目前最可行的突破方向是什麼？`

---

## 11. Five Cards — Two-Choice Reflection

### 11.1 Identifier

`twoChoiceFive`

### 11.2 Titles

- Traditional Chinese: `二選一抉擇`
- English: `Two-Choice Reflection`

### 11.3 Purpose

- Traditional Chinese: `比較兩個選項的狀態與可能走向，也看看你目前的內在狀態`
- English: `Compare the current energy and possible direction of two choices while reflecting on your own state`

### 11.4 Positions

1. `選項 A 的狀態` / `Option A — Current State`
2. `選項 B 的狀態` / `Option B — Current State`
3. `選擇 A 的可能走向` / `Option A — Possible Direction`
4. `選擇 B 的可能走向` / `Option B — Possible Direction`
5. `你目前的狀態` / `Your Current State`

### 11.5 Supported Domains

All domains, when explicit A and B options exist.

### 11.6 Best For

- choosing between two jobs
- staying or leaving
- accepting or declining
- comparing two courses of action
- comparing two romantic options
- deciding between two locations, plans, or commitments

### 11.7 Not Ideal For

- vague confusion without two explicit options
- more than two options
- seeking a guaranteed winner
- asking the app to make the decision

### 11.8 Required Inputs

- decision context
- Option A
- Option B

Canonical field labels:

Traditional Chinese:

- `你正在考慮什麼？`
- `選項 A`
- `選項 B`

English:

- `What decision are you considering?`
- `Option A`
- `Option B`

### 11.9 Validation

The user cannot continue if Option A or Option B is empty after trimming whitespace.

Use inline validation.

Do not auto-invent missing options.

### 11.10 Example Questions

Relationship:

- Context: `我正在考慮兩段不同的感情方向`
- Option A: `重新嘗試和前任相處`
- Option B: `往新的關係前進`

Career:

- Context: `我正在比較兩個工作選擇`
- Option A: `留在目前公司`
- Option B: `接受新的工作邀請`

General life:

- Context: `我正在決定下一步的生活安排`
- Option A: `留在台北`
- Option B: `搬到另一個城市`

### 11.11 Interpretation Rule

The result must:

- explain each option neutrally
- identify trade-offs
- reflect the user's current state
- avoid declaring a winner
- avoid `你應該選 A` or `你應該選 B`

### 11.12 Spread Layout

```text
Option A side:
Card 1 — current state
Card 3 — possible direction

Option B side:
Card 2 — current state
Card 4 — possible direction

Centered below:
Card 5 — user's current state
```

On compact iPhones, the interpretation page may stack sections vertically while preserving position meaning.

---

## 12. Five Cards — Relationship Insight

### 12.1 Identifier

`relationshipFive`

### 12.2 Titles

- Traditional Chinese: `感情萬用`
- English: `Relationship Insight`

### 12.3 Purpose

- Traditional Chinese: `理解你、對方，以及這段關係目前呈現的互動與可能走向`
- English: `Reflect on you, the other person, and the dynamics currently shaping the relationship`

### 12.4 Positions

1. `我的狀態` / `My Current State`
2. `我對對方的感情態度` / `My Feelings and Attitude`
3. `對方呈現的狀態` / `The Other Person's Presented State`
4. `對方在關係中呈現的態度` / `Their Presented Attitude in the Relationship`
5. `關係的可能走向` / `Possible Relationship Direction`

Use `呈現的狀態` and `呈現的態度` to avoid claiming factual access to another person's private mind.

### 12.5 Supported Domains

- romantic relationship only

### 12.6 Best For

- holistic romantic relationship overview
- understanding how both people are showing up
- reflecting on current relationship dynamics
- seeing the interaction pattern and possible direction

### 12.7 Not Ideal For

- work, money, general life, or unrelated topics
- a simple quick reminder
- explicit A/B choice
- a specific root-cause problem where Core Clarity is a better fit
- questions demanding certainty about another person's hidden thoughts

### 12.8 Required Inputs

- one relationship question

Optional:

- person's name or label

Do not require personally identifying information.

### 12.9 Prompt Guidance

Traditional Chinese:

`你想理解這段關係的哪個面向？`

English:

`What would you like to understand about this relationship?`

### 12.10 Example Questions

- `我和對方目前的關係處於什麼狀態？`
- `我在這段關係裡需要看見什麼？`
- `我們目前的互動中，有哪些地方值得我重新理解？`
- `這段關係接下來可能朝什麼方向發展？`

### 12.11 Interpretation Rule

The result may discuss:

- perceived interaction patterns
- emotional possibilities
- communication gaps
- boundaries
- the user's own needs
- what may deserve reflection

The result must not state as fact:

- that the other person definitely loves or dislikes the user
- that the other person is cheating
- that the other person will definitely contact the user
- that the relationship is destined
- that the app knows the other person's private intentions

### 12.12 Spread Layout

```text
My side:
Card 1 — my state
Card 2 — my feelings and attitude

Other person's side:
Card 3 — their presented state
Card 4 — their presented attitude

Centered below:
Card 5 — possible relationship direction
```

---

# PART IV — Spread Recommendation Contract

## 13. Eligibility Rules

### 13.1 General-Purpose Spreads

The following spreads are eligible for all domains when their intent requirements match:

- `singleCard`
- `timelineThree`
- `actionDirectionThree`
- `blindSpotThree`
- `thinkFeelActThree`
- `directionPathThree`
- `coreClarityFour`

`holisticCheckInThree` is primarily intended for wellbeing, self-growth, and general state, but may be used when another domain is affecting the user's whole-person state.

### 13.2 Two-Choice Spread

`twoChoiceFive` is eligible for all domains only when:

- exactly two meaningful options exist
- both options can be clearly named

### 13.3 Relationship Spread

`relationshipFive` is eligible only when:

- domain is romantic relationship
- the user wants a holistic view of both people and the relationship dynamic

It must not be recommended merely because the topic is romantic.

---

## 14. Recommendation Priority Rules

Use the following order of evaluation.

### Rule 1 — Explicit A/B Overrides General Domain Preference

If the user has two explicit options and wants to compare them:

- recommend `twoChoiceFive`

This applies to relationship, career, money, and general-life questions.

### Rule 2 — Holistic Romantic Dynamic

If the domain is romantic relationship and the user wants to understand both people and the relationship as a whole:

- recommend `relationshipFive`

### Rule 3 — Daily or Whole-Person Check-in

If the user wants to understand their current body, emotions, thoughts, and inner care needs:

- recommend `holisticCheckInThree`

This is also the canonical Daily Tarot Check-in spread.

### Rule 4 — Thoughts, Feelings, and Behavior Alignment

If the user wants to understand how their thinking, feelings, and current behavior relate around a specific event:

- recommend `thinkFeelActThree`

### Rule 5 — Blind Spot

If the user asks what they may be missing, assuming, or failing to see:

- recommend `blindSpotThree`

### Rule 6 — Goal or Desired Direction

If the user knows where they want to go but does not know how to move closer:

- recommend `directionPathThree`

### Rule 7 — Immediate Next Action

If the user mainly wants to know what action is available now and what direction it may support:

- recommend `actionDirectionThree`

### Rule 8 — Root Cause, Blocker, and Action

If the user asks what is really wrong, what is blocking them, or what they can do:

- recommend `coreClarityFour`

This applies across all domains, including romance.

### Rule 9 — Time Progression

If the user wants to understand past, present, and possible direction:

- recommend `timelineThree`

### Rule 10 — Quick or Broad Reflection

If the user wants one concise message, has a broad question, or has not yet formed a detailed question:

- recommend `singleCard`

### Rule 11 — Alternatives

Every recommendation may include up to two eligible alternatives.

Alternatives should be meaningfully different perspectives, not random spreads.

Example:

User question:

`這段關係真正卡住的地方是什麼？`

Recommended:

- Core Clarity

Eligible alternatives:

- Relationship Insight
- Past, Present & Possible Direction

---

## 15. Recommendation Matrix

| User need / question structure | Primary recommendation | Typical alternatives | Eligibility notes |
|---|---|---|---|
| One concise message or broad early-stage question | One Card | Timeline; Blind Spot | All domains |
| Understand how a situation developed over time | Timeline Three | Core Clarity; Blind Spot | All domains |
| Decide what action is available now | Situation, Action & Possible Direction | Core Clarity; Path Forward | All domains |
| See an assumption or missing perspective | Blind Spot Reflection | Core Clarity; Thoughts/Feelings/Actions | All domains |
| Check in with whole-person state and self-care needs | Body, Mind & Inner Care | One Card; Thoughts/Feelings/Actions | Primarily wellbeing/self-growth; may include stress from other domains |
| Understand thought, emotion, and behavior around one event | Thoughts, Feelings & Actions | Blind Spot; Core Clarity | All domains |
| Move toward a known goal or desired state | Path Forward | Situation/Action/Direction; Core Clarity | All domains |
| Identify the core issue, blocker, approach, and strengths | Core Clarity | Blind Spot; Situation/Action/Direction | All domains |
| Compare exactly two explicit options | Two-Choice | Core Clarity; Path Forward | All domains when A and B are known |
| Understand both people and the romantic relationship dynamic | Relationship Insight | Timeline; Core Clarity | Romantic relationship only |

Domain is an eligibility and context signal. It does not force one spread.
Relationship questions may use every general-purpose spread when the intent matches.

---

## 16. Recommendation Reason Copy

The system should explain why a spread is recommended in one concise sentence.

Examples:

### Core Clarity

`這個問題比較像是想找出真正卡住的地方，以及你可以怎麼往前走。`

### Three Cards

`你想理解事情如何走到現在，以及接下來可能朝哪個方向發展。`

### Situation, Action & Possible Direction

`你現在比較需要一個能落地的下一步，以及這個行動可能帶來的方向。`

### Blind Spot Reflection

`這個問題可能不只需要答案，也適合看看目前有哪些面向還沒有被注意到。`

### Body, Mind & Inner Care

`你現在比較需要先理解自己的整體狀態，以及今天可以怎麼照顧自己。`

### Thoughts, Feelings & Actions

`你對這件事的想法、感受和正在採取的行動之間，可能值得一起整理。`

### Path Forward

`你已經知道想往哪裡走，這個牌陣適合看看目前的位置與可以如何靠近。`

### Two-Choice

`你已經有兩個明確選項，這個牌陣適合比較兩條路的狀態與可能走向。`

### Relationship Insight

`你想從你、對方與整段關係的互動，一起理解目前的狀態。`

### One Card

`你現在比較需要一個簡單、聚焦的提醒。`

Avoid claims such as:

- `Twinko knows this is your destiny`
- `This is definitely the correct spread`

---

# PART V — Question Guidance and Rewriting

## 17. Question Quality Principles

The system should encourage questions that are:

- open-ended
- reflective
- user-centered
- specific enough to understand
- focused on patterns, choices, needs, and possible actions

Avoid encouraging questions that demand:

- absolute certainty
- guaranteed prediction
- surveillance of another person
- medical diagnosis
- legal conclusions
- financial certainty

Canonical helper copy:

Traditional Chinese:

`比較適合開放式問題，例如「我需要看見什麼？」或「我可以如何理解這件事？」`

English:

`Open-ended questions usually work best, such as “What might I need to see?” or “How can I understand this situation more clearly?”`

---

## 18. Question Rewrite Rules

Future LLM question rewriting may:

- clarify the user's topic
- convert yes/no questions into reflective questions
- preserve the user's intent
- remove deterministic or invasive framing
- add missing context without inventing facts
- adapt the question to the selected spread

It must not:

- change the user's topic
- add unconfirmed personal details
- invent Option A or Option B
- claim another person's internal state as fact
- turn the question into medical, legal, or financial advice

### 18.1 Example — Yes/No Relationship Question

User:

`他到底愛不愛我？`

Recommended rewrite for Relationship Insight:

`我可以如何理解對方目前在這段關係中呈現的態度，以及我們之間的互動？`

Alternative rewrite for Core Clarity:

`這段關係目前真正卡住的地方是什麼？我需要看見什麼？`

### 18.2 Example — Guaranteed Future

User:

`我什麼時候一定會找到工作？`

Rewrite:

`我目前求職的狀態是如何發展到這裡的？接下來可能有哪些方向值得留意？`

### 18.3 Example — Missing A/B

User:

`我不知道該怎麼選。`

Do not recommend Two-Choice until the app asks:

- `你正在比較哪兩個選項？`

### 18.4 Example — Overly Broad

User:

`我的人生會怎樣？`

Rewrite options:

- One Card: `我現在最需要留意的人生主題是什麼？`
- Core Clarity: `我目前在人生方向上真正卡住的地方是什麼？`

---

# PART VI — UX Flow Specification

## 19. Direct Tarot Landing

Primary question:

- Traditional Chinese: `這次想從哪個角度看看？`
- English: `What would you like clarity on?`

Do not present all spread templates as an undifferentiated card-count directory.
Use intent-oriented entry groups, then recommend the most suitable spread and up to two alternatives.

Canonical intent entries:

1. `快速獲得一個提醒` / `A quick reflection`
2. `看看事情如何發展` / `Understand how things developed`
3. `看見可能忽略的面向` / `See what I may be missing`
4. `找出下一步與方向` / `Find a next step or path forward`
5. `理解自己的狀態` / `Understand myself more clearly`
6. `比較兩個選擇` / `Compare two choices`
7. `理解一段感情` / `Understand a romantic relationship`

Intent-to-spread recommendation may include:

- quick reflection → `singleCard`
- progression → `timelineThree`
- blind spot → `blindSpotThree`
- immediate action → `actionDirectionThree`
- root cause / blocker → `coreClarityFour`
- desired direction → `directionPathThree`
- whole-person check-in → `holisticCheckInThree`
- specific event self-awareness → `thinkFeelActThree`
- explicit A/B → `twoChoiceFive`
- holistic romantic dynamic → `relationshipFive`

Card count is supporting information, not the primary decision language.
The UI may group closely related templates behind one intent entry to prevent overload.

---

## 20. Recommended Spread Setup

The setup screen must show:

- `Twinko 建議` / `Twinko Suggests`
- selected spread title
- one-sentence recommendation reason
- short purpose
- number of cards
- compact position preview
- spread-specific question guidance
- required input fields
- `更換牌陣` / `Change Spread`
- primary continue CTA

The user can always change spread before drawing.

---

## 21. Change Spread Behavior

The spread selector shows all eligible spreads with:

- title
- short purpose
- card count
- concise position summary

Changing spread before drawing:

- does not require destructive confirmation
- updates question guidance
- updates required fields
- updates preview positions
- preserves compatible general question text where reasonable
- clears incompatible A/B fields when leaving Two-Choice
- does not auto-start the reading

Changing spread after cards have been drawn:

- must start a new reading through the existing new-reading behavior
- must not mutate the current reading

---

## 22. Spread-Specific Inputs

### 22.1 General One-, Three-, and Four-Card Spreads

Required:

- one multiline general-question field

This includes Single Card, Timeline, Situation/Action/Direction, Blind Spot, Body/Mind/Inner Care, Thoughts/Feelings/Actions, Direction Path, and Core Clarity.

### 22.2 Two-Choice

Required:

- decision context
- Option A
- Option B

### 22.3 Relationship Insight

Required:

- one multiline relationship-question field

Optional:

- person's name or label

### 22.4 Common Input Behavior

- preserve text during ordinary back navigation
- keyboard must not cover active fields
- trim whitespace for validation
- examples may prefill but never auto-submit
- no mixed-language placeholders

---

## 23. Setup Review

Before any preparation, shuffle, or draw, show a review state containing:

- source question
- selected spread
- spread purpose
- card-position meanings
- Option A / Option B where relevant
- relationship label where relevant
- edit-question action
- change-spread action
- primary `開始抽牌` / `Begin Reading` CTA

The user must explicitly confirm.

---

## 24. Immersive Reading Flow

Canonical flow:

```text
Setup Review
→ Preparing ritual state
→ Shuffle
→ Draw
→ Reveal
→ Result
→ Optional Guidance Card
```

Shared bottom navigation is hidden throughout the immersive flow.

Leaving the flow restores top-level navigation.

---

## 25. Cross-Feature Entry from Chat

Chat may recommend Tarot in addition to Meditation.

Appropriate Chat signals:

- user wants one quick reflection
- user wants to understand a situation's progression
- user wants to see a blind spot
- user wants an immediate next action
- user wants to understand thoughts, feelings, and behavior around an event
- user has a desired direction but is unsure how to move closer
- user feels stuck and wants to identify the real issue
- user is choosing between two explicit options
- user wants to understand a romantic relationship dynamic

A Tarot recommendation should:

- appear after a conversational response
- not interrupt the conversation
- not automatically navigate
- contain one primary Tarot CTA
- preserve an option to continue chatting

Example:

`聽起來你不是沒有努力，而是還沒看清真正卡住的位置。要不要用四張牌，從核心、阻礙、對策和你的優勢一起看看？`

Primary CTA:

`用四張牌看看`

Secondary:

`先繼續聊聊`

### 25.1 Chat Handoff

When the CTA is tapped:

- open recommended Tarot setup/review
- prefill an editable draft question where available
- prefill A/B only if both are explicitly known
- allow spread change
- never auto-draw
- Close returns to the originating Chat context

Do not pass full raw Chat history into Tarot.

Use a minimal structured summary.

---

## 26. Cross-Feature Entry from Home

Home may recommend Tarot when it is the most relevant next action.

Examples:

- `迷惘` + `獲得方向` → Core Clarity or Direction Path depending on whether a desired destination is known
- emotional check-in completed + desire for deeper self-care → Body, Mind & Inner Care
- general reflection → One Card
- desire for one practical next action → Situation, Action & Possible Direction
- known explicit A/B → Two-Choice
- known romantic relationship context and holistic intent → Relationship Insight

Home must not fabricate unknown details.

When context is insufficient:

- prefill a generic editable question
- do not invent Option A or Option B
- do not pretend Twinko knows the relationship context

Close returns to Home.

---

# PART VII — Reading Session and Card Rules

## 27. Canonical Reading Session

One reading must have one source of truth.

Recommended model:

```swift
struct TarotReadingSession: Codable, Identifiable {
    let id: UUID
    var source: TarotEntrySource
    var spreadID: TarotSpreadID
    var domain: TarotDomain?
    var intent: TarotIntent?
    var question: String
    var decisionContext: String?
    var optionA: String?
    var optionB: String?
    var relationshipPersonLabel: String?
    var drawnCards: [DrawnTarotCard]
    var revealedPositionIDs: Set<TarotPositionID>
    var guidanceCard: DrawnTarotCard?
    var phase: TarotReadingPhase
}
```

Exact naming may follow the repository architecture.

### 27.1 State Rules

- spread selection must not live only in temporary view-local state
- drawn cards must not regenerate on view recreation
- orientation must not change after draw
- revealed cards remain face-up within the same session
- back navigation must not reset cards
- starting a new reading is the explicit reset boundary
- do not maintain competing session sources of truth

---

## 28. Draw Rules

All spreads support:

- upright cards
- reversed cards
- random draw independent from animation
- unique cards within one reading

Requirements:

- each spread position receives exactly one card
- position order matches the spread definition
- no duplicate cards in the spread
- card orientation is assigned once and preserved
- shuffle animation does not determine card identity

---

## 29. Optional Guidance Card

Every standard spread result page offers one optional Guidance Card.
Future Weekly, Monthly, and Celtic Cross readings follow the same rule.

Supported standard spreads:

- One Card
- Timeline Three
- Situation, Action & Possible Direction
- Blind Spot Reflection
- Body, Mind & Inner Care
- Thoughts, Feelings & Actions
- Path Forward
- Core Clarity
- Two-Choice
- Relationship Insight

Future premium spreads:

- Weekly Guidance: 7 base cards + optional 1 Guidance Card
- Monthly Guidance: 4 base cards + optional 1 Guidance Card
- Celtic Cross: 10 base cards + optional 1 Guidance Card
- Yearly Guidance is the exception: its thirteenth `Annual Core Guidance` card fulfills the +1 guidance role. Do not offer a fourteenth card.

Canonical CTA:

- Traditional Chinese: `再抽一張指引牌`
- English: `Draw a Guidance Card`

Supporting copy:

- Traditional Chinese: `看看這次解讀還想提醒你什麼`
- English: `See what additional guidance may support this reading`

### 29.1 Guidance Card Rules

- optional only, except the Yearly Annual Core Guidance step defined in §49
- never auto-drawn
- exactly one per reading
- drawn from the remaining deck
- must not duplicate any spread card
- orientation is assigned once
- remains face-up after reveal
- persists during back navigation
- shown in a distinct `指引牌` / `Guidance Card` section
- not treated as another numbered base-spread position
- included in the reading entitlement and never charged separately

After drawing:

- remove or disable the draw CTA
- do not allow replacement or redraw

The Guidance Card interpretation should:

- synthesize the full reading
- offer one supportive reflection or possible next step
- not override the spread
- not become a command

---

# PART VIII — Result and Interpretation Contract

## 30. Result Page Hierarchy

Every completed result page must show:

1. Original question
2. Spread title
3. Spread purpose or compact position summary
4. Each card and orientation
5. Position title
6. Position-specific interpretation
7. Integrated reading summary
8. Optional Guidance Card section
9. Reflection prompt or gentle next step
10. Disclaimer

Avoid creating a stack of unrelated white cards.

The result must remain readable and visually coherent with the Tarot environment.

---

## 31. Interpretation Tone

Twinko Tarot interpretation should be:

- warm
- reflective
- concise but meaningful
- emotionally present
- non-controlling
- non-medical
- non-deterministic

Preferred phrases:

- `可能`
- `也許`
- `可以留意`
- `這張牌邀請你思考`
- `這可能反映`
- `你可以把它當作一個觀察角度`

Avoid:

- `一定`
- `注定`
- `他就是這樣想`
- `你必須`
- `這件事肯定會發生`

---

## 32. Position-Specific Interpretation

Each card interpretation should include:

- card identity
- upright or reversed orientation
- general symbolic meaning relevant to the position
- position-specific interpretation
- one concise reflection point

Do not use a generic card meaning without connecting it to the assigned position.

---

## 33. Integrated Summary

The integrated summary should:

- synthesize all cards
- identify patterns or tensions
- connect the reading back to the original question
- avoid repeating every card paragraph
- offer a reflective next step

For Two-Choice:

- compare trade-offs neutrally
- reflect the user's current state
- do not name a winner

For Relationship Insight:

- distinguish perceived dynamics from verified facts
- focus on communication, boundaries, and user reflection
- avoid factual claims about the other person

---

## 34. Reflection Prompt and Next Step

Every interpretation may end with one reflection prompt or one gentle action.

Examples:

- `哪一張牌最像你現在真正的感受？`
- `你願意先做哪個最小的改變？`
- `這兩個選項中，哪一個更符合你現在重視的價值？`
- `你有哪些感受需要被更直接地說出來？`

Do not overload the result page with multiple action plans.

---

# PART IX — Future LLM Reference

## 35. Role of the LLM

The LLM may perform:

- domain classification
- intent classification
- question-structure classification
- spread recommendation within product rules
- alternative spread suggestions
- question rewriting
- missing-field detection
- spread-specific interpretation
- integrated summary
- Guidance Card synthesis

The LLM must not define product rules independently.

The product layer remains responsible for:

- eligible spread validation
- required-field validation
- no-duplicate-card enforcement
- state ownership
- routing
- localization identifiers
- session reset boundaries
- safety constraints

---

## 36. Recommendation LLM Input

Recommended structured input:

```json
{
  "source": "chat",
  "locale": "zh-Hant",
  "user_text": "我不知道要留在目前公司，還是接受新的工作邀請",
  "context_summary": "使用者正在比較兩個工作選擇",
  "available_spread_ids": [
    "singleCard",
    "timelineThree",
    "coreClarityFour",
    "twoChoiceFive"
  ]
}
```

Do not send unnecessary full conversation history.

---

## 37. Recommendation LLM Output

Recommended structured output:

```json
{
  "domain": "careerWork",
  "intent": "compareExplicitOptions",
  "question_structure": "explicitTwoChoice",
  "recommended_spread_id": "twoChoiceFive",
  "alternative_spread_ids": [
    "coreClarityFour"
  ],
  "confidence": 0.94,
  "recommendation_reason": "使用者正在比較兩個明確工作選項，適合從兩條路的狀態與可能走向進行反思。",
  "draft_question": "我正在比較留在目前公司與接受新工作邀請這兩個選擇。",
  "decision_context": "比較兩個工作機會",
  "option_a": "留在目前公司",
  "option_b": "接受新的工作邀請",
  "missing_fields": []
}
```

### 37.1 Output Validation

The app must validate:

- recommended spread is in the allowed list
- relationship spread is only used for eligible domain
- Two-Choice contains both Option A and Option B
- alternatives are eligible
- missing fields are explicitly requested before continuing

The app must not trust LLM output blindly.

---

## 38. Interpretation LLM Input

Recommended input:

```json
{
  "locale": "zh-Hant",
  "spread_id": "coreClarityFour",
  "question": "我目前求職一直卡住的核心原因是什麼？",
  "positions": [
    {
      "position_id": "coreIssue",
      "card_id": "...",
      "orientation": "upright"
    },
    {
      "position_id": "currentObstacle",
      "card_id": "...",
      "orientation": "reversed"
    }
  ],
  "guidance_card": null
}
```

The backend should provide canonical card metadata rather than asking the model to infer it from image assets.

---

## 39. Interpretation LLM Output

Recommended output shape:

```json
{
  "position_interpretations": [
    {
      "position_id": "coreIssue",
      "title": "問題核心",
      "interpretation": "...",
      "reflection_prompt": "..."
    }
  ],
  "integrated_summary": "...",
  "gentle_next_step": "...",
  "safety_notes": [],
  "disclaimer_key": "tarot.disclaimer"
}
```

For a Guidance Card, append:

```json
{
  "guidance_interpretation": {
    "interpretation": "...",
    "supportive_reflection": "..."
  }
}
```

---

## 40. LLM Safety Constraints

The system prompt or server-side policy must instruct the model to:

- use reflective and probabilistic language
- avoid guaranteed predictions
- avoid medical, legal, and financial conclusions
- avoid claims about another person's private mind
- avoid telling the user which decision they must make
- preserve user agency
- encourage direct communication where appropriate
- provide the canonical disclaimer

If the user requests harmful certainty, the model should gently reframe the question rather than comply literally.

---

# PART X — Localization, Accessibility, and Visual Rules

## 41. Localization

Support Traditional Chinese and English in parallel.

Localize:

- spread titles
- spread purposes
- intent entries
- position labels
- recommendation reasons
- prompts
- examples
- field labels
- validation
- CTA labels
- result section labels
- Guidance Card copy
- disclaimer

Persist canonical identifiers, not localized display strings.

Do not allow mixed-language screens.

English must be natural, not literal translation.

---

## 42. Accessibility

- minimum tap target: 44 × 44 pt
- support Dynamic Type where practical
- prevent text clipping
- provide accessibility labels for icon-only controls
- do not communicate selected spread by color alone
- maintain readable contrast over illustrated backgrounds
- preserve iOS swipe-back where compatible
- support Reduce Motion

Under Reduce Motion:

- disable repeated float and ritual loops
- replace nonessential movement with fade or cross-dissolve
- preserve required reveal action and comprehension

---

## 43. Visual Direction

All Tarot UI must inherit the canonical Twinko visual system:

- soft atmospheric 3D / polished 2.5D
- mystical but gentle
- purple, plum, deep blue, and restrained warm gold
- soft architecture and celestial atmosphere
- hierarchical glass
- readable result surfaces
- restrained motion

Do not:

- use generic iOS grouped lists as the primary structure
- reproduce external website artwork or composition
- create new permanent low-quality raster assets
- create dense stacks of unrelated white cards
- introduce a separate Tarot design language

---

# PART XI — Navigation and State

## 44. Navigation Rules

### Direct Entry

```text
Explore / Tarot entry
→ Intent selection
→ Recommended setup
→ Setup review
→ Immersive reading
→ Result
```

### Chat Entry

```text
Chat recommendation
→ Recommended setup/review
→ Immersive reading
→ Result
```

Close returns to Chat.

### Home Entry

```text
Home recommendation
→ Recommended setup/review
→ Immersive reading
→ Result
```

Close returns to Home.

### General Rules

- immersive Tarot hides shared bottom navigation
- leaving restores top-level navigation
- Back returns to the previous Tarot step
- Close exits to the logical source
- explicit `回到首頁` routes directly to Home
- do not create duplicate `NavigationStack`s
- revealed cards stay face-up during same-session back navigation

---

# PART XII — Future Premium and Periodic Reading Specification

## 45. Commercial Model Principle

TwinkoTalk uses a **Free + Companion Membership** model rather than assigning a separate pay-per-reading price to every spread.

The commercial model must remain configurable and must not be hardcoded into view logic.
Use entitlement and quota models that can be changed through backend or remote configuration later.

The Home screen remains a companion experience, not a storefront. Premium invitations must be contextual, frequency-capped, and visually secondary to the user's immediate emotional needs.

## 46. Access Classes

Recommended canonical access classes:

```swift
enum TarotAccessClass: String, Codable {
    case freeStandard
    case freeLifetimeTrial
    case premiumIncluded
    case premiumQuota
    case paidAddOn
}
```

A spread definition may contain future access metadata equivalent to:

```swift
struct TarotAccessPolicy: Codable {
    let accessClass: TarotAccessClass
    let freeLifetimeTrialCount: Int
    let includedPremiumQuota: Int?
    let quotaPeriod: TarotQuotaPeriod?
    let allowsPaidAddOnAfterQuota: Bool
    let allowsRollover: Bool
}
```

Do not persist prices inside `TarotSpreadDefinition`.
Pricing belongs to a separate commerce configuration.

## 47. Future Weekly Guidance — 7 + 1

### Identifier

`weeklyGuidanceSeven`

### Status

Future premium feature. Defined for reference only; not part of the current MVP implementation.

### Base Positions — 7 Cards

1. `本週整體能量` / `Overall Energy`
2. `感情與關係` / `Love & Relationships`
3. `事業與行動` / `Career & Action`
4. `財務與資源` / `Money & Resources`
5. `本週主要挑戰` / `Key Challenge`
6. `可以運用的機會或支持` / `Opportunity or Support`
7. `本週行動焦點` / `Weekly Focus`

### Optional +1

One optional Guidance Card:

- `本週指引` / `Weekly Guidance`
- drawn from the remaining deck
- no duplicate card
- only one per weekly reading

Maximum cards: 8.

### Access Policy

- free user: one lifetime trial reading
- premium user: one reading per local calendar week
- no quota rollover
- no redraw within the same week
- after completion, the same week's result is revisitable
- using the lifetime trial during a week does not grant a second reading after upgrading during that same week

Recommended week boundary: Monday 00:00 through Sunday 23:59 in the user's effective local timezone.

### Home Entry

Home may surface Weekly Guidance near the beginning of a new week, but:

- it must be dismissible
- it must not remain the primary Home CTA every day
- after completion, show `查看本週指引` / `View This Week's Guidance`
- free users who already used the lifetime trial may see a restrained Premium invitation, not a repeated paywall interruption

## 48. Future Monthly Guidance — 4 + 1

### Identifier

`monthlyGuidanceFour`

### Status

Future premium feature. Not part of the current MVP implementation.

### Base Positions — 4 Cards

1. `本月整體` / `Overall Month`
2. `感情與關係` / `Love & Relationships`
3. `事業與行動` / `Career & Action`
4. `財務與資源` / `Money & Resources`

### Optional +1

One optional Guidance Card:

- `本月指引` / `Monthly Guidance`
- no duplicate card
- only one per monthly reading

Maximum cards: 5.

### Access Policy

- premium only
- one reading per local calendar month
- no quota rollover
- no redraw during the same month
- completed result remains revisitable

### Home Entry

Home may surface Monthly Guidance during a limited early-month window.
It must not appear every day for the entire month.
After completion, replace the invitation with a result entry.

## 49. Future Yearly Guidance — 12 + 1

### Identifier

`yearlyGuidanceTwelve`

### Status

Future seasonal premium feature. Not part of the current MVP implementation.

### Base Positions — 12 Cards

One card for each calendar month:

1. January
2. February
3. March
4. April
5. May
6. June
7. July
8. August
9. September
10. October
11. November
12. December

Localize month names according to the active language and locale.

### Final +1 Annual Core Guidance

The thirteenth card is:

- `年度核心指引` / `Annual Core Guidance`

It is revealed after the twelve monthly cards and serves as the annual Guidance Card.
Do not offer an additional fourteenth Guidance Card.

Total cards: 13.

### Result Structure

The result must contain:

1. annual core guidance
2. twelve-month timeline
3. four LLM synthesis sections derived from the complete reading:
   - `整體` / `Overall`
   - `感情` / `Love & Relationships`
   - `事業` / `Career`
   - `財運` / `Money & Resources`
4. important turning points or recurring themes
5. reflective next steps
6. disclaimer

The four themes are interpretation/report sections, not four additional cards.

### Access Policy

- premium only
- one reading per local calendar year
- no quota rollover
- no redraw during the same year
- completed result remains revisitable throughout the year

### Home Entry

Yearly Guidance is a seasonal campaign entry, not a permanent Home module.
Recommended invitation window may include late December through January and may be configured later.

## 50. Future Celtic Cross — 10 + 1

### Identifier

`celticCrossTen`

### Status

Future advanced premium feature. Not part of the current MVP implementation.

### Canonical Positions — 10 Cards

1. `核心現況` / `Present Core Situation`
2. `當前挑戰` / `Crossing Challenge`
3. `深層基礎` / `Underlying Foundation`
4. `過去影響` / `Past Influence`
5. `有意識的目標或期待` / `Conscious Aim`
6. `近期可能發展` / `Near-Term Development`
7. `自己的立場` / `Self Position`
8. `外部環境與影響` / `External Environment`
9. `希望與擔憂` / `Hopes and Concerns`
10. `綜合可能走向` / `Integrated Possible Direction`

This position order is canonical for TwinkoTalk. Do not allow the LLM or UI to substitute a different Celtic Cross ordering.

### Optional +1

One optional Guidance Card:

- `深度指引` / `Deep Reading Guidance`
- no duplicate card
- only one per reading

Maximum cards: 11.

### Best For

- complex, multi-factor, long-running questions
- situations involving both internal and external forces
- users explicitly requesting a deep reading

### Not Ideal For

- quick reflection
- simple A/B decisions
- daily or weekly routine use
- repeated reading of the same unresolved question

### Access Policy

- free user: one lifetime trial reading
- premium user: one included Celtic Cross reading per subscription billing period as the launch hypothesis
- no quota rollover
- additional Celtic Cross readings after the included premium quota may be purchased as a separate add-on
- add-on price remains TBD and must be commerce-configurable
- completing the free lifetime trial does not consume a later premium-period allowance after the user subscribes, except that the same active reading cannot be redrawn

The included premium quota should remain remotely configurable so the business may test one or more included readings without changing Tarot UX code.

## 51. Entitlement Consumption and Period Rules

### Consumption Boundary

An entitlement is consumed when the base spread draw is committed and the selected cards are locked into the reading session.
Opening setup, editing a question, or viewing the paywall does not consume quota.

### Interrupted Sessions

- an interrupted committed session must be resumable
- resuming does not consume a second entitlement
- the app must not silently reroll cards after interruption

### Period Keys

Use stable account-level period keys based on the user's effective timezone:

- Daily: local calendar date
- Weekly: Monday-based local calendar week
- Monthly: local calendar month
- Yearly: local calendar year
- Premium Celtic quota: subscription billing period

Timezone behavior must be backend-authoritative when production entitlements are implemented.

### No Reroll and No Rollover

- periodic reading quota does not roll over
- a completed weekly, monthly, or yearly reading cannot be redrawn for the same period
- the result remains available to revisit
- starting a new session must not bypass period limits

### Guidance Card

The single Guidance Card is included in the reading entitlement.
It is never charged separately.

## 52. Premium UX Guardrails

- do not place prices directly on Home recommendation cards unless the user enters the purchase flow
- clearly distinguish `首次免費` / `First Reading Free` from recurring entitlement
- clearly show when the next weekly, monthly, yearly, or premium quota becomes available
- do not use countdown pressure, false scarcity, or shame-based copy
- do not obscure that additional Celtic Cross readings may require an add-on after the included quota
- do not block access to previously completed results after subscription expiration
- premium status and quota must come from one entitlement source of truth
- do not duplicate entitlement logic across Home, Tarot, and paywall views

## 53. Future Implementation Boundary

The Weekly, Monthly, Yearly, and Celtic Cross definitions are canonical product references only.
Current MVP work must not implement:

- premium paywalls
- purchase flows
- StoreKit products
- subscription entitlement services
- periodic quotas
- paid add-ons
- Home campaigns for these future readings
- LLM reports for these spreads

When implementation is approved later, build one narrow vertical slice first and reuse centralized entitlement and reading-session infrastructure.

---

# PART XIII — Explicit MVP Scope and Future Scope

## 54. MVP / Prototype Scope

The product and UX should support:

- ten MVP-ready spread definitions
- intent-first direct entry
- the expanded standard spread library: Single Card, Timeline, Situation/Action/Direction, Blind Spot, Body/Mind/Inner Care, Thoughts/Feelings/Actions, Direction Path, Core Clarity, Two-Choice, and Relationship Insight
- Daily Tarot Check-in using `holisticCheckInThree`
- spread change before drawing
- spread-specific question guidance
- structured Two-Choice fields
- Chat and Home structured handoff
- mock or deterministic recommendation paths
- upright and reversed cards
- no duplicate cards
- one optional Guidance Card
- result hierarchy and disclaimer
- session state preservation

The MVP may use mock interpretation content and deterministic recommendation triggers.

---

## 55. Future Scope

Not required merely because it is defined here:

- production LLM recommendation
- production LLM interpretation
- Tarot history
- saved readings
- saved Guidance Cards
- memory integration
- journal integration
- analytics and insights
- personalized long-term patterns
- voice narration
- music integration
- backend prompt management
- Weekly Guidance
- Monthly Guidance
- Yearly Guidance
- Celtic Cross
- premium entitlement and quota enforcement
- paid Celtic Cross add-ons

These should be implemented only through an explicitly approved vertical slice.

---

# PART XIV — Canonical Acceptance Rules

## 56. Product Acceptance

A Tarot implementation is correct only when:

1. Users choose the kind of clarity they need rather than card count alone.
2. Spread recommendation is based on intent and question structure.
3. Relationship questions may use all eligible general-purpose spreads.
4. Relationship Insight is specialized, not the default for all romantic questions.
5. Non-romantic questions do not use Relationship Insight.
6. Immediate-action, root-cause, goal-path, blind-spot, whole-person check-in, and event self-awareness intents remain distinguishable.
7. Daily Tarot Check-in uses `holisticCheckInThree` and is not duplicated as another spread.
8. Two-Choice requires explicit A and B options.
9. Users can change spread before drawing.
10. Questions are guided according to spread purpose.
11. Chat and Home handoffs remain editable.
12. No contextual entry auto-starts drawing.
13. Cards do not duplicate within a reading.
14. Guidance Card does not duplicate spread cards.
15. Revealed state persists during same-session navigation.
16. Results remain reflective and non-deterministic.
17. The disclaimer is visible.
18. English and Traditional Chinese do not mix.
19. Existing approved card assets and Tarot visual language are preserved.
20. Future premium definitions do not silently enter current MVP scope.
21. Premium and quota logic, when implemented, uses one entitlement source of truth.
22. Weekly, Monthly, and Yearly readings cannot be redrawn during the same active period.
23. Previously completed results remain accessible after entitlement changes.

---

# PART XV — Reference Summary

## 57. Fast Recommendation Guide

| User need | Recommended spread |
|---|---|
| One quick message | One Card |
| Understand past, present, and possible direction | Timeline Three |
| Decide one available next action | Situation, Action & Possible Direction |
| See an assumption or missing perspective | Blind Spot Reflection |
| Check in with body, thoughts/emotions, and inner care | Body, Mind & Inner Care |
| Understand thoughts, feelings, and behavior around one event | Thoughts, Feelings & Actions |
| Move from the current state toward a desired direction | Path Forward |
| Find the core issue, blocker, approach, and strength | Core Clarity |
| Compare two explicit options | Two-Choice |
| Understand both people and the romantic relationship dynamic | Relationship Insight |
| Weekly premium guidance | Weekly Guidance Seven |
| Monthly premium guidance | Monthly Guidance Four |
| Annual premium guidance | Yearly Guidance Twelve + Annual Core Guidance |
| Deep, complex multi-factor reading | Celtic Cross Ten |

## 58. Key Guardrail

> The question topic tells Twinko what the situation is about.  
> The user's intent tells Twinko which spread is most useful.

## 59. Final Product Rule

> Twinko recommends a perspective, not an answer.  
> The user keeps control of the question, the spread, and the decision.
