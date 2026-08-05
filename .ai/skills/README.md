# Skills (core)

Tool-neutral skill packages live here as flat `eversis-<topic>/` directories (same identity model as the legacy Cursor Collections catalog).

**Status:** Ported in **DHI-520** (45 packages). Full accounting: `docs/specs/dhi-520/port-manifest.md`.

**Consumption:** Prefer MCP `eversis_skills_list` / `eversis_skills_get` / `eversis_skills_validate` once the server resolves from this tree (**DHI-535**). Until then, read `SKILL.md` (and `references/`, `scripts/`) under `.ai/skills/` directly. Do not require Cursor Agent Skills UI registration for core workflows.

Adapters may surface or symlink these packages for IDE UX; this tree remains SSOT.
