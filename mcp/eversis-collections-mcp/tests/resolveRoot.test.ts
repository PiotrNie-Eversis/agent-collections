import assert from "node:assert/strict";
import { mkdtemp, mkdir, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import { findRepoRoot } from "../src/resolveRoot.ts";

async function makeFakeRoot(): Promise<string> {
  const dir = await mkdtemp(path.join(tmpdir(), "eversis-resolve-test-"));
  await mkdir(path.join(dir, ".ai", "skills"), { recursive: true });
  return dir;
}

let savedEnv: Record<string, string | undefined> = {};

function setEnv(key: string, value: string | undefined): void {
  savedEnv[key] = process.env[key];
  if (value === undefined) {
    delete process.env[key];
  } else {
    process.env[key] = value;
  }
}

function restoreEnv(): void {
  for (const [key, value] of Object.entries(savedEnv)) {
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
  savedEnv = {};
}

test("findRepoRoot — walk-up finds .ai/skills", async () => {
  const root = await makeFakeRoot();
  const nested = path.join(root, "a", "b", "c");
  await mkdir(nested, { recursive: true });
  try {
    const found = findRepoRoot(nested);
    assert.equal(found, root);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("findRepoRoot — AGENT_COLLECTIONS_HOME used when walk-up fails", async () => {
  const fakeHome = await makeFakeRoot();
  const unrelated = await mkdtemp(path.join(tmpdir(), "eversis-unrelated-"));
  setEnv("AGENT_COLLECTIONS_HOME", fakeHome);
  try {
    const found = findRepoRoot(unrelated);
    assert.equal(found, fakeHome);
  } finally {
    restoreEnv();
    await rm(fakeHome, { recursive: true, force: true });
    await rm(unrelated, { recursive: true, force: true });
  }
});

test("findRepoRoot — AGENT_COLLECTIONS_HOME pointing to bad path throws with var name", async () => {
  const unrelated = await mkdtemp(path.join(tmpdir(), "eversis-unrelated-"));
  setEnv("AGENT_COLLECTIONS_HOME", "/nonexistent-path-xyz-12345");
  try {
    assert.throws(
      () => findRepoRoot(unrelated),
      (err: Error) => err.message.includes("AGENT_COLLECTIONS_HOME"),
    );
  } finally {
    restoreEnv();
    await rm(unrelated, { recursive: true, force: true });
  }
});

test("findRepoRoot — no env, no .ai/skills in walk-up throws mentioning AGENT_COLLECTIONS_HOME", async () => {
  const unrelated = await mkdtemp(path.join(tmpdir(), "eversis-unrelated-"));
  setEnv("AGENT_COLLECTIONS_HOME", undefined);
  try {
    assert.throws(
      () => findRepoRoot(unrelated),
      (err: Error) => err.message.includes("AGENT_COLLECTIONS_HOME"),
    );
  } finally {
    restoreEnv();
    await rm(unrelated, { recursive: true, force: true });
  }
});
