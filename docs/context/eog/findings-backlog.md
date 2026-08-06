# EOG pilot — findings / backlog draft

Draft notes only. **Do not** auto-create Jira issues without explicit human request.

## Findings (2026-08-06)

| ID | Finding | Severity | Suggested follow-up |
|----|---------|----------|---------------------|
| F1 | EOG MCP still wires `CURSOR_COLLECTIONS_HOME` for `eversis-collections` | High (blocks clean cutover) | Apply upgrade runbook MCP step on pilot branch |
| F2 | No `agent-collections` submodule yet | Medium | Add submodule pin to SemVer tag (team default) |
| F3 | Framework abstract `apps/*` ≠ EOG `portal`/`cms` | Medium (expected) | Keep consumer overlay; never hardcode into framework profiles |
| F4 | WNF-03 file-count proxy already ≥30% for portal- and cms-scoped sets vs monorepo U | Info / pass | Re-measure after ignore triad + live sessions |
| F5 | Live Q5 dual-agent session quota not executed in Wave D implement workspace | Medium | Schedule 5 business days or ≥3+3 sessions; fill collision checklist |

## Optional backlog tickets (titles only)

1. EOG: cut over MCP env to `AGENT_COLLECTIONS_HOME` and pin Agent Collections submodule.
2. EOG: materialize consumer ignore overlay for portal/cms vs heavy infra.
3. EOG: complete Q5 dual-agent pilot window and attach session log to DHI-542.
4. Agent Collections: when public docs hosting exists, publish Wave D site (out-of-band vs Wave D DoD).
