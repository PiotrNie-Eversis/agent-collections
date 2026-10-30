# Plan Review: ac-2.research.md (portfolio AC-2)

**Reviewed artifact:** `docs/specs/ac-2/ac-2.research.md`, Question 18 (AC-20), against the tree after the other AC-2 children.  
**Not reviewed again:** `docs/specs/ac-2/ac-2.plan.md` and its `ac-2.plan-review.md`.  
**Research file:** `docs/specs/ac-2/ac-2.research.md`  
**Review date:** 2026-09-22  
**Verdict:** `REVISIONS NEEDED`

**Summary:** 1 blocker · 1 warning · 0 suggestions

Iteration 2. The reporter closed every AC-2 child except AC-20. The tree matches that for AC-16, AC-17, AC-18, AC-19, and AC-22. There is still no `docs/specs/ac-20/*.plan.md`, so this pass cannot approve an implementation plan. It stress-tests Question 18 as the only remaining brief. Fewer than five findings: the sibling tickets are no longer open coordination problems. What is left is one stale brief.

| Klucz | W drzewie po tej iteracji | Skutek dla AC-20 |
| --- | --- | --- |
| AC-16 | `docs/decisions/` plus odczyt w `agent-core.md` | Opisać jako dziś. Question 18 mówi „jeszcze nie” |
| AC-17 | Trzeci draft w `eversis-fine-handoff` i na `overview.md` | Opisać jako dziś, z odsyłaczem. Question 18 mówi „jeszcze nie” |
| AC-18 | `status: approved` przy zapisie, licznik audytu, `deprecated` / `superseded` w skillu audytu | Opisać jako dziś, bez receptury frontmatter. Question 18 mówi „jeszcze nie” |
| AC-19 | Reguła 14 bez licznika 5–10 | Jedno zdanie o checkpointcie bez liczby wymian. Licznik nie jest już luką |
| AC-22 | Skill `eversis-add-domain-knowledge` i akapit na `domain-context.md` | Nie ruszać tej sekcji |
| AC-21 | Pod AC-14, poza parentem | Poza AC-20 |
| Faza 6 | Brak ticketu, brak kodu | Jedyna pozycja, która zostaje „jeszcze nie” |

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | No issue. AC-20 zostaje przy stronach Docusaurus. Nowych zależności nie ma. SQL nie dotyczy. |
| Irreversible or high-cost decisions | No issue for the closed children. Their homes stay. Issue only if AC-20 documents `docs/decisions/` as future work and a later reader treats the page as the contract. That is B1. |
| Contradictions with research or prior context | Issue. Question 18 was written while AC-16, AC-17, and AC-18 were still backlog. The reporter has since closed them and the tree matches. The brief does not. |
| Scope gaps and silent omissions | Issue. Criterion 3 of AC-20 (generated prompt page) is already true. The hand-authored readiness sentences are not. The brief still assigns both to the same unchecked task. |
| Cross-cutting decisions that propagate | No issue on shared edits with open siblings. AC-22 and AC-17 already wrote their pages. AC-20 must leave those paragraphs in place. |
| Build vs buy vs reuse | No issue. The read-budget paragraph on `domain-context.md` stays. AC-20 adds the missing current-behavior sentences. It does not rebuild the page. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-09-22 | 1 | Portfolio vs six subtasks | Question 11 table and gates 5–6 lagged the later deltas | Review only; `ac-2.plan-review.md` untouched | kept |
| 2026-09-22 | 2 | Other children resolved | Reporter: remaining work is AC-20. Tree confirms AC-16, AC-17, AC-18, AC-19, AC-22 | Drop sibling blockers. Question 18 is the brief under test. No AC-20 plan to approve | open |

Iteration 1 findings B2, W1, W3, S1, and S2 are dropped. They were about unfinished siblings or about navigation in the parent research. The reporter closed those tickets. The audit skill still does not name `source: manual` in the empty-`code_paths` exception. That stays inside the closed AC-18 / AC-22 pair. It is not an AC-20 task.

## Top Failure Modes

- A plan copied from Question 18 labels the decisions catalog, the status lifecycle, and the As-Is Pack comment as future work. All three are already in `.ai/`. The public page would contradict the skills.
- The same plan runs `npm run sync:website-docs` to fix “exact four-line” on the generated prompt page. That page already says “four required lines plus optional signals”, the same sentence as `.ai/prompts/public/eversis-implement.md`. The stale sentences that remain are hand-authored.

## Unproven Assumptions

- That “phases that are not built yet” in the AC-20 Jira text is still the decisions home, the status lifecycle, and the As-Is suggestion. Those three shipped. The phrase that is still true is richer retrieval (Phase 6), which has no ticket.

## Most Likely Rework Triggers

- An edit of `website/docs/reference/domain-context.md` that rewrites the AC-22 section (“Add a known fact” / `eversis-add-domain-knowledge`) while adding the map.
- A docs pass that regenerates the prompt page and leaves `standard-flow.md`, `engineering-manager.md`, and the orchestration skill summary on the old four-line wording.

## Questions the Architect Must Answer Before Coding

- Question 18’s two gate questions (section on `domain-context.md` vs a new page; three hand pages vs the generated prompt only) are still unanswered. They do not change the shipped-vs-future split below. A plan can take the recommended side: one section on the existing page, and the three hand pages, because the generated prompt page is already correct.

## BLOCKERS

### B1: Question 18’s “not yet” list describes shipped behavior

The table in Question 18 says the decisions home, the status lifecycle, and the As-Is suggestion do not exist and must be labeled future work. Checked against the tree on 2026-09-22, after the reporter closed the other tasks:

| Question 18 | Tree |
| --- | --- |
| Decisions home does not exist | `docs/decisions/INDEX.md`, `README.md`, `0001-decisions-home.md`, and the read steps in `agent-core.md` |
| Status lifecycle does not exist | Promote writes `status: approved`. Audit sets `deprecated` / `superseded` and resets `tasks_since_audit` |
| As-Is suggestion does not exist | `eversis-fine-handoff` has “Optional third draft — As-Is Pack comment”. `overview.md` shows that draft |
| Generated prompt still says “exact four-line” | `website/docs/reference/prompts/public/eversis-implement.md` matches the source prompt |

`domain-context.md` still does not mention the decisions catalog, the status field, the Pack comment, or the session checkpoint. That silence is the remaining AC-20 work. Calling those four “not yet” would make the page false. The only “not yet” line that survives is Phase 6 retrieval.

**Action:** Revise Question 18 before any AC-20 plan. Current behavior to name, without recipes: decisions index, status on a component file, As-Is comment (link to the overview section that already describes it), session checkpoint without an exchange count. Leave the AC-22 “add a known fact” section as it stands. Keep Phase 6 as future work.

## WARNINGS

### W1: The readiness sentences that are still wrong are the hand-authored ones

These still teach the retired contract:

- `website/docs/main-flow/workflow/standard-flow.md` — “exact four-line”
- `website/docs/reference/agents/engineering-manager.md` — “exact four-line”, optional `Reason` only
- `website/docs/reference/skills/orchestrating-implementation.md` — “Exactly four bullet lines” and an optional fifth `Reason` line

The generated prompt page does not. `npm run sync:website-docs` will not change the three files above. The skill summary also omits `Resume` and `Context`, which Layer A already emits.

**Action:** The AC-20 plan edits those three pages in place. It does not treat a website-docs sync as the fix for criterion 3.

## SUGGESTIONS

None. A numbering index for Question 11 and the older floors of the AC-17 research are not on the path to the AC-20 plan.

## Verdict

`REVISIONS NEEDED`

AC-16, AC-17, AC-18, AC-19, and AC-22 are in the tree. AC-20 is the remaining documentation ticket, and it has no plan. Question 18 cannot be handed to an architect as written: it would document three shipped mechanisms as future work and would “fix” a prompt page that already matches `.ai/`. Revise that section, then write `docs/specs/ac-20/ac-20.plan.md`. This file does not approve that plan, because the plan does not exist yet.
