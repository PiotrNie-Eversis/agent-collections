# Agent instructions (Cursor)

This project is the **Agent Collections** framework repository. Core SSOT lives under **`.ai/`**. Versioning and the consumer **upgrade contract** are documented in root [`README.md`](./README.md) (SemVer `v0.0.1`, project-owned paths, changelog policy). See also [`CHANGELOG.md`](./CHANGELOG.md).

Temporary Cursor scaffold may still reference the sibling [Cursor Collections](https://github.com/PiotrNie-Eversis/cursor-collections) checkout under `.cursor/` until adapters and self-contained bootstrap land.

## Framework

- **Core rules / skills / prompts:** `.ai/` (see `.ai/README.md`)
- **Rules (Cursor packaging, if present):** `.cursor/rules/` — customise **`eversis-project-stack.mdc`** for consumer projects
- **Prompts:** load by stable id under `.ai/prompts/` (Cursor `@` attach is optional adapter UX)
- **Skills:** MCP `eversis_skills_list` / `eversis_skills_get` when enabled; otherwise read `.ai/skills/*/SKILL.md`
- **MCP:** enable `eversis-collections` in `.cursor/mcp.json` when using the Cursor channel

## Project specifics

<!-- Replace this section with project-specific agent instructions. -->
