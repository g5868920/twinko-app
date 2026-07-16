# TwinkoTalk Horoscope Summary Card Specification

**Status:** Canonical CPO-approved visual and export specification  
**Version:** v1.0  
**Target:** iOS-first prototype / MVP  
**Audience:** Claude Code, product, design, engineering, QA  
**Dependencies:**
- `DESIGN.md`
- `TWINKOTALK_HOROSCOPE_FEATURE_SPEC_V1.md`
- `TWINKOTALK_HOROSCOPE_SCREEN_SPEC_V1.md`
- Approved `bg_horoscope_summary_card_v1.png`
- Approved canonical Horoscope Twinko asset
- Approved 12 zodiac symbol assets

---

# 0. Purpose

This file defines the visual hierarchy, data mapping, export behavior, and implementation rules for the Horoscope Summary Card.

The card is a shareable and saveable daily artifact that gives the user a concise, visually branded summary of the selected zodiac sign’s horoscope.

The card should feel:

> **Cosmic, elegant, warm, readable, and unmistakably TwinkoTalk.**

---

# 1. Product Goal

The Horoscope Summary Card should allow users to:

- save a polished daily horoscope image
- share a concise horoscope result with friends or social platforms
- retain the most meaningful part of the day’s reading
- feel a stronger sense of emotional connection with TwinkoTalk

It is not meant to reproduce the full Horoscope screen.

---

# 2. Canonical Asset Inputs

Use these assets:

```text
bg_horoscope_summary_card_v1.png
twinko_horoscope_default_v1.png
zodiac_aries_v1.png
zodiac_taurus_v1.png
zodiac_gemini_v1.png
zodiac_cancer_v1.png
zodiac_leo_v1.png
zodiac_virgo_v1.png
zodiac_libra_v1.png
zodiac_scorpio_v1.png
zodiac_sagittarius_v1.png
zodiac_capricorn_v1.png
zodiac_aquarius_v1.png
zodiac_pisces_v1.png
```

Do not embed localized text into these image assets.

All copy must be rendered at runtime.

---

# 3. Export Specifications

## 3.1 Primary export

```text
Canvas: 1080 × 1350 px
Aspect ratio: 4:5
Format: PNG
Color space: sRGB
```

This ratio is optimized for social sharing while remaining readable on mobile.

## 3.2 Safe area

Recommended safe margins:

```text
Top: 72 px
Left / Right: 72 px
Bottom: 72 px
```

No critical text or icon should touch the outer decorative frame.

## 3.3 Rendering quality

- render at full 1080 × 1350 resolution
- avoid screenshotting the app UI
- use a dedicated runtime renderer
- ensure text remains sharp
- prevent image interpolation blur
- preserve consistent asset scaling

---

# 4. Card Information Hierarchy

Top to bottom:

1. TwinkoTalk / Horoscope branding
2. Date
3. Zodiac identity
4. Daily headline
5. Overall score and summary
6. Twinko message
7. Lucky details
8. Optional footer attribution / disclaimer

The card should remain readable in 2–4 seconds.

---

# 5. Layout Structure

## 5.1 Top branding zone

Recommended content:

```text
TwinkoTalk
Daily Horoscope / 今日星座運勢
```

Rules:

- keep branding compact
- do not use oversized logos
- use warm gold or soft ivory
- do not compete with zodiac identity

## 5.2 Date zone

Display localized date.

Examples:

```text
July 16, 2026
2026 年 7 月 16 日
```

Use secondary emphasis.

## 5.3 Zodiac identity zone

Must include:

- canonical zodiac symbol asset
- localized zodiac name
- optional English zodiac name only when locale requires it

Recommended composition:

- symbol at top center or beside sign name
- sign name in clear heading
- symbol size visually distinct but not oversized

Example:

```text
♌
獅子座
```

## 5.4 Twinko placement

Use:

```text
twinko_horoscope_default_v1.png
```

Recommended placement:

- upper-right
- lower-right
- or centered between zodiac identity and headline

Recommended visible width:

```text
18–26% of card width
```

Rules:

- Twinko should feel present but not dominate
- do not crop face or headpiece
- do not cover the headline
- do not apply aggressive glow

## 5.5 Headline zone

This is the main message.

Recommended:

- 1–2 lines
- large, readable
- centered or left-aligned depending on composition
- use warm ivory or soft gold

Do not exceed the defined content-length rules.

## 5.6 Overall score zone

Include:

- localized label: Overall / 整體運勢
- score from 1–5
- star icons or equivalent
- accessible text alternative in app preview

Recommended presentation:

```text
整體運勢  ★★★★☆
```

Do not use red or warning styling for low scores.

## 5.7 Overall summary zone

Include one concise summary only.

Recommended length:

- Traditional Chinese: 14–30 characters
- English: 8–18 words

Do not include the full detailed paragraph.

## 5.8 Twinko message zone

Use a visually distinct but calm surface.

Example:

```text
Twinko 想說
不用一次解決全部，先把今天最重要的一步走好。
```

Recommended style:

- semi-transparent deep-blue / purple surface
- rounded corners
- soft border
- 1–2 short lines

## 5.9 Lucky details zone

Display four items:

- Lucky Number
- Lucky Color
- Lucky Zodiac
- Lucky Item

Recommended layout:

- 4-column row if readable
- otherwise 2 × 2 grid

Each item contains:

- small label
- emphasized value
- optional icon

Do not use color alone for Lucky Color. Always include the localized name.

## 5.10 Footer

Optional content:

```text
TwinkoTalk
For reflection and entertainment.
```

Keep very subtle.

---

# 6. Content Mapping

Map `DailyHoroscope` fields as follows:

| Summary Card Element | Data Source |
|---|---|
| Date | `date` |
| Zodiac ID | `zodiacSign` |
| Zodiac Name | localized zodiac registry |
| Zodiac Symbol | corresponding zodiac asset |
| Headline | `headline` |
| Overall Score | `overall.score` |
| Overall Summary | `overall.summary` |
| Twinko Message | `twinkoMessage` |
| Lucky Number | `lucky.number` |
| Lucky Color | `lucky.color.localizedName` |
| Lucky Zodiac | localized `lucky.zodiacSign` |
| Lucky Item | `lucky.item` |

Do not expose:

- birthday
- user name
- long-form detail
- hidden personalization context
- internal prompt or model metadata

---

# 7. Localization Rules

Required locales:

```text
en
zh-Hant
```

Rules:

- render only one locale at a time
- use localized zodiac names
- support English and Traditional Chinese layouts
- allow text wrapping
- avoid fixed-height text boxes that clip localized copy
- do not show bilingual copy simultaneously

Recommended fallback:

- if a localized field is missing, use English
- do not mix multiple languages in the same sentence

---

# 8. Typography

Use existing TwinkoTalk typography tokens.

Recommended hierarchy:

- Brand: 20–24 px equivalent
- Zodiac name: 42–56 px
- Headline: 36–48 px
- Overall label / score: 24–30 px
- Summary: 28–34 px
- Twinko message: 24–30 px
- Lucky labels: 18–22 px
- Lucky values: 22–28 px
- Footer: 16–18 px

Rules:

- prioritize readability
- avoid ultra-thin weights
- use semibold for headings
- use regular for body
- provide sufficient line spacing for Chinese

---

# 9. Color and Surface Rules

## 9.1 Background

Use:

```text
bg_horoscope_summary_card_v1.png
```

The background should remain visible but support text legibility.

## 9.2 Text colors

Preferred:

```text
Primary: warm ivory / near-white
Secondary: soft lavender-white
Accent: warm gold
```

Avoid pure white everywhere.

## 9.3 Surface overlay

Use semi-transparent surfaces where necessary.

Recommended:

```text
Deep blue-purple at 45–65% opacity
Soft border at 20–35% opacity
```

Avoid heavy glassmorphism blur if it hurts rendering performance.

---

# 10. Zodiac Symbol Usage

Each sign uses one canonical asset.

Rules:

- do not redraw symbols in code if canonical assets exist
- keep consistent visible size
- avoid stretching
- preserve transparent background
- use subtle glow only
- do not show multiple zodiac symbols unless one is the Lucky Zodiac icon

The main sign symbol must have the strongest emphasis.

---

# 11. Lucky Color Treatment

Lucky Color should include:

- localized color name
- optional small circular swatch
- optional hex-driven color fill

Rules:

- swatch is supplemental only
- color name is required
- ensure enough contrast if swatch is pale
- avoid placing text directly on the swatch

---

# 12. Preview Sheet

Before saving or sharing, show a preview sheet.

Recommended layout:

1. Preview image
2. Save Image button
3. Share button
4. Close button

Actions:

- Save Image → Photos
- Share → native iOS share sheet
- Close → return to Horoscope Today

The preview should use the exact final render.

---

# 13. Save and Share Behavior

## 13.1 Save

- request Photos permission only when needed
- show success toast after save
- show clear error if permission is denied

Suggested success copy:

```text
Saved to Photos
已儲存到照片
```

## 13.2 Share

- share the generated PNG
- optionally include short share text
- do not attach the full horoscope body by default
- preserve the card image quality

---

# 14. Rendering Architecture

Recommended modules:

```text
HoroscopeSummaryCardView
HoroscopeSummaryCardRenderer
HoroscopeSummaryCardPreviewSheet
```

Recommended input:

```text
DailyHoroscope
ZodiacMetadata
Locale
CanonicalAssets
```

The renderer should not depend on app-screen layout.

Do not take a screenshot of `HoroscopeTodayView`.

---

# 15. Prototype Rules

Prototype may:

- use local fixture data
- use local zodiac assets
- render the card entirely on device
- use one fixed composition for all signs

Prototype must still:

- support all 12 signs
- support English and zh-Hant
- render dynamic text
- support share and save
- exclude birthday

---

# 16. Accessibility

In the app preview:

- provide a text summary for VoiceOver
- describe sign, score, and headline
- do not expose decorative stars individually
- buttons must have clear labels

Suggested accessibility summary:

```text
Leo daily horoscope. Overall score 4 out of 5. Today is a good time to focus your attention on yourself.
```

The exported PNG itself should have a parallel share-text alternative.

---

# 17. Error Handling

If rendering fails:

- keep the horoscope result intact
- show a branded error message
- allow Retry
- allow Share Text as fallback

If save fails:

- show permission or system error
- do not regenerate content

If zodiac asset is missing:

- use localized zodiac text
- log missing asset
- do not crash

---

# 18. Hard Rules

Claude Code must not:

- screenshot the app UI as the final card
- expose birthday
- show all long-form details
- bake localized text into assets
- create multiple unrelated card layouts
- use an unapproved Horoscope Twinko state
- use Tarot visual assets in Horoscope
- overfill the card with decorative stars
- use a different zodiac symbol style
- add QR codes, URLs, or promotional banners in MVP

---

# 19. Acceptance Criteria

## Composition

- [ ] Background fills 1080 × 1350
- [ ] Branding is compact
- [ ] Zodiac sign is immediately identifiable
- [ ] Headline is readable
- [ ] Overall score and summary are present
- [ ] Twinko message is present
- [ ] Four lucky details are present
- [ ] Canonical Horoscope Twinko is used

## Data

- [ ] Card uses structured `DailyHoroscope` data
- [ ] Correct zodiac asset is resolved
- [ ] Correct localized names are shown
- [ ] Birthday is excluded

## Localization

- [ ] English renders without clipping
- [ ] Traditional Chinese renders without clipping
- [ ] Only one locale appears at a time

## Actions

- [ ] Preview opens
- [ ] Save to Photos works
- [ ] Native share sheet works
- [ ] Errors show a retry or fallback action

## Quality

- [ ] Final export is sharp
- [ ] Card is not a screenshot of the app UI
- [ ] Text remains readable on the approved background
- [ ] Design feels consistent with TwinkoTalk Horoscope

---

# 20. v1.1 Refinements (founder review 2026-07-16)

Superseding updates:

1. **Export is 1080 × 1440 (3:4)** — the background art's native
   ratio. This is the root fix for the previously clipped top/bottom
   decorative frame: the canvas must match the art ratio; never
   aspect-fill a mismatched canvas.
2. **No headline zone.** Card content: branding + date → zodiac
   identity (code-rendered glyph) + Twinko → overall score + summary
   → Twinko message (feeling + one small action) → 2×2 lucky details.
3. **No disclaimer, privacy note, or "does not include personal
   data" copy on the card.** The short disclaimer lives only on the
   main Horoscope screen.
4. Zodiac symbols on the card are code-rendered glyphs
   (`ZodiacGlyphView`), not raster assets.
5. Preview and export share the exact same composition and ratio.
