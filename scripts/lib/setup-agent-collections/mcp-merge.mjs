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
  const composeFile = 'docker-compose.yml';
  // Vendored Claude: do not put ${CLAUDE_PROJECT_DIR:-.} in committed JSON —
  // config-time ${VAR} expansion leaves it empty on the VS Code extension.
  // Use bash -c with a bare $CLAUDE_PROJECT_DIR token (no braces) plus an
  // upward walk so the spawn env / cwd can still find the wrapper script.
  if (host === 'claude' && useRelative) {
    const locator = [
      'if [ -n "$CLAUDE_PROJECT_DIR" ] && [ -f "$CLAUDE_PROJECT_DIR/scripts/run-eversis-collections-mcp.sh" ]; then',
      'exec "$CLAUDE_PROJECT_DIR/scripts/run-eversis-collections-mcp.sh";',
      'fi;',
      'd="$PWD";',
      'for _ in 1 2 3 4 5 6 7 8; do',
      'if [ -f "$d/scripts/run-eversis-collections-mcp.sh" ] && [ -f "$d/vendor/agent-collections/docker-compose.yml" ]; then',
      'exec "$d/scripts/run-eversis-collections-mcp.sh";',
      'fi;',
      'd="$(dirname "$d")";',
      'done;',
      'exit 1',
    ].join(' ');
    picked['eversis-collections'] = {
      command: 'bash',
      args: ['-c', locator],
      type: 'stdio',
    };
  } else {
    let cmdPath;
    if (host === 'claude') {
      // Claude Code only expands ${VAR} / ${VAR:-default} — no ${env:X}. The
      // compose file hardcodes AGENT_COLLECTIONS_HOME=/repo inside the
      // container; CONSUMER_PROJECT_ROOT is a separate host env (below).
      // The *host-side* -f path in absolute mode still needs a value for
      // ${AGENT_COLLECTIONS_HOME} — GUI-launched hosts don't reliably inherit
      // shell profile exports, so the value already resolved by the installer
      // (`collections`) is baked in as the `${VAR:-default}` fallback.
      cmdPath = `\${AGENT_COLLECTIONS_HOME:-${collections}}/${composeFile}`;
    } else if (useRelative) {
      cmdPath = `\${workspaceFolder}/vendor/agent-collections/${composeFile}`;
    } else {
      cmdPath = `\${env:AGENT_COLLECTIONS_HOME}/${composeFile}`;
    }
    // CONSUMER_PROJECT_ROOT is interpolated by Compose on the host for the
    // /workspace bind. AGENT_COLLECTIONS_HOME stays hardcoded as /repo inside
    // the container. Cursor expands ${workspaceFolder}; Claude absolute mode
    // expands ${CLAUDE_PROJECT_DIR:-.} (no ${workspaceFolder}, no ${env:X}).
    const consumerRoot = host === 'claude' ? '${CLAUDE_PROJECT_DIR:-.}' : '${workspaceFolder}';
    picked['eversis-collections'] = {
      command: 'docker',
      args: ['compose', '-f', cmdPath, 'run', '--rm', '-T', 'eversis-collections'],
      type: 'stdio',
      env: {
        CONSUMER_PROJECT_ROOT: consumerRoot,
      },
    };
  }
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
