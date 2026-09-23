import path from "node:path";

/**
 * Resolve a docx-related path against the consumer workspace root.
 * Absolute inputs stay absolute (path.resolve). Relative inputs join onto
 * workspaceRoot and are rejected when they escape that root.
 */
export function resolveDocxPath(docxPath: string, workspaceRoot: string): string {
  if (path.isAbsolute(docxPath)) {
    return path.resolve(docxPath);
  }

  const root = path.resolve(workspaceRoot);
  const resolved = path.resolve(root, docxPath);
  const rel = path.relative(root, resolved);
  if (rel === ".." || rel.startsWith(`..${path.sep}`) || path.isAbsolute(rel)) {
    throw new Error(`docx path escapes workspace root: ${docxPath}`);
  }
  return resolved;
}

/**
 * Resolve the summary-map output path. When outputMdPath is set, resolve it
 * like any other docx-related path; otherwise replace .docx with .summary.md
 * beside the already-resolved document.
 */
export function resolveSummaryOutputPath(
  outputMdPath: string | undefined,
  resolvedDocxAbs: string,
  workspaceRoot: string
): string {
  if (outputMdPath !== undefined) {
    return resolveDocxPath(outputMdPath, workspaceRoot);
  }
  return resolvedDocxAbs.replace(/\.docx$/i, ".summary.md");
}
