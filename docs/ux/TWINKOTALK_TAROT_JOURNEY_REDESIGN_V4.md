# TwinkoTalk Tarot Journey Redesign

**Version:** v4.2
**Status:** Implemented (prototype) — founder/CPO decisions 2026-07-16,
refinement passes 2026-07-17 (see §10–§11)
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
