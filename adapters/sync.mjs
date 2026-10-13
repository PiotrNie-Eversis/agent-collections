#!/usr/bin/env node
/**
 * Adapter sync CLI (TASK-527).
 * Orchestrates Cursor + Claude generators from core. Zero npm dependencies.
 *
 * Usage (repo root):
 *   node adapters/sync.mjs
 *   node adapters/sync.mjs --out /path/to/out
 *   node adapters/sync.mjs --check
 *   npm run sync:adapters
 *   npm run sync:adapters:check
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CURSOR_GENERATE = path.join(__dirname, "cursor", "generate.mjs");
const CLAUDE_GENERATE = path.join(__dirname, "claude", "generate.mjs");
const CLAUDE_COMMANDS_GENERATE = path.join(
  __dirname,
  "claude",
  "generate-commands.mjs",
);
const CURSOR_MAP = path.join(__dirname, "cursor", "rule-map.yaml");
const CLAUDE_MAP = path.join(__dirname, "claude", "rule-map.yaml");

function fail(message) {
  console.error(`error: ${message}`);
  process.exit(1);
}

function findRepoRoot(startDir) {
  let dir = startDir;
  for (;;) {
    if (
      fs.existsSync(path.join(dir, ".ai")) &&
      fs.existsSync(path.join(dir, "adapters"))
    ) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) {
      fail(
        "could not find repository root (expected .ai/ and adapters/). Run from repo root.",
      );
    }
    dir = parent;
  }
}

function parseArgs(argv) {
  let outRoot = null;
  let check = false;
  let frameworkPrefix = "";
  /** @type {Set<string>|null} */
  let agents = null;
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--out") {
      const next = argv[i + 1];
      if (!next || next.startsWith("-")) {
        fail("--out requires a directory path");
      }
      outRoot = path.resolve(next);
      i++;
      continue;
    }
    if (arg === "--framework-prefix") {
      const next = argv[i + 1];
      if (!next || next.startsWith("-")) {
        fail("--framework-prefix requires a value");
      }
      frameworkPrefix = next;
      i++;
      continue;
    }
    if (arg === "--agents") {
      const next = argv[i + 1];
      if (!next || next.startsWith("-")) {
        fail("--agents requires a comma-separated list (cursor,claude,opencode)");
      }
      agents = new Set(
        next
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
      );
      for (const id of agents) {
        if (!["cursor", "claude", "opencode"].includes(id)) {
          fail(`unknown agent id: ${id} (allowed: cursor, claude, opencode)`);
        }
      }
      i++;
      continue;
    }
    if (arg === "--check") {
      check = true;
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      console.log(
        "Usage: node adapters/sync.mjs [--check] [--out <dir>] [--agents cursor,claude,opencode]\n" +
          "                              [--framework-prefix <path>]\n" +
          "  Default: regenerate Cursor (.mdc) then Claude (CLAUDE.md) from core.\n" +
          "  --check: compare fresh generation to disk; exit 0 if no drift (also checks\n" +
          "           Cursor↔Claude id/source map parity). Does not write in-place.\n" +
          "  --out: pass through to generators (write or compare under <dir>).\n" +
          "  --agents: only run selected adapters (default: cursor,claude).\n" +
          "            opencode is placeholder-only (copies opencode.jsonc when present).\n" +
          "  --framework-prefix: pass through to both generators — prepends <path> to\n" +
          "            .ai/... references in CLAUDE.md's How-to section and .cursor/commands/\n" +
          "            SSOT pointers, for vendored consumer installs (empty = self-host,\n" +
          "            unprefixed). Does not affect .cursor/rules/*.mdc body content.\n" +
          "\n" +
          "npm: npm run sync:adapters | npm run sync:adapters:check",
      );
      process.exit(0);
    }
    fail(`unknown argument: ${arg}`);
  }
  return { outRoot, check, agents, frameworkPrefix };
}

function stripQuotes(value) {
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1);
  }
  return value;
}

function parseScalar(raw) {
  const value = raw.trim();
  if (value === "true") return true;
  if (value === "false") return false;
  if (value === "[]") return [];
  if (/^-?\d+$/.test(value)) return Number(value);
  return stripQuotes(value);
}

/**
 * Constrained YAML parser for rule-map shapes (id/source/output + optional globs).
 */
function parseRuleMapYaml(text) {
  const lines = text.split(/\r?\n/);
  const doc = { version: null, rules: [] };
  let currentRule = null;
  let inGlobs = false;

  for (let i = 0; i < lines.length; i++) {
    const rawLine = lines[i];
    const line = rawLine.replace(/\s+#.*$/, "");
    if (!line.trim() || line.trim().startsWith("#")) continue;

    const indent = line.match(/^ */)[0].length;
    const trimmed = line.trim();

    if (indent === 0 && trimmed.startsWith("version:")) {
      doc.version = parseScalar(trimmed.slice("version:".length));
      inGlobs = false;
      continue;
    }

    if (indent === 0 && trimmed === "rules:") {
      inGlobs = false;
      continue;
    }

    if (indent === 2 && trimmed.startsWith("- ")) {
      currentRule = {};
      doc.rules.push(currentRule);
      inGlobs = false;
      const rest = trimmed.slice(2).trim();
      if (rest.includes(":")) {
        const idx = rest.indexOf(":");
        const key = rest.slice(0, idx).trim();
        const val = rest.slice(idx + 1).trim();
        if (val !== "") {
          currentRule[key] = parseScalar(val);
        }
      }
      continue;
    }

    if (!currentRule) {
      fail(`unexpected line ${i + 1}: ${rawLine}`);
    }

    if (indent === 4 && trimmed.startsWith("globs:")) {
      const inline = trimmed.slice("globs:".length).trim();
      if (inline === "[]" || inline === "") {
        currentRule.globs = [];
        inGlobs = inline === "";
      } else {
        currentRule.globs = [parseScalar(inline)];
        inGlobs = false;
      }
      continue;
    }

    if (inGlobs && indent >= 6 && trimmed.startsWith("- ")) {
      currentRule.globs.push(parseScalar(trimmed.slice(2).trim()));
      continue;
    }

    if (indent === 4 && trimmed.includes(":")) {
      inGlobs = false;
      const idx = trimmed.indexOf(":");
      const key = trimmed.slice(0, idx).trim();
      const val = trimmed.slice(idx + 1).trim();
      if (val === "" && key === "globs") {
        currentRule.globs = [];
        inGlobs = true;
      } else {
        currentRule[key] = parseScalar(val);
      }
      continue;
    }

    fail(`unexpected line ${i + 1}: ${rawLine}`);
  }

  return doc;
}

function loadRuleMap(mapPath, label) {
  if (!fs.existsSync(mapPath)) {
    fail(`${label} rule map not found: ${mapPath}`);
  }
  const map = parseRuleMapYaml(fs.readFileSync(mapPath, "utf8"));
  if (map.version !== 1) {
    fail(`${label} unsupported rule-map version: ${map.version} (expected 1)`);
  }
  if (!Array.isArray(map.rules) || map.rules.length === 0) {
    fail(`${label} rule-map has no rules`);
  }
  return map;
}

function idSourceKey(rule) {
  return `${rule.id}\0${rule.source}`;
}

function assertIdSourceParity(cursorMap, claudeMap) {
  const cursorKeys = new Set(cursorMap.rules.map(idSourceKey));
  const claudeKeys = new Set(claudeMap.rules.map(idSourceKey));

  const onlyCursor = [...cursorKeys].filter((k) => !claudeKeys.has(k));
  const onlyClaude = [...claudeKeys].filter((k) => !cursorKeys.has(k));

  if (onlyCursor.length === 0 && onlyClaude.length === 0) {
    return;
  }

  const fmt = (key) => {
    const [id, source] = key.split("\0");
    return `${id} → ${source}`;
  };

  const parts = [];
  if (onlyCursor.length) {
    parts.push(`only in Cursor map: ${onlyCursor.map(fmt).join("; ")}`);
  }
  if (onlyClaude.length) {
    parts.push(`only in Claude map: ${onlyClaude.map(fmt).join("; ")}`);
  }
  fail(`Cursor↔Claude id/source parity failed — ${parts.join(" | ")}`);
}

function runGenerator(scriptPath, outRoot, label, extraArgs = []) {
  if (!fs.existsSync(scriptPath)) {
    fail(`${label} generator not found: ${scriptPath}`);
  }
  const args = [scriptPath];
  if (outRoot) {
    args.push("--out", outRoot);
  }
  args.push(...extraArgs);
  const result = spawnSync(process.execPath, args, {
    cwd: process.cwd(),
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  if (result.stdout) {
    process.stdout.write(result.stdout);
  }
  if (result.stderr) {
    process.stderr.write(result.stderr);
  }
  if (result.error) {
    fail(`${label} generator failed to start: ${result.error.message}`);
  }
  if (result.status !== 0) {
    fail(
      `${label} generator exited with code ${result.status ?? "unknown"}`,
    );
  }
}

function normalizeNewlines(text) {
  return text.replace(/^\uFEFF/, "").replace(/\r\n/g, "\n");
}

function compareFiles(expectedAbs, actualAbs, label) {
  if (!fs.existsSync(actualAbs)) {
    return `${label}: missing on disk: ${actualAbs}`;
  }
  if (!fs.existsSync(expectedAbs)) {
    return `${label}: missing generated reference: ${expectedAbs}`;
  }
  const expected = normalizeNewlines(fs.readFileSync(expectedAbs, "utf8"));
  const actual = normalizeNewlines(fs.readFileSync(actualAbs, "utf8"));
  if (expected !== actual) {
    return `${label}: drift — ${actualAbs}`;
  }
  return null;
}

function resolveCompareRoot(repoRoot, outRoot) {
  return outRoot || repoRoot;
}

/**
 * True when sync writes/checks this framework checkout (not a consumer --out).
 * Consumer skill mirrors are owned by the installer, not this relative self-host step.
 */
function isFrameworkRootTarget(repoRoot, outRoot) {
  if (!outRoot) return true;
  return path.resolve(outRoot) === path.resolve(repoRoot);
}

function listSkillPackageNames(repoRoot) {
  const skillsRoot = path.join(repoRoot, ".ai", "skills");
  if (!fs.existsSync(skillsRoot)) {
    return [];
  }
  return fs
    .readdirSync(skillsRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name.startsWith("eversis-"))
    .map((entry) => entry.name)
    .sort();
}

/** Relative target from .cursor/skills/<name> or .claude/skills/<name> to SSOT. */
function skillMirrorRelativeTarget(name) {
  return path.posix.join("..", "..", ".ai", "skills", name);
}

function expectedSkillMirrorTarget(repoRoot, name) {
  return path.resolve(repoRoot, ".ai", "skills", name);
}

function refreshSkillsMirror(repoRoot, hostDirRel) {
  const names = listSkillPackageNames(repoRoot);
  const mirrorRoot = path.join(repoRoot, ...hostDirRel.split("/"));
  fs.mkdirSync(mirrorRoot, { recursive: true });

  const keep = new Set(names);
  const relativeTarget = (name) => skillMirrorRelativeTarget(name);

  for (const name of names) {
    const dst = path.join(mirrorRoot, name);
    const target = relativeTarget(name);
    try {
      if (fs.lstatSync(dst).isSymbolicLink()) {
        const current = fs.readlinkSync(dst);
        if (current === target) {
          continue;
        }
      }
      fs.rmSync(dst, { recursive: true, force: true });
    } catch (err) {
      if (err && err.code !== "ENOENT") {
        throw err;
      }
    }
    fs.symlinkSync(target, dst);
  }

  if (fs.existsSync(mirrorRoot)) {
    for (const entry of fs.readdirSync(mirrorRoot, { withFileTypes: true })) {
      if (!entry.name.startsWith("eversis-")) continue;
      if (keep.has(entry.name)) continue;
      fs.rmSync(path.join(mirrorRoot, entry.name), {
        recursive: true,
        force: true,
      });
    }
  }

  return names.length;
}

function checkSkillsMirror(repoRoot, hostDirRel, label) {
  const names = listSkillPackageNames(repoRoot);
  const mirrorRoot = path.join(repoRoot, ...hostDirRel.split("/"));
  const drifts = [];
  const expectedRel = (name) => skillMirrorRelativeTarget(name);
  const seen = new Set();

  for (const name of names) {
    const dst = path.join(mirrorRoot, name);
    seen.add(name);
    let st;
    try {
      st = fs.lstatSync(dst);
    } catch {
      drifts.push(
        `${label}:${name}: missing symlink: ${path.join(hostDirRel, name)}`,
      );
      continue;
    }
    if (!st.isSymbolicLink()) {
      drifts.push(
        `${label}:${name}: not a symlink: ${path.join(hostDirRel, name)}`,
      );
      continue;
    }
    const link = fs.readlinkSync(dst);
    if (link !== expectedRel(name)) {
      drifts.push(
        `${label}:${name}: wrong target (got ${link}, expected ${expectedRel(name)})`,
      );
      continue;
    }
    const resolved = path.resolve(path.dirname(dst), link);
    if (resolved !== expectedSkillMirrorTarget(repoRoot, name)) {
      drifts.push(
        `${label}:${name}: resolves outside .ai/skills/${name}: ${resolved}`,
      );
      continue;
    }
    const skillMd = path.join(dst, "SKILL.md");
    if (!fs.existsSync(skillMd)) {
      drifts.push(
        `${label}:${name}: SKILL.md not readable through symlink`,
      );
    }
  }

  if (fs.existsSync(mirrorRoot)) {
    for (const entry of fs.readdirSync(mirrorRoot, { withFileTypes: true })) {
      if (!entry.name.startsWith("eversis-")) continue;
      if (seen.has(entry.name)) continue;
      drifts.push(
        `${label}:${entry.name}: unexpected eversis-* entry (no .ai/skills match): ${path.join(hostDirRel, entry.name)}`,
      );
    }
  }

  return drifts;
}

function runCheck(repoRoot, outRoot, frameworkPrefix) {
  const cursorMap = loadRuleMap(CURSOR_MAP, "Cursor");
  const claudeMap = loadRuleMap(CLAUDE_MAP, "Claude");
  assertIdSourceParity(cursorMap, claudeMap);

  for (const rule of cursorMap.rules) {
    if (!rule.output) {
      fail(`Cursor rules entry ${rule.id}: missing output (needed for --check)`);
    }
  }

  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "agent-collections-sync-"));
  try {
    const frameworkPrefixArgs = frameworkPrefix
      ? ["--framework-prefix", frameworkPrefix]
      : [];
    runGenerator(CURSOR_GENERATE, tmp, "Cursor", frameworkPrefixArgs);
    runGenerator(CLAUDE_GENERATE, tmp, "Claude", frameworkPrefixArgs);
    runGenerator(
      CLAUDE_COMMANDS_GENERATE,
      tmp,
      "Claude commands",
      frameworkPrefixArgs,
    );

    const compareRoot = resolveCompareRoot(repoRoot, outRoot);
    const drifts = [];

    for (const rule of cursorMap.rules) {
      const expected = path.join(tmp, rule.output);
      const actual = path.join(compareRoot, rule.output);
      const err = compareFiles(expected, actual, rule.id);
      if (err) drifts.push(err);
    }

    {
      const expectedCommandsDir = path.join(tmp, ".cursor", "commands");
      const actualCommandsDir = path.join(compareRoot, ".cursor", "commands");
      const expectedNames = new Set();

      if (fs.existsSync(expectedCommandsDir)) {
        for (const name of fs.readdirSync(expectedCommandsDir).sort()) {
          if (!/^eversis-.*\.md$/.test(name)) continue;
          expectedNames.add(name);
          const expected = path.join(expectedCommandsDir, name);
          const actual = path.join(actualCommandsDir, name);
          const err = compareFiles(
            expected,
            actual,
            `command:${name.replace(/\.md$/, "")}`,
          );
          if (err) drifts.push(err);
        }
      }

      if (fs.existsSync(actualCommandsDir)) {
        for (const name of fs.readdirSync(actualCommandsDir).sort()) {
          if (!/^eversis-.*\.md$/.test(name)) continue;
          if (expectedNames.has(name)) continue;
          const actual = path.join(actualCommandsDir, name);
          let text = "";
          try {
            text = fs.readFileSync(actual, "utf8");
          } catch {
            continue;
          }
          if (
            !text.includes(
              "GENERATED by adapters/cursor/generate.mjs",
            )
          ) {
            continue;
          }
          drifts.push(
            `command:${name.replace(/\.md$/, "")}: unexpected generated file on disk: ${actual}`,
          );
        }
      }
    }

    {
      const expectedCommandsDir = path.join(tmp, ".claude", "commands");
      const actualCommandsDir = path.join(compareRoot, ".claude", "commands");
      const expectedNames = new Set();

      if (fs.existsSync(expectedCommandsDir)) {
        for (const name of fs.readdirSync(expectedCommandsDir).sort()) {
          if (!/^eversis-.*\.md$/.test(name)) continue;
          expectedNames.add(name);
          const expected = path.join(expectedCommandsDir, name);
          const actual = path.join(actualCommandsDir, name);
          const err = compareFiles(
            expected,
            actual,
            `claude-command:${name.replace(/\.md$/, "")}`,
          );
          if (err) drifts.push(err);
        }
      }

      if (fs.existsSync(actualCommandsDir)) {
        for (const name of fs.readdirSync(actualCommandsDir).sort()) {
          if (!/^eversis-.*\.md$/.test(name)) continue;
          if (expectedNames.has(name)) continue;
          const actual = path.join(actualCommandsDir, name);
          let text = "";
          try {
            text = fs.readFileSync(actual, "utf8");
          } catch {
            continue;
          }
          if (
            !text.includes(
              "GENERATED by adapters/claude/generate-commands.mjs",
            )
          ) {
            continue;
          }
          drifts.push(
            `claude-command:${name.replace(/\.md$/, "")}: unexpected generated file on disk: ${actual}`,
          );
        }
      }
    }

    {
      const expectedRulesDir = path.join(tmp, ".claude", "rules");
      const actualRulesDir = path.join(compareRoot, ".claude", "rules");
      const expectedNames = new Set();

      if (fs.existsSync(expectedRulesDir)) {
        for (const name of fs.readdirSync(expectedRulesDir).sort()) {
          if (!/^eversis-.*\.md$/.test(name)) continue;
          expectedNames.add(name);
          const expected = path.join(expectedRulesDir, name);
          const actual = path.join(actualRulesDir, name);
          const err = compareFiles(
            expected,
            actual,
            `claude-rule:${name.replace(/\.md$/, "")}`,
          );
          if (err) drifts.push(err);
        }
      }

      if (fs.existsSync(actualRulesDir)) {
        for (const name of fs.readdirSync(actualRulesDir).sort()) {
          if (!/^eversis-.*\.md$/.test(name)) continue;
          if (expectedNames.has(name)) continue;
          const actual = path.join(actualRulesDir, name);
          let text = "";
          try {
            text = fs.readFileSync(actual, "utf8");
          } catch {
            continue;
          }
          if (!text.includes("GENERATED by adapters/claude/generate.mjs")) {
            continue;
          }
          drifts.push(
            `claude-rule:${name.replace(/\.md$/, "")}: unexpected generated file on disk: ${actual}`,
          );
        }
      }
    }

    {
      const expected = path.join(tmp, "CLAUDE.md");
      const actual = path.join(compareRoot, "CLAUDE.md");
      const err = compareFiles(expected, actual, "CLAUDE.md");
      if (err) drifts.push(err);
    }

    if (isFrameworkRootTarget(repoRoot, outRoot)) {
      drifts.push(...checkSkillsMirror(repoRoot, ".cursor/skills", "cursor-skill"));
      drifts.push(...checkSkillsMirror(repoRoot, ".claude/skills", "claude-skill"));
    }

    if (drifts.length > 0) {
      console.error("error: adapter drift detected:");
      for (const d of drifts) {
        console.error(`  ${d}`);
      }
      console.error(
        "hint: run `node adapters/sync.mjs` (or `npm run sync:adapters`) then re-check.",
      );
      process.exit(1);
    }

    console.log("adapter sync check: OK (no drift; id/source parity OK)");
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true });
  }
}

function runOpenCodePlaceholder(repoRoot, outRoot) {
  const src = path.join(repoRoot, "opencode.jsonc");
  const destRoot = outRoot || repoRoot;
  const dest = path.join(destRoot, "opencode.jsonc");
  if (!fs.existsSync(src)) {
    console.warn(
      "adapter sync: OpenCode placeholder requested but opencode.jsonc missing in framework home — skipping",
    );
    return;
  }
  fs.mkdirSync(destRoot, { recursive: true });
  fs.copyFileSync(src, dest);
  console.log(
    "adapter sync: OpenCode placeholder copied (maturity=placeholder — not a full adapter)",
  );
}

function runWrite(repoRoot, outRoot, agents, frameworkPrefix) {
  const selected = agents ?? new Set(["cursor", "claude"]);
  const frameworkPrefixArgs = frameworkPrefix
    ? ["--framework-prefix", frameworkPrefix]
    : [];
  if (selected.has("cursor")) {
    console.log("adapter sync: regenerating Cursor…");
    runGenerator(CURSOR_GENERATE, outRoot, "Cursor", frameworkPrefixArgs);
  }
  if (selected.has("claude")) {
    console.log("adapter sync: regenerating Claude…");
    runGenerator(CLAUDE_GENERATE, outRoot, "Claude", frameworkPrefixArgs);
    runGenerator(
      CLAUDE_COMMANDS_GENERATE,
      outRoot,
      "Claude commands",
      frameworkPrefixArgs,
    );
  }
  if (selected.has("opencode")) {
    runOpenCodePlaceholder(repoRoot, outRoot);
  }
  if (isFrameworkRootTarget(repoRoot, outRoot)) {
    const cursorCount = refreshSkillsMirror(repoRoot, ".cursor/skills");
    const claudeCount = refreshSkillsMirror(repoRoot, ".claude/skills");
    console.log(
      `adapter sync: framework skills mirror — .cursor/skills (${cursorCount}), .claude/skills (${claudeCount})`,
    );
  }
  console.log("adapter sync: done");
}

function main() {
  const { outRoot, check, agents, frameworkPrefix } = parseArgs(
    process.argv.slice(2),
  );
  const repoRoot = findRepoRoot(process.cwd());

  if (check) {
    runCheck(repoRoot, outRoot, frameworkPrefix);
  } else {
    runWrite(repoRoot, outRoot, agents, frameworkPrefix);
  }
}

main();
