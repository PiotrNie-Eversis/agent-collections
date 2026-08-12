#!/usr/bin/env node
/**
 * Generate website/src/pages/changelog.md from root CHANGELOG.md (SSOT).
 *
 * Usage:
 *   node scripts/sync-changelog.mjs          # write generated page
 *   node scripts/sync-changelog.mjs --check  # exit 1 if committed page would change
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..");
const src = path.join(root, "CHANGELOG.md");
const dest = path.join(root, "website/src/pages/changelog.md");

const GITHUB_BLOB =
  "https://github.com/PiotrNie-Eversis/agent-collections/blob/main";

const checkOnly = process.argv.includes("--check");

if (!fs.existsSync(src)) {
  console.error(`sync-changelog: missing ${src}`);
  process.exit(1);
}

let body = fs.readFileSync(src, "utf8");

// Site-friendly targets for root-relative links used in CHANGELOG.md
const replacements = [
  ["[README](./README.md)", `[README](${GITHUB_BLOB}/README.md)`],
  ["[README.md](./README.md)", `[README.md](${GITHUB_BLOB}/README.md)`],
  ["](./README.md)", `](${GITHUB_BLOB}/README.md)`],
];

for (const [from, to] of replacements) {
  body = body.split(from).join(to);
}

const frontmatter = `---
title: Changelog
---

:::tip Source of truth
This page is **generated** from [\`CHANGELOG.md\`](${GITHUB_BLOB}/CHANGELOG.md) in the repository root. Edit that file only, then run \`node scripts/sync-changelog.mjs\` (or rely on \`website\` \`prestart\` / \`prebuild\`). Do not hand-edit this page.
:::

`;

const output = frontmatter + body;
if (!output.endsWith("\n")) {
  // keep trailing newline for stable diffs
}

const normalized = output.endsWith("\n") ? output : `${output}\n`;

if (checkOnly) {
  if (!fs.existsSync(dest)) {
    console.error(
      "sync-changelog --check: missing website/src/pages/changelog.md (run without --check first)",
    );
    process.exit(1);
  }
  const existing = fs.readFileSync(dest, "utf8");
  if (existing !== normalized) {
    console.error(
      "sync-changelog --check: website/src/pages/changelog.md is out of sync with CHANGELOG.md",
    );
    console.error("Run: node scripts/sync-changelog.mjs");
    process.exit(1);
  }
  console.log("sync-changelog --check: OK");
  process.exit(0);
}

fs.mkdirSync(path.dirname(dest), { recursive: true });
fs.writeFileSync(dest, normalized, "utf8");
console.log("sync-changelog: wrote website/src/pages/changelog.md");
