---
sidebar_position: 0
title: Coding Agents
---

# Coding Agents

Agent Collections keeps one process and packages it for each coding agent. The stages and human gates are the same everywhere. The tools that carry them out are not.

## In this section

- **[Claude Code](./claude-code)** — rules in `CLAUDE.md`, work delegated to sub-agents
- **[Cursor](./cursor)** — rules in `.cursor/rules/`, work delegated to sub-agents
- **[Pi](./pi)** — rules on demand, all work in one session

## How they differ

| | Claude Code | Cursor | Pi |
| --- | --- | --- | --- |
| **Rules** | Six always on, accessibility for UI files | Two always on, accessibility for UI files, four attach-only | Small core always on, full rules on demand |
| **Commands** | `.claude/commands/`, thin pointers | `.cursor/commands/`, thin pointers, or `@` attach | `.pi/prompts/`, with the Executable section copied in |
| **Skills** | `.claude/skills/` | `.cursor/skills/` | `.pi/skills/` |
| **MCP config** | `.mcp.json` | `.cursor/mcp.json` | `.pi/mcp.json` |
| **Delegation** | Sub-agents | Sub-agents | One session |
| **Independent review** | Sub-agent, in the same run | Sub-agent, in the same run | New session, started by a person |
| **Compaction by budget** | No | No | Yes, once at 50% by default |

All three are installed with the same installer. See [Installation](../getting-started/installation.mdx).
