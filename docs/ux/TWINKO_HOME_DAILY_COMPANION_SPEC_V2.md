# Twinko Home — Daily Companion Redesign (V2)

**Status:** Implemented (prototype)
**Date:** 2026-07-16
**Authority:** Founder/CPO decisions 2026-07-16. Supersedes the Home layout
sections of `TWINKO_HOME_SCREEN_SPEC_V1.md` (five-icon orbit Home). All
non-layout rules in V1 (naming, no wordmark, localization, asset integrity)
remain active unless restated here.

## 1. Purpose

Home changes from five isolated feature icons into a daily-companion loop:

1. Notice how I feel → 2. Tell Twinko what I need → 3. Receive one
personalized recommendation → 4. Enter the most relevant existing feature.

## 2. Information architecture

Top-to-bottom on Home (`HomeView.swift`):

1. **Greeting header** — time-aware greeting (早安/午安/晚安 + preferred
   name; EN equivalents) plus the support line 「今天想先照顧哪一部分的自己？」.
   No streaks, counters, or gamification. Top-right **Settings gear** opens
   Settings directly (`SettingsSheetView`, language only) — a *different*
   destination from the My Planet tab.
2. **Daily Check-in card** — progressive disclosure (see §3).
3. **Twinko hero** — existing `twinko_default_smile_v1` art, gentle float
   (≈5 pt, ~2.8 s easeInOut loop), static under Reduce Motion.
4. **Personalized recommendation** — only after today's check-in (see §4).
5. **Contextual continuation** — conditional; only when real recent state
   exists (currently: a chat session updated today). Hidden otherwise; never
   fake history or zero-counters.
6. **Compact Explore shortcuts** — Tarot / Horoscope / Meditation / Music
   (not Chat — it has a tab). "View all" is the Explore tab.

Background stays `home_screen_v1` with a code-based readability gradient
overlay (Background = atmosphere, Twinko = focal, cards = info, CTA = action).

## 3. Daily Check-in

- Mood first: 「你現在感覺如何？」 with five code-rendered **Mood Orbs**
  (`MoodOrbView` in `HomeCheckIn.swift`) — 開心 warm yellow `#F4CF6E`,
  平靜 soft blue `#9CBBE8`, 焦慮 muted lavender `#B3A2E0`, 疲憊 soft
  coral/peach `#F0AFA0`, 迷惘 lavender-gray `#B6AFC9`. Twinko DNA (glossy
  eyes, simple mouth per mood) but deliberately simpler than the hero; no
  new PNG assets. Selected state = gold ring + checkmark (never color alone).
- Need second (appears after a mood is chosen): 「現在最需要什麼？」 chips —
  聊聊 / 安定下來 / 獲得方向 / 休息.
- After both: the card collapses to a summary (mood orb + 今天感覺／現在需要)
  with an 修改 button. Editable all day; not re-asked after navigating away
  the same day. One record per local day.
- Model `DailyCheckIn` (id, localDate `yyyy-MM-dd`, mood, need, createdAt,
  updatedAt) persisted via the existing `JSONStore` as `daily_checkin`.
  Emotional content is never logged to analytics.

## 4. Recommendation

Provider boundary `HomeRecommendationProviding` with deterministic local
`LocalHomeRecommendationProvider` now (AI-personalized later, same protocol).

- One short message acknowledging mood + need (natural tone, never
  "because you selected X") plus one small step.
- One primary CTA + one quieter text alternative.
- Need drives the primary action: 聊聊 → Chat; 安定下來 → 3-min Meditation
  (焦慮 → 釋放焦慮 focus, else 平靜下來); 獲得方向 → Tarot; 休息 → Sleep
  Meditation (Music remains a placeholder, offered as the quiet secondary).
- Check-in → Meditation handoff uses `MeditationSourceContext` with the new
  `MeditationSourceType.checkIn` (`"check_in"`), a short focus summary, and
  a recommended focus — no raw emotional text.

## 5. Bottom navigation (app shell)

`AppShellView.swift` owns exactly four top-level destinations — 首頁 Home,
聊天 Chat, 探索 Explore, 我的星球 My Planet. Each tab hosts its own
`NavigationStack` (kept alive across switches); feature-internal navigation
is unchanged. The root `RootRouterView` shows the shell for returning users;
onboarding is untouched.

- Tab icons are SF Symbols except My Planet, which uses the
  `home_my_planet_v1` asset (existing `home_my_planet_v1_transparent`
  imageset). Selected state = fill variant + bold label + color (never
  color alone; VoiceOver announces selected).
- Explore is the full catalog (Tarot / Horoscope / Meditation / Music).
- My Planet tab hosts the existing My Planet landing (`MyPlanetContentView`).
  Settings remains reachable both from My Planet and directly from the Home
  gear; they are distinct destinations.

## 6. Explicitly out of scope (not implemented)

Memory, Journal, Weekly Insights, streaks/coins, Journey engine, new
Music/Tarot/Horoscope/Meditation logic, any new router/DB/recommendation
framework, model calls.

## 7. Validation (2026-07-16)

- `xcodebuild build` clean; `HomeCheckInTests` (7 tests: check-in storage,
  same-day edit, day rollover, need→primary mapping, recommendation shape,
  check-in meditation context, tab mapping + Settings≠My Planet) plus
  existing Meditation/ChatViewModel tests all pass.
- Simulator walkthrough `testHomeRedesignWalkthrough`: initial Home,
  mood→need progressive disclosure, collapsed summary + recommendation,
  Settings gear vs My Planet tab, same-day no-re-ask. Screenshots H1–H4.
- Known environment note: the very first synthesized tap after launch can
  be dropped while the shell's tab stacks attach; the UI test settles 3 s
  and retries once.

## Bottom-navigation visibility mechanism (2026-07-17)

`ShellChrome.tabBarHidden` is now **derived, never imperatively
toggled by tab roots**: immersive screens (Tarot, Meditation, the
Horoscope content page) register a per-instance token on appear and
remove it on disappear, and Chat reports whether an active
conversation is open. The bar hides whenever any token exists or a
conversation is active. Rationale: the shell keeps all four tab roots
alive in a ZStack and their `onAppear` re-fires at unpredictable
times, which raced with (and could undo) an immersive push —
token-based derivation is idempotent and makes nested handoffs
(Tarot → Meditation) seamless. Visibility map: tab roots + Chat
History + Chat landing = visible; active conversation, Tarot (all
stages), Meditation (whole flow), Horoscope content = hidden.

---

# Addendum — Home + dock reference-alignment pass (2026-07-17)

**Reference.** The canonical combined visual reference for this pass is
`docs/ux/references/home_reference_v1.png` (the task brief named it
`home_reference_v2`, but no such file exists in the repository — v1 is
the file that contains the described combined concept: airy greeting,
large Twinko with a real speech bubble, compact Journey, polished mood
orbs, Explore row, floating glass dock). Guidance, not pixel-copying;
working product behavior wins over the image.

## What this pass changed

- **Mood selected state** (`MoodOrbView`): the thick gold ring +
  gold-check badge became a soft warm-gold halo behind the orb, a ~5%
  orb scale, a refined thin white highlight, and a small warm-white
  check at the upper-right — "gently illuminated", never form
  validation. The check remains the non-color signal.
- **Twinko prominence:** hero enlarged 96 → 108 pt with a slightly
  wider glow; the reference's small 「Twinko 建議 / Twinko Suggests」
  glass tag (one tiny star) now sits above the speech bubble.
  Floating motion, Reduce Motion behavior, and message logic
  unchanged.
- **Secondary action:** now a quiet ghost glass pill (translucent
  fill + white outline, 44 pt target) — clearly interactive, still
  visually behind the primary CTA. Routing unchanged.
- **Journey steps:** the fabricated "current step" highlight on step 1
  was removed — all three steps use equal treatment because no real
  progress state exists (no-fabrication rule).
- **Explore More:** Tarot now uses the same mini-card-with-star glyph
  as its Explore-map planet; Activities uses a place-beacon glyph
  (`mappin.and.ellipse`) instead of the forbidden navigation-arrow
  style. Labels/descriptors and routes unchanged (探索更多 retained).
- **Dock icon family:** Explore is a small drawn rocket ship
  (`DockRocketIcon` — explicitly not a paper-plane) with its gold
  trail; My Planet is a normalized drawn planet-and-ring
  (`DockPlanetIcon`) with a sparkle accent. **`home_my_planet_v1`
  (and its transparent derivative) is no longer referenced by the
  bottom navigation**; the raster assets remain in the repository and
  everywhere else they are used. All four icons share the 30 pt
  bounding box, weight, highlight, and active/inactive treatment.
  Dock structure, matchedGeometryEffect capsule, haptics, tab state,
  and feature dock-hiding untouched.

Unchanged and re-confirmed: `bg_home_screen_v2` background, one-screen
rule with the accessibility/edit scroll fallback, single-container
Check-in, need-chip 2×2 grid and icon family, collapsed summary +
Edit round-trip, recommendation/journey providers, no Settings on
Home.

## Validation (pass — strictly minimal)

Build clean. Directly affected existing tests:
`testSaveCreatesTodayCheckInAndPersists`,
`testSameDayEditUpdatesRecordInsteadOfCreatingNew`,
`testFourTabsAndSettingsIsNotATab` — all pass. One focused scripted
walkthrough (iPhone 16, zh-Hant): uncompleted greeting state → mood +
need selection → collapsed summary → Twinko/CTA/secondary/journey/
explore inspection → Edit round-trip → dock icons → one top-level tab
transition (Explore) → one immersive dock hide/restore (Explore →
Meditation → back). A first run silently used a stale app binary
(identifiers matched the old UI); after clearing DerivedData
intermediates the walkthrough passed against the new UI and the
screenshots were re-taken. EN spot check on the completed Home via
`-uiTestEnglish` (greeting, summary, journey title, explore label,
dock label). Reduce Motion verified by code inspection (existing
branches; no new motion system added). Three screenshots (S1–S3) plus
one replacement capture after the Activities-glyph correction.

## Addendum 2 — home_reference_v2 applied (2026-07-17)

Gina supplied the actual `home_reference_v2` visual inline (not yet
exported into `docs/ux/references/` — drop it there when convenient).
Applied against it, preserving all working logic and `bg_home_screen_v2`:

- Check-in card gains the ✨ 今日心情 / Today's Mood header + state
  question 「現在的你比較像哪一種狀態？」; mood orbs enlarged (48 pt),
  selected check moved to the reference position; a faint divider
  precedes 現在最需要什麼？; need chips restyled as leading-aligned
  rows with small filled icon squares. Instant save-and-collapse
  behavior retained (founder decision).
- Recommendation actions moved inside Twinko's speech bubble (primary
  capsule CTA with its action icon + quieter text-link secondary with
  chevron); Twinko enlarged to 122 pt. Provider/routing unchanged.
- Journey wrapped in one glass container with the ♡ 自由選擇，隨時開始
  caption; step cards use tinted icon orbs with corner number badges.
- Explore wrapped in a glass container, title 探索 / Explore;
  descriptors updated to the approved set (聆聽指引/今日能量/平靜身心/
  療癒旋律/探索附近); Activities uses the reference's arrow glyph in a
  blue orb (founder decision, supersedes the earlier no-arrow rule on
  Home). Dock unchanged: rocket + drawn planet retained (founder
  decision over the reference's two-planet dock).
- Per founder instruction, no tests or walkthroughs were run for this
  pass — one compile-check build only.

## Addendum 2 — reference asset crops + brightened glass (2026-07-18)

Founder-directed pass matching `home_reference_v2` (supplied in
conversation; visually continuous with the committed
`home_reference_v1.png`, which served as the crop source):

- **Reference artwork in the UI.** Eleven circular crops from
  `home_reference_v1.png` now live in the asset catalog
  (`ref_mood_{happy,calm,anxious,tired,confused}_v1`,
  `ref_icon_{chat,moon,star_orange,tarot,star_gold,music}_v1`) and are
  used by the mood orbs (`MoodOrbView`), Journey step icons, and four
  Explore orbs. They are placeholder-quality (≈45–50 pt source
  resolution, circular masks) and should be swapped 1:1 when original
  exports are provided. Activities has no crop in v1 and draws its
  reference-style white-arrow blue orb in code (founder approved the
  arrow, overriding the earlier beacon rule).
- **Brightened glass.** `TwinkoGlassSurface` moved to ultraThin
  material with a whiter lilac tint, stronger catch-light, and a
  brighter border; Home's background readability veil dropped from
  0.20/0.30 to 0.10/0.14; all Home container/bubble tints reduced —
  surfaces now read as the reference's light translucent glass rather
  than dulled panels. The shared dock uses the same brighter capsule
  treatment; its chat icon carries the reference's two tiny stars
  inside the bubble; Explore keeps the rocket (founder decision) and
  My Planet the drawn ringed planet.
- **Haptics.** Mood selection now fires the shared light haptic
  (needs already did).
- Per founder instruction, no tests or Simulator validation were run
  for this pass beyond one compile-check build.
