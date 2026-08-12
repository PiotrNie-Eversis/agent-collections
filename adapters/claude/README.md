# Claude Code adapter

Generates Claude Code's native surfaces from Agent Collections core: a repository-root `CLAUDE.md` (one H2 section per always-on/attach-only mapped rule) plus `.claude/rules/*.md` (glob-scoped rules, `paths:` frontmatter) and `.claude/commands/*.md` (thin pointers to `.ai/prompts/`). `.claude/skills/` is linked by the installer, not generated here (see "Generated skills" below). Mapping contract: [`docs/architecture/adapter-mapping.md`](../../docs/architecture/adapter-mapping.md) §5.

## Run (from repository root)

Prefer regenerating **all** shipped adapters after core / map changes:

```bash
node adapters/sync.mjs
# or: npm run sync:adapters
```

Claude only (rules → `CLAUDE.md`, then commands → `.claude/commands/`):

```bash
node adapters/claude/generate.mjs
node adapters/claude/generate-commands.mjs
```

Optional output root (writes under the given directory) and, for vendored
consumer installs, `--framework-prefix` (prepends `.ai/...` references so
they resolve outside self-host — see `_resolve_framework_prefix` in
`scripts/lib/setup-agent-collections/link-framework.sh`):

```bash
node adapters/claude/generate.mjs --out /path/to/out --framework-prefix vendor/agent-collections
node adapters/claude/generate-commands.mjs --out /path/to/out --framework-prefix vendor/agent-collections
```

Re-run after core or map changes. **Do not hand-edit** the generated `CLAUDE.md` or `.claude/commands/*.md` — both are overwritten on the next run.

## Generated commands

`adapters/claude/generate-commands.mjs` discovers `.ai/prompts/{public,internal}/eversis-*.md` and writes one thin pointer file per prompt to `.claude/commands/<id>.md` — same discovery, deny-list (`command-deny.yaml`), and marker-gated orphan-cleanup contract as Cursor's `.cursor/commands/` (DHI-598), so `/eversis-implement` etc. work the same way in both tools. Frontmatter is `description` + `argument-hint` (Claude has no `globs`/`alwaysApply`); the GENERATED marker sits at the end of the file, not the top, so it never leaks into the slash-menu preview text.

## Generated skills

`.claude/skills/` is **not generated** by a Node script — it's linked (symlink) or copied by the installer's `_link_claude_skills` (`scripts/lib/setup-agent-collections/link-framework.sh`), one entry per `.ai/skills/eversis-*/` directory, following the same `EFFECTIVE_LINK_MODE` decision as the rest of framework materialisation. Content is never rewritten, so a skill's own frontmatter is preserved exactly — including `user-invocable: false` on orchestration-only skills (e.g. `eversis-orchestrating-implementation`), which keeps them out of the `/` menu while remaining loadable by the model.

## Generated rule ids

| id | Source | Emit target |
|----|--------|-------------|
| `eversis-agent-core` | `.ai/rules/orchestration/agent-core.md` | `CLAUDE.md` H2 section |
| `eversis-testing-and-terminal` | `.ai/rules/orchestration/testing-and-terminal.md` | `CLAUDE.md` H2 section |
| `eversis-accessibility` | `.ai/rules/frontend/accessibility.md` | `.claude/rules/eversis-accessibility.md` (`paths:` frontmatter — **not** a `CLAUDE.md` section) |
| `eversis-engineering-manager` | `.ai/rules/orchestration/engineering-manager.md` | `CLAUDE.md` H2 section |
| `eversis-code-reviewer` | `.ai/rules/architecture/code-reviewer.md` | `CLAUDE.md` H2 section |
| `eversis-fine-handoff` | `.ai/rules/orchestration/fine-handoff.md` | `CLAUDE.md` H2 section |
| `eversis-spec-driven-development` | `.ai/rules/orchestration/spec-driven-development.md` | `CLAUDE.md` H2 section |

`id` / `source` parity with [`adapters/cursor/rule-map.yaml`](../cursor/rule-map.yaml). Source of packaging metadata: [`rule-map.yaml`](./rule-map.yaml). Emit target is derived automatically at generate time — `adapters/claude/generate.mjs` reads `globs:` for each id from the **Cursor** map (`adapters/cursor/rule-map.yaml`, the single source of truth for which rules are glob-scoped) and routes non-empty-`globs` ids to `.claude/rules/*.md` instead of an inline `CLAUDE.md` section. Nothing to configure in the Claude map itself — it stays free of Cursor packaging fields, per the existing `globs`/`alwaysApply`/`description`/`output` ban in `validateRule`.

## Exceptions (not generated)

| Item | Reason |
|------|--------|
| Prompt content mirrors | `.claude/commands/*.md` are thin pointers, not full prompt copies — SSOT stays under `.ai/prompts/` |
| BA Docs rules | Not in Cursor MVP map — same exclusion here |
| Consumer `eversis-project-stack.mdc` (Cursor) | **Consumer-owned** — never overwrite without opt-in |
| Consumer `.claude/CLAUDE.md` | **Consumer-owned** — seeded once by the installer, never regenerated (see Consumer project notes) |
| Monorepo area / path globs | **Deferred** to DHI-530 (Work Stream 3) |
| `.claudeignore` | **Shipped** at repo root (DHI-529 ignore triad), but **not enforced by Claude Code** — it is a class source only; the installer regenerates `permissions.deny` in `.claude/settings.json` from it on every run (see [`isolation-strategy.md`](../../docs/architecture/isolation-strategy.md) §8.1) |

`.claude/rules/*.md` (glob-scoped rules) and native `.claude/commands/` / `.claude/skills/` are **no longer deferred** — see "Generated rule ids", "Generated commands", and "Generated skills" above. They were deferred at DHI-523 / DHI-526 (Q1=A) time; that decision was revisited and shipped alongside this framework's claude-code-setup work.

## Consumer project notes

- **Do not hand-edit** the generated `CLAUDE.md`, `.claude/commands/*.md`, or `.claude/rules/*.md` — all three are overwritten on the next `sync:adapters` / Claude generate run.
- Claude Code does **not** load Cursor `.cursor/rules/*.mdc`, and does **not** auto-read `AGENTS.md` — put consumer stack, area map, and skills policy in **`.claude/CLAUDE.md`** instead (seeded once by the installer's `scaffold_project` — `templates/claude-CLAUDE.template.md` — never regenerated). This is the Claude Code equivalent of Cursor's `eversis-project-stack.mdc`. When `AGENTS.md` also exists, the seeded `.claude/CLAUDE.md` starts with `@AGENTS.md` so the shared orientation map is still loaded.
- Skills resolve two ways: **natively** via `.claude/skills/` (linked/copied by the installer from `.ai/skills/eversis-*/`, discoverable in the `/` menu unless `user-invocable: false`), or via MCP **`eversis-collections`** (or by reading `.ai/skills/*/SKILL.md` from the framework home / vendor path directly).

## Requirements

- Node.js 18+ (stdlib only; no npm install)
- Run from the **repository root** (directory that contains `.ai/` and `adapters/`)
