#!/usr/bin/env node
/**
 * Merge .claude/settings.json for a consumer install (Agent Collections).
 *
 * Ownership split (Q8 in docs/specs/claude-code-setup/claude-code-setup.plan.md):
 *  - First run (no existing file): seed the whole file from
 *    templates/claude-settings.json.
 *  - Every run: fully regenerate `permissions.deny` (from .claudeignore path
 *    classes — the single source of truth for path classes, TASK-529) and
 *    `enabledMcpjsonServers` (from the current MCP selection). Every other
 *    key in an existing file — including `permissions.allow` and anything a
 *    consumer added by hand — is left untouched.
 *  - Preserve mode (CS_PRESERVE_EXISTING=true, AC-99 upgrade/sync reusing the
 *    record): `enabledMcpjsonServers` is the selection plus every catalog id
 *    already present in `.mcp.json` (CS_MCP_JSON_PATH), so servers that
 *    mcp-merge.mjs kept on disk stay enabled in Claude Code.
 */
import fs from 'node:fs';

function fail(msg) {
  console.error(`[claude-settings-merge] ${msg}`);
  process.exit(1);
}

const existingJson = process.env.CS_EXISTING_JSON ?? '';
const templatePath = process.env.CS_TEMPLATE_PATH;
const claudeignorePath = process.env.CS_CLAUDEIGNORE_PATH;
const mcpServersCsv = process.env.CS_MCP_SERVER_IDS ?? '';
const preserveExisting = process.env.CS_PRESERVE_EXISTING === 'true';
const mcpJsonPath = process.env.CS_MCP_JSON_PATH ?? '';
const serverListPath = process.env.CS_SERVER_LIST_PATH ?? '';

if (!templatePath || !claudeignorePath) {
  fail('Missing required environment variables for Claude settings merge.');
}

/**
 * Translate .claudeignore's gitignore-style path classes into Claude Code
 * `permissions.deny` Read() globs. Mirrors gitignore anchoring: a pattern
 * with an internal "/" (before any trailing slash) is root-anchored;
 * everything else matches at any depth.
 */
function denyPatternsFromClaudeignore(path) {
  if (!fs.existsSync(path)) return [];
  const lines = fs.readFileSync(path, 'utf8').split(/\r?\n/);
  const patterns = [];
  for (const raw of lines) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    if (line.startsWith('!')) {
      // Gitignore negation (re-allow) has no equivalent in Claude Code's
      // permissions.deny — it's a flat deny list, not an ordered set of
      // rules. Skip rather than emit a literal "!"-prefixed glob, which
      // would never match anything and silently look like it worked.
      continue;
    }

    const isDir = line.endsWith('/');
    // A leading "/" is gitignore's own root-anchor marker (e.g. "/dist/")
    // — strip it before checking for an *internal* "/", otherwise it both
    // double-counts as anchoring evidence and survives into the glob as a
    // literal ".//dist/**" (a malformed double slash that may not match).
    const bodyWithLeadingSlash = isDir ? line.slice(0, -1) : line;
    const body = bodyWithLeadingSlash.replace(/^\//, '');
    const anchored = body.includes('/') || bodyWithLeadingSlash.startsWith('/');

    let glob;
    if (anchored) {
      glob = isDir ? `./${body}/**` : `./${body}`;
    } else {
      glob = isDir ? `./**/${body}/**` : `./**/${body}`;
    }
    patterns.push(`Read(${glob})`);
  }
  return [...new Set(patterns)];
}

let existing;
try {
  existing = existingJson.trim() ? JSON.parse(existingJson) : null;
} catch {
  fail('Existing .claude/settings.json is not valid JSON.');
}

let result;
if (existing) {
  result = existing;
} else {
  if (!fs.existsSync(templatePath)) {
    fail(`Template not found: ${templatePath}`);
  }
  result = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
}

if (result.permissions === undefined) {
  result.permissions = {};
} else if (
  typeof result.permissions !== 'object' ||
  result.permissions === null ||
  Array.isArray(result.permissions)
) {
  fail(
    '.claude/settings.json "permissions" is not an object — refusing to merge (fix the file by hand, then re-run).',
  );
}

result.permissions.deny = denyPatternsFromClaudeignore(claudeignorePath);

/**
 * Catalog ids present in the consumer's `.mcp.json`, in file order. Any
 * problem (no path, missing / invalid file or catalog) yields [] so preserve
 * mode silently falls back to the selection — never a failed install.
 */
function catalogIdsInMcpJson(mcpPath, listPath) {
  if (!mcpPath || !listPath) return [];
  try {
    const catalogIds = new Set(JSON.parse(fs.readFileSync(listPath, 'utf8')).servers ?? []);
    const servers = JSON.parse(fs.readFileSync(mcpPath, 'utf8')).mcpServers;
    if (!servers || typeof servers !== 'object' || Array.isArray(servers)) return [];
    return Object.keys(servers).filter((id) => catalogIds.has(id));
  } catch {
    return [];
  }
}

const enabled = mcpServersCsv
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
if (preserveExisting) {
  // Selection order first, then preserved ids not already listed.
  for (const id of catalogIdsInMcpJson(mcpJsonPath, serverListPath)) {
    if (!enabled.includes(id)) enabled.push(id);
  }
}
result.enabledMcpjsonServers = enabled;

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
