<!--
Twinko migration metadata (appended at migration time; not part of the source document)
canonical_owner_repository: twinko-app
source_repository: gina-ai-native-venture-studio
original_source_path: handoffs/twinko/TWINKO_PRODUCT_OPERATING_BRIEF.md
source_commit_hash: 8550cbb
migration_date: 2026-07-12
document_classification: Twinko product canonical
-->

# TWINKO_PRODUCT_OPERATING_BRIEF

> 文件狀態：Consolidated Working Source of Truth  
> Owner：Founder / Product Lead - Gina  
> Last updated：2026-07-11  
> 目的：在進入設計與開發前，統一 Twinko 的產品、商業、設計、技術、風險與 launch operating context。  
> Source priority：最新 founder 明確決策 > 原始 TwinkoTalk project brief > 後續工作計畫與 AI 建議。  
> 注意：本文把內容分為「已確認／已核准」、「Working direction」、「Unvalidated hypothesis」、「Open decision」；未經驗證的市場、使用者與商業假設不視為事實。`TWINKO_MARKET_BUSINESS_GAMIFICATION_CONSOLIDATION.md` 是 detailed domain supplement，不是市場驗證結果。

---

## 1. Executive Summary

### What Twinko is

Twinko 是一個以可愛星星角色為核心的 AI digital companion iOS app。它不是單純 chatbot，也不是單一塔羅、星座或冥想工具；產品意圖是透過角色互動、情緒陪伴、反思型內容與身心靈功能，讓使用者在不想麻煩朋友、無法立即找到合適對象傾訴，或只是想獲得一段溫暖互動時，有一個低門檻、隨時可用的 personal comfort space。

### User problem

原始產品假設指出，18-35 歲 young adults 可能會遇到：

- 有情緒或生活困擾，但不想打擾親友。
- 有些內容太私密，不想對真人說。
- 想被理解、陪伴或獲得正向引導，但不一定願意或需要進入正式心理諮商。
- 現有 AI chat、冥想、放鬆音樂、塔羅與星座服務分散在不同產品中。

以上是 founder-originated problem hypothesis，目前尚未以訪談、量化調查或真實使用數據驗證。

### Why it may be valuable

Twinko 的潛在價值來自三個組合：

1. **Character-based companionship**：透過具有持續人格、視覺存在感與主動關心能力的 Twinko，建立比工具型 app 更有溫度的互動。
2. **Integrated reflection experiences**：把 Chat、Tarot、Astrology、Meditation 等放在同一個 companion context 中，而不是各自獨立。
3. **Immersive native experience**：角色換裝、場景轉換、motion、聲音與回訪 loop 共同構成體驗，而不是只靠文字回覆。

這些是 differentiation hypotheses，不是已證明 Twinko 優於 Replika、Character.AI、Woebot、ChatGPT、Calm / Headspace 或專門 tarot / astrology apps 的結論。

### Market and commercial evidence status

- `TWINKO_MARKET_BUSINESS_GAMIFICATION_CONSOLIDATION.md` 已整理市場、business model、unit economics、partnership 與 gamification 的 working hypotheses。
- 該 supplement 提供研究框架與 decision inputs，但**不構成 market validation**。
- Pricing、willingness to pay、retention、competitor superiority、gamification effectiveness 與 commercial viability 均未驗證。

### Immediate product gating priority

在 naming、完整 visual identity 或 technical build 之前，當前最重要的 founder decisions 是：

1. **Primary user wedge**：先服務 emotional companionship、spiritual reflection，還是 short calming need？
2. **First-value moment**：使用者第一次在哪一個具體互動中明確感受到 Twinko 的價值？

Naming 仍重要，但應排在上述兩項 gating decisions 之後，因為 wedge 與 first value 會直接決定 positioning、onboarding、scope、research、metrics 與 build sequence。

### Current product stage

目前屬於 **pre-build consolidation / product definition stage**：

- 已有高層產品概念、初始 target user、initial feature universe、rough user flow、早期視覺方向與 domain supplement。
- 過去曾以 Lovable / no-code 作為 MVP 方向，但最新方向已轉為 native iOS commercial product。
- 尚未確認有可持續開發的正式 SwiftUI codebase、approved design system、validated target segment、正式 technical architecture 或 launch-ready content。
- 下一個 execution gate 是以 market / problem evidence 支持 wedge 與 first-value decision，而不是立即大量 coding。

### Intended commercial outcome

- 公開推出一個可在 App Store 發布、可維護、可持續迭代的 native iOS app。
- 建立足以驗證 retention、engagement、user trust 與 monetization willingness 的商業產品，而非只做 portfolio demo。
- 先透過 small beta / TestFlight 驗證，再決定正式 go-to-market、pricing 與 monetization model。

### Relationship to the AI-Native PM Workflow

Twinko 將是 AI-Native PM Workflow 的第一個真實 internal customer 與 dogfooding case。近期不先追求 full lifecycle automation；第一個 bounded dogfood slice 是 **Discovery-to-Decision**：將 research question、interview evidence、competitor observations、assumptions 與 decision criteria，轉成可追溯的 evidence map、decision memo、updated decision log 與 next-step backlog。

後續 Twinko 的 PRDs、design changes、GitHub activity、bugs、risks、launch criteria、user feedback 與 analytics 才逐步納入更完整的 PM Workflow lifecycle。

## 2. Product Vision

### Long-term vision

建立一個可愛、溫暖、具有記憶與個人化能力的 AI companion。使用者不只是「打開功能」，而是「回來找 Twinko」；Twinko 能根據 context 陪使用者聊天、提供反思型指引、帶領短時間放鬆活動，並透過一致的角色與互動設計形成長期關係感。

### Intended user experience

- 打開 app 時有「Twinko 正在等我」的感覺，而非進入工具 dashboard。
- 互動要 easy, safe, low-pressure，不要求使用者先輸入大量資訊。
- 情緒被接住後，再提供適合的下一步：繼續聊天、抽牌反思、查看 daily insight、做短冥想或暫停。
- 角色、場景、motion、sound 與 copy 應共同支持 emotional state，不只做裝飾。
- 每次互動都應讓使用者感覺被尊重，不被操控、不被過度依賴設計綁架。

### Strategic ambition

- 在 AI companion、wellness 與 spiritual reflection 的交叉區域建立 differentiated consumer product。
- 先以 iOS-first 建立品質與品牌辨識度，再根據需求與 economics 決定是否擴展 Android 或 web。
- 讓 Twinko 成為可反覆驗證 AI product judgment、native app execution 與 AI-Native PM Workflow 的實際場域。

### What Twinko should not become

- 不應宣稱是心理治療、診斷工具、危機處理服務或專業醫療替代品。
- 不應將塔羅、星座或其他 fortune-telling 結果包裝成確定預言或重大人生決策依據。
- 不應成為 generic LLM wrapper，僅以可愛 skin 包住普通聊天。
- 不應在 first release 同時塞入 community、wearables、local events、所有東西方命理、複雜 gamification 與大量付費內容。
- 不應透過 guilt、emotional pressure、假裝真實人類或刻意製造依賴來提升 retention。
- 不應直接複製 Disney《Soul》或任何競品的受保護視覺語言、角色造型或動畫表現。

---

## 3. Target Users

### Immediate segmentation gate

目前三個 segment 都是 founder hypotheses。**不能同時把三者都視為 primary target。** 下一個 product gate 必須透過訪談與 concept testing，選出一個 primary wedge；其他 segments 只能作 supporting use case 或 future expansion。

Decision priority：

1. Primary user wedge。
2. First-value moment。
3. Beachhead market / language。
4. Product naming 與 visual refinement。

### Segment A - 需要低門檻情緒陪伴的 young adults

- **User description**：18-35 歲，可能獨居、遠距工作、生活轉換中、社交支持不穩定，或偶爾不想對真人傾訴。
- **Jobs to be done**
  - 當我心情不好或腦中很亂時，讓我先把話說出來。
  - 給我一個不評判、低壓力、隨時可用的互動空間。
  - 在我不知道下一步要做什麼時，提供一個小而可行的行動。
- **Problems / unmet needs**
  - 不想打擾朋友或揭露隱私。
  - 普通 chatbot 缺乏持續角色感；wellness apps 又可能太制式。
- **Current alternatives**：朋友、社群、日記、ChatGPT / Character AI 類聊天工具、Replika、冥想 app、心理諮商。
- **Why adopt Twinko — hypothesis**：可愛角色、主動關心、情緒導向互動，以及聊天與反思功能整合。
- **Evidence level**：Founder hypothesis；尚未完成 user interview 或 behavioral validation。

### Segment B - 對塔羅、星座與 self-reflection 有興趣的使用者

- **User description**：會使用星座、塔羅、生命靈數等內容作為自我理解、娛樂或決策反思的 young adults。
- **Jobs to be done**
  - 當我對關係、工作或個人成長感到迷惘時，給我一個結構化的 reflection entry point。
  - 將抽牌或 daily insight 轉成可理解、可行動的 guidance。
- **Problems / unmet needs**
  - 內容分散、品質不一、過度宿命或缺少 personal context。
- **Current alternatives**：塔羅 app、星座 app、社群內容、真人占卜師、general-purpose LLM。
- **Why adopt Twinko — hypothesis**：同一角色能延續 context，將 insight 與聊天、行動建議連在一起。
- **Evidence level**：Founder hypothesis；市場興趣與 willingness to pay 尚未驗證。

### Segment C - 需要短時間放鬆或睡前陪伴的使用者

- **User description**：壓力高、睡前腦袋停不下來，希望透過短冥想、聲音或角色陪伴放鬆。
- **Jobs to be done**
  - 在 3-10 分鐘內降低緊繃感。
  - 睡前獲得不刺激、低互動負擔的陪伴。
- **Current alternatives**：Calm / Headspace 類 app、YouTube、Spotify、podcasts、白噪音。
- **Why adopt Twinko — hypothesis**：由熟悉角色帶領、可根據當下情緒推薦內容。
- **Evidence level**：Founder hypothesis；是否足以成為 primary wedge 尚未驗證。

### Beachhead market

- **Working hypothesis**：台灣或繁體中文使用者可能是較可控的 first beta market，因 founder 能直接研究、招募、營運並控制語氣品質。
- **Not approved / not validated**：是否鎖定台灣、台灣＋香港、中文 only、bilingual 或女性優先 segment。
- **Required evidence**：target-user access、current alternatives、iOS usage、trust / privacy attitude、concept response、early willingness to use。Willingness to pay 應在使用者實際體驗後才測，不應只靠抽象問卷。

## 4. Problem Definition

### Primary problem hypothesis

當使用者需要被陪伴、被聽見或整理情緒時，現有選項往往具有社交成本、隱私顧慮、時間限制，或缺乏持續角色感與個人化 context。

### Secondary problems

- Chat、tarot、astrology、meditation、music 被拆散在多個 app。
- 通用 AI 可能回答過度理性、不穩定或沒有安全邊界。
- wellness app 可能缺乏情感連結與遊戲感。
- fortune-telling 內容可能過度宿命、低品質或缺乏行動導向。
- 使用者回來的理由不明確，容易一次性使用。

### Existing workarounds

- 找朋友聊天或在社群匿名發文。
- 使用 general-purpose LLM。
- 分別開啟星座、塔羅、冥想或音樂 app。
- 寫日記、滑社群、看短影音分散注意力。
- 尋求專業心理支持。

### Why it matters

若 Twinko 能降低「啟動情緒照顧或自我反思」的門檻，並在低風險範圍內把陪伴、反思與微行動串起來，可能形成頻繁且具有 emotional value 的使用場景。反之，若只提供 novelty、generic content 或過多 unrelated modules，retention 可能很弱。

### Known evidence

- 已存在明確 founder problem intuition 與產品願景。
- 已建立 user segment、competitor / alternative、business-model、unit-economics 與 gamification validation framework。
- Project 內尚無完成的正式 market research、訪談逐字稿、survey、prototype comparison 或 usage data。
- 尚無 evidence 證明「多功能整合」比 narrower wedge 更能提高 adoption 或 retention。
- 尚無 evidence 證明 Twinko 優於目前 alternatives。

### Immediate validation questions

1. 使用者在什麼具體情境下會打開 Twinko，而不是找朋友、ChatGPT、tarot app 或 meditation app？
2. 三個 segment 中哪一個 pain / JTBD 最強、頻率最高、最容易測試？
3. Chat-first、Tarot-first、daily-insight-first 或 calming-first，哪一個 first-value moment 最有感？
4. 使用者把 Twinko 視為 relationship、tool、entertainment，還是三者組合？
5. Character layer 是否實際提高 trust、warmth 與 return intent？
6. Spiritual features 是 acquisition hook、recurring value，還是一次性 novelty？

### Assumptions requiring validation

1. 使用者願意對 AI 角色分享情緒。
2. 可愛角色與 motion 能提升 trust 與 return behavior。
3. Chat + Tarot / Astrology / Meditation 的組合不是過度分散。
4. 使用者願意接受 proactive notification。
5. spiritual content 能帶來 differentiation，而不降低 trust。
6. 使用者願意付費，且付費理由不是只靠 cosmetic items。
7. iOS-first 的可觸達市場足夠支持 beta 與早期商業驗證。
8. 任一 gamification mechanic 能改善 meaningful retention，而不降低 trust；目前完全未驗證。

## 5. Value Proposition

### Functional value

- 24/7 情緒對話與低壓力表達空間。
- 將迷惘轉成結構化 reflection：Chat、Tarot、Astrology。
- 提供短時間的 calm-down / meditation flow。
- 根據使用者同意保存的資料與偏好提供一致的 personalization。
- 透過 opt-in notification 形成溫和的 check-in。

### Emotional value

- 被記得、被迎接、被關心。
- 不必擔心麻煩他人或立刻解釋背景。
- 在 uncertain moment 得到陪伴與小步驟，而不是被說教。
- 與 Twinko 建立熟悉、可愛、可回訪的情感連結。

### Differentiation hypothesis

- Character-first，而不是 feature-dashboard-first。
- Emotional support + spiritual reflection + calming experience 的一體化。
- Native iOS motion、場景與音效形成沉浸式 interaction。
- 以亞洲文化語境與中文 UX 為可能切入點。
- 將占卜定位為 self-reflection，而非 prediction engine。

### Competitive claim boundary

- Replika、Character.AI、Woebot-like products、ChatGPT、Calm / Headspace 及 tarot / astrology apps 是 current working competitor / alternative set。
- 尚未完成正式 feature、pricing、review、retention 或 usability benchmark。
- 在取得可追溯 evidence 前，不得宣稱 Twinko 更安全、更療癒、更準確、更有 retention 或整體優於競品。

### Reasons to believe

目前只有 product concept、founder conviction 與 structured hypotheses；真正的 reasons to believe 必須來自：

- target-user interviews；
- positioning / concept tests；
- prototype usability and emotional-response tests；
- beta activation / meaningful retention；
- qualitative trust and emotional-value feedback；
- prompt safety and response-quality evaluation；
- cost-per-meaningful-session 與 willingness-to-pay evidence。

### Key risks

- 功能多但沒有單一 compelling first-value use case。
- 情緒陪伴品質不穩定，造成失望或傷害。
- 角色設計不夠 distinctive。
- spiritual content 讓產品顯得不可信或過於 niche。
- AI 成本與 subscription willingness 不匹配。
- 使用者對隱私、情緒資料與 notification 感到不安。
- Gamification 看起來幼稚、操控或與情緒場景不相容。

## 6. Core User Journey

### 1. Discovery

**Working direction**

- 使用者從 App Store、IG / TikTok content、creator collaboration、朋友分享或 waitlist 接觸 Twinko。
- Positioning 應先說明一個 primary need 和 first-value scenario，避免把功能清單當主訊息。

**Undefined**

- Primary user wedge、首發市場、語言、launch channel mix、ASO keyword 與 referral mechanism。

### 2. App installation

- App Store listing 傳達角色、核心情緒場景與一個主 first-value scenario。
- 安裝後不應立即要求過多敏感資料或複雜帳號設定。

### 3. Onboarding

**Historical approved concept**

1. Welcome page。
2. Twinko 歡迎使用者。
3. 點擊 “Start Your Journey”。
4. 輸入 name、gender、birth date。
5. 進入 Home。

**Open decisions**

- Gender 是否真的必要。
- Birth time / location 是否因 astrology 需要。
- 是否先 anonymous onboarding，再延後建立帳號。
- 如何說明資料用途、privacy 與 notification permission。
- 是否先讓使用者選擇目前想要的陪伴方式或 mood。

### 4. First value moment — immediate gating decision

目前有四個候選 first-value moments，但**不可在 discovery 階段假設它們同等重要**：

- 得到一段被理解的 Chat 回覆；
- 完成一次短 tarot reflection；
- 收到個人化 daily insight；
- 完成 3-5 分鐘 calming exercise。

下一輪 research / concept test 必須選出一個 primary first-value moment，並回答：

- 使用者是否在 onboarding 後約 3 分鐘內感受到明確價值？
- 他們會如何用自己的話描述價值？
- 是否有 return intent？
- 哪個 current alternative 原本會被使用？

此定義與候選順序尚未 founder approval，也尚未驗證。

### 5. Core recurring usage

- 開啟 Home，Twinko 根據時間與 safe context 問候。
- 使用者進入 primary flow，其他功能作 supporting options。
- Twinko 以一致 personality 回應。
- Session 結束時提供一個小結、下一步或「今天先到這裡也可以」。
- 使用者可回看有限度的 history / insight，前提是 privacy model 已定義。

### 6. Return loop

- Relationship continuity：Twinko 記得使用者同意保存的 preference / context。
- Daily value：opt-in check-in、daily insight 或 relevant content。
- Progress：reflection / calming history；是否進 v1 尚未決定。
- Cosmetic progression：post-launch hypothesis；beta 若測試，**最多只測一個低成本 mechanic**。
- 以「有價值的回訪」為主，而非 streak guilt。

### 7. Retention mechanism

候選機制：

- Relationship continuity。
- Daily value。
- Reflection / calming progress visibility。
- Content freshness。
- One low-cost progression experiment，例如一次 outfit unlock 或 simple relationship milestone。

Retention 與 gamification effectiveness 均未驗證。不得先以 points、levels、currency、leaderboard、gacha、punishment 或複雜 quest system 當作 retention solution。

### 8. Sharing / referral

尚未定義。Launch-critical scope 不建議加入公開 community。可考慮 post-beta 的低風險分享：

- 分享非敏感的 daily insight card。
- 分享 Twinko outfit / room。
- 邀請碼或 waitlist referral。

## 7. Product Scope

### Scope status summary

| Scope layer | Current interpretation |
|---|---|
| Launch-critical working set | Onboarding / profile、Home、Twinko core presence、one primary first-value flow、selected supporting features、basic safety、analytics、feedback、beta release infrastructure |
| Conditional beta experiment | At most one low-cost progression mechanic，例如 single outfit unlock 或 simple relationship milestone；只有在不影響 core build 時才加入 |
| Post-launch | Music / bedtime stories、expanded gamification、outfits / home decoration catalog、advanced personalization、更多命理工具、referral |
| Explicitly deferred | Complex points / levels / currency / missions / leaderboard / gacha、community、wearable integration、local / offline activities、完整 eastern / western fortune-telling suite |
| Superseded | 以 Lovable no-code 作為正式 commercial build 的 primary implementation；iOS / Android 同步 launch |
| Still undecided | Primary wedge、primary first-value flow、exact v1 feature set、account model、Music、push depth、paywall、history / memory、first market / language |

> 原始 feature universe 仍被保留作 historical context，但 launch scope 不能在 primary wedge 與 first-value moment 決定前被視為 frozen。

### Launch feature detail

| Feature | User problem | Intended outcome | Dependencies | Proposed success criteria | Known risk |
|---|---|---|---|---|---|
| Onboarding / Profile | 無法個人化問候與內容 | 低摩擦完成必要設定並理解資料用途 | Wedge decision、auth、privacy copy、profile schema | Completion、time to first value、drop-off | 要求過多資料造成流失；敏感資料風險 |
| Home / Twinko | 功能分散、缺乏 relationship continuity | 使用者感覺在「回來找 Twinko」 | Character assets、state、navigation、motion | Home-to-primary-flow conversion、qualitative warmth | 視覺效果掩蓋價值或拖慢效能 |
| Primary first-value flow | 使用者未快速感受到產品價值 | 在約 3 分鐘內完成一個明確有感互動 | User research、prototype、acceptance criteria | First-value completion、value articulation、return intent | 選錯 wedge，導致整體 build 偏離需求 |
| Chat candidate | 需要傾訴、整理情緒 | 被理解並得到低風險的小步驟 | LLM、prompt、memory、safety | Helpfulness、safety、repeat intent | Harmful advice、dependency、latency、cost |
| Tarot candidate | 面對 uncertain life question 缺乏反思結構 | 以抽牌與解讀促進 reflection | Card data / art rights、randomization、prompt | Completion、clarity、return intent | 宿命論、重大決策誤導、IP |
| Astrology candidate | 想快速獲得 daily personal reflection | 提供一致、可閱讀、非決定論 insight | Birth data、content source、caching | Insight completion、trust、repeat intent | 重複、資料要求、可信度 |
| Meditation candidate | 壓力或睡前需要短 calming flow | 完成可跟隨的 3-10 分鐘 session | Scripts、audio / TTS、player | Completion、reported calmness、repeat intent | 音訊授權、內容品質、scope |
| Safety / Fallback | AI 在 sensitive context 可能造成風險 | 辨識高風險情境、限制能力並提供適當資源 | Policy、rules / classifiers、copy、QA dataset | Safety test pass、incident rate | False negative / positive；地域差異 |
| Analytics / Feedback | 無法知道產品是否有價值 | 建立 decision-grade evidence | Event schema、privacy、tool | Event completeness、feedback response | Tracking 過多、隱私疑慮 |
| Beta Release | 無真實使用 evidence | 透過 TestFlight cohort 驗證 wedge、first value、trust、retention signal 與 cost | Apple setup、QA、support、legal basics | Crash-free beta、activation signal、critical bug closure | Founder capacity、insufficient cohort |

### Gamification scope constraint

- Complex gamification **不是 launch-critical**。
- Beta **最多測試一個低成本 progression mechanic**，並應有 control / comparison 或至少 structured qualitative feedback。
- Candidate examples：一次 outfit unlock、simple relationship milestone、completed-session acknowledgement。
- 不在 beta 同時建立 points、currency、levels、badges、streak rewards、missions、leaderboards、social competition、gacha 或 paid energy。
- 如果 core first-value flow 不成立，gamification test 應取消，而不是用 reward 掩蓋問題。

### Post-launch scope

- Music and bedtime stories。
- Small outfit collection、home decoration、seasonal visual content。
- Deeper memory and personalized recommendations。
- Other fortune-telling systems：Numerology、Chinese astrology、Human Design、Zi Wei Dou Shu 等。
- Local / offline activities recommendation。
- Wearable integration。
- Community features。
- Advanced referral / social sharing。
- Android / web expansion。

### Explicitly deferred

- Complex gamification economy：在 retention、trust 與 content-production economics 有 evidence 前不做。
- Community / public UGC：moderation、safety 與 privacy 成本高。
- Wearables：不是 first value 的必要依賴。
- Local activities marketplace / partner directory：需要 external data、ops 與 geographic coverage。
- 完整 fortune-telling suite：內容、品質、legal / trust 與 UX scope 過大。

### Rejected scope

目前沒有足夠 evidence 顯示 founder 永久 rejected 某個產品概念。以下屬「不應進 first release」而非永久拒絕：

- 所有 advanced features 同時開發。
- 以大量 decoration、points 或 rewards 取代核心 companion value。
- 需要真人 moderation 的 community。
- 以 guilt、loss、dependency 或 opaque reward mechanics 驅動使用。

## 8. UI, UX, and Brand Direction

### Visual identity

**Historical approved direction**

- App / working name：TwinkoTalk；角色名：Twinko。
- Icon：黃色星星。
- Palette：
  - Soft Gold `#FFD700` with reduced opacity。
  - Lavender `#E6E6FA`。
  - Dark Slate Grey `#2F4F4F`。
- Font reference：Fredoka。
- Overall mood：可愛、療癒、溫暖、夢幻、帶遊戲感與神秘感。

**Current requirement**

- 成為 visually distinctive、polished native iOS product。
- 必須建立 original visual language，不可直接複製 Disney《Soul》。
- `Twinko` 與 `TwinkoTalk` 的 naming hierarchy 尚未決定。

### Tone and personality

Working direction：

- Warm, caring, playful, slightly magical。
- 像朋友與 mentor，但不居高臨下。
- 可以幽默，但不在使用者脆弱時過度搞笑。
- 承認不確定性，不假裝具備專業治療或預知能力。
- 避免「只有我懂你」「不要離開我」等 dependency-inducing language。

### Interaction principles

1. **Character before menu**：Home 先讓 Twinko 有存在感，再導向功能。
2. **Low cognitive load**：每個 screen 聚焦一個 action。
3. **Emotional state aware**：visual / motion / copy 配合情緒，不製造刺激。
4. **Progressive disclosure**：進階選項在需要時才出現。
5. **Safe exit**：使用者可隨時結束、清除、重新開始。
6. **Transparent AI**：適當說明 Twinko 是 AI，且 fortune content 供反思／娛樂。
7. **No dark patterns**：notification、streak、paywall 與 memory 都需可控。

### Accessibility expectations

尚未 formal approval，但 commercial iOS 必須納入：

- Dynamic Type / scalable text。
- VoiceOver labels。
- 足夠 contrast。
- 不以顏色作為唯一訊號。
- Tap targets、focus order、audio controls。
- Reduced Motion。
- Captions / text alternative for audio content where practical。
- 避免閃爍、快速旋轉與造成不適的 motion。

### Design-system direction

Recommended working direction：

- SwiftUI token-based system：color、type、spacing、radius、shadow、motion。
- Reusable components：Twinko avatar state、primary CTA、feature card、chat bubble、insight card、modal、player controls、loading / error / safety state。
- Figma components 與 SwiftUI components 名稱盡量對齊。
- 所有 design assets 需有 ownership / license metadata。

### Navigation structure

Candidate：

- Onboarding flow。
- Main Home。
- Feature destinations：Chat、Tarot、Astrology、Meditation。
- Optional secondary area：History / Profile / Settings。
- 不建議 first release 使用過多 tabs；可能採 Home-first + context navigation。

需以 wireframe / prototype usability test 確認。

### Key screens

- Splash / launch。
- Welcome。
- Privacy / AI disclosure。
- Profile setup。
- Notification permission context。
- Home with Twinko。
- Chat。
- Tarot topic selection / spread / draw / reading / summary。
- Astrology daily insight。
- Meditation selection / player / completion。
- History or saved insights（若 launch scope 保留）。
- Profile / Settings / data controls。
- Safety / crisis fallback。
- Feedback。
- Paywall（只有 monetization 決策後）。

### UX writing direction

- 中文自然、像真實產品，不用過多 AI-style motivational language。
- 短句、低壓力、承認使用者選擇。
- Fortune content 使用「你可以把這張牌當作一個提醒」而非「事情一定會發生」。
- Safety copy 清楚、直接、不責怪。
- Permission copy 解釋 value before system prompt。

### References / inspirations

- Tamagotchi / virtual pet：relationship、return loop、character presence。
- Disney《Soul》：早期對柔和、靈魂感、夢幻世界的 mood reference，僅可作抽象靈感。
- Replika / Character AI / Woebot：競品或替代方案，需研究但不可直接照抄。
- Native Apple interaction patterns：current working direction。

### Areas still needing definition

- Final logo、character silhouette、face / limb treatment、outfit system。
- Home layout and navigation。
- Dark / light mode。
- Motion language。
- Illustration production method。
- Audio identity。
- Chinese / English typography。
- Accessibility acceptance criteria。
- Brand name and App Store display name。

---

## 9. Motion and Animation Direction

### Role of animation

Animation 應：

- 強化 Twinko 是一個「存在中的角色」。
- 表達 state：listening、thinking、celebrating、calming、warning。
- 支持場景切換與功能理解。
- 降低 loading 等待的不確定感。
- 提供 emotional pacing。

Animation 不應只是炫技或每次點擊都做長轉場。

### Signature interactions

Historical concept：

- 選 Tarot 時 Twinko 換上占卜師 outfit，背景與音樂切換成 tarot scene。
- 選 Meditation 時 Twinko 進入 calm / sleep outfit 與低刺激環境。
- Home 中 Twinko 在宇宙場景輕微 floating，並以使用者名稱問候。

Working recommendation：

- 保留 1-2 個 signature transformations 作為品牌記憶點。
- First release 不做大量高成本 3D；優先使用 original 2D / vector / SwiftUI motion，視 performance spike 再決定。

### Transition principles

- 轉場 200-500ms 為一般基準，長場景轉換需可略過或保持短。
- 功能切換要有 continuity，避免每個 module 像不同 app。
- 不以 motion 阻擋 primary task。
- 返回 Home 時狀態一致，不重播冗長 intro。

### Loading, error, success states

- Loading：Twinko thinking / breathing 的短 loop，加上可理解文字。
- Long LLM wait：顯示 progress expectation；超時可 retry / cancel。
- Success：微小 acknowledgement，不過度 fireworks。
- Error：Twinko 誠實說明「現在連不上」，提供重試與 fallback。
- Safety state：降低裝飾，使用清楚、穩定、直接的 UI。

### Consistency rules

- 建立 motion tokens：duration、easing、spring、distance、opacity。
- 同一 semantic state 使用同一 motion。
- Haptic、sound、motion 需協調，不重複刺激。
- Character animation 與 UI transition 分層，避免同時競爭 attention。

### Performance considerations

- 在真機測試 animation FPS、memory、launch time、battery。
- 遠端下載資產需 caching 與 fallback。
- 低網路時不依賴大型 asset 才能完成 core task。
- Lottie / Rive / SpriteKit / native SwiftUI 等方案需 technical spike 後決定。

### Accessibility

- 支援 Reduce Motion。
- 關鍵資訊不可只靠 animation。
- 提供靜態替代 state。
- 音效可關閉；背景音樂與語音音量可分開控制。
- 避免快速閃爍或無法停止的 loop。

---

## 10. Technical Architecture

### A. Confirmed product-level technical direction

- 目標是 public commercial iOS app。
- 需要 polished native iOS experience。
- 需要 maintainable、可持續迭代。
- GitHub 作為 source control。
- Xcode / Simulator / real-device testing 是 release workflow 的必要部分。
- AI-Native PM Workflow 將接收產品與工程 signals。

### B. Current working direction, not yet technically validated

- Swift + SwiftUI。
- Claude Code using Fable model 作為主要 implementation agent。
- Cursor 作為日常 codebase interaction environment。
- Supabase 作為 authentication、database、storage 與 backend services。
- Codex 或 independent coding agent 作 code review、test generation、bug detection。
- Native Apple animation / interaction frameworks 優先。

### C. Recommended architecture for validation

#### App structure

- Feature-oriented SwiftUI modules：
  - App / bootstrap
  - Onboarding
  - Home / Companion
  - Chat
  - Tarot
  - Astrology
  - Meditation
  - Profile / Settings
  - Shared Design System
  - Services
  - Safety
  - Analytics
- 避免 first build 過度 micro-modularization。
- 使用 clear protocol boundaries 讓 LLM、backend、analytics 可替換。

#### State management

Recommended candidates：

- SwiftUI Observation / `@Observable` with feature view models。
- Single app session state for auth / profile / entitlement。
- Feature-local state 不全部集中在 global store。
- Async operations 使用 Swift Concurrency。
- Final pattern需 technical spike 驗證，不先鎖死大型 architecture framework。

#### Navigation

- `NavigationStack` / typed destinations 作 working direction。
- Onboarding 與 authenticated main flow 分開。
- Deep link / notification routing 在 first architecture 中預留，但不需做完整 system。

#### Backend

Supabase working direction：

- Auth。
- Postgres data。
- Row Level Security。
- Storage for remote assets / audio when appropriate。
- Edge Functions 或 server-side proxy 以保護 LLM secrets and enforce policy。

需要驗證：

- Taiwan / target geography latency。
- Data residency / cross-border implications。
- RLS configuration skill。
- Cost at expected usage。
- Vendor lock-in與 backup。

#### Authentication

Open options：

1. Anonymous first, account later。
2. Sign in with Apple。
3. Email magic link。
4. Combination。

需要基於 onboarding friction、data persistence、App Store requirements 與 privacy 決策。不得把 LLM API keys 放在 client。

#### Recommended data entities

- `users`
- `profiles`
- `consents`
- `companion_preferences`
- `conversation_sessions`
- `messages`
- `memory_items`（若批准）
- `tarot_cards`
- `tarot_spreads`
- `tarot_sessions`
- `astrology_profiles`
- `daily_insights`
- `meditation_content`
- `meditation_sessions`
- `notification_preferences`
- `entitlements`
- `feedback`
- `safety_events`
- `analytics_events` or external analytics references
- `content_versions`

所有敏感欄位、retention policy 與 delete flow 尚未定義。

#### Media and assets

- Small launch-critical visual assets 可 bundle in app。
- Remote / frequently updated audio or content 可使用 Supabase Storage 或其他 CDN-backed storage。
- 需要建立 asset naming、version、license、fallback 與 compression policy。
- Music / voice / tarot art 上線前需確認 rights。

#### AI / LLM service layer

Recommended：

- App 不直接呼叫 provider secret。
- Backend function handles provider call、policy、logging、rate limit、fallback。
- Prompt templates version-controlled。
- 分離 system persona、feature prompt、safety policy、user context。
- Structured outputs for tarot / astrology / recommendations。
- Prompt and model version must be attached to evaluation / incident data。
- Provider 尚未決定，cost / latency / privacy / Chinese quality 需比較。

#### Notifications

- Local notification：可用於 simple scheduled check-ins。
- Remote push：需要 APNs、backend token management、preference / quiet hours。
- Founder需先決定 launch 是否需要 remote personalization。
- Permission 必須 contextual ask，並讓使用者控制 frequency。

#### Analytics

Tool 未決定。Architecture 應提供 vendor-neutral analytics protocol，避免 feature code 綁死特定 SDK。

#### Testing

Minimum proposed layers：

- Unit tests：business logic、formatting、random draw、state transitions。
- Integration tests：Supabase / backend / LLM stub。
- UI tests：onboarding、core feature flows、offline / error。
- Prompt regression tests：quality、format、safety、Chinese tone。
- Snapshot / screenshot review：key screens、Dynamic Type、dark mode、Reduce Motion。
- Real-device tests：performance、audio、notification、network changes。
- Beta incident / bug triage。

#### Release management

- Dev / staging / production environments。
- TestFlight internal -> small external beta -> wider beta。
- Build number、release notes、migration plan、rollback / feature flags。
- Launch blocker criteria：crash、data loss、auth failure、unsafe AI response、core flow failure、privacy issue。

#### GitHub / branch strategy

Recommended simple approach：

- Protected `main`。
- Short-lived `feature/*` branches。
- Pull request required for merge。
- Each PR links to issue / decision / acceptance criteria。
- AI-generated code must include tests or explanation when tests are not practical。
- Tagged beta / release versions。
- Secrets managed outside repository。
- CODEOWNERS may remain founder-only initially, with independent review gate。

#### AI coding workflow

1. Approved spec / acceptance criteria。
2. Create issue and branch。
3. Claude Code / Cursor implements within bounded scope。
4. Local build + tests。
5. Independent agent review。
6. Human reviews diff, UI screenshot, behavior and data implications。
7. Merge only after checks。
8. Update PM Workflow status, decision and risk signals。

### D. Technical questions requiring validation

- Can one non-technical founder safely maintain native SwiftUI with agent assistance?
- Which model / provider meets Chinese emotional-quality, safety, latency and cost needs?
- Supabase vs alternative backend for auth, privacy and scale。
- Animation framework and asset pipeline。
- Local vs server-generated astrology content。
- Data retention / memory architecture。
- Offline behavior。
- Analytics vendor。
- Subscription entitlement architecture。
- App Store signing / account / CI setup。
- PM Workflow integration method with GitHub / Supabase / analytics。

---

## 11. Tool-Assisted Development Workflow

| Tool | Primary ownership | Must produce | Human approval point |
|---|---|---|---|
| ChatGPT 5.6 | Product reasoning、architecture options、PRDs、acceptance criteria、risk critique | Decision-ready options、specs、review notes | Founder approves product decisions, scope, claims and priorities |
| ChatGPT Work | Cross-file synthesis / multi-step tasks where useful | Consolidated artifacts and traceability | Founder verifies source fidelity |
| Claude Code + Fable | Repository-level implementation、refactor、tests | Buildable code, commit summary, tests | Founder reviews behavior and independent agent reviews code |
| Cursor | Day-to-day code navigation、small edits、debugging | Local changes and explanations | No blind accept of large diff |
| Xcode | Build、simulator、profiling、signing、archive | Passing build, test results, release artifact | Founder verifies on simulator and real device |
| Codex / independent agent | Code review、test generation、bug detection、security critique | Review findings with severity and evidence | Founder decides merge / remediation |
| Supabase | Auth、database、storage、backend | Configured environments, policies, migrations | Founder reviews data model, access and cost |
| AI-Native PM Workflow | Governance、status、decision / risk / launch artifacts | Dashboard, backlog, decision log, reports | Founder remains accountable for decisions |

### Conflict resolution between AI recommendations

1. 回到 approved product objective 和 acceptance criteria。
2. 要求每個 agent 提供 rationale、tradeoff、evidence、risk。
3. 優先選最小、可測試、可回退的方案。
4. 若涉及 security、privacy、payments、legal、data loss，不能以 majority vote；需要 qualified human / professional review。
5. 將未解衝突記錄成 decision item，不得 silently combine。

### Verification model

- Code quality：build、tests、lint / static analysis、independent review、small PRs。
- Product quality：acceptance criteria、screen review、real-device test、user test。
- AI quality：golden test set、safety cases、tone review、structured output validation、model / prompt versioning。
- Operational quality：analytics completeness、crash monitoring、bug triage、release checklist。
- Legal / trust quality：privacy and terms review、data-flow map、content rights、current App Store compliance review。

### Must never be delegated without review

- Final product scope and roadmap tradeoffs。
- Safety policy and crisis response。
- Privacy / data retention / deletion decisions。
- App Store declarations。
- Subscription / pricing and claims。
- Merge of security-sensitive code。
- Production credentials、database policy、RLS。
- User-facing medical / mental-health / financial / legal wording。
- IP / licensing acceptance。
- Production release approval。

---

## 12. Data and Analytics

### Evidence status

Activation、retention、paid conversion、competitor performance 與 gamification effectiveness 都尚未有 Twinko 實際數據。以下是 measurement framework，不是 benchmark 或預測。

### Proposed event taxonomy

#### Acquisition / onboarding

- `app_first_open`
- `onboarding_started`
- `onboarding_step_completed`
- `onboarding_completed`
- `profile_created`
- `notification_permission_context_viewed`
- `notification_permission_result`

#### Core experience

- `home_viewed`
- `twinko_greeting_rendered`
- `feature_opened`
- `feature_completed`
- `first_value_completed`
- `session_ended`

#### Chat

- `chat_session_started`
- `chat_message_sent`
- `chat_response_received`
- `chat_response_failed`
- `chat_feedback_submitted`
- `safety_fallback_triggered`

#### Tarot

- `tarot_topic_selected`
- `tarot_spread_selected`
- `tarot_card_drawn`
- `tarot_reading_completed`
- `tarot_reading_saved_or_shared`

#### Astrology

- `daily_insight_viewed`
- `astrology_profile_completed`
- `daily_insight_feedback`

#### Meditation

- `meditation_selected`
- `meditation_started`
- `meditation_paused`
- `meditation_completed`
- `meditation_abandoned`

#### Return / monetization

- `notification_delivered`
- `notification_opened`
- `paywall_viewed`
- `trial_started`
- `subscription_started`
- `subscription_cancelled`
- `cosmetic_viewed`
- `cosmetic_purchased`

#### Optional beta progression experiment

Only instrument if one small experiment is approved：

- `progression_experiment_exposed`
- `progression_milestone_reached`
- `progression_reward_unlocked`
- `progression_reward_equipped`
- `progression_feedback_submitted`

#### Quality

- `app_error`
- `api_timeout`
- `content_load_failed`
- `audio_playback_failed`
- `crash`
- `feedback_submitted`
- `delete_account_requested`

### Activation definition

**Recommended working proposal, not approved**：

A user is activated when they complete onboarding and the selected primary first-value interaction within 24 hours. Before the primary wedge decision, Chat、Tarot、daily insight 與 Meditation 只是 candidate activation paths，不應同時被當作等價 definitions。

需要 discovery / beta data 判斷哪個 first-value action 最能預測 meaningful return。

### Retention definition

- D1 / D7 / D30 retained：使用者在指定日窗完成至少一個 meaningful interaction。
- 不以 app open alone 定義 retained。
- Cohort 需按 acquisition source、primary first feature、language、notification opt-in 分析。
- Retention target / benchmark 未 approved，也沒有 evidence 證明任何 gamification mechanic 會提高 retention。

### Engagement indicators

- Meaningful sessions per active user per week。
- First-value completion and time to first value。
- Chat helpfulness and safe-response feedback。
- Feature completion rate。
- Meditation completion。
- Daily insight repeat rate。
- Feature concentration / switching。
- Notification open to meaningful action。
- Repeat use without notification。

### Unit-economics indicators

必須在選定 monetization model 前建立：

- Cost per active user。
- Cost per meaningful session。
- Cost per Chat session / average turns。
- Free-user monthly variable cost。
- Subscriber monthly variable cost。
- LLM retry / moderation / memory-context cost。
- Backend、storage、audio / TTS cost。
- Gross margin after Apple fee and variable costs。
- Cosmetic / content production cost and break-even volume。
- CAC、paid conversion、renewal and LTV，僅在有真實數據後計算。

### Monetization metrics

僅在付費 experiment / model 被批准後：

- Paywall view -> trial -> paid conversion。
- Trial completion / cancellation。
- Subscriber retention / renewal。
- ARPU / ARPPU。
- Cosmetic viewed / equipped / purchased。
- Free-to-paid feature behavior。
- Gross margin and cost per meaningful session。

Pricing 與 willingness to pay 必須保持 unvalidated，直到使用者體驗 product value 後取得 evidence。

### Progression / gamification experiment metrics

若 beta 測試一個 low-cost mechanic：

- Exposure -> unlock -> equip / use rate。
- Meaningful D1 / D7 behavior relative to no-mechanic baseline where feasible。
- Trust、motivation、childishness、manipulation perception。
- Negative feedback、notification opt-out、dependency-language incidents。
- 是否提高 meaningful action，而不是只有 app opens 或 session time。

### Crash and performance

- Crash-free users / sessions。
- Cold / warm start time。
- Screen render and animation performance。
- LLM response latency P50 / P95。
- API error rate。
- Audio start latency / interruption。
- Memory usage / battery impact。
- Prompt format failure / fallback rate。

### Qualitative feedback

- 「有沒有感覺被理解？」
- 「哪一刻讓你第一次覺得 Twinko 有價值？」
- 「回覆是否自然、有幫助、不說教？」
- 「哪個 feature 最想再使用？」
- 「Twinko 比你原本使用的替代方案多了什麼，或少了什麼？」
- 「有沒有任何內容讓你不舒服、不信任或覺得被操控？」
- 「是否理解 Twinko 不是 therapist / prediction authority？」
- 「哪一種價值可能值得付費？為什麼？」
- Open-text plus session-context metadata。

### Data still required

- Primary segment behavior and willingness to use。
- Primary first-value moment。
- Current alternatives and switching triggers。
- Character layer contribution。
- Notification tolerance。
- Data-sharing comfort。
- Price sensitivity after product experience。
- Safety incident patterns。
- Content quality thresholds。
- Cost per active user / meaningful session。
- Meaningful retention baseline。
- One progression mechanic’s effectiveness and trust impact, only if tested。

## 13. Business Model

### Current status

Twinko 的 business model 仍是 hypothesis set；沒有 approved pricing、paywall timing、free quota、paid conversion expectation 或 willingness-to-pay conclusion。The detailed market / business / gamification supplement provides a decision framework, not validation。

### Current monetization hypotheses

1. **Freemium + subscription — leading hypothesis, not approved**
   - Free：足以證明 core value 的 limited experience。
   - Paid：higher limits、deeper personalization / user-approved memory、premium content 或 continuity。
2. **Trial + subscription — open hypothesis**
   - Economics 較簡單，但 early trust / adoption friction 較高。
3. **Cosmetic IAP — post-validation hypothesis**
   - Twinko skins、outfits、home decoration、seasonal themes。
4. **Premium content packs — post-launch hypothesis**
   - Meditation、tarot themes、stories 或 seasonal journeys。
5. **Partnership / branded content — post-validation hypothesis**
   - Illustrators、wellness creators、licensed content。
6. **Hybrid — longer-term only**
   - Functional subscription + expressive cosmetics + optional content packs；early complexity 最高。

### Monetization sequencing rule

不得只因 competitor 採 subscription 就直接選 subscription。Founder 應在以下 evidence 形成後才選 model：

1. Primary user wedge and recurring value are clear。
2. Product shows a meaningful retention signal。
3. Cost per meaningful session and free-user monthly cost are measured。
4. Willingness to pay is tested after actual product experience。
5. Free / paid boundary is ethically acceptable。
6. Gross-margin path is credible。

### Free vs paid principles

- Safety fallback、crisis exit、data controls 與必要 transparency 不可付費鎖定。
- 不在使用者高度脆弱或 crisis-like moment 使用 aggressive paywall。
- Free version 必須能讓使用者完整體驗核心價值，不能只是 empty shell。
- Paid value 應提升 depth、continuity、personalization、content 或 self-expression，而不是透過 emotional pressure 製造缺口。
- 不使用「Twinko 想你」「只有訂閱才能繼續被理解」等 guilt / dependency copy。
- Price、trial、renewal、cancellation 必須清楚。

### Cost drivers

- LLM inference、moderation、retry、memory context。
- Supabase compute、database、storage、bandwidth、edge functions。
- TTS、audio generation、music / content license、CDN。
- Apple developer / platform fees。
- Character、UI、motion、outfit / seasonal asset production。
- Tarot / astrology / meditation writing、review、localization。
- QA、monitoring、support、incident handling。
- Legal、privacy、terms、IP review。
- Creator / partnership and acquisition cost。

### Required unit economics

- Cost per active user and meaningful session。
- Cost per Chat session / average turns。
- Free-user and subscriber monthly variable cost。
- Gross margin after Apple and AI / backend costs。
- Cosmetic / content production cost vs purchase volume。
- Trial-to-paid、renewal、CAC and LTV，only after actual data exists。

### Partnership model

Potential partners：

- Illustrators / motion designers：original character and scalable assets。
- Tarot / astrology reviewers：content quality and non-deterministic framing。
- Meditation writers / voice talent：script / audio quality。
- Wellness / mental-health advisors：safety principles and review。
- Creators / micro-influencers：post-positioning beta acquisition。
- LLM / backend vendors：infrastructure。
- Lifestyle / wellness brands：post-validation content or seasonal collaboration。

**Partnership principle**：partners should strengthen product quality、trust 或 distribution；不應在 product value 尚未驗證前建立複雜 partnership network、承諾大規模聯名或形成 launch dependency。

### Risks and unknowns

- Users may enjoy novelty but not return or pay。
- Subscription fatigue。
- LLM cost may scale faster than revenue。
- Cosmetics require sustained art production and may have no value without relationship retention。
- Spiritual content may attract a niche but weaken broader trust。
- Pricing and willingness to pay may differ by market。
- Emotional companion monetization can create ethical concerns。
- No retention、paid conversion、competitor superiority、gamification effectiveness or gross-margin evidence exists yet。

## 14. Marketing and Launch

### Positioning

Working draft：

> Twinko 是一顆會陪你聊天、整理心情並帶你做小小反思的 AI 星星夥伴。

This is a concept-level positioning line。Final positioning must follow the primary wedge and first-value decision。

Avoid：

- 「治療憂鬱」。
- 「比心理師更懂你」。
- 「準確預測未來」。
- 「永遠不會離開你」。
- Any unsupported claim that Twinko is better than named competitors。

### Market validation before launch-channel scaling

Before committing to ASO、creator campaigns or broad audience content：

1. Interview users across the three candidate segments。
2. Test 2-3 positioning statements。
3. Compare candidate first-value concepts：Chat-first、Tarot-first、daily-insight-first、calming-first。
4. Document current alternatives and switching triggers。
5. Choose one primary wedge and one first-value promise。

### Target audience

- Initial founder hypothesis：18-35 young adults。
- Beachhead geography / language 未決。
- 「偏女性」曾作為 AI 建議，不視為 approved segment。
- Primary wedge must be decided before naming or broad audience targeting becomes the main workstream。

### Competitive research boundary

- Current research set：Replika、Character.AI、Woebot-like products、ChatGPT、Calm / Headspace、tarot / astrology apps、friends / journaling。
- Formal feature / pricing / review / positioning benchmark 尚未完成。
- Competitor price、market share、retention 或 superiority claims 必須附 current traceable sources before becoming canonical。

### App Store strategy

- 以角色與 selected first-value scenario 呈現，不列滿功能。
- Screenshots 取決於 v1 wedge；不預設四個 modules 都是同等 hero screens。
- 明確說明 AI、privacy、subscription、content nature。
- ASO keywords 需透過實際 research 決定。
- App category、age rating、review notes 尚未定義。

### Launch channels

Candidate：

- TestFlight waitlist。
- Founder network。
- IG / TikTok short-form content。
- Relevant micro-creators after segment / positioning choice。
- Product-building / indie maker content。
- App Store organic。
- Selected communities，避免大量 cold-start community ops。

### Content strategy

- Twinko 的短問候、情緒 scenario、角色動畫。
- Tarot / astrology 作 reflection content，不做恐嚇式運勢。
- Behind-the-scenes research、design / build and learning。
- Beta learnings and founder story。
- User quotes only with explicit permission and anonymization。

### Community and partnerships

Post-validation candidates：

- Illustrators / motion designers。
- Meditation writers / voice talent。
- Tarot / astrology domain reviewers。
- Wellness / safety advisors。
- Creators / micro-influencers。
- Lifestyle / wellness brands after product evidence。

Partnerships are not a substitute for product validation and must not become a pre-beta dependency unless required for safety, rights or launch-critical quality。

### Launch experiments

- Landing-page positioning / concept test。
- Waitlist message test。
- Primary first-value prototype comparison。
- Notification opt-in timing only after return hypothesis exists。
- Free-usage boundary only after core value is experienced。
- Beta cohort by primary need。
- At most one low-cost progression experiment；no complex gamification economy。

### Feedback collection

- In-app lightweight feedback。
- Session-level thumbs / reason。
- Structured beta survey。
- 1:1 interviews with activated and non-returning users。
- App Store review monitoring after public launch。
- Safety incident reporting path。

### Post-launch loop

1. Collect events / feedback / bugs / costs。
2. PM Workflow generates evidence-linked weekly summary。
3. Founder reviews metric + qualitative evidence。
4. Update decision log and prioritization。
5. Ship small changes。
6. Compare cohort behavior without overclaiming causality。
7. Maintain changelog and learning record。

## 15. Legal, Privacy, and App Store Requirements

> 本節是 issue inventory，不是 legal advice。所有正式 policy、terms、subscription wording、mental-health claims、cross-border data 與 App Store submission 應在 launch 前依當時法規與 Apple current requirements 進行專業或 qualified review。

### Privacy policy

Likely needs：

- 收集哪些資料：name、birth information、chat content、preferences、usage、device / diagnostics、payment status。
- 每項資料的 purpose。
- LLM / Supabase / analytics 等 processors。
- Retention and deletion。
- User access / correction / deletion rights。
- Cross-border processing。
- Contact and policy updates。
- Sensitive emotional content handling。

**Professional review recommended / required before public launch。**

### Terms of use

- AI nature and limitation。
- No medical / legal / financial advice。
- Fortune-telling for entertainment / reflection。
- Acceptable use。
- Account responsibility。
- Content ownership and license。
- Subscription / cancellation。
- Disclaimer and limitation of liability。
- Service changes / termination。
- Governing law / jurisdiction。

**Professional legal review required。**

### App Store disclosures

Need current submission-time validation for：

- App privacy details。
- Data types and tracking。
- AI / user-generated content behavior。
- Subscription products and paywall copy。
- Account deletion if accounts exist。
- Sign-in method requirements。
- Age rating。
- Review notes / demo account。
- Third-party SDK disclosures / privacy manifests where applicable。

### Analytics and tracking consent

- First-party product analytics should be data-minimized。
- Any cross-app / advertising tracking must be separately evaluated。
- Consent / opt-out rules depend on tool and jurisdiction。
- Do not collect chat text into analytics by default。

### User data

- Encrypt in transit and at rest through qualified services。
- Secrets never stored client-side。
- RLS / access-control testing。
- Separate operational logs from message content。
- Define deletion, export and retention。
- Avoid collecting birth time / location unless feature requires it。
- High-risk content logging needs strict access and retention control。

### Intellectual property

- Twinko character、logo、assets must be original or properly licensed。
- Disney《Soul》只能作 mood reference，不能模仿受保護角色 / style elements。
- Tarot card art, music, ambient sound, fonts, animation libraries, icons require clear commercial license。
- AI-generated assets require tool terms review and provenance record。

### Third-party content and vendors

- LLM provider terms、data use and retention。
- Supabase terms / DPA where relevant。
- Analytics SDK。
- TTS / audio provider。
- Animation asset marketplace。
- Tarot / astrology content source。
- All vendor changes recorded in dependency register。

### Subscriptions and payments

- Use platform-compliant in-app purchase for digital goods / subscriptions。
- Clearly disclose price, billing period, auto-renewal, trial and cancellation path。
- Restore purchases / entitlement sync。
- Avoid manipulative paywall around emotional distress。
- Tax / accounting implications require operations review。

### UGC / community

Not launch-critical. If added later：

- Moderation。
- Reporting / blocking。
- Abuse / harassment policy。
- CSAM / illegal content procedures。
- Age restrictions。
- Human operations capacity。

### Age and geography

- Historical target is 18-35, but age gate policy not set。
- Launching for minors would significantly increase privacy and safety obligations；not recommended until intentionally designed。
- Crisis resources, terms and data requirements vary by geography。

### Professional review list

- Privacy policy and terms。
- Mental-health / wellness claims。
- Crisis / safety language。
- Subscription / refund wording。
- Cross-border data processing。
- IP / licensing。
- Minor access。
- UGC if introduced。
- Influencer / endorsement and marketing claims where applicable。

---

## 16. AI-Native PM Workflow Dogfooding Plan

### Objective

Use Twinko as a real product operating environment to test whether the PM Workflow can reduce manual consolidation, improve decision traceability, surface risk earlier and generate decision-ready artifacts without removing human accountability。

### Immediate bounded slice：Discovery-to-Decision

The first dogfood implementation should **not** attempt to automate the entire Twinko lifecycle。Its immediate scope is one closed loop：

1. **Discovery question intake**
   - Primary user wedge。
   - Primary first-value moment。
   - Current alternatives / switching triggers。
   - Character layer value。
2. **Evidence ingestion**
   - Interview notes / transcripts。
   - Concept-test responses。
   - Competitor observations with source links。
   - Founder assumptions and hypotheses。
3. **Evidence classification**
   - Confirmed observation。
   - Participant statement。
   - Founder assumption。
   - AI inference。
   - Conflict / gap。
4. **Synthesis**
   - Segment evidence matrix。
   - JTBD / problem pattern summary。
   - First-value option comparison。
   - Risks and unanswered questions。
5. **Decision preparation**
   - Decision memo with options、tradeoffs、confidence and recommendation。
   - Founder approval / rejection / defer status。
6. **Operational update**
   - Update decision log、product brief、backlog、risk register and next experiment。

### Discovery-to-Decision inputs

- Research plan and interview guide。
- Participant profile and segment tag。
- Interview notes / verbatim quotes with consent rules。
- Current alternative and behavior evidence。
- Concept / prototype shown。
- Evidence source、date、owner and confidence。
- Market / business / gamification hypotheses from the domain supplement。

### Discovery-to-Decision outputs

- Research evidence repository。
- Problem / JTBD pattern map。
- Primary wedge decision memo。
- First-value moment decision memo。
- Updated assumption register。
- Updated decision log and risk register。
- Prioritized next experiment / scope recommendation。
- Weekly founder update explaining what changed and why。

### Success evidence for this slice

- Founder can trace each recommendation to source evidence。
- Conflicting evidence remains visible rather than silently merged。
- Time to synthesize research and update documents decreases。
- Decision confidence and unresolved gaps are explicit。
- Product naming、scope and design work are sequenced after wedge / first value rather than driving them。
- The workflow does not label interviews or competitor observations as market validation beyond their actual sample and method。

### Later lifecycle inputs

#### Product and business

- Product brief / PRDs。
- Roadmap / backlog。
- Business model hypotheses。
- Pricing and unit-economics experiments。
- Decision records and open questions。

#### Design

- Figma links / component status。
- Screen review screenshots。
- Design changes。
- Accessibility checklist。
- Asset / license status。
- UX writing changes。

#### Engineering

- GitHub issues / PRs / commits。
- Build status and tests。
- Architecture decisions。
- Supabase migrations / schema status。
- Bugs / crash / performance signals。
- Dependency changes。

#### Launch and operations

- Launch criteria。
- App Store checklist。
- Legal / privacy readiness。
- TestFlight feedback。
- Release notes and support issues。

#### User and performance

- Beta surveys and session feedback。
- Analytics and retention signals。
- Subscription / cost data。
- Gamification experiment data。
- Safety incidents。

### Required data contract

Each input should carry where practical：

- ID。
- Type。
- Source link。
- Owner。
- Status。
- Created / updated date。
- Related segment / feature / decision / release。
- Confidence or evidence level。
- Decision / risk linkage。
- Sensitive-data classification。

### Full-lifecycle expected outputs

- Product dashboard。
- Roadmap and feature backlog。
- Decision log and risk register。
- Research / evidence repository。
- Design and engineering status。
- Launch-readiness report。
- Weekly founder update。
- Beta feedback synthesis。
- Post-launch performance and unit-economics report。
- Change / learning log。

### Human governance

- Workflow may summarize、classify、flag、suggest and draft。
- Founder approves wedge、first value、scope、priority、commercial model、release、claim and risk acceptance。
- Agents cannot mark market validation、legal / safety readiness、retention success or gamification effectiveness complete without evidence。
- Generated artifacts must link back to source evidence。

### Dogfooding risks

- Building workflow integration may distract from Twinko discovery / build。
- Poor data hygiene may create misleading synthesis。
- Automated status can be falsely confident。
- Sensitive interview or future user content must not be broadly ingested。
- Start manual / semi-structured；automate only repeated, high-value steps after usefulness is demonstrated。

## 17. Product Risks and Dependencies

| Category | Risk | Impact | Mitigation / decision needed |
|---|---|---|---|
| Product | Primary wedge remains broad / unresolved | Weak activation, confusing scope and positioning | Validate one segment and first-value moment before naming / full design / build |
| Product | Too many feature pillars dilute the wedge | Weak activation and confusing positioning | Treat non-primary features as supporting or deferred modules |
| Product | Character novelty without durable value | Short-lived usage | Test value articulation, return intent and meaningful retention, not only visual preference |
| Market | Competitor superiority is assumed without benchmark | Misleading positioning and bad investment decisions | Maintain working competitor set; use traceable current research and user evidence |
| User | Emotional dependency or manipulation | Trust / safety harm | No guilt, exclusivity, absence punishment or distress paywall; easy notification controls |
| User | Harmful response in crisis or sensitive advice | Severe user and legal risk | Safety policy, test set, fallback, resource routing, incident process |
| Design | Twinko visual quality is not distinctive | Brand fails | Original character exploration and user test before full asset production |
| Design | “Soul-like” direction creates IP / imitation risk | Rework / legal concern | Translate into abstract principles and original art direction |
| Engineering | Non-technical founder relies on AI-generated code | Maintainability / security risk | Small PRs, tests, independent review, documented architecture |
| Engineering | LLM output variability | Product inconsistency | Structured outputs, versioned prompts, regression evals |
| Engineering | Native animation scope | Timeline and performance risk | Technical spike, signature motion only for v1, Reduce Motion |
| Engineering | Supabase / RLS misconfiguration | Data exposure | Architecture review, policy tests, separate environments |
| Engineering | LLM cost / latency | Poor UX and economics | Provider benchmark, caching, limits, fallback, cost-per-session tracking |
| Timeline | Scope creep | Missed beta | Gate-based scope control; complex gamification, music and community remain deferred |
| Gamification | Progression mechanics are assumed to improve retention | Rework, low trust or vanity engagement | Beta tests no more than one low-cost mechanic; measure meaningful actions and qualitative trust |
| Gamification | Reward mechanics trivialize emotional moments | Brand and trust damage | Gentle acknowledgement only; no guilt, punishment, opaque odds or false clinical progress |
| Legal | Sensitive emotional data / claims | Compliance and trust risk | Data minimization, legal review, no clinical claims |
| Legal | Third-party art / music / fonts | Takedown / rejection | License register and provenance |
| Marketing | Broad 18-35 audience | Inefficient acquisition | Choose beachhead from research before scaling channels |
| Business model | No validated willingness to pay or retention | Unsustainable model | Delay pricing / paywall until product experience, retention signal and WTP research |
| Business model | Unknown unit economics | Negative gross margin | Measure LLM, backend, Apple, content and support cost per meaningful session |
| Partnership | Early partnerships create dependency before product validation | Delays and contractual / IP complexity | Use partners only for critical quality, trust or rights; defer broad collaboration network |
| PM Workflow | Dogfooding becomes parallel product build | Focus loss | Limit current scope to Discovery-to-Decision and evidence-linked outputs |
| External services | Apple, LLM, Supabase or TTS changes | Release or cost impact | Vendor abstraction, dependency register, contingency |
| Content | Astrology / tarot content quality or repetition | Low trust | Domain review, content versioning, user feedback |
| Operations | Founder capacity | Slow iteration | Explicit weekly priority, scope gates and buffer |

## 18. Decisions Already Made

| Decision | Rationale | Source / sequence | Confidence | Reversible? |
|---|---|---|---|---|
| Twinko is intended as a real commercial product, not only portfolio prototype | Public launch and real user learning are required | Current consolidation directive, latest | High | Strategic direction: low reversibility |
| iOS-first native experience | Quality, animation and maintainability are strategic goals | Current consolidation directive | High | Medium |
| Twinko is a cute star companion | Central emotional and visual identity | Original project brief | High | Character type change would be costly |
| Core concept combines companionship with reflection / wellness features | Differentiates conceptually from generic chat | Original project brief | Medium-high; differentiation unvalidated | Product bundle can be narrowed |
| Primary user wedge and first-value moment are the immediate gating decisions | They determine positioning, onboarding, scope, metrics and research; naming should follow | Incremental reconciliation | High prioritization; specific answers pending | Yes |
| Product should not over-expand first release | Founder needs executable scope | Current directive | High | Yes |
| Complex gamification is not launch-critical | Core emotional / reflective value must be proven first | Market / business / gamification supplement | High scope principle | Yes later |
| Beta may test no more than one low-cost progression mechanic | Limits confounding, art scope and manipulation risk | Market / business / gamification supplement | High | Yes |
| Monetization and pricing remain hypotheses until retention, WTP and unit economics exist | Avoids copying competitors or monetizing unproven value | Supplement + current operating brief | High principle | Model remains reversible |
| Safety support and ethical exit paths cannot be aggressively paywalled | Emotional companion monetization must not exploit distress | Supplement trust principles | High | Low reversibility as trust principle |
| AI-Native PM Workflow will use Twinko as first dogfooding case | Prove workflow on actual product lifecycle | Current directive | High | Medium |
| Immediate PM Workflow dogfood scope is Discovery-to-Decision | Keeps workflow useful and bounded before engineering automation | Incremental reconciliation | High | Yes |
| GitHub is source control | Needed for engineering traceability | Current working tool stack | Medium-high | Yes |
| Swift / SwiftUI / Xcode are current implementation direction | Native iOS strategy | Current working tool stack | Medium | Yes, before build lock |
| Claude Code + Fable and Cursor are current build tools | AI-assisted implementation for solo founder | Current working tool stack | Medium | Yes |
| Supabase is backend working direction, pending validation | Consolidated auth / DB / storage | Current working tool stack | Medium | Yes |
| Independent coding review is required | Reduce AI-code risk | Current working tool stack | High principle; tool reversible |
| Music is not clearly launch-critical | Later plans consistently focused on Chat / Tarot / Astrology / Meditation | Later task planning | Medium | Yes |
| Historical no-code-first plan is no longer primary commercial architecture | Latest native iOS direction supersedes it | Sequence conflict resolved by latest directive | High | Yes |
| Initial target is 18-35 young adults | Founder-defined starting audience | Original brief | Medium; too broad for execution | Yes after research |
| Partnerships should support critical quality, trust or distribution rather than become pre-validation dependencies | Avoids complexity and commitments before product evidence | Domain supplement | Medium-high | Yes |

## 19. Open Decisions

| Priority | Question | Why it matters | Options already discussed | Information needed | Recommended deadline |
|---|---|---|---|---|---|
| 1 | What is the primary user wedge? | Determines problem definition, research sample, positioning and scope | Emotional companionship、spiritual reflection、short calming | Interviews, behavior / alternatives, concept response | Discovery-to-Decision Gate |
| 2 | What is the primary first-value moment? | Determines onboarding, hero flow, activation and build sequence | Chat response、tarot reflection、daily insight、calming session | Prototype / concept test, value articulation, return intent | Discovery-to-Decision Gate |
| 3 | Does an integrated multi-feature concept outperform a narrower wedge? | Controls scope and messaging | Four-module experience vs one primary flow with supporting modules | User testing and tradeoff analysis | Before v1 scope freeze |
| 4 | Launch market and language? | Content, safety, legal, ASO and recruitment | Taiwan Chinese、broader Traditional Chinese、bilingual | User access, market / competitor research | Before content production |
| 5 | Exact v1 scope? | Controls timeline and architecture | Four core features vs narrower vertical slice | Wedge decision, effort estimates, prototype test | Before sprint planning |
| 6 | Product / App Store name：Twinko or TwinkoTalk? | Brand, domain, App Store search and legal | Twinko character + TwinkoTalk app | Wedge / positioning, trademark / name search | After wedge / first value; before visual identity lock |
| 7 | Is Music in v1? | Audio pipeline and rights add scope | Include / defer | User value, licensing, engineering | Before design freeze |
| 8 | Auth model? | Friction, persistence, Apple submission | Anonymous、Apple、email | Data needs and compliance | Technical validation gate |
| 9 | What birth data is required? | Privacy and astrology depth | Date only、time / location | Selected astrology scope | Before onboarding design |
| 10 | Which LLM provider / model? | Quality, cost, latency, privacy | Not yet selected | Chinese benchmark, safety, unit cost | Technical spike |
| 11 | Memory depth and retention policy? | Personalization vs privacy | No memory、approved summaries、full history | User trust research, data model | Before Chat build |
| 12 | Safety / crisis policy? | Highest trust risk | Rule-based + model + static resources | Professional review and test cases | Before beta |
| 13 | Tarot / astrology content source? | Quality and IP | Human-authored、AI-assisted、licensed | Domain review, rights | Before content import |
| 14 | Notification strategy? | Return loop vs annoyance | Local daily、remote personalized、none at first | User preference test | Before beta |
| 15 | Is any gamification needed in beta? | Could add delight or distract from core value | None、one outfit unlock、simple milestone | Core-flow stability, experiment design | Before beta scope lock |
| 16 | What counts as meaningful progression? | Prevents vanity mechanics | Relationship acknowledgement、reflection history、calm completion、cosmetic unlock | User feedback and ethical review | Before progression experiment |
| 17 | Monetization model and pricing? | Business viability | Freemium、subscription、IAP、content packs、hybrid | Retention, WTP after experience, unit economics | After early retention signal; before public launch |
| 18 | Maximum acceptable cost per meaningful session? | Determines free quota, model choice and margin | To be calculated | LLM / backend benchmark and usage pattern | Before monetization decision |
| 19 | Which partnerships are launch-critical? | Partners can improve quality but create dependency | Design、domain review、safety、creator、brand | Capability gaps, IP and cost | Before contracting |
| 20 | Analytics vendor? | Decision quality and privacy | Vendor options not approved | SDK / privacy / cost evaluation | Before beta instrumentation |
| 21 | Animation stack? | Design quality, effort, performance | SwiftUI native、Rive / Lottie、SpriteKit | Technical prototype | Before motion production |
| 22 | Beta cohort size and recruitment? | Quality of evidence | Earlier plan mentioned first 50 testers | Target segment access, support capacity | Before external TestFlight |
| 23 | Launch success criteria? | Prevents subjective go / no-go | Activation、D7 signal、crash、safety、trust、cost | Beta baseline | Before beta start |
| 24 | How will later PM Workflow ingestion work? | Dogfooding beyond discovery | Manual links、GitHub connector、API | Discovery-slice learning, workflow capability, privacy | Build preparation |
| 25 | Legal counsel / review budget? | Public launch readiness | TBD | Jurisdiction, budget, vendors | Before external beta / public launch |
| 26 | Subscription entitlement tool? | Payment reliability | StoreKit native / supporting service | Architecture and ops evaluation | Before paywall build |

## 20. Immediate Execution Sequence

### 1. Market / problem validation

- Treat the domain supplement as a hypothesis inventory, not validation。
- Define three candidate wedges and candidate first-value moments。
- Interview 5-10 relevant users across the candidate segments。
- Capture current alternatives, trigger moments, behavior, trust concerns and switching criteria。
- Run lightweight positioning / concept comparison。

### 2. Discovery-to-Decision PM Workflow dogfood slice

- Ingest research questions、interview evidence、competitor observations and assumptions。
- Separate observation、participant statement、founder hypothesis、AI inference and gap。
- Generate segment evidence matrix and first-value option comparison。
- Produce founder decision memo with confidence and unresolved risks。
- After founder decision, update operating brief、decision log、risk register and backlog。

### 3. Founder product decisions

Decision order：

1. Primary user wedge。
2. Primary first-value moment。
3. Launch market / language。
4. v1 scope and explicit deferrals。
5. Naming and visual identity lock。

### 4. UX definition

- Map onboarding -> selected first value -> recurring loop。
- Create low-fidelity flow and screen inventory。
- Define Twinko personality, states and UX writing principles。
- Test prototype for clarity、warmth、trust and return intent。
- Lock original art direction without copying reference brands。

### 5. Business / experiment definition

- Create unit-economics skeleton and provider cost assumptions。
- Keep pricing and WTP unvalidated until product experience exists。
- Define ethical free / paid principles。
- Decide whether beta includes no progression mechanic or one low-cost experiment。
- Identify only launch-critical partners for safety、rights or missing capability。

### 6. Technical validation

Run time-boxed spikes：

- SwiftUI project and navigation。
- Supabase auth / RLS / data read-write。
- LLM backend proxy and structured output。
- One Twinko motion prototype。
- Audio playback / background behavior only if selected primary flow needs it。
- Benchmark model quality, latency and cost。
- Document architecture decisions and risks。

### 7. Build preparation

- Create GitHub repository, environments and branch rules。
- Set issue / PR templates and acceptance-criteria format。
- Create design tokens and SwiftUI component skeleton。
- Define schema、analytics events、prompt versioning and test datasets。
- Expand PM Workflow from Discovery-to-Decision only after that slice proves useful。

### 8. Development

Build vertical slices in the order determined by the selected first-value flow：

1. Onboarding + Home + one Twinko state。
2. Primary flow end-to-end with safety and analytics。
3. Only the highest-value supporting flow(s)。
4. Settings / privacy / feedback。
5. Notification, additional motion and one progression experiment only after core stability。

### 9. QA

- Unit / integration / UI / prompt tests。
- Screenshot and accessibility review。
- Real-device performance。
- Safety red-team cases。
- Data deletion / auth / network failure。
- Bug severity and launch-blocker review。

### 10. Legal and App Store readiness

- Data-flow map。
- Privacy policy / terms。
- Rights and license register。
- App privacy / disclosure draft。
- Subscription copy only if a model is approved。
- Age rating、support and deletion flow。
- Validate against current Apple requirements。

### 11. Launch and learning

- Internal TestFlight -> small external beta。
- Evaluate first-value completion、qualitative trust、meaningful return、cost and safety。
- If one progression mechanic is tested, evaluate it separately and do not infer causality from app opens alone。
- Decide whether to widen beta, narrow scope or change wedge。
- Pricing and complex gamification remain post-evidence decisions。

## 21. Sequencing Amendment — 2026-07-12

> This is an additive amendment. §16 (AI-Native PM Workflow Dogfooding Plan) and §20 (Immediate Execution Sequence) above remain unchanged and continue to describe valid product-gating logic and build-readiness guidance. This section records how company-level execution sequencing has changed since those sections were written; it does not alter product truth。

The original Discovery-first gating logic in §16 and §20 — primary user wedge validation, primary first-value moment validation, safety boundaries, and the Discovery-to-Decision PM Workflow slice — remains valid product strategy and build-readiness guidance。It has not been rejected, invalidated, or superseded as product logic。

**Studio Decision 0006** (Fast-Track Product Delivery, Chairwoman Approved, 2026-07-12) temporarily reprioritized active company execution：PM Workflow Control Tower became the primary active priority, the Twinko iOS UI prototype became the secondary active priority, and Twinko Discovery-to-Decision together with PM Workflow dogfooding were deferred until both prototypes are ready。Decision 0006 was explicit that this is a sequencing decision, not a rejection of Twinko's product-gating logic, and that it does not decide wedge, first-value moment, naming, or scope freeze。

**Studio Decision 0007** (One-Person Company OS v1.0 Reprioritization, Chairwoman Approved, 2026-07-12) later superseded only the active-priority sequencing in Decision 0006 §§1–2。One-Person Company OS v1.0 is now the primary active company milestone。PM Workflow Control Tower work is paused, after preservation, rather than continued。The Twinko UI prototype remains deferred until the One-Person Company OS v1.0 milestone is complete。Twinko Discovery-to-Decision and PM Workflow dogfooding remain deferred, not rejected or superseded。

**Current status**：Twinko implementation and discovery work are currently deferred at the company-execution level。Deferred does not mean rejected, invalidated, or superseded — the product-gating logic above remains the standing guidance for when work resumes。The Product Definition Sprint, and any resumption of Discovery-to-Decision, may begin only after an explicit new company- or venture-level milestone authorization is recorded in Studio governance。

Basis：Studio Decision 0006 (`decisions/approvals/0006-fast-track-product-delivery.md`) and Decision 0007 (`decisions/approvals/0007-one-person-company-os-v1-reprioritization.md`)。

## 22. Full Interactive Prototype and Home Screen Amendment — 2026-07-14

> This is an additive amendment. It does not delete or rewrite any text in §1–§21 above. Where a passage below narrows, extends, or updates a specific statement in an earlier section, that earlier statement remains as historical record; this section states what currently controls implementation. §21's Sequencing Amendment logic (deferred, not rejected) is unaffected outside the scope this section describes.

### Governing basis

- **D-054** ("Twinko Full Interactive Local Prototype") authorized building and evaluating the complete integrated local prototype — Welcome, Profile Setup, Home Menu, Chat with local Chat History, Tarot, and a local daily Astrology screen — as a fully local, deterministic, reversible experience-evaluation vehicle.
- **D-055** ("Home UI v1") subsequently adopted a founder-approved Home Screen Specification and Asset Manifest (`docs/ux/TWINKO_HOME_SCREEN_SPEC_V1.md`, `docs/ux/TWINKO_HOME_ASSET_MANIFEST_V1.md`) as the controlling specification for the Home screen specifically, except that `Log Out` is excluded because no authentication or account system exists.

### Interpretation that applies across this document

- **The full integrated prototype may be built and evaluated before final primary-wedge validation.** §1's "Immediate product gating priority" and §16/§20's Discovery-first sequencing remain valid *product strategy and v1-scope guidance* — they are not rejected — but D-054/D-055 record that building and evaluating the integrated prototype (§6 Core User Journey's four candidate first-value moments implemented side by side, §7's four launch-feature candidates implemented together) does not itself require the wedge decision to be made first. §7's "Still undecided: Primary wedge, primary first-value flow, exact v1 feature set" remains accurate for **v1/launch scope**.
- **This does not convert prototype scope into validated v1 scope.** Nothing in D-054 or D-055 resolves §19 Open Decision #1 (primary user wedge), #2 (primary first-value moment), #3 (whether an integrated concept outperforms a narrower wedge), or #5 (exact v1 scope). Prototype feature inclusion — Chat, Tarot, Zodiac, Meditate, Music all present on Home — does not prove primary wedge, market validation, equal strategic priority, retention, or final v1 scope.
- **The approved Home experience is bilingual.** §8's "Chinese / English typography" (listed under "Areas still needing definition") is now resolved for the Home screen specifically: English and Traditional Chinese are developed and tested in parallel, per D-055.
- **Meditate and Music are placeholder-navigation entries on Home**, not the "即將推出"/disabled treatment referenced in the D-054 Current Status amendment. They are tappable and open minimal local placeholder pages with working back navigation, no fake feature implementation, and no audio player or mock service (D-055). §7's "Post-launch scope" listing of Music remains accurate for final v1/launch scope — placeholder navigation is prototype-only.
- **Home uses the founder-approved assets and 2–2–1 layout.** §8's "Areas still needing definition" list ("Final logo, character silhouette... Home layout and navigation") is now resolved for the Home screen: fixed background (`home_screen_v1.png`), canonical central character (`twinko_default_smile_v1.png`), five circular mode icons in a 2–2–1 orbit around Twinko (Chat/Tarot top pair, Zodiac/Meditate lower pair, Music bottom-center).
- **Final product naming remains unresolved.** §19 Open Decision #6 ("Product / App Store name: Twinko or TwinkoTalk?") is unchanged. D-055 additionally requires that Home display no product wordmark at all (`Twinko`, `TwinkoTalk`, or otherwise) — this is a stricter Home-specific constraint, not a naming decision.
- **No auth, logout, backend, live AI, beta, release, or production work is authorized.** §10's technical-architecture "Recommended data entities," "Authentication," and "Backend" subsections remain unvalidated working direction only; D-054 and D-055 are strictly local-prototype authorizations and do not activate any of §10's Supabase/backend/auth direction, §12's analytics event taxonomy, §13's monetization hypotheses, or §14/§15's launch/legal readiness items.

### Section-by-section notes

- **§1 Executive Summary** — "Current product stage" is refined for engineering only: a local, non-network SwiftUI codebase implementing the full prototype scope now exists (superseding "尚未確認有可持續開發的正式 SwiftUI codebase"). This is engineering-baseline fact, not a change to market/commercial evidence status, which remains as stated.
- **§6 Core User Journey** — Step 3 (Onboarding) and Step 4 (First value moment) are now implemented as a working local prototype (Welcome → Profile Setup → Home → any of the four candidate flows), but the "Open decisions" and "must select one primary first-value moment" language remains accurate for v1; the prototype implements all four candidates side by side precisely so they can be evaluated, not because the selection question is resolved.
- **§7 Product Scope** — "Launch-critical working set," "Still undecided," and the feature-detail table are unchanged for v1/launch purposes. Add: a local, non-production prototype instance of every "Launch feature detail" row except Safety/Fallback's full policy and Beta Release now exists for evaluation purposes only.
- **§8 UI, UX, and Brand Direction** — "Navigation structure" candidate is refined for Home specifically: Home-first with a single top-right Profile control opening a bottom sheet (Profile / Settings / Privacy; Settings contains Language), per D-055 §10–§11. "Key screens" gains: Home now has a founder-approved fixed visual specification (§8 "Areas still needing definition" is resolved for Home layout, character asset, and icon set only — logo, outfit system, dark/light mode, and audio identity remain undecided).
- **§9 Motion and Animation Direction** — "Signature interactions" and "Consistency rules" gain a concrete instance: Home's Twinko idle motion (floating 4–6pt over 3.5–4.5s, subtle breathing glow, 1.0→1.015→1.0 scale, with a static low-intensity Reduce-Motion fallback) and mode-icon tap feedback (0.94–0.96 press scale, 120–180ms) are now founder-approved per D-055, consistent with this section's existing accessibility and consistency principles.
- **§18 Decisions Already Made** — Add (without rewriting existing rows): "The full local interactive prototype (Chat, Chat History, Tarot, Astrology, Home) may be built for experience evaluation before primary-wedge validation is complete" (D-054); "The Home screen uses a founder-approved fixed visual specification and asset set, bilingual from the start, with no product wordmark displayed" (D-055).
- **§19 Open Decisions** — Every row remains open exactly as recorded. Clarification: none of these are resolved or narrowed by D-054/D-055 except as noted above (Home layout/assets, Home bilingual scope). In particular #1, #2, #3, #5, and #6 remain fully open.
- **§20 Immediate Execution Sequence** — Step "4. UX definition" gains a concrete precedent: the Home screen's low-fidelity-to-approved-visual cycle (steps "Map onboarding → selected first value → recurring loop," "Create low-fidelity flow and screen inventory," "Lock original art direction") has now happened once, for Home only, via the founder-approved D-055 package — this does not mean the equivalent work is done for Chat, Tarot, or Astrology's final production visual direction, nor does it substitute for step "3. Founder product decisions" (wedge, first-value moment, market/language, v1 scope, naming lock), which remain open.

### Home/Profile refinement note — 2026-07-14 (additive)

Within the D-055 Home scope, a founder-directed refinement pass is authorized and implemented: a larger central Twinko with layered glow and gentle idle motion (Reduce Motion supported), a tightened 2–2–1 cluster, a temporary founder-approved native-SwiftUI "profile planet" control (no PNG asset exists), and a branded Profile bottom sheet (header with name/zodiac/Edit; custom rows for Profile / Settings / Privacy; Settings contains Language only; no Log Out). Profile edits (name, birthday, gender; zodiac auto-derived) persist through the existing local JSON store. Temporary vector icons and the procedural Twinko remain until valid transparent assets exist. No product naming, live AI, backend, auth, cloud, analytics, payment, beta, or release decision changes.

Basis：`docs/product/TWINKO_DECISION_LOG.md`（D-054, D-055）、`docs/ux/TWINKO_HOME_SCREEN_SPEC_V1.md`、`docs/ux/TWINKO_HOME_ASSET_MANIFEST_V1.md`。
