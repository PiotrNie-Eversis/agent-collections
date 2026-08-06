import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { DOMParser, XMLSerializer } from "@xmldom/xmldom";
import type { Document as XmlDocument, Element as XmlElement } from "@xmldom/xmldom";
import JSZip from "jszip";
import { getBody, listBodyParagraphs, buildStyleMap } from "./chapters.js";

export interface LoadedDocx {
  abs: string;
  zip: JSZip;
  doc: XmlDocument;
  body: XmlElement;
  paragraphs: XmlElement[];
  /** styleId → resolved English name (e.g. "Nagwek1" → "heading 1"). Empty map when styles.xml is absent. */
  styleMap: Map<string, string>;
  /** True when word/document.xml contained a leading UTF-8 BOM (\uFEFF) that was stripped on load. */
  hasBom: boolean;
}

/**
 * Parse an XML string from a .docx zip entry.
 * Strips a leading UTF-8 BOM (\uFEFF) that MS Office sometimes writes before `<?xml`.
 * @xmldom/xmldom treats the BOM as content outside the root element and throws a fatalError.
 */
function parseXml(xml: string): XmlDocument {
  const clean = xml.charCodeAt(0) === 0xfeff ? xml.slice(1) : xml;
  return new DOMParser().parseFromString(clean, "application/xml") as XmlDocument;
}

export async function loadDocx(docxPath: string): Promise<LoadedDocx> {
  const abs = path.resolve(docxPath);
  let buf: Buffer;
  try {
    buf = await readFile(abs);
  } catch {
    throw new Error(`Not a file: ${abs}`);
  }

  const zip = await JSZip.loadAsync(buf);

  // --- document.xml (required) ---
  const docFile = zip.file("word/document.xml");
  if (!docFile) throw new Error("word/document.xml missing in docx");
  const rawDocXml = await docFile.async("string");
  const hasBom = rawDocXml.charCodeAt(0) === 0xfeff;
  const doc = parseXml(rawDocXml);
  const docEl = doc.documentElement;
  if (!docEl) throw new Error("Empty document.xml");
  if (docEl.localName === "parsererror") throw new Error("Failed to parse word/document.xml");

  // --- styles.xml (optional — used for locale-agnostic heading detection) ---
  let styleMap: Map<string, string> = new Map();
  const stylesFile = zip.file("word/styles.xml");
  if (stylesFile) {
    try {
      const stylesDoc = parseXml(await stylesFile.async("string"));
      styleMap = buildStyleMap(stylesDoc);
    } catch {
      // Non-critical — fall back to legacy heading detection
    }
  }

  const body = getBody(doc);
  const paragraphs = listBodyParagraphs(body);
  return { abs, zip, doc, body, paragraphs, styleMap, hasBom };
}

export async function saveDocx(loaded: LoadedDocx): Promise<void> {
  const { zip, doc, abs } = loaded;
  const ser = new XMLSerializer();
  const root = doc.documentElement;
  if (!root) throw new Error("No document root");
  const out = ser.serializeToString(root);
  const decl = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
  zip.file("word/document.xml", `${decl}\n${out}`);
  const buf = await zip.generateAsync({ type: "nodebuffer" });
  await writeFile(abs, buf);
}
