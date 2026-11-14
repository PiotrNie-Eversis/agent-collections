/**
 * Tests for scripts/validate-spec-artifacts.mjs.
 * Unit tests run the pure check against the real templates and against
 * variants of them with one rule broken at a time. CLI tests run the script
 * as a child process on temp files and check exit codes 0/1/2 and the
 * --report mode. Zero dependencies.
 *
 * Run: node --test scripts/validate-spec-artifacts.test.mjs
 */

import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { after, test } from "node:test";
import { fileURLToPath } from "node:url";

import {
  LEGACY_HINT,
  TEMPLATE_PATHS,
  detectKind,
  readTemplate,
  validateSpecArtifact,
} from "./validate-spec-artifacts.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CLI = path.join(__dirname, "validate-spec-artifacts.mjs");
const PLAN_TEMPLATE = readTemplate("plan");
const RESEARCH_TEMPLATE = readTemplate("research");

const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "validate-spec-artifacts-"));
after(() => fs.rmSync(tmpRoot, { recursive: true, force: true }));

function checkPlan(text) {
  return validateSpecArtifact({ kind: "plan", text, templateText: PLAN_TEMPLATE });
}

function checkResearch(text) {
  return validateSpecArtifact({ kind: "research", text, templateText: RESEARCH_TEMPLATE });
}

/** Replace exactly one occurrence of `from` in `text`; fails when absent. */
function replaceOnce(text, from, to) {
  assert.ok(text.includes(from), `fixture anchor not found: ${from}`);
  return text.replace(from, to);
}

/** Remove the H2 section `name` (heading up to the next H2) from `text`. */
function dropSection(text, name) {
  const start = text.indexOf(`## ${name}\n`);
  assert.ok(start >= 0, `section not found: ${name}`);
  const next = text.indexOf("\n## ", start + 1);
  return text.slice(0, start) + (next < 0 ? "" : text.slice(next + 1));
}

function runCli(args) {
  return spawnSync(process.execPath, [CLI, ...args], { encoding: "utf8" });
}

function writeTemp(rel, text) {
  const file = path.join(tmpRoot, rel);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, text);
  return file;
}

test("templates are located relative to the script", () => {
  for (const file of Object.values(TEMPLATE_PATHS)) {
    assert.ok(path.isAbsolute(file));
    assert.ok(fs.existsSync(file), file);
  }
});

test("detectKind reads the file name only", () => {
  assert.equal(detectKind("docs/specs/proj-123-x/proj-123-x.plan.md"), "plan");
  assert.equal(detectKind("docs\\specs\\proj-123-x\\proj-123-x.research.md"), "research");
  assert.equal(detectKind("/abs/plan.example.md"), "plan");
  assert.equal(detectKind("research.example.md"), "research");
  assert.equal(detectKind("docs/specs/proj-123-x/proj-123-x.plan-review.md"), null);
  assert.equal(detectKind("README.md"), null);
  assert.equal(detectKind(""), null);
});

test("both templates pass their own check", () => {
  assert.deepEqual(checkPlan(PLAN_TEMPLATE), { ok: true, gaps: [] });
  assert.deepEqual(checkResearch(RESEARCH_TEMPLATE), { ok: true, gaps: [] });
});

test("unknown kind is rejected", () => {
  assert.throws(
    () => validateSpecArtifact({ kind: "notes", text: "", templateText: "" }),
    TypeError,
  );
});

test("plan: task heading without a marker is a named gap", () => {
  const text = replaceOnce(
    PLAN_TEMPLATE,
    "#### Task 1.2 - [CREATE/MODIFY/REUSE] <task-name>",
    "#### Task 1.2 - Wire the PROJ-123 endpoint",
  );
  const result = checkPlan(text);
  assert.equal(result.ok, false);
  assert.equal(result.gaps.length, 1);
  assert.match(result.gaps[0], /without a \[CREATE\], \[MODIFY\] or \[REUSE\] marker/);
  assert.match(result.gaps[0], /#### Task 1\.2 - Wire the PROJ-123 endpoint \(line \d+\)/);
});

test("plan: single and combined markers are accepted", () => {
  for (const marker of ["[CREATE]", "[MODIFY]", "[REUSE]", "[CREATE/MODIFY]", "[MODIFY / REUSE]"]) {
    const text = replaceOnce(
      PLAN_TEMPLATE,
      "#### Task 1.2 - [CREATE/MODIFY/REUSE] <task-name>",
      `#### Task 1.2 - ${marker} Something`,
    );
    assert.deepEqual(checkPlan(text).gaps, [], marker);
  }
});

test("plan: task without **Files:** is a named gap", () => {
  const text = replaceOnce(
    PLAN_TEMPLATE,
    "**Files:** `src/<feature>.ts` (create), `src/<feature>.types.ts` (reuse)\n",
    "",
  );
  const result = checkPlan(text);
  assert.equal(result.gaps.length, 1);
  assert.match(result.gaps[0], /task without a \*\*Files:\*\* line: #### Task 1\.1/);
});

test("plan: task without **Definition of Done** is a named gap", () => {
  const start = PLAN_TEMPLATE.indexOf("#### Task 1.2");
  const dod = PLAN_TEMPLATE.indexOf("**Definition of Done**:", start);
  const text = PLAN_TEMPLATE.slice(0, dod) + "**Checks**:" + PLAN_TEMPLATE.slice(dod + "**Definition of Done**:".length);
  const result = checkPlan(text);
  assert.equal(result.gaps.length, 1);
  assert.match(result.gaps[0], /task without a \*\*Definition of Done\*\* block: #### Task 1\.2/);
});

test("plan: last phase that is not Code Review is a named gap", () => {
  const text = replaceOnce(PLAN_TEMPLATE, "### Phase 3: Code Review", "### Phase 3: Rollout");
  const result = checkPlan(text);
  assert.equal(result.gaps.length, 1);
  assert.match(result.gaps[0], /last phase is not Code Review: ### Phase 3: Rollout \(line \d+\)/);
});

test("plan: no phase at all is a named gap", () => {
  const text = PLAN_TEMPLATE.replace(/^### Phase .*$/gm, "### Stage");
  const result = checkPlan(text);
  assert.deepEqual(result.gaps, ["no ### Phase heading found (the last phase must be Code Review)"]);
});

test("plan: missing ## Human gates is a named gap", () => {
  const result = checkPlan(dropSection(PLAN_TEMPLATE, "Human gates"));
  assert.deepEqual(result.gaps, ["missing section: ## Human gates"]);
});

test("plan: every missing H2 is listed", () => {
  const text = dropSection(dropSection(PLAN_TEMPLATE, "Security Considerations"), "Changelog");
  assert.deepEqual(checkPlan(text).gaps, [
    "missing section: ## Security Considerations",
    "missing section: ## Changelog",
  ]);
});

test("research: missing H2 is a named gap", () => {
  const result = checkResearch(dropSection(RESEARCH_TEMPLATE, "Business Impact"));
  assert.deepEqual(result.gaps, ["missing section: ## Business Impact"]);
});

test("research: missing Changelog is a named gap", () => {
  const result = checkResearch(dropSection(RESEARCH_TEMPLATE, "Changelog"));
  assert.deepEqual(result.gaps, ["missing section: ## Changelog"]);
});

test("research: missing H3 under Gathered Information is a named gap", () => {
  const text = replaceOnce(RESEARCH_TEMPLATE, "### Codebase\n", "### Code notes\n");
  assert.deepEqual(checkResearch(text).gaps, [
    "missing section: ### Codebase (under ## Gathered Information)",
  ]);
});

test("research: H3 placed under the wrong H2 does not count", () => {
  const without = replaceOnce(RESEARCH_TEMPLATE, "### Key Files and Directories\n", "");
  const text = replaceOnce(without, "## Gap Analysis\n", "## Gap Analysis\n\n### Key Files and Directories\n");
  assert.deepEqual(checkResearch(text).gaps, [
    "missing section: ### Key Files and Directories (under ## Current Implementation Status)",
  ]);
});

test("research: Gap Analysis questions are not required", () => {
  const text = RESEARCH_TEMPLATE.replace(/^### Question \d+\n#### .*\n.*\n/gm, "");
  assert.ok(!text.includes("### Question"));
  assert.deepEqual(checkResearch(text).gaps, []);
});

test("extra sections are allowed", () => {
  const plan = replaceOnce(PLAN_TEMPLATE, "## Human gates\n", "## Rollout notes\n\nPROJ-123 only.\n\n## Human gates\n");
  assert.deepEqual(checkPlan(plan).gaps, []);
  const research = replaceOnce(RESEARCH_TEMPLATE, "## Gap Analysis\n", "## Risks\n\n### Data\n\n## Gap Analysis\n");
  assert.deepEqual(checkResearch(research).gaps, []);
});

test("headings inside code fences are ignored", () => {
  const removed = dropSection(RESEARCH_TEMPLATE, "Business Impact");
  const fenced = `${removed}\n\`\`\`markdown\n## Business Impact\n\`\`\`\n\n~~~~\n## Business Impact\n~~~~\n`;
  assert.deepEqual(checkResearch(fenced).gaps, ["missing section: ## Business Impact"]);

  const fakeTask = replaceOnce(
    PLAN_TEMPLATE,
    "## Security Considerations\n",
    "```text\n#### Task 9.9 - no marker here\n### Phase 9: Rollout\n```\n\n## Security Considerations\n",
  );
  assert.deepEqual(checkPlan(fakeTask).gaps, []);
});

test("headings inside HTML comments are ignored", () => {
  const removed = dropSection(PLAN_TEMPLATE, "Open Questions");
  const commented = replaceOnce(
    removed,
    "## Technical Context\n",
    "<!--\n## Open Questions\n#### Task 9.9 - no marker\n-->\n<!-- ## Open Questions -->\n\n## Technical Context\n",
  );
  assert.deepEqual(checkPlan(commented).gaps, ["missing section: ## Open Questions"]);
});

test("CRLF line endings are accepted", () => {
  assert.deepEqual(checkPlan(PLAN_TEMPLATE.replace(/\n/g, "\r\n")).gaps, []);
  assert.deepEqual(checkResearch(RESEARCH_TEMPLATE.replace(/\n/g, "\r\n")).gaps, []);
});

test("CLI: passing file exits 0", () => {
  const file = writeTemp("pass/proj-123-ok/proj-123-ok.plan.md", PLAN_TEMPLATE);
  const r = runCli([file]);
  assert.equal(r.status, 0, r.stderr);
  assert.match(r.stdout, /: ok$/m);
});

test("CLI: file with gaps exits 1 and ends with the legacy hint", () => {
  const file = writeTemp(
    "fail/proj-123-bad/proj-123-bad.research.md",
    dropSection(RESEARCH_TEMPLATE, "Changelog"),
  );
  const r = runCli([file]);
  assert.equal(r.status, 1, r.stderr);
  assert.match(r.stdout, /missing section: ## Changelog/);
  assert.ok(r.stdout.trimEnd().endsWith(LEGACY_HINT));
});

test("CLI: usage and I/O errors exit 2", () => {
  assert.equal(runCli([]).status, 2);
  assert.equal(runCli(["--bogus"]).status, 2);
  assert.equal(runCli([writeTemp("notes/proj-123-notes.md", "# Notes\n")]).status, 2);
  assert.equal(runCli([path.join(tmpRoot, "missing", "proj-123-x.plan.md")]).status, 2);
  assert.equal(runCli(["--report"]).status, 2);
  assert.equal(runCli(["--report", path.join(tmpRoot, "no-such-dir")]).status, 2);
});

test("CLI: --help documents both modes and the exit codes", () => {
  const r = runCli(["--help"]);
  assert.equal(r.status, 0);
  assert.match(r.stdout, /--report <dir>/);
  assert.match(r.stdout, /<file>\.\.\./);
  assert.match(r.stdout, /Exit codes/);
});

test("CLI: --report exits 0 and lists only non-compliant files", () => {
  const dir = path.join(tmpRoot, "report");
  writeTemp("report/proj-123-a/proj-123-a.plan.md", PLAN_TEMPLATE);
  writeTemp("report/proj-123-a/proj-123-a.research.md", dropSection(RESEARCH_TEMPLATE, "Changelog"));
  writeTemp("report/proj-123-b/proj-123-b.plan.md", replaceOnce(PLAN_TEMPLATE, "### Phase 3: Code Review", "### Phase 3: Rollout"));
  writeTemp("report/proj-123-b/notes.md", "# not an artifact\n");
  const r = runCli(["--report", dir]);
  assert.equal(r.status, 0, r.stderr);
  assert.match(r.stdout, /proj-123-a\.research\.md: 1 gap/);
  assert.match(r.stdout, /proj-123-b\.plan\.md: 1 gap/);
  assert.doesNotMatch(r.stdout, /proj-123-a\.plan\.md/);
  assert.match(r.stdout, /2 of 3 spec artifacts under .* do not follow the template\./);
});
