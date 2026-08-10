import assert from "node:assert/strict";
import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import JSZip from "jszip";
import { Document, Packer, Paragraph, TextRun } from "docx";
import {
  assertWordCompatibleDocumentXml,
  assessDocumentXmlHealth,
  validateDocxFile,
} from "../src/docx/validate.ts";

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

test("assessDocumentXmlHealth PASS on w:document", () => {
  const xml =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body/></w:document>';
  const r = assessDocumentXmlHealth(xml);
  assert.equal(r.reasons.length, 0);
});

test("assessDocumentXmlHealth FAIL on ns0:document", () => {
  const xml =
    "<?xml version='1.0' encoding='utf-8'?>\n" +
    '<ns0:document xmlns:ns0="http://schemas.openxmlformats.org/wordprocessingml/2006/main"></ns0:document>';
  const r = assessDocumentXmlHealth(xml);
  assert.ok(r.reasons.some((x) => /ns0/.test(x)));
});

test("assertWordCompatibleDocumentXml rejects ns0", () => {
  assert.throws(() =>
    assertWordCompatibleDocumentXml(
      '<ns0:document xmlns:ns0="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'
    )
  );
});

test("validateDocxFile PASS on healthy package / FAIL on ns0 rewrite", async () => {
  const dir = await mkdtemp(path.join(tmpdir(), "eversis-validate-docx-"));
  const healthyPath = path.join(dir, "healthy.docx");
  await writeFile(healthyPath, await minimalDocx());

  const pass = await validateDocxFile(healthyPath);
  assert.equal(pass.status, "PASS", JSON.stringify(pass));

  const damagedPath = path.join(dir, "damaged.docx");
  const zip = new JSZip();
  zip.file(
    "word/document.xml",
    "<?xml version='1.0' encoding='utf-8'?>\n" +
      '<ns0:document xmlns:ns0="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><ns0:body/></ns0:document>'
  );
  zip.file(
    "[Content_Types].xml",
    '<?xml version="1.0" encoding="UTF-8"?>' +
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
      '<Default Extension="xml" ContentType="application/xml"/>' +
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>' +
      "</Types>"
  );
  await writeFile(damagedPath, await zip.generateAsync({ type: "nodebuffer" }));

  const fail = await validateDocxFile(damagedPath);
  assert.equal(fail.status, "FAIL", JSON.stringify(fail));
  assert.ok(fail.reasons.some((x) => /ns0/.test(x)));
});
