# AC-35 post-deploy review — Structured analysis

## Context

Post-implementation review of the public **Prerequisites** page after AC-35 (role matrix, OS tabs, verification). The information architecture improved significantly; remaining gaps affect **non-technical readers** (QA, BA, PO).

## Positive outcomes (baseline)

- Requirements table with official links addresses the original missing-vendor-links problem.
- macOS / Windows `<Tabs>` and the verification section support onboarding without framework jargon first.

## Findings

### 1. Conceptual mismatch: Claude Code is not a desktop GUI app

**Problem:** Claude Code is presented alongside Cursor as a generic “AI editor.”

**Impact:** Non-technical users expect a desktop application with an icon. Claude Code documentation describes a **terminal CLI**, subscription (Claude Pro/Team/Enterprise) or API billing, and often **npm-based** install paths.

**Gap:** No explicit **Cursor = GUI editor** vs **Claude Code = CLI** distinction. No guidance such as: *If you are not comfortable with the terminal, start with Cursor.*

**Source:** Post-deploy analysis §1.

### 2. Node.js messaging vs Claude Code install paths

**Problem:** Page states QA/BA/PO can skip Node.js.

**Impact:** Official Claude Code install via `npm install -g @anthropic-ai/claude-code` requires Node.js ≥ 18. Anthropic quickstart may show Node first even when standalone scripts exist.

**Gap:** Clarify dependency: *If you choose Claude Code, the install path you pick may require Node.js. If you choose Cursor only, Node.js is not required for your role.*

**Source:** Post-deploy analysis §2.

### 3. Docker Desktop: license and administrator rights

**Problem:** No mention of Docker Desktop licensing or admin permissions.

**Impact:** Corporate QA/BA may be blocked by IT policy (paid Docker Desktop at scale; admin rights on managed laptops). Teams sometimes use Rancher Desktop, Podman Desktop, or OrbStack (Mac).

**Gap:** Short callout: admin rights required; confirm organizational Docker Desktop license or consult IT. (Alternatives can stay out of scope unless PO wants them listed.)

**Source:** Post-deploy analysis §3.

### 4. Duplicate table of contents entries

**Problem:** Right-hand “On this page” lists Cursor, Claude Code, Docker, Git **twice**.

**Cause:** Docusaurus indexes `###` headings inside both `<TabItem>` blocks.

**Gap:** Use non-TOC headings (bold labels) inside tabs, and/or set `toc_max_heading_level: 2` in frontmatter.

**Source:** Post-deploy analysis §4; current `prerequisites.mdx` uses `###` per tool in each tab.

### 5. How to open a terminal

**Problem:** Verification says “Run these commands in a terminal” without defining terminal.

**Impact:** Manual QA and BA users may not know Spotlight → Terminal (macOS) or Start → PowerShell (Windows).

**Gap:** One or two sentences per OS before the verification table.

**Source:** Post-deploy analysis §5.

### 6. Troubleshooting missing

**Problem:** Only advice is to close and reopen the terminal if commands are not found.

**Typical failures:**

- Windows: `docker` not found because Docker Desktop was installed but not started.
- Windows: PowerShell execution policy blocking install scripts.
- macOS: Git triggers large Xcode download instead of lightweight Git installer.

**Gap:** Short “Common problems” section with ~3 scenarios.

**Source:** Post-deploy analysis §6.

### 7. LLM access / billing prerequisites

**Problem:** “Accounts and network” mentions Jira/Figma tokens but not **AI model access**.

**Impact:** Cursor needs trial/Pro/API keys; Claude Code needs Anthropic account with suitable plan or API credits.

**Gap:** Add row or callout in requirements area: organization or Tech Lead provides Cursor/Anthropic access.

**Source:** Post-deploy analysis §7.

## Recommended fix bundle (from analysis)

1. GUI vs CLI distinction; recommend Cursor for terminal-averse users.
2. Micro-instructions for opening Terminal / PowerShell before verification.
3. Fix tab headings for TOC.
4. Docker admin + license warning.
5. LLM account/licensing requirements for Cursor and Claude.
