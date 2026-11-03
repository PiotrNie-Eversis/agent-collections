# Adapter architecture and mapping specification

**Status:** Canonical (committed)  
**Story:** Work Stream 2 / Story 2.1  
**Audience:** Implementers of the Cursor generator, the Claude Code generator, the OpenCode placeholder, and the adapter sync CLI

This document is the **single source of truth** for how Agent Collections **core** (`.ai/`) transforms into each tool’s native packaging. Core rule bodies stay vendor-neutral Markdown; packaging metadata and generated outputs live in the **adapter** layer (created in follow-on stories — **not** in this document’s delivery).

---

## 1. Purpose and model

```text
.ai/ (SSOT — content)
  rules/<domain>/*.md
  skills/eversis-*
  prompts/{public,internal}

        │
        ▼  mapping (this spec) + rule-map / generators

adapters
  cursor/   → .cursor/rules/*.mdc + thin .cursor/commands/eversis-*.md
  claude/   → CLAUDE.md
  opencode/ → opencode.json (+ optional AGENTS pointers)
```

| Concept | Definition |
|---------|------------|
| **Core asset** | File under `.ai/` (rule, skill package, prompt) |
| **Adapter** | Tool-specific packaging that **consumes** core; does not own canonical text |
| **Emit** | Whether the adapter **writes** a tool-native file for that asset class in MVP |
| **Maturity** | `shipped` \| `placeholder` \| `deferred` for an adapter capability |

**Invariant:** Do not put Cursor YAML (`description`, `globs`, `alwaysApply`) or Claude/OpenCode-only conventions inside `.ai/rules/*.md`.

---

## 2. Emit matrix (MVP)

| Adapter | Rules | Prompts | Skills | Commands / other | Maturity |
|---------|-------|---------|--------|------------------|----------|
| **Cursor** | Generate `.cursor/rules/*.mdc` via **rule-map** | **No** full mirror | **No** emit — resolve via MCP skill resolution | **Thin** `.cursor/commands/eversis-*.md` from `.ai/prompts` (HYBRID pointer + Executable) — not a full prompt copy | Generator: `adapters/cursor/` (Cursor generator + thin slash commands) |
| **Claude Code** | Root **`CLAUDE.md`** (H2 section per non-glob-scoped mapped rule) + `.claude/rules/*.md` (`paths:` frontmatter for glob-scoped rules) | **No** full mirror | **Native** `.claude/skills/eversis-*/` — linked/copied by the **installer** (not the generator) from `.ai/skills/`, one dir per skill package | **Thin** `.claude/commands/eversis-*.md` from `.ai/prompts` (same HYBRID pointer + Executable shape as Cursor's thin slash commands; `description` + `argument-hint` frontmatter, marker at file end) — closes the claude-code-setup research's F1 | Generator: `adapters/claude/generate.mjs` + `generate-commands.mjs` (Claude Code generator); skills linking + `.claude/CLAUDE.md`/`.claude/settings.json` seeding: installer (`scripts/lib/setup-agent-collections/`) — **shipped** |
| **OpenCode** | Point at core (or generated) paths via `opencode.json` `instructions` | Deferred | Deferred | Config placeholder; optional `AGENTS.md` | **placeholder** |

Skills and prompts remain under `.ai/` as SSOT. Cursor slash files are **thin packaging** only (stable id + path + optional Executable section). Adapters **must not** claim they ship a full multi-copy of skills/prompts.

---

## 3. Cursor adapter mapping

### 3.1 Field map

| Field | Type | Required | Meaning |
|-------|------|----------|---------|
| `description` | string | **Yes** | Short summary shown in Cursor rule UI |
| `alwaysApply` | boolean | Conditionally | `true` = always-on; use sparingly |
| `globs` | string[] | Conditionally | Path patterns when the rule auto-attaches |

**Packaging modes (exactly one per mapped rule):**

| Mode | Front matter shape | When |
|------|--------------------|------|
| **Always-on** | `alwaysApply: true` (+ `description`) | Core orchestration / quality that must load every session |
| **Glob-scoped** | `globs: […]` (+ `description`); omit `alwaysApply` or set false | Domain rules tied to file types |
| **Attach-only** | `globs: []`, `alwaysApply: false` (+ `description`) | Role rules loaded on demand |

### 3.2 Packaging classes (inputs)

| Class | Typical core sources | Cursor packaging |
|-------|----------------------|------------------|
| Always-on | `.ai/rules/orchestration/agent-core.md`, `testing-and-terminal.md` | `alwaysApply: true` |
| Glob-scoped | `.ai/rules/frontend/accessibility.md` | `globs` list (see example) |
| Attach-only | `engineering-manager.md`, `code-reviewer.md`, BA role rules | `globs: []`, `alwaysApply: false` |

**Consumer-owned:** project stack customization is **not** framework SSOT. If listed in a consumer install, the adapter **must not** overwrite it without explicit opt-in (see versioning / upgrade contract).

### 3.3 Output path

| Core | Output |
|------|--------|
| `.ai/rules/<domain>/<name>.md` | `.cursor/rules/eversis-<stable-id>.mdc` |

Body of the `.mdc` = YAML front matter + Markdown body copied (or lightly adapted) from the core rule. Prefer stable ids aligned with legacy `eversis-*` names where they already exist.

### 3.4 Worked examples

**Always-on**

```markdown
---
description: Core agent behavior — relay workflow, human gates, no placeholder code
alwaysApply: true
---

# …body from .ai/rules/orchestration/agent-core.md…
```

**Glob-scoped**

```markdown
---
description: Accessibility expectations for UI code
globs:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.vue"
  - "**/*.html"
  - "**/*.svelte"
---

# …body from .ai/rules/frontend/accessibility.md…
```

**Attach-only**

```markdown
---
description: Engineering Manager — orchestrate research, plan, implementation
globs: []
alwaysApply: false
---

# …body from .ai/rules/orchestration/engineering-manager.md…
```

---

## 4. Cursor `rule-map.yaml` contract

**File:** [`adapters/cursor/rule-map.yaml`](../../adapters/cursor/rule-map.yaml)  
**Generator:** [`adapters/cursor/generate.mjs`](../../adapters/cursor/generate.mjs) — run from repo root: `node adapters/cursor/generate.mjs` (optional `--out <dir>`).

### 4.1 Required shape

| Key | Required | Description |
|-----|----------|-------------|
| `version` | Yes | Integer schema version (start at `1`) |
| `rules` | Yes | List of rule entries |
| `rules[].id` | Yes | Stable id (e.g. `eversis-agent-core`) |
| `rules[].source` | Yes | Path to core `.md` (repo-relative) |
| `rules[].output` | Yes | Path to generated `.mdc` |
| `rules[].description` | Yes | Cursor `description` |
| Packaging | Yes | **Either** `alwaysApply: true` **or** `globs: […]` (attach-only uses `globs: []` and `alwaysApply: false`) |

### 4.2 Example (live map)

See committed [`adapters/cursor/rule-map.yaml`](../../adapters/cursor/rule-map.yaml). Excerpt:

```yaml
# Excerpt — full map: adapters/cursor/rule-map.yaml
version: 1
rules:
  - id: eversis-agent-core
    source: .ai/rules/orchestration/agent-core.md
    output: .cursor/rules/eversis-agent-core.mdc
    description: "Core agent behavior — relay workflow, human gates, no placeholder code"
    alwaysApply: true
  - id: eversis-accessibility
    source: .ai/rules/frontend/accessibility.md
    output: .cursor/rules/eversis-accessibility.mdc
    description: "Accessibility expectations for UI code"
    globs:
      - "**/*.tsx"
      - "**/*.jsx"
      - "**/*.vue"
      - "**/*.html"
      - "**/*.svelte"
  - id: eversis-engineering-manager
    source: .ai/rules/orchestration/engineering-manager.md
    output: .cursor/rules/eversis-engineering-manager.mdc
    description: "Engineering Manager — orchestrate research, plan, implementation"
    globs: []
    alwaysApply: false
```

### 4.3 Generator expectations

1. Read `rule-map.yaml`.
2. For each entry, write `output` with front matter from the map + body from `source`.
3. Re-run must refresh generated files without hand-editing `.mdc` bodies.
4. Replace symlink-only bootstrap in consumer/framework Cursor trees.

---

## 5. Claude Code adapter mapping

### 5.1 Field map

| Field | Meaning in this framework | Mapping |
|-------|---------------------------|---------|
| `scope` | Which core rules are inlined into `CLAUDE.md` | One **H2 section per mapped core rule file that has no non-empty `globs` in the Cursor map** (unambiguous for the Claude Code generator). A rule with non-empty Cursor `globs` (e.g. `eversis-accessibility`) is routed to `.claude/rules/<id>.md` instead — see the `paths` row below. Install profiles may later subset domains; the generator still uses section-per-rule for included ids. |
| `paths` | Glob-scoped rules (Cursor `globs:` equivalent) | `.claude/rules/<id>.md` with a `paths:` frontmatter array, copied 1:1 from the same id's `globs:` in `adapters/cursor/rule-map.yaml` (the Cursor map is the single source of truth for which rules are glob-scoped — the Claude map itself stays free of packaging fields). No longer deferred. |
| `commands` | How the agent is told to run framework entrypoints | Two surfaces: (1) **instructional** lines inside `CLAUDE.md`'s How-to section (e.g. "load prompt id `eversis-implement`"), and (2) **native** `.claude/commands/eversis-*.md` files — one per `.ai/prompts/{public,internal}/eversis-*.md`, same discovery/deny-list/orphan-cleanup contract as Cursor's `.cursor/commands/`. No longer deferred (shipped alongside this framework's claude-code-setup work). |
| `.claude/CLAUDE.md` | Consumer-owned project surface | **Not generated.** Seeded once (copy-if-absent) by the installer's `scaffold_project` from `templates/claude-CLAUDE.template.md`, importing `@AGENTS.md` when that file exists. Never regenerated or overwritten — the Claude Code equivalent of Cursor's `eversis-project-stack.mdc`. Closes the AGENTS.md↔Claude Code gap: Claude Code does not auto-read root `AGENTS.md`. |

### 5.2 Output structure

**Rules:** repository-root `CLAUDE.md` (single file, one H2 per mapped rule).

**Commands:** `.claude/commands/eversis-<id>.md` — one thin pointer file per discovered prompt, generated by `adapters/claude/generate-commands.mjs` (see §5.1 `commands` row). Not shown in the worked sketch below since it lives outside `CLAUDE.md`.

```markdown
# Agent Collections (Claude Code)

## How to use prompts and skills

- Load public prompts by stable id under `.ai/prompts/public/` (e.g. `eversis-implement`).
- Resolve skills via MCP (`eversis_skills_get`) when available; otherwise read `.ai/skills/<id>/SKILL.md`.
- Do not expect `.cursor/commands` or Cursor `@` attachment as the only entry.

## eversis-agent-core

…full or condensed body from `.ai/rules/orchestration/agent-core.md`…

## eversis-testing-and-terminal

…
```

`eversis-accessibility` is **not** shown above — it has non-empty `globs` in the Cursor map, so it's routed to `.claude/rules/eversis-accessibility.md` (`paths:` frontmatter) instead of an inline section here.

**Section title:** prefer `## <rule-id>` matching `rule-map` / stable id for cross-tool alignment.

**Skills:** not copied by the **generator** (`adapters/claude/`) — linked or copied into `.claude/skills/` by the **installer** (`scripts/lib/setup-agent-collections/link-framework.sh`, one entry per `.ai/skills/eversis-*/`). **Prompts:** not mirrored in full — only thin `.claude/commands/*.md` pointers (see `commands` row above); SSOT stays under `.ai/prompts/`.

### 5.3 Worked sketch (abbreviated)

```markdown
# Agent Collections (Claude Code)

## How to use prompts and skills
- Implement: load `.ai/prompts/public/eversis-implement.md`
- Review: load `.ai/prompts/public/eversis-review.md`

## eversis-agent-core
(You follow Ideate → Research → Plan → Implement → Review …)
```

---

## 6. OpenCode adapter mapping (placeholder)

**Maturity:** `placeholder` — richer sketch aligned to public OpenCode docs; **no** full generator required in this wave.

**Materialized:** live stub at [`adapters/opencode/`](../../adapters/opencode/) (`opencode.jsonc` + README) and an identical root `opencode.jsonc`. Field contract below is unchanged — evolve OpenCode packaging in the adapter layer only; do not rewrite `.ai/rules`.

**References:**

- Rules / instructions: [https://opencode.ai/docs/rules](https://opencode.ai/docs/rules)
- Config schema: `https://opencode.ai/config.json`

### 6.1 Primary config sketch

Hand-maintained placeholder — committed as **`opencode.jsonc`** (JSONC comments allowed):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".ai/rules/orchestration/*.md",
    ".ai/rules/frontend/*.md",
    ".ai/rules/backend/*.md",
    ".ai/rules/architecture/*.md",
    ".ai/rules/devops/*.md",
    ".ai/rules/shared-types/*.md"
  ]
}
```

| Field | Role |
|-------|------|
| `$schema` | Official OpenCode config schema URL |
| `instructions` | Array of paths / globs OpenCode loads as custom instructions (may point at `.ai/rules` directly while placeholder) |

Optional later fields (document as **TBD / deferred**, do not invent proprietary keys):

- Agent mode / permission blocks in `opencode.json` (see OpenCode agents docs) — **out of MVP placeholder** unless the OpenCode placeholder expands
- Ignore files: `.opencodeignore` → see canonical [isolation strategy](./isolation-strategy.md); triad materialized at repo root

### 6.2 `AGENTS.md`

OpenCode also supports project `AGENTS.md` as an instructions surface. Framework-wide `AGENTS.md` standardization: canonical standard **[`agents-md-standard.md`](./agents-md-standard.md)**; reference fill is this repository's own `AGENTS.md`. This placeholder may:

- Point OpenCode users at root `AGENTS.md`, and/or
- Use `instructions` globs only

Do not block the OpenCode placeholder on the AGENTS work; record the dual surface in the emit notes.

### 6.3 Placeholder status block (for install wizard / docs)

```text
adapter: opencode
maturity: placeholder
emits: opencode.jsonc (instructions → .ai/rules globs); optional AGENTS.md pointer
does_not_emit: full skill/prompt mirrors, ignore files, production-grade agent profiles
```

---

## 7. Maturity legend

| Value | Meaning |
|-------|---------|
| `shipped` | Generator/docs exist and are supported for install |
| `placeholder` | Spec + sample config only; wizard must not claim a full adapter |
| `deferred` | Explicitly out of current adapter MVP |

**Cursor** packaging for mapped rules is available via `adapters/cursor/`. **Claude Code** packaging is available via `adapters/claude/` — generates root `CLAUDE.md`, `.claude/rules/*.md`, and `.claude/commands/*.md`; the installer additionally links `.claude/skills/` and seeds `.claude/CLAUDE.md` / `.claude/settings.json` (claude-code-setup work, see §2 emit matrix). BA Docs rules may still be temporary Cursor symlinks; full skill/prompt mirrors remain outside adapter MVP emit. Ignore / monorepo isolation: canonical strategy is [`isolation-strategy.md`](./isolation-strategy.md); ignore triad materialized at repo root (enforced for Claude Code via `.claude/settings.json` `permissions.deny`); monorepo path globs remain a follow-up (see isolation strategy §8.2).

---

## 8. Sibling stories and out of scope

| Item | Responsibility |
|-------|----------------|
| **Adapter mapping (this document)** | Mapping specification (this file) + pointer from `.ai/README.md` |
| **Cursor generator** | `adapters/cursor/`, live `rule-map.yaml`, replace framework symlinks (**done** in this repo for mapped rules) |
| **Claude Code generator** | Claude `CLAUDE.md` generator (`adapters/claude/`) — **done** in this repo |
| **OpenCode placeholder** | Materialization from §6 (**done** — `adapters/opencode/` + root `opencode.jsonc`) |
| **Adapter sync CLI** | Sync / generation CLI — **done**: `node adapters/sync.mjs` (`--check`, optional `--out`; npm `sync:adapters` / `sync:adapters:check`) |
| **MCP skill resolve** | Resolve skills from `.ai/skills/` via MCP |
| **Isolation strategy** | Canonical isolation strategy — [`isolation-strategy.md`](./isolation-strategy.md) (**done**) |
| **Ignore triad** | Materialization (root `.cursorignore` / `.claudeignore` / `.opencodeignore`) — **done** |
| **Monorepo area glob scoping** | Consumes isolation strategy |
| **AGENTS.md standard** | Standard + template — [`agents-md-standard.md`](./agents-md-standard.md) |
| **AGENTS.md reference fill** | Reference `AGENTS.md` fill for this repository |

**Out of scope for this mapping-only document:** creating live generators, installer, ignore files. Cursor thin slash emit is specified in the emit matrix; full prompt/skill mirrors remain out of adapter scope.

---

## 9. Checklist for implementers (2.2–2.4)

- [ ] Every mapped Cursor rule has `description` and exactly one packaging mode
- [ ] No packaging YAML written into `.ai/rules/*.md`
- [x] Claude output is a single `CLAUDE.md` with one H2 per mapped rule (`adapters/claude/`)
- [x] OpenCode placeholder uses `$schema` + `instructions` and status `placeholder` (materialized: `adapters/opencode/`)
- [ ] Emit matrix respected (no silent full `.cursor` tree mirror in MVP)
