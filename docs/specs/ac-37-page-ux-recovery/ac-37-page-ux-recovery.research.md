# ac-37-page-ux-recovery — Research

**Jira:** [AC-37](https://eversis.atlassian.net/browse/AC-37) (Epic — Prerequisites: Page UX and recovery)  
**Active child tasks:** [AC-50](https://eversis.atlassian.net/browse/AC-50) (TOC), [AC-51](https://eversis.atlassian.net/browse/AC-51) (troubleshooting)  
**Superseded Stories (Done / duplicate):** AC-44, AC-45  
**Workshop source:** `docs/specs/ac-35-prerequisites-post-review/` (Gate 1–2 approved 2026-10-13)  
**Sibling epic (same page, separate delivery):** [AC-38](https://eversis.atlassian.net/browse/AC-38) — enterprise Docker (`docs/specs/ac-38-enterprise-docker/`)

> **Label correction:** Older AC-36 notes and `code-quality-report.md` swapped epic summaries. Live Jira is SSOT: **AC-37 = TOC + troubleshooting**; **AC-38 = enterprise Docker**.

## Task Details

| Field | Value |
|---|---|
| Jira ID | AC-37 |
| Title | Prerequisites: Page UX and recovery |
| Type | Epic (Backlog) |
| Priority | Medium |
| Labels | `ac-35-follow-up`, `documentation`, `getting-started`, `ux` |
| Success metrics (epic) | Side TOC lists each major section once; ≥3 troubleshooting scenarios with screenshots and alt text |

## Problem

After AC-35 / AC-36, Prerequisites still (1) duplicates tool names in the Docusaurus “On this page” TOC because `###` headings live inside both macOS and Windows `<TabItem>`s, and (2) lacks a recovery section for common install/verification failures.

## Scope (this epic only)

| Task | Jira | Primary deliverable |
| --- | --- | --- |
| Clean TOC | AC-50 | `prerequisites.mdx` — bold labels and/or `toc_max_heading_level: 2` |
| Common problems | AC-51 | New troubleshooting section + images under `website/static/img/getting-started/prerequisites/` |

**Out of scope:** AC-38 Docker admin/license/alternatives callout; installer/MCP/Compose changes; Linux tab; video walkthroughs.

## Acceptance criteria (from active Tasks)

### AC-50 — TOC

- Published Prerequisites “On this page”: tab tool names (Cursor, Claude Code, Docker, Git) appear **at most once**.
- Fix via **bold labels instead of `###` inside tabs** and/or **`toc_max_heading_level: 2`**; `npm run website:build` passes.
- OS tab install steps stay plain-language and scannable.

### AC-51 — Troubleshooting

- Windows: `docker` not recognized → start Docker Desktop / wait for engine.
- Windows: PowerShell script blocked → execution policy noted; IT or documented rerun.
- macOS Git: Xcode prompt → lightweight Git installer alternative explained.
- ≥3 scenarios; **text + screenshots with alt text**; static assets path; build passes.

## Affected paths

- `website/docs/getting-started/prerequisites.mdx` (SSOT; current `###` inside both OS tabs)
- `website/static/img/getting-started/prerequisites/` (new; directory created empty for AC-51 assets)
- Possibly frontmatter only on the MDX page (no theme fork expected)

## Root cause

1. **TOC:** Docusaurus indexes markdown headings inside both tab panes; duplicate `### Cursor` / `### Docker Desktop` / etc. appear twice in the sidebar TOC.
2. **Recovery:** Verification only says close/reopen terminal; workshop findings 4 and 6 documented the duplicate TOC and three typical failures.

## Constraints

- Plain language, full sentences (AC-35 doc standard).
- No new npm dependencies; `npm run website:build` must pass.
- Screenshots: no secrets; store under agreed static path; alt text required.
- Prefer minimal MDX change for TOC (frontmatter and/or replace in-tab `###` with bold).

## Current implementation status

| Component | Path | Status |
|---|---|---|
| Prerequisites page | `website/docs/getting-started/prerequisites.mdx` | Needs modification — duplicate `###` in tabs; no Common problems section |
| Static prereq images | `website/static/img/getting-started/prerequisites/` | Directory exists; **no screenshots yet** |
| AC-36 clarity copy | same MDX | Done — do not regress GUI/CLI, Node, accounts, terminal how-to |

## Gap Analysis

### Question 1
#### TOC strategy preference: `toc_max_heading_level: 2` only, bold labels inside tabs only, or both?
**Answer (locked):** Both — `toc_max_heading_level: 2` and bold labels inside tabs.  
Evidence: user `Q1. OK;` (2026-10-14).

### Question 2
#### Who supplies the ≥3 troubleshooting screenshots (Docker running, PowerShell/terminal, Git installer choice)?
**Answer (locked):** Agent creates sanitized, non-secret illustrative screenshots during Implement under `website/static/img/getting-started/prerequisites/`. Human may replace later.  
Evidence: user `Q2. OK;` (2026-10-14).

### Question 3
#### Deliver AC-37 alone or in one Implement thread with AC-38 (same page)?
**Answer (locked):** Implement with AC-38 — one thread / one plan, AC-38 then AC-37, single `website:build`.  
Evidence: user `Q3. Implement with AC-38;` (2026-10-14).

## Open questions (blocking)

None — Q1–Q3 locked 2026-10-14.

## Human gates

1. ~~Approve research~~ — done (`Q1. OK;` / `Q2. OK;` / `Q3. Implement with AC-38;`)
2. Approve plan (once written)
3. Implement → Review → Fine

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-10-14 | eversis-implement | CREATE from workshop + live Jira AC-37 / AC-50 / AC-51; corrected epic label vs AC-36 notes |
| 2026-10-14 | eversis-implement | Gap Q1–Q3 locked; research approved; proceed to combined plan with AC-38 |
