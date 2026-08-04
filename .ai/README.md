# Agent Collections core (`.ai/`)

This directory is the **vendor-neutral source of truth (SSOT)** for Agent Collections (BRD WF-01). Adapters (Cursor, Claude Code, OpenCode stub) and tooling (installer, MCP) **consume** this tree; they do not own the canonical content.

Content fill schedule:

| Area | Story |
|------|-------|
| Orchestration rules (full) | DHI-518 |
| Domain rules | DHI-519 |
| Skills and prompts bodies | DHI-520 |

## Layout

```text
.ai/
  README.md                 # this file — mapping contract
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

| Core asset | Path under `.ai/` | Later consumer role |
|------------|-------------------|---------------------|
| Domain & orchestration **rules** | `rules/<domain>/*.md` | Cursor adapter → `.cursor/rules/*.mdc`; Claude → sections in `CLAUDE.md` |
| **Skills** | `skills/eversis-<topic>/` (packages arrive in DHI-520) | MCP skill tools resolve from `.ai/skills/`; adapters may surface or symlink |
| **Prompts** | `prompts/public/`, `prompts/internal/` | Public = user entrypoints; Internal = orchestration delegation; adapters may mirror under tool-specific paths |
| **Orchestration contracts** | `rules/orchestration/` plus this README | Lifecycle, human gates, Fine/QA handoff, SDD expectations — **not** only IDE rule packaging |

### What does **not** live in `.ai/`

- Cursor **commands** (thin slash shims) — adapter / Cursor channel
- IDE front matter (`globs`, `alwaysApply`) — adapter packaging
- Consumer **project stack** customization — stays project-owned
- Framework **docs site** / rebrand — DHI-540

## Rule format

Core rules use **plain Markdown** (`.md`):

- No Cursor YAML front matter (`description`, `globs`, `alwaysApply`)
- No Claude-only `CLAUDE.md` conventions inside rule files
- Prefer tool-agnostic wording (“load the Implement prompt”, “resolve skills via MCP”)

See `rules/orchestration/sample-lifecycle.md` for a format sample (placeholder until DHI-518).

## Related specs

- Inventory: `docs/specs/dhi-516/asset-inventory.md`
- Structure story: `docs/specs/dhi-517/`
