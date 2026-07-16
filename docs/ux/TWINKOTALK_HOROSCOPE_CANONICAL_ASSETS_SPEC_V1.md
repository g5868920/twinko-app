# TwinkoTalk Horoscope Canonical Assets Specification

**Status:** Canonical CPO and Design Lead approved asset specification  
**Version:** v1.0  
**Target:** iOS-first prototype / MVP  
**Audience:** Claude Code, product, design, engineering, QA  
**Dependencies:**
- `DESIGN.md`
- `TWINKOTALK_HOROSCOPE_FEATURE_SPEC_V1.md`
- `TWINKOTALK_HOROSCOPE_SCREEN_SPEC_V1.md`
- `TWINKOTALK_HOROSCOPE_SUMMARY_CARD_SPEC_V1.md`

---

# 0. Purpose

This file defines the canonical asset system for the TwinkoTalk Horoscope feature.

The goal is to:

- establish one source of truth for Horoscope assets
- prevent filename drift
- keep all 12 zodiac symbols visually consistent
- ensure the Horoscope Twinko asset is used correctly
- separate app-screen assets from summary-card assets
- clarify which visuals are static image assets and which are rendered by code

The Horoscope feature should feel:

> **Blue-purple, cosmic, exploratory, warm, and consistent with the Twinko universe.**

---

# 1. Canonical Repo Structure

Recommended asset structure:

```text
assets/
└── horoscope/
    ├── background/
    │   └── bg_horoscope_cosmic_v1.png
    │
    ├── summary-card/
    │   └── bg_horoscope_summary_card_v1.png
    │
    ├── twinko/
    │   └── twinko_horoscope_default_v1.png
    │
    └── zodiac-symbols/
        ├── zodiac_aries_v1.png
        ├── zodiac_taurus_v1.png
        ├── zodiac_gemini_v1.png
        ├── zodiac_cancer_v1.png
        ├── zodiac_leo_v1.png
        ├── zodiac_virgo_v1.png
        ├── zodiac_libra_v1.png
        ├── zodiac_scorpio_v1.png
        ├── zodiac_sagittarius_v1.png
        ├── zodiac_capricorn_v1.png
        ├── zodiac_aquarius_v1.png
        └── zodiac_pisces_v1.png
```

Use lowercase snake_case canonical filenames.

Do not create hyphenated aliases in implementation code.

---

# 2. Required Asset Inventory

The MVP requires exactly:

- 1 main Horoscope background
- 1 Horoscope Summary Card background
- 1 canonical Horoscope Twinko asset
- 12 canonical zodiac symbol assets

Total required static assets:

```text
15
```

Do not add more Horoscope Twinko variants or extra backgrounds for MVP unless founder-approved.

---

# 3. Main Horoscope Background

## 3.1 Canonical filename

```text
bg_horoscope_cosmic_v1.png
```

## 3.2 Usage

Use for:

- Horoscope Today screen
- Birthday Required state
- Zodiac Selector background treatment when needed
- Empty / error state
- Detail expansion state

## 3.3 Visual direction

The background should communicate:

- blue-purple cosmic night
- constellation map / star chart
- soft cosmic mist
- exploration and discovery
- restrained warm-gold star accents
- visual continuity with Home and Tarot

It should not feel:

- like a generic neon astrology app
- overly dark or horror-like
- too busy behind text
- identical to Tarot
- overly pink
- overly saturated
- like a realistic astronomy photograph

## 3.4 Composition rules

- keep the center readable
- decorative elements should remain mostly at edges
- allow room for Twinko and UI cards
- avoid strong contrast directly behind body text
- avoid embedded text
- avoid embedded zodiac names
- no permanent logo inside the image
- do not bake a selected zodiac sign into the background

## 3.5 Format

Recommended:

```text
Format: PNG
Color space: sRGB
Orientation: portrait
Minimum size: 1290 × 2796 px
Background: opaque
```

Use one source image and crop responsively for supported iPhone sizes.

---

# 4. Horoscope Summary Card Background

## 4.1 Canonical filename

```text
bg_horoscope_summary_card_v1.png
```

## 4.2 Usage

Use only for:

- Horoscope Summary Card export
- Summary Card preview

Do not use it as the regular Horoscope screen background.

## 4.3 Visual direction

The approved Summary Card background should include:

- blue-purple cosmic gradient
- restrained gold decorative frame
- celestial chart lines
- crescent moon and star accents
- soft cloud / cosmic mist details
- large calm central space for runtime content

## 4.4 Composition rules

- preserve clear text-safe center
- decorative frame must remain inside safe margins
- no embedded text
- no zodiac sign selected in advance
- no baked Twinko
- no baked date
- no baked horoscope copy
- no baked lucky details
- no promotional CTA

## 4.5 Format

```text
Canvas: 1080 × 1350 px
Aspect ratio: 4:5
Format: PNG
Color space: sRGB
Background: opaque
```

---

# 5. Canonical Horoscope Twinko

## 5.1 Canonical filename

```text
twinko_horoscope_default_v1.png
```

## 5.2 Approved visual identity

The Horoscope Twinko asset must preserve:

- yellow rounded Twinko star body
- no separate human body
- no separate arms or legs
- rounded black eyes with white highlights
- soft smile
- orange cheeks
- lavender astrology cape
- gold moon / star decorative elements
- pearl and celestial headpiece
- gold clasp
- soft dimensional illustration style
- transparent background

## 5.3 Product role

This single asset is used for:

- Horoscope Today hero
- Birthday Required state
- Empty / retry state
- Horoscope Summary Card
- Save / share preview

MVP intentionally uses only one state.

Do not create additional states such as:

- thinking
- celebration
- reading
- worried
- sleepy

unless explicitly approved later.

## 5.4 Usage rules

- do not crop the headpiece
- do not cover the face with UI
- keep Twinko secondary to horoscope copy on summary cards
- preserve aspect ratio
- avoid aggressive glow
- do not recolor the cape per zodiac sign
- do not place a zodiac symbol on Twinko’s forehead dynamically
- do not redraw Twinko using SwiftUI shapes

## 5.5 Format

```text
Format: PNG
Background: transparent
Color space: sRGB
Minimum canvas: 2048 × 2048 px
```

---

# 6. Zodiac Symbol Asset System

## 6.1 Canonical filenames

```text
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

## 6.2 Canonical mapping

| ID | English | Traditional Chinese | Symbol | Filename |
|---|---|---|---|---|
| `aries` | Aries | 牡羊座 | ♈ | `zodiac_aries_v1.png` |
| `taurus` | Taurus | 金牛座 | ♉ | `zodiac_taurus_v1.png` |
| `gemini` | Gemini | 雙子座 | ♊ | `zodiac_gemini_v1.png` |
| `cancer` | Cancer | 巨蟹座 | ♋ | `zodiac_cancer_v1.png` |
| `leo` | Leo | 獅子座 | ♌ | `zodiac_leo_v1.png` |
| `virgo` | Virgo | 處女座 | ♍ | `zodiac_virgo_v1.png` |
| `libra` | Libra | 天秤座 | ♎ | `zodiac_libra_v1.png` |
| `scorpio` | Scorpio | 天蠍座 | ♏ | `zodiac_scorpio_v1.png` |
| `sagittarius` | Sagittarius | 射手座 | ♐ | `zodiac_sagittarius_v1.png` |
| `capricorn` | Capricorn | 摩羯座 | ♑ | `zodiac_capricorn_v1.png` |
| `aquarius` | Aquarius | 水瓶座 | ♒ | `zodiac_aquarius_v1.png` |
| `pisces` | Pisces | 雙魚座 | ♓ | `zodiac_pisces_v1.png` |

## 6.3 Visual system

All 12 assets must use:

- the same canvas size
- the same symbol scale
- the same line thickness
- the same glow intensity
- the same transparent margins
- the same overall visual weight
- the same rendering style
- no text
- transparent background

## 6.4 Approved style direction

The symbol set should feel:

- clean
- luminous
- celestial
- premium
- simple enough for small sizes
- aligned with blue-purple cosmic UI

Recommended style:

- glowing outline or softly dimensional symbol
- restrained gold / warm yellow emphasis
- optional subtle lavender secondary glow
- no photographic effects
- no separate illustrated character per sign
- no random iconography beyond the zodiac glyph itself

## 6.5 Important consistency rule

The symbols must not look like they came from different illustration sets.

Do not vary:

- stroke width
- corner softness
- depth
- glow intensity
- material finish
- perspective
- padding
- symbol orientation

## 6.6 Selected and unselected states

The PNG itself should not include selected-state UI.

Implement states in code:

### Unselected

- reduced glow
- normal opacity
- neutral surface

### Selected

- highlight ring or elevated surface
- stronger but restrained glow
- selected marker
- accessible selected state

### Profile sign

- small `"My Sign"` / `"我的星座"` badge rendered by UI

Do not create separate selected PNGs for MVP.

## 6.7 Format

Recommended:

```text
Format: PNG
Background: transparent
Color space: sRGB
Canvas: 1024 × 1024 px
```

All 12 exports must use identical dimensions.

---

# 7. Asset-to-Screen Mapping

| Product State | Asset |
|---|---|
| Horoscope Today background | `bg_horoscope_cosmic_v1.png` |
| Birthday Required background | `bg_horoscope_cosmic_v1.png` |
| Zodiac Selector background | `bg_horoscope_cosmic_v1.png` or sheet surface |
| Main Horoscope hero | `twinko_horoscope_default_v1.png` |
| Empty / retry state | `twinko_horoscope_default_v1.png` |
| Summary Card background | `bg_horoscope_summary_card_v1.png` |
| Summary Card character | `twinko_horoscope_default_v1.png` |
| Main selected zodiac | matching `zodiac_<sign>_v1.png` |
| Lucky zodiac | matching `zodiac_<sign>_v1.png` |
| Zodiac selector | all 12 zodiac assets |

---

# 8. Code-Generated Visual Elements

The following are implementation elements, not required image files:

- selected zodiac ring
- unselected zodiac surface
- card shadows
- background dim overlays
- small star shimmer
- lucky color swatch
- score stars
- summary-card text surfaces
- loading indicator
- save success toast

Do not add these as static asset requirements unless engineering finds a clear need.

---

# 9. Asset Resolver Rules

Use the zodiac canonical ID to resolve the asset.

Example:

```swift
func zodiacAssetName(for sign: ZodiacSign) -> String {
    switch sign {
    case .aries: return "zodiac_aries_v1"
    case .taurus: return "zodiac_taurus_v1"
    case .gemini: return "zodiac_gemini_v1"
    case .cancer: return "zodiac_cancer_v1"
    case .leo: return "zodiac_leo_v1"
    case .virgo: return "zodiac_virgo_v1"
    case .libra: return "zodiac_libra_v1"
    case .scorpio: return "zodiac_scorpio_v1"
    case .sagittarius: return "zodiac_sagittarius_v1"
    case .capricorn: return "zodiac_capricorn_v1"
    case .aquarius: return "zodiac_aquarius_v1"
    case .pisces: return "zodiac_pisces_v1"
    }
}
```

Do not use array index order as the source of truth.

---

# 10. Validation Requirements

Before implementation handoff is considered complete, validate:

- all 15 required assets exist
- filenames match canonical names exactly
- no duplicate zodiac filenames
- all 12 symbols are 1024 × 1024
- all zodiac assets have transparent backgrounds
- Twinko has a transparent background
- main background is portrait and opaque
- summary-card background is 1080 × 1350
- no asset contains baked localized text
- no asset contains an unintended white background
- no zodiac icon is mirrored or mislabeled

---

# 11. Accessibility Metadata

Suggested accessibility labels:

```text
Aries zodiac symbol
Taurus zodiac symbol
Gemini zodiac symbol
Cancer zodiac symbol
Leo zodiac symbol
Virgo zodiac symbol
Libra zodiac symbol
Scorpio zodiac symbol
Sagittarius zodiac symbol
Capricorn zodiac symbol
Aquarius zodiac symbol
Pisces zodiac symbol
```

Traditional Chinese labels must be localized.

Decorative background images should be hidden from VoiceOver.

The Horoscope Twinko asset should be hidden when purely decorative.

If Twinko communicates an error or empty state, use a meaningful text label.

---

# 12. Prototype Boundary

The MVP asset set is intentionally limited.

Do not add:

- twelve zodiac-specific Twinko characters
- multiple Horoscope backgrounds
- animated zodiac symbol variants
- weekly or monthly card backgrounds
- compatibility assets
- natal chart diagrams
- extra celestial props

These may be evaluated after the Horoscope MVP is implemented and tested.

---

# 13. Claude Code Implementation Rules

Claude Code should:

- use canonical filenames
- keep asset resolution centralized
- implement selected state in code
- preserve transparent PNG composition
- use the same symbol scale across the zodiac selector
- reuse the same Twinko asset everywhere in MVP
- use `bg_horoscope_summary_card_v1.png` only in summary-card rendering
- validate missing assets during development
- preserve consistency with `DESIGN.md`

Claude Code must not:

- invent alternate filenames
- redraw zodiac symbols in SF Symbols
- use Unicode glyphs as the main visual asset when canonical images exist
- recolor canonical PNGs inconsistently
- add zodiac names inside images
- use Tarot Twinko or Tarot backgrounds in Horoscope
- create different zodiac UI styles per screen
- add extra assets outside this spec without approval

---

# 14. Acceptance Criteria

## Inventory

- [ ] One main Horoscope background exists
- [ ] One Summary Card background exists
- [ ] One canonical Horoscope Twinko asset exists
- [ ] All 12 zodiac symbol assets exist

## Naming

- [ ] All filenames use canonical lowercase snake_case
- [ ] No duplicate or alias filenames are required
- [ ] Zodiac assets resolve from canonical zodiac IDs

## Visual consistency

- [ ] All 12 symbols use the same style
- [ ] All 12 symbols use the same canvas and padding
- [ ] Main background feels cosmic and exploratory
- [ ] Summary background has sufficient text-safe space
- [ ] Twinko matches the approved Horoscope character

## Implementation

- [ ] Selected states are rendered in code
- [ ] Assets are not stretched
- [ ] No text is baked into static assets
- [ ] Summary-card background is not used as the main screen background
- [ ] Tarot visual assets are not reused in Horoscope

---

# Addendum — v1.1 (founder review 2026-07-16)

The 12 zodiac symbol PNGs (`zodiac_*_v1.png`) are now
**reference-only**: runtime presentation switched to code-rendered
glyphs (`ZodiacGlyphView`) because the raster assets' edges were not
clean enough to keep maintaining. The source PNGs remain under
`assets/horoscope/zodiac-symbols/` but are no longer imported into
the app's asset catalog. Canonical runtime Horoscope assets are now:
`bg_horoscope_cosmic_v1.png`, `bg_horoscope_summary_card_v1.png`, and
`twinko_horoscope_default_v1.png` (via its derived transparent copy).
