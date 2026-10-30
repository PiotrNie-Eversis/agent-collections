# promote-skill-cursor-packaging - Analysis Result

**Origin:** User report via `/eversis-implement`: *"eversis-promote-domain-knowledge - zauważyłem że ten skill jest instalowany tylko dla cursora. Brakuje go w plikach .cursor"*. **Correction from user, same session, after the first research pass below:** the report should read *"...tylko dla **claude**. Brakuje go w plikach .cursor"* — "I noticed this skill is installed only for **Claude**. It's missing from the `.cursor` files." The user then pointed to a real external consumer install (`/Users/piotrniemirski/Documents/repos/DAWIS/eog`, `vendor/agent-collections`) as evidence.
**Related Jira:** none (framework packaging/documentation question).
**Related prior work:** `docs/specs/cursor-only-mislabel/` (2026-08-20) — a confirmed, three-times-recurring bug class in this repo where text falsely scopes a host-neutral behavior to "(Cursor-only)". Turned out **not** to be the same bug class — see below.
**Workflow:** Three-pass research, same session. **Pass 1** (before the correction) checked only the two adapter *generators* and concluded — wrongly — that no skill is ever mirrored into either adapter's files. **Pass 2** (after the user pointed at a real consumer install) found the real mechanism (`.claude/skills/` symlink mirror, no Cursor equivalent, by a named "Q1" decision) and initially read it as intentional/working-as-designed. **Pass 3** (user's follow-up: *"The problem is easy to figure out with framework installation only with Cursor (without installing Claude). In this situation it is impossible to call eversis-promote-domain-knowledge"*) went back into the same real consumer install and found the actual reachability failure the user is describing: it is not just that Cursor lacks a skills mirror — **Cursor's generated SSOT pointers to `.ai/...` are never rewritten for vendored installs at all**, unlike Claude's, so the documented text fallback ("otherwise read `.ai/skills/*/SKILL.md`") resolves to a path that doesn't exist at the consumer root. Combined with no `.cursor/skills/` mirror, this leaves **MCP as the only working path for Cursor**, with no working local fallback — verified concretely below. This upgrades the finding from "asymmetric but working as designed" to "a real reachability bug for Cursor-only vendored installs." Awaiting human decision on Gap Analysis Question 1 (Pass 3 revision).

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | In a vendored, Cursor-only consumer install, `eversis-promote-domain-knowledge` (and, more broadly, every skill/prompt SSOT reference the Cursor adapter emits) has no working local fallback — MCP is the only path, and if it's unavailable, the skill is genuinely uncallable |
| Description | Two compounding, verified gaps: (1) no `.cursor/skills/` mirror exists (Claude gets `.claude/skills/`, Cursor doesn't — `link-framework.sh:212`, a named "Q1" decision); (2) **new this pass** — Cursor's generated `.cursor/commands/*.md` and `.cursor/rules/*.mdc` reference `.ai/...` paths that are never rewritten for vendored installs, unlike Claude's equivalent files. `adapters/sync.mjs --help` (line 114) states `--framework-prefix` is "pass through to the **Claude generator only**." Verified in `DAWIS/eog`: `.claude/commands/eversis-implement.md` correctly says `SSOT: vendor/agent-collections/.ai/prompts/public/eversis-implement.md`; the Cursor equivalent, `.cursor/commands/eversis-implement.md`, says `SSOT: .ai/prompts/public/eversis-implement.md` — a path that does not exist at that repo's root (confirmed: no top-level `.ai/` there, only under `vendor/agent-collections/.ai/`). The same unprefixed-`.ai/skills/` pattern repeats in every `.cursor/rules/*.mdc` file's skill references. Net effect: in this install, a Cursor agent's only *working* path to any skill or prompt SSOT is the `eversis-collections` MCP server — every textual local-file fallback the framework documents is broken for Cursor specifically. |
| Priority | Medium — not a total outage (MCP does work when configured and running, as it is in the `DAWIS/eog` example), but removes the redundancy Claude gets, and the *specific* skill named in the report (`eversis-promote-domain-knowledge`) has no user-invocable command at all to fall back on if MCP hiccups — Claude has 3 layers of redundancy (MCP, prefix-corrected text fallback, real `.claude/skills/` symlink); Cursor has exactly 1 (MCP) |
| Reporter | User, this session (corrected mid-investigation: "cursor" → "claude" in the original phrasing; then supplied the concrete failure mode: Cursor-only install ⇒ cannot call this skill) |
| Created Date | 2026-09-09 |
| Due Date | n/a |
| Labels | agent-collections, skills-packaging, cursor-adapter, claude-adapter, installer, vendored-install |
| Estimated Effort | Root-cause fix (extend `--framework-prefix`-style rewriting to the Cursor generator, matching Claude's) is a moderate, well-scoped change — same shape as work `adapters/claude/generate.mjs`/`generate-commands.mjs` already do, applied to `adapters/cursor/generate.mjs`. A `.cursor/skills/` mirror (matching `_link_claude_skills`) is a separate, additive follow-up, not required to fix the reachability bug itself since MCP + a *correct* text fallback would already restore parity with Claude's non-mirror layers. |

---

## Business Impact

- **This is now a reachability bug, not just an asymmetry.** The "Q1 — no `.cursor/skills/` mirror" decision (Pass 2) is defensible *on its own* — MCP was meant to be the Cursor-side equivalent. But Pass 3 found that the framework's own documented backup plan for when MCP isn't available ("otherwise read `.ai/skills/*/SKILL.md`", in `AGENTS.md` and every `.cursor/rules/*.mdc` that mentions a skill) is **silently broken for any vendored (submodule/copy) Cursor install**, because the Cursor generator never rewrites `.ai/...` references the way the Claude generator does. So the "Q1" decision's implicit assumption — that MCP-or-local-file is a reasonable pair of options for Cursor, same as for Claude — doesn't actually hold: Cursor only ever really has the MCP option in a vendored install.
- **Concretely reproduces the user's claim.** "Impossible to call `eversis-promote-domain-knowledge` in a Cursor-only install" is accurate for the case where MCP isn't configured/running (a real, ordinary failure mode — the `eversis-collections` MCP server in `DAWIS/eog` runs via `docker compose run`, which fails outright if Docker isn't running). In that state: no `.cursor/skills/` entry, and the text fallback points at a non-existent path — there is no third option.
- **Broader than just this one skill.** The same broken-path pattern affects every `.cursor/commands/*.md` (all prompts, not just this skill) and every `.cursor/rules/*.mdc` mention of `.ai/skills/`. This skill (`eversis-promote-domain-knowledge`) is a particularly sharp instance because it's `user-invocable: false` — it has no `.cursor/commands/*.md` entry at all to fall back on the way a directly-invocable prompt like `/eversis-implement` does — so for this specific skill, MCP genuinely is the *only* path, broken fallback or not.
- **Not the `cursor-only-mislabel` bug class.** That class is a false *label* claiming something is Cursor-exclusive when it isn't. This is a real functional gap in the Cursor adapter's vendored-path handling — different bug shape entirely.

---

## Gathered Information

### Pass 2 (verified, current understanding) — the real mechanism

Pass 1 (below) only read the two adapter *generators* (`adapters/cursor/generate.mjs`, `adapters/claude/generate.mjs`), which indeed never touch `.ai/skills/`. What Pass 1 missed: skill materialisation for Claude Code happens in a **third place**, the installer itself, not either generator.

Verified two ways this session:

1. **Direct filesystem evidence from a real consumer install**, pointed to by the user: `/Users/piotrniemirski/Documents/repos/DAWIS/eog` (a `vendorMode: submodule`\-style install with `vendor/agent-collections/`).
   - `.claude/skills/` contains ~60 real entries, one per framework skill (`eversis-promote-domain-knowledge` included), each a **symlink**: `.claude/skills/eversis-promote-domain-knowledge -> ../../vendor/agent-collections/.ai/skills/eversis-promote-domain-knowledge`.
   - `.cursor/` contains only `commands/`, `rules/`, `mcp.json` — **no `skills/` directory at all**, confirmed with `ls -la`.
   - The vendored copy at `vendor/agent-collections/.cursor/` and `vendor/agent-collections/.claude/` (the framework's own tree as vendored, before consumer-side linking) also has no `skills/` under either — consistent with skills being linked at install time into the *consumer's* root `.claude/skills/`, not shipped pre-populated inside the vendored framework copy.

2. **Source of the mechanism**, read in full this session: `scripts/lib/setup-agent-collections/link-framework.sh`.
   - `_link_claude_skills()` (lines 132-176): when `claude` is in `--agents`, for every `.ai/skills/eversis-*` directory, creates `<target>/.claude/skills/<name>` as a symlink (`EFFECTIVE_LINK_MODE=symlink`, the default on non-Windows) or a full copy (Windows / explicit `--link-mode copy`). Also prunes stale entries whose source skill no longer exists, and (via `_prune_deselected_agents`, lines 60-75) removes all framework-owned entries from `.claude/skills/` if Claude is later deselected.
   - `link_framework_files()` (the orchestrator, lines 198-223) calls `_run_adapter_sync` (the two generators, for rules/commands) and then **separately** calls `_link_claude_skills`. Immediately above that call chain, an explicit comment states the design decision in so many words: **`# Q1: do NOT mirror .cursor/skills|prompts|commands — skills via MCP + .ai/`** (line 212).
   - This confirms, in the installer's own words, that the Cursor-side omission is a **named, deliberate decision** ("Q1"), not an oversight or drift — consistent with `website/docs/reference/skills/overview.md:8`'s "this repo does not ship a full `.cursor/skills/` mirror," which is accurate for Cursor specifically but (see Business Impact) doesn't mention that Claude *does* get one.
   - Git history corroborates this was a conscious removal, not something that was never built: commit `3047412` (2026-08-06, "Enhance adapter synchronization and agent selection functionality" / "Complete Wave C self-contained distribution: drop sibling cursor-collections symlinks") shows `.cursor/skills` (along with `.cursor/commands` and `.cursor/prompts`) being **removed** from this framework repo's own self-hosted tree in the same commit that introduced the `--agents` selection feature — i.e., a `.cursor/skills` symlink existed at some point and was deliberately dropped as part of consolidating to the current design.

**Why this repo's own self-host (`agent-collections` itself) doesn't show a `.claude/skills/` mirror:** `_link_claude_skills()` links from `${COLLECTIONS_HOME}/.ai/skills` into `${TARGET_DIR}/.claude/skills`; for a normal consumer install those are different directories (vendor copy → consumer root), but for this repo's own self-host `COLLECTIONS_HOME == TARGET_DIR` (see `_resolve_framework_prefix`'s comment, `link-framework.sh:106-113`) — linking `.ai/skills/X` to `.claude/skills/X` in the same tree would be a same-directory no-op / self-referential symlink, so this repo's own `.claude/` (confirmed earlier: only `settings.json`, `settings.local.json`, `rules/`, `commands/`) never gets one, which is why Pass 1's direct inspection of *this* repo alone missed the mechanism entirely. The mechanism is real, but only observable in an actual consumer install — exactly what the user's example surfaced.

### Pass 1 (superseded) — what the adapter generators alone showed

Two adapter generators exist, `adapters/cursor/generate.mjs` and `adapters/claude/generate.mjs` (+ `adapters/claude/generate-commands.mjs`). Read both in full this session. Neither one touches `.ai/skills/` at all:

- **Rules** (`.ai/rules/**/*.md`) → `adapters/*/rule-map.yaml` drives generation of `.cursor/rules/*.mdc` and (for Claude) inlined sections in `CLAUDE.md` (+ `.claude/rules/*.md` for glob-scoped, non-alwaysApply rules like `eversis-accessibility`).
- **Prompts** (`.ai/prompts/{public,internal}/eversis-*.md`) → auto-discovered into `.cursor/commands/*.md` and `.claude/commands/*.md`.
- **Skills** (`.ai/skills/eversis-*/SKILL.md`) → **not referenced by either generator, at all.** Confirmed by `rg -n "skills" adapters/claude/*.mjs adapters/cursor/*.mjs`: the only hit is a doc string in `adapters/claude/generate.mjs` telling the agent to resolve skills via MCP or by reading `.ai/skills/<id>/SKILL.md` directly — not a packaging step.

This is corroborated by explicit, already-written documentation:

- `website/docs/reference/skills/overview.md:8` — *"Skills are stored under `.ai/skills/` (SSOT — consumed directly by hosts that read files, such as Claude Code; also available through adapters). In Cursor Agent, use them through the `eversis-collections` MCP server ... do not register the folder separately as Cursor **Agent Skills** for this framework — this repo does not ship a full `.cursor/skills/` mirror."*
- This repo's own loaded `CLAUDE.md` (`agent-core.md` § Skills discovery, point 5): *"Skill packages belong under `.ai/skills/eversis-<topic>/`. Do **not** register the skills folder as a vendor-specific 'Agent Skills' UI path unless the adapter docs say so."*

Both statements say the same thing from two different adapters' perspectives: **no skill, for either host, is mirrored as files into `.cursor/` or `.claude/`.** Access is uniformly via the `eversis-collections` MCP server (`eversis_skills_list` / `eversis_skills_get`) or, for hosts that read files directly (this session, Claude Code), a direct read of `.ai/skills/<id>/SKILL.md`.

### Checked whether `eversis-promote-domain-knowledge` specifically is treated differently from its sibling skills

It is not, on every axis checked:

- **Directory presence:** `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` exists (added in commit `81f1cd5`, 2026-08-25, alongside `eversis-audit-domain-knowledge` and `eversis-import-confluence-knowledge` — the other two domain-context skills).
- **`user-invocable` frontmatter:** `false` — same value as 10 other internal, EM-orchestrated skills (`eversis-orchestrating-implementation`, `eversis-fine-handoff`'s siblings, `eversis-planning-tests`, etc.). This is why it does not appear in this session's Claude Code `Skill` tool listing — that listing is populated from `.ai/prompts/*` → `.claude/commands/*`, and `user-invocable: false` skills correctly have no such prompt/command. `eversis-audit-domain-knowledge` and `eversis-import-confluence-knowledge` are `user-invocable: true` and *do* have corresponding entries — this is an intentional, per-skill distinction (whether a human directly invokes it vs. the EM invoking it internally at Fine), not a host-availability distinction.
- **No "(Cursor-only)" or equivalent host-exclusivity language anywhere in or near this skill.** Ran the same class of check that found the 3 confirmed instances in `cursor-only-mislabel` (`rg -ni "cursor"`) against: `.ai/skills/eversis-promote-domain-knowledge/SKILL.md`, `.ai/rules/orchestration/fine-handoff.md`, `.ai/skills/eversis-orchestrating-implementation/SKILL.md`, `.ai/skills/eversis-fine-handoff/SKILL.md`, `website/docs/reference/skills/promote-domain-knowledge.md`, `website/docs/reference/domain-context.md`, `docs/architecture/install-selection.md`. Zero matches in the first four files; the two doc-site hits are unrelated (installer `--agents=cursor,claude` example, and a note about `.claude/`/`.cursor/` root-file vendoring in general — nothing scoping this specific skill to Cursor).
- **MCP server code has no host/client-based filtering.** Checked `mcp/eversis-collections-mcp/src/skills.ts` and `skillScripts.ts` directly (`rg -ni "cursor|host|client"` → zero hits). `eversis_skills_list`/`eversis_skills_get` serve identical content regardless of which MCP client calls them.
- **The commit that introduced this skill (`81f1cd5`) updated both adapters' generated output in the same commit**, for the two *rule* files it touched (`agent-core.md`, `fine-handoff.md`, which both gained a short reference to the new skill): `CLAUDE.md` (+16 lines) **and** `.cursor/rules/eversis-agent-core.mdc` (+6) **and** `.cursor/rules/eversis-fine-handoff.mdc` (+10) were all regenerated together. There is no adapter-specific gap in that commit either.

### Pass 3 (root cause of "impossible to call") — Cursor's SSOT pointers are never vendor-path-corrected

Triggered by the user's follow-up pinpointing the actual failure: a Cursor-only, vendored install genuinely cannot reach this skill's content through any local mechanism. Verified directly in `DAWIS/eog` (a `vendor/agent-collections/` submodule/copy install):

1. **Command SSOT pointers — compared side by side, same install, same prompt:**
   - `.claude/commands/eversis-implement.md:12` → `**SSOT:** \`vendor/agent-collections/.ai/prompts/public/eversis-implement.md\`` — **correct**, resolves.
   - `.cursor/commands/eversis-implement.md:7` → `**SSOT:** \`.ai/prompts/public/eversis-implement.md\`` — **wrong**, this path does not exist at the repo root (confirmed: top-level `find` on `DAWIS/eog` shows no `.ai/`, only `vendor/agent-collections/.ai/`). Every one of the ~30 generated `.cursor/commands/*.md` files carries the same unprefixed pattern (confirmed via `adapters/cursor/generate.mjs`'s `buildCommandContent()`, which writes `prompt.sourceRel` — a bare repo-relative string like `.ai/prompts/public/<id>.md` — with no prefix parameter anywhere in the function or its caller).

2. **Rule-file skill references — same unprefixed pattern:**
   - `.cursor/rules/eversis-agent-core.mdc:56`, `eversis-fine-handoff.mdc:16`, `eversis-engineering-manager.mdc:14`, `eversis-code-reviewer.mdc:15` — all reference `` `.ai/skills/` `` bare, with no vendor prefix. (Some soften this with "or via MCP" / "adapter-resolved path" alongside, but the literal path given as the direct-read option is wrong for this install.)
   - The consumer's own `AGENTS.md:10` template text is aware of the problem in general terms — *"Submodule / copy mode: SSOT may live under `vendor/agent-collections/.ai/` — still prefer MCP for skills"* — but this is a hint to prefer MCP, not a corrected path, and it doesn't change what the `.cursor/rules/*.mdc` files themselves say.

3. **Root cause, confirmed in the generator/orchestrator code itself:**
   - `adapters/sync.mjs`'s own `--help` text (line 114): *"`--framework-prefix`: pass through to the **Claude generator only** — prepends `<path>` to `.ai/...` references in CLAUDE.md's How-to section for vendored consumer installs (empty = self-host, unprefixed)."* — stated in the tool's own usage text as Claude-exclusive.
   - `adapters/cursor/generate.mjs` (read in full, both passes): accepts only `--out` and `--help`; there is no `--framework-prefix` (or equivalent) argument anywhere in the file, and no prefix logic in `buildFrontMatter`, `writeRule`, `buildCommandContent`, or `writeCommand`.
   - Net effect: for **any** vendored (non-self-host) install, Cursor's generated files are only ever correct when read from a checkout where `.ai/` sits at the repo root — i.e., only for this framework's own self-host. Every real consumer install with `vendorMode: submodule` or `copy` gets Cursor files with dangling `.ai/...` references, while getting Claude files with correct, prefix-rewritten ones.

4. **Compounding factor specific to `eversis-promote-domain-knowledge`:** because it's `user-invocable: false`, it has no `.cursor/commands/*.md` entry at all (those are generated only from `.ai/prompts/*`, and this is a skill, not a prompt) — so there's no slash-command surface to fall back on either. For this specific skill, in a Cursor-only vendored install: `.cursor/skills/` doesn't exist (Pass 2), the rule-file text fallback points at a dangling path (Pass 3, point 2), and no command exists — leaving **only** the MCP tool call as a working path. If MCP is down, misconfigured, or (as for many teams) simply not yet wired into that session, the skill is unreachable exactly as reported.

### Still open

- **Whether the same unprefixed-path problem also affects `opencode`'s adapter output** — out of scope for this pass (report was Cursor-specific), not checked.
- **Whether Cursor has (or has gained) a native skill-folder discovery feature** analogous to Claude Code's `.claude/skills/`. Less central now than in Pass 2 — even without one, correcting the path prefix (Pass 3 fix) restores Cursor to parity with Claude's *text-fallback* layer; a real `.cursor/skills/` mirror would still be a nice-to-have third layer (matching Claude's belt-and-suspenders), not the blocking fix.

---

## Current Implementation Status

### Existing Components

- `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` — SSOT, present, `user-invocable: false` (EM-orchestrated, not directly human-invoked).
- `scripts/lib/setup-agent-collections/link-framework.sh` `_link_claude_skills()` — installer step that symlinks/copies every `.ai/skills/eversis-*` into a consumer's `.claude/skills/` when Claude is a selected agent. Working as designed; handles add/remove/deselect correctly (stale-entry pruning, `_prune_deselected_agents`).
- No equivalent function exists for Cursor. `link_framework_files()` line 212 names this as a deliberate decision ("Q1").
- `website/docs/reference/skills/overview.md:8` and `agent-core.md` § Skills discovery both describe the Cursor/MCP side accurately but don't mention the Claude-side `.claude/skills/` mirror exists — the accurate-but-incomplete picture that likely produced the original report.

---

## Gap Analysis

### Question 1 (Pass 3 revision — root cause confirmed)

#### Fix scope: how far should this ticket go to restore Cursor-side reachability?

| Option | Change | Effect |
|---|---|---|
| **A — Root-cause fix only:** extend vendored-path rewriting to the Cursor generator, matching what `--framework-prefix` already does for Claude. Concretely: give `adapters/cursor/generate.mjs` the same `--framework-prefix`-style parameter, applied to (a) `prompt.sourceRel` in `buildCommandContent()` (fixes every `.cursor/commands/*.md` SSOT line) and (b) wherever `.ai/skills/` / `.ai/rules/` literal paths are emitted in rule bodies sourced from `.ai/rules/**`. `adapters/sync.mjs` would need to stop scoping `--framework-prefix` to "Claude generator only" and pass it to both. | Restores Cursor to the same two-layer redundancy Claude has *without* the mirror (MCP + a working text fallback). Directly fixes the reported "impossible to call" failure mode (MCP down ⇒ agent can still find and read the real vendored path). Moderate, well-scoped change — mirrors work the Claude adapter already does. |
| **B — Root-cause fix + a `.cursor/skills/` mirror**, adding `_link_cursor_skills()` to `link-framework.sh` (parallel to `_link_claude_skills()`) so Cursor gets the same third, most-robust layer (a real local file, immune to any path-prefix logic entirely) that Claude has | Full parity with Claude's redundancy (MCP + corrected text fallback + real local mirror). Larger scope: new install-script function + `.gitignore`/pruning rules + installer test coverage (`setup-agent-collections.test.sh`), and only pays off if something can actually read `.cursor/skills/*` (Cursor's own agent, at minimum, can `Read` an arbitrary file at a known path even without "native discovery UI" — unlike Pass 2's framing, this doesn't require Cursor to have a special skills-UI feature, since the point here is just a locatable fallback file, not discovery/autoload). |
| **C — Docs-only, no behavior change:** just document that Cursor's local fallback is currently broken in vendored installs and MCP is the only reliable path today | Fastest, but leaves the actual reachability gap unfixed — not recommended now that a concrete, reproducible failure (not just an asymmetry) is confirmed. |
| **D — Close as acceptable risk**, on the reasoning that MCP is expected to be configured for any real install and this is a low-probability edge case | Not recommended — the report itself is evidence this isn't hypothetical (Docker-dependent MCP servers do go down; a "Cursor-only" install by definition may never wire up Claude's redundant path), and the fix (A) is small relative to the failure mode it closes. |

**Recommendation: A now, B as a fast-follow.** A is the actual bug fix — it's what makes the documented fallback true again, for every skill and prompt, not just this one. B adds genuine extra robustness (matching Claude's belt-and-suspenders) but is additive and can land separately without leaving anything broken in the meantime, since A alone already restores a working local path.

**Decision (locked):** **A+B** — `"Q1. A+B;"`. Plan written: [`promote-skill-cursor-packaging.plan.md`](./promote-skill-cursor-packaging.plan.md).

---

## Suggested next steps

1. Human answers Gap Analysis Question 1 — confirm fix scope (**A** root-cause path fix alone, or **A+B** with the added `.cursor/skills/` mirror).
2. Write `promote-skill-cursor-packaging.plan.md` covering, per the confirmed scope:
   - **A (always, if any code fix is approved):** add prefix support to `adapters/cursor/generate.mjs` (new parameter, threaded into `buildCommandContent()`'s SSOT line and rule-body path references), update `adapters/sync.mjs` to pass `--framework-prefix` to both generators (drop the "Claude generator only" restriction), verify against `--check` drift mode, and re-verify by hand against a vendored fixture (or ask to re-check the `DAWIS/eog` example post-fix).
   - **B (if scoped in):** `_link_cursor_skills()` in `link-framework.sh`, parallel to `_link_claude_skills()`; wire into `link_framework_files()`; extend `_prune_deselected_agents` for the Cursor case; add coverage in `setup-agent-collections.test.sh`.
   - Doc touch-up either way: `website/docs/reference/skills/overview.md:8` / `agent-core.md` § Skills discovery should end up describing the corrected, current state (accurate fallback path + whichever mirror layers exist) rather than the pre-fix picture.
3. Note for the human: this is larger in scope than a typical `*.plan.md` for this repo (touches 2 generator scripts + the installer + possibly a new install-script function) — likely warrants the full Research→Plan→Implement→Review cycle rather than Quick Flow, given it changes generated-file content for every consumer install going forward.

---

## Changelog

| Date | Change |
|---|---|
| 2026-09-09 (Pass 1, superseded) | Verified the user's original report ("`eversis-promote-domain-knowledge` installed only for Cursor, missing from `.cursor` files") against both adapter generators only (`adapters/cursor/generate.mjs`, `adapters/claude/generate.mjs`) and the MCP skill-serving code. Concluded — incorrectly, as it turned out — that no skill is ever mirrored into any adapter's files for any host, since neither generator touches `.ai/skills/`. This conclusion missed a third mechanism (the installer's own linking step) that lives outside both generators. |
| 2026-09-09 (Pass 2) | User corrected the report ("cursor" → "claude" in "installed only for X") and pointed at a real consumer install (`DAWIS/eog`, `vendor/agent-collections`) as evidence. Direct inspection of that install's `.claude/skills/` (symlinks to `vendor/agent-collections/.ai/skills/*`, `eversis-promote-domain-knowledge` included) and `.cursor/` (no `skills/` at all) confirmed the corrected report. Traced the mechanism to `link-framework.sh`'s `_link_claude_skills()`, and initially read the Cursor-side omission as a named, deliberate, working-as-designed decision (`# Q1`, line 212). Recommended Option D (doc-only fix + revisit Q1 later) — later superseded by Pass 3. |
| 2026-09-09 (Pass 3, current) | User's follow-up narrowed the claim to the actual failure: in a Cursor-only vendored install, `eversis-promote-domain-knowledge` is genuinely uncallable. Re-inspected `DAWIS/eog` and found the deeper root cause: Cursor's generated `.cursor/commands/*.md` and `.cursor/rules/*.mdc` reference `.ai/...` paths that are **never vendor-path-corrected**, unlike Claude's (`adapters/sync.mjs --help`: `--framework-prefix` is explicitly "pass through to the Claude generator only"; confirmed no such logic anywhere in `adapters/cursor/generate.mjs`). Side-by-side proof: `.claude/commands/eversis-implement.md` correctly resolves to `vendor/agent-collections/.ai/prompts/public/eversis-implement.md`; `.cursor/commands/eversis-implement.md` points at the non-existent `.ai/prompts/public/eversis-implement.md`. Combined with Pass 2's confirmed lack of a `.cursor/skills/` mirror, and this skill's lack of any `.cursor/commands/*.md` entry (it's `user-invocable: false`), MCP is the *only* working path for Cursor to reach this skill in such an install — exactly reproducing the report. Reclassified from "intentional asymmetry" to "real reachability bug." Revised Gap Analysis: recommend Option A (extend framework-prefix rewriting to the Cursor generator — the actual root-cause fix) now, with a `.cursor/skills/` mirror (Option B) as an optional, additive fast-follow for full parity. Awaiting human confirmation of fix scope before writing a plan. |
