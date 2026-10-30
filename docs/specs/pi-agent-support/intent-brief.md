# Pi Agent support — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-21 |
| Participants | Requestor (chat) |
| Source Materials | Chat request: “Dodanie pełnej obsługi PI Agent” with [https://pi.dev/](https://pi.dev/); Pi product docs ([documentation](https://pi.dev/docs)); Agent Collections adapter mapping; `docs/context/agent-collections/task-baseline.md`; Jira projects AC and DHI |
| Prepared By | Business Analyst (`eversis-analyze-materials`) |

Transcript processing was skipped: the input is a one-line request, not a workshop transcript.

## Goal

Teams that use [Pi](https://pi.dev/) (the minimal terminal coding harness from Earendil) should be able to run Agent Collections in Pi the same way they already can in Cursor and Claude Code: install the framework, load its rules, skills, and prompts, and follow the same delivery workflow.

“Full support” is interpreted as a **shipped** Pi adapter (selectable, documented, and usable), not a config-only placeholder of the kind OpenCode has today.

## In Scope

- Pi is a first-class agent target in Agent Collections, at the same maturity class as the shipped Cursor and Claude Code adapters.
- A person installing Agent Collections can choose Pi and get the framework’s rules, skills, and prompt templates available inside a Pi session.
- Public docs and the install choice list name Pi as a supported agent, with a short description of what the install provides.
- On Pi, a long Implement session keeps a ~50% context budget, because that host exposes window usage and already ships 50% rolling compaction. Cursor and Claude Code do not gain a window-fill trigger. Source: AC-2 plan, Open Question 6 and Improvements (“PI Agent context-window trigger”).
- The work is tracked in Jira project **AC**.

## Out of Scope

- Replacing or rewriting the vendor-neutral core (`.ai/`). Pi packaging consumes that core.
- Promoting the existing OpenCode adapter from placeholder to full support (separate request, not in this chat).
- Building the capabilities Pi itself does not ship (MCP client, sub-agents, plan mode, permission popups, built-in to-dos, background shell) unless a later decision adds them as Pi extensions.
- Pi themes, custom model/provider catalogs, SDK/RPC embedding, and container/sandbox setup.
- Changing the delivery workflow (Ideate → Research → Plan → Implement → Review → Fine).
- Putting a context-window percent trigger back into the Cursor or Claude Code Implement rule. AC-2 removed that trigger because those hosts cannot observe window fill.

## Key Stakeholders / Actors

- Framework maintainer — decides which agents are shipped and how install selection works.
- Team using Pi — wants Agent Collections rules, skills, and prompts in a Pi session without maintaining a second copy of the framework.
- Reader of the docs site — needs to see Pi listed as a supported agent and know what “supported” means.

## Candidate Epics

- **Full Pi Agent support** — one capability: Agent Collections can be installed and used in Pi at shipped maturity, covering rules, skills, prompt templates, install selection, and docs.

## Baseline Overlap / Existing Backlog Notes

- No Jira issue in **AC** or **DHI** mentions Pi or pi.dev.
- Shipped adapters today: Cursor and Claude Code. OpenCode is a **placeholder** only (`DHI-525` / baseline `TASK-525`, “Define OpenCode future adapter manifest”, parent epic `DHI-515` which is **Done**).
- `docs/context/agent-collections/task-baseline.md` (refreshed 2026-09-04) indexes DHI migration and docs-UX work. It does not list Pi. New work belongs in project **AC**, not under the closed DHI-515 epic.
- AC backlog today is context-flow and knowledge-management work (`AC-1`–`AC-13`). No overlap with a Pi adapter.

## Open Questions

- None. Approval on 2026-09-21 locks the recommended reading: usable in Pi (rules, skills, prompt templates, install, docs). Capabilities Pi does not ship (MCP, sub-agents, plan mode) stay out of scope.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-09-21. Requestor approved the brief and asked for one ticket on the AC board (https://eversis.atlassian.net/jira/software/c/projects/AC/boards/1471). |

---

# Scope extension — cost-predictable model access and token economy in Pi (2026-10-27)

## Workshop Summary

| Field | Value |
|---|---|
| Date | 2026-10-27 |
| Participants | Requestor (chat) |
| Source Materials | “GitHub Copilot Pro a koszty API.md” (Google Drive, AI_agents/Agent Collections/Docs) — an exported Gemini chat; Jira AC-14 (status In Progress, sub-task AC-21, comment 2026-10-27 on the one-off Pi port in a consumer repo) |
| Prepared By | Business Analyst (`eversis-analyze-materials`) |

Transcript processing was skipped: the source is a Q&A chat export, not a workshop transcript.

## Goal

A team that runs Agent Collections in Pi should be able to keep model costs predictable. This means signing in to Pi with a flat-rate subscription instead of a pay-per-token API key, and keeping each Implement session's context and token use small enough that the subscription allowance lasts.

## What the material says (business reading)

1. **Subscription sign-in instead of an API key.** When Pi signs in with a GitHub Copilot Pro / Pro+ account, usage is drawn from the monthly subscription allowance. Nothing extra is charged unless the account owner turns on paid overage (spending limit above $0). When the allowance runs out, premium models stop answering until the next billing period. The requestor reports that OpenAI/Codex Pro behaves the same way, while a Claude subscription used through Pi still bills extra usage. Anthropic API is pay-per-token and was “very expensive” for agent work.
2. **Model tiering.** Use a light model for exploration and simple edits, a mid-tier model (Sonnet class) for real logic, and the heaviest model (Opus class, Pro+ only) only for one-off hard problems — never in an agent loop.
3. **Token and context economy rules.** Proposed system rules: no blind whole-repo sweeps, read only the needed line ranges, stay on named paths, skip build artifacts and lockfiles, stop after 2 failed fix attempts and hand off, run only targeted tests, output diffs instead of whole files, batch tool calls, short commentary.
4. **Hard exclusion of heavy files.** Ignore file covering dependencies, lockfiles, build output, logs, media, secrets. Lockfiles alone can pull 100k+ tokens into one request. A “canary” test checks that the agent really cannot see excluded files.
5. **Shell guardrails.** Ask-before-run for shell commands, tool allow-lists, or a hard ban on shell reads of excluded paths.
6. **Sandboxing.** Dev Container with no sudo, dropped capabilities and CPU/RAM limits. Network isolation: none / internal-only / allow-list proxy for npm and PyPI. Verification tests for each.

## Reliability of the source

The figures come from a Gemini answer and are **not verified**. They also disagree with each other: the Pro allowance is given as both “300 premium requests” and “$15 ≈ 1,500 AI credits”, and the claims that every tool call costs one request and that Opus is Pro+ only were not checked. Plan prices, allowance sizes, the per-request overage rate, how Pi’s Copilot sign-in is metered, and whether the provider’s terms allow it must be confirmed from official GitHub / Pi docs in Research. They do not go into the ticket as facts.

## Conflicts with the current AC-14 scope and the framework core

- AC-14 **Out of Scope** already excludes “sandbox setup” and “custom model or provider catalogs”. Items 5–6 (sandbox, network isolation) conflict with that. Item 1 does not, because Pi’s built-in subscription sign-in is not a custom provider catalog.
- Several item 3 rules contradict the framework core as written: “run only the touched test file” vs `testing-and-terminal` (lint + typecheck + tests after behavior change), “no closing summaries” vs the Fine QA draft, and “stop after 2 attempts” vs Implement/Review continuity. Shipping them unchanged would break the delivery workflow in Pi.
- Item 4 overlaps the ignore-file / path-isolation work DHI-528 – DHI-530, which is **Done** (synchronized ignore files are delivered). Pi should join that mechanism.
- AC-14 is In Progress. Changing its acceptance criteria mid-flight affects work already started; sub-tasks (as with AC-21) keep the original story stable.

## Candidate scope additions (to confirm at Gate 0)

- **A — Cost-predictable model access guide for Pi (docs).** How to sign Pi in with a subscription (Copilot, Codex) instead of an API key, how to check that paid overage is off, what happens when the allowance runs out, and which model tier to pick for which Implement stage.
- **B — Token-economy rules in the Pi packaging.** A Pi-only rule set based on item 3, aligned with the framework core so tests, review and the Fine handoff still run.
- **C — Heavy-file exclusion shipped with the Pi install.** A default ignore file plus a documented canary check, built on the delivered synchronized ignore files (DHI-528 – DHI-530).
- **D — Sandbox and network isolation for Pi.** Currently out of scope. Recommended as a separate ticket, not part of AC-14.

## Open Questions

1. Which of A–D belong to AC-14?
2. Extend the AC-14 description and acceptance criteria, or add sub-tasks under AC-14?
3. Token-economy rules: Pi-only and aligned with the core, a shared core rule for all hosts, or docs-only guidance?

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-10-27. All of A–D belong to AC-14. Delivery as sub-tasks under AC-14 — **changed 2026-10-27 to standalone Tasks linked to AC-14** (requestor; AC rule: Sub-task is never the leaf). Original AC-14 story and acceptance criteria stay unchanged. Token-economy rules are **Pi-only and aligned with the framework core**. Because D is now in scope, the AC-14 Out of Scope line “sandbox setup” must be narrowed so it no longer contradicts the D Task. |
