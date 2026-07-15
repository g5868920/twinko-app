# TwinkoTalk Meditation Feature Specification
**Status:** Canonical CPO-approved feature specification
**Version:** v1.0
**Target:** iOS-first MVP / V1 launch scope
**Audience:** Product, design, Claude Code, engineering, AI, QA, safety

## 0. Purpose

Twinko Meditation is a context-aware AI companion experience that helps users move from emotional expression or reflection into a short, personalized guided meditation.

```text
Chat helps users express
Tarot helps users reflect
Meditation helps users regulate and integrate
```

```text
Express → Understand → Integrate
```

## 1. Product Positioning

Twinko first understands what the user is going through, then turns that context into a short personalized meditation.

The feature supports:

- Quick Start
- Direct personalized input
- Chat-derived meditation
- Tarot-derived meditation

## 2. MVP Scope

All capabilities below are part of MVP launch scope, even if engineering delivers them in milestones.

The MVP includes:

- Meditation Home / Setup
- Quick Start
- AI-personalized meditation
- Chat-to-Meditation handoff
- Tarot-to-Meditation handoff
- context preview and edit
- context summarization
- emotional-state and desired-outcome extraction
- structured meditation planning
- full script generation
- safety classification
- generated-script validation
- TTS generation
- Meditation Player
- soundscape controls
- pause / resume / end early
- 3-, 5-, and 10-minute sessions
- English and Traditional Chinese
- Completion Reflection
- result write-back to relevant Chat context
- lightweight local completion record
- one canonical Meditation Twinko asset
- one canonical Meditation background
- Quick Start fallback content
- offline and generation fallback behavior

The MVP does not include public social sharing, community, subscriptions, wearables, treatment claims, or live coaching.

## 3. Canonical Entry Points

### 3.1 Meditation Home

Options:

- Create a meditation with Twinko
- Quick Start
- Use recent Chat context
- Use latest Tarot reading

### 3.2 Chat Contextual Offer

Twinko may proactively suggest a meditation when a short grounding or reflective practice may help.

Example:

> It sounds like you’re carrying a lot right now. Would you like me to create a short meditation around what we just talked about?

Actions:

- Start personalized meditation
- Not now

### 3.3 Chat Manual Action

The user may tap `Meditate on this` under a relevant Twinko message.

### 3.4 Tarot Result CTA

The Tarot result screen may include `Turn this guidance into a meditation` after the interpretation synthesis is available.

## 4. Core User Flows

### Quick Start

```text
Meditation Home
→ Choose immediate need
→ Choose duration
→ Confirm session
→ Player
→ Completion Reflection
```

### Personalized Direct Input

```text
Meditation Home
→ Create with Twinko
→ Describe current need
→ Context extraction
→ Context preview
→ Choose duration
→ Generate
→ Player
→ Completion Reflection
```

### Chat-to-Meditation

```text
Chat discussion
→ Twinko suggests meditation or user taps “Meditate on this”
→ User accepts
→ Relevant context is summarized
→ Context Review opens
→ Focus and duration are prefilled
→ User confirms or edits
→ Generate
→ Player
→ Completion Reflection
→ Optional Chat write-back
```

The user must not be asked to repeat accepted Chat context.

### Tarot-to-Meditation

```text
Tarot interpretation
→ User taps “Turn this guidance into a meditation”
→ Question and reading synthesis are summarized
→ Context Review opens
→ Focus and duration are suggested
→ User confirms or edits
→ Generate
→ Player
→ Completion Reflection
```

## 5. Quick Start Themes

Canonical themes:

```text
calm_down
release_anxiety
sleep
self_love
manifest
```

| ID | English | Traditional Chinese |
|---|---|---|
| `calm_down` | Calm Down | 平靜下來 |
| `release_anxiety` | Release Anxiety | 釋放焦慮 |
| `sleep` | Sleep | 準備入睡 |
| `self_love` | Self-Love | 照顧自己 |
| `manifest` | Manifest | 顯化意念 |

Approved durations are 3, 5, and 10 minutes. Default: 5 minutes.

## 6. Canonical Meditation Context

All entry points normalize into one shared model.

```json
{
  "source": "chat",
  "topic": "job interview anxiety",
  "userConcern": "The user feels afraid of failing an upcoming interview.",
  "emotionalState": ["anxious", "self-critical", "mentally tired"],
  "desiredOutcome": ["grounded", "self-trusting", "calm"],
  "guidanceDirection": "Separate preparation from self-worth and return attention to the next manageable step.",
  "tone": "gentle_grounding",
  "durationSeconds": 300,
  "locale": "zh-Hant",
  "avoidances": [
    "Do not promise success.",
    "Do not diagnose anxiety.",
    "Do not repeat private details verbatim."
  ]
}
```

Canonical source values:

```text
direct_input
quick_start
chat
tarot
```

## 7. Context Source Rules

### Direct Input

Use user-entered concern, selected theme, desired outcome, duration, and locale.

### Chat

Use only the minimum relevant context:

- recent emotional topic
- current concern
- desired state
- tone preference
- high-level summary

Do not pass the entire conversation unnecessarily or quote private details verbatim.

### Tarot

Use:

- user question
- spread type
- cards and orientation
- interpretation synthesis
- guidance summary
- optional guidance card

Do not introduce new predictions or treat Tarot as certainty.

## 8. Consent and Context Transparency

Before generation, show a concise focus summary.

Example:

```text
Focus:
Feeling anxious about tomorrow’s interview and wanting to trust yourself.
```

The user can:

- edit the focus
- remove source context
- change duration
- cancel

Do not show the raw transcript.

## 9. Chat Suggestion Logic

Suitable signals include anxiety, overthinking, trouble sleeping, relationship uncertainty, work pressure, self-doubt, overwhelm, or wanting to calm down.

Frequency cap:

- maximum one proactive suggestion per conversation
- if declined, do not proactively ask again in that conversation
- user-triggered `Meditate on this` remains available

## 10. AI Generation Pipeline

```text
Context Extraction
→ Safety Classification
→ Meditation Plan Generation
→ Structured Script Generation
→ Script Validation
→ TTS Generation
→ Playback
```

Each stage must be separable and observable.

## 11. Safety Classification

Standard wellness contexts may proceed, including mild or moderate anxiety, work stress, overthinking, difficulty winding down, relationship uncertainty, and self-doubt.

High-risk contexts must not enter the normal closed-eye meditation flow, including:

- self-harm or suicide intent
- acute psychiatric crisis
- violence threat
- chest pain or breathing emergency
- user driving or operating machinery
- immediate danger
- request to replace treatment or medication
- unsafe breath-holding request

These cases must route to the existing safety response or a safe grounding path.

## 12. Meditation Plan

Generate a structured plan before the full script.

```json
{
  "title": "Returning to Your Own Ground",
  "theme": "release_anxiety",
  "durationSeconds": 300,
  "tone": "gentle_grounding",
  "goal": "Reduce urgency and support self-trust",
  "segments": [
    {"type": "arrival", "targetSeconds": 30},
    {"type": "breathing", "targetSeconds": 50},
    {"type": "acknowledgement", "targetSeconds": 70},
    {"type": "personalized_guidance", "targetSeconds": 110},
    {"type": "closing", "targetSeconds": 40}
  ]
}
```

## 13. Canonical Script Structure

Every session includes:

1. Arrival
2. Breath Regulation
3. Emotional Acknowledgement
4. Personalized Guidance
5. Closing / Re-entry

Breathing must be simple and safe, with no prolonged breath holding or aggressive breathwork.

## 14. Structured Script Model

```json
{
  "sessionId": "med_20260716_001",
  "title": "Returning to Your Own Ground",
  "subtitle": "You do not need every answer right now.",
  "locale": "en",
  "durationSeconds": 300,
  "theme": "release_anxiety",
  "segments": [
    {
      "id": "arrival",
      "type": "arrival",
      "startOffsetSeconds": 0,
      "estimatedDurationSeconds": 30,
      "text": "Find a position that feels steady..."
    },
    {
      "id": "breathing",
      "type": "breathing",
      "startOffsetSeconds": 30,
      "estimatedDurationSeconds": 50,
      "text": "Allow your breath to settle naturally..."
    },
    {
      "id": "acknowledgement",
      "type": "acknowledgement",
      "startOffsetSeconds": 80,
      "estimatedDurationSeconds": 70,
      "text": "There may be a part of you that wants certainty..."
    },
    {
      "id": "guidance",
      "type": "personalized_guidance",
      "startOffsetSeconds": 150,
      "estimatedDurationSeconds": 110,
      "text": "For now, let the unanswered question rest beside you..."
    },
    {
      "id": "closing",
      "type": "closing",
      "startOffsetSeconds": 260,
      "estimatedDurationSeconds": 40,
      "text": "Return to the feeling of your body being supported..."
    }
  ],
  "closingMessage": "You can care about the answer without losing your connection to yourself."
}
```

## 15. Script Validation

Validate before playback:

- schema validity
- required segments
- duration fit
- safe breathing language
- no diagnosis or treatment claims
- no medication guidance
- no Tarot determinism
- no manifestation guarantee
- no harmful instructions
- no excessive private-detail repetition
- no dependency language
- appropriate locale

Failure behavior:

1. regenerate once
2. validate again
3. use a safe fallback if still invalid
4. never play unvalidated content

## 16. TTS and Audio

The MVP includes dynamic TTS in English and Traditional Chinese.

Requirements:

- calm, warm, non-theatrical voice
- stable pace
- no exaggerated acting
- no unrelated spoken branding
- no raw markup spoken aloud

Recommended flow:

```text
Validated Script
→ TTS generation
→ audio cache
→ player
```

Show an honest generating state and do not promise unmeasured generation time.

## 17. Quick Start Fallback

Quick Start must remain available if personalized generation fails.

Fallback combinations must support all launch-visible themes, durations, and locales. Fallback content uses the same structured script schema.

## 18. Soundscapes

Approved soundscapes:

```text
cosmic
rain
ocean
silence
```

Default: `cosmic`.

Narration and ambient sound must be separate layers.

## 19. Meditation Player

Required controls:

- play
- pause
- resume
- remaining time
- progress
- end early
- narration volume
- ambient volume
- soundscape selection
- close / exit confirmation

The player should handle audio interruption and respect Reduce Motion.

## 20. Completion Reflection

Required question:

```text
How do you feel now?
```

Options:

```text
calmer
about_the_same
still_unsettled
```

| ID | English | Traditional Chinese |
|---|---|---|
| `calmer` | Calmer | 比較平靜 |
| `about_the_same` | About the same | 差不多 |
| `still_unsettled` | Still unsettled | 還是有點不安 |

Optional: short note.

Do not shame the user for selecting `still_unsettled`.

## 21. Cross-Feature Write-Back

### Chat

A lightweight context may be stored in the related conversation, for example:

```text
User completed a 5-minute meditation about interview anxiety and reported feeling calmer.
```

Do not inject it into unrelated conversations.

### Tarot

A Tarot-derived session may record that an integration meditation was completed. Do not change or validate the Tarot interpretation.

## 22. Privacy and Data Minimization

The system must:

- use only relevant source context
- summarize before generation
- avoid unnecessary raw transcript transfer
- not expose raw private context in the player
- allow focus editing or removal
- avoid logging generated scripts or sensitive context in analytics

## 23. Localization

Required locales:

```text
en
zh-Hant
```

Rules:

- one locale at a time
- TTS voice matches locale
- context extraction and validation support both locales
- generated copy should sound natural, not mechanically translated

## 24. Canonical Assets

Canonical Twinko asset:

```text
twinko_meditation_calm_v1.png
```

Approved characteristics:

- yellow rounded Twinko star
- no separate arms or legs
- soft smile
- lavender meditation wrap
- lotus details
- transparent background

Canonical background:

```text
bg_meditation_cosmic_calm_v1.png
```

Direction:

- deep blue to lavender gradient
- soft stars
- subtle cloud layers
- central readability
- no baked text, controls, Twinko, or large moon seat

## 25. Architecture Recommendation

```text
Meditation/
├── Models/
│   ├── MeditationContext
│   ├── MeditationPlan
│   ├── MeditationScript
│   ├── MeditationSegment
│   ├── MeditationTheme
│   ├── MeditationSource
│   └── MeditationCompletion
├── Context/
│   ├── ChatMeditationContextAdapter
│   ├── TarotMeditationContextAdapter
│   └── DirectMeditationContextAdapter
├── AI/
│   ├── MeditationContextExtractor
│   ├── MeditationSafetyClassifier
│   ├── MeditationPlanner
│   ├── MeditationScriptGenerator
│   └── MeditationScriptValidator
├── Audio/
│   ├── MeditationTTSProvider
│   ├── MeditationAudioCache
│   ├── MeditationAudioSession
│   └── SoundscapeProvider
├── Data/
│   ├── MeditationRepository
│   ├── QuickStartMeditationProvider
│   └── MeditationSessionStore
├── Views/
│   ├── MeditationHomeView
│   ├── MeditationContextReviewView
│   ├── MeditationGeneratingView
│   ├── MeditationPlayerView
│   └── MeditationCompletionView
└── Integration/
    ├── ChatMeditationHandoff
    └── TarotMeditationHandoff
```

Reuse existing architecture and shared components where practical.

## 26. Internal Delivery Milestones

All are part of MVP launch scope.

### Milestone A — Core Player and Quick Start

- Setup
- Quick Start
- structured scripts
- audio player
- soundscapes
- completion reflection
- one Twinko
- one background

### Milestone B — AI Generation

- context extraction
- safety classification
- plan generation
- script generation
- validation
- TTS
- generation state
- cache
- fallback behavior

### Milestone C — Cross-Feature Intelligence

- Chat proactive suggestion
- Chat manual action
- Chat context handoff
- Tarot result CTA
- Tarot context handoff
- context review / edit
- write-back
- frequency cap

The feature is complete only when A, B, and C are functional.

## 27. Hard Product Rules

The implementation must not:

- treat Meditation as therapy
- claim to diagnose or treat anxiety, depression, trauma, or insomnia
- use Tarot as deterministic truth
- guarantee manifestation outcomes
- generate unsafe breathing instructions
- suggest ordinary Meditation during an acute crisis
- copy raw private Chat content into narration
- ask users to repeat accepted context
- proactively offer Meditation repeatedly in one conversation
- create separate generation pipelines for Chat and Tarot
- add social sharing to MVP
- redesign unrelated screens
- create additional Twinko assets without approval

## 28. Acceptance Criteria

### Entry Points

- [ ] Meditation opens from main navigation
- [ ] Chat can proactively suggest Meditation when appropriate
- [ ] Chat supports `Meditate on this`
- [ ] Tarot supports `Turn this guidance into a meditation`

### Context

- [ ] Direct input creates a valid Meditation Context
- [ ] Chat context is summarized and minimized
- [ ] Tarot context is summarized without deterministic claims
- [ ] Context Review supports edit, removal, duration change, and cancel
- [ ] The user is not asked to repeat accepted context

### AI

- [ ] Safety classification runs before regular generation
- [ ] Meditation Plan is structured
- [ ] Meditation Script is structured
- [ ] Validation runs before playback
- [ ] Invalid content is never played
- [ ] TTS supports English and Traditional Chinese
- [ ] Safe fallback exists

### Player

- [ ] 3-, 5-, and 10-minute sessions work
- [ ] Play, pause, resume, and end early work
- [ ] Remaining time and progress are correct
- [ ] Narration and ambient volume are separate
- [ ] Cosmic, Rain, Ocean, and Silence are supported
- [ ] Audio interruption is handled

### Completion

- [ ] Completion Reflection appears
- [ ] Calmer, About the same, and Still unsettled are supported
- [ ] Result can write back to the relevant Chat context
- [ ] Tarot-derived sessions may record integration completion

### Privacy and Safety

- [ ] Raw transcripts are not unnecessarily passed or displayed
- [ ] Sensitive context is not logged
- [ ] Crisis contexts do not enter ordinary Meditation flow
- [ ] No treatment, diagnosis, Tarot certainty, or manifestation guarantee appears

### Assets

- [ ] `twinko_meditation_calm_v1.png` is used consistently
- [ ] One canonical Meditation background is used
- [ ] No unapproved Twinko variants are added
