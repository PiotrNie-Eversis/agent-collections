---
sidebar_position: 9
title: Cursor customization orchestrator
---

# Cursor customization orchestrator *(experimental)*

**Packaging:** Composed workflow using **`@eversis-create-custom-agent`** ([Create custom agent](../prompts/public/create-custom-agent)) and related create-custom prompts, with explicit human checkpoints between phases.

The orchestrator pattern coordinates **large Cursor customization** efforts. It **decomposes** work into focused subtasks, **delegates** to workers (fresh context per step), and **synthesizes** results—so complex work does not collapse into one long, drifting Agent thread.

## When to use it

Prefer this pattern over a single long chat when work requires:

- Creating new packaging from scratch (**research → design → create → review**), for example a new rule, skill, or prompt system.
- Auditing all customization artifacts for consistency.
- Designing **multi-rule / multi-prompt** systems (or other multi-step packaging that behaves like a small “multi-agent” workflow).
- Any task that naturally splits into **research, authoring, and review**.

For smaller or medium tasks, the [Cursor customization engineer](./cursor-customization-engineer) alone is often enough.

## How it works

Each phase uses a focused instruction (prompt + optional rule attachment). Typical workers:

1. **Customization researcher** — Analyzes existing `.cursor/rules`, `.cursor/prompts/`, skills, and related docs; reads references; extracts patterns. **Read-only** (summaries, not bulk paste of sources).
2. **Customization artifact creator** — Creates or updates files from **fully specified** requirements in the delegation prompt.
3. **Customization artifact reviewer** — Validates quality, consistency, and best practices; **read-only** review output.

The standard flow is: **Research → Design decisions → Create → Review → Fix (if needed)**.

The orchestration model keeps **design decisions** with you and the lead turn in Agent mode; workers receive **tight, standalone** task prompts.

## Key principles

- **Context is precious** — The orchestration thread should carry user intent, decisions, and **synthesized** summaries—not full raw dumps from research.
- **Delegate execution, retain judgment** — Workers execute; you (or the lead step) own design. Important outputs are **validated** (especially after Create).
- **Prompt is the interface** — Each worker step gets a clear delegation prompt and minimal reliance on unrelated chat history.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Sequential Thinking** | Decompose complex tasks, evaluate design trade-offs |
| **Cursor Agent** | Read and search the workspace; advance phases and apply follow-ups |
| **Todo** | Track orchestration progress with structured checklists |

## Workers

| Worker | Documentation | When |
| --- | --- | --- |
| Research | [Customization researcher](./cursor-customization-researcher) | Existing files, patterns, docs |
| Create | [Customization artifact creator](./cursor-customization-artifact-creator) | Authoring or editing packaging files |
| Review | [Customization artifact reviewer](./cursor-customization-artifact-reviewer) | Quality and consistency checks |
| Engineer | [Cursor customization engineer](./cursor-customization-engineer) | Moderately complex subtasks that do not decompose cleanly into research / create / review |

## Flow

```text
User goal
    │
    ▼
┌──────────────────┐
│  Orchestration    │ ← Design decisions / approvals
└────────┬─────────┘
         │
    ┌────┼────────────┐
    ▼    ▼            ▼
Research → Create → Review
    │        │          │
    └────────┴──────────┘
              │
              ▼
    Synthesized results → User
```
