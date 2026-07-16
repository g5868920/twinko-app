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
