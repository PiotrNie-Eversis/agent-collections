/**
 * Tests for scripts/pi-load-check.mjs (AC-138).
 * Unit tests feed inline JSON-lines RPC fixtures to the exported pure helpers
 * (no Pi needed). Integration tests run only when `pi` is on PATH: they install
 * the framework once through the CLI (--keep), then copy that project, break it
 * (bad prompt front matter, broken extension, malformed .pi/mcp.json) and run
 * the CLI with --project. Zero dependencies.
 *
 * Run: node --test scripts/pi-load-check.test.mjs
 */

import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { after, test } from "node:test";
import { fileURLToPath } from "node:url";

import {
  buildPiEnv,
  diffSnapshots,
  evaluate,
  findPiPackageDir,
  formatReport,
  listExpected,
  parseRpcOutput,
  snapshotDir,
} from "./pi-load-check.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(__dirname, "..");
const CLI = path.join(__dirname, "pi-load-check.mjs");

const tmpDirs = [];
function mkTmp() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-load-check-test-"));
  tmpDirs.push(dir);
  return dir;
}
after(() => {
  for (const dir of tmpDirs) fs.rmSync(dir, { recursive: true, force: true });
});

function findPiOnPath() {
  for (const dir of (process.env.PATH ?? "").split(path.delimiter)) {
    if (!dir) continue;
    const candidate = path.join(dir, "pi");
    try {
      fs.accessSync(candidate, fs.constants.X_OK);
      if (fs.statSync(candidate).isFile()) return candidate;
    } catch {
      // keep looking
    }
  }
  return null;
}
const PI_BIN = findPiOnPath();
const hasPi = PI_BIN !== null;

// --- fixtures ----------------------------------------------------------------

const P = "/proj/.pi";
const EXPECTED = [
  { kind: "prompt", name: "eversis-implement", path: `${P}/prompts/eversis-implement.md` },
  { kind: "prompt", name: "eversis-review", path: `${P}/prompts/eversis-review.md` },
  { kind: "skill", name: "skill:eversis-fine-handoff", path: `${P}/skills/eversis-fine-handoff/SKILL.md` },
];

function cmd(source, name, filePath) {
  const c = { name, description: "d", source };
  if (filePath !== undefined) {
    c.sourceInfo = { path: filePath, source: "auto", scope: "project", origin: "top-level" };
  }
  return c;
}

const BUILTIN_EXTENSIONS = [
  { name: "llama", source: "extension", sourceInfo: { path: "builtin:llama.cpp", source: "builtin" } },
  { name: "mcp", source: "extension", sourceInfo: { path: "builtin:mcp", source: "builtin" } },
];

function fullCommands() {
  return [
    ...BUILTIN_EXTENSIONS,
    ...EXPECTED.map((e) => cmd(e.kind, e.name, e.path)),
  ];
}

function response(commands) {
  return JSON.stringify({
    id: "load-check",
    type: "response",
    command: "get_commands",
    success: true,
    data: { commands },
  });
}

function notify(message) {
  return JSON.stringify({
    type: "extension_ui_request",
    id: "n-1",
    method: "notify",
    message,
    notifyType: "warning",
  });
}

const MCP_CONNECTION_FAILED = notify(
  "MCP servers need attention:\n  eversis-collections: failed: MCP connection closed\nRun /mcp to fix.",
);
const MCP_CONFIG_ERROR = notify(
  "MCP servers need attention:\n  config: /proj/.pi/mcp.json: Expected double-quoted property name in JSON at position 4\nRun /mcp to fix.",
);

function run(stdout, overrides = {}) {
  return evaluate({
    exitCode: 0,
    stderr: "",
    timedOut: false,
    rpc: parseRpcOutput(stdout),
    expected: EXPECTED,
    mcpLoaderErrors: [],
    homeChanged: [],
    ...overrides,
  });
}

// --- parseRpcOutput / evaluate -----------------------------------------------

test("clean run passes with counts and built-in extensions as info", () => {
  const result = run(`${response(fullCommands())}\n${MCP_CONNECTION_FAILED}\n`);
  assert.deepEqual(result.problems, []);
  assert.deepEqual(result.warnings, []);
  assert.deepEqual(result.counts, {
    prompts: { expected: 2, loaded: 2 },
    skills: { expected: 1, loaded: 1 },
  });
  assert.ok(result.info.some((i) => i.includes("Pi extension command: llama")));
  const report = formatReport({ piVersion: "1.5.0", label: "pinned" }, result);
  assert.match(report, /^Pi 1\.5\.0 \(pinned\)\n/);
  assert.match(report, /prompts: 2\/2 loaded/);
  assert.match(report, /skills: {2}1\/1 loaded/);
  assert.match(report, /PASS/);
  assert.match(report, /Pi stderr: \(empty\)/);
});

test("parseRpcOutput collects commands, notify messages and non-JSON lines", () => {
  const rpc = parseRpcOutput(`${response(fullCommands())}\nnot json\n${MCP_CONNECTION_FAILED}\n\n`);
  assert.equal(rpc.commands.length, 5);
  assert.equal(rpc.notifications.length, 1);
  assert.match(rpc.notifications[0], /MCP servers need attention/);
  assert.deepEqual(rpc.nonJson, ["not json"]);
});

test("missing prompt is named", () => {
  const commands = fullCommands().filter((c) => c.name !== "eversis-review");
  const result = run(response(commands));
  assert.equal(result.problems.length, 1);
  assert.match(result.problems[0], /^Missing prompt: eversis-review \(/);
  assert.deepEqual(result.counts.prompts, { expected: 2, loaded: 1 });
});

test("missing skill is named", () => {
  const commands = fullCommands().filter((c) => c.source !== "skill");
  const result = run(response(commands));
  assert.equal(result.problems.length, 1);
  assert.match(result.problems[0], /^Missing skill: skill:eversis-fine-handoff \(/);
});

test("matches by sourceInfo.path, not by name, when the path is present", () => {
  // Same name but loaded from another file (e.g. a user-global prompt): still missing.
  const commands = fullCommands().map((c) =>
    c.name === "eversis-review" ? cmd("prompt", "eversis-review", "/home/u/.pi/agent/prompts/eversis-review.md") : c,
  );
  const result = run(response(commands));
  assert.equal(result.problems.length, 1);
  assert.match(result.problems[0], /Missing prompt: eversis-review/);
  assert.ok(result.info.some((i) => i.includes("Extra prompt command not generated by the installer: eversis-review")));
});

test("falls back to name when sourceInfo is absent", () => {
  const commands = EXPECTED.map((e) => cmd(e.kind, e.name));
  const result = run(response(commands));
  assert.deepEqual(result.problems, []);
  assert.deepEqual(result.counts.skills, { expected: 1, loaded: 1 });
});

test("extension load error: exit 1 and stderr, no response", () => {
  const stderr = 'Error: Failed to load extension "/proj/.pi/extensions/broken.ts": ParseError: Unexpected token\n';
  const result = run("", { exitCode: 1, stderr });
  assert.ok(result.problems.includes("Pi exited with code 1"));
  assert.ok(result.problems.includes("Pi sent no successful get_commands response"));
  assert.ok(result.problems.some((p) => p.startsWith("Pi wrote to stderr: Error: Failed to load extension")));
  const report = formatReport({ piVersion: "1.5.0", label: "latest" }, result);
  assert.match(report, /^Pi 1\.5\.0 \(latest\)/);
  assert.match(report, /FAIL — Pi 1\.5\.0/);
  assert.match(report, /Pi stderr:\nError: Failed to load extension/);
});

test("stderr alone fails with 'Pi wrote to stderr:'", () => {
  const result = run(response(fullCommands()), { stderr: "warning: something\n" });
  assert.deepEqual(result.problems, ["Pi wrote to stderr: warning: something"]);
});

test("MCP config: line in the notify event fails", () => {
  const result = run(`${response(fullCommands())}\n${MCP_CONFIG_ERROR}\n`);
  assert.equal(result.problems.length, 1);
  assert.match(result.problems[0], /^MCP config error \(Pi notify\): \/proj\/\.pi\/mcp\.json: Expected double-quoted/);
});

test("MCP 'failed: MCP connection closed' is info only", () => {
  const result = run(`${response(fullCommands())}\n${MCP_CONNECTION_FAILED}\n`);
  assert.deepEqual(result.problems, []);
  assert.ok(result.info.some((i) => i.includes("eversis-collections: failed: MCP connection closed")));
});

test("MCP loader errors fail the check", () => {
  const result = run(response(fullCommands()), {
    mcpLoaderErrors: ["/proj/.pi/mcp.json: Expected double-quoted property name"],
  });
  assert.deepEqual(result.problems, ["MCP config error (Pi loader): /proj/.pi/mcp.json: Expected double-quoted property name"]);
});

test("timeout with no response fails", () => {
  const result = run("", { exitCode: null, timedOut: true });
  assert.deepEqual(result.problems, ["Pi timed out before answering get_commands"]);
  assert.deepEqual(result.counts.prompts, { expected: 2, loaded: 0 });
});

test("no response without timeout fails", () => {
  const failed = JSON.stringify({ type: "response", command: "get_commands", success: false, error: "x" });
  const result = run(failed);
  assert.deepEqual(result.problems, ["Pi sent no successful get_commands response"]);
});

test("mcpLoaderErrors null gives a warning, not a failure", () => {
  const result = run(response(fullCommands()), { mcpLoaderErrors: null });
  assert.deepEqual(result.problems, []);
  assert.equal(result.warnings.length, 1);
  assert.match(result.warnings[0], /MCP loader/);
  assert.match(formatReport({ piVersion: "9.9.9", label: "latest" }, result), /warning: Pi MCP loader/);
});

test("home changes fail the check, all problems are listed", () => {
  const commands = fullCommands().filter((c) => c.source !== "skill");
  const result = run(response(commands), { homeChanged: ["added: trust.json"], stderr: "oops\n" });
  assert.equal(result.problems.length, 3);
  assert.ok(result.problems.includes("Real ~/.pi/agent changed during the run: added: trust.json"));
  const report = formatReport({ piVersion: "1.5.0", label: "pinned" }, result);
  assert.match(report, /3 problem\(s\)/);
  for (const p of result.problems) assert.ok(report.includes(`  - ${p.split("\n")[0]}`));
});

// --- snapshots ---------------------------------------------------------------

test("diffSnapshots: absent → present", () => {
  const dir = path.join(mkTmp(), "agent");
  const before = snapshotDir(dir);
  assert.deepEqual(before, { absent: true });
  fs.mkdirSync(dir);
  fs.writeFileSync(path.join(dir, "auth.json"), "{}");
  const changes = diffSnapshots(before, snapshotDir(dir));
  assert.equal(changes.length, 1);
  assert.match(changes[0], /^created/);
  assert.deepEqual(diffSnapshots({ absent: true }, { absent: true }), []);
});

test("diffSnapshots: file added, changed, removed; sessions/ and install/ ignored", () => {
  const dir = mkTmp();
  fs.writeFileSync(path.join(dir, "settings.json"), "{}");
  fs.writeFileSync(path.join(dir, "gone.json"), "{}");
  fs.mkdirSync(path.join(dir, "sessions"));
  fs.mkdirSync(path.join(dir, "install"));
  const before = snapshotDir(dir);
  assert.equal(before.entries["sessions"], undefined);

  fs.writeFileSync(path.join(dir, "sessions", "s.jsonl"), "x");
  fs.writeFileSync(path.join(dir, "install", "current-version"), "1.5.0");
  assert.deepEqual(diffSnapshots(before, snapshotDir(dir)), []);

  fs.writeFileSync(path.join(dir, "trust.json"), "{}");
  fs.writeFileSync(path.join(dir, "settings.json"), '{"changed":true}');
  fs.rmSync(path.join(dir, "gone.json"));
  assert.deepEqual(diffSnapshots(before, snapshotDir(dir)), [
    "removed: gone.json",
    "changed: settings.json",
    "added: trust.json",
  ]);
});

// --- env ---------------------------------------------------------------------

test("buildPiEnv has exactly PATH, HOME, TERM, NODE_NO_WARNINGS", () => {
  const saved = { a: process.env.ANTHROPIC_API_KEY, o: process.env.OPENAI_API_KEY };
  process.env.ANTHROPIC_API_KEY = "sk-ant-test";
  process.env.OPENAI_API_KEY = "sk-test";
  try {
    const env = buildPiEnv({ path: "/stub:/usr/bin", home: "/tmp/h" });
    assert.deepEqual(Object.keys(env).sort(), ["HOME", "NODE_NO_WARNINGS", "PATH", "TERM"]);
    assert.deepEqual(env, { PATH: "/stub:/usr/bin", HOME: "/tmp/h", TERM: "dumb", NODE_NO_WARNINGS: "1" });
    assert.ok(!JSON.stringify(env).includes("sk-"));
  } finally {
    if (saved.a === undefined) delete process.env.ANTHROPIC_API_KEY;
    else process.env.ANTHROPIC_API_KEY = saved.a;
    if (saved.o === undefined) delete process.env.OPENAI_API_KEY;
    else process.env.OPENAI_API_KEY = saved.o;
  }
});

test("listExpected reads generated prompts and skills by name", () => {
  const root = mkTmp();
  fs.mkdirSync(path.join(root, ".pi", "prompts"), { recursive: true });
  fs.mkdirSync(path.join(root, ".pi", "skills", "eversis-a"), { recursive: true });
  fs.mkdirSync(path.join(root, ".pi", "skills", "no-skill-file"), { recursive: true });
  fs.writeFileSync(path.join(root, ".pi", "prompts", "eversis-x.md"), "");
  fs.writeFileSync(path.join(root, ".pi", "prompts", "mine.md"), "");
  fs.writeFileSync(path.join(root, ".pi", "skills", "eversis-a", "SKILL.md"), "");
  const real = fs.realpathSync(root);
  assert.deepEqual(listExpected(root), [
    { kind: "prompt", name: "eversis-x", path: path.join(real, ".pi", "prompts", "eversis-x.md") },
    { kind: "skill", name: "skill:eversis-a", path: path.join(real, ".pi", "skills", "eversis-a", "SKILL.md") },
  ]);
});

// --- integration (needs pi on PATH) ------------------------------------------

function runCli(args) {
  const r = spawnSync(process.execPath, [CLI, ...args], {
    cwd: REPO_ROOT,
    encoding: "utf8",
    timeout: 240000,
  });
  return { status: r.status, out: `${r.stdout}${r.stderr}` };
}

let baseProject = null;
function installedProject() {
  if (baseProject !== null) return baseProject;
  const r = runCli(["--keep", "--label", "test", "--settle-ms", "1500"]);
  const kept = /kept temp dir (.+)$/m.exec(r.out);
  assert.ok(kept, `CLI did not print the kept temp dir:\n${r.out}`);
  tmpDirs.push(kept[1]);
  assert.equal(r.status, 0, `clean install must pass:\n${r.out}`);
  assert.match(r.out, /^Pi \S+ \(test\)$/m);
  baseProject = path.join(kept[1], "project");
  return baseProject;
}

function brokenCopy(mutate) {
  const dest = path.join(mkTmp(), "project");
  fs.cpSync(installedProject(), dest, { recursive: true, verbatimSymlinks: true });
  mutate(dest);
  return dest;
}

test("integration: clean install passes", { skip: !hasPi }, () => {
  assert.ok(fs.existsSync(path.join(installedProject(), ".pi", "mcp.json")));
});

test("integration: unquoted 'description: Bad: x' prompt fails and is named (AC2)", { skip: !hasPi }, () => {
  const project = brokenCopy((dir) => {
    fs.writeFileSync(
      path.join(dir, ".pi", "prompts", "eversis-zz-bad.md"),
      "---\ndescription: Bad: x\n---\nBody\n",
    );
  });
  const r = runCli(["--project", project, "--settle-ms", "1500"]);
  assert.equal(r.status, 1, r.out);
  assert.match(r.out, /Missing prompt: eversis-zz-bad/);
});

test("integration: broken .pi/extensions/*.ts fails", { skip: !hasPi }, () => {
  const project = brokenCopy((dir) => {
    fs.writeFileSync(path.join(dir, ".pi", "extensions", "zz-broken.ts"), "export default function ( {\n");
  });
  const r = runCli(["--project", project, "--settle-ms", "1500"]);
  assert.equal(r.status, 1, r.out);
  assert.match(r.out, /Pi exited with code|Pi wrote to stderr:/);
  assert.match(r.out, /zz-broken\.ts/);
});

test("integration: malformed .pi/mcp.json fails with the loader error line", { skip: !hasPi }, () => {
  const project = brokenCopy((dir) => {
    fs.writeFileSync(path.join(dir, ".pi", "mcp.json"), "{ mcpServers: }\n");
  });
  const r = runCli(["--project", project, "--settle-ms", "1500"]);
  assert.equal(r.status, 1, r.out);
  assert.match(r.out, /MCP config error \(Pi loader\): .*mcp\.json/);
});

test("integration: findPiPackageDir finds the MCP loader", { skip: !hasPi }, () => {
  const dir = findPiPackageDir(PI_BIN);
  assert.ok(dir, "Pi package folder found");
  assert.ok(fs.existsSync(path.join(dir, "dist", "extensions", "mcp", "config.js")));
});
