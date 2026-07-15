# TwinkoTalk Tarot Canonical Assets & Guidance Summary Card Specification

**Version:** v3.0  
**Status:** canonical founder-reviewed asset specification

## 1. Approved background system

### Canonical repo filenames
```text
bg_tarot_celestial_altar_setup_v1.png
bg_tarot_observatory_shuffle_v1.png
bg_tarot_moonlight_altar_result_v1.png
```

### Current source files in this delivery pack
```text
assets/bg_tarot_celestial_altar_setup_v1.png
assets/bg_tarot_observatory_shuffle_v1.png
assets/bg_tarot_moonlight_altar_result_v1.png
```

## 2. Spread preview assets

```text
tarot_spread_single_preview_v1.png
tarot_spread_three_preview_v1.png
```

Rules:
- transparent background
- must visually use the same card-back design language as `tarot_card_back_v1.png`
- no text baked into the asset
- no selected state baked into the asset

## 3. Card back

```text
tarot_card_back_v1.png
```

This is the single canonical face-down card used for shuffle, reveal, spread previews, and any face-down card UI.

## 4. Tarot Twinko state set

```text
twinko_tarot_idle_v1.png
twinko_tarot_interpreting_v1.png
twinko_tarot_magic_v1.png
twinko_tarot_summary_v1.png
```

## 5. Additional card asset added in this pack

```text
tarot_swords_page_v1.png
```

This was created to match the existing tarot suit-page style and sizing.

## 6. Guidance Summary Card system

The Guidance Summary Card is **not** a single editable background PNG.

It should be implemented as a **runtime-composed export template**.

### Supported variants
1. Single Card summary
2. Three Card summary
3. General Guidance summary

### Recommended export size
```text
1080 × 1620 px
3:4 ratio
PNG
sRGB
```

### Recommended layers
1. simplified dark-purple Tarot background surface
2. title
3. date / metadata
4. `twinko_tarot_summary_v1.png`
5. one or three revealed cards
6. short interpretation summary
7. one actionable prompt
8. optional metadata tags
9. subtle footer branding

### Design rules
- dark purple + gold Tarot mood
- calm hierarchy
- mobile-readable type
- Twinko supports the reading, not overwhelms it
- use runtime text, not baked text images
