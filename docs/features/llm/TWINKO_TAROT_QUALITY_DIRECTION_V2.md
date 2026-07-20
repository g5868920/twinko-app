# Tarot Interpretation Quality Direction v2

**Status:** `Implemented for founder evaluation — quality outcome not yet
validated.` The prompt (§3) and rubric (§4) are now implemented in
`TarotPromptBuilder` / `TarotEvalHarness.reviewGuide()` (2026-07-21); the
founder will judge the quality outcome through further live test rounds.
The worked example (§7) illustrates the intent — it is NOT proof that v2
succeeds.
**Principle:** Do NOT shorten readings for mobile readability. Length is
acceptable — even preferred — when every paragraph adds insight. The issue
is insight DENSITY, not length. Length adapts to spread size (§2.9) and is
never scored by itself.

This document separates: **implemented requirements** (§2–§4, in code),
**provisional quality hypotheses** (§2 as a whole — pending founder
evaluation), the **deferred Meditation schema proposal** (§6), the
**evaluation criteria** (§4), and the **single OpenAI smoke-test record**
(§8).

## 1. Founder assessment of the first live reading (recorded)

**Preserve:** strong spread-position usage · correct reversed orientations
· successful cross-card synthesis · non-deterministic language · warm
zh-Hant · action orientation.
**Improve:** deeper + more specific (not shorter) · move beyond emotional
description · fewer repeated ideas, more substance · clearer behavioral and
strategic implications · more distinctive Twinko voice without losing rigor
· Guidance summary differentiated from base summary.

## 2. Quality principles v2

A strong reading helps the user understand: what may be happening → why the
pattern may exist → how emotional / behavioral / strategic / environmental
factors interact → what each card distinctly contributes → cross-card
tensions and trade-offs → which assumptions can be reality-checked → what
concrete next steps exist. "You feel tired / doubt yourself / rest / trust
yourself" may appear but never as the ceiling.

1. **Insight density.** Every paragraph must add ≥1 of: new causal
   hypothesis · distinct position contribution · cross-card tension ·
   behavioral implication · decision trade-off · reality-check question ·
   concrete action. Never: keyword restatement as sentences, repeated
   emotional themes, generic reassurance, multiple same-content summaries,
   anyone-advice.
2. **Four layers** (used where relevant, not mechanically): emotional
   (feelings/defenses/unmet needs) → behavioral (how those shape actions,
   communication, avoidance, consistency) → strategic (assumptions,
   priorities, feedback loops, trade-offs worth reviewing) → environmental
   (timing, other people, market, factors outside control). Never imply
   every outcome is caused by mindset.
3. **Position distinctness.** Cards sharing a reversed/negative tone must
   not converge on one interpretation. Each card = canonical meaning ×
   orientation × position function × the actual question × how it differs
   from the other cards. Three-card roles: current state DIAGNOSES the
   pattern; action identifies what can be CHANGED OR TESTED; direction
   describes what may EMERGE if the pattern continues or changes.
4. **Synthesis with added value.** Pattern counts (suits, majors, numbers,
   elements) are raw material, not the answer. The synthesis must answer:
   *what does this combination reveal that the cards would not reveal
   separately?* Name reinforcement / contradiction / progression, internal
   vs external tension, effort vs outcome, emotion vs action, agency vs
   timing, and the apparent central bottleneck.
5. **Testable hypotheses.** Interpretations are qualified hypotheses (一個
   可能是 / 或許值得確認的是 / 牌面似乎在強調), each reading offering ≥1
   gentle reality-check (what evidence supports/contradicts this? actual
   feedback or anticipated rejection? effort vs positioning vs feedback
   loop vs timing? which part is controllable?).
6. **Concrete, problem-specific actions.** Where appropriate: one
   low-effort action today · one deeper action this week · one question or
   metric to evaluate progress. Tarot supports structured reflection and
   better questions — never professional career/medical/legal/financial
   advice.
7. **Depth in final sections.** Integrated summary: central pattern +
   mechanism + controllable vs external + key trade-off + bridge to
   action. 「Twinko 想對你說」 is warmer and conversational but always
   carries a real insight or concrete step — never comfort alone.
8. **Guidance Card delta.** After a Guidance draw the section heading is
   differentiated (e.g. 「加入指引牌後」), and its content covers only the
   DELTA: the new dimension, whether it reinforces / redirects /
   complicates the base reading, and how it changes or sharpens the action
   — never a repeat of the base summary.

## 3. Proposed prompt changes (TarotPromptBuilder — for the next code batch)

- METHOD: add the four-layer instruction; require explicit per-card
  differentiation ("state how this card's contribution differs from every
  other card in this spread"); three-card role definitions.
- New INSIGHT DENSITY block: the every-paragraph rule + the prohibited
  list (keyword restatement, repeated emotional themes, generic
  reassurance, duplicate summaries, anyone-advice).
- Cross-card block: replace "analyze patterns where present" with the
  combination question, bottleneck naming, controllable-vs-external and
  trade-off requirements; forbid bare pattern-listing.
- New HYPOTHESES block: qualified language + ≥1 reality-check per reading.
- gentle_next_step: must contain (a) one low-effort today action, (b) one
  deeper this-week action, (c) one progress question or metric — all
  specific to the stated question.
- LANGUAGE/length: replace "roughly 3–5 sentences" with "as long as each
  sentence adds information (typically 4–8 sentences per card); never pad,
  never repeat"; add environmental honesty ("never imply outcomes are
  purely mindset; name external timing factors where relevant").
- Twinko voice note for gentle_next_step: warm, personal, but substantive.

## 4. Evaluation rubric v2 (REVIEW_GUIDE additions)

New human criteria (scored 1–5): insight density · emotional→behavioral
depth · behavioral→strategic depth · position distinctiveness · cross-card
added value · problem specificity · testable hypotheses · concrete
next-step quality · controllable-vs-external distinction · absence of
repetitive emotional paraphrasing. **Never penalize length itself.**
Penalize: repetition, generic content, low information gain, anyone-advice,
emotional description without behavioral/strategic implication.

## 5. Schema changes

**None implemented, none required.** Depth/density/layers/hypotheses/
actions are prompt + rubric enforceable in the existing prose fields; the
response schema is unchanged. The guidance heading (「加入指引牌後」/
"After Adding the Guidance Card") is a future app copy change bundled with
the (not yet live) guidance addendum.

## 5a. Meditation schema proposal — DEFERRED

The proposed `meditation { recommendation, prefilled_problem,
suggested_focus }` object is **deferred, not implemented**. Before any
schema coupling, evaluate: (1) how often Meditation is genuinely relevant
after a reading; (2) whether the generated recommendation invents context
(evidence-boundary risk); (3) whether app-side derivation from the
question + integrated summary is sufficient; (4) whether a future generic
`recommended_follow_up` structure is preferable to a Meditation-specific
field. The Tarot schema is not permanently coupled to Meditation. The §6
quality requirements remain the standard the handoff must eventually meet,
whichever mechanism is chosen.

## 6. Tarot→Meditation contextual handoff v2

**Context priority (strict order):** 1 user's original question → 2
integrated interpretation → 3 the central emotional/behavioral bottleneck
the reading identified → 4 the user's selected focus. Never derived only
from spread category, topic label, meditation type, broad phrases (「生活
方向」), or isolated keywords.

**Recommendation copy** must recognizably connect to THIS reading, with
qualified language (這次的牌面可能在提醒 / 你似乎正承受 / 也許值得先 /
如果這符合你現在的感受).

**Pre-filled problem** = concrete situation + main emotional/behavioral
pressure + desired internal shift, recognizably the user's own question;
always editable, presented as a suggestion, never auto-starting, never
silently replacing the user's wording, minimum context only. Never
pre-fill generic text (我對生活方向感到迷惘 / 我想放下焦慮 / 我希望找到
內心平靜) unless genuinely present. **Never invent problems** (fear of
success, trauma, global lack of confidence, lost in life, needing to
forgive) beyond the validated question + reading.

**Focus mapping:** 平靜下來 → accumulated tension/exhaustion; 釋放焦慮 →
waiting/rejection/outcome fixation; 照顧自己 → depletion/self-criticism;
準備入睡 → only when sleep/rumination relevant; 顯化意念 → never framed
as securing outcomes through belief/visualization.

**Review criterion:** *Could the user read the recommendation and pre-fill
and immediately recognize it came from this specific question and
reading?* Penalize generic summaries, lost original problem, unrelated
pre-fill, keyword-parroting, invented problems, and framing meditation as
replacing the real-world action (it regulates before the next action).

## 7. Worked example

The improved job-search example (權杖九逆 / 聖杯侍者逆 / 權杖六逆 + 指引
戀人逆) lives in the founder-review deliverable of 2026-07-21 (session
record); it becomes golden-case material for the step 7 blind review. It
illustrates intent only — it is not evidence that v2 succeeds.

## 8. OpenAI live smoke-test record (single)

OpenAI live Tarot completed one successful founder-only smoke test using
`gpt-5.6-terra` (2026-07-21): consent gate before the request, structured
response decoded and rendered, Debug provider/model diagnostic correct,
region-specific resource behavior correct. This verifies the first
end-to-end live path, not long-term stability, full spread coverage, full
safety coverage, or final provider selection. D-043 remains open. Full
record: `TWINKO_LLM_PHASE_A.md` §12.3.
