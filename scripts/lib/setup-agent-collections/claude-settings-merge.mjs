#!/usr/bin/env node
/**
 * Merge .claude/settings.json for a consumer install (Agent Collections).
 *
 * Ownership split (Q8 in docs/specs/claude-code-setup/claude-code-setup.plan.md):
 *  - First run (no existing file): seed the whole file from
 *    templates/claude-settings.json.
 *  - Every run: fully regenerate `permissions.deny` (from .claudeignore path
 *    classes — the single source of truth for path classes) and
 *    `enabledMcpjsonServers` (from the current MCP selection). Every other
 *    key in an existing file — including `permissions.allow` and anything a
 *    consumer added by hand — is left untouched.
 *  - Preserve mode (CS_PRESERVE_EXISTING=true, upgrade/sync reusing the
 *    record): `enabledMcpjsonServers` is the selection plus every catalog id
 *    already present in `.mcp.json` (CS_MCP_JSON_PATH), so servers that
 *    mcp-merge.mjs kept on disk stay enabled in Claude Code.
 *  - Every run: exactly one framework-owned entry under each of two hook
 *    events, both running the spec artifact guard (command
 *    FRAMEWORK_HOOK_COMMAND, the same launcher):
 *      - `hooks.PreToolUse`, matcher `Bash` — records when a shell command
 *        starts, so the post hook can find spec files it changed;
 *      - `hooks.PostToolUse`, matcher `Write|Edit|MultiEdit|Bash` — validates
 *        spec artifacts written by an edit tool or changed by a shell
 *        command.
 *    Both are written only when the launcher exists in the target
 *    (CS_HOOK_LAUNCHER_PATH), and removed otherwise, so the settings never
 *    point at a missing file. The same rule applies to each event on its
 *    own: a framework entry is found by the launcher path in its command; a
 *    stale framework entry (for example the older single `PostToolUse`
 *    entry with matcher `Write|Edit|MultiEdit`) is replaced in place, and
 *    every consumer hook (other events, other entries of these two events)
 *    is kept in order. A removal that empties `PreToolUse`, `PostToolUse` or
 *    `hooks` drops that key. A non-array `PreToolUse` or `PostToolUse` is
 *    refused.
 *  - Remove-hook mode (CS_MODE=remove-hook, Claude deselected): only the
 *    framework hook entries (both events) are dropped from
 *    CS_EXISTING_JSON; nothing else is regenerated and no template or
 *    .claudeignore is read. Prints nothing when there is no existing file.
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
const hookLauncherPath = process.env.CS_HOOK_LAUNCHER_PATH ?? '';
const mode = process.env.CS_MODE ?? '';

/** Launcher location as Claude Code sees it; identifies the framework entry. */
const FRAMEWORK_HOOK_LAUNCHER = '.claude/hooks/eversis-validate-spec.cjs';
const FRAMEWORK_HOOK_COMMAND = `node "\${CLAUDE_PROJECT_DIR}/${FRAMEWORK_HOOK_LAUNCHER}"`;
/**
 * Framework-owned entry per hook event, in the order the events are written
 * into a new `hooks` object. `PreToolUse` on Bash records the start of a
 * shell command; `PostToolUse` validates what an edit tool or that shell
 * command changed. Both run the same launcher command.
 */
const FRAMEWORK_HOOK_EVENTS = [
  { event: 'PreToolUse', matcher: 'Bash' },
  { event: 'PostToolUse', matcher: 'Write|Edit|MultiEdit|Bash' },
];

function frameworkHookEntry(matcher) {
  return {
    matcher,
    hooks: [{ type: 'command', command: FRAMEWORK_HOOK_COMMAND }],
  };
}

function isFrameworkHook(hook) {
  return (
    hook !== null &&
    typeof hook === 'object' &&
    typeof hook.command === 'string' &&
    hook.command.replace(/\\/g, '/').includes(FRAMEWORK_HOOK_LAUNCHER)
  );
}

/**
 * Bring `settings.hooks.PreToolUse` and `settings.hooks.PostToolUse` to the
 * wanted state: one framework entry per event (FRAMEWORK_HOOK_EVENTS) when
 * `wanted`, none otherwise. Each event is handled on its own: inner hooks
 * that run the framework launcher are stripped from every entry; an entry
 * left with no hooks by that strip is dropped. The framework entry goes where
 * the first stripped entry was (or at the end), so re-runs are
 * byte-identical, consumer order is kept, and an older framework entry with
 * a different matcher is upgraded in the same position. An event array or a
 * `hooks` object emptied by removal is dropped. Mutates `settings`.
 */
function applyFrameworkHook(settings, wanted) {
  if (settings.hooks === undefined) {
    if (!wanted) return;
    settings.hooks = {};
  } else if (
    typeof settings.hooks !== 'object' ||
    settings.hooks === null ||
    Array.isArray(settings.hooks)
  ) {
    fail(
      '.claude/settings.json "hooks" is not an object — refusing to merge (fix the file by hand, then re-run).',
    );
  }
  // Check every owned event before changing any, so a refusal leaves no
  // half-merged state behind.
  for (const { event } of FRAMEWORK_HOOK_EVENTS) {
    const value = settings.hooks[event];
    if (value !== undefined && !Array.isArray(value)) {
      fail(
        `.claude/settings.json "hooks.${event}" is not an array — refusing to merge (fix the file by hand, then re-run).`,
      );
    }
  }

  let removedAny = false;
  for (const { event, matcher } of FRAMEWORK_HOOK_EVENTS) {
    if (applyFrameworkHookEvent(settings.hooks, event, matcher, wanted)) removedAny = true;
  }
  if (removedAny && Object.keys(settings.hooks).length === 0) {
    delete settings.hooks;
  }
}

/**
 * Apply the framework entry rule to one event array of `hooks` (see
 * applyFrameworkHook). Returns true when a framework hook was stripped.
 * Mutates `hooks`.
 */
function applyFrameworkHookEvent(hooks, event, matcher, wanted) {
  const hadEvent = hooks[event] !== undefined;
  const current = hadEvent ? hooks[event] : [];

  const next = [];
  let insertAt = -1;
  let removedAny = false;
  for (const entry of current) {
    const inner = entry && typeof entry === 'object' && Array.isArray(entry.hooks) ? entry.hooks : null;
    if (!inner || !inner.some(isFrameworkHook)) {
      next.push(entry);
      continue;
    }
    removedAny = true;
    if (insertAt === -1) insertAt = next.length;
    const kept = inner.filter((hook) => !isFrameworkHook(hook));
    if (kept.length > 0) next.push({ ...entry, hooks: kept });
  }
  if (wanted) {
    next.splice(insertAt === -1 ? next.length : insertAt, 0, frameworkHookEntry(matcher));
  }

  if (next.length > 0 || (hadEvent && !removedAny)) {
    hooks[event] = next;
  } else {
    delete hooks[event];
  }
  return removedAny;
}

if (mode === 'remove-hook') {
  if (!existingJson.trim()) process.exit(0);
  let parsed;
  try {
    parsed = JSON.parse(existingJson);
  } catch {
    fail('Existing .claude/settings.json is not valid JSON.');
  }
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    fail('Existing .claude/settings.json is not a JSON object.');
  }
  applyFrameworkHook(parsed, false);
  process.stdout.write(`${JSON.stringify(parsed, null, 2)}\n`);
  process.exit(0);
} else if (mode !== '') {
  fail(`Unknown CS_MODE: ${mode}`);
}

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

applyFrameworkHook(result, Boolean(hookLauncherPath) && fs.existsSync(hookLauncherPath));

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
