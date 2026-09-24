---
sidebar_position: 2
title: Agent Collections MCP
---

# Agent Collections MCP

**Server key:** `eversis-collections`  
**Type:** stdio  
**Package:** [`mcp/eversis-collections-mcp/`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/tree/main/mcp/eversis-collections-mcp) — **not published to npm**; build from a clone.

The **local first-party MCP (Model Context Protocol) bridge** for Agent Collections. It connects **Cursor Agent** to procedural **skills** (`.cursor/skills/eversis-*/SKILL.md`), **Word `.docx` chapter tools** (Business Manager Docs), and **allowlisted repository scripts** — in one server alongside third-party MCPs in [`.cursor/mcp.json`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/.cursor/mcp.json).

Unlike third-party servers that run via `npx`, this server **must be built** before Agent can call its tools.

## Capabilities

- **Skills in Agent** — List, read, and validate `eversis-*` skill packages; run allowlisted per-skill scripts.
- **Business Manager Docs** — Read and edit Word `.docx` release documentation by chapter (summary maps, append/update, table cells).
- **Repo automation** — Run allowlisted root scripts (`sync-prompts`, `sync-framework-doc`) and skill validation from Agent or CI.

## Which Agents and Prompts Use It

| Agent / prompt                                                               | When                                                                                                                                                        |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Engineering Manager** (`@eversis-implement`)                               | Skill discovery during implement; **`eversis-fine-handoff`** on Fine, plus **`eversis-promote-domain-knowledge`** when Fine's optional second draft applies |
| **QA practice** (`@eversis-qa-workflow`)                                     | QA skills on demand (`eversis-planning-tests`, regression, AC verify, …)                                                                                    |
| **Code Reviewer** (`@eversis-review`)                                        | Procedural review skills via `eversis_skills_get`                                                                                                           |
| **Business Analyst** (`@eversis-ba-docs-planner`, `@eversis-ba-docs-writer`) | Word chapter tools for release documentation                                                                                                                |
| **Context Engineer** (Research step)                                         | `eversis_context_get`/`list` — budget-aware read of `docs/context/<project>/` (see [Domain Context (SSOT)](../../domain-context))                           |
| **All agents**                                                               | When `eversis-agent-core` instructs skill discovery before broad implementation                                                                             |
| **Any agent (on request)**                                                   | `eversis-import-confluence-knowledge` (seed domain context from an existing Confluence page), `eversis-audit-domain-knowledge` (periodic review)            |
| **Contributors**                                                             | `eversis_skills_validate` (same checks as `npm run validate` in the MCP package)                                                                            |

## Tool inventory (17 tools)

| Group              | Tools                                                                                                                                                                                      | Count |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----- |
| **Skills**         | `eversis_skills_list`, `eversis_skills_get`, `eversis_skills_validate`, `eversis_skill_run_script`                                                                                         | 4     |
| **Repo**           | `eversis_repo_run_script` (`sync-prompts`, `sync-framework-doc`)                                                                                                                           | 1     |
| **Domain context** | `eversis_context_get`, `eversis_context_list`, `eversis_context_sync`                                                                                                                      | 3     |
| **Word / BA Docs** | `generate_summary_map`, `read_chapter`, `append_chapter`, `update_chapter`, `update_table_cell`, `list_section_elements`, `inspect_document`, `backup_docx`, `upload_to_sharepoint` (stub) | 9     |

## Tool reference

Each entry: **Focus** (goal), **How to use** (when Agent calls it), **Outcome** (what you get back).

:::note Keep in sync
When adding or changing MCP tools, update this section and the matching **Tool reference** in [`mcp/eversis-collections-mcp/README.md`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/mcp/eversis-collections-mcp/README.md). The package README also documents document compatibility, environment variables, and tests.
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

### Domain context {#domain-context}

Read, list, and refresh **domain context** — durable, cross-task knowledge (a confirmed business rule, a reusable integration pattern) stored as plain Markdown in `docs/context/`. Full concept: [Domain Context (SSOT)](../../domain-context).

#### `eversis_context_list`

- **Focus:** Discover which components exist across both layers (`docs/context/<project>/` and `docs/context/global/`).
- **How to use:** No arguments. Example: `eversis_context_list()`.
- **Outcome:** JSON array of component names with their source layer (`project` or `global`).

#### `eversis_context_get`

- **Focus:** Read one named component — project layer first, falling back to global.
- **How to use:** Pass `component` (the name from `eversis_context_list`). Example: `eversis_context_get({ component: "billing" })`.
- **Outcome:** JSON with the file's content and frontmatter; on a global-layer result, also a staleness flag comparing the local copy against the `domain-context` remote. Updates the file's `last_consulted` field as a side effect.

#### `eversis_context_sync`

- **Focus:** Pull the latest `domain-context` content into `docs/context/global/`.
- **How to use:** Optional `branch` (defaults to `main`). Example: `eversis_context_sync({ branch: "main" })`.
- **Outcome:** JSON with `{ synced, message }` — runs a `git subtree pull --squash`; failures are reported, never silently retried.

### Word (Business Manager Docs)

**Docx paths:** Pass a **project-relative** path under the consumer project (container `/workspace`), e.g. `.playwright-mcp/backups/file.docx`. Host absolute paths (`/Users/...`) are not visible inside the MCP container. `/workspace` is the consumer project only when `.agent-collections/install-selection.json` is present (same rule as domain context); without it, resolution falls back to the image cwd. Cursor sets host MCP `env.CONSUMER_PROJECT_ROOT`; vendored Claude Code relies on `scripts/run-eversis-collections-mcp.sh` for the same mount.

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

Full playbook: [Business Manager Docs workflow](../../main-flow/workflow/business-manager-docs).

### BA Docs safety {#ba-docs-safety}

Before editing any `.docx` through MCP:

- **Always** call `backup_docx` before the first write in a session.
- **Prefer `append_chapter`** for additive edits — it preserves tables and images.
- **`update_chapter` replaces the entire section body** — use only on **TEXT-SAFE** sections (no tables, no images); for tables use `update_table_cell`.

## Configuration

### Workspace (this repository)

```bash
docker compose build eversis-collections
```

Enable **`eversis-collections`** in **Cursor → Settings → MCP**, then restart Cursor.

```json
{
  "eversis-collections": {
    "command": "docker",
    "args": [
      "compose",
      "-f",
      "docker-compose.yml",
      "run",
      "--rm",
      "-T",
      "eversis-collections"
    ],
    "type": "stdio"
  }
}
```

`docker-compose.yml` bind-mounts **two** separate volumes: `.:/repo` (the framework checkout, resolved relative to `docker-compose.yml`'s own directory — the `-f` path is what points Compose at that file) and `${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace` (your consumer project). How `CONSUMER_PROJECT_ROOT` is set depends on the host:

- **Cursor** — the installer writes it into MCP `env` as `${workspaceFolder}`.
- **Vendored Claude Code** (copy or submodule under `vendor/` — a copy of the framework inside your repo) — `.mcp.json` starts `bash -c`, which execs `scripts/run-eversis-collections-mcp.sh`. That script sets `CONSUMER_PROJECT_ROOT` from its own location (the parent of `scripts/`) and points Compose at `vendor/agent-collections/docker-compose.yml`. Do not treat `${CLAUDE_PROJECT_DIR:-.}` as the portable vendored fix.
- **Absolute (non-vendored) Claude Code** — still uses MCP `env` `${CLAUDE_PROJECT_DIR:-.}` and a baked `AGENT_COLLECTIONS_HOME` fallback on the `-f` path.

`${PWD}` is only a fallback (`PWD` is often the compose-file directory when `-f` is `vendor/agent-collections/docker-compose.yml`). Domain-context tools read `docs/context/` through `/workspace`, not `/repo`, and only treat `/workspace` as the project when `install-selection.json` is there. See [Domain Context (SSOT)](../../domain-context) and [MCP Setup](../../getting-started/mcp-setup#domain-context-needs-the-project-volume-not-just-the-framework-volume).

### Consumer project (framework outside workspace)

1. Clone the framework once and set **`AGENT_COLLECTIONS_HOME`** to that checkout (must contain `.cursor/skills` and `docker-compose.yml`).
2. Bootstrap with `setup-agent-collections.sh --build-mcp` — see [Installation §4](../../getting-started/installation).
3. Enable **`eversis-collections`** in Cursor MCP settings and restart.

The setup script writes `docker compose -f ${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml run --rm -T eversis-collections` in your project's `.cursor/mcp.json` (local mode) — the `-f` path is the only place `AGENT_COLLECTIONS_HOME` is used; Compose resolves the `.:/repo` bind mount relative to that file's own directory. For Cursor, the second volume uses host `CONSUMER_PROJECT_ROOT` `${workspaceFolder}`. Absolute (non-vendored) Claude Code still uses `${CLAUDE_PROJECT_DIR:-.}` in MCP `env`. Vendored Claude uses the wrapper above, not an env token. `${PWD}` is only a fallback. Export `AGENT_COLLECTIONS_HOME` where the Cursor process can see it — see [Installation](../../getting-started/installation).

## Do not register skills as Agent Skills

For this framework, consume skills through **`eversis_skills_*` MCP tools** — do **not** register `.cursor/skills/` as Cursor **Agent Skills**. See [Skills overview](../skills/overview) and [AGENTS.md](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/AGENTS.md).

## Verify

After restart, open **Agent** and confirm tools such as **`eversis_skills_list`** appear. If tools are missing, rebuild the image with `docker compose build eversis-collections` and check that it built successfully.

## Authentication

No OAuth or API keys. The server **runs in a Docker container**; Node.js is only needed to develop the package itself (see [`mcp/eversis-collections-mcp/`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/tree/main/mcp/eversis-collections-mcp)'s build/test scripts). A **Docker Compose build step is required** before tools are available — unlike `npx`-based third-party MCPs.

Optional: set **`AGENT_COLLECTIONS_HOME`** when walk-up auto-detection cannot find `.cursor/skills` from your workspace — it is used only to locate the right `docker-compose.yml` via `-f`, never passed into the container itself.

## Official Documentation

- [MCP package README](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/mcp/eversis-collections-mcp/README.md) — document compatibility (BOM, locale), environment variables, tests, CLI
- [MCP setup](../../getting-started/mcp-setup) — workspace vs user profile, third-party servers

## When NOT to Use

- Projects that **do not** vendor Agent Collections skills and never run `@eversis-implement`, `@eversis-review`, or BA Docs prompts (you may omit this server from `.cursor/mcp.json`).
- Loading a single `SKILL.md` once by hand — you can **`@`-attach** the file or read it directly without MCP when you are not running the full orchestration workflow.
- Registering `.cursor/skills/` in Cursor **Agent Skills** UI — use this MCP instead.
