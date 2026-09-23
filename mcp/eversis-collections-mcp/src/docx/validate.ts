import { readFile } from "node:fs/promises";
import { resolveWorkspaceRoot } from "../context.js";
import JSZip from "jszip";
import { resolveDocxPath } from "./paths.js";

export type DocxValidateStatus = "PASS" | "FAIL";

export interface DocxValidateResult {
  status: DocxValidateStatus;
  path: string;
  entry_count: number;
  document_xml_bytes: number;
  reasons: string[];
  warnings: string[];
  head_preview: string;
}

/**
 * OOXML health checks for word/document.xml (research recipe B).
 * Detects ElementTree-style ns0: rewrites that MS Word rejects even when unzip -t passes.
 */
export function assessDocumentXmlHealth(rawXml: string): {
  reasons: string[];
  warnings: string[];
  headPreview: string;
} {
  const head = rawXml.slice(0, 500);
  const headPreview = head.replace(/\s+/g, " ").trim().slice(0, 240);
  const reasons: string[] = [];
  const warnings: string[] = [];

  if (rawXml.length === 0) {
    reasons.push("word/document.xml is empty");
    return { reasons, warnings, headPreview };
  }

  const hasNs0Root =
    /<ns0:document[\s>]/.test(head) || /xmlns:ns0=/.test(head);
  if (hasNs0Root) {
    reasons.push(
      "ElementTree-style ns0: rewrite detected (<ns0:document / xmlns:ns0=) — Word typically reports the file as damaged"
    );
  }

  const hasWDocument = /<w:document[\s>]/.test(head);
  const hasXmlnsW = /xmlns:w=/.test(rawXml.slice(0, 4000));
  if (!hasWDocument && !hasXmlnsW) {
    reasons.push("missing Word OOXML markers (expected <w:document or xmlns:w= in document head)");
  } else if (!hasWDocument && hasXmlnsW) {
    warnings.push("xmlns:w= present but <w:document root marker not found in first 500 chars");
  }

  if (!/standalone\s*=\s*["']yes["']/.test(head)) {
    warnings.push('missing standalone="yes" on XML declaration (MCP saveDocx normally restores this)');
  }

  return { reasons, warnings, headPreview };
}

/** Fail closed if serialized output looks like an ns0: rewrite. */
export function assertWordCompatibleDocumentXml(serializedRootXml: string): void {
  const head = serializedRootXml.slice(0, 500);
  if (/<ns0:document[\s>]/.test(head) || /xmlns:ns0=/.test(head)) {
    throw new Error(
      "saveDocx refused to write ElementTree-style ns0: document.xml (Word-incompatible serialization)"
    );
  }
  const hasWDocument = /<w:document[\s>]/.test(head);
  const hasXmlnsW = /xmlns:w=/.test(serializedRootXml.slice(0, 4000));
  if (!hasWDocument && !hasXmlnsW) {
    throw new Error(
      "saveDocx refused to write document.xml without Word OOXML markers (<w:document or xmlns:w=)"
    );
  }
}

export async function validateDocxFile(
  docxPath: string,
  workspaceRoot?: string
): Promise<DocxValidateResult> {
  const root = workspaceRoot ?? resolveWorkspaceRoot();
  const abs = resolveDocxPath(docxPath, root);
  const reasons: string[] = [];
  const warnings: string[] = [];
  let entryCount = 0;
  let documentXmlBytes = 0;
  let headPreview = "";

  let buf: Buffer;
  try {
    buf = await readFile(abs);
  } catch {
    return {
      status: "FAIL",
      path: abs,
      entry_count: 0,
      document_xml_bytes: 0,
      reasons: [`not a readable file: ${abs}`],
      warnings: [],
      head_preview: "",
    };
  }

  let zip: JSZip;
  try {
    zip = await JSZip.loadAsync(buf);
  } catch (e) {
    return {
      status: "FAIL",
      path: abs,
      entry_count: 0,
      document_xml_bytes: 0,
      reasons: [`failed to open as zip/docx: ${String(e)}`],
      warnings: [],
      head_preview: "",
    };
  }

  entryCount = Object.keys(zip.files).length;
  const docFile = zip.file("word/document.xml");
  if (!docFile) {
    reasons.push("word/document.xml missing in package");
  } else {
    const raw = await docFile.async("string");
    documentXmlBytes = Buffer.byteLength(raw, "utf8");
    const assessed = assessDocumentXmlHealth(raw);
    reasons.push(...assessed.reasons);
    warnings.push(...assessed.warnings);
    headPreview = assessed.headPreview;
  }

  return {
    status: reasons.length === 0 ? "PASS" : "FAIL",
    path: abs,
    entry_count: entryCount,
    document_xml_bytes: documentXmlBytes,
    reasons,
    warnings,
    head_preview: headPreview,
  };
}
