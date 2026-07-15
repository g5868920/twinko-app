# TwinkoTalk Tarot Delivery Pack

**Version:** V3  
**Purpose:** Updated implementation package after founder review.

## What changed in this pack

1. Added the missing `tarot_swords_page_v1.png`.
2. Standardized the approved result background canonical filename to:
   - `bg_tarot_moonlight_altar_result_v1.png`
3. Kept a clear source-to-canonical mapping for backgrounds so raw upload names and repo names are not confused.
4. Updated the spec docs to reflect:
   - all 78 tarot fronts are now PNG assets
   - prototype can use mock interpretation data
   - production LLM mode must not use hardcoded card-answer outputs
   - optional visual effects are implementation-layer items, not required source PNGs
5. Bundled the currently approved Tarot reference assets under canonical filenames for Claude Code handoff.

## Included folders

- `assets/` → approved / renamed Tarot reference assets
- `docs/` → updated specs and supporting docs

## Important naming rule

The **source upload filename** for the approved result background may still contain `setup`, but the **repo import name** must be:

`bg_tarot_moonlight_altar_result_v1.png`

You do **not** need to redraw that asset. Only rename it in the repo / implementation layer.

## Interpretation rule

Prototype:
- mock reading outputs are allowed

Production LLM:
- must synthesize output dynamically from question, spread, positions, orientation, card combination, and context
- must not rely on one fixed prewritten answer per card
