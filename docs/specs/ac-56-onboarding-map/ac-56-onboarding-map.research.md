# AC-56 onboarding map - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | [AC-56](https://eversis.atlassian.net/browse/AC-56) (Epic) |
| Title | Start here: Onboarding map rewrite |
| Description | Rewrite the public Start here page into a scannable onboarding map: short Prerequisites pointer, role-based paths for QA/BA/PO versus maintainers, plain-language success criteria, and next steps — without duplicating Prerequisites prose or exposing shell/MCP jargon on the critical path. |
| Priority | High |
| Reporter | Piotr Niemirski |
| Created Date | 2026-10-13 |
| Due Date | — |
| Labels | documentation, getting-started, start-here-onboarding, ux, website |
| Estimated Effort | Docs IA/copy — Start here rewrite (MDX Tabs) + link integrity verify; five Tasks across AC-56 and AC-55 |
| Child tasks (AC-56) | [AC-57](https://eversis.atlassian.net/browse/AC-57), [AC-58](https://eversis.atlassian.net/browse/AC-58), [AC-59](https://eversis.atlassian.net/browse/AC-59), [AC-60](https://eversis.atlassian.net/browse/AC-60) |
| In-scope sibling | [AC-55](https://eversis.atlassian.net/browse/AC-55) / [AC-61](https://eversis.atlassian.net/browse/AC-61) — Start here link integrity (human locked into this Implement plan 2026-10-13) |
| Relates to | [AC-36](https://eversis.atlassian.net/browse/AC-36) (Prerequisites clarity — expanded Start here step 1; this epic pulls that prose back) |

## Business Impact

AC-36 lengthened Start here checklist item 1 with Prerequisites detail (Node, VS Code, accounts). Non-technical QA/BA/PO readers now hit a wall of text and two unlabeled checklists. Restoring Start here as a **map** reduces cognitive load, matches the page tip, and keeps Prerequisites as the detail SSOT.

## Gathered Information

### Knowledge Base & Task Management Tools

- **Jira AC-56** — Epic; Done when all child Tasks are Done and `npm run website:build` passes.
- **Children (implementable leaves) — AC-56:**
  | Task | Summary | Maps to workshop |
  | --- | --- | --- |
  | AC-57 | Short Prerequisites pointer | Story 1.1 |
  | AC-59 | Role-based paths (replace dual checklists) | Story 1.2 |
  | AC-58 | Plain-language success criteria + next steps | Story 1.3 |
  | AC-60 | Remove In this section; demote encyclopedic footer | Story 1.4 |
- **Sibling epic in this Implement plan (human Q3 = YES):**
  | Task | Summary | Maps to workshop |
  | --- | --- | --- |
  | AC-61 (under AC-55) | Site-absolute `/docs/…` links + trailing-slash verify | Story 2.1 |
- **Workshop (Gate 0 skip; Gate 1 approved):** `docs/specs/start-here-onboarding-ux/` — `intent-brief.md`, `extracted-tasks.md`, `quality-review.md` (S-01/S-02 ACs applied), `jira-tasks.md`.
- **Hierarchy policy:** `docs/context/agent-collections/jira-backlog-hierarchy` — Epic → Task; children are already Tasks (correct for Implement).

### Codebase

- Primary page: convert `website/docs/getting-started/start-here.md` → **`start-here.mdx`** (Tabs required — human Q2).
- Tabs pattern to reuse: `website/docs/getting-started/prerequisites.mdx` (`@theme/Tabs` / `@theme/TabItem`, `groupId` for persistence).
- Current problems visible on disk:
  - Checklist item 1 is a long Prerequisites paragraph (Cursor/Claude Code/Node/VS Code/accounts).
  - Two competing sections: “First successful install checklist” and “Setup checklist (maintainers)”.
  - Success criteria packed into one jargon-heavy “Done when” line (installer flags / MCP skills).
  - “In this section” duplicates sidebar; Requirements traceability + GitLab README/AGENTS sit on the critical path.
- Internal links already use site-absolute `/docs/...` (partial AC-55 fix). After rewrite, **verify and harden** per AC-61 (trailing-slash Start here URL; Prerequisites, Installation, MCP setup, Quick wins, Domain Context, Framework).
- Quality gate: `npm run website:build` (and `npm run website:changelog:check` if changelog touched — not expected here).

### Relevant Links

- https://eversis.atlassian.net/browse/AC-56 — Epic (onboarding map)
- https://eversis.atlassian.net/browse/AC-55 — Epic (link integrity; included in this plan per human)
- https://eversis.atlassian.net/browse/AC-61 — Task under AC-55
- https://eversis.atlassian.net/browse/AC-36 — Related Prerequisites clarity epic
- `/docs/getting-started/prerequisites` — detail SSOT (do not duplicate)
- `/docs/getting-started/installation`, `/docs/getting-started/mcp-setup`, `/docs/getting-started/quick-wins`, `/docs/main-flow/workflow/overview`, `/docs/domain-context`, `/docs/framework` — link targets for paths / next steps / AC-61 verify

### Relevant Charts & Diagrams

- Workshop mockup intent (Polish source → English SSOT) in `cleaned-transcript.md` / `extracted-tasks.md`: role choice → short steps → success criteria → next steps.
- **Role UI locked to Tabs only** (human 2026-10-13) — not the Gate 0 Markdown role-table default. Tab values should cover at least QA/BA/PO, developer/QA tech, and maintainer/MCP.

## Current Implementation Status

### Existing Components

- Start here Docusaurus page — `website/docs/getting-started/start-here.md` — **needs modification** (convert to MDX + full IA/copy rewrite for AC-57–AC-60; verify links for AC-61)
- Prerequisites page — `website/docs/getting-started/prerequisites.mdx` — **reuse** as link target and as Tabs copy pattern
- Getting-started sidebar / Previous-Next — Docusaurus nav — **reuse** (keeps reachability after removing “In this section”)

### Key Files and Directories

- `website/docs/getting-started/start-here.md` → `start-here.mdx` — primary edit surface (delete/replace `.md` after MDX ships)
- `website/docs/getting-started/prerequisites.mdx` — Tabs import/usage reference
- `docs/specs/start-here-onboarding-ux/` — workshop SSOT for requirements
- `docs/specs/ac-56-onboarding-map/` — this Implement research/plan folder
- `package.json` — `website:build` script for Done check

## Gap Analysis

Workshop Gate 0 skipped; Gate 1 quality suggestions accepted; Jira children match Stories 1.1–1.4. Human locked Q1–Q3 on 2026-10-13. No remaining blocking gaps.

### Question 1
#### Should one Implement plan cover all four child Tasks (AC-57–AC-60) in a single rewrite of Start here?
#### Answer
**Yes** (human 2026-10-13) — single coordinated plan/rewrite with AC checkboxes per Task; include AC-61 in the same plan (see Q3).

### Question 2
#### Role table vs Tabs for the role-based path?
#### Answer
**Tabs only** (human 2026-10-13) — override Gate 0 Markdown table default. Implement via `start-here.mdx` using `@theme/Tabs` / `@theme/TabItem` (same pattern as `prerequisites.mdx`). No role table as the primary chooser.

### Question 3
#### Include AC-55/AC-61 link integrity in this epic’s plan?
#### Answer
**Yes** (human 2026-10-13) — plan and execute AC-61 (site-absolute `/docs/…` links + trailing-slash verification + `website:build`) in the same Implement thread after the onboarding-map rewrite.

## Human gates

1. ~~Approve research~~ — done (`Research is ok. Make the plan`)
2. ~~Approve plan~~ — done (`Plan is ok. Implement`)
3. ~~Implement → Review → Fine~~ — done (review PASS; Fine this turn)

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-10-13 | eversis-implement | CREATE from AC-56 + workshop `start-here-onboarding-ux` |
| 2026-10-13 | eversis-implement | DELTA — Gap Q1–Q3 locked: single plan YES; Tabs only; include AC-55/AC-61 |
