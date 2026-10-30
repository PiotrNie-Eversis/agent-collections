# copilot-readiness - Analysis Result

**Origin:** `/eversis-research "is agent-collections ready for implementing with microsoft copilot?"` — analysis-only task, no Jira ID, no implementation.
**Related Jira:** none.
**Workflow:** Pure readiness assessment. Expands on a chat-only answer given earlier in this session with full codebase evidence — this document is the durable, citable version.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | Is Agent Collections ready for implementing with Microsoft Copilot (GitHub Copilot)? |
| Description | User asked whether the framework can be used with GitHub Copilot today, and by extension what it would take if not. |
| Priority | n/a — informational |
| Reporter | User, this session |
| Created Date | 2026-09-05 |
| Due Date | n/a |
| Labels | framework, adapters, copilot, feasibility |
| Estimated Effort | N/A — analysis only; effort estimate for a hypothetical Copilot adapter is given in Gap Analysis |

## Business Impact

Today, three teams that already standardized on GitHub Copilot as their AI coding tool cannot adopt Agent Collections without switching tools first — the framework is explicitly Cursor/Claude Code/OpenCode-only. If Copilot were supported, the framework's addressable audience would extend to any org using GitHub's own first-party AI assistant, which is common in enterprises already invested in the GitHub ecosystem. Conversely, building and maintaining a fourth adapter is recurring cost (every core rule/prompt/skill change needs to stay in sync across one more packaging target).

---

## Gathered Information

### Knowledge Base & Task Management Tools

None — no Jira/Confluence material exists for this question; it originated in chat.

### Codebase

**Direct answer, confirmed by explicit repo text (not inferred):** No — and it's not merely unimplemented, it's actively excluded by name in three places:

- `.ai/prompts/public/eversis-create-custom-instructions.md`: *"Do not target GitHub Copilot `copilot-instructions.md` — this framework is vendor-neutral (no Copilot channel), not Cursor-only."* and *"Never instruct the user to add `.github/prompts` or Copilot — those are not part of this framework."*
- `.ai/skills/eversis-creating-instructions/SKILL.md`: *"No GitHub copilot-instructions.md in this framework."* and *"Deprecated for this repo: `.github/copilot-instructions.md` and Copilot `*.instructions.md` — do not add them here."*

**Existing adapter architecture (`docs/architecture/adapter-mapping.md`, the canonical SSOT for this question) — 3 adapters, not 4:**

| Adapter | Maturity | What it emits |
|---|---|---|
| Cursor | `shipped` | `.cursor/rules/*.mdc` (from `adapters/cursor/rule-map.yaml`), thin `.cursor/commands/*.md` |
| Claude Code | `shipped` | Root `CLAUDE.md`, `.claude/rules/*.md`, thin `.claude/commands/*.md`; installer links `.claude/skills/` |
| OpenCode | `placeholder` | A hand-maintained `opencode.jsonc` pointing at `.ai/rules/**` globs; **no generator**, no skills/prompts emit |

**Mechanical confirmation the exclusion isn't just documentation** — three places in the actual tooling hardcode the 3-adapter list, not 4:
- `adapters/sync.mjs` — `--agents` flag only accepts `cursor,claude,opencode`; generation logic is hardcoded to Cursor + Claude only (`CURSOR_GENERATE`/`CLAUDE_GENERATE` constants), OpenCode gets a static-copy-only path, no fourth branch exists
- `scripts/setup-agent-collections.sh` — `--agents` installer flag: *"Comma-separated agent adapters: cursor,claude,opencode"*
- `adapters/opencode/` itself is the **thinnest possible adapter** in this codebase (`README.md` + one `opencode.jsonc` file, no `generate.mjs`, no `rule-map.yaml`) — confirming there is no partially-built Copilot equivalent lying around unfinished; the pattern simply hasn't been started for Copilot at all

### Relevant Links

- GitHub Copilot custom instructions: `.github/copilot-instructions.md` (repo-wide) and `.github/instructions/*.instructions.md` (path-scoped via `applyTo:` glob frontmatter) — VS Code/GitHub Copilot's actual native mechanism, referenced here only to compare shape against the existing Cursor/Claude mapping, not fetched as new project content.
- GitHub Copilot reusable prompt files: `.github/prompts/*.prompt.md`, invoked via `/name` in Copilot Chat — the closest Copilot-native analog to Cursor's/Claude's thin slash-command packaging.

### Relevant Charts & Diagrams

Reused from `docs/architecture/adapter-mapping.md` §1 (Purpose and model) — the `.ai/ → adapters/{cursor,claude,opencode}` flow diagram already in that file; a hypothetical Copilot branch would slot into the same diagram as a sibling, not a redesign.

---

## Current Implementation Status

### Existing Components

- `docs/architecture/adapter-mapping.md` — the mapping spec that any new adapter must be added to (canonical SSOT, not this document) — can be reused/extended, not rewritten
- `adapters/opencode/` — the closest existing precedent for how a **placeholder**-maturity 4th adapter looks in this repo; a Copilot placeholder could follow the exact same shape (a stub directory + a materialized native config file + a maturity: placeholder status block)
- `adapters/sync.mjs`, `adapters/cursor/generate.mjs` (as a generator-shape template), `adapters/cursor/rule-map.yaml` (as a rule-mapping-shape template) — reusable patterns, not reusable as-is

### To Be Modified (only if this were greenlit — none of this is started)

- `docs/architecture/adapter-mapping.md` — add a real §7 "Copilot adapter mapping" (currently no such section exists)
- `adapters/sync.mjs` — extend `--agents` allowlist and generation branches to include `copilot`
- `scripts/setup-agent-collections.sh` — add `copilot` to the installer's `--agents` option
- `.ai/prompts/public/eversis-create-custom-instructions.md`, `.ai/skills/eversis-creating-instructions/SKILL.md` — the explicit "do not target Copilot" exclusions would need to be reversed, not just supplemented — these are current, deliberate policy statements, not stale TODOs

### To Be Created (only if greenlit)

- `adapters/copilot/` — new adapter directory (generator + a Cursor-`rule-map.yaml`-equivalent mapping file)
- `.github/copilot-instructions.md` — generated repo-wide instructions (direct analog to Claude's generated root `CLAUDE.md`)
- `.github/instructions/*.instructions.md` — generated path-scoped instructions using `applyTo:` glob frontmatter (direct analog to Claude's `.claude/rules/*.md` `paths:` frontmatter, and to Cursor's glob-scoped `.mdc` rules)
- `.github/prompts/*.prompt.md` — thin prompt pointers (direct analog to Cursor's `.cursor/commands/` / Claude's `.claude/commands/`)

---

## Gap Analysis

### Question 1
#### Is there a technical blocker, or only a policy one?

**Answer, not a question needing the user's input — stated here because it's the crux of the readiness question:** Only policy. GitHub Copilot's actual instruction mechanism (`copilot-instructions.md` for repo-wide, `*.instructions.md` with `applyTo:` globs for path-scoped, `*.prompt.md` for reusable prompts) maps cleanly onto the exact same three-tier shape (always-on / glob-scoped / attach-only) the adapter-mapping spec already uses for Cursor and Claude — this is not a novel packaging problem, it's the same pattern a third time. Skills could very plausibly resolve the same way they do for Claude Code today: GitHub Copilot Chat in VS Code supports MCP servers, so the same `eversis-collections` MCP server this framework already ships could serve skills to Copilot too, without a new skills-emit mechanism. The barrier is that the framework's own instructions currently and explicitly forbid this channel by name, in three separate files — a deliberate scope decision (likely: keep the vendor-neutral core tight, avoid maintaining a 4th packaging target) that would need to be consciously reversed, not merely "filled in."

### Question 2
#### Rough size, if this were greenlit?

Comparable to the OpenCode-placeholder-to-shipped jump implied by the existing maturity ladder in the mapping doc, not a from-scratch effort — the architecture, generator pattern, and rule-mapping shape all already exist and are documented for reuse. Realistic phased scope: (1) mapping-doc section + policy reversal in the 2 instruction-exclusion files, (2) a `placeholder`-maturity `adapters/copilot/` following the OpenCode precedent (hand-maintained `.github/copilot-instructions.md`, no generator yet), (3) only later, if adopted, a real generator + `rule-map.yaml` + `sync.mjs`/installer wiring to reach `shipped` maturity — the same three-stage path Cursor and Claude Code already walked.

## Human gates

1. ~~Approve research~~ — pending (this document)
2. n/a — analysis-only task, no plan expected unless the user decides to greenlit a Copilot adapter
3. n/a
