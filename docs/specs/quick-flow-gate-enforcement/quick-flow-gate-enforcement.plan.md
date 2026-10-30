# Quick Flow gate-closing rule — Plan

Approved research: [`quick-flow-gate-enforcement.research.md`](./quick-flow-gate-enforcement.research.md) (Q1 = A+C, Q2 = B, Q3 = no change to `agent-core.md`, locked 2026-08-14).

## Goal

Close the gap that let a declared `Next gate` be treated as cleared without real user acceptance: add an explicit gate-closing rule to the canonical orchestration skill, and a matching mid-thread self-check to the always-loaded engineering-manager summary, then regenerate derived files.

## Files in scope

| File | Role | Action |
|---|---|---|
| `.ai/skills/eversis-orchestrating-implementation/SKILL.md` | Canonical, detailed workflow rule (loaded on demand) | Add new "Gate-closing rule (hard)" subsection; cross-reference it from the existing Quick Flow line |
| `.ai/rules/orchestration/engineering-manager.md` | Always-loaded summary (SSOT for `CLAUDE.md`'s engineering-manager section) | Add a second, separate mid-thread self-check list |
| `CLAUDE.md`, `.cursor/rules/eversis-engineering-manager.mdc` | Generated from `.ai/rules/orchestration/**` | Do **not** hand-edit — regenerate via `npm run sync:adapters` |

Confirmed out of scope: `.ai/rules/orchestration/agent-core.md` (Q3, no change needed) and `website/docs/skills/orchestrating-implementation.md` (hand-authored human-readable mirror, not part of the `sync:adapters` pipeline — optional separate follow-up, not required here).

## Phases

### Phase 1 — Add the gate-closing rule to `SKILL.md`

Insert a new subsection between the existing `#### Readiness output contract` block (ends ~line 98) and `#### Adequacy checklist` (~line 100):

```markdown
#### Gate-closing rule (hard)

A declared `Next gate` closes only when the user's next message **directly responds to that specific gate** — not merely because the user replied to something else in the thread (e.g., locking research Gap Analysis answers closes the *research* gate, not a later Plan or Quick Flow gate).

- If recommending Quick Flow as a substitute for an already-declared Full-Flow gate — or any other flow/gate reclassification mid-thread — **state the proposal and stop**. Do not perform any implementation action, file edit, or delegation in that same turn.
- Treat only an explicit answer to that proposal in the user's **next** turn as the acceptance signal — not silence, not an unrelated reply, not the absence of objection.
- Applies to every declared gate in a thread (Plan, code, Quick Flow acceptance, review→Fine), not only the readiness block in the first response.
```

Then append a cross-reference to the existing Quick Flow line (~line 152):

```
Use Quick Flow only if Step 1 passed every Quick criterion and the user selected or accepted it (see **Gate-closing rule** above — acceptance must be explicit, in response to a direct proposal, never inferred).
```

### Phase 2 — Add the mid-thread self-check to `engineering-manager.md`

Insert immediately after the existing "Self-check before sending the first message" 5-item list (after current line 31, before `## Key delegates`):

```markdown
**Self-check before treating a mid-thread gate as cleared:**

1. Does the user's message **directly respond to the specific gate** that was declared (not a different, earlier question)?
2. If proposing a flow or gate change (e.g., Quick Flow instead of a previously-declared Full-Flow gate), did I **stop** instead of also acting on it in this same turn?

See orchestration skill **Gate-closing rule** for the full rule.
```

### Phase 3 — Regenerate derived artifacts

1. `npm run sync:adapters` — regenerates `CLAUDE.md` and `.cursor/rules/eversis-engineering-manager.mdc` from the updated `engineering-manager.md`.
2. `SKILL.md` is not part of the `sync:adapters` pipeline (confirmed this session — no reference to `eversis-orchestrating-implementation` in `adapters/sync.mjs`) — no regeneration step needed for it beyond the direct edit in Phase 1.

### Phase 4 — Verify

1. `npm run sync:adapters:check` → expect exit 0 (no drift between `.ai/rules/**` and generated files).
2. Read back `CLAUDE.md`'s `eversis-engineering-manager` section — confirm the new mid-thread self-check list is present verbatim.
3. Read back `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — confirm the new Gate-closing rule subsection and the cross-reference are present.
4. `git diff --stat` — confirm only `SKILL.md`, `engineering-manager.md`, `CLAUDE.md`, and `.cursor/rules/eversis-engineering-manager.mdc` changed; `agent-core.md` untouched per Q3.

## Acceptance checks

- [ ] `SKILL.md` contains the new "Gate-closing rule (hard)" subsection with all 3 bullet points.
- [ ] `SKILL.md`'s Quick Flow line cross-references the Gate-closing rule.
- [ ] `engineering-manager.md` contains the new 2-item mid-thread self-check, after (not replacing) the existing first-message checklist.
- [ ] `CLAUDE.md`'s embedded `eversis-engineering-manager` section reflects both additions after regeneration.
- [ ] `npm run sync:adapters:check` passes.
- [ ] `agent-core.md` unchanged.
- [ ] No unrelated content changed (diff limited to the two source files + their regenerated outputs).

## Out of scope

- `website/docs/skills/orchestrating-implementation.md` — hand-authored docs-site mirror, not byte-synced from `SKILL.md`; updating it is an optional separate follow-up, not required for this fix to take effect.
- Any change to `agent-core.md` (Q3, locked no-op).
- Broader tooling enforcement (e.g., a lint/hook that mechanically detects propose+act-in-one-turn) — this plan is a documentation/rule-text fix only, matching the scope the research recommended.
