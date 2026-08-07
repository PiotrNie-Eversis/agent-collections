# Cursor adapter

Generates Cursor packaging from Agent Collections core:

- `.cursor/rules/*.mdc` from `.ai/rules` via [`rule-map.yaml`](./rule-map.yaml) (DHI-524)
- Thin `.cursor/commands/eversis-*.md` slash shims from `.ai/prompts/{public,internal}/` (DHI-598)

## Run (from repository root)

Prefer regenerating **all** shipped adapters after core / map / prompt changes:

```bash
node adapters/sync.mjs
# or: npm run sync:adapters
```

Cursor only:

```bash
node adapters/cursor/generate.mjs
```

Optional output root (keeps `.cursor/rules/…` and `.cursor/commands/…` under the given directory):

```bash
node adapters/cursor/generate.mjs --out /path/to/out
```

Re-run after core, map, or prompt Executable-section changes. **Do not hand-edit** generated `.mdc` or generated command bodies — they are overwritten on the next run.

## Generated rule ids

| id | Packaging |
|----|-----------|
| `eversis-agent-core` | always-on |
| `eversis-testing-and-terminal` | always-on |
| `eversis-accessibility` | glob-scoped |
| `eversis-engineering-manager` | attach-only |
| `eversis-code-reviewer` | attach-only |
| `eversis-fine-handoff` | attach-only |
| `eversis-spec-driven-development` | attach-only |

Source of packaging metadata: [`rule-map.yaml`](./rule-map.yaml). Mapping contract: [`docs/architecture/adapter-mapping.md`](../../docs/architecture/adapter-mapping.md).

## Slash commands (DHI-598)

| Item | Detail |
|------|--------|
| Discovery | All `eversis-*.md` under `.ai/prompts/public/` and `.ai/prompts/internal/` |
| Output | `.cursor/commands/<id>.md` |
| Shape (HYBRID) | First plain paragraph = `prompt_description` (slash menu summary); SSOT pointer; embed `## Executable prompt…` when present; GENERATED marker at **end** of file |
| Deny list | [`command-deny.yaml`](./command-deny.yaml) — ids listed there are not emitted |
| Orphans | Generated `eversis-*.md` under `.cursor/commands/` not in inventory are removed on sync |
| Drift check | Included in `npm run sync:adapters:check` |

Stable prompt id under `.ai/prompts/` remains SSOT. Claude Code does **not** consume `.cursor/commands/` (separate channel; native Claude slash emit deferred).

## Exceptions (not generated)

| Path | Reason |
|------|--------|
| `.cursor/rules/eversis-ba-docs-planner.mdc` | **Temporary symlink** to `cursor-collections` until BA core rules exist (DHI-519 deferred / DHI-524 Q3=B) |
| `.cursor/rules/eversis-ba-docs-writer.mdc` | Same as planner |
| `.cursor/rules/eversis-project-stack.mdc` | **Consumer-owned** — never overwrite without opt-in (DHI-521 / README) |
| `.cursor/skills/`, `.cursor/prompts/` | Outside Cursor emit (no full skill/prompt mirror) |

## Requirements

- Node.js 18+ (stdlib only; no npm install)
- Run from the **repository root** (directory that contains `.ai/` and `adapters/`)
