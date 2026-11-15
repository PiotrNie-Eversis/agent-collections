# Local MCP server for **Agent Collections**

Lists, reads, and validates `eversis-*` skills under **`.ai/skills/`**. Resolves repository root via walk-up to `.ai/skills` or **`AGENT_COLLECTIONS_HOME`**. It also serves the consumer project's domain knowledge (`docs/context/`), runs allowlisted scripts, and edits Word `.docx` files for the BA Docs workflow.

## Tools (18)

| Group | Tools |
|-------|-------|
| Skills | `eversis_skills_list`, `eversis_skills_get`, `eversis_skills_validate` |
| Domain knowledge (`docs/context/`) | `eversis_context_list`, `eversis_context_get`, `eversis_context_sync` |
| Scripts | `eversis_repo_run_script` (allowlist: `sync-adapters` only), `eversis_skill_run_script` (allowlist: `eversis-creating-skills-skill-md-stats`) |
| Word `.docx` | `inspect_document`, `read_chapter`, `update_chapter`, `append_chapter`, `list_section_elements`, `update_table_cell`, `generate_summary_map`, `backup_docx`, `validate_docx`, `upload_to_sharepoint` (stub: checks that the file exists, does not upload) |

`eversis_context_sync` never runs on its own. Call it when you want to refresh `docs/context/global/`.

## Roots and environment

| Variable | Used for |
|----------|----------|
| `AGENT_COLLECTIONS_HOME` | Framework root (skills, scripts). Used when walk-up from the server folder finds no `.ai/skills`. |
| `CONSUMER_PROJECT_ROOT` | Consumer project root for the `eversis_context_*` and `.docx` tools. Used only when it holds `.agent-collections/install-selection.json`; otherwise the server tries `/workspace`, then its working directory. Relative `.docx` paths resolve against this root and may not leave it. |

`docker-compose.yml` mounts the framework at `/repo` and the consumer project at `/workspace` (from `CONSUMER_PROJECT_ROOT`, or `PWD` when unset), and sets both variables inside the container.

Not published to npm. Runs via Docker Compose — build the image from the repository root:

```bash
docker compose build eversis-collections
```

For package development (not required to run the server):

```bash
cd mcp/eversis-collections-mcp
npm install
npm run build
npm test
```

Configure Cursor (or other MCP hosts) with `templates/mcp.json` / installer merge — default entry runs `docker compose -f ${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml run --rm -T eversis-collections`.
