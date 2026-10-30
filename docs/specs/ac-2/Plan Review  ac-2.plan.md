# Plan Review: ac-2.plan.md

**Reviewed plan:** `docs/specs/ac-2/ac-2.plan.md`
**Research file:** `docs/specs/ac-2/ac-2.research.md` (`ac-2.research-2.md` as supplied)
**Review date:** 2026-09-21
**Verdict:** `REVISIONS NEEDED`

**Summary:** 5 blockers · 5 warnings · 3 suggestions

All findings below were verified against the supplied `agent-collections` source archive (`.ai/` SSOT, `mcp/eversis-collections-mcp/src/`, `docs/`, generated `CLAUDE.md`). File and line references are to that archive.

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | No issue. Markdown-only scope, zero new dependencies, `sync:adapters:check` exists and is wired (`package.json`). Read-budget diagnosis verified verbatim at `.ai/rules/orchestration/agent-core.md:36`. |
| Irreversible or high-cost decisions | **B3** — `INDEX.md` schema is load-bearing for `eversis_context_list` and silently fails on a third column. Any per-component metadata added as a column is a silent, repo-wide knowledge outage. |
| Contradictions with research or prior context | **B1** — research asserts the bootstrap mechanism does not exist ("trzeci, dziś nieistniejący mechanizm"); `.ai/skills/eversis-import-confluence-knowledge/SKILL.md` already implements the Confluence-first path including the `INDEX.md` row write. |
| Scope gaps and silent omissions | **B2** — the four-line readiness contract is asserted in 5 files; the plan modifies 2. **B4** — the `Audit` readiness line has no data source anywhere in the codebase. |
| Cross-cutting decisions that propagate | **B5** — `getContext()` resolves only `<component>/index.md`, while `eversis-import-confluence-knowledge` writes `<domena>/<temat>.md`; knowledge written by the existing seed path is unreachable through the router AC-2 is tightening. |
| Build vs buy vs reuse | **B1** — Open Question 3 evaluated only `promote` and `audit` as reuse candidates and never considered `eversis-import-confluence-knowledge`, which is the closest existing match by trigger, input, and output shape. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-09-21 | 1 | Task 2.2 — new bootstrap skill | An existing skill already covers the Confluence-first half of the design | Reduce Task 2.2 to extending `eversis-import-confluence-knowledge` with the `docs/specs/` clustering fallback | open |
| 2026-09-21 | 1 | Task 2.1 — readiness block extension | Contract is normatively closed at four lines in 5 files, not 2 | Extend the file list to all 5 assertion sites | open |
| 2026-09-21 | 1 | Task 2.1 — `Audit` line | No persistence exists for "tasks since last audit" | Defer `Audit` to the Phase 5 ticket, or add explicit persistence | open |
| 2026-09-21 | 1 | `INDEX.md` schema | Two-column parser hard limit is undocumented in the plan | Record the invariant in Technical Context | open |
| 2026-09-21 | 1 | Component file naming | `<temat>.md` files are unreachable via `eversis_context_get` | Add a Phase 1 task unifying on `index.md`, or widen the resolver | open |

## Top Failure Modes

- **Duplicate mechanism ships.** Task 2.2 creates a third domain-knowledge seeding skill overlapping an existing one, leaving two skills that both claim the Confluence-to-`docs/context/` path with no stated precedence. This is precisely the fragmentation the research diagnoses as AC-2's motivation.
- **SSOT self-contradiction ships undetected.** After Task 2.1 the framework will simultaneously mandate a six-line readiness block and assert it is exactly four lines. `npm run sync:adapters:check` compares `.ai/` against generated adapters and cannot detect semantic contradiction inside `.ai/` itself, so the repo's own verification gate passes on a broken state.
- **New signals ship inert.** `Audit` satisfies its Definition of Done by naming a skill while always emitting the same constant, adding a line of noise to every readiness block and creating false confidence that hygiene is now observable.

## Unproven Assumptions

- That the readiness block lives in exactly two files (plan, Technical Context, line 97). It is asserted in five — see B2.
- That no mechanism exists for bootstrapping domain knowledge from Confluence (research, Question 9). One exists — see B1.
- That "tasks since the last audit" is derivable. Nothing persists an audit timestamp; `eversis-audit-domain-knowledge` Step 3 already reads "since the last audit" against storage that does not exist — see B4.
- That the plan `Changelog` field is a suitable state-checkpoint target. It is a two-column `Date | Change Description` table (`plan.example.md:224-227`) with no fields for changed files, next step, or window state — see W1.
- That Task 2.1 is verifiable in this repository. `docs/context/agent-collections/` contains no `INDEX.md`, so `eversis_context_list` returns an empty array here — see W3.

## Most Likely Rework Triggers

- Code review discovering the `spec-driven-development.md`, `orchestration/README.md`, and `eversis-implement.md` four-line assertions after Task 2.1 is already merged, forcing a second pass across the readiness contract.
- An implementer following research Question 6 option 1 literally and adding an audit counter as an `INDEX.md` column, zeroing `eversis_context_list` output.
- A consumer repo running `eversis-import-confluence-knowledge` and then `eversis_context_get`, discovering imported topics are unreachable, and filing it against AC-2's router work.

## Questions the Architect Must Answer Before Coding

- Does Task 2.2 become an extension of `eversis-import-confluence-knowledge`, or does a new skill ship alongside it with an explicit precedence rule and a stated reason the existing skill was rejected?
- Is the readiness contract being reopened (four lines becomes "four required plus optional") as a deliberate, documented contract change across all five assertion sites, or is the `Context` signal moved somewhere that is not the readiness block?
- Does the `Audit` line ship with persistence, ship as an explicitly approximate heuristic, or move to the Phase 5 ticket?
- Is `<component>/index.md` the single canonical component-file path, and if so does Phase 1 include correcting `eversis-import-confluence-knowledge` to emit it?

## BLOCKERS

### B1: Task 2.2 duplicates an existing skill the plan never considered

`.ai/skills/eversis-import-confluence-knowledge/SKILL.md` already exists and already implements the design Task 2.2 proposes to create. Its own text states it "splits one Confluence AS-IS Pack page into per-topic domain-knowledge files under `docs/context/<project>/`", is "one-time, manual", carries `user-invocable: true`, and at Process Step 5 explicitly does what Task 2.2 lists as its novelty: "Add one row per new component to `docs/context/<project>/INDEX.md`".

Against the plan's Open Question 3 criteria, the overlap is near-total: identical trigger (one-time adoption event), identical primary input (an existing Confluence As-Is Pack), identical output shape (potentially many new component files plus `INDEX.md` rows at once), identical human-gate posture. The plan's Open Question 3 compared Task 2.2 only against `eversis-promote-domain-knowledge` and `eversis-audit-domain-knowledge` and concluded "New skill"; the one existing skill that actually matches was never entered into the comparison.

The genuinely missing capability is narrower than the plan states: **only the raw `docs/specs/` clustering fallback** for modules the As-Is Pack does not cover, plus the "no As-Is Pack at all" branch. That is an extension to an existing skill, not a new skill.

This finding also invalidates a load-bearing research claim. Research Question 9 states a "trzeci, dziś nieistniejący mechanizm" is required, having evaluated only `promote` and `audit`. Note that `eversis-import-confluence-knowledge`'s own principles block cites `global-domain-context-ssot.research.md` Question 1 as the source of its one-time-split design — so AC-2's research re-derived a decision DHI-630 had already made and shipped. This is the exact failure mode the research's own Business Impact section warns about ("kolejne tickety będą dalej odkrywać te same pytania od nowa").

**Action:** rewrite Task 2.2 as `[MODIFY] .ai/skills/eversis-import-confluence-knowledge/SKILL.md` adding (a) the `docs/specs/` clustering fallback for modules the As-Is Pack flags as uncovered, (b) the no-As-Is-Pack-at-all branch, (c) the `bootstrap-report.example.md` companion. If a separate skill is still preferred, the plan must record why the existing skill was rejected and state which skill takes precedence when both apply.

### B2: The four-line readiness contract is asserted in five files; Task 2.1 modifies two

The contract is not "four lines plus optional extras" — it is normatively closed, in five independent locations:

| File | Line | Assertion |
| ---- | ---- | --------- |
| `.ai/rules/orchestration/engineering-manager.md` | 13 | "output the **exact four-line** Implement readiness block" |
| `.ai/rules/orchestration/spec-driven-development.md` | 77 | "Output the **Implement readiness** four-line block first" |
| `.ai/rules/orchestration/README.md` | 26 | "Implement readiness four-line block as first content" |
| `.ai/prompts/public/eversis-implement.md` | 82 | "Output the **exact four-line** Implement readiness block" |
| `.ai/skills/eversis-orchestrating-implementation/SKILL.md` | 96 | "Include **exactly four** bullet lines: Flow, Research, Plan, Next gate — in that order." |

The plan's Technical Context (line 97) asserts the block "is duplicated verbatim in **two** files"; that is incorrect. Task 2.1 touches `engineering-manager.md` and `eversis-orchestrating-implementation/SKILL.md`, leaving three assertions of the old count in force, one of them in a public prompt that is the actual entry point for every Implement run.

Two aggravating details:

1. `eversis-orchestrating-implementation/SKILL.md:96` phrases it "**exactly four** bullet lines", not "four-line". A `grep -rn 'four-line' .ai/` — the obvious verification — **misses the strictest assertion of all**, the one that enumerates the permitted lines in order.
2. `engineering-manager.md:28` (self-check #2) enumerates permitted lines as "Flow, Research, Plan, Next gate (optional `Reason:`)". An agent applying its own self-check after Task 2.1 would reject its own correct six-line output.

`npm run sync:adapters:check` cannot catch this. It verifies `.ai/` against generated adapter output; a contradiction wholly inside `.ai/` propagates cleanly to every adapter and the check passes.

**Action:** add `spec-driven-development.md`, `orchestration/README.md`, and `prompts/public/eversis-implement.md` to Task 2.1's file list. Add to its Definition of Done: "no file under `.ai/` asserts a fixed readiness line count — verified by `grep -rniE 'four[- ]line|exactly four' .ai/` returning zero normative assertions of the old contract", and "self-check #2 in `engineering-manager.md` lists the new optional lines".

### B3: `INDEX.md` rows are parsed as exactly two columns and a third column is dropped silently

`mcp/eversis-collections-mcp/src/context.ts:114-115`:

```js
const m = line.match(/^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$/);
if (!m) continue;
```

The pattern is anchored with `$` immediately after the second column. Any row carrying a third column fails to match and is skipped by `continue` — no error, no warning, no log. The component simply ceases to exist for `eversis_context_list`, and therefore for the `Context: N components` signal Task 2.1 introduces.

Three live exposures in this plan's blast radius:

- **Task 2.1.** Research Question 6 option 1 proposes the audit counter "jako metadana w `docs/context/<project>/INDEX.md`". An implementer taking that as a column would zero the entire index — the new signal would report `0 components` as a direct result of adding the mechanism intended to detect zero components.
- **Task 2.2.** The required `bootstrap-report.example.md` must show "candidate `INDEX.md` rows". A three-column example (component / summary / source, which is the natural shape given the As-Is-Pack-versus-`docs/specs/` provenance the Definition of Done demands be visible) becomes a copy-paste trap into a real `INDEX.md`.
- **Deferred Phase 7.** The research specifies a new `as_is_pack_module` field linking component to As-Is Pack module. As a column, same silent failure.

**Action:** add to the plan's Technical Context: "`INDEX.md` rows MUST remain exactly two columns (`| component | one-line summary |`). `mcp/eversis-collections-mcp/src/context.ts:114` silently drops any row with a third column. Per-component metadata belongs in the component file's frontmatter — `upsertFrontmatterField()` (`context.ts:72`) already exists for exactly this — never as an `INDEX.md` column." Add a Definition of Done item to Task 2.2 requiring two-column example rows.

### B4: The `Audit` readiness line has no data source, and the audit skill already depends on the same missing storage

Task 2.1 requires an `Audit` line "reporting how many completed tasks have passed since `eversis-audit-domain-knowledge` last ran (or 'never')". Nothing in the codebase can produce that number.

`mcp/eversis-collections-mcp/src/context.ts` offers only:

- `touchLastConsulted()` (line 93) — writes `last_consulted` into a **component file's** frontmatter, not `INDEX.md`, and fires only from `getContext()`, which cannot fire when `INDEX.md` is empty;
- `upsertFrontmatterField()` (line 72) — a generic primitive with no audit caller;
- `computeStaleness()` (line 134) — git-subtree freshness of the **global** context directory, an unrelated metric.

`eversis-audit-domain-knowledge` is `user-invocable: true` with no orchestration trigger, so no code path exists that could stamp a run. The line will emit the constant `never` in perpetuity while satisfying its Definition of Done, whose only substantive requirement is that the line "references `eversis-audit-domain-knowledge` by name".

This exposes a pre-existing defect worth recording regardless of how AC-2 resolves it: `eversis-audit-domain-knowledge` Process Step 3 instructs the agent to "sample `docs/specs/` folders created **since the last audit**" — the skill already reads against storage that was never built.

By contrast, the `Context` line is cheap and ready: `listContext()` (line 125) returns `ContextComponent[]`, so the count is `.length` with no MCP change at all. The two halves of Task 2.1 are not comparable in cost and should not share a fate.

**Action:** choose one explicitly. (a) Add a sub-task persisting `audit_last_run` in `INDEX.md` **frontmatter** (not a column — see B3) plus an increment in `eversis-promote-domain-knowledge`; (b) define `Audit` as an explicitly approximate git-derived heuristic and say so in the Definition of Done; or (c) — recommended — drop `Audit` from Phase 2 and move it to the Phase 5 (status lifecycle) ticket, which already touches frontmatter and both skills' workflows. Option (c) keeps the valuable, zero-cost `Context` signal and stops an inert line from shipping.

### B5: Component files written by the existing import skill are unreachable through the router

`getContext()` (`context.ts:185, 198`) resolves exactly one shape:

```js
path.join(root, sel.projectContextPath, component, "index.md")
```

`eversis-promote-domain-knowledge` matches this — it writes `docs/context/<project>/<component>/index.md` (Step 3, line 53), and the plan is correct that this path needs no change.

`eversis-import-confluence-knowledge` does not. Its Process Step 4 writes `docs/context/<project>/<domena>/<temat>.md` — "one file per logical section", explicitly plural per domain. Every such file whose `<temat>` is not literally `index` is invisible to `eversis_context_get`, which throws `No docs/context entry for component "<x>"`. The `INDEX.md` rows the same skill adds at Step 5 will resolve to nothing.

This sits squarely inside AC-2's stated scope — the bounded read path from `INDEX.md` to one component file. Tightening the read budget (Task 1.1) while leaving one of the two write paths emitting unreadable filenames hardens a route that is already broken at one end. It also compounds B1: the skill Task 2.2 should be extending is the one with the non-conforming output shape.

**Action:** add a Phase 1 task resolving the granularity contract — either correct `eversis-import-confluence-knowledge` Step 4 to `<component>/index.md` (consolidating multiple Confluence sections per component, consistent with the one-line-per-component router), or widen `getContext()` to resolve additional topic files under a component directory. The first is far cheaper and preserves the router's one-row-per-component premise. Record the chosen contract in Technical Context so future skills cannot diverge again.

## WARNINGS

### W1: The plan `Changelog` is a two-column table and cannot hold a session checkpoint; no resume protocol is defined

Task 3.1 names "the plan's existing `Changelog` field" as the write target for zero-compaction state, and its Definition of Done requires "no new file or field is introduced". The actual field (`plan.example.md:224-227`) is:

```
| Date   | Change Description   |
| ------ | -------------------- |
```

Two columns, prose. The research's own recipe for what a resuming session needs (Question 5, point 3, after the Aider pattern) is a short state summary plus changed-file list plus diff — none of which has a home here. It also already carries unrelated traffic: execution rule 12 mandates recording solution changes there, and Phases 2 and 3 of `plan.example.md` require verification and review outcomes in the same table. Checkpoints will interleave with review history in one undifferentiated column.

The larger gap is that **nothing defines how a fresh session knows to resume.** The readiness contract offers `Research: SKIP | CREATE | DELTA` and `Plan: SKIP | CREATE | REFRESH` (`engineering-manager.md:18-19`); none of those values means "resume from checkpoint". A fresh session on the same ticket will find an approved plan, emit `Plan: SKIP`, and restart implementation without knowing what the previous session completed — reintroducing the lost-work failure mode Phase 3 exists to prevent, by a different route.

**Action:** either define a checkpoint sub-format within `Changelog` (and state that rule 12's entries and checkpoints are distinguishable), or add a `Resume` value to the `Flow` line. The second option is architecturally tidier and makes Tasks 2.1 and 3.1 one coherent change to the readiness contract across the same five files as B2 — worth considering, since B2 forces that contract open anyway.

### W2: `docs/context/README.md` never mentions `INDEX.md`

Task 1.2 corrects the public site page. But the in-repo README a consumer actually reads while scaffolding says only: "Internal knowledge for this project... Use clear filenames under `docs/context/<project>/`", and documents `task-baseline.md`. The word `INDEX.md` does not appear.

The directory for which AC-2 builds a mandatory router contains a README that does not know the router exists. This strengthens the research's adoption diagnosis (EOG: 0 rows after 28 closed tasks) — the failure is not only that promotion never ran, but that scaffolding never stated `INDEX.md` was required or what shape it takes.

**Action:** add Task 1.3 `[MODIFY] docs/context/README.md` — two sentences naming `INDEX.md` as the one mandatory router and its two-column format (ties to B3). Cheap, and it closes Requirement 4 ("Empty INDEX is a failure mode") at the point of first contact rather than only at read time.

### W3: Task 2.1 cannot be verified in this repository

`docs/context/agent-collections/` contains `delivery-index.md` and `task-baseline.md` and **no `INDEX.md`**. `listContext()` therefore returns `[]` here, so `Context: 0 components` is the only observable state and the `N > 0` branch of the new signal is unreachable in the repo where the change is implemented.

This is defensible in principle — `docs/context/*/` is gitignored in the framework repo (`docs/context/README.md`, "Framework repository" section) — but it means Task 2.1's Definition of Done is not actually testable as written, and the framework does not dogfood the convention it mandates.

**Action:** add to Phase 2's Verification a local, uncommitted fixture: a two-row `INDEX.md` under `docs/context/agent-collections/` used to smoke-test `eversis_context_list` and both branches of the `Context` line.

### W4: Incorrect path in Technical Context

Plan line 98 reads `.ai/rules/orchestration/eversis-orchestrating-implementation/SKILL.md`. Verified correct path: `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (as the plan itself writes at lines 61, 69, 176, 216). Skills do not live under `rules/`. Minor, but that sentence is the sole instruction locating where rule 14 is appended.

Positive confirmation alongside it: the "Execution rules and gates" list is genuinely numbered **1-13**, ending at "13. **Proceed to Fine on PASS**". Task 3.1's assumption and its `Clues` note are accurate, and its Stop Rule about renumbering is unnecessary but harmless.

### W5: No rollback path for generated adapters

Every phase runs `npm run sync:adapters` then `--check`. If Task 4.1 rejects one phase, regenerated adapter output for all phases is already in the working tree. With one `.ai/` source fanning out to Cursor rules and `CLAUDE.md`, a partial revert requires reverting `.ai/` and regenerating, not reverting the generated files.

**Action:** one line in Phase 4: "on rejection of any phase, revert the `.ai/` source for that phase and re-run `npm run sync:adapters` — never hand-edit or selectively revert generated adapter output."

## SUGGESTIONS

### S1: State the required flow explicitly

The plan spans 4 phases, 6 tasks, 5+ files and creates a new skill package. The framework's own hard exclusion routes cross-domain work or likely >3 files to Full Flow only. Worth stating in Human gates so no implementer enters via Quick and skips plan validation.

### S2: Reconsider which skill Task 2.2 should mirror

Task 2.2's `Clues` say to mirror `eversis-promote-domain-knowledge` and set `user-invocable: true`. That skill is `user-invocable: false` and runs inside the Fine turn. `eversis-import-confluence-knowledge` is already `user-invocable: true`, already one-time, already manual, already Confluence-sourced — a strictly better structural model, and per B1 the better merge target outright.

### S3: AC-2's research contradicts an assumption inside the existing import skill — carry the correction across

`eversis-import-confluence-knowledge` Process Step 6 warns that the source page "is very likely still mostly template placeholders (`{{...}}`) rather than filled-in content (confirmed pattern in `global-domain-context-ssot.research.md`, Question 1)". AC-2's research verified the opposite for EOG's live As-Is Pack: 4/6 sections complete, a ready 10-module map, 3 fully described modules, and existing manual cross-references into `docs/specs/`.

That is a genuine, useful research finding whose natural destination is the existing skill — its pessimistic assumption is now known to be project-dependent rather than universal. Folding this correction into Task 2.2 (as reframed in B1) converts a claimed gap into an evidence-backed improvement of shipped behaviour.

## What the review confirms as sound

Recorded so the revision does not disturb verified-correct decisions:

- **Task 1.1's diagnosis is exact.** `agent-core.md:36` reads: "Fall back to searching `docs/specs/`/the codebase directly only when the component has no entry yet in `INDEX.md`." All three research criticisms hold — no discovery/consumption distinction, conditioned on the common case rather than the exception, and the `1-2` budget is attached only to `related_specs`, leaving the fallback formally unbounded.
- **`eversis-promote-domain-knowledge`'s target path is correct** (`docs/context/<project>/<component>/index.md`, Step 3) and matches `getContext()`. The plan's instruction not to "fix" it is right, and the research's self-correction on this point was the correct call.
- **The audit skill is genuinely a no-op on an empty `INDEX.md`.** Process Step 1 iterates "For each `docs/context/<project>/<component>/index.md`", and the skill's own `<existing-knowledge-only>` principles block concedes it cannot detect never-promoted topics. The research's reasoning here is accurate and well-sourced.
- **Execution rules are numbered 1-13**; rule 14 is the correct next number.
- **`listContext()` returns an array**, so `Context: N components` needs no MCP change.
- **Phase 4-7 deferral is disciplined.** Task 4.1's `Clues` explicitly instruct the reviewer to check for scope creep into deferred phases — a good control, and one this review found no violations of.
- **The framework-builds-the-tool versus consumer-runs-it separation** (Task 2.2, Definition of Done item 4) is precise and correctly keeps EOG execution out of scope.

## Verdict

`REVISIONS NEEDED`

The architecture is right and the research is unusually rigorous — it self-corrects a wrong path claim and correctly separates discovery cost from consumption cost. Phases 1 and 3 address defects this review confirmed in the source.

But five blockers are defects of executability, not phrasing. Two are factual errors about the current codebase (B1: the mechanism exists; B2: the contract lives in five files, not two) that were load-bearing for the plan's task decomposition. Two are silent-failure traps in code the plan builds on (B3, B5). One would ship an inert signal that passes its own Definition of Done (B4).

Minimum revision set before approval:

1. Rewrite Task 2.2 as an extension of `eversis-import-confluence-knowledge`, or justify a separate skill and define precedence. **(B1)**
2. Extend Task 2.1 to all five readiness-contract assertion sites; make the Definition of Done grep for both "four-line" and "exactly four". **(B2)**
3. Record the two-column `INDEX.md` invariant in Technical Context and require two-column example rows. **(B3)**
4. Resolve the `Audit` line — persist it, mark it approximate, or defer it to Phase 5. **(B4)**
5. Add a Phase 1 task unifying the component-file path contract. **(B5)**
6. Fix the path at plan line 98; add Task 1.3 for `docs/context/README.md`; decide the resume protocol in Task 3.1. **(W4, W2, W1)**
