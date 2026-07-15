# TwinkoTalk Tarot Animation Specification

**Status:** Canonical CPO-approved motion specification  
**Version:** v1.0  
**Target:** iOS-first prototype / MVP  
**Audience:** Claude Code, Fable, product, design, engineering, QA  
**Dependencies:**
- `DESIGN.md`
- `TWINKOTALK_TAROT_FEATURE_SPEC_V1.md`
- `TWINKOTALK_TAROT_BACKGROUND_USAGE_SPEC_V1.md`
- `TWINKOTALK_TAROT_SCREEN_SPEC_V1.md`
- `TWINKOTALK_TAROT_TWINKO_EXPRESSION_AND_USAGE_SPEC_V1.md`

---

# 0. Purpose

This file defines the canonical Tarot animation system for:

- screen transitions
- Twinko character motion
- shuffle ritual
- card distribution
- manual card reveal
- interpretation loading
- Guidance Card flow
- final summary
- Reduce Motion

The animation goal is:

> **Magical, calm, emotionally safe, and premium — never chaotic or game-like.**

---

# 1. Motion Principles

All Tarot motion must be:

- slow
- soft
- readable
- intentional
- low-amplitude
- reversible where possible
- accessible

Avoid:

- hard cuts
- fast spins
- chaotic physics
- excessive bounce
- confetti-like particle bursts
- large camera movement
- constant looping motion
- simultaneous motion across every layer

Use animation to guide attention, not to decorate every moment.

---

# 2. Global Motion Tokens

Recommended timing:

```text
micro:       120–160 ms
standard:    200–260 ms
screen:      300–500 ms
cardFlip:    500–700 ms
shuffle:     1.8–2.8 s
twinkoIdle:  3.5–4.5 s
```

Recommended curves:

```text
easeOut:       cubic-bezier(0.22, 1, 0.36, 1)
easeInOut:     cubic-bezier(0.65, 0, 0.35, 1)
gentleSpring:  low stiffness, high damping, no visible overshoot
```

Do not use strong spring bounce.

---

# 3. Screen Transition System

## 3.1 Setup → Spread Selection

Use:

- standard crossfade
- optional 4–8 pt upward content transition
- duration 240–320 ms

Background remains the same.

Do not animate the full background.

## 3.2 Spread Selection → Shuffle

Sequence:

1. Selected spread card confirms with a small scale response
2. UI content fades out
3. Setup background crossfades to Shuffle background
4. Magic Twinko fades and scales into the central stage
5. Shuffle ritual begins

Total transition before shuffle:

```text
300–500 ms
```

## 3.3 Shuffle → Reveal

Sequence:

1. Cards gather into final spread
2. Particle intensity decreases
3. Shuffle background crossfades to Result background
4. Cards move into reveal positions
5. Instruction text appears
6. Card interaction becomes enabled

Do not enable tapping before the cards settle.

---

# 4. Twinko Motion

## 4.1 Idle

Use for:

- landing
- topic selection
- question setup
- spread selection

Motion:

```text
vertical movement: 4–6 pt
scale: 1.0 → 1.01–1.015
duration: 3.5–4.5 s
loop: yes
curve: easeInOut
```

Do not rotate.

## 4.2 Magic activation

Use:

```text
twinko_tarot_magic_v1.png
```

Sequence:

1. Twinko fades in or replaces Idle asset
2. Slight scale-in from 0.96 to 1.0
3. Warm-gold aura appears
4. One energy ring expands
5. Cards begin rising
6. Glow settles before transition

Twinko remains near screen center.

Cards must not cover Twinko’s face.

## 4.3 Interpreting

Use:

```text
twinko_tarot_interpreting_v1.png
```

Motion:

- fade-in
- slow breathing scale 1.0 → 1.01
- one or two subtle star pulses
- no continuous card orbit

## 4.4 Summary

Use:

```text
twinko_tarot_summary_v1.png
```

Motion:

- soft fade-in
- 4 pt upward settle
- optional one-time sparkle
- no required loop

---

# 5. Shuffle Ritual

## 5.1 Product intent

The shuffle should feel like Twinko is activating magic and inviting the deck to move.

The system still selects cards randomly in logic.

The animation is presentation only and must not influence selection.

## 5.2 Canonical sequence

1. User confirms spread
2. Shuffle screen appears
3. Twinko activates magic
4. Warm-gold energy ring expands
5. Full deck or representative card stack rises
6. Cards fan outward
7. Cards rotate gently
8. Cards drift in a controlled orbital path
9. Selected cards separate from the group
10. Remaining cards fade or return
11. Selected cards gather into the chosen spread
12. Transition to reveal screen

## 5.3 Timing breakdown

Suggested:

```text
Twinko activation:  300–450 ms
Cards rise:         350–500 ms
Fan and orbit:      700–1,100 ms
Selected cards:     300–450 ms
Gather and settle:  300–500 ms
```

Total:

```text
1.8–2.8 seconds
```

## 5.4 Card movement

Allowed:

- slow Y-axis rotation
- slight Z-axis tilt
- smooth curved paths
- layered depth
- small scale variation

Avoid:

- rapid full rotations
- random collision
- cards flying offscreen
- dramatic perspective distortion
- cards moving behind critical UI
- physics that imply user control over the random draw

## 5.5 Particle behavior

Use:

- sparse warm-gold dust
- low opacity
- slow outward drift
- short lifetime
- maximum visual concentration during magic activation

Do not create a glitter storm.

---

# 6. Random Draw and Animation Separation

The card draw must occur in application logic before or during the shuffle presentation.

Rules:

- use all 78 cards
- no weighting
- no topic filtering
- no duplicate within one reading
- upright / reversed randomized independently at 50/50
- test builds may use seeded randomness
- production remains unweighted and non-deterministic

The animation must not suggest that a visible card was selected because of its path.

---

# 7. Card Placement

## 7.1 Single Card

The selected card settles:

- centered above the altar
- face down
- slight shadow
- optional 2–4 pt idle float

## 7.2 Three Cards

Cards settle left-to-right:

- Past
- Present
- Future

Recommended sequence:

- center card arrives first or all arrive together
- final labels appear after cards settle

Do not auto-flip.

## 7.3 Guidance Card

The Guidance Card enters as a separate moment.

Suggested:

- fade from the remaining deck
- move into center
- small gold Guidance indicator appears
- manual reveal remains required

---

# 8. Manual Card Reveal

## 8.1 Pre-reveal idle

Allowed:

- 2–4 pt vertical float
- faint edge highlight
- subtle shadow pulse
- no repeated shimmer

## 8.2 Tap response

On tap:

1. haptic feedback
2. card lifts 4–8 pt
3. scale increases to maximum 1.03
4. shadow strengthens briefly

Duration:

```text
100–160 ms
```

## 8.3 Flip

Use:

- 3D Y-axis rotation
- swap card-back to card-front near 90°
- total duration 500–700 ms
- easeInOut
- optional restrained gold shimmer at midpoint

For Reversed cards:

- front image appears rotated 180°
- do not add a separate dramatic animation

## 8.4 Completion

1. Card settles
2. Card name appears
3. Position label appears
4. Upright / Reversed appears
5. CTA state updates

Use one haptic only.

## 8.5 Three-card behavior

- User may reveal in any order
- No auto-reveal
- Each card flips independently
- Progress updates after each reveal
- CTA enables only after all required cards are revealed

---

# 9. Interpretation Loading

## 9.1 Entry

After all cards are revealed:

1. CTA is tapped
2. Cards remain visible briefly
3. Interpreting Twinko appears
4. Loading text appears
5. Result content loads

## 9.2 Copy

English:

> Twinko is connecting the cards.

Traditional Chinese:

> Twinko 正在整理牌卡的訊息。

## 9.3 Motion

- subtle breathing
- one or two star pulses
- no fake progress bar
- no rotating loader over Twinko
- no long artificial delay

If the result is ready quickly, maintain at least a brief transition for continuity, but do not exceed what is necessary.

---

# 10. Guidance Card Prompt

Use a branded modal or inline card.

Motion:

- background dim 35–45%
- modal fades and rises 8–12 pt
- duration 220–300 ms
- no bounce

On accept:

- modal fades
- Guidance Card transition begins

On decline:

- modal fades
- continue to final summary

---

# 11. Final Summary Motion

Sequence:

1. Result screen becomes quieter
2. Card overview fades in
3. Main synthesis surface rises 8 pt
4. Summary Twinko appears
5. Actions appear last

Do not animate long text line-by-line.

Optional:

- one-time soft sparkle near Twinko
- subtle gold divider reveal

---

# 12. Share and Save Motion

## 12.1 Share sheet entry

Use branded bottom sheet first.

Motion:

- dim background
- sheet rises from bottom
- duration 250–320 ms

Native iOS share sheet appears only after a share action is selected.

## 12.2 Guidance Summary Card generation

Loading:

- use a short progress state
- do not replay Tarot shuffle
- preserve reading state

Preview:

- image fades in
- scale 0.98 → 1.0
- duration 200–260 ms

Save success:

- branded toast
- one small sparkle allowed
- no celebration burst

---

# 13. Background Motion

Default:

- backgrounds remain static

Optional subtle effects:

- one slow star twinkle
- very slow particle drift
- slight gold light pulse

Do not animate:

- columns
- arches
- altar geometry
- astrological circle rotation
- camera parallax by default

Background motion must never compete with cards or Twinko.

---

# 14. Layer Order

Recommended compositing order:

```text
1. Background image
2. Optional dim / light overlays
3. Background particles
4. Twinko
5. Magic aura / energy ring
6. Cards
7. Card shimmer
8. UI text and controls
9. Modal / sheet
10. Toast
```

Do not bake foreground effects into background assets.

---

# 15. Reduce Motion

When Reduce Motion is enabled:

## Screen transitions

- use crossfade only
- no parallax
- no large translation

## Twinko

- static image
- static subtle glow
- no idle float
- no breathing loop

## Shuffle

Replace orbit with:

1. cards fade upward
2. selected cards appear
3. cards slide gently into spread

## Reveal

Replace 3D flip with:

- short fade
- slight scale
- card-front replacement

## Particles

- disable looping particles
- keep only static decorative stars

---

# 16. Performance Rules

- Preload card-back and required Twinko assets
- Load selected card fronts before reveal is enabled
- Avoid loading all 78 high-resolution fronts into memory simultaneously
- Use optimized image sizes
- Keep particle count limited
- Pause loops when screen is not visible
- Avoid nested blur-heavy layers
- Maintain smooth performance on supported iPhones

---

# 17. Error and Recovery Motion

## LLM error

- stop loading animation
- keep cards visible
- show branded error surface
- do not shake the screen
- do not replay shuffle

## App interruption

When resuming:

- restore current Tarot state
- do not replay completed shuffle
- do not re-flip already revealed cards
- preserve generated result if available

---

# 18. Implementation Boundaries

Claude Code should:

- implement reusable motion tokens
- separate random draw logic from animation
- use separate layers for Twinko, cards, aura, and particles
- support Reduce Motion
- preserve the current working Tarot flow
- validate single, three, and Guidance Card flows
- prevent interaction during critical transition phases

Claude Code must not:

- add game-like physics
- add sound without approval
- use cards to visually determine randomness
- auto-flip cards
- over-animate result pages
- rotate the background astrological circle continuously
- replay completed rituals after app resume
- create long artificial loading delays

---

# 19. Acceptance Criteria

## Shuffle

- [ ] Twinko activates magic
- [ ] Cards rise and rotate gently
- [ ] Cards gather into selected spread
- [ ] Total duration is 1.8–2.8 seconds
- [ ] Animation does not affect randomness
- [ ] Cards do not cover Twinko’s face

## Reveal

- [ ] Cards remain face down until tapped
- [ ] Flip duration is 500–700 ms
- [ ] Upright / Reversed appears correctly
- [ ] Three cards can be revealed independently
- [ ] CTA enables only after required reveals

## Loading

- [ ] Interpreting state is calm
- [ ] No fake progress
- [ ] No long artificial delay
- [ ] Error recovery keeps the reading intact

## Accessibility

- [ ] Reduce Motion has complete fallbacks
- [ ] State changes include text
- [ ] No meaning relies on animation alone

## Performance

- [ ] Animation remains smooth
- [ ] Assets are preloaded appropriately
- [ ] Offscreen loops stop
- [ ] Memory use remains controlled
