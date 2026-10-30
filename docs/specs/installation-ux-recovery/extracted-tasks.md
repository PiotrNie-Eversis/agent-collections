# installation-ux-recovery - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-14 |
| Participants | Documentation / DevEx analysis (report); BA extraction session |
| Source Materials | UX/IA audit for `/docs/getting-started/installation` (`source-ux-audit.md`); current `website/docs/getting-started/installation.md`; `docs/context/agent-collections/task-baseline.md`; pattern from `docs/specs/mcp-setup-ux-recovery/` |
| Intent Brief | [intent-brief.md](./intent-brief.md) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` |
| Total Epics | 1 |
| Total Stories | 7 |
| Jira note | On project **AC**, create implementable items as **Task** (board: Epic → Task/Bug). Story wording below is the BA format. |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Installation page: guided onboarding and DevEx recovery | 7 | Highest |

## Epic 1: Installation page: guided onboarding and DevEx recovery

**Business Description**: Getting Started readers must clone the Agent Collections framework once and run the installer in their own project. Today the Installation page buries the happy path, mixes maintainer/CLI-reference content into numbered steps, and shows Unix-only commands that block Windows users. This epic delivers a single guided Installation page: clear three-step framing, framework-vs-project mental model, OS tabs, one default command with deferred advanced flags, early verification, and slim TOC.

**Success Criteria**:
- A non-developer (QA/BA/PO) can complete install by following three main steps without reading the full CLI flag table or submodule internals.
- Windows readers get a working Git Bash path (not Unix-only samples as the only option).
- Reader can recognize success (selection file / context index / installer exit) before leaving for MCP Setup.
- Page IA follows: what this is → download once → install into project → verify → upgrade → advanced (details) → next link to MCP Setup.
- Time-to-first-success guidance targets a short path (audit: ~2 minutes of action vs long reference reading).

### Story 1.1: Reader sees a clear three-step install framing

**User Story**: As a Getting Started reader, I want the Installation page to open with a short “install in three steps” message, so that I know this page is the install path and I am not sent back to Start here as my first action.

**Source**: Audit §3 matrix (Intro and Callout); Executive Summary inverted-flow critique; proposed template intro.

**Acceptance Criteria**:
- [ ] GIVEN I open Installation WHEN I read the top of the page THEN I see a concise statement that I will install Agent Collections into my project in about three steps.
- [ ] GIVEN I am new WHEN I see the opening callout/tip THEN Prerequisites (especially Docker running) is linked as a prerequisite — not as a loop that replaces the install steps.
- [ ] GIVEN I scan the page WHEN I look at the main headings THEN the primary path is ordered as download → install into project → verify (not maintainers → flags → sample install last).

**Additional Acceptance Checks**:
- Start here may remain as a secondary cross-link, but it is not the dominant first CTA.

**High-Level Technical Notes**: Docusaurus tip/info callout; English copy aligned with current docs SSOT.

**Priority**: Highest

### Story 1.2: Reader understands framework vs consumer project

**User Story**: As a non-terminal-fluent user, I want a plain explanation that I download the framework once and then run the installer inside my business project, so that I do not run setup inside the framework repo by mistake.

**Source**: Audit §2.D (mental model); proposed template framing (“consumer project”).

**Acceptance Criteria**:
- [ ] GIVEN I open Installation WHEN I read before the first commands THEN I see an explicit two-part model: (A) download the toolkit once on my machine; (B) go to my project and install into it.
- [ ] GIVEN I follow Step A WHEN I finish cloning THEN I know the framework folder can live outside my app repo.
- [ ] GIVEN I start Step B WHEN I change directory THEN the page tells me to use my business/sample project folder — not the `agent-collections` checkout — as the working directory for the installer.
- [ ] GIVEN I might confuse the two folders WHEN I read the mental-model section THEN I see an explicit warning not to run the installer from inside the `agent-collections` framework checkout.

**High-Level Technical Notes**: Text diagram or short labeled steps; keep `AGENT_COLLECTIONS_HOME` explained in plain language.

**Priority**: Highest

### Story 1.3: Reader follows OS-specific clone and environment steps

**User Story**: As a macOS, Linux, or Windows user, I want OS-appropriate commands for cloning the framework and setting `AGENT_COLLECTIONS_HOME`, so that I do not paste Unix syntax into PowerShell and get stuck at step 1.

**Source**: Audit §2.A (no OS tabs); §3 matrix (OS); proposed template Step 1 tabs; Windows Git Bash guidance.

**Acceptance Criteria**:
- [ ] GIVEN I open Step 1 (download framework) WHEN I look at the commands THEN I see tabs (or equivalent) for **macOS / Linux** and **Windows**.
- [ ] GIVEN I am on Windows WHEN I open the Windows tab THEN I am directed to run the steps in **Git Bash** (installed with Git for Windows) with paths that work there.
- [ ] GIVEN I prefer PowerShell WHEN I read the Windows guidance THEN I at least see how to set `AGENT_COLLECTIONS_HOME` in PowerShell, without requiring full PowerShell installer scripting if Git Bash remains the supported path for `bash setup-agent-collections.sh`.
- [ ] GIVEN I am on macOS/Linux WHEN I use the default tab THEN clone + `export AGENT_COLLECTIONS_HOME=...` examples remain correct and copy-pasteable.

**Additional Acceptance Checks**:
- In-tab headings do not spam “On this page” (prefer bold labels and/or `toc_max_heading_level: 2`, same lesson as AC-37/AC-50).

**High-Level Technical Notes**: `<Tabs groupId="operating-system">`; installer remains a Bash script — Windows happy path is Git Bash.

**Priority**: Highest

### Story 1.4: Reader runs one recommended install command in their project

**User Story**: As a QA, BA, or PO, I want a single recommended installer command for the common case, so that I am not forced to decide among a dozen CLI flags before first success.

**Source**: Audit §2.B (flag table overload); §3 matrix (install modes); proposed template Step 2 + `--profile` tip; progressive disclosure principle.

**Acceptance Criteria**:
- [ ] GIVEN I reach Step 2 WHEN I look for what to run THEN I see one default, copy-paste command suitable for first install (agents + profile called out; Docker/build called out as needed).
- [ ] GIVEN I am about to run the recommended install command WHEN I read Step 2 THEN I see a clear reminder that Docker Desktop/Engine must be running (with a link to Prerequisites), and what failure symptom means Docker is not ready.
- [ ] GIVEN I only need the standard consumer path WHEN I scan Step 2 THEN I am not required to choose `--vendor`, `--ssot-source`, or `--confluence-space-key` to proceed.
- [ ] GIVEN I wonder what `--profile` means WHEN I read the adjacent tip THEN I see plain-language options (e.g. fullstack recommended; frontend/backend when limiting stack).
- [ ] GIVEN OS tabs are used in Step 1 WHEN I run Step 2 THEN matching OS tabs (or clear “same shell / Git Bash” guidance) appear so path/`cd` syntax stays consistent.

**Additional Acceptance Checks**:
- Default path is labeled as the recommended path for most users / non-developers (no early push into submodule/vendor modes).

**High-Level Technical Notes**: Align default flags with live installer SSOT (`--build-mcp`, `--non-interactive`, `--agents`, `--profile`, MCP defaults as used today). Full flag table belongs in Story 1.6, not here.

**Priority**: Highest

### Story 1.5: Reader verifies that installation succeeded

**User Story**: As a framework user, I want an explicit verification step with concrete success signals, so that I know the install worked before I move to MCP Setup.

**Source**: Audit §2.E (buried smoke test); proposed template Step 3; Executive Summary inverted flow.

**Acceptance Criteria**:
- [ ] GIVEN I finished the recommended install WHEN I follow Verification THEN I know which project artifacts indicate success (at least `.agent-collections/install-selection.json` and that `docs/context/<project>/INDEX.md` exists or was created).
- [ ] GIVEN the installer finished WHEN I read Verification THEN I know a clean completion means exit without critical errors (exit code 0 / no critical failure messaging — wording may be plain language).
- [ ] GIVEN verification fails (missing selection file, missing context INDEX, or installer error) WHEN I read Verification THEN I see a short recovery checklist (at least: correct project folder, `AGENT_COLLECTIONS_HOME` set, Docker running / Prerequisites) before being left only with a next-step to MCP Setup.
- [ ] GIVEN verification succeeds WHEN I reach the end of that section THEN I see a clear next-step link to **MCP Setup**.
- [ ] GIVEN verification is part of the main path WHEN I scan the page THEN I do not have to scroll to a buried “First successful install” sample as the only smoke test.

**High-Level Technical Notes**: Sample-project `/tmp` walkthrough may remain as an optional illustration under advanced or as a short aside, but must not be the only verification content.

**Priority**: Highest

### Story 1.6: Advanced and maintainer content sits below the happy path

**User Story**: As a first-time installer, I want upgrade, submodule, full CLI flags, and maintainer adapter-sync content kept out of the numbered happy path, so that optional/advanced topics do not look mandatory.

**Source**: Audit §2.C (maintainer step 2); §2.B (flag table); §3 matrix (step structure, install modes); proposed template Upgrade + `<details>` advanced blocks.

**Acceptance Criteria**:
- [ ] GIVEN I follow the numbered main path WHEN I complete download → install → verify THEN I never encounter “open the framework / `npm run sync:adapters`” as a required numbered step.
- [ ] GIVEN I need to upgrade later WHEN I scroll below the happy path THEN I find a clear Upgrade & Sync section with the upgrade command and a short note that local rules are preserved where the product already does so.
- [ ] GIVEN I need team submodule or full CLI flags WHEN I open Advanced THEN those topics are in collapsible sections (or clearly labeled advanced), including at least submodule workflow and the full useful-flags table moved out of the default step.
- [ ] GIVEN I am a framework maintainer WHEN I look for adapter sync / open-framework guidance THEN it is available in advanced/end content, not in steps 1–3.

**High-Level Technical Notes**: Use `<details>` / summary blocks as in the audit template; preserve accurate flag meanings from the current page when relocating the table.

**Priority**: High

### Story 1.7: Reader scans a short table of contents of major sections only

**User Story**: As a scanner, I want the “On this page” outline limited to a few major sections, so that I can navigate the install path without TOC noise from every nested heading and flag subsection.

**Source**: Audit §3 matrix (TOC); proposed frontmatter `toc_max_heading_level: 2`; related lesson from AC-37/AC-50 Prerequisites TOC cleanup.

**Acceptance Criteria**:
- [ ] GIVEN I open Installation WHEN I view “On this page” THEN I see roughly 4–5 major sections (happy path + upgrade + advanced), not a long list of mixed-depth headings.
- [ ] GIVEN OS or client tabs contain inner labels WHEN those labels are present THEN they do not duplicate as many TOC entries (bold labels and/or `toc_max_heading_level: 2`).
- [ ] GIVEN the page builds WHEN docs site build runs THEN the page renders without TOC regression that reintroduces the old dense outline.

**High-Level Technical Notes**: Mirror Prerequisites TOC approach (`toc_max_heading_level` and/or avoid `###` inside tabs).

**Priority**: High

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.3 | Story 1.2 | Related to | OS tabs sit on the download/install steps that assume the mental model |
| Story 1.4 | Story 1.2, Story 1.3 | Blocked by | Default install command needs project-vs-framework clarity and OS path consistency |
| Story 1.5 | Story 1.4 | Blocked by | Verification assumes the recommended install was documented |
| Story 1.6 | Story 1.1, Story 1.4 | Related to | Advanced deferral depends on happy-path framing and moving flags out of Step 2 |
| Story 1.7 | Stories 1.1–1.6 | Related to | TOC reflects final heading structure after IA rewrite |
| Epic 1 | AC-63 (MCP Setup) | Related to | Installation next-step links to MCP Setup; do not duplicate MCP content |
| Epic 1 | AC-37 / AC-38 | Related to | Prerequisites tip/link only |
| Epic 1 | DHI-649 | Related to | Canonical install checklist continuity across entry pages |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | Deliver as a **new epic in project AC** (parallel to AC-63), not as children of DHI-641 | High | If stakeholders want DHI parenting, re-parent on push; story content unchanged |
| 2 | Published page remains **English**; Polish audit wording is source only | High | If Polish docs are requested, add a localization story |
| 3 | Windows supported path for the Bash installer is **Git Bash**; PowerShell is env-note only unless Gate 1 expands it | Medium | Full PowerShell tabs would add AC work and possibly installer docs for non-Bash shells |
| 4 | Docs-only change — installer CLI behavior stays as today | High | Product bugs found during Implement become separate tickets |
| 5 | “First successful install” sample may shrink or move; verification criteria in Story 1.5 remain mandatory | High | If product owners want to keep the `/tmp` sample prominent, place it under verification as optional, not instead of artifact checks |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Installer / Docker / MCP runtime code changes.
- Rewriting Prerequisites (AC-37/AC-38) or MCP Setup (AC-63) beyond inbound/outbound links.
- Site-wide IA under DHI-641 (sidebar, Introduction, homepage).
- Non-English published docs for this page.
- Video tutorials.

## Open Questions for Stakeholders

None — resolved at Gate 1 (2026-10-14): new AC epic; Git Bash-primary Windows; English-only page. See `intent-brief.md` §Gate 1 Decisions.
