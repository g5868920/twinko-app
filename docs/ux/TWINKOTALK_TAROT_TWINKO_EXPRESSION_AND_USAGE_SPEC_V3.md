# TwinkoTalk Tarot Twinko Expression & Usage Specification

**Version:** v3.1 (founder review 2026-07-16 — character asset rule)  
**Status:** founder-reviewed character usage spec

## Canonical foundation
All Tarot Twinko assets must preserve:
- founder-approved yellow star silhouette
- black eyes with highlights
- orange cheeks
- purple wizard hat with yellow star ornament
- purple cape with gold clasp
- no separate arms or legs
- soft illustrated dimensionality
- transparent background

Character PNGs contain the character only. Scene effects (orbiting
cards, magic rings, halos, particle fields) are composed at runtime —
never baked into the character PNG.

## Canonical state set (v3.1)

```text
twinko_tarot_idle_v1.png            — active
twinko_tarot_gentle_concern_v1.png  — active (delivered 2026-07-16)
twinko_tarot_magic_v1.png           — active
```

### Idle — `twinko_tarot_idle_v1.png`
- use: setup, spread selection, ordinary idle, stable result states,
  Overall Synthesis, Guidance Summary Card, final summary / closing
- emotion: welcoming, calm
- **Idle and Summary use the same character asset.** Summary
  presentation = idle + code-rendered warm halo + restrained sparkles
  + optional soft aura.

### Gentle Concern — `twinko_tarot_gentle_concern_v1.png`
- use selectively: sensitive/emotionally heavy reading context,
  supportive error or reflection states, the Tarot-derived Meditation
  introduction, moments acknowledging uncertainty
- expression: softly raised inner brows, small reassuring smile — not
  sadness or panic; same body/hat/cape/proportions as idle
- do not overuse; it never replaces idle across the whole result screen
- **Status: active.** Delivered 2026-07-16 with the usual baked
  checkerboard; a derived-transparent runtime copy lives in
  `assets/tarot/derived/` (source untouched). First usage: the mini
  character introducing the Tarot-derived Meditation handoff.

### Magic — `twinko_tarot_magic_v1.png`
- use: shuffle, energy sensing, selected-card separation, magical
  loading/processing, optional reveal transition
- runtime composition: `twinko_tarot_magic_v1` + code-rendered magic
  aura + independent card layers + sparse sparkles + optional energy
  ring
- note: the 2026-07-16 delivery replaced the old PNG with a clean
  character-only pose (no baked cards/rings) — fully compliant with
  the character/effect separation rule

## Deprecated character states (v3.1)

```text
twinko_tarot_summary_v1.png       — deprecated (source retained in assets/tarot/twinko/; no runtime reference)
twinko_tarot_interpreting_v1.png  — removed (source deleted in the 2026-07-16 founder delivery)
```

- Summary references → `twinko_tarot_idle_v1` + runtime summary effects.
- Interpreting/concerned references → `twinko_tarot_gentle_concern_v1`
  where the emotional state is genuinely needed.
- Runtime image sets for the deprecated poses were removed from the
  asset catalog; the source PNGs remain in `assets/tarot/twinko/` as
  reference-only files.

## Runtime effects (code, not PNG)

```text
tarot_idle_glow / tarot_magic_aura / tarot_magic_sparkles /
tarot_magic_ring / tarot_card_orbit / tarot_summary_aura /
tarot_summary_sparkles
```

Implemented as SwiftUI layers (`TarotTwinkoView` effects and the
shuffle stage). All respect Reduce Motion: no orbit, no scale pulsing,
static or faded effects, cross-fades instead of large movement.

## Semantic sizing

```text
Hero: 160–200 pt   (shuffle)
Supporting: 96–128 pt (setup, spread, result header)
Mini: 44–64 pt     (summary card corner)
```

Centralized in `TarotTwinkoSize`.

## State mapping table (v3.1)
| Product State | Character | Runtime effect |
|---|---|---|
| Tarot Entry / Setup | idle | idle glow + float |
| Spread Selection | idle | idle glow + float |
| Shuffle Ritual | magic | aura, ring, dust, card fan (independent) |
| Result / Synthesis | idle | summary aura |
| Sensitive / error states | gentle concern | minimal glow |
| Guidance Summary Card | idle | warm halo + sparse static sparkles |

## Hard rules
- do not redraw Twinko in a different material style
- do not add separate arms or legs
- do not substitute unofficial poses
- do not bake runtime effects into new character PNGs
- do not keep the deprecated summary/interpreting poses as required
  canonical production assets
