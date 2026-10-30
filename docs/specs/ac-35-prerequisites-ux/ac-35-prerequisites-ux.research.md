# AC-35 prerequisites ux - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | AC-35 |
| Title | Prerequisites page: UX overhaul for QA/BA (role matrix, OS tabs, verification) |
| Description | UX/technical audit (2026-10-13): Prerequisites page is engineer-centric; needs role matrix, macOS/Windows tabs, official vendor links, verification steps, and de-emphasized framework jargon. See Jira AC-35 for full requirements and acceptance criteria. |
| Priority | Medium |
| Reporter | Piotr Niemirski |
| Created Date | 2026-10-13 |
| Due Date | — |
| Labels | documentation, getting-started, ux, website |
| Estimated Effort | Small–medium (docs-only; first Docusaurus Tabs adopter) |

## Business Impact

Prerequisites is step 1 in the **Start here** checklist. QA, BA, and PO readers currently see adapter/submodule/MCP-developer framing before they can install tools. Clear role-based requirements, OS-specific GUI installs, and a verification block reduce internal support questions and improve time-to-first successful install on consumer projects.

## Gathered Information

### Knowledge Base & Task Management Tools

- **Jira AC-35** (Backlog): Story with 12 numbered requirements, 6 acceptance criteria, explicit out of scope (installer/MCP image changes, full Polish translation, Linux tab without PO approval).
- Jira Delivery Standard suggested folder `docs/specs/prerequisites-docs-update/`; repo **tracked convention** is `docs/specs/<key>-<topic>/` per `docs/specs/README.md` — this artifact uses **`docs/specs/ac-35-prerequisites-ux/`**.
- Audit source referenced in Jira (UX report attachment) was not loaded in this session; requirements in the Jira description are treated as authoritative.

### Codebase

**Current Prerequisites** (`website/docs/getting-started/prerequisites.md`, ~47 lines):

- Opens with **Agent tools** table (Cursor / Claude Code / OpenCode) — framework adapter roles, not a download checklist.
- **Docker** section leads with Compose build command and Node ≥ 18 for MCP **development**; domain-context cwd **gotcha** appears early.
- **Git**, **MCP optional**, **Third-party accounts** — no OS paths, no verification commands, sparse official download links.
- Implies Node is part of the main path (listed alongside Docker in narrative flow).

**Start here** (`website/docs/getting-started/start-here.md`):

- Checklist item 1 lists: Cursor/Claude, Docker, **Node.js ≥ 18 (MCP dev)**, Git — contradicts desired QA/BA message that Node is optional for their role.
- Must be aligned after Prerequisites rewrite (requirement 11).

**MCP setup** (`website/docs/getting-started/mcp-setup.md`):

- Links back to Prerequisites for Docker; deep topics (domain-context volume, Compose) belong here or in admonitions on Prerequisites — not above the fold.

**Website / Docusaurus**:

- `website/docusaurus.config.ts`: classic preset, `onBrokenLinks: 'throw'`, admonitions include `tip`, `info`, `warning`.
- **No existing `<Tabs>` / `TabItem` / `.mdx` files** under `website/` (grep) — AC-35 is the first MDX + Tabs adopter.
- Docusaurus classic docs plugin supports `.mdx` alongside `.md`; doc id should remain `getting-started/prerequisites` when renaming to `prerequisites.mdx` (verify in plan/build).

**Quality gate**: `npm run website:build` required before Done (Jira + project stack).

### Relevant Links

- [Cursor](https://cursor.com/) — AI editor download
- [Claude Code quickstart](https://docs.anthropic.com/en/docs/claude-code/quickstart) — CLI install (macOS/Linux script, Windows PowerShell)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — GUI install; Mac Apple Silicon vs Intel; Windows WSL 2
- [Git for Windows](https://git-scm.com/download/win) / [Git macOS](https://git-scm.com/download/mac)
- [Node.js LTS](https://nodejs.org/) — optional for MCP developers only
- Benchmarks cited in Jira: React Native Environment Setup (OS tabs), GitHub CLI verify-after-install pattern

### Relevant Charts & Diagrams

None required. Suggested IA flow:

```text
Role tip → Quick matrix (tools × roles × links)
    → OS tabs (macOS | Windows) GUI-first
    → Optional Node (info admonition)
    → Verification (commands + sample output)
    → Framework depth (warning/info + link MCP setup)
    → CTA Installation
```

## Current Implementation Status

### Existing Components

- Prerequisites page — `website/docs/getting-started/prerequisites.md` — **needs replacement / MDX conversion**
- Start here checklist — `website/docs/getting-started/start-here.md` — **needs modification** (prerequisite bullet copy)
- MCP setup — `website/docs/getting-started/mcp-setup.md` — **reuse as link target**; optional minor cross-link tweak only if plan requires
- Docusaurus Tabs — **needs extension** (first use in repo)

### Key Files and Directories

- `website/docs/getting-started/` — primary edit surface
- `website/docusaurus.config.ts` — no change expected unless MDX imports need global config (unlikely for `@theme/Tabs`)
- `website/sidebars.ts` — autogenerated from filesystem; confirm no hard-coded `.md` extension

## Gap Analysis

Jira description is implementation-ready. Residual items for plan phase (not blocking research approval):

### Question 1

#### Should the doc file be renamed to `prerequisites.mdx` or stay `.md` with MDX imports?

**Answer:** Use **`prerequisites.mdx`** with `@theme/Tabs` and `@theme/TabItem`. Confirm slug/links unchanged after build (`./prerequisites` routes). *(User: `q1. .mdx`)*

### Question 2

#### Keep a short “Agent tools (framework)” section or fold Cursor/Claude into the matrix only?

**Answer:** Matrix + role tip cover downloads; retain a **compact** “Which AI editor?” note for OpenCode placeholder honesty, **below** verification. *(User: `q2. ok`)*

### Question 3

#### Exact official URLs for Claude Code install scripts?

**Answer:** Pin Anthropic Claude Code quickstart URLs in plan Technical Context at implementation time. *(User: `q3. ok`)*

## Human gates

1. ~~Approve research~~ — done (`q1. .mdx; q2. ok; q3. ok;`)
2. Approve plan (once written)
3. Implement → Review → Fine

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-10-13 | Agent (eversis-implement) | Initial research from Jira AC-35 + codebase scan |
| 2026-10-13 | Agent (eversis-implement) | Gap Analysis Q1–Q3 resolved per user confirmation |
