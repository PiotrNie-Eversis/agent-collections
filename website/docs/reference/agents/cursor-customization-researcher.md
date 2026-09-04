---
sidebar_position: 13
title: Customization Researcher Agent (internal)
---

# Customization Researcher Agent *(internal)*

**Type:** Internal worker — not a user-facing entry point.

Research specialist that gathers, analyzes, and summarizes information from codebases and documentation for **Cursor packaging** work — `.cursor/rules`, **`.cursor/prompts/`** (including `eversis-*.md` files), Agent Skills (`SKILL.md`), and related project docs. Returns structured research summaries. **Read-only:** does not create or modify files.

## Responsibilities

- Analyze codebase structure, existing rules, `eversis-*` prompts, skills (`SKILL.md`), instruction patterns in rules / `AGENTS.md`, and workspace patterns.
- Fetch and summarize external documentation (Cursor docs, MCP server docs, best practices).
- Identify patterns, conventions, and inconsistencies across multiple files.
- Return structured, concise findings organized by topic with file paths for traceability.

## Output Format

Every research response includes:

1. **Summary** — 2–3 sentences answering the research question directly.
2. **Key findings** — Organized by topic with file paths.
3. **Patterns and observations** — Cross-cutting patterns and notable conventions.
4. **Gaps or ambiguities** — Areas that could not be found or are uncertain.

## Boundaries

- Does not create or modify any files.
- Does not make design decisions or propose implementations.
- Does not include raw file contents — always synthesizes and summarizes.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Cursor Agent** | Read specific files after discovery; search the repo for patterns, names, and content |
| **Context7** | Library-specific documentation lookup, API specs, MCP server capabilities |
| **Web fetch** | Fetch external documentation (Cursor docs, MCP docs, best practices) |

## Invocation

This worker is not a user-facing entry point. It is used inside the [Cursor customization orchestrator](./cursor-customization-orchestrator) flow as part of multi-step customization workflows — not as a standalone `@` prompt.
