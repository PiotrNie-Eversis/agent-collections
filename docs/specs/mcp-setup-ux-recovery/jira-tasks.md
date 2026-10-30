# mcp-setup-ux-recovery — Jira-ready Tasks

| Field | Value |
|---|---|
| Target project | **AC** |
| Workshop folder | `docs/specs/mcp-setup-ux-recovery/` |
| Gate 1 | Approved 2026-10-14 |
| Quality review | Lite — S-01–S-04 accepted (`quality-review.md`) |
| Issue type rule | Epic → **Task** (never Story as implementable leaf — `jira-backlog-hierarchy`) |
| Push status | **Pushed 2026-10-14** — Epic AC-63, Tasks AC-64–AC-71 |

## Completeness checklist

| # | Summary | Type | Priority | AC | Parent | Labels | Ready |
|---|---|---|---|---|---|---|---|
| E1 | Getting Started MCP Setup: guided onboarding and DevEx recovery | Epic | Highest | Yes | — | Yes | ✅ |
| T1.1 | Reader gets a plain-language mental model for MCP | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.2 | Reader chooses a setup path by role | Task | High | Yes | E1 | Yes | ✅ |
| T1.3 | Reader can complete core local server setup first | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.4 | Reader connects the core server via Cursor and Claude Code tabs | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.5 | Reader verifies that MCP connected successfully | Task | Highest | Yes | E1 | Yes | ✅ |
| T1.6 | Reader understands the project folder requirement in plain language | Task | High | Yes | E1 | Yes | ✅ |
| T1.7 | Optional integrations are clearly non-blocking | Task | High | Yes | E1 | Yes | ✅ |
| T1.8 | Reader can self-recover via a troubleshooting table | Task | High | Yes | E1 | Yes | ✅ |

---

## Epic: Getting Started MCP Setup: guided onboarding and DevEx recovery

**Jira Key**: AC-63
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-63
**Issue Type**: Epic
**Priority**: Highest

**Description**:
```
h2. Overview

Rewrite the Getting Started MCP Setup docs page so readers of different skill levels (QA, BA, PO, Developer) can configure the core eversis-collections server, connect Cursor or Claude Code, verify success, and recover from common failures—without treating optional MCP servers as blockers.

h2. Business Value

MCP Setup is the most technical and critical step in Getting Started. Today mixed jargon, mixed clients, and optional integrations block non-developers and slow developers. A guided English page reduces onboarding failure and support load.

h2. Success Metrics

* A non-developer can follow a Cursor-first path and recognize success without hand-editing JSON when the product UI allows it
* Required path covers only the core eversis-collections server; optional integrations are clearly later/optional
* Reader can confirm success (status and/or chat smoke check) and recover via a troubleshooting table
* Page IA: what this step is → core server → connect editor → verify → project folder note → optional integrations → troubleshooting → next links
```

**Acceptance Criteria**:
```
(/) Page leads with a plain-language MCP mental model before advanced catalogs
(/) Role guidance recommends Cursor + core server for QA/BA/PO
(/) Core server setup is Step 1 and does not require third-party API tokens
(/) Cursor and Claude Code have separate client instructions; Claude Desktop has only an unsupported disclaimer line
(/) Verification defines success and failure next steps, including Getting Started next links
(/) Optional integrations are visibly non-blocking
(/) Troubleshooting covers disconnected status, Docker/image issues, wrong project folder, and duplicate User vs project MCP entries
(/) Page copy is English (docs SSOT)
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

**Related**: AC-37 / AC-38 (Prerequisites); DHI-641 (broader docs UX — related, not parent)

---

## Task 1.1: Reader gets a plain-language mental model for MCP

**Parent**: AC-63
**Jira Key**: AC-64
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-64
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It removes the first cognitive barrier: readers must understand what MCP is before Docker and editor settings.

h2. User Story

As a QA, BA, or Product Owner, I want a short explanation of what MCP is and why I need a local server, so that Docker and editor settings make sense before I copy any commands.

h2. Source Context

UX audit §1.A (missing mental model); recommended IA item 1; Gate 1 approved workshop mcp-setup-ux-recovery.

h2. Requirements

# Short tip or paragraph at the top explains MCP as giving the AI editor access to project tools, rules, and context (not a cloud product to buy)
# Intro states the core skills server runs locally and connects to the editor
# MCP is introduced before multi-server catalogs or advanced env cutover tables
# Intro does not require knowing volume mounts, Compose internals, or JSON schema

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Audit suggests a Docusaurus tip/callout; keep wording product-accurate (skills + domain context tools). Target page: website/docs/getting-started/mcp-setup (English).
```

**Acceptance Criteria**:
```
(/) GIVEN I open MCP Setup WHEN I read the top of the page THEN I see a one-paragraph (or short tip) analogy that MCP gives the AI editor “hands” for project tools/rules/context — not a cloud product I must buy
(/) GIVEN I am a non-developer WHEN I finish the intro THEN I understand that the core skills server runs locally (e.g. via Docker) and connects to my editor
(/) GIVEN the intro WHEN I scan the page THEN MCP is introduced before any multi-server catalog or advanced env cutover tables
(/) Intro does not require knowing “volume mount”, Compose internals, or JSON schema
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.2: Reader chooses a setup path by role

**Parent**: AC-63
**Jira Key**: AC-65
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-65
**Issue Type**: Task
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It stops readers from assuming every MCP and every IDE is mandatory.

h2. User Story

As a Getting Started reader, I want to see which editor and which servers my role needs, so that I do not assume I must configure every MCP and every IDE.

h2. Source Context

UX audit §1.E; proposed role table (QA/BA/PO → Cursor; Dev → Cursor or Claude Code; Maintainer → advanced).

h2. Requirements

# Scannable role guidance recommends Cursor + core server only for QA/BA/PO (low difficulty)
# Developer path allows optional integrations later, not for first success
# Framework maintainer / advanced non-Docker path is labeled advanced and does not dominate the default path

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Table or equivalent scannable layout; Cursor labeled recommended for non-technical roles.
```

**Acceptance Criteria**:
```
(/) GIVEN I open MCP Setup WHEN I look for guidance by role THEN I see a clear recommendation for QA/BA/PO (Cursor + core server only, low difficulty)
(/) GIVEN I am a Developer WHEN I use the same section THEN I see that optional integrations (Jira/Figma/Playwright, etc.) are allowed later, not required for first success
(/) GIVEN I am a framework maintainer WHEN I read the role guidance THEN advanced non-Docker paths are labeled advanced and do not dominate the default path
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.3: Reader can complete core local server setup first

**Parent**: AC-63
**Jira Key**: AC-66
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-66
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It makes building/preparing only the core eversis-collections server the first actionable step.

h2. User Story

As a framework user, I want the first actionable step to be building/running only the core eversis-collections server, so that I get a working foundation before optional tools.

h2. Source Context

UX audit §1.E and summary; quality review S-01 (Prerequisites callout at page top); related AC-37/AC-38 Prerequisites.

h2. Requirements

# Top-of-page callout/link: Prerequisites and Docker Engine must be ready before Step 1
# Step 1 provides copy-paste commands to prepare the core local server image/service
# macOS and Windows get clear OS-specific command variants (tabs or equivalent)
# Step 1 does not ask for Jira/Figma/API tokens
# If Docker is not running, page points to Prerequisites / Engine running recovery
# Commands and env names match live framework SSOT (AGENT_COLLECTIONS_HOME, Compose-based installer entry)—not legacy CURSOR_COLLECTIONS_HOME as primary

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Audit draft used simplified docker run examples; Implement must reconcile with live Compose/docker compose + installer behavior on the current page. Prefer linking Prerequisites recovery rather than duplicating Windows Docker install content.
```

**Acceptance Criteria**:
```
(/) GIVEN I open MCP Setup before finishing Prerequisites WHEN I read the top of the page THEN I see a clear link/callout that Docker Engine (and the Prerequisites checklist) must be ready before Step 1
(/) GIVEN Prerequisites are already met (Docker Engine running) WHEN I follow Step 1 on MCP Setup THEN I get copy-paste commands to prepare the core local server image/service
(/) GIVEN I am on macOS or Windows WHEN I open Step 1 THEN OS-specific command tabs (or clear OS variants) are available so I do not guess shell syntax
(/) GIVEN I only need framework skills WHEN I finish Step 1 THEN I have not been asked for Jira/Figma/API tokens
(/) GIVEN Docker is not running WHEN the page warns me THEN I am pointed to Prerequisites / “Engine running” recovery rather than buried mid-page
(/) Primary commands use AGENT_COLLECTIONS_HOME and Compose-based entry consistent with the installer SSOT
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.4: Reader connects the core server via Cursor and Claude Code tabs

**Parent**: AC-63
**Jira Key**: AC-67
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-67
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It separates client instructions and prevents duplicate MCP configuration.

h2. User Story

As a Cursor or Claude Code user, I want client-specific setup steps in separate tabs, so that I know exactly where to click or which command to run and I do not mix configs across tools.

h2. Source Context

UX audit §1.B; Gate 1: Claude Desktop out of v1 (one-line disclaimer only); quality review S-03 (installer vs manual GUI).

h2. Requirements

# Tabs (or equivalent) for Cursor | Claude Code only; Cursor is the default for the non-technical path
# Cursor path is GUI-oriented (Settings → MCP)
# Claude Code path covers CLI registration and how to list servers
# Exactly one line: “Claude Desktop is not a supported Getting Started path yet.” — no Desktop setup tab
# Reader using one editor is not told to configure the other
# If installer already wrote project MCP config: enable existing entry; do not duplicate in User settings; manual add only when installer was not used

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Docusaurus Tabs groupId mcp-client; keep toc_max_heading_level so in-tab headings do not spam the TOC. Preserve accuracy of installer-written .cursor/mcp.json / .mcp.json vs User config.
```

**Acceptance Criteria**:
```
(/) GIVEN I use Cursor WHEN I open the client-setup section THEN I see GUI-oriented steps (Settings → MCP → add server) with Cursor as the default tab for the recommended non-technical path
(/) GIVEN I use Claude Code WHEN I select its tab THEN I see CLI registration steps and how to list configured servers
(/) GIVEN I only use one editor WHEN I follow its tab THEN I am not told I must configure the other clients
(/) GIVEN I look for Claude Desktop WHEN I read the client-setup section THEN I see exactly one clear line: “Claude Desktop is not a supported Getting Started path yet.” (no Desktop setup tab or JSON walkthrough)
(/) GIVEN the installer already wrote the project MCP config WHEN I follow the Cursor (or Claude Code) connect steps THEN the page tells me whether to enable the existing entry, avoid duplicating it in User settings, or only add manually when the installer was not used — so I do not end up with two conflicting eversis-collections servers
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.5: Reader verifies that MCP connected successfully

**Parent**: AC-63
**Jira Key**: AC-68
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-68
**Issue Type**: Task
**Priority**: Highest
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It closes the feedback loop so readers know setup worked before Quick Wins.

h2. User Story

As a framework user, I want an explicit verification step with a visible success signal, so that I know whether setup worked before I move to Quick Wins.

h2. Source Context

UX audit §1.F; quality review S-02 (What’s next links).

h2. Requirements

# Verification describes UI success (e.g. green status / tools listed for eversis-collections)
# Documented smoke prompt expects a core MCP tool call and project confirmation
# Failure path points to Troubleshooting
# Success path shows Getting Started next-step links (at least Quick Wins; Main Flow optional if still in IA)

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Align expected tool names with the live server (eversis_skills_*, eversis_context_*).
```

**Acceptance Criteria**:
```
(/) GIVEN I finished connecting the editor WHEN I follow Verification THEN I know what “success” looks like in the UI (e.g. green status / tools listed for eversis-collections)
(/) GIVEN I can open the AI chat WHEN I run the documented smoke prompt THEN the assistant is expected to use a core MCP tool (e.g. skills or context index) and confirm project connection
(/) GIVEN verification fails WHEN I read the same section THEN I am directed to Troubleshooting rather than left without a next action
(/) GIVEN verification succeeds WHEN I reach the end of the verification (or page footer) THEN I see clear next-step links to continue Getting Started (at least Quick Wins; Main Flow optional if that route stays in the IA)
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.6: Reader understands the project folder requirement in plain language

**Parent**: AC-63
**Jira Key**: AC-69
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-69
**Issue Type**: Task
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It explains the working-directory / consumer project root requirement without Docker jargon.

h2. User Story

As a non-developer, I want a short warning about opening the correct project folder, so that context tools work without me needing to understand Docker volume mounts.

h2. Source Context

UX audit §1.D (Domain Context / working directory gotcha).

h2. Requirements

# Warning tells reader to open the consumer project root (the repo they work in), not a random subfolder or only the framework checkout when that would break context
# Any remaining technical terms are explained in everyday language or replaced with “current project folder” style wording
# Same root cause appears again in Troubleshooting for empty/wrong path symptoms

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Preserve accuracy of consumer vs framework mounts from current docs; simplify language, do not remove the requirement.
```

**Acceptance Criteria**:
```
(/) GIVEN I need domain/context tools WHEN I read the working-directory note THEN I am told to open the consumer project root (the repo I work in), not a random subfolder or only the framework checkout when that would break context
(/) GIVEN the note uses any technical terms WHEN they appear THEN they are explained in everyday language or replaced with “current project folder” style wording
(/) GIVEN context tools fail with empty/wrong path symptoms WHEN I use Troubleshooting THEN I find the same root-cause called out again
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.7: Optional integrations are clearly non-blocking

**Parent**: AC-63
**Jira Key**: AC-70
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-70
**Issue Type**: Task
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It keeps optional MCP servers from blocking first success.

h2. User Story

As a Getting Started reader, I want optional MCP servers (Jira, Figma, Playwright, etc.) called out as optional, so that I am not blocked waiting for API keys before my first successful session.

h2. Source Context

UX audit §1.E; recommended IA item 6.

h2. Requirements

# Visible callout after core setup: optional integrations are not required for framework start
# Short overview only; details link to Reference (or equivalent)
# When listing servers, eversis-collections is visually primary / required

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Current page already lists many servers; reorder/relabel rather than invent new products.
```

**Acceptance Criteria**:
```
(/) GIVEN I scroll past core setup WHEN I reach integrations THEN a visible callout states they are not required for framework start
(/) GIVEN I want details later WHEN I click through THEN I reach Reference (or equivalent) docs for those adapters — this page stays a short overview only
(/) GIVEN the page lists what each MCP is for WHEN core vs optional are shown THEN eversis-collections is visually primary / required
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Task 1.8: Reader can self-recover via a troubleshooting table

**Parent**: AC-63
**Jira Key**: AC-71
**Status**: Backlog
**URL**: https://eversis.atlassian.net/browse/AC-71
**Issue Type**: Task
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Getting Started MCP Setup: guided onboarding and DevEx recovery] epic. It provides symptom → cause → fix recovery for common MCP Setup failures.

h2. User Story

As a framework user stuck on a red/disconnected MCP status, I want a symptom → cause → fix table, so that I can unblock myself without filing a ticket for common mistakes.

h2. Source Context

UX audit §1.C, §1.F; quality review S-04 (duplicate MCP troubleshooting row); related AC-37/AC-38 Prerequisites screenshots.

h2. Requirements

# Table row: disconnected/red → Docker Engine not running → fix + Prerequisites link
# Rows for docker not found / image not built with restart-editor / rebuild remedies
# Row for empty/wrong path context tools → open correct project root
# Windows virtualization/WSL issues point to safe recovery or Prerequisites (no deep Hyper-V essay on this page)
# Row for duplicate User vs project eversis-collections → keep installer/project entry, remove duplicate
# Windows path/escaping guidance referenced where env vars are documented

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: docs/specs/mcp-setup-ux-recovery/ (after push, prefer docs/specs/<AC-key>-topic/ per AC-32)
* Research: *.research.md — required before plan
* Plan: *.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): @eversis-implement / @eversis-review when available.

h2. Technical Notes

Prefer linking AC-37/AC-38 Prerequisites recovery screenshots over duplicating large Windows install guides here.
```

**Acceptance Criteria**:
```
(/) GIVEN MCP shows disconnected / red WHEN I open Troubleshooting THEN I see Docker Engine not running as a primary cause with a concrete fix (including link/pointer to Prerequisites where appropriate)
(/) GIVEN docker is not found or the image is missing WHEN I match the symptom THEN I get restart-editor / rebuild-image style remedies
(/) GIVEN context tools return empty or path errors WHEN I match the symptom THEN I am told to open the correct project root / fix the working-directory mount
(/) GIVEN I am on Windows with virtualization/WSL issues WHEN that row is in scope THEN the table points to a safe recovery path (or Prerequisites) without requiring deep Hyper-V knowledge on this page
(/) GIVEN I see two eversis-collections entries, wrong project tree, or flaky disconnect after “adding” the server again WHEN I open Troubleshooting THEN a row covers duplicate User vs project MCP config and tells me to keep the installer/project entry and remove the duplicate
```

**Labels**: `docs`, `getting-started`, `mcp-setup`, `workshop-2026-10-14`

---

## Dependencies (for Jira links after push)

| From | To | Link type |
|---|---|---|
| T1.4 | T1.3 | Blocks / is blocked by |
| T1.5 | T1.4 | Blocks / is blocked by |
| T1.3 | AC-37 / AC-38 | Relates |
| Epic | DHI-641 | Relates (optional) |
| T1.6 | T1.5 | Relates |
| T1.7 | T1.3 | Relates |
| T1.8 | T1.3–T1.6 | Relates |

---

## Gate 2 — Push complete (2026-10-14)

| Action | Result |
|---|---|
| Created | Epic **AC-63** + Tasks **AC-64–AC-71** (8) |
| Parent | All Tasks → AC-63 (verified via JQL `parent = AC-63`) |
| Relates | AC-63 ↔ AC-37, AC-63 ↔ AC-38 |
| Blocks | AC-66 → AC-67 → AC-68 |
| Status | All Backlog |
| Verification | Summaries, parent links, Task issue type, AC in descriptions — PASS |
