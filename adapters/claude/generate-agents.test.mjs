/**
 * Tests for the Claude Code role subagent generator (generate-agents.mjs),
 * the hooks generator (generate-hooks.mjs) and the spec artifact hook
 * launcher it writes (assets/eversis-validate-spec.cjs).
 *
 * Launcher runs use a throwaway project under the OS temp dir with its own
 * copy of the validator and templates, and a process cwd outside the
 * project, so the tests prove the launcher takes the project root from the
 * hook environment, never from the cwd.
 *
 * Run: node --test adapters/claude/generate-agents.test.mjs
 */

import { spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import { createRequire } from "node:module";
import os from "node:os";
import path from "node:path";
import { after, describe, it } from "node:test";
import assert from "node:assert/strict";
import { fileURLToPath } from "node:url";

import { GENERATED_MARKER as AGENT_MARKER, loadAgentMap, parseAgentMapYaml } from "./generate-agents.mjs";
import { GENERATED_MARKER as HOOK_MARKER } from "./generate-hooks.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, "..", "..");
const AGENTS_GENERATOR = path.join(__dirname, "generate-agents.mjs");
const HOOKS_GENERATOR = path.join(__dirname, "generate-hooks.mjs");
const LAUNCHER_ASSET = path.join(__dirname, "assets", "eversis-validate-spec.cjs");
const LAUNCHER_REL = path.join(".claude", "hooks", "eversis-validate-spec.cjs");
const FRAMEWORK_FILES = [
  "scripts/validate-spec-artifacts.mjs",
  ".ai/skills/eversis-task-analysing/research.example.md",
  ".ai/skills/eversis-creating-implementation-plans/plan.example.md",
];
const SELF_TEST_OK = "eversis-validate-spec self-test: ok";
const BAD_PLAN_REL = "docs/specs/proj-123-example/proj-123-example.plan.md";
const BAD_PLAN = [
  "# PROJ-123 example - Implementation Plan",
  "",
  "## Implementation Plan",
  "",
  "#### Task 1.1 - Task without a marker",
  "",
].join("\n");

const CREATED_DIRS = [];
after(() => {
  for (const dir of CREATED_DIRS) fs.rmSync(dir, { recursive: true, force: true });
});

function tmpDir(label) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), `eversis-${label}-`));
  CREATED_DIRS.push(dir);
  return dir;
}

/** A cwd that is neither the repo nor any test project. */
const ELSEWHERE = tmpDir("cwd");

function run(script, args, options = {}) {
  return spawnSync(process.execPath, [script, ...args], {
    cwd: options.cwd || REPO,
    encoding: "utf8",
    input: options.input,
    env: options.env || process.env,
  });
}

function generateHooks(out, prefix) {
  const args = ["--out", out];
  if (prefix !== undefined) args.push("--framework-prefix", prefix);
  const result = run(HOOKS_GENERATOR, args);
  assert.equal(result.status, 0, result.stderr);
  return path.join(out, LAUNCHER_REL);
}

function generateAgents(out, prefix) {
  const args = ["--out", out];
  if (prefix !== undefined) args.push("--framework-prefix", prefix);
  const result = run(AGENTS_GENERATOR, args);
  assert.equal(result.status, 0, result.stderr);
  return path.join(out, ".claude", "agents");
}

/** Copy the real validator and both templates under root. */
function installFramework(root) {
  for (const rel of FRAMEWORK_FILES) {
    const dest = path.join(root, rel);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(path.join(REPO, rel), dest);
  }
}

/** A stub validator under root whose only gap names `tag`, to see which root was used. */
function installStubFramework(root, tag) {
  const file = path.join(root, "scripts", "validate-spec-artifacts.mjs");
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(
    file,
    [
      'export function detectKind() { return "plan"; }',
      'export function readTemplate() { return ""; }',
      `export function validateSpecArtifact() { return { ok: false, gaps: [${JSON.stringify(`root=${tag}`)}] }; }`,
      'export function formatGapReport(label, gaps) { return label + ": " + gaps.join(", "); }',
      "",
    ].join("\n"),
  );
}

function writeProjectFile(project, rel, text) {
  const abs = path.join(project, rel);
  fs.mkdirSync(path.dirname(abs), { recursive: true });
  fs.writeFileSync(abs, text);
  return abs;
}

function hookInput(filePath, extra = {}) {
  return JSON.stringify({
    hook_event_name: "PostToolUse",
    tool_name: "Write",
    tool_input: { file_path: filePath, content: "" },
    ...extra,
  });
}

/**
 * Preload that makes the launcher see another Node version, to exercise the
 * version policy without installing old Node.
 */
function fakeNodeVersionPreload(version) {
  const file = path.join(tmpDir("node-version"), "fake-version.cjs");
  fs.writeFileSync(
    file,
    `Object.defineProperty(process.versions, "node", { value: ${JSON.stringify(version)} });\n`,
  );
  return file;
}

function runLauncher(launcher, { project, input, args = [], env = {}, nodeVersion }) {
  const childEnv = { ...process.env, ...env };
  delete childEnv.AGENT_COLLECTIONS_HOME;
  if (env.AGENT_COLLECTIONS_HOME) childEnv.AGENT_COLLECTIONS_HOME = env.AGENT_COLLECTIONS_HOME;
  if (project === undefined) delete childEnv.CLAUDE_PROJECT_DIR;
  else childEnv.CLAUDE_PROJECT_DIR = project;
  const nodeArgs = nodeVersion ? ["--require", fakeNodeVersionPreload(nodeVersion)] : [];
  return spawnSync(process.execPath, [...nodeArgs, launcher, ...args], {
    cwd: ELSEWHERE,
    encoding: "utf8",
    input: input || "",
    env: childEnv,
  });
}

/** Path → sha256 for every file under dir (snapshot for "nothing written"). */
function treeHash(dir) {
  const out = {};
  const visit = (current) => {
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) visit(full);
      else out[path.relative(dir, full)] = crypto.createHash("sha256").update(fs.readFileSync(full)).digest("hex");
    }
  };
  visit(dir);
  return out;
}

/** Self-host style project: framework at the root, launcher generated with an empty prefix. */
function selfHostProject() {
  const project = tmpDir("project");
  installFramework(project);
  const launcher = generateHooks(project);
  return { project, launcher };
}

describe("hook launcher: hook mode", () => {
  it("failing plan (absolute path, project from CLAUDE_PROJECT_DIR) → exit 2 with the gaps on stderr", () => {
    const { project, launcher } = selfHostProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, new RegExp(BAD_PLAN_REL.replace(/[.]/g, "\\.")));
    assert.match(result.stderr, /missing section: ## /);
    assert.match(result.stderr, /\[CREATE\]|CREATE/);
    assert.equal(result.stdout, "");
  });

  it("passing plan → exit 0 with no output", () => {
    const { project, launcher } = selfHostProject();
    const template = fs.readFileSync(path.join(REPO, FRAMEWORK_FILES[2]), "utf8");
    const abs = writeProjectFile(project, "docs/specs/proj-123-ok/proj-123-ok.plan.md", template);
    const result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stderr, "");
    assert.equal(result.stdout, "");
  });

  it("failing research file → exit 2", () => {
    const { project, launcher } = selfHostProject();
    const abs = writeProjectFile(project, "docs/specs/proj-123-r/proj-123-r.research.md", "# Research\n\n## Overview\n");
    const result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, /missing section/);
  });

  it("non-spec path → exit 0 with no output", () => {
    const { project, launcher } = selfHostProject();
    for (const rel of ["src/app.plan.md", "docs/specs/proj-123-x/notes.md", "README.md"]) {
      const abs = writeProjectFile(project, rel, BAD_PLAN);
      const result = runLauncher(launcher, { project, input: hookInput(abs) });
      assert.equal(result.status, 0, `${rel}: ${result.stderr}`);
      assert.equal(result.stdout + result.stderr, "", rel);
    }
    const outside = path.join(tmpDir("outside"), BAD_PLAN_REL);
    fs.mkdirSync(path.dirname(outside), { recursive: true });
    fs.writeFileSync(outside, BAD_PLAN);
    const result = runLauncher(launcher, { project, input: hookInput(outside) });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("malformed or empty stdin → exit 0 with no output", () => {
    const { project, launcher } = selfHostProject();
    for (const input of ["{not json", "", "null", "[]", JSON.stringify({ tool_input: { file_path: 42 } })]) {
      const result = runLauncher(launcher, { project, input });
      assert.equal(result.status, 0, `${input}: ${result.stderr}`);
      assert.equal(result.stdout + result.stderr, "", input);
    }
  });

  it("without CLAUDE_PROJECT_DIR the project root comes from the stdin cwd", () => {
    const { project, launcher } = selfHostProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, { project: undefined, input: hookInput(abs, { cwd: project }) });
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, /missing section/);
  });

  it("spec path with the validator missing → exit 2 naming the validator path", () => {
    const project = tmpDir("novalidator");
    const launcher = generateHooks(project, "vendor/agent-collections");
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 2);
    const expected = path.join(project, "vendor", "agent-collections", "scripts", "validate-spec-artifacts.mjs");
    assert.ok(result.stderr.includes(`validator not found at ${expected}`), result.stderr);
  });

  it("Node 18-21 → still validates, and the gap output ends with the end-of-life warning", () => {
    const { project, launcher } = selfHostProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, { project, input: hookInput(abs), nodeVersion: "20.11.0" });
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, /missing section/);
    assert.match(result.stderr.trimEnd().split("\n").pop(), /^warning: Node 20\.11\.0 is past end of life/);
  });

  it("Node below 18 → exit 2 with the Node version message, no validation", () => {
    const { project, launcher } = selfHostProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, { project, input: hookInput(abs), nodeVersion: "12.22.0" });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /Node 12\.22\.0 found, Agent Collections needs Node 22 or newer/);
    assert.doesNotMatch(result.stderr, /missing section/);
    const other = runLauncher(launcher, { project, input: hookInput(path.join(project, "README.md")), nodeVersion: "12.22.0" });
    assert.equal(other.status, 0, "a non-spec write is never blocked, whatever the Node version");
  });

  it("non-spec path with the validator missing → exit 0 (unrelated writes are never blocked)", () => {
    const project = tmpDir("novalidator");
    const launcher = generateHooks(project, "vendor/agent-collections");
    const abs = writeProjectFile(project, "src/index.js", "");
    const result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stderr, "");
  });
});

/**
 * Bash hook input for one event. The same session_id / tool_use_id pair
 * links a PreToolUse run to its PostToolUse run.
 */
function bashInput(event, extra = {}) {
  return JSON.stringify({
    session_id: "sess-1",
    tool_use_id: "toolu_01",
    hook_event_name: event,
    tool_name: "Bash",
    tool_input: { command: "printf 'x' >> docs/specs/proj-123-example/proj-123-example.plan.md" },
    ...extra,
  });
}

/** Self-host project plus a private TMPDIR for the marker directory. */
function bashProject() {
  const { project, launcher } = selfHostProject();
  const tmp = tmpDir("bash-tmp");
  return { project, launcher, tmp };
}

function runBash(launcher, { project, tmp, event, input, extra, nodeVersion }) {
  return runLauncher(launcher, {
    project,
    input: input !== undefined ? input : bashInput(event, extra),
    env: { TMPDIR: tmp, TMP: tmp, TEMP: tmp },
    nodeVersion,
  });
}

function markerDirIn(tmp) {
  const tag = typeof process.getuid === "function" ? String(process.getuid()) : os.userInfo().username.replace(/[^A-Za-z0-9_-]/g, "");
  return path.join(tmp, `eversis-validate-spec-${tag}`);
}

function markerFiles(tmp) {
  const dir = markerDirIn(tmp);
  return fs.existsSync(dir) ? fs.readdirSync(dir) : [];
}

/** Set a file's times to `ms` (epoch milliseconds). */
function setMtime(abs, ms) {
  fs.utimesSync(abs, ms / 1000, ms / 1000);
}

const OTHER_BAD_PLAN_REL = "docs/specs/proj-124-other/proj-124-other.plan.md";
const LEGACY_HINT_START = "A section missing from an existing file may be added";

describe("hook launcher: Bash before and after the command", () => {
  it("PreToolUse/Bash → exit 0, no output, one private marker file", () => {
    const { project, launcher, tmp } = bashProject();
    const result = runBash(launcher, { project, tmp, event: "PreToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
    const files = markerFiles(tmp);
    assert.equal(files.length, 1);
    if (typeof process.getuid === "function") {
      assert.equal(fs.statSync(markerDirIn(tmp)).mode & 0o777, 0o700);
    }
  });

  it("a bad plan written between PreToolUse and PostToolUse → exit 2 naming the file, marker gone", () => {
    const { project, launcher, tmp } = bashProject();
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(result.status, 2, result.stderr);
    assert.ok(result.stderr.includes(`${BAD_PLAN_REL}: `), result.stderr);
    assert.match(result.stderr, /missing section: ## /);
    assert.equal(result.stdout, "");
    assert.deepEqual(markerFiles(tmp), []);
  });

  it("a bad plan modified only before PreToolUse → exit 0", () => {
    const { project, launcher, tmp } = bashProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    setMtime(abs, Date.now() - 60_000);
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("two changed failing files → both named, the legacy hint printed once at the end", () => {
    const { project, launcher, tmp } = bashProject();
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    writeProjectFile(project, OTHER_BAD_PLAN_REL, BAD_PLAN);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(result.status, 2, result.stderr);
    assert.ok(result.stderr.includes(`${BAD_PLAN_REL}: `), result.stderr);
    assert.ok(result.stderr.includes(`${OTHER_BAD_PLAN_REL}: `), result.stderr);
    assert.equal(result.stderr.split(LEGACY_HINT_START).length - 1, 1, result.stderr);
    assert.ok(result.stderr.trimEnd().split("\n").pop().startsWith(LEGACY_HINT_START), result.stderr);
  });

  it("Node 18-21 → the end-of-life warning once, after the hint", () => {
    const { project, launcher, tmp } = bashProject();
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse", nodeVersion: "20.11.0" }).status, 0);
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    writeProjectFile(project, OTHER_BAD_PLAN_REL, BAD_PLAN);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse", nodeVersion: "20.11.0" });
    assert.equal(result.status, 2, result.stderr);
    assert.equal(result.stderr.split("is past end of life").length - 1, 1, result.stderr);
    assert.match(result.stderr.trimEnd().split("\n").pop(), /^warning: Node 20\.11\.0 is past end of life/);
  });

  it("a changed passing plan, or a changed non-spec file → exit 0 with no output", () => {
    const { project, launcher, tmp } = bashProject();
    const template = fs.readFileSync(path.join(REPO, FRAMEWORK_FILES[2]), "utf8");
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    writeProjectFile(project, "docs/specs/proj-123-ok/proj-123-ok.plan.md", template);
    writeProjectFile(project, "docs/specs/proj-123-x/notes.md", BAD_PLAN);
    writeProjectFile(project, "src/app.plan.md", BAD_PLAN);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("no marker (no PreToolUse run, or another tool_use_id) → exit 0", () => {
    const { project, launcher, tmp } = bashProject();
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    let result = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");

    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    writeProjectFile(project, BAD_PLAN_REL, `${BAD_PLAN}\n`);
    result = runBash(launcher, { project, tmp, event: "PostToolUse", extra: { tool_use_id: "toolu_02" } });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("without tool_use_id the key is a hash of session_id and the command", () => {
    const { project, launcher, tmp } = bashProject();
    const extra = { tool_use_id: undefined };
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse", extra }).status, 0);
    assert.equal(markerFiles(tmp).length, 1);
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse", extra });
    assert.equal(result.status, 2, result.stderr);
    assert.deepEqual(markerFiles(tmp), []);
  });

  it("malformed stdin on either event → exit 0 with no output", () => {
    const { project, launcher, tmp } = bashProject();
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const inputs = [
      "{not json",
      "",
      "null",
      JSON.stringify({ hook_event_name: "PreToolUse", tool_name: "Bash" }),
      JSON.stringify({ hook_event_name: "PostToolUse", tool_name: "Bash" }),
      JSON.stringify({ hook_event_name: "PreToolUse", tool_name: "Bash", session_id: 42, tool_use_id: {}, tool_input: "x" }),
      JSON.stringify({ hook_event_name: "PostToolUse", tool_name: "Bash", session_id: 42, tool_use_id: {}, tool_input: "x" }),
      JSON.stringify({ hook_event_name: "PreToolUse", tool_name: "Bash", tool_use_id: "../../etc" }),
      JSON.stringify({ hook_event_name: "Notification", tool_name: "Bash", session_id: "s", tool_use_id: "t" }),
    ];
    for (const input of inputs) {
      const result = runBash(launcher, { project, tmp, input });
      assert.equal(result.status, 0, `${input}: ${result.stderr}`);
      assert.equal(result.stdout + result.stderr, "", input);
    }
  });

  it("a symlinked directory inside docs/specs is not followed", { skip: process.platform === "win32" }, () => {
    const { project, launcher, tmp } = bashProject();
    const outside = tmpDir("bash-linked");
    fs.mkdirSync(path.join(project, "docs", "specs"), { recursive: true });
    fs.symlinkSync(outside, path.join(project, "docs", "specs", "proj-125-linked"), "dir");
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    fs.writeFileSync(path.join(outside, "proj-125-linked.plan.md"), BAD_PLAN);
    const result = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("PreToolUse/Bash with a symlink in place of the marker directory → exit 0, no output, nothing written", { skip: process.platform === "win32" }, () => {
    const { project, launcher, tmp } = bashProject();
    const target = tmpDir("bash-target");
    fs.symlinkSync(target, markerDirIn(tmp), "dir");
    const result = runBash(launcher, { project, tmp, event: "PreToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
    assert.deepEqual(fs.readdirSync(target), []);
    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const post = runBash(launcher, { project, tmp, event: "PostToolUse" });
    assert.equal(post.status, 0, post.stderr);
  });

  it("PreToolUse/Bash with an unwritable TMPDIR → exit 0, no output", () => {
    const { project, launcher } = bashProject();
    const missing = path.join(tmpDir("bash-missing"), "does", "not", "exist");
    const result = runBash(launcher, { project, tmp: missing, event: "PreToolUse" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("PreToolUse/Bash on Node below 18 still exits 0 with no output", () => {
    const { project, launcher, tmp } = bashProject();
    const result = runBash(launcher, { project, tmp, event: "PreToolUse", nodeVersion: "12.22.0" });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout + result.stderr, "");
  });

  it("markers older than 24 hours are removed when a new one is written", () => {
    const { project, launcher, tmp } = bashProject();
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse", extra: { tool_use_id: "toolu_old" } }).status, 0);
    const old = path.join(markerDirIn(tmp), markerFiles(tmp)[0]);
    setMtime(old, Date.now() - 25 * 60 * 60 * 1000);
    assert.equal(runBash(launcher, { project, tmp, event: "PreToolUse" }).status, 0);
    assert.ok(!fs.existsSync(old));
    assert.equal(markerFiles(tmp).length, 1);
  });

  it("Write/Edit input is unaffected by the Bash handling", () => {
    const { project, launcher, tmp } = bashProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runBash(launcher, { project, tmp, input: hookInput(abs, { session_id: "sess-1", tool_use_id: "toolu_01" }) });
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, /missing section/);
    assert.deepEqual(markerFiles(tmp), []);
  });
});

describe("hook launcher: framework root from the generated prefix", () => {
  it("vendored prefix resolves under <project>/<prefix>; AGENT_COLLECTIONS_HOME elsewhere does not redirect it", () => {
    const project = tmpDir("vendored");
    installStubFramework(path.join(project, "vendor", "agent-collections"), "vendor");
    const elsewhere = tmpDir("elsewhere");
    installStubFramework(elsewhere, "elsewhere");
    const launcher = generateHooks(project, "vendor/agent-collections");
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, {
      project,
      input: hookInput(abs),
      env: { AGENT_COLLECTIONS_HOME: elsewhere },
    });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /root=vendor/);
    assert.doesNotMatch(result.stderr, /root=elsewhere/);
  });

  it("${AGENT_COLLECTIONS_HOME} token: framework-home.txt first, then the env var", () => {
    const project = tmpDir("local");
    const recorded = tmpDir("recorded");
    installStubFramework(recorded, "home-file");
    const fromEnv = tmpDir("fromenv");
    installStubFramework(fromEnv, "env");
    const launcher = generateHooks(project, "${AGENT_COLLECTIONS_HOME}");
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);

    writeProjectFile(project, ".agent-collections/framework-home.txt", `${recorded}\n`);
    let result = runLauncher(launcher, { project, input: hookInput(abs), env: { AGENT_COLLECTIONS_HOME: fromEnv } });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /root=home-file/);

    fs.rmSync(path.join(project, ".agent-collections"), { recursive: true });
    result = runLauncher(launcher, { project, input: hookInput(abs), env: { AGENT_COLLECTIONS_HOME: fromEnv } });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /root=env/);

    result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /framework root not found/);
  });

  it("empty prefix (self-host) resolves the validator at the project root", () => {
    const project = tmpDir("selfhost");
    installStubFramework(project, "self-host");
    const launcher = generateHooks(project);
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runLauncher(launcher, { project, input: hookInput(abs) });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /root=self-host/);
  });
});

describe("hook launcher: --self-test", () => {
  it("real validator → exit 0 with the marker line, and no project file created or changed", () => {
    const { project, launcher } = selfHostProject();
    const before = treeHash(project);
    const result = runLauncher(launcher, { project, args: ["--self-test"] });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.stdout, `${SELF_TEST_OK}\n`);
    assert.deepEqual(treeHash(project), before);
  });

  it("validator missing → exit 1 naming the path, nothing written", () => {
    const project = tmpDir("selftest-missing");
    const launcher = generateHooks(project, "vendor/agent-collections");
    const before = treeHash(project);
    const result = runLauncher(launcher, { project, args: ["--self-test"] });
    assert.equal(result.status, 1);
    const expected = path.join(project, "vendor", "agent-collections", "scripts", "validate-spec-artifacts.mjs");
    assert.ok(result.stderr.includes(expected), result.stderr);
    assert.doesNotMatch(result.stdout, /self-test: ok/);
    assert.deepEqual(treeHash(project), before);
  });

  it("a validator that reports no gaps for the built-in bad plan → exit 1", () => {
    const project = tmpDir("selftest-lenient");
    const file = path.join(project, "scripts", "validate-spec-artifacts.mjs");
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(
      file,
      'export function readTemplate() { return ""; }\nexport function validateSpecArtifact() { return { ok: true, gaps: [] }; }\n',
    );
    const launcher = generateHooks(project);
    const result = runLauncher(launcher, { project, args: ["--self-test"] });
    assert.equal(result.status, 1);
    assert.doesNotMatch(result.stdout, /self-test: ok/);
  });
});

describe("hook launcher: source and exports", () => {
  const source = fs.readFileSync(LAUNCHER_ASSET, "utf8");

  it("uses no syntax that old Node cannot parse", () => {
    const wrapper = 'new Function("u", "return import(u)")';
    assert.equal(source.split(wrapper).length, 2, "the Function import wrapper appears exactly once");
    const rest = source.split(wrapper).join("");
    assert.ok(!rest.includes("?."), "no optional chaining");
    assert.ok(!rest.includes("??"), "no nullish coalescing");
    assert.doesNotMatch(rest, /^\s*import[\s{*"']/m, "no static import statement");
    assert.doesNotMatch(rest, /^\s*export\s/m, "no export statement");
    assert.doesNotMatch(rest, /\bimport\s*\(/, "no bare dynamic import call");
  });

  it("runs main() only when executed directly and exports the helpers", () => {
    assert.match(source, /if \(require\.main === module\)/);
    const require = createRequire(import.meta.url);
    const launcher = require(LAUNCHER_ASSET);
    assert.equal(typeof launcher.nodeVersionStatus, "function");
    assert.equal(typeof launcher.toProjectRelative, "function");
  });

  it("nodeVersionStatus follows the Node policy", () => {
    const { nodeVersionStatus } = createRequire(import.meta.url)(LAUNCHER_ASSET);
    assert.equal(nodeVersionStatus("12.22.0"), "error");
    assert.equal(nodeVersionStatus("v16.20.2"), "error");
    assert.equal(nodeVersionStatus("18.0.0"), "warn");
    assert.equal(nodeVersionStatus("20.11.0"), "warn");
    assert.equal(nodeVersionStatus("22.0.0"), "ok");
    assert.equal(nodeVersionStatus("24.1.0"), "ok");
    assert.equal(nodeVersionStatus("garbage"), "error");
  });

  it("toProjectRelative normalises absolute, Windows and relative paths", () => {
    const { toProjectRelative } = createRequire(import.meta.url)(LAUNCHER_ASSET);
    assert.equal(
      toProjectRelative("C:\\proj\\docs\\specs\\proj-123-x\\proj-123-x.plan.md", "C:\\proj"),
      "docs/specs/proj-123-x/proj-123-x.plan.md",
    );
    assert.equal(
      toProjectRelative("c:\\PROJ\\docs\\specs\\proj-123-x\\proj-123-x.plan.md", "C:\\proj\\"),
      "docs/specs/proj-123-x/proj-123-x.plan.md",
    );
    assert.equal(
      toProjectRelative("/work/proj/docs/specs/proj-123-x/proj-123-x.plan.md", "/work/proj"),
      "docs/specs/proj-123-x/proj-123-x.plan.md",
    );
    assert.equal(toProjectRelative("/work/proj/./docs/../docs/a.md", "/work/proj/"), "docs/a.md");
    assert.equal(toProjectRelative("docs/specs/a/a.plan.md", "/work/proj"), "docs/specs/a/a.plan.md");
    assert.equal(toProjectRelative("/work/project-b/docs/a.md", "/work/proj"), null);
    assert.equal(toProjectRelative("/work/proj/../other/a.md", "/work/proj"), null);
    assert.equal(toProjectRelative("", "/work/proj"), null);
    assert.equal(toProjectRelative(undefined, "/work/proj"), null);
  });

  it("markerKey keeps [A-Za-z0-9_-] of session_id + tool_use_id, else hashes session_id + command", () => {
    const { markerKey } = createRequire(import.meta.url)(LAUNCHER_ASSET);
    assert.equal(markerKey({ session_id: "abc-123", tool_use_id: "toolu_01X" }), "abc-123-toolu_01X");
    assert.equal(markerKey({ session_id: "a/../b", tool_use_id: "t.1 2" }), "ab-t12");
    const hashed = markerKey({ session_id: "s", tool_input: { command: "ls" } });
    assert.match(hashed, /^h-[0-9a-f]{40}$/);
    assert.equal(markerKey({ session_id: "s", tool_input: { command: "ls" } }), hashed);
    assert.notEqual(markerKey({ session_id: "s", tool_input: { command: "pwd" } }), hashed);
    assert.match(markerKey({ session_id: "s".repeat(300), tool_use_id: "t" }), /^k-[0-9a-f]{40}$/);
    assert.equal(markerKey({}), "");
    assert.equal(markerKey(null), "");
    assert.equal(markerKey({ session_id: 42, tool_use_id: {} }), "");
  });

  it("changedSpecArtifacts lists changed plan/research files, sorted, skipping links, dot-dirs and node_modules", () => {
    const { changedSpecArtifacts } = createRequire(import.meta.url)(LAUNCHER_ASSET);
    const project = tmpDir("changed");
    const since = Date.now() - 10_000;
    const old = writeProjectFile(project, "docs/specs/proj-123-a/proj-123-a.plan.md", "");
    setMtime(old, since - 1000);
    for (const rel of [
      "docs/specs/proj-123-b/proj-123-b.research.md",
      "docs/specs/proj-123-a/nested/proj-123-a.plan.md",
      "docs/specs/proj-123-a/notes.md",
      "docs/specs/.cache/proj-123-c.plan.md",
      "docs/specs/node_modules/proj-123-d.plan.md",
      "docs/other.plan.md",
    ]) {
      writeProjectFile(project, rel, "");
    }
    if (process.platform !== "win32") {
      const outside = tmpDir("changed-linked");
      fs.writeFileSync(path.join(outside, "proj-123-e.plan.md"), "");
      fs.symlinkSync(outside, path.join(project, "docs", "specs", "proj-123-e"), "dir");
      fs.symlinkSync(
        path.join(outside, "proj-123-e.plan.md"),
        path.join(project, "docs", "specs", "proj-123-b", "linked.plan.md"),
      );
    }
    assert.deepEqual(changedSpecArtifacts(project, since), [
      "docs/specs/proj-123-a/nested/proj-123-a.plan.md",
      "docs/specs/proj-123-b/proj-123-b.research.md",
    ]);
    assert.deepEqual(changedSpecArtifacts(tmpDir("changed-empty"), since), []);
    assert.deepEqual(changedSpecArtifacts("", since), []);
  });
});

describe("hooks generator", () => {
  it("fills in the prefix, appends the marker, and is byte-identical on a second run", () => {
    const out = tmpDir("hooks");
    const launcher = generateHooks(out, "vendor/agent-collections");
    const first = fs.readFileSync(launcher, "utf8");
    assert.ok(first.includes('var FRAMEWORK_PREFIX = "vendor/agent-collections";'));
    assert.ok(!first.includes("__EVERSIS_FRAMEWORK_PREFIX__"));
    assert.ok(first.trimEnd().endsWith(HOOK_MARKER));
    generateHooks(out, "vendor/agent-collections");
    assert.equal(fs.readFileSync(launcher, "utf8"), first);
  });

  it("removes a marker-bearing orphan launcher and keeps a hand-made one", () => {
    const out = tmpDir("hooks-orphan");
    const dir = path.join(out, ".claude", "hooks");
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, "eversis-old.cjs"), `// old\n${HOOK_MARKER}\n`);
    fs.writeFileSync(path.join(dir, "eversis-mine.cjs"), "// hand-made\n");
    generateHooks(out);
    assert.ok(!fs.existsSync(path.join(dir, "eversis-old.cjs")));
    assert.ok(fs.existsSync(path.join(dir, "eversis-mine.cjs")));
    assert.ok(fs.existsSync(path.join(dir, "eversis-validate-spec.cjs")));
  });

  it("rejects an absolute or escaping prefix", () => {
    for (const prefix of ["/abs/path", "../outside"]) {
      const result = run(HOOKS_GENERATOR, ["--out", tmpDir("hooks-bad"), "--framework-prefix", prefix]);
      assert.equal(result.status, 1, prefix);
    }
  });
});

describe("self-host settings entries", () => {
  const LAUNCHER_COMMAND = 'node "${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs"';

  /** Framework entries (inner hook names the launcher) of one hook event in this repo's settings. */
  function frameworkEntries(event) {
    const settings = JSON.parse(fs.readFileSync(path.join(REPO, ".claude", "settings.json"), "utf8"));
    return (settings.hooks[event] || []).filter((e) =>
      e.hooks.some((h) => String(h.command).includes(".claude/hooks/eversis-validate-spec.cjs")),
    );
  }

  /** A copy of this repo's generated launcher in a throwaway self-host project. */
  function settingsProject() {
    const project = tmpDir("settings");
    installFramework(project);
    fs.mkdirSync(path.join(project, ".claude", "hooks"), { recursive: true });
    fs.copyFileSync(path.join(REPO, LAUNCHER_REL), path.join(project, LAUNCHER_REL));
    return project;
  }

  /** Runs `command` through bash from another directory, the way Claude Code runs a hook. */
  function runSettingsCommand(command, project, input, env = {}) {
    return spawnSync("bash", ["-c", command], {
      cwd: ELSEWHERE,
      encoding: "utf8",
      input,
      env: { ...process.env, CLAUDE_PROJECT_DIR: project, ...env },
    });
  }

  it("holds exactly two framework entries: PreToolUse on Bash and PostToolUse on Write|Edit|MultiEdit|Bash", () => {
    const pre = frameworkEntries("PreToolUse");
    const post = frameworkEntries("PostToolUse");
    assert.equal(pre.length, 1);
    assert.equal(post.length, 1);
    assert.equal(pre[0].matcher, "Bash");
    assert.equal(post[0].matcher, "Write|Edit|MultiEdit|Bash");
    assert.deepEqual(pre[0].hooks, [{ type: "command", command: LAUNCHER_COMMAND }]);
    assert.deepEqual(post[0].hooks, [{ type: "command", command: LAUNCHER_COMMAND }]);
  });

  it("the PostToolUse command string, run through bash from another directory, blocks a bad plan written with Write", () => {
    const command = frameworkEntries("PostToolUse")[0].hooks[0].command;
    const project = settingsProject();
    const abs = writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const result = runSettingsCommand(command, project, hookInput(abs));
    assert.equal(result.status, 2, result.stderr);
    assert.match(result.stderr, /missing section/);
  });

  it("the PreToolUse and PostToolUse command strings, run through bash, block a bad plan written by a shell command", () => {
    const preCommand = frameworkEntries("PreToolUse")[0].hooks[0].command;
    const postCommand = frameworkEntries("PostToolUse")[0].hooks[0].command;
    const project = settingsProject();
    const tmp = tmpDir("settings-tmp");
    const env = { TMPDIR: tmp, TMP: tmp, TEMP: tmp };

    const pre = runSettingsCommand(preCommand, project, bashInput("PreToolUse"), env);
    assert.equal(pre.status, 0, pre.stderr);
    assert.equal(pre.stdout + pre.stderr, "");
    assert.equal(markerFiles(tmp).length, 1);

    writeProjectFile(project, BAD_PLAN_REL, BAD_PLAN);
    const post = runSettingsCommand(postCommand, project, bashInput("PostToolUse"), env);
    assert.equal(post.status, 2, post.stderr);
    assert.ok(post.stderr.includes(`${BAD_PLAN_REL}: `), post.stderr);
    assert.match(post.stderr, /missing section/);
    assert.deepEqual(markerFiles(tmp), []);
  });
});

describe("agents generator", () => {
  const agents = loadAgentMap();
  const ids = ["eversis-context-engineer", "eversis-architect", "eversis-code-reviewer"];

  it("the map lists the three roles and every read path exists", () => {
    assert.deepEqual(agents.map((a) => a.id), ids);
    for (const agent of agents) {
      for (const rel of agent.reads) {
        assert.ok(fs.existsSync(path.join(REPO, rel)), `${agent.id}: ${rel} does not exist`);
      }
    }
  });

  it("writes three files, prefixes every read path, and is byte-identical on a second run", () => {
    const out = tmpDir("agents");
    const dir = generateAgents(out, "vendor/agent-collections");
    const names = fs.readdirSync(dir).sort();
    assert.deepEqual(names, ids.map((id) => `${id}.md`).sort());
    const first = {};
    for (const agent of agents) {
      const text = fs.readFileSync(path.join(dir, `${agent.id}.md`), "utf8");
      first[agent.id] = text;
      assert.ok(text.startsWith(`---\nname: ${agent.id}\n`));
      assert.ok(text.trimEnd().endsWith(AGENT_MARKER));
      for (const rel of agent.reads) {
        assert.ok(text.includes(`\`vendor/agent-collections/${rel}\``), `${agent.id}: ${rel} not prefixed`);
      }
    }
    generateAgents(out, "vendor/agent-collections");
    for (const agent of agents) {
      assert.equal(fs.readFileSync(path.join(dir, `${agent.id}.md`), "utf8"), first[agent.id]);
    }
  });

  it("every body carries the hand-back rule and the template rules", () => {
    const dir = generateAgents(tmpDir("agents-body"));
    for (const id of ids) {
      const text = fs.readFileSync(path.join(dir, `${id}.md`), "utf8");
      assert.match(text, /Hand-back rule: you cannot talk to the person\./);
      assert.match(text, /list the questions in your final message and stop/);
      assert.match(text, /put the exact text in your final message/);
      assert.match(text, /never from earlier `docs\/specs\/\*` files/);
      assert.match(text, /first Changelog row names the template used/);
      assert.match(text, /Do not ask the person for approval/);
    }
  });

  it("the code reviewer cannot write: tools without Write/Edit and readonly: true", () => {
    const dir = generateAgents(tmpDir("agents-reviewer"));
    const text = fs.readFileSync(path.join(dir, "eversis-code-reviewer.md"), "utf8");
    const frontmatter = text.split("\n---\n")[0];
    assert.match(frontmatter, /^tools: Read, Grep, Glob, Bash$/m);
    assert.doesNotMatch(frontmatter, /^tools:.*\b(Write|Edit|MultiEdit)\b/m);
    assert.match(frontmatter, /^readonly: true$/m);
    assert.match(text, /PASS \/ BLOCKER \/ SUGGESTION/);
    for (const id of ["eversis-context-engineer", "eversis-architect"]) {
      const other = fs.readFileSync(path.join(dir, `${id}.md`), "utf8").split("\n---\n")[0];
      assert.doesNotMatch(other, /^(tools|readonly):/m, id);
    }
  });

  it("removes a marker-bearing orphan and keeps a hand-made eversis-x.md", () => {
    const out = tmpDir("agents-orphan");
    const dir = path.join(out, ".claude", "agents");
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, "eversis-retired.md"), `old\n${AGENT_MARKER}\n`);
    fs.writeFileSync(path.join(dir, "eversis-x.md"), "hand-made\n");
    generateAgents(out);
    assert.ok(!fs.existsSync(path.join(dir, "eversis-retired.md")));
    assert.ok(fs.existsSync(path.join(dir, "eversis-x.md")));
  });

  it("the map parser rejects unknown keys", () => {
    assert.throws(
      () => parseAgentMapYaml("version: 1\nagents:\n  - id: eversis-x\n    colour: red\n"),
      /unknown key: colour/,
    );
  });
});
