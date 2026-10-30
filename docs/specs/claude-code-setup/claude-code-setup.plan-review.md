# Plan Review: claude-code-setup.plan.md

| Field | Value |
|---|---|
| Reviewed plan | `docs/specs/claude-code-setup/claude-code-setup.plan.md` |
| Research file | `docs/specs/claude-code-setup/claude-code-setup.research.md` |
| Review date | 2026-08-12 |
| Iteration | 1 |
| Verdict | **APPROVED** |

**Summary counts:** 0 BLOCKERS · 2 WARNINGS · 2 SUGGESTIONS

## Challenge Domains

- **Technology and stack decisions** — No issue. Every new piece of logic (Phase A host transform, Phase C command generator, Phase E settings merge) stays on Node stdlib + bash, matching the existing zero-dependency posture of `adapters/*/generate.mjs` and `scripts/lib/setup-agent-collections/*.sh`. No new package-manager dependency proposed (hard limit respected).
- **Irreversible or high-cost decisions** — No issue. Every artifact introduced (`.mcp.json`, `.claude/commands/`, `.claude/skills/`, `.claude/settings.json`, `.claude/CLAUDE.md`) is either regenerated on next sync or explicitly seed-once/never-overwritten. No schema, vendor, or framework lock-in decision is made.
- **Contradictions with research or prior context** — No issue. All 8 Open Questions resolve to the research document's own recommended option; no silent deviation found.
- **Scope gaps and silent omissions** — No issue. Cross-checked all 11 findings (F1–F11) against the phase table: every finding has at least one owning phase (F3/F4/F9→A, F11→B, F1/F10→C, F2→D, F5/F8→E, F6→F, F7→G, F10 also partially→F for `.claude/rules/` orphan-detection).
- **Cross-cutting decisions that propagate** — **Issue found**, see WARNING-1. The `--framework-prefix` mechanism introduced in Phase B is silently relied upon by Phase C (Task C.2: "treść wskaźnika rozwiązuje ścieżkę SSOT przez frameworkPrefix") and implicitly by Phase F, but Task C.3 doesn't explicitly say the new commands generator receives `--framework-prefix` from `sync.mjs`'s CLI parsing — the plumbing is assumed, not specified as a task-boundary contract.
- **Build vs buy vs reuse** — No issue. Phase C explicitly ports (not reimplements) `discoverPromptCommands`/`extractPromptMeta`/`extractExecutableSection`/`cleanupOrphanCommands` from the existing Cursor generator; Phase D explicitly reuses `_make_symlink`/`EFFECTIVE_LINK_MODE` instead of writing new linking logic.

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
|---|---|---|---|---|---|
| 2026-08-12 | 1 | Q1–Q8 resolution | Research left 8 options open | Adopted research's recommended option for all 8, listed in plan's Open Questions table for human override | Resolved |
| 2026-08-12 | 1 | `--framework-prefix` threading to Phase C | Not explicit in Task C.3 | Flagged as WARNING-1, not a blocker — implementer must thread the same flag | Open (non-blocking) |
| 2026-08-12 | 1 | `<200` line target for `CLAUDE.md` (F6) | Research's own recommendation isn't achievable by removing only `eversis-accessibility` | Plan explicitly disclaims the threshold in Phase F description and Task F.3 DoD, moves full compression to Improvements | Resolved |

## Top Failure Modes

1. **`mcp-merge.test.sh` isolation risk (Task A.4)** — `merge_mcp_json()` depends on `mcp_pkg_dir`/`dist_index` (built MCP server output) per the existing Cursor-only path. A unit test sourcing `mcp-merge.sh` directly (mirroring `gitignore.test.sh`'s isolation style) may need a built `dist/index.js` fixture or a stub, which `gitignore.test.sh` never had to deal with. Not a plan blocker — the implementer should stub/mkdir a placeholder `dist/index.js` in the test's scratch dir rather than requiring a real `npm run mcp:build` in the test.
2. **JSON merge in Task E.2 could reorder/reformat unrelated keys** in a hand-edited `.claude/settings.json` on every `--upgrade` run (JS `JSON.parse`/`stringify` round-trip is not format-preserving). Low functional risk (JSON has no comments to lose) but could produce noisy diffs in a consumer's git history every install run. Worth a one-line note in Task E.2's implementation, not a plan change.

## Unproven Assumptions

- That `relative-path.mjs` (already used by `_make_symlink`) correctly computes a path from `TARGET_DIR` to `COLLECTIONS_HOME` across all three vendor modes (`local`, `submodule`, `copy`) for the new `--framework-prefix` use in Task B.3 — plausible since the same helper already works for Phase D's symlink target, but Phase B applies it in a new direction (root-relative CLI arg vs. per-file symlink target) and should be spot-checked in all three vendor modes during implementation, not just the one exercised by the existing smoke test (`--vendor=copy`).
- That Claude Code's frontmatter parser tolerates the marker-at-end-of-file convention identically to Cursor's (Task C.2) — reasonable given both are plain Markdown files read by the same class of tool, but not independently verified against Claude Code docs in the research (research verified `.claude/commands/` frontmatter fields, not marker placement tolerance specifically). Non-blocking: worst case is a cosmetic marker line visible in menu preview, not a functional break.

## Most Likely Rework Triggers

- If `--framework-prefix` threading (WARNING-1) is discovered mid-Phase-C to require a different CLI shape than Phase B assumed (e.g., commands generator needs a *different* relative root than rules/CLAUDE.md because `.claude/commands/*.md` pointer text vs. `.claude/rules/*.md` frontmatter might resolve paths differently) — low probability, contained to Phase C/F task bodies, not a plan-wide restructure.
- If the JSON-round-trip merge in Task E.2 turns out to reorder keys in a way a consumer team finds noisy enough to reject — contained to Task E.2, swappable for a smarter partial-write approach without touching other phases.

## Questions the Architect Must Answer Before Coding

None execution-blocking. One clarification to resolve during Phase C implementation (not before starting Phase A/B): confirm the exact CLI flag name/shape used to thread `--framework-prefix` into the new Claude commands generator so Task C.2/C.3 don't diverge from Task B.1/B.2's flag contract.

## Findings

### BLOCKERS

None.

### WARNINGS

1. **[Cross-cutting] `--framework-prefix` threading into Phase C not made explicit as a task-boundary contract.** Task C.3 says the generator is "wywołana" from `sync.mjs` but doesn't state it receives the same `--framework-prefix` CLI value established in Task B.2. *Recommendation:* when implementing C.3, reuse the exact flag/variable introduced in B.2 rather than inventing a parallel mechanism — no plan text change required, this is an implementation-fidelity note.
2. **[Failure mode] `mcp-merge.test.sh` (Task A.4) may need a built-MCP-server fixture** that `gitignore.test.sh`'s isolation pattern didn't require. *Recommendation:* stub `dist/index.js` in the test's scratch `mcp_pkg_dir` rather than depending on `npm run mcp:build` inside the unit test.

### SUGGESTIONS

1. Spot-check Task B.3's relative-path computation in `local` and `submodule` vendor modes during implementation, not only `copy` (the mode the smoke test in Task B.4 exercises).
2. Consider a short implementation-time note in Task E.2 that the JSON merge is not format-preserving (round-trip via `JSON.parse`/`stringify`) — acceptable since JSON carries no comments, but worth being deliberate about rather than surprising a consumer with reformatted `.claude/settings.json` on every install.

## Verdict

**APPROVED** — no blockers found. The plan may proceed to execution. The two warnings are implementation-fidelity notes for Phases C and A respectively, not plan revisions; address them inline while executing those tasks rather than looping back through another plan-review iteration.
