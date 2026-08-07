# Claude Code adapter

Generates a single repository-root `CLAUDE.md` from Agent Collections core (`.ai/rules`) using a central rule map. One H2 section per mapped rule (full inline body). Mapping contract: [`docs/architecture/adapter-mapping.md`](../../docs/architecture/adapter-mapping.md) §5.

## Run (from repository root)

Prefer regenerating **all** shipped adapters after core / map changes:

```bash
node adapters/sync.mjs
# or: npm run sync:adapters
```

Claude only:

```bash
node adapters/claude/generate.mjs
```

Optional output root (writes `CLAUDE.md` under the given directory):

```bash
node adapters/claude/generate.mjs --out /path/to/out
```

Re-run after core or map changes. **Do not hand-edit** the generated `CLAUDE.md` — it is overwritten on the next run.

## Generated rule ids

| id | Source |
|----|--------|
| `eversis-agent-core` | `.ai/rules/orchestration/agent-core.md` |
| `eversis-testing-and-terminal` | `.ai/rules/orchestration/testing-and-terminal.md` |
| `eversis-accessibility` | `.ai/rules/frontend/accessibility.md` |
| `eversis-engineering-manager` | `.ai/rules/orchestration/engineering-manager.md` |
| `eversis-code-reviewer` | `.ai/rules/architecture/code-reviewer.md` |
| `eversis-fine-handoff` | `.ai/rules/orchestration/fine-handoff.md` |
| `eversis-spec-driven-development` | `.ai/rules/orchestration/spec-driven-development.md` |

`id` / `source` parity with [`adapters/cursor/rule-map.yaml`](../cursor/rule-map.yaml). Source of packaging metadata: [`rule-map.yaml`](./rule-map.yaml).

## Exceptions (not generated)

| Item | Reason |
|------|--------|
| Skills / prompts mirrors | Outside Claude emit MVP — resolve via MCP / `.ai/skills` / `.ai/prompts` (see How-to in `CLAUDE.md`) |
| BA Docs rules | Not in Cursor MVP map — same exclusion here |
| Consumer `eversis-project-stack` | **Consumer-owned** — never overwrite without opt-in |
| `.claude/rules/`, native Claude skills/commands | Deferred (strict single `CLAUDE.md` per DHI-523 / DHI-526 Q1=A) |
| Monorepo area / path globs | **Deferred** to DHI-530 (Work Stream 3) |
| `.claudeignore` | **Shipped** at repo root (DHI-529 ignore triad; see [`isolation-strategy.md`](../../docs/architecture/isolation-strategy.md) §8.1) |

## Consumer project notes

- **Do not hand-edit** the generated `CLAUDE.md` — it is overwritten on the next `sync:adapters` / Claude generate run.
- Claude Code does **not** load Cursor `.cursor/rules/*.mdc`. Put consumer stack, area map, and skills policy in **`AGENTS.md`** (shared orientation map). Cursor teams still customise `eversis-project-stack.mdc` for Cursor-only stack commands.
- Skills resolve via MCP **`eversis-collections`** (or by reading `.ai/skills/*/SKILL.md` from the framework home / vendor path).

## Requirements

- Node.js 18+ (stdlib only; no npm install)
- Run from the **repository root** (directory that contains `.ai/` and `adapters/`)
