---
sidebar_position: 13
title: GCP Storage
---

# GCP Storage MCP

**Server key:** `gcp-storage`
**Type:** stdio
**Package:** `@google-cloud/storage-mcp`

Provides access to Google Cloud Storage for managing buckets, objects, and storage configurations.

## Capabilities

- Manage Cloud Storage buckets and objects.
- Configure lifecycle policies and storage classes.
- Set access controls and IAM bindings.
- Query storage usage and costs.

## Which Agents Use It

| Agent | When |
|---|---|
| **DevOps Engineer** | Managing storage resources, configuring lifecycle policies, auditing storage costs |

## Configuration

```json
{
  "gcp-storage": {
    "command": "npx",
    "args": ["-y", "@google-cloud/storage-mcp"]
  }
}
```

## Prerequisites

- Node.js installed (for running via `npx`).
- Google Cloud SDK authenticated with storage permissions.
- Active GCP project with Cloud Storage API enabled.

## Authentication

Uses Application Default Credentials (ADC) — authenticate via `gcloud auth application-default login` or a service account key with storage permissions.
