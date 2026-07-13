# TWINKOTALK_PROTOTYPE_PRD

> Version: 0.9 founder-review draft  
> Status date: 2026-07-13  
> Product: TwinkoTalk  
> Prototype language: Traditional Chinese  
> Objective: validate product experience, flow, visual coherence, and the roles of Chat, Tarot, and Astrology.  
> This is not a production MVP or market-validation result.

## 1. Objective

Create a coherent mobile prototype in which a user can:

1. Meet Twinko.
2. Complete a lightweight profile.
3. Enter a character-first Home.
4. Use Chat with scripted responses and real history.
5. Complete a Single-Card or Three-Card Tarot reading.
6. View a Daily Astrology insight.
7. Understand that Meditation and Music are future modes.

## 2. Non-Goals

- Live LLM quality.
- Account authentication.
- Cloud sync.
- Long-term memory.
- Clinical or wellness-outcome validation.
- Payments.
- Notifications.
- Gamification.
- Meditation or Music playback.
- Full 78-card production library.
- Full natal chart or compatibility.
- App Store release.

## 3. Primary User

A broad, unvalidated early-user hypothesis: a Traditional-Chinese-speaking adult who is comfortable with mobile / AI products and interested in companionship, reflection, tarot, or daily astrology.

The prototype is not optimized to prove a final persona.

## 4. End-to-End Flow

### Flow A — First launch

1. Welcome.
2. Continue.
3. Profile Setup.
4. Save profile.
5. Home / Menu.

### Flow B — Return launch

1. Open app.
2. Load saved prototype profile.
3. Home / Menu.

### Flow C — Chat

1. Tap Chat.
2. Open current or new Chat.
3. Enter a message.
4. Show thinking / loading state.
5. Show scripted Twinko response.
6. Continue or end.
7. Save conversation.
8. Open Chat History.
9. Reopen conversation.

### Flow D — Tarot

1. Tap Tarot.
2. Enter Tarot environment.
3. Choose topic or enter question.
4. Choose Single Card or Three Cards.
5. Shuffle.
6. Reveal.
7. View card meaning(s).
8. View Twinko reflection.
9. Return or start again.

### Flow E — Astrology

1. Tap Astrology.
2. Determine sun sign from birthday.
3. Show date, sign, overall guidance.
4. Show Love / Career / Finance.
5. Show lucky number / color / sign / item.
6. Return Home.

### Flow F — Disabled modes

1. Tap Meditation or Music.
2. The app does not navigate into an unfinished flow.
3. Show disabled / coming-soon treatment or prevent interaction with clear status.

## 5. Functional Requirements

### FR-001 Welcome

- Display Twinko and TwinkoTalk name.
- Traditional Chinese welcome copy.
- One clear continue action.

Acceptance:

- User can continue without confusion.
- Visual style matches the selected Twinko reference.

### FR-002 Profile Setup

Fields:

- Name.
- Birthday.
- Gender.

Requirements:

- Validate required fields.
- Save locally / within prototype state.
- No Apple or Google login.
- Explain that the information supports personalization and Astrology in production-oriented copy or helper text.

Pending:

- Gender choices.
- “Prefer not to say.”
- Minimum age behavior.

### FR-003 Home / Menu

Show:

- Twinko centered.
- Chat active.
- Tarot active.
- Astrology active.
- Meditation inactive.
- Music inactive.

Acceptance:

- Active and inactive modes are visually distinguishable.
- User never mistakes an inactive mode for a broken button.
- Twinko remains the focal point.

### FR-004 Chat

Requirements:

- Input field.
- Send action.
- Scripted response engine.
- Loading state.
- Fallback state.
- Start New Chat.
- Save conversation.
- Chat History list.
- Reopen a saved chat.
- Basic title.

Out of scope:

- LLM.
- Voice.
- Search.
- Cross-device sync.
- Long-term memory.

### FR-005 Tarot question

Requirements:

- Topic choices:
  - Love / relationships.
  - Career / finance.
  - Personal growth.
  - General guidance.
- Suggested questions.
- Custom question input.
- Copy must not promise certainty.

### FR-006 Tarot spread

- Single Card.
- Three Cards.

Pending:

- Three-card position labels.

Recommended safe options:

- Situation / Insight / Advice.
- Your View / Hidden Factor / Next Step.
- Past Influence / Present Focus / Possible Direction.

Avoid “fixed future.”

### FR-007 Tarot shuffle and reveal

- Visual shuffle state.
- Card-selection or reveal action.
- Single Card shows one card.
- Three Cards shows three cards.
- Results use the founder-provided Twinko Tarot visual direction.

### FR-008 Tarot interpretation

For each card:

- Card name.
- Short meaning.
- Contextual reflection.
- Optional question or small action.

Three Card also includes an integrated summary.

### FR-009 Astrology

Display:

- Zodiac sign.
- Date.
- Overall daily insight.
- Love.
- Career.
- Finance.
- Lucky number.
- Lucky color.
- Lucky sign.
- Lucky item.

Requirements:

- Sun-sign level only.
- Clear information hierarchy.
- Reflection / entertainment framing.
- No guaranteed financial or relationship result.

## 6. Content Requirements

### Chat

Minimum scenarios should cover:

- Feeling down.
- Recent worries.
- Confidence / encouragement.
- Dream / curiosity.
- General check-in.

A final number is pending. Recommended minimum: 5–8 scenarios with 2–3 turns each.

### Tarot

Prototype content should support enough cards to demonstrate Single and Three Card flows. It does not require a production-ready 78-card library.

### Astrology

Use a repeatable content template. Prototype may use sample daily content, clearly treated as a content demonstration rather than live astrological calculation.

## 7. Visual Requirements

### Twinko

- Rounded five-point star.
- Gold / orange glow.
- Black oval eyes with highlights.
- Simple smile.
- Orange cheeks.
- Consistent proportions.

### Home

- Pink / lavender / warm sky.
- Clouds and stars.
- Twinko central.
- Five mode icons.

### Chat

- Warm night / room feeling.
- Twinko seated or present.
- Comfortable, low-pressure visual tone.

### Tarot

- Deep purple star field.
- Wizard hat and cloak.
- Ritual table and cards.
- Gold accents.

### Astrology

- Cosmic tone.
- Clear cards or sections.
- Twinko still present.

## 8. States

Every relevant screen must specify:

- Default.
- Loading.
- Empty.
- Error / fallback.
- Disabled.
- Success / completion where applicable.

## 9. Trust and Content Guardrails

- Clearly AI / fictional companion.
- No diagnosis or treatment.
- No medical, legal, or financial instruction.
- Tarot does not know another person’s thoughts.
- Astrology does not guarantee outcomes.
- No exclusivity, guilt, or abandonment language.
- No statement that Twinko’s wellbeing depends on user return.

## 10. Prototype Acceptance Criteria

- All required flows complete.
- Chat History is functional.
- Tarot supports both spreads.
- Astrology shows every approved field.
- Disabled modes are clear.
- Twinko is consistent across screens.
- Traditional Chinese copy is reviewed.
- No broken links, placeholder text, or unsafe claims.
- The Prototype QA Checklist passes.

## 11. Open Decisions Before Production

1. Gender options.
2. Exact Chinese mode naming.
3. Three-card position labels.
4. Chat scenario number and branching.
5. Chat-title rule.
6. Astrology content source.
7. Disabled-state treatment.
8. Final typeface and component system.
