# mcp-setup-ux-recovery - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-14 |
| Participants | Documentation / DevEx analysis (report); BA extraction session |
| Source Materials | UX/IA/DevEx audit for `/docs/getting-started/mcp-setup`; current `website/docs/getting-started/mcp-setup.md`; `docs/context/agent-collections/task-baseline.md` |
| Intent Brief | [intent-brief.md](./intent-brief.md) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` |
| Total Epics | 1 |
| Total Stories | 8 |
| Jira note | On project **AC**, create implementable items as **Task** (board: Epic → Task/Bug). Story wording below is the BA format. |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | MCP Setup page: guided onboarding and DevEx recovery | 8 | Highest |

## Epic 1: MCP Setup page: guided onboarding and DevEx recovery

**Business Description**: Getting Started readers must configure Model Context Protocol so the AI editor can use framework skills and project context. Today the page mixes jargon, clients, optional servers, and env/path details, which blocks QA/BA/PO and slows developers. This epic delivers a single guided MCP Setup page: plain mental model, role path, core-first setup, per-client and OS instructions, verification, and self-serve troubleshooting.

**Success Criteria**:
- A non-developer (QA/BA/PO) can follow a Cursor-first path and recognize success without editing JSON by hand when the product UI allows it.
- Required path only covers the core `eversis-collections` server; optional integrations are clearly marked as later/optional.
- Reader can confirm success (status indicator and/or chat tool check) and recover from the top failure cases via a troubleshooting table.
- Page IA follows: what this step is → run core server → connect editor → verify → project folder note → optional integrations → troubleshooting → next links.

### Story 1.1: Reader gets a plain-language mental model for MCP

**User Story**: As a QA, BA, or Product Owner, I want a short explanation of what MCP is and why I need a local server, so that Docker and editor settings make sense before I copy any commands.

**Source**: Audit §1.A (missing mental model); recommended IA item 1; tip “Czym jest MCP w 10 sekund?” in proposed template.

**Acceptance Criteria**:
- [ ] GIVEN I open MCP Setup WHEN I read the top of the page THEN I see a one-paragraph (or short tip) analogy that MCP gives the AI editor “hands” for project tools/rules/context — not a cloud product I must buy.
- [ ] GIVEN I am a non-developer WHEN I finish the intro THEN I understand that the core skills server runs locally (e.g. via Docker) and connects to my editor.
- [ ] GIVEN the intro WHEN I scan the page THEN MCP is introduced before any multi-server catalog or advanced env cutover tables.

**Additional Acceptance Checks**:
- Intro does not require knowing “volume mount”, Compose internals, or JSON schema.

**High-Level Technical Notes**: Audit suggests Docusaurus tip/callout; keep wording product-accurate (skills + domain context tools).

**Priority**: Highest

### Story 1.2: Reader chooses a setup path by role

**User Story**: As a Getting Started reader, I want to see which editor and which servers my role needs, so that I do not assume I must configure every MCP and every IDE.

**Source**: Audit §1.E (core vs optional blur); recommended IA; proposed template §1 role table (QA/BA/PO → Cursor; Dev → Cursor or Claude Code; Maintainer → advanced).

**Acceptance Criteria**:
- [ ] GIVEN I open MCP Setup WHEN I look for guidance by role THEN I see a clear recommendation for QA/BA/PO (Cursor + core server only, low difficulty).
- [ ] GIVEN I am a Developer WHEN I use the same section THEN I see that optional integrations (Jira/Figma/Playwright, etc.) are allowed later, not required for first success.
- [ ] GIVEN I am a framework maintainer WHEN I read the role guidance THEN advanced non-Docker paths are labeled advanced and do not dominate the default path.

**High-Level Technical Notes**: Table or equivalent scannable layout; Cursor labeled recommended for non-technical roles.

**Priority**: High

### Story 1.3: Reader can complete core local server setup first

**User Story**: As a framework user, I want the first actionable step to be building/running only the core `eversis-collections` server, so that I get a working foundation before optional tools.

**Source**: Audit §1.E, summary points 1 & 3; recommended IA item 2; proposed template §2 Docker step with OS tabs.

**Acceptance Criteria**:
- [ ] GIVEN I open MCP Setup before finishing Prerequisites WHEN I read the top of the page THEN I see a clear link/callout that Docker Engine (and the Prerequisites checklist) must be ready before Step 1.
- [ ] GIVEN Prerequisites are already met (Docker Engine running) WHEN I follow Step 1 on MCP Setup THEN I get copy-paste commands to prepare the core local server image/service.
- [ ] GIVEN I am on macOS or Windows WHEN I open Step 1 THEN OS-specific command tabs (or clear OS variants) are available so I do not guess shell syntax.
- [ ] GIVEN I only need framework skills WHEN I finish Step 1 THEN I have not been asked for Jira/Figma/API tokens.
- [ ] GIVEN Docker is not running WHEN the page warns me THEN I am pointed to Prerequisites / “Engine running” recovery rather than buried mid-page.

**Additional Acceptance Checks**:
- Commands and env names match current framework SSOT (`AGENT_COLLECTIONS_HOME`, Compose-based entry as used by the installer) — not legacy `CURSOR_COLLECTIONS_HOME` as the primary path.

**High-Level Technical Notes**: Audit draft used simplified `docker run` examples; Implement must reconcile with live Compose/`docker compose` + installer behavior documented in the current page.

**Priority**: Highest

### Story 1.4: Reader connects the core server in their AI editor via client tabs

**User Story**: As a Cursor or Claude Code user, I want client-specific setup steps in separate tabs, so that I know exactly where to click or which command to run and I do not mix configs across tools.

**Source**: Audit §1.B (mixed clients); market pattern “Tabbed Client Configuration”; recommended IA item 3; Gate 1 (2026-10-14): Claude Desktop out of v1 — one-line disclaimer only.

**Acceptance Criteria**:
- [ ] GIVEN I use Cursor WHEN I open the client-setup section THEN I see GUI-oriented steps (Settings → MCP → add server) with Cursor as the default tab for the recommended non-technical path.
- [ ] GIVEN I use Claude Code WHEN I select its tab THEN I see CLI registration steps and how to list configured servers.
- [ ] GIVEN I only use one editor WHEN I follow its tab THEN I am not told I must configure the other clients.
- [ ] GIVEN I look for Claude Desktop WHEN I read the client-setup section THEN I see exactly one clear line: “Claude Desktop is not a supported Getting Started path yet.” (no Desktop setup tab or JSON walkthrough).
- [ ] GIVEN the installer already wrote the project MCP config WHEN I follow the Cursor (or Claude Code) connect steps THEN the page tells me whether to enable the existing entry, avoid duplicating it in User settings, or only add manually when the installer was not used — so I do not end up with two conflicting `eversis-collections` servers.

**High-Level Technical Notes**: Docusaurus `<Tabs groupId="mcp-client">` with Cursor | Claude Code only; keep `toc_max_heading_level` so in-tab headings do not spam the TOC (audit §“Dlaczego ten układ…”).

**Priority**: Highest

### Story 1.5: Reader verifies that MCP connected successfully

**User Story**: As a framework user, I want an explicit verification step with a visible success signal, so that I know whether setup worked before I move to Quick Wins.

**Source**: Audit §1.F (no healthcheck); market pattern “Visual Healthcheck”; recommended IA item 4; proposed template §4.

**Acceptance Criteria**:
- [ ] GIVEN I finished connecting the editor WHEN I follow Verification THEN I know what “success” looks like in the UI (e.g. green status / tools listed for `eversis-collections`).
- [ ] GIVEN I can open the AI chat WHEN I run the documented smoke prompt THEN the assistant is expected to use a core MCP tool (e.g. skills or context index) and confirm project connection.
- [ ] GIVEN verification fails WHEN I read the same section THEN I am directed to Troubleshooting rather than left without a next action.
- [ ] GIVEN verification succeeds WHEN I reach the end of the verification (or page footer) THEN I see clear next-step links to continue Getting Started (at least Quick Wins; Main Flow optional if that route stays in the IA).

**High-Level Technical Notes**: Align expected tool names with what the live server actually exposes (`eversis_skills_*`, `eversis_context_*`).

**Priority**: Highest

### Story 1.6: Reader understands the project folder requirement in plain language

**User Story**: As a non-developer, I want a short warning about opening the correct project folder, so that context tools work without me needing to understand Docker volume mounts.

**Source**: Audit §1.D (Domain Context / working directory gotcha); recommended IA item 5; proposed template §5 warning callout.

**Acceptance Criteria**:
- [ ] GIVEN I need domain/context tools WHEN I read the working-directory note THEN I am told to open the consumer project root (the repo I work in), not a random subfolder or only the framework checkout when that would break context.
- [ ] GIVEN the note uses any technical terms WHEN they appear THEN they are explained in everyday language or replaced with “current project folder” style wording.
- [ ] GIVEN context tools fail with empty/wrong path symptoms WHEN I use Troubleshooting THEN I find the same root-cause called out again.

**High-Level Technical Notes**: Preserve accuracy of consumer vs framework mounts from current docs; simplify language, do not remove the requirement.

**Priority**: High

### Story 1.7: Optional integrations are clearly non-blocking

**User Story**: As a Getting Started reader, I want optional MCP servers (Jira, Figma, Playwright, etc.) called out as optional, so that I am not blocked waiting for API keys before my first successful session.

**Source**: Audit §1.E; recommended IA item 6; proposed template §6 info callout + short bullets + link to Reference.

**Acceptance Criteria**:
- [ ] GIVEN I scroll past core setup WHEN I reach integrations THEN a visible callout states they are not required for framework start.
- [ ] GIVEN I want details later WHEN I click through THEN I reach Reference (or equivalent) docs for those adapters — this page stays a short overview only.
- [ ] GIVEN the page lists what each MCP is for WHEN core vs optional are shown THEN `eversis-collections` is visually primary / required.

**High-Level Technical Notes**: Current page already lists many servers; reorder/relabel rather than invent new products.

**Priority**: High

### Story 1.8: Reader can self-recover via a troubleshooting table

**User Story**: As a framework user stuck on a red/disconnected MCP status, I want a symptom → cause → fix table, so that I can unblock myself without filing a ticket for common mistakes.

**Source**: Audit §1.C (env/paths), §1.F; recommended IA item 7; proposed template §7 troubleshooting table; summary point 4.

**Acceptance Criteria**:
- [ ] GIVEN MCP shows disconnected / red WHEN I open Troubleshooting THEN I see Docker Engine not running as a primary cause with a concrete fix (including link/pointer to Prerequisites where appropriate).
- [ ] GIVEN `docker` is not found or the image is missing WHEN I match the symptom THEN I get restart-editor / rebuild-image style remedies.
- [ ] GIVEN context tools return empty or path errors WHEN I match the symptom THEN I am told to open the correct project root / fix the working-directory mount.
- [ ] GIVEN I am on Windows with virtualization/WSL issues WHEN that row is in scope THEN the table points to a safe recovery path (or Prerequisites) without requiring deep Hyper-V knowledge on this page.
- [ ] GIVEN I see two `eversis-collections` entries, wrong project tree, or flaky disconnect after “adding” the server again WHEN I open Troubleshooting THEN a row covers duplicate User vs project MCP config and tells me to keep the installer/project entry and remove the duplicate.

**Additional Acceptance Checks**:
- Table covers at least: disconnected status, docker not found, image not built, wrong working directory, duplicate User vs project MCP; Windows path/escaping guidance referenced where env vars are documented.

**High-Level Technical Notes**: Prefer linking AC-37/AC-38 Prerequisites recovery screenshots over duplicating large Windows install guides here.

**Priority**: High

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.3 | Prerequisites Docker guidance (AC-37/AC-38) | Related to | MCP Setup assumes Engine running; links out rather than re-owning Prerequisites |
| Story 1.4 | Story 1.3 | Blocked by | Editor connect steps assume core server/image instructions exist |
| Story 1.5 | Story 1.4 | Blocked by | Verification assumes client connection steps exist |
| Story 1.6 | Story 1.5 | Related to | Working-directory note supports verification failures for context tools |
| Story 1.7 | Story 1.3 | Related to | Optional section must appear after required core path |
| Story 1.8 | Stories 1.3–1.6 | Related to | Troubleshooting rows mirror earlier success/failure signals |
| Epic 1 | DHI-641 | Related to | Broader docs UX epic; this epic is page-scoped |
| Epic 1 | AC-37 / AC-38 | Related to | Prerequisites UX/Docker; complementary Getting Started |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | One new epic is enough; eight tasks map to the audit IA without separate epics per client. | High | Split epic if stakeholders want Cursor-only MVP vs multi-client as separate deliveries |
| 2 | Docs remain English SSOT always; Polish audit text is requirements input only. | High | Locked Gate 1 — no localization stories |
| 3 | Live commands must follow current Compose + `AGENT_COLLECTIONS_HOME` + installer merge — audit `docker run` snippets are UX examples, not final copy. | High | Wrong copy would break onboarding; Implement reconciles with SSOT |
| 4 | Claude Desktop is out of v1 except the one-line unsupported disclaimer (Gate 1). | High | Locked Gate 1 |
| 5 | Jira target is project **AC**, new standalone epic, implementable items as **Task**. | High | Locked Gate 1 |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Changing MCP server code, Docker image build pipeline, or installer behavior (unless a docs fix reveals a product defect — then a separate bug).
- Full rewrite of Prerequisites, Quick Wins, Installation, or Main Flow pages.
- Deep how-tos for every optional MCP on this page.
- Broader DHI-641 IA items (sidebar clusters, Introduction glossary, homepage diagram sync).
- Claude Desktop setup walkthrough (unsupported Getting Started path; one-line disclaimer only — Story 1.4).
- Non-English page copy.

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| — | None | Gate 1 locked 2026-10-14 | — |

## Gate 1 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-10-14 — Epic OK; Claude Desktop = no (disclaimer line only); new AC epic; English-only page |
