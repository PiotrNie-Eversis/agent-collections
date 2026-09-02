import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

// Consumer-owned domain-context tools (Question 3/6/10/12,
// global-domain-context-ssot.research.md). Unlike eversis_skills_* (framework-owned,
// resolved from AGENT_COLLECTIONS_HOME), these read/write the CONSUMER project's own
// docs/context/, mounted separately as /workspace (docker-compose.yml) because the
// framework mount (/repo) never contains the consumer repo's files.

export type ContextSource = "project" | "global";

export type ContextComponent = {
  component: string;
  summary: string;
  source: ContextSource;
};

export type ContextEntry = {
  component: string;
  source: ContextSource;
  path: string;
  content: string;
  staleness?: { upToDate: boolean; localSplitSha?: string; remoteHeadSha?: string; daysSinceLastSync?: number };
};

type SsotSelection = {
  externalSsotRepo: string | null;
  projectContextPath: string;
  globalContextPath: string;
};

const SELECTION_REL = path.join(".agent-collections", "install-selection.json");

function hasInstallSelection(dir: string): boolean {
  return fs.existsSync(path.join(dir, SELECTION_REL));
}

/** Injected seam for tests — production callers use `resolveWorkspaceRoot()`. */
export function resolveWorkspaceRootFrom(
  env: NodeJS.Dict<string | undefined>,
  workspaceMount: string,
  cwd: string
): string {
  const envRoot = env["CONSUMER_PROJECT_ROOT"];
  if (envRoot && hasInstallSelection(envRoot)) return envRoot;
  if (hasInstallSelection(workspaceMount)) return workspaceMount;
  return cwd;
}

export function resolveWorkspaceRoot(): string {
  return resolveWorkspaceRootFrom(process.env, "/workspace", process.cwd());
}

function readSelection(workspaceRoot: string): SsotSelection {
  const selPath = path.join(workspaceRoot, SELECTION_REL);
  if (!fs.existsSync(selPath)) {
    throw new Error(
      `${SELECTION_REL} not found under ${workspaceRoot} — run setup-agent-collections.sh first.`
    );
  }
  const raw = JSON.parse(fs.readFileSync(selPath, "utf8"));
  const ssot = raw.ssot ?? {};
  return {
    externalSsotRepo: ssot.externalSsotRepo ?? null,
    projectContextPath: ssot.projectContextPath ?? "docs/context/project/",
    globalContextPath: ssot.globalContextPath ?? "docs/context/global/",
  };
}

/** Minimal frontmatter get/set — round-trips unknown fields, only touches the given key. */
function upsertFrontmatterField(raw: string, key: string, value: string): string {
  const m = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!m) {
    return `---\n${key}: ${value}\n---\n\n${raw}`;
  }
  const block = m[1] ?? "";
  const lines = block.split(/\r?\n/);
  const lineRe = new RegExp(`^${key}\\s*:`);
  let found = false;
  const nextLines = lines.map((line) => {
    if (lineRe.test(line)) {
      found = true;
      return `${key}: ${value}`;
    }
    return line;
  });
  if (!found) nextLines.push(`${key}: ${value}`);
  const newBlock = nextLines.join("\n");
  return raw.slice(0, m.index!) + `---\n${newBlock}\n---\n` + raw.slice(m.index! + m[0].length);
}

function touchLastConsulted(filePath: string): void {
  try {
    const raw = fs.readFileSync(filePath, "utf8");
    const updated = upsertFrontmatterField(raw, "last_consulted", new Date().toISOString());
    fs.writeFileSync(filePath, updated);
  } catch {
    // Non-fatal — staleness/last_consulted bookkeeping must never block a read.
  }
}

/** First INDEX column is a bare id; strip `[text](url)` so markdown-link rows still resolve. */
function stripIndexComponentName(cell: string): string {
  const link = cell.match(/^\[([^\]]+)\]\([^)]+\)$/);
  return (link ? link[1]! : cell).trim();
}

function readIndexComponents(indexPath: string, source: ContextSource): ContextComponent[] {
  if (!fs.existsSync(indexPath)) return [];
  const raw = fs.readFileSync(indexPath, "utf8");
  const rows: ContextComponent[] = [];
  for (const line of raw.split(/\r?\n/)) {
    // Table row: | component | one-line summary |
    const m = line.match(/^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$/);
    if (!m) continue;
    const component = stripIndexComponentName(m[1]!.trim());
    const summary = m[2]!.trim();
    if (component === "Component" || component.startsWith("---")) continue;
    rows.push({ component, summary, source });
  }
  return rows;
}

export function listContext(): ContextComponent[] {
  const root = resolveWorkspaceRoot();
  const sel = readSelection(root);
  const project = readIndexComponents(path.join(root, sel.projectContextPath, "INDEX.md"), "project");
  const global_ = readIndexComponents(path.join(root, sel.globalContextPath, "INDEX.md"), "global");
  const seen = new Set(project.map((c) => c.component));
  return [...project, ...global_.filter((c) => !seen.has(c.component))];
}

function computeStaleness(
  root: string,
  globalContextPathAbs: string,
  externalSsotRepo: string,
  branch = "main"
): ContextEntry["staleness"] {
  try {
    const relPrefix = path.relative(root, globalContextPathAbs);
    const log = execFileSync(
      "git",
      ["-C", root, "log", "--grep=git-subtree-split", "-1", "--pretty=%B", "--", relPrefix],
      { encoding: "utf8" }
    );
    const splitMatch = log.match(/git-subtree-split:\s*([0-9a-f]{7,40})/);
    const localSplitSha = splitMatch?.[1];
    const commitDateRaw = execFileSync(
      "git",
      ["-C", root, "log", "-1", "--format=%cI", "--", relPrefix],
      { encoding: "utf8" }
    ).trim();
    const daysSinceLastSync = commitDateRaw
      ? Math.floor((Date.now() - new Date(commitDateRaw).getTime()) / 86_400_000)
      : undefined;

    let remoteHeadSha: string | undefined;
    try {
      const lsRemote = execFileSync("git", ["ls-remote", externalSsotRepo, branch], {
        encoding: "utf8",
        timeout: 5000,
      });
      remoteHeadSha = lsRemote.split(/\s+/)[0];
    } catch {
      // Remote unreachable — report what we know locally, don't fail the read.
    }

    return {
      upToDate: !!localSplitSha && !!remoteHeadSha && localSplitSha === remoteHeadSha,
      localSplitSha,
      remoteHeadSha,
      daysSinceLastSync,
    };
  } catch {
    return undefined;
  }
}

export function getContext(component: string): ContextEntry {
  if (component.includes("..") || component.includes("/")) {
    throw new Error("Invalid component name");
  }
  const root = resolveWorkspaceRoot();
  const sel = readSelection(root);

  const projectFile = path.join(root, sel.projectContextPath, component, "index.md");
  if (fs.existsSync(projectFile)) {
    touchLastConsulted(projectFile);
    return {
      component,
      source: "project",
      path: path.relative(root, projectFile),
      content: fs.readFileSync(projectFile, "utf8"),
    };
  }

  const globalDirAbs = path.join(root, sel.globalContextPath);
  const globalFile = path.join(globalDirAbs, component, "index.md");
  if (fs.existsSync(globalFile)) {
    touchLastConsulted(globalFile);
    const staleness = sel.externalSsotRepo
      ? computeStaleness(root, globalDirAbs, sel.externalSsotRepo)
      : undefined;
    return {
      component,
      source: "global",
      path: path.relative(root, globalFile),
      content: fs.readFileSync(globalFile, "utf8"),
      staleness,
    };
  }

  throw new Error(
    `No docs/context entry for component "${component}" in project or global. ` +
      `Run eversis_context_list to see what exists.`
  );
}

export function syncContext(branch = "main"): { synced: boolean; message: string } {
  const root = resolveWorkspaceRoot();
  const sel = readSelection(root);
  if (!sel.externalSsotRepo) {
    return { synced: false, message: "No externalSsotRepo configured in install-selection.json — nothing to sync." };
  }
  try {
    execFileSync(
      "git",
      ["-C", root, "subtree", "pull", "--prefix", sel.globalContextPath, sel.externalSsotRepo, branch, "--squash"],
      { encoding: "utf8" }
    );
    return { synced: true, message: `Synced ${sel.globalContextPath} from ${sel.externalSsotRepo} (${branch}).` };
  } catch (e) {
    return { synced: false, message: e instanceof Error ? e.message : String(e) };
  }
}
