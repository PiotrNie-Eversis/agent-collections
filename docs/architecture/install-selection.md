## Purpose

`.agent-collections/` is the **consumer install record directory** created by `scripts/setup-agent-collections.sh`. It is intentional (not leftover from Cursor Collections). Upgrade / sync **reads** this directory so re-runs can reuse agents, MCP servers, profile, and vendor mode without re-prompting.

Primary file:

```text
.agent-collections/install-selection.json
```

Related helper files may also appear (for example `domain-profile.txt`, `area-profile.txt`). They are small install hints — not the framework SSOT (SSOT remains under `AGENT_COLLECTIONS_HOME/.ai/` or `vendor/agent-collections/.ai/`).

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
