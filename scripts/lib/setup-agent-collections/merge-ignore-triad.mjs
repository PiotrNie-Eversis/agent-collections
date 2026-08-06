#!/usr/bin/env node
/**
 * Merge framework ignore triad classes into consumer files without wiping consumer entries.
 */
import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const out = { home: null, target: null, agents: 'cursor' };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--home') out.home = argv[++i];
    else if (argv[i] === '--target') out.target = argv[++i];
    else if (argv[i] === '--agents') out.agents = argv[++i];
  }
  return out;
}

const { home, target, agents } = parseArgs(process.argv.slice(2));
if (!home || !target) {
  console.error('Usage: merge-ignore-triad.mjs --home <fw> --target <dir> [--agents csv]');
  process.exit(1);
}

const agentSet = new Set(agents.split(',').map((s) => s.trim()).filter(Boolean));

const FILES = [];
if (agentSet.has('cursor')) FILES.push({ name: '.cursorignore', src: path.join(home, '.cursorignore') });
if (agentSet.has('claude')) FILES.push({ name: '.claudeignore', src: path.join(home, '.claudeignore') });
if (agentSet.has('opencode')) FILES.push({ name: '.opencodeignore', src: path.join(home, '.opencodeignore') });

const MARKER_BEGIN = '# agent-collections framework [begin]';
const MARKER_END = '# agent-collections framework [end]';

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

function frameworkLines(srcPath) {
  if (!fs.existsSync(srcPath)) return [];
  return fs
    .readFileSync(srcPath, 'utf8')
    .split(/\r?\n/)
    .map((l) => l.trimEnd())
    .filter((l) => l && !l.startsWith('#'));
}

for (const file of FILES) {
  const dst = path.join(target, file.name);
  const fwLines = frameworkLines(file.src);
  let existing = fs.existsSync(dst) ? fs.readFileSync(dst, 'utf8') : '';
  existing = stripBlock(existing);

  const existingSet = new Set(
    existing
      .split(/\r?\n/)
      .map((l) => l.trim())
      .filter((l) => l && !l.startsWith('#')),
  );

  const missing = fwLines.filter((l) => !existingSet.has(l.trim()));
  const block = [MARKER_BEGIN, ...missing, MARKER_END].join('\n');

  const next = existing
    ? `${existing.trimEnd()}\n\n${block}\n`
    : `${block}\n`;
  fs.writeFileSync(dst, next);
  console.log(`[ignore-triad] updated ${file.name} (+${missing.length} framework lines)`);
}
