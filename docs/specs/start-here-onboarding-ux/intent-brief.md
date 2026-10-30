# start-here-onboarding-ux — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-13 |
| Participants | UX / IA reviewer (QA/BA/PO lens); documentation maintainers |
| Source Materials | User-provided Start here UX analysis (Polish); live `website/docs/getting-started/start-here.md` |
| Prepared By | eversis-analyze-materials (Business Analyst workflow) |

## Goal

Rewrite **Start here** into a true **onboarding map**: scannable steps, clear role paths for QA/BA/PO vs maintainers, plain-language success criteria, and no duplicate Prerequisites essay or redundant section lists — while keeping English as docs SSOT.

## In Scope

- Restructure `website/docs/getting-started/start-here.md` (and MDX only if Tabs are chosen).
- Short Prerequisites pointer (no wall-of-text in checklist item 1).
- Role-based path (table and/or Tabs): end user vs maintainer / MCP developer.
- Compact **success criteria** and **next steps** (Quick wins, Main Flow).
- Remove or demote **In this section**; demote dense GitLab/canonical blocks off the critical path.
- Keep internal links as **site-absolute** `/docs/...` paths (verify no trailing-slash 404s in local `yarn start`).
- `npm run website:build` before Done.

## Out of Scope

- Full rewrite of Installation / MCP setup / Prerequisites pages (except link targets already shipped).
- Polish localization of the docs site (English remains SSOT; mockup is design intent).
- Installer script or MCP image changes.
- New product features beyond documentation IA/copy.

## Key Stakeholders / Actors

- **QA / BA / PO** — primary onboarding readers; need role clarity and scannable steps.
- **Developers / QA Tech** — secondary; may use Claude Code / env vars (details live on Installation).
- **Maintainers / MCP developers** — separate path; Node + MCP depth.
- **Documentation maintainers** — implement and verify Docusaurus build.

## Candidate Epics

- **Start here — onboarding map rewrite** — hierarchy, role paths, success criteria, redundancy removal.
- **Start here — link integrity** — absolute internal links; verify no `start-here/<sibling>` 404s.

## Baseline Overlap / Existing Backlog Notes

- **AC-35 / AC-36** extended Prerequisites and previously **lengthened** Start here step 1 (Node / VS Code / accounts). This workshop **pulls that prose back** to Prerequisites and restores Start here as a map.
- Absolute `/docs/...` links on Start here were already applied after a local trailing-slash 404 report (2026-10-13) — Story on link integrity should **verify** and harden, not redo blindly.
- No `docs/context/<project>/task-baseline.md` in this framework repo.

## Open Questions

| Question | Proposed default | Needs Gate 0? |
|---|---|---|
| Tabs vs role table | **Role table** on Start here (Tabs optional later) | No — default in extraction |
| Keep Requirements traceability / GitLab README on page? | **Demote** to Framework reference or a collapsed “Maintainers / canonical refs” note | Confirm at Gate 1 if disputed |
| Expand scope into Installation “copy-paste for QA”? | **No** this workshop | Confirm at Gate 1 if needed |

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Skipped — materials unambiguous | Structured UX diagnosis with concrete recommendations and a page mockup; live Start here path is clear. Skip recorded 2026-10-13. |
