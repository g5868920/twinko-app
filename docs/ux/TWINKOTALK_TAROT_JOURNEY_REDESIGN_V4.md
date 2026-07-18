# TwinkoTalk Tarot Journey Redesign

**Version:** v4.3
**Status:** Implemented (prototype) — founder/CPO decisions 2026-07-16,
refinement passes 2026-07-17 (see §10–§14)
**Supersedes:** the flow-, layout-, shuffle-, and result-structure
sections of `TWINKOTALK_TAROT_SCREEN_SPEC_V3.md` and
`TWINKOTALK_TAROT_ANIMATION_SPEC_V1.md`. Data models, the 78-card
registry, draw logic, reversed-card support, Guidance Summary Card
rendering, and the Meditation handoff are unchanged and their specs
remain active.

## 1. Goal

Tarot becomes one immersive, readable, clearly paced magical reading
journey: topic → question → spread → vortex shuffle ritual → reveal →
scrolled interpretation → Twinko closing → one meaningful next action.
Each stage has one primary task.

## 2. Topics (six, exact labels)

`TarotTopicType`: `relationships / career / finance / growth /
lifePath / other` — stable language-independent identifiers.

| id | zh-Hant | English (exact) |
|---|---|---|
| relationships | 愛情與關係 | Relationships |
| career | 工作與事業 | Career |
| finance | 財務與投資 | Finance |
| growth | 自我成長 | Growth |
| lifePath | 生活方向 | Life Path |
| other | 其他 | Other |

- Fixed equal 2×3 grid; width never depends on text length; selected
  state = gold fill + check (never border color alone).
- Suggested questions are topic-specific (two per topic, approved copy
  in `TarotTopicType.suggestedQuestions`), rendered as equal
  full-width rows that populate the question input. Finance prompts
  are reflective only — never investment advice.
- No sessions are persisted with old topic raw values, so no stored
  migration was required.

## 3. Immersive navigation

- The shell bottom navigation hides on entering Tarot and stays hidden
  through every stage, including Tarot-derived Meditation, until
  navigation returns to a root tab (`ShellChrome.tabBarHidden`).
- All redundant top-center 塔羅 / Tarot titles removed; each stage
  keeps only the Back affordance and its content.
- **Back button / edge swipe = previous page.** Stage map: spread →
  setup; shuffle/reveal → spread; result → reveal (cards stay
  revealed); guidance reveal → result; first screen → the page Tarot
  was entered from. Backward navigation never redraws cards; cards
  redraw only on explicit spread re-selection or a new reading.
- **App-wide convention:** on non-root pushed pages, the native
  left-edge swipe returns to the previous page
  (`InteractivePopSupport.swift` restores UIKit interactive pop with
  the navigation bar hidden; root pages unaffected). Tarot's stages
  live inside one pushed view, so Tarot gates the native pop off while
  frontmost and drives a stage-wise leading-edge drag instead.
  Known limitation: on pages whose content owns horizontal drags at
  the touch point (e.g. the Horoscope zodiac selector row), the
  content gesture can win; verified working on Meditation.
- **回到首頁 / Back to Home** (result page) always navigates to the
  Home root, selects the Home tab, and restores the bottom navigation
  — regardless of where Tarot was entered.
- **開始新的占卜 / Start a New Reading** stays immersive: clears the
  reading and Guidance Card and returns to topic setup.

## 4. Spread selection

Two spreads with identical visual weight: shared fixed illustration
container (104 pt), equal card sizes, equal subtitle region.
Subtitles (exact, short): 單張牌「一個此刻最需要的提醒」/ "A message
for this moment"; 三張牌「過去・現在・未來」/ "Past · Present ·
Future". Previews are composed from the canonical card back in one
shared container — both center cards identical in size, three-card
sides at ~84% rotated behind — so neither option dominates.

## 5. Vortex shuffle (replaces the fan shuffle)

`TarotShuffleStage` (TimelineView-driven, ~2.9 s): energy awakens at
the lower altar → a reusable pool of 14 card backs rises in layered
spiral paths (varied scale, depth, rotation, delay, speed) around the
casting Twinko → the vortex slows and converges into exactly the drawn
1 or 3 cards while the rest dissolve and fall away. Selection indices
come from `TarotShuffleChoreography`; card identities always come from
the draw engine. Reduce Motion: a simple rising fade with the same
draw result and completion timing.

**Casting Twinko:** canonical `twinko_tarot_casting_v1` has NOT been
delivered. The delivered magic pose has furrowed brows (ruled out for
casting); `TarotTwinkoState.casting` therefore aliases the approved
gentle idle wizard pose with the energy ring rendered in code. Swap
the one alias mapping when the canonical asset arrives.

## 6. Reveal

Unrevealed / flipping (3D Y-flip ~600 ms; Reduce Motion crossfades) /
revealed states preserved. Instruction copy: 「輕點牌面，把牌翻開」→
「繼續翻開下一張牌」→ transition into the reading. Every revealed card
gets the subtle warm-gold activation glow (`tarotRevealedGlow`) — a
soft breathing shimmer, static under Reduce Motion.

## 7. Result page

Begins directly with interpretation — no repeated result hero. One
warm-white matte editorial system (`tarotReadingCard()`), magical
dividers (`TarotMagicalDivider`) only between major groups:

- **Single Card:** interpretation → Twinko message → Guidance Card →
  Save → Meditation → exits → disclaimer (no redundant synthesis).
- **Three Cards:** Past/Present/Future interpretations + Overall
  Synthesis (same group) → Twinko message → Guidance Card → Save →
  Meditation → exits → disclaimer.
- Full interpretations shown by default — 「展開完整解讀」removed.
- Per-card mini reflections (「小小的反思」) removed.
- `overallSynthesis` (provider `synthesis`) and `twinkoMessage` remain
  distinct provider fields — never the same string.
- Guidance Card: one optional draw per reading
  (`TarotReadingSession.canDrawGuidance`); the prompt disappears after
  drawing and the drawn card joins the reading in the same style. Now
  offered for both spreads.
- 儲存指引小卡 / Save Guidance Card is the single export entry on the
  result page; the separate 分享結果 / Share Result action is removed.
  The Guidance Card preview sheet keeps its rendered-image ShareLink.
- Personalized Meditation is one merged section: crescent icon +
  「把這份指引化成一段冥想」+ description + 「生成專屬冥想」CTA →
  straight to the Meditation Context Review with the existing
  Tarot-derived context adapter (now mapping all six topics).
- Exits are quiet: Start a New Reading (restrained secondary), Back to
  Home (text).
- Disclaimer, once, absolute bottom, low prominence:
  「內容僅供反思與娛樂」/ "For reflection and entertainment only".
  Never inside the Guidance Summary Card.

## 8. Effects system (centralized in `TarotEffects.swift`)

- `TarotMagicPrimaryButtonStyle` (`.tarotMagicPrimary`): gold capsule +
  press scale 0.97 + soft gold halo + 4 restrained edge sparkles +
  light haptic. Applied to Tarot action CTAs (Next, spread choice, see
  reading, draw/save Guidance, meditation, magic effects honored by
  Reduce Motion). Navigation controls keep standard feedback.
- `TarotMagicalDivider`, `tarotRevealedGlow`, `tarotReadingCard()`.
- Background readability: full-screen deep-purple overlay raised to
  ~0.22–0.38 (top→bottom); reading content sits on warm-white cards.

## 9. Validation (2026-07-16)

Build clean. `TarotDrawTests` (23) pass, including new: six topics +
exact EN labels, topic-specific localized suggestions, one-draw
Guidance limit, new-reading reset, approved disclaimer, vortex pool
convergence count, six-topic meditation recommendations. Focused
Simulator walkthrough `testTarotRedesignWalkthrough` passed (immersive
shell, six topics, equal spreads, three-card convergence, partial
reveal glow, restructured result, one Guidance draw, Save present /
Share absent, merged meditation section, Start a New Reading, Back to
Home restoring the tab bar, native edge swipe verified on Meditation).
Screenshots T1–T5.

## 10. Refinement pass (2026-07-17)

- **Premium CTA system** (`TarotCTAPalette`, applied Tarot-wide):
  primary = deep amethyst gradient + antique-gold border + warm light
  text + restrained violet glow (下一步, 看看牌想說什麼, 抽一張指引牌,
  生成專屬冥想, summary-sheet share); secondary = quieter deep-purple
  surface + thin gold border (儲存指引小卡, 開始新的占卜); tertiary =
  text-led (回到首頁). Primary/secondary keep the magical press
  feedback (scale, halo, sparkles, light haptic); tertiary and Back
  use standard feedback. The bright orange treatment is retired inside
  Tarot. Brand logic: blue-violet = magical energy, gold = chosen.
- **Shuffle upgrade:** shuffle Twinko enlarged to 216 pt with a
  blue-violet energy ring and aura; the tornado is bigger (radius
  108–180, cards emerge from lower off-stage), with a narrowing funnel
  as it rises; violet card trails resolve into gold auras on the
  chosen cards; violet + gold stardust. Settled cards hover in a row
  clearly above Twinko's head (settleY −176), never on the forehead.
  Copy is exactly 「讓牌在星光中回應你的心意……」.
- **Moonlit ivory surfaces:** all reading containers use one warm
  ivory → soft lavender gradient (never pure white) with a faint
  antique-gold border; the guidance prompt joins the same family.
  The moon icon before Twinko 想對你說 (and the sparkles icon before
  整體來看, and the meditation crescent) are gold accents.
- **Guidance restructure:** once drawn, the 指引 card joins the
  reading directly after the original cards, followed by an
  **expanded 整體來看** (`combinedSummary`, now covering single +
  guidance as well) and Twinko 想對你說 derived from the full current
  state; the 抽一張指引牌 CTA disappears. Original card
  interpretations, identities, and orientations are never
  regenerated. Order after guidance — three: 過去/現在/未來/指引 →
  整體來看 → Twinko 想對你說 → 儲存 → 冥想 → exits → disclaimer;
  single: 主牌/指引 → 整體來看 → Twinko 想對你說 → …
- The Summary Card and the Meditation handoff always render from the
  current session state, so both reflect the expanded reading after a
  Guidance Card (already-exported images are never altered).
- Validation: build clean; TarotDrawTests 27/27 (new: approved spread
  subtitles, starlight shuffle copy, expanded combined summary for
  both spreads, Twinko-message expansion); one focused Three-Card
  Simulator walkthrough incl. post-guidance expanded result + summary
  sheet; 5 screenshots (T1–T5). Single-card post-guidance behavior
  verified via the unit tests above.

## 11. Final polish + Summary Card V2 (2026-07-17)

### Flow polish
- **Completed reveal state:** Back from the Result re-enters Reveal
  with every card face already shown (identities, positions,
  orientations, glow preserved) — no card backs, no re-flip, no
  shuffle replay. Copy 「這就是你本次抽到的牌」+ CTA 「查看完整解讀 /
  View Full Reading」. Redraws happen only via explicit spread
  re-selection or 開始新的占卜.
- **Topic selection styling:** selected = deep amethyst surface +
  antique-gold border + warm-ivory text + gold check + subtle violet
  glow; unselected = dark translucent plum. Selection never relies on
  color alone.
- **Spread copy:** 單張牌「此刻最需要的提醒」/ "Quick Insight";
  三張牌「過去・現在・未來」/ "Past · Present · Future".
- **Shuffle ritual tuning:** orbit radius +~25% (135–225), speed
  −~20%, larger card backs (66 pt), per-card drift for imperfect
  elliptical paths, total ≈3.5 s with the settled cards holding ≈0.8 s.
  Energy ring is now two rotating incomplete blue-violet arc segments.
  Copy switches to 「你的牌已在星光中浮現 / Your cards have emerged in
  the starlight」 once convergence completes. Selected cards enlarge on
  settle (single ×1.30; three ×1.18 with the center ×1.25) and hover
  clearly above Twinko's hat (settle offset −204/−196 relative to the
  character frame).
- **Flip haptics:** light impact when a flip begins, very soft settle
  impact when the face lands, slightly stronger (medium) on the final
  required card. UIKit honors the system haptic setting; Reduce Motion
  keeps the haptics with the crossfade reveal.
- **Guidance insertion:** returning from the Guidance reveal scrolls
  the result to the inserted 指引 section with a brief gold glow —
  never jumping to the top.
- **Primary CTA gradient** pinned to ≈#6248A6→#3E2C73 with gold Label
  icons; Moonlit Ivory surfaces pinned to #FFF9EE→#F7F0F8 (94%),
  antique-gold border 30%, deep-plum shadow 16%.

### Guidance Summary Card V2
- **Background:** production `bg_tarot_summary_card_v2.png`
  (`assets/tarot/backgrounds/`, bundled as the 3× `bg_tarot_summary_
  card_v2` imageset). Runtime layered composition — never a screenshot.
- **Export geometry matches Horoscope exactly:** 360×480 design at 3×
  → 1080×1440 (`TarotSummaryCardView.designSize ==
  HoroscopeSummaryCardView.designSize`, unit-tested).
- **Layer order:** background → readability gradient → TwinkoTalk
  brand / 塔羅指引 title / localized date / topic badge → card artwork
  → 整體訊息 Moonlit Ivory panel → Twinko closing strip (idle wizard +
  message + TwinkoTalk signature over translucent dark plum + gold
  divider).
- **Four layout modes** (`TarotSummaryLayout.mode(for:)`): single
  (one large centered card); three (Past/Present/Future row);
  single+guidance (two balanced cards labeled 主訊息／指引, guidance
  gold-glowed); three+guidance (row + guidance centered below a small
  connector spark — never a fourth chronological position; compact
  name・orientation labels keep the synthesis un-clipped).
- 整體訊息 and the closing always use the **current** reading state
  (`combinedSummary` / `twinkoMessage`), so post-Guidance cards carry
  the expanded synthesis. Excluded from the image: profile data, the
  question, full interpretations, CTAs, disclaimer.
- **Preview sheet:** uncropped aspect-fit preview of the exact render;
  three distinct actions — 儲存到照片 (primary, PHPhotoLibrary
  add-only), 分享 (secondary, native share sheet with the same
  rendered image), 關閉 (tertiary). Preview, saved, and shared images
  are one render.

### Validation (2026-07-17, pass 3)
Build clean. TarotDrawTests 29/29 (new: layout-mode selection, export
geometry equals Horoscope; updated spread subtitles + emerged copy).
Render probe verified all four Summary Card modes at 1080×1440 with
no clipped text. Focused Three-Card walkthrough passed incl. Result→
Back completed-reveal state, post-Guidance updates, and the three
distinct sheet actions. Screenshots T1–T5. Single-card modes verified
via unit tests + render probe.

## 12. Flow exit control (2026-07-17)

Top-right `X` on every Tarot stage (setup → guidance): Back = previous
step, X = leave the whole flow to its **original source** (the flow is
one pushed view, so dismiss returns to Explore, Home, or wherever it
was entered — never forced to Home; the revealed root restores the tab
bar). Before meaningful state (setup, spread) X exits directly; from
the shuffle onward (`TarotFlowView.requiresExitConfirmation`) a branded
confirmation appears: 「要先離開這次占卜嗎？」/「這次的占卜流程會先結
束，你之後可以再重新開始。」· 繼續占卜 preserves all reading state /
離開占卜 exits (saved Summary Cards untouched). Back, Back to Home, and
Start a New Reading are unchanged.

## 13. Polish notes (2026-07-17, pass 4)

- Moonlit Ivory reading surfaces blend slightly deeper into the scene
  (gradient opacity 0.94 → 0.88); border, typography, and structure
  unchanged; readability re-verified in the Simulator.
- Completed-reading Back behavior re-verified after the shared
  tab-visibility change: Result → Back shows the same revealed faces
  (no card backs, no shuffle replay, no redraw) with the
  查看完整解讀 completed-state CTA; reveal state remains the single
  source of truth (`revealSeen` + `initiallyRevealed`).

## 14. UX fixes + focused visual polish (2026-07-17, pass 5)

### Header and navigation
- **Floating header controls:** no local bar, background, safe-area
  fill, or top strip on any Tarot stage — Back (left) and Close/X
  (right) float directly over the illustrated scene, inside the safe
  area, never overlapping Twinko, cards, or headings.
- **Unified Back/X styling:** one control system — restrained warm
  gold (`TarotCTAPalette.antiqueGold`), identical size/weight
  (16 pt semibold), a faint deep-space halo for contrast, 44×44 pt tap
  targets, shared subtle press feedback + light haptic
  (`tarotHeaderControlIcon()` + `TarotHeaderControlStyle`). Never one
  gold icon and one flat white icon.

### No-scroll rule for guided stages
- Topic/question setup, spread selection, shuffle, reveal, the
  completed-reveal landing, and the exit modal fit **without vertical
  scrolling** at standard Dynamic Type on a modern iPhone.
- Setup uses `ViewThatFits` with a scroll fallback reserved for small
  devices, Accessibility Dynamic Type, and the open keyboard; a greedy
  outer frame keeps the stage (and the flow background) full-screen.
- **Result-page exception:** genuinely long interpretation content
  remains scrollable — one curated journey, never truncated, no
  expand/collapse controls.

### Revealed-state persistence (critical rule)
- Reveal state is **session-owned**: `TarotReadingSession.revealSeen`
  (never stage-local view `@State`). Result → Back always shows the
  same face-up cards — IDs, orientations, and spread positions
  unchanged; cards are never redrawn, rerandomized, or re-hidden by
  backward navigation. Reveal → Back returns to spread selection where
  a new draw may be started explicitly.
- Root-cause note (this pass): the session state was already correct,
  but `FlipTarotCard` only showed the card front once its flip angle
  passed 90°, and the angle was view-local starting at 0 — so a
  re-entered completed reveal *reported* face-up while *rendering*
  card backs. Cards created already-revealed now start at the flipped
  angle. Unit test `testCompletedRevealStatePersistsWhenReturningFrom
  Result` plus UI walkthrough `testTarotUXFixesWalkthrough` guard both
  layers.

### Exit modal (approved concise copy)
- 「要先離開占卜嗎？」/「這次占卜會結束。」· 繼續占卜 / 離開占卜 —
  English: "Leave this reading?" / "This reading will end." /
  Continue Reading / Leave Reading. Branded compact modal (never a
  native alert); the leave action keeps the muted-coral destructive
  token, not bright red. Supersedes the longer §12 copy.

### Shuffle ritual (calm magical ritual)
- **Duration:** convergence completes ≈3.7 s; the settled cards hold
  suspended ≈0.7 s before the transition (total ≈4.4 s). Supersedes
  the §11 ≈3.5 s timing.
- **Motion:** wider orbit (radius 155–255) and slower revolutions
  (≈0.29–0.48 rev/s); selected cards still separate clearly above
  Twinko's head and enlarge on settle; one light haptic marks
  convergence.
- **Blue/blue-violet sparkle layer:** deterministic icy-blue
  (#9FD4FF) and blue-violet (`violetGlow`) star glints
  (`TarotShuffleGlints`) ring the vortex edges with phase-offset
  twinkle pulses and a soft presence floor — visible but restrained,
  never over Twinko's face, no particle system, removed as the cards
  converge. The blue-violet arc ring now accompanies most of the
  ritual and dissolves into convergence.
- **Reduce Motion:** simplified lift/fade with a static blue-violet
  glow, extended timing (≈2.8 s) so the ritual still reads.

### Result page (warm matte glass + hierarchy)
- **One surface system** (`tarotReadingCard`): warm ivory→lilac-ivory
  gradient at 0.82 opacity (never pure white), soft internal top
  highlight, low-opacity antique-gold border, restrained shadow — no
  strong floating-card halo. The `.companion` variant warms the tint
  slightly for Twinko's message only.
- **Hierarchy:** cards → per-card readings (lead sentence emphasized
  by weight, supporting text regular) → 整體來看 elevated one type
  step as the synthesis → Twinko 想對你說 (companion) → guidance /
  save / meditation actions → quiet exits → single short disclaimer
  (「內容僅供反思與娛樂」/ "For reflection and entertainment only").
- **Star = Twinko guidance, moon = Meditation:** 「Twinko 想對你說」
  uses a small refined gold star (subtle sparkle accent) plus a tiny
  three-star signature divider; the Meditation section keeps
  `moon.stars.fill`. Magical dividers remain reserved for major
  chapter breaks — never between paragraphs, and containers are not
  added to solve hierarchy.
- CTA hierarchy unchanged (§11 system): one dominant primary per
  stage, secondary glass, text actions for low-priority navigation.

### Validation (pass 5 — strictly minimal)
Build clean. Targeted unit test
`testCompletedRevealStatePersistsWhenReturningFromResult` passed (one-
and three-card sessions). One focused three-card Simulator walkthrough
(`testTarotUXFixesWalkthrough`, iPhone 16 — scripted because host
assistive access for manual clicks was unavailable): floating header,
longer sparkle shuffle, reveal, result hierarchy, **Result → Back
same-cards verification** (labels, orientations, order; zero card
backs), exit-modal copy. Four screenshots (W1–W4). One-card flow
shares the same session-state path (verified by code inspection + the
unit test). Export logic, Meditation handoff, and interpretation
generation untouched.

---

## 15. Phase 1 — Canonical spread library + intent-first pre-reading (2026-07-19)

**Status:** Implemented, **not publicly activated** (development-gated).
**Canonical product source:** `docs/features/tarot/TWINKOTALK_TAROT_USAGE_SPEC.md`
(v2.0) — product logic, copy, and future draw/result/premium contracts live
there; this section records only what Phase 1 implemented and its boundary.

### 15.1 Implementation boundary

Phase 1 delivers the complete pre-reading experience up to a validated launch
boundary and intentionally stops there. Not implemented (deferred): generalized
draw (Task 2), 4-/5-card drawing (Task 2), reveal/result generalization and
position-aware interpretation (Task 2), Guidance Card generalization (Task 2),
Daily Tarot entry/limits/persistence (Task 3), Chat/Home contextual handoffs
(Task 3), reading history, premium/periodic spreads (`weeklyGuidanceSeven`,
`monthlyGuidanceFour`, `yearlyGuidanceTwelve`, `celticCrossTen` remain
spec-only and are absent from all MVP UI and the active library).

### 15.2 Canonical spread model (`TarotSpreadLibrary.swift`)

One centralized source defines the ten MVP spreads:

| `TarotSpreadID` | Cards | Ordered `TarotPositionID`s | Input kind | Layout kind |
|---|---|---|---|---|
| `singleCard` | 1 | momentMessage | generalQuestion | single |
| `timelineThree` | 3 | past · present · possibleDirection | generalQuestion | threeLinear |
| `actionDirectionThree` | 3 | currentSituation · availableAction · possibleDirection | generalQuestion | threeLinear |
| `blindSpotThree` | 3 | currentUnderstanding · unseenPerspective · possibleReframe | generalQuestion | threeLinear |
| `holisticCheckInThree` | 3 | bodySignal · thoughtsFeelings · innerCare | generalQuestion | threeLinear |
| `thinkFeelActThree` | 3 | whatIThink · whatIFeel · howIRespond | generalQuestion | threeLinear |
| `directionPathThree` | 3 | whereIAmNow · whereIWantToGo · howIMoveCloser | generalQuestion | threeLinear |
| `coreClarityFour` | 4 | coreIssue · currentObstacle · possibleApproach · availableStrength | generalQuestion | fourGrid |
| `twoChoiceFive` | 5 | optionAState · optionBState · optionADirection · optionBDirection · yourCurrentState | twoChoice | twoChoiceFive |
| `relationshipFive` | 5 | myState · myFeelingsAttitude · theirPresentedState · theirPresentedAttitude · relationshipDirection | relationship | relationshipFive |

All display copy (titles, purposes, recommendation reasons, position labels,
abbreviated preview labels, guidance, placeholders, examples, card-count
labels) localizes through functions; identifiers are never translated strings.
`supportsGuidanceCard` is recorded (`true` for all ten) but Guidance Card
behavior is untouched. `holisticCheckInThree` is the reserved future Daily
Tarot Check-in spread — no duplicate identifier, no Daily routing.

### 15.3 Intent-first flow (`TarotPreReadingFlow.swift`)

`Intent Selection → (inline refinement when needed) → Recommended Spread Setup
→ Setup Review → launch boundary`. Seven landing intents (`TarotIntent`), with
deterministic mapping: quickReflection→singleCard;
understandProgression→timelineThree; missingPerspective→blindSpotThree;
compareTwoChoices→twoChoiceFive; romanticRelationship→relationshipFive;
nextStepOrDirection refines to practicalNextAction→actionDirectionThree /
understandWhyStuck→coreClarityFour /
knownDirectionUnknownPath→directionPathThree; understandMyself refines to
wholePersonCheckIn→holisticCheckInThree /
specificSituationReflection→thinkFeelActThree. No LLM, no free-text
classification, no randomness. Card count is supporting information only.

- **Recommended Spread Setup:** small `Twinko 建議` / `Twinko Suggests` badge
  (never in the title), title, one-sentence reason, short purpose, card count,
  compact position preview (five layout kinds built from the canonical card
  back), spread-specific guidance/placeholder, required inputs, ≤3 selectable
  examples (prefill only, never submit), `更換牌陣`, primary continue.
- **Change Spread:** branded sheet, three groups (快速反思 / 三張牌視角 /
  深入反思), each row shows title + purpose + card count + selected state;
  `relationshipFive` carries the 感情限定 / Romantic relationships caption.
  Changing mutates the same draft, preserves compatible general-question text,
  keeps structured values attached to the draft (incompatible fields are not
  rendered), never auto-starts, and a manual choice replaces the
  recommendation badge with a quiet 自選牌陣 / Your choice caption.
- **Inputs:** general spreads keep the existing optional multiline question;
  `twoChoiceFive` requires decision context + Option A + Option B (trimmed,
  inline field-level validation, no alerts, nothing invented);
  `relationshipFive` requires the relationship question, with an optional
  non-identifying person label (感情限定 copy, no hidden-mind claims).
- **Setup Review:** question/context (+A/B or person label where relevant),
  spread title, purpose, card count, ordered position meanings, 修改問題,
  更換牌陣, and the explicit `開始抽牌` / `Begin Reading` CTA, which
  revalidates and produces one canonical `TarotReadingLaunchRequest(draft:)`.
  No cards, orientations, reveal, or result state are created anywhere in
  pre-reading.

### 15.4 Draft ownership and launch boundary

`TarotReadingDraft` (id, recommended vs selected spread ID, intent,
refinement, question, decisionContext, optionA/B, relationshipPersonLabel,
phase) is owned solely by `TarotPreReadingFlowView`; every screen mutates the
same draft, so input survives Back navigation and Change Spread. Phases:
intentSelection → spreadSetup → setupReview → readyToLaunch.

**Public activation status:** the live reading engine accepts only
`TarotSpreadType` (1/3 cards with past/present/future result semantics), so no
safe seam exists that could launch the ten new spread IDs without changing
draw/reveal/result behavior. The public Tarot entry therefore still runs the
proven v4 flow (§1–§14) unchanged; the Phase 1 flow activates only through the
existing launch-argument development mechanism (`-tarotPreReadingV2`, same
family as the `-uiTest…` hooks). Task 2 connects the launch request to a
generalized engine and activates the flow publicly.

### 15.5 Validation (strictly minimal, per instruction §35)

One `build-for-testing` build; unit test `TarotPreReadingTests` (definitions /
mappings / draft validation); one focused Simulator walkthrough
(`testTarotPreReadingWalkthrough`: Explore → 找出下一步與方向 → 卡住原因 →
Core Clarity setup → example prefill → Change Spread to Timeline and back →
review → Edit Question draft check → bounded Two-Choice validation spot
check, 4 screenshots T1–T4) plus `testTarotPreReadingEnglishSpotCheck`
(landing + one setup + Change Spread sheet in English). Results recorded in
the task report.

---

## 16. Task 2 — Flexible reading engine, 1/3/4/5-card readings (2026-07-19)

**Status:** Implemented and **publicly activated**. This section supersedes
§15.4's activation paragraph: the intent-first pre-reading (§15) is now the
live public Tarot entry, and the legacy topic/spread pre-reading stages
(§2, §5 of this document's original flow) are retired. Canonical product
source remains `docs/features/tarot/TWINKOTALK_TAROT_USAGE_SPEC.md`.

### 16.1 Boundary

Implemented: consumption of the Task 1 `TarotReadingLaunchRequest`; one
canonical active `TarotReadingSession`; descriptor-driven reading for all ten
MVP spreads (1/3/4/5 cards); unique per-position draw with once-assigned
orientation; generalized shuffle → reveal → result; per-position session-owned
reveal state; spread-specific result grouping; position-aware deterministic
mock interpretation; integrated summary for every reading; Two-Choice
neutrality and Relationship presented-state safety language; one optional
Guidance Card for every spread.

Not implemented (Task 3+/spec-only): Daily Tarot entry/limits/persistence,
Chat/Home handoffs and source-aware return, reading history, saved readings or
cards, LLM interpretation, backend, premium/periodic spreads (weekly, monthly,
yearly, Celtic Cross remain absent from all UI).

### 16.2 Session, deck, and phases

`TarotReadingSession` (TarotEngine.swift) is the one source of truth: stable
`id`, `spreadID`, validated inputs copied verbatim from the launch request
(question, decision context, Option A/B, optional person label, intent), drawn
cards, `revealedPositionIDs: Set<TarotPositionID>`, `guidanceCard`,
`revealSeen`. Cards are drawn once at Begin Reading (the existing ritual
pattern) by `TarotDrawEngine.draw(spreadID:)` — one unique card per canonical
position in canonical order, orientation assigned exactly once, identity never
derived from choreography. The Guidance Card draws from the remaining deck
(`drawGuidance(excluding:)`), role `.guidance`, never a numbered position,
at most one per session. Flow phases: pre-reading (Task 1 view, kept mounted)
→ shuffle → reveal → result → guidanceReveal → result. View recreation and
Back navigation never mutate the session; `assertionFailure` guards
definition/count mismatches in development builds.

### 16.3 New Reading / reset boundary

New Reading (result) and Back before the result (confirmed via the branded
「要回到設定嗎？」 modal) both clear the active session and return to the
still-mounted Task 1 pre-reading with the draft intact; the next Begin Reading
creates a new session ID and deck. Cards are never reinterpreted under a
different spread. Back from result → completed face-up reveal → result stays
unchanged (same cards, same orientations, Guidance Card intact).

### 16.4 Reveal and progress

One reveal stage serves every spread: ≤3 cards in one row; 4 as 2×2; 5 as
2+2+1 (Two-Choice reads as A|B columns, Relationship as my-side/other-side
rows with the direction centered). Multi-card reveals show localized progress
(`已翻開 x / N 張・下一張：<position>` / `x of N cards revealed · Next: …`).
Each flip reports its canonical position to the session; rapid or repeated
taps are idempotent and can never overdraw.

### 16.5 Result generalization

Hierarchy: context card (question or decision context + A/B, optional person
label, spread title, purpose, card count) → base-card sections in canonical
order — grouped with equal visual weight for Two-Choice (選項 A/選項 B/你目前的
狀態, user labels shown, no winner language) and Relationship (我這一邊/對方呈現
的一邊/關係的可能走向) — each section: numbered position badge, card art, name,
orientation, keywords, position-aware interpretation, one reflection sentence
→ 整體來看 integrated summary (every spread; Two-Choice neutral comparison,
Relationship presented-state reflection, expands when the Guidance Card joins)
→ Twinko closing → optional Guidance Card draw (CTA removed after the one
draw; distinct 指引牌 section) → save card → meditation → exits → single
canonical disclaimer.

### 16.6 Interpretation boundary

`MockTarotInterpretationProvider` stays the deterministic prototype boundary:
position frames now cover all 21 canonical position IDs plus the guidance
role (zh/EN), composed with the existing suit/arcana theme, orientation
nuance, and intent-derived topic flavor (`TarotReadingSession.topicFlavor` —
no question-text classification). Two-Choice copy never ranks or chooses;
Relationship copy never claims hidden thoughts, cheating, contact, or destiny.

### 16.7 Validation (strictly minimal, per instruction §46)

One `build-for-testing` build; directly affected unit-test groups
`TarotDrawTests` (migrated: canonical counts/uniqueness/order, guidance
exclusion and single-draw, session stability, safety language, summaries) and
`TarotPreReadingTests`; one Core Clarity Simulator walkthrough
(`testTarotReadingCoreClarityWalkthrough`, includes the bounded Two-Choice
five-card result check — no fixture/preview mechanism exists, so the shortest
normal UI route was used) plus `testTarotReadingEnglishSpotCheck` (three-card
EN: progress, result headings, Guidance CTA, disclaimer). Results in the task
report. Reduce Motion and Relationship layout verified by code inspection.
