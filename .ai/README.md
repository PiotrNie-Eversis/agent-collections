# Agent Collections core (`.ai/`)

This directory is the **vendor-neutral source of truth (SSOT)** for Agent Collections (BRD WF-01). Adapters (Cursor, Claude Code, Pi, OpenCode stub) and tooling (installer, MCP) **consume** this tree; they do not own the canonical content.

Content status:

| Area | Where |
|------|-------|
| Orchestration rules (full), including the spec-driven Delivery Standard | `rules/orchestration/` (`spec-driven-development.md`) |
| Domain rules | `rules/{frontend,backend,devops,architecture,shared-types}/` |
| Skills and prompts bodies | `skills/`, `prompts/` (MCP resolves skills from this tree) |

## Layout

```text
.ai/
  README.md                 # this file — layout + pointer to mapping spec
  rules/
    frontend/               # UI / web client guidance
    backend/                # API / services / data access
    shared-types/           # shared contracts, DTOs, domain types
    devops/                 # CI/CD, infra, ops patterns
    architecture/           # cross-cutting architecture standards
    orchestration/          # Ideate → Implement → Review, gates, handoffs
  skills/                   # tool-neutral skill packages (flat eversis-<topic>/ folders)
  prompts/
    public/                 # user-facing entrypoints
    internal/               # EM-routed / delegation prompts
```

**Naming note:** Jira “shared orchestration” maps to the folder `rules/orchestration/` (not `shared-orchestration/`).

## Mapping contract

**Canonical specification:** [`docs/architecture/adapter-mapping.md`](../docs/architecture/adapter-mapping.md) — field maps for Cursor / Claude Code / OpenCode placeholder, emit matrix, and adapter `rule-map.yaml` contracts. Prefer that document over this summary when implementing or extending adapters. Cursor: [`adapters/cursor/`](../adapters/cursor/). Claude Code: [`adapters/claude/`](../adapters/claude/) → root `CLAUDE.md`. Pi: [`adapters/pi/`](../adapters/pi/) → `.pi/`.

**Isolation strategy:** [`docs/architecture/isolation-strategy.md`](../docs/architecture/isolation-strategy.md) — cross-tool packaging visibility and area/path profiles (`frontend-scope` / `backend-scope` / `fullstack`). Ignore triad materialized at repo root; monorepo area path globs are defined in the same document.

**AGENTS.md standard:** [`docs/architecture/agents-md-standard.md`](../docs/architecture/agents-md-standard.md) — agnostic orientation map (sections, role matrix, docs triad `docs/{context,plans,specs}`, install contract). Copyable seed: [`templates/AGENTS.template.md`](../templates/AGENTS.template.md).

**OpenCode placeholder:** materialized under [`adapters/opencode/`](../adapters/opencode/) (plus root `opencode.jsonc`). Maturity remains **`placeholder`** — not a full / shipped OpenCode adapter.

| Core asset | Path under `.ai/` | Later consumer role |
|------------|-------------------|---------------------|
| Domain & orchestration **rules** | `rules/<domain>/*.md` | Cursor → `.cursor/rules/*.mdc` via [`adapters/cursor/`](../adapters/cursor/); Claude → root `CLAUDE.md` via [`adapters/claude/`](../adapters/claude/); Pi → `.pi/APPEND_SYSTEM.md` and `.pi/skills/eversis-rule-<name>/` via [`adapters/pi/`](../adapters/pi/); OpenCode → `instructions` globs ([`adapters/opencode/`](../adapters/opencode/) placeholder) |
| **Skills** | `skills/eversis-<topic>/` | MCP (`eversis-collections`); mirrored unchanged into `.cursor/skills/`, `.claude/skills/` and `.pi/skills/` by the installer (`adapters/sync.mjs` refreshes the Cursor and Claude mirrors in the framework root) |
| **Prompts** | `prompts/public/`, `prompts/internal/` | Stable ids; thin commands in `.cursor/commands/` and `.claude/commands/`, Pi prompts in `.pi/prompts/` |
| **Orchestration contracts** | `rules/orchestration/` plus this README | Lifecycle, gates, Fine/QA, SDD — not only IDE packaging |

### What does **not** live in `.ai/`

- Cursor **commands** (thin slash shims) — adapter / Cursor channel
- IDE front matter (`globs`, `alwaysApply`) and **rule-map** — adapter packaging (see mapping spec)
- Consumer **project stack** customization — stays project-owned
- Framework **docs site** — `website/`

## Rule format

Core rules use **plain Markdown** (`.md`):

- No Cursor YAML front matter (`description`, `globs`, `alwaysApply`)
- No Claude-only `CLAUDE.md` conventions inside rule files
- Prefer tool-agnostic wording (“load the Implement prompt”, “resolve skills via MCP”)

See `rules/orchestration/agent-core.md` for the production lifecycle and gate rules.

## Related specs

- Adapter mapping (canonical): `docs/architecture/adapter-mapping.md`
- Isolation strategy (canonical): `docs/architecture/isolation-strategy.md`
