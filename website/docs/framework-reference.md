---
id: framework-reference
title: Framework reference
sidebar_label: Framework reference
description: Authoritative short guide for Agent Collections — core, adapters, installer, MCP.
slug: /framework
sidebar_position: 2
---

# Agent Collections — framework reference

Authoritative short guide for **Agent Collections**: a vendor-neutral multi-agent core (`.ai/`) with adapters, installer, and MCP. Consumer documentation is written in **English**.

**Delivery standard:** Ideate → Research → Plan → Implement → Review → Fine.

Repo source: [`documentation/agent-collection.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/documentation/agent-collection.md).

:::info Hosting
This site builds locally (`npm run build` in `website/`). **Public hosting is deferred** — there is no production docs URL in MVP.
:::

## Model

```text
.ai/          SSOT — rules, skills, prompts
adapters/     Cursor / Claude / OpenCode packaging + sync
mcp/          eversis-collections-mcp → .ai/skills via AGENT_COLLECTIONS_HOME
scripts/      setup-agent-collections.sh
templates/    AGENTS / stack / mcp seeds
```

| Concept | Definition |
|---------|------------|
| **Core** | Canonical Markdown under `.ai/` |
| **Adapter** | Tool packaging that consumes core (does not own SSOT text) |
| **Consumer** | Application repo that installs via local / submodule / copy |

Related product **Cursor Collections** is a separate Cursor distribution channel. Dual-channel **code** is allowed; **documentation channels stay fully separate** (no shared docs portal). See [Migration](./getting-started/migration-from-cursor-collections).

## Install and env

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor,claude \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

- Env for skills MCP: **`AGENT_COLLECTIONS_HOME`** (not `CURSOR_COLLECTIONS_HOME`).
- Selection: `.agent-collections/install-selection.json`.

Details: [Installation](./getting-started/installation), [MCP setup](./getting-started/mcp-setup).

## Agents and prompts

| Phase | Primary prompt id |
|-------|-------------------|
| Ideate | `eversis-analyze-materials` |
| Implement | `eversis-implement` |
| Review | `eversis-review` |
| Review (UI) | `eversis-review-ui` |

Load prompts by stable id under `.ai/prompts/`. Optional Cursor `@` attach when surfaced. Slash `/eversis-*` commands are **not** MVP.

## Skills (MCP)

Skills live under `.ai/skills/eversis-*/`. Prefer MCP server **`eversis-collections`** (`eversis_skills_list` / `eversis_skills_get`). Respect the consumer **project stack** skills policy.

MVP does **not** ship a full `.cursor/skills` mirror.

## Multi-agent and isolation

- **Cursor** — generated `.cursor/rules/*.mdc`, MCP skills.
- **Claude Code** — root `CLAUDE.md`; skills via MCP / `AGENTS.md`.
- **OpenCode** — placeholder only.

Cross-tool ignore + area profiles: [Isolation](./isolation). Abstract layout uses `apps/web` / `apps/api`; consumers map local trees via overlay (not framework profile hardcoding).

## Versioning and upgrade

SemVer tags on this repository cover core + adapters + installer + MCP together. Breaking releases include a **Migration** subsection in the root CHANGELOG. Upgrade modes: local sync, submodule bump, installer `--upgrade`.

## Architecture docs (in repo)

| Doc | Topic |
|-----|--------|
| `docs/architecture/adapter-mapping.md` | Emit matrix |
| `docs/architecture/isolation-strategy.md` | Ignore + area + WNF-03 |
| `docs/architecture/install-selection.md` | Selection schema |
| `docs/architecture/requirements-traceability.md` | WF/WNF → docs |

## Getting started

- [Start here](./getting-started/start-here)
- [Quick wins](./getting-started/quick-wins)
- [Migration from Cursor Collections](./getting-started/migration-from-cursor-collections)
