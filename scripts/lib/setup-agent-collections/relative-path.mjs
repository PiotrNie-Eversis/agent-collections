#!/usr/bin/env node
/**
 * Print a POSIX relative path from fromDir to toPath.
 * Usage: node relative-path.mjs <fromDir> <toPath>
 */
import fs from 'node:fs';
import path from 'node:path';

const fromDir = process.argv[2];
const toPath = process.argv[3];

if (!fromDir || !toPath) {
  console.error('[relative-path] Usage: node relative-path.mjs <fromDir> <toPath>');
  process.exit(1);
}

try {
  const resolvedFrom = fs.realpathSync(path.resolve(fromDir));
  const resolvedTo = fs.realpathSync(path.resolve(toPath));
  const rel = path.relative(resolvedFrom, resolvedTo);
  process.stdout.write(rel.split(path.sep).join('/') + '\n');
} catch (err) {
  const message = err instanceof Error ? err.message : String(err);
  console.error(`[relative-path] ${message}`);
  process.exit(1);
}
