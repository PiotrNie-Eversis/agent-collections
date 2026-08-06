---
sidebar_position: 8
title: PDF Reader
---

# PDF Reader MCP

**Server key:** `pdf-reader`
**Type:** stdio
**Command:** `npx @sylphx/pdf-reader-mcp`

Provides PDF document extraction capabilities for reading and processing PDF files — workshop materials, design specifications, technical documentation, and other documents.

## Capabilities

- Extract text content from PDF documents.
- Read PDF metadata (title, author, page count).
- Process multi-page documents for structured information extraction.

## Which Agents Use It

| Agent | When |
|---|---|
| **Business Analyst** | Extracting content from workshop materials, design briefs, and meeting notes in PDF format |
| **Context Engineer** | Reading technical documentation, requirement specifications, and reference materials |
| **Architect** | Processing architecture documents, technical specifications, and design documentation |

## Configuration

```json
{
  "pdf-reader": {
    "command": "npx",
    "args": ["@sylphx/pdf-reader-mcp"],
    "type": "stdio"
  }
}
```

## Usage Notes

- The PDF Reader runs locally via `npx` as a stdio MCP server.
- Provide file paths to PDF documents for extraction.
- Works well with the Business Analyst workflow for processing workshop transcripts and design documents that are only available in PDF format.
