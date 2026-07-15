# TwinkoTalk Tarot Screen-by-Screen UI Specification

**Version:** v3.0  
**Status:** founder-reviewed product and UI spec

## Canonical flow
```text
Tarot Entry
→ Question Setup
→ Spread Selection
→ Shuffle Transition
→ Card Reveal
→ Interpretation
→ Optional Guidance Card
→ Final Summary
→ Share / Save / Continue
```

Prototype supports:
- Single Card
- Three Cards: Past / Present / Future
- Optional Guidance Card after a three-card reading
- Upright and Reversed cards

## Background mapping

```text
Setup / Entry / Spread Selection:
bg_tarot_celestial_altar_setup_v1.png

Shuffle:
bg_tarot_observatory_shuffle_v1.png

Reveal / Interpretation / Final Summary:
bg_tarot_moonlight_altar_result_v1.png
```

## Screen definitions

### 1. Tarot Entry / Landing
- background: setup background
- hero: `twinko_tarot_idle_v1.png`
- goal: invite the user into Tarot

### 2. Question Setup
- background: setup background
- hero: `twinko_tarot_idle_v1.png`
- question is optional
- suggested prompts may prefill input

### 3. Spread Selection
- background: setup background
- hero: `twinko_tarot_idle_v1.png`
- spread options shown with:
  - `tarot_spread_single_preview_v1.png`
  - `tarot_spread_three_preview_v1.png`
- no Four Card spread in MVP

### 4. Shuffle Transition
- background: shuffle background
- hero: `twinko_tarot_magic_v1.png`
- short ritual transition only
- prototype may keep baked magical cards / glow in this Twinko image

### 5. Card Reveal
- background: result background
- single: show one face-down `tarot_card_back_v1.png`
- three-card: show three face-down cards

### 6. Interpretation
- background: result background
- loading / reflection state: `twinko_tarot_interpreting_v1.png`
- production output must be LLM-synthesized, not hardcoded per card

### 7. Guidance Card Prompt
- only after three-card reading
- if accepted, reveal one additional card

### 8. Final Summary
- background: result background or a calmer dark surface in the same Tarot language
- hero: `twinko_tarot_summary_v1.png`
- supports save / share / continue
- uses runtime summary-card composition system

## Hard rules
- no Four Cards spread in MVP
- no deterministic card-answer lookup in production
- no duplicated cards within one reading
- no permanent wordmark baked into screen assets
