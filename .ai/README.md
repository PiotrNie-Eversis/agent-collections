# Agent Collections core (`.ai/`)

This directory is the **vendor-neutral source of truth (SSOT)** for Agent Collections (BRD WF-01). Adapters (Cursor, Claude Code, OpenCode stub) and tooling (installer, MCP) **consume** this tree; they do not own the canonical content.

Content fill schedule:

| Area | Story |
|------|-------|
| Orchestration rules (full) | TASK-518 (**done** — see `rules/orchestration/`) + TASK-522 SDD (`spec-driven-development.md`) |
| Domain rules | TASK-519 (**done** — see `rules/{frontend,backend,devops,architecture,shared-types}/`) |
| Skills and prompts bodies | TASK-520 (**done** — see `skills/`, `prompts/`; manifest `docs/specs/task-520/port-manifest.md`; MCP resolveRoot → TASK-535) |

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
  skills/                   # tool-neutral skill packages (flat eversis-* later)
  prompts/
    public/                 # user-facing entrypoints
    internal/               # EM-routed / delegation prompts
```

**Naming note:** Jira “shared orchestration” maps to the folder `rules/orchestration/` (not `shared-orchestration/`).

## Mapping contract

**Canonical specification:** [`docs/architecture/adapter-mapping.md`](../docs/architecture/adapter-mapping.md) (TASK-523) — field maps for Cursor / Claude Code / OpenCode placeholder, emit matrix, and adapter `rule-map.yaml` contracts. Prefer that document over this summary when implementing or extending adapters (TASK-524+). Cursor: [`adapters/cursor/`](../adapters/cursor/). Claude Code: [`adapters/claude/`](../adapters/claude/) → root `CLAUDE.md`.

**Isolation strategy (TASK-528):** [`docs/architecture/isolation-strategy.md`](../docs/architecture/isolation-strategy.md) — cross-tool packaging visibility and area/path profiles (`frontend-scope` / `backend-scope` / `fullstack`). Ignore triad materialized at repo root (**TASK-529**); monorepo path globs → TASK-530.

**AGENTS.md standard (TASK-531):** [`docs/architecture/agents-md-standard.md`](../docs/architecture/agents-md-standard.md) — agnostic orientation map (sections, role matrix, docs triad `docs/{context,plans,specs}`, install contract). Copyable seed: [`templates/AGENTS.template.md`](../templates/AGENTS.template.md). Full reference fill for this repo → **TASK-532**.

**OpenCode placeholder (TASK-525):** materialized under [`adapters/opencode/`](../adapters/opencode/) (plus root `opencode.jsonc`). Maturity remains **`placeholder`** — not a full / shipped OpenCode adapter.

| Core asset | Path under `.ai/` | Later consumer role |
|------------|-------------------|---------------------|
| Domain & orchestration **rules** | `rules/<domain>/*.md` | Cursor → `.cursor/rules/*.mdc` via [`adapters/cursor/`](../adapters/cursor/); Claude → root `CLAUDE.md` via [`adapters/claude/`](../adapters/claude/); OpenCode → `instructions` globs ([`adapters/opencode/`](../adapters/opencode/) placeholder) |
| **Skills** | `skills/eversis-<topic>/` (45 packages — TASK-520) | MCP after **TASK-535** — not emitted by Cursor/Claude adapters in MVP |
| **Prompts** | `prompts/public/`, `prompts/internal/` | Stable ids; not mirrored by Cursor adapter in MVP |
| **Orchestration contracts** | `rules/orchestration/` plus this README | Lifecycle, gates, Fine/QA, SDD — not only IDE packaging |

### What does **not** live in `.ai/`

- Cursor **commands** (thin slash shims) — adapter / Cursor channel
- IDE front matter (`globs`, `alwaysApply`) and **rule-map** — adapter packaging (see mapping spec; file lands in TASK-524)
- Consumer **project stack** customization — stays project-owned
- Framework **docs site** / rebrand — TASK-540

## Rule format

Core rules use **plain Markdown** (`.md`):

- No Cursor YAML front matter (`description`, `globs`, `alwaysApply`)
- No Claude-only `CLAUDE.md` conventions inside rule files
- Prefer tool-agnostic wording (“load the Implement prompt”, “resolve skills via MCP”)

See `rules/orchestration/agent-core.md` for the production lifecycle and gate rules (TASK-518).

## Related specs

- Inventory: `docs/specs/task-516/asset-inventory.md`
- Structure story: `docs/specs/task-517/`
- Orchestration extraction: `docs/specs/task-518/`
- Domain rules extraction: `docs/specs/task-519/`
- Skills & prompts port: `docs/specs/task-520/` (manifest: `port-manifest.md`)
- Adapter mapping (canonical): `docs/architecture/adapter-mapping.md` (TASK-523)
- Isolation strategy (canonical): `docs/architecture/isolation-strategy.md` (TASK-528)
