# TwinkoTalk Meditation Screen Specification

**Status:** Canonical CPO-approved UI specification  
**Version:** v1.0  
**Target:** iOS-first MVP / V1 launch scope  
**Audience:** Product, design, Claude Code, engineering, QA  
**Dependencies:**
- `DESIGN.md`
- `TWINKOTALK_MEDITATION_FEATURE_SPEC_V1.md`
- Approved `twinko_meditation_calm_v1.png`
- Approved `bg_meditation_cosmic_calm_v1.png`

---

# 0. Purpose

This document defines the screen architecture, information hierarchy, interaction rules, states, transitions, and cross-feature handoffs for TwinkoTalk Meditation.

The experience must feel:

> **Calm, context-aware, personal, and unmistakably Twinko.**

The user should be able to move from an emotional need to a meditation with minimal friction, while still understanding what context Twinko is using.

---

# 1. Screen Inventory

The MVP includes:

1. Meditation Home
2. Personalized Input
3. Context Review
4. Generating State
5. Meditation Player
6. Completion Reflection
7. Chat Meditation Offer
8. Chat “Meditate on this” action
9. Tarot Meditation CTA
10. Error / fallback / safety states

---

# 2. Global Visual Direction

Use:

- deep blue to lavender cosmic background
- soft stars and subtle cloud layers
- canonical `twinko_meditation_calm_v1.png`
- soft ivory text
- restrained lavender and gold accents
- rounded, quiet surfaces
- low visual noise

Avoid:

- humanized Twinko limbs
- bright candy gradients
- oversized marketing headlines
- dense dashboards
- too many simultaneous glowing controls
- large decorative moons that compete with content
- heavy glassmorphism that reduces readability

---

# 3. Screen 1 — Meditation Home

## 3.1 Goal

Help the user choose between:

- AI-personalized meditation
- Quick Start
- recent Chat context
- latest Tarot reading

The user should understand the main value within a few seconds.

## 3.2 Recommended hierarchy

```text
Navigation header
Twinko hero
Primary personalized CTA
Recent context shortcuts
Quick Start themes
Duration selector
Begin / Continue
```

## 3.3 Hero

Content:

- canonical Meditation Twinko
- short title
- supportive subtitle

Recommended copy:

### English

**What do you need right now?**  
Twinko can create a meditation for what you’re going through.

### Traditional Chinese

**你現在最需要什麼？**  
Twinko 可以根據你正在經歷的事，陪你做一段專屬冥想。

Do not use a large campaign-style title.

## 3.4 Primary CTA

Primary button:

```text
Create a meditation with Twinko
讓 Twinko 為我客製冥想
```

This enters Personalized Input.

## 3.5 Recent context shortcuts

Display only when relevant context exists.

Possible cards:

```text
Use recent Chat
Use latest Tarot reading
```

Each card should show a short summary, not raw content.

Example:

```text
Recent Chat
Feeling nervous about tomorrow’s interview
```

Example:

```text
Latest Tarot
Returning attention to your own boundaries
```

Actions:

- tap card
- open Context Review
- prefill duration and focus

Do not show these cards when no eligible context exists.

## 3.6 Quick Start section

Show the five approved themes:

- Calm Down
- Release Anxiety
- Sleep
- Self-Love
- Manifest

Recommended presentation:

- horizontal cards or a compact two-column grid
- one selected state at a time
- no second page required

## 3.7 Duration selection

Options:

- 3 minutes
- 5 minutes
- 10 minutes

Default:

- 5 minutes

Selection should be visible but secondary to the theme.

## 3.8 Quick Start CTA behavior

If theme and duration are selected:

- tap Begin
- load validated quick-start script
- open Player

If a personalized shortcut is selected:

- tap Continue
- open Context Review

---

# 4. Screen 2 — Personalized Input

## 4.1 Goal

Let the user describe what they need without turning the experience into another long Chat flow.

## 4.2 Layout

```text
Back
Title
Helper text
Text input
Optional theme suggestions
Duration
Continue
```

## 4.3 Copy

### English

**What would you like this meditation to support?**

Example placeholder:

```text
I’m feeling overwhelmed about work and want to feel more grounded.
```

### Traditional Chinese

**你希望這段冥想陪你面對什麼？**

Placeholder:

```text
我最近對工作很焦慮，希望可以安定下來。
```

## 4.4 Input behavior

- multiline input
- reasonable character limit
- do not force a long explanation
- allow voice dictation through native keyboard behavior
- preserve input if navigation is interrupted

## 4.5 Suggested chips

Optional quick chips:

- Calm down
- Sleep better
- Let go
- Trust myself
- Feel supported

These supplement text input, not replace it.

## 4.6 Continue behavior

On Continue:

- create a draft direct-input context
- run context extraction
- open Context Review

If extraction fails:

- keep user text
- allow retry
- allow manual focus editing

---

# 5. Screen 3 — Context Review

## 5.1 Goal

Show the user what Twinko understood and what will be used.

This is the trust and consent checkpoint.

## 5.2 Required content

- source label
- concise focus summary
- suggested emotional goal
- selected duration
- optional theme
- Edit focus
- Remove source context
- Generate meditation

## 5.3 Source labels

Examples:

```text
Based on your recent Chat
Based on your Tarot reading
Based on what you shared
Quick Start
```

## 5.4 Focus summary card

Example:

```text
Focus
Feeling anxious about tomorrow’s interview and wanting to trust yourself.
```

Rules:

- 1–3 short sentences
- no raw transcript
- no names unless necessary
- no unnecessary private details

## 5.5 Edit behavior

Tap Edit:

- show inline text field or compact sheet
- user may rewrite the focus
- regenerate only after confirmation

## 5.6 Remove source context

For Chat or Tarot-derived sessions:

- user may remove source context
- keep only manually edited focus
- do not lose selected duration

## 5.7 Duration

Options remain editable:

- 3
- 5
- 10 minutes

## 5.8 Primary CTA

```text
Create my meditation
開始生成專屬冥想
```

On tap:

- run safety classification
- if eligible, open Generating State
- if high-risk, route to safe support state

---

# 6. Screen 4 — Generating State

## 6.1 Goal

Provide an honest, calm waiting experience while:

- plan is generated
- script is generated
- script is validated
- TTS is generated

## 6.2 Visual composition

- canonical Meditation Twinko
- subtle breathing animation
- short status copy
- optional step indicator
- cancel action

## 6.3 Recommended copy

### English

**Twinko is creating a meditation for what you’re going through…**

### Traditional Chinese

**Twinko 正在根據你現在的狀態，準備一段專屬冥想⋯**

## 6.4 Status steps

Optional progress states:

```text
Understanding your focus
Creating your meditation
Preparing Twinko’s voice
Almost ready
```

Do not show fake percentages unless real progress is measurable.

## 6.5 Cancel

Allow cancellation.

On cancel:

- return to Context Review
- preserve focus and duration
- stop pending generation if technically possible

## 6.6 Failure

If generation fails:

- show retry
- offer validated Quick Start fallback
- do not discard focus
- explain clearly without technical jargon

---

# 7. Screen 5 — Meditation Player

## 7.1 Goal

Deliver a calm, low-distraction guided experience.

## 7.2 Layout

```text
Close / End
Session title
Supportive subtitle
Meditation Twinko
Progress ring / remaining time
Play / Pause
Sound controls
Optional transcript toggle
```

## 7.3 Header

- compact close button
- session title
- optional context label

Avoid large marketing-style titles.

## 7.4 Twinko

Use `twinko_meditation_calm_v1.png`.

Recommended behavior:

- gentle scale animation
- subtle glow change
- 4–6 second breathing cycle
- no lip sync required
- no body-part animation

Respect Reduce Motion.

## 7.5 Time display

Show:

- remaining time
- progress ring or progress bar

The remaining time must be accurate to the audio session.

## 7.6 Core controls

Required:

- play
- pause
- resume
- end session

Optional:

- rewind 15 seconds only if audio architecture already supports it cleanly

Do not overload with media-player controls.

## 7.7 Sound controls

Provide:

- soundscape selector
- narration volume
- ambient volume
- silence option

Approved soundscapes:

- Cosmic
- Rain
- Ocean
- Silence

Use a compact bottom sheet rather than permanent sliders on the main screen if the screen becomes crowded.

## 7.8 Transcript

Optional MVP control:

- Show transcript / Hide transcript

If included:

- show current segment only or a calm scrolling transcript
- do not turn the player into a reading screen
- keep narration primary

## 7.9 End early

Tap close or End:

- show confirmation sheet

Copy:

```text
End this meditation?
You can return whenever you’re ready.
```

Actions:

- Continue meditation
- End session

If ended intentionally:

- show Completion Reflection with `endedEarly = true`
- do not label it as failure

## 7.10 Interruption behavior

On phone call or audio interruption:

- pause safely
- preserve progress
- resume only after user action or existing app policy

---

# 8. Screen 6 — Completion Reflection

## 8.1 Goal

Close the emotional loop without making the user perform extra work.

## 8.2 Layout

```text
Twinko
Completion message
Duration completed
How do you feel now?
Mood options
Optional note
Done
```

## 8.3 Copy

### English

**You made a little space for yourself.**

### Traditional Chinese

**你剛剛為自己留了一點空間。**

## 8.4 Mood options

- Calmer
- About the same
- Still unsettled

All options must receive neutral, supportive treatment.

Do not use green / gray / red judgment colors.

## 8.5 Optional note

Optional prompt:

```text
Anything you want to remember from this moment?
```

This is not a full journal.

## 8.6 Follow-up message

Use the generated `closingMessage`.

Example:

```text
You can care about the answer without losing your connection to yourself.
```

## 8.7 Done behavior

On Done:

- save lightweight completion record
- write back only to related Chat context if applicable
- optionally mark Tarot integration completion
- return to prior source or Meditation Home

Recommended return behavior:

- Chat source → return to Chat
- Tarot source → return to Tarot result
- Meditation Home source → return to Meditation Home

---

# 9. Chat Meditation Offer

## 9.1 Trigger placement

Twinko may show a contextual offer after a relevant response.

Recommended component:

```text
Would you like me to create a short meditation around this?
[Start meditation] [Not now]
```

## 9.2 Rules

- show once per conversation proactively
- do not show during acute crisis flow
- do not interrupt every emotional message
- preserve conversation position

## 9.3 Accept behavior

On accept:

- summarize relevant context
- open Context Review directly
- do not ask the user to restate the issue

## 9.4 Decline behavior

On decline:

- dismiss quietly
- do not ask again proactively in that conversation

---

# 10. Chat “Meditate on this” Action

## 10.1 Placement

Recommended under eligible Twinko messages:

```text
Meditate on this
```

Use a compact contextual action.

## 10.2 Eligibility

Show when:

- message contains reflection or emotional guidance
- context is suitable for Meditation
- not in high-risk state

## 10.3 Behavior

- use current message plus minimal relevant context
- open Context Review
- prefill suggested focus and duration

---

# 11. Tarot Meditation CTA

## 11.1 Placement

After interpretation synthesis.

Recommended label:

```text
Turn this guidance into a meditation
把這份指引化成一段冥想
```

## 11.2 Priority

Secondary CTA.

Do not replace or overpower the existing main Tarot result action.

## 11.3 Handoff

Pass:

- question
- spread
- cards and orientations
- synthesis
- guidance direction
- optional guidance card

Then open Context Review.

---

# 12. Safety Support State

## 12.1 When used

If context classification indicates acute risk or ordinary closed-eye Meditation is inappropriate.

## 12.2 UI behavior

Do not show the normal Generating State.

Show:

- calm direct message
- immediate support options
- safe grounding option if appropriate
- return to Chat
- contact trusted person / emergency support guidance according to the app’s safety system

## 12.3 Important

Meditation is not the primary response to immediate danger.

---

# 13. Error and Fallback States

## 13.1 Context extraction error

Show:

- preserved user text
- edit manually
- retry
- use Quick Start

## 13.2 Script generation error

Show:

- retry
- validated fallback session
- preserve theme and duration

## 13.3 TTS error

Show:

- retry voice generation
- text-guided session if supported
- pre-recorded fallback if available

## 13.4 Offline

If cached:

- allow playback

If not cached:

- offer cached Quick Start content
- preserve current settings

## 13.5 Audio load error

- do not silently start with missing narration
- show clear retry
- keep ambient sound optional

---

# 14. Component Inventory

Recommended reusable components:

```text
MeditationHero
MeditationPrimaryCTA
MeditationRecentContextCard
MeditationThemeCard
MeditationDurationSelector
MeditationInputField
MeditationContextSummaryCard
MeditationGeneratingStatus
MeditationProgressView
MeditationPlayerControls
MeditationSoundscapeSheet
MeditationCompletionMoodSelector
ChatMeditationOfferCard
TarotMeditationCTA
MeditationErrorState
MeditationSafetySupportState
```

Reuse existing shared buttons, cards, sheets, toasts, navigation, and typography tokens.

---

# 15. Motion Guidance

Allowed:

- subtle Twinko breathing
- gentle star shimmer
- soft page transitions
- calm expand / collapse
- progress movement

Avoid:

- bounce
- confetti
- fast orbiting particles
- game-like completion animation
- constant heavy movement

Reduce Motion:

- replace breathing scale with slight opacity change or static image
- use fades instead of large motion transitions

---

# 16. Accessibility

Required:

- 44 × 44 pt minimum tap targets
- VoiceOver labels for theme and duration
- accessible player state
- progress announced meaningfully
- selected state not conveyed by color alone
- sound controls labeled clearly
- Dynamic Type where practical
- decorative stars hidden from VoiceOver
- safety messages readable without animation

Example:

```text
Calm Down, selected.
Five minutes, selected.
Meditation paused, 3 minutes 42 seconds remaining.
```

---

# 17. Localization

Required:

- English
- Traditional Chinese

Rules:

- one language at a time
- natural copy, not literal translation
- allow text wrapping
- avoid fixed heights for generated titles
- player titles may vary in length
- TTS locale must match screen locale

---

# 18. Navigation Summary

```text
Home
└── Meditation Home
    ├── Personalized Input
    │   └── Context Review
    │       └── Generating
    │           └── Player
    │               └── Completion
    └── Quick Start
        └── Player
            └── Completion

Chat
└── Offer / Meditate on this
    └── Context Review
        └── Generating
            └── Player
                └── Completion
                    └── Return to Chat

Tarot Result
└── Turn this guidance into a meditation
    └── Context Review
        └── Generating
            └── Player
                └── Completion
                    └── Return to Tarot
```

---

# 19. Hard UI Rules

Claude Code must not:

- ask the user to repeat accepted Chat or Tarot context
- expose raw transcripts
- overcrowd Meditation Home
- create multiple Meditation Twinko states
- redesign unrelated Chat or Tarot screens
- add social sharing
- add streaks or gamification
- use humanized Twinko body poses
- turn the player into a complex audio workstation
- use fake generation percentages
- block cancellation during generation
- treat early exit as failure
- style low mood responses negatively

---

# 20. Acceptance Criteria

## Meditation Home

- [ ] Personalized CTA is the strongest action
- [ ] Quick Start themes are visible
- [ ] Duration selection works
- [ ] Recent Chat / Tarot cards appear only when available

## Personalized Input

- [ ] User can enter a concern
- [ ] Input persists through navigation interruptions
- [ ] Continue opens Context Review

## Context Review

- [ ] Source is clearly identified
- [ ] Focus is summarized
- [ ] User can edit or remove context
- [ ] Duration remains editable
- [ ] Generation starts only after confirmation

## Generating State

- [ ] Honest status is shown
- [ ] User can cancel
- [ ] Failure offers retry and fallback
- [ ] High-risk context does not enter normal generation

## Player

- [ ] Play, pause, resume, and end work
- [ ] Remaining time is accurate
- [ ] Soundscape and volumes are controllable
- [ ] Twinko animation is subtle
- [ ] Reduce Motion is supported
- [ ] Interruption handling preserves session progress

## Completion

- [ ] Reflection appears after completion or intentional early end
- [ ] Three mood options work
- [ ] Optional note is supported
- [ ] Return destination matches the source

## Cross-feature

- [ ] Chat offer accepts and declines correctly
- [ ] Chat offer follows frequency cap
- [ ] `Meditate on this` opens Context Review
- [ ] Tarot CTA opens Context Review
- [ ] Accepted context is preserved across the handoff

## Quality

- [ ] English and Traditional Chinese do not clip
- [ ] Canonical Twinko asset is used consistently
- [ ] One canonical background is used
- [ ] No raw sensitive context appears in the UI
