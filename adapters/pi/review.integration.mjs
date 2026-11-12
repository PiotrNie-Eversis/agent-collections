/**
 * Integration test for .pi/extensions/eversis-review.ts on real Pi (AC-136).
 *
 * Runs `pi --mode rpc --approve` in temp projects against a local stub model and
 * reads what Pi really sent to it. The parent's user message carries a unique
 * marker; the stub answers it with a call to eversis_independent_review, so the
 * tool starts the separate review session (child) inside real Pi. Asserts:
 * - the child's request has none of the parent's messages (no marker), no
 *   `edit` / `write` tools, no review tool (no recursion), and the
 *   `<eversis_process_rules>` section;
 * - the parent gets the tool result with the independent label and a usage line;
 * - the temp HOME's .pi/agent/ ends with the same files and hashes as a
 *   parent-only baseline run (the child adds no user-global writes);
 * - when the stub refuses the child, the parent gets the failure text with the
 *   fresh-session steps and without the independent label.
 *
 * The stub refuses the child with HTTP 400, not 500: Pi 1.5.0 retries 5xx
 * answers (pi-ai RETRYABLE_PROVIDER_ERROR_PATTERN; settings retry default 3
 * tries from 2 s), which only slows the test down; a 400 fails at once.
 *
 * The stub model is configured in the temp HOME's .pi/agent/models.json (custom
 * provider, openai-completions, literal fake key), not by an extension, so the
 * parent and the child see the same model, as with a real configured provider.
 *
 * The name stays outside the *.test.mjs glob, so unit runs never start Pi.
 * Skips with a message when `pi` is not on PATH.
 *
 * Isolation follows scripts/pi-load-check.mjs: a temp HOME, an env of only PATH,
 * HOME, TERM, NODE_NO_WARNINGS, no provider keys, a `docker` that always fails,
 * and Pi in its own process group. No real model is called.
 *
 * Stdlib only. Run: node --test adapters/pi/review.integration.mjs
 */

import assert from "node:assert/strict";
import { spawn, spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import { after, before, describe, test } from "node:test";
import { fileURLToPath } from "node:url";

import { buildPiEnv } from "../../scripts/pi-load-check.mjs";

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const GENERATOR = path.join(REPO_ROOT, "adapters", "pi", "generate.mjs");
const SKILLS_SOURCE = path.join(REPO_ROOT, ".ai", "skills");

const PROVIDER = "ac136-stub";
const MODEL = "stub-model";
const TOOL_NAME = "eversis_independent_review";
const MARKER = "AC136-PARENT-MARKER-5d1e";
const PARENT_MESSAGE = `${MARKER} please run the independent review for AC-1`;
/** Text only the child's prompt carries (the tool's fixed review instruction). */
const CHILD_PROBE = `separate Pi session started by the ${TOOL_NAME} tool`;
const CHILD_ANSWER = "PASS\n\nStub review: no findings.";
const INDEPENDENT_LABEL = "Review context: separate Pi session (independent)";
const USAGE_RE = /Review usage: (\d+) in \/ (\d+) out tokens, \d+ tool calls \(separate session\)/;
const PROCESS_RULES_OPEN = "<eversis_process_rules>";
const STUB_USAGE = { prompt_tokens: 321, completion_tokens: 12, total_tokens: 333 };

const STEP_TIMEOUT_MS = 90_000;
const TEST_TIMEOUT_MS = 180_000;
const KILL_AFTER_MS = 10_000;

/** Every docker call fails while Pi runs, as in scripts/pi-load-check.mjs. */
const PI_DOCKER_STUB = `#!/bin/sh
echo "docker disabled by review.integration" >&2
exit 1
`;

function findPi() {
  const r = spawnSync("sh", ["-c", "command -v pi"], { encoding: "utf8" });
  return r.status === 0 ? r.stdout.trim() || null : null;
}

function killGroup(child, signal) {
  try {
    process.kill(-child.pid, signal);
  } catch {
    // group already gone
  }
}

function textOf(message) {
  if (typeof message?.content === "string") return message.content;
  if (!Array.isArray(message?.content)) return "";
  return message.content.map((part) => part?.text ?? "").join("");
}

/** models.json for the temp HOME: one custom provider at the stub URL. */
function modelsJson(url) {
  return `${JSON.stringify(
    {
      providers: {
        [PROVIDER]: {
          baseUrl: url,
          api: "openai-completions",
          apiKey: "not-a-real-key",
          models: [
            {
              id: MODEL,
              name: "stub",
              reasoning: false,
              input: ["text"],
              cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
              contextWindow: 200000,
              maxTokens: 1000,
            },
          ],
        },
      },
    },
    null,
    2,
  )}\n`;
}

/**
 * One stub OpenAI-style model on 127.0.0.1 for all runs, so every temp HOME has
 * the same models.json. Records each request with its role: "child" when a
 * user message carries the tool's review instruction, else "parent".
 * stub.refuseChild = true answers child requests with HTTP 400.
 */
async function startStub() {
  const stub = { requests: [], refuseChild: false, url: "", close: () => {} };
  const server = http.createServer((req, res) => {
    let raw = "";
    req.on("data", (chunk) => {
      raw += chunk;
    });
    req.on("end", () => {
      const body = JSON.parse(raw || "{}");
      const messages = body.messages ?? [];
      const system = messages.find((m) => m.role === "system" || m.role === "developer");
      const userTexts = messages.filter((m) => m.role === "user").map(textOf);
      const last = messages.at(-1);
      const isChild = userTexts.some((t) => t.includes(CHILD_PROBE));
      stub.requests.push({
        role: isChild ? "child" : "parent",
        all: messages.map((m) => `${m.role}: ${textOf(m)}`).join("\n"),
        system: textOf(system),
        tools: (body.tools ?? []).map((t) => t.function?.name ?? t.name),
        lastRole: last?.role,
        lastText: textOf(last),
      });

      if (isChild && stub.refuseChild) {
        res.writeHead(400, { "content-type": "application/json" });
        res.end(JSON.stringify({ error: { message: "stub refuses the review session", type: "invalid_request_error" } }));
        return;
      }
      res.writeHead(200, { "content-type": "text/event-stream" });
      const send = (choice) =>
        res.write(`data: ${JSON.stringify({ id: "1", object: "chat.completion.chunk", choices: [choice] })}\n\n`);
      if (!isChild && last?.role === "user" && textOf(last).includes(MARKER)) {
        const fn = { name: TOOL_NAME, arguments: JSON.stringify({ key: "AC-1" }) };
        send({ index: 0, delta: { role: "assistant", tool_calls: [{ index: 0, id: "call-1", type: "function", function: fn }] }, finish_reason: null });
        send({ index: 0, delta: {}, finish_reason: "tool_calls" });
      } else {
        send({ index: 0, delta: { role: "assistant", content: isChild ? CHILD_ANSWER : "ok" }, finish_reason: null });
        send({ index: 0, delta: {}, finish_reason: "stop" });
      }
      res.write(`data: ${JSON.stringify({ id: "1", object: "chat.completion.chunk", choices: [], usage: STUB_USAGE })}\n\n`);
      res.end("data: [DONE]\n\n");
    });
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  stub.url = `http://127.0.0.1:${server.address().port}/v1`;
  stub.close = () =>
    new Promise((resolve) => {
      server.closeAllConnections();
      server.close(resolve);
    });
  return stub;
}

/** RPC agent_end count and prompt failures in Pi's stdout so far. */
function readRpc(stdout) {
  let agentEnds = 0;
  let promptError = null;
  for (const line of stdout.split("\n")) {
    if (line.trim() === "") continue;
    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      continue;
    }
    if (msg?.type === "agent_end") agentEnds++;
    if (msg?.type === "response" && msg.command === "prompt" && msg.success === false) {
      promptError = String(msg.error);
    }
  }
  return { agentEnds, promptError };
}

/** One Pi process, one RPC prompt; resolves after its agent_end and exit. */
function runPi({ pi, project, env, message }) {
  return new Promise((resolve, reject) => {
    const child = spawn(pi, ["--mode", "rpc", "--approve", "--no-session", "--provider", PROVIDER, "--model", MODEL], {
      cwd: project,
      env,
      detached: true,
      stdio: ["pipe", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    let failure = null;
    let done = false;
    let killTimer = null;

    const finish = () => {
      clearTimeout(stepTimer);
      if (!child.stdin.destroyed) child.stdin.end();
      killTimer ??= setTimeout(() => killGroup(child, "SIGKILL"), KILL_AFTER_MS);
    };
    const fail = (text) => {
      failure ??= new Error(`${text}\nPi stderr: ${stderr}\nPi stdout tail: ${stdout.slice(-2000)}`);
      finish();
    };
    const stepTimer = setTimeout(() => fail(`no agent_end for: ${message}`), STEP_TIMEOUT_MS);

    child.stdin.on("error", () => {
      // Pi may exit before reading stdin; the checks below report it.
    });
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
      const { agentEnds, promptError } = readRpc(stdout);
      if (promptError) fail(`prompt rejected: ${promptError}`);
      else if (agentEnds >= 1 && !done) {
        done = true;
        finish();
      }
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", (err) => fail(err.message));
    child.on("exit", () => {
      clearTimeout(stepTimer);
      killGroup(child, "SIGKILL");
    });
    child.on("close", (code) => {
      clearTimeout(killTimer);
      if (failure) reject(failure);
      else if (!done) reject(new Error(`Pi exited early (${code}).\nPi stderr: ${stderr}`));
      else resolve({ exitCode: code, stderr });
    });

    child.stdin.write(`${JSON.stringify({ type: "prompt", message })}\n`);
  });
}

/** Relative path -> sha1 of every file under dir (empty when dir is missing). */
function snapshot(dir) {
  const out = {};
  const walk = (current) => {
    if (!fs.existsSync(current)) return;
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const abs = path.join(current, entry.name);
      if (entry.isDirectory()) walk(abs);
      else out[path.relative(dir, abs)] = crypto.createHash("sha1").update(fs.readFileSync(abs)).digest("hex");
    }
  };
  walk(dir);
  return out;
}

const describeOptions = {};
const piBin = findPi();
if (!piBin) {
  describeOptions.skip = "pi is not on PATH: review integration test skipped";
  console.log(`review.integration: ${describeOptions.skip}`);
}

describe("independent review on real Pi (stub model)", describeOptions, () => {
  let tmp;
  let template;
  let piBinDir;
  let stub;
  let runs = 0;

  before(async () => {
    tmp = fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), "pi-review-"));
    piBinDir = path.join(tmp, "pi-bin");
    fs.mkdirSync(piBinDir, { recursive: true });
    fs.writeFileSync(path.join(piBinDir, "docker"), PI_DOCKER_STUB, { mode: 0o755 });

    template = path.join(tmp, "template");
    fs.mkdirSync(template);
    const generated = spawnSync(process.execPath, [GENERATOR, "--out", template], { encoding: "utf8" });
    assert.equal(generated.status, 0, generated.stderr);
    assert.ok(fs.existsSync(path.join(template, ".pi", "extensions", "eversis-review.ts")), "review extension generated");
    for (const dir of fs.readdirSync(SKILLS_SOURCE)) {
      if (!dir.startsWith("eversis-")) continue;
      fs.cpSync(path.join(SKILLS_SOURCE, dir), path.join(template, ".pi", "skills", dir), { recursive: true, dereference: true });
    }
    stub = await startStub();
  });

  after(async () => {
    await stub?.close();
    if (tmp) fs.rmSync(tmp, { recursive: true, force: true });
  });

  /** A new project and HOME; HOME/.pi/agent holds only models.json. */
  async function run(message) {
    const n = ++runs;
    const home = path.join(tmp, `home-${n}`);
    const agentDir = path.join(home, ".pi", "agent");
    fs.mkdirSync(agentDir, { recursive: true });
    fs.writeFileSync(path.join(agentDir, "models.json"), modelsJson(stub.url));
    const project = path.join(tmp, `project-${n}`);
    fs.cpSync(template, project, { recursive: true });
    const env = buildPiEnv({ path: `${piBinDir}${path.delimiter}${process.env.PATH ?? ""}`, home });

    const first = stub.requests.length;
    const result = await runPi({ pi: piBin, project, env, message });
    assert.equal(result.exitCode, 0, `Pi exit code; stderr: ${result.stderr}`);
    assert.equal(result.stderr, "");
    return { requests: stub.requests.slice(first), agentFiles: snapshot(agentDir) };
  }

  /** The parent's request that carries the review tool's result. */
  function toolResultRequest(requests) {
    const parents = requests.filter((r) => r.role === "parent");
    const withResult = parents.find((r) => r.lastRole === "tool");
    assert.ok(withResult, `a parent request carries the tool result; roles: ${requests.map((r) => r.role).join(",")}`);
    return withResult;
  }

  test("PASS: child is clean and edit-restricted; parent gets the label and usage; no extra HOME writes", { timeout: TEST_TIMEOUT_MS }, async (t) => {
    stub.refuseChild = false;
    const baseline = await run("hello plain");
    assert.ok(baseline.requests.every((r) => r.role === "parent"), "baseline starts no child");
    assert.ok(Object.keys(baseline.agentFiles).length > 0);

    const review = await run(PARENT_MESSAGE);
    const children = review.requests.filter((r) => r.role === "child");
    assert.equal(children.length, 1, "exactly one child request (the stub answers without tool calls)");
    const [child] = children;
    t.diagnostic(`child tools: ${child.tools.join(", ")}`);
    assert.ok(!child.all.includes(MARKER), "the child never sees the parent's message");
    assert.ok(!child.system.includes(MARKER));
    assert.ok(!child.tools.includes("edit") && !child.tools.includes("write"), "no edit / write tools");
    assert.ok(!child.tools.includes(TOOL_NAME), "no review tool in the child (no recursion)");
    assert.ok(child.tools.includes("bash") && child.tools.includes("read"), "read and bash stay");
    assert.ok(child.system.includes(PROCESS_RULES_OPEN), "process rules reach the child");

    const parentTools = review.requests.find((r) => r.role === "parent").tools;
    assert.ok(parentTools.includes(TOOL_NAME), "the parent has the review tool");

    const result = toolResultRequest(review.requests).lastText;
    t.diagnostic(`tool result: ${result.replace(/\n/g, " | ")}`);
    assert.ok(result.startsWith(INDEPENDENT_LABEL), "result starts with the independent label");
    assert.ok(result.includes(CHILD_ANSWER), "the child's review text comes back");
    const usage = USAGE_RE.exec(result);
    assert.ok(usage, "usage line");
    assert.ok(Number(usage[1]) > 0 && Number(usage[2]) > 0, "token counts from the child");

    t.diagnostic(`HOME/.pi/agent files: ${Object.keys(review.agentFiles).sort().join(", ")}`);
    assert.deepEqual(review.agentFiles, baseline.agentFiles, "same HOME/.pi/agent files and hashes as the parent-only run");
  });

  test("child refused by the model: failure text, fresh-session steps, never the independent label", { timeout: TEST_TIMEOUT_MS }, async (t) => {
    stub.refuseChild = true;
    try {
      const { requests } = await run(PARENT_MESSAGE);
      assert.ok(requests.some((r) => r.role === "child"), "the child was started and refused");
      const result = toolResultRequest(requests).lastText;
      t.diagnostic(`tool result: ${result.replace(/\n/g, " | ")}`);
      assert.ok(!result.includes(INDEPENDENT_LABEL), "no independent label on failure");
      assert.match(result, /Independent review did not run: /);
      assert.ok(result.includes("stub refuses the review session"), "names the reason");
      assert.ok(result.includes("Start a new Pi session in the project root."));
      assert.ok(result.includes("`/eversis-review AC-1`"));
      assert.ok(result.includes("Review context: same session as implementation (not independent)"));
    } finally {
      stub.refuseChild = false;
    }
  });
});
