# TwinkoTalk Tarot Review & Changelog

**Version:** v3.0  
**Purpose:** summarize the latest corrections applied to the Tarot package

## Changes applied

1. Added `tarot_swords_page_v1.png`.
2. Standardized result background canonical naming to `bg_tarot_moonlight_altar_result_v1.png`.
3. Clarified that an old raw source filename may still contain `setup`, but the repo import name must use `result`.
4. Reflected founder confirmation that all 78 tarot fronts are now PNG.
5. Kept the prototype-vs-production interpretation rule explicit.
6. Reframed the effect items as optional implementation-layer polish rather than missing required PNG files.
7. Bundled the current approved reference asset set under canonical names for Claude Code handoff.

## Items intentionally left as implementation choices

- whether to implement optional aura / particle / shimmer polish in MVP
- exact runtime layout details of the summary-card renderer
- final localization copy polish for the Tarot UI

## v3.1 changes (founder review 2026-07-16)

1. Canonical Twinko character inventory reduced to
   `twinko_tarot_idle_v1` / `twinko_tarot_gentle_concern_v1` /
   `twinko_tarot_magic_v1`. Summary and interpreting poses deprecated
   (sources retained as reference-only; runtime image sets removed).
2. Summary presentation = idle character + runtime summary aura and
   restrained sparkles; magic = magic character + runtime aura, dust,
   ring, and independent card layers. Effects are never baked into
   character PNGs.
3. `twinko_tarot_gentle_concern_v1.png` is an approved concept but is
   NOT yet in the repo (status: missing). Runtime falls back to idle.
4. Three-Card shuffle now isolates exactly three selected cards from
   the fan before reveal (single card isolates one).
5. Setup suggestions are tappable chips; reveal copy adds a
   second-state line; targeted readability overlays added over the
   approved backgrounds (art unchanged).
6. Result restructured: collapsed card cores with expandable full
   interpretations; Overall Synthesis and Twinko Message are separate
   provider fields; Guidance Card prompt compacted; CTA order is Save
   Guidance Card → meditation handoff → Share → Start a New Reading /
   Back to Home ("Draw Again" renamed).
7. Guidance Summary Card: larger card art, 3–4-line synthesis,
   idle character with runtime halo/sparkles, readable card names.
8. Tarot → Meditation handoff now goes through
   `TarotMeditationContextAdapter`: concise adapted focus summary (no
   card lists, no determinism, no ellipsis), recommended theme +
   duration marked as Twinko recommendations, trust note, supplemental
   input copy, sticky generation CTA ("Create My Meditation").

## v3.1 asset delivery addendum (2026-07-16)

- `twinko_tarot_gentle_concern_v1.png` delivered — status Active.
  Derived transparent runtime copy created; wired into
  `TarotTwinkoState.gentleConcern` and shown as the mini character
  introducing the Tarot-derived Meditation handoff.
- `twinko_tarot_magic_v1.png` replaced with a clean character-only
  pose (no baked cards/rings); derived runtime copy regenerated.
- `twinko_tarot_summary_v1.png` source replaced by founder; remains
  deprecated with no runtime reference.
- `twinko_tarot_interpreting_v1.png` source removed by founder.

## v4.0 journey redesign (2026-07-16)

- Six approved topics (`relationships/career/finance/growth/lifePath/
  other`) with exact English labels, equal 2×3 grid, topic-specific
  full-width suggestions.
- Immersive Tarot: bottom navigation hidden throughout; all redundant
  塔羅 top titles removed; Back/edge-swipe = previous page; Back to
  Home → Home root; Start a New Reading → topic setup.
- App-wide native edge-swipe-back convention on non-root pushed pages
  (`InteractivePopSupport.swift`).
- Equal spread-selection cards with approved subtitles; vortex shuffle
  (14-card pool → exactly 1/3 converge) with gentle casting Twinko and
  Reduce Motion fallback; revealed-card gold glow; centralized magical
  CTA press treatment.
- Result restructure: starts directly with full interpretations
  (expand controls and per-card mini reflections removed), warm-white
  matte reading system, magical dividers, synthesis vs Twinko message
  kept distinct, one optional Guidance Card for both spreads, Share
  Result removed, merged Personalized Meditation section, quiet exits,
  short single disclaimer 「內容僅供反思與娛樂」.
- Full spec: `TWINKOTALK_TAROT_JOURNEY_REDESIGN_V4.md`.
