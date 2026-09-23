# Code Quality Report - agent-collections

## Overview

| Field | Value |
|---|---|
| Repository | agent-collections |
| Repository Type | Monorepo (framework SSOT `.ai/`, adapters, MCP, docs site) |
| Date | 2026-09-23 (re-review) |
| Layers/Apps Analyzed | Orchestration SSOT; AC-2 child plans AC-16–AC-27 and `close-implement-gates`; public page `website/docs/reference/domain-context.md` |
| Scope | Second logical pass after the close-out of Implement gates and the AC-26 session contract. Same question as the first pass: Implement continuity and Human Gates. |

## Executive Summary

The first pass found one critical break: five finished tickets still showed an open Implement gate and no QA draft, so a later `/eversis-implement` could start them again. That break is closed. AC-16, AC-17, AC-22, AC-23, and AC-25 now have gate 3 struck and a pasted draft labeled `**Draft QA comment — review before posting to Jira**`. The drafts are not posted. `close-implement-gates` itself has research and plan approval, an `APPROVED` plan review, a struck gate 3, and Fine recorded without a Jira post.

The session contract is now one story. Rule 14 is titled “Checkpoint handoff note (session continues)”. The parent Human gates, the AC-19 superseded note, `domain-context.md`, and `readiness-contract` all say the same thing: the same turn writes `RESUMED` and the session goes on through Review and Fine unless the person asks to stop. `Resume` is still not a `Flow` value. The audit exception now includes `source: manual` and still excludes `source: agent-discovered`.

What remains is the Jira appendix inside `ac-2.plan.md`. Human gates above it already name the AC-26 contract. The appendix, which is the text published as the AC-2 description, still tells an agent to stop the session on a 5–10 exchange count. Republishing that block would put the hard stop back.

AC-27 (three links from the domain-context page to the add-domain-knowledge skill page) has an approved plan review, a struck gate 3, and a review PASS. The QA draft is not in that plan file.

---

## Findings by Layer/App

### Orchestration SSOT (`.ai/skills/eversis-orchestrating-implementation/`, `.ai/rules/orchestration/`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| — | — | — | — | No new dead path. `Resume` still fires only when a `CHECKPOINT:` has no later `RESUMED:` or same-task completion. AC-26 keeps that as the crash gap between the two rows. The happy path consumes the checkpoint on purpose. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Layer A pair, still aligned | `.ai/skills/eversis-orchestrating-implementation/SKILL.md:80-97` and `:253`; `.ai/rules/orchestration/engineering-manager.md:23-31` | The readiness block and the “same turn writes `RESUMED:`” sentence still live in both Layer A files. They match. | On the next shape change, edit both files in one task and run `npm run sync:adapters:check`. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Stale published contract | `docs/specs/ac-2/ac-2.plan.md:413` versus `:622`, `:754`, and `:801` | Gate 3 now states the AC-26 rule: one completed-and-tested trigger, same-turn `RESUMED:`, session continues, no exchange count, no “open a new chat”. The appendix “Jira AC-2 Description (shipped)” still says Phase 3 has two triggers (5–10 exchanges or completed+tested) and that the agent ends the session. Requirement 10 and the Phase 3 acceptance check repeat that. The live skill does not. `close-implement-gates` was told not to edit this file because the Human gates section was already correct. | Mark the appendix as the 2026-09-21 publish snapshot, superseded for session behavior by AC-26. Do not republish it as the current description. A Jira update of that field needs a separate “publish to Jira”. |

### Child plans — Human gates (`docs/specs/ac-16` … `ac-27`, `close-implement-gates`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| — | — | — | — | Open gate 3 text (“new window”, “ten czat nie implementuje”) is gone from the gate lines. Those phrases remain only in changelog rows that record the original approval. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| — | — | — | — | The history sentence is repeated on purpose on AC-16, AC-17, AC-18, AC-22, AC-23, and AC-24. AC-25 correctly has none, because it already has an `APPROVED` plan review. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Fine declared, draft not in the plan | `docs/specs/ac-27/ac-27.plan.md:186` | Gate 3 is struck: review PASS, Fine declared this turn. Plan review is `APPROVED`. The file has no `**Draft QA comment — review before posting to Jira**` section. A later session will not restart the three links. The handoff draft, if it existed only in chat, is not in the artifact. `close-implement-gates` records the same pattern for its own ticket (`:256`, `:270`): Fine in the changelog, draft not pasted into that plan. The five child drafts that ticket was supposed to paste are in those plans. | Paste the AC-27 draft under a Fine heading when it is still in the chat. Leave it unposted until you say to publish. |

### Public docs (`website/docs/reference/domain-context.md`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| — | — | — | — | The “resume marker for a long session” sentence is gone. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Matching copies | `website/docs/reference/domain-context.md:130` and `:186` | Both now say: checkpoint when this task is done and tested and later tasks remain; the same turn writes RESUMED; this session continues through Review and Fine unless the person asks to stop; the row does not update the project index. The Implement diagram (`:195`) and the legend (`:298`) say the same. | None. The earlier contradiction is closed. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | AC-27 links | `website/docs/reference/domain-context.md:310`, `:324`, `:334` | Loop step 3, the scan-table row, and the four write skills card each link `./reference/skills/add-domain-knowledge`. The “Add-a-fact” sentence at `:122` stays unlinked, which AC-27 put out of scope. The checkpoint paragraphs were not rewritten by that ticket. | None for this pass. |

---

## Architecture Observations

Closed since the first report:

| First-pass item | Now |
|---|---|
| Gate 3 open on AC-16, AC-17, AC-22, AC-23, AC-25, with no QA draft | Struck. Each plan has one draft. Not posted. |
| Parent gates still said the exchange count and the new-chat sentence were undecided | `ac-2.plan.md:413` names the AC-26 contract. The old logical-gap note at `:571` is marked historical and closed by AC-26. |
| AC-19 Success Measure still required „Otwórz nową sesję…” as current | The sentence remains in the body as history. Human gates (`ac-19.plan.md:229`) say superseded by AC-26 and forbid putting it back into the skill. |
| `domain-context.md` described a resume marker and a continuing session | Both checkpoint sentences match the diagram. |
| Rule 14 heading “Zero-compaction session budget” | Heading is “Checkpoint handoff note (session continues)” (`SKILL.md:253`). |
| Empty `code_paths` on `source: manual` could signal Delete | Exception at `eversis-audit-domain-knowledge/SKILL.md:34` includes `confluence`, `docs-specs-cluster`, and `manual`. `agent-discovered` stays outside it. The audit was not run. `tasks_since_audit` was not reset. |
| Missing plan-review files, and AC-20 still `REVISIONS NEEDED` | History notes on the six plans. `ac-20.plan-review.md:6-8` keeps `REVISIONS NEEDED` and says not to reopen implementation. |
| `readiness-contract` silent on AC-26 | The note now says a checkpoint does not end the session. Layer A/B and “`Resume` is not a `Flow` value” stay. |

Human gates that were already sound are unchanged: research and plan close on a quoted human message; Review is not a human attach gate; Jira publish stays behind a later explicit OK.

`close-implement-gates` followed its own checkpoint rule: `CHECKPOINT:` then `RESUMED:` in the changelog, then the session continued into review and Fine. AC-27’s plan review is `APPROVED`, which is the validation step the earlier tickets often skipped.

## Summary

| Category | 🔴 Critical | 🟡 Important | 🟢 Nice to Have | Total |
|---|---|---|---|---|
| Dead Code | 0 | 0 | 0 | 0 |
| Duplications | 0 | 0 | 2 | 2 |
| Improvements | 0 | 1 | 2 | 3 |
| **Total** | **0** | **1** | **4** | **5** |

First pass was 1 critical, 5 important, 3 nice-to-have. This pass has no critical finding.

## Recommended Action Plan

### Immediate (Critical)

None.

### Short-term (Important)

1. In `docs/specs/ac-2/ac-2.plan.md`, label the Jira appendix as the 2026-09-21 snapshot. State that session behavior in that snapshot (5–10 exchanges, end the session) was replaced by AC-26. Do not publish that appendix again.

### Long-term (Nice to Have)

1. If the AC-27 QA draft is still in the Implement chat, paste it into `ac-27.plan.md` under Fine. Do not post it.
2. Keep the two Layer A files together on the next readiness-block edit.
