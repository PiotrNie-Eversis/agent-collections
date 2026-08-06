---
sidebar_position: 8
title: Cursor customization engineer
---

# Cursor customization engineer

**Rule pack (canonical):** `.cursor/rules/eversis-role-cursor-customization.mdc` (optional; add when you specialize this role)  
**Typical prompts:** `@eversis-create-custom-agent` ([Create custom agent](../prompts/public/create-custom-agent)), `@eversis-create-custom-skill` ([Create custom skill](../prompts/public/create-custom-skill)), `@eversis-create-custom-prompt` ([Create custom prompt](../prompts/public/create-custom-prompt)), `@eversis-create-custom-instructions` ([Create custom instructions](../prompts/public/create-custom-instructions))

This role designs, creates, reviews, and improves **vendor-neutral multi-agent packaging**: project rules (`.mdc`), Agent Skills (`SKILL.md`), prompt markdown under **`.cursor/prompts/`**, and high-level project guidance (`AGENTS.md`, stack rules).

## Responsibilities

- Creating, reviewing, and improving **rules** (`.cursor/rules/*.mdc`), **skills** (`SKILL.md`), **prompts** (`.cursor/prompts/**/eversis-*.md`), and **project instructions** (conventions in rules, `AGENTS.md`, and related docs).
- Applying prompt-engineering practice: clarity, structure, token efficiency, progressive disclosure.
- Designing context architecture: what information lives in always-on rules vs attach-on-demand prompts vs skills, and with what priority.
- Enforcing strict separation of concerns between customization types.
- Advising on tool and MCP server configuration for Cursor Agent and prompts.
- Optimizing signal-to-noise ratio within context windows.

## Separation of concerns

| Artifact | Role | Contains |
| --- | --- | --- |
| **Rule** (`.cursor/rules/*.mdc`) | WHO + guardrails | Persona-agnostic behaviors, globs, always-on or scoped standards |
| **Skill** (`SKILL.md`) | HOW | Repeatable procedures, checklists, domain playbooks |
| **Prompt** (`.cursor/prompts/**/eversis-*.md`) | WHAT | Workflow entry, steps, attachments users should include |
| **Project docs / AGENTS.md** | WHERE | Pointers to framework, conventions, and repo layout |

When content lands in the wrong layer, this role identifies the violation and moves or splits it.

## Key design principles

- **Token efficiency** — Every token competes for context space; add only what the model cannot infer from the repo.
- **Progressive disclosure** — Discovery (~100 tokens): name + short description. Activation (full body, typically under ~5000 tokens when expanded). Resources on demand: templates and examples.
- **Structural reliability** — Prefer explicit sections and boundaries (including tag-like blocks where helpful) so Agent mode parses content consistently; use Markdown for sequential narrative.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Context7** | Cursor, rules/skills layout, MCP server and framework documentation |
| **Sequential Thinking** | Design packaging architecture, analyze multi-artifact interactions, evaluate trade-offs |
| **Web fetch** | Fetch external documentation and reference materials |
| **Mermaid diagrams** | Render architecture and workflow diagrams when documenting flows |
| **Cursor Agent** | Read, modify, and search workspace files |
| **Todo** | Track task progress with structured checklists |

## Skills Loaded

- [eversis-creating-agents](../skills/creating-agents) — Methodology for defining roles in Cursor (rules/prompts); templates and validation checklist.
- [eversis-creating-skills](../skills/creating-skills) — Naming conventions, body structure, progressive disclosure patterns.
- [eversis-creating-prompts](../skills/creating-prompts) — Prompt authoring workflow, templates, workflow-focused guidelines.
- [eversis-creating-instructions](../skills/creating-instructions) — Templates and decision framework for project instructions vs skill placement.
- [eversis-technical-context-discovering](../skills/technical-context-discovery) — Understand existing customization patterns in the project.
- [eversis-codebase-analysing](../skills/codebase-analysis) — Analyze existing packaging files and identify patterns.

## Related

For multi-phase customization (research → create → review), use the [Cursor customization orchestrator](./cursor-customization-orchestrator) pattern and public [Create custom agent](../prompts/public/create-custom-agent) (and related create-custom prompts).
