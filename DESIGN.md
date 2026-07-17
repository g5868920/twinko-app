# TwinkoTalk DESIGN.md

**Status:** Global implementation source of truth  
**Version:** 2.0  
**Target:** iOS-first MVP  
**Languages:** English + Traditional Chinese  
**Audience:** Claude Code, Fable, designers, and engineers

**Document structure (v2.0):** This file now has two layers.
**Part I — Twinko World Canonical Visual Direction** is the highest-level
framework: the art direction, world rules, and material/motion philosophy
every screen inherits. **Part II — Implementation Tokens & Components** is
the concrete token, component, and behavior layer beneath it (the original
`DESIGN.md §1–§26`, section numbers preserved so existing `DESIGN.md §xx`
references in code and specs keep resolving). When Part II detail and Part I
direction ever disagree, Part I direction governs the intent and Part II
governs the exact values.

---

## 0. Operating Rules

### Source of truth and priority

When design instructions conflict, follow this order:

1. Latest explicit founder instruction
2. This `DESIGN.md` (Part I direction over Part II detail on matters of intent)
3. Current feature-specific specification
4. Current asset manifest
5. Existing implementation
6. Archived references and earlier mockups

Feature specifications may refine layout or interaction, but must not
introduce a visual language that contradicts this document.

### Originality

Do not reproduce a reference artwork's or animation studio's proprietary
style. References may inform atmosphere, softness, dimensionality, lighting,
and emotional tone only. Final output must remain recognizably original to
Twinko. When a reference image conflicts with this document, treat the
reference as inspiration only and follow this document.

### Implementation rules

- Build reusable tokens and components before adding screen-level styling.
- Do not hardcode global colors, typography, radii, shadows, or motion values inside individual views.
- Screen specs may define layout and behavior, but should reuse this global design language.
- Preserve approved image assets exactly. Do not redraw Twinko or approved icons with code.
- Do not use unapproved raster artwork as a permanent substitute (temporary, clearly-labeled placeholders that are swappable 1:1 are acceptable until final assets arrive).
- Do not expand scope or refactor unrelated working features.

---

# PART I — Twinko World Canonical Visual Direction

Part I is the canonical framework. Every screen and asset must read as part
of one connected companion world. The detailed tokens in Part II implement
this direction; they do not override it.

## North Star

Product personality (unchanged):

> **Cute × Premium × Calm**

World style:

> **Soft Atmospheric 3D Cosmic Companion World** — 柔霧立體宇宙陪伴世界

Visual expression of that personality:

> **Dreamy × Healing × Atmospheric × Cosmic × Soft 3D**

TwinkoTalk should feel like a healing universe a user can emotionally enter —
not an app decorated with stars. The world should feel: cute but not childish;
dreamy but still readable; dimensional but not photorealistic; premium but not
cold or corporate; magical but not visually noisy; calm but not empty;
emotionally warm and safe.

## Core Experience Principle

TwinkoTalk is one connected companion universe, not a set of unrelated feature
pages:

- **Home** — where the user meets Twinko
- **Chat** — a warm private space for conversation
- **Explore** — the map of the wider Twinko universe
- **My Planet** — the user's personal world
- **Meditation** — a quiet moonlit sanctuary
- **Tarot** — a mystical but gentle guidance space
- **Horoscope** — a celestial reflection space
- **Music** — an ambient healing space
- **Activities** — connects the Twinko universe to real-world experiences

Every screen may have its own mood, but all must look as if they belong to the
same animated world.

## Five Global Design Principles

1. **Backgrounds are environments, not decorations.** Use fore/middle/background
   depth, atmospheric perspective, soft rounded terrain/clouds/planets/windows,
   restrained lighting direction, mist and glow, and intentional negative space
   for UI. Avoid plain gradients with random stars, generic stock space,
   photorealistic astronomy, backgrounds detailed everywhere, or scenery that
   competes with text and controls.
2. **Twinko is a soft 3D luminous companion.** Softly dimensional, rounded and
   huggable, gently luminous, warm, slightly plush-like rather than plastic,
   simple-faced, consistent in proportion across features. Never flat/sticker,
   never a highly reflective toy figurine, never furry, never photorealistic,
   never sharply outlined, never re-proportioned per screen.
3. **Icons are magical objects from the same world.** They need not have faces
   or look like Twinko, but they share rounded geometry, soft dimensional
   lighting, restrained highlight, subtle depth, common bounding boxes,
   coherent weight, and one rendering family.
4. **UI floats inside the world.** The interface is suspended within the
   environment via translucent glass, soft blur, pale borders, gentle inner
   highlights, restrained shadows, and floating speech bubbles — not large
   opaque white rectangles, iOS-Settings lists as the main structure,
   card-in-card stacks, flat gray system surfaces, or panels that hide the
   background.
5. **Premium means storybook premium.** Quality comes from art direction,
   spacing, material consistency, gentle depth, controlled color, refined
   transitions, and a coherent illustration language — not cold black-and-gold
   luxury, hard metallic surfaces, excessive glassmorphism, tiny formal type,
   realistic sci-fi interfaces, or visual complexity.

## Visual DNA

- **Shape:** rounded silhouettes, pills, soft rectangles, circles/orbs, organic
  curves, generous radii. Avoid sharp corners, angular sci-fi panels, aggressive
  diagonals, mechanical frames, dense geometric grids.
- **Light:** diffused light, soft rim light, subtle internal glow, warm-gold
  magical accents, gentle shadow separation, atmospheric bloom. Glow is reserved
  for Twinko, selected states, magical moments, recommended actions, and
  celestial objects — standard UI must not continuously glow.
- **Surface:** one hierarchical set — primary atmospheric glass, secondary
  lavender glass, warm-ivory speech glass, interactive purple glass, floating
  orb controls (see Glass Material System below). Do not mix many unrelated
  material recipes on one screen.
- **Depth:** soft gradients, low-contrast shadows, consistent-direction
  highlights, overlap, atmospheric scale, slight blur on distant layers — not
  strong drop shadows or hard 3D extrusion.

## Illustration and Rendering Style

Illustrations are **soft atmospheric 3D or polished 2.5D**: stylized rather than
realistic, rounded, slightly storybook-like, softly textured, emotionally
calming, rich in depth but simple in form.

Avoid: ultra-realistic planets or space photography; flat vector art with no
volume; glossy plastic-toy rendering; hard cel shading; thick black outlines;
hyper-detailed fantasy scenes; mismatched realism levels; a different
illustration style per feature.

> **Rendering-direction note (supersedes earlier "soft 2D only" guidance).**
> Earlier versions of this document asked for flat soft-2D rendering and banned
> "Pixar-like / plush / clay" looks. The canonical direction now embraces soft
> dimensional, storybook, slightly plush-not-plastic rendering. The enduring
> bans are on *photorealism*, *glossy plastic toy* looks, and *hard cel /
> heavy-outline* styling — not on gentle dimensionality.

References may guide dimensional softness, rounded landscape language,
atmospheric color, mist, depth, and calm tone — never character design, exact
environments, architecture, composition, or proprietary motifs.

## Mascot Language vs. World Language

**Mascot (Twinko only):** rounded five-point-star body, warm-yellow body, glossy
dark eyes with highlights, soft cheeks, simple friendly mouth, feature-specific
clothing/accessories, stronger emotional expression, subtle body glow, gentle
float. Twinko is the most expressive, emotionally alive element on screen.
(Implementation rules for the canonical Twinko asset are in Part II §17.)

**World (UI, icons, planets, objects):** inherit rounded form, soft lighting,
subtle glow, pastel-cosmic palette, dimensional highlights, gentle shadows — but
do **not** inherit Twinko's face, cheeks, exact star shape, or full mascot
proportions. Not every object should become another character.

## Background Family

All backgrounds are one coherent family: soft atmospheric depth, rounded
environmental forms, gentle mist/glow, stylized 3D or 2.5D rendering, controlled
detail, clear UI-safe zones, coherent lighting. Backgrounds carry no production
UI text, buttons, or navigation.

Governing rule (carried from the original background system):

> **The more reading or decision-making a screen requires, the quieter its
> background must be.**

| Space | Purpose & direction | Canonical asset |
|---|---|---|
| **Home** | Warmth, reassurance, invitation. Warm cosmic sky; purple/pink/peach/soft-gold; rounded cloud hills; central warm light; open space for Twinko and UI; welcoming rather than mystical. | `bg_home_screen_v2` |
| **Chat** | Intimacy and emotional safety. Dreamy indoor-outdoor companion space; soft pink/lilac/peach/warm light; window, curtains, clouds; gentle storybook dimensionality; low visual noise; warmest environment in the product. | `chat_v1` |
| **Explore** | Curiosity and cosmic discovery. Darker than Home/Chat; deep indigo/blue-violet/restrained nebula; stylized not realistic; dark quiet center so interactive planets can glow; no large bright background planets competing with feature planets. | `bg_explore_v1` (replaceable if its rendering conflicts with this direction) |
| **My Planet** | Ownership, reflection, memory, growth. Blue-green/teal/violet/soft luminous white; dreamlike personal-planet surface; rounded hills, memory paths, stations; soulful, quiet but not lonely. | `bg_my_planet_v1` |
| **Meditation** | Silence, regulation, rest. Deep blue/blue-violet/moonlight/clouds/soft haze; less UI density; slow rhythm; calm negative space; minimal background movement. | — |
| **Tarot** | Reflection, mystery, guidance. Purple/plum/restrained warm gold; celestial altar, moonlight, cards, soft architecture; mystical without becoming dark, threatening, or occult-heavy; keep softness. | — |
| **Horoscope** | Celestial perspective and daily reflection. Deep violet/blue; luminous zodiac detail; fewer decorative layers than dense current implementations; clear card hierarchy; soft glow over heavy gold ornamentation. | — |
| **Music** | Ambient healing space. Calm, low-density, atmospheric — same family, quiet rhythm. | — |
| **Profile / Settings / Privacy** | Reading and decision-making first. Neutral surfaces, minimal decorative background, information hierarchy takes priority. | — |

Do not use the old detailed My Planet raster artwork (`home_my_planet_v1`) as
the bottom-navigation icon; the raster remains valid as the My Planet
identity/background artwork elsewhere.

## Icon System

All production icons use one visual family: the same perceived bounding box,
consistent stroke/fill weight, one highlight direction, similar dimensional
depth, readable at small sizes, transparent backgrounds when delivered as
assets, and no baked-in production text.

Two approved construction methods (do not mix randomly within one component
family):

- **A. Soft 3D object icon** (prominent feature icons): rounded dimensional
  object, soft gradient, restrained highlight, subtle shadow, one small magical
  accent.
- **B. Simplified cosmic line/fill icon** (small controls): rounded strokes,
  consistent weight, minimal fill, restrained star accent, no excess detail.

**Bottom navigation** must be especially consistent: Home = rounded home with a
small star; Chat = rounded speech bubble with a subtle star; Explore = a
recognizable small spaceship / cosmic navigator; My Planet = a simplified planet
and ring. Do **not** use a paper-plane icon for Explore, a detailed raster
illustration for My Planet, unrelated SF Symbols without customization, or
inconsistent icon sizes.

> Practical construction dimensions (tap targets, visible control size, press
> scale) live in Part II §10 and §18; SF Symbols are acceptable only as a base
> that is customized into this family, never raw at feature hierarchy.

## Glass Material System

Glass supports the world; it never becomes the world. Five hierarchical tiers —
concrete surface/opacity/border tokens are in Part II (§7 borders/shadows, §12
cards, §13 sheets):

1. **Primary atmospheric glass** — daily check-in, major information containers,
   key grouped controls. Medium translucency, environmental color visible
   underneath, soft lilac-white border, subtle internal highlight, low-contrast
   shadow.
2. **Secondary lavender glass** — journey cards, suggestion cards, search fields,
   history items, supporting content. Lighter weight, less blur, quieter border,
   restrained depth.
3. **Warm speech glass** — Twinko speech bubbles and emotionally supportive
   content. Warm ivory-lilac tint, high text readability, softer than system
   cards, clear speech-bubble relationship to Twinko.
4. **Interactive purple glass** — primary CTA, selected states, active tab
   indicator, important controls. Saturated but calm purple, subtle dimensional
   highlight, readable warm-white text, restrained gold accent when appropriate.
5. **Floating orb glass** — feature icons, top controls, compact navigation
   objects. Circular, transparent dimensional surface, soft highlight and
   border, limited glow.

Do not: stack visible glass panels inside each other without need; use one
opacity for every hierarchy; turn all containers white; use dark-gray
native-sheet styling; blur every element; or make text contrast depend on blur
alone. (This clarifies the earlier blanket "avoid glassmorphism" rule — the goal
is *disciplined, hierarchical* glass, not the removal of glass.)

## Color Roles

Roles below are semantic; the exact approved hex tokens are canonical in
Part II §2 and must be used ("use existing color tokens where applicable"):

- **Purple** — primary interaction, selected state, companion-world system color
- **Yellow / Gold** — Twinko, magical accent, emphasis, stars
- **Lilac** — borders, secondary glass, quiet states
- **Coral / Peach** — emotional warmth, supportive accents
- **Deep blue / indigo** — environmental depth and immersive feature backgrounds
- **Teal / blue-green** — My Planet and reflective spaces

No feature should invent a new dominant palette. (See the color-usage ratio and
hard rules in Part II §2.)

## Typography

Friendly, readable, rounded, conversational, emotionally clear — Nunito
(Latin) + PingFang TC (Traditional Chinese). Avoid formal serif in production UI,
very thin weights over illustrated backgrounds, excessive size variation, and
decorative body fonts. Exact type scale and weights are in Part II §4.

## Motion Language

Motion should feel like breathing, drifting, glowing, or gently travelling.

- **Twinko float:** ~4–8 pt vertical, ~2.8–3.5 s, ease-in-out, repeating, subtle.
- **Planet / object float:** ~3–6 pt, ~3.5–5.5 s, slightly varied timing, no
  synchronized bouncing.
- **Glass selection:** smooth moving capsule/highlight, ~220–320 ms, no snapping
  or springy game bounce.
- **Selected state:** gentle halo, slightly brighter border, small scale, brief
  sparkle, light haptic — restrained, not all at once.
- **Magical transitions:** restrained blue-purple sparkle, short light trail,
  soft shimmer, gentle fade/zoom.

Avoid rapid spinning, aggressive bounce, large particle bursts, continuous
emitters, constant pulsing, and long blocking animations. Every nonessential
float/orbit/shimmer/travel effect must have a Reduce Motion fallback (static,
fade, cross-dissolve, or minimal opacity breathing). Concrete duration tokens
are in Part II §20; those tokens have been updated to match this direction.

## Feature Consistency Rules

Each feature may have its own mood but must keep the same rendering family,
rounded DNA, dimensional softness, icon system, Twinko proportions, motion
philosophy, and material hierarchy. A screen is not approved merely because it
is individually attractive — it must also look as if it belongs to the Twinko
universe.

## Global Do and Don't

**Do:** build environments with atmospheric depth; keep Twinko the emotional
focus; use soft 3D / polished 2.5D rendering; make UI float inside the
environment; use rounded magical objects over generic system icons; use glass
sparingly and hierarchically; preserve breathing space; make selected states
clear but restrained; keep screens calm and emotionally approachable; ensure all
features share one visual DNA.

**Don't:** imitate a specific studio or copyrighted scene; use photorealistic
space imagery; combine realistic planets with flat system icons; create a
different illustration style per screen; use plain iOS Settings lists as the
primary experience; use large opaque white cards throughout; make every element
glow; turn every icon into a face; use hard sci-fi panels; use cold corporate
luxury styling; use excessive candy gradients; add decoration that weakens
usability; or prioritize a pretty mockup over readable production UI.

## Claude Code Enforcement

Before any visual change: (1) read this `DESIGN.md`; (2) identify which
canonical world rules apply; (3) inspect the current feature spec; (4) preserve
working functionality; (5) make the minimum code changes; (6) do not introduce a
new visual language; (7) do not use unapproved raster art as a permanent
substitute; (8) reuse existing tokens/components; (9) validate consistency with
adjacent Twinko screens; (10) run only the directly required minimal validation
unless the change affects shared architecture.

## Design Review Checklist (world-level)

Before approving a new screen or asset, confirm it: feels part of the same
animated world; renders Twinko consistently; treats the background as an
environment; is soft and dimensional rather than flat or realistic; uses one
coherent icon family; keeps controls distinguishable from decoration; floats UI
within the scene; uses glass with hierarchy; keeps text readable; is calm enough
for emotional use; keeps motion restrained; honors Reduce Motion; and stays
original to Twinko. (The implementation-level validation checklist is Part II
§24.)

---

# PART II — Implementation Tokens & Components

The sections below (§1–§26, numbering preserved) are the concrete token,
component, and behavior layer that implements Part I. Where a Part II value and
a Part I principle appear to disagree, Part I governs intent and Part II governs
the exact value; raise genuine contradictions for founder confirmation rather
than guessing.

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
- Heavy glow, or undisciplined glassmorphism that ignores the glass-material hierarchy (Part I)
- Childish game UI
- Photorealistic, glossy plastic-toy, or hard-cel rendering (soft atmospheric 3D / polished 2.5D is the required style — see Part I)
- Excessive shadows, gradients, or decorative stars
- Mixed icon styles (all production icons share one family — Part I Icon System)
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

- Use simple rounded line icons from the one coherent family (Part I Icon System).
- Approximate stroke: 2 pt.
- Do not mix decorative feature icons with system icons at the same hierarchy.
- SF Symbols are acceptable only as a base customized into the Twinko-world family, never raw at feature hierarchy.
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
- Render as a soft, gently dimensional, luminous companion per the Mascot Language (Part I) — slightly plush-like rather than plastic.
- Avoid photorealistic, highly reflective toy-figurine, or hard-cel materials.
- Character outfits must not reshape the canonical body.
- Twinko is the main source of cuteness; surrounding UI remains restrained.

---

# 18. Illustration and Icon Style

Implements the Part I **Icon System** and **Illustration and Rendering Style** —
see Part I for the global icon family, the two approved construction methods
(soft-3D object vs. simplified cosmic line/fill), and the bottom-navigation
concepts (including "no paper-plane for Explore" and "no raster My Planet nav
icon").

## Feature icons

- Simple circular container / rounded dimensional object
- Low-detail symbol
- Soft atmospheric 3D or polished 2.5D, from one coherent family
- Consistent visible size and weight
- No heavy texture, and no continuous glow (glow is reserved — Part I)
- Preserve approved assets

## Illustrations

- Rounded shapes
- Soft gradients and gentle dimensional depth
- Minimal detail
- Calm composition
- Stylized, storybook, soft atmospheric 3D / polished 2.5D — not photorealistic, glossy plastic-toy, or hard-cel (see Part I rendering-direction note)

---

# 19. Background System

The per-feature background direction, canonical asset names, and the governing
rule now live in one place: **Part I — Background Family**. That table is the
single source of truth for Home, Chat, Explore, My Planet, Meditation, Tarot,
Horoscope, Music, and Profile/Settings/Privacy backgrounds.

Retained implementation notes not restated in Part I:

- **Chat:** dreamy background allowed, but bubbles and composer remain neutral
  and readable (see §15) to prevent purple/pink visual fatigue.
- **Governing rule (also in Part I):** the more reading or decision-making a
  screen requires, the quieter its background must be.

---

# 20. Motion

## Principles

- Slow
- Soft
- Low amplitude
- Calm
- No gaming-style bounce

Implements the Part I **Motion Language** (breathing, drifting, glowing,
travelling). Concrete tokens below.

## Tokens

| Motion | Duration |
|---|---:|
| `fast` | 120–160 ms |
| `standard` | 200–260 ms |
| `sheet` | 250–320 ms |
| `glassSelect` | 220–320 ms |
| `twinkoFloat` | 2.8–3.5 s |
| `objectFloat` | 3.5–5.5 s |

> **Revised in v2.0 to match the canonical direction (and current
> implementation).** `twinkoFloat` was 3.5–4.5 s; it is now 2.8–3.5 s, and
> Twinko idle vertical travel widened from 4–6 pt to 4–8 pt. `objectFloat`
> (planets and world objects) and `glassSelect` (moving tab/selection glass)
> are added.

## Twinko idle motion

- Vertical movement: `4–8 pt`
- Scale: maximum `1.015`
- Ease in/out
- No rotation
- Pause nonessential float when the screen is not visible
- Respect Reduce Motion

## Planet and object motion

- Vertical movement: `3–6 pt`
- Duration: `3.5–5.5 s`, slightly varied timing (no synchronized bouncing)
- Ease in/out
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
- [ ] The screen reads as part of the one Twinko world (Part I Feature Consistency): shared rendering family, icon family, glass hierarchy, Twinko proportions, and motion philosophy.
- [ ] Rendering is soft atmospheric 3D / polished 2.5D — not flat 2D-only, photorealistic, glossy plastic, or hard-cel.
- [ ] Icons belong to one family; Explore uses a spaceship/navigator (not a paper plane) and My Planet a simplified planet-and-ring (not the raster).

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
