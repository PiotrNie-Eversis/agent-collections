# Orchestration rules

Shared workflow rules for Agent Collections: Ideate → Research → Plan → Implement → Review, human gates, Fine/QA handoff, and testing discipline.

Jira “shared orchestration” maps to this folder (`rules/orchestration/`).

## Files

| File | Role |
|------|------|
| [`agent-core.md`](./agent-core.md) | Lifecycle, Implement steps, skills discovery, quality bar, hard limits; pointer to SDD |
| [`spec-driven-development.md`](./spec-driven-development.md) | **Mandatory Delivery Standard** — specs convention, gates, copy-ready Jira block |
| [`engineering-manager.md`](./engineering-manager.md) | Implement readiness block, gates, Fine same-turn policy, delegates |
| [`testing-and-terminal.md`](./testing-and-terminal.md) | Post-change lint / typecheck / test discipline |
| [`fine-handoff.md`](./fine-handoff.md) | Fine → QA comment draft contract (no auto publish) |

**Skill bodies** (`eversis-orchestrating-implementation`, `eversis-fine-handoff`) live under `.ai/skills/`; this folder holds the **contracts** and stable skill ids.

## Mandatory workflow parity checklist

Compared to legacy Cursor Collections orchestration, the core **must** preserve:

1. Ideate → Research → Plan → Implement → Review lifecycle (SDD); drafts until human approves — see `spec-driven-development.md`
2. Research artifact + human approve before plan (when Full / required)
3. Plan artifact + human approve before broad execution
4. Implement readiness four-line block as first content on Implement entry
5. Adequacy checklist before Research/Plan SKIP
6. Post-change lint/typecheck/tests discipline
7. Review with PASS / BLOCKER / SUGGESTION (review step not dropped)
8. Fine → QA comment draft **same turn**; no issue-tracker publish without explicit human approval
9. Hard limits: no out-of-scope edits; no silent doc-comment removal; no new deps without agreement
10. Skills discovery via stack policy / context / MCP — not keyword guessing alone

## Related

- Mapping: [`.ai/README.md`](../../README.md)
- Specs convention: `docs/specs/README.md` (repo root)
