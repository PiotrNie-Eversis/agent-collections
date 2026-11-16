/**
 * Rule registry check used by `adapters/sync.mjs --check`.
 *
 * A rule file under .ai/rules/ reaches a host only through the adapter rule
 * maps. A file that no map lists is silently not emitted, and the generators'
 * drift comparison cannot see it. This module closes that gap: every
 * .ai/rules/**\/*.md file (README.md files excluded) must be either a `source`
 * in adapters/cursor/rule-map.yaml (the Claude and Pi maps are held to the
 * same id/source pairs by the parity checks in sync.mjs) or an entry in
 * adapters/rules-not-emitted.yaml with a reason.
 *
 * parseNotEmittedYaml() and findRuleRegistryProblems() are pure;
 * listRuleFiles() reads the directory tree. Zero npm dependencies.
 */

import fs from "node:fs";
import path from "node:path";

export const RULES_DIR = ".ai/rules";
export const NOT_EMITTED_FILE = "adapters/rules-not-emitted.yaml";
export const CURSOR_MAP_FILE = "adapters/cursor/rule-map.yaml";

function stripQuotes(value) {
  if (
    value.length >= 2 &&
    ((value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'")))
  ) {
    return value.slice(1, -1);
  }
  return value;
}

/**
 * Drop a trailing ` # comment` that starts outside quotes, so a quoted value
 * may contain " #".
 */
function stripTrailingComment(line) {
  let quote = null;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (quote) {
      if (ch === quote) quote = null;
    } else if (ch === '"' || ch === "'") {
      quote = ch;
    } else if (ch === "#" && i > 0 && /\s/.test(line[i - 1])) {
      return line.slice(0, i).replace(/\s+$/, "");
    }
  }
  return line;
}

/**
 * Constrained YAML parser for adapters/rules-not-emitted.yaml:
 *   version: 1
 *   not_emitted:
 *     - source: <path>
 *       reason: "<text>"
 * Throws an Error naming the line on any other shape, on a key repeated
 * within one entry, and when the `not_emitted` key is missing.
 * A ` #` inside a quoted value is kept; outside quotes it starts a comment.
 *
 * @param {string} text
 * @returns {{ version: number | null, entries: { source?: string, reason?: string, line: number }[] }}
 */
export function parseNotEmittedYaml(text) {
  const doc = { version: null, entries: [] };
  let sawList = false;
  let inList = false;
  let current = null;
  const lines = text.split(/\r?\n/);

  for (let i = 0; i < lines.length; i++) {
    const rawLine = lines[i];
    const line = stripTrailingComment(rawLine);
    if (!line.trim() || line.trim().startsWith("#")) continue;
    const indent = line.match(/^ */)[0].length;
    const trimmed = line.trim();
    const unexpected = () =>
      new Error(`${NOT_EMITTED_FILE}: unexpected line ${i + 1}: ${rawLine}`);

    if (indent === 0) {
      if (trimmed.startsWith("version:")) {
        const value = trimmed.slice("version:".length).trim();
        doc.version = /^\d+$/.test(value) ? Number(value) : value;
        inList = false;
        continue;
      }
      if (trimmed === "not_emitted:" || trimmed === "not_emitted: []") {
        inList = trimmed === "not_emitted:";
        sawList = true;
        continue;
      }
      throw unexpected();
    }

    let pair = null;
    if (inList && indent === 2 && trimmed.startsWith("- ")) {
      current = { line: i + 1 };
      doc.entries.push(current);
      pair = trimmed.slice(2).trim();
    } else if (inList && current && indent === 4) {
      pair = trimmed;
    } else {
      throw unexpected();
    }

    const idx = pair.indexOf(":");
    if (idx === -1) throw unexpected();
    const key = pair.slice(0, idx).trim();
    if (key !== "source" && key !== "reason") throw unexpected();
    if (Object.prototype.hasOwnProperty.call(current, key)) {
      throw new Error(
        `${NOT_EMITTED_FILE}: line ${i + 1}: key "${key}" repeated in the entry that starts on line ${current.line}`,
      );
    }
    current[key] = stripQuotes(pair.slice(idx + 1).trim());
  }

  if (!sawList) {
    throw new Error(`${NOT_EMITTED_FILE}: missing key not_emitted (use "not_emitted: []" for none)`);
  }

  return doc;
}

/**
 * Repo-relative paths (forward slashes, sorted) of every .md file under
 * .ai/rules/ except README.md files.
 *
 * @param {string} repoRoot
 * @returns {string[]}
 */
export function listRuleFiles(repoRoot) {
  const out = [];
  const walk = (relDir) => {
    const absDir = path.join(repoRoot, relDir);
    if (!fs.existsSync(absDir)) return;
    for (const entry of fs.readdirSync(absDir, { withFileTypes: true })) {
      const rel = `${relDir}/${entry.name}`;
      if (entry.isDirectory()) {
        walk(rel);
      } else if (entry.isFile() && entry.name.endsWith(".md") && entry.name !== "README.md") {
        out.push(rel);
      }
    }
  };
  walk(RULES_DIR);
  return out.sort();
}

/**
 * Compare the rule files with the Cursor map sources and the exception list.
 *
 * @param {{
 *   ruleFiles: string[],
 *   mappedSources: string[],
 *   notEmitted: { source?: string, reason?: string, line?: number }[],
 * }} input
 * @returns {string[]} one message per problem; empty when the registry is complete
 */
export function findRuleRegistryProblems({ ruleFiles, mappedSources, notEmitted }) {
  const problems = [];
  const files = new Set(ruleFiles);
  const mapped = new Set(mappedSources);
  const excluded = new Map();

  for (const entry of notEmitted) {
    const where = entry.line ? ` (line ${entry.line})` : "";
    if (!entry.source) {
      problems.push(`${NOT_EMITTED_FILE}${where}: entry has no source`);
      continue;
    }
    if (excluded.has(entry.source)) {
      problems.push(`${NOT_EMITTED_FILE}${where}: ${entry.source} is listed twice`);
    }
    excluded.set(entry.source, entry);
    if (!entry.reason || !entry.reason.trim()) {
      problems.push(`${NOT_EMITTED_FILE}${where}: ${entry.source} has no reason`);
    }
    if (!files.has(entry.source)) {
      problems.push(
        `${NOT_EMITTED_FILE}${where}: ${entry.source} is not a rule file under ${RULES_DIR}/ (remove the entry)`,
      );
    }
    if (mapped.has(entry.source)) {
      problems.push(
        `${entry.source} is both a source in ${CURSOR_MAP_FILE} and listed in ${NOT_EMITTED_FILE} (keep one)`,
      );
    }
  }

  for (const file of ruleFiles) {
    if (!mapped.has(file) && !excluded.has(file)) {
      problems.push(
        `unregistered rule: ${file} — add it to ${CURSOR_MAP_FILE}, adapters/claude/rule-map.yaml and adapters/pi/rule-map.yaml, or list it with a reason in ${NOT_EMITTED_FILE}`,
      );
    }
  }

  return problems;
}
