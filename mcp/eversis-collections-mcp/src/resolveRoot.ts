import fs from "node:fs";
import path from "node:path";

/**
 * Walk upward from `startDir` until `.ai/skills` exists.
 * Falls back to env when walk-up finds nothing:
 *   AGENT_COLLECTIONS_HOME (canonical)
 */
export function findRepoRoot(startDir: string): string {
  let dir = path.resolve(startDir);
  for (;;) {
    const skillsPath = path.join(dir, ".ai", "skills");
    if (fs.existsSync(skillsPath) && fs.statSync(skillsPath).isDirectory()) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) {
      break;
    }
    dir = parent;
  }

  const home = process.env["AGENT_COLLECTIONS_HOME"];
  if (home) {
    const resolved = path.resolve(home);
    const skillsPath = path.join(resolved, ".ai", "skills");
    if (fs.existsSync(skillsPath) && fs.statSync(skillsPath).isDirectory()) {
      return resolved;
    }
    throw new Error(
      `AGENT_COLLECTIONS_HOME=${home} does not contain .ai/skills`,
    );
  }

  throw new Error(
    "Could not find repository root (directory with .ai/skills). " +
      "Set AGENT_COLLECTIONS_HOME to the agent-collections checkout path.",
  );
}

export function assertUnderRoot(repoRoot: string, candidate: string): string {
  const resolved = path.resolve(candidate);
  const root = path.resolve(repoRoot);
  if (!resolved.startsWith(root + path.sep) && resolved !== root) {
    throw new Error(`Path escapes repository root: ${candidate}`);
  }
  return resolved;
}
