# ac-35-prerequisites-post-review - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-13 |
| Participants | Post-deploy reviewer; documentation maintainers |
| Source Materials | `cleaned-transcript.md`; `prerequisites.mdx`; AC-35 |
| Intent Brief | `intent-brief.md` |
| Project Baseline Used | None |
| Total Epics | 3 |
| Total Stories | 7 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Prerequisites — non-technical clarity | 4 | High |
| 2 | Prerequisites — enterprise Docker reality | 1 | High |
| 3 | Prerequisites — page UX and recovery | 2 | Medium |

---

## Epic 1: Prerequisites — non-technical clarity

**Business Description:** Readers in QA, BA, and PO roles understand which tools are graphical apps versus command-line tools, when Node.js might still be needed, how to open a terminal, and what AI accounts their organization must provide—before they hit install or verification steps.

**Success Criteria:**

- A non-technical reader can choose **Cursor alone** without installing Claude Code or Node.js and still meet Prerequisites for their role.
- A reader who chooses Claude Code understands **CLI and account** requirements up front.

### Story 1.1: Distinguish Cursor (GUI) from Claude Code (CLI)

**User Story:** As a **QA or BA** preparing my machine, I want the Prerequisites page to explain that Cursor is a desktop editor and Claude Code is a terminal tool, so that I do not expect a Claude Code icon on my desktop.

**Source:** Post-deploy analysis §1; `cleaned-transcript.md` finding 1.

**Acceptance Criteria:**

- [ ] GIVEN the quick requirements table WHEN a reader scans tool descriptions THEN Cursor is labeled as a **graphical (GUI) editor** and Claude Code as a **command-line (CLI) tool**.
- [ ] GIVEN a reader who is not comfortable with the terminal WHEN they read the role tip or an adjacent note THEN the page recommends **starting with Cursor** as the first AI editor.
- [ ] GIVEN plain-language rules from AC-35 WHEN new copy is added THEN sentences are full and jargon is explained on first use.

**High-Level Technical Notes:** Update `prerequisites.mdx` matrix and/or tip; no new npm dependencies.

**Priority:** High

### Story 1.2: Explain Node.js in relation to Claude Code install choice

**User Story:** As a **QA or BA**, I want to know when Node.js is still required, so that I am not blocked after choosing Claude Code while the page told me to skip Node.js.

**Source:** Post-deploy analysis §2; `cleaned-transcript.md` finding 2.

**Acceptance Criteria:**

- [ ] GIVEN the Node.js optional section WHEN a reader chooses **Cursor only** for their role THEN the page states Node.js is **not** required for that path.
- [ ] GIVEN a reader who installs **Claude Code** via npm or Anthropic quickstart WHEN they follow linked instructions THEN the page states that path **may require Node.js LTS** even for non-MCP-developer roles.
- [ ] GIVEN the optional Node section WHEN MCP developer role is described THEN existing MCP-package Node requirement remains accurate.
- [ ] GIVEN **Start here** checklist step 1 WHEN a reader opens it after this change THEN the prerequisite bullet matches the updated Node and Claude Code messaging on Prerequisites.

**High-Level Technical Notes:** May adjust `:::info` Node block and Claude Code tab copy; align `start-here.md` if the checklist sentence becomes ambiguous.

**Priority:** High

### Story 1.3: Document AI account and subscription prerequisites

**User Story:** As a **QA or BA**, I want Prerequisites to list AI account requirements for Cursor and Claude Code, so that I ask my Tech Lead or IT for access before install day.

**Source:** Post-deploy analysis §7; `cleaned-transcript.md` finding 7.

**Acceptance Criteria:**

- [ ] GIVEN the quick requirements area WHEN a reader plans installs THEN the page mentions **Cursor** needs an account (trial, Pro, or org-provided API access as applicable).
- [ ] GIVEN the same area WHEN a reader plans Claude Code THEN the page mentions an **Anthropic account** with a suitable plan (Pro/Team/Enterprise) or API billing, per org policy.
- [ ] GIVEN corporate readers WHEN they lack personal subscriptions THEN the page advises contacting **Tech Lead or IT** for organization keys or seats.

**High-Level Technical Notes:** Extend matrix with a row or dedicated short subsection; keep vendor links official.

**Priority:** High

### Story 1.4: Explain how to open Terminal or PowerShell before verification

**User Story:** As a **manual QA or BA**, I want to know how to open a terminal on my OS, so that I can run the verification commands without asking a developer.

**Source:** Post-deploy analysis §5; `cleaned-transcript.md` finding 5.

**Acceptance Criteria:**

- [ ] GIVEN the Check your setup section WHEN a macOS reader follows instructions THEN the page explains opening **Terminal** (for example Spotlight → Terminal).
- [ ] GIVEN the same section WHEN a Windows reader follows instructions THEN the page explains opening **PowerShell** (or equivalent) from Start.
- [ ] GIVEN verification commands WHEN a reader completes the steps THEN they know which window to type commands into.

**High-Level Technical Notes:** Place immediately before the verification command table in `prerequisites.mdx`.

**Priority:** High

---

## Epic 2: Prerequisites — enterprise Docker reality

**Business Description:** Corporate readers learn early that Docker Desktop installation may require administrator rights and a valid organizational license, reducing silent failure on locked-down laptops.

**Success Criteria:**

- QA/BA on managed devices know to involve IT before assuming Docker Desktop is allowed.

### Story 2.1: Docker Desktop administrator and license callout

**User Story:** As a **QA or BA on a corporate laptop**, I want a clear warning about Docker admin rights and licensing, so that I escalate to IT instead of failing install silently.

**Source:** Post-deploy analysis §3; `cleaned-transcript.md` finding 3.

**Acceptance Criteria:**

- [ ] GIVEN Docker Desktop install steps WHEN a reader prepares to install THEN a `:::warning` or equivalent states **administrator rights** are typically required on Windows and macOS.
- [ ] GIVEN organizational use WHEN the reader works in a company THEN the page states Docker Desktop may require a **paid subscription** at certain company sizes and they should **confirm license or policy with IT** before installing.
- [ ] GIVEN IT blocks Docker Desktop WHEN the reader needs a container runtime THEN the callout names **examples** IT sometimes approves (**Rancher Desktop**, **Podman Desktop**, **OrbStack** on macOS) and states the team must confirm the choice supports **`docker compose`** for Agent Collections MCP setup.
- [ ] GIVEN plain-language standards WHEN the callout is written THEN it uses full sentences; Docker Desktop remains the **primary documented install path** in OS tabs.

**High-Level Technical Notes:** Informational only; link to Docker subscription FAQ; alternatives are examples, not tested matrix in this story.

**Priority:** High

---

## Epic 3: Prerequisites — page UX and recovery

**Business Description:** The Prerequisites page navigation and recovery content match user expectations: no duplicate TOC noise, and help when verification commands fail for common reasons.

**Success Criteria:**

- Right-hand TOC lists each install subsection once.
- Readers find at least three troubleshooting entries without leaving the page.

### Story 3.1: Remove duplicate table-of-contents entries from OS tabs

**User Story:** As a **documentation reader**, I want the side table of contents to list each section once, so that the page does not look broken.

**Source:** Post-deploy analysis §4; `cleaned-transcript.md` finding 4; duplicate `###` in both TabItems.

**Acceptance Criteria:**

- [ ] GIVEN the published Prerequisites page WHEN a reader views “On this page” THEN **Cursor, Claude Code, Docker, and Git** each appear **at most once** (or tab internals are excluded from TOC per design).
- [ ] GIVEN implementation options WHEN maintainers choose heading strategy THEN either **bold labels replace `###` inside tabs** and/or **`toc_max_heading_level: 2`** is set in frontmatter, and `npm run website:build` passes.
- [ ] GIVEN macOS and Windows tabs WHEN content remains readable THEN install steps stay scannable with plain-language sentences.

**High-Level Technical Notes:** Docusaurus MDX frontmatter supports `toc_max_heading_level`; verify theme behavior after change.

**Priority:** Medium

### Story 3.2: Add common problems (troubleshooting) for verification and install

**User Story:** As a **QA or BA**, I want short fixes for typical install and verification failures, so that I can recover without opening a support ticket for every common mistake.

**Source:** Post-deploy analysis §6; `cleaned-transcript.md` finding 6.

**Acceptance Criteria:**

- [ ] GIVEN Docker on Windows WHEN `docker` is not recognized THEN troubleshooting explains **starting Docker Desktop** and waiting for the engine to be ready.
- [ ] GIVEN PowerShell on Windows WHEN a script is blocked THEN troubleshooting mentions **execution policy** at a high level and points to rerunning as documented or asking IT.
- [ ] GIVEN Git on macOS WHEN Xcode Command Line Tools prompt appears THEN troubleshooting explains the **lightweight Git installer** alternative versus full Xcode.
- [ ] GIVEN the troubleshooting section WHEN added THEN it contains **at least three** distinct scenarios with actionable steps in full sentences.
- [ ] GIVEN each major scenario WHEN a reader follows troubleshooting THEN at least one **screenshot** illustrates the fix (Docker running, terminal window, or installer choice) with **alt text** for accessibility.
- [ ] GIVEN Docusaurus build WHEN images are added THEN assets live under `website/static/img/getting-started/prerequisites/` (or team-agreed path) and `npm run website:build` passes.

**High-Level Technical Notes:** New `## Common problems` after verification; capture screenshots on macOS/Windows or use sanitized stock captures; no secrets in images.

**Priority:** Medium

---

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.1 | Related to | GUI/CLI framing makes Node messaging easier to understand |
| Story 3.1 | — | — | Can ship independently |
| Story 2.1 | — | — | Can ship independently |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | English docs remain SSOT; no Polish page in this epic | High | Add i18n story |
| 2 | Named Docker alternatives are examples only; IT approval required | High | Wording must not imply official support for every runtime |
| 4 | Screenshot assets maintained with doc changes | Medium | Stale UI in images after vendor redesigns |
| 3 | Anthropic/Cursor billing models remain as documented on vendor sites | Medium | Refresh links and wording in maintenance |

## Out of Scope

- Installer or MCP image changes.
- Linux tab.
- Full video walkthroughs; testing every alternative container runtime end-to-end in CI.

## Human gates (workflow)

1. ~~Gate 0~~ — Skipped (see `intent-brief.md`)
2. ~~Gate 1 — Approve extracted tasks~~ — done (`gate 1 oK`)
3. ~~Gate 1.5 — Quality review~~ — done (S-01 applied; S-02 accepted at push)
4. ~~Gate 2 — Jira push~~ — done (`Push do jiry`, 2026-10-13)
