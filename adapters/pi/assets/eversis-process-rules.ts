/**
 * Agent Collections process rules for Pi (AC-134).
 *
 * Shipped by the Agent Collections Pi adapter (source:
 * adapters/pi/assets/eversis-process-rules.ts, copied to
 * .pi/extensions/eversis-process-rules.ts by adapters/pi/generate.mjs, which
 * fills in PROCESS_SKILL_IDS from adapters/pi/rule-map.yaml).
 *
 * .pi/APPEND_SYSTEM.md is a small always-on core. This extension decides per run
 * whether the process rules are added on top of it:
 * - Active after an eversis-* prompt command, for the rest of the session. The
 *   state is saved with pi.appendEntry and restored in session_start, so it
 *   survives --continue, /reload and compaction. A new session starts inactive.
 * - Active at session start when the pointer file names a plan that still has
 *   an open box. A successful Pi edit or write of a *.plan.md under docs/specs/
 *   updates the pointer. It does not turn the rules on in the running session.
 * - When active, before_agent_start adds the rules as a section. Pi hands over
 *   an empty sections object on every run, so leaving the section out is enough
 *   to remove it.
 * - When inactive, before_agent_start removes eversis-* entries from the skill
 *   listing, in place. Consumer skills stay listed, and /skill:<name> still
 *   works for every skill.
 *
 * Rule text comes only from the generated eversis-rule-* skills, located through
 * import.meta.url; it never comes from a plan file. The pointer file is untrusted
 * input: it counts only when it resolves to a docs/specs plan inside the project,
 * and it is cleared otherwise. A command queued while the agent is streaming does
 * not reach before_agent_start until the next run, and the notice says so.
 *
 * Pi-only: Cursor and Claude Code keep their rules always on.
 * No network or shell. File writes stay under .pi/eversis-state/: the folder is
 * refused when it is a symlink or resolves outside the project, and a symlink
 * inside it is replaced or removed, never followed. This guards against planted
 * symlinks; it is not atomic against another process running as the same user at
 * the same moment.
 * Type-only import from Pi — no runtime dependency.
 */

import { randomUUID } from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

/** Filled in by the generator. Empty in the raw asset; see register(). */
export const PROCESS_SKILL_IDS: readonly string[] = [/* eversis:process-skill-ids */];

export const ENTRY_TYPE = "eversis-process-rules";
export const SECTION_KEY = "eversis_process_rules";
export const STATE_DIR_REL = ".pi/eversis-state";
export const POINTER_REL = `${STATE_DIR_REL}/active-plan.json`;
export const NAMING_LINE =
  "Rule id naming: a rule id `eversis-<x>` is the skill `eversis-rule-<x>` when that skill exists.";

const SKILLS_DIR_REL = ".pi/skills";
const FRAMEWORK_SKILL_PREFIX = "eversis-";
const PLAN_PATH_RE = /^docs\/specs\/(?:[^/]+\/)*[^/]+\.plan\.md$/;
const OPEN_BOX_RE = /^\s*[-*+]\s+\[ \]/m;
const COMMAND_RE = /^\/(eversis-[a-z0-9]+(?:-[a-z0-9]+)*)(?=\s|$)/;

/** What turned the rules on. */
export type Trigger =
  | { kind: "command"; name: string; queued: boolean }
  | { kind: "restored"; name: string }
  | { kind: "plan"; plan: string };

/** The parts of Pi's events this extension reads. */
interface InputEvent {
  text: string;
  streamingBehavior?: unknown;
}
interface BeforeAgentStartEvent {
  systemPromptOptions?: {
    sections?: Record<string, string>;
    skills?: Array<{ name?: unknown }>;
  };
}
interface ToolResultEvent {
  toolName: string;
  input?: { path?: unknown };
  isError?: boolean;
}
interface SessionStartEvent {
  reason?: string;
}
interface BranchEntry {
  type?: string;
  customType?: string;
  data?: { trigger?: unknown };
}

export interface ProcessRulesConfig {
  /** Skill ids of the process bundle, in order. */
  skillIds: readonly string[];
  /** Folder that holds .pi/. */
  root: string;
  /** Home directory for "~" tool paths. */
  home: string;
}

/**
 * The command name when the raw input text is an eversis-* prompt command Pi
 * knows, else null. There is no trimming: Pi expands a prompt only when the text
 * starts with "/", so " /eversis-implement" is not a command. Pure.
 */
export function matchProcessCommand(
  text: string,
  commands: ReadonlyArray<{ name?: string; source?: string }>,
): string | null {
  const name = COMMAND_RE.exec(text)?.[1];
  if (!name) return null;
  return commands.some((c) => c.name === name && c.source === "prompt") ? name : null;
}

/** True when markdown text has at least one unchecked task box. Pure. */
export function hasOpenBox(text: string): boolean {
  return OPEN_BOX_RE.test(text);
}

/** True for a clean relative path to a *.plan.md under docs/specs/. Pure. */
export function isPlanPath(value: unknown): value is string {
  if (typeof value !== "string" || value.includes("\0") || value.includes("\\")) return false;
  return PLAN_PATH_RE.test(value) && path.posix.normalize(value) === value;
}

/** The plan path in the pointer file's text, or null when it is not valid. Pure. */
export function parsePointer(text: string): string | null {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    return null;
  }
  const plan = (parsed as { plan?: unknown } | null)?.plan;
  return isPlanPath(plan) ? plan : null;
}

/** Removes a leading "@", expands "~", then resolves against cwd. Pure. */
export function normalizeToolPath(toolPath: string, cwd: string, home: string): string {
  const bare = toolPath.startsWith("@") ? toolPath.slice(1) : toolPath;
  if (bare === "~") return home;
  if (bare.startsWith("~/")) return path.join(home, bare.slice(2));
  return path.resolve(cwd, bare);
}

/** Removes a leading front-matter block and the GENERATED marker. Pure. */
export function stripFrontMatter(text: string): string {
  const unix = text.replace(/\r\n/g, "\n");
  const end = unix.startsWith("---\n") ? unix.indexOf("\n---", 3) : -1;
  const body = end === -1 ? unix : unix.slice(end + 4);
  return body.replace(/<!--\s*GENERATED[^>]*-->\n?/, "").trim();
}

/** The section text: the naming line, then each rule body. Pure. */
export function buildSection(bodies: readonly string[]): string {
  return [NAMING_LINE, ...bodies].join("\n\n---\n\n");
}

/** Removes eversis-* entries from the listing in place; returns how many. */
export function removeFrameworkSkills(skills: Array<{ name?: unknown }>): number {
  let removed = 0;
  for (let i = skills.length - 1; i >= 0; i--) {
    const name = skills[i]?.name;
    if (typeof name === "string" && name.startsWith(FRAMEWORK_SKILL_PREFIX)) {
      skills.splice(i, 1);
      removed++;
    }
  }
  return removed;
}

/** The trigger saved on this branch, or null. The last entry wins. Pure. */
export function restoredTrigger(entries: readonly BranchEntry[]): string | null {
  for (let i = entries.length - 1; i >= 0; i--) {
    const entry = entries[i];
    if (entry?.type !== "custom" || entry.customType !== ENTRY_TYPE) continue;
    const trigger = entry.data?.trigger;
    return typeof trigger === "string" ? trigger : "an earlier command";
  }
  return null;
}

/** Text of the activation notice. Pure. */
export function activationNotice(trigger: Trigger): string {
  const prefix = "Agent Collections process rules on";
  switch (trigger.kind) {
    case "command":
      return trigger.queued
        ? `${prefix} after /${trigger.name}. The agent is busy, so the rules start with the next run.`
        : `${prefix}: /${trigger.name}.`;
    case "restored":
      return `${prefix}: restored from this session (${trigger.name}).`;
    case "plan":
      return `${prefix}: active plan ${trigger.plan}. If that work is abandoned, delete ${POINTER_REL}.`;
  }
}

function realpathOrNull(target: string): string | null {
  try {
    return fs.realpathSync(target);
  } catch {
    return null;
  }
}

/** Real path of target relative to the real root, with "/" separators, or null. */
function relativeToRoot(root: string, target: string): string | null {
  const realRoot = realpathOrNull(root);
  const realTarget = realpathOrNull(target);
  if (!realRoot || !realTarget) return null;
  return path.relative(realRoot, realTarget).split(path.sep).join("/");
}

/**
 * The value to store in the pointer for a file a tool just edited, or null when
 * it is not a plan in this project. Runs after the tool, so the file exists.
 * Comparing real paths keeps a symlinked cwd or root from hiding a match.
 */
export function pointerForToolPath(
  toolPath: string,
  cwd: string,
  root: string,
  home: string,
): string | null {
  const rel = relativeToRoot(root, normalizeToolPath(toolPath, cwd, home));
  return isPlanPath(rel) ? rel : null;
}

/** True when plan is a plan file inside the project and has an open box. */
export function isActivePlan(root: string, plan: string): boolean {
  const abs = path.join(root, plan);
  if (!isPlanPath(relativeToRoot(root, abs))) return false;
  try {
    return hasOpenBox(fs.readFileSync(abs, "utf8"));
  } catch {
    return false;
  }
}

function lstatOrNull(target: string): fs.Stats | null {
  try {
    return fs.lstatSync(target);
  } catch {
    return null;
  }
}

/**
 * Why the state folder must not be used, or null when it may be. The folder may
 * not exist yet. Its parent is checked by real path, and the folder itself must
 * not be a symlink, so together its real path stays inside the real project root.
 */
function stateDirRefusal(root: string): string | null {
  const stateDir = path.join(root, STATE_DIR_REL);
  const parent = relativeToRoot(root, path.dirname(stateDir));
  if (parent === null || parent === ".." || parent.startsWith("../") || path.isAbsolute(parent)) {
    return `${STATE_DIR_REL} is outside the project`;
  }
  const stat = lstatOrNull(stateDir);
  if (stat?.isSymbolicLink()) return `${STATE_DIR_REL} is a symlink`;
  if (stat && !stat.isDirectory()) return `${STATE_DIR_REL} is not a folder`;
  return null;
}

/** Writes through a new temp file and a rename, so a symlink at target is replaced, not followed. */
function replaceFile(target: string, text: string): void {
  const temp = `${target}.${randomUUID()}.tmp`;
  try {
    fs.writeFileSync(temp, text, { encoding: "utf8", flag: "wx" });
    fs.renameSync(temp, target);
  } catch (error) {
    fs.rmSync(temp, { force: true });
    throw error;
  }
}

/**
 * Saves the pointer. The folder ignores itself, so consumers change no .gitignore.
 * Throws, before writing anything, when the state folder is refused.
 */
export function writePointer(root: string, plan: string): void {
  const stateDir = path.join(root, STATE_DIR_REL);
  fs.mkdirSync(path.dirname(stateDir), { recursive: true });
  const refusal = stateDirRefusal(root);
  if (refusal) throw new Error(refusal);
  fs.mkdirSync(stateDir, { recursive: true });
  replaceFile(path.join(stateDir, ".gitignore"), "*\n");
  replaceFile(path.join(root, POINTER_REL), `${JSON.stringify({ plan })}\n`);
}

/**
 * The plan the pointer names, if it is still active. Otherwise clears the pointer.
 * A refused state folder counts as no pointer: nothing is read or removed through
 * it. A pointer that is not a regular file is not read; clearing removes only the
 * entry in the state folder, so a symlink's target stays.
 */
export function readActivePlan(root: string): string | null {
  if (stateDirRefusal(root)) return null;
  const pointer = path.join(root, POINTER_REL);
  const stat = lstatOrNull(pointer);
  if (!stat) return null;
  let text = "";
  if (stat.isFile()) {
    try {
      text = fs.readFileSync(pointer, "utf8");
    } catch {
      return null;
    }
  }
  const plan = parsePointer(text);
  if (plan && isActivePlan(root, plan)) return plan;
  try {
    fs.rmSync(pointer, { force: true });
  } catch {
    // Unreadable as a plan either way; the next session tries again.
  }
  return null;
}

function notify(ctx: ExtensionContext, message: string, type: "info" | "warning"): void {
  if (ctx.hasUI) ctx.ui.notify(message, type);
}

/** Wires the handlers. Separate from the default export so tests can pass a config. */
export function register(pi: ExtensionAPI, config: ProcessRulesConfig): void {
  const { skillIds, root, home } = config;
  let active = false;
  let persisted = false;
  let section: string | null = null;
  const warned = new Set<string>();
  // session_start can fire twice for one start; one notice is enough.
  let lastStartNotice: string | null = null;

  const warnOnce = (ctx: ExtensionContext, key: string, message: string): void => {
    if (warned.has(key)) return;
    warned.add(key);
    notify(ctx, message, "warning");
  };

  const loadSection = (ctx: ExtensionContext): string | null => {
    if (section !== null) return section || null;
    const bodies: string[] = [];
    for (const id of skillIds) {
      const skillPath = path.join(root, SKILLS_DIR_REL, id, "SKILL.md");
      try {
        bodies.push(stripFrontMatter(fs.readFileSync(skillPath, "utf8")));
      } catch {
        warnOnce(ctx, skillPath, `Agent Collections process rules: ${id} not found (${skillPath}). Continuing without it.`);
      }
    }
    section = bodies.length > 0 ? buildSection(bodies) : "";
    return section || null;
  };

  pi.on("session_start", (event: SessionStartEvent, ctx: ExtensionContext) => {
    const restored = restoredTrigger(ctx.sessionManager.getBranch() as BranchEntry[]);
    const plan = readActivePlan(root);
    persisted = restored !== null;
    active = restored !== null || plan !== null;

    let trigger: Trigger | null = null;
    if (restored !== null) trigger = { kind: "restored", name: restored };
    else if (plan !== null) trigger = { kind: "plan", plan };
    if (!trigger) return;
    const message = activationNotice(trigger);
    const noticeKey = `${event.reason ?? ""}:${message}`;
    if (noticeKey === lastStartNotice) return;
    lastStartNotice = noticeKey;
    notify(ctx, message, "info");
  });

  pi.on("input", (event: InputEvent, ctx: ExtensionContext) => {
    const name = matchProcessCommand(event.text, pi.getCommands());
    if (name) {
      if (!persisted) {
        pi.appendEntry(ENTRY_TYPE, { trigger: `/${name}` });
        persisted = true;
      }
      if (!active) {
        active = true;
        const queued = Boolean(event.streamingBehavior) || !ctx.isIdle();
        notify(ctx, activationNotice({ kind: "command", name, queued }), "info");
      }
    }
    return { action: "continue" as const };
  });

  pi.on("before_agent_start", (event: BeforeAgentStartEvent, ctx: ExtensionContext) => {
    const options = event.systemPromptOptions;
    if (!active) {
      if (Array.isArray(options?.skills)) removeFrameworkSkills(options.skills);
      return;
    }
    const sections = options?.sections;
    if (!sections || typeof sections !== "object") {
      warnOnce(ctx, "sections", "Agent Collections process rules: this Pi has no prompt sections, so the rules are not loaded. Pi 1.5.0 or later is required.");
      return;
    }
    const text = loadSection(ctx);
    if (text) sections[SECTION_KEY] = text;
  });

  // tool_result, not tool_call: a failed or blocked edit must change nothing.
  pi.on("tool_result", (event: ToolResultEvent, ctx: ExtensionContext) => {
    if (event.isError) return;
    if (event.toolName !== "edit" && event.toolName !== "write") return;
    const toolPath = event.input?.path;
    if (typeof toolPath !== "string") return;
    const plan = pointerForToolPath(toolPath, ctx.cwd, root, home);
    if (!plan) return;
    try {
      writePointer(root, plan);
    } catch (error) {
      warnOnce(ctx, "pointer", `Agent Collections process rules: could not save ${POINTER_REL}: ${String(error)}`);
    }
  });
}

export default function eversisProcessRules(pi: ExtensionAPI): void {
  register(pi, {
    skillIds: PROCESS_SKILL_IDS,
    // This file sits at <root>/.pi/extensions/.
    root: path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", ".."),
    home: os.homedir(),
  });
}
