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
node adapters/claude/generate-agents.mjs   # role subagents → .claude/agents/
node adapters/claude/generate-hooks.mjs    # spec artifact hook launcher → .claude/hooks/
```

Optional output root (writes under the given directory) and, for vendored
consumer installs, `--framework-prefix` (prepends `.ai/...` references so
they resolve outside self-host — see `_resolve_framework_prefix` in
`scripts/lib/setup-agent-collections/link-framework.sh`):

```bash
node adapters/claude/generate.mjs --out /path/to/out --framework-prefix vendor/agent-collections
node adapters/claude/generate-commands.mjs --out /path/to/out --framework-prefix vendor/agent-collections
node adapters/claude/generate-agents.mjs --out /path/to/out --framework-prefix vendor/agent-collections
node adapters/claude/generate-hooks.mjs --out /path/to/out --framework-prefix vendor/agent-collections
```

Re-run after core or map changes. **Do not hand-edit** the generated `CLAUDE.md` or `.claude/commands/*.md` — both are overwritten on the next run.

## Generated commands

`adapters/claude/generate-commands.mjs` discovers `.ai/prompts/{public,internal}/eversis-*.md` and writes one thin pointer file per prompt to `.claude/commands/<id>.md` — same discovery, deny-list (`command-deny.yaml`), and marker-gated orphan-cleanup contract as Cursor's `.cursor/commands/`, so `/eversis-implement` etc. work the same way in both tools. Frontmatter is `description` + `argument-hint` (Claude has no `globs`/`alwaysApply`); the GENERATED marker sits at the end of the file, not the top, so it never leaks into the slash-menu preview text.

## Generated skills

`.claude/skills/` is **not generated** by a Node script — it's linked (symlink) or copied by the installer's `_link_claude_skills` (`scripts/lib/setup-agent-collections/link-framework.sh`), one entry per `.ai/skills/eversis-*/` directory, following the same `EFFECTIVE_LINK_MODE` decision as the rest of framework materialisation. Content is never rewritten, so a skill's own frontmatter is preserved exactly — including `user-invocable: false` on orchestration-only skills (e.g. `eversis-orchestrating-implementation`), which keeps them out of the `/` menu while remaining loadable by the model.

## Generated agents

`adapters/claude/generate-agents.mjs` reads [`agent-map.yaml`](./agent-map.yaml) and writes one role subagent per row to `.claude/agents/<id>.md`:

| Subagent | Stage | Reads first |
|----------|-------|-------------|
| `eversis-context-engineer` | Research — writes or updates the research artifact | `eversis-research` prompt, `eversis-task-analysing` skill, `research.example.md` |
| `eversis-architect` | Plan — writes or refreshes the implementation plan | `eversis-plan` prompt, `eversis-creating-implementation-plans` skill, `plan.example.md` |
| `eversis-code-reviewer` | Review — reports PASS / BLOCKER / SUGGESTION without changing files | `eversis-review` prompt, `eversis-code-reviewing` skill |

Each file is a thin pointer: frontmatter `name` + `description` (+ optional `tools` and `readonly` from the map), then a generated body that tells the subagent to read the listed files in full before writing, to take artifact structure only from the template (never from earlier `docs/specs/` files), to name the template in the first Changelog row, and to return the file path and a summary without asking the person for approval. A subagent cannot talk to the person, so the body adds a **hand-back rule**: clarification questions, and any write the role has no access for, go in the final message, and the Engineering Manager relays or writes them. The role prompts under `.ai/prompts/` stay the single source of the workflow.

Read paths are rewritten through `--framework-prefix`, the GENERATED marker sits at the end of each file, and marker-bearing `.claude/agents/eversis-*.md` files the map no longer lists are removed (hand-made files are kept) — the same contract as `.claude/commands/`.

**Cursor reads `.claude/agents/` too.** Cursor ignores Claude Code's `tools` allow-list and understands `readonly` instead, so the code reviewer carries both: `tools: Read, Grep, Glob, Bash` for Claude Code and `readonly: true` for Cursor.

## Generated hook

`adapters/claude/generate-hooks.mjs` writes `.claude/hooks/eversis-validate-spec.cjs`, a Claude Code `PostToolUse` hook (a command Claude Code runs after a tool call). It is copied from [`assets/eversis-validate-spec.cjs`](./assets/eversis-validate-spec.cjs) with the framework prefix filled in and the GENERATED marker appended; marker-bearing `.claude/hooks/eversis-*.cjs` files it no longer writes are removed.

The settings entry is owned by the installer's settings merge (`scripts/lib/setup-agent-collections/claude-settings-merge.mjs`), not by the generator. It keeps exactly one framework entry under `hooks.PostToolUse` in `.claude/settings.json`:

```json
{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [
    { "type": "command", "command": "node \"${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs\"" }
  ]
}
```

The entry is added only when the launcher exists in the target, and removed otherwise (also when Claude is deselected). Every consumer hook is kept.

What the launcher does after each `Write`, `Edit` or `MultiEdit`:

1. Reads the hook JSON from stdin and takes the project root from `CLAUDE_PROJECT_DIR` (or the input `cwd`).
2. Ignores every file except `docs/specs/**/*.plan.md` and `docs/specs/**/*.research.md` (Windows backslashes are normalised).
3. Checks the Node version: below 18 it prints the version message and exits 2; 18–21 validates and adds an end-of-life warning to any gap output; 22 or newer validates.
4. Finds the framework root from the generated prefix — self-host uses the project root, a vendored install uses `<project>/vendor/agent-collections`, local mode reads `.agent-collections/framework-home.txt` and then `AGENT_COLLECTIONS_HOME`. A vendored or self-host install is never redirected to another checkout.
5. Runs the validator. Exit 0 when the file passes; exit 2 with the gap list on stderr when it does not, or when the validator cannot be found (`validator not found at …`), so the guard never switches itself off silently.

Claude Code shows exit-2 stderr to the model, which fixes the file; the hook runs again on the next write. It also fires for writes made by subagents. Files written through a shell command (Bash) do not trigger it.

The launcher is old-syntax CommonJS so that an unsupported Node can still parse it and print the version message instead of a syntax error. `node .claude/hooks/eversis-validate-spec.cjs --self-test` resolves the validator exactly as a hook run does, validates a built-in bad plan held in memory, and prints `eversis-validate-spec self-test: ok` (exit 0) only when gaps are reported; any problem exits 1 with the reason. It reads no project spec file and writes nothing.

**Windows:** Claude Code runs hook commands through Git Bash when it finds one, and otherwise through PowerShell, where `${CLAUDE_PROJECT_DIR}` may not expand. Claude Code on Windows needs Git Bash for the hook — the same tool the installer already needs.

## The validator

The hook is a thin launcher; the checks live in the host-neutral `scripts/validate-spec-artifacts.mjs`, which any host or person can run directly:

```bash
node scripts/validate-spec-artifacts.mjs docs/specs/proj-123-context-management/proj-123-context-management.plan.md
node scripts/validate-spec-artifacts.mjs --report docs/specs
node scripts/validate-spec-artifacts.mjs --help
```

Required headings are read at run time from the templates (`.ai/skills/eversis-task-analysing/research.example.md` and `.ai/skills/eversis-creating-implementation-plans/plan.example.md`), so a template change needs no validator change. A research file needs every template H2 and the H3s under `## Gathered Information` and `## Current Implementation Status`. A plan needs every template H2 (including `## Human gates`), each `#### Task` needs a `[CREATE]`, `[MODIFY]` or `[REUSE]` marker, a `**Files:**` line and a `**Definition of Done**` block, and the last phase must be Code Review. Extra sections are allowed. A section missing from an existing file may be filled with one line such as "No data — section added during DELTA <date>", recorded in a Changelog row.

Exit codes: in `<file>` mode 0 when every file passes, 1 when at least one has gaps, 2 for a usage or I/O error. `--report <dir>` lists every non-compliant file and exits 0 after the walk (2 on a usage or I/O error); it is informational and stays out of CI.

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
| Monorepo area / path globs | **Not generated** by this adapter — area path scoping is a separate concern (installer area profiles in [`../profiles/`](../profiles/README.md); see [`isolation-strategy.md`](../../docs/architecture/isolation-strategy.md) §8.2) |
| `.claudeignore` | **Shipped** at repo root (part of the ignore triad `.cursorignore` / `.claudeignore` / `.opencodeignore`), but **not enforced by Claude Code** — it is a class source only; the installer regenerates `permissions.deny` in `.claude/settings.json` from it on every run (see [`isolation-strategy.md`](../../docs/architecture/isolation-strategy.md) §8.1) |

`.claude/rules/*.md` (glob-scoped rules) and native `.claude/commands/` / `.claude/skills/` are **no longer deferred** — see "Generated rule ids", "Generated commands", and "Generated skills" above. They were deferred in the first version of this adapter; that decision was revisited and shipped alongside this framework's claude-code-setup work.

## Consumer project notes

- **Do not hand-edit** the generated `CLAUDE.md`, `.claude/commands/*.md`, or `.claude/rules/*.md` — all three are overwritten on the next `sync:adapters` / Claude generate run. The same applies to `.claude/agents/eversis-*.md` and `.claude/hooks/eversis-*.cjs`.
- Claude Code does **not** load Cursor `.cursor/rules/*.mdc`, and does **not** auto-read `AGENTS.md` — put consumer stack, area map, and skills policy in **`.claude/CLAUDE.md`** instead (seeded once by the installer's `scaffold_project` — `templates/claude-CLAUDE.template.md` — never regenerated). This is the Claude Code equivalent of Cursor's `eversis-project-stack.mdc`. When `AGENTS.md` also exists, the seeded `.claude/CLAUDE.md` starts with `@AGENTS.md` so the shared orientation map is still loaded.
- Skills resolve two ways: **natively** via `.claude/skills/` (linked/copied by the installer from `.ai/skills/eversis-*/`, discoverable in the `/` menu unless `user-invocable: false`), or via MCP **`eversis-collections`** (or by reading `.ai/skills/*/SKILL.md` from the framework home / vendor path directly).

## Requirements

- Node.js 22+ (stdlib only; no npm install)
- Run from the **repository root** (directory that contains `.ai/` and `adapters/`)
