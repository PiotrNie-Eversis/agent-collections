# Plan Review: ac-81-spec-folder.plan.md

**Reviewed plan:** `docs/specs/ac-81-spec-folder/ac-81-spec-folder.plan.md`  
**Research file:** `docs/specs/ac-81-spec-folder/ac-81-spec-folder.research.md`  
**Review date:** 2026-10-15  
**Verdict:** `APPROVED`

**Summary:** 0 blockers · 0 warnings · 0 suggestions

Open Questions 1 and 2 are both `✅ Resolved`. Iteration 2 re-read the revised plan only. Research was not changed. Human approval `Selected option(s) approve-plan` remains the validation start. It does not start implementation.

Iteration 1 returned `REVISIONS NEEDED` (B1, W1, W2, W3, S1). The revised plan closes each of those findings. The edit list is unchanged and still matches the ticket, the approved scaffolding inclusion, and the live stack rule.

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | No issue. Wording stays in markdown sources. The plan uses existing scripts: `sync:adapters`, `sync:website-docs`, `website:changelog:sync`, `website:changelog:check`, `installer:smoke`. No new dependency. Adapter sync does not overwrite `.cursor/rules/eversis-project-stack.mdc`. |
| Irreversible or high-cost decisions | No issue. No data model, vendor, or deploy change. The plan keeps lookup's existing-key folder rule and the installer's write-if-missing README behavior. |
| Contradictions with research or prior context | No issue. Iteration 1 B1 is closed. Lookup proof is `docs/specs/<key>/` and `hit is used` on `.ai/prompts/public/eversis-implement.md`. The plan states that `docs/specs/<key>-<topic>/` is not that proof. |
| Scope gaps and silent omissions | No issue. Iteration 1 W1 is closed. Done searches cover the executable sentence, `user-authentication` and `my-feature` without a trailing slash, the `specifications/` alternates, `{task-name}.plan-review.md`, and `plan-reviewer.md`. |
| Cross-cutting decisions that propagate | No issue. Phase 3's content search includes `.cursor/commands/eversis-plan.md` and `.claude/commands/eversis-plan.md`. Phase 4 lists the human docs and runs the content searches plus `installer:smoke`. |
| Build vs buy vs reuse | No issue. Generated prompt pages and command shims are regenerated with the existing adapters. `knowledge-entry.example.md` stays unchanged on purpose. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-10-15 | 1 | Folder token | Key-only and `<task-name>` create-paths | Use `docs/specs/<key>-<topic>/` and repeat that folder name in the file names | kept |
| 2026-10-15 | 1 | English placeholder | Polish acceptance line `<klucz>-<temat>` | English sources use `<key>-<topic>` | kept |
| 2026-10-15 | 1 | Installer heredocs | Fresh installs still write `<issue-kebab>` and `my-feature/` | Include `scaffolding.sh`; sample becomes `ac-2-context-management` | kept |
| 2026-10-15 | 1 | Lookup exception | A second folder beside an existing key-only folder | Do not edit lookup paragraphs | kept |
| 2026-10-15 | 1 | Lookup proof | Plan says `docs/specs/<key>-<topic>/` already matches in `eversis-implement.md` | That string is absent; the check must target the lookup literals that are actually there | open |
| 2026-10-15 | 2 | B1 W1 W2 W3 S1 | Lookup proof, done searches, changelog sync, review file list, example file | Lookup searches are `docs/specs/<key>/` and `hit is used`. Stale-token searches cover the executable sentence, unsuffixed `user-authentication` and `my-feature`, `specifications/` alternates, and `{task-name}.plan-review.md`. Phase 3 includes both plan command shims. Task 2.4 runs `website:changelog:sync` before the check and does not hand-edit the site page. Task 4.1 lists the human docs and Phase 4 runs the content searches plus `installer:smoke`. `knowledge-entry.example.md` stays unchanged | resolved |

## Top Failure Modes

- Iteration 1's three failure modes are closed by the revised checks. Lookup proof no longer searches for `docs/specs/<key>-<topic>/`. The executable sentence and both plan command shims are in the done searches. Task 2.4 runs the changelog writer before the check.
- No new material failure mode. A green content search now fails if the issue-id folder sentence, the alternate `specifications/` root, or `{task-name}.plan-review.md` remains.

## Unproven Assumptions

- None that block execution. The four iteration-1 assumptions are now written into the plan: lookup proof uses `docs/specs/<key>/` and `hit is used`; `user-authentication` and `my-feature` are unsuffixed; Task 2.3's search is the heredoc wording check; Task 2.4 lists `npm run website:changelog:sync` before the check.

## Most Likely Rework Triggers

- None material. The remaining out-of-scope surfaces are named on purpose: `eversis-repo-docs-writer.md`, `plan.example.md` titles, and `knowledge-entry.example.md`.

## Questions the Architect Must Answer Before Coding

None.

## BLOCKERS

No open blockers.

Iteration 1 B1 is closed. Technical Context, Phase 1 verification, and Task 1.2 require both `rg -n 'docs/specs/<key>/' .ai/prompts/public/eversis-implement.md` and `rg -n 'hit is used' .ai/prompts/public/eversis-implement.md` to match. The same task says a match on `docs/specs/<key>-<topic>/` is not the lookup proof, and that this string is absent from the file today.

## WARNINGS

No open warnings.

- W1 closed. The stale-agent-path search includes `folder named after the issue ID`, unsuffixed `user-authentication`, `specifications/<task-name>/`, `specifications/<task>/`, `specifications/{task-name-or-id}`, and `{task-name}.plan-review.md`. The human-and-installer search includes unsuffixed `my-feature`, `plan-reviewer.md`, `specifications/<task-name>/`, and `{task-name}.plan-review.md`. Phase 3 includes `.cursor/commands/eversis-plan.md` and `.claude/commands/eversis-plan.md`.
- W2 closed. Task 2.4 runs `npm run website:changelog:sync`, then `npm run website:changelog:check`, and does not hand-edit `website/src/pages/changelog.md`. Technical Context and the phase diagram state the same order.
- W3 closed. Task 4.1's file list includes `AGENTS.md`, `README.md`, both templates, `.cursor/rules/eversis-project-stack.mdc`, `docs/architecture/agents-md-standard.md`, `docs/plans/README.md`, and the four website pages. Phase 4 verification and the task checks include both content searches and `npm run installer:smoke`.

## SUGGESTIONS

No open suggestions.

Iteration 1 S1 is closed. Task 1.4 marks `knowledge-entry.example.md` reuse and says it is unchanged. The out-of-scope list names the topic-only samples `new-payment-provider` and `refactor-validation`.

## Verdict

`APPROVED`
