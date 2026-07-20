# TwinkoTalk LLM Integration — Phase A

**Status:** Phase A Task 1 implemented (2026-07-19)
**Basis:** Founder-approved direction of 2026-07-19 (Phase A local prototype,
vendor-neutral design, canonical Tarot knowledge, structured output + safety
matrix, two-level evaluation, privacy disclosure, cost limits, 13-step order).
**Scope owner:** This doc records the Phase A engineering boundary. Product
canon stays in `docs/product/`; Tarot product logic stays in
`docs/features/tarot/TWINKOTALK_TAROT_USAGE_SPEC.md`.

---

## 1. Phase A boundary (temporary development shortcut)

Local **direct API access** from the iOS development build is approved for
Phase A under these conditions — and only these:

- Gina's own devices only; no TestFlight; no shared builds.
- Dedicated **prototype** API keys (created fresh, console spend limits set).
- Keys live only in the gitignored local file below; the repo carries an
  empty example template only.
- No keys in source code, UserDefaults, JSONStore files, logs, error
  messages, screenshots, or documentation.
- No sensitive prompt/response logging anywhere (operational numbers only).
- Explicit timeout, output-token cap, bounded context, at most one
  controlled retry.

> **THE PROXY GATE (hard requirement).** A Twinko-owned server-side or
> serverless proxy — holding the real provider keys in backend secrets with
> daily/monthly/per-device/per-request limits — is required **before
> TestFlight or installation by anyone else**. At that point the Phase A
> prototype keys are **revoked**. Phase A direct access is a temporary
> development shortcut, not the production security architecture.

## 2. Key setup (founder machine)

1. Copy `apps/ios/Twinko/Twinko/LLM/LLMSecrets.example.plist` to
   `LLMSecrets.plist` **in the same directory**.
2. Paste the dedicated prototype keys into `ANTHROPIC_API_KEY` /
   `OPENAI_API_KEY`.
3. That's it. `LLMSecrets.plist` is **gitignored** (entry added before the
   file could ever exist). A conditional build phase copies it into the app
   bundle **only when present and only for Debug builds**; the build
   succeeds normally when it is absent, and both services then throw
   `.notConfigured` (the app keeps running on its deterministic mocks).
   `LLMSecrets.apiKey` additionally compiles to `nil` in Release builds, so
   no key can ride an archive.

## 3. Transport layer (what Task 1 built)

- `Twinko/LLM/LLMTransport.swift` — `LLMProvider` (anthropic/openai),
  neutral `LLMRequest`/`LLMResult`, `LLMServing` protocol, typed `LLMError`
  (notConfigured / network / timeout / rateLimited / httpStatus / decoding /
  safetyRefusal / budgetExceeded), Phase A secrets loading, safeguard
  defaults, static price table, and the day-keyed `LLMUsageLedger`
  (JSONStore `llm_usage.json` — request counts and token totals only,
  never content).
- `Twinko/LLM/LLMServices.swift` — shared `LLMEngine` (safeguards) plus
  `AnthropicLLMService` (Messages API) and `OpenAILLMService`
  (Chat Completions), both minimal non-streaming URLSession clients with
  identical neutral semantics. `jsonMode` maps to OpenAI's JSON object mode
  today; Anthropic JSON enforcement arrives with the real Task 3 schema.

Safeguard defaults: **30 s timeout · 2000 output-token hard cap · exactly
one retry (transient failures only: network timeout / 5xx / 429; never 4xx
or safety refusals) · US$1.00/day local allowance** (estimated from a
conservative static price table; unknown models use the conservative
fallback rate). Operational logging is category/number only: provider,
model, latency, token counts, error category.

Nothing is wired into any ViewModel or View. No streaming, no prompts, no
schema validation.

## 4. Tarot registry knowledge layer (v0.1 draft)

`twinko_tarot_card_registry_v1.json` was extended **in place** (no second
canonical file): every one of the 78 cards now carries `element`,
`keywords_upright_zh/en` and `keywords_reversed_zh/en` (3–5 each),
`core_symbols` (2–3, zh/en), and one-sentence `core_upright_zh/en` /
`core_reversed_zh/en`, following standard Rider-Waite-Smith attributions in
a reflective, non-deterministic tone (no medical/legal/financial/destiny
claims). The file carries the top-level marker:

```json
"knowledge_version": "0.1-draft-unreviewed"
```

This content is a **draft for founder review**, not automatically
authoritative. `TarotCardInfo` decodes the new fields backward-compatibly
(older files yield empty values, never a crash); nothing reads them in UI
or interpretation logic yet.

## 5. What Task 1 explicitly did NOT implement

Structured Tarot response schema · any Tarot/Horoscope/Chat prompt · the
safety action matrix · the evaluation harness · the provider benchmark ·
any UI integration or reading-flow change · ephemeris work · the
server-side proxy · streaming · analytics.

## 6. Approved 13-step order (for reference)

1. Provider-neutral interface + Phase A local key handling *(this task)*
2. Extend the existing Tarot card registry *(this task)*
3. Structured response schema
4. Safety action matrix *(complete before live Tarot reaches the user flow)*
5. Grounded Tarot prompt
6. 10–12-case evaluation harness
7. Blind Anthropic/OpenAI benchmark
8. Founder selects provider; record decision (D-043 close)
9. Privacy disclosures updated *(before first live call in the user flow)*
10. Connect live Tarot generation with mock fallback
11. **Server-side proxy before any external distribution**
12. Later: ephemeris-backed Horoscope (until then: reflective framing only)
13. Later: D-037 finalized, then Chat

## 7. Suggested decision-log entry (for the founder to move over)

> **D-056 — Phase A LLM foundation (2026-07-19).** Approved: temporary
> local direct API access for founder-only Debug builds under the Phase A
> conditions (dedicated prototype keys, gitignored local config, no
> sensitive logging, bounded requests, US$10/month budget); vendor-neutral
> transport with blind benchmark before provider selection (D-043 remains
> open); Tarot registry knowledge layer v0.1 (draft, unreviewed) added to
> the canonical registry; server-side proxy is a hard gate before
> TestFlight or any external distribution, at which point prototype keys
> are revoked. Implemented per `docs/features/llm/TWINKO_LLM_PHASE_A.md`.
