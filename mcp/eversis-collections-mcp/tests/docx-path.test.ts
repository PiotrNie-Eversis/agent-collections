import assert from "node:assert/strict";
import { access, mkdir, mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import { Document, Packer, Paragraph, TextRun } from "docx";
import { backupDocxFile, loadDocx } from "../src/docx/docx-io.ts";
import { resolveDocxPath, resolveSummaryOutputPath } from "../src/docx/paths.ts";
import { validateDocxFile } from "../src/docx/validate.ts";

async function minimalDocx(): Promise<Buffer> {
  const doc = new Document({
    sections: [
      {
        children: [new Paragraph({ children: [new TextRun("Hello.")] })],
      },
    ],
  });
  return Buffer.from(await Packer.toBuffer(doc));
}

async function makeWorkspaceWithNestedDocx(): Promise<{
  workspaceRoot: string;
  relPath: string;
  absPath: string;
}> {
  const workspaceRoot = await mkdtemp(path.join(tmpdir(), "eversis-docx-ws-"));
  const nested = path.join(workspaceRoot, "nested");
  await mkdir(nested, { recursive: true });
  const absPath = path.join(nested, "file.docx");
  await writeFile(absPath, await minimalDocx());
  return { workspaceRoot, relPath: "nested/file.docx", absPath };
}

test("loadDocx relative path opens under workspaceRoot not cwd", async () => {
  const { workspaceRoot, relPath, absPath } = await makeWorkspaceWithNestedDocx();
  const cwdCandidate = path.join(process.cwd(), relPath);
  await assert.rejects(() => access(cwdCandidate), /ENOENT/);

  const loaded = await loadDocx(relPath, workspaceRoot);
  assert.ok(loaded.abs.startsWith(path.resolve(workspaceRoot)));
  assert.equal(loaded.abs, path.resolve(absPath));
});

test("validateDocxFile relative path PASS under workspaceRoot", async () => {
  const { workspaceRoot, relPath } = await makeWorkspaceWithNestedDocx();
  const cwdCandidate = path.join(process.cwd(), relPath);
  await assert.rejects(() => access(cwdCandidate), /ENOENT/);

  const result = await validateDocxFile(relPath, workspaceRoot);
  assert.equal(result.status, "PASS", JSON.stringify(result));
  assert.ok(result.path.startsWith(path.resolve(workspaceRoot)));
});

test("backupDocxFile default dir under workspace beside source", async () => {
  const { workspaceRoot, relPath } = await makeWorkspaceWithNestedDocx();
  const dest = await backupDocxFile(relPath, undefined, workspaceRoot);
  const expectedDir = path.join(workspaceRoot, "nested", "backups");
  assert.ok(dest.startsWith(expectedDir + path.sep), dest);
  await access(dest);
});

test("backupDocxFile relative backupDir under workspaceRoot", async () => {
  const { workspaceRoot, relPath } = await makeWorkspaceWithNestedDocx();
  const dest = await backupDocxFile(relPath, "rel-backups", workspaceRoot);
  const expectedDir = path.join(workspaceRoot, "rel-backups");
  assert.ok(dest.startsWith(expectedDir + path.sep), dest);
  assert.ok(!dest.startsWith(path.join(process.cwd(), "rel-backups")));
  await access(dest);
});

test("resolveSummaryOutputPath relative output under workspaceRoot", () => {
  const workspaceRoot = path.join(tmpdir(), "eversis-docx-summary-root");
  const resolvedDocx = path.join(workspaceRoot, "nested", "file.docx");
  const out = resolveSummaryOutputPath("out/map.md", resolvedDocx, workspaceRoot);
  assert.equal(out, path.join(workspaceRoot, "out/map.md"));
  assert.ok(!out.startsWith(path.join(process.cwd(), "out")));
});

test("relative path that escapes workspace throws before read", async () => {
  const { workspaceRoot } = await makeWorkspaceWithNestedDocx();
  const escape = "../outside.docx";

  assert.throws(
    () => resolveDocxPath(escape, workspaceRoot),
    (err: Error) => {
      assert.match(err.message, /outside\.docx|escapes/);
      return true;
    }
  );
  await assert.rejects(
    () => loadDocx(escape, workspaceRoot),
    (err: Error) => {
      assert.match(err.message, /outside\.docx|escapes/);
      assert.ok(!err.message.startsWith("Not a file:"));
      return true;
    }
  );
  await assert.rejects(
    () => validateDocxFile(escape, workspaceRoot),
    (err: Error) => {
      assert.match(err.message, /outside\.docx|escapes/);
      return true;
    }
  );
});

test("one-arg loadDocx defaults to resolveWorkspaceRoot via CONSUMER_PROJECT_ROOT", async () => {
  const savedEnv = process.env["CONSUMER_PROJECT_ROOT"];
  try {
    const consumerRoot = await mkdtemp(path.join(tmpdir(), "eversis-docx-consumer-"));
    await mkdir(path.join(consumerRoot, ".agent-collections"), { recursive: true });
    await writeFile(
      path.join(consumerRoot, ".agent-collections", "install-selection.json"),
      JSON.stringify({ frameworkVersion: "0.0.1" })
    );
    const nested = path.join(consumerRoot, "nested");
    await mkdir(nested, { recursive: true });
    const absPath = path.join(nested, "file.docx");
    await writeFile(absPath, await minimalDocx());

    const relPath = "nested/file.docx";
    await assert.rejects(() => access(path.join(process.cwd(), relPath)), /ENOENT/);

    process.env["CONSUMER_PROJECT_ROOT"] = consumerRoot;
    const loaded = await loadDocx(relPath);
    assert.equal(loaded.abs, path.resolve(absPath));
  } finally {
    if (savedEnv === undefined) delete process.env["CONSUMER_PROJECT_ROOT"];
    else process.env["CONSUMER_PROJECT_ROOT"] = savedEnv;
  }
});
