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

---

## 8. Phase A Task 2 — schema, safety matrix (draft), grounded prompt (2026-07-20)

**Implements approved steps 3–5.** Still not wired into any user flow.

### 8.1 Structured response schema (`TarotLLMSchema.swift`)

Provider-neutral wire contract `TarotLLMResponse`: `positions[]`
(`position_id` = canonical TarotPositionID raw value, `card_id`,
`interpretation`, `reflection_prompt`), `cross_card_patterns`,
`integrated_summary`, `gentle_next_step`, `safety_category`. The app
validates every response **before rendering** via
`TarotLLMResponseValidator`: position count/order against the canonical
spread, card-to-position identity match against the actual draw, non-empty
fields, and a deterministic prohibited-language lint (zh+en deterministic/
destiny/mind-reading/winner phrases). Free-form text is never the contract.

### 8.2 Safety action matrix — DRAFT v0.1, ⚠️ awaiting founder sign-off

> **2026-07-21:** the canonical safety + privacy policy now lives in
> `TWINKO_LLM_SAFETY_PRIVACY_SPEC.md` (category × severity matrix,
> structured safety object, reframing, consent, data inventory, retention,
> incident response). On founder approval of that spec, this v0.1 matrix
> and the implemented `TarotSafetyMatrix` become migration debt (see spec
> §18); until then this table describes what the code does today.

| Category | Normal interp. | Supportive replacement | Guidance CTA | Stronger disclaimer | Professional resources |
|---|---|---|---|---|---|
| none | ✅ | — | ✅ | — | — |
| self_harm_crisis | ❌ | ✅ (incl. 安心專線 1925 / 988) | ❌ | ✅ | ✅ |
| medical_diagnosis | ❌ | ✅ (reframe to feelings + care) | ❌ | ✅ | ✅ |
| legal_decision | ✅ (reflective only) | — | ✅ | ✅ | ✅ |
| financial_decision | ✅ (reflective only) | — | ✅ | ✅ | — |
| pregnancy_death_prediction | ❌ | ✅ | ❌ | ✅ | — |
| relationship_mind_reading | ✅ (presented-state only) | — | ✅ | ✅ | — |

Universal rule: when a category triggers, **only the category may be
logged — never the user's original content**. This matrix is DRAFT and is
a hard gate: it must be founder-approved before live Tarot generation
reaches the normal user flow (step 10). Chat integration additionally
waits for D-037.

### 8.3 Grounded prompt (`TarotPromptBuilder.swift`)

One prompt for both vendors (what makes the blind benchmark fair):
professional RWS reflective-reading standards **without invented
personas/credentials**; per-card synthesis of grounded registry data ×
orientation × position × question; required cross-card analysis (majors
concentration, repeated suits/numbers, elemental balance, reinforcement/
tension, narrative); full usage-spec safety language rules; honest
self-classification into the safety categories; zh-Hant/EN language rule;
exact JSON output schema per spread. User content carries the validated
session inputs plus each drawn card's canonical knowledge (keywords for
the actual orientation, core sentence, symbols, element). Deterministic —
no transcripts, no fabrication.

### 8.4 Next

Step 6 (10–12-case golden evaluation harness) → step 7 (blind benchmark)
→ step 8 (founder provider decision). Matrix sign-off and privacy
disclosure (step 9) remain founder gates before step 10 wiring.

---

## 9. Step 6 — golden evaluation harness (2026-07-21)

### 9.1 Golden cases (`TarotGoldenCases.swift`)

Twelve fixed, deterministic reading fixtures — cards and orientations
are **pinned, never drawn**, so both providers answer identical
readings and results stay comparable across runs. All content is
synthetic. Coverage (protected by unit tests): every one of the 10
spreads; an all-reversed spread; a 4-Major concentration; a repeated
suit (three Cups); a repeated number (three Fives); conflicting cards
(Sun/Tower); a Daily Check-in context; one English case; and three
high-risk questions (`self_harm_crisis`, `medical_diagnosis`,
`relationship_mind_reading`).

### 9.2 Mechanical evaluation (`TarotEvalHarness.swift`)

Per case × model arm: schema validity + full validator issues
(structure, empty fields, prohibited-language lint), expected vs
reported safety category **and** whether the reported category maps to
the same app-side action in the safety matrix, latency, token usage,
and estimated cost from the local price table (console = billing
truth). Request failures become records with an error category —
never lost. Human quality dimensions (RWS accuracy, position ×
question integration, cross-card depth, 語言自然度, tone & safety,
actionability) are scored by the founder from the review sheets —
never by code.

### 9.3 Blind benchmark runner (step 7, founder-run)

`TarotEvalBenchmarkTests.testRunBlindProviderBenchmark` runs the full
12-case set against both providers sequentially and **skips** unless
all of these exist in the local `LLMSecrets.plist`:

- `ANTHROPIC_API_KEY` and `OPENAI_API_KEY` (prototype keys), and
- `TAROT_BENCHMARK_OPENAI_MODEL` — the exact OpenAI model id,
  **verified in the OpenAI console first** (the founder-named
  candidates could not be verified from here);
  `TAROT_BENCHMARK_ANTHROPIC_MODEL` is optional (defaults to
  `claude-sonnet-5`).

Providers are randomly assigned blind labels per run. Artifacts land
in a temp folder whose path is printed in the test log: per-case
review sheets and JSON records labeled `model_a`/`model_b` only,
`summary.md`, `REVIEW_GUIDE.md` (the six human dimensions), and
`unblind.json` — the only file naming providers, opened after
scoring. Estimated live cost for a full run is roughly US$0.3–0.8
(24 requests); the US$1/day client-side budget guard still applies,
so run it on a day with no other LLM spend.

### 9.4 Status of gates

Unchanged: safety-matrix sign-off and privacy disclosure remain
founder gates before step 10; the proxy remains the hard gate before
any external distribution; D-043 (provider) closes at step 8 after
the blind review.

---

## 10. Step 9 — privacy disclosure (DRAFT, ⚠️ awaiting founder sign-off)

The My Planet privacy page previously claimed "Nothing is uploaded" —
true today, but false the moment step 10 connects live generation.
`LLMPrivacyDisclosure` (LLMTransport.swift) now single-sources DRAFT
wording that is **conditional on the build actually being able to make
live calls** (a prototype key configured): unconfigured builds keep the
original local-only claims, which remain true for them.

When active, the page (a) qualifies the upload claim — "except for AI
interpretation, nothing is uploaded/synced/shared" — and (b) adds one
row:

| | Draft wording |
|---|---|
| zh title | AI 解讀（測試中） |
| zh body | 啟用 AI 解讀時，產生回應所需的內容——你的提問、選項說明與抽到的牌——會以加密連線傳送給外部 AI 服務。Twinko 不會把任何內容儲存在這台裝置以外的地方；你的暱稱、生日等個人資料也不會被傳送。請避免在問題中輸入你不想傳出的私人資訊。 |
| en title | AI interpretation (in testing) |
| en body | When AI interpretation is on, only what the response needs — your question, option notes, and the cards drawn — is sent to an external AI service over an encrypted connection to generate the reading. Twinko stores nothing outside this device. Your nickname, birthday, and profile are never sent. Please avoid typing private details you would not want transmitted into a question. |

Design choices for review: every claim is mechanically verifiable
(what is sent = exactly the prompt payload; profile data is never in
the prompt); no provider is named (D-043 open); no training-data
claims are made (provider-policy dependent — revisit at the proxy
step); the "not a production privacy policy" caveat stays. **This
wording is a founder gate before step 10** and must be re-reviewed
when the server-side proxy changes the data path.
