---
sidebar_position: 1
title: Prerequisites
---

# Prerequisites

## Agent tools

Agent Collections is **multi-agent**:

| Tool | Role in MVP |
|------|-------------|
| **[Cursor](https://cursor.com/)** | Full adapter: generated `.cursor/rules/*.mdc`, MCP skills, attachable prompts |
| **Claude Code** | Shipped adapter: root `CLAUDE.md` from core rules; skills via MCP / `AGENTS.md` |
| **OpenCode** | Placeholder only — not a full shipped adapter |

Use at least one supported tool. Teams often run **Cursor for frontend** and **Claude Code for backend** in the same monorepo with isolation (see [isolation strategy](../isolation)).

## Node.js

**Node.js ≥ 18** is required to build the local **`eversis-collections`** MCP package (`mcp/eversis-collections-mcp/`). From the framework checkout:

```bash
npm run mcp:install && npm run mcp:build
```

## Git

You need **Git** to clone this repository, pin tags, and (for teams) vendor as a **submodule**.

## MCP (for full workflow)

Jira, Figma, Playwright, Context7, and other MCP servers are **optional** but required for the full integrated experience. Configure them per [MCP setup](./mcp-setup). The skills server **`eversis-collections`** is the primary way to load skill packages in MVP (there is **no** full mirror of skills under `.cursor/skills`).

## Third-party accounts

Where prompts call external APIs (Jira, Figma, cloud providers, etc.), you need the appropriate **accounts, tokens, and network access** per your organization’s policies.

---

**Not required:** VS Code global `chat.*Locations`, `.github/prompts`, or a sibling `agent-collections` checkout. Agent Collections is self-contained.
