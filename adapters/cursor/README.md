# Cursor adapter

Generates `.cursor/rules/*.mdc` from Agent Collections core (`.ai/rules`) using a central rule map.

## Run (from repository root)

Prefer regenerating **all** shipped adapters after core / map changes:

```bash
node adapters/sync.mjs
# or: npm run sync:adapters
```

Cursor only:

```bash
node adapters/cursor/generate.mjs
```

Optional output root (keeps `.cursor/rules/…` under the given directory):

```bash
node adapters/cursor/generate.mjs --out /path/to/out
```

Re-run after core or map changes. **Do not hand-edit** generated `.mdc` bodies — they are overwritten on the next run.

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

## Exceptions (not generated)

| Path | Reason |
|------|--------|
| `.cursor/rules/eversis-ba-docs-planner.mdc` | **Temporary symlink** to `cursor-collections` until BA core rules exist (DHI-519 deferred / DHI-524 Q3=B) |
| `.cursor/rules/eversis-ba-docs-writer.mdc` | Same as planner |
| `.cursor/rules/eversis-project-stack.mdc` | **Consumer-owned** — never overwrite without opt-in (DHI-521 / README) |
| `.cursor/skills/`, `.cursor/prompts/` | Outside Cursor emit MVP (rules only) |

## Requirements

- Node.js 18+ (stdlib only; no npm install)
- Run from the **repository root** (directory that contains `.ai/` and `adapters/`)
