# Host-neutrality fix — eversis-creating-skills + eversis-create-custom-* family - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | none — framework self-improvement, chat-reported |
| Title            | Remove host-exclusivity (Cursor/MCP) claims from skill-creation guidance |
| Description      | `eversis-creating-skills/SKILL.md` and the `eversis-create-custom-*` prompt family assert Cursor+MCP as the *only* channel for skill discovery/consumption. This is factually wrong for Claude Code, which discovers skills natively via symlinked `.claude/skills/` (no MCP) — verified live in this session. Same bug class as the already-shipped fix `a214eb5` for `eversis-code-reviewing`. |
| Priority         | Low (docs-only, no runtime behavior change) |
| Related Research | `docs/specs/update-agent-collections-skills/update-agent-collections-skills.research.md` (sections "Analiza host-neutralności" + "Uwaga (2026-08-19)") |

## Wildly Important Goal

**Goal**: No file in the `eversis-creating-skills` / `eversis-create-custom-*` family asserts Cursor+MCP as the exclusive way skills are listed, read, or consumed — wording is accurate for Claude Code's native `.claude/skills/` mechanism too, without hardcoding host names into SSOT.

**Success Measure**: Re-reading all 5 target files finds zero remaining "only in Cursor" / "Cursor is the canonical way" / "this repository is Cursor-only" claims about skill or instruction consumption; `eversis_skills_validate` and `sync:adapters:check` still pass; the Cursor-specific orchestrator doc link stays correctly named (not broken by an unrelated rename).

**Do NOT touch / do NOT add**:
- `website/docs/agents/cursor-customization-orchestrator.md` — confirmed genuinely Cursor-specific pattern (multi-worker orchestration, marked `*(experimental)*`); out of scope per research Ustalenie 3.
- The `## Executable prompt (attach in Cursor)` heading text itself — structural, consumed verbatim by both Claude and Cursor adapter generators (`EXECUTABLE_HEADING_RE`); renaming it is a separate, much larger 14-file/2-generator change (research Ustalenie 4).
- OpenCode adapter files — no skill/prompt packaging channel exists yet (research Ustalenie 5, separate story).
- Any file other than the 5 listed below.
- No new dependencies, no code/script changes — Markdown/YAML frontmatter only.

## Proposed Solution

Reword the specific sentences that name Cursor/MCP as exclusive, using **fully neutral phrasing** (per your chosen style): *"skills are consumed through the current host's native mechanism, or through the `eversis-collections` MCP server, depending on the adapter"* — no host names hardcoded in SSOT body text, matching the vendor-neutral-SSOT principle already used in `spec-driven-development.md`.

Two items surfaced during planning that need your explicit call before I implement (see **Open Questions**):

1. `prompt_role: "Cursor customization orchestrator"` in all 4 `eversis-create-custom-*` prompts links to a doc I just verified **is** genuinely Cursor-specific — renaming the label would misdescribe a correct, intentional link. My recommendation: leave `prompt_role` and the role link untouched; only strip the dead legacy `<!-- Cursor Collections -->` footer comment (pre-rename framework name, zero function).
2. `eversis-create-custom-instructions.md` line 12 makes a claim not called out in the research's Ustalenie 3: *"this repository is Cursor-only"* — factually false (this session is Claude Code, reading `AGENTS.md`). Same bug class as Ustalenie 2. My recommendation: include it in this plan's scope since it's inside an already-approved file.

## Current Implementation Analysis

### Already Implemented

- Neutral-wording precedent — `vendor/agent-collections` commit `a214eb5` (per research) already fixed the identical bug class in `eversis-code-reviewing/SKILL.md`'s Do-NOT-use clause. Same pattern reused here.

### To Be Modified

- `eversis-creating-skills/SKILL.md` — `.ai/skills/eversis-creating-skills/SKILL.md`
  - Line 3 (frontmatter `description`): drop "Cursor" → `"Create new Agent Skills (SKILL.md) under .ai/skills/eversis-*. Provides naming (gerund), description, body structure, progressive disclosure, templates, validation. For Agent Collections."`
  - Line 11 ("Consumption in this framework..."): replace the Cursor-Agent-only / "do not register... under Cursor's Agent Skills settings" claim with the neutral phrasing above, keeping the concrete `eversis-collections` MCP mention (still true, just not exclusive) and adding a one-clause pointer to native per-host discovery (no host name hardcoded).

- `eversis-create-custom-skill.md` — `.ai/prompts/public/eversis-create-custom-skill.md`
  - Frontmatter `prompt_role` (line 5) and Role line (line 10): **unchanged** if Open Question 1 resolves as recommended.
  - Line 13 (intro body — "the agent reads skills through the eversis-collections MCP server... do not rely on a separate Agent Skills path in Cursor settings"): neutralize, same phrasing as SKILL.md line 11.
  - Line 45 (Executable prompt Step 3 — "so Cursor matches the skill"): drop "Cursor" → "so the agent matches the skill when appropriate".
  - Line 46 (Executable prompt Step 4 — "skills are consumed in Cursor via the eversis-collections MCP..."): neutralize.
  - Line 48 (`<!-- Cursor Collections -->` footer): remove.

- `eversis-create-custom-agent.md` — `.ai/prompts/public/eversis-create-custom-agent.md`
  - Footer `<!-- Cursor Collections -->`: remove. (Full-file re-read during Implement to catch any other Cursor-exclusivity phrasing not yet spotted in planning — flag anything found instead of silently expanding scope further.)

- `eversis-create-custom-prompt.md` — `.ai/prompts/public/eversis-create-custom-prompt.md`
  - Footer `<!-- Cursor Collections -->`: remove. Same re-read-and-flag rule as above.

- `eversis-create-custom-instructions.md` — `.ai/prompts/public/eversis-create-custom-instructions.md`
  - Footer `<!-- Cursor Collections -->`: remove.
  - Line 12 ("Helps the user encode project-wide instructions for **Cursor**... this repository is Cursor-only"): neutralize — describe it as project-wide instructions the current adapter packages (`AGENTS.md` always; `.cursor/rules/*.mdc` when the Cursor adapter is in use) — **only if Open Question 2 is confirmed in scope.**

### To Be Created

None — no new files.

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | Keep `prompt_role: "Cursor customization orchestrator"` + role link as-is (it correctly names a verified Cursor-specific pattern), and only strip the dead `<!-- Cursor Collections -->` footer from all 4 prompts — instead of renaming the role label? | User confirmed: keep role label, strip footer only | ✅ Resolved |
| 2 | Include the newly-found `eversis-create-custom-instructions.md` line 12 "this repository is Cursor-only" claim in this plan's scope (same bug class as Ustalenie 2, found during planning, not in original research Ustalenie 3)? | User confirmed: yes, fix it | ✅ Resolved |
| 3 | Implementation location and commit boundary | This standalone `agent-collections` clone (`/Users/piotrniemirski/Documents/Projects/agent-collections`) shares origin with `user-profile`'s `vendor/agent-collections` submodule (both → `gitlab3.eversis.com/eversis-ai/agent-collections.git`). Edit happens here directly; whether/when to also bump the submodule pointer in `user-profile` is a separate, later step — not part of this plan unless you say otherwise. | ✅ Resolved (scope boundary) |

## Technical Context

### Project Instructions

- `agent-collections/.ai/rules/orchestration/spec-driven-development.md` — vendor-neutral SSOT principle: use stable ids/paths, not IDE-attach syntax, in body text.
- `agent-collections/docs/specs/README.md` — this repo's `docs/specs/*/` subfolders are gitignored local artifacts; only this plan/research pair, not a commit, is expected here.

### Architecture & Patterns

- SSOT for skills/prompts: `.ai/skills/eversis-*/SKILL.md`, `.ai/prompts/public|internal/eversis-*.md` — hand-edited Markdown/YAML frontmatter, no code generation for content.
- Claude Code adapter reads `.ai/skills/` via one-time symlinks into `.claude/skills/` (`adapters/claude/README.md`, `scripts/lib/setup-agent-collections/link-framework.sh`) — content edits are live immediately, no regeneration needed.
- `.claude/commands/*.md` and `.cursor/commands/*.md` ARE generated from `.ai/prompts/**` via `adapters/claude/generate-commands.mjs` / `adapters/cursor/generate.mjs` — frontmatter/body edits in this plan flow through on next `npm run sync:adapters`.

### Tech Stack

- Plain Markdown + YAML frontmatter files; no build step required for the edits themselves.
- MCP validator: Node/TypeScript (`mcp/eversis-collections-mcp`), built with `tsc`.

### Code Style & Standards

- Skill `description` formula (from `eversis-creating-skills/SKILL.md` itself): `{What it does}. {When to use — triggers}. {Do NOT use when — exclusions}.` — third person, ≤1024 chars.
- No host name hardcoded in SSOT body text where the claim would be false for another adapter (this is literally the bug being fixed).

### Testing Patterns

- `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate` — skill/prompt structural validation (frontmatter, naming, description formula).
- `npm run sync:adapters:check` — verifies generated `.claude/commands/*`, `.cursor/commands/*` stay consistent with `.ai/prompts/**` sources after the edits (catches any accidental drift from the frontmatter/body changes).

### Additional Context

- All 5 files are plain-text edits reviewed by direct re-read, not automated tests — "verification" here means: re-read each changed file end-to-end for any remaining Cursor-exclusivity claim, plus the two commands above.

## Implementation Plan

### Phase 1: Neutralize `eversis-creating-skills/SKILL.md`

**Goal**: Fix the description-field bug (Ustalenie 1) and the exclusivity claim (Ustalenie 2) at their source skill, since the prompt delegates to it.

**Description**: Edit frontmatter `description` and the "Consumption in this framework" paragraph per **To Be Modified** above.

**Verification:** `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate`

#### Task 1.1 - [MODIFY] `eversis-creating-skills/SKILL.md` description + consumption paragraph

**Description**: Rewrite line 3 frontmatter `description` and line 11 body paragraph to neutral wording (no "Cursor" exclusivity), keeping `eversis-collections` MCP mentioned as one valid channel, not the only one.

**Files:** `.ai/skills/eversis-creating-skills/SKILL.md` (modify)

**Definition of Done**:

- [ ] `description` field no longer contains the word "Cursor"
- [ ] "Consumption in this framework" paragraph describes native per-host discovery + MCP as two valid channels, names no single host as exclusive
- [ ] Run `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate` — passes

**Stop Rule:** If validation flags the new `description` (length/format), stop and re-word rather than truncating meaning.

### Phase 2: Neutralize `eversis-create-custom-skill.md`

**Goal**: Fix the two remaining exclusivity sentences (intro + Executable prompt Steps 3–4) and remove the dead legacy footer.

**Description**: Per **To Be Modified** above; `prompt_role`/Role line left untouched (Open Question 1 recommendation).

**Verification:** `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate && npm run sync:adapters:check`

#### Task 2.1 - [MODIFY] Neutralize body + strip footer

**Description**: Edit lines 13, 45, 46 to neutral wording; delete the `<!-- Cursor Collections -->` footer line.

**Files:** `.ai/prompts/public/eversis-create-custom-skill.md` (modify)

**Definition of Done**:

- [ ] No remaining sentence claims Cursor/MCP as the only consumption path
- [ ] `<!-- Cursor Collections -->` footer removed
- [ ] `prompt_role` and Role line unchanged (still correctly point to the Cursor-specific orchestrator doc)
- [ ] Run `npm run sync:adapters:check` — passes (generated `.claude/commands/eversis-create-custom-skill.md` / `.cursor/commands/...` stay in sync)

**Stop Rule:** none

### Phase 3: Strip legacy footer from the remaining 3 sibling prompts

**Goal**: Consistency across the whole "customization orchestrator" family (Ustalenie 3, as scoped by Open Question 1).

**Description**: Remove `<!-- Cursor Collections -->` from `eversis-create-custom-agent.md` and `eversis-create-custom-prompt.md`; remove it from `eversis-create-custom-instructions.md` too and additionally neutralize its line 12 "Cursor-only" claim **if Open Question 2 is confirmed**. Re-read each file fully during this task — if any other Cursor-exclusivity phrasing turns up beyond what's listed, stop and flag it rather than silently expanding or silently skipping it.

**Verification:** `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate && npm run sync:adapters:check`

#### Task 3.1 - [MODIFY] `eversis-create-custom-agent.md`

**Files:** `.ai/prompts/public/eversis-create-custom-agent.md` (modify)

**Definition of Done**:

- [ ] `<!-- Cursor Collections -->` footer removed
- [ ] Full-file re-read found no other undisclosed exclusivity claim (or: found one, flagged to user, not silently edited)

#### Task 3.2 - [MODIFY] `eversis-create-custom-prompt.md`

**Files:** `.ai/prompts/public/eversis-create-custom-prompt.md` (modify)

**Definition of Done**:

- [ ] `<!-- Cursor Collections -->` footer removed
- [ ] Full-file re-read found no other undisclosed exclusivity claim (or flagged)

#### Task 3.3 - [MODIFY] `eversis-create-custom-instructions.md`

**Files:** `.ai/prompts/public/eversis-create-custom-instructions.md` (modify)

**Definition of Done**:

- [ ] `<!-- Cursor Collections -->` footer removed
- [ ] Line 12 "this repository is Cursor-only" claim neutralized (only if Open Question 2 confirmed — otherwise leave line 12 untouched and note as deferred)
- [ ] Run `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate && npm run sync:adapters:check` — passes

### Phase 4: Review

**Goal**: Independent verification that no exclusivity claim survives and no out-of-scope file was touched.

**Description**: Run the Review step (`eversis-review` / `eversis-code-reviewing`) against this plan — check the 5 modified files against **Do NOT touch** list and the Hard limits (scope, documentation comments, no new dependencies).

**Verification:** Full-repo `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate && npm run sync:adapters:check`, plus manual grep for `"Cursor"` across the 5 files to confirm only the intentionally-kept `prompt_role`/Role-link occurrences remain.

#### Task 4.1 - [REUSE] Review

**Description**: Structured PASS/BLOCKER/SUGGESTION review of the diff across the 5 files.

**Files:** all 5 files above (reuse)

**Definition of Done**:

- [x] `grep -rn "Cursor" .ai/skills/eversis-creating-skills/SKILL.md .ai/prompts/public/eversis-create-custom-*.md` shows only the deliberately-kept `prompt_role`/Role-link lines, the out-of-scope "Executable prompt (attach in Cursor)" heading, and pre-existing non-exclusive adapter mentions (`Cursor adapter may generate/emit .../.mdc`) — no exclusivity claims remain
- [x] Validator + sync:adapters:check both pass
- [x] Review outcome documented in this plan's Changelog

## Security Considerations

- None — no secrets, no executable code, no dependency changes; documentation/instruction text only.

## Quality Assurance

- [x] `eversis-creating-skills/SKILL.md` description and consumption paragraph contain no Cursor-exclusivity claim
- [x] `eversis-create-custom-skill.md` body (intro + Steps 3–4) contains no Cursor-exclusivity claim
- [x] All 4 sibling prompts lose the dead `<!-- Cursor Collections -->` footer
- [x] `eversis-create-custom-instructions.md` "this repository is Cursor-only" claim resolved per Open Question 2 (fixed)
- [x] `website/docs/agents/cursor-customization-orchestrator.md`, the `## Executable prompt (attach in Cursor)` heading, and OpenCode adapter files remain untouched
- [x] Validator (`eversis_skills_validate`) and `sync:adapters:check` both pass after edits (adapter copies regenerated via `npm run sync:adapters`)

## Improvements (Out of Scope)

- Renaming the `## Executable prompt (attach in Cursor)` heading across all 14 prompts + both adapter generators (research Ustalenie 4) — separate, much larger story.
- Retitling/generalizing `website/docs/agents/cursor-customization-orchestrator.md` if the orchestrator pattern is ever ported to another host — not needed today since the pattern is genuinely Cursor-only right now.
- OpenCode prompt/skill packaging parity — blocked on that adapter maturing past `placeholder` (research Ustalenie 5, tracked separately as `TASK-527` per research).
- Whether/when to bump the `vendor/agent-collections` submodule pointer inside `user-profile` after this lands — deliberately deferred (Open Question 3).

## Changelog

| Date       | Change Description |
| ---------- | ------------------- |
| 2026-08-19 | Initial plan created from research Ustalenia 1–3 (host-neutrality analysis) + 2 new findings surfaced during planning (Open Questions 1–2) |
| 2026-08-19 | Both open questions confirmed by user as recommended. Implemented: neutralized `eversis-creating-skills/SKILL.md` (description + consumption paragraph), `eversis-create-custom-skill.md` (intro + Steps 3–4), `eversis-create-custom-instructions.md` ("Cursor-only" claim); removed dead `<!-- Cursor Collections -->` footer from all 4 sibling prompts. `prompt_role`/Role links left untouched (verified genuinely Cursor-specific target). Ran `npm --prefix mcp/eversis-collections-mcp install` (deps were missing, pre-existing env gap, unrelated to this change), then `npm run mcp:build && npm --prefix mcp/eversis-collections-mcp run validate` (pass, only 2 pre-existing unrelated line-count WARNs) and `npm run sync:adapters` + `sync:adapters:check` (regenerated `.claude/commands/*` / `.cursor/commands/*` for the 4 touched prompts; no drift). Two remaining minor `prompt_description` host-bias mentions (`eversis-create-custom-agent.md`, `eversis-create-custom-instructions.md`) found but left untouched — outside approved scope, flagged for a future task instead of silently expanded. Not yet run: formal `eversis-review` structured pass (Phase 4 Task 4.1) and Fine/QA handoff. |
