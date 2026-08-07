# Installer & MCP UX deltas - Implementation Plan

**Status:** Fine (2026-08-07) — Review PASS  
**Jira:** Child Story under Epic [DHI-515](https://eversis.atlassian.net/browse/DHI-515) (create on explicit human OK; do not auto-publish)  
**Research:** [`pilot-feedback-framework-deltas.research.md`](./pilot-feedback-framework-deltas.research.md)  
**Research locks:** U1 umbrella · P1.1 N/A · P2.1 Yes · Same PR · DHI-515 parent  

### Changelog (implement)

| Date | Change |
|------|--------|
| 2026-08-07 | Plan approved (OK IMPLEMENT); Phases 1–6 landed; smoke PASS |
| 2026-08-07 | `eversis-review` PASS → Fine |

## Overview

Ship installer interactive agents/profile UX, rewrite post-install **Next steps** (agent- and vendor-aware), decouple interactive MCP selection from `--build-mcp`, harden empty-home messaging, and document selection dir / Claude stack / submodule teammate flow. **One PR.** Do **not** change `area-fullstack.yaml` `charts/**` (Q2 N/A).

## Technical Context

| Item | Detail |
|------|--------|
| Entry | `scripts/setup-agent-collections.sh` + `scripts/lib/setup-agent-collections/*` |
| WIP already on disk | `agents-prompt.mjs`, `profile-prompt.mjs`; edits in `agents.sh`, `profile.sh`, `common.sh`, `summary.sh` (partial), `templates/AGENTS.template.md`; `mcp-prompt.sh` deps moved toward shared `_ensure_inquirer_prompt_deps` |
| MCP gate (current) | `_resolve_mcp_selection` in `mcp-prompt.sh` lines ~100–114 — interactive only when `ARG_BUILD_MCP=true` |
| Build semantics | `build-mcp.sh` — `--build-mcp` = force rebuild; missing `dist` still builds |
| Quality | `bash scripts/setup-agent-collections.test.sh`; spot-check interactive paths manually |
| Docs | `scripts/README.md`, `README.md`, `website/docs/getting-started/*`, `docs/architecture/install-selection.md`, `adapters/claude/README.md`, `CHANGELOG.md` |
| Skills policy | Do **not** load product UI/filter skills; optional `eversis-writing-repo-documentation` for docs phase |
| Path policy | No machine-local absolute paths in committed docs |

## In scope (map research → plan)

| Research ID | Plan phase |
|-------------|------------|
| P0.1 | Phase 1 |
| P0.2 | Phase 2 |
| P2.1 | Phase 3 |
| P2.2 | Phase 4 |
| P3.1–P3.4 | Phase 5 |
| CHANGELOG + smoke | Phase 6 |

## Out of scope

- P1.1 `charts/**` in `adapters/profiles/area-*.yaml`
- P4.x optional later
- Consumer (EOG) product trees — already handled in consumer repo
- Creating / transitioning Jira without explicit human OK

## Phases

### Phase 1 — Finish interactive agents / profile UX (P0.1)

| # | Task | Done when |
|---|------|-----------|
| 1.1 | Confirm `agents-prompt.mjs` + `profile-prompt.mjs` + `agents.sh` / `profile.sh` / `common.sh` (`_ensure_inquirer_prompt_deps`) are complete and consistent with MCP checkbox pattern | Shared dep install; Space/Enter agents; arrows/Enter profile |
| 1.2 | Non-interactive / `--agents` / `--profile` paths unchanged | Flags bypass prompts |
| 1.3 | Cancel (Ctrl+C / exit 130) → clean `die` | No half-written selection |

### Phase 2 — Rewrite Next steps (P0.2)

| # | Task | Done when |
|---|------|-----------|
| 2.1 | Rewrite `summary.sh` `print_summary` next-step list per research logic | Numbered steps, agent-aware |
| 2.2 | Cursor selected → customise `.cursor/rules/eversis-project-stack.mdc` | Shown only if `cursor` in `SELECTED_AGENTS` |
| 2.3 | Claude selected → customise `AGENTS.md` (stack / areas / skills — not Cursor `.mdc`) | Shown only if `claude` in `SELECTED_AGENTS` |
| 2.4 | Vendor `submodule`\|`copy` → mark framework path as **done / informational**; add teammate `git submodule update --init --recursive` | Not phrased as installer todo for already-vendored tree |
| 2.5 | Local → export `AGENT_COLLECTIONS_HOME=…`; clarify skills not in-repo `.ai/` | Clear local vs vendor |
| 2.6 | MCP enable / restart with path hint by mode | Present |
| 2.7 | Keep OpenCode placeholder warning if selected | Unchanged intent |
| 2.8 | Optional: align `scaffolding.sh` fallback AGENTS blurb with Claude/Cursor guidance (P3.4) | No contradiction with summary |

### Phase 3 — Decouple MCP UI from `--build-mcp` (P2.1)

| # | Task | Done when |
|---|------|-----------|
| 3.1 | Change `_resolve_mcp_selection`: interactive TTY + not `--non-interactive` + no `--mcp-servers` / pre-set ids → run interactive MCP prompt **without** requiring `ARG_BUILD_MCP` | Wizard runs on normal interactive install |
| 3.2 | Keep `--build-mcp` meaning **force rebuild** only in `maybe_build_mcp` | Docs + header comments match |
| 3.3 | Preserve defaults: non-interactive → `eversis-collections`; existing flags win | Smoke still green |
| 3.4 | Update `setup-agent-collections.sh` help / examples so `--build-mcp` is not implied as “show MCP checklist” | Help text accurate |
| 3.5 | Update `scripts/README.md` + getting-started install docs for new semantics | No “must pass `--build-mcp` to pick servers” |

### Phase 4 — Empty home / one-liner guard (P2.2)

| # | Task | Done when |
|---|------|-----------|
| 4.1 | When script is invoked via empty/`unset` home path that resolves to invalid `/scripts/...` style failure, fail early with message to set `AGENT_COLLECTIONS_HOME` or pass `--collections-home` | Clear `die` before meaningless path |
| 4.2 | Prefer documenting one-liners with `--collections-home` or `"$AGENT_COLLECTIONS_HOME/scripts/..."` after export | Examples in README / installation.md |
| 4.3 | Do not break script-root self-discovery when installer is run from a valid framework checkout | `paths.sh` script_root branch still works |

### Phase 5 — Documentation (P3)

| # | Task | Done when |
|---|------|-----------|
| 5.1 | `docs/architecture/install-selection.md` (+ short pointer from getting-started / README) — purpose of `.agent-collections/` for upgrade | T6 covered |
| 5.2 | `adapters/claude/README.md` and/or getting-started — Claude customises **`AGENTS.md`**, not `eversis-project-stack.mdc`; do not hand-edit generated `CLAUDE.md` | T8 covered |
| 5.3 | Installation / migration — teammate submodule init | T10 covered |
| 5.4 | `CHANGELOG.md` Unreleased — interactive UX, summary rewrite, MCP gate, docs | Entry present |
| 5.5 | Confirm `templates/AGENTS.template.md` local/vendor wording matches Phase 2 | Template coherent |

### Phase 6 — Validation

| # | Task | Done when |
|---|------|-----------|
| 6.1 | `bash scripts/setup-agent-collections.test.sh` | Exit 0 |
| 6.2 | Manual (or scripted) spot-check: interactive without `--build-mcp` offers MCP UI on TTY | Behavior matches Phase 3 |
| 6.3 | Spot-check summary text: cursor-only / claude-only / both × local / submodule | Matches Phase 2 matrix |
| 6.4 | `eversis-review` on the PR diff | PASS or blockers fixed |

## Delivery / PR

| Item | Decision |
|------|----------|
| PR shape | **Single PR** (Q4) — Phases 1–5 + tests |
| Jira | After plan approval: create one Story under Epic DHI-515 (explicit human OK) |
| Commit | Only when human requests |

## Risks

| Risk | Mitigation |
|------|------------|
| Interactive MCP every install slows CI/scripts | `--non-interactive` / `--mcp-servers` unchanged; smoke uses those |
| Shared inquirer deps install surprises offline users | Same pattern as existing MCP prompt; fail with clear npm message |
| Summary step numbering fragile | Build steps as ordered list in one function; agent/vendor conditionals only |
| Empty-home guard false positives | Only die when resolved home invalid; keep script_root discovery |
| Docs drift (`--build-mcp` still in examples) | Sweep README + website getting-started in Phase 3.5 / 5 |

## Acceptance criteria checklist

- [x] GIVEN interactive install without `--build-mcp` WHEN TTY and no `--mcp-servers` THEN MCP server checkbox/toggle runs
- [x] GIVEN `--build-mcp` WHEN `dist` already present THEN MCP package is rebuilt (force); WHEN flag absent and dist present THEN skip build
- [x] GIVEN `cursor` in agents WHEN summary prints THEN stack `.mdc` customise step appears; WHEN only `claude` THEN that step does not appear and `AGENTS.md` customise does
- [x] GIVEN vendorMode submodule\|copy WHEN summary prints THEN vendored path is informational + teammate submodule init note; not “you still need to vendor”
- [x] GIVEN local mode WHEN summary prints THEN `AGENT_COLLECTIONS_HOME` export + no in-repo `.ai/` expectation
- [x] GIVEN empty / wrong home invocation WHEN no valid checkout THEN clear error mentioning `--collections-home` / env
- [x] GIVEN docs WHEN Done THEN `.agent-collections`, Claude→AGENTS, submodule teammate, `--build-mcp` semantics documented + CHANGELOG
- [x] GIVEN `bash scripts/setup-agent-collections.test.sh` WHEN run THEN PASS
- [x] GIVEN area profiles WHEN Done THEN `charts/**` defaults **unchanged**
- [x] Delivery Standard: research approved → plan approved → implement → review → Fine

## Definition of done

1. Phases 1–5 implemented in agent-collections — **done**  
2. Smoke PASS — **done**; Review PASS — **done**  
3. Single PR ready (human commit/push/Jira publish as requested)  
4. Fine QA draft in same turn as Fine declaration — **this turn**  

## Human gates

1. ~~Research locks Q1–Q5~~ — done 2026-08-07  
2. ~~Approve research~~ — proceed to plan (user: OK MAKE A PLAN)  
3. ~~Approve this plan~~ — OK IMPLEMENT 2026-08-07  
4. Explicit OK to create Jira Story under DHI-515  
5. Explicit OK to commit / open PR  
6. ~~Run `eversis-review`~~ — PASS 2026-08-07 → Fine  

## Code Review Findings

**Verdict: PASS** (2026-08-07)

| Severity | Finding | Resolution |
|----------|---------|------------|
| — | No BLOCKERs | — |
| SUGGESTION | Smoke covers non-interactive only; interactive MCP/agents UI not automated | Acceptable for v1; logic reviewed; plan Phase 6.2 was spot-check |
| SUGGESTION | AC text implies submodule-init note for `copy` as well; implementation correctly shows init only for `submodule` | Prefer implementation; optional AC wording DELTA later |
| SUGGESTION | `start-here.md` still lists `--build-mcp --non-interactive` for first install | Fine for CI-style first success; interactive semantics covered in installation.md |
| NOTE | New untracked `agents-prompt.mjs` / `profile-prompt.mjs` must be included in the commit | Human commit gate |
| NOTE | No new root/package deps; reuses existing `@inquirer/prompts` under `scripts/lib/setup-agent-collections/` | STRICT FORBIDDEN deps OK |
| NOTE | `charts/**` area defaults unchanged (Q2 N/A) | Verified |

STRICT FORBIDDEN: scope OK (installer + docs + CHANGELOG + template); no silent comment stripping; no new agreed-deps violations.

## Changelog

| Date | Change |
|------|--------|
| 2026-08-07 | **CREATE** — plan from locked research (U1, P1.1 out, MCP Yes, Same PR, DHI-515) |
| 2026-08-07 | **DELTA** — implement complete; smoke PASS; awaiting review |
| 2026-08-07 | **DELTA** — eversis-review PASS; Fine |
