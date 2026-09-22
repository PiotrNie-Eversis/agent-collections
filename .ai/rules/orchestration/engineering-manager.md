# Engineering Manager (Agent Collections)

Use when running the **Implement** prompt (`eversis-implement`) or acting as the orchestration role for Implement.

## Canonical workflow

Load and follow skill **`eversis-orchestrating-implementation`** (via MCP `eversis_skills_get`, or by reading its `SKILL.md` under `.ai/skills/` after TASK-520 / adapter resolution). That skill owns flow selection (Quick vs Full), planning readiness, task routing, todos, review gates, and Fine handoff — do not improvise a parallel workflow from this rule file alone.

## Human gates

Follow **`agent-core.md`**: approve research, plan, and plan validation before broad code changes unless Quick Flow criteria are met and the user accepts Quick.

On the **first response** of every Implement run (`eversis-implement`), output the Implement readiness block (four required lines, plus any optional lines that apply) as the **first content** (orchestration skill Step 1 — Readiness output contract) before artifacts or code — even when existing plan/research allow skipping Ideate.

```text
## Implement readiness
- **Flow:** Quick | Full | QA follow-up
- **Research:** SKIP (<path>) | CREATE | DELTA (<reason>)
- **Plan:** SKIP (<path>) | CREATE | REFRESH (<reason>)
- **Next gate:** Awaiting approval before code | Awaiting approval before plan | Proceeding (<one-line reason>)
```

Optional additional lines, any subset, appended after the four required lines in this order when present:
- `- **Resume:** CHECKPOINT <date>` (or omit when not resuming) — present when a fresh session recognizes an **unconsumed** `CHECKPOINT:` entry in the plan's `Changelog` (scan defined in `eversis-orchestrating-implementation` Step 1: a later `RESUMED:` row or a later row that records that same task complete consumes it; other later rows do not) and is picking up a zero-compaction handoff. This is independent of `Flow` — `Flow` still states the governing flow (e.g. `Full`) exactly as it did before the checkpoint; resuming never loses that declaration.
- `- **Context:** <N> components indexed` (or `0 components indexed`) — `docs/context/<project>/INDEX.md`'s component count via `eversis_context_list`. `0` is a visible, non-blocking signal, not a gate.
- `- **Audit:** …` — The agent reads `docs/context/<project>/INDEX.md` frontmatter directly. It does not call MCP for this line. It does not compute the count from git history or from `eversis_context_list`. Omit the line when the index has 0 components. When there is at least one component and `last_audit` is absent: `Audit: never`. Otherwise: `Audit: N since YYYY-MM-DD`, and append `due` when `N >= audit_due_after` (the integer stored in frontmatter; `5` only when that key is absent). The line is not a gate. It is not a fifth required line. It is not a `Next gate` value. `Flow` stays `Quick | Full | QA follow-up`.
- `- **Reason:** …` — why this Flow / Research decision.

**Self-check before sending the first message:**

1. Inspected `docs/specs/<issue>/` and any attached research/plan paths, and scanned the plan `Changelog` from the newest row backward for an unconsumed `CHECKPOINT:` (a later `RESUMED:` row, or a later row that records that same task complete, consumes it; other later rows do not). Emit `Resume` only for an unconsumed checkpoint, using the scan in `eversis-orchestrating-implementation` Step 1.
2. First content is `## Implement readiness` with the four required lines (Flow, Research, Plan, Next gate) plus any applicable optional lines (`Resume`, `Context`, `Audit`, `Reason`).
3. Ran **adequacy checklist** before any `Research: SKIP` when artifacts exist.
4. No A/B/C menu or ticket recap before the readiness block.
5. Stopped at the correct gate (before plan or before code) unless Proceeding is allowed.

**Self-check before treating a mid-thread gate as cleared:**

1. Does the user's message **directly respond to the specific gate** that was declared (not a different, earlier question, and not a message sent before that gate existed)?
2. If I just declared **any** `Next gate` in this turn — not only a flow/gate change proposal — did I **stop** there, instead of also acting on it (implementing, delegating, or otherwise progressing) in this same turn?
3. If the answer to #1 isn't a clean yes **and the reply is plausibly an uncertain approval attempt**, did I **ask an explicit clarifying question** instead of proceeding on a plausible reading? (Not needed when the reply is clearly something else — a question, a requested change, a clarification — just handle it directly and leave the gate open.)

See orchestration skill **Gate-closing rule** for the full rule.

## Key delegates

- Internal prompts (by stable name): `eversis-research`, `eversis-plan`, `eversis-review-plan`, `eversis-implement-ui`, and other `eversis-implement-*` per the routing table in the orchestration skill.
- Public prompts: `eversis-review-ui`, `eversis-review`.

Do not skip **UI verification** items tracked in the plan before handoff to code review.

**Continuity:** After code + checks, run `eversis-review` in-session then Fine on PASS — see orchestration skill **Continuity (default)**. Do not wait for a separate human `/eversis-review` attach unless the user said `pause before review` or `review later`.

## QA Handoff Policy

- When you reach **Fine**, **always** produce the QA comment draft **in the same turn** per **`fine-handoff.md`** / skill `eversis-fine-handoff` (orchestration skill Step 5).
- Label: `**Draft QA comment — review before posting to Jira**`
- **Do not** publish to the issue tracker until the human explicitly approves.
