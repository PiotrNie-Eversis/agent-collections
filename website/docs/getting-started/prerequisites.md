---
sidebar_position: 1
title: Prerequisites
---

# Prerequisites

## Agent tools

Agent Collections is **multi-agent**:

| Tool | Role in MVP |
|------|-------------|
| **[Cursor](https://cursor.com/)** | Full adapter: generated `.cursor/rules/*.mdc`, `.cursor/commands/*.md`, MCP skills |
| **Claude Code** | Full adapter: `CLAUDE.md` + `.claude/rules/*.md` from core rules, native `.claude/commands/*.md`, native `.claude/skills/`; project notes in `.claude/CLAUDE.md` |
| **OpenCode** | Placeholder only — not a full shipped adapter |

Use at least one supported tool. Teams often run **Cursor for frontend** and **Claude Code for backend** in the same monorepo with isolation (see [isolation strategy](../isolation)).

## Docker

**Docker Engine + Compose v2** are required to **run** the local **`eversis-collections`** MCP server. From the framework checkout:

```bash
docker compose build eversis-collections
```

**Node.js ≥ 18** is required only to **develop** the `eversis-collections` MCP package (`mcp/eversis-collections-mcp/`) itself — running `npm run mcp:test` or building outside Docker for debugging. It is not a prerequisite for end users who only run the server.

## Git

You need **Git** to clone this repository, pin tags, and (for teams) vendor as a **submodule**.

## MCP (for full workflow)

Jira, Figma, Playwright, Context7, and other MCP servers are **optional** but required for the full integrated experience. Configure them per [MCP setup](./mcp-setup). The skills server **`eversis-collections`** is the primary way to load skill packages in MVP (there is **no** full mirror of skills under `.cursor/skills`).

## Third-party accounts

Where prompts call external APIs (Jira, Figma, cloud providers, etc.), you need the appropriate **accounts, tokens, and network access** per your organization’s policies.

---

**Not required:** VS Code global `chat.*Locations`, `.github/prompts`, or a sibling `agent-collections` checkout. Agent Collections is self-contained.
