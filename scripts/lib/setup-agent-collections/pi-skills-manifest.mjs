#!/usr/bin/env node
/**
 * Record and check content hashes of the skill entries the installer copies
 * into .pi/skills/. The installer consults the manifest before it backs up a
 * .pi/skills/eversis-* entry: content equal to a hash it recorded after its own
 * copy is a former framework copy and needs no backup. Every doubt (missing or
 * invalid manifest, unknown version, read error, unknown entry type) means "no
 * match", so the caller keeps its backup.
 *
 * Usage:
 *   node pi-skills-manifest.mjs write <manifestPath> <skillsDir> [<name>...]
 *     Hashes <skillsDir>/<name> for each name and writes the manifest through a
 *     temp file + rename in the same folder (parent created when missing).
 *     A name whose hash fails is left out; zero names writes an empty "skills".
 *     Output is byte-stable: names sorted by code point, duplicates removed,
 *     2-space JSON with a trailing newline. Exit 0, non-zero on write failure.
 *   node pi-skills-manifest.mjs match <manifestPath> <name> <entryPath>
 *     Exit 0 only when the manifest parses, its version is 1, it has a
 *     "sha256:" entry for <name>, and that entry equals the hash of
 *     <entryPath>. Exit 1 in every other case. Never prints to stdout.
 *
 * Entry hash (SHA-256, every field length-prefixed so no two inputs share a
 * serialization): a format tag, then the root type ("file" or "dir").
 * - A regular file: its bytes.
 * - A directory: every file, directory and symlink under it, dotfiles
 *   included, in code-point order of the POSIX relative path; each item is
 *   type + path + (bytes | link target | nothing for a directory).
 * Symlinks are never followed (a link is hashed by its target text). Any other
 * entry type (fifo, socket, device), and a root that is a symlink, is a hash
 * failure. File mode and mtime are ignored, so the same content gives the
 * same hash on macOS and Linux.
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const MANIFEST_VERSION = 1;
const HASH_PREFIX = 'sha256:';
const FORMAT_TAG = 'agent-collections-pi-skill-entry/1';

class HashFailure extends Error {}

/** Feeds one length-prefixed field into the hash. */
function field(hash, value) {
  const buf = Buffer.isBuffer(value) ? value : Buffer.from(String(value), 'utf8');
  hash.update(`${buf.length}:`);
  hash.update(buf);
}

/** Code-point order (UTF-8 byte order equals code-point order). */
function byCodePoint(a, b) {
  return Buffer.compare(Buffer.from(a, 'utf8'), Buffer.from(b, 'utf8'));
}

/** Lists every item under dir as { rel, abs, stat }, depth-first, unsorted. */
function collectTree(dir, relBase, out) {
  for (const child of fs.readdirSync(dir)) {
    const abs = path.join(dir, child);
    const rel = relBase ? `${relBase}/${child}` : child;
    const stat = fs.lstatSync(abs);
    out.push({ rel, abs, stat });
    if (stat.isDirectory()) collectTree(abs, rel, out);
  }
  return out;
}

/** Returns "sha256:<hex>" for the entry at entryPath; throws on any failure. */
function hashEntry(entryPath) {
  const hash = crypto.createHash('sha256');
  field(hash, FORMAT_TAG);
  const root = fs.lstatSync(entryPath);
  if (root.isFile()) {
    field(hash, 'file');
    field(hash, fs.readFileSync(entryPath));
  } else if (root.isDirectory()) {
    field(hash, 'dir');
    const items = collectTree(entryPath, '', []).sort((a, b) => byCodePoint(a.rel, b.rel));
    field(hash, items.length);
    for (const item of items) {
      if (item.stat.isFile()) {
        field(hash, 'file');
        field(hash, item.rel);
        field(hash, fs.readFileSync(item.abs));
      } else if (item.stat.isDirectory()) {
        field(hash, 'dir');
        field(hash, item.rel);
      } else if (item.stat.isSymbolicLink()) {
        field(hash, 'link');
        field(hash, item.rel);
        field(hash, fs.readlinkSync(item.abs, { encoding: 'buffer' }));
      } else {
        throw new HashFailure(`unsupported entry type: ${item.abs}`);
      }
    }
  } else {
    throw new HashFailure(`not a regular file or directory: ${entryPath}`);
  }
  return HASH_PREFIX + hash.digest('hex');
}

/** A plain skill entry name: no path separator, not "." or "..". */
function isEntryName(name) {
  return typeof name === 'string' && name !== '' && name !== '.' && name !== '..'
    && !name.includes('/') && !name.includes('\\') && !name.includes('\0');
}

function writeManifest(manifestPath, skillsDir, names) {
  const sorted = [...new Set(names.filter(isEntryName))].sort(byCodePoint);
  const lines = [];
  for (const name of sorted) {
    let digest;
    try {
      digest = hashEntry(path.join(skillsDir, name));
    } catch {
      continue;
    }
    lines.push(`    ${JSON.stringify(name)}: ${JSON.stringify(digest)}`);
  }
  const skills = lines.length ? `{\n${lines.join(',\n')}\n  }` : '{}';
  const text = `{\n  "version": ${MANIFEST_VERSION},\n  "skills": ${skills}\n}\n`;

  const dir = path.dirname(path.resolve(manifestPath));
  const tmp = path.join(dir, `.${path.basename(manifestPath)}.${process.pid}.tmp`);
  try {
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(tmp, text);
    fs.renameSync(tmp, manifestPath);
  } catch (err) {
    try { fs.rmSync(tmp, { force: true }); } catch { /* keep the original error */ }
    const message = err instanceof Error ? err.message : String(err);
    console.error(`[pi-skills-manifest] ${message}`);
    return 1;
  }
  return 0;
}

function matchManifest(manifestPath, name, entryPath) {
  try {
    const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    if (!manifest || typeof manifest !== 'object' || Array.isArray(manifest)) return 1;
    if (manifest.version !== MANIFEST_VERSION) return 1;
    const skills = manifest.skills;
    if (!skills || typeof skills !== 'object' || Array.isArray(skills)) return 1;
    if (!Object.prototype.hasOwnProperty.call(skills, name)) return 1;
    const recorded = skills[name];
    if (typeof recorded !== 'string' || !recorded.startsWith(HASH_PREFIX)) return 1;
    return hashEntry(entryPath) === recorded ? 0 : 1;
  } catch {
    return 1;
  }
}

const [command, ...args] = process.argv.slice(2);
const usage = '[pi-skills-manifest] Usage: node pi-skills-manifest.mjs write <manifestPath> <skillsDir> [<name>...] | match <manifestPath> <name> <entryPath>';

if (command === 'write' && args.length >= 2) {
  process.exit(writeManifest(args[0], args[1], args.slice(2)));
} else if (command === 'match' && args.length === 3) {
  process.exit(matchManifest(args[0], args[1], args[2]));
} else {
  console.error(usage);
  process.exit(1);
}
