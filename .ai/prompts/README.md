# Prompts (core)

Tool-neutral prompt bodies live under:

| Subfolder | Role | Count (TASK-520) |
|-----------|------|----------------:|
| `public/` | User-facing entrypoints | 16 |
| `internal/` | Engineering Manager / delegation prompts | 12 |

**Status:** Ported in **TASK-520**. Full accounting: `docs/specs/task-520/port-manifest.md`.

Load by stable id (`eversis-<name>`) via file read under `.ai/prompts/…` or tool-native attach. Cursor `@` attach and `/eversis-*` slash commands are optional adapter UX, not core SSOT requirements.

Adapters may later mirror these into tool-specific locations; this tree remains SSOT.
