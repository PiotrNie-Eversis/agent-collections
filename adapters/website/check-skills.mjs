#!/usr/bin/env node
/**
 * Website docs adapter — skills existence/count check (TASK: website-docs-skills-prompts-sync).
 * Skill pages are curated summaries, NOT generated 1:1 from SKILL.md (procedural agent content
 * vs. a short human-facing page) — so this script only checks existence/count drift, never content:
 *   1. Every .ai/skills/<id>/ folder must be mentioned (by id string) somewhere in some
 *      website/docs/reference/skills/*.md file (content match, not filename — page slugs differ from ids).
 *   2. The "N reusable skills" count declared in website/docs/reference/skills/overview.md must match
 *      the actual number of .ai/skills subfolders.
 * Zero npm dependencies. Exit 1 on any drift (write mode: informational; --check/blocking use
 * the exit code from the caller).
 *
 * Usage (repo root):
 *   node adapters/website/check-skills.mjs
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

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

function listSkillIds(repoRoot) {
  const skillsDir = path.join(repoRoot, ".ai", "skills");
  return fs
    .readdirSync(skillsDir, { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => e.name)
    .sort();
}

function readSkillPagesText(repoRoot) {
  const dir = path.join(repoRoot, "website", "docs", "reference", "skills");
  const texts = [];
  for (const name of fs.readdirSync(dir).sort()) {
    if (!name.endsWith(".md")) continue;
    texts.push({ name, text: fs.readFileSync(path.join(dir, name), "utf8") });
  }
  return texts;
}

function findMissingSkillPages(repoRoot) {
  const ids = listSkillIds(repoRoot);
  const pages = readSkillPagesText(repoRoot);
  const haystack = pages.map((p) => p.text).join("\n---\n");
  const missing = ids.filter((id) => !haystack.includes(id));
  return { ids, missing };
}

function checkOverviewCount(repoRoot, actualCount) {
  const overviewPath = path.join(repoRoot, "website", "docs", "reference", "skills", "overview.md");
  if (!fs.existsSync(overviewPath)) {
    return `overview.md not found at ${overviewPath}`;
  }
  const text = fs.readFileSync(overviewPath, "utf8");
  const match = text.match(/\*\*(\d+) reusable skills\*\*/);
  if (!match) {
    return "overview.md does not declare a \"**N reusable skills**\" count";
  }
  const declared = Number(match[1]);
  if (declared !== actualCount) {
    return `overview.md declares ${declared} reusable skills, but .ai/skills/ has ${actualCount} folders`;
  }
  return null;
}

function run(repoRoot) {
  const { ids, missing } = findMissingSkillPages(repoRoot);
  const countError = checkOverviewCount(repoRoot, ids.length);

  const problems = [];
  if (missing.length > 0) {
    problems.push(
      `${missing.length} skill(s) with no matching website/docs/reference/skills/*.md page: ${missing.join(", ")}`,
    );
  }
  if (countError) {
    problems.push(countError);
  }

  if (problems.length > 0) {
    console.error("website docs: skills drift detected:");
    for (const p of problems) {
      console.error(`  ${p}`);
    }
    return false;
  }

  console.log(
    `website docs: skills check OK (${ids.length}/${ids.length} skills have a page, overview.md count matches)`,
  );
  return true;
}

function main() {
  const repoRoot = findRepoRoot(process.cwd());
  const ok = run(repoRoot);
  if (!ok) process.exit(1);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { findMissingSkillPages, checkOverviewCount, run, findRepoRoot };
