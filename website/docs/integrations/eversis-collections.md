---
sidebar_position: 2
title: Agent Collections MCP
---

# Agent Collections MCP

**Server key:** `eversis-collections`  
**Type:** stdio  
**Package:** [`mcp/eversis-collections-mcp/`](https://github.com/PiotrNie-Eversis/agent-collections/tree/main/mcp/eversis-collections-mcp) — **not published to npm**; build from a clone.

The **local first-party MCP bridge** for Agent Collections. It connects **Cursor Agent** to procedural **skills** (`.cursor/skills/eversis-*/SKILL.md`), **Word `.docx` chapter tools** (Business Manager Docs), and **allowlisted repository scripts** — in one server alongside third-party MCPs in [`.cursor/mcp.json`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/mcp.json).

Unlike third-party servers that run via `npx`, this server **must be built** before Agent can call its tools.

## Capabilities

- **Skills in Agent** — List, read, and validate `eversis-*` skill packages; run allowlisted per-skill scripts.
- **Business Manager Docs** — Read and edit Word `.docx` release documentation by chapter (summary maps, append/update, table cells).
- **Repo automation** — Run allowlisted root scripts (`sync-prompts`, `sync-framework-doc`) and skill validation from Agent or CI.

## Which Agents and Prompts Use It

| Agent / prompt | When |
| --- | --- |
| **Engineering Manager** (`@eversis-implement`) | Skill discovery during implement; **`eversis-fine-handoff`** on Fine |
| **QA practice** (`@eversis-qa-workflow`) | QA skills on demand (`eversis-planning-tests`, regression, AC verify, …) |
| **Code Reviewer** (`@eversis-review`) | Procedural review skills via `eversis_skills_get` |
| **Business Analyst** (`@eversis-ba-docs-planner`, `@eversis-ba-docs-writer`) | Word chapter tools for release documentation |
| **All agents** | When `eversis-agent-core` instructs skill discovery before broad implementation |
| **Contributors** | `eversis_skills_validate` (same checks as `npm run validate` in the MCP package) |

## Tool inventory (14 tools)

| Group | Tools | Count |
| --- | --- | --- |
| **Skills** | `eversis_skills_list`, `eversis_skills_get`, `eversis_skills_validate`, `eversis_skill_run_script` | 4 |
| **Repo** | `eversis_repo_run_script` (`sync-prompts`, `sync-framework-doc`) | 1 |
| **Word / BA Docs** | `generate_summary_map`, `read_chapter`, `append_chapter`, `update_chapter`, `update_table_cell`, `list_section_elements`, `inspect_document`, `backup_docx`, `upload_to_sharepoint` (stub) | 9 |

## Tool reference

Each entry: **Focus** (goal), **How to use** (when Agent calls it), **Outcome** (what you get back).

:::note Keep in sync
When adding or changing MCP tools, update this section and the matching **Tool reference** in [`mcp/eversis-collections-mcp/README.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/mcp/eversis-collections-mcp/README.md). The package README also documents document compatibility, environment variables, and tests.
:::

### Skills

#### `eversis_skills_list`

- **Focus:** Discover all `eversis-*` skill packages under `.cursor/skills/`.
- **How to use:** Enabled MCP; Agent calls at the start of implement/review when `eversis-agent-core` instructs skill discovery.
- **Outcome:** JSON list of `{ name, description }` from each `SKILL.md` frontmatter.

#### `eversis_skills_get`

- **Focus:** Load procedural content from a skill folder.
- **How to use:** Agent passes `skillId` (folder name) and optional `relativePath` (`SKILL.md`, `references/…`, `assets/…`); optional `startLine` / `endLine` for partial reads.
- **Outcome:** JSON with resolved file path and full or ranged text content.

#### `eversis_skills_validate`

- **Focus:** CI-quality validation of every skill package.
- **How to use:** Call from Agent or run `npm run validate` / `node dist/cli.js validate`; set `treatWarningsAsErrors: true` (or `--strict`) in CI.
- **Outcome:** JSON report of errors and warnings (frontmatter, directory name match, `SKILL.md` presence, length hints).

#### `eversis_skill_run_script`

- **Focus:** Run deterministic, allowlisted scripts bundled under `.cursor/skills/eversis-*/scripts/`.
- **How to use:** Agent passes a script key from the MCP allowlist (e.g. stats helpers for skill authoring).
- **Outcome:** JSON with `exitCode`, `stdout`, and `stderr`.

#### `eversis_repo_run_script`

- **Focus:** Run allowlisted maintenance scripts at the repository root.
- **How to use:** Agent passes `script`: `sync-prompts` or `sync-framework-doc`.
- **Outcome:** JSON with `exitCode`, `stdout`, and `stderr`.

### Word (Business Manager Docs)

#### `generate_summary_map`

- **Focus:** Map `.docx` headings to stable `chapter_id` values (`sec-0`, `sec-1`, …).
- **How to use:** First step when onboarding a document; pass `docx_path` and optional `output_md_path`.
- **Outcome:** Writes `*.summary.md` next to the doc (unless `output_md_path` is set) with section table including `hasTables` / `hasImages` flags. Locale-aware heading detection (Polish `Nagwek*`, French `Titre*`, etc.).

#### `read_chapter`

- **Focus:** Read current body text for one section before editing.
- **How to use:** Pass `docx_path` and `chapter_id` from the summary map.
- **Outcome:** Plain-text section body (heading line excluded).

#### `append_chapter`

- **Focus:** Add new paragraphs **without** removing existing content, tables, or images.
- **How to use:** Preferred for additive edits on **TEXT-SAFE** or **IMAGE-CONTAINS** sections; pass `new_content` with `\n\n` between paragraphs; optional `requires_graphics_review`.
- **Outcome:** Saved `.docx` with appended paragraphs; confirmation message with paragraph count.

#### `update_chapter`

- **Focus:** **Replace** entire section body with new plain text.
- **How to use:** Only on **TEXT-SAFE** sections with no tables/images; read with `read_chapter` first if merging existing text. See [BA Docs safety](#ba-docs-safety) below.
- **Outcome:** Saved `.docx` with replaced body; optional graphics-review placeholder paragraph.

#### `update_table_cell`

- **Focus:** Edit cells inside Word tables within a section.
- **How to use:** After `list_section_elements` confirms **TABLE-CONTAINS**; update one cell (`row`, `col`, `new_content`) or append a row (`action: append_row`, `row_values`).
- **Outcome:** Saved `.docx`; message describing the cell or row change.

#### `list_section_elements`

- **Focus:** Classify a section before choosing an edit tool.
- **How to use:** Call per `chapter_id` before `append_chapter`, `update_chapter`, or `update_table_cell`.
- **Outcome:** JSON with `content_type` (`TEXT-SAFE`, `TABLE-CONTAINS`, `IMAGE-CONTAINS`, `MIXED`), counts, and character total.

#### `inspect_document`

- **Focus:** Pre-flight analysis of an entire `.docx` before the first edit session.
- **How to use:** Especially when plan status is UNVERIFIED; pass `docx_path` only.
- **Outcome:** JSON with BOM flag, heading locale, per-section `content_type` summary, warnings, and `READY` / `WARNINGS` / `ERROR` status.

#### `backup_docx`

- **Focus:** Timestamped binary backup before any modification.
- **How to use:** **Always** call before the first write in a BA Docs session; optional `backup_dir` (defaults to `backups/` beside the file).
- **Outcome:** Path to the backup copy on disk.

#### `upload_to_sharepoint`

- **Focus:** Publish finished documentation to SharePoint.
- **How to use:** Stub only — validates that `docx_path` exists.
- **Outcome:** Message that upload is not implemented; publish manually or extend this MCP for your tenant.

**Security:** `eversis_skill_run_script` and `eversis_repo_run_script` only run paths on a fixed allowlist in this package. New scripts require a PR that adds the file and the key in `src/skillScripts.ts` or `src/repoScripts.ts`. Tools that call external APIs (e.g. cloud cost APIs) are not bundled here by default; add them only with explicit env/credential requirements and review.

## Supported workflows

### Implement with skills

```text
@eversis-implement <ticket>
  ↳ Agent calls eversis_skills_list / eversis_skills_get (e.g. eversis-fine-handoff on Fine)
  ↳ You review research, plan, and code at human gates
```

### Business Manager Docs

```text
@eversis-ba-docs-planner → plan with chapter_ids and content types
@eversis-ba-docs-writer
  ↳ backup_docx → inspect_document → list_section_elements
  ↳ TEXT-SAFE → append_chapter or read_chapter + update_chapter
  ↳ TABLE-CONTAINS → update_table_cell
```

Full playbook: [Business Manager Docs workflow](../workflow/business-manager-docs).

### BA Docs safety {#ba-docs-safety}

Before editing any `.docx` through MCP:

- **Always** call `backup_docx` before the first write in a session.
- **Prefer `append_chapter`** for additive edits — it preserves tables and images.
- **`update_chapter` replaces the entire section body** — use only on **TEXT-SAFE** sections (no tables, no images); for tables use `update_table_cell`.

## Configuration

### Workspace (this repository)

```bash
cd mcp/eversis-collections-mcp && npm install && npm run build
```

Enable **`eversis-collections`** in **Cursor → Settings → MCP**, then restart Cursor.

```json
{
  "eversis-collections": {
    "command": "node",
    "args": ["mcp/eversis-collections-mcp/dist/index.js"],
    "type": "stdio"
  }
}
```

Paths in `args` are relative to the **repository root** that contains `.cursor/mcp.json`.

### Consumer project (framework outside workspace)

1. Clone the framework once and set **`AGENT_COLLECTIONS_HOME`** to that checkout (must contain `.cursor/skills`).
2. Bootstrap with `setup-agent-collections.sh --build-mcp` — see [Installation §4](../getting-started/installation).
3. Enable **`eversis-collections`** in Cursor MCP settings and restart.

The setup script writes `${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js` in your project's `.cursor/mcp.json` (local mode). Export `AGENT_COLLECTIONS_HOME` where the Cursor process can see it — see [Installation](../getting-started/installation).

## Do not register skills as Agent Skills

For this framework, consume skills through **`eversis_skills_*` MCP tools** — do **not** register `.cursor/skills/` as Cursor **Agent Skills**. See [Skills overview](../skills/overview) and [AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md).

## Verify

After restart, open **Agent** and confirm tools such as **`eversis_skills_list`** appear. If tools are missing, rebuild the package and check that **`dist/index.js`** exists.

## Authentication

No OAuth or API keys. The server runs locally via **Node.js** (≥ 18). A **build step is required** before tools are available — unlike `npx`-based third-party MCPs.

Optional: set **`AGENT_COLLECTIONS_HOME`** when walk-up auto-detection cannot find `.cursor/skills` from your workspace.

## Official Documentation

- [MCP package README](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/mcp/eversis-collections-mcp/README.md) — document compatibility (BOM, locale), environment variables, tests, CLI
- [MCP setup](../getting-started/mcp-setup) — workspace vs user profile, third-party servers

## When NOT to Use

- Projects that **do not** vendor Agent Collections skills and never run `@eversis-implement`, `@eversis-review`, or BA Docs prompts (you may omit this server from `.cursor/mcp.json`).
- Loading a single `SKILL.md` once by hand — you can **`@`-attach** the file or read it directly without MCP when you are not running the full orchestration workflow.
- Registering `.cursor/skills/` in Cursor **Agent Skills** UI — use this MCP instead.
