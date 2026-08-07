---
sidebar_position: 2
title: Installation
---

# Installation

:::info Curated path
Follow **[Start here](./start-here)** for the full onboarding checklist, including **first successful install**.
:::

## 1. Clone the framework

```bash
cd ~/projects
git clone https://github.com/PiotrNie-Eversis/agent-collections.git agent-collections
export AGENT_COLLECTIONS_HOME="$(pwd)/agent-collections"
```

You can use any folder name. Paths in [AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md) and [`documentation/agent-collection.md`](../framework) are relative to the repo root.

Pin consumers to a **SemVer git tag** when you leave local development (see root README versioning).

## 2. Open the framework (optional for maintainers)

1. Open the `agent-collections` folder in Cursor or Claude Code.
2. Read root **`AGENTS.md`** and **`.ai/README.md`**.
3. Refresh adapters after core rule changes: `npm run sync:adapters`.

## 3. Bootstrap a consumer project

The installer lives in the **agent-collections** repository (`scripts/setup-agent-collections.sh`), not in your app repo. Run it from the consumer project (recommended) or pass `--target`.

### Non-interactive example (CI / first install)

```bash
cd ~/my-sample-project
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections

bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor,claude \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

Selection is written to **`.agent-collections/install-selection.json`**. Schema: [`docs/architecture/install-selection.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/architecture/install-selection.md).

### Vendor modes

| Mode | Flag | Notes |
|------|------|-------|
| **Local** (default) | (omit `--vendor`) | Framework stays outside the consumer repo; set `AGENT_COLLECTIONS_HOME` |
| **Submodule** | `--vendor submodule` | **Team / EOG default** — pin a tag in `.gitmodules` |
| **Copy** | `--vendor copy` | Tree under `vendor/agent-collections/` |

### Useful flags

| Flag | Purpose |
|------|---------|
| `--build-mcp` | Force rebuild of `mcp/eversis-collections-mcp` (also builds when `dist` is missing). Does **not** gate the interactive MCP server checklist. |
| `--agents` | `cursor`, `claude`, `opencode` (opencode = placeholder) |
| `--mcp-servers` | Comma-separated ids; without it + `--non-interactive` → `eversis-collections` only |
| `--profile` | `frontend` \| `backend` \| `fullstack` |
| `--link-mode` | `auto` \| `symlink` \| `copy` |
| `--sync` | Refresh framework-managed surfaces |
| `--upgrade` | Reuse selection (fail-safe if missing/corrupt) |
| `--non-interactive` | No prompts — defaults + flags |
| `--target DIR` | Consumer path when not running from that repo |
| `--collections-home DIR` | Framework checkout path (safer than relying on an unset `$AGENT_COLLECTIONS_HOME` expansion) |

Interactive runs (TTY, without `--non-interactive`) prompt for agents × domain profile × MCP servers. `--build-mcp` is optional on interactive installs. Re-runs are idempotent; partial failures list completed vs failed steps.

### After submodule install (teammates)

When the consumer uses `--vendor submodule`, teammates clone the app repo then:

```bash
git submodule update --init --recursive
```

Framework SSOT and MCP live under `vendor/agent-collections/`. Selection remains at `.agent-collections/install-selection.json` (see [install-selection.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/architecture/install-selection.md)).

### Customising stack (Cursor vs Claude)

| Channel | Customise |
|---------|-----------|
| Cursor | `.cursor/rules/eversis-project-stack.mdc` |
| Claude Code | `AGENTS.md` (do not hand-edit generated `CLAUDE.md`) |

## 4. Skills and prompts (MVP)

- **Skills** resolve from **`.ai/skills/`** via MCP **`eversis-collections`** (`eversis_skills_list` / `eversis_skills_get`), or by reading `SKILL.md` directly.
- **Prompts** load by **stable id** under `.ai/prompts/` (e.g. `eversis-implement`). Optional Cursor `@` attach when surfaced.
- This MVP does **not** ship a full mirror under `.cursor/skills` or `.cursor/prompts`. The Cursor adapter **does** generate thin slash shims under `.cursor/commands/` from `.ai/prompts` (after `npm run sync:adapters`).

## 5. Upgrade

```bash
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --upgrade --sync --non-interactive
```

Reuses agents / MCP / profile / vendor / link from selection. Missing or corrupt selection **fails** with wizard instructions (no invented full install). Project-owned paths (stack rule, `docs/context|plans|specs`, local `AGENTS.md`, secrets) are not overwritten without opt-in.

### Keeping consumers aligned

| Install mode | After framework update |
|--------------|------------------------|
| Local + symlink | Pull/tag checkout → rebuild MCP → re-run setup |
| Local + copy | Pull + re-run with `--sync` |
| Vendor submodule | Update submodule to tag → `--upgrade --sync` |
| Vendor copy | Re-run with `--vendor copy --build-mcp` |

## First successful install (sample project)

```bash
mkdir -p /tmp/ac-sample && cd /tmp/ac-sample && git init
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=fullstack
test -f .agent-collections/install-selection.json && echo "OK: first successful install"
```

Next: [MCP setup](./mcp-setup) → enable tools in the IDE → [Start here](./start-here) checklist item 6.
