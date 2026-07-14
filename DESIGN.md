# TwinkoTalk DESIGN.md

**Status:** Global implementation source of truth  
**Version:** 1.0  
**Target:** iOS-first MVP  
**Languages:** English + Traditional Chinese  
**Audience:** Claude Code, Fable, designers, and engineers

---

## 0. Operating Rules

### Source priority

When sources conflict, follow this order:

1. Latest founder-approved instruction
2. This `DESIGN.md`
3. Current screen-specific specification
4. Asset manifest
5. Older summaries, mockups, and visual references

### Implementation rules

- Build reusable tokens and components before adding screen-level styling.
- Do not hardcode global colors, typography, radii, shadows, or motion values inside individual views.
- Screen specs may define layout and behavior, but should reuse this global design language.
- Preserve approved image assets exactly. Do not redraw Twinko or approved icons with code.
- Do not expand scope or refactor unrelated working features.

---

# 1. Design Contract

## North star

> **Cute × Premium × Calm**

TwinkoTalk is a soft cosmic companion: warm, magical, trustworthy, and emotionally safe.

### Visual role split

- **Twinko and illustrations:** carry the cuteness and personality.
- **UI components:** remain neutral, calm, polished, and readable.
- **Backgrounds:** may be dreamy and atmospheric.
- **Surfaces:** must create clear hierarchy and reduce visual fatigue.

### Avoid

- Overly pink or candy-colored UI
- Purple on every surface
- Heavy glow or glassmorphism
- Childish game UI
- Plastic, clay, fuzzy, Pixar-like rendering
- Excessive shadows, gradients, or decorative stars
- Mixed icon styles
- Pure black text or cold pure-white surfaces

---

# 2. Color Tokens

## 2.1 Brand colors

| Token | Hex | Use |
|---|---:|---|
| `brandPurple` | `#A88BFE` | Canonical brand purple, highlights, active states |
| `brandPurpleDeep` | `#7B65D1` | CTA gradient end, pressed states |
| `brandPurpleMuted` | `#8E7AE6` | Solid purple controls and selected states |
| `twinkoYellow` | `#FFD84A` | Twinko, stars, magical highlights |
| `accentGold` | `#D9A441` | Send, compact confirm actions, premium accents |
| `accentGoldPressed` | `#C28E32` | Pressed gold action |
| `warningCoral` | `#E9777E` | Warning and emotionally important alerts |
| `warningCoralPressed` | `#D96871` | Pressed warning state |
| `emotionalCoralSoft` | `#F4A39B` | Low-severity emotional emphasis |

## 2.2 Neutral and surface colors

| Token | Hex | Use |
|---|---:|---|
| `deepSpace` | `#151326` | Tarot, deep scenes, dim layers |
| `deepPlum` | `#2C2347` | Primary text, dark icons |
| `overlayDeep` | `#312552` | Modal overlay and deep panels |
| `menuDeep` | `#3E2C73` | Menus and floating panels |
| `surfacePrimary` | `#FFFDF8` | Main warm-ivory surface |
| `surfaceSecondary` | `#F7F1FC` | Pale-lilac secondary surface |
| `surfaceInput` | `#FEFBF7` | Inputs and composer |
| `surfaceSelected` | `#F0E8F8` | Selected or hover surface |
| `borderSoft` | `#DCCAF2` | Borders and dividers |
| `borderStrong` | `#CDBDE8` | Focused or interactive borders |

## 2.3 Text colors

| Token | Hex | Use |
|---|---:|---|
| `textPrimary` | `#2C2347` | Main text on light surfaces |
| `textSecondary` | `#6F6385` | Supporting text |
| `textMuted` | `#8F7FA8` | Placeholder and metadata |
| `textInverse` | `#FFFDF8` | Text on dark or purple surfaces |
| `textDisabled` | `#A79CB9` | Disabled content |
| `linkPurple` | `#6D5CC8` | Links and interactive text |

## 2.4 Semantic colors

| Token | Hex | Use |
|---|---:|---|
| `success` | `#7FA68A` | Success confirmation |
| `info` | `#7188B8` | Informational status |
| `warning` | `#E9777E` | Warning |
| `destructive` | `#C95F68` | Delete and destructive actions |

### Color usage ratio

Target overall balance:

- 35% warm ivory and neutral light surfaces
- 25% purple family
- 20% deep plum / dark contrast
- 10% soft lilac
- 5% gold
- 5% Twinko Yellow and magical highlights

### Hard rules

- Do not use `twinkoYellow` as the global Primary CTA.
- Do not place purple surfaces on top of purple backgrounds without a neutral separator.
- Use warm ivory for high-reading surfaces such as chat bubbles, sheets, forms, and history rows.
- Gold is an accent, not a general button color.
- Coral is semantic, not decorative.

---

# 3. Gradients

## 3.1 Primary CTA gradient

```text
Start: #A88BFE
End:   #7B65D1
Direction: 135°
```

Use for Primary CTA only.

## 3.2 Brand ambient gradient

```text
Top:    #A88BFE
Middle: #C9A6E8
Bottom: #F2B0A5
```

Use only for backgrounds, ambient panels, and marketing moments. Do not place behind long-form text without a neutral surface.

## 3.3 User chat bubble gradient

```text
Top:    #8E7AE6
Bottom: #7460CC
Direction: vertical
```

Subtle only. A solid `#7460CC` fallback is acceptable.

## Gradient rules

- Maximum two color stops for components.
- Avoid yellow-purple gradients in standard UI.
- Do not use gradients on warning, destructive, or disabled components.
- Do not apply gradients to every card.

---

# 4. Typography

## Font families

- Latin / English: **Nunito**
- Traditional Chinese: **PingFang TC**
- Fallback: `-apple-system`, `BlinkMacSystemFont`, `sans-serif`

## Type scale

| Style | Size | Line height | Weight |
|---|---:|---:|---:|
| `display` | 32 pt | 40 pt | 700 |
| `title1` | 24 pt | 32 pt | 700 |
| `title2` | 20 pt | 28 pt | 600 |
| `headline` | 17 pt | 24 pt | 600 |
| `body` | 16 pt | 24 pt | 500 |
| `bodySmall` | 14 pt | 20 pt | 500 |
| `label` | 14 pt | 20 pt | 600 |
| `caption` | 12 pt | 16 pt | 500 |

## Typography rules

- Use semantic styles instead of screen-specific font values.
- Avoid weights above 700.
- Body copy is normally left aligned.
- Do not use more than two text weights in one component.
- Use `textPrimary`, not pure black.
- Use `textInverse`, not pure white, on dark surfaces.
- Test English and Traditional Chinese in parallel.
- Text must not be baked into image assets.

---

# 5. Spacing and Layout

## Base grid

Use a 4 pt grid:

```text
4, 8, 12, 16, 20, 24, 32, 40, 48
```

## Standard spacing

| Token | Value |
|---|---:|
| `space1` | 4 pt |
| `space2` | 8 pt |
| `space3` | 12 pt |
| `space4` | 16 pt |
| `space5` | 20 pt |
| `space6` | 24 pt |
| `space7` | 32 pt |
| `space8` | 40 pt |
| `space9` | 48 pt |

## Layout defaults

- Screen horizontal margin: `16–20 pt`
- Section spacing: `24–32 pt`
- Component gap: `8–12 pt`
- Card internal padding: `16–20 pt`
- Minimum interactive target: `44 × 44 pt`
- Respect safe areas on all screens.

---

# 6. Radius

| Token | Value | Use |
|---|---:|---|
| `radiusSm` | 12 pt | Small controls |
| `radiusMd` | 18 pt | Rows and compact cards |
| `radiusLg` | 22 pt | Cards and chat bubbles |
| `radiusXl` | 26 pt | Buttons and inputs |
| `radiusSheet` | 28 pt | Bottom sheets |
| `radiusFull` | 999 pt | Pills and circles |

Do not invent new radii per screen unless a screen spec explicitly requires it.

---

# 7. Borders, Shadows, and Glow

## Borders

- Default border: `1 pt borderSoft`
- Focused / selected border: `1–2 pt borderStrong`
- Avoid dark borders on light surfaces.
- Avoid borders and heavy shadows on the same component.

## Shadows

```text
shadowSmall:
0 2 8 rgba(15, 17, 37, 0.08)

shadowMedium:
0 6 20 rgba(15, 17, 37, 0.12)

shadowFloating:
0 12 32 rgba(15, 17, 37, 0.16)
```

Use neutral shadows, not purple shadows, for standard UI.

## Twinko glow

```text
Inner:
warm yellow-white
opacity 18–26%
blur 18–24 pt

Outer:
pink-lavender
opacity 8–14%
blur 30–42 pt
```

## Glow rules

- Twinko may glow.
- Standard cards, bubbles, sheets, and buttons do not glow.
- Selected magical states may use a maximum 10–12% glow opacity.
- Prefer shadow over glow.
- Never make all components glow simultaneously.

---

# 8. Interaction States

## Platform rule

Hover is secondary and only applies to:

- iPad pointer
- Web prototype
- Desktop preview
- Figma interactive reference

For iPhone, prioritize:

- Pressed
- Selected
- Focus
- Disabled

## Pressed

- Scale: `0.96–0.98`
- Duration: `120–160 ms`
- Reduce shadow
- No large bounce or overshoot

## Focus

```text
Ring: 2 pt
Color: rgba(142, 122, 230, 0.55)
Offset: 2 pt
```

## Selected

Use no more than two signals:

- Purple border
- Soft-lilac surface
- Small gold/yellow indicator

Do not combine border, glow, scale, and badge at once.

## Disabled

- No shadow or glow
- Background: `#D9D2E8`
- Text/icon: `#A79CB9`
- Maintain readability
- Do not rely on opacity alone

## Hover definitions

### Primary CTA

```text
Gradient: #B39CFF → #8974DE
Translate Y: -1 pt
Shadow: 0 10 24 rgba(63, 43, 109, 0.22)
Duration: 140–180 ms
```

### Secondary button

```text
Background: #F0E8F8
Border: #CDBDE8
Text: #2C2347
```

### Card

```text
Background: #FFFDF8
Border: rgba(142, 122, 230, 0.35)
Translate Y: -1 pt
Shadow: shadowMedium
```

### Icon button

```text
Background: rgba(168, 139, 254, 0.12)
Icon: #6D5CC8
```

---

# 9. Buttons

## 9.1 Primary CTA

```text
Height: 52 pt
Radius: 26 pt
Horizontal padding: 20–24 pt
Background: Primary CTA gradient
Text: textInverse
Typography: headline
Shadow: 0 8 20 rgba(63, 43, 109, 0.18)
```

Pressed:

- Scale `0.97`
- Darken gradient approximately 6%
- Reduce shadow

Use for one highest-priority action per view.

## 9.2 Secondary button

```text
Height: 48–52 pt
Radius: 24–26 pt
Background: surfaceSecondary
Text: textPrimary
Border: 1 pt borderSoft
Shadow: none
```

## 9.3 Tertiary / ghost button

```text
Background: transparent
Text: linkPurple
Minimum height: 44 pt
```

## 9.4 Gold action button

```text
Background: accentGold
Pressed: accentGoldPressed
Text/icon: textInverse
```

Use only for:

- Send
- Compact confirm actions
- Selected magical action

Do not use for full-width general navigation.

## 9.5 Warning button / badge

```text
Background: warningCoral
Pressed: warningCoralPressed
Text/icon: textInverse
Border: none
```

Use only for warning or emotionally important alerts.

## 9.6 Destructive button

```text
Background: destructive
Text: textInverse
```

Require confirmation for irreversible actions.

---

# 10. Icon Buttons

```text
Minimum tap target: 44 × 44 pt
Visible control: 36–40 pt
Radius: radiusFull
Default background: rgba(255, 253, 248, 0.72) or transparent
Icon: deepPlum or linkPurple
```

- Use simple rounded line icons.
- Approximate stroke: 2 pt.
- Do not mix decorative feature icons with system icons at the same hierarchy.
- Press scale: `0.94–0.96`.

---

# 11. Inputs

## Text field / composer

```text
Minimum height: 52 pt
Maximum multiline height: 140 pt
Radius: radiusXl
Background: surfaceInput
Border: 1 pt borderSoft
Text: textPrimary
Placeholder: textMuted
Internal horizontal padding: 16–20 pt
```

Focused:

```text
Border: 2 pt brandPurpleMuted
Focus ring: defined global focus style
```

Error:

```text
Border: 1–2 pt warningCoral
Supporting text: destructive
```

Rules:

- Inputs do not glow.
- Keyboard must not cover active fields.
- Preserve entered data during navigation where appropriate.

---

# 12. Cards and List Rows

## Standard card

```text
Background: surfacePrimary
Radius: radiusLg
Padding: 16–20 pt
Border: optional 1 pt borderSoft
Shadow: shadowSmall
```

## Secondary card

```text
Background: surfaceSecondary
Radius: radiusLg
Shadow: none or shadowSmall
```

## List row

```text
Minimum height: 56 pt
Radius: radiusMd
Background: surfacePrimary
Horizontal padding: 16 pt
```

Rules:

- Do not place large blocks of pink-purple behind text.
- Use warm ivory for content-heavy cards.
- Use purple primarily for active, branded, or selected states.

---

# 13. Bottom Sheets and Modals

```text
Surface: surfacePrimary or surfaceSecondary
Top radius: radiusSheet
Handle: textMuted at low opacity
Background dim: 20–28%
Background blur: 8–12 pt where supported
Shadow: shadowFloating
```

- Prefer content-aware height.
- Avoid large unused blank space.
- Do not use pure system white.
- Use custom rows/cards instead of default grouped-list styling when a branded presentation is required.

---

# 14. Navigation and Headers

## Standard header

- Left: Back or contextual action
- Center: page title
- Right: one primary contextual action
- Minimum control target: `44 × 44 pt`
- Title: `title2` or `headline`
- Avoid crowded headers.
- Avoid persistent wordmarks inside feature screens.

---

# 15. Chat Components

## Twinko bubble

```text
Background: #FFFBF6
Text: textPrimary
Border: optional 1 pt #E9DCF7
Radius: radiusLg
Shadow: shadowSmall
Max width: 75–78%
```

## User bubble

```text
Background: user bubble gradient or #7460CC
Text: textInverse
Radius: radiusLg
Shadow: shadowSmall
Max width: 72–75%
```

## Chat avatar

- Use approved Twinko asset.
- Size: `28–34 pt`
- Show only at the first message of a consecutive Twinko message group.

## Composer send button

- Use `accentGold`.
- Pressed: `accentGoldPressed`.
- Do not use bright yellow.

## Chat visual rule

Dreamy backgrounds are allowed, but bubbles and composer must remain neutral and readable to prevent purple/pink visual fatigue.

---

# 16. Chips, Tags, and Status

## Default chip

```text
Height: 32–36 pt
Radius: radiusFull
Background: surfaceSecondary
Text: textPrimary
Border: optional borderSoft
```

## Selected chip

```text
Background: surfaceSelected
Border: brandPurpleMuted
Text: deepPlum
Optional small gold indicator
```

## Status indicator

- Success/online: `success`
- Info: `info`
- Warning: `warningCoral`
- Do not use Twinko Yellow for every status.

---

# 17. Twinko Character Rules

- Use approved canonical PNG assets only.
- Never redraw Twinko with SwiftUI shapes, Canvas, SF Symbols, emoji, or generated vectors.
- Preserve silhouette, face, cheeks, eye highlights, color, and proportions.
- No separate human body.
- No explicit hands or feet unless a founder-approved asset includes them.
- Use soft 2D with very light dimensionality.
- Avoid plastic, clay, fuzzy, glossy, or realistic materials.
- Character outfits must not reshape the canonical body.
- Twinko is the main source of cuteness; surrounding UI remains restrained.

---

# 18. Illustration and Icon Style

## Feature icons

- Simple circular container
- Low-detail symbol
- Soft 2D / light 2.5D
- Consistent visible size and weight
- No heavy texture or glow
- Preserve approved assets

## Illustrations

- Rounded shapes
- Soft gradients
- Minimal detail
- Calm composition
- No anime, Pixar, plastic, or realistic rendering

---

# 19. Background System

## Home

- Most open and magical
- Purple, warm peach, yellow glow, clouds
- UI cluster remains the focal point

## Chat

- Softer and calmer
- Dreamy background allowed
- Neutral bubbles and composer required

## Tarot

- Deep Space, restrained purple, controlled gold
- More mysterious, never visually noisy

## Zodiac

- Cosmic but restrained
- Purple, deep plum, subtle highlights

## Profile / Settings / Privacy

- Neutral surfaces first
- Minimal decorative background
- Reading and information hierarchy take priority

### Rule

> The more reading or decision-making a screen requires, the quieter its background must be.

---

# 20. Motion

## Principles

- Slow
- Soft
- Low amplitude
- Calm
- No gaming-style bounce

## Tokens

| Motion | Duration |
|---|---:|
| `fast` | 120–160 ms |
| `standard` | 200–260 ms |
| `sheet` | 250–320 ms |
| `twinkoFloat` | 3.5–4.5 s |

## Twinko idle motion

- Vertical movement: `4–6 pt`
- Scale: maximum `1.015`
- Ease in/out
- No rotation
- Respect Reduce Motion

## Reduce Motion

- Disable floating, parallax, and scale loops.
- Preserve static glow only.

---

# 21. Localization

- Support English and Traditional Chinese in parallel.
- Localize labels, values, dates, zodiac signs, gender values, placeholders, errors, and confirmations.
- Store canonical values; localize only the displayed text.
- Do not persist translated strings as data values.
- Switching language must update visible UI immediately.
- Do not allow mixed-language screens.

---

# 22. Accessibility

- Minimum tap target: `44 × 44 pt`
- Support Dynamic Type where practical.
- Prevent text clipping and overlap.
- Provide accessibility labels for all icon-only controls.
- Maintain readable contrast.
- Never communicate state through color alone.
- Support Reduce Motion.
- Test on small and large iPhones.

---

# 23. Engineering Architecture

Claude Code should create or maintain reusable centralized definitions equivalent to:

```text
TwinkoColors
TwinkoGradients
TwinkoTypography
TwinkoSpacing
TwinkoRadius
TwinkoShadow
TwinkoMotion
TwinkoButtonStyle
TwinkoInputStyle
TwinkoCardStyle
TwinkoSheetStyle
```

Rules:

- Use semantic names, not raw color names inside views.
- Screen files should consume shared tokens.
- Do not duplicate token values.
- Approved asset filenames must remain unchanged.
- Do not add new visual libraries unless necessary.

---

# 24. Validation Checklist

Before completing any UI task, verify:

- [ ] Global tokens are reused instead of hardcoded.
- [ ] The screen follows Cute × Premium × Calm.
- [ ] UI is not overwhelmingly pink or purple.
- [ ] Reading surfaces use warm ivory or neutral light colors.
- [ ] Yellow is reserved for Twinko and limited magical highlights.
- [ ] Gold is used sparingly.
- [ ] Warning uses `#E9777E`.
- [ ] Primary CTA uses the approved purple gradient.
- [ ] Hover is implemented only where pointer interaction exists.
- [ ] Pressed, selected, focus, and disabled states are present.
- [ ] Radii and spacing use global tokens.
- [ ] Standard UI does not glow.
- [ ] Twinko uses approved canonical assets.
- [ ] English and Traditional Chinese both pass.
- [ ] Accessibility and Reduce Motion are supported.
- [ ] Unrelated screens and working flows were not changed.

---

# 25. Current Screen Specs

This global file governs visual language. Screen-specific layout and behavior remain in:

```text
TWINKOTALK_HOME_SCREEN_SPEC.md
TWINKOTALK_CHAT_SCREEN_SPEC.md
```

Future screen specs should reference this file rather than redefining global colors, typography, radii, shadow, glow, and motion.

---

# 26. Chat Polish Components (v1.1)

Appended after the Chat visual-polish pass (2026-07-15). These are
canonical component rules, additive to the sections above — nothing
prior is removed or superseded except where explicitly noted.

## 26.1 Avatar Container

A shared circular frame used everywhere a chat avatar appears against
an illustrated background, so the character never blends into the art.

```text
Container size:   36–40 pt (default 38 pt)
Shape:            perfect circle
Background:       surfacePrimary (#FFFDF8)
Border:           1 pt borderSoft (#DCCAF2)
Shadow:           shadowSmall
Glow:              none
Badge / ring:      none
Inner asset size: 28–32 pt, centered, aspect preserved, never cropped
```

Component: `TwinkoChatAvatar`. Shown only on the first message of a
consecutive Twinko message group — never repeated per message.

## 26.2 Chat Avatar Rules

- Twinko's chat avatar is always wrapped in the Avatar Container (26.1).
- One canonical smiling Day/Night expression per MVP; no animated or
  alternate expressions while Twinko wears an outfit (existing
  expression library assumes no clothing — mixing the two breaks
  consistency). Revisit once outfit-specific expressions exist.
- Active Chat header carries no persistent avatar and no online
  indicator — only Back, title, and the star quick-menu control.

## 26.3 Branded Modal

Shared shell for every popup that needs confirmation or input —
Rename, Delete, and future confirmations (profile editing, etc.).
Replaces native `UIAlertController` / SwiftUI `Alert` /
`confirmationDialog` chrome everywhere in Chat.

```text
Scrim:      deepSpace, opacity 35–45%
Layout:     centered, floating above content
Width:      84–88% of screen width
Surface:    surfacePrimary
Radius:     28 pt
Padding:    20–24 pt
Shadow:     shadowFloating
Optional icon: 52 pt circle, semantic tint background at 14% opacity
Buttons:    Cancel (ghost / surfaceSecondary) + Confirm (primary or destructive)
```

Component: `BrandedModal`. Every dialog, sheet, and floating menu in
the app should converge on this component family rather than
introducing a new popup style per screen.

## 26.4 Rename Modal

Uses Branded Modal (26.3) with no icon.

```text
Title:   "Rename Conversation" / 「重新命名對話」
Input:   surfaceInput background, 1 pt borderSoft border, prefilled
         with the current title
Cancel:  ghost / secondary
Save:    primary purple gradient (brandPurple → brandPurpleDeep)
         disabled while the trimmed input is empty (inline validation
         only — no separate error alert)
```

## 26.5 Delete Modal

Reuses the exact same Branded Modal shell as Rename — no separate
dialog style.

```text
Icon:    exclamationmark.triangle.fill, destructive tint, 14% tint background
Title:   deleteConfirmTitle ("Delete this conversation?" / 「刪除這段對話？」)
Body:    deleteConfirmBody ("This can't be undone." / 「刪除後無法復原。」)
Cancel:  ghost / secondary
Delete:  destructive (#C95F68), no gradient
```

## 26.6 Composer States

Send button, circular, 44×44 pt tap target:

```text
Disabled:
  Background: #E8D6A7, opacity 55–65%
  Icon:       #FFFDF8
  Shadow:     none

Enabled:
  Background: #D9A441
  Icon:       #FFFDF8
  Shadow:     shadowSmall

Pressed:
  Background: #C28E32
  Scale:      0.95
  Animation:  120–160 ms ease-out
```

State updates immediately as composer text changes (no debounce).

## 26.7 Star Menu

The existing quick-menu treatment is canonical — carried forward
unchanged, documented here for reference:

```text
Overlay:    deepSpace, opacity 35–45%, blocks background interaction
Surface:    menuDeep, floating, rounded corners, shadowFloating
Contents:   exactly two rows — New Chat, History — icon + title only,
            no subtitles or extra descriptions
Close:      circular control below the panel, or tap the scrim
```

## 26.8 Chat History Row

- Title takes layout priority over the trailing relative-time label so
  it can display roughly 12–14 Traditional Chinese characters (or the
  Latin equivalent) before truncating, matching the auto-title
  generator's own truncation limit.
- Three-dot overflow menu keeps a 44×44 pt touch target regardless of
  visual icon size.
- No decorative filler content in empty rows.
