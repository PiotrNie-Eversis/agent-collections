# Local MCP server for **Agent Collections**

Lists, reads, and validates `eversis-*` skills under **`.ai/skills/`**. Resolves repository root via walk-up to `.ai/skills` or **`AGENT_COLLECTIONS_HOME`**.

Not published to npm — build from this repository:

```bash
cd mcp/eversis-collections-mcp
npm install
npm run build
npm test
```

Configure Cursor (or other MCP hosts) with `templates/mcp.json` / installer merge — default entry uses `${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js`.
