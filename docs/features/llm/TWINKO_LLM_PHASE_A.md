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

## 10. Step 9 — privacy disclosure (Provisional copy — founder review pending)

The My Planet privacy page previously claimed "Nothing is uploaded" —
true today, but false the moment step 10 connects live generation.
`LLMPrivacyDisclosure` (LLMTransport.swift) now single-sources DRAFT
wording that is **conditional on the build actually being able to make
live calls** (a prototype key configured): unconfigured builds keep the
original local-only claims, which remain true for them.

When active, the page (a) qualifies the upload claim — "except for AI
interpretation, nothing is uploaded/synced/shared" — and (b) adds one
row:

| | Draft wording (corrected 2026-07-21: no absolute storage/never-sent claims) |
|---|---|
| zh title | AI 解讀（測試中） |
| zh body | 啟用 AI 解讀時，你的提問、抽到的牌與牌位、以及你輸入的選項說明或關係稱呼，會傳送給外部 AI 服務以產生這次的解讀。TwinkoTalk 目前不會把完整的提問或回應儲存在自己的伺服器上；外部服務可能依其政策暫時處理或保留這些資料。TwinkoTalk 不會自動附上你的暱稱、生日或個人檔案——除非你自己把這類資訊寫進問題裡。若選擇不使用，會改以清楚標示的本機示意解讀呈現。 |
| en title | AI interpretation (in testing) |
| en body | When AI interpretation is on, your question, the cards drawn, their spread positions, and any option or relationship labels you entered are sent to an external AI provider to generate this reading. TwinkoTalk does not currently store full questions or responses on its own servers; the external provider may temporarily process or retain data according to its policies. TwinkoTalk does not automatically attach your nickname, birthday, or profile data — unless you include such information in the question yourself. If you decline, a clearly labeled local sample reading is shown instead. |
| consent CTA | zh 「繼續，使用 AI 解讀」／「暫時不要」 · en "Continue with AI" / "Not now" |

Design choices for review: every claim is mechanically verifiable
(what is sent = exactly the prompt payload; profile data is never in
the prompt); no provider is named (D-043 open); no training-data
claims are made (provider-policy dependent — revisit at the proxy
step); the "not a production privacy policy" caveat stays. **This
wording is a founder gate before step 10** and must be re-reviewed
when the server-side proxy changes the data path.

---

## 11. Provider data-policy verification (safety spec §14.1) — 2026-07-21

Verified against **official provider documentation** on 2026-07-21 (not
marketing pages, not third-party summaries). Policies change — re-verify at
D-043 close and again at the proxy step.

### Anthropic (Claude API)

| item | verified finding |
|---|---|
| Training on API data | Not used for training: "Retained data is never used for model training without your express permission" (platform docs); commercial terms exclude Customer Content from training |
| Default retention | "We automatically delete inputs and outputs on our backend within 30 days of receipt or generation" (privacy center, commercial) |
| Abuse-monitoring / flagged | Usage-Policy-flagged content retained "for up to 2 years"; trust-and-safety classification scores "up to 7 years" |
| ZDR | Available, but **sales-negotiated per organization** — not applicable to a Phase A self-serve prototype org |
| Model-specific | `claude-sonnet-5` (our Tarot candidate) has no special retention requirement. Note: Claude Fable 5 / Mythos 5 are "Covered Models" requiring 30-day retention and are ZDR-ineligible — irrelevant to our candidates but worth knowing |
| Deletion | Org-deleted content "deleted from our back-end storage systems within 30 days" |

Sources: [platform.claude.com — API and data retention](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention) · [privacy.claude.com — organization data retention](https://privacy.claude.com/en/articles/7996866-how-long-do-you-store-my-organization-s-data)

### OpenAI (API)

| item | verified finding |
|---|---|
| Training on API data | "Data sent to the OpenAI API is not used to train or improve OpenAI models (unless you explicitly opt in)" |
| Default retention | Abuse-monitoring logs "retained for up to 30 days" by default; some stateful endpoints (e.g. `/v1/conversations`) retain until deleted — we do not use them |
| `store` parameter | Chat Completions supports `store`; under ZDR it is forced `false`. **Follow-up for next code batch:** set `store: false` explicitly in `OpenAILLMService` for defense-in-depth (today we simply omit it) |
| ZDR / modified abuse monitoring | Requires prior approval (qualifying/enterprise use case) — not applicable to a Phase A self-serve prototype account |
| Deletion | Files deletable via API/dashboard or `expires_after`; not relevant to our chat-completions-only usage |

Source: [developers.openai.com — data controls](https://developers.openai.com/api/docs/guides/your-data)

### What the privacy disclosure may therefore claim (both providers)

✅ "The provider does not use API data to train models by default."
✅ "The provider may temporarily retain requests (typically up to 30 days;
content flagged for abuse may be retained longer per provider policy)."
❌ Zero retention · ❌ no human access · ❌ complete deletion — neither
Phase A account qualifies for ZDR, so these stay prohibited claims per
safety spec §12.

---

## 12. Step 10 — live Tarot integration path (PROVISIONAL, 2026-07-21)

**Status: `Proposed — implementation prepared, founder review pending`.**

The founder did **not** approve the safety matrix, the privacy/consent
wording, or the live Tarot flow; a prior session message was over-read as
approval and this section was corrected accordingly (2026-07-21 bounded
audit). All of the following remain **pending explicit founder review**
and may be revised:

- Safety action matrix — now **DRAFT v0.2** (§12.1a below; §8.2's v0.1
  table is superseded by v0.2 as the provisional implementation).
- Privacy disclosure + consent copy (`LLMPrivacyDisclosure`,
  `TarotLiveStrings`) — **provisional copy, founder review pending**.
- The live integration itself — implemented but **uncommitted** until
  authorized.
- Canonical safety spec FD-01–FD-16 — all unresolved.

Proposed decision-log entries (status: **Proposed — founder review
pending**; do not treat as accepted or closed):
> **D-057 (Proposed)** — Tarot safety action matrix draft v0.2 for Phase A
> live generation. **D-058 (Proposed)** — LLM privacy disclosure and
> consent wording (conditional on live-capable builds).

### 12.1a Safety matrix draft v0.2 — complete category coverage

Policy actions: `allowReflectiveReading` / `allowWithConstraints`
(reserved for the approved severity model) / `requireUserApprovedReframe`
/ `replaceWithSupport` / `refuseRequest`. The APP enforces every action;
category-only logging applies to every category (never the user's text).
Severity note: v0.2 collapses in-category severity distinctions to the
**safer** action (e.g. any self-harm signal → replacement; ordinary
sadness or habit reflection classifies as `none` per prompt rules); the
full category × severity model is spec §2–4, pending FD-16.

| Category | Severity handling | Policy | Tarot interp. | Reframe | Replacement | Guidance | Disclaimer | Resources |
|---|---|---|---|---|---|---|---|---|
| none | normal | allowReflectiveReading | ✅ | — | — | ✅ | standard | — |
| self_harm_crisis | any ideation→crisis-safe | replaceWithSupport | ❌ | ❌ never | ✅ (安心專線 1925 / 988) | ❌ | stronger | ✅ |
| harm_to_others | fantasy/intent→safer | replaceWithSupport | ❌ | ❌ | ✅ de-escalation + support | ❌ | stronger | ✅ |
| abuse_unsafe_relationship | conflict=none; danger→replace | replaceWithSupport | ❌ | ❌ | ✅ safety-first (113, unverified) | ❌ | stronger | ✅ |
| medical_diagnosis | reflection=none; diagnosis/meds→replace | replaceWithSupport | ❌ | ❌ | ✅ feelings + care | ❌ | stronger | ✅ |
| legal_decision | restricted | requireUserApprovedReframe | ❌ until approved | ✅ user-approved | — | ❌ until approved | stronger | ✅ |
| financial_decision | restricted | requireUserApprovedReframe | ❌ until approved | ✅ user-approved | — | ❌ until approved (never a betting signal) | stronger | — |
| pregnancy_death_prediction | restricted | replaceWithSupport | ❌ | ❌ | ✅ toward testing/professional support | ❌ | stronger | — |
| relationship_mind_reading | restricted | requireUserApprovedReframe | ❌ until approved (presented-state only after) | ✅ user-approved | — | ❌ until approved | stronger | — |
| reality_distortion | restricted | replaceWithSupport | ❌ | ❌ | ✅ acknowledge feeling, never the belief | ❌ | stronger | ✅ |
| minor_sexual_safety | always | **refuseRequest** | ❌ ever | ❌ | ✅ refusal + safety support (113) | ❌ | stronger | ✅ |
| substance_risk | habit reflection=none; dosing/overdose→replace | replaceWithSupport | ❌ | ❌ | ✅ no dosing, urgent → 119 | ❌ | stronger | ✅ |

**Region-based crisis resources (corrected 2026-07-21):** resource
mapping follows the device-locale **region** (existing system setting —
no location permission), never the UI language: an English-language
user in Taiwan gets Taiwan resources, never US 988.

| Region | Mapping (Phase A) | Status |
|---|---|---|
| Taiwan (TW) | 1925 emotional crisis · 113 protection (abuse/minors) · 119 immediate/medical danger | pending verification |
| United States (US) | 988 suicide & crisis support only; other categories → number-free fallback | pending verification |
| Unknown/unsupported | **no phone number ever shown** — local emergency services + a trusted person + explicit statement that verified local mapping is not yet available | verified by test |

No resource mapping is verified for external release; markets without
verified mappings remain **blocked from external-release readiness**
(FD-02/FD-03; proxy gate unchanged).

> The local deterministic safety preflight is a Phase A heuristic and
> is not a production-grade safety classifier. The validated provider
> response remains a second enforcement layer. Production release
> requires expanded evaluation and verified locale-aware crisis
> resources.

The keyword scanner does not detect all possible high-risk phrasing —
no such claim is made anywhere.

### 12.1b Pre-reading safety sequence (correction 2)

**Setup Review → Begin tapped → consent gate when required (Continue
with AI / Not Now — before any card exists) → deterministic safety
preflight of the draft question + context fields (`preflightCategory`,
no network) → allow / user-approved editable reframe (updates the DRAFT
question only) / supportive replacement (no draw) → only then the draw
commits.** The model's own classification of the generated response is
the second enforcement layer. If a restricted category is discovered
only post-draw: the committed session's question is never mutated and
its cards are never reinterpreted — the user is offered a NEW safely
reframed reading (fresh session, fresh draw, normal ritual) or backs
out to the labeled mock; declining keeps Guidance restricted (no
bypass). Not-Now consent readings and no-key builds keep the existing
local mock behavior unchanged (no preflight — pre-existing product
behavior; gating the mock path too is a founder decision, spec FD-16).

### 12.1 What was wired (`TarotLiveReading.swift` + flow/result changes)

- **Consent strictly precedes the draw AND the network boundary:** in a
  live-capable build (key configured), tapping Begin Reading shows the
  provisional disclosure ("Continue with AI" / Not Now — never
  preselected) **before any card is drawn** (§12.1b). No provider is
  resolved, no request object is constructed, and nothing is sent until
  explicit Continue; declined consent produces **zero provider
  requests** (proven by a request-counting stub test), draws the
  reading locally, renders the labeled mock, and asks again on the next
  reading. Continue is persisted (`llm_consent.json`, provisional
  one-time behavior — FD-04 open). Mock-only builds (no key) behave
  exactly as before — no sheet, no labels.
- **Fail-closed vendor-neutral resolution:** a single configured provider
  resolves (OpenAI only with an explicit model id, never guessed;
  Anthropic model defaults to `claude-sonnet-5`); **both keys configured
  without an explicit `TAROT_LIVE_PROVIDER` fails closed** — no live
  request, labeled mock, concise dev-config log line (no secrets). An
  explicit provider choice is honored strictly (no silent substitution).
  No implicit preference exists while D-043 is open.
- **Validated render path:** grounded prompt → schema decode → full
  validator (structure, card identity, banned-language lint) → app-side
  policy decision → only then render. Any failure, timeout, invalid or
  malformed safety output, or skip lands on the deterministic mock with
  the provisional FD-09 label 「示意解讀（這次不是 AI 個人化生成）」;
  live readings carry the 「AI 生成的反思內容」 badge.
- **App-enforced safety (draft matrix v0.2):** replace-categories render
  the bilingual supportive response — no Guidance CTA, no meditation
  upsell, no export. Reframe-categories (legal/financial/mind-reading)
  render the reframe surface (§12.1a) — no interpretation and no
  Guidance until explicit approval; Guidance permission is derived from
  the validated policy state, so a Guidance request can never bypass a
  restriction (including after a declined reframe). Category-only
  logging.
- **Daily persistence:** a Daily reading's validated response is stored on
  the current-day record (local only), so reopening today's guidance shows
  identical text with no new call and no drift; legacy records decode
  unchanged.
- **Loading UX:** bounded by the 30 s timeout + single retry, with a
  visible "先看示意解讀" skip.

### 12.2 Known Phase A limitations (documented, not hidden)

- The optional Guidance Card and closing line still read from the
  deterministic mock (a live guidance addendum is future work).
- A language switch after generation re-renders live per-position text as
  generated (zh or en); the mock remains fully bilingual.
- ALL user-facing copy (consent, labels, reframe, disclaimers) is
  provisional pending founder review.
- The local key remains extractable from any app bundle — this path is a
  temporary founder-only development shortcut, never a distribution
  architecture; the prototype key is revoked at the proxy gate (§1).

### 12.3 Step 10 status and validation

**`Step 10 integration path implemented; live provider behavior remains
unverified pending a controlled founder-only key-enabled smoke test.`**

| Path | Status |
|---|---|
| Mock path (no key) | verified (build + prior walkthroughs; unchanged by audit per code inspection) |
| Stubbed provider path (consent → validate → render; reframe; fallback) | verified via unit tests + stubbed Simulator check (see known issue below) |
| Consent sequencing (declined → 0 requests; accepted → 1 attempt) | verified via request-counting unit tests |
| Real Anthropic path | **unverified** (no live request has ever been made) |
| Real OpenAI path | **one successful founder-only smoke test** (2026-07-21, see below) |
| Privacy/consent copy | provisional — founder review pending |
| Safety matrix v0.2 | draft — founder review pending |

**OpenAI smoke-test record (2026-07-21):** OpenAI live Tarot completed one
successful founder-only smoke test using `gpt-5.6-terra`. The consent gate
appeared before the request, the structured response decoded and rendered,
the Debug provider/model diagnostic displayed correctly (`OpenAI ·
gpt-5.6-terra`), and region-specific resource behavior appeared correct.
**This verifies the first end-to-end live path, not long-term stability,
full spread coverage, full safety coverage, or final provider selection.**
OpenAI is NOT the selected provider; D-043 remains open pending the blind
benchmark.

Known narrow issue (correction 4 status): the reframe editor was
reworked to a `TextEditor` carrying its accessibility identifier and a
localized label directly on the control (before styling), with real
multiline editing. The stubbed Simulator check verified every policy
assertion up to that point (consent precedes the draw; declined
consent → labeled mock; reframe surface present with no interpretation
and no Guidance), but the exposure assertion itself remains
**UI-unverified**: the pre-fix run failed it, and the single permitted
re-run after the fix aborted early on an unrelated launch-timing flake.
Verify the one assertion (`testLiveTarotConsentAndReframeStates`) in
the next authorized batch before relying on VoiceOver addressability.
