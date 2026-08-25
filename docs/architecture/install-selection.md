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
| `ssot.externalSsotRepo` | string \| null | GitLab `domain-context` project URL, or `null` when this project does not participate in a shared domain-context SSOT (see `global-domain-context-ssot.research.md`) |
| `ssot.projectContextPath` | string | Project-level domain-knowledge path, default `docs/context/<project>/` |
| `ssot.globalContextPath` | string | Subtree-pull target for `externalSsotRepo`, default `docs/context/global/` — a dedicated sibling directory, never nested inside `projectContextPath`, so `git subtree` never shares a prefix with natively-committed files (`README.md`, other `docs/context/<project>/` folders) |
| `ssot.confluenceSpaceKey` | string \| null | Optional. Recorded for the one-time AS-IS import (`eversis-import-confluence-knowledge` skill, run manually) — omitting it never blocks install (empty-start mode) |

### Required environment for domain-context promotion

When `ssot.externalSsotRepo` is set, the knowledge-promotion skill (`eversis-promote-domain-knowledge`) writes to that GitLab project through the REST API (Branches → Commits → Merge Requests), not a local checkout. It expects a `GITLAB_TOKEN` environment variable with `api` scope and write access to `externalSsotRepo` to be available in the agent's execution environment. Provisioning that token (how it reaches a developer's machine or CI runner) is a team/organization responsibility — the installer never generates, stores, or requests it.

## Rules

- Project-owned-ish: upgrade/sync **reads** this file; does not delete it.
- Missing or corrupt file → upgrade **fails** with wizard instructions (no invented multi-agent install).
- See README Upgrade contract for operational CLI (`--upgrade` / `--sync`).
