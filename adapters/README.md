# Adapters

Tool-specific packaging that **consumes** Agent Collections core (`.ai/`). Generators live per tool; this folder also has an umbrella **sync** CLI.

Mapping contract: [`docs/architecture/adapter-mapping.md`](../docs/architecture/adapter-mapping.md).

## Sync all shipped adapters (TASK-527)

From the repository root, regenerate **Cursor** then **Claude** outputs from core:

```bash
node adapters/sync.mjs
# or
npm run sync:adapters
```

Validate that on-disk outputs match a fresh generation (no drift) and that Cursor↔Claude `id`/`source` sets match:

```bash
node adapters/sync.mjs --check
# or
npm run sync:adapters:check
```

Optional `--out <dir>` is passed through to both generators (same behaviour as each `generate.mjs`).

**Pi (opt-in, AC-14):** add `pi` to `--agents` to also run the Pi generator — last, after Cursor / Claude. With `--check`, only the named agents are checked; Pi is checked by its own generator's `--check` against the target. Defaults stay `cursor,claude`, so no `.pi/` is created in this repository unless you ask for it:

```bash
node adapters/sync.mjs --agents cursor,claude,pi --out /path/to/project
node adapters/sync.mjs --check --agents cursor,claude,pi --out /path/to/project
```

`--check` also asserts that every Claude `id`/`source` pair is present in the Pi map.

**MVP scope:** Cursor + Claude by default; Pi when selected (see above). OpenCode remains a placeholder (no generate step). Sync does **not** overwrite consumer-owned `eversis-project-stack`, BA Docs symlinks, skills/prompts trees, ignore files, or secrets.

**Future CI:** add a job that runs `node adapters/sync.mjs --check` after core or map changes (not wired in this repository yet).

## Per-adapter generators

| Adapter | Command | Output |
|---------|---------|--------|
| [Cursor](./cursor/) | `node adapters/cursor/generate.mjs` | `.cursor/rules/eversis-*.mdc` (mapped) |
| [Claude Code](./claude/) | `node adapters/claude/generate.mjs` | root `CLAUDE.md` |
| [Pi](./pi/) | `node adapters/pi/generate.mjs` (or `sync.mjs --agents pi`) | `.pi/APPEND_SYSTEM.md`, `.pi/prompts/eversis-*.md`, `.pi/skills/eversis-rule-*/SKILL.md`, `.pi/extensions/eversis-context-budget.ts`, `.pi/settings.json` (seeded once); installer adds `.pi/skills/eversis-*/` and `.pi/mcp.json` |
| [OpenCode](./opencode/) | — (placeholder) | `opencode.jsonc` / stub |

Prefer `adapters/sync.mjs` after changing `.ai/rules` or any `rule-map.yaml` (add `--agents …,pi` when the target uses Pi).
