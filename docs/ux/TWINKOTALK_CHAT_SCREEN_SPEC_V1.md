
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
