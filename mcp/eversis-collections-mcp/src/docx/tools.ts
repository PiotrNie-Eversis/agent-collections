import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod";
import { copyFile, mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import {
  appendSectionBody,
  buildSections,
  countSectionImages,
  detectHeadingLocale,
  readSectionText,
  renderSummaryMd,
  updateSectionBody,
  updateTableCell,
  type Section,
} from "./chapters.js";
import { loadDocx, saveDocx } from "./docx-io.js";

const GRAPHICS_PLACEHOLDER =
  ">>> FOR BA REVIEW: CHECK AND UPDATE DIAGRAM ACCORDING TO RELEASE <<<";

function textResult(text: string) {
  return { content: [{ type: "text" as const, text }] };
}

function findSection(sections: Section[], chapterId: string): Section {
  const cid = chapterId.trim().toLowerCase();
  const s = sections.find((x) => x.section_id.toLowerCase() === cid);
  if (!s) {
    throw new Error(
      `Unknown chapter_id ${JSON.stringify(chapterId)}. Valid: ${sections.map((x) => x.section_id).join(", ")}`
    );
  }
  return s;
}

/** Register .docx chapter tools (same names as legacy eversis-docs MCP servers). */
export function registerDocxTools(server: McpServer): void {
  server.registerTool(
    "generate_summary_map",
    {
      description:
        "Build a markdown table of sections (chapter_id sec-N). Writes *.summary.md next to the doc unless output_md_path is set.",
      inputSchema: {
        docx_path: z.string(),
        output_md_path: z.string().optional(),
      },
    },
    async ({ docx_path, output_md_path }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);
        const md = renderSummaryMd(sections, path.basename(loaded.abs));
        const out = output_md_path
          ? path.resolve(output_md_path)
          : loaded.abs.replace(/\.docx$/i, ".summary.md");
        await mkdir(path.dirname(out), { recursive: true });
        await writeFile(out, md, "utf8");
        return textResult(`Wrote summary map to ${out} (${sections.length} sections).`);
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  server.registerTool(
    "read_chapter",
    {
      description: "Return body text for chapter_id (e.g. sec-0, sec-1) from the .docx.",
      inputSchema: {
        docx_path: z.string(),
        chapter_id: z.string(),
      },
    },
    async ({ docx_path, chapter_id }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);
        const sec = findSection(sections, chapter_id);
        return textResult(readSectionText(loaded.paragraphs, sec, loaded.styleMap));
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  server.registerTool(
    "update_chapter",
    {
      description:
        "Replace section body (excluding heading line) with new_content and save the .docx.",
      inputSchema: {
        docx_path: z.string(),
        chapter_id: z.string(),
        new_content: z.string(),
        requires_graphics_review: z.boolean().optional(),
      },
    },
    async ({
      docx_path,
      chapter_id,
      new_content,
      requires_graphics_review,
    }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);
        const sec = findSection(sections, chapter_id);
        const ph = requires_graphics_review ? GRAPHICS_PLACEHOLDER : null;
        updateSectionBody(loaded.doc, loaded.paragraphs, sec, new_content, ph, loaded.styleMap);
        await saveDocx(loaded);
        return textResult(`Updated ${chapter_id} in ${loaded.abs} and saved.`);
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  server.registerTool(
    "upload_to_sharepoint",
    {
      description:
        "Stub — organisation-specific auth required. Validates docx path exists.",
      inputSchema: { docx_path: z.string() },
    },
    async ({ docx_path }) => {
      try {
        await loadDocx(docx_path); // validates path exists
        return textResult(
          "upload_to_sharepoint is not implemented in this repo. " +
            "Publish manually or extend this MCP with tenant-specific integration."
        );
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  // ── MCP-4: append_chapter ─────────────────────────────────────────────────

  server.registerTool(
    "append_chapter",
    {
      description:
        "Append new content paragraphs to a section WITHOUT removing existing content. " +
        "Preserves tables, images, and existing text. Use for additive edits (TEXT-SAFE or IMAGE-CONTAINS sections). " +
        "For TABLE-CONTAINS sections use update_table_cell instead.",
      inputSchema: {
        docx_path: z.string(),
        chapter_id: z.string(),
        new_content: z.string().describe(
          'Plain text to append. Use "\\n\\n" to separate paragraphs.'
        ),
        requires_graphics_review: z.boolean().optional().describe(
          "When true, inserts a graphics-review placeholder paragraph after the new content."
        ),
      },
    },
    async ({ docx_path, chapter_id, new_content, requires_graphics_review }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);
        const sec = findSection(sections, chapter_id);
        const ph = requires_graphics_review ? GRAPHICS_PLACEHOLDER : null;
        appendSectionBody(loaded.doc, loaded.paragraphs, sec, new_content, ph);
        await saveDocx(loaded);
        // Count paragraphs appended (one per non-empty double-newline block)
        const blockCount = new_content
          .trimEnd()
          .split(/\n\n+/)
          .filter((b) => b.trim()).length;
        const withPh = ph ? blockCount + 1 : blockCount;
        return textResult(
          `Appended to ${chapter_id} in ${loaded.abs}. Added ${withPh} paragraph(s).`
        );
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  // ── MCP-5: list_section_elements ─────────────────────────────────────────

  server.registerTool(
    "list_section_elements",
    {
      description:
        "Return element counts and content_type classification for a section. " +
        "Use before editing to decide which tool is safe: " +
        "TEXT-SAFE → append_chapter, TABLE-CONTAINS → update_table_cell, " +
        "IMAGE-CONTAINS → append_chapter + graphics flag, MIXED → treat as TABLE-CONTAINS.",
      inputSchema: {
        docx_path: z.string(),
        chapter_id: z.string(),
      },
    },
    async ({ docx_path, chapter_id }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);
        const sec = findSection(sections, chapter_id);

        const imageCount = countSectionImages(loaded.body, loaded.paragraphs, sec);
        const text = readSectionText(loaded.paragraphs, sec, loaded.styleMap);

        let contentType: "TEXT-SAFE" | "TABLE-CONTAINS" | "IMAGE-CONTAINS" | "MIXED";
        if (sec.hasTables && sec.hasImages) contentType = "MIXED";
        else if (sec.hasTables) contentType = "TABLE-CONTAINS";
        else if (sec.hasImages) contentType = "IMAGE-CONTAINS";
        else contentType = "TEXT-SAFE";

        const result = {
          chapter_id: sec.section_id,
          heading: sec.title,
          paragraphs: sec.end - sec.start,
          tables: sec.tableCount,
          images: imageCount,
          total_chars: text.length,
          content_type: contentType,
        };
        return textResult(JSON.stringify(result, null, 2));
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  // ── MCP-6: inspect_document ───────────────────────────────────────────────

  server.registerTool(
    "inspect_document",
    {
      description:
        "Pre-flight analysis of a .docx file: BOM detection, heading style locale, " +
        "section count, per-section content_type, and diagnostic warnings. " +
        "Call before the first edit session (especially when plan_status is UNVERIFIED).",
      inputSchema: {
        docx_path: z.string(),
      },
    },
    async ({ docx_path }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);

        const { locale, examples } = detectHeadingLocale(loaded.styleMap);

        let sectionsWithTables = 0;
        let sectionsWithImages = 0;
        const sectionsSummary: Array<{
          chapter_id: string;
          heading: string;
          content_type: string;
          tables?: number;
        }> = [];

        for (const sec of sections) {
          let contentType: "TEXT-SAFE" | "TABLE-CONTAINS" | "IMAGE-CONTAINS" | "MIXED";
          if (sec.hasTables && sec.hasImages) contentType = "MIXED";
          else if (sec.hasTables) contentType = "TABLE-CONTAINS";
          else if (sec.hasImages) contentType = "IMAGE-CONTAINS";
          else contentType = "TEXT-SAFE";

          if (sec.hasTables) sectionsWithTables++;
          if (sec.hasImages) sectionsWithImages++;

          const entry: (typeof sectionsSummary)[number] = {
            chapter_id: sec.section_id,
            heading: sec.title,
            content_type: contentType,
          };
          if (sec.tableCount > 0) entry.tables = sec.tableCount;
          sectionsSummary.push(entry);
        }

        const warnings: string[] = [];
        if (loaded.hasBom) {
          warnings.push("BOM detected — loadDocx strips it automatically");
        }
        if (locale !== "en") {
          warnings.push(
            `Non-English heading styles detected (${examples.join(", ")}) — locale-aware detection active`
          );
        }

        const status: "READY" | "WARNINGS" | "ERROR" =
          warnings.length > 0 ? "WARNINGS" : "READY";

        const result = {
          path: loaded.abs,
          has_bom: loaded.hasBom,
          heading_style_locale: locale,
          heading_style_examples: examples,
          sections_count: sections.length,
          sections_with_tables: sectionsWithTables,
          sections_with_images: sectionsWithImages,
          sections_summary: sectionsSummary,
          warnings,
          status,
        };
        return textResult(JSON.stringify(result, null, 2));
      } catch (e) {
        return textResult(
          JSON.stringify({ error: String(e), status: "ERROR" }, null, 2)
        );
      }
    }
  );

  // ── MCP-7: update_table_cell ─────────────────────────────────────────────

  server.registerTool(
    "update_table_cell",
    {
      description:
        "Edit a table inside a section. " +
        "Mode 1 (default): update a specific cell (row + col + new_content). " +
        "Mode 2: append a new row (action='append_row' + row_values). " +
        "Use list_section_elements first to confirm content_type is TABLE-CONTAINS.",
      inputSchema: {
        docx_path: z.string(),
        chapter_id: z.string(),
        table_index: z.number().int().nonnegative().optional().describe(
          "0-based table index within the section. Defaults to 0."
        ),
        // Mode 1
        row: z.number().int().nonnegative().optional(),
        col: z.number().int().nonnegative().optional(),
        new_content: z.string().optional(),
        // Mode 2
        action: z.literal("append_row").optional(),
        row_values: z.array(z.string()).optional().describe(
          "Cell values for the new row (one per column). Used with action='append_row'."
        ),
      },
    },
    async ({
      docx_path,
      chapter_id,
      table_index,
      row,
      col,
      new_content,
      action,
      row_values,
    }) => {
      try {
        const loaded = await loadDocx(docx_path);
        const sections = buildSections(loaded.paragraphs, loaded.body, loaded.styleMap);
        const sec = findSection(sections, chapter_id);
        const tblIdx = table_index ?? 0;

        let resultMsg: string;
        if (action === "append_row") {
          if (!row_values || row_values.length === 0) {
            return textResult(
              JSON.stringify({ error: "row_values is required for action='append_row'" })
            );
          }
          resultMsg = updateTableCell(
            loaded.doc,
            loaded.body,
            loaded.paragraphs,
            sec,
            tblIdx,
            { action: "append_row", rowValues: row_values }
          );
        } else {
          if (row === undefined || col === undefined || new_content === undefined) {
            return textResult(
              JSON.stringify({
                error: "row, col, and new_content are required when action is not 'append_row'",
              })
            );
          }
          resultMsg = updateTableCell(
            loaded.doc,
            loaded.body,
            loaded.paragraphs,
            sec,
            tblIdx,
            { row, col, newContent: new_content }
          );
        }

        await saveDocx(loaded);
        return textResult(resultMsg);
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );

  // ── MCP-8: backup_docx ───────────────────────────────────────────────────

  server.registerTool(
    "backup_docx",
    {
      description:
        "Create a timestamped binary backup copy of a .docx file. " +
        "Always call this BEFORE the first modification in a session. Log the backup path.",
      inputSchema: {
        docx_path: z.string(),
        backup_dir: z.string().optional().describe(
          "Destination directory for the backup. Defaults to a 'backups/' subfolder next to the source file."
        ),
      },
    },
    async ({ docx_path, backup_dir }) => {
      try {
        const abs = path.resolve(docx_path);
        const ext = path.extname(abs);
        const base = path.basename(abs, ext);
        const dir = backup_dir
          ? path.resolve(backup_dir)
          : path.join(path.dirname(abs), "backups");
        await mkdir(dir, { recursive: true });
        // Format: YYYY-MM-DD-HHmmss
        const now = new Date();
        const ts = now
          .toISOString()
          .replace("T", "-")
          .replace(/:/g, "")
          .slice(0, 17);
        const dest = path.join(dir, `${base}.backup-${ts}${ext}`);
        await copyFile(abs, dest);
        return textResult(`Backup created: ${dest}`);
      } catch (e) {
        return textResult(JSON.stringify({ error: String(e) }, null, 2));
      }
    }
  );
}
