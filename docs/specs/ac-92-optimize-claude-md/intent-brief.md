# ac-92-optimize-claude-md — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-30 (desk analysis, no workshop) |
| Participants | Piotr Niemirski |
| Source Materials | [S1] PostHog newsletter — "Your AGENTS.md is holding you back" (Jina Yoon); [S2] ColdTea — "What the 100 biggest GitHub repos put in their AGENTS.md" (field study, files fetched 2026-08-21); [S3] Jira AC-92 + Sub-tasks AC-93–AC-98; [S4] open AC backlog (JQL `project = AC AND statusCategory != Done`, 2026-10-30); [S5] repo state: `CLAUDE.md` (396 lines), `AGENTS.md` (89 lines), `templates/AGENTS.template.md`, `docs/architecture/agents-md-standard.md`, `adapters/profiles/*.yaml`; [S6] `docs/context/agent-collections/task-baseline.md`, `jira-backlog-hierarchy` |
| Prepared By | Claude (eversis-analyze-materials) |

## Goal

Check whether the AC-92 backlog (thin-root `CLAUDE.md`) already covers what two recent field reports say about agent instruction files, and decide which gaps become new or extended tickets. The aim is lighter, accurate instruction files that stay accurate over time — not only a one-off size cut.

## Key findings from the materials

| # | Finding | Source | Covered today? |
|---|---|---|---|
| F1 | Context that models can infer now makes agents worse; shift from adding to removing; labs moved from rules and repetition to judgment and progressive disclosure (Anthropic cut ~80% of the Claude Code system prompt) | S1 | **Yes** — AC-93/94/95 (phase rules on demand, stated once) |
| F2 | Keep it short (≈ two pages); link to deeper docs instead of repeating them | S2 | **Yes** — AC-92 budget ≤ 257 lines, AC-93 index of links |
| F3 | Measure token cost after each upgrade (`/doctor`): ~350 tokens cut from a 1,780-token file; 3 plugins + 3 skills disabled ≈ 6K tokens/session | S1 | **Partly** — AC-97 guards line count; no guidance to re-check after tool/framework upgrades; skill load already filtered by `adapters/profiles/*` allowlists |
| F4 | "For each line, if you can't name the failure it prevents, delete it." | S1 | **No** — AC-92 removes duplication and phase-only text, but does not ask each remaining always-on rule to justify itself |
| F5 | Instructions about state that is not in code go stale silently (merge-queue line → 21 h of wrong agent behaviour, 10 h stuck PR) | S1 | **No** — `eversis-audit-domain-knowledge` covers `docs/context/`, not the instruction files themselves |
| F6 | Test context like code: save prompts that caused failures (`failures.md`) and re-run them on every instruction edit; automated evaluator on sample runs | S1 | **Partly** — AC-98 is a one-off manual check for AC-92, not a standing regression set |
| F7 | Ask agents for feedback at the end of a run ("what info would have prevented wasted turns?"); PR template asks which skills were invoked; verify before fixing | S1 | **No** |
| F8 | Write an operating manual, not a policy: exact fenced commands (install, build, full suite, **single test**, lint/typecheck), structure map, git/PR conventions, boundaries | S2 | **Partly** — `AGENTS.md` lists commands inline, no single-test command, no fenced blocks; template/standard not re-checked against S2 |
| F9 | Negative rules should be specific and tied to real failures (e.g. "Do not claim an interrupted or timed-out test passed", "Never delete, weaken, or rewrite a test to make a change pass") | S2 | **Partly** — hard limits cover scope / doc comments / dependencies only; honesty about test results and no test weakening are not stated |
| F10 | 90% of files use must/always/never; heavy rule language is common but S1 says it is no longer the best default | S1, S2 | **Partly** — current `CLAUDE.md` has 37 lines with must/never/always/do not; AC-94 condenses but does not set a tone guideline |

## In Scope

- Mapping S1/S2 findings onto AC-92 and its Sub-tasks (coverage table above).
- Proposing changes to existing AC-92 Sub-tasks where a finding fits their scope (F4 into AC-94, F10 into AC-94, F6 into AC-98).
- Proposing new Tasks for gaps outside AC-92's scope (F5/F3 upkeep, F7 feedback loop, F8/F9 AGENTS.md + template refresh).
- Flagging backlog hygiene found during the check (see Baseline Overlap).

## Out of Scope

- Implementing any change (this is backlog work only; AC-92 still needs research + plan).
- An automated LLM evaluator running sample apps (S1 `wizard-ci` / `pr-evaluator`) — too heavy for the framework now; a manual, repeatable prompt set is the proposed first step.
- Cursor `.mdc` and `.ai/rules/*.md` source edits — AC-92 option B keeps them unchanged.
- Changing the skill allowlist mechanism — profiles already filter installed skills.

## Key Stakeholders / Actors

- Claude Code user (framework and consumer) — pays the startup-token cost every session.
- Framework maintainer — keeps rules accurate, owns tests and the regression prompt set.
- Consumer project team — owns its own `AGENTS.md`, built from the framework template.

## Candidate Epics / Tickets

Per the AC hierarchy rule, the implementable leaf is a Task or Bug.

- **Extend AC-94** — every always-on rule left in `CLAUDE.md` names the failure it prevents (or is cut); plain directive tone over must/always/never where the rule is not a hard gate. (F4, F10)
- **Extend AC-98** — the gate check becomes a stored regression prompt set (`failures`-style file) re-run whenever `CLAUDE.md`, `agent-core.md` or the generator changes, not only once for AC-92. (F6)
- **New Task A — Instruction-file upkeep after upgrades** — documented maintainer routine: after a Claude Code or framework upgrade, run `/doctor` (token/skill report), re-check lines that describe non-code state, record result. (F3, F5)
- **New Task B — Agent feedback at Fine** — Fine handoff gains an optional, short "instruction friction" note (what missing or wrong instruction cost turns; which skills were loaded), verified by a human before any rule change. (F7)
- **New Task C — AGENTS.md as an operating manual** — refresh `AGENTS.md`, `templates/AGENTS.template.md` and `docs/architecture/agents-md-standard.md` against S2: fenced commands incl. single test, boundaries incl. honest test reporting and no test weakening, remove stale lines (`docs/plans/` — see AC-3; `task-*`-only gitignore wording). (F8, F9)

## Baseline Overlap / Existing Backlog Notes

- **AC-92 has not started**: `CLAUDE.md` is still 396 lines; spec folder `docs/specs/ac-92-optimize-claude-md/` did not exist before this brief.
- **Hierarchy conflict**: AC-93–AC-98 are **Sub-tasks** under Task AC-92 (created 2026-10-19). The `jira-backlog-hierarchy` rule (updated 2026-10-20) says the leaf must be a Task/Bug, with Story or Epic above. To comply, AC-92 would become a Story (or Epic) and AC-93–AC-98 Tasks.
- **AC-80** — edits the Delivery Standard source text; already linked to AC-92; no change.
- **AC-3** — deprecates `docs/plans/`; Task C should relate to it (AGENTS.md still lists `docs/plans/`).
- **AC-112** — token-economy rules for Pi only; related theme, different tool; Relates link only.
- **AC-4 epic (context-flow guides)** — website explainers; no overlap with instruction content.
- **TASK-531 / TASK-532** (historical) — delivered the AGENTS.md template and reference file that Task C would refresh.

## Open Questions

Resolved at Gate 0 (see below).

1. Should F4/F10/F6 extend AC-94 and AC-98 (keeps AC-92 one deliverable, grows its scope), or become separate Tasks after AC-92?
2. Which of the new Tasks A, B, C do you want in the backlog now — and under a new Epic (e.g. "Agent instruction files: lean and accurate") or as standalone Tasks?
3. Fix the AC-92 hierarchy now (Task → Story, Sub-tasks → Tasks), or leave it as created before the rule?

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-10-30 — Piotr Niemirski. Decisions: (1) F4 + F10 extend AC-94, F6 extends AC-98 in a minimal form (committed prompt set, no automated evaluator); (2) Tasks A, B, C go to the backlog under a new Epic "Agent instruction files: lean and accurate", AC-92 moves under it; C is High, A and B Medium; (3) AC-92 hierarchy is fixed now: AC-92 Task → Story, AC-93–AC-98 Sub-task → Task (Jira change only at Gate 2). |
