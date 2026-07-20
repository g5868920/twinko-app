
> **Safety authority (2026-07-21):** any future LLM-backed Chat behavior is
> governed by `docs/features/llm/TWINKO_LLM_SAFETY_PRIVACY_SPEC.md` (DRAFT,
> awaiting founder sign-off) plus D-037; Chat also sends only minimum
> bounded context per that spec's data inventory. This spec must not fork
> safety policy.

## Implemented behavior — v1.2 Chat refinement (founder/CPO review 2026-07-16)

- **Meditation intent.** A centralized deterministic matcher
  (`MeditationIntentDetector`, EN + zh-Hant, model-replaceable)
  distinguishes request intent (我想要冥想 / 帶我冥想 / 我想靜一下 /
  我需要放鬆 / "I want to meditate"…) from topic mentions
  (我昨天做冥想反而睡不著 / 你覺得冥想有用嗎…). Only request intent
  shows the confirmation card. Explicit feature intent is routed
  before scripted/fallback responses, so a clear meditation request
  can never receive the misunderstanding reply.
- **Confirmation required.** Explicit requests never navigate
  immediately: Twinko acknowledges, then a contextual confirmation
  card appears after the related message —「好呀。要不要讓我根據我們
  剛剛聊的事情，為你準備一段專屬冥想？」with a dominant「好，為我準備」
  CTA and a quiet「先不用」decline.
- **Centralized offer state.** Explicit and proactive triggers share
  one conversation-level `ChatMeditationOffer` (source, related
  message ID) on the view model; never two cards at once. Proactive
  suggestions appear at most once per conversation (persisted flag on
  the session), only after a meaningful exchange; declining blocks
  further proactive offers but a later explicit request reopens
  confirmation. Declining dismisses silently — no reply message.
- **Accept handoff.** `ChatMeditationContextAdapter` derives a concise
  reflective focus summary + recommended theme from recent user
  messages (never raw quotes) and opens the Meditation Context Review
  directly, prefilled, with return navigation to the conversation.
- **Quick prompts.** Restyled as translucent lavender suggestion cards
  (icon chip + chevron, 44 pt) clearly distinct from the white
  composer.「我最近有點喘不過氣」was replaced with「我最近壓力有點大」—
  breathing-difficulty wording is reserved for safety routing.
- **Composer.** Send button is vertically centered against the
  single-line field (consistent inset when expanded).
- **Scrolling.** Message list uses a bottom default scroll anchor,
  top content padding, and a subtle header backdrop; new messages and
  the confirmation card scroll into full view above the composer.
- **Titles.** ChatGPT-style topic titles (面試前的心情 / 最近的工作壓力 /
  Recent work stress…) generated once after the first exchange by the
  locale-aware fallback provider; manual rename locks the title
  permanently (`titleSource = user`).
- **Chat History.** Rows grouped by 今天 / 昨天 / 過去 7 天 / 更早
  (localized), newest first per group; quieter lower rows; previews
  use the latest message normalized to one trimmed line with leading
  hesitation fillers softened.
- **Menu.** The star toggles the quick menu open/closed; outside tap
  still dismisses; the separate floating X was removed.
- **Rename.** Auto-focused field, Return saves, trimmed, empty
  rejected, 30-character cap, Save disabled while invalid.

## Chat polish + localization amendment (2026-07-17)

Supersedes the corresponding sections above where they conflict.

- **Landing:** the generic 聊天/Chat page title and the translucent
  header gradient block are removed — the landing keeps only the
  top-right star menu over the approved background. Welcome copy is
  exactly 「我在這裡陪你」(no ending punctuation) +
  「今天想聊些什麼呢？」/ "I'm here with you" + "What's on your mind
  today?".
- **Quick prompts** (approved copy): 我想聊聊今天發生的事／我最近壓力
  有點大／我只是想有人陪我 · "I want to talk about my day" / "I've
  been under some pressure lately" / "I just want some company".
  Equal full-width rows, natural wrapping up to two lines (no font
  shrinking/clipping), fixed leading icon + trailing chevron, quiet
  pressed state. Tapping a prompt starts the conversation directly
  with the prompt as the first user message.
- **Composer send button:** premium violet treatment (brandPurple→
  brandPurpleDeep gradient, restrained glow, centered icon); disabled
  state stays visible (30% purple). Light haptic on enabled send taps
  and on the star menu button only.
- **Star menu button:** brighter saturated Twinko gold with a
  restrained glow; function and menu unchanged.
- **Bottom navigation:** visible on the Chat landing; hidden only
  while an active conversation is open (`ChatView.hidesTabBar` +
  `ShellChrome`); restored on returning to the landing. At the tab
  root, an active conversation shows a Back chevron that returns to
  the landing (the conversation stays saved in History).
- **Active conversation:** no generic page title.
- **Response localization:** the mock provider is locale-aware
  (`MockChatServicing.response(for:lang:)`) — new Twinko replies,
  scripted scenarios, and the fallback match the app locale at the
  moment of sending. Stored history is never retroactively translated.
- **History:** rows use a warm ivory→lavender surface with purple-
  tinted icon chips, soft plum shadow, and the same title/preview/time
  hierarchy; the localized 聊天紀錄/History title stays.
- **Delete confirmation:** one concise sentence — 「確定要永久刪除這段
  對話嗎？」/ "Delete this conversation permanently?" with 取消/刪除 ·
  Cancel/Delete; the separate warning subtitle is removed (danger icon
  and destructive styling stay).

## Chat polish addendum (2026-07-17, pass 2)

- Quick prompts sharpened: stronger lavender surface + border, bordered
  icon chip, brighter chevron, soft purple shadow — clearly interactive
  while staying secondary to the composer.
- Star menu button: highlight→gold gradient star with restrained glow
  and a thin gold ring separating it from its circular surface.
- Branded modal typography normalized app-wide (`BrandedModal`): title
  at headline scale, subheadline action labels, 46 pt buttons — Rename
  and Delete no longer read oversized.
- Invalid-title fallback: `LocalChatTitleGenerator` rejects meaningless
  fragments (single Latin letter, digits, punctuation, whitespace) via
  `isMeaningful`; the display then falls back to the localized default
  新對話 / **New Chat** (EN default renamed from "New Conversation").
  Stored valid titles are never rewritten.

## Implemented behavior — v1.3 Chat UI/UX refinement (2026-07-17)

Focused refinement of the New Chat landing, active-conversation
chrome, and Chat-specific controls. Message models, persistence, mock
responses, Meditation offers, and Chat History remain untouched.

- **One-scene landing.** The New Chat landing does not normally
  scroll: `ViewThatFits` measures the fixed hero (floating Twinko →
  headline → three prompt cards) and falls back to a controlled
  scroll only for very small screens, Accessibility Dynamic Type, or
  the open keyboard. Flexible spacers balance the scene between the
  floating header and the composer; the composer stays above the
  shared dock and bottom safe area.
- **Top-bar artifact removed.** The prior landing hero lived in a
  ScrollView whose top edge clipped Twinko under the transparent
  header during scroll/keyboard movement; with the non-scrolling
  scene there is no clip edge. The approved `chat_v1` background
  (unchanged, intentionally preserved) extends through the top safe
  area; Back and the star control float directly over it.
- **Floating Twinko.** ~7 pt vertical travel, ~3.2 s ease-in-out
  cycle; Reduce Motion shows Twinko static; the animation stops with
  the view.
- **Glass prompt cards.** One component family: translucent
  warm-white glass with a top catch-light border, icon orb, prompt
  text (wraps up to two lines, adaptive height, min 52 pt), and
  chevron. Very subtle per-card emotional tints (today = blue-lilac,
  pressure = lavender, company = warm lilac). Press: slight brighten
  + ~2.5 pt nudge + light haptic. Tapping still starts the
  conversation with the prompt as the first user message.
- **Send-button states.** Enabled: saturated lavender→deep-purple
  fill, white plane, soft top catch-light, restrained warm inner
  border, soft depth. Disabled: same silhouette at low saturation /
  reduced opacity, no glow — clearly distinct but still the send
  control. Pressed: 0.95 scale, light haptic, brief restrained
  sparkle shimmer (Reduce Motion: scale only). Validity still comes
  solely from the existing draft-trimming rule; no second send path.
- **Star control = glass orb.** White-lilac translucent orb with a
  soft lilac border holding a dimensional gold star (highlight-to-
  deep-gold gradient, tiny sparkle accent, restrained glow); press
  scale + haptic. Same action (quick menu) — destination unchanged.
- **Navigation chrome.** Landing = top-level destination with the
  dock visible; any active conversation (new or from History — both
  use the same `ChatView` shell) hides the dock via the existing
  `ShellChrome` conversation flag; the floating Back control returns
  through the existing stack and restores the dock at top level.
  Keyboard presentation does not restore the hidden dock. No new
  title was introduced. Chat History redesign is deferred pending a
  separate visual reference; its behavior is functionally unchanged.

### Validation (v1.3 pass — strictly minimal)

Build clean. Directly affected tests:
`testTabBarHiddenOnlyForActiveConversation` and
`testEmptyOrWhitespaceDraftDoesNotSend` — pass. One focused scripted
walkthrough (iPhone 16, zh-Hant): landing without a header bar or
scrolling, three glass cards, star orb opens/closes its existing
menu, disabled → enabled send with text, prompt card → immersive
conversation (dock hidden, Back present), one message sent, keyboard
round-trip with the dock still hidden, Back restoring landing +
dock. EN-locale landing spot check via the `-uiTestEnglish` hook
(prompt wrapping, no mixed language) — the in-app settings-switch
path was flaky under automation and is documented as such. Four
screenshots (C1–C4).

## Implemented behavior — v1.4 Chat History redesign (2026-07-17)

**Purpose.** Chat History is a calm archive of moments shared with
Twinko: scan, search, reopen, rename, delete. It is a management
destination (dock visible), not an immersive conversation.

**Reference.** `docs/ux/references/chat_history_reference_v1.png` is
authoritative for atmosphere, hierarchy, spacing, glass materials,
card proportions, search placement, grouping, modal tone, and the
empty-state composition. Intentional deviations: one standardized
chat-bubble icon in a lavender glass circle for every row (no
decorative hearts/moons/plants/wands/orbs, no topic icons); no
unread/favorite/collectible/notification states; existing Twinko
typography and tokens throughout.

- **Background.** The same `chat_v1` Chat-room asset (source
  untouched), quieted by a code-only translucent lilac/warm-mist
  gradient overlay so cards read clearly while the scene stays
  recognizably Chat-world. Extends through both safe areas.
- **No native list styling.** Custom ScrollView + LazyVStack; no
  `List`/`Form`, separators, large titles, default search bar,
  system context menu, or system alerts anywhere in the flow.
- **Floating header.** Back (44 pt, light haptic, press style) +
  centered 聊天紀錄 / Chat History with the one-line subtitle
  你和 Twinko 留下的每一段星光 / "Moments you've shared with Twinko".
  No opaque bar.
- **Search.** Custom glass field (search icon, clear control when
  text exists, lavender focus border, localized placeholder
  搜尋聊天紀錄 / Search conversations). Pure local metadata search
  (`ChatHistorySearch.filter`): display title + last-message preview,
  case-insensitive, trimmed, live-updating; clearing restores the
  grouped list. No indexing, no backend, no per-keystroke persistence
  queries. Hidden entirely when zero conversations exist.
- **Grouping.** Existing 今天/昨天/過去 7 天/更早 groups with a quiet
  sparkle marker + fading gold hairline — no bold native headers, no
  pinned styling. While searching, a flat 搜尋結果 / Search Results
  list reuses the same card component.
- **Cards.** Warm ivory-lilac glass (≈78% opacity, 22 pt radius, top
  catch-light border, restrained shadow), standardized bubble icon
  orb, semibold deep-plum title (16.5 pt, one line), muted preview
  (14 pt, one line), quiet relative time (existing formatter), and a
  44 pt ellipsis menu separate from the card-open target. Press:
  0.985 scale + slight brighten + light haptic. Rows insert/remove
  with a soft fade/scale (opacity-only under Reduce Motion).
- **Navigation.** Card opens the existing conversation via a
  `navigationDestination(item:)` push in the same stack (dock hides
  through the existing `ShellChrome` conversation flag; Back restores
  History and the dock). History itself keeps the dock visible with
  Chat selected; Back pops to the Chat landing.
- **Actions.** Branded popover: 重新命名 / Rename and 刪除對話 /
  Delete Conversation. Rename modal (重新命名這段對話 / Rename
  Conversation) keeps the existing validation/persistence and adds a
  success haptic. Delete keeps the one-sentence confirmation
  (確定要永久刪除這段對話嗎？) with muted-coral action, animated row
  removal, and a short non-blocking 已刪除對話 / Conversation deleted
  toast.
- **Empty states.** True empty: Twinko with restrained memory-light
  dots, 還沒有聊天紀錄 copy, and a 開始聊天 / Start Chatting CTA
  that pops back to the New Chat landing (existing route); search is
  hidden. No-results: compact search-orb state (沒有找到相關對話)
  with 清除搜尋 / Clear Search; the field stays available. The two
  states are visually and behaviorally distinct.
- **Performance.** Lazy rendering, no timers, no continuous effects,
  no per-row queries. Accessibility: 44 pt targets, localized labels
  for back/search/clear/cards/menu/actions, header traits on
  sections, Reduce Motion fallbacks.

### Validation (v1.4 pass — strictly minimal)

Build clean. New narrow unit test
`testHistorySearchMatchesTitleAndPreviewAndClearsCleanly` (title +
preview matching, case-insensitivity, trimming, clear-restores-all,
no-match-empty) — passes. One focused scripted walkthrough (iPhone
16, zh-Hant) passed end-to-end after a simulator reboot cleared
degraded accessibility snapshots: true empty state (no search, Start
Chatting routes to the landing) → two disposable conversations →
normal list (groups, cards, dock) → search match → clear → no-match
state → clear → rename opened + cancelled → delete confirmation
opened + cancelled → conversation opened (dock hidden) → Back
(History + dock restored). EN spot check via `-uiTestEnglish`:
header, Today group, menu labels, rename-modal title. Destructive
delete verified at the wiring/store level only (existing
`ChatStore.delete` untouched). Four screenshots (H1–H4).

## Implemented behavior — v1.5 immersive Chat landing (2026-07-18)

- **Immersive landing.** The shared bottom navigation hides whenever
  any Chat surface (landing or active conversation) is frontmost and
  its reserved layout space collapses (existing `ShellChrome` flag +
  `DockClearance`; `ChatView.hidesTabBar(chatSurfaceVisible:)`). The
  tab-root instance re-reports on tab changes (it stays alive across
  opacity-based tab switching) and pauses the Twinko float off-tab;
  pushed instances report on appear/disappear. Keyboard presentation
  cannot resurface the dock. No second chrome state, router,
  coordinator, or NavigationStack.
- **Back control.** Always present top-left (44 pt, light haptic,
  lavender glass orb balanced with the star control): pushed instances
  pop the existing stack; tab-root conversation returns to the
  landing; tab-root landing returns to Home via the existing shared
  tab state. No new title, no previous-screen tracker.
- **Top area.** No opaque block; the unchanged `chat_v1` background
  runs through the top safe area with floating controls. The landing
  keeps its one-screen `ViewThatFits` rule (scroll fallback only for
  small screens / Accessibility Dynamic Type / keyboard).
- **Example cards.** Darker translucent lavender glass (clearly
  separated from the pink background), lavender glass icon orbs (no
  white circles), readable purple chevrons, 30 pt page margins,
  ≥56 pt adaptive height with natural EN two-line wrapping; press =
  brighten + ~2.5 pt nudge + light haptic; actions unchanged.
- **Send button.** Disabled: visible lavender-purple circle (~55–68%
  perceived), pale-lilac plane, white border — recognizably the Send
  control, still disabled for accessibility. Enabled: saturated
  purple gradient, warm-white plane, catch-light, warm inner border,
  press scale + haptic + one-shot sparkle. Validity remains the
  existing draft-trimming rule.
- **Star control.** Saturated lavender-purple glass orb with brighter
  dimensional gold star + sparkle accent — reads as a control, same
  quick-menu action, light haptic.
- **Twinko floating.** Landing Twinko keeps the ~7 pt / ~3.2 s float
  (static under Reduce Motion), now paused when Chat is not the
  frontmost tab. The active conversation contains no prominent
  standalone Twinko (per-message avatars only), so no conversation
  motion was added and avatars stay static. Chat History Twinko
  states are explicitly out of scope and untouched.

### Validation (v1.5 — strictly minimal)

Build clean. Directly affected tests:
`testDockHiddenWheneverChatSurfaceIsFrontmost` (updated for the new
rule) and `testEmptyOrWhitespaceDraftDoesNotSend` — pass. Focused
scripted walkthrough (iPhone 16, zh-Hant) passed: immersive landing
(no dock, no reserved space), controls visible, three cards, disabled
→ enabled send, one message sent, keyboard round-trip with dock still
hidden, Back → landing → Home with the dock restored. EN spot check
passed (cards, disabled send; dock-hide waited via predicate — chrome
propagation can trail the headline, a test-timing note, not a product
issue). Two screenshots (I1 landing, I2 enabled send); no third — no
standalone conversation Twinko exists. Pre-existing walkthrough
assertions that encoded the old "dock visible on landing" rule were
updated in place.
