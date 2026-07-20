# TwinkoTalk Horoscope Feature Specification

> **Safety authority (2026-07-21):** any future LLM-backed Horoscope
> behavior is governed by
> `docs/features/llm/TWINKO_LLM_SAFETY_PRIVACY_SPEC.md` (DRAFT, awaiting
> founder sign-off) — including the rule that Horoscope stays
> reflective/entertainment content until a deterministic ephemeris layer
> exists, and its data inventory. This spec must not fork safety policy.

**Status:** Canonical CPO-approved feature specification  
**Version:** v1.0  
**Target:** iOS-first prototype / MVP  
**Audience:** Claude Code, product, design, engineering, QA  
**Dependencies:**
- `DESIGN.md`
- Approved Horoscope Twinko asset
- Approved Horoscope background asset
- 12 approved zodiac symbol assets
- Approved Horoscope Summary Card background

---

# 0. Purpose

This file defines the product scope, user flow, data contract, content rules, prototype boundaries, and future LLM architecture for the TwinkoTalk Horoscope feature.

The feature should help users:

- quickly understand the tone of their day
- reflect on love, career, wealth, and overall direction
- receive one gentle, practical suggestion
- share or save a branded daily Horoscope Summary Card
- explore other zodiac signs without losing focus on their own sign

The experience must feel:

> **Cosmic, warm, exploratory, calm, and clearly part of the Twinko world.**

---

# 1. Product Positioning

Twinko Horoscope is a daily reflection feature.

It is not:

- a deterministic prediction engine
- a substitute for medical, legal, or financial advice
- a natal-chart analysis product
- a compatibility engine
- a long-form astrology encyclopedia

The MVP focuses on a simple daily horoscope experience based on the user’s sun sign.

---

# 2. MVP Scope

The MVP includes:

- automatic sun-sign determination from birthday
- manual zodiac override
- daily horoscope for the selected sign
- four horoscope dimensions:
  - Overall
  - Love
  - Career
  - Wealth
- four lucky details:
  - Lucky Number
  - Lucky Color
  - Lucky Zodiac Sign
  - Lucky Item
- one daily Twinko message
- zodiac switching
- share text result
- save Horoscope Summary Card
- Traditional Chinese and English localization
- one canonical Horoscope Twinko asset
- one canonical Horoscope background
- 12 canonical zodiac symbol assets
- one Horoscope Summary Card background

The MVP does not include:

- natal chart calculation
- moon sign or rising sign
- compatibility reports
- weekly or monthly horoscope
- horoscope history
- push notifications
- personalized memory-based astrology
- paid readings
- multiple Twinko expression states
- astrology chat

---

# 3. Canonical User Flow

```text
Home Horoscope Entry
→ Today Horoscope
→ Expand / review four dimensions
→ Review lucky details
→ Optional zodiac switch
→ Share text or save Horoscope Summary Card
```

First-time or missing-birthday flow:

```text
Horoscope Entry
→ Birthday input
→ Auto-detected zodiac sign
→ Confirmation
→ Today Horoscope
```

Manual correction flow:

```text
Current zodiac sign
→ Change sign
→ Zodiac selector
→ Confirm selected sign
→ Today Horoscope updates
```

---

# 4. Entry Rules

## 4.1 Existing birthday data

If the user has already completed birthday setup:

- determine the sun sign automatically
- use it as the default sign
- do not ask again

## 4.2 Missing birthday data

If birthday is missing:

- ask for birthday
- explain that it is used to determine the user’s zodiac sign
- do not request birth time or birth location
- allow the user to skip birthday and manually choose a zodiac sign

## 4.3 Manual override

Users may manually change the selected sign.

The override should:

- affect Horoscope display only
- not silently overwrite profile birthday
- persist as the last viewed sign for the session
- preserve the user’s profile sign as “My Sign”

---

# 5. Zodiac Identity System

Use English lowercase identifiers as canonical IDs:

```text
aries
taurus
gemini
cancer
leo
virgo
libra
scorpio
sagittarius
capricorn
aquarius
pisces
```

Do not use numeric indices as primary identifiers.

Each sign should include:

- canonical ID
- English display name
- Traditional Chinese display name
- zodiac symbol
- date range
- asset filename
- localized accessibility label

---

# 6. Horoscope Content Model

Each daily horoscope result should conform to this structure:

```json
{
  "date": "2026-07-16",
  "locale": "zh-Hant",
  "zodiacSign": "leo",
  "headline": "今天適合把注意力收回自己身上。",
  "overall": {
    "score": 4,
    "summary": "整體節奏穩定，適合處理重要事項。",
    "detail": "今天的能量有助於你整理優先順序。先完成最重要的一件事，再處理次要選項，會比同時推進所有事情更輕鬆。"
  },
  "love": {
    "score": 3,
    "summary": "坦白但溫柔的溝通更有幫助。",
    "detail": "不要急著猜測對方的想法。清楚表達自己的感受，也留一點空間聽對方說完。"
  },
  "career": {
    "score": 4,
    "summary": "適合推進需要判斷與協調的工作。",
    "detail": "今天適合把模糊問題整理成具體步驟。先確認目標，再分配時間與資源。"
  },
  "wealth": {
    "score": 2,
    "summary": "購買前多停一下，避免情緒性消費。",
    "detail": "今天不適合因為焦慮或衝動做大額決定。先把需求和想要分開，再決定是否行動。"
  },
  "lucky": {
    "number": 7,
    "color": {
      "name": "Lavender",
      "localizedName": "薰衣草紫",
      "hex": "#B8A2E8"
    },
    "zodiacSign": "libra",
    "item": "A small notebook"
  },
  "twinkoMessage": "不用一次解決全部，先把今天最重要的一步走好。",
  "disclaimer": "Horoscope content is for reflection and entertainment."
}
```

---

# 7. Content Length Rules

## Traditional Chinese

- Headline: 12–28 characters
- Summary: 14–30 characters
- Detail: 45–90 characters
- Twinko Message: 18–40 characters
- Lucky Item: 2–12 characters

## English

- Headline: 6–14 words
- Summary: 8–18 words
- Detail: 28–60 words
- Twinko Message: 10–24 words
- Lucky Item: 1–5 words

The UI must support realistic variation within these ranges.

Do not design around one perfect sample.

---

# 8. Score System

Each horoscope dimension uses an integer score from 1 to 5.

```text
1 = move carefully
2 = lower-energy / reflective
3 = balanced
4 = supportive
5 = especially favorable
```

Rules:

- do not label 1 or 2 as “bad”
- avoid red warning treatment
- use the score as guidance, not judgment
- display both visual stars and accessible text
- color must not be the only signal

Recommended Traditional Chinese labels:

```text
1：放慢腳步
2：多一點留意
3：平穩
4：順勢前進
5：能量充足
```

---

# 9. Prototype Content Behavior

The prototype may use:

- static fixture JSON
- one mock result per zodiac sign
- date-based sample rotation
- deterministic test fixtures
- local data only

Prototype content must be stored outside UI components.

Recommended provider pattern:

```text
HoroscopeProvider
├── MockHoroscopeProvider
└── FutureLLMHoroscopeProvider
```

The UI should consume a structured `DailyHoroscope` model.

Do not write long horoscope copy directly inside SwiftUI views.

---

# 10. Future LLM Behavior

The production provider should generate a structured daily horoscope.

Minimum inputs:

- zodiac sign
- date
- locale
- requested content schema
- brand tone
- safety rules

Optional future inputs:

- broad user preference
- current mood selected by the user
- recent reflection category

The LLM must return valid structured data.

It must not:

- claim certainty
- predict death, disease, disaster, pregnancy, or legal outcomes
- tell users to make major financial decisions
- present medical advice
- create fear or dependency
- imply that Twinko has supernatural certainty

Preferred language:

- “may”
- “could”
- “it may help to”
- “consider”
- “today may be a good time to”

Avoid:

- “will definitely”
- “this is destined”
- “you must”
- “the universe guarantees”

---

# 11. Daily Refresh Logic

The daily horoscope should refresh based on the user’s local calendar date.

Rules:

- one result per sign per local date
- cache the daily result
- opening the app repeatedly should not regenerate a different result
- switching signs should load the corresponding sign for the same date
- prototype fixtures may be deterministic by date + sign
- production generation should also cache the generated result

Suggested cache key:

```text
horoscope:{localDate}:{zodiacSign}:{locale}
```

---

# 12. Zodiac Switching

Users may view another sign.

The selector should:

- display all 12 signs
- prioritize recognizability
- show icon + localized name
- highlight the selected sign
- identify the profile sign as “My Sign”
- avoid showing all symbols with maximum glow simultaneously

Selection behavior:

- tap sign
- update selected state
- confirm or load directly
- preserve scroll position if returning

The MVP should not show compatibility scores.

---

# 13. Sharing

## 13.1 Share Text

The shared text may include:

- date
- zodiac sign
- headline
- overall summary
- Twinko message
- subtle TwinkoTalk attribution

Do not include the full long-form horoscope by default.

Example:

```text
獅子座｜今日運勢

今天適合把注意力收回自己身上。
整體節奏穩定，適合處理重要事項。

Twinko 想說：
不用一次解決全部，先把今天最重要的一步走好。

TwinkoTalk
```

Use the native iOS share sheet after the user chooses Share.

---

# 14. Horoscope Summary Card

The user can save a visual summary card.

The card should include:

- TwinkoTalk / Horoscope branding
- date
- selected zodiac sign and symbol
- headline
- overall score
- one concise overall summary
- Twinko message
- lucky number
- lucky color
- lucky zodiac sign
- lucky item
- canonical Horoscope Twinko asset
- approved Horoscope Summary Card background

The card should not contain:

- all four long details
- dense paragraphs
- bilingual copy at the same time
- private profile data
- birthday
- user name unless explicitly enabled later

Recommended export:

```text
1080 × 1350 px
4:5
PNG
sRGB
```

The summary card must be rendered as a runtime composition.

It is not a screenshot of the app screen.

---

# 15. Privacy

- Birthday is used to determine sun sign
- Do not expose birthday on share cards
- Do not log full profile birth data in analytics events
- Do not include hidden user context in shared text
- Changing viewed sign does not change profile birthday

---

# 16. Localization

Required locales:

```text
en
zh-Hant
```

Rules:

- show one locale at a time
- zodiac IDs remain English lowercase internally
- display names are localized
- lucky color requires localized name and optional hex value
- summary-card layout must support both English and Traditional Chinese
- avoid text baked into zodiac assets or backgrounds

---

# 17. Accessibility

- Support Dynamic Type in app screens
- Provide VoiceOver labels for zodiac symbols
- Read scores as text, not just stars
- Do not rely on glow or color alone
- Decorative stars and background art should be hidden from VoiceOver
- Share-card image should have an accessible text alternative
- Zodiac selector tap targets must be at least 44 × 44 pt
- Support Reduce Motion

---

# 18. Analytics

Recommended MVP events:

```text
horoscope_opened
horoscope_birthday_requested
horoscope_sign_confirmed
horoscope_sign_switched
horoscope_dimension_expanded
horoscope_share_tapped
horoscope_summary_card_saved
horoscope_summary_card_shared
```

Recommended properties:

```text
zodiac_sign
profile_sign_or_other
locale
date
dimension
source_screen
```

Do not log:

- full birthday
- full shared text
- generated long-form horoscope body
- personally sensitive user context

---

# 19. Error and Empty States

## Missing birthday

Offer:

- Add Birthday
- Choose Zodiac Sign Manually

## Missing daily horoscope

Show:

- canonical Horoscope Twinko
- short retry message
- Retry action

## Generation error

- keep selected sign
- retry without resetting navigation
- do not generate a random fallback presented as final truth
- prototype may load a clearly marked fixture fallback

## Offline

If cached result exists:

- show cached result

If no cached result:

- show retry state
- preserve selected sign

---

# 20. Architecture Recommendation

Recommended modules:

```text
Horoscope/
├── Models/
│   ├── ZodiacSign
│   ├── DailyHoroscope
│   ├── HoroscopeDimension
│   └── LuckyDetails
├── Data/
│   ├── HoroscopeProvider
│   ├── MockHoroscopeProvider
│   └── HoroscopeCache
├── Views/
│   ├── HoroscopeTodayView
│   ├── ZodiacSelectorView
│   ├── HoroscopeDimensionCard
│   ├── LuckyDetailsGrid
│   └── HoroscopeSummaryCardView
├── Sharing/
│   ├── HoroscopeShareFormatter
│   └── HoroscopeSummaryCardRenderer
└── Assets/
```

The implementation should reuse existing app navigation, localization, and design tokens.

---

# 21. Hard Product Rules

Claude Code must not:

- implement weekly or monthly horoscope
- implement natal-chart logic
- add compatibility matching
- create multiple unofficial Horoscope Twinko states
- bake text into the background or zodiac icons
- hardcode production content inside UI files
- regenerate a different result every app open
- show birthday on shared outputs
- make absolute predictions
- add medical, legal, or financial advice
- redesign unrelated app screens

---

# 22. MVP Acceptance Criteria

## Entry

- [ ] User can enter from Home
- [ ] Profile birthday determines default sign
- [ ] Missing birthday has a manual-sign fallback
- [ ] User can switch zodiac signs

## Content

- [ ] Overall, Love, Career, and Wealth are displayed
- [ ] Each dimension includes a score, summary, and detail
- [ ] Lucky Number, Color, Zodiac, and Item are displayed
- [ ] Twinko Message is displayed
- [ ] Content supports English and Traditional Chinese

## Assets

- [ ] One canonical Horoscope Twinko asset is used
- [ ] One canonical background is used
- [ ] All 12 zodiac symbols use consistent canonical assets
- [ ] Summary-card background is used correctly

## Sharing

- [ ] Text result can be shared
- [ ] Horoscope Summary Card can be rendered
- [ ] Summary Card can be saved
- [ ] Summary Card can be shared
- [ ] Shared output excludes birthday

## Technical

- [ ] UI uses structured horoscope data
- [ ] Mock provider is separate from UI
- [ ] Daily result is cached
- [ ] Sign switching works without regenerating unrelated data
- [ ] Accessibility labels exist
- [ ] Reduce Motion is supported

---

# 23. v1.1 Refinements (founder review 2026-07-16)

1. The main screen no longer displays the headline; the **Twinko
   message** is the single personalized takeaway and always includes
   one small, doable action (no separate action block). The
   `headline` field remains in the data model and share text only.
2. Lucky Number remains an integer in **1–99**, deterministic per
   local date + sign + locale (unchanged behavior, now explicit).
3. Zodiac symbols are code-rendered glyphs; the raster assets are
   reference-only (see canonical assets spec addendum).
4. The Summary Card exports at 1080×1440 (3:4) with no disclaimer or
   privacy copy; the short disclaimer appears once on the main screen.
