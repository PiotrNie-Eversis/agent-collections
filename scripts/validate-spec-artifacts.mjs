#!/usr/bin/env node
/**
 * Spec artifact validator.
 *
 * Checks that a research file (`*.research.md`) or an implementation plan
 * (`*.plan.md`) follows the framework template, so a file whose structure was
 * copied from memory or from an older spec never reaches a human gate
 * unreported. The templates are the only source of structure: required
 * headings are read at runtime from
 *   .ai/skills/eversis-task-analysing/research.example.md
 *   .ai/skills/eversis-creating-implementation-plans/plan.example.md
 * located relative to this file (not to the process cwd), so a template change
 * needs no validator change and a vendored copy checks against its own
 * templates.
 *
 * Rules:
 *   - Research: every template H2, plus every template H3 under
 *     `## Gathered Information` and `## Current Implementation Status` (found
 *     under the same H2 in the checked file). Extra sections are allowed. The
 *     Gap Analysis question count and the Task Details rows are not checked.
 *   - Plan: every template H2. Every `#### Task` heading carries a
 *     `[CREATE]`, `[MODIFY]` or `[REUSE]` marker (combinations such as
 *     `[CREATE/MODIFY]` allowed) and its body has `**Files:**` and
 *     `**Definition of Done**`. The last `### Phase` heading names Code Review.
 *   - Lines inside fenced code blocks and inside HTML comments are ignored, so
 *     example headings never count.
 *
 * The check itself is a pure function (`validateSpecArtifact`) with no file
 * access, so other hosts can import it without spawning a process. The CLI
 * wraps it.
 *
 * Stdlib only, zero npm dependencies. main() runs only when executed directly.
 *
 * Usage (repo root):
 *   node scripts/validate-spec-artifacts.mjs <file>...
 *   node scripts/validate-spec-artifacts.mjs --report <dir>
 *   node scripts/validate-spec-artifacts.mjs --help
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const FRAMEWORK_ROOT = path.resolve(path.dirname(__filename), "..");

/** Absolute template path per artifact kind, relative to this file. */
export const TEMPLATE_PATHS = Object.freeze({
  research: path.join(
    FRAMEWORK_ROOT,
    ".ai",
    "skills",
    "eversis-task-analysing",
    "research.example.md",
  ),
  plan: path.join(
    FRAMEWORK_ROOT,
    ".ai",
    "skills",
    "eversis-creating-implementation-plans",
    "plan.example.md",
  ),
});

/** H2 sections whose template H3s are also required, per kind. */
const REQUIRED_H3_PARENTS = Object.freeze({
  research: ["Gathered Information", "Current Implementation Status"],
  plan: [],
});

/**
 * Hint appended to every failing report. Legacy files must reach the
 * template when edited, but without invented content.
 */
export const LEGACY_HINT =
  "A section missing from an existing file may be added with one line such as " +
  '"No data — section added during DELTA <date>" instead of invented content; ' +
  "record it in a Changelog row.";

const TASK_MARKER = /\[\s*(CREATE|MODIFY|REUSE)(\s*\/\s*(CREATE|MODIFY|REUSE))*\s*\]/;
const FILES_FIELD = /\*\*Files:?\*\*/;
const DOD_FIELD = /\*\*Definition of Done:?\*\*/;
const HEADING = /^ {0,3}(#{1,6})[ \t]+(.*?)(?:[ \t]+#+)?[ \t]*$/;
const FENCE_OPEN = /^ {0,3}(`{3,}|~{3,})/;

const HELP = `Usage:
  node scripts/validate-spec-artifacts.mjs <file>...
      Validate each research (*.research.md) or plan (*.plan.md) file against
      its template. The templates themselves (research.example.md,
      plan.example.md) are accepted too. Prints "ok" or the gap list per file.
  node scripts/validate-spec-artifacts.mjs --report <dir>
      Walk <dir> for **/*.plan.md and **/*.research.md and list every
      non-compliant file with its gaps. Informational: gaps do not change
      the exit code.
  node scripts/validate-spec-artifacts.mjs --help

Templates (read relative to this script):
  ${path.relative(process.cwd(), TEMPLATE_PATHS.research) || TEMPLATE_PATHS.research}
  ${path.relative(process.cwd(), TEMPLATE_PATHS.plan) || TEMPLATE_PATHS.plan}

Exit codes:
  <file> mode:   0 every file passes, 1 at least one file has gaps,
                 2 usage or I/O error (unknown file kind, unreadable file,
                 missing template)
  --report mode: 0 always after the walk, 2 usage or I/O error
                 (missing directory, missing template)
`;

/** Error that ends the CLI with exit code 2 (usage or I/O). */
class UsageError extends Error {}

/**
 * Tell the artifact kind from a file name.
 * @param {string} filePath
 * @returns {"plan" | "research" | null}
 */
export function detectKind(filePath) {
  if (typeof filePath !== "string" || filePath === "") return null;
  const base = filePath.replace(/\\/g, "/").split("/").pop();
  if (base === "plan.example.md" || base.endsWith(".plan.md")) return "plan";
  if (base === "research.example.md" || base.endsWith(".research.md")) {
    return "research";
  }
  return null;
}

/**
 * Lines that count for the structure check: everything outside fenced code
 * blocks and HTML comments, with inline comments removed.
 * @param {string} text
 * @returns {{ line: number, text: string }[]} 1-based line numbers
 */
function visibleLines(text) {
  const out = [];
  let fence = null; // { char, length } of the open fence
  let inComment = false;
  const lines = text.replace(/\r\n?/g, "\n").split("\n");
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i];
    if (fence) {
      const close = line.match(/^ {0,3}(`{3,}|~{3,})[ \t]*$/);
      if (close && close[1][0] === fence.char && close[1].length >= fence.length) {
        fence = null;
      }
      continue;
    }
    if (inComment) {
      const end = line.indexOf("-->");
      if (end < 0) continue;
      inComment = false;
      line = line.slice(end + 3);
    }
    line = line.replace(/<!--[\s\S]*?-->/g, "");
    const open = line.indexOf("<!--");
    if (open >= 0) {
      inComment = true;
      line = line.slice(0, open);
    }
    const fenceOpen = line.match(FENCE_OPEN);
    if (fenceOpen) {
      fence = { char: fenceOpen[1][0], length: fenceOpen[1].length };
      continue;
    }
    out.push({ line: i + 1, text: line });
  }
  return out;
}

/**
 * Parse ATX headings from visible lines.
 * @param {{ line: number, text: string }[]} lines
 * @returns {{ level: number, text: string, line: number, index: number }[]}
 *   `index` is the position in `lines`
 */
function headings(lines) {
  const out = [];
  lines.forEach((entry, index) => {
    const m = entry.text.match(HEADING);
    if (m) out.push({ level: m[1].length, text: m[2].trim(), line: entry.line, index });
  });
  return out;
}

/** Case- and whitespace-insensitive heading key. */
function headingKey(text) {
  return text.replace(/\s+/g, " ").trim().toLowerCase();
}

/** H3 headings under the H2 named `parent`, up to the next H2 or H1. */
function h3sUnder(all, parent) {
  const key = headingKey(parent);
  const out = [];
  let inside = false;
  for (const h of all) {
    if (h.level <= 2) {
      inside = h.level === 2 && headingKey(h.text) === key;
      continue;
    }
    if (inside && h.level === 3) out.push(h);
  }
  return out;
}

/** Template-derived requirements for one kind. */
function templateRequirements(kind, templateText) {
  const all = headings(visibleLines(templateText));
  const h2 = all.filter((h) => h.level === 2).map((h) => h.text);
  const h3 = [];
  for (const parent of REQUIRED_H3_PARENTS[kind]) {
    for (const h of h3sUnder(all, parent)) h3.push({ parent, text: h.text });
  }
  return { h2, h3 };
}

/** Plan-only rules: task markers and fields, last phase. */
function planGaps(lines, all) {
  const gaps = [];
  all.forEach((h, n) => {
    if (h.level !== 4 || !/^Task\b/i.test(h.text)) return;
    const label = `#### ${h.text} (line ${h.line})`;
    if (!TASK_MARKER.test(h.text)) {
      gaps.push(`task heading without a [CREATE], [MODIFY] or [REUSE] marker: ${label}`);
    }
    const next = all.slice(n + 1).find((later) => later.level <= 4);
    const body = lines.slice(h.index + 1, next ? next.index : lines.length);
    if (!body.some((l) => FILES_FIELD.test(l.text))) {
      gaps.push(`task without a **Files:** line: ${label}`);
    }
    if (!body.some((l) => DOD_FIELD.test(l.text))) {
      gaps.push(`task without a **Definition of Done** block: ${label}`);
    }
  });
  const phases = all.filter((h) => h.level === 3 && /^Phase\b/i.test(h.text));
  if (phases.length === 0) {
    gaps.push("no ### Phase heading found (the last phase must be Code Review)");
  } else {
    const last = phases[phases.length - 1];
    if (!/code review/i.test(last.text)) {
      gaps.push(`last phase is not Code Review: ### ${last.text} (line ${last.line})`);
    }
  }
  return gaps;
}

/**
 * Check one artifact against its template. Pure: no file access.
 * @param {{ kind: "plan" | "research", text: string, templateText: string }} input
 * @returns {{ ok: boolean, gaps: string[] }}
 */
export function validateSpecArtifact({ kind, text, templateText }) {
  if (kind !== "plan" && kind !== "research") {
    throw new TypeError(`validateSpecArtifact: unknown kind ${JSON.stringify(kind)}`);
  }
  if (typeof text !== "string" || typeof templateText !== "string") {
    throw new TypeError("validateSpecArtifact: text and templateText must be strings");
  }
  const req = templateRequirements(kind, templateText);
  const lines = visibleLines(text);
  const all = headings(lines);
  const gaps = [];

  const present = new Set(all.filter((h) => h.level === 2).map((h) => headingKey(h.text)));
  for (const name of req.h2) {
    if (!present.has(headingKey(name))) gaps.push(`missing section: ## ${name}`);
  }
  for (const { parent, text: name } of req.h3) {
    if (!present.has(headingKey(parent))) continue; // parent already reported
    const found = h3sUnder(all, parent).some((h) => headingKey(h.text) === headingKey(name));
    if (!found) gaps.push(`missing section: ### ${name} (under ## ${parent})`);
  }
  if (kind === "plan") gaps.push(...planGaps(lines, all));
  return { ok: gaps.length === 0, gaps };
}

/**
 * Read the template for a kind from TEMPLATE_PATHS.
 * @param {"plan" | "research"} kind
 * @returns {string}
 */
export function readTemplate(kind) {
  const file = TEMPLATE_PATHS[kind];
  try {
    return fs.readFileSync(file, "utf8");
  } catch (err) {
    throw new UsageError(`template not readable: ${file} (${err.code || err.message})`);
  }
}

/**
 * Plain-text report for one file. Failing reports end with LEGACY_HINT
 * unless `hint` is false.
 * @param {string} label file name shown to the reader
 * @param {string[]} gaps
 * @param {{ hint?: boolean }} [options]
 * @returns {string}
 */
export function formatGapReport(label, gaps, options = {}) {
  if (gaps.length === 0) return `${label}: ok`;
  const lines = [`${label}: ${gaps.length} gap${gaps.length === 1 ? "" : "s"}`];
  for (const gap of gaps) lines.push(`  - ${gap}`);
  if (options.hint !== false) lines.push(LEGACY_HINT);
  return lines.join("\n");
}

/** Validate one file from disk. Throws UsageError on kind or I/O problems. */
function validateFile(file, templates) {
  const kind = detectKind(file);
  if (!kind) {
    throw new UsageError(`cannot tell the artifact kind of ${file} (expected *.plan.md or *.research.md)`);
  }
  let text;
  try {
    text = fs.readFileSync(file, "utf8");
  } catch (err) {
    throw new UsageError(`file not readable: ${file} (${err.code || err.message})`);
  }
  if (!templates[kind]) templates[kind] = readTemplate(kind);
  return validateSpecArtifact({ kind, text, templateText: templates[kind] });
}

/** All *.plan.md / *.research.md under dir, sorted, skipping node_modules. */
function walkArtifacts(dir) {
  const out = [];
  const visit = (current) => {
    const entries = fs.readdirSync(current, { withFileTypes: true });
    entries.sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
    for (const entry of entries) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) {
        if (entry.name !== "node_modules") visit(full);
      } else if (entry.isFile() && detectKind(entry.name)) {
        out.push(full);
      }
    }
  };
  visit(dir);
  return out;
}

/** --report mode: list non-compliant files; returns the exit code. */
function runReport(dir, out) {
  let stat;
  try {
    stat = fs.statSync(dir);
  } catch {
    throw new UsageError(`report directory not found: ${dir}`);
  }
  if (!stat.isDirectory()) throw new UsageError(`not a directory: ${dir}`);
  const templates = {};
  const files = walkArtifacts(dir);
  let failing = 0;
  for (const file of files) {
    const result = validateFile(file, templates);
    if (result.ok) continue;
    failing++;
    out(formatGapReport(file, result.gaps, { hint: false }));
  }
  out(`${failing} of ${files.length} spec artifact${files.length === 1 ? "" : "s"} under ${dir} do not follow the template.`);
  if (failing > 0) out(LEGACY_HINT);
  return 0;
}

/**
 * CLI entry. Returns the exit code instead of exiting, so tests can call it.
 * @param {string[]} argv arguments after the script name
 * @param {{ out?: (s: string) => void, err?: (s: string) => void }} [io]
 * @returns {number}
 */
export function main(argv, io = {}) {
  const out = io.out || ((s) => process.stdout.write(`${s}\n`));
  const err = io.err || ((s) => process.stderr.write(`${s}\n`));
  try {
    if (argv.length === 0) throw new UsageError("no file given");
    if (argv.includes("--help") || argv.includes("-h")) {
      out(HELP.trimEnd());
      return 0;
    }
    if (argv[0] === "--report") {
      if (argv.length !== 2) throw new UsageError("--report takes exactly one directory");
      return runReport(argv[1], out);
    }
    const unknown = argv.find((a) => a.startsWith("--"));
    if (unknown) throw new UsageError(`unknown option: ${unknown}`);
    const templates = {};
    let failing = 0;
    for (const file of argv) {
      const result = validateFile(file, templates);
      if (!result.ok) failing++;
      out(formatGapReport(file, result.gaps));
    }
    return failing > 0 ? 1 : 0;
  } catch (e) {
    if (e instanceof UsageError) {
      err(`validate-spec-artifacts: ${e.message}`);
      err("Run with --help for usage.");
      return 2;
    }
    throw e;
  }
}

if (process.argv[1] && fs.realpathSync(process.argv[1]) === fs.realpathSync(__filename)) {
  // A reader that closes early (for example `--report docs/specs | head`)
  // raises EPIPE on stdout; stop quietly instead of printing a stack trace.
  process.stdout.on("error", (e) => {
    if (e.code === "EPIPE") process.exit(process.exitCode ?? 0);
    throw e;
  });
  process.exitCode = main(process.argv.slice(2));
}
