# TwinkoTalk Horoscope Screen-by-Screen UI Spec

**Status:** Canonical CPO-approved UI specification  
**Version:** v1.0  
**Target:** iOS-first prototype / MVP  
**Audience:** Claude Code, product, design, engineering, QA  
**Companion specs:**
- `TWINKOTALK_HOROSCOPE_FEATURE_SPEC_V1.md`
- `DESIGN.md`

---

# 0. Purpose

This file defines the actual screen structure, component hierarchy, interaction rules, states, content priorities, and implementation guidance for the TwinkoTalk Horoscope feature.

This document should be used by Claude Code to build the Horoscope flow in a way that is:

- visually consistent with the Twinko world
- lightweight enough for prototype delivery
- structured enough for future LLM integration
- clear enough for QA and iteration

---

# 1. Experience Principles

The Horoscope feature should feel:

1. **Cosmic but gentle**  
   Blue-purple, constellation-inspired, slightly mysterious, but still warm and welcoming.

2. **Simple, not overwhelming**  
   Users should get value within a few seconds.

3. **Reflective, not predictive**  
   The language should guide and comfort, not declare certainty.

4. **Visually aligned with Twinko**  
   Use the approved horoscope Twinko asset, zodiac symbols, and background assets consistently.

5. **Shareable by design**  
   The summary experience should naturally lead to saving or sharing.

---

# 2. MVP Screen List

The MVP Horoscope feature includes these screens / states:

1. Horoscope Entry Point (from Home)
2. Horoscope Today Screen
3. Zodiac Selector Modal / Sheet
4. Birthday Required Screen / State
5. Horoscope Detail Expansion State
6. Share Action Sheet
7. Save Horoscope Summary Card Flow
8. Error / Empty / Offline States

The MVP does **not** require a separate historical archive screen.

---

# 3. Canonical Asset Usage

## 3.1 Required assets

Use the approved assets only:

- **Horoscope Twinko:** one canonical character state
- **Horoscope Background:** one main background asset for the screen
- **12 Zodiac Symbols:** consistent style, no embedded text
- **Horoscope Summary Card Background:** for exported summary card only

## 3.2 Do not do

Do not:

- generate alternate Twinko poses for MVP unless explicitly approved
- use mixed zodiac symbol styles
- bake UI text into the background image
- use the summary-card background as the main screen background
- create a second visual system for Horoscope separate from Twinko

---

# 4. Screen 1 — Horoscope Today Screen

This is the main experience screen.

## 4.1 Goal

Allow the user to:

- see today’s horoscope at a glance
- confirm which sign is being viewed
- understand four life dimensions
- review lucky details
- switch zodiac sign
- share or save the result

## 4.2 Layout Priority

Top to bottom:

1. Navigation bar
2. Hero section
3. Headline / Twinko message
4. Four dimension cards
5. Lucky details block
6. Action buttons
7. Optional footer disclaimer

## 4.3 Navigation bar

Recommended elements:

- Left: Back button if navigated from Home
- Center: title `"Horoscope"` / `"今日星座運勢"`
- Right: optional compact action menu or share icon

Rules:

- keep title simple
- do not overload navigation with extra filters
- share action may also appear lower on the page

## 4.4 Hero section

Purpose:

- establish zodiac identity
- make the screen feel branded and special
- visually anchor the user

Recommended composition:

- approved Horoscope background visible behind hero area
- canonical Horoscope Twinko centered or slightly lower center
- selected zodiac symbol shown clearly
- zodiac name displayed near the top or below the symbol
- current date displayed in localized format

Recommended hero content order:

```text
Zodiac symbol
Localized zodiac name
Date
Canonical Horoscope Twinko
Headline
```

## 4.5 Headline block

This is the “instant takeaway”.

Content:

- one short headline
- one short Twinko message

Recommended hierarchy:

- Headline = larger, primary
- Twinko message = secondary, warm, supportive

Example:

```text
今天適合把注意力收回自己身上。
Twinko 想說：不用一次解決全部，先把今天最重要的一步走好。
```

## 4.6 Four dimension cards

Must include:

- Overall
- Love
- Career
- Wealth

Each card contains:

- section label
- 1–5 score
- short summary
- optional expand affordance
- hidden detailed copy revealed on expand

Recommended presentation:

- 2-column grid on larger layouts if it still feels readable
- otherwise stacked cards
- in iPhone portrait, stacked cards are safer for MVP

Recommended order:

1. Overall
2. Love
3. Career
4. Wealth

## 4.7 Dimension card component spec

Each dimension card should include:

- localized title
- score treatment
- one-line summary
- chevron or “more” affordance
- expanded detail body

Collapsed state:

```text
[Section Title]     [Score]
[One-line summary]
```

Expanded state:

```text
[Section Title]     [Score]
[One-line summary]
[Longer detail paragraph]
```

Interaction:

- tap card to expand / collapse
- only one expanded card at a time is preferred for MVP
- allow all-collapsed default state or auto-expand “Overall”

**Recommendation:** auto-expand “Overall” by default.

## 4.8 Lucky details block

This section should feel compact and visually scannable.

Must include:

- Lucky Number
- Lucky Color
- Lucky Zodiac Sign
- Lucky Item

Recommended display:

- 2 × 2 grid
- each item with small label and emphasized value

Example structure:

```text
Lucky Number     7
Lucky Color      薰衣草紫
Lucky Zodiac     天秤座
Lucky Item       小筆記本
```

If desired, lucky color may include:

- swatch
- localized name

But color must not be the only information.

## 4.9 Primary actions

At least two actions:

1. **Share**
2. **Save Summary Card**

Optional third action:

3. **Change Zodiac Sign**

Recommended order:

- Save Summary Card = primary
- Share = secondary
- Change Zodiac Sign = tertiary text/button

If Change Zodiac Sign already appears in hero area, it does not need a second large button.

## 4.10 Footer disclaimer

Small secondary text only.

Example:

```text
For reflection and entertainment.
僅供娛樂與自我反思參考。
```

Do not overemphasize the disclaimer.

---

# 5. Screen 2 — Zodiac Selector

This screen lets the user view another sign without changing their profile birthday.

## 5.1 Goal

Allow the user to:

- recognize all 12 signs easily
- change the currently viewed sign quickly
- know which sign is their actual profile sign

## 5.2 Presentation

Recommended presentation:

- bottom sheet or modal sheet
- not a full-screen permanent page unless needed for implementation simplicity

## 5.3 Content

Top area:

- title: `"Choose a Zodiac Sign"` / `"選擇星座"`
- short helper text:  
  `"You can explore other signs without changing your profile."`

Main content:

- 12 zodiac sign options
- each option includes:
  - zodiac symbol asset
  - localized name
  - English name optional if needed
  - selected state
  - “My Sign” badge when applicable

## 5.4 Layout

Recommended:

- 3-column icon grid
- or 2-column list if larger labels are preferred

For MVP, a **3-column grid** is preferred.

## 5.5 Interaction rules

Tap behavior:

- tap sign
- selection updates immediately
- either:
  - close and apply directly, or
  - show a confirm CTA

**Recommendation:** apply immediately and dismiss.

## 5.6 Visual rules

Selected sign:

- stronger glow / highlight ring
- filled or emphasized card

Profile sign:

- small tag: `"My Sign"` / `"我的星座"`

Do not:

- give every icon maximum glow at once
- create a cluttered zodiac wheel for the selector itself

---

# 6. Screen 3 — Birthday Required State

This appears only if birthday is missing and there is no selected default sign.

## 6.1 Goal

Help the user continue into Horoscope with minimal friction.

## 6.2 Content structure

Top:

- Horoscope title
- friendly subtitle

Main body:

- brief explanation:
  `"We use your birthday to determine your zodiac sign."`
- Birthday input control
- optional helper note
- primary CTA: Continue
- secondary CTA: Choose Zodiac Sign Manually

## 6.3 Input

Required field:

- birth date only

Do not ask for:

- birth time
- birthplace
- extra personal info

## 6.4 Success behavior

After entering birthday:

- auto-detect zodiac sign
- show a quick confirmation:
  `"You’re a Leo"` / `"你是獅子座"`
- continue to Today Horoscope

## 6.5 Skip behavior

If user chooses manual sign selection:

- go directly to Zodiac Selector
- do not force birthday completion

---

# 7. Screen 4 — Detail Expansion Behavior

This is a state inside Horoscope Today, not a separate page.

## 7.1 Default behavior

Recommended default:

- Overall expanded
- Love, Career, Wealth collapsed

This gives immediate value while preserving scanability.

## 7.2 Animation

Use gentle expand / collapse animation.

Rules:

- short duration
- no bounce
- respect Reduce Motion

## 7.3 Copy behavior

Expanded detail should:

- provide practical emotional guidance
- remain concise
- not overflow excessively

If a detail paragraph becomes too long:

- clip to max lines with “Read more” only if truly needed

**Recommendation for MVP:** keep copy short enough that extra “Read more” is not needed.

---

# 8. Share Flow

## 8.1 Share text action

Trigger:

- user taps Share button

System:

- present native iOS share sheet

Shared payload should include:

- localized zodiac sign name
- date
- headline
- short overall summary
- Twinko message
- TwinkoTalk attribution

## 8.2 Share UX rules

Before share:

- do not require extra editing screen for MVP
- allow one-tap native sharing

Optional confirmation toast after successful share:

- `"Shared successfully"` / `"已成功分享"`

---

# 9. Save Horoscope Summary Card Flow

## 9.1 Goal

Let users save a polished branded image.

## 9.2 Trigger

User taps:

- Save Summary Card
- or Share Summary Card

## 9.3 Card generation

The app should render a structured visual card using:

- approved Horoscope Summary Card background
- selected zodiac symbol
- localized zodiac name
- date
- headline
- overall score
- short summary
- Twinko message
- lucky details
- canonical Horoscope Twinko

## 9.4 Post-render actions

Recommended options:

- Save Image
- Share Image

For MVP:

- either show a preview sheet
- or directly save/share after rendering

**Recommendation:** show a preview sheet with action buttons.

## 9.5 Preview sheet content

- preview image
- Save to Photos button
- Share button
- Close button

---

# 10. Error / Empty / Offline States

## 10.1 No horoscope data

Show:

- Twinko
- short message:
  `"Today’s message is still gathering stars. Please try again."`
- Retry button

## 10.2 Offline with cached data

Show cached result normally.

Optional small note:

- `"Showing saved result"` / `"顯示已儲存內容"`

## 10.3 Offline with no cached data

Show:

- Twinko
- clear explanation
- Retry button
- optional Back button

## 10.4 Invalid provider response

If the data schema fails validation:

- do not crash
- log the error
- show fallback retry state
- optionally load a safe mock fallback in prototype

---

# 11. Screen Hierarchy and Navigation Summary

```text
Home
└── Horoscope Entry
    └── Horoscope Today
        ├── Zodiac Selector (modal/sheet)
        ├── Birthday Required (conditional)
        ├── Share Sheet
        └── Summary Card Preview / Save / Share
```

---

# 12. UI Component Inventory

Claude Code should implement these reusable components:

1. `HoroscopeHeroHeader`
2. `ZodiacSignChip` or `ZodiacPill`
3. `ZodiacSelectorGrid`
4. `HoroscopeDimensionCard`
5. `HoroscopeScoreView`
6. `LuckyDetailItem`
7. `LuckyDetailsGrid`
8. `TwinkoMessageBlock`
9. `HoroscopeActionBar`
10. `HoroscopeSummaryCardView`
11. `HoroscopeEmptyStateView`

---

# 13. Recommended Visual Hierarchy

## Highest emphasis

- selected zodiac sign
- headline
- Twinko visual presence

## Medium emphasis

- four dimension summaries
- lucky details

## Lower emphasis

- disclaimer
- extra support text
- metadata

The screen should not feel like a dense article.

It should feel like:

> **a beautifully packaged daily cosmic check-in**

---

# 14. Typography Guidance

Use the app’s existing typography system from `DESIGN.md`.

Hierarchy recommendation:

- Screen title: heading
- Zodiac name: subheading / strong title
- Headline: prominent body title
- Section labels: semibold body
- Summaries: body
- Details: secondary body
- Lucky labels: caption / small label
- Disclaimer: smallest secondary text

Rules:

- do not use too many type sizes
- keep the card readable in both zh-Hant and English
- avoid tight line spacing for Chinese text

---

# 15. Color and Mood Guidance

Use the approved Horoscope palette and overall Twinko system.

Mood direction:

- blue-purple / cosmic night foundation
- soft golden highlights
- exploratory / dreamy glow
- subtle constellation feeling

Do not:

- turn the screen into a pure neon effect
- use harsh contrast blocks
- use too many competing accent colors

Recommended emphasis colors:

- primary cosmic background
- warm gold for symbols / highlights
- soft white / cream text
- muted lavender surfaces

---

# 16. Motion Guidance

Only light motion is needed in MVP.

Optional subtle motion areas:

- Twinko idle glow
- background star shimmer
- expand / collapse animation
- summary card presentation transition

Rules:

- all motion must be subtle
- no long looping animation required for MVP
- support Reduce Motion
- do not block content loading with animation

---

# 17. Accessibility Guidance

All screens must support:

- Dynamic Type as much as practical
- VoiceOver labels for zodiac sign choices
- 44 × 44 pt tap targets
- accessible score text
- non-color-only meaning
- hidden decorative background from accessibility tree

VoiceOver examples:

- `"Leo, selected, my sign"`
- `"Love, score 3 out of 5, honest communication helps today."`

---

# 18. Prototype vs Future Production

## Prototype implementation may:

- use mock horoscope JSON
- use one main background asset
- use static summary-card rendering
- use local-only save/share flow

## Production-ready architecture should support:

- provider swap to LLM-backed content
- caching by date + sign + locale
- future personalization
- future weekly/monthly extensions without redesigning the whole screen

---

# 19. Hard Implementation Rules

Claude Code must not:

- redesign Twinko’s core look
- replace the approved zodiac asset style
- mix unrelated astrology UI inspirations
- hardcode horoscope copy in the SwiftUI view files
- create a complicated multi-step wizard
- add weekly/monthly tabs
- add natal chart logic
- expose birthday in share output
- create a dense wall of text
- add extra screens outside this spec unless necessary for system share/save flows

---

# 20. Acceptance Criteria

## Main screen

- [ ] Horoscope Today screen shows selected sign clearly
- [ ] Headline and Twinko message are visible above the fold
- [ ] Four dimension cards render correctly
- [ ] Lucky details block renders correctly
- [ ] Share and Save Summary Card actions are available

## Selector

- [ ] User can switch zodiac signs
- [ ] Current sign is visibly selected
- [ ] Profile sign is marked as “My Sign”

## Birthday flow

- [ ] Missing-birthday flow appears only when needed
- [ ] User can enter birthday or choose manually
- [ ] Birthday entry resolves to a sign and continues

## Summary card

- [ ] Summary card can be rendered as a composed asset
- [ ] Summary card can be saved
- [ ] Summary card can be shared

## UX quality

- [ ] The screen feels visually aligned with the Twinko world
- [ ] Text remains readable in English and zh-Hant
- [ ] Decorative backgrounds do not interfere with readability
- [ ] Accessibility support is present
- [ ] Prototype uses structured data and reusable components

---

# 21. v1.1 Refinements (founder review 2026-07-16)

The following supersede any conflicting sections above:

1. **No headline.** The hero shows zodiac glyph → localized name (+
   My Sign badge) → date → change-sign chip → floating Twinko. The
   single takeaway is the **Twinko message**, which carries the day's
   feeling plus one small, doable action — there is no separate
   headline block and no separate "small action" section.
2. **Floating Twinko.** The hero Twinko uses the same gentle
   breathing-float motion language as Home and Chat (±5 pt, ~3.8 s
   ease-in-out, Reduce Motion → static).
3. **Readability overlay.** A restrained deep-purple gradient
   (22–36%) sits over the cosmic background so the art stays
   atmospheric and never competes with reading surfaces.
4. **Zodiac selector opens fully.** The sheet presents at the large
   detent so all 12 signs are visible immediately — no drag needed.
   Tap still applies immediately and dismisses.
5. **Code-rendered zodiac glyphs.** All zodiac symbols (hero,
   selector, lucky grid, summary card) are rendered in code
   (`ZodiacGlyphView`: Unicode glyph forced to text presentation,
   brand-gold gradient, soft glow, emphasized/unemphasized states).
   The raster symbol PNGs are reference-only and are not shipped in
   the asset catalog.
6. **Disclaimer** appears once, short, at the bottom of the main
   screen only — never on the Summary Card.

## Horoscope polish amendment (2026-07-17)

- **CTA family:** feature-scoped deep-grape treatment
  (`HoroscopeCTAPalette`, ≈#5B3A94→#372359 + antique-gold border/icon,
  warm-ivory text) replaces the bright-gold primary — premium and
  distinct from Tarot's amethyst. Save 運勢小卡 = primary; Share =
  secondary (same family); applied on the page, the Summary Card
  sheet, setup, and retry states. Renderer, export dimensions, Photos
  and share services unchanged.
- **Hierarchy:** deeper background overlay (~0.28–0.42) so the zodiac
  wheel reads as atmosphere; 整體運勢 carries a stronger surface +
  gold border; Twinko 想說 unchanged as the entry point; 今日幸運 uses
  a quieter title and lighter tiles; slightly more spacing before the
  actions.
- **Disclaimer:** 「內容僅供反思與娛樂」/ "For reflection and
  entertainment only", low prominence.
- **Tab visibility:** the Horoscope content page registers an
  immersive token (bar hidden); the outer entry (Explore/Home) keeps
  the bar and it restores on pop.
