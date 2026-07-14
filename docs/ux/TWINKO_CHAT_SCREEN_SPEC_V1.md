# TwinkoTalk Chat Screen Specification

> ## Visual References

Primary visual reference:

- `/docs/design/references/chat_visual_primary.png`

Secondary functional-state reference:

- `/docs/design/references/chat_functional_states.png`

Use the primary reference for visual tone, color balance, spacing, bubble
treatment, and quick-menu depth.

Use the secondary reference only for required states and flows. Do not copy
its generated artifacts, bilingual simultaneous text, decorative noise,
incorrect Twinko artwork, or white quick-menu treatment.

When sources conflict, follow:

1. Latest founder-approved instruction
2. `/DESIGN.md`
3. This specification
4. Approved assets
5. Reference images

## Implemented behavior — v1 (2026-07-14)

- Background: approved `chat_v1.png`, full-screen aspect fill behind safe areas, unmodified.
- Header: Back / localized title (Chat・聊天) / star quick-menu button. No top avatar, no Online status.
- Empty state: large Day (06:00–17:59) or Night Twinko via derived transparent runtime copies of the approved assets (`assets/chat/derived/`), subtle glow + idle float (Reduce Motion supported), localized intro copy, and three identically styled warm-ivory starters that insert text into the composer without auto-sending. Day/night re-evaluates on open and on returning to foreground; never persisted.
- Active conversation: warm-ivory Twinko bubbles / muted-purple user bubbles per DESIGN.md §15; 30 pt Day/Night avatar on the first Twinko message of each group; three-dot typing indicator on the Twinko bubble surface; no per-message timestamps.
- Composer: multiline (52–140 pt), surfaceInput + borderSoft + radiusXl, localized placeholder, gold send button (disabled until trimmed content exists), draft preserved while the view is open.
- Star quick menu: deep-space ~45% scrim dims the chat; elevated `menuDeep` panel (196 pt) with exactly New Chat・新對話 (gold accent icon) and History・聊天紀錄 rows plus a circular close control; scrim tap closes. New Chat prompts only when an unsent draft exists.
- History: pale-lilac surface, warm-ivory rows (neutral bubble icon, title, last-message preview, relative time, ⋮ menu). Rename (pre-filled, trimmed, empty rejected, persists, locks `titleSource = user`) and Delete (confirmation, cannot be undone; deleting the open conversation resets it to a new empty chat).
- Titles: stored `title` + `titleSource (auto|user)`; a local replaceable `ChatTitleGenerating` abstraction derives a topic title after the first exchange (greeting/filler stripped, no emoji/quotes/trailing punctuation, ~30 Latin / ~14 CJK chars); automatic generation never overwrites a user rename. Temporary title: New Conversation・新對話.
- Persistence: existing ChatStore Codable-JSON architecture, extended backward-compatibly (older sessions decode with an empty auto title).
- Localization: all Chat/History/menu/dialog copy via `ChatStrings`, driven by the persisted app language; never bilingual simultaneously.
- Known limitation: the local deterministic mock service cannot fail, so the send-failure/retry state defined above is not reachable in this prototype.
