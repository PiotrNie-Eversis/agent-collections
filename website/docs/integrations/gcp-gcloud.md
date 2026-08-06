---
sidebar_position: 11
title: GCP Gcloud
---

# GCP Gcloud MCP

**Server key:** `gcp-gcloud`
**Type:** stdio
**Package:** `@google-cloud/gcloud-mcp`

Provides access to Google Cloud operations and resource management for infrastructure automation.

## Capabilities

- Manage GCP resources across projects and regions.
- Query resource configurations and status.
- Execute GCP operations for infrastructure management.
- Support for Compute, Networking, IAM, and other GCP services.

## Which Agents Use It

| Agent | When |
|---|---|
| **DevOps Engineer** | Managing GCP infrastructure, querying resource state, cost analysis |

## Configuration

```json
{
  "gcp-gcloud": {
    "command": "npx",
    "args": ["-y", "@google-cloud/gcloud-mcp"]
  }
}
```

## Prerequisites

- Node.js installed (for running via `npx`).
- Google Cloud SDK (`gcloud`) authenticated with appropriate permissions.
- Active GCP project configured.

## Authentication

Uses Application Default Credentials (ADC) — authenticate via `gcloud auth application-default login` or a service account key.

## Troubleshooting

### `gcloud executable not found`

The MCP package (`@google-cloud/gcloud-mcp`) starts via `npx`, then shells out to the **`gcloud` CLI**. If Cloud SDK is not installed or `gcloud` is not on `PATH`, the server fails during startup/tool discovery with:

```text
Unable to start gcloud mcp server: Error: gcloud executable not found
```

This is an **environment** issue, not a broken `.cursor/mcp.json` entry. Fix:

1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
2. Confirm `gcloud` is on `PATH` (`which gcloud` / `gcloud --version`).
3. Authenticate ADC as in **Authentication** above, then restart the MCP server in Cursor.
