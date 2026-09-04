---
sidebar_position: 9
title: AWS API
---

# AWS API MCP

**Server key:** `awslabs.aws-api-mcp-server`
**Type:** stdio
**Package:** `awslabs.aws-api-mcp-server@latest` (via `uvx --with mcp<2`)

Provides direct access to AWS APIs for querying live infrastructure, validating resource configurations, and performing cost analysis.

## Capabilities

- Query AWS resources across regions and services.
- Validate resource configurations against best practices.
- Check tag compliance and resource utilization.
- Support for all AWS service APIs.

## Which Agents Use It

| Agent | When |
|---|---|
| **DevOps Engineer** | Querying live infrastructure, validating Terraform plans against reality, cost audits |

## Configuration

```json
{
  "awslabs.aws-api-mcp-server": {
    "command": "uvx",
    "args": ["--with", "mcp<2", "awslabs.aws-api-mcp-server@latest"]
  }
}
```

`mcp<2` pins the MCP Python SDK (the library this server imports) to 1.x. SDK 2 renamed `McpError` to `MCPError`, and `awslabs.aws-api-mcp-server` (`1.5.4`) still imports `McpError` while declaring `mcp>=1.23.0` with no upper bound. Do not apply this pin to `awslabs.aws-documentation-mcp-server` — that package requires MCP SDK 2 (see [AWS Documentation](./aws-documentation.md)). Drop the pin here when the API package supports SDK 2.

## Prerequisites

- Python with `uvx` installed (for running the MCP server).
- AWS credentials configured (via `~/.aws/credentials`, environment variables, or IAM role).
- Appropriate IAM permissions for the services being queried.

## Authentication

Uses standard AWS credential chain — `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` environment variables, `~/.aws/credentials` file, or IAM roles when running on AWS infrastructure.
