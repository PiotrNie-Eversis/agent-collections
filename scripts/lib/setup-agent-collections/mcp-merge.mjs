#!/usr/bin/env node
/**
 * Merge selected MCP server entries into consumer mcp.json (Agent Collections).
 */
import fs from 'node:fs';

const targetDir = process.env.MCP_TARGET_DIR?.replace(/\\/g, '/');
const distIndex = process.env.MCP_DIST_INDEX?.replace(/\\/g, '/');
const collections = process.env.MCP_COLLECTIONS_HOME?.replace(/\\/g, '/');
const useRelative = process.env.MCP_USE_RELATIVE === 'true';
const existingJson = process.env.MCP_EXISTING_JSON ?? '{}';
const selectedCsv = process.env.MCP_SELECTED_IDS ?? '';
const templatePath = process.env.MCP_TEMPLATE_PATH;
const serverListPath = process.env.MCP_SERVER_LIST_PATH;

function fail(msg) {
  console.error(`[mcp-merge] ${msg}`);
  process.exit(1);
}

if (!targetDir || !distIndex || !collections || !templatePath || !serverListPath) {
  fail('Missing required environment variables for MCP merge.');
}

const catalog = JSON.parse(fs.readFileSync(serverListPath, 'utf8'));
const allowedIds = new Set(catalog.servers);
const selected = selectedCsv
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

if (selected.length === 0) {
  fail('No MCP servers selected for merge.');
}

for (const id of selected) {
  if (!allowedIds.has(id)) {
    fail(`Unknown MCP server id: ${id}. Allowed: ${catalog.servers.join(', ')}`);
  }
}

const template = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
const templateServers = template.mcpServers ?? {};
let existing;
try {
  existing = JSON.parse(existingJson);
} catch {
  fail('Existing mcp.json is not valid JSON.');
}

const picked = {};
for (const id of selected) {
  if (!templateServers[id]) {
    fail(`Server "${id}" is not defined in framework template mcpServers.`);
  }
  picked[id] = structuredClone(templateServers[id]);
}

if (picked['eversis-collections']) {
  const distSuffix = 'mcp/eversis-collections-mcp/dist/index.js';
  let cmdPath;
  let envBlock;
  if (useRelative) {
    cmdPath = `\${workspaceFolder}/vendor/agent-collections/${distSuffix}`;
    envBlock = {};
  } else {
    cmdPath = `\${env:AGENT_COLLECTIONS_HOME}/${distSuffix}`;
    envBlock = { AGENT_COLLECTIONS_HOME: '${env:AGENT_COLLECTIONS_HOME}' };
  }
  picked['eversis-collections'] = {
    command: 'node',
    args: [cmdPath],
    type: 'stdio',
    ...(Object.keys(envBlock).length ? { env: envBlock } : {}),
  };
}

const existingServers = existing.mcpServers ?? {};
// Replace only selected keys; drop previous framework-managed ids that were deselected
const frameworkManaged = new Set(catalog.servers);
const kept = {};
for (const [id, cfg] of Object.entries(existingServers)) {
  if (frameworkManaged.has(id) && !selected.includes(id)) {
    continue; // deselection removes unless consumer re-adds manually outside catalog
  }
  kept[id] = cfg;
}
const mergedServers = { ...kept, ...picked };

const ALLOWED_TOP = new Set(['mcpServers', 'inputs']);
const cleanedTop = {};
for (const [key, value] of Object.entries(existing)) {
  if (ALLOWED_TOP.has(key)) {
    cleanedTop[key] = value;
  } else if (allowedIds.has(key)) {
    continue;
  } else {
    cleanedTop[key] = value;
  }
}

const result = {
  ...cleanedTop,
  mcpServers: mergedServers,
  inputs: cleanedTop.inputs ?? template.inputs ?? [],
};

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
