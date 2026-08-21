---
sidebar_position: 0
title: Start here
---

# Start here

**Agent Collections** is a **vendor-neutral** multi-agent product engineering framework. Canonical content lives under **`.ai/`**; adapters package it for Cursor, Claude Code, and (placeholder) OpenCode.

> **Ideate → Research → Plan → Implement → Review → Fine**

Each phase produces documented artifacts; the next step waits on **your approval** where the prompts require it.

:::tip New to this framework?
Follow the checklist below in order. Each step links to the detailed playbook — this page is the map, not the encyclopedia.
:::

## First successful install checklist

Complete these steps on a **sample consumer project** (empty folder or small repo) until install succeeds:

1. **[Prerequisites](./prerequisites)** — Cursor and/or Claude Code, **Docker Engine + Compose v2** (to run the MCP server), **Node.js ≥ 18** (to develop the MCP package), Git.
2. Clone **agent-collections** and export `AGENT_COLLECTIONS_HOME` (see [Installation](./installation)).
3. **[Installation](./installation)** — run `setup-agent-collections.sh` with `--build-mcp --non-interactive` (local, submodule, or copy).
4. Confirm `.agent-collections/install-selection.json` exists in the consumer project.
5. **[MCP setup](./mcp-setup)** — enable **`eversis-collections`** with `AGENT_COLLECTIONS_HOME` (not `CURSOR_COLLECTIONS_HOME`).
6. Open the consumer project in your agent tool and attach **`@eversis-implement`** (or load prompt id `eversis-implement`) with a short task — or read `.ai/skills/*/SKILL.md` via MCP.
7. **Done** when: installer exited 0, MCP skills list works (or skills readable from `.ai/skills/`), and a first Implement readiness block appears in chat.

That is a **first successful install**. Optional next steps: [Quick wins](./quick-wins), [Migration from Cursor Collections](./migration-from-cursor-collections), [Workflow overview](../workflow/overview).

## Setup checklist (maintainers)

1. **[Prerequisites](./prerequisites)**
2. **[Installation](./installation)** — framework checkout + consumer bootstrap
3. **[MCP setup](./mcp-setup)** — build and enable `eversis-collections`
4. **First prompt** — attach `@eversis-implement` / load `eversis-implement` with your ticket or task text
5. **[Workflow overview](../workflow/overview)** — pick a variant (standard, UI, workshop, E2E)
6. **Go deeper** — [Framework reference](../framework), [Agents overview](../agents/overview), [Skills overview](../skills/overview)

## Requirements traceability

See [Requirements traceability](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/architecture/requirements-traceability.md) (WF-01…WF-05 and key WNF → docs / stories).

## Canonical references

- Root **[README](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/README.md)** — install, upgrade, versioning
- **[AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md)** — agent entry map
- **[Framework reference](../framework)** — authoritative short guide (`documentation/agent-collection.md`)
- Architecture: isolation, adapter mapping, install selection under `docs/architecture/`

## In this section

- [Prerequisites](./prerequisites)
- [Installation](./installation)
- [MCP setup](./mcp-setup)
- [Quick wins](./quick-wins)
- [Migration from Cursor Collections](./migration-from-cursor-collections)
