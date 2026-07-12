# twinko-app

## Repository ownership

`twinko-app` is the canonical owner of **Twinko product truth and implementation** — product documents, research, UX/brand assets, the SwiftUI application, and Twinko-specific backend and analytics.

- **`gina-ai-native-venture-studio`** owns company governance: portfolio priorities, milestones, approvals, and cross-venture handoffs and status. It does not hold Twinko product runtime code.
- **`pm-workflow-copilot`** owns PM Workflow product truth and the canonical PM Workflow ingestion contract.
- Twinko is PM Workflow's **first dogfood customer**, not its parent repository. This repo may hold only a versioned adapter, sample exports, and a reference to the canonical contract — never the contract itself.

## Current stage

**Pre-build / canonical-migration.** Product documents have just been migrated from Studio into `docs/`. No SwiftUI implementation, PM Workflow adapter, safety policy, or research output has started. See `docs/product/TWINKO_CURRENT_STATUS.md` for current execution status.

## Structure

Directories are created just-in-time, only when real content or implementation exists — see the approved target architecture for the full structure and rationale.
