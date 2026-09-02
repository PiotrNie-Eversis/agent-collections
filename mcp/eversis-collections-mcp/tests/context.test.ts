import assert from "node:assert/strict";
import { mkdtemp, mkdir, writeFile, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { test } from "node:test";
import { listContext, getContext, syncContext, resolveWorkspaceRootFrom } from "../src/context.ts";

function _gitSubtreeAvailable(): boolean {
  // `git subtree --help` shells out to `man` and fails on systems without the
  // man page installed even when the subtree command itself works — invoke it
  // bare instead: a real "usage: git subtree add ..." on stderr (exit 129)
  // proves the command exists, vs. git's own "is not a git command" error.
  try {
    execFileSync("git", ["subtree"], { stdio: "pipe" });
    return true;
  } catch (e) {
    const stderr = (e as { stderr?: Buffer })?.stderr?.toString() ?? "";
    return stderr.includes("usage: git subtree");
  }
}

let savedEnv: string | undefined;
function setRoot(dir: string): void {
  savedEnv = process.env["CONSUMER_PROJECT_ROOT"];
  process.env["CONSUMER_PROJECT_ROOT"] = dir;
}
function restoreRoot(): void {
  if (savedEnv === undefined) delete process.env["CONSUMER_PROJECT_ROOT"];
  else process.env["CONSUMER_PROJECT_ROOT"] = savedEnv;
}

async function makeConsumerRoot(opts: {
  externalSsotRepo?: string | null;
} = {}): Promise<string> {
  const dir = await mkdtemp(path.join(tmpdir(), "eversis-context-test-"));
  await mkdir(path.join(dir, ".agent-collections"), { recursive: true });
  const selection = {
    frameworkVersion: "0.0.1",
    ssot: {
      externalSsotRepo: opts.externalSsotRepo ?? null,
      projectContextPath: "docs/context/project/",
      globalContextPath: "docs/context/global/",
    },
  };
  await writeFile(
    path.join(dir, ".agent-collections", "install-selection.json"),
    JSON.stringify(selection, null, 2)
  );
  return dir;
}

test("listContext — project overrides global for the same component", async () => {
  const root = await makeConsumerRoot();
  await mkdir(path.join(root, "docs/context/project"), { recursive: true });
  await writeFile(
    path.join(root, "docs/context/project/INDEX.md"),
    "| Component | One-line summary |\n|---|---|\n| checkout | project version |\n"
  );
  await mkdir(path.join(root, "docs/context/global"), { recursive: true });
  await writeFile(
    path.join(root, "docs/context/global/INDEX.md"),
    "| Component | One-line summary |\n|---|---|\n| checkout | global version |\n| pricing | global only |\n"
  );
  setRoot(root);
  try {
    const list = listContext();
    const checkout = list.find((c) => c.component === "checkout");
    const pricing = list.find((c) => c.component === "pricing");
    assert.equal(checkout?.source, "project");
    assert.equal(pricing?.source, "global");
    assert.equal(list.length, 2);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("getContext — reads project file when it exists, updates last_consulted", async () => {
  const root = await makeConsumerRoot();
  const compDir = path.join(root, "docs/context/project/checkout");
  await mkdir(compDir, { recursive: true });
  await writeFile(
    path.join(compDir, "index.md"),
    "---\nscope: project\n---\n\n# Checkout flow\n"
  );
  setRoot(root);
  try {
    const entry = getContext("checkout");
    assert.equal(entry.source, "project");
    assert.match(entry.content, /Checkout flow/);
    const after = await readFile(path.join(compDir, "index.md"), "utf8");
    assert.match(after, /last_consulted:/);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("getContext — falls back to global when project entry is missing", async () => {
  const root = await makeConsumerRoot();
  const compDir = path.join(root, "docs/context/global/pricing");
  await mkdir(compDir, { recursive: true });
  await writeFile(path.join(compDir, "index.md"), "# Pricing\n");
  setRoot(root);
  try {
    const entry = getContext("pricing");
    assert.equal(entry.source, "global");
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("getContext — annotates staleness on a global entry when up to date, and after the remote moves on", async () => {
  const hasSubtree = _gitSubtreeAvailable();
  if (!hasSubtree) {
    return; // environment without git-subtree — covered by syncContext's own skip-aware test.
  }

  const remoteDir = await mkdtemp(path.join(tmpdir(), "eversis-context-staleness-remote-"));
  execFileSync("git", ["init", "-q", "-b", "main"], { cwd: remoteDir });
  await mkdir(path.join(remoteDir, "pricing"), { recursive: true });
  await writeFile(path.join(remoteDir, "pricing", "index.md"), "# Pricing v1\n");
  execFileSync("git", ["add", "-A"], { cwd: remoteDir });
  execFileSync("git", ["-c", "user.email=t@example.com", "-c", "user.name=t", "commit", "-q", "-m", "v1"], {
    cwd: remoteDir,
  });

  const root = await makeConsumerRoot({ externalSsotRepo: remoteDir });
  execFileSync("git", ["init", "-q", "-b", "main"], { cwd: root });
  execFileSync("git", ["add", "-A"], { cwd: root });
  execFileSync("git", ["-c", "user.email=t@example.com", "-c", "user.name=t", "commit", "-q", "-m", "init"], {
    cwd: root,
  });
  execFileSync(
    "git",
    ["subtree", "add", "--prefix", "docs/context/global", remoteDir, "main", "--squash"],
    { cwd: root }
  );

  setRoot(root);
  try {
    const upToDate = getContext("pricing");
    assert.equal(upToDate.source, "global");
    assert.equal(upToDate.staleness?.upToDate, true);
    assert.ok(upToDate.staleness?.localSplitSha);
    assert.equal(upToDate.staleness?.localSplitSha, upToDate.staleness?.remoteHeadSha);

    // Remote moves on — local subtree copy is now behind.
    await writeFile(path.join(remoteDir, "pricing", "index.md"), "# Pricing v2\n");
    execFileSync("git", ["add", "-A"], { cwd: remoteDir });
    execFileSync("git", ["-c", "user.email=t@example.com", "-c", "user.name=t", "commit", "-q", "-m", "v2"], {
      cwd: remoteDir,
    });

    const stale = getContext("pricing");
    assert.equal(stale.staleness?.upToDate, false);
    assert.notEqual(stale.staleness?.localSplitSha, stale.staleness?.remoteHeadSha);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
    await rm(remoteDir, { recursive: true, force: true });
  }
});

test("getContext — throws a clear error when component does not exist anywhere", async () => {
  const root = await makeConsumerRoot();
  setRoot(root);
  try {
    assert.throws(() => getContext("nonexistent"), /No docs\/context entry/);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("getContext — rejects component names that could escape the context dir", async () => {
  const root = await makeConsumerRoot();
  setRoot(root);
  try {
    assert.throws(() => getContext("../../etc"), /Invalid component name/);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("syncContext — reports no-op when externalSsotRepo is not configured", async () => {
  const root = await makeConsumerRoot({ externalSsotRepo: null });
  setRoot(root);
  try {
    const result = syncContext();
    assert.equal(result.synced, false);
    assert.match(result.message, /nothing to sync/);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("resolveWorkspaceRootFrom — ignores a workspace mount that has no install-selection.json", async () => {
  const mount = await mkdtemp(path.join(tmpdir(), "eversis-workspace-mount-"));
  const cwd = await mkdtemp(path.join(tmpdir(), "eversis-workspace-cwd-"));
  try {
    const root = resolveWorkspaceRootFrom({}, mount, cwd);
    assert.equal(root, cwd);
  } finally {
    await rm(mount, { recursive: true, force: true });
    await rm(cwd, { recursive: true, force: true });
  }
});

test("resolveWorkspaceRootFrom — uses the workspace mount when install-selection.json is there", async () => {
  const mount = await makeConsumerRoot();
  const cwd = await mkdtemp(path.join(tmpdir(), "eversis-workspace-cwd-"));
  try {
    const root = resolveWorkspaceRootFrom({}, mount, cwd);
    assert.equal(root, mount);
  } finally {
    await rm(mount, { recursive: true, force: true });
    await rm(cwd, { recursive: true, force: true });
  }
});

test("resolveWorkspaceRootFrom — ignores CONSUMER_PROJECT_ROOT when it has no install-selection.json", async () => {
  const envDir = await mkdtemp(path.join(tmpdir(), "eversis-env-root-"));
  const mount = await makeConsumerRoot();
  const cwd = await mkdtemp(path.join(tmpdir(), "eversis-workspace-cwd-"));
  try {
    const root = resolveWorkspaceRootFrom({ CONSUMER_PROJECT_ROOT: envDir }, mount, cwd);
    assert.equal(root, mount);
  } finally {
    await rm(envDir, { recursive: true, force: true });
    await rm(mount, { recursive: true, force: true });
    await rm(cwd, { recursive: true, force: true });
  }
});

test("listContext/getContext — strips markdown links in the INDEX first column", async () => {
  const root = await makeConsumerRoot();
  const compDir = path.join(root, "docs/context/project/checkout");
  await mkdir(compDir, { recursive: true });
  await writeFile(
    path.join(root, "docs/context/project/INDEX.md"),
    "| Component | One-line summary |\n|---|---|\n| [checkout](./checkout/index.md) | payment and cart |\n"
  );
  await writeFile(path.join(compDir, "index.md"), "# Checkout\n");
  setRoot(root);
  try {
    const list = listContext();
    assert.equal(list.find((c) => c.component === "checkout")?.source, "project");
    const entry = getContext("checkout");
    assert.equal(entry.source, "project");
    assert.match(entry.content, /Checkout/);
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("listContext — bare INDEX component names still work", async () => {
  const root = await makeConsumerRoot();
  await mkdir(path.join(root, "docs/context/project"), { recursive: true });
  await writeFile(
    path.join(root, "docs/context/project/INDEX.md"),
    "| Component | One-line summary |\n|---|---|\n| checkout | payment and cart |\n"
  );
  setRoot(root);
  try {
    const list = listContext();
    assert.equal(list[0]?.component, "checkout");
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
  }
});

test("syncContext — runs git subtree pull when reachable, or reports failure without throwing", async () => {
  const hasSubtree = _gitSubtreeAvailable();

  const remoteDir = await mkdtemp(path.join(tmpdir(), "eversis-context-remote-"));
  execFileSync("git", ["init", "-q", "-b", "main"], { cwd: remoteDir });
  await writeFile(path.join(remoteDir, "INDEX.md"), "# domain-context\n");
  execFileSync("git", ["add", "INDEX.md"], { cwd: remoteDir });
  execFileSync("git", ["-c", "user.email=test@example.com", "-c", "user.name=test", "commit", "-q", "-m", "seed"], {
    cwd: remoteDir,
  });

  const root = await makeConsumerRoot({ externalSsotRepo: remoteDir });
  execFileSync("git", ["init", "-q", "-b", "main"], { cwd: root });
  execFileSync("git", ["add", "-A"], { cwd: root });
  execFileSync("git", ["-c", "user.email=test@example.com", "-c", "user.name=test", "commit", "-q", "-m", "init"], {
    cwd: root,
  });
  setRoot(root);
  try {
    const result = syncContext("main");
    if (hasSubtree) {
      assert.equal(result.synced, true);
    } else {
      assert.equal(result.synced, false);
    }
  } finally {
    restoreRoot();
    await rm(root, { recursive: true, force: true });
    await rm(remoteDir, { recursive: true, force: true });
  }
});
