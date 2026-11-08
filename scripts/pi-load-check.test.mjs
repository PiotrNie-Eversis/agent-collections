/**
 * Tests for scripts/pi-load-check.mjs (AC-138, AC-139).
 * Unit tests feed inline JSON-lines RPC fixtures to the exported pure helpers
 * (no Pi needed). Stub-Pi tests (AC-139) need no Pi either: they put a `/bin/sh`
 * script named `pi` first on PATH and run the CLI with --project against an
 * empty `.pi/` (normal exit with a background process, a failed response split
 * across two chunks, a hang that ignores SIGTERM) and check the run's exit,
 * timing and that no stub process is left. A fourth stub test starts a `perl`
 * process that calls `setsid` (leaves Pi's group) and keeps stdout open; it
 * checks the run still ends by the timeout's SIGKILL step, reported as timed
 * out, and kills that process itself (skipped when `perl` is not on PATH).
 * They are skipped on Windows.
 * Integration tests run only when `pi` is on PATH: they install
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

test("parseRpcOutput: any complete get_commands response sets responded (AC-139 R3)", () => {
  const failed = JSON.stringify({ type: "response", command: "get_commands", success: false, error: "x" });
  const rpc = parseRpcOutput(`${failed}\n`);
  assert.equal(rpc.responded, true);
  assert.equal(rpc.commands, null);
  assert.equal(parseRpcOutput(response(fullCommands())).responded, true);
  // The state the stdout handler sees after the first half of a split line.
  assert.equal(parseRpcOutput('{"type":"resp').responded, false);
  assert.equal(parseRpcOutput("").responded, false);
});

test("other MCP notice lines show as info, header and hint do not (AC-139 R4)", () => {
  const message = notify(
    "MCP servers need attention:\n  eversis-collections: failed: MCP connection closed\n  something new from Pi\nRun /mcp to fix.",
  );
  const result = run(`${response(fullCommands())}\n${message}\n`);
  assert.deepEqual(result.problems, []);
  const notices = result.info.filter((i) => i.startsWith("MCP notice:"));
  assert.deepEqual(notices, ["MCP notice: something new from Pi"]);
  assert.ok(result.info.some((i) => i.includes("eversis-collections: failed:")));
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

// --- stub Pi (AC-139; /bin/sh, no real Pi) -----------------------------------

const noStub = process.platform === "win32";

function onPath(name) {
  for (const dir of (process.env.PATH ?? "").split(path.delimiter)) {
    if (!dir) continue;
    try {
      fs.accessSync(path.join(dir, name), fs.constants.X_OK);
      return true;
    } catch {
      // keep looking
    }
  }
  return false;
}
const noPerl = noStub || !onPath("perl");

/**
 * Write a `pi` shell stub into a temp bin/ dir. The stub answers --version
 * first (never writes stderr) and then runs `body`. Pi's env holds only PATH,
 * HOME, TERM and NODE_NO_WARNINGS, so PID files go to an absolute dir baked in
 * as $PIDS. Returns the project (empty .pi/), the PID dir and the CLI env.
 */
function stubPi(body) {
  const dir = mkTmp();
  const bin = path.join(dir, "bin");
  const pids = path.join(dir, "pids");
  const project = path.join(dir, "project");
  for (const d of [bin, pids, path.join(project, ".pi")]) fs.mkdirSync(d, { recursive: true });
  const script = [
    "#!/bin/sh",
    'case "$1" in --version) echo 0.0.0-stub; exit 0 ;; esac',
    `PIDS='${pids}'`,
    body,
    "",
  ].join("\n");
  fs.writeFileSync(path.join(bin, "pi"), script);
  fs.chmodSync(path.join(bin, "pi"), 0o755);
  const env = { ...process.env, PATH: `${bin}${path.delimiter}${process.env.PATH ?? ""}` };
  return { project, pids, env };
}

/** Run the CLI with `env`; fails fast (30 s) and reports the elapsed time. */
function runCliStub(args, env) {
  const start = Date.now();
  const r = spawnSync(process.execPath, [CLI, ...args], {
    cwd: REPO_ROOT,
    env,
    encoding: "utf8",
    timeout: 30000,
  });
  return { status: r.status, out: `${r.stdout}${r.stderr}`, elapsedMs: Date.now() - start };
}

function readPid(pids, name, out) {
  const file = path.join(pids, name);
  assert.ok(fs.existsSync(file), `stub did not record PID "${name}"; CLI output:\n${out}`);
  const pid = Number(fs.readFileSync(file, "utf8").trim());
  assert.ok(Number.isInteger(pid) && pid > 0, `bad PID in ${file}`);
  return pid;
}

/** Gone = no such process, or a zombie (not yet reaped by its new parent). */
function processGone(pid) {
  try {
    process.kill(pid, 0);
  } catch (err) {
    return err.code === "ESRCH" || err.code === "EPERM";
  }
  if (process.platform === "linux") {
    try {
      const stat = fs.readFileSync(`/proc/${pid}/stat`, "utf8");
      return stat.slice(stat.lastIndexOf(")") + 2).startsWith("Z");
    } catch {
      return true;
    }
  }
  const ps = spawnSync("ps", ["-o", "stat=", "-p", String(pid)], { encoding: "utf8" });
  const state = `${ps.stdout ?? ""}`.trim();
  return state === "" || state.startsWith("Z");
}

/** Poll up to 2 s for every PID to be gone; kill any survivor so none leaks. */
async function assertAllGone(pidList, out) {
  const deadline = Date.now() + 2000;
  let alive = pidList.filter((p) => !processGone(p));
  while (alive.length > 0 && Date.now() < deadline) {
    await new Promise((r) => setTimeout(r, 50));
    alive = alive.filter((p) => !processGone(p));
  }
  for (const p of alive) {
    try {
      process.kill(p, "SIGKILL");
    } catch {
      // already gone
    }
  }
  assert.deepEqual(alive, [], `stub process(es) still running after the run; CLI output:\n${out}`);
}

test("stub Pi: normal exit leaves no background process and does not wait for the timeout (AC-139 R2, AC2)", { skip: noStub }, async () => {
  const ok = JSON.stringify({ type: "response", command: "get_commands", success: true, data: { commands: [] } });
  const { project, pids, env } = stubPi(
    [`printf '%s\\n' '${ok}'`, "sleep 300 &", 'echo $! > "$PIDS/sleep"', "cat > /dev/null", "exit 0"].join("\n"),
  );
  const r = runCliStub(["--project", project, "--settle-ms", "200", "--timeout-ms", "20000"], env);
  const sleepPid = readPid(pids, "sleep", r.out);
  await assertAllGone([sleepPid], r.out);
  assert.doesNotMatch(r.out, /timed out/, r.out);
  assert.ok(r.elapsedMs < 10000, `CLI took ${r.elapsedMs} ms:\n${r.out}`);
});

test("stub Pi: failed response split across two chunks fails without the timeout (AC-139 R3, AC3)", { skip: noStub }, () => {
  const { project, env } = stubPi(
    [
      `printf '%s' '{"type":"resp'`,
      "sleep 1",
      `printf '%s\\n' 'onse","command":"get_commands","success":false,"error":"x"}'`,
      "cat > /dev/null",
      "exit 0",
    ].join("\n"),
  );
  const r = runCliStub(["--project", project, "--settle-ms", "200", "--timeout-ms", "20000"], env);
  assert.equal(r.status, 1, r.out);
  assert.match(r.out, /Pi sent no successful get_commands response/);
  assert.doesNotMatch(r.out, /timed out/, r.out);
  assert.ok(r.elapsedMs < 10000, `CLI took ${r.elapsedMs} ms:\n${r.out}`);
});

test("stub Pi: hang that ignores SIGTERM times out, exits 1 and leaves no process (AC-139 R6, AC6)", { skip: noStub }, async () => {
  const { project, pids, env } = stubPi(
    ["trap '' TERM", 'echo $$ > "$PIDS/pi"', "sleep 300 &", 'echo $! > "$PIDS/sleep"', "wait"].join("\n"),
  );
  const r = runCliStub(["--project", project, "--settle-ms", "200", "--timeout-ms", "1000"], env);
  const piPid = readPid(pids, "pi", r.out);
  const sleepPid = readPid(pids, "sleep", r.out);
  await assertAllGone([piPid, sleepPid], r.out);
  assert.equal(r.status, 1, r.out);
  assert.match(r.out, /Pi timed out before answering get_commands/);
});

test("stub Pi: pipe held open from outside the group ends at the timeout, reported as timed out (AC-139)", { skip: noPerl }, async () => {
  const ok = JSON.stringify({ type: "response", command: "get_commands", success: true, data: { commands: [] } });
  // perl leaves Pi's process group (setsid), writes its PID, then holds the
  // inherited stdout/stderr for 30 s. The group kill cannot reach it. The
  // stub waits for the PID file before exiting, so the group SIGKILL on exit
  // cannot hit perl before setsid.
  const perl = `perl -MPOSIX -e 'setsid; open my $f, ">", $ARGV[0] or exit 1; print $f $$; close $f; sleep 30' "$PIDS/setsid" &`;
  const { project, pids, env } = stubPi(
    [`printf '%s\\n' '${ok}'`, perl, 'while [ ! -s "$PIDS/setsid" ]; do sleep 0.1; done', "exit 0"].join("\n"),
  );
  let setsidPid = null;
  try {
    const r = runCliStub(["--project", project, "--settle-ms", "200", "--timeout-ms", "1000"], env);
    setsidPid = readPid(pids, "setsid", r.out);
    assert.equal(r.status, 1, r.out);
    assert.match(r.out, /timed out/, r.out);
    assert.ok(r.elapsedMs < 10000, `CLI took ${r.elapsedMs} ms:\n${r.out}`);
  } finally {
    // Outside Pi's group by design, so the check does not kill it: we do.
    if (setsidPid === null) {
      try {
        setsidPid = Number(fs.readFileSync(path.join(pids, "setsid"), "utf8").trim()) || null;
      } catch {
        // no PID recorded
      }
    }
    if (setsidPid !== null) {
      try {
        process.kill(setsidPid, "SIGKILL");
      } catch {
        // already gone
      }
    }
  }
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
