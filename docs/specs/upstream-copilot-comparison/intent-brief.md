# upstream-copilot-comparison — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-30 (desk analysis, no workshop) |
| Participants | Framework maintainer |
| Source Materials | copilot-collections `master` @ `b7b6b04`; agent-collections `master` @ `035912f`; both CHANGELOGs; `materials-analysis.md`; `docs/context/agent-collections/task-baseline.md` |
| Prepared By | Claude Code (eversis-analyze-materials) |

## Goal

Decide which upstream copilot-collections improvements Agent Collections should adopt, adapt, or reject, and turn the accepted ones into a backlog that strengthens gate enforcement and role isolation without giving up multi-host neutrality.

## In Scope

- Revision-bound human approval for plans and plan reviews
- Structural role isolation through adapter-generated subagents (Claude Code, OpenCode)
- Upstream sync ledger and a recurring upstream review
- CLI-first UI capture as an optional verification path
- `eversis-explore-materials` prompt
- Fail-closed approval check in delegated implement prompts
- Optional per-role model routing in profiles
- Positioning/documentation of differences vs copilot-collections

## Out of Scope

- A GitHub Copilot adapter — no demand recorded yet
- Hard-coded model names in `.ai/` SSOT
- Removing Quick Flow or adopting the Discussion Boundary — evaluate first (decision record only)
- Website homepage redesign (covered by DHI-641)

## Key Stakeholders / Actors

- Framework maintainer — owns SSOT, adapters, release
- Consumer project teams — receive the changes through `--upgrade --sync`; need a Migration note for plan-template changes
- Agent hosts (Claude Code, Cursor, OpenCode, Pi) — differ in subagent and model-routing support

## Candidate Epics

- **Gate enforcement hardening** — revision-bound approval record, revision-bound review verdict, fail-closed check in implement prompts
- **Role isolation via generated subagents** — adapters emit subagents for reviewer / UI reviewer / plan implementor; optional model routing
- **Upstream alignment process** — sync ledger, recurring review, decision records for Quick Flow / Discussion Boundary, positioning doc
- **UI verification & discovery parity** — CLI-first UI capture, explore-materials prompt, later BA worker split

## Baseline Overlap / Existing Backlog Notes

- TASK-523/526/527 (adapter architecture, Claude adapter, sync tooling) — subagent generation extends this delivered work; new epic, not a reopen
- `docs/specs/quick-flow-gate-enforcement/`, `close-implement-gates`, `ambiguous-gate-acceptance` — prior gate work; approval record builds on it
- DHI-641 (docs IA) — a positioning page could fit there instead of a new story
- AC-91 (Chrome DevTools) — adjacent to UI capture; keep separate

## Open Questions

- Which epics should go to Jira now — all four, or only Gate enforcement + Upstream alignment first?
- Target Jira project: `AC`?
- Subagent generation: Claude Code + OpenCode only, or must Cursor get an equivalent first?
- Is contributing back to TheSoftwareHouse upstream desired, or only a positioning page?

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Pending | Awaiting maintainer decision on scope and open questions |
