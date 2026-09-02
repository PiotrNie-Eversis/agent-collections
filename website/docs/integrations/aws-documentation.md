---
sidebar_position: 10
title: AWS Documentation
---

# AWS Documentation MCP

**Server key:** `awslabs.aws-documentation-mcp-server`
**Type:** stdio
**Package:** `awslabs.aws-documentation-mcp-server@latest` (via `uvx`)

Provides access to AWS service documentation and reference materials for accurate infrastructure decisions and best practices.

## Capabilities

- Search AWS documentation for any service.
- Retrieve API references, configuration guides, and best practices.
- Look up service limits, pricing models, and feature availability.
- Find solutions to specific AWS errors and issues.

## Which Agents Use It

| Agent | When |
|---|---|
| **DevOps Engineer** | Looking up AWS service documentation, verifying best practices, understanding service limits |

## Configuration

```json
{
  "awslabs.aws-documentation-mcp-server": {
    "command": "uvx",
    "args": ["awslabs.aws-documentation-mcp-server@latest"],
    "env": {
      "FASTMCP_LOG_LEVEL": "ERROR",
      "AWS_DOCUMENTATION_PARTITION": "aws"
    }
  }
}
```

This package (`1.2.0`) depends on `mcp[cli]>=2.0.0,<3.0.0`. Do not add `--with mcp<2` — that pin conflicts with SDK 2 and uvx fails to resolve. The AWS API MCP server is different: it still needs `mcp<2` (see [AWS API](./aws-api.md)).

## Prerequisites

- Python with `uvx` installed (for running the MCP server).

## Authentication

No authentication required. The documentation server accesses publicly available AWS documentation.
