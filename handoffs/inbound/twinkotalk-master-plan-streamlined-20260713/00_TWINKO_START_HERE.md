# 00_TWINKO_START_HERE

> Project: **TwinkoTalk**  
> Character: **Twinko**  
> Status date: **2026-07-13**  
> Current phase: **Prototype definition locked; documentation and production preparation**  
> Package model: **streamlined source of truth** — domain content is integrated by purpose, not maintained as parallel strategy files.  
> Scope: business, market, product, development planning, trust/safety/legal, and project governance. Detailed software architecture and coding implementation discussions are intentionally excluded.

## 1. Current Product Direction

TwinkoTalk is a **character-first AI companion app** centered on Twinko, a warm, glowing yellow star. The product is intended to give users a low-pressure place to talk, reflect, and return for small daily rituals.

The current operating strategy is:

- Consumer AI companion first.
- Non-medical and non-clinical.
- Traditional Chinese first; English later.
- Prototype before market-validation claims.
- Twinko is the product center; Chat, Tarot, and Astrology are companion modes rather than unrelated tools.

## 2. Current Prototype Scope

### Active prototype modes

- **Chat** — warm, scripted / mocked conversation experience with real local chat history.
- **Tarot** — mysterious, ritual-based experience with single-card and three-card readings.
- **Astrology** — sun-sign daily insights with love, career, finance, lucky number, lucky color, lucky sign, and lucky item.

### Supporting prototype screens

- Welcome page.
- First-time profile setup with name, birthday, and gender.
- Home / Menu centered on Twinko.
- Meditation and Music visible as disabled / coming-soon modes.

### Explicitly not in the prototype

- Live LLM.
- Apple / Google authentication.
- Long-term AI memory.
- Meditation or Music flows.
- Gamification economy, feeding, levels, relationship score, or outfit unlocking.
- Push notifications.
- Payments.
- Offline activity marketplace.
- Advanced astrology compatibility.

## 3. Five Information Buckets

All project knowledge is still organized into five conceptual buckets, but the files are organized by **use**, not by chat or bucket:

1. **Business & Venture Strategy** — integrated into the Product Operating Brief and Decision Log.
2. **Market, Brand & Growth** — integrated into the Product Operating Brief, Brand Guide, and Decision Log.
3. **Product Strategy & Experience** — integrated into the Product Operating Brief, Prototype PRD, Feature Backlog, Brand Guide, and Content Spec.
4. **Development & Product Operations** — integrated into Current Status, Prototype PRD, Screen Inventory, QA Checklist, and Decision Log.
5. **Trust, Safety, Legal & Governance** — maintained in the dedicated Trust/Safety/Legal file and reflected in the Operating Brief, PRD, QA, and Decision Log.

## 4. Active Source-of-Truth Structure

### Entry point

1. `00_TWINKO_START_HERE.md`

### Canonical truth

2. `01_CANONICAL/TWINKO_PRODUCT_OPERATING_BRIEF.md`  
   Full product, business, market, brand, product-experience, gamification, evidence-gap, and strategic detail.
3. `01_CANONICAL/TWINKO_DECISION_LOG.md`  
   Approved, working, pending, deferred, superseded, and evidence-status decisions.
4. `01_CANONICAL/TWINKO_CURRENT_STATUS.md`  
   Current stage, work completed, blockers, next priorities, milestone, and integrated product-operations model.
5. `01_CANONICAL/TWINKO_VENTURE_STUDIO_HANDOFF.md`  
   Concise restart and cross-venture handoff.

### Product execution

6. `02_PRODUCT_EXECUTION/TWINKOTALK_PROTOTYPE_PRD.md`
7. `02_PRODUCT_EXECUTION/TWINKOTALK_FEATURE_BACKLOG.md`
8. `02_PRODUCT_EXECUTION/TWINKOTALK_BRAND_CHARACTER_GUIDE.md`
9. `02_PRODUCT_EXECUTION/TWINKOTALK_CONTENT_SPEC.md`
10. `02_PRODUCT_EXECUTION/TWINKOTALK_SCREEN_INVENTORY.md`
11. `02_PRODUCT_EXECUTION/TWINKOTALK_PROTOTYPE_QA_CHECKLIST.md`

### Trust / governance

12. `03_TRUST_GOVERNANCE/TWINKOTALK_TRUST_SAFETY_LEGAL_GOVERNANCE.md`

### References only

Everything under `04_REFERENCES/` is provenance, source material, historical governance, archived generated drafts, or visual reference. These files **do not override** canonical decisions.

When two active files conflict, the latest explicit founder decision in the Decision Log takes priority.

## 5. Why There Are No Active Market / Business / Gamification Strategy Files

The earlier package incorrectly created parallel active domain documents. Their full content has now been integrated into:

- Product Operating Brief — full strategic detail.
- Decision Log — approved and unresolved decisions.
- Feature Backlog — feature and gamification concepts.
- Brand Guide — product-facing brand and visual direction.
- Trust / Safety / Legal — ethical engagement, dependency, claims, privacy, and monetization guardrails.
- Current Status — execution and product-operations detail.

Standalone generated domain drafts are preserved under `04_REFERENCES/archived_generated_domain_drafts/` only to prove provenance and prevent information loss.

## 6. Recommended Reading Order

### To restart product work

1. This file.
2. Product Operating Brief.
3. Current Status.
4. Decision Log.
5. Prototype PRD.
6. Brand Character Guide.
7. Content Spec.
8. Screen Inventory.
9. QA Checklist.

### To review business, market, product and gamification strategy

Read the Product Operating Brief, especially:

- Business Model and Integrated Business Appendix.
- Market and Growth and Integrated Market Appendix.
- Product Strategy / Experience and Integrated Product Appendix.
- Gamification Strategy and Integrated Gamification Appendix.

### To hand off to Claude or another collaborator

Provide at minimum:

- This file.
- Product Operating Brief.
- Current Status.
- Decision Log.
- Prototype PRD.
- Brand Character Guide.
- Content Spec.
- Feature Backlog.
- Trust / Safety / Legal file.

## 7. Evidence Labels

All major statements should use one of these labels:

- **Approved** — explicitly decided by the founder.
- **Working direction** — preferred but reversible.
- **Hypothesis** — plausible but unvalidated.
- **Pending** — requires a founder decision.
- **Deferred** — intentionally moved out of current scope.
- **Superseded** — replaced by a newer direction.
- **Reference only** — context or provenance; not evidence of validation.

## 8. Current Highest-Priority Work

1. Review and approve the Prototype PRD.
2. Lock the Twinko character model and mode-specific visual system.
3. Finalize the minimum Traditional-Chinese content set for Chat, Tarot, and Astrology.
4. Confirm the remaining micro-decisions listed in Current Status.
5. Begin prototype production only against the locked PRD and Screen Inventory.

## 9. Important Boundaries

- A working prototype is not evidence of product-market fit, retention, willingness to pay, or clinical effectiveness.
- Tarot and astrology are reflection / entertainment rather than certainty or prediction.
- TwinkoTalk must not claim to diagnose, treat, or replace mental-health professionals.
- Healthy trust and repeat value are goals; unhealthy dependency is not.
- Gamification remains a backlog strategy and is not part of the prototype.
