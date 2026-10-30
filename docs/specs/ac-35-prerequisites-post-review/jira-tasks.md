# Jira-ready tasks — ac-35-prerequisites-post-review

**Target project:** AC (Agent Collections)  
**Push status:** Pushed 2026-10-13 (Gate 2: Push do jiry)  
**Related delivery:** [AC-35](https://eversis.atlassian.net/browse/AC-35) — **Relates** links on epics; label `ac-35-follow-up` on all issues

## Created issue keys (Epic → **Task** — team standard)

| Epic | Key | Tasks (active) | Superseded Story (Done + Duplicate) |
|------|-----|----------------|-------------------------------------|
| Prerequisites: Non-technical reader clarity | [AC-36](https://eversis.atlassian.net/browse/AC-36) | [AC-47](https://eversis.atlassian.net/browse/AC-47), [AC-48](https://eversis.atlassian.net/browse/AC-48), [AC-49](https://eversis.atlassian.net/browse/AC-49), [AC-46](https://eversis.atlassian.net/browse/AC-46) | AC-40, AC-39, AC-41, AC-42 |
| Prerequisites: Page UX and recovery | [AC-37](https://eversis.atlassian.net/browse/AC-37) | [AC-50](https://eversis.atlassian.net/browse/AC-50), [AC-51](https://eversis.atlassian.net/browse/AC-51) | AC-44, AC-45 |
| Prerequisites: Enterprise Docker install reality | [AC-38](https://eversis.atlassian.net/browse/AC-38) | [AC-52](https://eversis.atlassian.net/browse/AC-52) | AC-43 |

See `docs/context/agent-collections/jira-backlog-hierarchy/` — push **Task/Bug** only under epics, never Story as leaf.

---

## Epic 1

| Field | Value |
|---|---|
| **Summary** | Prerequisites: Non-technical reader clarity |
| **Issue Type** | Epic |
| **Priority** | High |
| **Labels** | documentation, getting-started, ux, website, ac-35-follow-up |
| **Jira Key** | — |

### Description

h2. Overview

Extend the public Prerequisites page so QA, BA, and PO readers understand GUI versus CLI tools, Node.js dependencies when choosing Claude Code, AI account requirements, and how to open a terminal before running verification commands.

h2. Business Value

Reduces blocked installs and internal “which app do I download?” questions after the AC-35 page refresh.

h2. Success Metrics

* Readers can complete Prerequisites using Cursor only without unexpected CLI or Node.js requirements.
* Readers know to request Cursor/Anthropic access from Tech Lead or IT before install day.

### Acceptance Criteria

(/) Epic is done when all child stories are Done and `npm run website:build` passes for the combined page changes.

---

## Story 1.1

| Field | Value |
|---|---|
| **Summary** | QA/BA can tell Cursor (GUI) from Claude Code (CLI) on Prerequisites |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Non-technical reader clarity |
| **Priority** | High |
| **Labels** | documentation, getting-started, ux, ac-35-follow-up |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | — |

### Description

h2. Context

This story is part of **Prerequisites: Non-technical reader clarity**. It fixes the conceptual mismatch where Claude Code was presented like a desktop “AI editor.”

h2. Source Context

Post-deploy analysis §1; `docs/specs/ac-35-prerequisites-post-review/cleaned-transcript.md`.

h2. User Story

As a **QA or BA** preparing my machine, I want the Prerequisites page to explain that Cursor is a desktop editor and Claude Code is a terminal tool, so that I do not expect a Claude Code icon on my desktop.

h2. Requirements

# Label Cursor as a graphical (GUI) editor and Claude Code as a command-line (CLI) tool in the quick requirements area.
# Recommend starting with Cursor for readers who are not comfortable with the terminal.
# Use plain language and full sentences per AC-35 documentation standards.

h2. Delivery Standard

* Spec folder: `docs/specs/ac-35-prerequisites-post-review/` (or split `<key>-<topic>/` per story at implement time)
* Research / plan: required before implementation when using `eversis-implement`
* Implement: `eversis-implement`
* Review: `eversis-review`
* Fine: QA comment draft per `eversis-fine-handoff`
* Verify: `npm run website:build`

h2. Technical Notes

Update `website/docs/getting-started/prerequisites.mdx` matrix and/or role tip.

### Acceptance Criteria

(/) GIVEN the quick requirements table WHEN a reader scans tool descriptions THEN Cursor is labeled as a graphical (GUI) editor and Claude Code as a command-line (CLI) tool.
(/) GIVEN a reader who is not comfortable with the terminal WHEN they read the role tip or an adjacent note THEN the page recommends starting with Cursor as the first AI editor.
(/) GIVEN plain-language documentation standards WHEN new copy is added THEN sentences are full and jargon is explained on first use.

---

## Story 1.2

| Field | Value |
|---|---|
| **Summary** | QA/BA see when Node.js is required for Claude Code vs Cursor-only path |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Non-technical reader clarity |
| **Priority** | High |
| **Labels** | documentation, getting-started, ac-35-follow-up |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | — |

### Description

h2. Context

Part of **Prerequisites: Non-technical reader clarity**. Resolves the contradiction between “skip Node.js” and Claude Code install paths that require Node.

h2. Source Context

Post-deploy analysis §2; quality review S-01 (Start here alignment).

h2. User Story

As a **QA or BA**, I want to know when Node.js is still required, so that I am not blocked after choosing Claude Code while the page told me to skip Node.js.

h2. Requirements

# State that Cursor-only roles do not require Node.js.
# State that Claude Code install via npm or Anthropic quickstart may require Node.js LTS.
# Keep MCP developer Node requirement accurate.
# Align **Start here** checklist step 1 with updated messaging.

h2. Delivery Standard

Same as Story 1.1.

h2. Technical Notes

Adjust Node `:::info` block and Claude Code tab copy; may update `start-here.md`.

### Acceptance Criteria

(/) GIVEN the Node.js optional section WHEN a reader chooses Cursor only for their role THEN the page states Node.js is not required for that path.
(/) GIVEN a reader who installs Claude Code via npm or Anthropic quickstart WHEN they follow linked instructions THEN the page states that path may require Node.js LTS even for non-MCP-developer roles.
(/) GIVEN the optional Node section WHEN MCP developer role is described THEN existing MCP-package Node requirement remains accurate.
(/) GIVEN Start here checklist step 1 WHEN a reader opens it after this change THEN the prerequisite bullet matches the updated Node and Claude Code messaging on Prerequisites.

---

## Story 1.3

| Field | Value |
|---|---|
| **Summary** | QA/BA see Cursor and Anthropic account requirements on Prerequisites |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Non-technical reader clarity |
| **Priority** | High |
| **Labels** | documentation, getting-started, ac-35-follow-up |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | — |

### Description

h2. Context

Part of **Prerequisites: Non-technical reader clarity**. Covers financial/access prerequisites for LLM tools omitted from the first page version.

h2. Source Context

Post-deploy analysis §7.

h2. User Story

As a **QA or BA**, I want Prerequisites to list AI account requirements for Cursor and Claude Code, so that I ask my Tech Lead or IT for access before install day.

h2. Requirements

# Mention Cursor account needs (trial, Pro, or org-provided API access as applicable).
# Mention Anthropic account/plan or API billing for Claude Code.
# Advise contacting Tech Lead or IT when the organization provides seats or keys.

h2. Delivery Standard

Same as Story 1.1.

h2. Technical Notes

Extend requirements matrix or add a short subsection; use official vendor links.

### Acceptance Criteria

(/) GIVEN the quick requirements area WHEN a reader plans installs THEN the page mentions Cursor needs an account (trial, Pro, or org-provided API access as applicable).
(/) GIVEN the same area WHEN a reader plans Claude Code THEN the page mentions an Anthropic account with a suitable plan or API billing, per org policy.
(/) GIVEN corporate readers WHEN they lack personal subscriptions THEN the page advises contacting Tech Lead or IT for organization keys or seats.

---

## Story 1.4

| Field | Value |
|---|---|
| **Summary** | QA/BA know how to open Terminal or PowerShell before verification |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Non-technical reader clarity |
| **Priority** | High |
| **Labels** | documentation, getting-started, ac-35-follow-up |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | — |

### Description

h2. Context

Part of **Prerequisites: Non-technical reader clarity**. Verification commands assume a terminal the reader can find.

h2. Source Context

Post-deploy analysis §5.

h2. User Story

As a **manual QA or BA**, I want to know how to open a terminal on my OS, so that I can run the verification commands without asking a developer.

h2. Requirements

# macOS: explain opening Terminal (e.g. Spotlight → Terminal).
# Windows: explain opening PowerShell from Start.
# Place instructions immediately before the verification command table.

h2. Delivery Standard

Same as Story 1.1.

h2. Technical Notes

`prerequisites.mdx` — section before “Check your setup” command table.

### Acceptance Criteria

(/) GIVEN the Check your setup section WHEN a macOS reader follows instructions THEN the page explains opening Terminal (for example Spotlight → Terminal).
(/) GIVEN the same section WHEN a Windows reader follows instructions THEN the page explains opening PowerShell (or equivalent) from Start.
(/) GIVEN verification commands WHEN a reader completes the steps THEN they know which window to type commands into.

---

## Epic 2

| Field | Value |
|---|---|
| **Summary** | Prerequisites: Enterprise Docker install reality |
| **Issue Type** | Epic |
| **Priority** | High |
| **Labels** | documentation, getting-started, ac-35-follow-up |
| **Jira Key** | — |

### Description

h2. Overview

Add corporate-friendly warnings about Docker Desktop administrator rights, licensing, and example IT-approved alternatives.

h2. Business Value

Prevents silent failure on locked-down laptops and unlicensed Docker Desktop installs in enterprises.

h2. Success Metrics

* Corporate QA/BA know to involve IT before assuming Docker Desktop is allowed.

### Acceptance Criteria

(/) Epic is done when Story 2.1 is Done and website build passes.

---

## Story 2.1

| Field | Value |
|---|---|
| **Summary** | QA/BA on corporate laptops see Docker admin, license, and IT alternatives |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Enterprise Docker install reality |
| **Priority** | High |
| **Labels** | documentation, getting-started, ac-35-follow-up |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | — |

### Description

h2. Context

Part of **Prerequisites: Enterprise Docker install reality**.

h2. Source Context

Post-deploy analysis §3; PO decision: IT first + named examples (Rancher Desktop, Podman Desktop, OrbStack on macOS).

h2. User Story

As a **QA or BA on a corporate laptop**, I want a clear warning about Docker admin rights and licensing, so that I escalate to IT instead of failing install silently.

h2. Requirements

# Warning admonition: administrator rights typically required on Windows and macOS.
# Explain Docker Desktop may require paid subscription at scale; confirm with IT.
# Name example alternatives IT may approve; state IT must confirm `docker compose` works for Agent Collections MCP.
# Keep OS tab install steps Docker Desktop–first.

h2. Delivery Standard

Same as Story 1.1.

h2. Technical Notes

Informational callout in `prerequisites.mdx`; link to Docker subscription documentation.

### Acceptance Criteria

(/) GIVEN Docker Desktop install steps WHEN a reader prepares to install THEN a warning states administrator rights are typically required on Windows and macOS.
(/) GIVEN organizational use WHEN the reader works in a company THEN the page states Docker Desktop may require a paid subscription at certain company sizes and they should confirm license or policy with IT before installing.
(/) GIVEN IT blocks Docker Desktop WHEN the reader needs a container runtime THEN the callout names examples IT sometimes approves (Rancher Desktop, Podman Desktop, OrbStack on macOS) and states the team must confirm the choice supports `docker compose` for Agent Collections MCP setup.
(/) GIVEN plain-language standards WHEN the callout is written THEN it uses full sentences; Docker Desktop remains the primary documented install path in OS tabs.

---

## Epic 3

| Field | Value |
|---|---|
| **Summary** | Prerequisites: Page UX and recovery |
| **Issue Type** | Epic |
| **Priority** | Medium |
| **Labels** | documentation, getting-started, ux, ac-35-follow-up |
| **Jira Key** | — |

### Description

h2. Overview

Fix duplicate table-of-contents entries from OS tabs and add troubleshooting with text and screenshots.

h2. Business Value

The page looks trustworthy and helps readers recover from common install mistakes without opening a ticket.

h2. Success Metrics

* Side TOC lists each major section once.
* At least three troubleshooting scenarios with screenshots and alt text.

### Acceptance Criteria

(/) Epic is done when Stories 3.1 and 3.2 are Done and `npm run website:build` passes.

---

## Story 3.1

| Field | Value |
|---|---|
| **Summary** | Documentation reader sees a single clean table of contents on Prerequisites |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Page UX and recovery |
| **Priority** | Medium |
| **Labels** | documentation, getting-started, ux, ac-35-follow-up |
| **Story Points (guidance)** | Small (1–3) |
| **Jira Key** | — |

### Description

h2. Context

Part of **Prerequisites: Page UX and recovery**. Duplicate TOC entries come from headings inside both OS tabs.

h2. Source Context

Post-deploy analysis §4.

h2. User Story

As a **documentation reader**, I want the side table of contents to list each section once, so that the page does not look broken.

h2. Requirements

# Remove duplicate “On this page” entries for Cursor, Claude Code, Docker, Git.
# Use bold labels inside tabs and/or `toc_max_heading_level: 2` in frontmatter.
# Preserve plain-language install steps.

h2. Delivery Standard

Same as Story 1.1.

h2. Technical Notes

Docusaurus MDX frontmatter; verify TOC after build.

### Acceptance Criteria

(/) GIVEN the published Prerequisites page WHEN a reader views “On this page” THEN Cursor, Claude Code, Docker, and Git each appear at most once (or tab internals are excluded from TOC per design).
(/) GIVEN implementation options WHEN maintainers choose heading strategy THEN either bold labels replace `###` inside tabs and/or `toc_max_heading_level: 2` is set in frontmatter, and `npm run website:build` passes.
(/) GIVEN macOS and Windows tabs WHEN content remains readable THEN install steps stay scannable with plain-language sentences.

---

## Story 3.2

| Field | Value |
|---|---|
| **Summary** | QA/BA can fix common Prerequisites install and verification failures |
| **Issue Type** | Story |
| **Parent** | Prerequisites: Page UX and recovery |
| **Priority** | Medium |
| **Labels** | documentation, getting-started, ux, ac-35-follow-up |
| **Story Points (guidance)** | Medium (5–8) — screenshots |
| **Jira Key** | — |

### Description

h2. Context

Part of **Prerequisites: Page UX and recovery**. PO requested text **and screenshots** for troubleshooting.

h2. Source Context

Post-deploy analysis §6.

h2. User Story

As a **QA or BA**, I want short fixes for typical install and verification failures, so that I can recover without opening a support ticket for every common mistake.

h2. Requirements

# At least three scenarios: Docker not running on Windows; PowerShell execution policy; macOS Git vs Xcode prompt.
# Full-sentence steps; at least one screenshot per major scenario with alt text.
# Images under `website/static/img/getting-started/prerequisites/` (or agreed path).

h2. Delivery Standard

Same as Story 1.1.

h2. Technical Notes

No secrets in screenshots; maintain images when vendor UI changes.

### Acceptance Criteria

(/) GIVEN Docker on Windows WHEN `docker` is not recognized THEN troubleshooting explains starting Docker Desktop and waiting for the engine to be ready.
(/) GIVEN PowerShell on Windows WHEN a script is blocked THEN troubleshooting mentions execution policy at a high level and points to rerunning as documented or asking IT.
(/) GIVEN Git on macOS WHEN Xcode Command Line Tools prompt appears THEN troubleshooting explains the lightweight Git installer alternative versus full Xcode.
(/) GIVEN the troubleshooting section WHEN added THEN it contains at least three distinct scenarios with actionable steps in full sentences.
(/) GIVEN each major scenario WHEN a reader follows troubleshooting THEN at least one screenshot illustrates the fix with alt text for accessibility.
(/) GIVEN Docusaurus build WHEN images are added THEN assets live under the agreed static path and `npm run website:build` passes.

---

## Completeness summary

| Task | Summary | Required fields | Status |
|------|---------|-----------------|--------|
| Epic 1 | Non-technical clarity | OK | Ready |
| Stories 1.1–1.4 | — | OK | Ready |
| Epic 2 | Enterprise Docker | OK | Ready |
| Story 2.1 | — | OK | Ready |
| Epic 3 | UX and recovery | OK | Ready |
| Stories 3.1–3.2 | — | OK | Ready |

---

## Gate 2 — Push checklist (when approved)

1. Confirm project **AC** and issue types (Epic + Story).
2. Create 3 epics, then 7 stories with parent links.
3. Add label `ac-35-follow-up` on all issues.
4. Link each epic **Relates to** **AC-35** (or single umbrella — see S-02).
5. Post-push verification per `eversis-jira-task-formatting` Step 10.
