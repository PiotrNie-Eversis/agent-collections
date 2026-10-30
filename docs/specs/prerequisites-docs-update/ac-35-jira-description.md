## Context

The public **Prerequisites** page (`website/docs/getting-started/prerequisites.md`) is the first step in the Start here checklist. A **UX and technical audit** (2026-10-13) confirms the page is written from a **framework engineer** perspective: missing vendor links (Claude Code, Docker, Node, Git), no **macOS vs Windows** install paths, no **verification** step, dense jargon (adapter, submodule, domain-context), and unclear **role separation** (QA/BA vs MCP developers).

**Audit source:** Raport UX i audyt techniczny strony Prerequisites (analysis session attachment).

**Related Jira:** AC-35 (this story). Not AC-20 / AC-3.

## User story

As a **QA, BA, or PO** preparing to use Agent Collections, I want Prerequisites to show a role-based checklist, OS-specific install instructions with official links, and a short verification guide, so that I can set up my machine before Installation without googling tools or reading framework internals.

## Requirements

### Information architecture (audit §4)

1. **Quick requirements matrix** at the top: columns **Tool | Required for (roles) | Purpose | Official download link** (Cursor, Claude Code, Docker Desktop, Git, Node.js LTS).
2. **Role tip** — Docusaurus `:::tip` at top: QA/BA/PO need **AI editor (Cursor and/or Claude Code) + Docker + Git**; **Node.js is not required** unless developing the MCP package.
3. **OS install tabs** — Docusaurus `<Tabs groupId="operating-system">` with **macOS** and **Windows** `<TabItem>` sections (benchmark: React Native Environment Setup pattern).
4. **GUI-first installs** — Default to Docker Desktop, Cursor/Claude installers, Git for Windows / macOS paths; terminal one-liners (Claude install.sh / install.ps1, Homebrew, WinGet) as **optional advanced** paths (benchmark: Claude Code quickstart, Docker Desktop guides).
5. **macOS tab** — Cursor `.dmg`; Claude Code CLI install; Docker Desktop with **Apple Silicon vs Intel** download choice; Git check via `git --version` / Xcode CLT prompt.
6. **Windows tab** — Cursor `.exe`; Claude Code via **PowerShell**; Docker Desktop with **Use WSL 2**; `:::warning` admonition for WSL2 setup (`wsl --install` + reboot when needed); Git for Windows installer.
7. **Node.js (optional section)** — `:::info` clearly stating **QA/BA: skip** vs **MCP developers: install LTS** from nodejs.org.
8. **Verification section** — "Check your setup": `docker --version`, `git --version`, optional `claude --version`, with **example expected output**; clear CTA link to **Installation** (benchmark: GitHub CLI verify-after-install).
9. **Framework accuracy without jargon up front** — Keep facts: Docker for running `eversis-collections`; Node only for MCP dev; domain-context tools need consumer project cwd — move to `:::warning` / link to **MCP setup** (not in the first screen of content).
10. **File format** — Use Docusaurus-native Tabs (convert to `.mdx` with `@theme/Tabs` / `@theme/TabItem` if required by site config).
11. **Cross-links** — Align **Start here** prerequisite bullet with the new page structure.
12. **Build** — `npm run website:build` before Done.

### Implementation reference (non-blocking)

Report includes a **ready MDX template** (sections 1–4: matrix, tabs, optional Node, verification). Adapt paths to repo (`website/docs/getting-started/`).

### Success metrics (optional, post-release)

Time-to-first-run for QA/BA, fewer internal "where to download Docker/Claude?" questions, improved click-through to Installation — **not gating for Done**.

## Delivery Standard

* Spec folder: `docs/specs/prerequisites-docs-update/`
* Implement: `eversis-implement` or docs PR
* Review: `eversis-review` before Done

## Out of scope

* Installer script or MCP Docker image behavior changes
* Full-site Polish translation (English docs remain SSOT)
* Linux tab (unless added with explicit PO approval — audit focused macOS/Windows)

## Acceptance criteria

* [ ] GIVEN Prerequisites WHEN a QA/BA reader scans the quick matrix THEN every listed tool has an official download/documentation link (Cursor, Claude Code, Docker Desktop, Git, Node.js).
* [ ] GIVEN a reader WHEN they choose macOS or Windows tabs THEN they see GUI-first install steps including platform notes (Apple Silicon/Intel on Mac; WSL2 on Windows).
* [ ] GIVEN a QA/BA reader WHEN they read the role tip and Node section THEN they can confirm Node.js is **not** required for their role.
* [ ] GIVEN a reader after install WHEN they follow the verification section THEN they know which commands to run and what successful version output looks like.
* [ ] GIVEN framework constraints WHEN deep topics (domain-context cwd, Compose) appear THEN they are below the main checklist in admonitions/links to MCP setup, not blocking the onboarding scan path.
* [ ] GIVEN maintainers WHEN they run `npm run website:build` THEN the build completes successfully.

## Technical notes

* Primary: `website/docs/getting-started/prerequisites.md` (likely `.mdx` after Tabs)
* Cross-check: `website/docs/getting-started/start-here.md`, `website/docs/getting-started/mcp-setup.md`
* No existing `<Tabs>` usage in `website/` — first adopter; verify Docusaurus config allows MDX in docs plugin.
