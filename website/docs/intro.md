---
slug: /
sidebar_position: 1
title: Introduction
---

# Introduction

**Agent Collections** is a **vendor-neutral multi-agent** product engineering framework — core rules, skills, and prompts under **`.ai/`**, packaged for Cursor, Claude Code, and (placeholder) OpenCode.

> **Ideate → Research → Plan → Implement → Review → Fine**

Maintained by [Eversis](https://eversis.com).

:::info Start here
New reader? Follow the curated path: **[Start here](./getting-started/start-here)**.
:::

:::note Docs hosting
Build this site locally (`cd website && npm run build`). **Public hosting is deferred** — no production docs URL in MVP.
:::

## What this framework provides

| Layer | Location | Role |
|-------|----------|------|
| **Core SSOT** | `.ai/rules`, `.ai/skills`, `.ai/prompts` | Canonical content |
| **Adapters** | `adapters/cursor`, `adapters/claude`, `adapters/opencode` | Tool packaging + `sync.mjs` |
| **Installer** | `scripts/setup-agent-collections.sh` | Local / submodule / copy into consumers |
| **MCP** | `mcp/eversis-collections-mcp` | Skills tools via `AGENT_COLLECTIONS_HOME` |

### Lifecycle

- **Ideate** — `eversis-analyze-materials` (Business Analyst)
- **Implement** — `eversis-implement` (Engineering Manager orchestration)
- **Review** — `eversis-review` / UI review prompts
- **Fine** — QA comment draft; Jira publish only with human approval

### Skills and prompts (MVP)

Prefer MCP **`eversis-collections`** and stable prompt ids under `.ai/prompts/`. Both the Cursor and Claude Code adapters generate thin `/eversis-*` shims — `.cursor/commands/` and `.claude/commands/` respectively — from `.ai/prompts` (TASK-598). Claude Code additionally gets a native skills mirror under `.claude/skills/`; Cursor does not ship a full `.cursor/skills` or `.cursor/prompts` mirror in this MVP.

## Multi-agent and isolation

Use Cursor and/or Claude Code in the same monorepo with [isolation](./isolation) (cross-tool ignore + area profiles). Abstract paths stay `apps/web` / `apps/api`; map consumer folder names locally.

## Migrating from Cursor Collections

See **[Migration from Cursor Collections](./getting-started/migration-from-cursor-collections)**. Documentation channels stay fully separate (no shared docs portal).

## Next steps

1. [Prerequisites](./getting-started/prerequisites)
2. [Installation](./getting-started/installation)
3. [MCP setup](./getting-started/mcp-setup)
4. [Framework reference](./framework)
5. [Isolation](./isolation)
