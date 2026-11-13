/**
 * Agent Collections independent review for Pi.
 *
 * Shipped by the Agent Collections Pi adapter (source:
 * adapters/pi/assets/eversis-review.ts, copied unchanged to
 * .pi/extensions/eversis-review.ts by adapters/pi/generate.mjs).
 *
 * Pi has no sub-agents, so a Review stage inside an Implement run would review
 * its own work. This extension registers one tool, eversis_independent_review.
 * The tool runs `/eversis-review <key> [<spec folder>]` in a separate Pi session
 * in the same process, and returns its PASS / BLOCKER / SUGGESTION text with the
 * label `Review context: separate Pi session (independent)` and a token usage line.
 *
 * The separate session (child):
 * - starts empty (SessionManager.inMemory): it never sees the implementing
 *   conversation; it gets only the review prompt, the spec folder path and the
 *   repository through its own tools;
 * - loads no extensions except the sibling eversis-process-rules.ts (by path),
 *   so the review tool is never registered in the child (no recursion);
 * - has the `edit` and `write` tools removed, and an inline tool_call guard
 *   blocks `bash` commands that a short pattern list flags as writing. This is
 *   edit-restricted, not read-only: `bash` still runs tests, and a determined
 *   command can still write;
 * - uses the parent's model and thinking level, with credentials read from the
 *   same Pi agent folder (auth.json, models.json). A model that only a Pi
 *   extension supplies is not known to the child; the tool then reports a failure.
 *
 * Every failure (bad input, no model, model not available to a clean session,
 * session error, abort, empty answer) returns an error result that says the
 * independent review did not run and gives the fresh-session steps (the manual
 * fallback: run the review in a new Pi session). A failure result never carries
 * the independent label.
 *
 * `runCleanRole` holds the SDK logic and is kept generic so a later runner for
 * other process roles can reuse it; only the review tool is exposed.
 *
 * Pi-only: Cursor and Claude Code run review in their own sub-agents.
 * Runtime import of Pi's own SDK (`@earendil-works/pi-coding-agent`, supplied by
 * Pi when it loads this file; no npm dependency), loaded inside the tool call.
 * It starts one extra model session per review, which costs extra tokens.
 * No network except that model call. No file writes by this extension; the child
 * session keeps no session file.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

export const TOOL_NAME = "eversis_independent_review";
export const INDEPENDENT_LABEL = "Review context: separate Pi session (independent)";
export const SAME_SESSION_LABEL = "Review context: same session as implementation (not independent)";
export const EXCLUDED_TOOLS: readonly string[] = ["edit", "write"];
export const MODEL_UNAVAILABLE = "the model is not available to a clean session";
export const START_NOTICE =
  "Independent review: running in a separate Pi session — this uses extra tokens.";

const PROCESS_RULES_FILE = "eversis-process-rules.ts";
const SPECS_PREFIX = "docs/specs/";
const KEY_RE = /^[A-Za-z][A-Za-z0-9]*-\d+$/;
const MAX_KEY_LENGTH = 64;
/** A spec folder reaches a slash command, which splits on spaces and quotes. */
const SAFE_FOLDER_RE = /^[A-Za-z0-9._/-]+$/;
/**
 * Fixed text after the command. Pi splits command arguments on whitespace and
 * strips quotes, so it has no quote characters.
 */
const REVIEW_INSTRUCTION =
  `Review instruction: you run in a separate Pi session started by the ${TOOL_NAME} tool. ` +
  "Do not change any file and do not run commands that write files; reading files and running tests is fine. " +
  `Start your result with the line: ${INDEPENDENT_LABEL}`;

/** Tool parameters, as the model sends them. */
export type ReviewParams = { key: string; specFolder?: string };

/** Token counts of one child session. */
export interface RoleTokens {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
}

/** What runCleanRole needs. */
export interface CleanRoleOptions {
  cwd: string;
  model: unknown;
  thinkingLevel?: unknown;
  prompt: string;
  excludeTools: readonly string[];
  /** Extension files the child loads by path (e.g. sibling eversis-process-rules.ts). */
  extensionPaths: readonly string[];
  /** Reason to block a bash command, or undefined to allow it. */
  guard?: (command: string) => string | undefined;
  signal?: AbortSignal;
  onProgress?: (text: string) => void;
}

/** What runCleanRole returns. */
export interface CleanRoleResult {
  text: string | undefined;
  tokens: RoleTokens;
  toolCalls: number;
}

/** The parts of Pi's SDK this extension uses (Pi 1.5.0). */
interface SdkModelRuntime {
  getModel(provider: string, id: string): unknown;
  hasConfiguredAuth(provider: string): boolean;
  checkAuth?(provider: string): Promise<unknown>;
}
interface SdkMessage {
  role?: string;
  stopReason?: string;
  errorMessage?: string;
}
interface SdkSessionEvent {
  type?: string;
  toolName?: string;
}
interface SdkSession {
  readonly modelRuntime?: SdkModelRuntime;
  readonly messages?: readonly SdkMessage[];
  prompt(text: string): Promise<void>;
  abort(): Promise<void> | void;
  dispose(): void;
  subscribe?(listener: (event: SdkSessionEvent) => void): () => void;
  getLastAssistantText(): string | undefined;
  getSessionStats(): { toolCalls?: number; tokens?: Partial<RoleTokens> };
}
interface SdkResourceLoader {
  reload(): Promise<void>;
  getExtensions?(): { errors?: Array<{ path: string; error: string }> };
}
interface SdkToolCallEvent {
  toolName?: string;
  input?: { command?: unknown };
}
interface SdkGuardApi {
  on(event: "tool_call", handler: (event: SdkToolCallEvent) => { block: true; reason: string } | undefined): void;
}
export interface PiSdk {
  getAgentDir(): string;
  DefaultResourceLoader: new (options: {
    cwd: string;
    agentDir: string;
    noExtensions: boolean;
    additionalExtensionPaths: string[];
    extensionFactories: Array<{ name: string; hidden?: boolean; factory: (pi: SdkGuardApi) => void }>;
  }) => SdkResourceLoader;
  SessionManager: { inMemory(cwd: string): unknown };
  createAgentSession(options: {
    cwd: string;
    model: unknown;
    thinkingLevel?: unknown;
    sessionManager: unknown;
    resourceLoader: SdkResourceLoader;
    excludeTools: string[];
  }): Promise<{ session: SdkSession }>;
}

/** The model fields this extension reads. */
interface ModelRef {
  provider?: unknown;
  id?: unknown;
}

/** Thrown when the parent's model cannot be used by a clean session. */
export class ModelUnavailableError extends Error {}

/**
 * Writing command patterns for the child's bash guard. A short list, not a
 * shell parser: it stops the usual ways a reviewer would change files.
 */
const WRITE_PATTERNS: ReadonlyArray<readonly [RegExp, string]> = [
  [/(^|[^<>&0-9])\d*>>?(?!&)\s*(?!\/dev\/null(?![^\s;|&)]))[^\s;|&)]/, "output redirect to a file"],
  [/&>>?\s*(?!\/dev\/null(?![^\s;|&)]))[^\s;|&)]/, "output redirect to a file"],
  [/(^|[\s;|&(`])(?:sudo\s+)?rm(\s|$)/, "rm"],
  [/(^|[\s;|&(`])(?:sudo\s+)?mv(\s|$)/, "mv"],
  [/(^|[\s;|&(`])(?:sudo\s+)?cp(\s|$)/, "cp"],
  [/(^|[\s;|&(`])tee(\s|$)/, "tee"],
  [/(^|[\s;|&(`])sed\s(?:[^;|&]*\s)?(?:-[A-Za-z]*i|--in-place)/, "sed -i"],
  [/(^|[\s;|&(`])git\s+(?:-[^\s]+(?:\s+[^-\s][^\s]*)?\s+)*(commit|checkout|reset|stash|apply|push|restore|clean)(\s|$)/, "git write command"],
  [/(^|[\s;|&(`])(npm|pnpm|yarn)\s+(install|i|add|ci)(\s|$)/, "package install"],
];

/**
 * The reason a bash command looks like it writes files, or undefined when it
 * does not. `> /dev/null` and `2>&1` are allowed. Pure.
 */
export function isWritingCommand(command: string): string | undefined {
  for (const [pattern, reason] of WRITE_PATTERNS) {
    if (pattern.test(command)) return reason;
  }
  return undefined;
}

/** Why the key is not acceptable, or undefined. Pure. */
export function keyProblem(key: unknown): string | undefined {
  if (typeof key !== "string" || key.length === 0) return "the ticket key is missing";
  if (key.length > MAX_KEY_LENGTH || !KEY_RE.test(key)) {
    return "the ticket key must look like AC-123 (letters and digits, a hyphen, a number)";
  }
  return undefined;
}

/**
 * The spec folder as a clean path relative to cwd (always under docs/specs/),
 * or an error. The folder must exist; real paths are compared, so `..`, an
 * absolute path elsewhere and a symlink that leaves docs/specs/ are refused.
 */
export function resolveSpecFolder(
  cwd: string,
  specFolder: unknown,
): { folder: string } | { error: string } {
  if (typeof specFolder !== "string" || specFolder.length === 0 || specFolder.includes("\0")) {
    return { error: "the spec folder is not a valid path" };
  }
  let realCwd: string;
  let realTarget: string;
  try {
    realCwd = fs.realpathSync(cwd);
    realTarget = fs.realpathSync(path.resolve(cwd, specFolder));
  } catch {
    return { error: "the spec folder does not exist" };
  }
  const rel = path.relative(realCwd, realTarget).split(path.sep).join("/");
  if (!rel.startsWith(SPECS_PREFIX) || rel.length === SPECS_PREFIX.length) {
    return { error: `the spec folder must be inside ${SPECS_PREFIX}` };
  }
  if (!SAFE_FOLDER_RE.test(rel)) {
    return { error: "the spec folder name has characters a command cannot carry" };
  }
  return { folder: rel };
}

/**
 * The checked parameters, or the reason they are refused. Runs before any SDK
 * call; the values come from the model and are untrusted.
 */
export function validateParams(
  cwd: string,
  params: unknown,
): { params: ReviewParams } | { error: string } {
  const raw = (params ?? {}) as { key?: unknown; specFolder?: unknown };
  const problem = keyProblem(raw.key);
  if (problem) return { error: problem };
  const key = raw.key as string;
  if (raw.specFolder === undefined || raw.specFolder === null || raw.specFolder === "") {
    return { params: { key } };
  }
  const resolved = resolveSpecFolder(cwd, raw.specFolder);
  if ("error" in resolved) return { error: resolved.error };
  return { params: { key, specFolder: resolved.folder } };
}

/**
 * The child's only prompt: the review command with the key (and folder), then
 * the fixed instruction. Nothing from the parent session. Pure.
 */
export function buildReviewPrompt(params: ReviewParams): string {
  const args = params.specFolder ? `${params.key} ${params.specFolder}` : params.key;
  return `/eversis-review ${args}\n\n${REVIEW_INSTRUCTION}`;
}

/** The usage line of a successful run. Pure. */
export function formatUsage(result: Pick<CleanRoleResult, "tokens" | "toolCalls">): string {
  return `Review usage: ${result.tokens.input} in / ${result.tokens.output} out tokens, ${result.toolCalls} tool calls (separate session)`;
}

/**
 * The tool result text of a successful run: the independent label, the child's
 * review text unchanged (a leading copy of the label is not repeated), the usage
 * line. Pure.
 */
export function formatReviewResult(result: CleanRoleResult): string {
  let text = (result.text ?? "").trim();
  const lineEnd = text.indexOf("\n");
  const firstLine = (lineEnd === -1 ? text : text.slice(0, lineEnd)).trim();
  if (firstLine === INDEPENDENT_LABEL) text = lineEnd === -1 ? "" : text.slice(lineEnd + 1).trim();
  return [INDEPENDENT_LABEL, "", text, "", formatUsage(result)].join("\n");
}

function reasonOf(error: unknown): string {
  if (error instanceof Error && error.message) return error.message;
  if (typeof error === "string" && error) return error;
  return "unknown error";
}

/** Removes every copy of the independent label from text. Pure. */
function stripIndependentLabel(text: string): string {
  return text.split(INDEPENDENT_LABEL).join("[label removed]");
}

/**
 * The tool result text when the independent review did not run: the reason,
 * the fresh-session steps (the manual fallback in a new Pi session) and the
 * same-session label rule. Pass only
 * validated params: a key or folder that does not pass the checks is shown as
 * a placeholder, never echoed. It never contains the independent label, even
 * when the reason quotes it; the joined text is stripped once more as a
 * backstop. Pure.
 */
export function formatReviewFailure(error: unknown, params: Partial<ReviewParams>): string {
  const reason = stripIndependentLabel(reasonOf(error));
  const key = typeof params.key === "string" && keyProblem(params.key) === undefined ? params.key : "<key>";
  const folder =
    typeof params.specFolder === "string" &&
    params.specFolder.startsWith(SPECS_PREFIX) &&
    SAFE_FOLDER_RE.test(params.specFolder)
      ? params.specFolder
      : "<spec folder>";
  const text = [
    `Independent review did not run: ${reason}.`,
    "",
    "Next step for an independent review:",
    "1. Start a new Pi session in the project root.",
    `2. Run \`/eversis-review ${key}\` (optionally add the spec folder or plan path, for example \`/eversis-review ${key} ${folder}\`).`,
    "",
    `Any review done in this session instead must start with \`${SAME_SESSION_LABEL}\` and must not be presented as independent.`,
  ].join("\n");
  return stripIndependentLabel(text);
}

function abortError(): Error {
  return new Error("the review was stopped (aborted)");
}

function modelLabel(model: ModelRef): string {
  return `${String(model.provider)}/${String(model.id)}`;
}

/**
 * Throws ModelUnavailableError unless the child's model runtime knows the model
 * and has auth for its provider (the same check Pi makes before a prompt).
 */
async function assertModelAvailable(session: SdkSession, model: ModelRef): Promise<void> {
  const runtime = session.modelRuntime;
  const provider = String(model.provider);
  const known = runtime?.getModel(provider, String(model.id)) !== undefined;
  let auth = known && runtime ? runtime.hasConfiguredAuth(provider) : false;
  if (known && !auth && runtime?.checkAuth) auth = (await runtime.checkAuth(provider)) !== undefined;
  if (!known || !auth) {
    throw new ModelUnavailableError(`${MODEL_UNAVAILABLE} (${modelLabel(model)})`);
  }
}

/** Throws when the last assistant message ended in an error or was aborted. */
function assertCompleted(session: SdkSession): void {
  const messages = session.messages ?? [];
  for (let i = messages.length - 1; i >= 0; i--) {
    const message = messages[i];
    if (message?.role !== "assistant") continue;
    if (message.stopReason === "error") {
      throw new Error(`the review session failed: ${message.errorMessage || "model error"}`);
    }
    if (message.stopReason === "aborted") throw abortError();
    return;
  }
}

/**
 * Runs one prompt in a new, clean Pi session and returns its last answer and
 * usage. The session is in memory, loads only `extensionPaths` plus an inline
 * bash guard, and has `excludeTools` removed. `signal` aborts it; it is always
 * disposed. Kept role-neutral so a later runner for other process roles can
 * reuse it.
 */
export async function runCleanRole(sdk: PiSdk, options: CleanRoleOptions): Promise<CleanRoleResult> {
  const { cwd, guard, signal, onProgress } = options;
  const model = options.model as ModelRef | undefined;
  if (!model || typeof model !== "object") {
    throw new ModelUnavailableError(`${MODEL_UNAVAILABLE} (no model is selected)`);
  }
  if (signal?.aborted) throw abortError();

  const extensionFactories = guard
    ? [{
        name: "eversis-clean-role-guard",
        hidden: true,
        factory: (pi: SdkGuardApi) => {
          pi.on("tool_call", (event) => {
            if (event.toolName !== "bash") return undefined;
            const reason = guard(String(event.input?.command ?? ""));
            return reason
              ? { block: true as const, reason: `Blocked in the review session (no file changes allowed): ${reason}.` }
              : undefined;
          });
        },
      }]
    : [];
  const loader = new sdk.DefaultResourceLoader({
    cwd,
    agentDir: sdk.getAgentDir(),
    noExtensions: true,
    additionalExtensionPaths: [...options.extensionPaths],
    extensionFactories,
  });
  await loader.reload();
  const loadErrors = loader.getExtensions?.().errors ?? [];
  if (loadErrors.length > 0) {
    throw new Error(`an extension of the review session did not load: ${loadErrors.map((e) => `${e.path}: ${e.error}`).join("; ")}`);
  }
  if (signal?.aborted) throw abortError();

  const { session } = await sdk.createAgentSession({
    cwd,
    model,
    thinkingLevel: options.thinkingLevel,
    sessionManager: sdk.SessionManager.inMemory(cwd),
    resourceLoader: loader,
    excludeTools: [...options.excludeTools],
  });
  const onAbort = () => {
    void Promise.resolve(session.abort()).catch(() => {});
  };
  let unsubscribe: (() => void) | undefined;
  try {
    await assertModelAvailable(session, model);
    if (signal?.aborted) throw abortError();
    signal?.addEventListener("abort", onAbort, { once: true });
    if (onProgress && session.subscribe) {
      unsubscribe = session.subscribe((event) => {
        if (event?.type === "tool_execution_start" && typeof event.toolName === "string") {
          onProgress(`Independent review: ${event.toolName}`);
        }
      });
    }
    await session.prompt(options.prompt);
    if (signal?.aborted) throw abortError();
    assertCompleted(session);
    const stats = session.getSessionStats();
    const tokens = stats.tokens ?? {};
    return {
      text: session.getLastAssistantText(),
      tokens: {
        input: tokens.input ?? 0,
        output: tokens.output ?? 0,
        cacheRead: tokens.cacheRead ?? 0,
        cacheWrite: tokens.cacheWrite ?? 0,
      },
      toolCalls: stats.toolCalls ?? 0,
    };
  } finally {
    signal?.removeEventListener("abort", onAbort);
    unsubscribe?.();
    session.dispose();
  }
}

/** What register() needs. Tests pass a fake SDK loader. */
export interface ReviewConfig {
  /** Loads Pi's SDK. Called inside each tool call, never at load time. */
  loadSdk: () => Promise<PiSdk>;
  /** Absolute path of eversis-process-rules.ts for the child. */
  processRulesPath: string;
}

type ToolResult = { content: Array<{ type: "text"; text: string }>; details: Record<string, unknown>; isError?: boolean };

function textResult(text: string, details: Record<string, unknown>, isError = false): ToolResult {
  return isError ? { content: [{ type: "text", text }], details, isError: true } : { content: [{ type: "text", text }], details };
}

/** Registers the tool. Separate from the default export so tests can pass a config. */
export function register(pi: ExtensionAPI, config: ReviewConfig): void {
  pi.registerTool({
    name: TOOL_NAME,
    label: "Independent review",
    description:
      "Runs the Agent Collections code review (/eversis-review) for a ticket in a separate Pi session " +
      "that has not seen this conversation, and returns its PASS / BLOCKER / SUGGESTION result with " +
      "token usage. The review session cannot edit files. Uses extra tokens.",
    promptSnippet: `${TOOL_NAME}: run the code review for a ticket in a separate, clean Pi session.`,
    promptGuidelines: [
      `At the Review stage of an Implement run, and again after every blocker fix, call ${TOOL_NAME} with the ticket key (and the spec folder when known) instead of reviewing the change yourself.`,
      `If ${TOOL_NAME} reports that the independent review did not run, say so, give its fresh-session steps, and never present a review done in this session as independent.`,
    ],
    parameters: {
      type: "object",
      properties: {
        key: { type: "string", description: "Ticket key, for example AC-123." },
        specFolder: {
          type: "string",
          description: "Optional spec folder under docs/specs/, for example docs/specs/ac-123-topic.",
        },
      },
      required: ["key"],
      additionalProperties: false,
    },
    async execute(
      _toolCallId: string,
      params: unknown,
      signal: AbortSignal | undefined,
      onUpdate: ((partial: ToolResult) => void) | undefined,
      ctx: ExtensionContext,
    ): Promise<ToolResult> {
      const checked = validateParams(ctx.cwd, params);
      if ("error" in checked) {
        // Only a key that passed its check is shown; the folder never is (B1).
        const rawKey = (params as { key?: unknown } | null | undefined)?.key;
        const shown = typeof rawKey === "string" && keyProblem(rawKey) === undefined ? { key: rawKey } : {};
        return textResult(formatReviewFailure(new Error(checked.error), shown), { independent: false }, true);
      }
      const reviewParams = checked.params;
      if (ctx.hasUI) ctx.ui.notify(START_NOTICE, "info");
      onUpdate?.(textResult(START_NOTICE, {}));
      try {
        const sdk = await config.loadSdk();
        const result = await runCleanRole(sdk, {
          cwd: ctx.cwd,
          model: ctx.model,
          thinkingLevel: ctx.thinkingLevel,
          prompt: buildReviewPrompt(reviewParams),
          excludeTools: EXCLUDED_TOOLS,
          extensionPaths: [config.processRulesPath],
          guard: isWritingCommand,
          signal: signal ?? ctx.signal,
          onProgress: onUpdate ? (text) => onUpdate(textResult(text, {})) : undefined,
        });
        if (!result.text || result.text.trim() === "") {
          throw new Error("the review session returned no text");
        }
        return textResult(formatReviewResult(result), {
          independent: true,
          tokens: result.tokens,
          toolCalls: result.toolCalls,
        });
      } catch (error) {
        return textResult(formatReviewFailure(error, reviewParams), { independent: false }, true);
      }
    },
  } as unknown as Parameters<ExtensionAPI["registerTool"]>[0]);
}

export default function eversisReview(pi: ExtensionAPI): void {
  register(pi, {
    // A literal specifier, so Pi's module alias resolves it to the running Pi.
    loadSdk: async () => (await import("@earendil-works/pi-coding-agent")) as unknown as PiSdk,
    // The child loads the process-rules extension that sits beside this file.
    processRulesPath: path.join(path.dirname(fileURLToPath(import.meta.url)), PROCESS_RULES_FILE),
  });
}
