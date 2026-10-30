# ac-63-mcp-setup-recovery - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | AC-63 (Epic) + AC-64–AC-71 (Tasks) |
| Title            | Getting Started MCP Setup: guided onboarding and DevEx recovery |
| Description      | Single-page docs rewrite of MCP Setup covering all eight child Tasks; MDX + Tabs; text-only; demote env cutover / volume deep-dive after core path. |
| Priority         | Highest |
| Related Research | [ac-63-mcp-setup-recovery.research.md](./ac-63-mcp-setup-recovery.research.md) |
| Workshop input   | `docs/specs/mcp-setup-ux-recovery/` (Gate 1 approved) |

## Wildly Important Goal

**Goal**: A non-developer can complete a Cursor-first core `eversis-collections` setup, recognize success, and self-recover—without treating optional MCP servers as blockers.

**Success Measure**: AC-64–AC-71 acceptance criteria are met on the published Getting Started MCP Setup page; page IA matches the workshop order; `npm run website:build` passes; Fine QA comment includes a per-ticket summary for AC-64 through AC-71.

**Do NOT touch / do NOT add**:
- Installer scripts, Docker image build pipeline, Compose runtime behavior (docs-only unless a product bug is discovered)
- Full rewrite of Prerequisites, Installation, Quick Wins, Start here, or Main Flow
- Deep how-tos for every optional third-party MCP on this page (short overview + Reference links only)
- Claude Desktop setup walkthrough (one-line unsupported disclaimer only)
- Screenshots / `website/static/img/getting-started/mcp-setup/` (Gap Q3: text-only)
- Non-English page copy
- Broader DHI-641 IA (sidebar clusters, Introduction framing, etc.)
- New npm dependencies

## Proposed Solution

Rewrite Getting Started MCP Setup as one MDX page (convert `mcp-setup.md` → `mcp-setup.mdx`) with this IA:

```text
what MCP is → role path → Prerequisites callout → Step 1 core server (OS tabs)
  → connect editor (Cursor | Claude Code tabs + Claude Desktop disclaimer)
  → verify → project folder note → optional integrations
  → troubleshooting (+ demoted env cutover / volume advanced)
  → next links
```

1. **Scaffold** — MDX frontmatter (`sidebar_position: 3`, `toc_max_heading_level: 2`), Tabs imports, delete or replace the `.md` file so Docusaurus keeps route `/docs/getting-started/mcp-setup`.
2. **AC-64 / AC-65** — Plain-language MCP tip + role guidance (QA/BA/PO → Cursor + core only; Dev → optional later; Maintainer → advanced, not primary).
3. **AC-66** — Top callout that Docker Engine / Prerequisites must be ready; Step 1 copy-paste Compose commands with macOS/Windows OS tabs; no third-party API tokens; SSOT = `AGENT_COLLECTIONS_HOME` + `docker compose` (not audit `docker run` examples).
4. **AC-67** — Client Tabs (`groupId="mcp-client"`): Cursor GUI-oriented default; Claude Code CLI; one-line Claude Desktop unsupported; installer-written project config vs avoid User duplicate.
5. **AC-68 / AC-69** — Verification (success UI signal + smoke prompt using real tool names; failure → Troubleshooting; next links to Quick Wins); plain-language project-folder note.
6. **AC-70 / AC-71 + Gap Q4** — Optional integrations callout (non-blocking); troubleshooting symptom→cause→fix table; demote env cutover table and volume/mount detail into Troubleshooting / advanced (preserve or retarget inbound anchors from Prerequisites / Domain Context / eversis-collections reference).
7. **Build + Review** — `npm run website:build`; Code Reviewer via `eversis-review`; Fine with **QA summary per AC-64…AC-71**.

Route docs implementation via Repo Docs Writer patterns (`eversis-writing-repo-documentation`). No Figma / no `[REUSE]` UI verification.

## Current Implementation Analysis

### Already Implemented

- MCP Setup page (Markdown) — `website/docs/getting-started/mcp-setup.md` — Compose + `AGENT_COLLECTIONS_HOME` commands, installer merge, User vs workspace caution, Claude Code note, domain-context volume section, short Verify, Next links
- Prerequisites recovery / Docker — `website/docs/getting-started/prerequisites.mdx` — link target for Engine-running precondition (AC-37/AC-38)
- Tabs / TOC pattern — `prerequisites.mdx`, `start-here.mdx` — reuse `@theme/Tabs`, `toc_max_heading_level: 2`, role guidance tone
- Installer / Compose SSOT — `scripts/setup-agent-collections.sh`, `docker-compose.yml`, `templates/mcp.json` — reference for accurate command copy only

### To Be Modified

- `website/docs/getting-started/mcp-setup.md` → replace with `mcp-setup.mdx` — full IA rewrite
- Inbound deep links that target `#domain-context-needs-the-project-volume-not-just-the-framework-volume` (and similar) — update anchors or add explicit heading ids so links do not 404:
  - `website/docs/getting-started/prerequisites.mdx`
  - `website/docs/reference/domain-context.md`
  - `website/docs/reference/integrations/eversis-collections.md`
- Path mentions of `mcp-setup.md` in repo docs (README, architecture tables) — update extension to `.mdx` where they point at the file on disk (route links without extension stay valid)

### To Be Created

- `website/docs/getting-started/mcp-setup.mdx` — new MDX SSOT for the page (after `.md` removal)

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | Delivery unit | Whole epic AC-64–AC-71; Fine QA summary per child ticket | ✅ Resolved |
| 2 | MDX + Tabs | Convert to `.mdx`; client + OS Tabs; `toc_max_heading_level: 2` | ✅ Resolved |
| 3 | Screenshots | Text-only | ✅ Resolved |
| 4 | Env cutover / volume | Demote after core path into Troubleshooting / advanced | ✅ Resolved |
| 5 | Nice-to-have verify scope | Implement NTH-I3/I4/I5; verify-only D1/D2/Dup2/Dup3/I6; Important out of scope | ✅ Resolved (`Q5. OK;`) |

## Technical Context

### Project Instructions

- `AGENTS.md` — framework repo; website docs under `website/docs/`
- `.cursor/rules/eversis-project-stack.mdc` — quality: `npm run website:build`; load `eversis-writing-repo-documentation` for docs (not BA Docs / frontend skills)
- Delivery Standard — specs under `docs/specs/<key>-<topic>/`
- `jira-backlog-hierarchy` — implementable leaves are Tasks; epic plan may still deliver the whole page and close AC-64–AC-71 together

### Architecture & Patterns

- Docusaurus MDX; Getting Started pages use admonitions (`:::tip` / `:::info` / `:::warning` / `:::caution`) and `@theme/Tabs` / `TabItem`
- Prefer `toc_max_heading_level: 2` and **bold** labels inside tabs (not `###`) so “On this page” stays clean
- Doc id / route comes from basename: `mcp-setup.mdx` keeps `/docs/getting-started/mcp-setup`
- Relative links use `./mcp-setup` (no extension) elsewhere — route-safe; file-path references in README/architecture may need `.mdx`

### Tech Stack

- Docusaurus site under `website/`
- Repo root: `npm run website:build`

### Code Style & Standards

- English SSOT; plain language, full sentences (match Prerequisites / Start here)
- Commands must match live Compose + installer (`AGENT_COLLECTIONS_HOME`, `docker compose … eversis-collections`) — never ship legacy `CURSOR_COLLECTIONS_HOME` as the primary path
- Smoke prompts must name tools the live server exposes (`eversis_skills_*`, `eversis_context_*`)
- No invented one-liners that contradict installer merge behavior

### Testing Patterns

- Docs: `npm run website:build` from repo root
- Inspectable checks: frontmatter keys; section headings in IA order; Tabs `groupId`s present; troubleshooting table rows; inbound anchors resolve; no new image assets under mcp-setup static path

### Database Patterns

- N/A

### Additional Context

- Child Task map: AC-64 mental model · AC-65 role · AC-66 core server · AC-67 client tabs · AC-68 verify · AC-69 project folder · AC-70 optional · AC-71 troubleshooting
- Related Prerequisites deep-link text today points at the volume section heading — preserve a stable heading id when demoting (e.g. keep a visible `##` / explicit `{#…}` id in Troubleshooting / advanced)
- Stack policy: do **not** load `eversis-implementing-frontend` / BA Docs for this work

## Implementation Plan

### Phase 1: MDX scaffold + mental model + role path (AC-64, AC-65)

**Goal**: Page opens with a plain MCP explanation and role guidance before any catalog or advanced env content.

**Description**: Convert the page to MDX with TOC cap and Tabs imports. Lead with mental-model tip and role table/tabs. Add Prerequisites/Docker Engine readiness callout at the top of the actionable flow (supports AC-66 precondition).

**Verification:** File is `mcp-setup.mdx` (no leftover competing `mcp-setup.md`); frontmatter has `toc_max_heading_level: 2`; intro tip and role guidance appear before Step 1 / catalogs.

#### Task 1.1 - [CREATE] Convert MCP Setup to MDX scaffold

**Description**: Create `website/docs/getting-started/mcp-setup.mdx` with frontmatter (`sidebar_position: 3`, `title: MCP Setup`, `toc_max_heading_level: 2`), import Tabs/TabItem, and remove `mcp-setup.md` so only one doc id remains. Skeleton headings follow the workshop IA (placeholders OK until later phases fill them).

**Files:** `website/docs/getting-started/mcp-setup.mdx` (create), `website/docs/getting-started/mcp-setup.md` (delete / replace)

**Definition of Done**:

- [x] Only `mcp-setup.mdx` exists under `website/docs/getting-started/` for this page (no duplicate `.md`)
- [x] Frontmatter includes `toc_max_heading_level: 2` and `sidebar_position: 3`
- [x] File imports `@theme/Tabs` and `@theme/TabItem`

**Clues**: Mirror `prerequisites.mdx` import style. Keep route id `mcp-setup`.

#### Task 1.2 - [MODIFY] Mental model + role guidance (AC-64, AC-65)

**Description**: Add plain-language MCP tip/analogy (editor “hands” for tools/rules/context; local core server; not a cloud product to buy) before catalogs. Add role guidance: QA/BA/PO → Cursor + core only; Developer → Cursor or Claude Code, optional later; Maintainer → advanced non-Docker path labeled advanced and not primary. Include Prerequisites/Docker Engine readiness callout linking to `./prerequisites`.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify — Task 1.1)

**Definition of Done**:

- [x] Top-of-page tip/paragraph introduces MCP before multi-server catalog or env cutover
- [x] Role guidance recommends Cursor + core for QA/BA/PO
- [x] Maintainer/advanced path is labeled advanced and does not dominate
- [x] Visible callout links to Prerequisites / Docker Engine before Step 1
- [x] Intro does not require volume mounts, Compose internals, or JSON schema knowledge

**Clues**: Role layout may be a table or Tabs; Start here role tabs are a tone reference, not a copy-paste.

### Phase 2: Core server + editor connect (AC-66, AC-67)

**Goal**: Reader can build/run only the core server, then connect via Cursor or Claude Code without mixing clients or duplicating MCP entries.

**Description**: Step 1 OS tabs with Compose SSOT commands; client tabs with Cursor default, Claude Code CLI, Claude Desktop one-liner; installer project config vs User duplicate guidance.

**Verification:** OS Tabs and `groupId="mcp-client"` present; page text does not require Jira/Figma tokens for Step 1; Claude Desktop appears only as unsupported disclaimer.

#### Task 2.1 - [MODIFY] Step 1 core local server (AC-66)

**Description**: Ordered Step 1: set `AGENT_COLLECTIONS_HOME`, `docker compose build eversis-collections`, and the Compose-based MCP entry shape matching live installer SSOT. Provide macOS vs Windows command tabs (or clear OS variants). Do not ask for third-party API tokens. Point “Docker not running” to Prerequisites.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify — Phase 1)

**Definition of Done**:

- [x] Step 1 uses `AGENT_COLLECTIONS_HOME` and `docker compose` for `eversis-collections` (not primary `CURSOR_COLLECTIONS_HOME` / not audit-only `docker run`)
- [x] macOS and Windows variants are available via Tabs or explicit OS sections
- [x] Step 1 does not require Jira/Figma/API tokens
- [x] In-tab labels use bold (or non-`###`) so TOC stays clean

**Clues**: Reuse accurate JSON/command blocks from current page; reconcile with installer merge wording.

#### Task 2.2 - [MODIFY] Client connect tabs (AC-67)

**Description**: Add Cursor | Claude Code Tabs (`groupId="mcp-client"`). Cursor: GUI Settings → MCP steps, default tab. Claude Code: CLI registration / list servers; vendored vs absolute notes kept short. One clear line only for Claude Desktop unsupported. Explain enable installer/project entry vs avoid duplicating in User MCP.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify — Task 2.1)

**Definition of Done**:

- [x] Cursor tab is default and GUI-oriented
- [x] Claude Code tab has separate CLI-oriented steps
- [x] Exactly one Claude Desktop unsupported disclaimer line (no Desktop setup tab)
- [x] Duplicate User vs project `eversis-collections` guidance is present
- [x] Following one client tab does not require configuring the other

**Clues**: Current page “User vs workspace” caution and Claude Code note are source material to rewrite into the Cursor/Claude tabs.

### Phase 3: Verify, folder note, optional, troubleshooting (AC-68–AC-71 + Gap Q4)

**Goal**: Reader can confirm success, understand the project folder requirement, skip optional integrations, and self-recover from common failures.

**Description**: Verification section with success/failure next steps; plain project-folder note; optional integrations callout; troubleshooting table; demote env cutover + volume deep-dive; fix inbound anchors.

**Verification:** IA order ends with optional → troubleshooting → next; troubleshooting rows cover disconnected, docker/image, wrong folder, duplicate MCP; no screenshot assets added; inbound `#domain-context…` links still resolve.

#### Task 3.1 - [MODIFY] Verification + project folder note (AC-68, AC-69)

**Description**: Verification: what success looks like (green/tools listed for `eversis-collections`); smoke prompt expecting `eversis_skills_*` and/or `eversis_context_*`; failure routes to Troubleshooting; next links include at least Quick Wins. Project-folder note: open consumer project root in everyday language; tie failure symptoms to Troubleshooting.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify — Phase 2)

**Definition of Done**:

- [x] Verification defines UI success signal and chat smoke check with real tool names
- [x] Failure path points to Troubleshooting
- [x] Next-step links include Quick Wins (and other Getting Started links as appropriate)
- [x] Project-folder note uses plain language and does not lead with volume-mount jargon

**Clues**: Keep accuracy of consumer vs framework roots from current docs; simplify wording.

#### Task 3.2 - [MODIFY] Optional integrations + troubleshooting + demote advanced (AC-70, AC-71, Gap Q4)

**Description**: Optional section with visible non-blocking callout; short bullets + Reference links; `eversis-collections` visually primary. Troubleshooting table: disconnected / Docker not running → Prerequisites; docker not found; image missing / rebuild; wrong project folder; duplicate User vs project MCP; Windows virtualization/WSL pointer to Prerequisites where appropriate. Move env cutover table and detailed volume/mount explanation into Troubleshooting or an Advanced subsection after the core path. Preserve a stable heading id for existing deep links (or update inbound links in the same task).

**Files:**
- `website/docs/getting-started/mcp-setup.mdx` (modify — Task 3.1)
- `website/docs/getting-started/prerequisites.mdx` (modify — only if anchor text/href must change)
- `website/docs/reference/domain-context.md` (modify — only if anchor must change)
- `website/docs/reference/integrations/eversis-collections.md` (modify — only if anchor must change)
- Optional path-string updates: `README.md`, `docs/architecture/requirements-traceability.md`, `documentation/agent-collection.md` (modify only where they hard-code `mcp-setup.md`)

**Definition of Done**:

- [x] Optional integrations callout states they are not required for framework start
- [x] Troubleshooting table covers disconnected, docker/image issues, wrong project folder, duplicate User vs project MCP
- [x] Env cutover and volume deep-dive do not appear before Step 1 / role guidance
- [x] Inbound deep links to the former volume section still resolve (preserved id or updated hrefs)
- [x] No new files under `website/static/img/getting-started/mcp-setup/`

**Clues**: Prefer linking Prerequisites for Windows Engine/WSL recovery over duplicating AC-37/AC-38 content. Prefer preserving `{#domain-context-needs-the-project-volume-not-just-the-framework-volume}` on the demoted heading over mass link edits.

### Phase 4: Website build verification

**Goal**: Confirm the docs site builds after the rewrite.

**Description**: Run the repo docs build and fix any MDX/import/link errors introduced by this plan.

**Verification:** `npm run website:build` exits 0.

#### Task 4.1 - [REUSE] Run website build

**Description**: From repo root, run `npm run website:build`. Fix only failures caused by this page rewrite (broken MDX, missing imports, dead anchors).

**Files:** `website/docs/getting-started/mcp-setup.mdx` (reuse / modify if build fails), inbound docs from Task 3.2 if needed

**Definition of Done**:

- [x] Run `npm run website:build` (exit 0)
- [x] Build does not report MDX errors for `mcp-setup`

**Clues**: If sidebar or plugin caches confuse local builds, prefer clean build once; do not change docusaurus theme.

### Phase 5: Code Review

**Goal**: Independent review confirms AC-64–AC-71 criteria and docs quality before Fine.

**Description**: Mandatory final gate. Code Reviewer via `eversis-review`. On PASS, Fine with per-ticket QA summaries.

**Verification:** `npm run website:build`; review PASS (zero BLOCKERs; QA checklist verified).

#### Task 5.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the MCP Setup rewrite and any inbound link edits. Verify Quality Assurance checkboxes below (per child Task). Document outcome in Changelog. Do not declare Fine until PASS.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (reuse), inbound files touched in Task 3.2 (reuse)

**Definition of Done**:

- [x] Run `npm run website:build`
- [x] Code review passes with no blocking findings
- [x] Every Quality Assurance item for AC-64–AC-71 is checked or explicitly deferred with user approval
- [x] Review outcome documented in Changelog

**Clues**: Fine handoff must include a short QA summary **per** AC-64, AC-65, AC-66, AC-67, AC-68, AC-69, AC-70, AC-71 (plus epic AC-63 rollup if useful).

## Security Considerations

- Docs must not embed secrets, API tokens, or personal machine paths as examples; use placeholders (`/path/to/agent-collections`, `${workspaceFolder}`).
- Do not instruct readers to paste credentials into MCP config for the required core path.
- Optional integration links may mention tokens exist for third-party MCPs but must not present them as required for first success.

## Quality Assurance

### Epic AC-63

- [x] Page IA: mental model → role → core server → connect → verify → project folder → optional → troubleshooting → next
- [x] Page copy is English
- [x] Optional integrations are non-blocking
- [x] `npm run website:build` passes

### AC-64 — Mental model

- [x] Top tip/paragraph analogy before catalogs / advanced env tables
- [x] Non-developer understands local core server connects to the editor
- [x] No volume/Compose/JSON-schema prerequisite in the intro

### AC-65 — Role path

- [x] QA/BA/PO recommended: Cursor + core only
- [x] Developer: optional integrations allowed later
- [x] Maintainer advanced path labeled and not dominant

### AC-66 — Core server Step 1

- [x] Prerequisites / Docker Engine callout before Step 1
- [x] Copy-paste Compose / `AGENT_COLLECTIONS_HOME` commands
- [x] OS-specific variants present
- [x] No third-party API tokens required for Step 1

### AC-67 — Client tabs

- [x] Separate Cursor and Claude Code instructions; Cursor default
- [x] Claude Desktop: one unsupported disclaimer line only
- [x] Installer/project vs User duplicate guidance present

### AC-68 — Verification

- [x] Success signal defined; smoke prompt uses real tool names
- [x] Failure routes to Troubleshooting
- [x] Next links include Quick Wins (minimum)

### AC-69 — Project folder

- [x] Plain-language consumer project root note
- [x] Same root-cause appears again in Troubleshooting

### AC-70 — Optional integrations

- [x] Visible non-blocking callout
- [x] Short overview + Reference links; `eversis-collections` primary

### AC-71 — Troubleshooting

- [x] Table covers disconnected, docker/image, wrong folder, duplicate User vs project MCP
- [x] Windows Engine/WSL points to Prerequisites where appropriate (no duplicate enterprise Docker essay)

## Improvements (Out of Scope)

- Screenshot set for verification / troubleshooting (future UX polish)
- Claude Desktop first-class Getting Started tab
- Deep optional-MCP tutorials on this page
- Installer UX changes to reduce User vs project duplicates automatically
- DHI-641 broader docs IA
- **Important** code-quality items (not this NTH pass): Claude-safe JSON / Cursor\|Claude sample tab; Jira board transitions for AC-63…AC-71; trim advanced volume bullets to Reference-only pointer

## Code Review Findings

**Verdict:** PASS (independent Code Reviewer, 2026-10-14) — original epic rewrite

**BLOCKERs:** none

**SUGGESTIONs (original):**
1. Prerequisites warning sits after the mental-model tip and before the role table; plan diagram showed role then callout — DoD only requires callout before Step 1 (met). **Addressed in Phase 6 (NTH-I3).**
2. Plan Changelog updated in this Fine turn.

**NTH polish review:** PASS (independent Code Reviewer, 2026-10-14) — zero BLOCKERs; Phase 6 QA checklist verified.

### Phase 6: Code-quality nice-to-have polish (DELTA)

**Goal**: Close all actionable 🟢 Nice to Have findings from `docs/reports/code-quality-report.md` without expanding into Important items.

**Description**: Docs-only edits to `mcp-setup.mdx` for IA order, single OS tab group, and softer Claude CLI verify wording; confirm verify-only NTH rows with no changelog rewrite.

**Verification:** Page order tip → role → warning → Step 1; one OS `groupId`; Claude Code primary path is open/trust `.mcp.json`; `npm run website:build` exit 0.

#### Task 6.1 - [MODIFY] Move Prerequisites warning under role table (NTH-I3)

**Description**: Reorder so mental-model tip and role table come first, then the Prerequisites `:::warning`, then Step 1. Callout must still appear before Step 1 (AC-66 DoD preserved).

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify)

**Definition of Done**:

- [x] Order is: tip → `## Choose your path by role` (table) → Prerequisites warning → `## Step 1`
- [x] Warning still links to `./prerequisites` and states Docker Engine must be running
- [x] No new screenshots or Important-item edits in this task

**Clues:** Research DELTA NTH-I3; code-quality Improvements #3.

#### Task 6.2 - [MODIFY] Merge OS env + build into one Tabs group (NTH-I4)

**Description**: Replace `mcp-os-env` + `mcp-os-build` with a single Tabs `groupId` (e.g. `mcp-os`). Each OS tab contains env export and `docker compose build` (Windows tab keeps the Docker-not-recognized → Prerequisites note).

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify — Task 6.1)

**Definition of Done**:

- [x] Exactly one OS Tabs group for Step 1 env+build (no second OS switch for build)
- [x] macOS/Linux and Windows both include set-env + build commands
- [x] In-tab headings stay non-`###` (TOC clean)

**Clues:** Research DELTA NTH-I4; code-quality Improvements #4.

#### Task 6.3 - [MODIFY] Demote `claude mcp list` on Claude Code tab (NTH-I5)

**Description**: On the Claude Code connect tab, make the primary step open/trust the project `.mcp.json` (confirm `eversis-collections` without adding a second entry). Keep `claude mcp list` only as an optional secondary check when the CLI version supports it.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (modify — Task 6.2)

**Definition of Done**:

- [x] Primary Claude Code verify/connect wording is open/trust `.mcp.json` (or equivalent trust flow)
- [x] `claude mcp list` appears only as optional / version-qualified, not the lead instruction
- [x] Cursor tab and User-duplicate caution unchanged

**Clues:** Research DELTA NTH-I5; code-quality Improvements #5.

#### Task 6.4 - [REUSE] Confirm verify-only nice-to-haves (NTH-D1, D2, Dup2, Dup3, I6)

**Description**: Confirm without edits: legacy `mcp-setup.md` absent; no `website/static/img/getting-started/mcp-setup/`; Cursor caution + troubleshooting duplicate-MCP row both remain; role table not merged with Start here; historical changelog `mcp-setup.md` strings left as-is.

**Files:** (reuse inspect only — no writes)

**Definition of Done**:

- [x] `website/docs/getting-started/mcp-setup.md` does not exist
- [x] `website/static/img/getting-started/mcp-setup/` does not exist
- [x] Cursor caution and Troubleshooting duplicate-MCP row both still present
- [x] Historical `mcp-setup.md` cites in CHANGELOG / generated changelog remain (no rewrite)

**Clues:** Research DELTA verify-only inventory.

#### Task 6.5 - [REUSE] Website build after NTH polish

**Description**: From repo root, run `npm run website:build`. Fix only MDX/import errors from Tasks 6.1–6.3.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (reuse / modify if build fails)

**Definition of Done**:

- [x] `npm run website:build` exits 0
- [x] Build does not report MDX errors for `mcp-setup`

### Phase 7: Code Review (NTH polish)

**Goal**: Independent review confirms NTH polish DoD before Fine.

**Description**: Code Reviewer via `eversis-review` on Phase 6 diffs only (plus confirm Important items stayed out of scope).

**Verification:** Build green; review PASS (zero BLOCKERs; Phase 6 QA checkboxes verified).

#### Task 7.1 - [REUSE] Code review by Code Reviewer (NTH)

**Description**: Run Code Reviewer on `mcp-setup.mdx` NTH changes. Document outcome in Changelog. Do not declare Fine until PASS.

**Files:** `website/docs/getting-started/mcp-setup.mdx` (reuse)

**Definition of Done**:

- [x] Run `npm run website:build`
- [x] Code review passes with no blocking findings
- [x] Every Phase 6 Quality Assurance item below is checked
- [x] Review outcome documented in Changelog

## Quality Assurance (Phase 6 — Nice to Have)

- [x] Tip → role table → Prerequisites warning → Step 1
- [x] Single OS Tabs group for env + build
- [x] Claude Code primary path is open/trust `.mcp.json`; `claude mcp list` optional only
- [x] Verify-only NTHs confirmed (no legacy `.md`, no screenshot dir, by-design duplicates kept, changelog history untouched)
- [x] Important findings not implemented in this pass
- [x] `npm run website:build` passes

## Human gates

1. ~~Approve research~~ — done (`Research is ok. Make the plan`)
2. ~~Approve this plan~~ — done (`Plan is ok. Implement`) for original Phases 1–5
3. ~~Implement → Review → Fine~~ — done 2026-10-14 (QA draft: summary per AC-64…AC-71)
4. ~~Approve research DELTA~~ — done (`Q5. OK;`)
5. ~~Approve Phase 6–7 plan REFRESH~~ — done (`Plan is ok. Implement`) — Implement in progress → Review → Fine (NTH polish QA draft)

## Changelog

| Date | Change Description |
| ------ | -------------------- |
| 2026-10-14 | Initial plan created from approved research (whole epic; MDX/Tabs; text-only; demote cutover/volume; per-ticket Fine QA) |
| 2026-10-14 | Implemented mcp-setup.mdx rewrite; website:build PASS; Code Review PASS; Fine |
| 2026-10-14 | **REFRESH** — Phase 6–7 for code-quality nice-to-have polish (NTH-I3/I4/I5 + verify-only); Q5 locked; Important items out of scope |
| 2026-10-14 | Phase 6 implemented: warning under role; `groupId="mcp-os"`; Claude `.mcp.json` primary; verify-only confirmed; `website:build` PASS |
| 2026-10-14 | Phase 7 Code Review PASS (NTH polish); Fine |
