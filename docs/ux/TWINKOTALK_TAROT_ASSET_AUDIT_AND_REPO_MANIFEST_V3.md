# TwinkoTalk Tarot Asset Audit & Repo Manifest

**Version:** v3.0  
**Status:** founder-reviewed implementation checklist

## Ready for repo import

- 3 approved Tarot backgrounds under canonical filenames
- 1 approved card-back asset under canonical filename
- 1 single-card spread preview
- 1 three-card spread preview
- 4 approved Tarot Twinko states
- 1 newly added `tarot_swords_page_v1.png`
- updated screen / character / summary-card specifications
- 78-card registry in JSON and spreadsheet formats

## Resolved since v2

1. Missing Swords Page asset has been added.
2. The previously noted JPG Tarot cards have been converted by founder to PNG.
3. Background canonical naming has been aligned in the spec package.
4. The result background filename conflict is now resolved through source-to-repo mapping.

## Remaining implementation tasks

1. Verify all 78 card front filenames exactly match the registry.
2. Copy canonical assets into the repo folder structure.
3. Implement runtime summary-card composition.
4. Implement optional code-layer effects only if desired for polish.

## Optional effects status

The following are **not blocking source files** for prototype implementation. They are implementation-layer effects and may be omitted in MVP if needed:

- `tarot_magic_aura_v1`
- `tarot_energy_ring_v1`
- `tarot_card_shimmer_v1`
- `tarot_gold_particles_v1`

## Critical product rule

Prototype interpretation may use separate mock fixtures.

Production LLM interpretation must be dynamically synthesized from:

- user question
- topic
- spread type
- card positions
- upright / reversed orientation
- all cards in the reading
- optional guidance card
- locale

Do **not** hardcode one fixed final answer per card.
