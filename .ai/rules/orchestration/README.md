# Orchestration rules

Shared workflow rules for Agent Collections: Ideate → Implement → Review, human gates, Fine/QA handoff, and testing discipline.

Jira “shared orchestration” maps to this folder (`rules/orchestration/`).

## Files

| File | Role |
|------|------|
| [`agent-core.md`](./agent-core.md) | Lifecycle, Implement steps, skills discovery, quality bar, hard limits |
| [`engineering-manager.md`](./engineering-manager.md) | Implement readiness block, gates, Fine same-turn policy, delegates |
| [`testing-and-terminal.md`](./testing-and-terminal.md) | Post-change lint / typecheck / test discipline |
| [`fine-handoff.md`](./fine-handoff.md) | Fine → QA comment draft contract (no auto publish) |

**Not in this folder yet:** full code-reviewer role standards → **DHI-519** (domain placement). Hard limits remain in `agent-core.md`.

**Skill bodies** (`eversis-orchestrating-implementation`, `eversis-fine-handoff`) → **DHI-520**; this folder holds the **contracts** and stable skill ids.

## Mandatory workflow parity checklist

Compared to legacy Cursor Collections orchestration (`eversis-agent-core`, `eversis-engineering-manager`, `eversis-testing-and-terminal`, Fine handoff contract), the core **must** preserve:

1. Ideate → Implement → Review lifecycle; drafts until human approves
2. Research artifact + human approve before plan (when Full / required)
3. Plan artifact + human approve before broad execution
4. Implement readiness four-line block as first content on Implement entry
5. Adequacy checklist before Research/Plan SKIP
6. Post-change lint/typecheck/tests discipline
7. Review with PASS / BLOCKER / SUGGESTION (review step not dropped; full reviewer rule in DHI-519)
8. Fine → QA comment draft **same turn**; no issue-tracker publish without explicit human approval
9. Hard limits: no out-of-scope edits; no silent doc-comment removal; no new deps without agreement
10. Skills discovery via stack policy / context / MCP — not keyword guessing alone

## Related

- Mapping: [`.ai/README.md`](../../README.md)
- Spec: `docs/specs/dhi-518/`
