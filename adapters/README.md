# Adapters

Tool-specific packaging that **consumes** Agent Collections core (`.ai/`). Generators live per tool; this folder also has an umbrella **sync** CLI.

Mapping contract: [`docs/architecture/adapter-mapping.md`](../docs/architecture/adapter-mapping.md).

## Sync all shipped adapters (DHI-527)

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

**MVP scope:** Cursor + Claude only. OpenCode remains a placeholder (no generate step). Sync does **not** overwrite consumer-owned `eversis-project-stack`, BA Docs symlinks, skills/prompts trees, ignore files, or secrets.

**Future CI:** add a job that runs `node adapters/sync.mjs --check` after core or map changes (not wired in this repository yet).

## Per-adapter generators

| Adapter | Command | Output |
|---------|---------|--------|
| [Cursor](./cursor/) | `node adapters/cursor/generate.mjs` | `.cursor/rules/eversis-*.mdc` (mapped) |
| [Claude Code](./claude/) | `node adapters/claude/generate.mjs` | root `CLAUDE.md` |
| [OpenCode](./opencode/) | — (placeholder) | `opencode.jsonc` / stub |

Prefer `adapters/sync.mjs` after changing `.ai/rules` or either `rule-map.yaml`.
