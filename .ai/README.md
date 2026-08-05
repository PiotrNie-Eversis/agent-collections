# Agent Collections core (`.ai/`)

This directory is the **vendor-neutral source of truth (SSOT)** for Agent Collections (BRD WF-01). Adapters (Cursor, Claude Code, OpenCode stub) and tooling (installer, MCP) **consume** this tree; they do not own the canonical content.

Content fill schedule:

| Area | Story |
|------|-------|
| Orchestration rules (full) | DHI-518 (**done** — see `rules/orchestration/`) + DHI-522 SDD (`spec-driven-development.md`) |
| Domain rules | DHI-519 (**done** — see `rules/{frontend,backend,devops,architecture,shared-types}/`) |
| Skills and prompts bodies | DHI-520 (**done** — see `skills/`, `prompts/`; manifest `docs/specs/dhi-520/port-manifest.md`; MCP resolveRoot → DHI-535) |

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

**Canonical specification:** [`docs/architecture/adapter-mapping.md`](../docs/architecture/adapter-mapping.md) (DHI-523) — field maps for Cursor / Claude Code / OpenCode placeholder, emit matrix, and the Cursor `rule-map.yaml` contract. Prefer that document over this summary when implementing adapters (DHI-524+).

| Core asset | Path under `.ai/` | Later consumer role |
|------------|-------------------|---------------------|
| Domain & orchestration **rules** | `rules/<domain>/*.md` | Cursor → `.cursor/rules/*.mdc` via rule-map; Claude → `CLAUDE.md` sections; OpenCode → `instructions` globs (placeholder) |
| **Skills** | `skills/eversis-<topic>/` (45 packages — DHI-520) | MCP after **DHI-535** — not emitted by Cursor/Claude adapters in MVP |
| **Prompts** | `prompts/public/`, `prompts/internal/` | Stable ids; not mirrored by Cursor adapter in MVP |
| **Orchestration contracts** | `rules/orchestration/` plus this README | Lifecycle, gates, Fine/QA, SDD — not only IDE packaging |

### What does **not** live in `.ai/`

- Cursor **commands** (thin slash shims) — adapter / Cursor channel
- IDE front matter (`globs`, `alwaysApply`) and **rule-map** — adapter packaging (see mapping spec; file lands in DHI-524)
- Consumer **project stack** customization — stays project-owned
- Framework **docs site** / rebrand — DHI-540

## Rule format

Core rules use **plain Markdown** (`.md`):

- No Cursor YAML front matter (`description`, `globs`, `alwaysApply`)
- No Claude-only `CLAUDE.md` conventions inside rule files
- Prefer tool-agnostic wording (“load the Implement prompt”, “resolve skills via MCP”)

See `rules/orchestration/agent-core.md` for the production lifecycle and gate rules (DHI-518).

## Related specs

- Inventory: `docs/specs/dhi-516/asset-inventory.md`
- Structure story: `docs/specs/dhi-517/`
- Orchestration extraction: `docs/specs/dhi-518/`
- Domain rules extraction: `docs/specs/dhi-519/`
- Skills & prompts port: `docs/specs/dhi-520/` (manifest: `port-manifest.md`)
- Adapter mapping (canonical): `docs/architecture/adapter-mapping.md` (DHI-523)
