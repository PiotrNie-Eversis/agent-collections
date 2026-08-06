---
sidebar_position: 1
title: Integrations Overview
---

# Integrations Overview

Agent Collections integrates with **11 external services** via the **Model Context Protocol (MCP)**, plus **one local repository server** that is not a third-party SaaS.

## Local server: Agent Collections MCP

Start here: build and enable **`eversis-collections`** before optional third-party MCPs. It is the **local first-party bridge** for skills, Word `.docx` tools, and allowlisted repo scripts — see [Agent Collections MCP](./eversis-collections) for setup, the grouped tool inventory, and workflow mapping.

Configured in **`.cursor/mcp.json`** alongside the integrations below.

## External services (11)

These integrations bring Jira, Figma, documentation, browser automation, structured reasoning, document reading, and cloud provider APIs directly into your **Cursor** session — enabling the end-to-end product engineering workflow.

## What is MCP?

The Model Context Protocol allows **Cursor** (and compatible hosts) to call external tools as part of a workflow. Each MCP server exposes specific capabilities (search, navigate, execute) that the agent can use to gather information or perform actions.

## Configured Servers

| Server | Type | Purpose | Used By |
|---|---|---|---|
| [Agent Collections MCP](./eversis-collections) | stdio | Skills, Word `.docx` tools, allowlisted repo scripts | All agents (skills); BA Docs prompts; contributors |
| [Atlassian](./atlassian) | HTTP | Jira & Confluence integration | BA, Architect, CR, CE, E2E, SE |
| [Figma](./figma) | HTTP | Design extraction and verification | BA, Architect, SE, UI Reviewer, CR, E2E |
| [Context7](./context7) | stdio | Library documentation search | Architect, SE, CR, UI Reviewer, E2E, DevOps, customization |
| [Playwright](./playwright) | stdio | Browser automation and UI testing | SE, UI Reviewer, E2E |
| [Sequential Thinking](./sequential-thinking) | stdio | Structured reasoning for complex problems | BA, Architect, SE, CR, E2E, UI Reviewer, DevOps, customization |
| [PDF Reader](./pdf-reader) | stdio | PDF document extraction | BA, CE, Architect |
| [AWS API](./aws-api) | stdio | AWS infrastructure automation and resource management | DevOps |
| [AWS Documentation](./aws-documentation) | stdio | AWS service documentation and reference | DevOps |
| [GCP Gcloud](./gcp-gcloud) | stdio | Google Cloud operations and management | DevOps |
| [GCP Observability](./gcp-observability) | stdio | Google Cloud monitoring and observability | DevOps |
| [GCP Storage](./gcp-storage) | stdio | Google Cloud Storage integration | DevOps |

## Configuration

All servers are configured in **`.cursor/mcp.json`** at the repository root (Cursor [project MCP configuration](https://cursor.com/docs/mcp)):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "type": "stdio"
    },
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "type": "stdio"
    },
    "figma": {
      "url": "https://mcp.figma.com/mcp",
      "type": "http"
    },
    "atlassian": {
      "url": "https://mcp.atlassian.com/v1/mcp",
      "type": "http"
    },
    "pdf-reader": {
      "command": "npx",
      "args": ["@sylphx/pdf-reader-mcp"],
      "type": "stdio"
    },
    "awslabs.aws-api-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-api-mcp-server@latest"]
    },
    "awslabs.aws-documentation-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_DOCUMENTATION_PARTITION": "aws",
        "MCP_USER_AGENT": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
      }
    },
    "gcp-gcloud": {
      "command": "npx",
      "args": ["-y", "@google-cloud/gcloud-mcp"]
    },
    "gcp-observability": {
      "command": "npx",
      "args": ["-y", "@google-cloud/observability-mcp"]
    },
    "gcp-storage": {
      "command": "npx",
      "args": ["-y", "@google-cloud/storage-mcp"]
    },
    "eversis-collections": {
      "command": "node",
      "args": ["mcp/eversis-collections-mcp/dist/index.js"],
      "type": "stdio"
    }
  },
  "inputs": []
}
```

## Server Types

- **stdio** — Runs locally via `npx` or `uvx`. The MCP server starts as a child process.
- **HTTP** — Connects to a remote API endpoint. Requires authentication (handled by the service).
