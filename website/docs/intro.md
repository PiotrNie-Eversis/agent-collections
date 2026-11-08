---
slug: /
sidebar_position: 1
title: Introduction
---

# Introduction

AI agents are only as good as the process you give them. Left to guess, they skip research, plan against the wrong context, and ship code nobody reviewed against real acceptance criteria.

**Agent Collections** fixes that: a structured, repeatable workflow — Ideate → Research → Plan → Implement → Review → Fine — with a human approval gate exactly where it matters, so an agent never plans or ships without your sign-off.

> **Ideate → Research → Plan → Implement → Review → Fine**

Under the hood, it's a **vendor-neutral multi-agent** product engineering framework — core rules, skills, and prompts under **`.ai/`** (the project's [SSOT](./reference/glossary#ssot)), packaged by [adapters](./reference/glossary#adapters) for Cursor, Claude Code, the [Pi coding agent](https://pi.dev/) (opt-in), and (placeholder) OpenCode.

Maintained by [Eversis](https://eversis.com).

## How it works

import SdlcDiagram from '@site/src/components/SdlcDiagram';

<SdlcDiagram />

**~15 min vs 1–2 days** — turning a discovery-workshop transcript into a Jira-ready backlog, structured start to finish, with a human approval gate at every phase.

:::tip What are you here for?
- **New to the framework?** → **[Start here](./getting-started/start-here)** — the first successful install checklist.
- **Evaluating for your team?** → **[For CTOs](./advanced/for-ctos)** — the business case and adoption path.
:::

Teams using this exact workflow report cutting workshop-to-backlog time from **1–2 days to ~15 minutes** — see [How it works](#how-it-works) above.

:::note Docs hosting
Build this site locally (`cd website && npm run build`). **Public hosting is deferred** — no production docs URL in MVP.
:::

## What this framework provides

| Layer | Location | Role |
|-------|----------|------|
| **Core SSOT** | `.ai/rules`, `.ai/skills`, `.ai/prompts` | Canonical content |
| **Adapters** | `adapters/cursor`, `adapters/claude`, `adapters/pi`, `adapters/opencode` | Tool packaging + `sync.mjs` |
| **Installer** | `scripts/setup-agent-collections.sh` | Local / submodule / copy into consumers |
| **[MCP](./reference/glossary#mcp)** | `mcp/eversis-collections-mcp` | Skills tools via `AGENT_COLLECTIONS_HOME`, plus **domain context** tools (`eversis_context_*`, see [Domain Context (SSOT)](./domain-context)) via a second, independent volume |

### Lifecycle

- **Ideate** — `eversis-analyze-materials` (Business Analyst)
- **Implement** — `eversis-implement` (Engineering Manager orchestration)
- **Review** — `eversis-review` / UI review prompts
- **Fine** — QA comment draft; Jira publish only with human approval

### Skills and prompts (MVP)

Prefer MCP **`eversis-collections`** and stable prompt ids under `.ai/prompts/`. Both adapters also get a local skills mirror under `.cursor/skills/eversis-*/` and `.claude/skills/eversis-*/` (framework sync / installer) for load-by-path or `@` attach — do **not** register `.cursor/skills` as Cursor **Agent Skills** UI. Both adapters generate thin `/eversis-*` shims — `.cursor/commands/` and `.claude/commands/` respectively — from `.ai/prompts` (TASK-598). Claude Code can use its native skills mirror without MCP.

**Pi (opt-in):** choose `pi` at install time and the installer writes a `.pi/` folder — a small always-on core in `.pi/APPEND_SYSTEM.md`, `/eversis-*` prompt templates in `.pi/prompts/`, the skills mirror plus role-rule skills in `.pi/skills/`, the `eversis-collections` MCP server in `.pi/mcp.json`, an extension that adds the process rules after an `eversis-*` command or while a plan is active, and a context-budget extension that compacts the session once it is about half full (a Pi-only feature). Pi reads `.pi/` only after you trust the project. See [Installation](./getting-started/installation).

## Multi-agent and isolation

Use Cursor and/or Claude Code in the same monorepo with [isolation](./isolation) (cross-tool ignore + area profiles). Pi can sit alongside them; Pi ignore files are not shipped yet, so isolation currently covers Cursor, Claude Code and OpenCode. Abstract paths stay `apps/web` / `apps/api`; map consumer folder names locally.

## Migrating from Cursor Collections

See **[Migration from Cursor Collections](./advanced/migration-from-cursor-collections)**. Documentation channels stay fully separate (no shared docs portal).

## Next steps

1. [Prerequisites](./getting-started/prerequisites)
2. [Installation](./getting-started/installation)
3. [MCP setup](./getting-started/mcp-setup)
4. [Framework reference](./framework)
5. [Isolation](./isolation)
