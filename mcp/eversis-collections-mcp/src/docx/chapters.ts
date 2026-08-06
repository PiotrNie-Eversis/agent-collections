/**
 * Section model for .docx (OOXML). Body-level w:p in word/document.xml only.
 * Matches the Business Manager Docs playbook tool contract (`chapter_id`, headings).
 */

import type { Document as XmlDocument, Element as XmlElement } from "@xmldom/xmldom";

export const W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
const XML_NS = "http://www.w3.org/XML/1998/namespace";

// ── Section model ─────────────────────────────────────────────────────────────

export interface Section {
  section_id: string;
  level: number;
  title: string;
  start: number;
  end: number;
  /** True when the section body contains at least one w:tbl (Word table). */
  hasTables: boolean;
  /** True when the section body contains at least one w:drawing (inline/anchored image). */
  hasImages: boolean;
  /** Number of direct-body w:tbl elements within this section. */
  tableCount: number;
}

// ── Body-node enumeration ─────────────────────────────────────────────────────

export type BodyNodeType = "paragraph" | "table" | "drawing" | "other";

export interface BodyNode {
  el: XmlElement;
  type: BodyNodeType;
  /** Index into the paragraphEls array; null for non-paragraph nodes (tables, etc.). */
  paraIndex: number | null;
}

/**
 * Return all direct children of w:body as typed BodyNode records.
 * Requires the same paragraphEls array produced by listBodyParagraphs to resolve paraIndex.
 */
export function listBodyNodes(body: XmlElement, paragraphEls: XmlElement[]): BodyNode[] {
  const paraSet = new Map<XmlElement, number>();
  paragraphEls.forEach((p, i) => paraSet.set(p, i));

  const out: BodyNode[] = [];
  for (let n = body.firstChild; n; n = n.nextSibling) {
    if (n.nodeType !== 1) continue;
    const el = n as XmlElement;
    let type: BodyNodeType = "other";
    if (el.namespaceURI === W_NS) {
      if (el.localName === "p") type = "paragraph";
      else if (el.localName === "tbl") type = "table";
      else if (el.localName === "drawing") type = "drawing";
    }
    out.push({ el, type, paraIndex: paraSet.get(el) ?? null });
  }
  return out;
}

// ── Style helpers ─────────────────────────────────────────────────────────────

/**
 * Build a map of styleId → resolved English name from word/styles.xml.
 *
 * MS Word localises style IDs (e.g. "Nagwek1" in Polish, "Titre1" in French)
 * but the w:name element always contains the canonical English value ("heading 1").
 * This map lets isHeadingPara work correctly regardless of the document locale.
 */
export function buildStyleMap(stylesDoc: XmlDocument): Map<string, string> {
  const map = new Map<string, string>();
  const styles = stylesDoc.getElementsByTagNameNS(W_NS, "style");
  for (let i = 0; i < styles.length; i++) {
    const s = styles[i] as XmlElement;
    const type = s.getAttribute("w:type") ?? s.getAttributeNS(W_NS, "type");
    if (type !== "paragraph") continue;
    const styleId = s.getAttribute("w:styleId") ?? s.getAttributeNS(W_NS, "styleId");
    if (!styleId) continue;
    const nameEls = s.getElementsByTagNameNS(W_NS, "name");
    if (!nameEls.length) continue;
    const nameVal =
      (nameEls[0] as XmlElement).getAttribute("w:val") ??
      (nameEls[0] as XmlElement).getAttributeNS(W_NS, "val");
    if (nameVal) map.set(styleId, nameVal.toLowerCase());
  }
  return map;
}

// ── Paragraph helpers ─────────────────────────────────────────────────────────

export function listBodyParagraphs(body: XmlElement): XmlElement[] {
  const out: XmlElement[] = [];
  for (let n = body.firstChild; n; n = n.nextSibling) {
    if (n.nodeType !== 1) continue;
    const el = n as XmlElement;
    if (el.namespaceURI === W_NS && el.localName === "p") out.push(el);
  }
  return out;
}

export function getBody(doc: XmlDocument): XmlElement {
  const docEl = doc.documentElement;
  if (!docEl) throw new Error("Empty XML document");
  const bodies = docEl.getElementsByTagNameNS(W_NS, "body");
  if (!bodies.length) throw new Error("No w:body");
  return bodies[0] as XmlElement;
}

function getPStyleVal(p: XmlElement): string | null {
  const pPrs = p.getElementsByTagNameNS(W_NS, "pPr");
  if (!pPrs.length) return null;
  const styles = pPrs[0].getElementsByTagNameNS(W_NS, "pStyle");
  if (!styles.length) return null;
  const st = styles[0];
  return st.getAttribute("w:val") ?? st.getAttributeNS(W_NS, "val");
}

/**
 * Return true when the paragraph uses a heading or TOC-heading style.
 *
 * @param styleMap  Optional map from loadDocx — resolves locale style IDs to
 *                  their canonical English names before the check. When absent
 *                  the raw styleId is tested (legacy behaviour).
 */
export function isHeadingPara(p: XmlElement, styleMap?: Map<string, string>): boolean {
  const val = getPStyleVal(p);
  if (!val) return false;
  const resolved = styleMap?.get(val) ?? val;
  const lower = resolved.toLowerCase();
  return lower.includes("heading") || lower.startsWith("toc");
}

/**
 * Extract the numeric heading level (1–9) from the paragraph style.
 * Works on both English ("Heading 2") and locale IDs ("Nagwek2", "Titre 3").
 */
export function headingLevel(p: XmlElement, styleMap?: Map<string, string>): number {
  const val = getPStyleVal(p) ?? "";
  const resolved = styleMap?.get(val) ?? val;
  const m = resolved.match(/(\d+)\s*$/);
  if (m) return Math.max(1, Math.min(9, parseInt(m[1], 10)));
  return 1;
}

export function paragraphText(p: XmlElement): string {
  const texts = p.getElementsByTagNameNS(W_NS, "t");
  let s = "";
  for (let i = 0; i < texts.length; i++) {
    s += texts[i].textContent ?? "";
  }
  return s.trim();
}

// ── Section flags helper ──────────────────────────────────────────────────────

/**
 * Walk body DOM from the anchor paragraph of a section to the first paragraph
 * of the next section, collecting table and image presence flags.
 *
 * Tables (w:tbl) are direct children of w:body.
 * Images (w:drawing) are descendants of w:p children of w:body.
 */
function computeSectionFlags(
  body: XmlElement,
  paragraphEls: XmlElement[],
  start: number,
  end: number
): { hasTables: boolean; hasImages: boolean; tableCount: number } {
  const startNode = paragraphEls[start];
  const endNode = end < paragraphEls.length ? paragraphEls[end] : null;

  let inSection = false;
  let hasTables = false;
  let tableCount = 0;
  let hasImages = false;

  for (let n = body.firstChild; n; n = n.nextSibling) {
    if (n === startNode) inSection = true;
    if (endNode && n === endNode) break;
    if (!inSection || n.nodeType !== 1) continue;

    const el = n as XmlElement;
    if (el.namespaceURI === W_NS) {
      if (el.localName === "tbl") {
        hasTables = true;
        tableCount++;
      } else if (el.localName === "p" && el.getElementsByTagNameNS(W_NS, "drawing").length > 0) {
        hasImages = true;
      }
    }
  }

  return { hasTables, hasImages, tableCount };
}

// ── Section building ──────────────────────────────────────────────────────────

/**
 * Build a flat list of sections from the body paragraph array.
 *
 * @param paragraphEls  All w:p nodes from listBodyParagraphs.
 * @param body          The w:body element. When provided, sections are annotated
 *                      with hasTables / hasImages / tableCount flags (MCP-3).
 * @param styleMap      Locale-aware style map from buildStyleMap / loadDocx (MCP-2).
 *                      When absent, legacy English-only heading detection is used.
 */
export function buildSections(
  paragraphEls: XmlElement[],
  body?: XmlElement,
  styleMap?: Map<string, string>
): Section[] {
  const headingIndices: { idx: number; level: number; title: string }[] = [];
  for (let i = 0; i < paragraphEls.length; i++) {
    const p = paragraphEls[i];
    if (isHeadingPara(p, styleMap)) {
      const t = paragraphText(p) || "(untitled)";
      headingIndices.push({ idx: i, level: headingLevel(p, styleMap), title: t });
    }
  }

  const noFlags = { hasTables: false, hasImages: false, tableCount: 0 };

  function flags(start: number, end: number) {
    return body ? computeSectionFlags(body, paragraphEls, start, end) : noFlags;
  }

  if (!headingIndices.length) {
    return [
      {
        section_id: "sec-0",
        level: 1,
        title: "Document",
        start: 0,
        end: paragraphEls.length,
        ...flags(0, paragraphEls.length),
      },
    ];
  }

  const sections: Section[] = [];
  const firstHeadingIdx = headingIndices[0].idx;
  if (firstHeadingIdx > 0) {
    sections.push({
      section_id: "sec-0",
      level: 1,
      title: "Preamble",
      start: 0,
      end: firstHeadingIdx,
      ...flags(0, firstHeadingIdx),
    });
  }

  for (let j = 0; j < headingIndices.length; j++) {
    const { idx, level, title } = headingIndices[j];
    const end =
      j + 1 < headingIndices.length ? headingIndices[j + 1].idx : paragraphEls.length;
    sections.push({
      section_id: `sec-${sections.length}`,
      level,
      title,
      start: idx,
      end,
      ...flags(idx, end),
    });
  }

  return sections;
}

// ── Text read / write ─────────────────────────────────────────────────────────

export function readSectionText(
  paragraphEls: XmlElement[],
  section: Section,
  styleMap?: Map<string, string>
): string {
  const lines: string[] = [];
  for (let i = section.start; i < Math.min(section.end, paragraphEls.length); i++) {
    if (i === section.start && isHeadingPara(paragraphEls[i], styleMap)) continue;
    const t = paragraphText(paragraphEls[i]);
    if (t) lines.push(t);
  }
  return lines.join("\n\n");
}

export function renderSummaryMd(sections: Section[], docBaseName: string): string {
  const lines = [
    `<!-- Generated map for \`${docBaseName}\` — do not edit structure by hand unless needed. -->`,
    "",
    "| chapter_id | level | title |",
    "| --- | --- | --- |",
  ];
  for (const s of sections) {
    const title = s.title.replace(/\|/g, "\\|");
    lines.push(`| \`${s.section_id}\` | ${s.level} | ${title} |`);
  }
  return lines.join("\n");
}

export function createTextParagraph(ownerDoc: XmlDocument, text: string): XmlElement {
  const p = ownerDoc.createElementNS(W_NS, "w:p");
  const r = ownerDoc.createElementNS(W_NS, "w:r");
  const t = ownerDoc.createElementNS(W_NS, "w:t");
  if (/^\s|\s$/.test(text)) {
    t.setAttributeNS(XML_NS, "xml:space", "preserve");
  }
  t.appendChild(ownerDoc.createTextNode(text));
  r.appendChild(t);
  p.appendChild(r);
  return p;
}

export function insertAfter(parent: XmlElement, newEl: XmlElement, after: XmlElement): void {
  const next = after.nextSibling;
  if (next) parent.insertBefore(newEl, next);
  else parent.appendChild(newEl);
}

// ── Heading locale detection ──────────────────────────────────────────────────

export interface HeadingLocaleInfo {
  locale: "en" | "pl" | "fr" | "other" | "mixed";
  /** Up to 3 example style IDs that resolved to heading styles. */
  examples: string[];
}

/**
 * Derive the document heading locale from the styleMap.
 * Inspects the style ID keys (not the resolved English values) to determine
 * the original locale: English IDs start with "Heading", Polish with "Nagwek",
 * French with "Titre".
 */
export function detectHeadingLocale(styleMap: Map<string, string>): HeadingLocaleInfo {
  const headingKeys: string[] = [];
  for (const [k, v] of styleMap) {
    if (v.includes("heading")) headingKeys.push(k);
  }
  if (!headingKeys.length) return { locale: "other", examples: [] };

  const examples = headingKeys.slice(0, 3);
  const isEn = headingKeys.every((k) => /^heading\s*\d/i.test(k));
  const hasPl = headingKeys.some((k) => /nagw/i.test(k));
  const hasFr = headingKeys.some((k) => /titre/i.test(k));

  if (isEn) return { locale: "en", examples };
  if (hasPl && !hasFr) return { locale: "pl", examples };
  if (hasFr && !hasPl) return { locale: "fr", examples };
  if (hasPl || hasFr) return { locale: "mixed", examples };
  return { locale: "other", examples };
}

// ── Image counting ────────────────────────────────────────────────────────────

/**
 * Count the total number of w:drawing elements (inline or anchored images)
 * inside w:p children of w:body that belong to this section's DOM range.
 */
export function countSectionImages(
  body: XmlElement,
  paragraphEls: XmlElement[],
  section: Section
): number {
  if (section.start >= paragraphEls.length) return 0;
  const startNode = paragraphEls[section.start];
  const endNode = section.end < paragraphEls.length ? paragraphEls[section.end] : null;

  let count = 0;
  let inSection = false;
  for (let n = body.firstChild; n; n = n.nextSibling) {
    if (n === startNode) inSection = true;
    if (endNode && n === endNode) break;
    if (!inSection || n.nodeType !== 1) continue;
    const el = n as XmlElement;
    if (el.namespaceURI === W_NS && el.localName === "p") {
      count += el.getElementsByTagNameNS(W_NS, "drawing").length;
    }
  }
  return count;
}

// ── Additive section append ───────────────────────────────────────────────────

/**
 * Append new content paragraphs to a section WITHOUT removing existing content.
 *
 * Insertion strategy (handles R-3 — section ending with w:tbl):
 * - When a next-section heading exists in paragraphEls, inserts all new paragraphs
 *   immediately before it (after any trailing tables in the section's DOM range).
 * - When the section is the last in the document, appends to the body.
 *
 * Style inheritance: w:pPr is copied from the last paragraph of the section so
 * the new paragraphs adopt the same paragraph formatting.
 */
export function appendSectionBody(
  ownerDoc: XmlDocument,
  paragraphEls: XmlElement[],
  section: Section,
  newContent: string,
  placeholderGraphics?: string | null
): void {
  const lastParaIdx = Math.min(section.end, paragraphEls.length) - 1;
  if (lastParaIdx < section.start) return;

  const lastPara = paragraphEls[lastParaIdx];
  const parent = lastPara.parentNode as XmlElement;

  const lastPPrCol = lastPara.getElementsByTagNameNS(W_NS, "pPr");
  const lastPPr = lastPPrCol.length ? (lastPPrCol[0] as XmlElement) : null;

  const nextHeading =
    section.end < paragraphEls.length ? paragraphEls[section.end] : null;

  let body = newContent.trimEnd();
  if (placeholderGraphics) body = `${body}\n\n${placeholderGraphics.trim()}`;

  const blocks = body.split(/\n\n+/).map((b) => b.trim()).filter(Boolean);

  /**
   * Build a sanitized copy of the source pPr: strip <w:pStyle> so the new
   * paragraph never inherits a heading style from the section's last paragraph.
   * Other formatting (indentation, spacing, etc.) is preserved.
   */
  function safePPr(): XmlElement | null {
    if (!lastPPr) return null;
    const clone = lastPPr.cloneNode(true) as XmlElement;
    const styleEls = clone.getElementsByTagNameNS(W_NS, "pStyle");
    for (let i = styleEls.length - 1; i >= 0; i--) {
      const el = styleEls[i] as XmlElement;
      if (el.parentNode) el.parentNode.removeChild(el);
    }
    // If pPr is now empty (no child nodes left), skip it entirely
    if (!clone.firstChild) return null;
    return clone;
  }

  if (nextHeading) {
    for (const line of blocks) {
      const newP = createTextParagraph(ownerDoc, line);
      const ppr = safePPr();
      if (ppr) newP.insertBefore(ppr, newP.firstChild);
      parent.insertBefore(newP, nextHeading);
    }
  } else {
    let ref = lastPara;
    for (const line of blocks) {
      const newP = createTextParagraph(ownerDoc, line);
      const ppr = safePPr();
      if (ppr) newP.insertBefore(ppr, newP.firstChild);
      insertAfter(parent, newP, ref);
      ref = newP;
    }
  }
}

// ── Table cell editing ────────────────────────────────────────────────────────

/**
 * Collect all w:tbl elements that are direct body children within a section's DOM range.
 */
function collectSectionTables(
  body: XmlElement,
  paragraphEls: XmlElement[],
  section: Section
): XmlElement[] {
  if (section.start >= paragraphEls.length) return [];
  const startNode = paragraphEls[section.start];
  const endNode = section.end < paragraphEls.length ? paragraphEls[section.end] : null;

  const tables: XmlElement[] = [];
  let inSection = false;
  for (let n = body.firstChild; n; n = n.nextSibling) {
    if (n === startNode) inSection = true;
    if (endNode && n === endNode) break;
    if (!inSection || n.nodeType !== 1) continue;
    const el = n as XmlElement;
    if (el.namespaceURI === W_NS && el.localName === "tbl") tables.push(el);
  }
  return tables;
}

/**
 * Update a specific table cell or append a new row to a table within a section.
 *
 * Mode 1 — update cell:   pass row, col, newContent
 * Mode 2 — append row:    pass action = "append_row" and rowValues
 *
 * Returns a human-readable result string.
 */
export function updateTableCell(
  ownerDoc: XmlDocument,
  body: XmlElement,
  paragraphEls: XmlElement[],
  section: Section,
  tableIndex: number,
  options:
    | { action?: undefined; row: number; col: number; newContent: string }
    | { action: "append_row"; rowValues: string[] }
): string {
  const tables = collectSectionTables(body, paragraphEls, section);
  if (tableIndex >= tables.length) {
    throw new Error(
      `table_index ${tableIndex} out of range — section "${section.section_id}" has ${tables.length} table(s)`
    );
  }
  const tbl = tables[tableIndex];

  // Collect rows
  const rowEls = tbl.getElementsByTagNameNS(W_NS, "tr");
  const rowCount = rowEls.length;

  if (!options.action) {
    // ── Mode 1: update cell ──────────────────────────────────────────────────
    const { row, col, newContent } = options;
    if (row >= rowCount) {
      throw new Error(`row ${row} out of range — table has ${rowCount} row(s)`);
    }
    const rowEl = rowEls[row] as XmlElement;
    const cellEls = rowEl.getElementsByTagNameNS(W_NS, "tc");
    const cellCount = cellEls.length;
    if (col >= cellCount) {
      throw new Error(`col ${col} out of range — row has ${cellCount} cell(s)`);
    }
    const tc = cellEls[col] as XmlElement;

    // Preserve w:tcPr (cell formatting) and w:pPr (paragraph formatting)
    const tcPrCol = tc.getElementsByTagNameNS(W_NS, "tcPr");
    const tcPr = tcPrCol.length ? (tcPrCol[0] as XmlElement) : null;

    const parasInCell = tc.getElementsByTagNameNS(W_NS, "p");
    const existingPPrCol = parasInCell.length
      ? (parasInCell[0] as XmlElement).getElementsByTagNameNS(W_NS, "pPr")
      : null;
    const existingPPr =
      existingPPrCol && existingPPrCol.length ? (existingPPrCol[0] as XmlElement) : null;

    // Clear cell, restore tcPr
    while (tc.firstChild) tc.removeChild(tc.firstChild);
    if (tcPr) tc.appendChild(tcPr);

    const newP = createTextParagraph(ownerDoc, newContent);
    if (existingPPr) newP.insertBefore(existingPPr.cloneNode(true), newP.firstChild);
    tc.appendChild(newP);

    return `Updated table[${tableIndex}] row ${row} col ${col} in ${section.section_id}.`;
  } else {
    // ── Mode 2: append row ───────────────────────────────────────────────────
    const { rowValues } = options;
    if (rowCount === 0) throw new Error("Table has no rows to clone");

    const lastRow = rowEls[rowCount - 1] as XmlElement;
    const clonedRow = lastRow.cloneNode(true) as XmlElement;

    const clonedCells = clonedRow.getElementsByTagNameNS(W_NS, "tc");
    const cellsToFill = Math.min(rowValues.length, clonedCells.length);
    for (let i = 0; i < cellsToFill; i++) {
      const tc = clonedCells[i] as XmlElement;
      const paras = tc.getElementsByTagNameNS(W_NS, "p");
      if (!paras.length) continue;
      const p = paras[0] as XmlElement;
      // Remove existing runs, keep w:pPr
      const runs = p.getElementsByTagNameNS(W_NS, "r");
      while (runs.length > 0) p.removeChild(runs[0]);
      // Add new run
      const r = ownerDoc.createElementNS(W_NS, "w:r");
      const t = ownerDoc.createElementNS(W_NS, "w:t");
      t.appendChild(ownerDoc.createTextNode(rowValues[i]!));
      r.appendChild(t);
      p.appendChild(r);
    }

    tbl.appendChild(clonedRow);
    return `Appended row to table[${tableIndex}] in ${section.section_id}: [${rowValues.join(", ")}]`;
  }
}

export function updateSectionBody(
  ownerDoc: XmlDocument,
  paragraphEls: XmlElement[],
  section: Section,
  newContent: string,
  placeholderGraphics?: string | null,
  styleMap?: Map<string, string>
): void {
  if (section.start >= paragraphEls.length) return;
  const anchorPara = paragraphEls[section.start];
  const startBody = isHeadingPara(anchorPara, styleMap) ? section.start + 1 : section.start;
  const end = Math.min(section.end, paragraphEls.length);

  const toRemove: XmlElement[] = [];
  for (let i = startBody; i < end; i++) {
    toRemove.push(paragraphEls[i]);
  }
  const parent = anchorPara.parentNode as XmlElement;
  for (const el of toRemove) {
    el.parentNode?.removeChild(el);
  }

  let body = newContent.trimEnd();
  if (placeholderGraphics) body = `${body}\n\n${placeholderGraphics.trim()}`;

  let ref: XmlElement = anchorPara;
  for (const block of body.split(/\n\n+/)) {
    const line = block.trim();
    if (!line) continue;
    const newP = createTextParagraph(ownerDoc, line);
    insertAfter(parent, newP, ref);
    ref = newP;
  }
}
