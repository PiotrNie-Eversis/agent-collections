---
sidebar_position: 12
title: Customization Artifact Reviewer (internal)
---

# Customization Artifact Reviewer Agent *(internal)*

**Type:** Internal worker — not a user-facing entry point.

Review specialist that evaluates **Cursor customization** artifacts — `.cursor/rules/*.mdc`, `.cursor/prompts/**/eversis-*.md`, `SKILL.md`, and related project instructions (`AGENTS.md`, stack rules) — against best practices, workspace consistency, and structural correctness. Returns structured review findings categorized by severity. **Read-only:** does not modify files.

## Responsibilities

- Evaluate Cursor customization artifacts against quality criteria provided in the delegation prompt.
- Compare artifacts against existing workspace patterns for consistency in naming, structure, formatting, and tool configuration.
- Identify separation-of-concerns violations — flag when content crosses rule vs skill vs prompt vs project-doc boundaries.
- Produce structured review findings categorized by severity with specific, actionable recommendations.

## Review Dimensions

| Dimension | What it checks |
| --- | --- |
| **Structural correctness** | Valid YAML frontmatter where used, required sections present, proper tag usage |
| **Best practice adherence** | Token efficiency, progressive disclosure, no redundant content |
| **Workspace consistency** | Naming conventions, tool lists, section ordering, formatting |
| **Separation of concerns** | Rule (WHO + guardrails), skill (HOW), prompt (WHAT), project docs (WHERE) boundaries |
| **Tool configuration** | MCP and tool lists match the stated role; appropriate access boundaries |

## Boundaries

- Does not modify any files — reports findings only.
- Does not propose alternative designs or architectures.
- Does not limit findings based on fixability — reports all issues found.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Cursor Agent** | Examine artifacts, compare against workspace patterns, find cross-references, check consistency across files |

## Invocation

This worker is not a user-facing entry point. It is used inside the [Cursor customization orchestrator](./cursor-customization-orchestrator) flow as part of multi-step customization workflows — not as a standalone `@` prompt.
