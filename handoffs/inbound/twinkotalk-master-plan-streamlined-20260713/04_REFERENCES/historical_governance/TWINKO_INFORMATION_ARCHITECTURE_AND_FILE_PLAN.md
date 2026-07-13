# TWINKO_INFORMATION_ARCHITECTURE_AND_FILE_PLAN

> Status date: 2026-07-13

## 1. Purpose

Prevent duplicated strategies, conflicting scopes, and “final-final” plan versions by defining a clear file hierarchy.

## 2. Five Buckets

1. Business & Venture Strategy.
2. Market, Brand & Growth.
3. Product Strategy & Experience.
4. Development & Product Operations.
5. Trust, Safety, Legal & Governance.

## 3. Canonical Files

- `00_TWINKO_START_HERE.md`
- `01_CANONICAL/TWINKO_PRODUCT_OPERATING_BRIEF.md`
- `01_CANONICAL/TWINKO_DECISION_LOG.md`
- `01_CANONICAL/TWINKO_CURRENT_STATUS.md`
- `04_PRODUCT/TWINKOTALK_PROTOTYPE_PRD.md`

## 4. Domain Files

- Business model and venture strategy.
- Market, brand and growth.
- Product experience strategy.
- Gamification strategy.
- Trust, safety, legal and governance.

## 5. Execution Files

- Feature Backlog.
- Brand Character Guide.
- Content Spec.
- Product Operations.
- Screen Inventory.
- Prototype QA Checklist.

## 6. Reference Files

- Original Market Analysis summary.
- Original Business Model summary.
- Original Gamification summary.
- Earlier Execution Restart Plan.
- Earlier mixed consolidation.
- Visual references.

## 7. Update Rules

### Product strategy change

Update:

- Decision Log.
- Operating Brief.
- PRD if prototype is affected.
- Current Status.

### Feature idea

Update Feature Backlog only unless approved.

### Content change

Update Content Spec and relevant PRD acceptance criteria.

### Visual change

Update Brand Character Guide and Screen Inventory.

### Safety / legal change

Update Trust / Safety / Legal and Decision Log.

## 8. Archive Rules

Historical schedules and old visuals remain references but are not active plans. Never use file modification date alone to determine authority; use the source-of-truth hierarchy and Decision Log.

## 9. Naming Convention

- `TWINKO_` for project-wide strategy / governance.
- `TWINKOTALK_` for product-specific execution docs.
- Date versions only for exported packages, not every working file.
