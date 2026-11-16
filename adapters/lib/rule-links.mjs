/**
 * Rule-body link rewrite shared by the adapter generators (Cursor, Claude, Pi).
 *
 * Rule bodies under .ai/rules/** are copied into other locations
 * (.cursor/rules/*.mdc, CLAUDE.md, .claude/rules/*.md, .pi/skills/<id>/SKILL.md).
 * A relative Markdown link such as `[x](./spec-driven-development.md)` only
 * resolves next to the source file, so it breaks in every emitted copy.
 *
 * rewriteRuleLinks() resolves each relative link (`./` or `../`) against the
 * rule's source path and asks the adapter for the emitted link of that target:
 *   - a mapped rule  -> the link the adapter returns (its emitted sibling);
 *                       a source `#fragment` is kept and replaces any
 *                       `#anchor` the returned link carries (the target's
 *                       headings are emitted with it, so the heading anchor
 *                       still exists); without a source fragment the
 *                       returned `#anchor` is kept
 *   - anything else  -> the link text followed by the prefix-aware SSOT path
 *                       as inline code, so it never becomes a broken link
 *   - a target that escapes the repository root -> the link text only
 * Link forms handled: `[a](./x.md)`, `[a](./x.md "title")` (the title is kept
 * on a mapped link) and `[a](<./x.md>)` (the angle brackets are kept on a
 * mapped link).
 * Absolute URLs, `#anchor`-only links, images, inline code spans and fenced
 * code blocks are left unchanged.
 * Relative-looking links the rewrite cannot handle (link text with nested
 * brackets, or a bare `x.md` target without `./`) are left unchanged and
 * reported through ctx.warn; generation does not fail.
 *
 * Pure string processing: no file or network access. Zero npm dependencies.
 */

import path from "node:path";

const FENCE_RE = /^ {0,3}(`{3,}|~{3,})/;
// Inline code span (kept as-is) or a Markdown link that is not an image.
// The destination is either `<...>` or a plain token, optionally followed by
// a "title" / 'title'.
const SEGMENT_RE =
  /(`+)[^`]*?\1|(?<!!)\[([^\]\n]*)\]\(\s*(<[^>\n]*>|[^)\s]+)(\s+"[^"\n]*"|\s+'[^'\n]*')?\s*\)/g;
// Code spans, images and every simple link: removed before looking for
// leftover relative link destinations (e.g. link text with nested brackets).
const HANDLED_RE = /(`+)[^`]*?\1|!?\[[^\]\n]*\]\([^)\n]*\)/g;
const LEFTOVER_RE = /\]\(\s*<?(\.\.?\/[^)\s>]*)/g;
const SCHEME_RE = /^[a-z][a-z0-9+.-]*:/i;

function isRelativeTarget(target) {
  return target.startsWith("./") || target.startsWith("../");
}

// A bare relative target such as `x.md` or `dir/x.md#a`: it resolves to a
// Markdown file next to the source but is not rewritten.
function isBareMarkdownTarget(target) {
  if (SCHEME_RE.test(target) || target.startsWith("#") || target.startsWith("/")) {
    return false;
  }
  const pathPart = target.split("#")[0].split("?")[0];
  return pathPart.endsWith(".md");
}

/**
 * Rewrite relative Markdown links in a rule body for its emitted location.
 *
 * @param {string} body - rule body (Markdown) as read from the SSOT source
 * @param {{
 *   sourceRel: string,
 *   resolveTarget: (targetSourceRel: string) => string | null,
 *   frameworkPrefix?: string,
 *   warn?: (message: string) => void,
 * }} ctx
 *   sourceRel - repo-relative POSIX path of the rule source
 *     (e.g. ".ai/rules/orchestration/agent-core.md")
 *   resolveTarget - returns the emitted link for a repo-relative target path
 *     when it is a mapped rule, or null otherwise
 *   frameworkPrefix - framework location in the consumer root ("" = self-host)
 *   warn - called with a message (source file and link) for each
 *     relative-looking link left unchanged; default console.warn
 * @returns {string}
 */
export function rewriteRuleLinks(body, ctx) {
  const { sourceRel, resolveTarget } = ctx;
  const frameworkPrefix = (ctx.frameworkPrefix ?? "").replace(/\/+$/, "");
  const sourceDir = path.posix.dirname(sourceRel);
  const warn = ctx.warn ?? ((message) => console.warn(message));
  const warnUntouched = (link) =>
    warn(`rule-links: ${sourceRel}: relative link left unchanged: ${link}`);

  const rewriteLink = (match, text, rawTarget, title = "") => {
    const angled = rawTarget.startsWith("<");
    const target = angled ? rawTarget.slice(1, -1).trim() : rawTarget;
    if (!isRelativeTarget(target)) {
      if (isBareMarkdownTarget(target)) warnUntouched(match);
      return match;
    }

    const hashIdx = target.indexOf("#");
    const pathPart = hashIdx === -1 ? target : target.slice(0, hashIdx);
    const fragment = hashIdx === -1 ? "" : target.slice(hashIdx);

    const resolved = path.posix.normalize(path.posix.join(sourceDir, pathPart));
    if (resolved === ".." || resolved.startsWith("../")) {
      return text;
    }

    const mapped = resolveTarget(resolved);
    if (mapped) {
      const mappedHash = mapped.indexOf("#");
      const link =
        mappedHash === -1
          ? `${mapped}${fragment}`
          : fragment
            ? `${mapped.slice(0, mappedHash)}${fragment}`
            : mapped;
      return `[${text}](${angled ? `<${link}>` : link}${title})`;
    }

    const ssot = frameworkPrefix ? `${frameworkPrefix}/${resolved}` : resolved;
    return `${text} (\`${ssot}${fragment}\`)`;
  };

  const lines = body.split("\n");
  let fence = null;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const fenceMatch = FENCE_RE.exec(line);
    if (fence) {
      if (
        fenceMatch &&
        fenceMatch[1][0] === fence[0] &&
        fenceMatch[1].length >= fence.length &&
        line.trim() === fenceMatch[1]
      ) {
        fence = null;
      }
      continue;
    }
    if (fenceMatch) {
      fence = fenceMatch[1];
      continue;
    }
    for (const leftover of line.replace(HANDLED_RE, "").matchAll(LEFTOVER_RE)) {
      warnUntouched(`](${leftover[1]})`);
    }
    lines[i] = line.replace(SEGMENT_RE, (match, ticks, text, target, title) =>
      ticks ? match : rewriteLink(match, text, target, title),
    );
  }
  return lines.join("\n");
}
