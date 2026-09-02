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

2. Build the Docker Compose image (requires Docker Engine + Compose v2 — see [Prerequisites](./prerequisites)):

```bash
cd "$AGENT_COLLECTIONS_HOME"
docker compose build eversis-collections
```

3. Point MCP at the Compose-based entry (the installer merges this into `.cursor/mcp.json` for Cursor and `.mcp.json` for Claude Code, translating syntax per host):

```json
"eversis-collections": {
  "command": "docker",
  "args": [
    "compose",
    "-f",
    "${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml",
    "run",
    "--rm",
    "-T",
    "eversis-collections"
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

- **eversis-collections** — list/get/validate skills from `.ai/skills/`; read/list/sync **domain context** (durable, cross-task knowledge — see [Domain Context (SSOT)](../domain-context)) from the consumer project's own `docs/context/`; optional Word `.docx` tools when BA Docs is in scope for the consumer.
- **Atlassian** — Jira and Confluence for implement, review, and research.
- **Figma** — design context for UI implement and UI review.
- **Context7** — up-to-date library documentation.
- **Playwright** — browser interactions and E2E-style checks.
- **Sequential Thinking** — structured reasoning for complex analysis.
- **PDF Reader** — workshop PDFs for analyze-materials.
- **AWS / GCP MCPs** — cloud APIs and docs for DevOps prompts (optional).

### Domain context needs the project volume, not just the framework volume

If `eversis_context_get/list/sync` come back empty, check this first.

The `eversis-collections` container mounts two separate **volumes** (folders shared between your machine and the container):

- *`./repo`* — the framework checkout. Always available.
- *`${PWD}/workspace`* — your consumer project. Resolved from the working directory of the process that *starts* the container — not from `AGENT_COLLECTIONS_HOME`.

Domain-context tools read and write `docs/context/` through `/workspace`, never `/repo`.

:::caution Silent failure, not an error
If your IDE starts the MCP process from somewhere other than your consumer project's root, these tools mount the wrong directory — you get missing or empty results, with no error to flag it. This also means one session can never cover more than one repo — see [Working across the whole group yourself](../domain-context#working-across-the-whole-group-yourself) if you operate across several repos in the same GitLab group.
:::

### Verify

After restart, open Agent and confirm tools appear (e.g. `eversis_skills_list`). If tools are missing: rebuild the Docker image (`docker compose build eversis-collections`), confirm Docker is visible to the IDE process, confirm `AGENT_COLLECTIONS_HOME` resolves to the framework checkout (launch from a terminal that exports it, or set a system env), and re-run the installer with `--build-mcp`.

## Installer merge

```bash
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --mcp-servers=eversis-collections,context7,figma,atlassian
```

Allowed ids match the installer MCP allowlist (see `scripts/setup-agent-collections.sh --help` and template `templates/mcp.json`).

:::caution User vs workspace (Cursor)
Cursor loads **both** `~/.cursor/mcp.json` (Settings badge **User**) and the project `.cursor/mcp.json` (badge = folder name). The installer writes the catalog into the **project** file. If you also keep the same ids in User config, each server appears twice and `eversis-collections` may start from the wrong tree.

Keep User MCP for personal tools only. Do not merge `templates/mcp.json` into User config when the installer already wrote the workspace file. The installer warns on overlap and **does not** edit `~/.cursor/mcp.json` — Command Palette → **MCP: Open User Configuration** to remove duplicate catalog ids.
:::

## Claude Code note

Claude Code has MCP config parity with Cursor: the installer writes a root **`.mcp.json`** with the same servers, using Claude-native syntax (`${VAR}` / `${VAR:-default}`, no `${env:...}`). The **`eversis-collections`** entry runs `docker compose ... run --rm -T eversis-collections`, not a bare `node` process — Docker is required, Node.js is not. Skills additionally resolve **natively** via `.claude/skills/` (linked by the installer), not only through MCP. Document which MCP servers your team enables in `.claude/CLAUDE.md`.

## Next

- [Quick wins](./quick-wins)
- [Installation](./installation)
- [Start here](./start-here)
