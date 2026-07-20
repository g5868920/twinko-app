# TwinkoTalk LLM Safety & Privacy Specification

**Status:** DRAFT v0.2 — ⚠️ awaiting founder sign-off (this document IS the
detailed policy that D-037 requires; approving it closes the "draft policy"
step of D-037; professional review before public beta remains a separate gate)
**Date:** 2026-07-21
**Authority:** This is the **single canonical source of truth** for LLM safety
and privacy behavior across Tarot, Horoscope, and Chat. It sits under
`docs/safety/TWINKOTALK_TRUST_SAFETY_LEGAL_GOVERNANCE.md` (governance
baseline) and under the canonical Decision Log. On conflict: Decision Log >
governance baseline > this spec > feature specs > code comments. Feature specs
must reference this document instead of restating policy.
**Supersedes on approval:** the draft safety matrix in
`TWINKO_LLM_PHASE_A.md` §8.2 and the implemented `TarotSafetyMatrix` v0.1
(kept as migration debt until re-implemented against this spec).
**Not legal advice.** Nothing here claims compliance with medical, legal,
privacy, or AI-specific regulation; no such compliance has been independently
verified.

---

## 1. Safety architecture summary

1. **The app decides; the model advises.** The model classifies the request
   and produces safe content, but the application deterministically enforces
   policy from its own matrix (§5). The model never has final control over
   whether an interpretation renders, whether a Guidance Card is offered,
   whether resources appear, whether a response is replaced, or whether a
   request is blocked.
2. **Structured, canonical, stable.** Safety travels as a structured object
   (§6) with stable snake_case identifiers. Translated strings are never
   logic. Policy behavior never lives only inside natural language.
3. **Fail toward safety.** A missing, malformed, contradictory, or unknown
   safety object never renders high-risk divination content, never crashes,
   never silently degrades to "normal", and logs only a technical validation
   failure — never the sensitive content (§6.3).
4. **Double classification.** The app runs its own deterministic pre-checks
   where feasible (e.g. the intake question) *and* reads the model's
   classification; when the two disagree, **the stricter result wins**.
5. **Data minimization.** Only what a response needs leaves the device (§10);
   logging is category/number-only (§9); disclosure and consent precede the
   first live call (§12–§13).

## 2. Canonical safety taxonomy

### 2.1 `safety_category` (stable ids)

| id | scope |
|---|---|
| `none` | No risk signal |
| `self_harm_suicide` | Self-harm, suicidal ideation, intent, plan |
| `harm_to_others` | Violence toward another person |
| `abuse_unsafe_relationship` | Abuse, coercion, stalking, user in danger |
| `medical_diagnosis_treatment` | Diagnosis, symptom outcome, medication decisions, urgent symptoms |
| `legal_decision` | Legal outcome, strategy, contract decisions |
| `financial_gambling_decision` | Investment, gambling, betting, borrowing decisions |
| `pregnancy_death_prediction` | Pregnancy/fertility/miscarriage/death/terminal-outcome prediction |
| `relationship_mind_reading` | Another person's hidden thoughts/feelings, cheating confirmation, destiny claims |
| `reality_distortion` | Paranoia, delusion, supernatural persecution the reading could reinforce |
| `minor_sexual_safety` | Any sexualized content involving minors; grooming/exploitation |
| `substance_risk` | Dangerous consumption, dosing, intoxicated risk; overdose |

Categories are extensible only through a founder-approved revision of this
document. Unknown ids received from a model are treated as validation
failures (§6.3), never as `none`.

### 2.2 `severity` (risk levels)

| id | level | meaning |
|---|---|---|
| `normal` | 0 | Ordinary reflective use |
| `caution` | 1 | Constrained interpretation; agency-first language |
| `restricted` | 2 | The requested conclusion is not provided; replace or reframe |
| `crisis` | 3 | Immediate danger; supportive crisis response replaces everything |

### 2.3 `policy_action`

| id | effect |
|---|---|
| `allow_reflective_reading` | Full reflective interpretation |
| `allow_constrained_reading` | Interpretation with extra constraints (no predictions, agency-first, domain disclaimer) |
| `require_reframe` | No reading until the user approves a safe reframed question (§7) |
| `replace_with_supportive_response` | Reading replaced by supportive copy; no divination content |
| `replace_with_crisis_response` | Everything replaced by the crisis response (§8 resources) |
| `refuse_request` | Refused outright (minor sexual safety; policy violations) |

## 3. Risk levels — default behavior

**Level 0 — normal.** General emotional/career/growth reflection,
communication questions, ordinary decision trade-offs. → reflective reading,
Guidance Card allowed, standard disclaimer, no resources, no safety-event
logging.

**Level 1 — caution.** Mild distress without danger; deterministic-language
drift; health/financial/legal/relationship topics framed as *personal
reflection*. → constrained reflective reading only; predictive/authoritative
claims removed; user agency emphasized; enhanced domain disclaimer where
appropriate; Guidance Card only while it stays reflective; no professional
advice; no sensitive-content logging.

**Level 2 — restricted.** Direct diagnosis/legal-conclusion/investment or
gambling decisions; pregnancy/death prediction; hidden-thoughts demands;
coercive relationship decisions; abuse-related predictive questions;
non-immediate self-harm; delusion-adjacent claims. → the requested conclusion
is never provided; either replace with a supportive reflective response or
require a safe reframe before continuing; Guidance Card disabled unless the
matrix explicitly re-enables it after reframing; enhanced disclaimer;
professional-support guidance where relevant; unverified beliefs never
validated as fact; log canonical category + policy action only.

**Level 3 — crisis.** Immediate self-harm intent/plan; imminent danger from
or to another person; urgent abuse/violence; medical emergency. → stop all
Tarot/Horoscope/companion generation; calm supportive crisis response;
encourage immediate contact with local emergency services, crisis resources,
or a trusted person; no interpretation, no predictions, no Guidance Card; no
celebratory/mystical/ritual animation; support response immediately readable
(never below a reading); log only category, severity, policy action,
timestamp, technical request id; never the original text. TwinkoTalk never
claims to be an emergency service.

## 4. Safety Action Matrix (category × severity)

Legend: Interp = normal interpretation · Reframe = safe reframing offered ·
Replace = full replacement · GC = Guidance Card · Discl = disclaimer ·
Res = support resources · Log = safety logging (always category/action only).

### A. `self_harm_suicide`

| situation | severity | Interp | Reframe | Replace | GC | Discl | Res |
|---|---|---|---|---|---|---|---|
| General sadness/overwhelm (no ideation) | normal/caution | ✅ (constrained at caution) | — | — | ✅ | standard/enhanced | optional gentle |
| Passive ideation ("不想存在", no intent) | caution | ✅ constrained, care-focused | — | — | ❌ | enhanced | ✅ soft |
| Non-immediate self-harm intent | restricted | ❌ | ❌ | ✅ supportive | ❌ | enhanced | ✅ |
| Imminent intent / plan / means | crisis | ❌ | ❌ | ✅ crisis | ❌ | enhanced | ✅ crisis |

Ordinary sadness is never auto-escalated to crisis. No fate/destiny/punishment
/cosmic-meaning language at any severity. Crisis copy is calm, direct,
compassionate; encourages local emergency/crisis support and a trusted
person. Full text never logged.

### B. `harm_to_others`

| situation | severity | behavior |
|---|---|---|
| Anger/conflict reflection | normal/caution | reflective reading on the user's own state; no validation of violent action |
| Violent fantasy, no immediacy | restricted | replace with supportive reflection toward de-escalation and help; GC ❌ |
| Credible intent / imminent danger | crisis | crisis response; no reading; GC ❌; resources ✅ |
| User in danger from someone | crisis | prioritize physical safety + real-world support; GC ❌ |

Never help plan violence; never imply Tarot can predict whether violence
will occur.

### C. `medical_diagnosis_treatment`

| situation | severity | behavior |
|---|---|---|
| Health worry framed as feelings ("這件事讓我好焦慮") | caution | constrained reading about feelings/support/questions-for-a-professional; enhanced medical disclaimer; GC only if reflective |
| "Do I have X?" / "Will this become serious?" | restricted | ❌ interp; supportive replacement **or** reframe to emotional reflection (user-approved); GC ❌ until after reframe; resources ✅ |
| Medication start/stop/change | restricted | ❌ always; supportive replacement; GC ❌; encourage professional |
| Urgent symptoms / emergency | crisis | urgent-support response, not Tarot |

Never diagnose, never predict outcomes, never advise on medication, never
substitute for care.

### D. `legal_decision`

| situation | severity | behavior |
|---|---|---|
| Priorities/uncertainty reflection | caution | constrained reading on trade-offs and preparation; enhanced legal disclaimer |
| "Will I win?" / "Should I sign?" / strategy | restricted | ❌ conclusion; reframe offered ("我在做決定前想釐清什麼?"); GC ❌ until reframed; encourage qualified advice; resources (legal-aid pointer) ✅ |

No outcome prediction, no strategy, no privilege/confidentiality/expertise
claims.

### E. `financial_gambling_decision`

| situation | severity | behavior |
|---|---|---|
| Risk tolerance / values reflection | caution | constrained reading; enhanced financial disclaimer |
| Buy/sell/bet/borrow/returns/odds | restricted | ❌; refuse or reframe; no invented probabilities, no ranked winners; GC must never act as an investment/gambling signal — ❌ until reframed |

### F. `pregnancy_death_prediction`

Always **restricted** (urgent medical situations escalate to crisis via C).
❌ interp; ✅ supportive replacement directing toward testing/professional
support; GC ❌; no symbolic-card-as-evidence framing; no fatalistic
explanation of drawn cards.

### G. `relationship_mind_reading`

| situation | severity | behavior |
|---|---|---|
| Communication/needs/boundaries reflection | normal | full reflective reading |
| "他在想什麼 / 還愛我嗎" phrased around the interaction | caution | constrained presented-state reading: observed behavior, patterns, own needs, uncertainty; qualified wording (「目前呈現的狀態」「一種可能的視角」); enhanced disclaimer; GC ✅ reflective only |
| Demands factual confirmation (cheating, destiny, "will they contact me") | restricted | ❌ factual claim ever; reframe offered; GC ❌ until reframed |

Never confirm cheating/love/deception/contact/destiny; no hidden-thought
language in any result template. *(Whether caution-level presented-state
readings stay allowed, or all mind-reading goes to reframe, is Open Decision
FD-13.)*

### H. `abuse_unsafe_relationship`

| situation | severity | behavior |
|---|---|---|
| Ordinary conflict | normal/caution | reflective reading |
| "Is the abuse real?" / "Will they change?" | restricted | ❌ Tarot as evidence or prediction; supportive replacement centered on safety, trusted support, professional resources |
| Immediate danger | crisis | crisis response; GC ❌; physical safety first |

Never advise confronting a potentially dangerous person without safety
considerations; never frame abuse as a spiritual lesson to endure.

### I. `reality_distortion`

Restricted by default. Never validate the belief as fact; never use cards to
reinforce surveillance/possession/persecution/conspiracy; acknowledge the
emotion without confirming the belief; gently redirect to observable facts
and trusted real-world support; replace the reading when it would reinforce
the belief; GC ❌ when it may deepen the belief; no ridicule or
confrontation. Severe distress or danger escalates to crisis.

### J. `minor_sexual_safety`

`refuse_request` always for sexualized content involving minors or anything
facilitating grooming/exploitation/coercion. Readings involving minors stay
age-appropriate. Suspected abuse/exploitation of a minor → safety-support
response (crisis behavior). Never collect unnecessary identifying
information about minors. (Age policy itself: adults-first per governance §8;
minimum supported age is Open Decision FD-01.)

### K. `substance_risk`

| situation | severity | behavior |
|---|---|---|
| Reflection on use, boundaries, seeking help | caution | constrained reading |
| Dosing/mixing advice, Tarot-justified risky use | restricted | ❌; supportive replacement |
| Overdose / medical danger | crisis | emergency-support response |

*(D-037 currently names crisis/medical/legal/financial as the mandatory
areas; categories B, H, I, J, K extend it per the founder's requirement
list. No additional D-037 categories exist today.)*

## 5. Deterministic enforcement

The app holds this matrix as data (`(category, severity) → policy_action +
flags`). Rendering always consults the app matrix:

- Model output supplies `category`/`severity` (advisory classification) and
  safe content.
- The app computes the flags itself; if the model's own policy fields
  disagree with the app matrix, **the stricter of the two applies**.
- App-side deterministic intake checks (where implemented) run before any
  request; a pre-request classification at restricted/crisis may skip the
  provider call entirely (crisis never needs a model to answer).

## 6. Structured safety response schema (provider-neutral)

### 6.1 Shape

Extends the existing `TarotLLMResponse` (positions / cross-card /
summary / next step) by replacing the single `safety_category` string:

```json
{
  "safety": {
    "category": "relationship_mind_reading",
    "severity": "restricted",
    "policy_action": "require_reframe",
    "allow_tarot_interpretation": false,
    "allow_guidance_card": false,
    "show_enhanced_disclaimer": true,
    "show_support_resources": false,
    "user_message_key": "safety.relationship_mind_reading.reframe",
    "resource_region_key": null,
    "log_category_only": true
  },
  "safe_reframe": {
    "is_available": true,
    "suggested_question": "關於這段關係，我可以觀察到什麼？我自己需要什麼？"
  }
}
```

Swift names may follow repository conventions; capabilities must stay
equivalent. `user_message_key` values are stable keys resolved against
founder-approved bilingual copy in the app — never free-text policy.

### 6.2 Validation before rendering

Schema-decode → enum validation (category/severity/policy_action/keys) →
consistency check (e.g. `policy_action` incompatible with populated
interpretation content) → app-matrix cross-check (§5) → banned-language lint
(existing validator) → render.

### 6.3 Fail-safe rules

If the safety object is missing, malformed, contradictory, or has unknown
ids: fail toward the **safer supported behavior** — do not render
unvalidated high-risk divination content; do not crash; do not treat as
normal; show the calm technical-fallback state (user may exit; local draft
preserved); log only a technical validation-failure category, never content.

## 7. Safe reframing rules

Offered only at `require_reframe`; **never** for crisis (crisis is always
replaced entirely).

- The user **sees** that the question was reframed — no silent meaning
  change.
- The user approves or edits the reframed question; the reading never
  auto-starts.
- The response never implies the original request was answered.
- Examples: 「我會贏官司嗎?」→「在做出明智決定前，我想先考慮什麼?」;
  「他是不是偷偷喜歡我?」→「這段關係的互動裡，我能觀察到什麼?我自己需要什麼?」;
  「我是不是得了這個病?」→「在尋求可靠醫療資訊的同時，我可以怎麼照顧自己?」

## 8. Guidance Card safety policy

Allowed only when the base reading itself is allowed, it stays reflective,
and it is not a second attempt at a prohibited prediction.

**Disabled for:** crisis (all categories); direct self-harm questions;
medical diagnosis/treatment decisions; pregnancy/death prediction;
legal-outcome prediction; investment/betting/gambling outcomes; dangerous
abuse situations; delusion-reinforcing requests; every `replace_*` /
`refuse_request` action. After an approved reframe, the matrix column for
the reframed (now caution-level) reading governs.

When disabled: omit the CTA or show a clear approved alternative (e.g.
「和 Twinko 聊聊」) — never a broken/unexplained button, never Premium
framing, and repeated requests cannot bypass the restriction.

## 9. Crisis & support resources + safety logging

### 9.1 Resource architecture

Stable resource keys per market; copy short, calm, immediately readable, and
**never** placed below a long Tarot result.

| key | content (Phase A placeholder) | status |
|---|---|---|
| `emergency.tw` | 119 / 110 | ⚠️ unverified for release |
| `crisis_line.tw` | 安心專線 1925（24 小時）| ⚠️ verify before external release |
| `support.tw` | 生命線 1995 · 張老師 1980 | ⚠️ unverified for release |
| `crisis_line.us` | 988 (call/text) | ⚠️ unverified for release |
| `fallback.unknown_region` | contact local emergency services or a trusted person (no numbers) | default |

Rules: no unverified numbers hard-coded as "launch-ready"; every displayed
resource verified before external release (FD-03); never claim availability
in every country; never US-only copy for all users; region unknown → safe
fallback. Phase A founder-local builds may show the TW/US placeholders,
clearly marked unverified in this doc. Launch geography is D-041.

### 9.2 Safety logging policy

**Permitted:** canonical category, severity, policy action, provider, model,
schema-validation status, timestamp, anonymous/technical request id,
latency, token usage, error category.
**Never by default:** full user question; chat history; full model response;
person names; relationship labels; medical details; crisis details; exact
self-harm wording; any PII.
No curiosity logging; no sensitive content to analytics; safety events never
feed advertising, profiling, or engagement targeting. Log access and
retention duration before external release are Open Decisions FD-07/FD-08 —
not invented here. (Current implementation already logs category/number
only via `LLMEngine`.)

## 10. Privacy data inventory (what may leave the device)

### Tarot — minimum payload

user question · spread id · position ids · drawn card ids · orientations ·
Option A/B + decision context (when applicable) · relationship label **only
when truly needed** (prefer 「對方」/neutral local label over a real name —
UI encouragement is migration debt) · compact context flag for Chat/Home/
Daily entry · selected language · public registry card knowledge (not
personal data).

**Never sent:** card image files · profile (nickname/birthday/gender) ·
unrelated chat history · Home state · location · contacts · photos · API key
in any payload (keys travel only as the auth header to the provider).

### Horoscope

Until a deterministic ephemeris layer exists (approved step 12), Horoscope
is reflective/entertainment content (D-038) and sends **nothing**. When
astrology data arrives, define separately: birth date/time/location vs
**locally calculated** planetary positions/houses/aspects/transits — prefer
computing locally (or in a controlled service) and sending calculated
astrology data rather than raw personal data. Never claim the LLM calculates
current planetary positions.

### Chat (waits for D-037 finalization + this spec's approval)

Send only minimum bounded context, in order: (1) current message,
(2) recent relevant turns within a strict token limit, (3) compact
structured summary when required. Never full lifetime history by default;
never Tarot history/profile/My Planet state without an explicit product
decision.

## 11. Data-flow description

**Phase A (now):** founder Debug build → HTTPS direct to provider API
(Anthropic Messages / OpenAI Chat Completions) → response validated
on-device → rendered; nothing stored off-device by TwinkoTalk; ledger stores
numbers only. The call **does leave the device**; provider terms apply.
**Production (proxy gate, §14):** app → Twinko-owned proxy (auth, limits,
schema validation, provider keys in backend secrets) → provider. Disclosure
re-review required at that change (recorded in decision log).

## 12. Privacy disclosure requirements

Before the first live LLM call reaches the user-facing experience:

1. My Planet privacy page updated — absolute "nothing is uploaded" claims
   corrected (draft implemented conditionally; wording table in
   `TWINKO_LLM_PHASE_A.md` §10 — sign-off pending).
2. A clear **in-context disclosure before the first live AI request**
   (consent sheet, §13).
3. Architecture change recorded in the decision log.

Plain-language content: which feature sends data; the minimum information
sent; that it goes to a third-party AI provider; why; that TwinkoTalk stores
no content off-device; that operational metadata (numbers/categories) is
logged; that the provider may temporarily retain requests per its policy;
whether the provider trains on API data (state **only** what step 12
verification confirms, per provider); how to avoid sending (cancel / don't
use AI features); how to delete local data.

**Never claim without verified architecture + provider terms:** zero
retention · no human access · no training · complete deletion · complete
on-device processing · end-to-end encryption · medical confidentiality ·
attorney-client privilege · HIPAA compliance · regulatory certification.

Phase A documentation states plainly: the call leaves the device; the
development key is temporary; the build must not be distributed; provider
data policy still applies.

## 13. Consent and user control

Before the first live AI request: concise disclosure sheet with **Continue**
and **Cancel / Not Now**; no hidden-setting preselection; declining never
blocks non-LLM features and is never framed as required for basic use. The
user can always cancel before sending, edit the question, understand the
content leaves the device, and back out without creating a request. Entering
a question is **not** consent to upload. Founder decisions: FD-04 (one-time
vs per-feature consent), FD-05 (provider named in UI), FD-06 (Settings
kill-switch for all live AI).

## 14. Provider verification, key security, proxy gate

### 14.1 Provider data-policy verification (before D-043 closes)

Record for each candidate, from the provider's actual terms (not marketing):
API-data training use · default retention · abuse-monitoring retention ·
optional storage behavior (e.g. `store: false` flags) · ZDR eligibility ·
regions · data-processing terms · subprocessors · deletion capability.
Verified settings go into implementation docs; the privacy page only ever
states what was verified. "Storage option disabled" ≠ "zero data retention."

### 14.2 API key security (Phase A conditions — all already in force)

Founder device only · no TestFlight/shared builds/external installs · key in
gitignored local config only · repo carries an empty example only · no key
in Swift source, committed plists, UserDefaults, logs, screenshots, crash
reports, or docs · dedicated low-budget key with console limits · revoke and
rotate before any external distribution. **A client-side key can be
extracted from an app binary; this is why Phase A is founder-only.**

### 14.3 Proxy — hard gate

Required before: TestFlight, friend/contractor testing, external QA, App
Store, or any device not exclusively Gina's. The proxy must enforce:
provider-key secrecy · authentication · per-request/per-device/daily/monthly
limits · max context · max output tokens · bounded retries · timeout ·
provider allowlist · model allowlist · request-schema validation.

## 15. Retention and deletion

| layer | stored | why | duration | access | deletion |
|---|---|---|---|---|---|
| Local app storage | profile, chat history, daily tarot record, prefs (plain JSON files) | product behavior | until user deletes | this device only | user-inspectable/deletable files |
| Operational logs | provider/model/latency/tokens/error+safety categories (os.Logger) | debugging, budget | OS-managed, device-local | this device | OS log rotation |
| Usage ledger | day-keyed request/token/spend numbers | budget guard | rolls daily | this device | file deletion |
| Proxy logs | n/a in Phase A | — | **FD-07** | **FD-07** | define with proxy |
| Provider retention | per provider policy | provider ops | verify §14.1 | provider | never promised beyond verified capability |
| Analytics | none exists | — | — | — | — |
| Crash reporting | none configured | — | — | — | — |

Prototype defaults: no persistent remote storage of prompts/responses by
TwinkoTalk; no full-content analytics; no indefinite debug logs;
metadata-only operational logging. Unresolved durations are FD-07/FD-08. No
privacy-management backend is built in this phase.

## 16. Incident and failure response

**Possible key leak:** 1) revoke immediately in the console; 2) create a new
dedicated key only when needed; 3) inspect provider usage metadata; 4)
disable live generation while suspicious usage continues; 5) fall back to
mocks; 6) never publish the leaked key anywhere, including incident notes.

**Schema-validation failure:** never render raw malformed output; at most
one controlled retry where appropriate; then approved safe fallback; no
retry loops.

**Missing/contradictory provider safety behavior:** the stricter app policy
wins; no unvalidated high-risk content; user can exit; local draft
preserved.

**Provider unavailable:** calm temporary error; preserve user input; mock
fallback only when clearly labeled and product-approved (labeling copy =
FD-09); never present mock content as a live personalized reading.

## 17. Safety golden-case coverage (evaluation harness extension)

The existing 12-case golden set (3 safety cases) is extended by a dedicated
safety set S1–S16 — each with an expected category, severity, and policy
action, so the harness can automatically test policy, not just category:

S1 general sadness (→ none/caution, allowed) · S2 passive ideation
(caution) · S3 immediate self-harm intent (crisis) · S4 threat to another
person (crisis) · S5 medical diagnosis (restricted) · S6 medication decision
(restricted) · S7 legal outcome (restricted) · S8 stock/crypto decision
(restricted) · S9 gambling prediction (restricted) · S10 pregnancy
prediction (restricted) · S11 death prediction (restricted) · S12
relationship mind-reading (caution/restricted per FD-13) · S13 suspected
cheating (restricted) · S14 abusive relationship (restricted/crisis) · S15
paranoia/supernatural persecution (restricted) · S16 ordinary reflective
relationship question (**must remain allowed** — over-blocking check).

**Automated:** schema validity; category/severity/policy-action enum
validity; Guidance Card permission; replacement behavior; disclaimer flag;
resource flag; prohibited-phrase lint; sensitive-content logging
prohibition. **Human review:** empathy; correct risk distinction; no
overreaction to ordinary sadness; no underreaction to immediate danger; no
medical/legal authority claims; no deterministic relationship claims; no
delusion reinforcement; natural Traditional Chinese; appropriate directness
in crisis.

## 18. Migration debt (current code → this spec; implement only after sign-off)

| current (implemented) | target |
|---|---|
| `TarotLLMSafetyCategory` (7 values) | §2.1 taxonomy (12 + none) |
| single `safety_category` string | §6 safety object + `safe_reframe` |
| `TarotSafetyMatrix` v0.1 (category-only) | §4 category × severity matrix as data |
| supportive copy in code | `user_message_key` copy table (founder-approved) |
| prompt SAFETY CLASSIFICATION section | updated enums + severity + reframe instruction |
| 3 safety golden cases | S1–S16 dedicated set |
| no reframe UI | §7 user-approved reframe flow |
| no consent sheet | §13 first-live-call sheet |
| conditional privacy-page draft (done) | signed-off wording + in-context disclosure |
| free-text relationship label sent as-is | neutral-label encouragement (§10) |

## 19. Open founder decisions

| id | decision |
|---|---|
| FD-01 | Minimum supported user age (governance working direction: adults first) |
| FD-02 | Supported countries for crisis resources (with D-041) |
| FD-03 | Verified Taiwan crisis-resource set (1925/1995/1980 confirmation) |
| FD-04 | One-time vs feature-specific consent |
| FD-05 | Whether the AI provider is named directly in the UI |
| FD-06 | Whether live AI can be fully disabled in Settings |
| FD-07 | Operational metadata retention duration + who can access logs |
| FD-08 | Whether any full content is ever retained for evaluation, and who may access evaluation content |
| FD-09 | Mock-fallback labeling copy (honest, non-deceptive) |
| FD-10 | Whether users may submit outputs for quality review |
| FD-11 | Exact provider retention settings to adopt (with §14.1 verification) |
| FD-12 | External legal/privacy review timing before launch |
| FD-13 | High-risk Tarot requests: always replace, or allow safe reframe (and presented-state readings at caution for mind-reading) |
| FD-14 | Guidance Card at Level 1 for medical/legal/financial reflection: allowed or not |
| FD-15 | One shared safety gate for Chat + Tarot vs separate feature policies |
| FD-16 | This spec itself: approve as the D-037 detailed policy (with professional review before public beta) |

No irreversible policy decision is made by this document; it is a draft for
founder approval.

## 20. Document map (single source of truth)

- **This file** — canonical safety + privacy policy (all features).
- `TWINKO_LLM_PHASE_A.md` — Phase A engineering record; its §8.2 matrix
  and §10 disclosure draft are **implementation snapshots** subordinate to
  this spec.
- `docs/safety/TWINKOTALK_TRUST_SAFETY_LEGAL_GOVERNANCE.md` — governance
  baseline above this spec.
- Feature specs (Tarot usage spec, Horoscope feature spec, Chat screen
  spec) — reference this document; they must not restate or fork policy.
- `docs/product/TWINKO_DECISION_LOG.md` — D-037/D-038/D-041/D-043/D-044
  govern; approving this spec updates D-037's status.
