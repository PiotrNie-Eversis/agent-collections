# EOG pilot — findings / backlog draft

Draft notes only. **Do not** auto-create Jira issues without explicit human request.

## Findings

| ID | Finding | Severity | Status / follow-up |
|----|---------|----------|---------------------|
| F1 | EOG MCP still wires `CURSOR_COLLECTIONS_HOME` for `eversis-collections` | High | **Closed (2026-08-07)** — live `mcp.json` uses `AGENT_COLLECTIONS_HOME` |
| F2 | No `agent-collections` submodule yet | Medium | **Deferred** after Q5 (research Q1 — local through pilot) |
| F3 | Framework abstract `apps/*` ≠ EOG `portal`/`cms` | Medium (expected) | Keep consumer overlay; never hardcode into framework profiles (**6a**) |
| F4 | WNF-03 file-count proxy already ≥30% for portal- and cms-scoped sets vs monorepo U | Info / pass | Proxy still valid as estimate; do not force excludes of active apps |
| F5 | Live Q5 dual-agent session quota not executed | Medium | **Scheduled** — start **2026-08-10**, owner Piotr Niemirski |
| F6 | Users expect `.ai/` inside EOG after local install; summary unclear | Medium (UX/docs) | **Addressed** — installer summary + EOG AGENTS clarify local mode |
| F7 | EOG has pre-existing dir named `\n` (LF) from old invalid-path docs bug | Low | Optional manual delete (`rm -rf $'\n'` from EOG root) — not auto-removed |
| F8 | Committed docs must not embed machine-local absolute paths | High (policy) | Enforced in research/plan/context updates |
| F9 | Misclassified `charts/` + handbooks as “heavy infra” in 2a overlay | High | **Fixed** — overlay removed; area-scope override drops `charts/**` exclude |

## Optional backlog tickets (titles only)

1. EOG: pin Agent Collections as submodule (SemVer) after Q5.  
2. ~~EOG: materialize consumer ignore overlay for heavy infra~~ — **cancelled** (misclassified product apps).  
3. EOG: complete Q5 dual-agent pilot window and attach session outcomes to TASK-542.  
4. Agent Collections: optional generic heavy-infra excludes in framework area manifests (**6b**) — not TASK-542; must not treat client product trees as infra.  
5. Agent Collections: formalize installer interactive agents/profile UX (checkbox/select) + CHANGELOG if not already shipped.
6. Agent Collections: consider removing `charts/**` from default `area-fullstack.yaml` exclude (generic name collides with consumer apps named `charts`).
