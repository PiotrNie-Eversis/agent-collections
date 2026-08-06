---
sidebar_position: 11
title: Customization Artifact Creator (internal)
---

# Customization Artifact Creator Agent *(internal)*

**Type:** Internal worker — not a user-facing entry point.

Creation specialist that builds and modifies **Cursor customization** artifacts — `.cursor/rules/*.mdc`, `.cursor/prompts/**/eversis-*.md`, `SKILL.md`, and related project guidance (`AGENTS.md`, stack rules) — based on detailed specifications from the orchestrator. Executes creation tasks only; does not perform open-ended research or final sign-off review.

## Responsibilities

- Create and modify Cursor customization artifacts based on specifications provided in the delegation prompt.
- Apply the relevant creation skills (`eversis-creating-agents`, `eversis-creating-skills`, `eversis-creating-prompts`, `eversis-creating-instructions`) based on the artifact type.
- Follow workspace conventions — match structure, formatting, and patterns of existing files.
- Validate created files before returning — ensure YAML frontmatter is valid where used, required sections are present, and the file follows the skill's checklist.

## Boundaries

- Does not make design decisions beyond what the specification provides.
- Does not conduct research — all information must be in the specification or existing workspace files.
- Does not review or critique specifications — review is a separate worker's responsibility.
- Does not propose alternative approaches — the orchestration step is the design authority.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Cursor Agent** | Check existing patterns before creating artifacts; find references and consistency impacts; create new files or modify existing ones |
| **Todo** | Track multi-file creation tasks |

## Skills Loaded

- `eversis-creating-agents` — Agent file template, structural conventions, and validation checklist (applied to Cursor rules / role packaging as appropriate).
- `eversis-creating-skills` — Naming conventions, body structure, progressive disclosure patterns.
- `eversis-creating-prompts` — Prompt file template, workflow focus guidelines, validation checklist.
- `eversis-creating-instructions` — Templates for repository-level and granular instruction files, decision framework.

## Invocation

This worker is not a user-facing entry point. It is used inside the [Cursor customization orchestrator](./cursor-customization-orchestrator) flow as part of multi-step customization workflows — not as a standalone `@` prompt.
