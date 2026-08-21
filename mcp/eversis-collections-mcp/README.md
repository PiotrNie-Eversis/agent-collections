# Local MCP server for **Agent Collections**

Lists, reads, and validates `eversis-*` skills under **`.ai/skills/`**. Resolves repository root via walk-up to `.ai/skills` or **`AGENT_COLLECTIONS_HOME`**.

Not published to npm. Runs via Docker Compose — build the image from the repository root:

```bash
docker compose build eversis-collections
```

For package development (not required to run the server):

```bash
cd mcp/eversis-collections-mcp
npm install
npm run build
npm test
```

Configure Cursor (or other MCP hosts) with `templates/mcp.json` / installer merge — default entry runs `docker compose -f ${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml run --rm -T eversis-collections`.
