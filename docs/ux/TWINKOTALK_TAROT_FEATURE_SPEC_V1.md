# TwinkoTalk Tarot Feature Specification

**Status:** Canonical product and UX specification for implementation  
**Version:** v1.0  
**Target:** iOS-first prototype / MVP  
**Audience:** Claude Code, Fable, product, design, and engineering  
**Global dependency:** Root-level `DESIGN.md`  
**Languages:** English + Traditional Chinese

---

# 0. Source Priority

When any source conflicts, follow this order:

1. Latest founder-approved decision
2. This Tarot specification
3. Root-level `DESIGN.md`
4. Approved asset registry and canonical filenames
5. Existing Tarot implementation
6. Legacy mockups, old notes, and generated references

This file consolidates the approved Tarot product flow, UX logic, UI direction, animation requirements, card-draw rules, sharing behavior, and future intelligence architecture.

---

# 1. Product Intent

Twinko Tarot should feel like a calm, magical, emotionally supportive ritual—not a gambling product, fortune-telling game, or generic card randomizer.

The experience should combine:

- User agency through manual card reveal
- True random card selection
- Twinko companionship
- Reflective, emotionally safe interpretation
- Premium-soft visual quality
- Consistent design language across every Tarot screen

## Design north star

> **Cute × Premium × Calm × Magical**

Tarot may feel deeper and more mysterious than Chat, but it must still belong to the same TwinkoTalk product family.

---

# 2. Global Design Requirements

Every Tarot screen must follow `DESIGN.md`.

## Required consistency

Use the shared global system for:

- Colors
- Typography
- Spacing
- Radius
- Shadows
- Glow
- Buttons
- Inputs
- Cards
- Modals
- Navigation
- Motion
- Localization
- Accessibility

## Tarot-specific visual direction

Primary visual balance:

- Deep purple / deep indigo atmosphere
- Warm ivory for reading surfaces
- Muted purple for secondary UI
- Restrained gold for magical and high-value actions
- Twinko Yellow reserved for Twinko and selected magical highlights

## Avoid

- Screen-by-screen visual inconsistency
- Different button styles across Tarot steps
- Large blocks of bright purple text surfaces
- Candy-like gradients
- Excessive glow
- Overly decorative stars on every screen
- Emoji-based fixed UI decoration
- Native iOS alert styling for branded flows
- Poster-like layouts where every screen has oversized text and oversized Twinko

## Screen-type rule

- Ritual / transition screens may be immersive and cinematic.
- Functional / reading screens must be structured, calm, and easy to scan.
- The more text a screen contains, the quieter the background and surfaces should be.

---

# 3. MVP Scope

The prototype must support exactly two spreads:

## 3.1 Single Card

Purpose:

- One immediate reminder
- One focused reflection
- One concise interpretation

## 3.2 Three Cards

Positions:

1. Past
2. Present
3. Future

After the three-card interpretation, the user may optionally draw one additional Guidance Card.

The final result may therefore contain:

- 3 cards, or
- 3 + 1 Guidance Card

## Not in current prototype scope

- Four-card spread
- Celtic Cross
- Custom spread builder
- Multiple visual themes
- Multiple summary-card templates
- Advanced reading-history management
- Social feed
- Paid card packs

---

# 4. Canonical User Flow

## 4.1 Setup

User chooses:

- Topic
- Optional question
- Suggested question if desired

Topics:

- Love & Relationships
- Career & Finance
- Personal Growth
- Life Path

Traditional Chinese:

- 愛情與關係
- 工作與財務
- 自我成長
- 生活方向

Question input remains optional.

Suggested questions should:

- Match the selected topic
- Populate the input when tapped
- Not auto-submit
- Use localized text
- Avoid deterministic or harmful phrasing

## 4.2 Spread Selection

User chooses:

- Single Card
- Three Cards

Each spread must be presented as a visual selection card with an image preview.

Do not use plain text-only buttons.

### Single Card preview

Visual:

- One face-down card or one-card arrangement

Copy:

- One reminder for this moment

### Three Card preview

Visual:

- Three face-down cards arranged as a spread

Copy:

- Past · Present · Future

The spread preview images will later be standardized as approved assets.

Architecture must support asset replacement without changing layout logic.

## 4.3 Shuffle Magic Transition

The shuffle step is a ritual transition, not a long standalone page.

Required sequence:

1. Twinko activates magic
2. A magical aura or energy ring appears
3. Cards rise into the air
4. Cards rotate and drift in controlled motion
5. Cards gather into the selected spread
6. Transition into the reveal screen

Recommended duration:

- Approximately 1.8–2.8 seconds

The transition must feel magical, not chaotic.

## 4.4 Draw / Reveal

The system selects the cards randomly before reveal.

The user manually reveals each card.

### Single Card

- One face-down card
- User taps the card
- Card lifts slightly
- Card flips
- Card settles into place
- Interpretation becomes available

### Three Cards

- Three face-down cards
- Ordered left to right:
  - Past
  - Present
  - Future
- User taps cards individually
- Each card flips independently
- After all three cards are revealed, the interpretation CTA becomes enabled

Manual reveal is mandatory for interaction quality.

Do not auto-flip all cards unless an accessibility fallback is explicitly triggered.

## 4.5 Interpretation

### Single Card result

Display:

- Card image
- Card name
- Upright / Reversed state
- Keywords
- Main interpretation
- Reflective prompt
- Share text action
- Save summary card action

### Three Card result

Display:

- Past interpretation
- Present interpretation
- Future interpretation
- Overall three-card synthesis

Each position uses the same reusable content structure:

- Position badge
- Card image
- Card name
- Orientation
- Interpretation
- Reflection prompt
- Share text action

Do not place all interpretation text in one visually dense block.

Use modular cards / sections.

## 4.6 Optional Guidance Card

After the three-card interpretation, ask:

- Would you like to draw one Guidance Card?
- 想再抽一張指引牌嗎？

This step is optional.

Actions:

- Draw Guidance Card
- Continue without it

If accepted:

1. Reuse the single-card reveal interaction
2. Draw one additional card from the remaining deck
3. Reveal manually
4. Show Guidance Card interpretation
5. Generate final 3 + 1 synthesis

The Guidance Card must not duplicate any of the three already drawn cards.

## 4.7 Final Summary

For Single Card:

- One-card synthesis
- Final Twinko message

For Three Cards without Guidance:

- Past / Present / Future synthesis
- Final Twinko message

For Three Cards with Guidance:

- Past / Present / Future synthesis
- Guidance Card action direction
- Final 3 + 1 summary
- Final Twinko message

Actions:

- Share text result
- Save Twinko guidance summary card
- Draw again
- Return to Tarot
- Return Home
- Optional future CTA: Chat with Twinko

---

# 5. Random Draw Logic

The draw must feel genuinely random.

## 5.1 Core rules

- Use the complete 78-card deck
- No content-based card filtering
- No topic-based card restriction
- No weighting
- No “positive card” preference
- No user-profile manipulation
- No repeated card within the same reading

## 5.2 Sampling

### Single Card

- Draw 1 card from 78

### Three Cards

- Draw 3 unique cards from 78
- Draw without replacement

### Guidance Card

- Draw 1 card from the remaining 75 cards
- No duplicates

## 5.3 Orientation

Reversed cards are required.

For every selected card:

- Independently assign upright or reversed
- Default probability: 50% upright / 50% reversed

Do not bias orientation based on topic, user history, or desired emotional tone.

## 5.4 Implementation guidance

Use a secure or system-appropriate random generator available in the current platform.

Avoid:

- Predictable fixed seeds in production behavior
- Hardcoded card sequences
- Restricted demonstration decks
- Curated “good result” logic

For deterministic UI tests only, allow injection of a seeded random provider behind a test-only interface.

---

# 6. Card Reveal Interaction

## 6.1 Idle state

Face-down card:

- Subtle breathing movement
- Small vertical float
- Very low-intensity gold edge highlight
- Optional slow shimmer
- No large bounce

## 6.2 Tap response

- Card lifts approximately 4–8 pt
- Slight scale increase, maximum approximately 1.03
- Shadow increases briefly
- Flip begins immediately

## 6.3 Flip animation

- 3D Y-axis rotation
- Front asset swaps near 90 degrees
- Duration approximately 500–700 ms
- Soft ease in/out
- Optional shimmer at reveal midpoint
- No exaggerated spin

## 6.4 Completion

After reveal:

- Card settles
- Gold shimmer fades
- Position label and card name appear
- Haptic feedback may occur once
- Interpretation CTA updates appropriately

## 6.5 Reduce Motion

When Reduce Motion is enabled:

- Remove 3D rotation
- Use crossfade + small scale transition
- Remove floating and rotating shuffle effects
- Preserve state clarity

---

# 7. Shuffle Magic Animation Specification

The shuffle animation must communicate that Twinko is actively beginning the ritual.

## 7.1 Twinko animation

Twinko:

- Uses approved Tarot outfit asset
- Floats subtly
- Activates a controlled warm-gold magical aura
- May have a soft circular energy wave
- Must not change into unapproved expressions or outfits

## 7.2 Card animation

Cards:

- Rise from lower screen / table area
- Fan outward
- Rotate gently on multiple axes
- Drift in a controlled orbit
- Gather into the selected spread

Do not:

- Spin cards rapidly
- Use chaotic physics
- Cover Twinko’s face
- Create motion longer than needed
- Add particle overload

## 7.3 Transition

The shuffle animation ends by:

- Aligning cards into one-card or three-card layout
- Fading Twinko slightly back in hierarchy
- Moving focus to the cards
- Enabling user reveal interaction

---

# 8. Spread Selection Visual System

Each spread option must be a reusable visual card.

## 8.1 Component structure

Each selection card contains:

- Preview image
- Spread title
- Short description
- Selected state
- Tap target

## 8.2 Selected state

Use no more than two indicators:

- Gold border
- Soft elevated shadow
- Optional small gold indicator

Do not combine:

- Strong glow
- Large scale
- Thick border
- Badge
- Animated particle effect

all at once.

## 8.3 Future asset placeholders

Expected future asset roles:

```text
tarot_spread_single_preview_v1
tarot_spread_three_preview_v1
```

Final filenames will be confirmed later.

---

# 9. Result Screen Information Architecture

## 9.1 Single Card

Recommended order:

1. Screen title / question summary
2. Revealed card
3. Card name + orientation
4. Keywords
5. Interpretation
6. Reflection prompt
7. Share / save actions
8. Next action CTA

## 9.2 Three Cards

Recommended order:

1. Question and topic summary
2. Three-card overview row
3. Past section
4. Present section
5. Future section
6. Overall synthesis
7. Guidance Card prompt
8. Final actions

## 9.3 Three + Guidance

Recommended order:

1. Four-card overview
2. Guidance Card interpretation
3. Combined 3 + 1 synthesis
4. Final Twinko message
5. Share / save actions

## 9.4 Reading surfaces

Use:

- Warm ivory or neutral light surfaces for long text
- Deep plum text
- Restrained gold labels
- Quiet background behind long reading content

Do not use large bright-purple text panels for long interpretation.

---

# 10. Sharing

## 10.1 Share Text Result

Available after:

- Single-card interpretation
- Each three-card position interpretation
- Overall three-card synthesis
- Final 3 + 1 synthesis

Share content may include:

- User question or topic
- Card name
- Orientation
- Position
- Short interpretation
- Twinko closing line
- Optional app attribution

Do not automatically include sensitive full question text without user confirmation in the final production version.

## 10.2 Copy Text

Provide a copy action alongside share where practical.

## 10.3 Native Share Sheet

The prototype may use the native iOS share sheet for external sharing behavior.

The share button itself must follow Twinko design language.

---

# 11. Twinko Guidance Summary Card

The user may save a visual summary card.

This is a generated branded image, not a screenshot of the app UI.

## 11.1 Availability

Provide for:

- Single-card final result
- Three-card final result
- Three + Guidance final result

## 11.2 Visual direction

The summary card must feel collectible and unmistakably Twinko.

Use:

- Approved Tarot Twinko visual
- Deep purple cosmic background
- Restrained gold accents
- Warm ivory text
- Card thumbnails
- Small star motifs
- Clean premium layout
- TwinkoTalk / Twinko branding at low prominence

Avoid:

- Overcrowded text
- Full raw interpretation paragraphs
- Excessive decorative stickers
- Multiple bright colors
- Screenshot-like UI chrome

## 11.3 Required content

- Reading type
- Date
- Topic
- User question, only if included by the user
- Card names
- Upright / Reversed orientation
- Positions
- Short final synthesis
- Final Twinko guidance line

## 11.4 Suggested export formats

Prototype priority:

- 1080 × 1350 portrait

Future optional:

- 1080 × 1920 story
- Square format

## 11.5 Save behavior

- Render summary card to image
- Save to Photos after user permission
- Show success confirmation
- Provide Share action after generation

---

# 12. Interpretation Framework

The prototype may use its current interpretation implementation, but the final product must use a structured Tarot intelligence layer.

## 12.1 Required input

Interpretation receives:

- User topic
- User question
- Spread type
- Card ID
- Orientation
- Position
- Other cards in the spread
- Guidance Card if present
- Language

## 12.2 Single-card output structure

- Core theme
- Question-specific interpretation
- Upright / reversed nuance
- Gentle guidance
- Reflection prompt

## 12.3 Three-card output structure

- Past interpretation
- Present interpretation
- Future interpretation
- Cross-card relationships
- Overall synthesis
- Optional Guidance Card interpretation
- Final 3 + 1 synthesis

## 12.4 Tone

Twinko Tarot must sound:

- Warm
- Thoughtful
- Insightful
- Reflective
- Clear
- Non-deterministic
- Emotionally safe

Avoid:

- Absolute prediction
- Fear-based language
- Fatalism
- Medical diagnosis
- Legal prediction
- Financial certainty
- Relationship certainty
- Claims of supernatural fact

Preferred language:

- “This card may reflect…”
- “It may be worth noticing…”
- “One possible message is…”
- “You might consider…”

---

# 13. Future Tarot Knowledge Architecture

The formal release should be grounded in a strong, curated Tarot knowledge system rather than generic free-form prompting.

## 13.1 Knowledge sources

The future knowledge base should distinguish and document:

- Rider–Waite–Smith tradition
- Major Arcana symbolism
- Minor Arcana suits and numerology
- Court card roles
- Upright interpretations
- Reversed interpretations
- Spread-position interaction
- Cross-card synthesis
- Reflective / psychological Tarot practice
- Ethical and non-deterministic reading practice

Other Tarot systems such as Marseille or Thoth should not be mixed casually into the same interpretation layer without explicit product decisions.

## 13.2 Architecture recommendation

Use:

- Structured card registry
- Curated interpretation knowledge base
- Retrieval layer
- Prompt template by spread
- Safety layer
- Output schema validation
- LLM generation
- Human quality review and evaluation set

## 13.3 Quality requirements

The final model should be evaluated for:

- Card-meaning accuracy
- Correct upright / reversed nuance
- Correct spread-position interpretation
- Cross-card coherence
- Tone consistency
- Non-deterministic phrasing
- Safety compliance
- Bilingual quality
- Repetition control

The LLM should not “invent” meanings that conflict with the canonical registry.

---

# 14. Tarot Card Registry Requirement

All 78 approved card images will be renamed and mapped later.

This is a mandatory next step before production asset integration.

The registry must include:

```text
id
canonicalAssetName
displayNameEnglish
displayNameTraditionalChinese
arcanaType
majorArcanaNumber
suit
rank
orientationSupport
assetPath
keywordsUpright
keywordsReversed
status
notes
```

## Naming principles

- Lowercase snake_case
- Stable canonical English IDs
- No spaces
- No translated filenames
- No ambiguous abbreviations
- Major Arcana numbered consistently
- Minor Arcana sorted consistently by suit and rank
- Filename changes must not change semantic IDs

Example direction:

```text
tarot_major_00_the_fool_v1.png
tarot_major_01_the_magician_v1.png

tarot_cups_ace_v1.png
tarot_cups_02_v1.png
tarot_cups_page_v1.png
tarot_cups_knight_v1.png
tarot_cups_queen_v1.png
tarot_cups_king_v1.png
```

The complete 78-card naming table will be produced separately.

---

# 15. Asset Categories to Prepare

## 15.1 Twinko Tarot

Expected roles:

- Tarot idle
- Tarot magic activation
- Tarot result / summary
- Optional thinking / interpreting states

Approved filenames will be confirmed later.

## 15.2 Backgrounds

Expected roles:

- Setup
- Spread selection
- Shuffle ritual
- Reveal table
- Interpretation
- Summary card

## 15.3 Spread previews

- Single Card preview
- Three Card preview

## 15.4 Card assets

- 78 card fronts
- Shared card back
- Optional frame / shimmer overlays

## 15.5 Effects

- Magic aura
- Energy ring
- Star particles
- Card shimmer
- Reveal flash
- Summary-card decorative elements

All effect assets must remain subtle and conform to `DESIGN.md`.

---

# 16. Localization

Support English and Traditional Chinese for:

- Topics
- Suggested questions
- Spread names
- Position labels
- Shuffle copy
- Reveal instructions
- Upright / Reversed
- Interpretation
- Guidance Card prompt
- Share / save labels
- Safety disclaimer
- Errors
- Permissions
- Summary card content

Never display both languages simultaneously.

Store canonical values and localize presentation.

---

# 17. Accessibility

- Minimum tap target: 44 × 44 pt
- Support Dynamic Type on reading screens
- Do not rely on card orientation alone; label Upright / Reversed
- Provide accessible labels for every face-down card
- Announce reveal state to VoiceOver
- Respect Reduce Motion
- Provide non-3D reveal fallback
- Maintain sufficient text contrast
- Avoid flashing effects
- Ensure share and save actions are accessible

---

# 18. Safety Disclaimer

Include a concise disclaimer on final result screens.

Traditional Chinese direction:

> 塔羅內容僅供反思與娛樂，不代表確定的未來，也不是醫療、法律或財務建議。

English direction:

> Tarot content is for reflection and entertainment. It does not predict a certain future and is not medical, legal, or financial advice.

The disclaimer should be visible but visually secondary.

---

# 19. Persistence

The prototype should preserve reading data using the existing project architecture where practical.

Recommended reading record:

```text
readingId
createdAt
topic
question
spreadType
cards[]
  cardId
  orientation
  position
interpretations
overallSummary
guidanceCard
finalSummary
summaryCardPath
```

Reading history may be implemented later, but the data model should not block it.

---

# 20. Engineering Boundaries

Claude Code must:

- Reuse `DESIGN.md`
- Reuse shared navigation, button, modal, and surface components
- Preserve existing working Tarot flow where possible
- Consolidate redundant screens rather than rewrite the whole feature
- Keep random selection separate from presentation
- Keep card registry separate from localized display strings
- Keep interpretation logic separate from UI
- Support seeded randomness only for tests
- Avoid unrelated refactors

Do not:

- Create a second Tarot-only design system
- Hardcode 78 card mappings in view code
- Couple filenames directly to user-facing text
- Use topic-based draw restrictions
- Bias draws
- Omit reversed cards
- Auto-flip cards without user action
- Use native iOS alert design for branded product flows
- Add Four Card spread in the prototype
- Build a production LLM knowledge system during the current visual prototype phase

---

# 21. Acceptance Criteria

## Flow

- [ ] Setup supports topic and optional question
- [ ] Spread selection supports Single and Three
- [ ] Spread options use image previews
- [ ] Shuffle uses Twinko magic transition
- [ ] User manually flips cards
- [ ] Three-card positions are Past / Present / Future
- [ ] Guidance Card is optional
- [ ] Final result supports 3 or 3 + 1 synthesis

## Draw logic

- [ ] Full 78-card deck is used
- [ ] Selection is unweighted
- [ ] No topic restrictions
- [ ] No duplicates in one reading
- [ ] Reversed cards are supported
- [ ] Orientation is independently randomized at 50/50
- [ ] Test-only seeded randomness is possible

## UI

- [ ] All screens follow `DESIGN.md`
- [ ] Tarot UI feels visually consistent
- [ ] Long text uses calm reading surfaces
- [ ] Spread selection uses visual cards
- [ ] Reveal interaction is clear
- [ ] Result sections are modular
- [ ] Guidance prompt is visually distinct but not intrusive

## Animation

- [ ] Twinko activates magic
- [ ] Cards rise, rotate, and gather
- [ ] Animation transitions into reveal screen
- [ ] Card flip interaction works
- [ ] Reduce Motion fallback works

## Sharing

- [ ] Text result can be shared
- [ ] Text can be copied where appropriate
- [ ] Guidance summary card can be generated
- [ ] Summary card uses Twinko visual language
- [ ] Summary card can be saved to Photos
- [ ] Summary card can be shared

## Content

- [ ] Upright / Reversed state is displayed
- [ ] Interpretations follow position and orientation
- [ ] Overall synthesis is provided
- [ ] 3 + 1 synthesis is provided when Guidance Card exists
- [ ] Safety disclaimer is displayed
- [ ] English and Traditional Chinese both work

---

# 22. Next Work Sequence

After this specification is approved:

1. Generate and approve Tarot visual assets screen by screen
2. Define canonical Tarot Twinko asset set
3. Define spread preview assets
4. Define shuffle / magic visual assets
5. Define reveal / shimmer effects
6. Produce the 78-card canonical naming registry
7. Rename and map all existing card images
8. Update Claude Code implementation prompt
9. Implement visual refresh with minimal changes to working flow
10. Validate randomness, reversed cards, localization, and accessibility
