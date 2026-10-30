# installation-ux-recovery — Jira-ready Tasks

| Field | Value |
|---|---|
| Target project | **AC** |
| Workshop folder | `docs/specs/installation-ux-recovery/` |
| Gate 1 | Approved 2026-10-14 |
| Quality review | Lite — S-01–S-03 accepted (`quality-review.md`) |
| Issue type rule | Epic → **Task** (never Story as implementable leaf — `jira-backlog-hierarchy`) |
| Push status | **Pushed 2026-10-14** — Epic AC-72, Tasks AC-73–AC-79 |

## Completeness checklist

| # | Summary | Type | Priority | AC | Parent | Labels | Ready |
|---|---|---|---|---|---|---|---|
| E1 | Getting Started Installation: guided onboarding and DevEx recovery | Epic | Highest | Yes | — | Yes | ✅ |
| T1.1 | Reader sees a clear three-step install framing | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.2 | Reader understands framework vs consumer project | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.3 | Reader follows OS-specific clone and environment steps | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.4 | Reader runs one recommended install command in their project | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.5 | Reader verifies that installation succeeded | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.6 | Advanced and maintainer content sits below the happy path | Task | High | Yes | E1 | Yes | ✅ |
| T1.7 | Reader scans a short table of contents of major sections only | Task | High | Yes | E1 | Yes | ✅ |

## Sync summary (post-push)

| Category | Count | Items |
|---|---|---|
| **CREATED** | 8 | Epic AC-72; Tasks AC-73–AC-79 |
| **UPDATE** | 0 | — |
| **SKIP** | 0 | — |

**Links:** Relates AC-72→AC-63, AC-37, AC-38, DHI-649. Blocks: AC-74→AC-76, AC-75→AC-76, AC-76→AC-77.

---

## Epic: Getting Started Installation: guided onboarding and DevEx recovery

**Jira Key**: AC-72
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-72
**Issue Type**: Epic
**Priority**: Highest

**Description**:
```
h2. Overview

Rewrite the Getting Started Installation docs page so readers of different skill levels (QA, BA, PO, Developer) can download the framework once, run one recommended installer command in their project, and verify success—without treating maintainer tooling, full CLI flags, or submodule internals as part of the numbered happy path.

h2. Business Value

Installation is the first actionable Getting Started step after Prerequisites. Today the page reads like an engineering reference: the happy path is buried, Windows users hit Unix-only samples, and a dense flag table causes decision paralysis. A guided English page shortens time-to-first-success and reduces support load.

h2. Success Metrics

* A non-developer can complete install in three main steps without reading the full CLI flag table or submodule internals
* Windows readers get a working Git Bash path (not Unix-only samples as the only option)
* Reader can recognize success (selection file / context index / clean installer exit) before leaving for MCP Setup
* Page IA: what this is → download once → install into project → verify → upgrade → advanced (details) → next link to MCP Setup
```

**Acceptance Criteria**:
```
(/) Page opens with clear three-step install framing; Prerequisites is a prerequisite link, not a Start-here navigation loop as the primary CTA
(/) Framework-vs-consumer-project mental model is explicit, including a warning not to run the installer inside the framework checkout
(/) Clone/env and install steps provide macOS/Linux vs Windows (Git Bash primary) guidance
(/) One recommended install command is the default path; full CLI flags and vendor/submodule detail are deferred
(/) Verification defines success artifacts, a short failure recovery checklist, and a next-step link to MCP Setup
(/) Maintainer open-framework / adapter-sync content is not a numbered happy-path step
(/) On-this-page TOC shows roughly 4–5 major sections only
(/) Page copy is English (docs SSOT)
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

**Related**: AC-63 (MCP Setup — next step); AC-37 / AC-38 (Prerequisites); DHI-649 (canonical install checklist); DHI-641 (broader docs UX — related, not parent)

---

## Task 1.1: Reader sees a clear three-step install framing

**Parent**: AC-72
**Jira Key**: AC-73
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-73
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It sets the page as a short install path instead of a reference dump or a Start-here bounce.

h2. User Story

As a Getting Started reader, I want the Installation page to open with a short “install in three steps” message, so that I know this page is the install path and I am not sent back to Start here as my first action.

h2. Source Context

UX audit §3 matrix (Intro and Callout); Executive Summary inverted-flow critique; Gate 1 approved workshop installation-ux-recovery; quality review S-01–S-03 applied to sibling tasks.

h2. Requirements

# Opening message states install into the project in about three steps
# Prerequisites (especially Docker running) is linked as a prerequisite, not as a replacement for install steps
# Main headings order the primary path as download → install into project → verify
# Start here may remain as a secondary cross-link, not the dominant first CTA

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Docusaurus tip/info callout; English copy. Target page: website/docs/getting-started/installation.
```

**Acceptance Criteria**:
```
(/) GIVEN I open Installation WHEN I read the top of the page THEN I see a concise statement that I will install Agent Collections into my project in about three steps
(/) GIVEN I am new WHEN I see the opening callout/tip THEN Prerequisites (especially Docker running) is linked as a prerequisite — not as a loop that replaces the install steps
(/) GIVEN I scan the page WHEN I look at the main headings THEN the primary path is ordered as download → install into project → verify (not maintainers → flags → sample install last)
(/) Start here may remain as a secondary cross-link, but it is not the dominant first CTA
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

---

## Task 1.2: Reader understands framework vs consumer project

**Parent**: AC-72
**Jira Key**: AC-74
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-74
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It prevents the common mistake of running the installer inside the framework repository.

h2. User Story

As a non-terminal-fluent user, I want a plain explanation that I download the framework once and then run the installer inside my business project, so that I do not run setup inside the framework repo by mistake.

h2. Source Context

UX audit §2.D (mental model); quality review S-03 (explicit anti-pattern warning).

h2. Requirements

# Explicit two-part model: (A) download toolkit once; (B) install into the business/sample project
# Framework folder may live outside the app repo
# Working directory for the installer is the consumer project, not the agent-collections checkout
# Explicit warning not to run the installer from inside the framework checkout
# AGENT_COLLECTIONS_HOME explained in plain language

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Text diagram or short labeled steps; keep AGENT_COLLECTIONS_HOME plain-language.
```

**Acceptance Criteria**:
```
(/) GIVEN I open Installation WHEN I read before the first commands THEN I see an explicit two-part model: (A) download the toolkit once on my machine; (B) go to my project and install into it
(/) GIVEN I follow Step A WHEN I finish cloning THEN I know the framework folder can live outside my app repo
(/) GIVEN I start Step B WHEN I change directory THEN the page tells me to use my business/sample project folder — not the agent-collections checkout — as the working directory for the installer
(/) GIVEN I might confuse the two folders WHEN I read the mental-model section THEN I see an explicit warning not to run the installer from inside the agent-collections framework checkout
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

---

## Task 1.3: Reader follows OS-specific clone and environment steps

**Parent**: AC-72
**Jira Key**: AC-75
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-75
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It removes the Windows platform barrier caused by Unix-only samples.

h2. User Story

As a macOS, Linux, or Windows user, I want OS-appropriate commands for cloning the framework and setting AGENT_COLLECTIONS_HOME, so that I do not paste Unix syntax into PowerShell and get stuck at step 1.

h2. Source Context

UX audit §2.A and §3 OS matrix; Gate 1: Git Bash primary for Windows; PowerShell env note only.

h2. Requirements

# Tabs (or equivalent) for macOS/Linux and Windows on Step 1
# Windows path directs readers to Git Bash with working paths
# PowerShell at least shows how to set AGENT_COLLECTIONS_HOME (no full PowerShell installer scripting required)
# macOS/Linux default tab keeps clone + export examples copy-pasteable
# In-tab labels must not spam On this page (bold labels and/or toc_max_heading_level: 2)

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Docusaurus Tabs groupId operating-system; installer remains Bash — Windows happy path is Git Bash.
```

**Acceptance Criteria**:
```
(/) GIVEN I open Step 1 (download framework) WHEN I look at the commands THEN I see tabs (or equivalent) for macOS / Linux and Windows
(/) GIVEN I am on Windows WHEN I open the Windows tab THEN I am directed to run the steps in Git Bash (installed with Git for Windows) with paths that work there
(/) GIVEN I prefer PowerShell WHEN I read the Windows guidance THEN I at least see how to set AGENT_COLLECTIONS_HOME in PowerShell, without requiring full PowerShell installer scripting if Git Bash remains the supported path for bash setup-agent-collections.sh
(/) GIVEN I am on macOS/Linux WHEN I use the default tab THEN clone + export AGENT_COLLECTIONS_HOME examples remain correct and copy-pasteable
(/) In-tab headings do not spam On this page (prefer bold labels and/or toc_max_heading_level: 2)
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

---

## Task 1.4: Reader runs one recommended install command in their project

**Parent**: AC-72
**Jira Key**: AC-76
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-76
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)
**Blocked by**: Task 1.2, Task 1.3

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It replaces a twelve-flag decision table with one recommended first-install command.

h2. User Story

As a QA, BA, or PO, I want a single recommended installer command for the common case, so that I am not forced to decide among a dozen CLI flags before first success.

h2. Source Context

UX audit §2.B progressive disclosure; quality review S-01 (Docker precondition at Step 2).

h2. Requirements

# One default copy-paste command for first install (agents + profile; build/MCP as needed)
# Step 2 reminds that Docker Desktop/Engine must be running, links Prerequisites, and names a failure symptom when Docker is not ready
# Standard path does not require choosing vendor, ssot-source, or confluence-space-key
# Plain-language tip for --profile (fullstack recommended; frontend/backend when limiting stack)
# OS tabs or same-shell guidance stay consistent with Step 1
# Default path labeled recommended for most users / non-developers (no early push into submodule/vendor modes)

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Align default flags with live installer SSOT (--build-mcp, --non-interactive, --agents, --profile, MCP defaults as used today). Full flag table belongs in Task 1.6.
```

**Acceptance Criteria**:
```
(/) GIVEN I reach Step 2 WHEN I look for what to run THEN I see one default, copy-paste command suitable for first install (agents + profile called out; Docker/build called out as needed)
(/) GIVEN I am about to run the recommended install command WHEN I read Step 2 THEN I see a clear reminder that Docker Desktop/Engine must be running (with a link to Prerequisites), and what failure symptom means Docker is not ready
(/) GIVEN I only need the standard consumer path WHEN I scan Step 2 THEN I am not required to choose --vendor, --ssot-source, or --confluence-space-key to proceed
(/) GIVEN I wonder what --profile means WHEN I read the adjacent tip THEN I see plain-language options (e.g. fullstack recommended; frontend/backend when limiting stack)
(/) GIVEN OS tabs are used in Step 1 WHEN I run Step 2 THEN matching OS tabs (or clear same shell / Git Bash guidance) appear so path/cd syntax stays consistent
(/) Default path is labeled as the recommended path for most users / non-developers (no early push into submodule/vendor modes)
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

---

## Task 1.5: Reader verifies that installation succeeded

**Parent**: AC-72
**Jira Key**: AC-77
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-77
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)
**Blocked by**: Task 1.4

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It promotes smoke-test / success signals into the main path and routes failures to a short recovery checklist.

h2. User Story

As a framework user, I want an explicit verification step with concrete success signals, so that I know the install worked before I move to MCP Setup.

h2. Source Context

UX audit §2.E buried smoke test; quality review S-02 (failure recovery checklist).

h2. Requirements

# Success artifacts include install-selection.json and docs/context/<project>/INDEX.md (exists or created)
# Clean completion described in plain language (no critical errors / exit 0)
# Failure path shows short recovery checklist: correct project folder, AGENT_COLLECTIONS_HOME set, Docker running / Prerequisites
# Success ends with a clear next-step link to MCP Setup
# Verification is on the main path — not only a buried First successful install sample

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Optional /tmp sample walkthrough may remain under advanced or as a short aside, but must not be the only verification content.
```

**Acceptance Criteria**:
```
(/) GIVEN I finished the recommended install WHEN I follow Verification THEN I know which project artifacts indicate success (at least .agent-collections/install-selection.json and that docs/context/<project>/INDEX.md exists or was created)
(/) GIVEN the installer finished WHEN I read Verification THEN I know a clean completion means exit without critical errors (exit code 0 / no critical failure messaging — wording may be plain language)
(/) GIVEN verification fails (missing selection file, missing context INDEX, or installer error) WHEN I read Verification THEN I see a short recovery checklist (at least: correct project folder, AGENT_COLLECTIONS_HOME set, Docker running / Prerequisites) before being left only with a next-step to MCP Setup
(/) GIVEN verification succeeds WHEN I reach the end of that section THEN I see a clear next-step link to MCP Setup
(/) GIVEN verification is part of the main path WHEN I scan the page THEN I do not have to scroll to a buried First successful install sample as the only smoke test
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

---

## Task 1.6: Advanced and maintainer content sits below the happy path

**Parent**: AC-72
**Jira Key**: AC-78
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-78
**Issue Type**: Task
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It relocates upgrade, submodule, full CLI flags, and maintainer adapter-sync content so they do not look mandatory.

h2. User Story

As a first-time installer, I want upgrade, submodule, full CLI flags, and maintainer adapter-sync content kept out of the numbered happy path, so that optional/advanced topics do not look mandatory.

h2. Source Context

UX audit §2.B, §2.C, §3 step-structure matrix; proposed template Upgrade + details blocks.

h2. Requirements

# Numbered main path never requires open framework / npm run sync:adapters
# Upgrade & Sync section below happy path with upgrade command and short note on preserved local rules
# Advanced collapsible (or clearly labeled) sections cover submodule workflow and full useful-flags table moved out of the default step
# Maintainer adapter-sync / open-framework guidance only in advanced/end content

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Use details/summary blocks; preserve accurate flag meanings from the current page when relocating the table.
```

**Acceptance Criteria**:
```
(/) GIVEN I follow the numbered main path WHEN I complete download → install → verify THEN I never encounter open the framework / npm run sync:adapters as a required numbered step
(/) GIVEN I need to upgrade later WHEN I scroll below the happy path THEN I find a clear Upgrade & Sync section with the upgrade command and a short note that local rules are preserved where the product already does so
(/) GIVEN I need team submodule or full CLI flags WHEN I open Advanced THEN those topics are in collapsible sections (or clearly labeled advanced), including at least submodule workflow and the full useful-flags table moved out of the default step
(/) GIVEN I am a framework maintainer WHEN I look for adapter sync / open-framework guidance THEN it is available in advanced/end content, not in steps 1–3
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`

---

## Task 1.7: Reader scans a short table of contents of major sections only

**Parent**: AC-72
**Jira Key**: AC-79
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-79
**Issue Type**: Task
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started Installation: guided onboarding and DevEx recovery] epic. It reduces On this page noise after the IA rewrite.

h2. User Story

As a scanner, I want the On this page outline limited to a few major sections, so that I can navigate the install path without TOC noise from every nested heading and flag subsection.

h2. Source Context

UX audit §3 TOC matrix; related lesson from AC-37/AC-50 Prerequisites TOC cleanup.

h2. Requirements

# On this page shows roughly 4–5 major sections (happy path + upgrade + advanced)
# Tab inner labels do not duplicate as many TOC entries (bold labels and/or toc_max_heading_level: 2)
# Docs site build passes without reintroducing the old dense TOC

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/installation-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Mirror Prerequisites TOC approach (toc_max_heading_level and/or avoid ### inside tabs).
```

**Acceptance Criteria**:
```
(/) GIVEN I open Installation WHEN I view On this page THEN I see roughly 4–5 major sections (happy path + upgrade + advanced), not a long list of mixed-depth headings
(/) GIVEN OS or client tabs contain inner labels WHEN those labels are present THEN they do not duplicate as many TOC entries (bold labels and/or toc_max_heading_level: 2)
(/) GIVEN the page builds WHEN docs site build runs THEN the page renders without TOC regression that reintroduces the old dense outline
```

**Labels**: `docs`, `getting-started`, `installation`, `workshop-2026-10-14`
