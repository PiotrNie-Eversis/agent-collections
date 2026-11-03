#!/usr/bin/env node
/**
 * Pi load check (AC-138).
 *
 * Proves that the Pi coding agent on PATH loads the `.pi/` tree the framework
 * installer writes, and names what it dropped. Steps:
 *   1. Install the framework for Pi into a temp project
 *      (scripts/setup-agent-collections.sh --agents=pi, non-interactive), with a
 *      stub `docker` first on the installer's PATH so the MCP image step is
 *      skipped (no real Docker needed, no image built). Skipped with --project.
 *   2. List the generated prompts (.pi/prompts/eversis-*.md) and skills
 *      (.pi/skills/<dir>/SKILL.md) the installer wrote.
 *   3. Start `pi --mode rpc --approve --no-session` with an isolated HOME and an
 *      env of only PATH, HOME, TERM, NODE_NO_WARNINGS (no provider keys), and a
 *      `docker` that always exits 1 first on PATH, so no real MCP container is
 *      ever started. Send `get_commands`, wait for the response plus a settle
 *      window for MCP `notify` events, then close stdin.
 *   4. Run Pi's own MCP config loader (dist/extensions/mcp/config.js
 *      `loadMcpConfig`) on the project's `.pi/mcp.json`, in a child process with
 *      the same isolated env. A missing loader is a warning, not a failure.
 *   5. Compare a snapshot of the real ~/.pi/agent taken before and after the run
 *      (sessions/ and install/ excluded): any change fails the check.
 *
 * Fails (exit 1) when Pi exits non-zero or times out, writes to stderr, drops a
 * generated prompt or skill, reports an MCP `config:` error, the MCP loader
 * reports errors, or the real ~/.pi/agent changed. All problems are printed
 * before exit. Exit 2: usage error, `pi` not on PATH, installer failure.
 * The report always starts with `Pi <version> (<label>)` and the counts.
 *
 * Note: the home guard can also report changes made by another Pi session that
 * runs on the same machine at the same time.
 *
 * Stdlib only, zero npm dependencies. Pure helpers are exported for
 * scripts/pi-load-check.test.mjs; main() runs only when executed directly.
 *
 * Usage (repo root):
 *   npm run pi:load-check
 *   node scripts/pi-load-check.mjs [--project <dir>] [--label <text>]
 *     [--settle-ms <n>] [--timeout-ms <n>] [--keep]
 */

import { spawn, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const REPO_ROOT = path.resolve(path.dirname(__filename), "..");
const INSTALLER = path.join(REPO_ROOT, "scripts", "setup-agent-collections.sh");
const PI_PACKAGE_NAME = "@earendil-works/pi-coding-agent";
const MCP_LOADER_REL = path.join("dist", "extensions", "mcp", "config.js");
const RPC_REQUEST_ID = "load-check";
const MCP_ATTENTION = "MCP servers need attention";
/** Top-level entries of ~/.pi/agent that the home guard ignores. */
const SNAPSHOT_EXCLUDES = new Set(["sessions", "install"]);
const TAG = "pi-load-check:";

/** Error that ends the run with exit code 2 (usage, environment, installer). */
class SetupError extends Error {}

/**
 * Parse Pi's RPC stdout (JSON lines).
 * commands: the get_commands response's command list, or null when no
 * successful response arrived. notifications: `notify` event messages.
 * nonJson: stdout lines that are not JSON (Pi documents stdout as protocol only).
 */
export function parseRpcOutput(stdout) {
  let commands = null;
  const notifications = [];
  const nonJson = [];
  for (const raw of stdout.split("\n")) {
    const line = raw.trim();
    if (line === "") continue;
    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      nonJson.push(line);
      continue;
    }
    if (msg === null || typeof msg !== "object") {
      nonJson.push(line);
      continue;
    }
    if (msg.type === "response" && msg.command === "get_commands") {
      if (msg.success === true && Array.isArray(msg.data?.commands)) {
        commands = msg.data.commands;
      }
      continue;
    }
    if (msg.type === "extension_ui_request" && msg.method === "notify") {
      notifications.push(String(msg.message ?? ""));
    }
  }
  return { commands, notifications, nonJson };
}

/**
 * List what the installer generated in `projectDir/.pi`:
 * prompts `.pi/prompts/eversis-*.md` and skills `.pi/skills/<dir>/SKILL.md`
 * (name "skill:<dir>"). Paths are real paths, matching Pi's sourceInfo.path.
 */
export function listExpected(projectDir) {
  const root = fs.realpathSync(projectDir);
  const expected = [];
  const promptsDir = path.join(root, ".pi", "prompts");
  if (fs.existsSync(promptsDir)) {
    for (const file of fs.readdirSync(promptsDir).sort()) {
      if (!file.startsWith("eversis-") || !file.endsWith(".md")) continue;
      const full = path.join(promptsDir, file);
      if (!fs.statSync(full).isFile()) continue;
      expected.push({ kind: "prompt", name: file.slice(0, -".md".length), path: full });
    }
  }
  const skillsDir = path.join(root, ".pi", "skills");
  if (fs.existsSync(skillsDir)) {
    for (const dir of fs.readdirSync(skillsDir).sort()) {
      const skillFile = path.join(skillsDir, dir, "SKILL.md");
      if (!fs.existsSync(skillFile)) continue;
      expected.push({ kind: "skill", name: `skill:${dir}`, path: skillFile });
    }
  }
  return expected;
}

/**
 * The only environment the Pi child gets: no provider keys, no caller HOME.
 * Keys are exactly PATH, HOME, TERM, NODE_NO_WARNINGS.
 */
export function buildPiEnv({ path: pathValue, home }) {
  return { PATH: pathValue, HOME: home, TERM: "dumb", NODE_NO_WARNINGS: "1" };
}

function isPiPackageDir(dir) {
  try {
    const pkg = JSON.parse(fs.readFileSync(path.join(dir, "package.json"), "utf8"));
    return pkg.name === PI_PACKAGE_NAME;
  } catch {
    return false;
  }
}

/**
 * Find the installed Pi package folder for the `pi` executable `piBin`:
 * 1. walk up from realpath(piBin) (npm global / local installs);
 * 2. managed install: <bin>/../install/current-version →
 *    <bin>/../install/releases/<v>/node_modules/@earendil-works/pi-coding-agent;
 * 3. `npm root -g`.
 * Returns null when none of them holds the package.
 */
export function findPiPackageDir(piBin) {
  let real;
  try {
    real = fs.realpathSync(piBin);
  } catch {
    return null;
  }
  for (let dir = path.dirname(real); ; dir = path.dirname(dir)) {
    if (isPiPackageDir(dir)) return dir;
    if (path.dirname(dir) === dir) break;
  }
  const installDir = path.join(path.dirname(real), "..", "install");
  try {
    const version = fs.readFileSync(path.join(installDir, "current-version"), "utf8").trim();
    if (version && !version.includes("/") && version !== "." && version !== "..") {
      const dir = path.resolve(installDir, "releases", version, "node_modules", PI_PACKAGE_NAME);
      if (isPiPackageDir(dir)) return dir;
    }
  } catch {
    // not a managed install
  }
  const npmRoot = spawnSync("npm", ["root", "-g"], { encoding: "utf8" });
  if (npmRoot.status === 0) {
    const dir = path.join(npmRoot.stdout.trim(), PI_PACKAGE_NAME);
    if (isPiPackageDir(dir)) return dir;
  }
  return null;
}

/**
 * Snapshot a directory tree: { absent: true } when it does not exist, else
 * { absent: false, entries: { relPath: "<type>:<size>:<mtimeMs>" } }.
 * Top-level sessions/ and install/ are excluded; symlinks are not followed.
 */
export function snapshotDir(dir) {
  let st;
  try {
    st = fs.lstatSync(dir);
  } catch {
    return { absent: true };
  }
  const entries = {};
  const describe = (s) => {
    const type = s.isDirectory() ? "dir" : s.isSymbolicLink() ? "link" : "file";
    return type === "dir" ? "dir" : `${type}:${s.size}:${s.mtimeMs}`;
  };
  if (!st.isDirectory()) {
    entries["."] = describe(st);
    return { absent: false, entries };
  }
  const walk = (abs, rel) => {
    let names;
    try {
      names = fs.readdirSync(abs);
    } catch {
      return;
    }
    for (const name of names) {
      if (rel === "" && SNAPSHOT_EXCLUDES.has(name)) continue;
      const childAbs = path.join(abs, name);
      const childRel = rel === "" ? name : `${rel}/${name}`;
      let s;
      try {
        s = fs.lstatSync(childAbs);
      } catch {
        continue;
      }
      entries[childRel] = describe(s);
      if (s.isDirectory()) walk(childAbs, childRel);
    }
  };
  walk(dir, "");
  return { absent: false, entries };
}

/** Human-readable differences between two snapshotDir() results. */
export function diffSnapshots(before, after) {
  if (before.absent && after.absent) return [];
  if (before.absent) return ["created (the directory did not exist before the run)"];
  if (after.absent) return ["removed (the directory existed before the run)"];
  const changes = [];
  const keys = new Set([...Object.keys(before.entries), ...Object.keys(after.entries)]);
  for (const key of [...keys].sort()) {
    const a = before.entries[key];
    const b = after.entries[key];
    if (a === undefined) changes.push(`added: ${key}`);
    else if (b === undefined) changes.push(`removed: ${key}`);
    else if (a !== b) changes.push(`changed: ${key}`);
  }
  return changes;
}

function firstLines(text, max) {
  const lines = text.trim().split("\n");
  const head = lines.slice(0, max).join("\n");
  return lines.length > max ? `${head}\n… (${lines.length - max} more line(s))` : head;
}

/**
 * Turn one run's raw results into problems (fail), info and warnings.
 * Also returns the stderr text and the prompt / skill counts for the report.
 */
export function evaluate({ exitCode, stderr, timedOut, rpc, expected, mcpLoaderErrors, homeChanged }) {
  const problems = [];
  const info = [];
  const warnings = [];
  const commands = rpc.commands ?? [];

  if (timedOut) {
    problems.push(
      rpc.commands === null
        ? "Pi timed out before answering get_commands"
        : "Pi timed out after answering get_commands (it did not exit in time)",
    );
  } else if (exitCode !== 0) {
    problems.push(`Pi exited with code ${exitCode === null ? "null (killed by a signal)" : exitCode}`);
  }
  if (rpc.commands === null && !timedOut) {
    problems.push("Pi sent no successful get_commands response");
  }
  if (stderr.trim() !== "") {
    problems.push(`Pi wrote to stderr: ${firstLines(stderr, 5)}`);
  }

  const matched = new Set();
  const counts = {
    prompts: { expected: 0, loaded: 0 },
    skills: { expected: 0, loaded: 0 },
  };
  for (const exp of expected) {
    const bucket = exp.kind === "prompt" ? counts.prompts : counts.skills;
    bucket.expected++;
    const hit = commands.find((c) => {
      if (c.source !== exp.kind) return false;
      const p = c.sourceInfo?.path;
      return typeof p === "string" ? p === exp.path : c.name === exp.name;
    });
    if (hit) {
      bucket.loaded++;
      matched.add(hit);
    } else if (rpc.commands !== null) {
      problems.push(`Missing ${exp.kind}: ${exp.name} (${exp.path})`);
    }
  }
  if (rpc.commands !== null) {
    for (const c of commands) {
      if (matched.has(c)) continue;
      const where = c.sourceInfo?.path ? ` (${c.sourceInfo.path})` : "";
      if (c.source === "extension") info.push(`Pi extension command: ${c.name}${where}`);
      else info.push(`Extra ${c.source} command not generated by the installer: ${c.name}${where}`);
    }
  }

  for (const message of rpc.notifications) {
    if (!message.includes(MCP_ATTENTION)) {
      info.push(`Pi notification: ${firstLines(message, 3)}`);
      continue;
    }
    for (const raw of message.split("\n")) {
      const line = raw.trim();
      if (line.startsWith("config:")) {
        problems.push(`MCP config error (Pi notify): ${line.slice("config:".length).trim()}`);
      } else if (/^[^\s:]+: failed:/.test(line)) {
        info.push(`MCP connection (expected; docker is stubbed): ${line}`);
      }
    }
  }

  if (mcpLoaderErrors === null) {
    warnings.push("Pi MCP loader (dist/extensions/mcp/config.js) not available; .pi/mcp.json checked via the Pi notify event only");
  } else {
    for (const err of mcpLoaderErrors) problems.push(`MCP config error (Pi loader): ${err}`);
  }

  for (const change of homeChanged) problems.push(`Real ~/.pi/agent changed during the run: ${change}`);

  if (rpc.nonJson.length > 0) {
    info.push(`Pi wrote ${rpc.nonJson.length} non-JSON stdout line(s): ${firstLines(rpc.nonJson.join("\n"), 3)}`);
  }

  return { problems, info, warnings, counts, stderr };
}

/** Plain-text report; the first line is always `Pi <version> (<label>)`. */
export function formatReport({ piVersion, label }, result) {
  const { prompts, skills } = result.counts;
  const lines = [
    `Pi ${piVersion} (${label})`,
    `  prompts: ${prompts.loaded}/${prompts.expected} loaded`,
    `  skills:  ${skills.loaded}/${skills.expected} loaded`,
  ];
  for (const w of result.warnings) lines.push(`warning: ${w}`);
  for (const i of result.info) lines.push(`info: ${i}`);
  lines.push(result.stderr.trim() === "" ? "Pi stderr: (empty)" : `Pi stderr:\n${result.stderr.trimEnd()}`);
  if (result.problems.length === 0) {
    lines.push(`${TAG} PASS — Pi ${piVersion} loaded every generated prompt and skill`);
  } else {
    lines.push(`${TAG} FAIL — Pi ${piVersion}: ${result.problems.length} problem(s)`);
    for (const p of result.problems) lines.push(`  - ${p}`);
  }
  return lines.join("\n");
}

// --- CLI -------------------------------------------------------------------

function parseArgs(argv) {
  const opts = { project: null, label: "local", settleMs: 5000, timeoutMs: 60000, keep: false };
  const numeric = (name, value) => {
    const n = Number(value);
    if (!Number.isInteger(n) || n < 0) throw new SetupError(`${name} requires a non-negative integer`);
    return n;
  };
  for (let i = 0; i < argv.length; i++) {
    let arg = argv[i];
    let value;
    const eq = arg.indexOf("=");
    if (arg.startsWith("--") && eq !== -1) {
      value = arg.slice(eq + 1);
      arg = arg.slice(0, eq);
    }
    const takeValue = () => {
      if (value !== undefined) return value;
      const next = argv[i + 1];
      if (next === undefined || next.startsWith("--")) throw new SetupError(`${arg} requires a value`);
      i++;
      return next;
    };
    switch (arg) {
      case "--project":
        opts.project = path.resolve(takeValue());
        break;
      case "--label":
        opts.label = takeValue();
        break;
      case "--settle-ms":
        opts.settleMs = numeric(arg, takeValue());
        break;
      case "--timeout-ms":
        opts.timeoutMs = numeric(arg, takeValue());
        break;
      case "--keep":
        opts.keep = true;
        break;
      case "--help":
      case "-h":
        console.log(
          "Usage: node scripts/pi-load-check.mjs [--project <dir>] [--label <text>] [--settle-ms <n>] [--timeout-ms <n>] [--keep]",
        );
        process.exit(0);
        break;
      default:
        throw new SetupError(`unknown argument: ${argv[i]}`);
    }
  }
  return opts;
}

function findOnPath(cmd, pathValue) {
  for (const dir of (pathValue ?? "").split(path.delimiter)) {
    if (!dir) continue;
    const candidate = path.join(dir, cmd);
    try {
      fs.accessSync(candidate, fs.constants.X_OK);
      if (fs.statSync(candidate).isFile()) return candidate;
    } catch {
      // keep looking
    }
  }
  return null;
}

function writeExecutable(file, content) {
  fs.writeFileSync(file, content);
  fs.chmodSync(file, 0o755);
}

/** Installer-only stub: answers `compose … config --images` and `image inspect`. */
const INSTALL_DOCKER_STUB = `#!/bin/sh
# AC-138 pi-load-check: stub docker for the installer only (no real image is built).
case "$*" in
  *"config --images"*) echo "eversis-collections:stub" ;;
esac
exit 0
`;

/** Pi-time stub: every docker call fails, so no MCP container is ever started. */
const PI_DOCKER_STUB = `#!/bin/sh
# AC-138 pi-load-check: docker always fails while Pi runs (no MCP containers).
echo "docker disabled by pi-load-check" >&2
exit 1
`;

function runInstaller(projectDir, installBin, logFile) {
  fs.mkdirSync(projectDir, { recursive: true });
  const git = spawnSync("git", ["init", "-q"], { cwd: projectDir, encoding: "utf8" });
  if (git.status !== 0) throw new SetupError(`git init failed in ${projectDir}: ${git.stderr}`);
  const env = { ...process.env, PATH: `${installBin}${path.delimiter}${process.env.PATH ?? ""}` };
  delete env.AGENT_COLLECTIONS_HOME;
  const result = spawnSync(
    "bash",
    [
      INSTALLER,
      "--collections-home",
      REPO_ROOT,
      "--target",
      projectDir,
      "--non-interactive",
      "--vendor=copy",
      "--agents=pi",
      "--mcp-servers=eversis-collections",
      "--profile=frontend",
      "--link-mode=copy",
    ],
    { cwd: REPO_ROOT, env, encoding: "utf8", maxBuffer: 64 * 1024 * 1024 },
  );
  const log = `${result.stdout ?? ""}${result.stderr ?? ""}`;
  fs.writeFileSync(logFile, log);
  if (result.status !== 0) {
    const tail = log.trimEnd().split("\n").slice(-30).join("\n");
    throw new SetupError(
      `installer failed (exit ${result.status ?? result.signal}); last lines of ${logFile}:\n${tail}`,
    );
  }
}

function piVersionOf(piBin, env, cwd) {
  const r = spawnSync(piBin, ["--version"], { env, cwd, encoding: "utf8", timeout: 30000 });
  const out = `${r.stdout ?? ""}`.trim() || `${r.stderr ?? ""}`.trim();
  return r.status === 0 && out ? out.split("\n")[0].trim() : "unknown";
}

function killGroup(child, signal) {
  try {
    process.kill(-child.pid, signal);
  } catch {
    // group already gone
  }
}

/** Run Pi in RPC mode, ask for get_commands, settle, close stdin. */
function runPiRpc({ piBin, cwd, env, settleMs, timeoutMs }) {
  return new Promise((resolve) => {
    const child = spawn(piBin, ["--mode", "rpc", "--approve", "--no-session"], {
      cwd,
      env,
      detached: true,
      stdio: ["pipe", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    let timedOut = false;
    let settleTimer = null;
    let killTimer = null;
    let responded = false;

    const closeStdin = () => {
      if (!child.stdin.destroyed) child.stdin.end();
    };
    const overall = setTimeout(() => {
      timedOut = true;
      killGroup(child, "SIGTERM");
      killTimer = setTimeout(() => killGroup(child, "SIGKILL"), 3000);
    }, timeoutMs);

    child.stdin.on("error", () => {
      // Pi may exit before reading stdin (e.g. an extension failed to load).
    });
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
      if (!responded && parseRpcOutput(stdout).commands !== null) {
        responded = true;
        settleTimer = setTimeout(closeStdin, settleMs);
      } else if (!responded && /"type"\s*:\s*"response"/.test(chunk)) {
        // A failed response still ends the wait.
        responded = true;
        settleTimer = setTimeout(closeStdin, settleMs);
      }
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", (err) => {
      stderr += `${err.message}\n`;
    });
    child.on("close", (code) => {
      clearTimeout(overall);
      clearTimeout(settleTimer);
      clearTimeout(killTimer);
      resolve({ exitCode: code, stdout, stderr, timedOut });
    });

    child.stdin.write(`${JSON.stringify({ type: "get_commands", id: RPC_REQUEST_ID })}\n`);
  });
}

/**
 * Run Pi's loadMcpConfig in a child node with the isolated env.
 * Returns { errors: string[] | null, warning?: string }.
 */
function runMcpLoader(packageDir, projectDir, agentDir, env) {
  if (packageDir === null) return { errors: null };
  const loader = path.join(packageDir, MCP_LOADER_REL);
  if (!fs.existsSync(loader)) return { errors: null };
  const code = [
    "const { loadMcpConfig } = await import(process.argv[1]);",
    "const r = loadMcpConfig({ cwd: process.argv[2], agentDir: process.argv[3], projectTrusted: true });",
    "const errs = (r.errors ?? []).map((e) => (typeof e === 'string' ? e : e?.message ?? JSON.stringify(e)));",
    "process.stdout.write(JSON.stringify(errs));",
  ].join("\n");
  const r = spawnSync(
    process.execPath,
    ["--input-type=module", "-e", code, pathToFileURL(loader).href, projectDir, agentDir],
    { cwd: projectDir, env, encoding: "utf8", timeout: 30000 },
  );
  if (r.status !== 0) {
    return { errors: null, warning: `Pi MCP loader failed to run: ${firstLines(`${r.stderr ?? ""}`, 3)}` };
  }
  try {
    return { errors: JSON.parse(r.stdout) };
  } catch {
    return { errors: null, warning: `Pi MCP loader returned unreadable output: ${firstLines(r.stdout, 3)}` };
  }
}

async function main() {
  let opts;
  let piVersion = "unknown";
  let label = "local";
  let tmp = null;
  let keep = false;
  try {
    opts = parseArgs(process.argv.slice(2));
    label = opts.label;
    keep = opts.keep;
    if (opts.project !== null && !fs.existsSync(path.join(opts.project, ".pi"))) {
      throw new SetupError(`--project ${opts.project} has no .pi/ directory`);
    }
    const piBin = findOnPath("pi", process.env.PATH);
    if (piBin === null) throw new SetupError("`pi` not found on PATH");

    const realAgentDir = path.join(os.userInfo().homedir, ".pi", "agent");
    const before = snapshotDir(realAgentDir);

    tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pi-load-check-"));
    const home = path.join(tmp, "home");
    const agentDir = path.join(tmp, "agent");
    const installBin = path.join(tmp, "install-bin");
    const piBinDir = path.join(tmp, "pi-bin");
    for (const d of [home, agentDir, installBin, piBinDir]) fs.mkdirSync(d, { recursive: true });
    writeExecutable(path.join(installBin, "docker"), INSTALL_DOCKER_STUB);
    writeExecutable(path.join(piBinDir, "docker"), PI_DOCKER_STUB);

    const piEnv = buildPiEnv({ path: `${piBinDir}${path.delimiter}${process.env.PATH ?? ""}`, home });
    piVersion = piVersionOf(piBin, piEnv, home);

    let project = opts.project;
    if (project === null) {
      project = path.join(tmp, "project");
      runInstaller(project, installBin, path.join(tmp, "install.log"));
    }
    const projectReal = fs.realpathSync(project);
    const expected = listExpected(projectReal);

    const run = await runPiRpc({
      piBin,
      cwd: projectReal,
      env: piEnv,
      settleMs: opts.settleMs,
      timeoutMs: opts.timeoutMs,
    });
    const rpc = parseRpcOutput(run.stdout);
    if (rpc.commands !== null) {
      // Compare real paths (e.g. macOS /var → /private/var).
      rpc.commands = rpc.commands.map((c) => {
        const p = c.sourceInfo?.path;
        if (typeof p !== "string" || !fs.existsSync(p)) return c;
        return { ...c, sourceInfo: { ...c.sourceInfo, path: fs.realpathSync(p) } };
      });
    }

    const loader = runMcpLoader(findPiPackageDir(piBin), projectReal, agentDir, piEnv);

    const after = snapshotDir(realAgentDir);
    const result = evaluate({
      exitCode: run.exitCode,
      stderr: run.stderr,
      timedOut: run.timedOut,
      rpc,
      expected,
      mcpLoaderErrors: loader.errors,
      homeChanged: diffSnapshots(before, after),
    });
    if (loader.warning) result.warnings.push(loader.warning);
    console.log(formatReport({ piVersion, label }, result));
    process.exitCode = result.problems.length === 0 ? 0 : 1;
  } catch (err) {
    if (err instanceof SetupError) {
      console.error(`${TAG} Pi ${piVersion} (${label}): ${err.message}`);
      process.exitCode = 2;
    } else {
      console.error(`${TAG} Pi ${piVersion} (${label}): unexpected error: ${err?.stack ?? err}`);
      process.exitCode = 2;
    }
  } finally {
    if (tmp !== null) {
      if (keep) console.log(`${TAG} kept temp dir ${tmp}`);
      else fs.rmSync(tmp, { recursive: true, force: true });
    }
  }
}

if (process.argv[1] && fs.realpathSync(process.argv[1]) === fs.realpathSync(__filename)) {
  await main();
}
