# TWINKO_P0_APP_SHELL_MOCK_CHAT_SPEC

> Status date: 2026-07-13
> Governing authorization: `docs/product/TWINKO_DECISION_LOG.md` D-053 ("Twinko P0 Technical Foundation + First SwiftUI Prototype")
> This is the single active implementation specification for D-053. It supersedes no canonical file and does not expand the milestone's scope.
> This document is a reconciled extract, not a copy, of the inbound TwinkoTalk package. Where the package described a broader product (Chat + Tarot + Astrology, persisted history, a confirmed product name), this spec deliberately narrows to only what D-053 authorizes.

## 0. Governance note (read first)

- **D-047 (primary user wedge / primary first-value moment) remains unresolved.** Nothing in this spec resolves it. Building the App Shell + Mock Chat prototype described here is a technical exercise only, not evidence that Chat is Twinko's primary wedge.
- **D-052** (Twinko implementation/discovery generally deferred, execution-timing only) remains in force outside the exact scope D-053 carves out.
- **D-053** authorizes exactly: a minimal Xcode/SwiftUI app shell plus a fully-mocked Chat flow, as a technical prototype vehicle. This spec implements that scope only.
- `TwinkoTalk` is **not** an approved product name. Per Gina's governing decision for this promotion, `Twinko` is used only as a temporary prototype working label, not a naming decision.
- If any requirement below appears to conflict with `docs/product/TWINKO_DECISION_LOG.md`, `docs/product/TWINKO_CURRENT_STATUS.md`, or `docs/product/TWINKO_PRODUCT_OPERATING_BRIEF.md`, those canonical documents override this spec.

## 1. Scope statement

Active UI scope for this milestone is exactly:

**App launch → Minimal shell → Mock Chat**

The shell may contain only:

- The temporary working label "Twinko" (not a confirmed product name).
- The Twinko character.
- A single path into Chat (no multi-mode menu).

No other screen, mode, or navigation path is in scope. (Source: user-specified explicit P0 scope, reconciled against package `02_PRODUCT_EXECUTION/TWINKOTALK_SCREEN_INVENTORY.md`, which lists a much larger 23-screen inventory — only the Chat-related IDs S-008/S-009 informed this spec, and even those are trimmed; S-010 Chat History and S-011 Saved Chat Detail are explicitly excluded because they assume persistence this milestone does not authorize.)

## 2. Screens in scope

### 2.1 App Launch / Minimal Shell

- On launch, present a minimal shell showing the Twinko character and the temporary working label "Twinko."
- Provide exactly one path forward: into the Chat screen.
- No Welcome copy flow, no continue-button-driven onboarding narrative, no profile collection of any kind.
- (Reconciled from package `TWINKOTALK_SCREEN_INVENTORY.md` S-001 "Welcome" and S-005 "Home/Menu," stripped of onboarding copy, product naming, and the five-mode menu — only the idea of "Twinko-centered entry point with one path forward" survives.)

### 2.2 Chat Screen

Required elements:

- A local text input field.
- A send action.
- A scrollable display of the active session's messages (user + Twinko).
- Three deterministic mock states: loading, success, error/fallback.

(Source: package `TWINKOTALK_SCREEN_INVENTORY.md` S-008 "Chat Home" / S-009 "Chat Conversation," and `TWINKOTALK_PROTOTYPE_PRD.md` §5 FR-004 "Chat" — with "Start New Chat," "Save conversation," "Chat History list," and "Reopen a saved chat" requirements removed, since those all assume persistence beyond this milestone's in-memory-only data rule.)

## 3. Functional requirements

### FR-P0-1 Text input and send

- User can type a message in a local text field and submit it via a send action.
- (Source: `TWINKOTALK_PROTOTYPE_PRD.md` §5 FR-004, "Input field" / "Send action" — retained as-is; this portion does not depend on persistence or scope excluded here.)

### FR-P0-2 User-message display

- Submitted messages appear immediately in the message list, attributed to the user.
- (Source: `TWINKOTALK_PROTOTYPE_PRD.md` §4 Flow C steps 3–4, reconciled to remove any reference to saving/reopening.)

### FR-P0-3 Deterministic mock loading state

- After send, the Chat screen shows a "thinking / loading" state before a response appears.
- The loading state must be deterministic (fixed behavior, not randomized or network-dependent) and must not trap the user — some visible response or recovery must always follow.
- (Source: `TWINKOTALK_PROTOTYPE_PRD.md` §4 Flow C step 4 and §8 "States"; QA requirement from `TWINKOTALK_PROTOTYPE_QA_CHECKLIST.md` §3 "Loading state appears" and §8 "Loading states do not trap the user.")

### FR-P0-4 Deterministic mock success response

- A scripted, hardcoded response is displayed after the loading state, selected by a deterministic local mock-response mechanism (e.g. keyword or scenario match) — not a live model call.
- (Source: `TWINKOTALK_PROTOTYPE_PRD.md` §5 FR-004 "Scripted response engine"; content pattern from `TWINKOTALK_CONTENT_SPEC.md` §5 "Response pattern": acknowledge → reflect the user's stated feeling without inventing facts → ask one gentle question or offer two options → offer a small optional action when appropriate → close without pressure.)

### FR-P0-5 Deterministic mock error / fallback state

- A fallback state must exist for when no scripted match applies, acknowledging that Twinko "may not have understood" and inviting the user to rephrase or choose a simple option, without fabricating certainty.
- (Source: `TWINKOTALK_PROTOTYPE_PRD.md` §5 FR-004 "Fallback state"; `TWINKOTALK_CONTENT_SPEC.md` §5 "Fallback.")

### FR-P0-6 In-memory messages during the active session

- All messages (user and Twinko) exist only in memory for the duration of the current app session.
- See §5 "Data and state rules" for the full persistence boundary.

## 4. Basic Twinko character and visual direction

Reconciled from package `TWINKOTALK_BRAND_CHARACTER_GUIDE.md` §3 "Twinko Character Baseline" and §6 "Mode Art Direction — Chat" — Home/Tarot/Astrology-specific direction excluded:

- Shape: rounded five-point star, soft/full proportions, no thin or sharp points, no prominent human limbs.
- Face: large black oval eyes with small white highlights, simple upward-curved mouth, orange-red round cheeks, friendly neutral expression.
- Material/light: golden yellow body, orange warmth near edges, soft internal glow (gentle bloom, not harsh neon).
- Consistency: point count, eye shape, mouth style, cheek placement, width/height ratio, and glow character must not vary within this prototype.
- Chat-mode environment tone: warm, low-pressure visual feeling (the package's full "warm night / fireplace / sofa" room direction is a nice-to-have, not a P0 requirement — a plain warm-toned background satisfies this milestone).
- Naming label on-screen, if shown at all, must read as "Twinko" only — never "TwinkoTalk" presented as a confirmed product name.

## 5. Applicable Chat tone and copy

Reconciled from package `TWINKOTALK_CONTENT_SPEC.md` §1 "Tone of Voice" and §5 "Chat Script Library":

- Twinko's voice: warm, natural, gentle, slightly playful, listening-first, concise for mobile.
- Never clinical, judgmental, deterministic, or emotionally manipulative.
- Avoid: forced positivity, "only I understand you," "you need me," "you made me sad by leaving," diagnosis, guaranteed outcomes.
- A small number of scripted scenarios is sufficient for this milestone (the package's suggested list — feeling down, recent worries, confidence/encouragement, general check-in, "I don't know what to say" — is a reasonable content seed; exact scenario count and branching remain an implementation detail, not a P0 gate).

## 6. Applicable safety and trust constraints

This section extracts only the parts of `docs/safety/TWINKOTALK_TRUST_SAFETY_LEGAL_GOVERNANCE.md` (promoted separately, see below) that bind a Chat-only mock prototype. The full document governs; this is a pointer, not a substitute.

- No diagnosis, treatment, therapy, prevention/cure, or clinical-improvement claims (source: §1 "Product Classification and Claims").
- Twinko may listen, reflect the user's stated feeling, ask gentle questions, and encourage contact with a trusted person or professional; it must not diagnose, pressure the user to stay in the app, imply exclusive understanding, or suggest the user is responsible for Twinko's emotions (source: §2 "Emotional-Support Boundary").
- No guilt streaks, no "Twinko is sad because you left," no distress-triggered paywall — not that a paywall is in scope at all, but the underlying tone rule applies to any mock copy written now (source: §6 "Dependency and Engagement").
- Marketing/UI copy should lean toward "a warm place to talk and reflect," never "treats depression," "better than therapy," or "knows exactly how you feel" (source: §11 "Marketing Claims").
- Tarot- and Astrology-specific safety sections (§5) are out of scope for this milestone and are not reproduced here.

## 7. Data and state rules

- Messages live only in memory for the duration of the active app session.
- A deterministic local mock service selects responses; there is no live LLM, no model API call of any kind.
- No persistence after app termination: no SwiftData, no `UserDefaults` conversation storage, no on-device database, no cloud sync, no backend.
- No network access anywhere in this milestone's implementation.
- No secret, no API key, no credential of any kind.
- No external SDK beyond what ships with Xcode/SwiftUI (no analytics, no crash-reporting, no third-party networking or persistence library).

## 8. Prototype QA acceptance criteria

Reconciled from package `TWINKOTALK_PROTOTYPE_QA_CHECKLIST.md` §3 "Chat" and relevant parts of §8 "States and Recovery," trimmed to remove persistence-dependent items:

- [ ] App launches and the minimal shell loads, showing Twinko and the "Twinko" working label.
- [ ] The single path from the shell into Chat works.
- [ ] User can enter a message in the Chat screen.
- [ ] Loading state appears after send.
- [ ] A scripted response appears following the loading state.
- [ ] The fallback/error state works when no scripted match applies.
- [ ] No LLM-dependent behavior is implied anywhere in copy or UI.
- [ ] Loading states do not trap the user — a next state always follows.
- [ ] No broken links, placeholder text, or unsafe claims anywhere in the shell or Chat screen.
- [ ] Messages are visibly gone after an app relaunch (confirms no persistence — this is a P0-specific addition, not present in the package checklist, added because the in-memory-only data rule needs an explicit, testable check).

Excluded from this milestone's QA (present in the package checklist but out of scope): all Home/Menu, Tarot, Astrology, Meditation/Music, Chat History, and saved-chat-reopen checks.

## 9. Explicit non-scope

The following are not active requirements or acceptance criteria for this milestone. None of them may be described as an active screen, feature, or QA item under this spec:

- Welcome onboarding flow
- Profile Setup (name, birthday, or gender collection)
- Persisted Chat History (any storage that survives app termination)
- Tarot (any screen, flow, or content)
- Astrology (any screen, flow, or content)
- Meditation
- Music
- Disabled/coming-soon placeholders for future modes
- Gamification
- Notifications
- Authentication
- Backend of any kind
- Cloud sync
- Live LLM
- Any external API call
- Analytics
- Crash-reporting SDKs
- Payments
- Subscriptions
- PM Workflow integration
- TestFlight or App Store work
- Final product-name lock ("TwinkoTalk" or otherwise)

Tarot and Astrology require a future, separate milestone authorization (per Gina's governing decision for this promotion); they are not deferred-but-implied here — they are absent from scope entirely.

## 10. Naming

Use only: **Twinko — temporary prototype working label.**

Do not state or imply that `TwinkoTalk` is a confirmed or approved product name anywhere in this prototype's UI, copy, or code comments. D-047 remains unresolved; naming lock requires its own future decision.

## 11. Provenance summary

| Section of this spec | Package source(s) |
|---|---|
| Screens in scope | `02_PRODUCT_EXECUTION/TWINKOTALK_SCREEN_INVENTORY.md` (S-001, S-005, S-008, S-009 — trimmed) |
| Functional requirements | `02_PRODUCT_EXECUTION/TWINKOTALK_PROTOTYPE_PRD.md` §4 Flow C, §5 FR-004, §8 States |
| Visual direction | `02_PRODUCT_EXECUTION/TWINKOTALK_BRAND_CHARACTER_GUIDE.md` §3, §6 (Chat only) |
| Tone and copy | `02_PRODUCT_EXECUTION/TWINKOTALK_CONTENT_SPEC.md` §1, §5 |
| Safety and trust | `03_TRUST_GOVERNANCE/TWINKOTALK_TRUST_SAFETY_LEGAL_GOVERNANCE.md` §1, §2, §6, §11 (full document promoted separately to `docs/safety/`) |
| QA acceptance criteria | `02_PRODUCT_EXECUTION/TWINKOTALK_PROTOTYPE_QA_CHECKLIST.md` §3, §8 (Chat/loading items only) |
| Visual reference asset | `04_REFERENCES/visual_references/twinko_master_visual_reference.png` (promoted unchanged to `assets/references/`) |

Not used as a source for this spec, and not promoted: package `01_CANONICAL/*`, `00_TWINKO_START_HERE.md`, `TWINKOTALK_FEATURE_BACKLOG.md`, `tarot_card_style_reference.png`, `MANIFEST.json`, and all `04_REFERENCES/` provenance material. These remain inbound-only per Gina's governing decisions.
