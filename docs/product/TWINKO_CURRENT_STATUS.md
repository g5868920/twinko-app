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

## Company Execution Status（Amendment — 2026-07-12）

> 這是一則 additive amendment，不變更、不刪除下方 Completed / In Progress / Not Started / Next Milestone 等既有內容。既有的 Discovery-first product-gating 邏輯（primary wedge、primary first-value moment、safety boundaries、Discovery-to-Decision、D-047、D-051）仍然有效，只是目前在 company-level 執行排序上被延後（deferred），不是被推翻或取代。

- **Repository canonical migration：已完成。** Twinko product truth（Operating Brief、Current Status、Decision Log）、strategy supplement 與 reconciliation history 已從 Studio 遷移到 `twinko-app`，`twinko-app` 現為 canonical owner。
- **Current product stage：仍為 pre-build。** 目前沒有 active 的 SwiftUI implementation milestone，也沒有 active 的 Discovery-to-Decision sprint。下方 Completed / In Progress / Not Started 描述的是 product-definition 階段既有的事實，依然成立，只是尚未被目前的 company priority 排入執行。
- **Current company execution priority：deferred。** 依據 Studio Decision 0006（Fast-Track Product Delivery）與 Decision 0007（One-Person Company OS v1.0 Reprioritization），Twinko UI prototype 與 Twinko Discovery-to-Decision 目前都是 deferred，不是 rejected 或 superseded。One-Person Company OS v1.0 目前是 primary active company milestone。
- **Next proposed product milestone：Product Definition Sprint。** 只有在 company 或 venture 層級出現新的、明確的 milestone authorization 之後，才可以重新啟動。下方「Next Milestone：Discovery-to-Decision Gate v1」是既有 product 邏輯下的既定目標，尚未變更，但目前不是 active 的執行對象。

Basis：`decisions/approvals/0006-fast-track-product-delivery.md`、`decisions/approvals/0007-one-person-company-os-v1-reprioritization.md`。

## Bounded Milestone Authorization（Amendment — 2026-07-13）

> 這是一則 additive amendment，疊加在上方「Company Execution Status（Amendment — 2026-07-12）」之上，不變更、不刪除該段落或下方 Completed / In Progress / Not Started / Next Milestone 等既有內容。D-052 所記錄的一般性 deferred 狀態，在本次授權範圍之外，依然完整有效。

- **Canonical repository migration：已完成。**（與上方一致，未變更。）
- **先前的執行狀態：deferred under D-052。** 在本次授權之前，Twinko implementation 與 discovery 在 company-level 上維持 deferred（見 D-052、上方 2026-07-12 amendment）。
- **目前的 bounded milestone：已授權。** 依據 D-053（見 `docs/product/TWINKO_DECISION_LOG.md`），"Twinko P0 Technical Foundation + First SwiftUI Prototype" 是一個 one-time, scope-limited exception，疊加在 D-052 的 deferred 狀態之上，不取代、不推翻 D-052。
- **目前的 product stage：pre-product-validation technical prototype。** 這不是 product-validation 或 market-validation 階段；這是在 product decision（尤其是 D-047）尚未解決之前的技術性 foundation 驗證。
- **Active scope：P0 technical foundation + App Shell + Mock Chat。** 僅限建立最小 Xcode/SwiftUI app shell、驗證 local build 與 iOS Simulator 執行、並實作一個 fully-mocked Chat flow。
- **Mock Chat 的角色：technical prototype vehicle only。** Mock Chat 用來驗證 navigation、state management 與 mock-service architecture；這不是「Chat 是 primary wedge / primary first-value moment」的決定，且不得被引用為這樣的決定。
- **尚未解決的 product decision：D-047。** Primary user wedge 與 primary first-value moment 依然 pending，未因本次技術授權而改變或預先決定。
- **Live services：prohibited。** 本次授權不包含任何 backend、Supabase、authentication、live LLM、API keys、cloud sync、analytics/crash-reporting SDK、TestFlight/App Store 作業、payments 或 PM Workflow integration。
- **Production infrastructure：prohibited。** 不建立任何 production persistence 或 production infrastructure；僅限 in-memory 或 bundled mock data。
- **Next gate：milestone Definition of Done，其後為 Chairwoman review。** Implementation 必須在 milestone 的 Definition of Done（見 D-053 與 Chairwoman Decision Request §5）停止；任何超出此範圍的後續工作，都需要新的、明確的 milestone authorization。

Basis：`docs/product/TWINKO_DECISION_LOG.md`（D-053）、Chairwoman Decision Request — Twinko P0 Technical Foundation + First SwiftUI Prototype（2026-07-12）。

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

## Active Implementation Milestone（Amendment — 2026-07-13）

> 這是一則 additive amendment，疊加在上方「Bounded Milestone Authorization（Amendment — 2026-07-13）」之上，不變更、不刪除該段落或其上任何既有段落。D-052 所記錄的一般性 deferred 狀態，在本次授權範圍之外，依然完整有效；D-047 依然 unresolved。

- **P0 engineering baseline：已完成並保留。** 依據 D-053 建立的最小 Xcode/SwiftUI app shell 與 fully-mocked Chat flow — build 與 unit tests 通過、無 network/persistence/secret/external SDK — 是既定的技術基礎，本次里程碑對其進行擴充，而非重建或取代。
- **目前的 active implementation milestone：`Twinko Full Interactive Local Prototype`。** 依據 D-054（見 `docs/product/TWINKO_DECISION_LOG.md`），此為疊加在 D-052 deferred 狀態之上的 bounded exception，僅在 D-054 所列範圍內取代 D-053 作為 *active implementation scope*；D-053 本身作為已完成的 P0 baseline 記錄維持 historically intact，不被改寫。
- **Current stage：local interactive prototype。** 範圍涵蓋 Welcome、Profile Setup（preferred name、birthday、gender）、Home Menu、Chat（含本地持久化的 Chat History：儲存、列表、重新開啟、刪除、新增 session）、Tarot（single-card 與 three-card，三張牌位置為「情境」「洞察」「建議」）、以及本地「每日星座」畫面（love、career、finance、lucky number、lucky color、lucky zodiac sign、lucky item）。Meditation 與 Music 僅以已停用的「即將推出」tile 呈現，無功能實作。
- **Primary implementation model：Fable。** Sonnet 可用於後續的測試、除錯或清理工作，但 Fable 為此里程碑的主要 implementation model。
- **Implementation method：擴充既有 SwiftUI baseline。** 保留既有 Xcode project、SwiftUI app target、Chat state-machine pattern，以及 View → ObservableObject/ViewModel → protocol service 架構；`RootShellView`、`TwinkoCharacterView`、視覺樣式、本地 Chat 內容與 navigation shell 允許 contained redesign 或 replacement。不引入 Clean Architecture、通用 repository 框架、dependency container、外部套件或推測性抽象。
- **Local persistence：Codable JSON in Application Support。** 僅限 local profile、local Chat sessions/messages、與 minimal prototype preferences；本地、可檢視、可刪除，不含雲端同步、不宣稱加密或正式產品等級的資料持久性、不存取任何外部 provider。不使用 SwiftData、Core Data、遠端資料庫，或以 UserDefaults 儲存對話紀錄。
- **Active modes：Chat、Tarot、Astrology。** 三者皆為 active，並依循現有 trust/safety 文件的 framing 規則。
- **Disabled prototype modes：Meditation、Music。** 於 Home Menu 中可見，標示為「即將推出」，無功能實作。
- **Naming：`Twinko` 為暫時性 prototype working label。** 不得於畫面中宣稱 `TwinkoTalk` 為核准的最終產品名稱。
- **Language：Traditional Chinese first。** English localization deferred。
- **Live services：prohibited。** 本次授權不包含任何 live LLM、backend、authentication、cloud sync、external API、analytics、crash-reporting SDK、payments、subscriptions、TestFlight，或 App Store 作業。
- **Production infrastructure：prohibited。** 不建立任何 production infrastructure 或正式產品等級的資料持久性；僅限 D-054 所授權的 local、deterministic、Codable JSON 內容與 persistence。
- **D-047：unresolved。** 本次里程碑作為 experience-evaluation vehicle，不決定 primary user wedge 或 primary first-value moment，也不因 Home Menu 中 Chat、Tarot、Astrology 的並列呈現而賦予其相等的策略優先性。
- **Next gate：本次里程碑的 Definition of Done，其後為 Chairwoman review。** Implementation 必須在 D-054 所定義的 Definition of Done 停止；任何超出此範圍的後續工作（live AI、beta 或 release 相關），都需要新的、明確的里程碑授權。

Basis：`docs/product/TWINKO_DECISION_LOG.md`（D-054）、Chairwoman Decision Request — Twinko Full Interactive Local Prototype（2026-07-13）。

## Home Screen Refinement（Amendment — 2026-07-14）

> 這是一則 additive amendment，疊加在上方「Active Implementation Milestone（Amendment — 2026-07-13）」之上，不變更、不刪除該段落或其上任何既有段落。

- **D-054 full local prototype baseline：已存在。** Welcome、Profile Setup、Home Menu、Chat（含 Chat History）、Tarot、每日星座 的完整本地互動原型已依 D-054 建置完成（見上方 2026-07-13 amendment）。
- **目前的 active implementation scope：D-055 Home refinement。** 依據 D-055（見 `docs/product/TWINKO_DECISION_LOG.md`），founder-approved 的 Home Screen Specification 與 Asset Manifest（`docs/ux/TWINKO_HOME_SCREEN_SPEC_V1.md`、`docs/ux/TWINKO_HOME_ASSET_MANIFEST_V1.md`）現為 Home 畫面的 controlling specification，`Log Out` 除外。
- **Home 使用 fixed approved image assets。** 背景 `home_screen_v1.png`、中央角色 `twinko_default_smile_v1.png`、五個 mode icons，皆已 byte-identical 方式 promote 至 `assets/home/` 與 `assets/twinko/`，不得 redraw、recolor、reshape 或 regenerate。
- **English 與 Traditional Chinese Home 實作為 active 且並行開發。** 兩種語言版本需並行開發與測試，UI 佈局在兩種語言下皆不得 clipping 或 overlap。
- **Meditate 與 Music 使用 minimal local placeholder navigation。** 兩者皆為可點擊，開啟保留現有視覺世界、具備可運作返回導覽的 placeholder 頁面；不含假功能、不含音訊播放器、不含 mock service。
- **不使用「Coming Soon」／「即將推出」狀態。** 不使用 disabled opacity 或 disabled interaction treatment；此規則取代 D-054 amendment 中 Meditation／Music 標示「即將推出」的敘述，僅限 Home 畫面範圍。
- **Profile sheet 包含 Profile、Settings、Privacy。** Settings 內含 Language。Traditional Chinese：個人資料、設定、隱私、語言。
- **Log Out：排除於 active scope 之外。** 因目前無 authentication 或 account system，`Log Out`／「登出」不得出現在 Home 或 Profile sheet 的任何實作中。
- **Naming：仍未解決。** Home 不得顯示 `Twinko`、`TwinkoTalk` 或任何其他 product wordmark。
- **D-047：作為最終產品策略與 v1 決策的有效指引，但不再阻擋 integrated interactive prototype 的實作或評估。** Chat、Tarot、Zodiac、Meditate、Music 在 prototype 中並列呈現，不構成 primary wedge、market validation、對等 strategic priority、retention 或 final v1 scope 的證明。
- **Live services 與 production infrastructure：仍然 prohibited。** 本次授權不包含任何 live AI、backend、authentication、cloud、analytics、payment、beta、release 或 production infrastructure。
- **Next gate：Home implementation、視覺驗收（對照核准的 specification）、build/test validation，其後為 Chairwoman review。**

Basis：`docs/product/TWINKO_DECISION_LOG.md`（D-055）、Chairwoman Decision Request — Twinko Home UI v1（2026-07-14）、`docs/ux/TWINKO_HOME_SCREEN_SPEC_V1.md`、`docs/ux/TWINKO_HOME_ASSET_MANIFEST_V1.md`。

### Temporary vector-icon exception（additive note — 2026-07-14）

- **交付的 icon 與 Twinko PNG 目前缺少真正的 alpha channel**（棋盤格為烘焙進不透明像素的圖樣），已於 asset 驗證中確認，暫時無法直接在 app 中使用。
- **D-055 授權一項 founder-approved 暫時例外**：五個 Home mode icons 以原生 SwiftUI vector views 暫時實作（以交付的 PNG 為視覺參照，不在 runtime 使用該等 PNG）；Home 中央角色暫時沿用既有的 procedural `TwinkoCharacterView`。`home_screen_v1.png` 為刻意不透明的背景，直接使用。
- **此例外不取代 founder-approved visual target**：待真正透明的 source assets 交付並通過 alpha 驗證後，應以 PNG assets 取代暫時的 SwiftUI drawings。
- **不改變任何 product scope、naming、language、navigation 或 feature 決策。**
- **Dogfooding distraction**：PM Workflow must prove value in a bounded Discovery-to-Decision slice before expanding。
