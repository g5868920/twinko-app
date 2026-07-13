# TWINKOTALK_SCREEN_INVENTORY

> Status date: 2026-07-13  
> Screen IDs are stable working references for PRD, content, design, and QA.

| ID | Screen | Area | Purpose | Required states |
|---|---|---|---|---|
| S-001 | Welcome | Core | Twinko introduction, product name, CTA | Default |
| S-002 | Profile Setup — Name | Core | Collect name | Default, validation |
| S-003 | Profile Setup — Birthday | Core | Collect birthday | Default, date picker, validation |
| S-004 | Profile Setup — Gender | Core | Collect gender | Default, selection, validation |
| S-005 | Home / Menu | Core | Twinko center; five visible modes | Default, returning user |
| S-006 | Meditation Coming Soon | Disabled | Optional modal / disabled treatment | Disabled |
| S-007 | Music Coming Soon | Disabled | Optional modal / disabled treatment | Disabled |
| S-008 | Chat Home | Chat | Current chat, new chat, history entry | Empty, active |
| S-009 | Chat Conversation | Chat | Messages and Twinko response | Default, loading, fallback |
| S-010 | Chat History | Chat | List saved chats | Empty, populated |
| S-011 | Saved Chat Detail | Chat | Reopen past conversation | Default |
| S-012 | Tarot Entry | Tarot | Twinko wizard mode | Default |
| S-013 | Tarot Topic | Tarot | Choose category | Default |
| S-014 | Tarot Question | Tarot | Suggested or custom question | Default, validation |
| S-015 | Tarot Spread | Tarot | Single or Three Cards | Default |
| S-016 | Tarot Shuffle | Tarot | Ritual / loading state | Loading |
| S-017 | Tarot Single Selection | Tarot | One card interaction | Default |
| S-018 | Tarot Three Selection | Tarot | Three card interaction | Default |
| S-019 | Tarot Single Result | Tarot | Card and reflection | Result |
| S-020 | Tarot Three Result | Tarot | Three cards and integrated reflection | Result |
| S-021 | Astrology Daily | Astrology | All approved daily fields | Default, content unavailable |
| S-022 | Generic Error | Shared | Recoverable error | Error |
| S-023 | Return / Exit Confirmation | Shared | Optional navigation guard | Default |

## Navigation Notes

- Welcome and Profile Setup appear on first launch.
- Returning prototype users may enter Home directly.
- Home is the main hub.
- Every active mode provides a clear return path.
- Disabled modes must not lead to incomplete screens unless the approved design uses a coming-soon modal.

## Open Screen Decisions

- Profile Setup as one multi-field screen vs multiple steps.
- Chat History as full-screen list vs side panel.
- Coming-soon modal vs disabled button only.
- Tarot topic and question combined vs separate.
- Tarot results scroll vs staged pages.
