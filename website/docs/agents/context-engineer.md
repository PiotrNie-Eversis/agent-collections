---
sidebar_position: 3
title: Context Engineer
---

# Context Engineer Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-context-engineer.mdc` — **not shipped** in agent-collections; behavior via delegated [Research](../prompts/internal/research) prompt.  
**Delegated prompt:** [Research](../prompts/internal/research) (via `@eversis-implement` — [Implement](../prompts/public/implement) — and Engineering Manager orchestration)

The Context Engineer gathers requirements, analyzes processes, and produces a research artifact before planning and implementation.

## Responsibilities

- Gathering all information related to a task from the codebase, Jira, Confluence, Figma, and other sources.
- Analyzing the task thoroughly, including parent tasks and subtasks.
- Checking external links and Confluence pages linked to the task.
- Reviewing Figma designs when linked to the task.
- Identifying ambiguities and missing information, asking for clarification.
- Exploring industry standards and domain-specific best practices.

## What It Produces

A `.research.md` document containing:

- **Task summary** — Clear description of what needs to be done.
- **Requirements and acceptance criteria** — Detailed functional requirements.
- **User stories and key flows** — How users interact with the feature.
- **Assumptions** — What the agent assumed based on available information.
- **Open questions** — Unresolved ambiguities that need stakeholder input.
- **Suggested next steps** — Recommendations for the planning phase.

## What It Does NOT Do

- Implementation detail or full technical specifications.
- Implementation plans, deployment plans, or test plans (Architect phase).

## Tool Access

| Tool | Usage |
| --- | --- |
| **Atlassian** | Gather requirements from Jira and Confluence, search for related issues |
| **Figma** | Review designs, understand functional intent, identify missing states |
| **PDF Reader** | Read and extract content from PDF requirement documents |
| **Sequential Thinking** | Analyze complex business rules, identify edge cases, map dependencies |
| **Cursor Agent** | Read code and docs, search the workspace for usages and related files, edit research output (e.g. `.research.md`) |
| **Todo** | Track research progress with structured checklists |

## Skills Loaded

- [eversis-task-analysing](../skills/task-analysis) — Analyze task descriptions, perform gap analysis, expand context, gather information from multiple sources.

## Handoffs

Returns to Engineering Manager orchestration; next step is planning via [Plan](../prompts/internal/plan) and the [Architect](./architect), with **human approval** after research per `eversis-agent-core.mdc`.
