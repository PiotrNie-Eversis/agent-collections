---
sidebar_position: 2
title: Installation
---

# Installation

:::info Curated path
Follow **[Start here](./start-here)** for the full onboarding checklist, including **first successful install**.
:::

Installing Agent Collections into a project turns on the assistant's built-in tools and skills for that project — things like structured research/plan/review workflows and a local library of reusable prompts. One of those tools, the **`eversis-collections`** skills server, now runs inside a small self-contained app called **Docker** rather than as a plain background process, so Docker needs to be installed and running before you set anything up. The steps below walk through cloning the framework once, then running one script against each project that should use it.

## 1. Clone the framework

```bash
cd ~/projects
git clone https://gitlab3.eversis.com/eversis-ai/agent-collections.git agent-collections
export AGENT_COLLECTIONS_HOME="$(pwd)/agent-collections"
```

You can use any folder name. Paths in [AGENTS.md](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/AGENTS.md) and [`documentation/agent-collection.md`](../framework) are relative to the repo root.

**Pin** (lock) consumers to a **SemVer git tag** when you leave local development (see root README versioning).

## 2. Open the framework (optional for maintainers)

1. Open the `agent-collections` folder in Cursor or Claude Code.
2. Read root **`AGENTS.md`** and **`.ai/README.md`**.
3. Refresh adapters after core rule changes: `npm run sync:adapters`.

## 3. Bootstrap a consumer project

The installer lives in the **agent-collections** repository (`scripts/setup-agent-collections.sh`), not in your app repo. Run it from the consumer project (recommended) or pass `--target`.

:::tip New to Docker?
[Docker Desktop](https://www.docker.com/products/docker-desktop/) is a free app that runs the small container the `eversis-collections` MCP server lives in — install it once per machine. Before running the command below, open Docker Desktop and confirm it's running (look for the whale icon in your menu bar / system tray). If the command below fails with something like "Cannot connect to the Docker daemon," Docker Desktop isn't running yet — start it and try again.
:::

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

Selection is written to **`.agent-collections/install-selection.json`**. Schema: [`docs/architecture/install-selection.md`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/docs/architecture/install-selection.md).

### Vendor modes

| Mode                | Flag                 | Notes                                                                        |
| ------------------- | -------------------- | ---------------------------------------------------------------------------- |
| **Local** (default) | (omit `--vendor`)    | Framework stays outside the consumer repo; set `AGENT_COLLECTIONS_HOME`      |
| **Submodule**       | `--vendor submodule` | **Common team default** — pin (lock) a specific version tag in `.gitmodules` |
| **Copy**            | `--vendor copy`      | Tree under `vendor/agent-collections/`                                       |

### Useful flags

| Flag                         | Purpose                                                                                                                                                                                                                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--build-mcp`                | Force rebuild of the `eversis-collections` Docker image (also builds when the image doesn't exist yet). Does **not** gate the interactive MCP server checklist.                                                                                                                     |
| `--agents`                   | `cursor`, `claude`, `opencode` (opencode = placeholder)                                                                                                                                                                                                                             |
| `--mcp-servers`              | Comma-separated ids; without it + `--non-interactive` → `eversis-collections` only                                                                                                                                                                                                  |
| `--profile`                  | `frontend` \| `backend` \| `fullstack`                                                                                                                                                                                                                                              |
| `--link-mode`                | `auto` \| `symlink` \| `copy`                                                                                                                                                                                                                                                       |
| `--sync`                     | Refresh framework-managed surfaces                                                                                                                                                                                                                                                  |
| `--upgrade`                  | Reuse selection (fail-safe if missing/corrupt)                                                                                                                                                                                                                                      |
| `--non-interactive`          | No prompts — defaults + flags                                                                                                                                                                                                                                                       |
| `--target DIR`               | Consumer path when not running from that repo                                                                                                                                                                                                                                       |
| `--collections-home DIR`     | Framework checkout path (safer than relying on an unset `$AGENT_COLLECTIONS_HOME` expansion)                                                                                                                                                                                        |
| `--ssot-source URL`          | Git URL of a `domain-context` repo to seed `docs/context/global/` from (optional — omit on **first** install to start empty). On `--upgrade` / `--sync`, omit to **keep** the URL already in `install-selection.json`; pass `--ssot-source ""` or `--ssot-source=` to **clear** it. |
| `--ssot-branch NAME`         | Branch to pull from `--ssot-source` (default `main`)                                                                                                                                                                                                                                |
| `--confluence-space-key KEY` | Records a Confluence space key for later use by `eversis-import-confluence-knowledge` (optional — never calls Confluence itself)                                                                                                                                                    |

Interactive runs (TTY, without `--non-interactive`) prompt for agents × domain profile × MCP servers. `--build-mcp` is optional on interactive installs. Re-runs are idempotent; partial failures list completed vs failed steps.

### After submodule install (teammates)

When the consumer uses `--vendor submodule`, teammates clone the app repo then:

```bash
git submodule update --init --recursive
```

Framework SSOT and MCP live under `vendor/agent-collections/`. Selection remains at `.agent-collections/install-selection.json` (see [install-selection.md](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/docs/architecture/install-selection.md)).

### Customising stack (Cursor vs Claude)

| Channel     | Customise                                                                                                                                 |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Cursor      | `.cursor/rules/eversis-project-stack.mdc`                                                                                                 |
| Claude Code | `.claude/CLAUDE.md` (seeded once, never overwritten — do not hand-edit generated `CLAUDE.md`; Claude Code does not auto-read `AGENTS.md`) |

## 4. Skills and prompts (MVP)

- **Skills** resolve from **`.ai/skills/`** via MCP **`eversis-collections`** (`eversis_skills_list` / `eversis_skills_get`), by reading `SKILL.md` directly, or — for Claude Code only — **natively** via `.claude/skills/eversis-*/` (linked/copied by the installer, no MCP required).
- **Prompts** load by **stable id** under `.ai/prompts/` (e.g. `eversis-implement`). Optional Cursor `@` attach when surfaced.
- This MVP does **not** ship a full mirror under `.cursor/skills` or `.cursor/prompts` — Cursor's skills stay MCP-only. Both adapters **do** generate thin slash shims from `.ai/prompts`: `.cursor/commands/` for Cursor, `.claude/commands/` for Claude Code (after `npm run sync:adapters`).
- **Domain context** (durable, cross-task knowledge — see [Domain Context (SSOT)](../domain-context)) is scaffolded on **every** install: `docs/context/<project>/INDEX.md` is created if missing. If `--ssot-source` is reachable, the installer also best-effort seeds `docs/context/global/` from it — this step never blocks or fails the install; an unreachable source just logs a warning with the manual recovery command.
- A project that already has history can fill that index after install — see [Seed existing project knowledge](#seed-existing-project-knowledge-optional).

## 5. Upgrade

```bash
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --upgrade --sync --non-interactive
```

Reuses agents / MCP / profile / vendor / link / `ssot.externalSsotRepo` (and `ssot.confluenceSpaceKey`) from selection. Omit `--ssot-source` to keep the recorded domain-context URL; pass an empty value (`--ssot-source ""` or `--ssot-source=`) to clear it. Missing or corrupt selection **fails** with wizard instructions (no invented full install). Project-owned paths (stack rule, `docs/plans|specs`, local `AGENTS.md`, secrets) are not overwritten without opt-in — `docs/context/` is the one partial exception: `INDEX.md` is **actively created** if missing, and `docs/context/global/` is **actively refreshed** by `eversis_context_sync`, not left untouched like the rest.

If your team vendors the framework as a **Git submodule**, `--upgrade --sync` only auto-updates that submodule's pinned version in one narrow case — see [Advanced: keeping a team submodule in sync](#advanced-keeping-a-team-submodule-in-sync) below before assuming an upgrade picked up the latest framework changes.

### Keeping consumers aligned

| Install mode     | After framework update                                                                            |
| ---------------- | ------------------------------------------------------------------------------------------------- |
| Local + symlink  | Pull or check out the new version tag → `docker compose build eversis-collections` → re-run setup |
| Local + copy     | Pull + re-run with `--sync`                                                                       |
| Vendor submodule | Usually a **manual** pin bump — see [Advanced](#advanced-keeping-a-team-submodule-in-sync)        |
| Vendor copy      | Re-run with `--vendor copy --build-mcp`                                                           |

## Advanced: keeping a team submodule in sync

:::info Skip this unless your team uses `--vendor submodule`
This section covers internals of how a Git-submodule-vendored install stays in sync with framework updates. If you installed with the **local** or **copy** vendor mode, you don't need it.
:::

When the framework is vendored as a submodule, `vendor/agent-collections/` is pinned to one specific commit (its "pin" — the exact version your project is locked to, identified by a **SHA**, a unique ID for that one commit). `--upgrade --sync` does **not** generally bump that pin to the latest framework version. It only auto-aligns the pin in one narrow case: when the vendored `adapters/sync.mjs` would otherwise reject a new CLI flag the installer is about to pass it (for example `--framework-prefix`). In that specific case, a **clean** vendor worktree is checked out to the launching installer's SHA automatically; a **dirty** worktree, or a SHA missing after `git fetch`, **fails** with the paths, SHAs, the flag name, and recovery `git fetch` / `git checkout` commands — it never force-resets anything.

For most other framework updates (like a new file or dependency added to the framework), **you must bump the submodule pin yourself**:

```bash
cd vendor/agent-collections
git fetch origin
git checkout <new-tag-or-commit>
cd ../..
git add vendor/agent-collections
```

Then re-run `--upgrade --sync` (and `--build-mcp` if the MCP server itself changed) to refresh the generated config from the new pin.

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

## Seed existing project knowledge (optional)

Skip this on a new project and on the sample install above. An empty `docs/context/<project>/INDEX.md` is the right result there.

Use this only when the consumer already has history: a Confluence **As-Is Pack** (one page that describes the system as it works today) or a `docs/specs/` backlog of past tasks. The installer never runs this import.

1. If you have a Confluence space key, pass `--confluence-space-key KEY` on the bootstrap command in [section 3](#3-bootstrap-a-consumer-project). That only records the key in `.agent-collections/install-selection.json`. It does not call Confluence and it does not import pages.
2. Finish [MCP setup](./mcp-setup) and connect the [Atlassian](../reference/integrations/atlassian.md) server. The import reads Confluence through that connection.
3. Open the consumer project and ask the agent to run [`eversis-import-confluence-knowledge`](../reference/skills/import-confluence-knowledge.md).
4. Review the draft. Nothing is written under `docs/context/<project>/` until you approve it. [Domain Context (SSOT)](../domain-context) describes what those files contain.
5. If you have no space key, you can still ask the agent to draft from `docs/specs/` history alone. Confluence is not required.
