/**
 * Agent Collections context budget for Pi (AC-14).
 *
 * Shipped by the Agent Collections Pi adapter (source:
 * adapters/pi/assets/eversis-context-budget.ts, copied to
 * .pi/extensions/eversis-context-budget.ts by adapters/pi/generate.mjs).
 *
 * Compacts the session once context usage crosses a budget (default 50% of
 * the model's context window; override with EVERSIS_CONTEXT_BUDGET_PERCENT,
 * integer 1–95). Pi's ctx.compact() aborts the running agent turn and never
 * resumes it, so when the crossing happened mid-task (the turn had tool
 * results) the extension sends one continuation message after compaction.
 * A crossing on a final turn (no tool results: the agent finished, asked a
 * question or stopped at a human gate) compacts and shows a notice only — no
 * unrequested run starts and nothing can be read as gate approval.
 * The first known usage reading after an extension-triggered compaction only
 * sets a new baseline and never fires, so a small window whose retained
 * context stays at/over the budget cannot loop compaction + continuation every
 * turn; the next compaction needs a fresh below -> at/over crossing.
 *
 * Pi-only: Cursor and Claude Code keep "window fill is not a trigger".
 * No network, file writes or shell. Type-only import — no runtime dependency.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
  TurnEndEvent,
} from "@earendil-works/pi-coding-agent";

export const DEFAULT_THRESHOLD_PERCENT = 50;
export const THRESHOLD_ENV = "EVERSIS_CONTEXT_BUDGET_PERCENT";
const MIN_THRESHOLD_PERCENT = 1;
const MAX_THRESHOLD_PERCENT = 95;

export const COMPACTION_INSTRUCTIONS = [
  "This session follows the Agent Collections delivery workflow (Research -> Plan -> Implement -> Review -> Fine).",
  "In the summary, keep these items verbatim and complete:",
  "1. The path of the active implementation plan (docs/specs/**/*.plan.md) and of its research file, if any.",
  "2. The current plan phase and task id, and its state (done / in progress / not started), including which Definition-of-Done items are already ticked.",
  "3. The latest CHECKPOINT: and RESUMED: rows of the plan Changelog, if any.",
  "4. Any open human gate: the declared Next gate and that it is still awaiting the human. Never record a gate as approved unless the human explicitly approved it in this session.",
  "5. The exact next step, the files changed so far, and the checks still to run.",
  "Drop exploratory tool output that is no longer needed.",
].join("\n");

export const CONTINUATION_MESSAGE = [
  "[eversis-context-budget] The context budget was reached and the session was compacted, which interrupted the previous turn.",
  "Resume the current plan task from the compaction summary:",
  "- Re-read the active plan file (docs/specs/**/*.plan.md) before editing anything.",
  "- Do not restart tasks that are already marked done.",
  "- Do not pass an open human gate: if the summary shows a gate awaiting the human, stop and wait for the human.",
  "If there is no active plan, continue the interrupted task from the compaction summary.",
  "This message is automatic and is not an approval of any gate.",
].join("\n");

type Env = Record<string, string | undefined>;

/** Budget in percent from EVERSIS_CONTEXT_BUDGET_PERCENT (integer 1–95), else 50. */
export function resolveThreshold(env: Env = {}): number {
  const raw = env[THRESHOLD_ENV];
  if (typeof raw !== "string") return DEFAULT_THRESHOLD_PERCENT;
  const trimmed = raw.trim();
  if (!/^\d+$/.test(trimmed)) return DEFAULT_THRESHOLD_PERCENT;
  const value = Number.parseInt(trimmed, 10);
  if (value < MIN_THRESHOLD_PERCENT || value > MAX_THRESHOLD_PERCENT) {
    return DEFAULT_THRESHOLD_PERCENT;
  }
  return value;
}

function isKnownPercent(value: number | null | undefined): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

/** Optional reading context for shouldCompact. */
export interface CompactReadingOptions {
  /**
   * True for the first known reading after an extension-triggered compaction:
   * that reading only sets a baseline and never fires.
   */
  afterCompaction?: boolean;
}

/**
 * True when the current reading is at/over the threshold and the previous
 * reading was below it or unknown (null / undefined: first reading, or right
 * after a compaction). False when the current reading is unknown.
 * With options.afterCompaction the reading is a post-compaction baseline and
 * never fires (unknown -> above fires only for a session's first reading, e.g.
 * a resumed session that is already over budget). Pure: no state, no I/O.
 */
export function shouldCompact(
  previousPercent: number | null | undefined,
  currentPercent: number | null | undefined,
  threshold: number,
  options: CompactReadingOptions = {},
): boolean {
  if (!isKnownPercent(currentPercent)) return false;
  if (options.afterCompaction) return false;
  if (currentPercent < threshold) return false;
  if (!isKnownPercent(previousPercent)) return true;
  return previousPercent < threshold;
}

function readProcessEnv(): Env {
  const proc = (globalThis as { process?: { env?: Env } }).process;
  return proc?.env ?? {};
}

function notify(
  ctx: ExtensionContext,
  message: string,
  type: "info" | "warning" | "error",
): void {
  if (ctx.hasUI) ctx.ui.notify(message, type);
}

export default function eversisContextBudget(pi: ExtensionAPI): void {
  const threshold = resolveThreshold(readProcessEnv());
  let previousPercent: number | null = null;
  let compacting = false;
  // Set when an extension-triggered compaction completes; cleared by the next
  // known reading, which becomes the post-compaction baseline.
  let justCompacted = false;

  pi.on("turn_end", (event: TurnEndEvent, ctx: ExtensionContext) => {
    if (compacting) return;
    const currentPercent = ctx.getContextUsage()?.percent ?? null;
    if (!isKnownPercent(currentPercent)) return;
    const fire = shouldCompact(previousPercent, currentPercent, threshold, {
      afterCompaction: justCompacted,
    });
    previousPercent = currentPercent;
    justCompacted = false;
    if (!fire) return;

    // Tool results on the crossing turn mean the agent was mid-task; the
    // abort inside ctx.compact() interrupts it, so a continuation is needed.
    const midTask = Array.isArray(event.toolResults) && event.toolResults.length > 0;
    compacting = true;
    notify(
      ctx,
      `Context at ${Math.round(currentPercent)}% (budget ${threshold}%) — compacting.`,
      "info",
    );
    ctx.compact({
      customInstructions: COMPACTION_INSTRUCTIONS,
      onComplete: () => {
        compacting = false;
        previousPercent = null;
        justCompacted = true;
        if (!midTask) {
          notify(ctx, "Context compacted. Continue when ready.", "info");
          return;
        }
        if (ctx.isIdle()) {
          pi.sendUserMessage(CONTINUATION_MESSAGE, { expandPromptTemplates: false });
        } else {
          pi.sendUserMessage(CONTINUATION_MESSAGE, {
            deliverAs: "followUp",
            expandPromptTemplates: false,
          });
        }
        notify(ctx, "Context compacted — resuming the current plan task.", "info");
      },
      onError: (error: Error) => {
        compacting = false;
        notify(ctx, `Context compaction failed: ${error.message}`, "error");
      },
    });
  });
}
