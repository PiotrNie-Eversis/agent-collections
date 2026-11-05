/**
 * Every eversis-* token in generated Pi prompts must resolve to a prompt or a
 * skill (AC-134). Runs the generator CLI into a temp directory; never starts Pi.
 *
 * Run: node --test 'adapters/pi/*.test.mjs'
 */

import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { after, test } from "node:test";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(__dirname, "..", "..");
const GENERATOR = path.join(__dirname, "generate.mjs");

/**
 * Tokens that are not prompts or skills: the MCP server name, the consumer
 * project-stack overlay, and two upstream provenance names in an HTML comment.
 */
const ALLOWLIST = new Set([
  "eversis-collections",
  "eversis-project-stack",
  "eversis-write-documentation",
  "eversis-writing-documentation",
]);

const TOKEN_RE = /(?<![a-z0-9_-])eversis-[a-z0-9]+(?:-[a-z0-9]+)*/g;

/** Tokens in text that are in neither the known set nor the allowlist. */
function unresolvedTokens(text, known) {
  const tokens = text.match(TOKEN_RE) ?? [];
  return [...new Set(tokens)].filter((token) => !known.has(token) && !ALLOWLIST.has(token));
}

const out = fs.mkdtempSync(path.join(os.tmpdir(), "pi-adapter-test-"));
after(() => fs.rmSync(out, { recursive: true, force: true }));

const generated = spawnSync(process.execPath, [GENERATOR, "--out", out], {
  cwd: REPO_ROOT,
  encoding: "utf8",
});
assert.equal(generated.status, 0, `generate failed: ${generated.stderr}`);

const promptsDir = path.join(out, ".pi", "prompts");
const promptFiles = fs.readdirSync(promptsDir).filter((name) => name.endsWith(".md"));
const readPrompt = (id) => fs.readFileSync(path.join(promptsDir, `${id}.md`), "utf8");

const known = new Set([
  ...promptFiles.map((name) => name.replace(/\.md$/, "")),
  ...fs.readdirSync(path.join(out, ".pi", "skills")),
  ...fs
    .readdirSync(path.join(REPO_ROOT, ".ai", "skills"), { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name.startsWith("eversis-"))
    .map((entry) => entry.name),
]);

test("every eversis-* token in all 28 generated prompts resolves", () => {
  assert.equal(promptFiles.length, 28);
  for (const name of promptFiles) {
    const text = fs.readFileSync(path.join(promptsDir, name), "utf8");
    assert.deepEqual(unresolvedTokens(text, known), [], name);
  }
});

test("the check fails on an unknown eversis-* token", () => {
  assert.deepEqual(
    unresolvedTokens("Load `eversis-review` and `eversis-no-such-thing`.", known),
    ["eversis-no-such-thing"],
  );
  assert.deepEqual(unresolvedTokens("`eversis-agent-core.mdc`", known), ["eversis-agent-core"]);
});

test("rule ids are rewritten to role skills, boundary-aware, dropping .mdc", () => {
  const implement = readPrompt("eversis-implement");
  assert.ok(implement.includes("`eversis-rule-engineering-manager`"));
  assert.doesNotMatch(implement, /(?<![a-z0-9_-])eversis-engineering-manager/);

  const planner = readPrompt("eversis-ba-docs-planner");
  assert.ok(planner.includes("`eversis-rule-agent-core`"));
  assert.ok(!planner.includes("eversis-agent-core"));
  assert.ok(!planner.includes("eversis-rule-agent-core.mdc"));
});

test("target none ids and longer names are unchanged", () => {
  const qa = readPrompt("eversis-qa-workflow");
  assert.ok(qa.includes("eversis-accessibility-auditing"));
  assert.ok(!qa.includes("eversis-rule-accessibility-auditing"));
  assert.ok(readPrompt("eversis-implement").includes("eversis-fine-handoff"));
  assert.ok(!readPrompt("eversis-implement").includes("eversis-rule-fine-handoff"));
});

test("a rule id inside a longer name is unchanged on either side", () => {
  // No real prompt has such a name, so this runs on a fixture prompt. The real
  // rules and skills are linked in, because the generator reads them.
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "pi-adapter-test-"));
  const fixtureOut = fs.mkdtempSync(path.join(os.tmpdir(), "pi-adapter-test-"));
  after(() => {
    fs.rmSync(repo, { recursive: true, force: true });
    fs.rmSync(fixtureOut, { recursive: true, force: true });
  });
  fs.mkdirSync(path.join(repo, "adapters"));
  fs.mkdirSync(path.join(repo, ".ai", "prompts", "public"), { recursive: true });
  for (const name of ["rules", "skills"]) {
    fs.symlinkSync(path.join(REPO_ROOT, ".ai", name), path.join(repo, ".ai", name));
  }
  fs.writeFileSync(
    path.join(repo, ".ai", "prompts", "public", "eversis-fixture.md"),
    "Fixture prompt.\n\nKeep my-eversis-agent-core, x_eversis-agent-core, 1eversis-agent-core and eversis-agent-core-extra.\nRewrite `eversis-agent-core`.\n",
  );
  const result = spawnSync(process.execPath, [GENERATOR, "--out", fixtureOut], {
    cwd: repo,
    encoding: "utf8",
  });
  assert.equal(result.status, 0, `generate failed: ${result.stderr}`);
  const prompt = fs.readFileSync(path.join(fixtureOut, ".pi", "prompts", "eversis-fixture.md"), "utf8");
  assert.ok(prompt.includes("Keep my-eversis-agent-core, x_eversis-agent-core, 1eversis-agent-core and eversis-agent-core-extra."));
  assert.ok(prompt.includes("Rewrite `eversis-rule-agent-core`."), "the plain id is still rewritten");
});

test("the consumer overlay name keeps its .mdc file name", () => {
  assert.ok(readPrompt("eversis-create-custom-instructions").includes("`eversis-project-stack.mdc`"));
});
