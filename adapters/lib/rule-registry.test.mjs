/**
 * Tests for the rule registry check (rule-registry.mjs).
 *
 * Run: node --test adapters/lib/rule-registry.test.mjs
 */

import { describe, it } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  findRuleRegistryProblems,
  listRuleFiles,
  parseNotEmittedYaml,
} from "./rule-registry.mjs";

const MAPPED = ".ai/rules/orchestration/agent-core.md";
const SEED = ".ai/rules/backend/backend-principles.md";
const PROBE = ".ai/rules/frontend/probe.md";

describe("findRuleRegistryProblems", () => {
  it("passes when every rule file is mapped or listed with a reason", () => {
    const problems = findRuleRegistryProblems({
      ruleFiles: [SEED, MAPPED],
      mappedSources: [MAPPED],
      notEmitted: [{ source: SEED, reason: "seed of a skill" }],
    });
    assert.deepEqual(problems, []);
  });

  it("fails on an unregistered rule and names the file", () => {
    const problems = findRuleRegistryProblems({
      ruleFiles: [MAPPED, PROBE],
      mappedSources: [MAPPED],
      notEmitted: [],
    });
    assert.equal(problems.length, 1);
    assert.match(problems[0], /^unregistered rule: \.ai\/rules\/frontend\/probe\.md/);
    assert.match(problems[0], /adapters\/cursor\/rule-map\.yaml/);
    assert.match(problems[0], /adapters\/rules-not-emitted\.yaml/);
  });

  it("fails on a file that is both mapped and listed", () => {
    const problems = findRuleRegistryProblems({
      ruleFiles: [MAPPED],
      mappedSources: [MAPPED],
      notEmitted: [{ source: MAPPED, reason: "x", line: 3 }],
    });
    assert.equal(problems.length, 1);
    assert.match(problems[0], /both a source/);
  });

  it("fails on an entry whose file does not exist", () => {
    const problems = findRuleRegistryProblems({
      ruleFiles: [MAPPED],
      mappedSources: [MAPPED],
      notEmitted: [{ source: SEED, reason: "seed", line: 8 }],
    });
    assert.equal(problems.length, 1);
    assert.match(problems[0], /line 8\): \.ai\/rules\/backend\/backend-principles\.md is not a rule file/);
  });

  it("fails on an entry without a reason or listed twice", () => {
    const problems = findRuleRegistryProblems({
      ruleFiles: [SEED],
      mappedSources: [],
      notEmitted: [
        { source: SEED, reason: "  " },
        { source: SEED, reason: "seed" },
      ],
    });
    assert.equal(problems.length, 2);
    assert.match(problems[0], /has no reason/);
    assert.match(problems[1], /listed twice/);
  });
});

describe("parseNotEmittedYaml", () => {
  it("reads version and entries with source, reason and line", () => {
    const doc = parseNotEmittedYaml(
      [
        "# comment",
        "version: 1",
        "not_emitted:",
        `  - source: ${SEED}`,
        '    reason: "Seed excerpt; the skill carries the content" # trailing',
        "",
      ].join("\n"),
    );
    assert.equal(doc.version, 1);
    assert.deepEqual(doc.entries, [
      { line: 4, source: SEED, reason: "Seed excerpt; the skill carries the content" },
    ]);
  });

  it("accepts an empty list", () => {
    assert.deepEqual(parseNotEmittedYaml("version: 1\nnot_emitted: []\n").entries, []);
  });

  it("rejects an unknown key", () => {
    assert.throws(
      () => parseNotEmittedYaml(`version: 1\nnot_emitted:\n  - source: ${SEED}\n    why: x\n`),
      /unexpected line 4/,
    );
  });

  it("rejects an unknown top-level key", () => {
    assert.throws(() => parseNotEmittedYaml("version: 1\nrules:\n"), /unexpected line 2/);
  });

  it("keeps a # inside a quoted value and drops a comment outside quotes", () => {
    const doc = parseNotEmittedYaml(
      `version: 1\nnot_emitted:\n  - source: ${SEED}\n    reason: "see item #3 here" # note\n`,
    );
    assert.equal(doc.entries[0].reason, "see item #3 here");
    const single = parseNotEmittedYaml(
      `version: 1\nnot_emitted:\n  - source: ${SEED}\n    reason: 'a # b'\n`,
    );
    assert.equal(single.entries[0].reason, "a # b");
  });

  it("rejects a key repeated within one entry", () => {
    assert.throws(
      () =>
        parseNotEmittedYaml(
          `version: 1\nnot_emitted:\n  - source: ${SEED}\n    source: ${MAPPED}\n    reason: x\n`,
        ),
      /line 4: key "source" repeated in the entry that starts on line 3/,
    );
  });

  it("rejects a file without the not_emitted key", () => {
    assert.throws(() => parseNotEmittedYaml("version: 1\n"), /missing key not_emitted/);
  });
});

describe("listRuleFiles", () => {
  it("lists .md files under .ai/rules/ recursively, without README.md", () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), "rule-registry-"));
    try {
      for (const rel of [
        ".ai/rules/README.md",
        ".ai/rules/frontend/README.md",
        ".ai/rules/frontend/accessibility.md",
        ".ai/rules/a/b/deep.md",
        ".ai/rules/frontend/notes.txt",
      ]) {
        fs.mkdirSync(path.dirname(path.join(root, rel)), { recursive: true });
        fs.writeFileSync(path.join(root, rel), "x");
      }
      assert.deepEqual(listRuleFiles(root), [
        ".ai/rules/a/b/deep.md",
        ".ai/rules/frontend/accessibility.md",
      ]);
    } finally {
      fs.rmSync(root, { recursive: true, force: true });
    }
  });

  it("returns an empty list when .ai/rules/ is missing", () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), "rule-registry-"));
    try {
      assert.deepEqual(listRuleFiles(root), []);
    } finally {
      fs.rmSync(root, { recursive: true, force: true });
    }
  });
});

describe("framework tree", () => {
  it("the shipped exception list parses and matches the current rule files", () => {
    const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
    const doc = parseNotEmittedYaml(
      fs.readFileSync(path.join(repoRoot, "adapters", "rules-not-emitted.yaml"), "utf8"),
    );
    assert.equal(doc.version, 1);
    const mappedSources = fs
      .readFileSync(path.join(repoRoot, "adapters", "cursor", "rule-map.yaml"), "utf8")
      .split(/\r?\n/)
      .map((l) => l.match(/^\s{4}source:\s*(\S+)/))
      .filter(Boolean)
      .map((m) => m[1].replace(/^["']|["']$/g, ""));
    assert.deepEqual(
      findRuleRegistryProblems({
        ruleFiles: listRuleFiles(repoRoot),
        mappedSources,
        notEmitted: doc.entries,
      }),
      [],
    );
  });
});
