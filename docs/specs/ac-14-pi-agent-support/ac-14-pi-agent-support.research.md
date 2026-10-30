# AC-14 pi agent support - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | AC-14 |
| Title | Add full Pi Agent support |
| Description | Add Pi as a shipped agent: a team that chooses Pi at install can use the framework's rules, skills, and prompt templates in a Pi session; a long Implement session in Pi keeps a ~50% context budget (Pi-only, deferred from AC-2). |
| Priority | Medium |
| Reporter | Piotr Niemirski |
| Created Date | 2026-09-21 |
| Due Date | — |
| Labels | `adapter`, `pi-agent`, `workshop-2026-09-21` |
| Estimated Effort | Large (suggestion from `docs/specs/pi-agent-support/jira-tasks.md`; team estimates in refinement) |
| Parent | AC-115 (Epic, "Full Pi Agent support") — AC-14 is the core Task and **blocks AC-111 – AC-114** |

## Business Impact

Teams working in Pi (https://pi.dev/) cannot use Agent Collections today. Cursor and Claude Code are shipped agents; OpenCode is a placeholder. AC-14 makes Pi a third shipped agent generated from the same `.ai/` SSOT (no second copy of the framework), and gives Pi — the only host whose extensions can read context-window fill — the ~50% context budget that AC-2 removed from the shared Implement rule. AC-111 – AC-114 (subscription sign-in, token-economy rules, ignore files, isolated workspace) all build on the packaging this task introduces.

## Gathered Information

### Knowledge Base & Task Management Tools

**Jira AC-14 — Requirements (verbatim intent):**

1. A person installing Agent Collections can choose Pi.
2. After that choice, a Pi session can use the framework's rules, skills, and prompt templates.
3. Public docs and the install choice list name Pi as a supported agent and say what the install provides.
4. Choosing not to include Pi leaves other selected agents unchanged.
5. If Pi setup cannot be completed, the person sees a clear failure and other selected agents are unaffected.
6. A long Implement session in Pi keeps a context budget of about 50%: Pi can see how full the window is, and compaction at that level runs before the current task is dropped.
7. Cursor and Claude Code sessions do not checkpoint or end because of context-window fill (AC-2 decision stays).

**Acceptance criteria (Jira):**

- AC1 — GIVEN Pi chosen at install WHEN install finishes THEN a Pi session can use the framework's rules, skills, and prompt templates.
- AC2 — GIVEN Pi is supported WHEN a reader opens install guidance or public docs THEN Pi is listed and the page says what the install provides.
- AC3 — GIVEN Pi not chosen WHEN install finishes THEN Pi packaging is not added and other agents still work.
- AC4 — GIVEN Pi chosen and Pi setup cannot complete WHEN install finishes THEN clear failure; other agents unaffected.
- AC5 — GIVEN an Implement session in Pi WHEN the window reaches ~half THEN the session compacts under that ~50% budget before the current task is dropped.
- AC6 — GIVEN an Implement session in Cursor or Claude Code WHEN the window fills THEN no checkpoint / end because of window fill.
- AC7 — Support is shipped and usable, not a config-only placeholder.

**Out of scope (Jira):** promoting OpenCode; rewriting the vendor-neutral core; Pi themes / model or provider catalogs / embedding Pi; sandbox beyond the opt-in isolated workspace (AC-114); *building* capabilities Pi does not ship (MCP, sub-agents, plan mode, permission prompts, to-dos, background shell); a window-percent trigger in the Cursor / Claude Code rule.

**Technical notes (Jira):** "Pi exposes window usage to the agent (`context_info`) and ships `pi-rolling-compaction` at 50%. Install settings for that host (including `.pi/settings.json`) belong with this ticket."

**Sibling scope (Epic AC-115) — kept out of AC-14:** subscription sign-in / model cost (AC-111), token-economy rules (AC-112), `.piignore`-style exclusion of heavy and secret files (AC-113), isolated workspace with restricted network (AC-114).

**AC-2 history** (`docs/specs/ac-2/ac-2.plan.md`, Open Question 6 + Task 3.2): the ~50% window trigger was removed from rule 14 of `eversis-orchestrating-implementation` because Cursor and Claude Code cannot observe window fill. "Do not mention PI Agent in the skill." Restoring a ~50% trigger is a Pi-install follow-up only.

### Benchmark — sternik-kariery Pi integration

User-provided benchmark: `/Users/piotrniemirski/Documents/repos/WUP/sternik-kariery` (commits `a65f9276`, `927b2f18`, `07b796d3`, 2026-10-27). It is a **consumer-side** port, not a framework adapter:

| Piece | Benchmark implementation | Reuse for AC-14 |
|---|---|---|
| Generator | `scripts/gen-pi-adapter.mjs` (271 lines, zero deps, `--check` mode, GENERATED marker, marker-gated orphan cleanup) | **High** — port into `adapters/pi/generate.mjs`; same idioms as `adapters/claude/generate-commands.mjs` |
| Rule map | `scripts/pi-rule-map.yaml` — `target: append_system` (agent-core, testing-and-terminal, accessibility with UI note) / `target: skill` (engineering-manager, code-reviewer, fine-handoff, spec-driven-development) + consumer `overlays` from `.cursor/rules/*.mdc` | **High** — becomes `adapters/pi/rule-map.yaml`; overlays need a framework-side equivalent (see Q4) |
| Always-on rules | `.pi/APPEND_SYSTEM.md` (28 KB, ~7k tokens incl. consumer overlays) | Yes — Pi's project system-prompt append surface |
| Prompts | `.pi/prompts/eversis-*.md` (28) — `description` + `argument-hint` frontmatter, executable section only, SSOT pointer, trailing `**User input for this run:** $ARGUMENTS` | Yes — matches Pi prompt-template contract |
| Role skills | `.pi/skills/eversis-{engineering-manager,code-reviewer,fine-handoff,spec-driven-development}/SKILL.md` | **Needs change** — `eversis-fine-handoff` collides with the framework skill of the same name (see Q2) |
| Step skills (51 `.ai/skills/eversis-*`) | **Not mirrored**; served only via `eversis-collections` MCP in `.pi/mcp.json` | Gap — Claude/Cursor get a local mirror that works without MCP/Docker (see Q1) |
| MCP | `.pi/mcp.json` — same `mcpServers` shape as `.mcp.json`; `eversis-collections` uses the `$PWD`-walk bash launcher (Claude variant minus `$CLAUDE_PROJECT_DIR`) | Yes — installer `mcp-merge` gains a `pi` host |
| Settings / context budget | **None** — no `.pi/settings.json`, no compaction extension | Gap — AC5 not covered by the benchmark |
| Wiring | `package.json` `sync:agents` runs vendor `adapters/sync.mjs` then the local generator | Replaced by native `--agents pi` in `adapters/sync.mjs` + installer |
| Analysis | `docs/specs/ac-14/pi-adapter-analysis.draft.md` — recommends moving the generator upstream into `adapters/pi/` so `git subtree pull` / sync keep Pi current | Confirms the AC-14 direction |

### Pi host capabilities (verified against installed Pi 1.4.0, `@earendil-works/pi-coding-agent`, local `docs/`)

| Surface | Fact | Source |
|---|---|---|
| Project config dir | `.pi/` (`piConfig.configDir`); loads **only after project trust** is granted | `docs/configuration.md`, `docs/security.md` |
| System prompt append | `.pi/APPEND_SYSTEM.md` (trusted project file wins over `~/.pi/agent/APPEND_SYSTEM.md`; not combined) | `docs/configuration.md` |
| Context files | `AGENTS.override.md` / `AGENTS.md` / `CLAUDE.md` from cwd and parents; loaded **regardless of trust**; precedence within one dir implied as override → AGENTS → CLAUDE (one file per dir — inferred from docs wording, not code-verified) | `docs/configuration.md` §Context files |
| Prompts | `.pi/prompts/*.md` → `/name`; frontmatter `description`, `argument-hint`; `$ARGUMENTS`, `$1`, `${@:N}` | `docs/prompt-templates.md` |
| Skills | Agent Skills spec; `.pi/skills/`, `.agents/skills/` (cwd → repo root), `settings.skills[]`; recursive `SKILL.md` discovery; `name` ≤ 64 chars, `description` ≤ 1024 chars; **name collisions keep the first discovered and warn**; `/skill:name` forces load | `docs/skills.md` |
| Settings | `.pi/settings.json` overrides `~/.pi/agent/settings.json`; resource arrays (`skills`, `prompts`, `extensions`, `packages`) are combined; `$schema: https://pi.dev/schemas/settings.schema.json` | `docs/settings.md` |
| Compaction | Auto when `contextTokens > contextWindow - compaction.reserveTokens` (default 16384); **absolute tokens, not percent**; per-model overrides via `compaction.modelOverrides` | `docs/settings.md`, `docs/compaction.md` |
| Context usage API | Extensions: `ctx.getContextUsage()` → `{ tokens, percent }` (both `null` right after compaction) and `ctx.compact({ customInstructions, onComplete, onError })`; `turn_end` is the actionable boundary | `docs/extensions.md`, `CHANGELOG.md`, `examples/extensions/trigger-compact.ts` |
| Extensions | `.pi/extensions/*.ts` (or dir with `index.ts`), loaded via `jiti` — no build step | `docs/extensions.md` |
| MCP | **Built-in** (`builtin:mcp`); `.pi/mcp.json` / `~/.pi/agent/mcp.json`, `mcpServers` format compatible with Claude/Cursor; `${VAR}` interpolation in `env` / `headers` | `docs/mcp.md`, `docs/settings.md` |

**Corrections to ticket assumptions (factual, from Pi 1.4.0):**

1. **`context_info`** — no tool or API by that name exists in Pi 1.4.0 docs or changelog. The real mechanism is the extension API `ctx.getContextUsage()` (the agent model itself does not see window fill; an extension does).
2. **`pi-rolling-compaction`** — not published on npm (`npm view pi-rolling-compaction` → 404). Pi ships the example `examples/extensions/trigger-compact.ts` (absolute 100k-token threshold) instead. AC5 therefore needs a small framework-owned extension, or a `reserveTokens` setting (see Q3).
3. **MCP** — Pi 1.4.0 *does* ship MCP (`builtin:mcp`). The out-of-scope line ("building capabilities Pi does not ship (MCP …)") stays true — nothing is built — but the install can *use* MCP by writing `.pi/mcp.json`.

### Codebase

**Adapter layer** (`adapters/`):
- `adapters/sync.mjs` (717 lines) — umbrella; `--agents` accepts only `cursor,claude,opencode` (hard-coded in `parseArgs`, lines ~81–95); `--check` compares fresh generation to disk; refreshes/checks `.cursor/skills` and `.claude/skills` mirrors on framework self-host; `runOpenCodePlaceholder` for opencode.
- `adapters/claude/generate-commands.mjs` — closest analogue to a Pi prompt generator (deny-list, executable-section extraction, GENERATED marker, orphan cleanup, `--framework-prefix` for vendored installs).
- `adapters/claude/rule-map.yaml` / `adapters/cursor/rule-map.yaml` — 7 rules; sync asserts id/source parity between them (`assertIdSourceParity`).
- `adapters/opencode/` — placeholder only.
- `adapters/README.md`, `docs/architecture/adapter-mapping.md` (§2 emit matrix, §7 maturity legend, §9 implementer checklist) — need a Pi section.

**Installer** (`scripts/setup-agent-collections.sh` + `scripts/lib/setup-agent-collections/`):
- `agents.sh` — `_validate_agents` allow-list `cursor|claude|opencode`; numbered fallback menu (5 options); `agents-prompt.mjs` checkbox choices.
- `link-framework.sh` — `_run_adapter_sync` passes `--agents`; `_link_claude_skills` / `_link_cursor_skills` mirror `.ai/skills/eversis-*` (symlink or copy) and prune stale entries; `_prune_deselected_*` remove marker-gated generated files when an agent is deselected.
- `mcp-merge.sh` / `mcp-merge.mjs` — per-host merge (`MCP_HOST=cursor|claude`); Claude variant uses `$CLAUDE_PROJECT_DIR` in the `eversis-collections` launcher.
- `merge-ignore-triad.mjs` — per-agent ignore files (Pi ignore = AC-113, **not** AC-14).
- `selection.sh` — records `agents[]` in `.agent-collections/install-selection.json` (upgrade path reuses it).
- `summary.sh` — per-agent "Next steps".
- Failure handling: each step is `… || { record_fail "<step>"; _print_partial_fail; exit 1; }` — a Pi failure inside a shared step (sync, mcp-merge) currently aborts the whole run. AC4 ("other agents unaffected") needs a Pi failure isolated or reported without undoing other agents' output (see Q5).
- Tests: `scripts/setup-agent-collections.test.sh` (`npm run installer:smoke`) + per-lib `*.test.sh` (e.g. `mcp-merge.test.sh`, `upgrade-preserve.test.sh`).

**Shared rule (must stay unchanged for AC6):** `.ai/skills/eversis-orchestrating-implementation/SKILL.md` rule 14 — "Context-window fill is not a trigger — do not write `CHECKPOINT:` or end the session because the window looks partly full." AC6 is already satisfied; AC-14 must not regress it. The ~50% budget lives in Pi host config only.

**Docs listing agents:** `README.md`, `AGENTS.md`, `adapters/README.md`, `website/docs/intro.md`, `website/docs/getting-started/{installation.mdx,start-here.mdx,prerequisites.mdx}`, `website/docs/reference/framework-reference.md`, `website/docs/advanced/{isolation.md,migration-from-cursor-collections.md}`.

### Relevant Links

- https://pi.dev/ — Pi product
- Local Pi 1.4.0 docs: `~/.nvm/versions/node/v24.16.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/` (`skills.md`, `prompt-templates.md`, `settings.md`, `compaction.md`, `extensions.md`, `mcp.md`, `configuration.md`, `security.md`)
- Pi example `examples/extensions/trigger-compact.ts` — reference for the compaction extension
- `docs/specs/pi-agent-support/` — intent brief (2026-09-21), extracted tasks, quality review, Jira tasks (scope extension 2026-10-27)
- `docs/specs/ac-2/ac-2.plan.md` — Open Question 6, Task 3.2 (why ~50% is Pi-only)
- Benchmark: `sternik-kariery/scripts/gen-pi-adapter.mjs`, `scripts/pi-rule-map.yaml`, `.pi/`, `docs/specs/ac-14/pi-adapter-analysis.draft.md`

### Relevant Charts & Diagrams

```text
.ai/ (SSOT)                     adapters/pi/ (new)                consumer project
─────────────                   ──────────────────                ─────────────────
.ai/rules/**  ── rule-map ───▶  generate.mjs ──────────────────▶  .pi/APPEND_SYSTEM.md   (always-on)
                                                     └─────────▶  .pi/skills/<role>/     (on-demand role rules)
.ai/prompts/{public,internal} ─▶ generate.mjs ──────────────────▶  .pi/prompts/eversis-*.md
.ai/skills/eversis-*  ───────── installer mirror (symlink/copy) ▶  .pi/skills/eversis-*/  (Q1)
templates/mcp.json  ─────────── mcp-merge (host=pi) ────────────▶  .pi/mcp.json
adapters/pi/ static assets ──── sync ───────────────────────────▶  .pi/settings.json, .pi/extensions/eversis-context-budget.ts (Q3)
```

## Current Implementation Status

### Existing Components

- Adapter sync CLI - `adapters/sync.mjs` - needs extension (`pi` agent id, generate + `--check` + skills mirror)
- Claude command generator - `adapters/claude/generate-commands.mjs` - can be reused as pattern
- Benchmark generator - `sternik-kariery/scripts/gen-pi-adapter.mjs` - can be reused (port, then adapt paths / prefix / collision handling)
- Agent selection - `scripts/lib/setup-agent-collections/agents.sh`, `agents-prompt.mjs` - needs extension
- Framework linking + skills mirror + deselect pruning - `scripts/lib/setup-agent-collections/link-framework.sh` - needs extension
- MCP merge - `scripts/lib/setup-agent-collections/mcp-merge.sh`, `mcp-merge.mjs` - needs extension (`pi` host)
- Install summary - `scripts/lib/setup-agent-collections/summary.sh` - needs extension
- Rule 14 (no window trigger on Cursor/Claude) - `.ai/skills/eversis-orchestrating-implementation/SKILL.md` - can be reused unchanged (AC6)
- Ignore triad - `scripts/lib/setup-agent-collections/merge-ignore-triad.mjs` - **no change in AC-14** (AC-113)

### Key Files and Directories

- `adapters/pi/` - new adapter (generator, rule map, README, static `.pi/settings.json` + context-budget extension)
- `adapters/sync.mjs` - register `pi`
- `scripts/lib/setup-agent-collections/{agents.sh,agents-prompt.mjs,link-framework.sh,mcp-merge.sh,mcp-merge.mjs,summary.sh}` - installer support
- `scripts/setup-agent-collections.test.sh`, `scripts/lib/setup-agent-collections/*.test.sh` - smoke coverage for `--agents=pi` and deselect
- `docs/architecture/adapter-mapping.md`, `adapters/README.md`, `README.md`, `AGENTS.md`, `website/docs/getting-started/*` - docs (AC2)
- `package.json` - possibly no change (`sync:adapters` already wraps `sync.mjs`)

## Gap Analysis

### Question 1
#### How should the 51 framework step skills reach a Pi session?
Proposed: mirror `.ai/skills/eversis-*` into `.pi/skills/` exactly like `.claude/skills/` and `.cursor/skills/` (symlink/copy, stale-prune, deselect-prune). This keeps skills usable without Docker/MCP (AC1, AC7) and matches the existing host-mirror contract. Alternatives: `settings.skills` pointing at the vendored `.ai/skills` (no copy, but path differs between vendor / local modes and resolves from `.pi/`), or MCP-only as in the benchmark (fails when Docker is not running). **Answer (2026-10-30): recommendation accepted.**

### Question 2
#### How do we avoid the `eversis-fine-handoff` name collision?
The benchmark turns four role rules into `.pi/skills/<rule-id>/`. The rule id `eversis-fine-handoff` equals the framework skill `.ai/skills/eversis-fine-handoff/`; with the skills mirror (Q1) Pi keeps the first discovered and warns, so one of them is silently lost. Options: (a) put all seven rules in `APPEND_SYSTEM.md` (simplest; mirrors Claude, where all seven sit in `CLAUDE.md`; costs always-on tokens); (b) keep role rules as skills but with a distinct id (e.g. `eversis-rule-fine-handoff`); (c) drop the `fine-handoff` role-skill because the framework skill of the same purpose is already mirrored. Proposed: **(b) for the role rules that are not already skills, (c) for `fine-handoff`** — keeps APPEND_SYSTEM small (AC-112 cares about this) and avoids duplicate content. **Answer (2026-10-30): recommendation accepted.**

### Question 3
#### How is the ~50% context budget (AC5) implemented, given `context_info` and `pi-rolling-compaction` do not exist?
Options: (a) a framework-shipped project extension `.pi/extensions/eversis-context-budget.ts` that on `turn_end` reads `ctx.getContextUsage().percent` and calls `ctx.compact(...)` once it crosses 50% (pattern from Pi's `trigger-compact.ts`; percent-based, so model-independent; custom instructions can ask the summary to keep the current plan task, the plan path and the latest `CHECKPOINT:`); (b) `.pi/settings.json` `compaction.reserveTokens` sized to half the window — absolute tokens, so wrong for any model whose window differs, and per-model overrides would need a model catalog (out of scope). Proposed: **(a)**, plus `.pi/settings.json` carrying only what the extension needs (and `$schema`). Threshold configurable via one constant / env var, default 50. **Answer (2026-10-30): recommendation accepted.**

### Question 4
#### What replaces the benchmark's consumer `overlays` (`eversis-project-stack`, `jira-bugfix-workflow` from `.cursor/rules/*.mdc`)?
The project-stack rule is consumer-owned and only seeded for Cursor today (`_seed_stack_rule`). For Pi the generator could append a consumer-owned stack file when present (e.g. `.cursor/rules/eversis-project-stack.mdc` body, or a Pi-specific seed). Proposed: append `eversis-project-stack` when the file exists in the target (front-matter stripped); no other overlays in AC-14 — teams can add their own later. **Answer (2026-10-30): recommendation accepted.**

### Question 5
#### What does "clear failure, other agents unaffected" (AC4) mean for the installer's fail-fast steps?
Today any failing step exits the whole installer. Proposed: run Pi generation as its own sync stage after Cursor/Claude; on Pi failure, print a dedicated `pi` failure line (via `record_fail "pi"` + `_print_partial_fail`), leave Cursor/Claude outputs already written in place, do not record `pi` in `install-selection.json`, and exit non-zero. Pre-check: Pi CLI presence is **not** required at install (files only) — a missing `pi` binary is a summary warning, not a failure. **Answer (2026-10-30): recommendation accepted.**

### Question 6
#### Should `CLAUDE.md` double-loading in Pi be handled in AC-14?
Pi loads `AGENTS.md`/`CLAUDE.md` context files regardless of trust. If a consumer selects Claude + Pi and has no `AGENTS.md`, Pi would load `CLAUDE.md` (all seven rules) *and* `APPEND_SYSTEM.md` → duplicated always-on content. Proposed: document it in the Pi README (recommend keeping a root `AGENTS.md`, which most consumers already have) and leave token trimming to AC-112. **Answer (2026-10-30): recommendation accepted.**

### Question 7
#### Vendor-path prefix for SSOT pointers in generated Pi prompts?
Claude commands use `--framework-prefix` so SSOT pointers resolve in vendored installs. The Pi generator should take the same flag (benchmark hard-coded `vendor/agent-collections`). Proposed: reuse `_resolve_framework_prefix` output. **Answer (2026-10-30): recommendation accepted.**

## Human gates

1. ~~Approve research~~ — done (`Q1. Recommendation OK; Q2. Recommendation ok; Q3. Recommendation ok; Q4. Recommendation ok; Q5. Recommendation ok; Q6. Recommendation ok; Q7. Recommendation ok;`)
2. Approve plan (`ac-14-pi-agent-support.plan.md`)
3. Implement → Review → Fine

## Changelog

| Date | Change Description |
|---|---|
| 2026-10-28 | Research created. Sources: Jira AC-14 / AC-115, `docs/specs/pi-agent-support/`, AC-2 plan, sternik-kariery benchmark (commits `a65f9276`, `927b2f18`), installed Pi 1.4.0 docs. Corrected ticket assumptions: no `context_info`, no `pi-rolling-compaction` on npm, MCP is built-in. |
| 2026-10-30 | Gap Analysis Q1–Q7 answered: all recommendations accepted. Research gate closed; plan written. |
