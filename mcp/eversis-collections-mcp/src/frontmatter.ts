export type SkillFrontmatter = {
  name?: string;
  description?: string;
  "user-invocable"?: boolean | string;
  /** Legacy spelling, accepted for one release (removal: AC-175). */
  "user-invokable"?: boolean | string;
};

const FRONTMATTER_RE = /^---\r?\n([\s\S]*?)\r?\n---/;

/** Minimal YAML-ish parse for skill frontmatter (key: value or key: "quoted"). */
export function parseSkillFrontmatter(raw: string): {
  frontmatter: SkillFrontmatter;
  bodyStartLine: number;
} {
  const m = raw.match(FRONTMATTER_RE);
  if (!m) {
    return { frontmatter: {}, bodyStartLine: 1 };
  }
  const block = m[1] ?? "";
  const fm: SkillFrontmatter = {};
  for (const line of block.split(/\r?\n/)) {
    const kv = line.match(/^(\s*)([a-zA-Z0-9_-]+)\s*:\s*(.*)$/);
    if (!kv) continue;
    const indent = kv[1];
    const key = kv[2];
    let val = kv[3].trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    if (key === "name") fm.name = val;
    else if (key === "description") fm.description = val;
    else if (
      (key === "user-invocable" || key === "user-invokable") &&
      indent === ""
    ) {
      // Only top-level keys count; a nested key (e.g. under metadata:) is ignored.
      if (val === "true" || val === "True") fm[key] = true;
      else if (val === "false" || val === "False") fm[key] = false;
      else fm[key] = val;
    }
  }
  const linesBefore = raw.slice(0, m.index! + m[0].length).split(/\r?\n/);
  const bodyStartLine = linesBefore.length + 1;
  return { frontmatter: fm, bodyStartLine };
}

/**
 * Effective `/` menu flag of a skill.
 * Precedence: `user-invocable`, else legacy `user-invokable`, else `true`.
 * A value that is not a boolean after parsing (e.g. `yes`) counts as the default `true`,
 * so only an explicit `false` hides the skill.
 */
export function resolveUserInvocable(fm: SkillFrontmatter): boolean {
  const value =
    fm["user-invocable"] !== undefined ? fm["user-invocable"] : fm["user-invokable"];
  return value !== false;
}
