# Adapter architecture and mapping specification

**Status:** Canonical (committed)  
**Story:** [DHI-523](https://eversis.atlassian.net/browse/DHI-523) (Work Stream 2 / Story 2.1)  
**Audience:** Implementers of Cursor (DHI-524), Claude Code (DHI-526), OpenCode placeholder (DHI-525), and sync tooling (DHI-527)

This document is the **single source of truth** for how Agent Collections **core** (`.ai/`) transforms into each tool’s native packaging. Core rule bodies stay vendor-neutral Markdown; packaging metadata and generated outputs live in the **adapter** layer (created in follow-on stories — **not** in this document’s delivery).

---

## 1. Purpose and model

```text
.ai/ (SSOT — content)
  rules/<domain>/*.md
  skills/eversis-*
  prompts/{public,internal}

        │
        ▼  mapping (this spec) + rule-map / generators (DHI-524+)

adapters (future)
  cursor/   → .cursor/rules/*.mdc
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
| **Cursor** | Generate `.cursor/rules/*.mdc` via **rule-map** | **No** (MVP) | **No** emit — resolve via MCP after DHI-535 | **No** slash commands in MVP (Cursor-specific / later) | Generator: **DHI-524** (`adapters/cursor/`) |
| **Claude Code** | One root **`CLAUDE.md`** (H2 section per mapped rule) | **No** | **No** emit — MCP / `AGENTS.md` | Instructional “load prompt id …” inside `CLAUDE.md` only — **not** `.cursor/commands` | Generator: **DHI-526** (`adapters/claude/`) — **shipped** |
| **OpenCode** | Point at core (or generated) paths via `opencode.json` `instructions` | Deferred | Deferred | Config placeholder; optional `AGENTS.md` | **placeholder** (DHI-525) |

Skills and prompts remain under `.ai/`. Adapters **must not** claim they ship a full multi-copy of skills/prompts in MVP.

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

**File (DHI-524):** [`adapters/cursor/rule-map.yaml`](../../adapters/cursor/rule-map.yaml)  
**Generator (DHI-524):** [`adapters/cursor/generate.mjs`](../../adapters/cursor/generate.mjs) — run from repo root: `node adapters/cursor/generate.mjs` (optional `--out <dir>`).

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

### 4.3 Generator expectations (DHI-524)

1. Read `rule-map.yaml`.
2. For each entry, write `output` with front matter from the map + body from `source`.
3. Re-run must refresh generated files without hand-editing `.mdc` bodies.
4. Replace symlink-only bootstrap in consumer/framework Cursor trees.

---

## 5. Claude Code adapter mapping

### 5.1 Field map

| Field | Meaning in this framework | Mapping |
|-------|---------------------------|---------|
| `scope` | Which core rules are inlined into `CLAUDE.md` | One **H2 section per mapped core rule file** (unambiguous for DHI-526). Install profiles may later subset domains; the generator still uses section-per-rule for included ids. |
| `commands` | How the agent is told to run framework entrypoints | **Instructional** lines inside `CLAUDE.md` (e.g. “For Implement, load prompt id `eversis-implement`”). **Not** Cursor slash-command files. Native Claude command files are **deferred**. |

### 5.2 Output structure

**Single file:** repository-root `CLAUDE.md`.

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

## eversis-accessibility

…
```

**Section title:** prefer `## <rule-id>` matching `rule-map` / stable id for cross-tool alignment.

**Skills / prompts:** not copied into adapter outputs in MVP (see emit matrix).

### 5.3 Worked sketch (abbreviated)

```markdown
# Agent Collections (Claude Code)

## How to use prompts and skills
- Implement: load `.ai/prompts/public/eversis-implement.md`
- Review: load `.ai/prompts/public/eversis-review.md`

## eversis-agent-core
(You follow Ideate → Research → Plan → Implement → Review …)

## eversis-accessibility
(WCAG expectations for UI …)
```

---

## 6. OpenCode adapter mapping (placeholder)

**Maturity:** `placeholder` — richer sketch aligned to public OpenCode docs; **no** full generator required in this wave.

**Materialized (DHI-525):** live stub at [`adapters/opencode/`](../../adapters/opencode/) (`opencode.jsonc` + README) and an identical root `opencode.jsonc`. Field contract below is unchanged — evolve OpenCode packaging in the adapter layer only; do not rewrite `.ai/rules`.

**References:**

- Rules / instructions: [https://opencode.ai/docs/rules](https://opencode.ai/docs/rules)
- Config schema: `https://opencode.ai/config.json`

### 6.1 Primary config sketch

Hand-maintained placeholder (DHI-525) — committed as **`opencode.jsonc`** (JSONC comments allowed):

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

- Agent mode / permission blocks in `opencode.json` (see OpenCode agents docs) — **out of MVP placeholder** unless DHI-525 expands
- Ignore files: `.opencodeignore` → **DHI-528 / DHI-529**

### 6.2 `AGENTS.md`

OpenCode also supports project `AGENTS.md` as an instructions surface. Framework-wide `AGENTS.md` standardization is **DHI-531 / DHI-532**. This placeholder may:

- Point OpenCode users at root `AGENTS.md`, and/or
- Use `instructions` globs only

Do not block DHI-525 on the AGENTS epic; record the dual surface in the emit notes.

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

**Cursor** packaging for mapped rules is available via `adapters/cursor/` (DHI-524). **Claude Code** packaging is available via `adapters/claude/` (DHI-526) — generates root `CLAUDE.md`. BA Docs rules may still be temporary Cursor symlinks; skills/prompts remain outside adapter MVP emit. Ignore / monorepo isolation remains DHI-528–530.

---

## 8. Sibling stories and out of scope

| Story | Responsibility |
|-------|----------------|
| **DHI-523 (this)** | Mapping specification (this file) + pointer from `.ai/README.md` |
| **DHI-524** | Cursor generator, `adapters/cursor/`, live `rule-map.yaml`, replace framework symlinks (**done** in this repo for mapped rules) |
| **DHI-526** | Claude `CLAUDE.md` generator (`adapters/claude/`) — **done** in this repo |
| **DHI-525** | OpenCode placeholder materialization from §6 (**done** — `adapters/opencode/` + root `opencode.jsonc`) |
| **DHI-527** | Sync / generation CLI over existing adapters |
| **DHI-535** | MCP skill resolve from `.ai/skills/` |
| **DHI-528–530** | Ignore files and monorepo isolation |
| **DHI-531–532** | AGENTS.md standard |

**Out of scope here:** creating `adapters/`, generators, live `rule-map.yaml`, slash commands, prompt/skill mirrors, MCP rewrite, installer, ignore files.

---

## 9. Checklist for implementers (2.2–2.4)

- [ ] Every mapped Cursor rule has `description` and exactly one packaging mode
- [ ] No packaging YAML written into `.ai/rules/*.md`
- [x] Claude output is a single `CLAUDE.md` with one H2 per mapped rule (`adapters/claude/`, DHI-526)
- [x] OpenCode placeholder uses `$schema` + `instructions` and status `placeholder` (materialized: `adapters/opencode/`, DHI-525)
- [ ] Emit matrix respected (no silent full `.cursor` tree mirror in MVP)
