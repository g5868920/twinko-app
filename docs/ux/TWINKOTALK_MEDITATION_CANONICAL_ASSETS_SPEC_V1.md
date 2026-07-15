# TwinkoTalk Meditation Canonical Assets Specification

**Status:** Canonical CPO and Design Lead approved asset specification  
**Version:** v1.0  
**Target:** iOS-first MVP / V1 launch scope  
**Audience:** Product, design, Claude Code, engineering, QA  
**Dependencies:**
- `DESIGN.md`
- `TWINKOTALK_MEDITATION_FEATURE_SPEC_V1.md`
- `TWINKOTALK_MEDITATION_SCREEN_SPEC_V1.md`
- `TWINKOTALK_MEDITATION_AI_GENERATION_SPEC_V1.md`

---

# 0. Purpose

This file defines the canonical visual asset system for TwinkoTalk Meditation.

The goals are to:

- establish one source of truth for Meditation assets
- preserve Twinko’s canonical character identity
- prevent unnecessary asset expansion
- separate static art from code-generated motion and UI
- ensure the feature can support Quick Start, AI-personalized sessions, Chat handoff, Tarot handoff, Player, and Completion using a minimal coherent asset set

The Meditation world should feel:

> **Calm, cosmic, warm, private, and emotionally safe.**

---

# 1. Canonical Repo Structure

Recommended asset structure:

```text
assets/
└── meditation/
    ├── background/
    │   └── bg_meditation_cosmic_calm_v1.png
    │
    ├── twinko/
    │   └── twinko_meditation_calm_v1.png
    │
    ├── soundscapes/
    │   ├── ambient_cosmic_loop_v1.m4a
    │   ├── ambient_rain_loop_v1.m4a
    │   └── ambient_ocean_loop_v1.m4a
    │
    └── fallback-audio/
        ├── en/
        └── zh-Hant/
```

Use lowercase snake_case filenames for image and audio assets.

Do not create duplicate filename aliases.

---

# 2. Required MVP Asset Inventory

The minimum required visual assets are:

- 1 canonical Meditation Twinko
- 1 canonical Meditation background

The minimum required ambient audio assets are:

- 1 Cosmic loop
- 1 Rain loop
- 1 Ocean loop

Silence is implemented in code and does not need an audio file.

Optional fallback narration assets may be added only when required by the Quick Start fallback implementation.

---

# 3. Canonical Meditation Twinko

## 3.1 Canonical filename

```text
twinko_meditation_calm_v1.png
```

## 3.2 Approved visual identity

The approved character asset includes:

- yellow rounded Twinko star body
- no separate arms
- no separate legs
- calm closed-eye or gently relaxed expression
- soft smile
- rounded black eyes or closed-eye line treatment consistent with the approved artwork
- lavender meditation wrap
- lotus-inspired decorative elements
- soft dimensional shading
- transparent background
- premium but cute rendering
- no hard outline

This is the only canonical Meditation Twinko asset for MVP.

## 3.3 Product usage

Use this same asset for:

- Meditation Home
- Personalized Input
- Context Review
- Generating State
- Meditation Player
- Completion Reflection
- Empty State
- Error State
- Quick Start
- Chat-derived sessions
- Tarot-derived sessions

## 3.4 Usage rules

- preserve the original aspect ratio
- do not crop the head, face, or main body
- do not stretch
- do not recolor per theme
- do not add human limbs
- do not redraw using SwiftUI shapes
- do not add a yoga mat as part of the character asset
- do not add a moon seat
- do not add a zodiac symbol
- do not merge the character permanently into the background
- do not generate multiple expressions for MVP
- do not apply strong glow that overwhelms the face

## 3.5 Recommended format

```text
Format: PNG
Background: transparent
Color space: sRGB
Minimum canvas: 2048 × 2048 px
```

If the approved source is smaller, preserve the source and avoid low-quality enlargement unless a proper high-resolution export exists.

---

# 4. Canonical Meditation Background

## 4.1 Canonical filename

```text
bg_meditation_cosmic_calm_v1.png
```

## 4.2 Product usage

Use the same background for:

- Meditation Home
- Personalized Input
- Context Review
- Generating State
- Meditation Player
- Completion Reflection
- Error / Empty State

The screen may apply different code-generated overlays, gradients, dimming, or blur treatments by state.

## 4.3 Visual direction

The background should communicate:

- deep blue to lavender-purple gradient
- soft cosmic atmosphere
- subtle stars
- restrained cloud or mist layers
- central calm space
- low visual noise
- safety and emotional softness
- continuity with Home, Tarot, and Horoscope without copying them

## 4.4 Differentiation from other Twinko worlds

### Compared with Tarot

Meditation should be:

- softer
- less ritualistic
- less gold-heavy
- less mysterious
- less visually dramatic

### Compared with Horoscope

Meditation should be:

- less informational
- less star-chart oriented
- calmer
- more spacious
- more inward and atmospheric

## 4.5 Composition rules

The background must:

- keep the central area readable
- reserve enough negative space for Twinko
- avoid bright stars behind body text
- avoid hard horizon lines
- avoid embedded controls
- avoid embedded text
- avoid baked Twinko
- avoid baked session titles
- avoid a large fixed moon seat
- avoid a human silhouette
- avoid obvious Tarot cards or zodiac wheels

## 4.6 Recommended format

```text
Format: PNG
Color space: sRGB
Orientation: portrait
Background: opaque
Minimum size: 1290 × 2796 px
```

Use one source image and crop responsively across supported iPhone layouts.

---

# 5. Static Asset vs Code-Generated Motion

The following should be implemented in code and are not separate required image assets:

- Twinko breathing scale animation
- subtle Twinko glow change
- star shimmer
- progress ring
- progress bar
- player controls
- selected theme state
- selected duration state
- soundscape selection state
- generation-step indicator
- loading particles
- dim overlays
- modal surfaces
- success toast
- completion-state emphasis

Do not request extra PNG assets for these unless engineering identifies a real performance or fidelity issue.

---

# 6. Twinko Breathing Animation

The canonical Twinko image remains static.

Recommended code animation:

```text
Scale: 0.985 → 1.015
Cycle: 4–6 seconds
Easing: easeInOut
Loop: continuous while active
```

Optional glow treatment:

```text
Opacity / blur intensity changes subtly with the breathing cycle
```

Rules:

- no bounce
- no sudden pulsing
- no facial deformation
- no independent body-part movement
- no lip sync required

Reduce Motion:

- use a static image
- or a very subtle opacity transition only

---

# 7. Soundscape Assets

## 7.1 Canonical files

```text
ambient_cosmic_loop_v1.m4a
ambient_rain_loop_v1.m4a
ambient_ocean_loop_v1.m4a
```

Silence uses no file.

## 7.2 Requirements

Each soundscape must:

- loop seamlessly
- contain no voice
- contain no ads
- contain no prominent melody
- contain no sharp transition
- remain supportive under narration
- avoid sudden loud peaks
- support separate volume control

## 7.3 Sound direction

### Cosmic

- soft airy texture
- restrained pads
- subtle distant sparkle
- no sci-fi sound effects
- no dramatic cinematic rise

### Rain

- gentle, consistent rain
- no thunder
- no sudden heavy downpour
- no distracting traffic or indoor sounds

### Ocean

- slow, soft waves
- no birds or voices
- no aggressive surf
- no sudden volume variation

## 7.4 Recommended technical format

```text
Format: M4A / AAC
Sample rate: 44.1 kHz or 48 kHz
Stereo
Loop length: 60–180 seconds
Normalized for quiet background playback
```

Engineering should validate loop boundaries before release.

---

# 8. Narration Assets and TTS

Personalized meditation narration is generated dynamically.

Do not treat generated narration as a canonical static asset.

Generated narration should be cached using internal keys.

Optional pre-recorded or pre-generated fallback narration may be stored under:

```text
assets/meditation/fallback-audio/en/
assets/meditation/fallback-audio/zh-Hant/
```

Recommended fallback naming:

```text
meditation_<theme>_<duration>_<locale>_v1.m4a
```

Examples:

```text
meditation_calm_down_3min_en_v1.m4a
meditation_sleep_10min_zh_hant_v1.m4a
```

Do not store raw user context in filenames.

---

# 9. Quick Start Theme UI

Quick Start theme states are code-rendered.

No theme-specific illustration set is required for MVP.

Recommended implementation:

- one reusable theme card
- localized title
- optional simple system icon or small code-rendered symbol
- selected surface
- restrained accent variation

Do not create:

- five different Twinko costumes
- five different backgrounds
- five full illustration cards
- theme-specific character poses

---

# 10. Context Source UI

Chat and Tarot context cards are UI components, not image assets.

Use:

- source label
- concise focus summary
- optional small feature icon
- standard card surface
- code-rendered selected state

Do not use screenshots from Chat or Tarot as visual context previews.

Do not embed conversation text into static assets.

---

# 11. Generating State Visuals

The Generating State should reuse:

```text
twinko_meditation_calm_v1.png
bg_meditation_cosmic_calm_v1.png
```

Code may add:

- breathing animation
- subtle sparkles
- soft circular aura
- step copy
- progress state

Do not create a separate generating Twinko asset for MVP.

---

# 12. Player Visual System

The Player reuses the canonical background and Twinko.

Code-generated player elements:

- remaining-time display
- progress ring
- play / pause control
- close / end control
- soundscape control
- narration volume
- ambient volume
- optional transcript sheet

Avoid permanent audio-control artwork baked into the background.

---

# 13. Completion Visual System

Completion reuses the canonical assets.

Code may add:

- calm completion headline
- duration completed
- mood-selection controls
- generated closing message
- subtle warm overlay

Do not add:

- confetti
- achievement badge
- streak icon
- game-like reward assets
- social-share card

---

# 14. Asset-to-Screen Mapping

| Product State | Background | Twinko |
|---|---|---|
| Meditation Home | `bg_meditation_cosmic_calm_v1.png` | `twinko_meditation_calm_v1.png` |
| Personalized Input | `bg_meditation_cosmic_calm_v1.png` | optional canonical Twinko |
| Context Review | `bg_meditation_cosmic_calm_v1.png` | canonical Twinko |
| Generating | `bg_meditation_cosmic_calm_v1.png` | canonical Twinko |
| Player | `bg_meditation_cosmic_calm_v1.png` | canonical Twinko |
| Completion | `bg_meditation_cosmic_calm_v1.png` | canonical Twinko |
| Error / Empty | `bg_meditation_cosmic_calm_v1.png` | canonical Twinko |
| Chat Offer | existing Chat UI | no new Meditation art required |
| Tarot CTA | existing Tarot UI | no new Meditation art required |

---

# 15. Asset Naming Rules

Use:

```text
lowercase_snake_case_v1.ext
```

Do not use:

- spaces
- uppercase filenames
- duplicate aliases
- versionless final files
- ambiguous names such as `meditation_bg_final.png`
- date-based names
- source-tool names

Correct:

```text
twinko_meditation_calm_v1.png
bg_meditation_cosmic_calm_v1.png
ambient_cosmic_loop_v1.m4a
```

Incorrect:

```text
Twinko Meditation.png
background-final-2.png
calm music.m4a
```

---

# 16. Asset Validation Checklist

Before implementation handoff is complete, validate:

## Twinko

- transparent background
- no unintended white box
- correct canonical character
- no separate human limbs
- no crop
- correct filename
- sufficient source resolution

## Background

- portrait orientation
- opaque
- no embedded text
- no baked Twinko
- center remains readable
- no Tarot cards
- no zodiac wheel
- correct filename

## Soundscapes

- seamless loops
- no voice
- no ads
- no loud peaks
- correct filenames
- background-level normalization
- works under narration

---

# 17. Accessibility

Decorative background:

- hidden from VoiceOver

Twinko:

- hidden when decorative
- paired with meaningful screen copy when it communicates state

Soundscape choices:

- localized accessible labels
- selected state announced
- do not rely on icons alone

Example:

```text
Cosmic ambience, selected.
Rain ambience.
Silence.
```

---

# 18. Performance

Image assets should:

- avoid unnecessary duplicate resolutions
- use appropriate compression
- preserve transparency quality
- load without blocking the first meaningful screen

Audio assets should:

- support streaming or local preload as appropriate
- avoid loading all soundscapes at full size simultaneously
- support clean looping
- stop cleanly on session end

Do not sacrifice audio loop quality for extremely aggressive compression.

---

# 19. Rights and Licensing

All soundscape and fallback narration assets must have rights appropriate for commercial app use.

Do not ship:

- unlicensed YouTube audio
- unclear royalty-free content
- assets restricted to personal use
- voice clones without appropriate permission
- audio containing third-party branding

Record asset provenance in the project’s asset manifest or licensing file.

---

# 20. Prototype Boundary

The MVP intentionally uses a minimal visual asset set.

Do not add:

- multiple Twinko meditation expressions
- theme-specific backgrounds
- Chat-specific meditation backgrounds
- Tarot-specific meditation backgrounds
- meditation badges
- streak graphics
- summary / share card
- animated video backgrounds
- character lip-sync sprites
- zodiac meditation variants

These may be evaluated after usage and retention data exists.

---

# 21. Claude Code Implementation Rules

Claude Code should:

- use canonical filenames exactly
- centralize Meditation asset resolution
- reuse one background and one Twinko asset
- render selected and progress states in code
- preserve transparency and aspect ratios
- keep narration and ambient audio separate
- validate missing assets during development
- avoid unnecessary asset duplication
- reuse existing design tokens and shared components

Claude Code must not:

- invent alternate filenames
- create new Twinko poses
- redraw Twinko in code
- use Tarot or Horoscope backgrounds
- bake text into image assets
- treat generated TTS as a bundled canonical asset
- use screenshots as UI assets
- add unapproved theme illustrations
- add gamification visuals
- add social-share visuals

---

# 22. Acceptance Criteria

## Visual Assets

- [ ] `twinko_meditation_calm_v1.png` exists
- [ ] Twinko has a transparent background
- [ ] Twinko preserves the approved canonical design
- [ ] `bg_meditation_cosmic_calm_v1.png` exists
- [ ] Background is portrait and opaque
- [ ] Background contains no embedded text or character
- [ ] No extra Meditation Twinko states are required

## Audio Assets

- [ ] Cosmic loop exists
- [ ] Rain loop exists
- [ ] Ocean loop exists
- [ ] Silence works without an audio file
- [ ] All loops are seamless
- [ ] Narration and ambient sound are separately controllable

## Naming

- [ ] All assets use canonical lowercase snake_case filenames
- [ ] No duplicate aliases are required
- [ ] Generated audio filenames do not expose user context

## Implementation

- [ ] One Twinko asset is reused across all Meditation screens
- [ ] One background is reused across all Meditation screens
- [ ] Motion is implemented in code
- [ ] Theme selection is implemented in code
- [ ] Chat and Tarot handoffs require no new visual asset set
- [ ] Reduce Motion produces a calm static experience
- [ ] Decorative assets do not interfere with accessibility
