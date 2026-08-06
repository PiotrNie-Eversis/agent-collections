---
sidebar_position: 3
title: MCP Setup
---

# MCP Setup

## At a glance

Configure **Model Context Protocol (MCP)** servers so Agent can call tools (skills, Jira, Figma, docs, browsers).

**Skills server (required for skill packages):**

1. Set the framework home (no `CURSOR_COLLECTIONS_HOME` required):

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
```

2. Build the local package:

```bash
cd "$AGENT_COLLECTIONS_HOME"
npm run mcp:install && npm run mcp:build
```

3. Point MCP at the built entry (installer merges this into `.cursor/mcp.json`):

```json
"eversis-collections": {
  "command": "node",
  "args": [
    "${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js"
  ]
}
```

4. Enable **`eversis-collections`** in your IDE MCP settings and restart the agent host if needed.

### Env cutover from Cursor Collections

| Legacy (Cursor Collections) | Agent Collections |
|--------|-------------------|
| `CURSOR_COLLECTIONS_HOME` | **`AGENT_COLLECTIONS_HOME`** |
| Path into `cursor-collections/mcp/...` | Path into **`agent-collections/mcp/...`** |

Do not keep both env vars pointing at different frameworks for the same skills server unless you intentionally dual-channel (advanced). For a clean cutover, export only `AGENT_COLLECTIONS_HOME`.

### What each MCP is used for

- **eversis-collections** — list/get/validate skills from `.ai/skills/`; optional Word `.docx` tools when BA Docs is in scope for the consumer.
- **Atlassian** — Jira and Confluence for implement, review, and research.
- **Figma** — design context for UI implement and UI review.
- **Context7** — up-to-date library documentation.
- **Playwright** — browser interactions and E2E-style checks.
- **Sequential Thinking** — structured reasoning for complex analysis.
- **PDF Reader** — workshop PDFs for analyze-materials.
- **AWS / GCP MCPs** — cloud APIs and docs for DevOps prompts (optional).

### Verify

After restart, open Agent and confirm tools appear (e.g. `eversis_skills_list`). If tools are missing: rebuild MCP, confirm `AGENT_COLLECTIONS_HOME` is visible to the IDE process (launch from a terminal that exports it, or set a system env), and re-run the installer with `--build-mcp`.

## Installer merge

```bash
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --mcp-servers=eversis-collections,context7,figma,atlassian
```

Allowed ids match the installer MCP allowlist (see `scripts/setup-agent-collections.sh --help` and template `templates/mcp.json`).

## Claude Code note

Claude MVP uses **`CLAUDE.md`** plus skills via MCP / reading `.ai/skills` — not a full Cursor MCP parity matrix. Prefer documenting which MCP servers your team enables in the consumer stack rule.

## Next

- [Quick wins](./quick-wins)
- [Installation](./installation)
- [Start here](./start-here)
