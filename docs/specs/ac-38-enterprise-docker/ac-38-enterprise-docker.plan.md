# ac-38-enterprise-docker - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | AC-38 (+ AC-37 in same thread) |
| Title            | Prerequisites: Enterprise Docker + Page UX / recovery |
| Description      | Combined delivery: AC-52 Docker enterprise callout, then AC-50 TOC fix and AC-51 troubleshooting with screenshots on `prerequisites.mdx`. |
| Priority         | High (AC-38) then Medium (AC-37) |
| Related Research | [ac-38-enterprise-docker.research.md](./ac-38-enterprise-docker.research.md), [ac-37-page-ux-recovery.research.md](../ac-37-page-ux-recovery/ac-37-page-ux-recovery.research.md) |
| Sibling plan pointer | [ac-37-page-ux-recovery.plan.md](../ac-37-page-ux-recovery/ac-37-page-ux-recovery.plan.md) (points here) |

## Wildly Important Goal

**Goal**: Corporate and non-technical readers of Prerequisites get an honest Docker Desktop warning and a clean, recoverable page (single TOC + ≥3 illustrated troubleshooting scenarios).

**Success Measure**: AC-52, AC-50, and AC-51 acceptance criteria are met on `prerequisites.mdx`, assets exist under `website/static/img/getting-started/prerequisites/`, and `npm run website:build` passes.

**Do NOT touch / do NOT add**:
- Installer scripts, MCP image, Compose behavior
- Linux install tab
- Full validation matrix for Rancher/Podman/OrbStack
- Regressing AC-36 copy (GUI/CLI, Node, accounts, terminal how-to, VS Code)
- Rewriting Start here (AC-56 owns the map)

## Proposed Solution

1. **AC-38 / AC-52** — Add one shared `:::warning` **above** the OS install `<Tabs>` covering administrator rights, corporate Docker Desktop licensing / IT confirmation, and IT-approved examples (Rancher Desktop, Podman Desktop, OrbStack on Mac) that must support `docker compose`. Keep Docker Desktop as the only step-by-step path inside tabs. Optionally tighten the matrix “Account before install” cell to point at the warning.
2. **AC-37 / AC-50** — Set `toc_max_heading_level: 2` in frontmatter and replace in-tab `###` tool headings with **bold** labels so “On this page” does not duplicate Cursor / Claude Code / Docker / Git.
3. **AC-37 / AC-51** — Add `## Common problems` after Check your setup with ≥3 scenarios (Windows Docker not started, PowerShell execution policy, macOS Git vs Xcode tools), each with actionable full-sentence steps plus a sanitized screenshot and alt text under `/img/getting-started/prerequisites/`.
4. Single verification: `npm run website:build`.

## Current Implementation Analysis

### Already Implemented

- Prerequisites MDX SSOT — `website/docs/getting-started/prerequisites.mdx` — AC-35/36 content (matrix, OS tabs, Node info, terminal how-to, verification)
- Empty image directory — `website/static/img/getting-started/prerequisites/` — created for AC-51 assets
- Docusaurus admonitions / Tabs patterns — same MDX file — reuse `:::warning`, `<Tabs>`

### To Be Modified

- `website/docs/getting-started/prerequisites.mdx` — Docker callout; frontmatter TOC; in-tab heading style; Common problems section + image refs

### To Be Created

- ≥3 PNG (or WebP) screenshots under `website/static/img/getting-started/prerequisites/` — Docker engine running, terminal/PowerShell context, Git installer / Xcode-tools choice (sanitized, no secrets)

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | TOC strategy | Both `toc_max_heading_level: 2` and bold labels in tabs | ✅ Resolved |
| 2 | Screenshot source | Agent creates sanitized assets during Implement | ✅ Resolved |
| 3 | Combined delivery | One plan: AC-38 then AC-37 | ✅ Resolved |
| 4 | Docker callout placement | One `:::warning` above OS tabs | ✅ Resolved |

## Technical Context

### Project Instructions

- `AGENTS.md` — framework repo; website docs under `website/docs/`
- `.cursor/rules/eversis-project-stack.mdc` — quality: `npm run website:build`; load `eversis-writing-repo-documentation` for docs
- Delivery Standard — research/plan under `docs/specs/<key>-<topic>/`

### Architecture & Patterns

- Docusaurus MDX docs site; Prerequisites uses `@theme/Tabs` / `TabItem`
- Headings inside tabs are indexed into TOC unless limited by `toc_max_heading_level` or non-heading labels
- Static assets: `website/static/` → site root URLs (e.g. `/img/getting-started/prerequisites/foo.png`)

### Tech Stack

- Docusaurus website package under `website/`
- Repo root script: `npm run website:build`

### Code Style & Standards

- Plain language, full sentences (AC-35)
- Official vendor links only; alternatives are examples, not endorsements
- Admonitions: `:::tip` / `:::info` / `:::warning`

### Testing Patterns

- Docs/content: `npm run website:build` (repo root)
- Inspectable checks: frontmatter key present; heading count; image files exist; alt text on `<img>` or MD image syntax

### Database Patterns

- N/A

### Additional Context

- Active Tasks: AC-52 (Docker), AC-50 (TOC), AC-51 (troubleshooting)
- Route docs work via Repo Docs Writer / `eversis-repo-docs-writer` + `eversis-writing-repo-documentation`
- No Figma / no `[REUSE]` UI verification for product UI

## Implementation Plan

### Phase 1: AC-38 Enterprise Docker callout (AC-52)

**Goal**: Corporate readers see admin, license, and IT-alternative guidance before following Docker Desktop steps.

**Description**: Insert one shared warning above OS tabs; keep tab steps Docker Desktop–first; do not duplicate the full warning inside each tab.

**Verification:** `rg -n "Rancher Desktop|administrator|docker compose" website/docs/getting-started/prerequisites.mdx` shows callout content; visual scan that warning sits above `<Tabs groupId="operating-system">`.

#### Task 1.1 - [MODIFY] Corporate Docker Desktop warning (AC-52)

**Description**: Add `:::warning` covering (1) administrator rights on Windows/macOS, (2) possible paid Docker Desktop / confirm with IT, (3) examples Rancher Desktop, Podman Desktop, OrbStack on Mac with IT approval and `docker compose` requirement for MCP. Optionally align the Docker matrix “Account before install” cell to reference the warning. Do not change install step order inside tabs.

**Files:** `website/docs/getting-started/prerequisites.mdx` (modify)

**Definition of Done**:

- [x] Warning states administrator rights on Windows and macOS
- [x] Warning states paid Docker Desktop may apply; confirm license/policy with IT
- [x] Warning names Rancher Desktop, Podman Desktop, OrbStack (Mac) and `docker compose` requirement
- [x] Docker Desktop remains the only step-by-step path in OS tabs
- [x] Warning appears once above the operating-system tabs (not duplicated per tab)

**Clues**: Place after “Install by operating system” intro paragraph and before `<Tabs groupId="operating-system">`. Link Docker Desktop subscription FAQ if useful.

### Phase 2: AC-37 TOC cleanup (AC-50)

**Goal**: Side TOC lists each major Prerequisites section once.

**Description**: Cap TOC depth and stop using `###` for in-tab tool labels.

**Verification:** Confirm frontmatter has `toc_max_heading_level: 2`; confirm no `### Cursor` / `### Docker` inside TabItems (bold labels instead).

#### Task 2.1 - [MODIFY] Deduplicate Prerequisites TOC (AC-50)

**Description**: Add `toc_max_heading_level: 2` to MDX frontmatter. Replace in-tab `### Cursor`, `### Claude Code`, `### Docker Desktop`, `### Git` (both OS tabs) with **bold** labels (or equivalent non-heading markup). Preserve plain-language steps.

**Files:** `website/docs/getting-started/prerequisites.mdx` (modify — Phase 1)

**Definition of Done**:

- [x] Frontmatter includes `toc_max_heading_level: 2`
- [x] No `###` tool headings remain inside `<TabItem>` for the OS install tabs
- [x] Install steps remain scannable with full sentences

**Clues**: Keep `##` sections (Quick requirements, Install by OS, Node.js, Check your setup, Common problems, Framework notes) as the TOC entries.

### Phase 3: AC-37 Troubleshooting + screenshots (AC-51)

**Goal**: Readers can recover from ≥3 common failures without a support ticket.

**Description**: Add Common problems section with text + images for Docker-not-running, PowerShell execution policy, and macOS Git vs Xcode tools.

**Verification:** Three image files exist under `website/static/img/getting-started/prerequisites/`; section references them with alt text; scenarios cover the three ACs.

#### Task 3.1 - [CREATE] Sanitized troubleshooting screenshots

**Description**: Create ≥3 sanitized, non-secret illustrative images (Docker Desktop/engine running or whale/status cue; terminal/PowerShell window; Git installer or Xcode CLT prompt alternative). No credentials, machine names, or customer data.

**Files:**
- `website/static/img/getting-started/prerequisites/docker-engine-running.png` (create)
- `website/static/img/getting-started/prerequisites/terminal-or-powershell.png` (create)
- `website/static/img/getting-started/prerequisites/macos-git-installer.png` (create)

**Definition of Done**:

- [x] At least three image files exist under `website/static/img/getting-started/prerequisites/`
- [x] Images contain no secrets or personal data

**Clues**: Filenames may vary if clearer; keep path prefix. Simple annotated captures or clean mock UI screenshots are acceptable.

#### Task 3.2 - [MODIFY] Common problems section (AC-51)

**Description**: After Check your setup (before Framework notes), add `## Common problems` with ≥3 scenarios matching AC-51: Windows `docker` not recognized → start Docker Desktop; PowerShell script blocked → execution policy / IT; macOS Git → lightweight installer vs Xcode tools. Each scenario: full-sentence steps + image with alt text.

**Files:** `website/docs/getting-started/prerequisites.mdx` (modify — Phases 1–2), images from Task 3.1 (reuse)

**Definition of Done**:

- [x] Section includes Windows Docker-not-started guidance
- [x] Section includes PowerShell execution-policy guidance
- [x] Section includes macOS Git / Xcode tools alternative
- [x] Each major scenario has a screenshot with alt text
- [x] Images referenced via `/img/getting-started/prerequisites/…`

### Phase 4: Build verification

**Goal**: Docs site still builds after MDX and static asset changes.

**Description**: Run the repo website build once after Phases 1–3.

**Verification:** `npm run website:build` exits 0.

#### Task 4.1 - [REUSE] Website build

**Description**: Run website build from repo root; fix any MDX/image path failures introduced by this plan.

**Files:** `website/docs/getting-started/prerequisites.mdx` (reuse), `website/static/img/getting-started/prerequisites/*` (reuse)

**Definition of Done**:

- [x] Run `npm run website:build` (repo root) — exit 0

### Phase 5: Code Review

**Goal**: Independent review confirms AC-52 / AC-50 / AC-51 without regressing AC-36.

**Description**: Mandatory final gate via Code Reviewer (`eversis-review`).

**Verification:** `npm run website:build`; AC checklist below.

#### Task 5.1 - [REUSE] Code review by Code Reviewer

**Description**: Review complete Prerequisites diff for AC coverage, plain language, TOC behavior, image alt text, and no installer/MCP scope creep.

**Files:** `website/docs/getting-started/prerequisites.mdx` (reuse), `website/static/img/getting-started/prerequisites/*` (reuse)

**Definition of Done**:

- [x] Run `npm run website:build`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

## Security Considerations

- Screenshots must not include tokens, API keys, emails, hostnames, or corporate wallpaper that reveals customer identity.
- Do not instruct readers to disable security controls beyond noting that IT may adjust PowerShell execution policy.
- Alternative runtimes are informational examples only — no claim of official support.

## Quality Assurance

- [x] AC-52: Admin rights warning (Windows + macOS)
- [x] AC-52: Paid Docker Desktop / IT license confirmation
- [x] AC-52: Rancher Desktop, Podman Desktop, OrbStack + `docker compose` note
- [x] AC-52: Docker Desktop remains primary tab path
- [x] AC-50: Tool names appear at most once in TOC / tab internals excluded
- [x] AC-50: `toc_max_heading_level` and/or bold labels; build passes
- [x] AC-51: Windows Docker not recognized → start Docker Desktop
- [x] AC-51: PowerShell execution policy guidance
- [x] AC-51: macOS Git lightweight installer vs Xcode
- [x] AC-51: ≥3 scenarios with screenshots + alt text; assets under static path
- [x] `npm run website:build` passes
- [x] AC-36 clarity copy not regressed

## Code Review Findings

**Verdict: PASS** (2026-10-14)

| Severity | Finding |
| --- | --- |
| — | No blockers. AC-52 / AC-50 / AC-51 met; OS tabs have no `###` tool headings; three static images with alt text; build exit 0. |

**Suggestions:** Schematic PNGs are illustrative placeholders (plan-allowed). Replace with org-branded captures later if desired.

## Improvements (Out of Scope)

- Linux Prerequisites tab
- End-to-end CI matrix for alternative container runtimes
- Org-branded screenshot pack replacement
- Closing Jira Tasks/Epics (human / Fine handoff)

## Human gates

1. ~~Approve research~~ — done (`Q1. OK;` / `Q2. OK;` / `Q3. Implement with AC-38;`)
2. ~~Approve this plan~~ — done (`Plan is ok. Implement`)
3. ~~Implement → Review → Fine~~ — done 2026-10-14

## Changelog

| Date | Change Description |
| ------ | -------------------- |
| 2026-10-14 | Initial combined plan created (AC-38 → AC-37) |
| 2026-10-14 | Implemented Phases 1–4; `npm run website:build` PASS |
| 2026-10-14 | Code review PASS; QA checklist checked |
