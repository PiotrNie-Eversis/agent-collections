---
sidebar_position: 12
title: GCP Observability
---

# GCP Observability MCP

**Server key:** `gcp-observability`
**Type:** stdio
**Package:** `@google-cloud/observability-mcp`

Provides access to Google Cloud monitoring, logging, and observability services for infrastructure and application monitoring.

## Capabilities

- Query Cloud Monitoring metrics and time series data.
- Search and analyze Cloud Logging entries.
- Manage alerting policies and notification channels.
- Access uptime check configurations and results.

## Which Agents Use It

| Agent | When |
|---|---|
| **DevOps Engineer** | Setting up monitoring, analyzing metrics, configuring alerts, debugging production issues |

## Configuration

```json
{
  "gcp-observability": {
    "command": "npx",
    "args": ["-y", "@google-cloud/observability-mcp"]
  }
}
```

## Prerequisites

- Node.js installed (for running via `npx`).
- Google Cloud SDK authenticated with monitoring permissions.
- Active GCP project with Cloud Monitoring and Cloud Logging enabled.

## Authentication

Uses Application Default Credentials (ADC) — authenticate via `gcloud auth application-default login` or a service account key with monitoring permissions.
