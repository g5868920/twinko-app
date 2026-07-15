# TwinkoTalk Meditation AI Generation Specification

**Status:** Canonical CPO-approved AI specification  
**Version:** v1.0  
**Target:** iOS-first MVP / V1 launch scope  
**Audience:** Product, AI engineering, backend, Claude Code, safety, QA  
**Dependencies:**
- `TWINKOTALK_MEDITATION_FEATURE_SPEC_V1.md`
- `TWINKOTALK_MEDITATION_SCREEN_SPEC_V1.md`
- Existing Chat safety and context systems
- Existing Tarot interpretation data model

---

# 0. Purpose

This document defines the AI generation architecture for TwinkoTalk Meditation.

It covers:

- context adapters
- context minimization
- safety classification
- structured meditation planning
- script generation
- validation
- TTS handoff
- fallback behavior
- caching
- observability
- privacy
- testing

The goal is to ensure personalized meditations are:

- context-aware
- emotionally relevant
- safe
- structured
- duration-aware
- natural in English and Traditional Chinese
- suitable for TTS
- reusable across Meditation, Chat, and Tarot entry points

---

# 1. Canonical Pipeline

All personalized meditation requests must use one shared pipeline:

```text
Source Context
→ Context Adapter
→ Context Extraction
→ Context Review
→ Safety Classification
→ Meditation Plan Generation
→ Script Generation
→ Script Validation
→ TTS Generation
→ Audio Cache
→ Playback
```

Do not build separate generation systems for Chat and Tarot.

Their only difference should be the source adapter.

---

# 2. Canonical Source Types

```text
quick_start
direct_input
chat
tarot
```

Recommended enum:

```swift
enum MeditationSource: String, Codable {
    case quickStart = "quick_start"
    case directInput = "direct_input"
    case chat
    case tarot
}
```

---

# 3. Context Adapters

Each source adapter converts feature-specific data into a shared draft context.

## 3.1 Direct Input Adapter

Inputs:

- user-entered concern
- selected theme, if any
- selected duration
- locale
- optional desired outcome

Output:

- concise topic
- user concern
- emotional state
- desired outcome
- recommended theme
- recommended tone

## 3.2 Chat Adapter

Inputs should be limited to:

- current triggering user message
- relevant Twinko response
- short recent conversation window or existing conversation summary
- conversation safety state
- locale

Do not automatically send the entire thread.

Preferred source order:

1. existing trusted Chat summary
2. relevant message pair
3. small recent context window only when required

The adapter should remove:

- unrelated topics
- system prompts
- hidden metadata
- tool traces
- unnecessary names
- addresses
- financial account numbers
- health details unrelated to the requested support

## 3.3 Tarot Adapter

Inputs:

- user question
- selected topic
- spread type
- cards
- card positions
- orientations
- reading synthesis
- guidance card, if present
- locale

Prefer the final synthesis over every long per-card explanation.

The adapter must explicitly mark:

```text
Tarot content is reflective context, not factual certainty.
```

---

# 4. Draft Context Schema

Adapters should output a draft object equivalent to:

```json
{
  "source": "chat",
  "sourceReferenceId": "optional-internal-id",
  "rawFocus": "I’m scared I’ll fail the interview tomorrow.",
  "selectedTheme": null,
  "durationSeconds": 300,
  "locale": "en",
  "sourceSummary": "The user feels anxious about an upcoming interview and is connecting the possible outcome to their self-worth.",
  "safetyState": "standard_wellness"
}
```

`sourceReferenceId` is internal only and must not be exposed in prompts unnecessarily.

---

# 5. Context Extraction

Context extraction transforms the draft into a canonical `MeditationContext`.

## 5.1 Required Output

```json
{
  "source": "chat",
  "topic": "upcoming interview anxiety",
  "userConcern": "The user feels afraid of failing and is tying the outcome to personal worth.",
  "emotionalState": [
    "anxious",
    "self-critical",
    "mentally tired"
  ],
  "desiredOutcome": [
    "grounded",
    "self-trusting",
    "calm"
  ],
  "guidanceDirection": "Separate preparation from self-worth and return attention to the next manageable step.",
  "recommendedTheme": "release_anxiety",
  "tone": "gentle_grounding",
  "durationSeconds": 300,
  "locale": "en",
  "avoidances": [
    "Do not promise interview success.",
    "Do not diagnose anxiety.",
    "Do not repeat private details verbatim."
  ],
  "safetyState": "standard_wellness"
}
```

## 5.2 Allowed Emotional Labels

Use a controlled vocabulary where practical:

```text
anxious
overwhelmed
sad
uncertain
self_critical
restless
lonely
angry
grieving
tired
hopeful
disconnected
```

## 5.3 Allowed Desired Outcomes

```text
calm
grounded
self_trusting
rested
emotionally_supported
clear
compassionate_toward_self
ready_to_sleep
less_attached
focused
```

## 5.4 Tone Options

```text
gentle_grounding
quiet_reassurance
sleepy_soft
warm_self_compassion
hopeful_intention
steady_confidence
```

Do not let the model invent unlimited tone labels.

---

# 6. Context Extraction Prompt Contract

The extraction prompt should instruct the model to:

- summarize only the relevant concern
- avoid diagnosis
- avoid certainty
- avoid quoting private details
- infer emotional state conservatively
- suggest one primary theme
- suggest one practical desired outcome
- produce JSON only
- preserve locale
- mark ambiguity rather than inventing facts

Example system instruction:

```text
You are a context extraction component for a wellness meditation feature.

Convert the provided user context into a concise, privacy-minimized MeditationContext.

Rules:
- Do not diagnose.
- Do not infer hidden trauma or medical conditions.
- Do not repeat private details unless necessary.
- Do not treat Tarot as factual certainty.
- Use only the allowed enum values.
- Return valid JSON only.
```

---

# 7. Context Review Contract

Before generation, the UI should display:

- `topic`
- a user-facing rewrite of `userConcern`
- `desiredOutcome`
- duration
- source

The review copy should not expose:

- model confidence
- safety labels
- internal avoidances
- raw source transcript

If the user edits the focus:

- treat the edited text as the new primary source
- rerun extraction
- preserve duration unless changed
- preserve source metadata for navigation only

---

# 8. Safety Classification

Safety classification must occur before normal plan generation.

## 8.1 Safety States

```text
standard_wellness
grounding_only
acute_risk
medical_emergency
unsafe_environment
```

## 8.2 Standard Wellness

Examples:

- ordinary stress
- mild or moderate anxiety
- relationship uncertainty
- difficulty winding down
- self-doubt
- sadness without immediate danger

Proceed with normal meditation generation.

## 8.3 Grounding Only

Examples:

- possible dissociation
- high emotional activation
- user does not want to close eyes
- trauma-sensitive context without acute danger

Generate only:

- eyes-open grounding
- orientation to room
- contact with floor / chair
- no imagery requiring deep inward focus
- no breath retention

## 8.4 Acute Risk

Examples:

- self-harm intent
- suicide intent
- immediate violence risk
- severe psychiatric crisis

Do not generate normal meditation.

Route to existing crisis-support handling.

## 8.5 Medical Emergency

Examples:

- chest pain
- severe breathing difficulty
- loss of consciousness
- suspected overdose

Do not generate meditation.

Route to emergency guidance.

## 8.6 Unsafe Environment

Examples:

- user is driving
- user is operating machinery
- user is in water
- user cannot safely reduce attention

Do not start closed-eye meditation.

Offer:

- stop when safe
- return later
- brief eyes-open grounding only if appropriate

---

# 9. Safety Classifier Output

```json
{
  "state": "standard_wellness",
  "reasonCode": "general_anxiety",
  "allowClosedEyes": true,
  "allowBreathGuidance": true,
  "allowedSessionStyle": "standard",
  "requiredResponseType": "meditation_generation"
}
```

For blocked cases:

```json
{
  "state": "acute_risk",
  "reasonCode": "self_harm_intent",
  "allowClosedEyes": false,
  "allowBreathGuidance": false,
  "allowedSessionStyle": "none",
  "requiredResponseType": "safety_support"
}
```

The classifier should return structured data only.

---

# 10. Meditation Plan Generation

The planner translates `MeditationContext` into a duration-aware plan.

## 10.1 Required Plan Fields

```json
{
  "title": "Returning to Your Own Ground",
  "subtitle": "You do not need every answer right now.",
  "theme": "release_anxiety",
  "tone": "gentle_grounding",
  "goal": "Reduce urgency and support self-trust.",
  "durationSeconds": 300,
  "sessionStyle": "standard",
  "segments": [
    {
      "type": "arrival",
      "targetSeconds": 30,
      "goal": "Help the user settle physically."
    },
    {
      "type": "breathing",
      "targetSeconds": 50,
      "goal": "Slow the pace without breath holding."
    },
    {
      "type": "acknowledgement",
      "targetSeconds": 70,
      "goal": "Validate uncertainty without reinforcing fear."
    },
    {
      "type": "personalized_guidance",
      "targetSeconds": 110,
      "goal": "Separate self-worth from the interview outcome."
    },
    {
      "type": "closing",
      "targetSeconds": 40,
      "goal": "Return attention to one manageable next step."
    }
  ],
  "closingAnchor": "I can prepare with care without measuring my worth by one outcome."
}
```

---

# 11. Duration Allocation

Suggested target ranges:

## 3 Minutes

```text
Arrival: 15–20 sec
Breathing: 30–40 sec
Acknowledgement: 35–45 sec
Personalized Guidance: 60–75 sec
Closing: 25–35 sec
```

## 5 Minutes

```text
Arrival: 25–35 sec
Breathing: 45–60 sec
Acknowledgement: 60–80 sec
Personalized Guidance: 100–130 sec
Closing: 35–50 sec
```

## 10 Minutes

```text
Arrival: 45–60 sec
Breathing: 90–120 sec
Acknowledgement: 120–150 sec
Personalized Guidance: 240–300 sec
Closing: 60–90 sec
```

The spoken script should include natural pauses.

Do not fill every second with speech.

---

# 12. Script Generation

The script generator receives:

- validated Meditation Context
- validated Meditation Plan
- locale
- TTS speech-rate assumptions
- safety constraints
- content style guide

It must return structured JSON only.

## 12.1 Required Script Fields

```json
{
  "sessionId": "med_20260716_001",
  "source": "chat",
  "title": "Returning to Your Own Ground",
  "subtitle": "You do not need every answer right now.",
  "theme": "release_anxiety",
  "tone": "gentle_grounding",
  "locale": "en",
  "durationSeconds": 300,
  "segments": [],
  "closingMessage": "You can care about the outcome without losing your connection to yourself.",
  "contentVersion": "1.0"
}
```

## 12.2 Segment Fields

```json
{
  "id": "guidance_1",
  "type": "personalized_guidance",
  "startOffsetSeconds": 150,
  "estimatedDurationSeconds": 110,
  "text": "For now, let the unanswered question rest beside you...",
  "pauseAfterSeconds": 3
}
```

Allowed segment types:

```text
arrival
breathing
body_awareness
acknowledgement
personalized_guidance
visualization
affirmation
silence
closing
```

Not every session needs every type.

---

# 13. Writing Style

The generated meditation should be:

- warm
- calm
- non-clinical
- emotionally specific without being invasive
- autonomy-supportive
- concise
- natural for spoken delivery

Preferred language:

```text
You may notice...
If it feels comfortable...
Let your attention return...
You do not need to solve this right now...
For this moment...
```

Avoid:

```text
You must...
This proves...
The universe guarantees...
Your cards say this will happen...
You are suffering from...
This meditation will cure...
```

---

# 14. Personalization Rules

Good personalization:

- reflects the high-level concern
- uses the desired emotional outcome
- acknowledges the user’s tension
- offers one relevant anchor
- avoids generic filler

Bad personalization:

- repeats names, dates, companies, or private details repeatedly
- narrates the conversation back to the user
- mentions card names throughout the meditation
- introduces unsupported interpretations
- makes promises about outcomes

Recommended private-detail rule:

> Use the emotional meaning, not the identifying detail.

Example:

Instead of:

```text
As you think about your 4 PM Uber interview tomorrow...
```

Use:

```text
As you notice the pressure around an important upcoming moment...
```

---

# 15. Tarot-Specific Generation Rules

Tarot-derived meditation may use:

- theme of the reading
- emotional tension
- guidance direction
- symbolic language in a light, optional way

It must not:

- state that the cards reveal objective truth
- predict what another person will do
- instruct financial, medical, or legal decisions
- intensify fear
- encourage repeated divination dependency

Preferred framing:

```text
The reading invited you to return attention to your own boundaries.
```

Avoid:

```text
The cards confirmed that this relationship will end.
```

---

# 16. Manifestation-Specific Rules

Manifestation sessions should focus on:

- clarifying intention
- imagining a desired emotional state
- identifying aligned action
- self-trust
- openness to possibilities

They must not:

- guarantee wealth, love, health, or career outcomes
- claim thoughts alone control reality
- blame users for outcomes
- discourage practical action

Preferred closing:

```text
Carry this intention into one small action you can choose today.
```

---

# 17. Breathing Safety Rules

Allowed:

- natural breath awareness
- slightly longer exhale
- gentle counted breathing without strain
- invitation to return to normal breathing

Not allowed:

- prolonged retention
- hyperventilation
- rapid breath cycles
- breath deprivation
- medical claims
- pressure to continue through dizziness

Required language:

```text
Return to your natural breath at any time.
```

For `grounding_only`, breathing should remain optional.

---

# 18. Validation Pipeline

Validation must include:

1. JSON schema validation
2. enum validation
3. duration validation
4. segment-order validation
5. safety-content validation
6. privacy validation
7. Tarot determinism validation
8. manifestation guarantee validation
9. TTS-readability validation
10. locale validation

---

# 19. Duration Validation

Estimate spoken duration using locale-aware speech-rate assumptions.

Initial planning assumptions:

```text
English: approximately 115–140 words per minute
Traditional Chinese: calibrate using measured TTS character timing
```

Do not rely on one universal word count.

The final implementation should calibrate using the actual selected TTS provider.

Tolerance:

```text
3-minute session: ±20 seconds
5-minute session: ±30 seconds
10-minute session: ±45 seconds
```

Pauses count toward duration.

---

# 20. Privacy Validation

Flag content that includes:

- full personal names
- email addresses
- phone numbers
- exact addresses
- account numbers
- precise birth data
- unnecessary company names
- verbatim sensitive Chat passages
- hidden metadata

Some user-provided first names may be allowed only if explicitly requested and contextually safe.

Default behavior is omission.

---

# 21. TTS Readability Validation

Before TTS:

- remove Markdown
- remove JSON artifacts
- expand symbols when needed
- avoid URLs
- avoid emoji-dependent meaning
- ensure punctuation supports natural pauses
- prevent stage directions from being spoken
- confirm locale consistency

Do not send raw app labels or segment IDs into spoken text.

---

# 22. Regeneration Policy

If validation fails:

## First failure

Regenerate with:

- specific validation errors
- same context
- same plan
- instruction to correct only invalid areas

## Second failure

Use:

- safe template-based script
- same theme
- same duration
- same desired outcome when safe

Do not loop indefinitely.

---

# 23. Safe Fallback Generation

Fallback scripts should be:

- prevalidated
- generic but relevant to theme
- available for all visible durations
- available in English and Traditional Chinese
- independent of network
- free of sensitive context

The fallback may include one neutral personalized line generated locally from the approved focus summary only if safe.

---

# 24. TTS Provider Interface

Recommended interface:

```swift
protocol MeditationTTSProvider {
    func synthesize(
        script: MeditationScript,
        voice: MeditationVoice,
        locale: AppLocale
    ) async throws -> MeditationAudioManifest
}
```

The provider should return:

```json
{
  "sessionId": "med_20260716_001",
  "audioFiles": [
    {
      "segmentId": "arrival",
      "localOrRemoteURL": "...",
      "durationSeconds": 31.4
    }
  ],
  "totalDurationSeconds": 301.2,
  "voiceId": "twinko_calm_en_v1",
  "locale": "en"
}
```

Segmented audio is preferred for:

- validation
- retry
- progress synchronization
- partial regeneration
- 10-minute reliability

---

# 25. Voice Requirements

Twinko’s Meditation voice should be:

- warm
- soft
- steady
- clear
- not whisper-heavy
- not infantilizing
- not theatrical
- not overly slow

Avoid:

- ASMR mouth sounds
- exaggerated breathiness
- romantic or seductive tone
- fake therapist authority
- overly cheerful delivery

Voice selection may vary by locale but should preserve the same personality.

---

# 26. Audio Cache

Cache key recommendation:

```text
meditation_audio:{scriptHash}:{voiceId}:{locale}
```

Script cache key:

```text
meditation_script:{contextHash}:{duration}:{locale}:{generationVersion}
```

Do not include raw context text in human-readable filenames.

Cache should support:

- replay
- returning from interruption
- offline playback
- avoiding duplicate TTS cost

---

# 27. Generation State Model

Recommended stages:

```text
idle
extracting_context
awaiting_context_confirmation
classifying_safety
planning
generating_script
validating_script
generating_voice
ready
failed
cancelled
```

The UI may simplify these labels, but engineering should preserve explicit state.

---

# 28. Cancellation

If the user cancels:

- stop pending work where supported
- preserve confirmed context
- preserve duration and theme
- do not save incomplete script as complete
- clean up partial temporary audio safely

---

# 29. Cross-Feature Write-Back Payload

Recommended internal payload:

```json
{
  "source": "chat",
  "sourceReferenceId": "internal-reference",
  "sessionId": "med_20260716_001",
  "theme": "release_anxiety",
  "durationSeconds": 300,
  "completionState": "completed",
  "reportedMood": "calmer",
  "completedAt": "2026-07-16T20:30:00+08:00"
}
```

Do not write the full generated script back into Chat or Tarot.

---

# 30. Analytics

Track operational and product metadata only.

Allowed:

```text
source
theme
duration
locale
safety_state
generation_stage_failed
validation_failure_type
fallback_used
tts_latency_bucket
script_generation_latency_bucket
completion_state
```

Do not log:

- raw prompt
- raw Chat transcript
- Tarot question text
- generated full script
- focus summary
- user note
- sensitive emotional details

---

# 31. Observability

Engineering logs may include:

- request ID
- anonymized session ID
- model version
- schema version
- validation result
- latency
- fallback path
- error code

Logs must not include sensitive raw user content by default.

---

# 32. Testing Strategy

## 32.1 Unit Tests

Test:

- all source adapters
- enum mapping
- duration allocation
- context minimization
- safety-state routing
- validator rules
- cache keys
- fallback selection

## 32.2 Golden Tests

Create approved examples for:

- interview anxiety
- relationship uncertainty
- difficulty sleeping
- self-love
- Tarot-derived self-worth reflection
- manifestation without guarantees
- English
- Traditional Chinese

## 32.3 Safety Tests

Test adversarial and high-risk inputs:

- self-harm intent
- medication replacement
- driving
- chest pain
- unsafe breathing request
- Tarot certainty request
- guaranteed manifestation request

## 32.4 Privacy Tests

Test that generated scripts do not expose:

- names
- exact dates
- addresses
- phone numbers
- verbatim transcript details

## 32.5 TTS Tests

Test:

- punctuation
- natural pauses
- duration accuracy
- mixed-language rejection
- segment synchronization
- interruption and resume

---

# 33. Versioning

Version separately:

```text
contextSchemaVersion
plannerPromptVersion
scriptPromptVersion
validatorVersion
ttsVoiceVersion
fallbackContentVersion
```

This allows quality comparison without changing the whole feature.

---

# 34. Recommended MVP Provider Boundaries

```text
MeditationContextExtractor
MeditationSafetyClassifier
MeditationPlanner
MeditationScriptGenerator
MeditationScriptValidator
MeditationTTSProvider
QuickStartMeditationProvider
MeditationAudioCache
```

Each provider should be replaceable and mockable.

---

# 35. Hard AI Rules

The AI system must not:

- generate a meditation before safety classification
- play content before validation
- pass the full Chat history by default
- treat Tarot as factual certainty
- diagnose users
- recommend stopping treatment or medication
- guarantee manifestation outcomes
- generate unsafe breathing
- repeat sensitive details unnecessarily
- create dependency language
- shame users
- hide fallback use from internal telemetry
- mix languages in one session unless explicitly designed later

---

# 36. Acceptance Criteria

## Context

- [ ] Direct input, Chat, and Tarot adapters produce the same canonical schema
- [ ] Chat context is minimized
- [ ] Tarot context uses synthesis rather than full repeated interpretation
- [ ] User edits trigger a refreshed context extraction
- [ ] Raw transcripts are not shown in Context Review

## Safety

- [ ] Every request is classified
- [ ] High-risk contexts do not enter normal meditation generation
- [ ] Grounding-only state produces appropriate content
- [ ] Unsafe-environment state blocks closed-eye flow

## Planning and Script

- [ ] Plan is structured
- [ ] Script is structured
- [ ] Duration is within tolerance
- [ ] All required segments are present
- [ ] Content is natural for TTS
- [ ] English and Traditional Chinese are supported

## Validation

- [ ] Invalid JSON is rejected
- [ ] Unsafe breathing is rejected
- [ ] Diagnosis and treatment claims are rejected
- [ ] Tarot certainty is rejected
- [ ] Manifestation guarantees are rejected
- [ ] Sensitive detail leakage is rejected
- [ ] Invalid content is never played

## TTS

- [ ] Validated scripts can generate audio
- [ ] Audio duration is measured
- [ ] Segment synchronization works
- [ ] Cache prevents unnecessary regeneration
- [ ] TTS failure has a safe fallback

## Cross-Feature

- [ ] Chat and Tarot handoffs preserve the intended emotional focus
- [ ] Full scripts are not written back to source features
- [ ] Completion metadata returns only to the relevant source
