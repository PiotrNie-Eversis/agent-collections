import assert from "node:assert/strict";
import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import { Document, HeadingLevel, Packer, Paragraph, TextRun } from "docx";
import { buildSections, readSectionText, updateSectionBody } from "../src/docx/chapters.ts";
import { loadDocx, saveDocx } from "../src/docx/docx-io.ts";

async function twoHeadingDocx(): Promise<Buffer> {
  const doc = new Document({
    sections: [
      {
        children: [
          new Paragraph({
            heading: HeadingLevel.HEADING_1,
            children: [new TextRun("Chapter One")],
          }),
          new Paragraph({ children: [new TextRun("Body one old.")] }),
          new Paragraph({
            heading: HeadingLevel.HEADING_1,
            children: [new TextRun("Chapter Two")],
          }),
          new Paragraph({ children: [new TextRun("Body two old.")] }),
        ],
      },
    ],
  });
  return Buffer.from(await Packer.toBuffer(doc));
}

test("buildSections and updateSectionBody (OOXML)", async () => {
  const dir = await mkdtemp(path.join(tmpdir(), "eversis-collections-docx-"));
  const p = path.join(dir, "t.docx");
  await writeFile(p, await twoHeadingDocx());

  let loaded = await loadDocx(p);
  let sections = buildSections(loaded.paragraphs);
  assert.deepEqual(
    sections.map((s) => s.section_id),
    ["sec-0", "sec-1"]
  );
  assert.match(readSectionText(loaded.paragraphs, sections[0]!), /Body one old/);
  assert.match(readSectionText(loaded.paragraphs, sections[1]!), /Body two old/);

  updateSectionBody(loaded.doc, loaded.paragraphs, sections[0]!, "Body one **new**.");
  await saveDocx(loaded);

  loaded = await loadDocx(p);
  sections = buildSections(loaded.paragraphs);
  const t0 = readSectionText(loaded.paragraphs, sections[0]!);
  assert.match(t0, /Body one \*\*new\*\*\./);
  assert.ok(!t0.includes("Body one old."));
  assert.match(readSectionText(loaded.paragraphs, sections[1]!), /Body two old/);
});

test("no headings → single sec-0", async () => {
  const doc = new Document({
    sections: [
      {
        children: [new Paragraph({ children: [new TextRun("Only body.")] })],
      },
    ],
  });
  const dir = await mkdtemp(path.join(tmpdir(), "eversis-collections-docx-"));
  const p = path.join(dir, "plain.docx");
  await writeFile(p, Buffer.from(await Packer.toBuffer(doc)));

  const loaded = await loadDocx(p);
  const sections = buildSections(loaded.paragraphs);
  assert.equal(sections.length, 1);
  assert.equal(sections[0]!.section_id, "sec-0");
  assert.match(readSectionText(loaded.paragraphs, sections[0]!), /Only body/);
});
