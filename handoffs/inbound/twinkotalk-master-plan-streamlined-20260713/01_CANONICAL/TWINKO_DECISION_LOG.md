# TWINKO_DECISION_LOG

> Status date: 2026-07-13  
> Status labels: **Approved**, **Working direction**, **Hypothesis / Backlog hypothesis**, **Pending**, **Deferred**, **Superseded**.  
> This is the latest nontechnical product / business / market / trust decision log. Detailed architecture and coding decisions are preserved only in historical reference files and are outside the scope of this package.

| ID | Decision | Status | Rationale | Source | Reversible? | Impact | Follow-up |
|---|---|---|---|---|---|---|---|
| D-001 | Build TwinkoTalk as a real commercial product rather than only a portfolio artifact | Approved | Long-term intent remains a public consumer product | Original consolidation | Low | Defines quality and long-term ambition | Prototype does not equal launch readiness |
| D-002 | iOS-first mobile product direction | Approved | Founder selected iOS as the first platform | Original consolidation | Medium | Narrows platform scope | Android remains future |
| D-003 | Twinko is the central companion character and a cute star | Approved | Character relationship is the product center | Original project brief | Costly after lock | Drives brand and UX | Maintain a model sheet |
| D-004 | Core value territory is emotional companionship and low-pressure self-expression | Approved intent; market need unvalidated | Consistent across chats | Original project brief | Yes | Guides positioning and safety | Validate later |
| D-005 | Broad early-user hypothesis is approximately 18/20–35 digital natives | Working direction | Different chats used 18–35 and 20–35 | Cross-chat reconciliation | Yes | Research and tone | Do not treat as final persona |
| D-006 | TwinkoTalk combines companion Chat, Tarot, Astrology and future wellness modes | Approved product universe; exact commercial value unvalidated | Founder retained the multi-mode concept | Original and latest founder input | Yes | Product architecture and brand | Current prototype uses three active modes |
| D-007 | Proactive check-ins are a future companion capability | Deferred / working direction | Useful but raises consent and dependency risks | Original concept | Yes | Notifications and personalization | Not in prototype |
| D-008 | Outfits, rooms and customization are future gamification / IP assets | Deferred | Founder values pet-like customization but removed it from prototype | Original + latest founder input | Yes | Art and monetization | Backlog |
| D-009 | Meditation, Music and Story are future content modes | Deferred | Current prototype focuses on Chat, Tarot and Astrology | Original + latest founder input | Yes | Content and licensing | Backlog |
| D-010 | Welcome → Profile Setup → Home is the current prototype onboarding flow | Approved | Founder explicitly confirmed the required pages | Latest founder input | Yes | Prototype flow | No formal authentication |
| D-011 | Prototype Profile Setup collects name, birthday and gender | Approved | Founder explicitly confirmed all three fields | Latest founder input | Yes | Personalization and privacy | Define gender options and disclosure |
| D-012 | Historical MVP with five complete modes is not the current prototype scope | Superseded | Current active scope is three modes | Reconciliation | Yes | Protects scope | Meditation and Music are disabled only |
| D-013 | Music is not an active prototype feature | Approved deferral | Founder moved it to backlog | Latest founder input | Yes | Reduces scope | Visible as coming soon |
| D-014 | Community, wearables, broad divination suite, marketplace and complex gamification are not prototype-critical | Approved deferral principle | They add major scope and risk | Reconciliation | Yes later | Backlog management | Revisit after prototype |
| D-015 | Visual mood is warm, cute, dreamy, cosmic and magical | Approved | Repeated across all visual directions | Original + latest reference | Medium | Brand and UI | Translate into consistent system |
| D-016 | External visual references communicate mood only and must not be copied | Approved constraint | Original IP is required | Governance | No | IP and design | Maintain original character assets |
| D-017 | Historical gold / lavender / deep-purple palette remains a working reference | Working direction | Consistent with current visual reference | Original + latest image | Yes | Design system | Validate contrast |
| D-018 | Official product name is TwinkoTalk; character name is Twinko | Approved | Founder explicitly decided | Latest founder input | Medium before launch | Naming and files | Use consistently |
| D-019 | Earlier Lovable prototype is a structural / historical reference, not the current visual standard | Approved | Latest character-first direction supersedes the dashboard look | Visual reconciliation | Yes | Design reference handling | Archive old visuals |
| D-020 | English follows Traditional Chinese rather than launching simultaneously | Approved | Founder explicitly decided | Latest founder input | Yes | Content scope | Prototype is Chinese-first |
| D-031 | Monetization options include subscription, premium content, cosmetics, partnerships and hybrid models | Hypothesis pool | No model has evidence yet | Business discussion | Yes | Future commercial design | Do not implement in prototype |
| D-032 | No pricing, free quota, paywall timing or willingness-to-pay conclusion is approved | Approved evidence rule | No product-use evidence exists | Business reconciliation | Yes | Prevents false certainty | Test later |
| D-033 | Landing page, waitlist, App Store copy and creator content are future GTM tools | Working direction | Useful after positioning and beta planning | Historical planning | Yes | Growth | Not prototype requirement |
| D-034 | Beta should test no more than one low-cost progression mechanic, if any | Approved principle | Avoids confounded learning and scope creep | Earlier reconciliation | Yes | Gamification experiment | Prototype tests none |
| D-035 | Historical two-week and two-month schedules are not governing | Superseded | They predate current decisions | Historical plans | Yes | Planning | Archive only |
| D-036 | Historical 84-day plan is a reference, not a validated estimate | Superseded as current plan | It was created before current scope lock | Historical plans | Yes | Planning | Archive only |
| D-037 | Crisis, medical, legal and financial boundaries are mandatory before public release | Approved risk requirement; detailed policy pending | Companion products encounter sensitive situations | Trust analysis | No | Safety | Create policy before beta |
| D-038 | Tarot and Astrology are reflection / entertainment rather than deterministic prediction | Approved | Reduces harm and matches product intent | Trust analysis | No for claims | Content and UX | Apply to all copy |
| D-039 | No manipulative emotional-dependency or dark-pattern engagement | Approved | Healthy trust is the goal | Gamification reconciliation | No | Notifications, copy, monetization | QA guardrail |
| D-040 | Retention, conversion, health outcomes and gamification effectiveness remain unvalidated | Approved evidence rule | No beta data exists | Reconciliation | Yes when evidence arrives | Metrics and claims | Do not overclaim |
| D-041 | Prototype language is Traditional Chinese; first commercial geography remains pending | Partly approved / partly pending | Language decided; launch market not decided | Latest founder input | Yes | Content and legal | Choose geography later |
| D-042 | Prototype does not require account authentication | Approved | Founder explicitly decided | Latest founder input | Yes | Onboarding | Use local / prototype profile |
| D-043 | Prototype Chat does not use a live LLM | Approved | Founder wants product flow first | Latest founder input | Yes | Chat scope | Scripted / mocked responses |
| D-044 | Long-term AI memory is deferred; Chat History is not the same as memory | Approved deferral | Founder requires history but not memory | Latest founder input | Yes | Data and UX | Keep concepts separate |
| D-045 | Public community / UGC is not in the prototype | Approved deferral | Moderation burden is too high | Earlier reconciliation | Yes | Scope and safety | Backlog |
| D-046 | Market / business / gamification source summaries are references and hypotheses, not validation | Approved evidence rule | They consolidate ideas without user or market proof | Earlier reconciliation | No | Source handling | Keep status labels |
| D-047 | Primary user wedge remains unresolved but no longer blocks prototype production | Approved sequencing update | Founder chose prototype-first execution | Latest sequencing | Yes | Research timing | Validate after prototype |
| D-048 | Competitor set is research-only; no superiority claim is approved | Approved evidence rule | Current benchmark is incomplete | Market reconciliation | No for claims | Positioning | Verify later |
| D-049 | Commercial model selection requires recurring-value, WTP, cost and retention evidence | Approved decision rule | Competitor pricing is insufficient | Business reconciliation | No | Monetization | Test later |
| D-050 | Partnerships must not become prototype dependencies | Approved operating principle | Broad partnerships create premature complexity | Business reconciliation | Yes | Partnerships | Backlog |
| D-051 | Discovery-to-Decision is not the immediate blocking milestone | Superseded | Founder now wants prototypes first | Latest sequencing | Yes | Execution | Can return later |
| D-052 | Current execution is prototype-first; prototype completion precedes formal market and monetization validation | Approved | Latest founder direction | Current chat | Yes | Roadmap | Do not claim validation |
| D-053 | Traditional Chinese is completed before English localization | Approved | Founder explicitly decided | Latest founder input | Yes | Content and QA | English later |
| D-054 | Future account options are Sign in with Apple and Google Sign-In | Approved future direction | Founder explicitly decided | Latest founder input | Yes | Future onboarding | Not in prototype |
| D-055 | Home / Menu displays five modes but only Chat, Tarot and Astrology are active | Approved | Founder wants the full universe visible | Latest founder input | Yes | Home UX | Meditation and Music disabled |
| D-056 | Disabled modes must communicate unavailable / coming soon rather than silently fail | Working design requirement | Prevents broken-product perception | Professional recommendation | Yes | UX clarity | Founder may refine treatment |
| D-057 | Chat History is real and usable in the prototype | Approved | Founder explicitly decided | Latest founder input | Yes | Prototype scope | Save, list and reopen chats |
| D-058 | Tarot supports Single Card and Three Cards | Approved | Founder explicitly decided | Latest founder input | Yes | Tarot scope | No four-card spread |
| D-059 | Three-card meaning remains a pending micro-decision | Pending | Multiple safe structures are possible | PRD review | Yes | Tarot content | Choose before production |
| D-060 | Astrology fields are love, career, finance, lucky number, lucky color, lucky sign and lucky item | Approved | Founder explicitly decided | Latest founder input | Yes | Astrology content | Also show date, sign and overall guidance |
| D-061 | Astrology prototype is sun-sign daily content, not a full natal chart | Approved scope interpretation | Birthday alone does not provide a full chart | Product reconciliation | Yes | Claims and complexity | Compatibility deferred |
| D-062 | The latest supplied Twinko image is the prototype character baseline | Approved | Founder explicitly selected the reference | Latest founder input | Medium | Brand consistency | Create a model sheet |
| D-063 | Complete gamification is moved to the Feature Backlog | Approved | Founder explicitly deferred it | Latest founder input | Yes | Scope | No pet loop in prototype |
| D-064 | Future pet gamification may include happiness, feeding, interaction, outfits, backgrounds and levels | Backlog hypothesis | Founder described the desired future system | Latest founder input | Yes | Future retention and IP | Requires ethics and evidence |
| D-065 | Negative mood must not immediately reduce a user-growth or Twinko score | Approved ethical principle | Avoids punishing emotional difficulty | Latest founder input | No | Gamification | Encode in future design |
| D-066 | Nearby wellness activities and booking are a future partnership / revenue hypothesis | Backlog hypothesis | Founder proposed an activity-discovery model | Latest founder input | Yes | Marketplace and business | Not prototype |
| D-067 | Mood-based in-app and offline recommendations are a future orchestration concept | Backlog hypothesis | Could connect companion context to actions | Latest founder input | Yes | Personalization | Requires consent and evidence |
| D-068 | Push notifications are future, proactive companion features and require consent and control | Deferred / approved guardrail | Founder proposed reminders and encouragement | Latest founder input | Yes | Retention and trust | Not prototype |
| D-069 | Advanced astrology compatibility and additional divination systems are backlog | Approved deferral | Founder wants the ideas preserved but not built now | Latest founder input | Yes | Feature universe | Prioritize later |
| D-070 | CBT / mindfulness-inspired mechanisms may inform general wellness design but must not be hidden or marketed as treatment | Approved governance correction | Legal and ethical safety requires transparency and review | Latest founder input + reconciliation | No for governance | Content and claims | Professional review if structured protocols are used |
| D-071 | TwinkoTalk should build healthy trust and repeat value, not unhealthy dependency | Approved | Founder wants a deep relationship; governance reframes the goal safely | Cross-chat reconciliation | No | Product and metrics | Use healthy relationship language |
| D-072 | Prototype and MVP are separate stages; current scope is a prototype, not a finalized MVP | Approved | Prevents overclaiming readiness | Phase 2 reconciliation | Yes | Planning | Define MVP after review |
| D-073 | Founder-provided installation figures are directional references only | Approved evidence label | Sources and methodology are incomplete | Latest founder input | No for evidence status | Market analysis | Do not use as market sizing |

| D-074 | Market, Business, Product Experience, Gamification and Product Operations domain drafts are integrated into canonical / execution files rather than maintained as parallel active strategies | Approved | Avoids duplicate sources of truth while preserving complete content | File-architecture reconciliation | Yes | Documentation governance | Standalone drafts archived as references only |
| D-075 | The active package uses four layers only: Start Here, Canonical, Product Execution, Trust/Governance; all source summaries and superseded drafts live under References | Approved | Makes restart and handoff simpler for founder and AI collaborators | File-architecture reconciliation | Yes | Project operations | Keep MANIFEST and Start Here aligned |

## Archived Technical Decision Range

Earlier technical planning used IDs D-021–D-030 for implementation tools, backend, coding agents, repository, and PM Workflow mechanics. Those decisions are intentionally excluded from the active nontechnical consolidation requested for this restart. Their historical text remains available in the reference copies of the previous Decision Log and Execution Restart Plan.

## Current Founder-Decision Queue

The remaining decisions are specification-level rather than strategy-level:

1. Gender options and whether “prefer not to say” is offered.
2. Final Chinese label for the Astrology mode.
3. Meaning of the three Tarot positions.
4. Number and branching depth of scripted Chat scenarios.
5. Chat-history title behavior.
6. Astrology content source / refresh method.
7. Disabled-state presentation for Meditation and Music.
8. Final Twinko model sheet and typography.
9. Adults-only or broader age policy for a future beta.
10. First commercial launch geography.
