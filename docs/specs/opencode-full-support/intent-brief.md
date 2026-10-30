# OpenCode full support — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-21 |
| Participants | Piotr Niemirski (request owner) |
| Source Materials | User request: “Dodanie pełnej obsługi Open Code” with product link [OpenCode](https://opencode.ai/); current framework packaging (OpenCode marked placeholder); `docs/context/agent-collections/task-baseline.md` |
| Prepared By | Business Analyst (eversis-analyze-materials) |

## Goal

Teams that use [OpenCode](https://opencode.ai/) (terminal, IDE, or desktop) can install Agent Collections and run the same delivery workflow they already get with Cursor and Claude Code. OpenCode stops being labeled a placeholder and becomes a supported agent channel.

## In Scope

- A consumer can select OpenCode during install and receive a supported Agent Collections setup, with the same expectation of “this agent is supported” that already applies to Cursor and Claude Code.
- An OpenCode session loads the framework’s rules, prompts, and skills, and follows the same Ideate → Research → Plan → Implement → Review → Fine delivery standard.
- Installer copy, getting-started docs, and the public description of adapters stop calling OpenCode a placeholder.
- Packaging stays generated from the shared core. Core rules stay vendor-neutral; OpenCode-specific packaging lives in the adapter layer.
- Existing cross-tool isolation stays: an OpenCode session does not load Cursor or Claude packaging, and those tools do not load OpenCode packaging.

## Out of Scope

- Building or operating the OpenCode product itself (models, Zen, accounts, share links, desktop app).
- Rewriting the shared core (`.ai/`) into an OpenCode-specific format.
- New framework capabilities that exist only inside OpenCode and have no equivalent on Cursor or Claude Code (custom agent modes, permission policies, provider login).
- Re-opening the finished multi-agent isolation epic (live Jira key DHI-515, status Done) or the docs UX epic DHI-641.

## Key Stakeholders / Actors

- Framework maintainer — owns adapter parity and installer/docs claims.
- Consumer team lead — chooses which coding agents to install.
- Engineer using OpenCode — expects rules, prompts, and skills to behave like the other supported agents.

## Candidate Epics

- **OpenCode as a supported Agent Collections channel** — one epic. The outcome is parity with the already shipped Cursor and Claude Code channels, replacing the current placeholder (historical backlog item TASK-525, “Define OpenCode future adapter manifest”).

## Baseline Overlap / Existing Backlog Notes

- Project baseline: `docs/context/agent-collections/task-baseline.md` (last refreshed 2026-09-04). Live Jira project key in that baseline is **DHI** (older TASK-* rows are historical).
- TASK-525 already captured a **future** OpenCode adapter manifest. That work shipped as a placeholder only: instructions pointing at core rules, hand-maintained config, and explicit “not a shipped adapter” status. This request is the follow-on: promote that placeholder to full support.
- DHI-515 (multi-agent isolation) is Done. A new OpenCode epic should be a sibling, the same way DHI-641 was created beside a finished epic.
- No current baseline row covers “full OpenCode support.”

## Open Questions

- Confirm the parity bar: supported means the same class of outcomes as Claude Code today (rules, prompts/commands, skills, installer selection, docs), with OpenCode-only product features left out.
- Jira home confirmed in chat: project **AC**, board 1471. Filed as one Task (same shape as AC-14), not as a child of DHI-515.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-09-21 — Piotr Niemirski zatwierdził zakres bez zmian. Pushed as [AC-15](https://eversis.atlassian.net/browse/AC-15). |
