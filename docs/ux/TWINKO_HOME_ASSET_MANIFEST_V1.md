<!--
Promotion metadata (added at promotion time; not part of the source document body)
active_role: controlling Home asset manifest under D-055
source_package_path: handoffs/inbound/twinko-home-ui-v1-20260714:/TWINKOTALK_HOME_ASSET_MANIFEST.md
promotion_date: 2026-07-14
governing_decision: docs/product/TWINKO_DECISION_LOG.md D-055
document_classification: Twinko UX — active Home asset manifest
amendment_summary: Meditate/Music rows already read "opens placeholder page" and no "Coming Soon"/"Log Out" text existed in the source manifest, so no content removal was needed there. The one substantive change from the source: §4 "Available Twinko Expression Assets" listed 12 files, but only `twinko_default_smile_v1.png` was actually delivered in the inbound package (verified by directory listing). The other 11 are retained below for provenance/roadmap context only and are explicitly marked NOT implementation-ready — do not reference them as if they exist in the repository.
asset_integrity_note: Verified via `sips -g hasAlpha` on 2026-07-14: none of the 7 delivered PNGs (background, 5 icons, Twinko character) have a real alpha channel — `hasAlpha: no` on every file. The visible checkerboard pattern in the icon and character images is baked into the opaque pixels, not actual transparency. This contradicts this manifest's and the Home Screen Specification's "Transparent PNG" / "preserve transparency" language. Flagged for founder/design awareness; assets are promoted byte-identical regardless, per the no-redraw/no-regeneration rule below — implementation must account for the lack of real transparency rather than assuming it.
-->

# TwinkoTalk Home Asset Manifest

> **Temporary implementation amendment — 2026-07-14 (additive; founder-approved D-055 exception):**
> The six character/icon PNGs in §2–§3 currently lack a real alpha channel (see the asset-integrity note in the promotion metadata). Until corrected transparent exports are delivered and pass alpha validation, D-055 authorizes a temporary exception: the five Home mode icons are implemented as original native SwiftUI vector views (`apps/ios/Twinko/Twinko/Home/HomeModeIcon.swift`) using the delivered PNGs solely as visual references, and the central Home character continues to use the existing procedural `TwinkoCharacterView`. The delivered PNGs are not rendered at runtime. `home_screen_v1.png` (intentionally opaque) IS used directly as the Home background. The PNG files in this manifest remain the intended visual target and should replace the temporary drawings once real transparent exports exist. No product scope, naming, language, navigation, or feature decision is changed.

**Status:** Finalized for Home implementation
**Version:** v1

## 1. Home Background

| Asset | Purpose | Format | Notes |
|---|---|---|---|
| `home_screen_v1.png` | Full-screen Home background | PNG | Use aspect fill; do not stretch; no runtime recoloring |

## 2. Home Character

| Asset | Purpose | Format | Notes |
|---|---|---|---|
| `twinko_default_smile_v1.png` | Canonical central Home Twinko | Transparent PNG | Do not redraw or alter proportions |

## 3. Home Mode Icons

| Asset | Mode | English label | Traditional Chinese | Notes |
|---|---|---|---|---|
| `home_icon_chat_v1.png` | Chat | Chat | 聊天 | Display at the same dimensions as all other icons |
| `home_icon_tarot_v1.png` | Tarot | Tarot | 塔羅 | Opens Tarot |
| `home_icon_zodiac_v1.png` | Horoscope | Zodiac | 星座 | Home label remains `Zodiac` |
| `home_icon_meditate_v1.png` | Meditation | Meditate | 冥想 | Opens placeholder page until implemented |
| `home_icon_music_v1.png` | Music | Music | 音樂 | Opens placeholder page until implemented |

All icons:

- Transparent PNG
- Equal displayed circle diameter
- Preserve original aspect ratio
- Do not resize based on internal symbol size
- Normalize through a fixed rendered frame when needed

## 4. Available Twinko Expression Assets

**Implementation-ready (delivered in the inbound package and promoted to the repository):**

| Asset | Intended semantic use | Status |
|---|---|---|
| `twinko_default_smile_v1.png` | Canonical default and Home | Delivered — promoted to `assets/twinko/twinko_default_smile_v1.png` |

**Not implementation-ready (referenced by the source manifest for roadmap/provenance context, but not delivered in the `twinko-home-ui-v1-20260714` package or present anywhere in this repository — do not implement against these until they are actually delivered):**

| Asset | Intended semantic use |
|---|---|
| `twinko_calm_rest_v1.png` | Calm, rest, meditation |
| `twinko_celebration_v1.png` | Celebration, success, positive feedback |
| `twinko_chat_listening_v1.png` | Active listening in Chat |
| `twinko_comforting_v1.png` | Emotional comfort |
| `twinko_cosmic_guide_v1.png` | Zodiac or cosmic guidance |
| `twinko_encouraging_v1.png` | Encouragement |
| `twinko_gentle_concern_v1.png` | Gentle concern |
| `twinko_magical-v1.png` | Magical focus or ritual state |
| `twinko_sad_v1.png` | Sad expression |
| `twinko_sleepy_v1.png` | Sleepy or dreamy state |
| `twinko_thinking_v1.png` | Thinking or processing |

## 5. Asset Usage Rules

- Preserve filenames exactly
- Do not overwrite source files
- Do not recolor approved assets
- Do not distort aspect ratios
- Do not regenerate substitutes
- Do not bake labels into icon images
- Do not bake Twinko into the background
- Keep background, character, icons, labels, and animation layers separate

## 6. Recommended Project Structure

```text
assets/
  home/
    home_screen_v1.png
    home_icon_chat_v1.png
    home_icon_tarot_v1.png
    home_icon_zodiac_v1.png
    home_icon_meditate_v1.png
    home_icon_music_v1.png

  twinko/
    twinko_default_smile_v1.png
    # The following are referenced in §4 as roadmap/provenance context
    # only — NOT delivered, NOT present in this repository, NOT
    # implementation-ready:
    # twinko_calm_rest_v1.png
    # twinko_celebration_v1.png
    # twinko_chat_listening_v1.png
    # twinko_comforting_v1.png
    # twinko_cosmic_guide_v1.png
    # twinko_encouraging_v1.png
    # twinko_gentle_concern_v1.png
    # twinko_magical-v1.png
    # twinko_sad_v1.png
    # twinko_sleepy_v1.png
    # twinko_thinking_v1.png
```

## 7. Validation Checklist

- [x] Every referenced filename in §1–§3 exists in the repository (promoted to `assets/home/` and `assets/twinko/`)
- [ ] PNG transparency is preserved — **see asset-integrity note above: none of the 7 delivered PNGs have a real alpha channel; this item cannot pass as written until the source assets are re-delivered with genuine transparency, or the Home implementation is designed to not require it**
- [ ] Home background renders edge-to-edge
- [ ] All five Home icons display at identical dimensions
- [ ] Central Twinko uses `twinko_default_smile_v1.png`
- [ ] Labels are live text, not image text
- [ ] English and Traditional Chinese are supported
- [ ] Placeholder navigation exists for Meditate and Music
