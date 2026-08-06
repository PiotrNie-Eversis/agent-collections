# Install selection schema

Consumer install record written by `scripts/setup-agent-collections.sh` to:

```text
.agent-collections/install-selection.json
```

## Schema (Q3)

| Field | Type | Description |
|-------|------|-------------|
| `frameworkVersion` | string | SemVer from framework `package.json` at install time |
| `agents` | string[] | Selected adapters: `cursor`, `claude`, `opencode` |
| `mcpServers` | string[] | Selected MCP server ids from catalog |
| `domainProfile` | string | `frontend` \| `backend` \| `fullstack` |
| `vendorMode` | string | `local` \| `submodule` \| `copy` |
| `linkMode` | string | Effective link mode (`auto` resolved to `symlink`/`copy`) |
| `recordedAt` | string | ISO-8601 timestamp (optional helper) |

## Rules

- Project-owned-ish: upgrade/sync **reads** this file; does not delete it.
- Missing or corrupt file → upgrade **fails** with wizard instructions (no invented multi-agent install).
- See README Upgrade contract for operational CLI (`--upgrade` / `--sync`).
