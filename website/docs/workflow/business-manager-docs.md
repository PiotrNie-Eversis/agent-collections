---
sidebar_position: 6
title: Business Manager Docs
---

# Business Manager Docs

Use this workflow when you need to **update large business or regulatory Word documents** (often `.docx` files with hundreds of pages) after a release — without pasting whole documents into the chat or destroying styles and tables.

It follows the same **relay race** idea as the rest of Agent Collections: each phase produces a **reviewable artifact** (the “baton”), and humans approve before the next agent runs.

:::tip How this differs from Standard Flow
**[`eversis-implement`](./standard-flow)** is for **product code**: the Engineering Manager drives research → plan → implementation → review, often with UI or E2E verification.

**Business Manager Docs** is for **Word documentation**: a **Planner** builds `docs-update-plan.md` from **Confluence rules** and **Jira release** scope; after your approval, a **Writer** applies chapter-level edits via MCP tools. There is **no** dev-server URL step and **no** `eversis-review-ui` requirement.
:::

## When to Use It

- You have (or can generate) a **document map** — typically `summary.md` from `generate_summary_map` — for a `.docx` source of truth.
- Release work is tracked in **Jira**, and **documentation update rules** live in **Confluence** (read dynamically; not baked into a single static prompt).
- You need **incremental chapter edits** that preserve Word styling (avoid whole-document Markdown round-trips).

Normative requirements (roles, numbered rules, prompt vs rule contract) are on this page under [**Normative requirements**](#normative-requirements).

## Normative requirements

This page is the **single source of truth** for the BA Docs workflow — playbook steps below and normative rules here.

### Context and business goal

- **Problem:** Manually updating extensive project documents (e.g. `.docx` files over 400 pages — regulatory specs, product manuals, or compliance binders) after each release is time-consuming, error-prone, and requires tedious mapping of code/Jira task changes to non-technical business language.
- **Goal:** A fully integrated Cursor IDE workflow, based on AI agents and a **Relay Race** architecture, that reduces documentation update time while preserving the original formatting of base documents (including table structure and diagrams).

Document guidelines are loaded dynamically from **Confluence** (not baked into a single static prompt).

## Architecture (High Level)

| Piece | Role |
| ----- | ---- |
| **Atlassian MCP** | Read **Confluence** pages for documentation rules; pull **Jira** issues for the named release or scope. |
| **`eversis-collections` MCP** | **`.docx` tools**: `generate_summary_map`, `read_chapter`, `update_chapter`, and `upload_to_sharepoint` (see server docs under `mcp/eversis-collections-mcp/`). Enable this server after a local build — see [MCP setup](../getting-started/mcp-setup) and [AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md). |
| **`summary.md`** | Navigation map for the physical `.docx` (structure / chapter identifiers for agents). Each section entry now includes `hasTables` and `hasImages` flags so the Planner can mark chapters that require special handling. |
| **`docs-update-plan.md`** | Planner output: which chapters change, what to change, and flags such as `[REQUIRES_GRAPHICS_UPDATE]` where diagrams need a human pass. Sections detected as `hasTables: true` should be labelled `TABLE-CONTAINS` to signal the Writer to use read-first / append rather than full replace. |

### Document format compatibility

The `.docx` engine automatically handles two common issues with non-English Word documents:

- **UTF-8 BOM** — MS Office on Windows (any locale) may write a BOM byte before `<?xml>`. The engine strips it before parsing so documents created on Polish, French, or other locale systems work without pre-processing.
- **Locale heading styles** — Word localises built-in style names (e.g. Polish `Nagwek1`–`Nagwek4`, French `Titre1`–`Titre4`). The engine reads `word/styles.xml` and maps every style ID to its canonical English name, so heading detection works correctly on any-language document.

### Editing safety

`update_chapter` **replaces** all paragraphs in a section — inline images and custom paragraph styles are lost. Follow the principle:

1. Always call `read_chapter` first to capture existing text.
2. For text-only additions, append new content to the existing text before passing to `update_chapter`.
3. For sections flagged `hasTables: true` or `hasImages: true` in `summary.md`, defer to a future `append_chapter` / `update_table_cell` tool (tracked in the BA Docs Workflow Evolution plan) or handle manually.

## Prompts vs Role Rules

Following **Agent Collections** monorepo convention, we separate:

- **Public prompt** — **`.cursor/prompts/public/eversis-*.md`**: **executable workflow** content (Docusaurus frontmatter + SOP steps). In Cursor, **`@` + file stem** (e.g. **`@eversis-ba-docs-planner`**) usually resolves **this prompt**.
- **Role rule** — **`.cursor/rules/eversis-*.mdc`**: **who the agent is**, boundaries, MCP tool behavior; attached on demand (**`@`** to the `.mdc` file or picker selection), often with `alwaysApply: false`.

In practice for this workflow **both artifacts are normative**: the prompt starts the track; the rule reinforces the role and framework consistency. If **`@`** does not pull both into one session, **explicitly attach** the second file (full path under `.cursor/…`), as in [AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md).

## Documentation channels (Word vs Repo)

Agent Collections has **two separate documentation playbooks** — do not mix them:

| Channel | Prompts | Format | Typical trigger |
| ------- | ------- | ------ | ---------------- |
| **BA Docs (Word)** | `@eversis-ba-docs-planner` → `@eversis-ba-docs-writer` | `.docx` | Jira release + Confluence rules |
| **Repo Docs** | `@eversis-repo-docs-writer` | README, CHANGELOG, `website/docs`, `docs/` | Documentation task from `@eversis-implement` plan |

This page documents **BA Docs (Word)** only.

## Roles

The workflow relies on two specialized agents communicating through a shared artifact (`docs-update-plan.md`).

### 1. Planner — Lead Analyst (BA Docs / Word)

- **Prompt (workflow):** **`.cursor/prompts/public/eversis-ba-docs-planner.md`** — attach **`@eversis-ba-docs-planner`**
- **Role rule:** **`.cursor/rules/eversis-ba-docs-planner.mdc`**
- **Responsibility:** Understand the Release scope, verify Confluence guidelines, and map changes to the appropriate document sections.
- **Input:** Jira Release ID + Confluence page title with update rules + `summary.md` (or path to `.docx` to generate a map first).
- **Output:** **`docs-update-plan.md`**
- **Rules:**

1. **[CRITICAL STEP]** Before analyzing tasks from the Release, use the Atlassian MCP tool to read the Confluence page (e.g. "&lt;your product&gt; Documentation Definitions & Updating Rules"). Use these rules as a decision matrix defining update boundary conditions (e.g. whether a document gets "N/A" status, version requirements).
2. Use Atlassian MCP to fetch all tasks linked to the Release in Jira.
3. Identify which tasks affect business requirements and align them with the `summary.md` table of contents.
4. Mark document chapter numbers that require updates and briefly describe WHAT must be changed.
5. If a change affects architecture/a UML/Visio diagram, add the flag **`[REQUIRES_GRAPHICS_UPDATE]`** to the plan.

### 2. Writer — Technical Writer (BA Docs / Word)

- **Prompt (workflow):** **`.cursor/prompts/public/eversis-ba-docs-writer.md`** — attach **`@eversis-ba-docs-writer`**
- **Role rule:** **`.cursor/rules/eversis-ba-docs-writer.mdc`**
- **Responsibility:** Physical content update in the `.docx` file using **`eversis-collections` MCP** `.docx` tools.
- **Input:** Approved **`docs-update-plan.md`**
- **Output:** Modified document ready for verification.
- **Rules:**

1. Work iteratively. Read the `docs-update-plan.md` plan section by section.
2. Use the `read_chapter` tool, modify the text, translating any technical language into system behavior descriptions.
3. Use the `update_chapter` tool to save the change.
4. Where you encounter the flag **`[REQUIRES_GRAPHICS_UPDATE]`**, insert a clear in-document marker for BA verification of UML/Visio-style diagrams: **`>>> FOR BA REVIEW: CHECK AND UPDATE DIAGRAM ACCORDING TO RELEASE <<<`** (plain OOXML body text — not native Word comment bubbles).

## Command Sequence

```text
1️⃣ @eversis-ba-docs-planner
   <release / scope> | <Confluence page for doc rules> | summary.md or path to .docx
   ↳ 📖 Read Confluence rules via Atlassian MCP
   ↳ 🔗 Pull Jira issues for the release
   ↳ 🗺️ Map impact to chapters using summary.md
   ↳ 📝 Produce docs-update-plan.md

2️⃣ Gate — Plan approval (human)
   ↳ 📖 Review docs-update-plan.md
   ↳ ✅ Approve, edit, or reject before any Writer run

3️⃣ @eversis-ba-docs-writer
   Implement updates per docs-update-plan.md (attach plan + rules if needed)
   ↳ 📖 read_chapter → edit → update_chapter (iterative)
   ↳ 💾 Save .docx; flag diagram rows for manual graphics review

4️⃣ Gate — Document review (human)
   ↳ 📖 Open Word outputs; fix diagrams/tables if needed
   ↳ 🚀 Publish via your org process (SharePoint / Confluence / etc.)
```

### Example commands

**Planner** (attach **`@eversis-ba-docs-planner`**; optionally **`.cursor/rules/eversis-ba-docs-planner.mdc`**):

```text
@eversis-ba-docs-planner Prepare a <your product> documentation update plan for Release 2.4.5. Project rules are on the Confluence page "<your product> Documentation Definitions & Updating Rules".
```

**Writer** (attach **`@eversis-ba-docs-writer`**; optionally **`.cursor/rules/eversis-ba-docs-writer.mdc`**):

```text
@eversis-ba-docs-writer Implement changes to the relevant documents according to the plan in docs-update-plan.md
```

## Workflow Diagram

```
┌─────────────────────────────┐
│  Confluence (rules)         │
│  + Jira (release scope)      │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│  Planner (@ba-docs-planner) │
│  → docs-update-plan.md       │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│  ★ Human approves plan       │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│  Writer (@ba-docs-writer)    │
│  MCP: read/update chapters   │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│  ★ Human reviews .docx       │
│  → publish                   │
└─────────────────────────────┘
```

## Optional Slash Commands

If your workspace includes **`.cursor/commands/`**, you may have thin wrappers such as **`/eversis-ba-docs-planner`** and **`/eversis-ba-docs-writer`** — same prompts, faster invocation from Chat.

## Connecting to Other Flows

This workflow **does not replace** backlog or code delivery. Typical separation:

- **Ideate / backlog** — [`eversis-analyze-materials`](./workshop-flow) and Jira refinement.
- **Code delivery** — [`eversis-implement`](./standard-flow) → [`eversis-review`](./overview#3-review).
- **Regulatory or BA Word docs after release** — **Business Manager Docs** (this page).

:::warning Important
Treat every Planner output and every Writer save as a **draft** until a human approves. AI assistance does not remove accountability for regulated or customer-facing documentation.
:::
