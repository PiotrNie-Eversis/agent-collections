# ac-35-prerequisites-ux - Implementation Plan

## Task Details

| Field            | Value                                                                 |
| ---------------- | --------------------------------------------------------------------- |
| Jira ID          | AC-35                                                                 |
| Title            | Prerequisites page: UX overhaul for QA/BA (role matrix, OS tabs, verification) |
| Description      | Rewrite getting-started Prerequisites for role-based onboarding, OS tabs, verification; align Start here. |
| Priority         | Medium                                                                |
| Related Research | `docs/specs/ac-35-prerequisites-ux/ac-35-prerequisites-ux.research.md` |

## Wildly Important Goal

**Goal**: QA/BA/PO readers can complete tool setup using the Prerequisites page alone—without framework jargon blocking the path to Installation.

**Success Measure**: All six Jira acceptance criteria are satisfied and `npm run website:build` exits 0 with existing `./prerequisites` links intact.

**Do NOT touch / do NOT add**: Installer scripts, MCP Docker image behavior, Linux OS tab, full-site translation, changes outside listed doc files unless build requires.

## Proposed Solution

Replace `prerequisites.md` with **`prerequisites.mdx`**: front-load a role `:::tip`, a five-tool requirements matrix (official links), Docusaurus `<Tabs groupId="operating-system">` for macOS and Windows with GUI-first steps and optional CLI subsections, optional Node in `:::info`, a **Check your setup** verification block with example outputs, then framework depth (Docker for MCP, domain-context cwd, OpenCode placeholder) in admonitions linking to [MCP setup](./mcp-setup). Update **Start here** checklist copy so Node is clearly optional for QA/BA. Remove the old `.md` file to avoid duplicate doc IDs.

```text
[Role tip] → [Matrix] → [OS Tabs] → [Optional Node] → [Verify] → [Framework notes] → [→ Installation]
```

## Current Implementation Analysis

### Already Implemented

- Docusaurus site with admonitions — `website/docusaurus.config.ts` — reuse
- MCP setup deep dive — `website/docs/getting-started/mcp-setup.md` — link target
- Relative links to `./prerequisites` — `start-here.md`, `mcp-setup.md`, `intro.md` — reuse paths (slug unchanged)

### To Be Modified

- `website/docs/getting-started/start-here.md` — checklist item 1 (and any duplicate prerequisite wording) to match role-based Node optional messaging

### To Be Created

- `website/docs/getting-started/prerequisites.mdx` — full page per Jira requirements 1–10

### To Be Removed

- `website/docs/getting-started/prerequisites.md` — after MDX replacement (same doc route)

## Open Questions

| #   | Question                         | Answer                                      | Status       |
| --- | -------------------------------- | ------------------------------------------- | ------------ |
| 1   | MDX vs `.md` for Tabs            | `prerequisites.mdx`                         | ✅ Resolved  |
| 2   | Agent tools section placement    | Compact note below verification             | ✅ Resolved  |
| 3   | Claude install URL source        | Anthropic quickstart (Technical Context)    | ✅ Resolved  |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `.cursor/rules/eversis-project-stack.mdc` — quality: `npm run website:build` from repo root
- Docs-only change; no new npm dependencies

### Architecture & Patterns

- Public docs live under `website/docs/`; getting-started sidebar order via frontmatter `sidebar_position`
- First MDX doc in repo: import Tabs at top of file:

```mdx
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
```

- Use existing admonition syntax: `:::tip`, `:::info`, `:::warning`
- `onBrokenLinks: 'throw'` — all internal links must resolve at build time

### Tech Stack

- Docusaurus classic preset (`website/docusaurus.config.ts`)
- Node/npm at repo root for website scripts

### Code Style & Standards

- English SSOT; **plain, easy-to-understand language** for QA/BA/PO readers (human gate from PO, 2026-10-13)
- Write **full sentences**; avoid telegraphic shortcuts, unexplained acronyms, and dense engineer jargon on the first screen
- Keep steps procedural but readable; official vendor links in matrix and tab bodies
- GUI-first install; terminal one-liners under **Optional (advanced)** subheadings within each tab

### Testing Patterns

- Website build (required): `npm run website:build` (repo root)
- Optional quick check after edit: `npm run website:changelog:check` only if changelog touched (not expected)

### Database Patterns

- N/A

### Additional Context — pinned official URLs

| Tool          | Link |
| ------------- | ---- |
| Cursor        | https://cursor.com/ |
| Claude Code   | https://docs.anthropic.com/en/docs/claude-code/quickstart |
| Docker Desktop| https://www.docker.com/products/docker-desktop/ |
| Git (Windows) | https://git-scm.com/download/win |
| Git (macOS)   | https://git-scm.com/download/mac |
| Node.js LTS   | https://nodejs.org/ |

**Tab content checklist (Jira):**

- **macOS:** Cursor `.dmg`; Claude CLI; Docker Desktop (Apple Silicon vs Intel); Git via installer or Xcode CLT prompt; optional Homebrew/advanced blocks
- **Windows:** Cursor `.exe`; Claude via PowerShell; Docker with WSL 2; `:::warning` for `wsl --install` + reboot; Git for Windows installer
- **Verification:** `docker --version`, `git --version`, optional `claude --version` with example output lines; CTA link to [Installation](./installation)

## Implementation Plan

### Phase 1: Prerequisites MDX page

**Goal**: Deliver the new onboarding-first Prerequisites content with matrix, tabs, verification, and deferred framework notes.

**Description**: Create `prerequisites.mdx` implementing Jira requirements 1–10 and AC 1–5; delete legacy `prerequisites.md`.

**Verification:** `npm run website:build`

#### Task 1.1 - [CREATE] prerequisites.mdx

**Description**: Author the full MDX page: role tip, tool matrix (Tool | Required for | Purpose | Link), OS tabs, optional Node section, verification, compact agent-tools/OpenCode note, framework admonitions + MCP setup link, Installation CTA.

**Files:** `website/docs/getting-started/prerequisites.mdx` (create)

**Definition of Done**:

- [ ] File imports `@theme/Tabs` and `@theme/TabItem`; `<Tabs groupId="operating-system">` has macOS and Windows `TabItem`s
- [ ] Matrix lists Cursor, Claude Code, Docker Desktop, Git, Node.js with official links
- [ ] `:::tip` states QA/BA/PO need AI editor + Docker + Git; Node not required unless MCP dev
- [ ] Body copy uses plain language and full sentences (no shortcut-only bullet fragments on the onboarding path)
- [ ] `npm run website:build` completes successfully

**Clues**: Preserve frontmatter `sidebar_position: 1` and `title: Prerequisites` from the current `.md` file.

#### Task 1.2 - [MODIFY] Remove legacy markdown doc

**Description**: Delete `prerequisites.md` after MDX is complete so Docusaurus does not register two docs for the same route.

**Files:** `website/docs/getting-started/prerequisites.md` (modify — delete)

**Definition of Done**:

- [ ] `prerequisites.md` no longer exists in the repo
- [ ] `npm run website:build` still exits 0

### Phase 2: Start here alignment

**Goal**: Step 1 of the onboarding checklist matches the new Prerequisites messaging.

**Description**: Update prerequisite bullet copy; avoid implying Node is required for QA/BA.

**Verification:** `npm run website:build`

#### Task 2.1 - [MODIFY] start-here checklist copy

**Description**: Revise checklist item 1 (and the parallel “Setup checklist” line if redundant) to: AI editor (Cursor and/or Claude Code), Docker, Git; Node called out as optional for MCP developers only—with link to Prerequisites for detail.

**Files:** `website/docs/getting-started/start-here.md` (modify)

**Definition of Done**:

- [ ] First successful install checklist item 1 no longer lists Node as peer-required with Docker/Git for all roles
- [ ] `npm run website:build` completes successfully

### Phase 3: Code Review

**Goal**: Independent verification that docs meet AC and build gate before Fine.

**Description**: Final review of MDX content, links, and acceptance criteria mapping.

**Verification:** `npm run website:build`

#### Task 3.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the doc changes. Confirm all Quality Assurance checkboxes and build.

**Files:** `website/docs/getting-started/prerequisites.mdx` (reuse), `website/docs/getting-started/start-here.md` (reuse)

**Definition of Done**:

- [ ] `npm run website:build` exits 0
- [ ] Code review passes with no blocking findings
- [ ] Review outcome documented in Changelog

## Security Considerations

- Documentation only; use HTTPS official vendor URLs; no secrets or tokens in examples.

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [ ] GIVEN Prerequisites WHEN a QA/BA reader scans the quick matrix THEN every listed tool has an official download/documentation link (Cursor, Claude Code, Docker Desktop, Git, Node.js).
- [ ] GIVEN a reader WHEN they choose macOS or Windows tabs THEN they see GUI-first install steps including platform notes (Apple Silicon/Intel on Mac; WSL2 on Windows).
- [ ] GIVEN a QA/BA reader WHEN they read the role tip and Node section THEN they can confirm Node.js is **not** required for their role.
- [ ] GIVEN a reader after install WHEN they follow the verification section THEN they know which commands to run and what successful version output looks like.
- [ ] GIVEN framework constraints WHEN deep topics (domain-context cwd, Compose) appear THEN they are below the main checklist in admonitions/links to MCP setup, not blocking the onboarding scan path.
- [ ] GIVEN maintainers WHEN they run `npm run website:build` THEN the build completes successfully.

## Improvements (Out of Scope)

- Linux tab in OS tabs
- Polish translation of getting-started
- MCP setup page restructure (link-only unless broken link found during build)
- Success metrics instrumentation (Jira optional post-release)

## Human gates

1. ~~Approve research~~ — done (`q1. .mdx; q2. ok; q3. ok;`)
2. ~~Approve this plan~~ — done (`Plan is ok. Implement`)
3. Implement → Review → Fine

## Changelog

| Date       | Change Description   |
| ---------- | -------------------- |
| 2026-10-13 | Initial plan created |
| 2026-10-13 | PO note: plain language, full sentences — added to Technical Context and Task 1.1 DoD |
| 2026-10-13 | Implemented prerequisites.mdx, start-here alignment; website:build PASS |
