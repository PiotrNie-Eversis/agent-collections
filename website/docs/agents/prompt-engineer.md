---
sidebar_position: 14
title: Prompt Engineer
---

# Prompt Engineer Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-prompt-engineer.mdc` — **not shipped** in agent-collections; behavior via [Engineer Prompt](../prompts/internal/engineer-prompt) delegate.  
**Delegated prompt:** [Engineer prompt](../prompts/internal/engineer-prompt) (via **`@eversis-implement`** — [Implement](../prompts/public/implement))

This role designs, optimizes, and secures **application LLM prompts** — system prompts, user templates, RAG injection patterns, tool-calling instructions, and classification/extraction prompts consumed by your product at runtime.

It does **not** own Cursor packaging artifacts (`.mdc` rules, repo prompt library, `SKILL.md` authoring for the IDE). That belongs to the [Cursor customization engineer](./cursor-customization-engineer).

## Responsibilities

- Prompt structure: roles, delimiters, output contracts.
- Optimization for clarity, token use, quality, and consistency.
- New prompts from requirements with explicit constraints and examples.
- Injection defenses and validation patterns.
- Evaluation: comparisons, metrics, and edge cases.

## Behaviors

- **Prompt-first** — Hands integration work back to software engineering when appropriate.
- **Security-first** — Treat prompt injection as a default threat.
- **Provider-agnostic patterns** — Portable across major LLM APIs.
- **Plan-driven** — Matches the approved implementation plan.

## Tools (typical)

| Tool                     | Usage                                |
| ------------------------ | ------------------------------------ |
| **Context7**             | Provider and framework documentation |
| **Sequential Thinking**  | Multi-step prompts, threat modeling  |
| **Cursor Agent**         | Read and edit prompt sources         |
| **Ask Questions / chat** | Clarify domain terminology           |
| **Todo**                 | Track prompt-delivery steps          |

## Skills (Eversis naming)

- [eversis-engineering-prompts](../skills/prompt-engineering)
- [eversis-technical-context-discovering](../skills/technical-context-discovery)
- [eversis-code-reviewing](../skills/code-review) (when reviewing prompt-related code)

## Delegation

- **Orchestrated:** Engineering Manager routes LLM prompt tasks during **`eversis-implement`** ([Implement](../prompts/public/implement)).
- **Focused:** Attach **`@eversis-engineer-prompt`** ([Engineer prompt](../prompts/internal/engineer-prompt)) when the task is prompt-only work inside an implement cycle.
