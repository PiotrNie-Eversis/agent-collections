# cursor-only-mislabel - Analysis Result

**Origin:** Surfaced as a side observation during the `ambiguous-gate-acceptance` investigation (same session) — the user asked why `eversis-orchestrating-implementation/SKILL.md`'s Step 5 is labeled `(Cursor-only)`, then asked for this to be split into its own, separate research (this file), since it's unrelated to the ambiguous-gate-acceptance ticket's subject matter.
**Related Jira:** none (framework documentation-accuracy bug).
**Related prior work:** commit `8ef063e` (2026-08-19), *"fix(prompts): remove Cursor-exclusivity claims from skill-creation guidance"* — the same bug class, in different files. This is the **third** confirmed instance of this bug class in this repo (see Gathered Information).
**Workflow:** Research drafted this session; Gap Analysis decisions locked this follow-up session (Q1 → A, Q2 → B) — awaiting human approval of this updated research before plan.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | `eversis-orchestrating-implementation/SKILL.md` labels Step 5 ("Declare Fine and produce QA comment draft") `(Cursor-only)` in three places, contradicting its own connected skill and the rest of the framework's host-neutral design |
| Description | `SKILL.md:36`, `:250`, `:264` all tag the Fine + QA-draft step `(Cursor-only)`. Nothing about that step is actually Cursor-specific — it's plain text output (a labeled draft) plus an optional Jira-post gated by Atlassian MCP availability and explicit human approval, neither of which is IDE-dependent. The label contradicts the step's own linked skill (`eversis-fine-handoff`), three orchestration rule files, and this very session's own loaded `CLAUDE.md` instructions (Claude Code), which already require this step with no Cursor scoping. |
| Priority | Low-Medium — no known incident caused by it (unlike `ambiguous-gate-acceptance`), but it is the **third** occurrence of this exact bug class in this repo's history, and a future agent in a non-Cursor adapter (Claude Code, OpenCode) could read the label literally and hedge or skip producing the mandatory QA draft |
| Reporter | User, this session, noticed while reading `SKILL.md` during an unrelated investigation |
| Created Date | 2026-08-20 |
| Due Date | n/a |
| Labels | agent-collections, documentation-accuracy, host-neutrality, orchestration |
| Estimated Effort | Small — 3 lines in 1 file; no generated/adapter files to regenerate (confirmed below), unlike the larger 14-file `8ef063e` fix |

---

## Business Impact

- **Low severity, but a real host-neutrality contract violation.** This framework explicitly promises Fine + a QA comment draft as mandatory, host-agnostic behavior (`agent-core.md`, `fine-handoff.md`, `spec-driven-development.md` all describe it with zero Cursor scoping). A literal reading of `(Cursor-only)` by a future agent session in Claude Code or OpenCode risks silently degrading that contract — skipping or hedging the QA draft specifically because the label says not to, in exactly the adapters where the framework's own rules say it's mandatory.
- **Third occurrence of a known, previously-fixed bug class.** This repo's own `CHANGELOG.md` already documents two prior fixes for false host-exclusivity claims: (1) `eversis-code-reviewing`'s discovery description lacking a host-neutral trigger clause, and (2) `eversis-creating-skills` / `eversis-create-custom-*` asserting "Cursor+MCP as the only channel" and "this repository is Cursor-only" (commit `8ef063e`, 2026-08-19 — one day before this session). A third instance in the same file family, found one day later, suggests the underlying cause (labels not audited when the framework generalized from Cursor-only to multi-adapter) may not be fully swept yet.
- **Low blast radius for this specific instance.** Unlike `ambiguous-gate-acceptance`, no concrete incident has been observed from this label — it's a documentation-accuracy bug found by inspection, not a reproduced failure.

---

## Gathered Information

### Confirmed occurrences

Exact-phrase repo-wide grep (`cursor-only|cursor-exclusive|only.{0,15}cursor|cursor.{0,10}only|this repository is cursor`, case-insensitive, across `.ai/`) found **exactly 3 matches, all in one file**:

| Location | Context |
|---|---|
| `SKILL.md:36` | Step 0's todo-list template: `- [ ] Step 5: Declare Fine and produce QA comment draft (Cursor-only)` |
| `SKILL.md:250` | Section heading: `### Step 5 - Declare Fine and produce QA comment draft (Cursor-only)` |
| `SKILL.md:264` | Connected Skills list: `` - `eversis-fine-handoff` — mandatory QA comment draft on Fine (Cursor-only) `` |

No other phrasing variant of this bug class was found in this pass — the two, previously-fixed instances documented in `CHANGELOG.md` were caught by human/agent inspection during unrelated work, not by a systematic audit, and the same is true of this third instance. A narrower "exact phrase" grep cannot rule out *differently worded* host-exclusivity claims elsewhere (see Gap Analysis).

### Origin

- Introduced in commit `e54eb1869943fd292ba31ef4303dc2ef70dac92e` (2026-08-06, *"Restructure AGENTS.md and enhance project documentation"*) — the original authoring of this `SKILL.md` file. The commit message gives no rationale for the Cursor scoping; it reads as an artifact of the label being written before the framework's multi-adapter (Claude Code / Cursor / OpenCode) design was fully carried through this file.

### Why it's contradicted — confirmed via direct reads, not inference

- `.ai/skills/eversis-fine-handoff/SKILL.md:3` (its own `description`): *"Mandatory QA comment draft after Fine (Implement handoff). Agent outputs a labeled draft; human approves or rewrites; optionally post to Jira via Atlassian MCP only after explicit human approval."* — zero Cursor scoping, and the Jira-posting sub-step is explicitly gated by **MCP availability + human approval**, not by IDE.
- `.ai/rules/orchestration/agent-core.md`: *"Declaring work Fine includes a QA comment comment draft for human review"* — described as universal lifecycle behavior, no host qualifier.
- `.ai/rules/orchestration/fine-handoff.md`: entirely host-agnostic throughout; zero Cursor mentions.
- `.ai/rules/orchestration/spec-driven-development.md`: `Fine (QA draft) | Draft is automatic with Fine; publish to tracker only with explicit human OK` — no host qualifier.
- **This session's own loaded `CLAUDE.md`** (Claude Code, embedding `agent-core.md` + `engineering-manager.md` + `fine-handoff.md`) already instructs: *"When you reach Fine, always produce the QA comment draft in the same turn"* — with no Cursor scoping — directly contradicting the label from inside the very adapter it claims to exclude.
- No technical constraint justifies the label: the QA draft is plain markdown text output (any host can produce it), and the only IDE-adjacent dependency (Atlassian MCP for posting) is available across adapters, not Cursor-specific, and is separately gated regardless.

### Prior fixes of the same bug class (this repo's own `CHANGELOG.md`, `[Unreleased] → Fixed`)

1. **`eversis-code-reviewing` discovery** — description lacked an explicit host-neutral trigger/exclusion clause, risking keyword-based routing to a host's generic review tooling instead of the framework's Review stage. Fixed by naming the trigger explicitly and adding a host-neutral exclusion clause.
2. **`eversis-creating-skills` / `eversis-create-custom-*` host-exclusivity claims** (commit `8ef063e`, 2026-08-19) — asserted "Cursor+MCP as the only way skills are listed/read/consumed" (false for Claude Code's native `.claude/skills/` discovery) and "this repository is Cursor-only" (contradicted by this repo's own `AGENTS.md` and Claude Code adapter). Fixed by rewording to name the current host's native mechanism generically, across 4 prompt files + `SKILL.md` + regenerated `.claude/commands/*` / `.cursor/commands/*`.

### Scope check: does this fix need adapter regeneration too?

No — confirmed via grep that `.ai/skills/eversis-orchestrating-implementation` content is **not** copied or embedded into any `.claude/commands/*` or `.cursor/commands/*` generated file (those are generated from `.ai/prompts/*.md` via `adapters/*/generate.mjs`, not from `.ai/skills/`). Skills are consumed live via MCP (`eversis_skills_get`) or direct file read, not compiled into slash commands. Unlike `8ef063e`'s 14-file fix, this fix is confined to the 3 lines in the one source file — no `sync:adapters` regeneration required.

### Broader sweep results (Question 2 → B, run this follow-up session)

Per the locked Q2 → B decision, ran additional passes beyond the original exact-phrase grep, looking for *differently worded* host-exclusivity claims (implicit prose assumptions, not just a `(Cursor-only)` tag) across `.ai/`:

- `grep -rniE "cursor"` across all `.ai/**/*.md` and `.mdc`, manually excluding the 3 already-known lines and skimming every remaining hit.
- Targeted follow-ups: `requires? cursor`, `cursor (is )?required`, `must (use|have) cursor`, `cursor chat`, `cursor extension`, `available only in cursor`, `works only in cursor`, `only (available|works|supported) in (cursor|claude|opencode)`.

**Result: one confirmed additional instance of the same bug class, in a different file:**

| Location | Context |
|---|---|
| `.ai/skills/eversis-technical-context-discovering/SKILL.md:23` | Discovery-progress todo template: `- [ ] Step 1: Check Cursor project instructions and rules` |
| `.ai/skills/eversis-technical-context-discovering/SKILL.md:29` | Section heading: `**Step 1: Check Cursor project instructions and rules**` |
| `.ai/skills/eversis-technical-context-discovering/SKILL.md:31` | Body: `**ALWAYS check first** for project-level guidance (Cursor):` |

Same shape as the original bug (3 lines, 1 file, a whole step mislabeled as one host's feature) but expressed as prose ("Check Cursor project instructions and rules") rather than a `(Cursor-only)` tag — confirming Q2's premise that the exact-phrase grep alone would miss variants. Contradiction is directly analogous to the original: the step's own body reads **`AGENTS.md`** at the repo root first (this repo's own `.ai/README.md:45` documents `AGENTS.md` as the host-neutral instruction surface consumed by Cursor **and** Claude Code, not a Cursor artifact) and only *then* lists `.cursor/rules/*.mdc` as one of several things to check — so the step is not actually Cursor-specific, only the label is.

**Weaker, out-of-scope candidate found but not recommended for this ticket:** `.ai/skills/eversis-creating-prompts/SKILL.md` frames its own subject as "Cursor markdown" / "Cursor prompts" throughout (title, `description` frontmatter, Step 2 body). This is a different shape of issue — the whole skill's stated purpose is narrowed to one host rather than one step/line being mislabeled inside an otherwise host-neutral document — and changing it would mean redesigning the skill's framing, not a text-label fix. Flagging it here for a human decision on whether to spin it into its own follow-up research rather than folding it into this narrowly-scoped fix.

No further instances found in this pass.

---

## Current Implementation Status

### Existing Components

- The 3 mislabeled lines (`SKILL.md:36`, `:250`, `:264`) — present, live, loaded into every `/eversis-implement` session (including this one) via `engineering-manager.md`'s reference to this skill.
- No audit rule or lint check anywhere in the framework scans for host-exclusivity language drift — both prior fixes and this one were caught by manual inspection during unrelated work, not by any systematic process.

---

## Gap Analysis

### Question 1

#### What should the fix be?

| Option | Change | Trade-off |
|---|---|---|
| **A — Remove `(Cursor-only)` from all 3 lines, no replacement text** (mirrors the `8ef063e` fix pattern: name/describe the step plainly, don't hardcode a host) | Matches the already-precedented, human-approved fix pattern from the exact same bug class one day earlier. Simplest, smallest diff. Consistent with how every other step in this same `SKILL.md` (Steps 0-4) is described — none of them carry a host qualifier. |
| **B — Replace `(Cursor-only)` with an accurate scoping note** (e.g. `(host-agnostic; Jira posting requires Atlassian MCP)`) | More explicit about the one real conditional dependency (MCP availability for the *posting* sub-step, not the draft-production step itself). Slightly more verbose; risks re-introducing a different inaccuracy if worded loosely (the draft itself has no MCP dependency, only the optional publish step does). |
| **C — Do nothing** | Rejected — the label is confirmed false against the step's own linked skill and three other rule files, and this framework has twice already treated this exact bug class as worth fixing. |

**Recommendation: A** — matches the established, human-approved precedent from `8ef063e` exactly (name the behavior plainly, don't hardcode a host), and keeps Step 5 consistent with Steps 0-4 in the same file, none of which carry a host qualifier today.

**Decision (locked this session): A.** Remove `(Cursor-only)` from all 3 lines in `eversis-orchestrating-implementation/SKILL.md` (`:36`, `:250`, `:264`), no replacement text — matching the `8ef063e` precedent and Steps 0-4's existing host-neutral phrasing.

### Question 2

#### Should this ticket also include a broader audit for other, differently-worded host-exclusivity claims elsewhere in `.ai/`, given this is the third confirmed instance of the bug class?

The exact-phrase grep run for this research (see Gathered Information) found no matches beyond the 3 known lines — but it only searched for close variants of "Cursor-only" wording, not other ways the same bug class could be expressed (e.g. "requires Cursor," "Cursor Chat," "only available in the Cursor extension," implicit assumptions in prose rather than a parenthetical tag).

| Option | Effect |
|---|---|
| **A — Scope this ticket to just the 3 confirmed lines** | Fast, minimal, matches what was actually asked ("make the separated research for **this bug**"). Leaves the possibility of further undiscovered instances unaddressed. |
| **B — Add a broader semantic sweep of `.ai/` for other host-exclusivity phrasing as part of this ticket's plan**, given this is the third instance in as many weeks | Cheap to add (a few more grep passes + spot-reads), and directly responsive to the pattern: 2 prior fixes, both reactive/manual, both found by inspection rather than a systematic check — a broader sweep now is proportionate given the recurrence rate. |

**Decision (locked this session): B.** Broader sweep added to this ticket's scope; run inline in this research follow-up (see **Broader sweep results**, above) rather than deferred to planning, since the sweep itself was cheap and its output is needed to size the plan correctly.

---

## Suggested next steps

1. ~~Human decides Question 1 and Question 2.~~ Done this session: Q1 → **A**, Q2 → **B**.
2. Write `cursor-only-mislabel.plan.md` covering:
   - The 3 original text edits in `eversis-orchestrating-implementation/SKILL.md` (`:36`, `:250`, `:264`) per Q1 → A.
   - The 3 additional text edits in `eversis-technical-context-discovering/SKILL.md` (`:23`, `:29`, `:31`) found by the Q2 → B broader sweep, using the same Option A style (plain removal / rewording, no host hardcoding).
   - A note for the human on the out-of-scope `eversis-creating-prompts` "Cursor markdown" framing candidate (see Broader sweep results) — decide whether to fold it in, split it into its own research, or leave it.
3. Per the same discipline established in `ambiguous-gate-acceptance` this same session: this research does not infer approval to plan from anything short of an explicit, unambiguous reply — the plan itself still requires a separate human gate before broad edits.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-20 | Initial research: traced the `(Cursor-only)` label on `eversis-orchestrating-implementation/SKILL.md`'s Step 5 to its origin (`e54eb18`, 2026-08-06, no stated rationale), confirmed it contradicts the step's own linked skill (`eversis-fine-handoff`) plus 3 orchestration rule files plus this session's own loaded `CLAUDE.md` instructions, and identified it as the third confirmed instance of a host-exclusivity bug class already fixed twice in this repo (`eversis-code-reviewing` discovery bug; `eversis-creating-skills`/`eversis-create-custom-*` via commit `8ef063e`, one day prior). Confirmed via grep that no adapter-generated files need regeneration for this fix (skills aren't compiled into `.claude/commands`/`.cursor/commands`). Proposed Option A (plain removal, matching the `8ef063e` precedent) for Q1; left Q2 (narrow fix vs. broader host-exclusivity sweep) open for human decision. Awaiting human decision before any plan is written. |
| 2026-08-20 (follow-up) | Human locked Gap Analysis decisions: **Q1 → A** (plain removal, no replacement text), **Q2 → B** (broader sweep added to ticket scope). Ran the broader sweep inline this session per Q2 → B: found one additional, differently-worded instance of the same bug class in `eversis-technical-context-discovering/SKILL.md` (`:23`, `:29`, `:31` — Step 1 labeled "Check Cursor project instructions and rules" though it actually reads the host-neutral `AGENTS.md` first), and flagged a weaker, out-of-scope candidate (`eversis-creating-prompts/SKILL.md`'s whole-skill "Cursor markdown" framing) for a separate human call rather than folding it into this fix. No further instances found. Updated Suggested next steps to route both confirmed fix sites into the upcoming plan. Awaiting human approval of this updated research before planning starts. |
| 2026-08-20 (implemented) | Research approved; plan written, stress-tested (2 plan-review iterations — iteration 1 caught a stale line-number citation plus an undiscovered 4th instance in `website/docs/skills/technical-context-discovery.md:28`, which the human chose to fold in), and executed. All 7 confirmed lines across 3 files fixed and code-reviewed **PASS** with 0 blockers. See `cursor-only-mislabel.plan.md` Changelog for full implementation detail. Declared Fine. |
