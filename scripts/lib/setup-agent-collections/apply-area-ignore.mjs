#!/usr/bin/env node
/**
 * Append area-scope exclude patterns into consumer ignore files (merge-only).
 */
import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const out = { target: null, areaManifest: null, agents: 'cursor' };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--target') out.target = argv[++i];
    else if (argv[i] === '--area-manifest') out.areaManifest = argv[++i];
    else if (argv[i] === '--agents') out.agents = argv[++i];
  }
  return out;
}

function parseYamlExcludes(text) {
  // Minimal YAML: look for exclude: list with "- pattern" lines
  const lines = text.split(/\r?\n/);
  const excludes = [];
  let inExclude = false;
  for (const line of lines) {
    if (/^exclude:\s*$/.test(line)) {
      inExclude = true;
      continue;
    }
    if (inExclude) {
      if (/^\S/.test(line) && !line.startsWith(' ')) {
        inExclude = false;
        continue;
      }
      const m = line.match(/^\s*-\s+(.+)$/);
      if (m) excludes.push(m[1].trim().replace(/^["']|["']$/g, ''));
    }
  }
  return excludes;
}

const { target, areaManifest, agents } = parseArgs(process.argv.slice(2));
if (!target || !areaManifest) {
  console.error('Usage: apply-area-ignore.mjs --target <dir> --area-manifest <yaml> [--agents csv]');
  process.exit(1);
}

const raw = fs.readFileSync(areaManifest, 'utf8');
const excludes = parseYamlExcludes(raw);
const agentSet = new Set(agents.split(',').map((s) => s.trim()).filter(Boolean));

const MARKER_BEGIN = '# agent-collections area-scope [begin]';
const MARKER_END = '# agent-collections area-scope [end]';

function stripBlock(text) {
  const lines = text.split(/\r?\n/);
  const out = [];
  let skip = false;
  for (const line of lines) {
    if (line.trim() === MARKER_BEGIN) {
      skip = true;
      continue;
    }
    if (line.trim() === MARKER_END) {
      skip = false;
      continue;
    }
    if (!skip) out.push(line);
  }
  return out.join('\n').replace(/\n{3,}/g, '\n\n').trimEnd();
}

const targets = [];
if (agentSet.has('cursor')) targets.push('.cursorignore');
if (agentSet.has('claude')) targets.push('.claudeignore');
if (agentSet.has('opencode')) targets.push('.opencodeignore');

for (const name of targets) {
  const dst = path.join(target, name);
  let existing = fs.existsSync(dst) ? fs.readFileSync(dst, 'utf8') : '';
  existing = stripBlock(existing);
  const block = [MARKER_BEGIN, ...excludes, MARKER_END].join('\n');
  const next = existing ? `${existing.trimEnd()}\n\n${block}\n` : `${block}\n`;
  fs.writeFileSync(dst, next);
}
