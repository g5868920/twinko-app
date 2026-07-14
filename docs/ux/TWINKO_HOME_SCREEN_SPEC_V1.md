<!--
Promotion metadata (added at promotion time; not part of the source document body)
active_role: controlling Home implementation specification under D-055
source_package_path: handoffs/inbound/twinko-home-ui-v1-20260714:/TWINKOTALK_HOME_SCREEN_SPEC.md
promotion_date: 2026-07-14
governing_decision: docs/product/TWINKO_DECISION_LOG.md D-055
document_classification: Twinko UX — active Home implementation specification
note: This document's original title retains the historical source name "TwinkoTalk" for provenance only. `TwinkoTalk` is NOT the approved final product name — naming remains unresolved per D-047 and D-055. Home itself must not display `Twinko`, `TwinkoTalk`, or any other product wordmark (see §2 and §18 below).
amendment_summary: The only content change from the inbound source is the removal of "Log Out" (§11 Profile Menu Structure, §19 Functional acceptance criteria) because no authentication or account system exists (D-055). All other content, including layout, motion, typography, navigation, localization, accessibility, and asset-integrity rules, is preserved unchanged.
override_rule: If any requirement below conflicts with docs/product/TWINKO_DECISION_LOG.md or docs/product/TWINKO_CURRENT_STATUS.md, those canonical documents override this spec.
-->

# TwinkoTalk Home Screen Specification

> **Temporary implementation amendment — 2026-07-14 (additive; founder-approved D-055 exception):**
> The delivered icon and Twinko PNGs (`home_icon_*_v1.png`, `twinko_default_smile_v1.png`) currently lack a real alpha channel — the checkerboard is baked into opaque pixels — so they cannot be rendered at runtime. Under a founder-approved temporary exception to §18's no-redraw rule (scoped to this problem only), D-055 authorizes: (1) a temporary native-SwiftUI vector implementation of the five Home mode icons, drawn to follow the delivered PNGs as visual references without using them as runtime images; and (2) continued temporary use of the existing procedural `TwinkoCharacterView` for the central Home character. `home_screen_v1.png` is intentionally opaque and is used directly as the Home background. This does not replace the founder-approved visual target: once transparent source exports are delivered and pass alpha validation, the PNG assets should replace the temporary SwiftUI drawings. No product scope, naming, language, navigation, or feature decision is changed by this amendment. All other rules in this specification remain active.

**Status:** Finalized for implementation
**Product:** TwinkoTalk
**Screen:** Home
**Version:** v1
**Target:** iOS-first MVP
**Languages:** English + Traditional Chinese

## 1. Purpose

The Home screen is the main entry point into the TwinkoTalk world. It should feel like a soft, dreamy, emotionally warm universe centered around Twinko rather than a conventional utility dashboard.

Primary objectives:

- Establish Twinko as the visual and emotional center
- Provide direct access to five product modes
- Support English and Traditional Chinese layouts
- Preserve a clean, immersive visual hierarchy
- Avoid temporary UI labels such as "Coming Soon"

## 2. Final Founder Decisions

- Home does not display the `TwinkoTalk` wordmark.
- MVP uses one fixed Home background.
- No light mode / dark mode for MVP.
- Home shows five mode entries:
  - Chat
  - Tarot
  - Zodiac
  - Meditate
  - Music
- Traditional Chinese labels:
  - 聊天
  - 塔羅
  - 星座
  - 冥想
  - 音樂
- Home uses a single Profile entry in the top-right corner.
- Settings is nested inside the Profile menu.
- Meditate and Music navigate to placeholder pages until implemented.
- Do not show "Coming Soon".
- Chinese and English UI must be developed and tested in parallel.

## 3. Final Assets

### Background

- `home_screen_v1.png`

Rules:

- Full-screen background
- Use aspect fill
- Extend behind safe areas
- Do not stretch or distort
- Do not bake UI elements into the background
- Do not apply strong runtime recoloring

### Central Twinko

- `twinko_default_smile_v1.png`

Rules:

- Canonical Home character asset
- Do not redraw, reshape, recolor, crop, or alter facial proportions
- Preserve original star silhouette, eyes, mouth, cheeks, and internal glow
- Home must not use mode-specific clothing

### Home Mode Icons

- `home_icon_chat_v1.png`
- `home_icon_tarot_v1.png`
- `home_icon_zodiac_v1.png`
- `home_icon_meditate_v1.png`
- `home_icon_music_v1.png`

Rules:

- Simple circular icon containers
- Soft 2D / light 2.5D style
- Consistent circle size and visual weight
- Minimal texture
- No heavy shine or excessive glow
- All five icons must render at equal displayed dimensions

## 4. Visual Hierarchy

Attention order:

1. Twinko
2. Five mode entries
3. Background atmosphere
4. Profile button
5. Decorative particles

## 5. Layout Structure

Use a **2–2–1 orbit layout** around Twinko.

- Top-left: Chat
- Top-right: Tarot
- Lower-left: Zodiac
- Lower-right: Meditate
- Bottom-center: Music

Recommended relative positions:

- Chat: approximately 10 o'clock from Twinko
- Tarot: approximately 2 o'clock
- Zodiac: approximately 7–8 o'clock
- Meditate: approximately 4–5 o'clock
- Music: approximately 6 o'clock

Maintain equal visual spacing across left and right pairs.

## 6. Central Twinko Placement

- Asset: `twinko_default_smile_v1.png`
- Default width: approximately `128 pt`
- Responsive range: `112–138 pt`
- Maximum: `145 pt`
- Horizontally centered
- Center Y: approximately `42–45%` of usable screen height

Because the background includes a warm yellow center:

- Add a very subtle pink-purple halo behind Twinko
- Implement the halo as a separate UI layer
- Avoid adding stronger yellow glow
- Keep halo opacity low

## 7. Twinko Idle Motion

### Floating

- Vertical movement: `4–6 pt`
- Duration: `3.5–4.5 seconds`
- Timing: ease-in-out
- Continuous loop

### Breathing glow

- Very subtle aura opacity shift
- Approximate range: `0.85–1.0`
- Do not synchronize perfectly with floating motion

### Subtle scale

- `1.0 → 1.015 → 1.0`
- Must not resemble button pulsing or heartbeat animation

### Reduce Motion

- Disable floating
- Disable scale animation
- Keep static low-intensity glow

## 8. Mode Entry Specification

Recommended dimensions:

- Icon diameter: `68 pt`
- Minimum tap target: `76 × 76 pt`
- Icon-to-label spacing: `6–8 pt`

Small-device fallback:

- Icon diameter: `60–64 pt`
- Preserve 2–2–1 layout
- Do not convert to scrolling or a grid

Labels:

- Chat / 聊天
- Tarot / 塔羅
- Zodiac / 星座
- Meditate / 冥想
- Music / 音樂

Rules:

- Single line
- Center aligned below icon
- Do not wrap
- All labels use consistent size and weight
- Reserve enough width for `Meditate`

## 9. Typography

### English

- Font: **Nunito**
- Recommended weight: `500` or `600`

### Traditional Chinese

- Font: **PingFang TC**
- Recommended weight: `Medium`

Recommended label styling:

- Font size: `15–17 pt`
- Color: warm white or soft cream
- Use only a subtle shadow when required
- Do not use thick outlines

Suggested fallback stack:

```css
font-family: "Nunito", "PingFang TC", "PingFang SC", -apple-system, BlinkMacSystemFont, sans-serif;
```

## 10. Profile Entry

Position and dimensions:

- Top-right only
- No traditional top navigation bar
- No Settings icon on Home
- No title or wordmark in the top area
- Tap target: `44 × 44 pt`
- Visible circle: `36–40 pt`
- Right margin: `16–20 pt`
- Top safe-area spacing: `12–16 pt`

Visual style:

- Lightweight circular control
- Semi-transparent deep purple background
- Soft lavender or warm-white icon
- Minimal shadow
- No continuous glow
- Smaller than mode icons

Default state:

- Use user initial when available
- Otherwise use a generic profile silhouette

## 11. Profile Menu Structure

Tap Profile to open a bottom sheet.

Top-level items:

- Profile
- Settings
- Privacy

Settings submenu:

- Language

Traditional Chinese:

- Profile → 個人資料
- Settings → 設定
- Privacy → 隱私
- Language → 語言

Recommended interaction:

- Modal bottom sheet
- Background softly dimmed or blurred
- Preserve Home context behind the sheet

## 12. Navigation Behavior

Active MVP destinations:

- Chat → Chat screen
- Tarot → Tarot screen
- Zodiac → Horoscope screen

Temporary destinations:

- Meditate → Meditate placeholder page
- Music → Music placeholder page

Do not:

- Display "Coming Soon"
- Gray out the icons
- Reduce opacity
- Disable tap feedback

Placeholder pages should:

- Preserve the same app shell
- Include working back navigation
- Remain minimal and easy to remove later

## 13. Tap Feedback

All five mode icons should use the same feedback:

- Press scale: `0.94–0.96`
- Release to: `1.0`
- Duration: `120–180 ms`
- Optional subtle brightness increase

Avoid rotation, large bounce, or strong glow bursts.

## 14. Background Behavior

Asset:

- `home_screen_v1.png`

Rules:

- Static image for MVP
- Full-screen aspect fill
- No day/night switching
- No Home wordmark
- No dynamic content baked into the asset

Optional UI-layer animation:

- Very subtle star twinkle
- Low frequency
- Non-synchronized
- Must not compete with Twinko

## 15. Localization and Layout Fit

English and Traditional Chinese must be tested in parallel.

Acceptance:

- No clipped labels
- No wrapping
- No overlap with icons
- No overlap with clouds or safe areas
- Same icon placement across languages
- Language changes must not shift Twinko

## 16. Responsive Rules

Larger screens:

- Preserve relative spatial relationships
- Do not over-enlarge Twinko or icons
- Allow more breathing room

Smaller screens:

- Reduce Twinko to `112–118 pt`
- Reduce icons to `60–64 pt`
- Reduce vertical gaps proportionally
- Maintain 2–2–1 structure
- Preserve minimum `44 pt` tap targets

## 17. Accessibility

- All controls require accessible labels
- Support Dynamic Type where practical
- Do not allow Dynamic Type to overlap icons
- Provide Reduce Motion handling
- Maintain sufficient label contrast
- Profile control must remain at least `44 × 44 pt`

Suggested accessibility labels:

- Open Chat
- Open Tarot
- Open Zodiac
- Open Meditate
- Open Music
- Open Profile

Traditional Chinese:

- 開啟聊天
- 開啟塔羅
- 開啟星座
- 開啟冥想
- 開啟音樂
- 開啟個人資料

## 18. Implementation Constraints

Claude Code must not:

- Replace approved visual assets with generic icons
- Regenerate Twinko in code
- Add a Home wordmark
- Add "Coming Soon"
- Add a top navigation bar
- Reintroduce day/night mode
- Change mode names without founder approval
- Use `Horoscope` as the Home label; use `Zodiac`
- Use a rigid card dashboard layout
- Apply heavy glassmorphism, shadows, or glow
- Alter approved asset proportions

## 19. Acceptance Criteria

### Visual

- [ ] `home_screen_v1.png` is used as the background
- [ ] `twinko_default_smile_v1.png` is used in the center
- [ ] Twinko remains the primary visual focus
- [ ] Home does not display `TwinkoTalk`
- [ ] Profile appears only in the top-right
- [ ] Five approved icons are used at equal dimensions
- [ ] Layout follows the 2–2–1 orbit structure
- [ ] Labels use Nunito / PingFang TC
- [ ] English and Traditional Chinese layouts fit without clipping
- [ ] No "Coming Soon" state is shown

### Functional

- [ ] Chat opens Chat
- [ ] Tarot opens Tarot
- [ ] Zodiac opens Horoscope
- [ ] Meditate opens a placeholder page
- [ ] Music opens a placeholder page
- [ ] Profile opens a bottom sheet
- [ ] Settings contains Language
- [ ] Privacy is available from Profile
- [ ] Placeholder pages have functional back navigation
- [ ] Reduce Motion behavior is supported

### Asset integrity

- [ ] Approved images are not redrawn
- [ ] No assets are stretched
- [ ] Transparent PNG assets retain transparency
- [ ] Icons use consistent rendering dimensions
- [ ] Original filenames are preserved

## 20. Open Items

The Home screen is design-complete.

Only implementation calibration remains:

- Final exact spacing on target iPhone sizes
- Final label font size within `15–17 pt`
- Final Profile icon asset or initial-based implementation
- Final placeholder-page copy, if any
