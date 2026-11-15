/**
 * Tests for the rule-body link rewrite helper (rule-links.mjs).
 *
 * Run: node --test adapters/lib/rule-links.test.mjs
 */

import { describe, it } from "node:test";
import assert from "node:assert/strict";

import { rewriteRuleLinks } from "./rule-links.mjs";

const SOURCE = ".ai/rules/orchestration/agent-core.md";
const MAPPED = new Map([
  [".ai/rules/orchestration/spec-driven-development.md", "./eversis-spec-driven-development.mdc"],
  [".ai/rules/orchestration/fine-handoff.md", "./eversis-fine-handoff.mdc"],
]);
const resolveTarget = (rel) => MAPPED.get(rel) ?? null;
const rewrite = (body, extra = {}) =>
  rewriteRuleLinks(body, {
    sourceRel: SOURCE,
    resolveTarget,
    frameworkPrefix: "",
    warn: () => {},
    ...extra,
  });
const collectWarnings = (body) => {
  const warnings = [];
  const out = rewrite(body, { warn: (message) => warnings.push(message) });
  return { out, warnings };
};

describe("rewriteRuleLinks", () => {
  it("rewrites a link to a mapped sibling rule", () => {
    assert.equal(
      rewrite("follow [`spec-driven-development.md`](./spec-driven-development.md) now"),
      "follow [`spec-driven-development.md`](./eversis-spec-driven-development.mdc) now",
    );
  });

  it("resolves ../ targets against the source directory", () => {
    const out = rewriteRuleLinks("see [x](../orchestration/fine-handoff.md)", {
      sourceRel: ".ai/rules/architecture/code-reviewer.md",
      resolveTarget,
    });
    assert.equal(out, "see [x](./eversis-fine-handoff.mdc)");
  });

  it("keeps the #fragment of a mapped link", () => {
    assert.equal(
      rewrite("[gates](./spec-driven-development.md#human-gates)"),
      "[gates](./eversis-spec-driven-development.mdc#human-gates)",
    );
  });

  it("keeps the source #fragment over the resolver's own #anchor", () => {
    const out = rewriteRuleLinks("[gates](./spec-driven-development.md#human-gates)", {
      sourceRel: SOURCE,
      resolveTarget: () => "#eversis-spec-driven-development",
    });
    assert.equal(out, "[gates](#human-gates)");
  });

  it("keeps the source #fragment on a resolver link with a path and an #anchor", () => {
    const out = rewriteRuleLinks("[gates](./spec-driven-development.md#human-gates)", {
      sourceRel: ".ai/rules/architecture/code-reviewer.md",
      resolveTarget: () => "../../CLAUDE.md#eversis-spec-driven-development",
    });
    assert.equal(out, "[gates](../../CLAUDE.md#human-gates)");
  });

  it("keeps the resolver's own #anchor when the source link has no #fragment", () => {
    const out = rewriteRuleLinks("[sdd](./spec-driven-development.md)", {
      sourceRel: SOURCE,
      resolveTarget: () => "#eversis-spec-driven-development",
    });
    assert.equal(out, "[sdd](#eversis-spec-driven-development)");
  });

  it("rewrites a link with a title and keeps the title", () => {
    assert.equal(
      rewrite('[sdd](./spec-driven-development.md "Delivery Standard")'),
      '[sdd](./eversis-spec-driven-development.mdc "Delivery Standard")',
    );
    assert.equal(
      rewrite("[qa](./fine-handoff.md#objective 'QA draft')"),
      "[qa](./eversis-fine-handoff.mdc#objective 'QA draft')",
    );
  });

  it("rewrites an angle-bracket link and keeps the angle brackets", () => {
    assert.equal(
      rewrite("[sdd](<./spec-driven-development.md#human-gates>)"),
      "[sdd](<./eversis-spec-driven-development.mdc#human-gates>)",
    );
  });

  it("turns an unmapped titled or angle-bracket link into inline code", () => {
    assert.equal(
      rewrite('[r](./README.md "Readme") and [s](<../../skills/>)'),
      "r (`.ai/rules/orchestration/README.md`) and s (`.ai/skills/`)",
    );
  });

  it("warns, without changing the body, on links it cannot rewrite", () => {
    const body = [
      "[bare](spec-driven-development.md#human-gates)",
      "[nested [brackets]](./fine-handoff.md)",
    ].join("\n");
    const { out, warnings } = collectWarnings(body);
    assert.equal(out, body);
    assert.equal(warnings.length, 2);
    assert.match(warnings[0], /agent-core\.md: .*\(spec-driven-development\.md#human-gates\)/);
    assert.match(warnings[1], /agent-core\.md: .*\(\.\/fine-handoff\.md\)/);
  });

  it("does not warn on rewritten, external, anchor, image, code or non-Markdown links", () => {
    const body = [
      "[x](./fine-handoff.md) [site](https://example.com/a.md) [a](#top)",
      "![img](./diagram.png) `[c](./x.md)` [file](notes.txt) [abs](/docs/a.md)",
      "```",
      "[fenced](y.md)",
      "```",
    ].join("\n");
    assert.deepEqual(collectWarnings(body).warnings, []);
  });

  it("defaults the warning to console.warn", () => {
    const original = console.warn;
    const seen = [];
    console.warn = (message) => seen.push(message);
    try {
      rewriteRuleLinks("[bare](fine-handoff.md)", { sourceRel: SOURCE, resolveTarget });
    } finally {
      console.warn = original;
    }
    assert.equal(seen.length, 1);
    assert.match(seen[0], /fine-handoff\.md/);
  });

  it("turns an unmapped link into inline code without a framework prefix", () => {
    assert.equal(
      rewrite("see [the README](./README.md#layout)."),
      "see the README (`.ai/rules/orchestration/README.md#layout`).",
    );
  });

  it("turns an unmapped link into inline code with a framework prefix", () => {
    assert.equal(
      rewrite("see [skills](../../skills/)", { frameworkPrefix: "vendor/agent-collections/" }),
      "see skills (`vendor/agent-collections/.ai/skills/`)",
    );
  });

  it("drops the link, keeping its text, when the target escapes the repository root", () => {
    assert.equal(rewrite("[up](../../../../outside.md)"), "up");
  });

  it("leaves https:, mailto:, #anchor and bare relative links untouched", () => {
    const body = [
      "[site](https://example.com/a.md)",
      "[mail](mailto:a@b.c)",
      "[anchor](#human-gates)",
      "[bare](spec-driven-development.md)",
    ].join("\n");
    assert.equal(rewrite(body), body);
  });

  it("leaves links inside fenced code blocks untouched", () => {
    const body = [
      "```text",
      "[x](./spec-driven-development.md)",
      "```",
      "~~~",
      "[y](./fine-handoff.md)",
      "~~~",
      "[z](./fine-handoff.md)",
    ].join("\n");
    const out = rewrite(body).split("\n");
    assert.equal(out[1], "[x](./spec-driven-development.md)");
    assert.equal(out[4], "[y](./fine-handoff.md)");
    assert.equal(out[6], "[z](./eversis-fine-handoff.mdc)");
  });

  it("leaves inline code spans and images untouched", () => {
    const body = "`[x](./fine-handoff.md)` and ![img](./diagram.png)";
    assert.equal(rewrite(body), body);
  });

  it("is a no-op for a body without relative links", () => {
    const body = "# Title\n\nNo links here.\n";
    assert.equal(rewrite(body), body);
  });
});
