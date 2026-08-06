# EOG upgrade runbook — Cursor Collections → Agent Collections

For maintainers of the **EOG** monorepo. Does not deep-link to any Cursor Collections docs site.

## Before

- EOG uses Cursor Collections patterns: `setup-cursor-local.sh`, MCP `eversis-collections` with `CURSOR_COLLECTIONS_HOME`.
- Areas: FE=`portal/`, BE=`cms/` (plus heavy infra siblings).

## Steps

1. **Branch** — create a rollback-friendly pilot branch (e.g. `dhi-542-agent-collections-pilot`).
2. **Pin framework** — prefer Git submodule `vendor/agent-collections` at a SemVer tag of Agent Collections. Solo: export `AGENT_COLLECTIONS_HOME` to a local checkout.
3. **Install**

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections   # or submodule path
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --vendor submodule --build-mcp --non-interactive \
  --agents=cursor,claude \
  --mcp-servers=eversis-collections,context7,figma,atlassian,playwright,sequential-thinking,pdf-reader \
  --profile=fullstack
```

4. **MCP cutover** — in `.cursor/mcp.json`, change the skills server to `${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js` and drop `CURSOR_COLLECTIONS_HOME` for that server. Keep Playwright, Context7, Figma, Atlassian, etc.
5. **Overlay** — document/enforce `portal`↔frontend-scope and `cms`↔backend-scope in EOG-owned ignores / `docs/context` (see [README.md](./README.md)). Do not patch framework YAML with client names.
6. **Verify** — `.agent-collections/install-selection.json` exists; `eversis_skills_list` works; Cursor rules and `CLAUDE.md` present; FE/BE sessions respect isolation checklist in [pilot-evidence.md](./pilot-evidence.md).
7. **Deprecate legacy for this repo** — stop running `setup-cursor-local.sh` once the pilot is accepted; keep the old branch for rollback.

## Rollback

Check out the pre-pilot branch (or revert the install commit), restore previous MCP JSON / `CURSOR_COLLECTIONS_HOME`, and optionally deinit the submodule.

## Measurement

Re-run the §7.2 file-count proxy after ignore overlays change; update [pilot-evidence.md](./pilot-evidence.md). Target ≥30% or justified estimate + improvement plan.
