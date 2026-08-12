#!/usr/bin/env node
/**
 * Merge selected MCP server entries into consumer mcp.json (Agent Collections).
 */
import fs from 'node:fs';

const host = process.env.MCP_HOST || 'cursor';
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
  if (host === 'claude') {
    // Claude Code only expands ${VAR} / ${VAR:-default} — no ${env:X} — and
    // GUI-launched hosts don't reliably inherit shell profile exports, so
    // AGENT_COLLECTIONS_HOME is always set explicitly on this entry's own
    // env block rather than assumed from the ambient process environment.
    if (useRelative) {
      const root = '${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections';
      cmdPath = `${root}/${distSuffix}`;
      envBlock = { AGENT_COLLECTIONS_HOME: root };
    } else {
      cmdPath = `\${AGENT_COLLECTIONS_HOME}/${distSuffix}`;
      envBlock = { AGENT_COLLECTIONS_HOME: collections };
    }
  } else if (useRelative) {
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

if (host === 'claude') {
  // Claude Code MVP syntax: ${env:X} isn't recognised (only ${X} / ${X:-d}),
  // and ${workspaceFolder} is a VS Code/Cursor-only variable — rewrite any
  // template-sourced server (context7, figma, aws/gcp entries, …) that still
  // uses either form. eversis-collections above is already Claude-native and
  // passes through unchanged.
  const rewriteClaudeSyntax = (value) => {
    if (typeof value === 'string') {
      return value
        .replace(/\$\{env:([^}]+)\}/g, '${$1}')
        .replace(/\$\{workspaceFolder\}/g, '${CLAUDE_PROJECT_DIR:-.}');
    }
    if (Array.isArray(value)) {
      return value.map(rewriteClaudeSyntax);
    }
    if (value && typeof value === 'object') {
      return Object.fromEntries(
        Object.entries(value).map(([k, v]) => [k, rewriteClaudeSyntax(v)]),
      );
    }
    return value;
  };
  for (const [id, cfg] of Object.entries(picked)) {
    if (id === 'eversis-collections') continue;
    picked[id] = rewriteClaudeSyntax(cfg);
  }
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
if (host === 'claude') {
  // Claude Code's .mcp.json ignores "inputs" (a VS Code/Cursor-only key) —
  // drop it even if it survived from a pre-existing hand-edited file.
  delete result.inputs;
}

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
