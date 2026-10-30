# Extracted tasks (updated from UX audit)

**Source:** `Raport_UX_i_audyt_techniczny_strony_Prerequisites.md` (2026-10-13); user request; `website/docs/getting-started/prerequisites.md`.

## Story 1 — Prerequisites UX overhaul (AC-35)

**User story:** As a **QA, BA, or PO** onboarding to Agent Collections, I want the Prerequisites page to show a role-based checklist, OS-specific install tabs, and verification steps with official links, so that I can prepare my workstation without searching the web or reading framework jargon.

**Requirements:**

1. **Quick requirements matrix** — table columns: Tool | Required for (roles) | Purpose | Official download link (Cursor, Claude Code, Docker Desktop, Git, Node.js LTS).
2. **Role clarity at top** — `:::tip` admonition: QA/BA/PO need AI editor + Docker + Git; Node.js only for MCP package developers.
3. **OS tabs (Docusaurus)** — `<Tabs groupId="operating-system">` with **macOS** and **Windows** `TabItem`s; GUI installers as default; terminal/CLI as optional advanced path.
4. **macOS tab** — Cursor `.dmg`; Claude Code install script (or Homebrew cask note); Docker Desktop with **Apple Silicon vs Intel** choice; Git via Xcode CLT prompt or installer.
5. **Windows tab** — Cursor `.exe`; Claude Code PowerShell install (or WinGet note); Docker Desktop with **WSL2** recommendation; `:::warning` for `wsl --install` when WSL2 missing; Git for Windows.
6. **Node.js (optional section)** — `:::info` separating QA/BA (skip) vs MCP developers (LTS from nodejs.org).
7. **Verification section** — “Check your setup” with `docker --version`, `git --version`, optional `claude --version`, and **example expected output**; link forward to Installation.
8. **Framework depth** — Move adapter/MVP/monorepo/domain-context gotchas out of the main scan path; keep accuracy via `:::warning` / link to [MCP setup](https://agent-collections.vercel.app/docs/getting-started/mcp-setup) (domain-context working directory).
9. **Implementation** — Prefer Docusaurus-native pattern (`.mdx` + `@theme/Tabs` if required); align [Start here](https://agent-collections.vercel.app/docs/getting-started/start-here) prerequisite bullet.
10. **Build** — `npm run website:build` passes.

**Benchmarks (implementation reference, non-blocking):** React Native env setup (OS tabs); Claude Code quickstart (platform installers); Docker Desktop docs (GUI + prerequisites); GitHub CLI (verify-after-install).

**Acceptance criteria:**

- GIVEN the Prerequisites page WHEN a QA/BA reader opens it THEN they see a quick matrix with official links for all listed tools without googling.
- GIVEN a reader on macOS or Windows WHEN they select their OS tab THEN they see GUI-first install steps (Docker Desktop, editors, Git) including platform-specific notes (Apple Silicon/Intel, WSL2).
- GIVEN a QA/BA reader WHEN they read the role tip and Node section THEN they can confirm Node.js is **not** required for their role.
- GIVEN a reader who completed install WHEN they run the verification commands THEN the page shows which commands to run and what successful output looks like.
- GIVEN maintainers WHEN they run `npm run website:build` THEN the build succeeds.

**Priority:** Medium | **Sizing:** Medium–Large
