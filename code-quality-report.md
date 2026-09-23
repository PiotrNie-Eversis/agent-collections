# Code Quality Report - agent-collections

## Overview

| Field | Value |
|---|---|
| Repository | agent-collections |
| Repository Type | Monorepo (framework SSOT `.ai/`, adapters, MCP, docs site) |
| Date | 2026-09-23 |
| Layers/Apps Analyzed | Orchestration SSOT (`.ai/rules/orchestration/`, `.ai/skills/eversis-orchestrating-implementation/`); AC-2 child plans (`docs/specs/ac-16` … `ac-26`); public workflow pages (`website/docs/`) |
| Scope | Logical review of shipped AC-2 work: Implement continuity (Review → Fine in the same session) and whether Human Gates stay true after later tickets. Not a whole-repo unused-import sweep. |

## Executive Summary

Research and plan gates on the AC-2 children are closed the way the framework requires: a later human message quotes an explicit approval, and implementation starts only after that. Continuity after code is uneven. The live rule (AC-26) keeps Review and Fine in the same session and treats `CHECKPOINT:` as a note, not a stop. Several finished plans still show Human gate 3 as open, and they record a review PASS without a Fine / QA-draft line. A later `/eversis-implement` that trusts that gate will treat the ticket as unfinished. It will also not emit `Resume`, because the same turn that wrote `CHECKPOINT:` already wrote `RESUMED:` and consumed it.

The parent plan still says the exchange-count and “open a new chat” questions are undecided. AC-19 and AC-26 already decided them, in opposite directions, and only the second decision is what the skill does today. The public domain-context page describes both decisions at once.

Two shipped knowledge skills still disagree. `eversis-add-domain-knowledge` may store `source: manual` with an empty `code_paths`. `eversis-audit-domain-knowledge` treats that shape as “code is gone” and signals Delete. The empty-path exception covers only `source: confluence` and `source: docs-specs-cluster`.

---

## Findings by Layer/App

### Orchestration SSOT (`.ai/rules/orchestration/`, `.ai/skills/eversis-orchestrating-implementation/`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| 1 | 🟢 | Unreachable happy path | `.ai/skills/eversis-orchestrating-implementation/SKILL.md:80`, `:253` | On the path the rule itself prescribes, `Resume` never fires. Rule 14 writes `CHECKPOINT:` and, in the same turn, `RESUMED:`. Step 1 treats a later `RESUMED:` as consumption. AC-26 records this on purpose: `Resume` exists only if the process dies between those two rows (`docs/specs/ac-26/ac-26.plan.md:38`). The scan is not unused code. It is unused whenever the agent finishes the turn. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Contract copied in two Layer A files | `.ai/skills/eversis-orchestrating-implementation/SKILL.md:80-97`, `.ai/rules/orchestration/engineering-manager.md:23-31` | The readiness block, the unconsumed-checkpoint scan, and the “same turn writes `RESUMED:`” sentence are maintained twice. They match today, including the generated `.cursor/rules/eversis-engineering-manager.mdc:31`. | Keep the pair. When rule 14 changes again, edit both files in one task and run `npm run sync:adapters:check`. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Continuity vs heading | `.ai/skills/eversis-orchestrating-implementation/SKILL.md:253` | The heading is still “Zero-compaction session budget”. The body forbids ending the turn, forbids telling the person to open a new session, and continues through remaining tasks, Review, and Fine. An agent that follows the heading reintroduces the hard stop AC-26 removed. Continuity itself (`SKILL.md:172-179`, rule 13 at `:252`) is consistent with the body: Review and Fine stay in the session; rule 14 yields once Review or Fine has started. | Rename the rule to a handoff note. State in the first sentence that the session does not stop. |
| 2 | 🟡 | Stale parent gate | `docs/specs/ac-2/ac-2.plan.md:413` and `:571` | Gate 3 is struck as done, then still says the exchange-count scope, Continuity during Review, and the new-chat sentence “remain undecided”. The logical-gap section below repeats that sentence as the reason a contradiction was not a blocker. Live rule 14 has no 5–10 trigger and does not ask for a new chat. | Replace that clause with the AC-26 contract: one trigger, same-turn `RESUMED:`, session continues, rule 13 on the last task. Do not leave “undecided” as the last word. |
| 3 | 🟡 | Superseded contract left as current | `docs/specs/ac-19/ac-19.plan.md:17`, `:31` | AC-19’s Success Measure and proposed solution still require the sentence „Otwórz nową sesję Implement…”. AC-26 deleted that sentence from the skill. The AC-19 human gate is struck, so a careful reader can treat the plan as history. A reader who treats Success Measure as the live contract will put the hard stop back. | Add one line under AC-19 Human gates: superseded by AC-26; do not re-apply the operator sentence. |

### Child plans — Human gates and Continuity (`docs/specs/ac-16` … `ac-26`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| — | — | — | — | No dead production code in this layer. The defect is a gate record that no longer matches the changelog. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| — | — | — | — | No duplicated implementation logic in the plans. The same unfinished gate sentence is copied across tickets; that is recorded below as one continuity defect, not as copy-paste code. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🔴 | Human gate left open after Review PASS; Fine not recorded | `docs/specs/ac-16/ac-16.plan.md:270` (PASS at `:281`); `docs/specs/ac-17/ac-17.plan.md:317` (PASS at `:354`); `docs/specs/ac-22/ac-22.plan.md:319`; `docs/specs/ac-23/ac-23.plan.md:236` (PASS at `:247`); `docs/specs/ac-25/ac-25.plan.md:286` (PASS at `:292`) | Research and plan gates on these tickets are struck and quote the human. Gate 3 (“Implement → Review → Fine”) is not. AC-17 still says the human will start implementation in a new window. AC-22 still says this chat does not implement. Changelogs show review PASS and, where used, a `CHECKPOINT:` already followed by `RESUMED:`. None of these five plans record Fine or a QA comment draft. Continuity (`eversis-orchestrating-implementation` Step 5, `agent-core.md:48-49`) requires both in the same turn as PASS, and it forbids publishing without a later human OK. AC-18 (`:305`), AC-19 (`:227`), AC-20 (`:242`), AC-24 (`:308`), and AC-26 (`:278`) did strike the implement gate. AC-20 also records Fine and a Jira comment only after explicit approval. | For each of the five, either strike gate 3 and add the Fine line plus the QA draft that was actually produced, or run the missing Fine turn now and stop before posting to Jira. Do not start a new Implement from an open gate 3 when the changelog already says PASS. |
| 2 | 🟡 | Plan validation skipped or left at REVISIONS NEEDED | No `*.plan-review.md` for AC-16, AC-17, AC-18, AC-22, AC-23, AC-24. `docs/specs/ac-20/ac-20.plan-review.md:6` and `:100` still say `REVISIONS NEEDED` | `engineering-manager.md:11` requires research, plan, and plan validation before broad code. Full Flow treats `*.plan-review.md` verdict `APPROVED` as that validation (`eversis-orchestrating-implementation/SKILL.md:192`). Human “Plan is ok” closed the human plan gate on these tickets. It did not produce an approved plan-review file. AC-20 is the sharp case: Fine is declared (`ac-20.plan.md:242`, `:256`) while the review file still demands revisions. The page content later addressed that review’s B1 (`website/docs/reference/domain-context.md:116-130`). The verdict file was not updated. AC-19, AC-25, and AC-26 have `APPROVED` plan reviews. | Re-run plan review only where the plan can still change a future session (AC-20’s verdict file). For the tickets with no review file, add a one-line note that the human accepted the plan without a Plan Reviewer pass, so a later session does not treat the missing file as “review still required” and reopen implementation. |
| 3 | 🟡 | Resume latch consumed before the session actually ended | `docs/specs/ac-23/ac-23.plan.md:243-247` | AC-23 wrote `CHECKPOINT:` and `RESUMED:` twice, then recorded review PASS, and left gate 3 open with no Fine line. Under the current scan, a new window sees a consumed checkpoint, so it emits no `Resume`, and it also sees an open implement gate. Those two signals disagree: the changelog says review already passed; the gate says Implement has not finished. | Close gate 3 with an explicit Fine outcome. Do not add another `CHECKPOINT:` for work that already has `RESUMED:`. |

### Public docs (`website/docs/`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| — | — | — | — | The retired “exact four-line” contract is gone from `standard-flow.md`, `engineering-manager.md`, and `orchestrating-implementation.md`. Those pages now say four required lines plus optional `Resume`, `Context`, and `Reason`. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Two descriptions of one checkpoint | `website/docs/reference/domain-context.md:130` and `:186` | The “What updates the project index” blurb (AC-19) calls the checkpoint a resume marker for a long session. The Implement diagram prose (AC-26) says the same turn writes `RESUMED` and this session continues. Both are on one page. | Make line 130 match the diagram: the row is a note; this session continues unless the person asks to stop. Keep the statement that the row does not update the project index. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Cross-skill contradiction | `.ai/skills/eversis-add-domain-knowledge/SKILL.md:56-67`; `.ai/skills/eversis-audit-domain-knowledge/SKILL.md:34` | AC-22 allows `source: manual` with `code_paths: []`. AC-18’s Delete exception covers empty `code_paths` only for `source: confluence` and `source: docs-specs-cluster`. It explicitly withholds the exception from `source: agent-discovered` and never mentions `manual`. An audit of a hand-entered fact with no paths signals Delete (“all paths are gone”). AC-20 recorded this residual and left it (`ac-20.plan.md:233`). The import skill’s `<split-not-copy>` block (`eversis-import-confluence-knowledge/SKILL.md:15-17`) now matches Step 4; that earlier contradiction is closed. | Extend the audit exception to `source: manual` with empty `code_paths` (signal Update, not Delete), in a ticket that is allowed to edit the audit skill. |

---

## Architecture Observations

Human gates that are still doing their job:

- Research stops before planning, and the plan stops before broad edits, on every child inspected. The closing words are quoted (`"Plan is ok. Implement"`, `"Research is ok"`, and the AC-20 hold “do not start until I say”).
- Review is not a human attach gate. `agent-core.md:23`, `spec-driven-development.md:27`, and Continuity in the orchestration skill agree.
- Publishing a QA comment or an As-Is Pack comment stays behind a later explicit approval. AC-20’s changelog shows the comment posted only after that approval.
- `Resume` is not a `Flow` value. Both Layer A files keep `Flow: Quick | Full | QA follow-up` and put `Resume` on its own line.
- Rule 13 wins on the plan’s last task. Rule 14 does not checkpoint a session that is already in Review or Fine.

What the later tickets did to continuity:

- AC-2 Phase 3 shipped a real stop (checkpoint, then end the session).
- AC-19 removed the 5–10 exchange trigger, kept a stop, and added the Polish “open a new session” sentence so the stop would not cut off Review and Fine.
- AC-26 removed the stop. The same turn writes `RESUMED:` and the session continues. That matches Continuity. It also makes a deliberate new-window handoff something only the person can ask for. The agent must not suggest it.

The parent Human gates section and the AC-19 Success Measure were not updated when AC-26 landed. The public page carries both stories. That is the remaining continuity bug: three documents, two policies, one skill.

Plan Reviewer validation is a second gate beside the human “Plan is ok”. It was kept on AC-19, AC-25, and AC-26, and skipped or left stale on the others. Skipping it did not by itself reopen research. It does leave a fresh session without an `APPROVED` artifact where the skill says to look.

Module boundaries are otherwise intact. Decisions stay in `docs/decisions/` (AC-16). Domain facts stay in `docs/context/` (AC-18, AC-22). The As-Is comment is a Fine draft, not a page edit (AC-17). The context router in `agent-core.md:32-44` still separates discovery from consumption.

## Summary

| Category | 🔴 Critical | 🟡 Important | 🟢 Nice to Have | Total |
|---|---|---|---|---|
| Dead Code | 0 | 0 | 1 | 1 |
| Duplications | 0 | 0 | 2 | 2 |
| Improvements | 1 | 5 | 0 | 6 |
| **Total** | **1** | **5** | **3** | **9** |

## Recommended Action Plan

### Immediate (Critical)

1. Close Human gate 3 on AC-16, AC-17, AC-22, AC-23, and AC-25. Where review PASS is already in the changelog and no QA draft exists, produce the Fine draft in a follow-up turn and do not post it until the human says to publish. Strike the gate only after that draft exists.

### Short-term (Important)

1. Rewrite `docs/specs/ac-2/ac-2.plan.md` Human gates so “undecided” is replaced by the AC-26 rule. Mark the AC-19 operator sentence as superseded.
2. Align `website/docs/reference/domain-context.md` line 130 with the Implement diagram: checkpoint does not end the session.
3. Rename rule 14 so the heading no longer says the session should stop to avoid compaction.
4. Either re-approve `ac-20.plan-review.md` or annotate it as historical after the B1 fix. Note missing plan-review files on the tickets that shipped from a human “Plan is ok” alone.
5. Add `source: manual` to the audit skill’s empty-`code_paths` exception so a hand-entered fact is not a Delete candidate.

### Long-term (Nice to Have)

1. When a session actually crashes between `CHECKPOINT:` and `RESUMED:`, confirm a new window emits `Resume` and does not redo the finished task. That is the only path that still needs the scan.
2. Keep Layer A (skill + engineering-manager rule) and the generated Cursor rule on one edit whenever the readiness block changes.
