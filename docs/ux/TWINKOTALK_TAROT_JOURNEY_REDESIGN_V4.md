# TwinkoTalk Tarot Journey Redesign

**Version:** v4.0
**Status:** Implemented (prototype) — founder/CPO decisions 2026-07-16
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
Subtitles: 單張牌「一個此刻最需要的提醒」/ "A message for this
moment"; 三張牌「過去・現在・未來，看見事情的發展」/ "Past · Present ·
Future".

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
