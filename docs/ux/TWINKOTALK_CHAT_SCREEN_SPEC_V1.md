
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
