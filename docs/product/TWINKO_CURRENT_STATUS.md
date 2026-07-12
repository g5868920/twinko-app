<!--
Twinko migration metadata (appended at migration time; not part of the source document)
canonical_owner_repository: twinko-app
source_repository: gina-ai-native-venture-studio
original_source_path: handoffs/twinko/TWINKO_CURRENT_STATUS.md
source_commit_hash: 11e05ba
migration_date: 2026-07-12
document_classification: Twinko product canonical
-->

# TWINKO_CURRENT_STATUS

> Status date：2026-07-11  
> Stage label：Pre-build consolidation / product definition  
> Evidence rule：只將 project 內有證據的內容列為 completed；計畫、建議與 working direction 不視為已完成。

## Current Stage

Twinko 仍處於 **pre-build consolidation / product definition**，但 source-of-truth 已新增 market、business model、unit economics、partnership 與 gamification 的 detailed domain supplement。

該 supplement 的角色是 hypothesis and decision framework，**不是 market validation**。目前最重要的 execution gate 已調整為：

1. Validate and choose the primary user wedge。
2. Validate and choose the primary first-value moment。
3. 再進行 v1 scope、positioning、naming、UX 與 technical build decisions。

最新方向維持不變：

- Twinko 要成為公開推出的 native iOS app。
- Swift / SwiftUI / Xcode、Claude Code + Fable、Cursor、GitHub、Supabase 與 independent coding review 是 current working tool stack。
- Twinko 是 AI-Native PM Workflow 的 first real dogfooding case。
- Immediate dogfood scope 是一個 bounded **Discovery-to-Decision** slice，而不是 full engineering automation。

## Completed

### Product concept

- 定義 Twinko 是可愛星星 AI digital companion。
- 定義核心問題 hypothesis：使用者有時需要陪伴與傾訴，但不想打擾親友或進入正式諮商。
- 定義初始 target range：18-35 young adults；尚未驗證或 narrow。
- 建立 initial feature universe：Chat、Tarot、Astrology、Meditation、Music，另有 gamification、stories、notifications 等延伸概念。
- 建立 rough onboarding / home journey。
- 確認 proactive care / daily check-in 的產品意圖。

### Early brand / experience direction

- 角色為黃色星星 Twinko。
- 初始 mood：可愛、療癒、夢幻、沉浸、帶遊戲感。
- 有 Soft Gold、Lavender、Dark Slate Grey、Fredoka 等 historical visual references。
- 有功能切換時換裝、場景與音樂變化的 signature interaction concept。

### Planning and governance

- 建立 Product Operating Brief、Current Status、Decision Log、Venture Studio Handoff。
- 完成 `TWINKO_MARKET_BUSINESS_GAMIFICATION_CONSOLIDATION.md`，整理 market / business / monetization / unit economics / partnerships / gamification / ethical engagement hypotheses。
- 明確標示該 supplement 不構成 market validation。
- 已決定 Twinko dogfood AI-Native PM Workflow。
- 已提出 current native iOS tool allocation。
- 已確認 complex gamification 不應是 launch-critical direction；beta 若測試 progression，最多一個 low-cost mechanic。

## In Progress

- Incremental source-of-truth reconciliation across the four canonical documents。
- Market / problem validation planning for three candidate user wedges。
- Definition of candidate first-value moments and decision criteria。
- Discovery-to-Decision PM Workflow dogfood slice design。
- Scope classification：launch-critical / supporting / post-launch / deferred / undecided。
- Unit-economics measurement framework and ethical monetization principles。
- Founder review of unresolved product、safety、design、commercial and gamification decisions。

目前沒有足夠證據確認以下項目已在 active implementation：

- 正式 SwiftUI repository。
- Supabase environments。
- Current Lovable prototype that can be reused。
- Approved Figma files。
- Production content database。
- TestFlight build。
- Interview evidence or validated primary wedge。

## Not Started

### Research and validation

- Target-user interviews across the three candidate segments。
- Positioning and first-value concept comparison。
- Structured current-alternative / switching-trigger analysis。
- Formal competitor feature、pricing、review and positioning benchmark。
- Character-layer value test。
- Willingness-to-pay research after product experience。
- Meaningful retention and gamification-effectiveness measurement。
- Beta cohort recruitment。

### Product definition

- Final primary user wedge。
- Final primary first-value moment。
- v1 scope freeze。
- Approved feature acceptance criteria。
- Activation / retention / launch metrics。
- Safety and escalation policy。
- Memory and personalization policy。
- Notification strategy。
- Monetization decision。
- Beta progression decision：none vs one low-cost mechanic。

### Business / operations

- Cost-per-meaningful-session model。
- Free-user and subscriber variable-cost estimate。
- Gross-margin scenarios。
- Launch-critical partnership / vendor gap analysis。
- Pricing / paywall / entitlement design。

### Design

- Original Twinko character production。
- Final logo / app icon / brand system。
- Approved navigation and wireframes。
- UI screens and design system。
- Motion prototype and Reduce Motion behavior。
- Accessibility acceptance criteria。
- Asset / license register。

### Engineering

- Technical spikes。
- SwiftUI repository setup。
- Architecture decision records。
- Supabase schema / RLS。
- LLM provider selection and backend proxy。
- Analytics implementation。
- Notification implementation。
- Automated tests and CI。
- Independent review workflow。
- Production / staging environments。

### Content

- Approved Twinko persona prompt。
- Chat safety and quality test set。
- Tarot meanings / spreads and artwork。
- Astrology templates / generation policy。
- Meditation scripts / audio。
- Notification copy。
- Content review and versioning。

### Launch / operations

- Privacy policy and terms。
- App Store disclosures and assets。
- TestFlight beta。
- Support / incident process。
- Public launch plan。
- Post-launch analytics and review cadence。

## Current Blockers

1. **Primary user wedge is not selected or validated**：18-35 過於 broad；emotional companion、spiritual reflection、calming 三者不能同時作 primary target。
2. **Primary first-value moment is not selected or validated**：Chat、Tarot、daily insight、Meditation 何者最有感未知。
3. **Launch scope cannot be responsibly frozen before 1-2 are resolved**：原始 feature universe 仍過大。
4. **Safety model is undefined**：crisis、medical / legal / financial、dependency、fortune-telling boundaries 尚未 formalize。
5. **Technical stack is not validated**：SwiftUI + Supabase + AI coding agents 對 non-technical solo founder 的 maintainability 尚未證明。
6. **No approved original character / UI assets**：historical inspiration 存在 imitation / IP risk。
7. **No confirmed LLM provider、cost-per-session model or gross-margin path**。
8. **No legal / privacy operating plan**。
9. **No verified current code or prototype baseline**。
10. **PM Workflow Discovery-to-Decision data contract and usefulness test are not yet run**。

## Dependencies

- Founder decisions：primary wedge、first value、launch market、scope、safety、monetization、gamification beta rule、name。
- Product research：interviews、concept comparison、current alternatives、competitor benchmark。
- PM Workflow：research evidence schema、decision memo template、source traceability。
- Design capability：original character、motion、native iOS system。
- Engineering capability：SwiftUI、Supabase、LLM backend、App Store release。
- Unit economics：provider benchmark、backend / content / Apple cost assumptions。
- External services：Apple Developer、LLM provider、Supabase、analytics、TTS / audio。
- Legal / trust review。
- Content rights and production。
- Launch-critical partners only where capability、safety or rights require them。

## Decisions Needed Next

Priority order：

1. Primary user wedge。
2. Primary first-value moment。
3. Whether integrated multi-feature positioning or narrower wedge should guide v1。
4. First target market and language。
5. Exact v1 feature scope and explicit deferrals。
6. Safety / crisis / fortune-telling / ethical-engagement principles。
7. Whether beta includes no progression mechanic or one low-cost experiment。
8. Twinko vs TwinkoTalk naming。
9. Anonymous vs account-first onboarding and required birth data。
10. LLM provider benchmark、Supabase validation and unit-economics plan。
11. Beta success criteria and cohort。
12. Monetization decision timing, not pricing selection yet。

## Next Seven-Day Priorities

### Day 1 — Discovery question and evidence setup

- Finalize three candidate wedge statements and four candidate first-value moments。
- Create interview / concept-test questions focused on real behavior, triggers and current alternatives。
- Configure the PM Workflow Discovery-to-Decision evidence schema：source、segment、observation、quote、assumption、confidence、decision link。

### Day 2 — Participant and competitor groundwork

- Recruit target users across at least two or three candidate segments。
- Build a source-linked current-alternative map：Replika、Character.AI、ChatGPT、wellness、tarot / astrology apps、friends / journaling。
- Do not score Twinko as superior；capture only observable differences and user perceptions。

### Day 3 — First interview / concept-test batch

- Conduct initial interviews。
- Test Chat-first、Tarot / reflection-first、daily-insight-first or calming-first concept descriptions。
- Ingest raw notes into the PM Workflow without prematurely summarizing them as validation。

### Day 4 — Second interview batch and pattern coding

- Continue interviews until a minimum useful discovery sample is reached, ideally 5-10 total over the cycle。
- Code evidence by problem frequency、intensity、current workaround、trust、return intent and first-value response。
- Surface conflicts and missing evidence。

### Day 5 — Discovery synthesis

- Produce segment evidence matrix、JTBD pattern summary and first-value option comparison。
- Identify what is observation vs founder hypothesis vs AI inference。
- Draft preliminary recommendation with confidence and counter-evidence。

### Day 6 — Business and experiment implications

- Create a first unit-economics skeleton：LLM / backend / Apple / content cost variables；no price recommendation。
- Define whether beta should have no gamification or one low-cost progression experiment。
- Identify only launch-critical partner needs for safety、rights or capability gaps。

### Day 7 — Founder decision and workflow review

- Founder decides or explicitly defers the primary wedge and first-value moment。
- PM Workflow updates decision log、risk register、scope recommendation and next experiment。
- Review whether the Discovery-to-Decision slice saved time、preserved traceability and avoided false validation claims。
- Naming and full scope work begin only after these outputs are accepted。

## Next Milestone

**Discovery-to-Decision Gate v1**

This is the immediate milestone before Build Readiness Gate v1。It confirms that the initial product wedge and first-value direction are supported by traceable discovery evidence and a founder decision—not by naming preference、feature enthusiasm or AI-generated market assumptions。

The subsequent major milestone remains **Build Readiness Gate v1**。

## Definition of Done for the Next Milestone

- Candidate segments and first-value options are explicitly documented。
- Research method、participant profiles and limitations are recorded。
- At least one discovery cycle of interviews / concept tests is completed；a target of 5-10 is recommended, not treated as statistical validation。
- Current alternatives and switching triggers are documented。
- Evidence is classified as observation、participant statement、founder assumption、AI inference or unresolved gap。
- Primary wedge decision is Approved、Deferred or Rejected with rationale and confidence。
- Primary first-value decision is Approved、Deferred or Rejected with rationale and confidence。
- No competitor-superiority、retention、WTP or market-validation claim is made beyond evidence。
- V1 scope recommendation is updated based on the decisions。
- Complex gamification remains outside launch-critical scope。
- Beta progression direction is limited to none or one low-cost mechanic。
- Initial unit-economics variables are defined without invented pricing。
- Discovery-to-Decision PM Workflow outputs link back to sources。
- Founder reviews whether the workflow was useful and what should be automated next。

## Risks Requiring Founder Attention

- **Discovery avoidance**：naming、visual design或 technical build may feel more tangible, but should not displace wedge / first-value validation。
- **False validation**：small interviews and competitor observations are directional evidence, not proof of market size、retention or willingness to pay。
- **Scope ambition vs solo capacity**：native character animation + multiple AI / content features remains large。
- **Safety / trust**：emotional companion risk can outweigh visual quality。
- **Gamification overreach**：complex progression can add scope, manipulate behavior or conceal weak core value；beta is limited to at most one low-cost mechanic。
- **Brand originality**：do not build too close to Disney or competitor visual language。
- **AI-code dependency**：founder must understand architecture, review changes and recover from failures。
- **Data sensitivity**：chat、birth data and interview notes require deliberate access, retention and deletion choices。
- **Business-model uncertainty**：pricing、WTP、retention and gross margin are unvalidated。
- **Partnership distraction**：do not create broad partnership dependencies before product evidence。
- **Dogfooding distraction**：PM Workflow must prove value in a bounded Discovery-to-Decision slice before expanding。
