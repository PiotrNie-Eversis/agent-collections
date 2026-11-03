/**
 * Tests for adapters/pi/assets/eversis-context-budget.ts (AC-14).
 * Imports the .ts asset directly via Node's native type stripping
 * (Node >= 22.18; dev-only — the installer itself keeps Node >= 18).
 *
 * Run: node --test 'adapters/pi/*.test.mjs'
 */

import assert from "node:assert/strict";
import { test } from "node:test";

const {
  default: eversisContextBudget,
  resolveThreshold,
  shouldCompact,
  CONTINUATION_MESSAGE,
  COMPACTION_INSTRUCTIONS,
  DEFAULT_THRESHOLD_PERCENT,
  THRESHOLD_ENV,
} = await import("./assets/eversis-context-budget.ts");

test("resolveThreshold: default, valid override, invalid overrides fall back to 50", () => {
  assert.equal(DEFAULT_THRESHOLD_PERCENT, 50);
  assert.equal(resolveThreshold({}), 50);
  assert.equal(resolveThreshold(), 50);
  assert.equal(resolveThreshold({ [THRESHOLD_ENV]: "70" }), 70);
  assert.equal(resolveThreshold({ [THRESHOLD_ENV]: " 1 " }), 1);
  assert.equal(resolveThreshold({ [THRESHOLD_ENV]: "95" }), 95);
  for (const bad of ["0", "96", "100", "-5", "abc", "", "50.5", "1e2"]) {
    assert.equal(resolveThreshold({ [THRESHOLD_ENV]: bad }), 50, `invalid ${JSON.stringify(bad)}`);
  }
});

test("shouldCompact: crossing table", () => {
  const cases = [
    // [previous, current, threshold, expected, label]
    [40, 55, 50, true, "below -> above fires"],
    [49.9, 50, 50, true, "below -> exactly threshold fires"],
    [55, 60, 50, false, "above -> above does not fire"],
    [50, 70, 50, false, "at threshold -> above does not fire"],
    [null, 60, 50, true, "unknown (null) -> above fires"],
    [undefined, 60, 50, true, "unknown (undefined) -> above fires"],
    [40, 45, 50, false, "below -> below does not fire"],
    [null, 30, 50, false, "unknown -> below does not fire"],
    [40, null, 50, false, "any -> unknown (null) does not fire"],
    [60, undefined, 50, false, "any -> unknown (undefined) does not fire"],
    [null, null, 50, false, "unknown -> unknown does not fire"],
    [60, 75, 70, true, "threshold override 70: below -> above fires"],
    [60, 65, 70, false, "threshold override 70: below -> below"],
  ];
  for (const [prev, cur, threshold, expected, label] of cases) {
    assert.equal(shouldCompact(prev, cur, threshold), expected, label);
  }
});

test("shouldCompact: afterCompaction reading is a baseline and never fires", () => {
  assert.equal(shouldCompact(null, 60, 50, { afterCompaction: true }), false, "post-compaction above");
  assert.equal(shouldCompact(40, 60, 50, { afterCompaction: true }), false, "even a crossing");
  assert.equal(shouldCompact(null, 60, 50, { afterCompaction: false }), true, "first-ever reading fires");
  assert.equal(shouldCompact(null, 60, 50, {}), true, "default options");
});

test("constants carry the workflow-preservation contract", () => {
  for (const needle of ["plan.md", "CHECKPOINT:", "RESUMED:", "human gate", "next step"]) {
    assert.ok(COMPACTION_INSTRUCTIONS.includes(needle), `instructions mention ${needle}`);
  }
  for (const needle of [
    "Re-read the active plan file",
    "Do not restart",
    "human gate",
    "If there is no active plan, continue the interrupted task from the compaction summary.",
    "This message is automatic and is not an approval of any gate.",
  ]) {
    assert.ok(CONTINUATION_MESSAGE.includes(needle), `continuation mentions ${needle}`);
  }
});

/** Fake Pi runtime: captures handlers, compact() and sendUserMessage() calls. */
function createFakePi({ percents, idle = true, hasUI = true }) {
  const handlers = {};
  const compactCalls = [];
  const sent = [];
  const notices = [];
  let reading = 0;
  const pi = {
    on(event, handler) {
      handlers[event] = handler;
      return () => {};
    },
    sendUserMessage(content, options) {
      sent.push({ content, options });
    },
  };
  const ctx = {
    hasUI,
    ui: { notify: (message, type) => notices.push({ message, type }) },
    isIdle: () => idle,
    getContextUsage: () => {
      const percent = percents[Math.min(reading++, percents.length - 1)];
      return percent === undefined ? undefined : { tokens: null, contextWindow: 1000, percent };
    },
    compact: (options) => compactCalls.push(options),
  };
  const turnEnd = (toolResults) => handlers.turn_end({ type: "turn_end", toolResults }, ctx);
  return { pi, ctx, handlers, compactCalls, sent, notices, turnEnd };
}

const TOOL_RESULT = [{ role: "toolResult" }];

test("factory: mid-task crossing compacts once and sends one continuation", () => {
  const fake = createFakePi({ percents: [30, 55, 58] });
  eversisContextBudget(fake.pi);
  assert.equal(typeof fake.handlers.turn_end, "function");

  fake.turnEnd(TOOL_RESULT); // 30%: below
  assert.equal(fake.compactCalls.length, 0);
  fake.turnEnd(TOOL_RESULT); // 55%: crossing, mid-task
  assert.equal(fake.compactCalls.length, 1);
  assert.equal(fake.compactCalls[0].customInstructions, COMPACTION_INSTRUCTIONS);

  fake.turnEnd(TOOL_RESULT); // in flight: no second compact
  assert.equal(fake.compactCalls.length, 1);
  assert.equal(fake.sent.length, 0);

  fake.compactCalls[0].onComplete({ summary: "s" });
  assert.equal(fake.sent.length, 1);
  assert.equal(fake.sent[0].content, CONTINUATION_MESSAGE);
  assert.equal(fake.sent[0].options.deliverAs, undefined, "idle -> plain send");
  assert.equal(fake.sent[0].options.expandPromptTemplates, false);
});

test("factory: mid-task crossing while streaming queues the continuation as followUp", () => {
  const fake = createFakePi({ percents: [55], idle: false, hasUI: false });
  eversisContextBudget(fake.pi);
  fake.turnEnd(TOOL_RESULT);
  assert.equal(fake.compactCalls.length, 1);
  fake.compactCalls[0].onComplete({ summary: "s" });
  assert.equal(fake.sent.length, 1);
  assert.equal(fake.sent[0].options.deliverAs, "followUp");
  assert.equal(fake.notices.length, 0, "no UI notify without hasUI");
});

test("factory: final-turn crossing compacts without a continuation", () => {
  const fake = createFakePi({ percents: [40, 60] });
  eversisContextBudget(fake.pi);
  fake.turnEnd([]);
  fake.turnEnd([]); // crossing with no tool results
  assert.equal(fake.compactCalls.length, 1);
  fake.compactCalls[0].onComplete({ summary: "s" });
  assert.equal(fake.sent.length, 0);
  assert.ok(fake.notices.some((n) => n.message.includes("compacted")));
});

test("factory: onError sends no continuation and clears the in-flight flag", () => {
  const fake = createFakePi({ percents: [60, 40, 65] });
  eversisContextBudget(fake.pi);
  fake.turnEnd(TOOL_RESULT); // first known reading 60%: unknown -> above fires
  assert.equal(fake.compactCalls.length, 1);
  fake.compactCalls[0].onError(new Error("boom"));
  assert.equal(fake.sent.length, 0);
  assert.ok(fake.notices.some((n) => n.type === "error" && n.message.includes("boom")));
  fake.turnEnd(TOOL_RESULT); // 40%: below
  fake.turnEnd(TOOL_RESULT); // 65%: crossing again -> compacts (flag cleared)
  assert.equal(fake.compactCalls.length, 2);
});

test("factory: unknown usage is ignored; after compaction the next known reading starts fresh", () => {
  const fake = createFakePi({ percents: [undefined, null, 52, null, 30, 20] });
  eversisContextBudget(fake.pi);
  fake.turnEnd(TOOL_RESULT); // getContextUsage() undefined
  fake.turnEnd(TOOL_RESULT); // percent null
  assert.equal(fake.compactCalls.length, 0);
  fake.turnEnd(TOOL_RESULT); // 52%: first known reading above -> fires
  assert.equal(fake.compactCalls.length, 1);
  fake.compactCalls[0].onComplete({ summary: "s" });
  fake.turnEnd(TOOL_RESULT); // null right after compaction
  fake.turnEnd(TOOL_RESULT); // 30%
  fake.turnEnd(TOOL_RESULT); // 20%
  assert.equal(fake.compactCalls.length, 1);
});

test("factory: post-compaction reading above threshold only sets a baseline (no loop)", () => {
  // Small window: retained context stays over budget after compaction.
  const fake = createFakePi({ percents: [40, 60, 70, 75, 45, 62] });
  eversisContextBudget(fake.pi);
  fake.turnEnd(TOOL_RESULT); // 40%: below
  fake.turnEnd(TOOL_RESULT); // 60%: crossing -> compacts
  assert.equal(fake.compactCalls.length, 1);
  fake.compactCalls[0].onComplete({ summary: "s" });
  assert.equal(fake.sent.length, 1, "one continuation");

  fake.turnEnd(TOOL_RESULT); // 70%: first reading after compaction -> baseline only
  fake.turnEnd(TOOL_RESULT); // 75%: above -> above
  assert.equal(fake.compactCalls.length, 1, "no compaction loop");
  assert.equal(fake.sent.length, 1, "no extra continuation");

  fake.turnEnd(TOOL_RESULT); // 45%: dropped below
  fake.turnEnd(TOOL_RESULT); // 62%: fresh crossing -> fires again
  assert.equal(fake.compactCalls.length, 2);
});

test("factory: first-ever known reading above threshold still fires (resumed session)", () => {
  const fake = createFakePi({ percents: [null, 80] });
  eversisContextBudget(fake.pi);
  fake.turnEnd(TOOL_RESULT); // unknown
  fake.turnEnd(TOOL_RESULT); // 80%: unknown -> above on first known reading
  assert.equal(fake.compactCalls.length, 1);
});
