# CLAUDE.md — twinko-app

Instructions for any AI agent working in this repository.

## Repository scope

This repo owns Twinko product truth and implementation only. It does not own PM Workflow product implementation or the canonical ingestion contract (`pm-workflow-copilot` owns those), and it does not own company-level governance, approvals, or cross-venture status (`gina-ai-native-venture-studio` owns those).

## Source-of-truth hierarchy

1. Founder (Gina) explicit decisions — highest authority.
2. `docs/product/TWINKO_PRODUCT_OPERATING_BRIEF.md` — product master.
3. `docs/product/TWINKO_CURRENT_STATUS.md`, `docs/product/TWINKO_DECISION_LOG.md`.
4. `docs/strategy/` and `docs/history/` — supporting sources, not validated market evidence.

Within product docs, evidence tiers are: confirmed/approved > working direction > unvalidated hypothesis > open decision. Unvalidated market, user, or business claims are never treated as fact.

## Reserved decisions (require Gina's explicit approval)

Repository ownership or major architectural boundary changes, product scope/sequencing changes, safety and crisis policy, monetization/pricing, live-LLM provider selection, and anything that would move a claim from "unvalidated" to "validated." Routine path refinements within the already-approved architecture do not require a new reserved decision.

## Product / runtime ownership

Twinko-specific backend, analytics, and runtime code live here. This repo does not implement PM Workflow's product logic, Control Tower, or canonical schema/validator.

## Safety and claim boundaries

Do not upgrade unvalidated hypotheses into facts. Do not treat `docs/strategy/TWINKO_MARKET_BUSINESS_GAMIFICATION_CONSOLIDATION.md` as market validation. Safety, crisis-fallback, and non-deterministic tarot/astrology framing policies must be resolved in `docs/safety/` before any live-LLM (Gate 3) release.

## Single-writer protocol

Before any write: check branch, HEAD, working-tree status, staged files, and remote divergence in this repo and any repo being cross-referenced. Do not write if an out-of-band change is detected — stop and report instead of guessing.

## Commit / push authorization boundary

No agent stages, commits, or pushes without an explicit, separate authorization for that specific action. Producing or modifying files is not authorization to commit or push them.

## Cross-repo boundaries

No automatic modification of `gina-ai-native-venture-studio` or `pm-workflow-copilot` canonical sources from this repo or its agents.

## Gate boundary

No SwiftUI implementation, live-LLM integration, backend, schema, PM Workflow adapter, or any Gate 1+ work proceeds without an explicitly approved milestone.
