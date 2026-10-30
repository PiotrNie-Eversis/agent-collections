# Jira-ready tasks — start-here-onboarding-ux

**Target project:** AC (Agent Collections)  
**Push status:** Pushed 2026-10-13 (Gate 2: Push to jira)
**Created keys:** Epics [AC-56](https://eversis.atlassian.net/browse/AC-56), [AC-55](https://eversis.atlassian.net/browse/AC-55); Tasks AC-57…AC-61  
**Related delivery:** [AC-36](https://eversis.atlassian.net/browse/AC-36) — **Relates** on epics; label `start-here-onboarding` on all issues  
**Leaf issue type:** **Task** under Epic (team standard — not Story as leaf)

## Created issue keys (Epic → Task)

| Epic | Key | Tasks |
|---|---|---|
| Start here: Onboarding map rewrite | [AC-56](https://eversis.atlassian.net/browse/AC-56) | [AC-57](https://eversis.atlassian.net/browse/AC-57), [AC-59](https://eversis.atlassian.net/browse/AC-59), [AC-58](https://eversis.atlassian.net/browse/AC-58), [AC-60](https://eversis.atlassian.net/browse/AC-60) |
| Start here: Link integrity | [AC-55](https://eversis.atlassian.net/browse/AC-55) | [AC-61](https://eversis.atlassian.net/browse/AC-61) |

---

## Epic 1

| Field | Value |
|---|---|
| **Summary** | Start here: Onboarding map rewrite |
| **Issue Type** | Epic |
| **Priority** | High |
| **Labels** | documentation, getting-started, ux, website, start-here-onboarding |
| **Relates to** | AC-36 |
| **Jira Key** | AC-56 |

### Description

h2. Overview

Rewrite the public Start here page into a scannable onboarding map: short Prerequisites pointer, role-based paths for QA/BA/PO versus maintainers, plain-language success criteria, and next steps — without duplicating Prerequisites prose or exposing shell/MCP jargon on the critical path.

h2. Business Value

Reduces cognitive overload for non-technical readers after AC-36 expanded Prerequisites (and previously lengthened Start here step 1). Restores the tip promise: map, not encyclopedia.

h2. Success Metrics

* First-time QA/BA can choose their path and open Prerequisites/Installation without a paragraph-length checklist item.
* Maintainers still find MCP depth without competing unlabeled checklists.
* `npm run website:build` passes after the combined Start here changes.

### Acceptance Criteria

(/) Epic is done when all child tasks are Done and `npm run website:build` passes for the Start here rewrite.

---

## Task 1.1

| Field | Value |
|---|---|
| **Summary** | QA/BA see a short Prerequisites pointer on Start here |
| **Issue Type** | Task |
| **Parent** | Start here: Onboarding map rewrite |
| **Priority** | High |
| **Labels** | documentation, getting-started, ux, start-here-onboarding |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | AC-57 |

### Description

h2. Context

This task is part of **Start here: Onboarding map rewrite**. It removes the Prerequisites wall of text from checklist item 1 while keeping a scannable tool summary.

h2. Source Context

`docs/specs/start-here-onboarding-ux/cleaned-transcript.md` — checklist item 1 wall of text; quality review S-02.

h2. User Story

As a **QA or BA** opening Start here, I want the first step to be a short link to Prerequisites, so that I am not blocked by a wall of text that belongs on another page.

h2. Requirements

# Limit the first onboarding step to at most two short sentences plus a link to Prerequisites.
# Still name an AI editor (Cursor and/or Claude Code), Docker Desktop, and Git in that short copy.
# Do not duplicate Prerequisites detail (GUI/CLI, Node, VS Code, accounts) inline on Start here.
# Use plain language and full sentences (English docs SSOT).

h2. Delivery Standard

* Spec folder: `docs/specs/start-here-onboarding-ux/` (or split `<key>-<topic>/` at implement time)
* Research / plan: required before implementation when using `eversis-implement`
* Implement: `eversis-implement`
* Review: `eversis-review`
* Fine: QA comment draft per `eversis-fine-handoff`
* Verify: `npm run website:build`

h2. Technical Notes

Edit `website/docs/getting-started/start-here.md`.

### Acceptance Criteria

(/) GIVEN Start here WHEN a reader scans the first onboarding step THEN the step is at most two short sentences plus a link to Prerequisites.
(/) GIVEN the short Prerequisites step WHEN a reader scans it without opening Prerequisites THEN the copy still names an AI editor (Cursor and/or Claude Code), Docker Desktop, and Git in at most two sentences before the link.
(/) GIVEN Prerequisites detail (GUI/CLI, Node, VS Code, accounts) WHEN Start here is updated THEN that detail is not duplicated inline on Start here.
(/) GIVEN English docs SSOT WHEN copy is written THEN sentences are full and plain language.

---

## Task 1.2

| Field | Value |
|---|---|
| **Summary** | QA/BA see role-based Start here paths instead of two checklists |
| **Issue Type** | Task |
| **Parent** | Start here: Onboarding map rewrite |
| **Priority** | High |
| **Labels** | documentation, getting-started, ux, start-here-onboarding |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | AC-59 |

### Description

h2. Context

Part of **Start here: Onboarding map rewrite**. Replaces unlabeled “First successful install” vs “Setup checklist (maintainers)” with explicit role paths.

h2. Source Context

Cleaned transcript — two competing checklists; quality review S-01.

h2. User Story

As a **QA, BA, or PO**, I want Start here to show which install path is for me versus maintainers, so that I do not guess between two checklists.

h2. Requirements

# Provide a role-based choice (table and/or tabs) for QA/BA/PO, developer/QA tech, and maintainer/MCP.
# QA/BA/PO path is Cursor-first and links Prerequisites before or together with Installation.
# Maintainer/MCP path points to MCP setup / Node expectations without forcing QA through the same list.
# Remove or replace the previous dual unlabeled checklists.

h2. Delivery Standard

Same as Task 1.1.

h2. Technical Notes

Prefer Markdown role table; Tabs/MDX optional. Do not invent new installer modes.

### Acceptance Criteria

(/) GIVEN a first-time reader WHEN they open Start here THEN they see an explicit role-based choice covering at least QA/BA/PO, developer/QA tech, and maintainer/MCP.
(/) GIVEN QA/BA/PO WHEN they follow their row/path THEN they are directed to Cursor-first Prerequisites and Installation (not maintainer MCP depth as the default).
(/) GIVEN a QA/BA/PO reader WHEN they follow their role path THEN the path links Prerequisites before or together with Installation.
(/) GIVEN maintainer/MCP WHEN they follow their path THEN they are directed to MCP setup / Node expectations without requiring QA readers to parse the same list.
(/) GIVEN the previous dual checklists WHEN the redesign ships THEN unlabeled competing First successful install vs Setup checklist (maintainers) sections are removed or replaced by the role-based structure.

---

## Task 1.3

| Field | Value |
|---|---|
| **Summary** | QA/BA see plain-language success criteria and next steps on Start here |
| **Issue Type** | Task |
| **Parent** | Start here: Onboarding map rewrite |
| **Priority** | High |
| **Labels** | documentation, getting-started, ux, start-here-onboarding |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | AC-58 |

### Description

h2. Context

Part of **Start here: Onboarding map rewrite**. Moves shell/MCP jargon off the critical path; keeps a short “you’re done when…” block.

h2. Source Context

Cleaned transcript — hermetic jargon; mockup success criteria and next steps.

h2. User Story

As a **QA or BA**, I want a short “you’re done when…” checklist in everyday language, so that I know install worked without interpreting shell flags on Start here.

h2. Requirements

# List success criteria in plain language (installer OK; expected folders/files; first AI prompt / @eversis-implement responds).
# Do not require shell flags, export, submodule/copy modes, or MCP skill internals as Start here reading.
# Link next steps to Quick wins and Main Flow / workflow overview.

h2. Delivery Standard

Same as Task 1.1.

h2. Technical Notes

One short “first prompt” line is OK; avoid packing `--build-mcp --non-interactive` into the map page.

### Acceptance Criteria

(/) GIVEN Start here WHEN a reader finishes the guided path THEN the page lists success criteria in plain language (installer finished without error; expected project folders/files present; first AI prompt/@eversis-implement responds).
(/) GIVEN shell flags, export, submodule/copy modes, and MCP skill internals WHEN they appear THEN they are not required reading on Start here.
(/) GIVEN successful install WHEN the reader looks for what to do next THEN Start here links to Quick wins and Main Flow / workflow overview (or equivalent) as primary next steps.

---

## Task 1.4

| Field | Value |
|---|---|
| **Summary** | Readers are not shown redundant In this section on Start here |
| **Issue Type** | Task |
| **Parent** | Start here: Onboarding map rewrite |
| **Priority** | Medium |
| **Labels** | documentation, getting-started, ux, start-here-onboarding |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | AC-60 |

### Description

h2. Context

Part of **Start here: Onboarding map rewrite**. Removes duplicate navigation and demotes encyclopedic GitLab/canonical blocks from the primary path.

h2. Source Context

Cleaned transcript — In this section redundancy.

h2. User Story

As a **documentation reader**, I want Start here free of duplicate navigation lists, so that the page stays short and I use the sidebar and next-page controls instead.

h2. Requirements

# Remove the In this section list (default) unless proven non-redundant.
# Demote Requirements traceability and GitLab README/AGENTS links off the primary onboarding steps.
# Keep reachability of Prerequisites, Installation, MCP setup, and Quick wins via sidebar / Previous-Next.

h2. Delivery Standard

Same as Task 1.1.

h2. Technical Notes

Coordinate with Tasks 1.2 and 1.3 so primary CTAs remain.

### Acceptance Criteria

(/) GIVEN Start here WHEN the redesign ships THEN the In this section list is removed (default) or proven non-redundant if intentionally kept.
(/) GIVEN Requirements traceability and GitLab README/AGENTS links WHEN the redesign ships THEN they are demoted off the primary onboarding steps.
(/) GIVEN sidebar and Previous/Next WHEN a reader navigates THEN they can still reach Prerequisites, Installation, MCP setup, and Quick wins.

---

## Epic 2

| Field | Value |
|---|---|
| **Summary** | Start here: Link integrity |
| **Issue Type** | Epic |
| **Priority** | High |
| **Labels** | documentation, getting-started, website, start-here-onboarding |
| **Relates to** | AC-36 |
| **Jira Key** | AC-55 |

### Description

h2. Overview

Ensure Start here internal documentation links resolve to the correct pages in local preview and production (no `/start-here/prerequisites` 404 pattern).

h2. Business Value

Prevents blocked onboarding when readers click the map links.

h2. Success Metrics

* Spot-check of Start here internal docs links succeeds for Prerequisites, Installation, MCP setup, Quick wins, Domain Context, Framework, Main Flow.

### Acceptance Criteria

(/) Epic is done when Task 2.1 is Done and `npm run website:build` passes.

---

## Task 2.1

| Field | Value |
|---|---|
| **Summary** | Start here internal links use site-absolute /docs paths |
| **Issue Type** | Task |
| **Parent** | Start here: Link integrity |
| **Priority** | High |
| **Labels** | documentation, getting-started, website, start-here-onboarding |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | AC-61 |

### Description

h2. Context

Part of **Start here: Link integrity**. Relative `./` links under a trailing-slash URL resolved to `/start-here/<sibling>` and 404’d in local preview.

h2. Source Context

Cleaned transcript — broken internal links; incident 2026-10-13. Partial absolute-link fix may already be on disk — verify after Epic 1 rewrite.

h2. User Story

As a **reader using local docs preview or production**, I want Start here links to open the real sibling pages, so that I am not stuck on 404 URLs under `/start-here/…`.

h2. Requirements

# Use site-absolute `/docs/…` paths (or another Docusaurus-safe form that does not resolve under `/start-here/`).
# Verify clicks from a trailing-slash Start here URL for Prerequisites, Installation, MCP setup, Quick wins, Domain Context, and Framework reference.
# Pass `npm run website:build`.

h2. Delivery Standard

Same as Task 1.1.

h2. Technical Notes

Re-verify after Epic 1 rewrite; harden any remaining relatives.

### Acceptance Criteria

(/) GIVEN Start here WHEN internal docs links are inspected THEN they use site-absolute paths under `/docs/…` (or another form that does not resolve under `/start-here/`).
(/) GIVEN local yarn start with a trailing-slash URL WHEN the reader clicks Prerequisites, Installation, MCP setup, Quick wins, Domain Context, and Framework reference THEN each target loads (no 404).
(/) GIVEN npm run website:build WHEN the task is Done THEN the build passes.
