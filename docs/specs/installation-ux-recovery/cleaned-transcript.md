# installation-ux-recovery - Cleaned Transcript

## Meeting Metadata

| Field | Value |
|---|---|
| Date | 2026-10-14 |
| Duration | N/A (written UX/IA audit, not a live workshop) |
| Topic | UX / IA / readability of Getting Started → Installation |
| Context | Structured audit of `/docs/getting-started/installation` for developers and non-technical roles (QA, BA, PO); includes problem diagnosis, recommendation matrix, and a proposed MDX template |

## Participants

| Name | Role |
|---|---|
| UX / DevEx report author | Documentation auditor (written report) |
| Piotr Niemirski | Requested BA extraction via `/eversis-analyze-materials` |

## Executive Summary

The Installation page is dense and accurate as an engineering reference, but fails as a Getting Started guide. Primary barriers: inverted information hierarchy (happy-path sample install buried at the bottom), Unix-only commands that block Windows users, and cognitive overload from mixing maintainer/framework-internals content with consumer install steps. The report proposes a three-step happy path with OS tabs, progressive disclosure of advanced flags, early success checks, and advanced content in collapsible sections.

## Discussion Topics

### Overall verdict — not a Getting Started guide

- Current page reads like an internal engineering spec / reference manual, not an install path.
- Main barriers: inverted flow, no Windows support in code blocks, cognitive overload from maintainer content mixed into numbered steps.

### Inverted information hierarchy

- “First successful install (sample project)” is section 6 at the bottom; users first face a 12-flag CLI table, submodule internals, and adapter sync.
- Recommendation: lead with prepare framework → run in project → verify success; move Upgrade / Submodules / full flag list lower.

### Platform barrier — Windows

- All sample commands use Unix paths (`~/projects`, `export`, `test -f`, bash).
- PowerShell users hit syntax errors immediately; installer script requires Bash (e.g. Git Bash).
- Recommendation: Docusaurus `<Tabs groupId="operating-system">` for **macOS/Linux** vs **Windows (Git Bash / PowerShell note)**.

### Cognitive overload — maintainer vs consumer

- Numbered step 2 (“Open the framework (optional for maintainers)”) with `npm run sync:adapters` looks mandatory in a 1→2→3 sequence.
- Advanced submodule SHA conflict content is interleaved with basic install.
- Recommendation: remove maintainer step from the main path; place at end or in a dedicated advanced section.

### Progressive disclosure — CLI flags

- Section 3 table lists ~12 flags (`--ssot-source`, `--ssot-branch`, `--confluence-space-key`, `--link-mode`, `--collections-home`, etc.).
- Causes decision paralysis for QA/BA (“Do I need my Confluence key now?”, “What is an SSOT branch?”).
- Recommendation: one default recommended command for ~90% of cases; full flag table in `<details>` or Reference.

### Mental model — framework vs consumer project

- Steps require two directories: clone `agent-collections` once, then `cd` into the business project and run the installer with `AGENT_COLLECTIONS_HOME`.
- Non-terminal users often run the installer inside the framework repo by mistake.
- Recommendation: explicit Step A (download toolkit once) / Step B (install into your project).

### Buried smoke test / success signal

- Verification (`test -f .agent-collections/install-selection.json`) only appears in section 6.
- Steps 3–4 give no “how do I know it worked?” cue (e.g. `.agent-collections/`, `docs/context/.../INDEX.md`).
- Recommendation: each install step ends with a short “how to recognize success” block; promote smoke test into the main path.

### Intro / navigation loop and TOC noise

- Opening callout sends readers back to Start here, creating a navigation loop instead of a clear install CTA.
- Recommendation: short message like “Install Agent Collections into your project in 3 steps.”
- TOC has ~12 mixed-depth entries; recommend `toc_max_heading_level: 2` and 4–5 major sections.

### Default install mode for non-developers

- Vendor terminology (local / symlink / submodule / copy) is mixed early.
- Recommendation: for QA/BA, recommend the standard path without vendor flags; keep team submodule mode under advanced.

### Proposed target IA (from report template)

1. Prerequisites tip → link to Prerequisites (Docker Desktop running).
2. Step 1: Download framework once (OS tabs).
3. Step 2: Install into consumer project (one default command; brief `--profile` note).
4. Step 3: Verification (selection file, context INDEX, exit code 0) → next: MCP Setup.
5. Upgrade & Sync (below happy path).
6. Advanced `<details>`: Git submodule; full CLI flag table.

## Key Decisions

| # | Decision | Made By | Conditions / Caveats |
|---|----------|---------|---------------------|
| 1 | Treat Installation as a 3-step Getting Started path, not a full CLI reference | Report | Engineering detail preserved but deferred via progressive disclosure |
| 2 | Provide OS-specific command tabs (macOS/Linux vs Windows / Git Bash) | Report | Windows primary path is Git Bash; PowerShell may be a short alternate note |
| 3 | One default install command; hide full flag matrix | Report | Advanced flags remain available in collapsible / advanced section |
| 4 | Remove maintainer “open framework / sync adapters” from the numbered happy path | Report | Content moved to advanced / end of page |
| 5 | Surface success criteria early (smoke test in main path) | Report | Explicit artifacts: `install-selection.json`, context `INDEX.md` |

## Action Items

| # | Action | Assigned To | Deadline |
|---|--------|-------------|----------|
| 1 | Convert audit into Jira-ready epic + tasks for Installation page UX recovery | BA (this session) | 2026-10-14 |
| 2 | Implement MDX rewrite per approved backlog (future Implement) | Docs / DevEx | After Gate 2 push |

## Open Questions

| # | Question | Raised By | Notes |
|---|----------|-----------|-------|
| 1 | Parent in Jira: new AC epic (parallel to AC-63) vs child of DHI-641? | BA | mcp-setup precedent: **new AC epic** |
| 2 | Page language: English-only SSOT vs Polish wording from the audit template? | BA | mcp-setup Gate 1: **English only** for docs SSOT |
| 3 | Should PowerShell get full command tabs or only a Git Bash path + one-line PowerShell env note? | Report | Template prefers Git Bash primary for Windows |

## Preserved Context

> “Obecna wersja strony zawiera wyczerpujące szczegóły techniczne, ale nie funkcjonuje poprawnie jako przewodnik instalacyjny (Getting Started). Jest napisana w stylu wewnętrznej specyfikacji inżynierskiej (reference manual / dev notes), a nie ścieżki wdrożeniowej.”
> — UX audit, Executive Summary

> “Sekcja z prostym, gotowym przykładem («First successful install (sample project)») znajduje się na samym dole (sekcja 6), zamiast na początku.”
> — UX audit, inverted flow

> “Z perspektywy QA/BA, którzy chcą tylko uruchomić narzędzie, ta tabela [12 flag] wywołuje paraliż decyzyjny.”
> — UX audit, progressive disclosure

> “Instalacja polega na pobraniu frameworka Agent Collections na Twój komputer, a następnie wdrożeniu jego reguł i narzędzi do Twojego projektu docelowego (consumer project).”
> — UX audit, proposed template framing
