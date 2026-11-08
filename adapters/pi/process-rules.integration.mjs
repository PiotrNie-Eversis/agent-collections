/**
 * Integration test for .pi/extensions/eversis-process-rules.ts on real Pi (AC-134).
 *
 * Runs `pi --mode rpc --approve` in temp projects and reads what Pi really sent
 * to a local stub model. event.systemPrompt keeps the pre-mutation length, so
 * only the recorded request proves what reached the model. Guards against the
 * main risk of the design: a Pi update that drops the section without an error.
 *
 * The name stays outside the *.test.mjs glob, so unit runs never start Pi.
 * Skips with a message when `pi` is not on PATH.
 *
 * Isolation follows scripts/pi-load-check.mjs: a temp HOME, an env of only PATH,
 * HOME, TERM, NODE_NO_WARNINGS plus the stub URL, no provider keys, a `docker`
 * that always fails, and Pi in its own process group. The only model is a fake
 * provider that a test extension registers, pointing at a server on 127.0.0.1.
 * No real model is called.
 *
 * Stdlib only. Run: node --test adapters/pi/process-rules.integration.mjs
 */

import assert from "node:assert/strict";
import { spawn, spawnSync } from "node:child_process";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import { after, before, describe, test } from "node:test";
import { fileURLToPath } from "node:url";

import { buildPiEnv, parseRpcOutput } from "../../scripts/pi-load-check.mjs";

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const GENERATOR = path.join(REPO_ROOT, "adapters", "pi", "generate.mjs");
const SKILLS_SOURCE = path.join(REPO_ROOT, ".ai", "skills");

/** System prompt size of a full install before AC-134 (research, Pi 1.5.0). */
const BASELINE_CHARS = 45_996;
const SECTION_OPEN = "<eversis_process_rules>";
const SECTION_CLOSE = "</eversis_process_rules>";
const NAMING_LINE = "Rule id naming:";
const CORE_HEADING = "## Hard limits (implement)";
const CONSUMER_SKILL = "acme-consumer-skill";
const BUNDLE = [
  "eversis-rule-agent-core",
  "eversis-rule-testing-and-terminal",
  "eversis-rule-accessibility",
  "eversis-rule-engineering-manager",
  "eversis-rule-spec-driven-development",
];
const PLAN_REL = "docs/specs/ac-1-demo/ac-1-demo.plan.md";
const POINTER_REL = ".pi/eversis-state/active-plan.json";
const OPEN_BOX = "- [ ] first task";
const DONE_BOX = "- [x] first task";

const PROVIDER = "ac134-stub";
const MODEL = "stub-model";
const STUB_URL_ENV = "AC134_STUB_URL";
const STEP_TIMEOUT_MS = 60_000;
const TEST_TIMEOUT_MS = 180_000;
const KILL_AFTER_MS = 10_000;

/** Registers the fake provider and logs what `input` handlers see. */
const STUB_EXTENSION = `import fs from "node:fs";
export default function (pi: any) {
  pi.registerProvider(${JSON.stringify(PROVIDER)}, {
    baseUrl: process.env.${STUB_URL_ENV},
    apiKey: "not-a-real-key",
    api: "openai-completions",
    models: [{ id: ${JSON.stringify(MODEL)}, name: "stub", reasoning: false, input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: 200000, maxTokens: 1000 }],
  });
  pi.on("input", (event: any, ctx: any) => {
    const line = JSON.stringify({ text: event.text, idle: ctx.isIdle(), streamingBehavior: event.streamingBehavior ?? null });
    fs.appendFileSync(new URL("../zz-input.jsonl", import.meta.url), line + "\\n");
    return { action: "continue" };
  });
}
`;

const CONSUMER_SKILL_MD = `---
name: ${CONSUMER_SKILL}
description: "A consumer skill the framework does not own. It must stay listed."
---
# Consumer skill
`;

/** Every docker call fails while Pi runs, as in scripts/pi-load-check.mjs. */
const PI_DOCKER_STUB = `#!/bin/sh
echo "docker disabled by process-rules.integration" >&2
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

/**
 * A stub OpenAI-style model on 127.0.0.1 that records each request. A user
 * message containing a key of toolCalls gets that tool call as the reply; any
 * other request gets "ok". The call runs in real Pi, then the tool result
 * comes back here and gets "ok".
 */
async function startStub(toolCalls = {}) {
  const stub = { requests: [], step: null, url: "", close: () => {} };
  const server = http.createServer((req, res) => {
    let raw = "";
    req.on("data", (chunk) => {
      raw += chunk;
    });
    req.on("end", () => {
      const body = JSON.parse(raw || "{}");
      const messages = body.messages ?? [];
      const system = messages.find((m) => m.role === "system" || m.role === "developer");
      const last = messages.at(-1);
      const user = [...messages].reverse().find((m) => m.role === "user");
      stub.requests.push({
        step: stub.step,
        bodyChars: raw.length,
        system: textOf(system),
        user: textOf(user),
        lastRole: last?.role,
      });

      res.writeHead(200, { "content-type": "text/event-stream" });
      const send = (choice) =>
        res.write(`data: ${JSON.stringify({ id: "1", object: "chat.completion.chunk", choices: [choice] })}\n\n`);
      const key = last?.role === "user" ? Object.keys(toolCalls).find((k) => textOf(last).includes(k)) : undefined;
      if (key) {
        const { name, args } = toolCalls[key];
        const fn = { name, arguments: JSON.stringify(args) };
        send({ index: 0, delta: { role: "assistant", tool_calls: [{ index: 0, id: "call-1", type: "function", function: fn }] }, finish_reason: null });
        send({ index: 0, delta: {}, finish_reason: "tool_calls" });
      } else {
        send({ index: 0, delta: { role: "assistant", content: "ok" }, finish_reason: null });
        send({ index: 0, delta: {}, finish_reason: "stop" });
      }
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

/** RPC events and prompt failures in Pi's stdout so far. */
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

/**
 * One Pi process: sends each message as an RPC prompt, waits for its agent_end,
 * then closes stdin. Each process is a new session, so a pointer is the only
 * way the rules can be active at its start.
 */
function runPi({ pi, project, env, stub, messages }) {
  return new Promise((resolve, reject) => {
    const child = spawn(pi, ["--mode", "rpc", "--approve", "--no-session", "--provider", PROVIDER, "--model", MODEL], {
      cwd: project,
      env: { ...env, [STUB_URL_ENV]: stub.url },
      detached: true,
      stdio: ["pipe", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    let sent = 0;
    let failure = null;
    let stepTimer = null;
    let killTimer = null;

    const finish = () => {
      clearTimeout(stepTimer);
      if (!child.stdin.destroyed) child.stdin.end();
      killTimer ??= setTimeout(() => killGroup(child, "SIGKILL"), KILL_AFTER_MS);
    };
    const fail = (message) => {
      failure ??= new Error(`${message}\nPi stderr: ${stderr}\nPi stdout tail: ${stdout.slice(-2000)}`);
      finish();
    };
    const sendNext = () => {
      clearTimeout(stepTimer);
      if (sent >= messages.length) return finish();
      stub.step = sent;
      const message = messages[sent];
      sent++;
      stepTimer = setTimeout(() => fail(`no agent_end for: ${message}`), STEP_TIMEOUT_MS);
      child.stdin.write(`${JSON.stringify({ type: "prompt", message })}\n`);
    };

    child.stdin.on("error", () => {
      // Pi may exit before reading stdin; the checks below report it.
    });
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
      const { agentEnds, promptError } = readRpc(stdout);
      if (promptError) fail(`prompt rejected: ${promptError}`);
      else if (agentEnds >= sent && !failure) sendNext();
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
      else if (sent < messages.length) reject(new Error(`Pi exited early (${code}).\nPi stderr: ${stderr}`));
      else resolve({ exitCode: code, stderr, notifications: parseRpcOutput(stdout).notifications });
    });

    sendNext();
  });
}

/** Skill names in the listing of a recorded system prompt. */
function listedSkills(system) {
  const listing = /<available_skills>[\s\S]*<\/available_skills>/.exec(system)?.[0] ?? "";
  return [...listing.matchAll(/<name>([^<]+)<\/name>/g)].map((m) => m[1]);
}

const describeOptions = {};
const piBin = findPi();
if (!piBin) {
  describeOptions.skip = "pi is not on PATH: process rules integration test skipped";
  console.log(`process-rules.integration: ${describeOptions.skip}`);
}

describe("process rules on real Pi", describeOptions, () => {
  let tmp;
  let template;
  let env;
  let projects = 0;

  before(() => {
    tmp = fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), "pi-process-rules-"));
    const home = path.join(tmp, "home");
    const piBinDir = path.join(tmp, "pi-bin");
    for (const dir of [home, piBinDir]) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(piBinDir, "docker"), PI_DOCKER_STUB, { mode: 0o755 });
    env = buildPiEnv({ path: `${piBinDir}${path.delimiter}${process.env.PATH ?? ""}`, home });

    template = path.join(tmp, "template");
    fs.mkdirSync(template);
    const generated = spawnSync(process.execPath, [GENERATOR, "--out", template], { encoding: "utf8" });
    assert.equal(generated.status, 0, generated.stderr);
    for (const dir of fs.readdirSync(SKILLS_SOURCE)) {
      if (!dir.startsWith("eversis-")) continue;
      fs.cpSync(path.join(SKILLS_SOURCE, dir), path.join(template, ".pi", "skills", dir), { recursive: true, dereference: true });
    }
    const consumer = path.join(template, ".pi", "skills", CONSUMER_SKILL);
    fs.mkdirSync(consumer);
    fs.writeFileSync(path.join(consumer, "SKILL.md"), CONSUMER_SKILL_MD);
    fs.writeFileSync(path.join(template, ".pi", "extensions", "zz-stub-provider.ts"), STUB_EXTENSION);
  });

  after(() => {
    if (tmp) fs.rmSync(tmp, { recursive: true, force: true });
  });

  function newProject(planText) {
    const project = path.join(tmp, `project-${++projects}`);
    fs.cpSync(template, project, { recursive: true });
    if (planText !== undefined) {
      const plan = path.join(project, PLAN_REL);
      fs.mkdirSync(path.dirname(plan), { recursive: true });
      fs.writeFileSync(plan, planText);
    }
    return project;
  }

  async function run(project, messages, toolCalls) {
    const stub = await startStub(toolCalls);
    try {
      const result = await runPi({ pi: piBin, project, env, stub, messages });
      assert.equal(result.exitCode, 0, `Pi exit code; stderr: ${result.stderr}`);
      assert.equal(result.stderr, "");
      return { ...result, requests: stub.requests };
    } finally {
      await stub.close();
    }
  }

  function assertPlain(request) {
    assert.ok(request.system.includes(CORE_HEADING), "the always-on core reaches the request");
    assert.ok(!request.system.includes(SECTION_OPEN), "no process rules section");
    assert.ok(!request.system.includes(NAMING_LINE), "no process rules text");
    const listed = listedSkills(request.system);
    assert.deepEqual(listed.filter((name) => name.startsWith("eversis-")), [], "no eversis-* listing");
    assert.ok(listed.includes(CONSUMER_SKILL), "the consumer skill stays listed");
  }

  function assertActive(project, request) {
    const open = request.system.indexOf(SECTION_OPEN);
    const close = request.system.indexOf(SECTION_CLOSE);
    assert.ok(open !== -1 && close > open, `the section ${SECTION_OPEN} reaches the request`);
    const section = request.system.slice(open, close);
    assert.ok(section.includes(NAMING_LINE), "the section has the naming line");
    for (const id of BUNDLE) {
      const skill = fs.readFileSync(path.join(project, ".pi", "skills", id, "SKILL.md"), "utf8");
      const heading = /^# .+$/m.exec(skill)?.[0];
      assert.ok(heading, `${id} has a heading`);
      assert.ok(section.includes(heading), `the section carries ${id}`);
    }
    const listed = listedSkills(request.system);
    for (const name of [CONSUMER_SKILL, "eversis-code-reviewing", ...BUNDLE]) {
      assert.ok(listed.includes(name), `the full listing has ${name}`);
    }
  }

  test("plain session, then a command, then a later message", { timeout: TEST_TIMEOUT_MS }, async (t) => {
    const project = newProject();
    const { requests, notifications } = await run(project, ["hello", "/eversis-implement AC-1", "and then"]);
    assert.equal(requests.length, 3);
    const [plain, command, later] = requests;

    t.diagnostic(`plain request: ${plain.system.length} system chars, ${plain.bodyChars} body chars`);
    t.diagnostic(`command request: ${command.system.length} system chars, ${command.bodyChars} body chars`);
    assertPlain(plain);
    assert.ok(plain.system.length < BASELINE_CHARS, `${plain.system.length} is below ${BASELINE_CHARS}`);

    assertActive(project, command);
    assert.ok(command.user.length > "/eversis-implement AC-1".length, "Pi expanded the prompt");
    assertActive(project, later);

    // A normal command is not queued: the notice must not say "next run".
    const seen = fs.readFileSync(path.join(project, ".pi", "zz-input.jsonl"), "utf8").trim().split("\n").map((line) => JSON.parse(line));
    assert.deepEqual(seen[1], { text: "/eversis-implement AC-1", idle: true, streamingBehavior: null });
    assert.ok(notifications.includes("Agent Collections process rules on: /eversis-implement."), notifications.join("\n"));
  });

  test("/eversis-review carries the Review context note in its first request", { timeout: TEST_TIMEOUT_MS }, async () => {
    const project = newProject();
    const { requests } = await run(project, ["/eversis-review AC-1"]);
    assert.equal(requests.length, 1);
    assertActive(project, requests[0]);
    assert.match(requests[0].system, /Review context:/);
  });

  test("a Pi edit of an open plan activates the next session, not the running one", { timeout: TEST_TIMEOUT_MS }, async () => {
    const project = newProject(`# Plan\n\n${OPEN_BOX}\n`);
    const toolCalls = {
      "bad edit": { name: "edit", args: { path: PLAN_REL, edits: [{ oldText: "no such text", newText: "x" }] } },
      "edit the plan": { name: "edit", args: { path: PLAN_REL, edits: [{ oldText: "# Plan", newText: "# Plan, edited" }] } },
    };

    const failed = await run(project, ["bad edit"], toolCalls);
    assert.equal(failed.requests.length, 2, "tool call, then its result");
    assert.equal(fs.existsSync(path.join(project, POINTER_REL)), false, "a failed edit leaves no pointer");

    const edited = await run(project, ["edit the plan"], toolCalls);
    assert.equal(edited.requests.length, 2, "tool call, then its result");
    assert.equal(edited.requests[1].lastRole, "tool");
    assertPlain(edited.requests[1]);
    assert.match(fs.readFileSync(path.join(project, PLAN_REL), "utf8"), /# Plan, edited/);
    assert.deepEqual(JSON.parse(fs.readFileSync(path.join(project, POINTER_REL), "utf8")), { plan: PLAN_REL });
    assert.equal(fs.readFileSync(path.join(project, ".pi", "eversis-state", ".gitignore"), "utf8"), "*\n");

    const next = await run(project, ["carry on"]);
    assertActive(project, next.requests[0]);
    assert.ok(
      next.notifications.some((n) => n.includes(PLAN_REL) && n.includes(POINTER_REL)),
      next.notifications.join("\n"),
    );
  });

  test("a plan Pi never edited does not activate the rules", { timeout: TEST_TIMEOUT_MS }, async () => {
    const project = newProject(`# Plan\n\n${OPEN_BOX}\n`);
    const { requests } = await run(project, ["hello"]);
    assertPlain(requests[0]);
    assert.equal(fs.existsSync(path.join(project, POINTER_REL)), false);
  });

  test("a plan with no open boxes clears the pointer", { timeout: TEST_TIMEOUT_MS }, async () => {
    const project = newProject(`# Plan\n\n${OPEN_BOX}\n`);
    const toolCalls = {
      "close the plan": { name: "edit", args: { path: PLAN_REL, edits: [{ oldText: OPEN_BOX, newText: DONE_BOX }] } },
    };
    await run(project, ["close the plan"], toolCalls);
    assert.equal(fs.existsSync(path.join(project, POINTER_REL)), true, "the edit writes the pointer");

    const { requests } = await run(project, ["hello"]);
    assertPlain(requests[0]);
    assert.equal(fs.existsSync(path.join(project, POINTER_REL)), false, "session start clears it");
  });
});
