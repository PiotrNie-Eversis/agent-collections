# EOG consumer context (Agent Collections pilot)

Local notes for the **EOG** monorepo pilot ([TASK-542](https://eversis.atlassian.net/browse/TASK-542)). Consumer-specific; not framework SSOT.

## Area overlay (Q7)

| Framework abstract class | EOG path | Notes |
|--------------------------|----------|-------|
| Frontend (`apps/web/**`) | `portal/**` | Next.js FE |
| Backend (`apps/api/**`) | `cms/**` | Liferay / CMS BE |
| Light shared | `docs/**`, `scripts/**` | Orientation |
| Heavy infra (default exclude) | `charts/**`, `*-nginx/**`, `mariadb/**`, `elasticsearch/**`, `maildev/**`, `load-test/**`, `swarm-data-handbook*/**`, … | Do not index in app agent sessions |

**Do not** commit `portal` / `cms` names into framework `adapters/profiles/*.yaml`. Keep mapping here and in EOG-owned ignore / stack docs.

## Install posture (team default)

- Prefer **`--vendor submodule`** pinned to an `agent-collections` SemVer tag.
- Solo trials may use **local** mode with `AGENT_COLLECTIONS_HOME` pointing at a checkout.
- MCP skills server must use **`AGENT_COLLECTIONS_HOME`** (replace `CURSOR_COLLECTIONS_HOME`).
- **Path policy:** committed docs here must not embed machine-local absolute paths — use repo names, in-repo relative paths, or `$AGENT_COLLECTIONS_HOME` / `${env:AGENT_COLLECTIONS_HOME}`.

## Documents in this folder

| File | Purpose |
|------|---------|
| [pilot-evidence.md](./pilot-evidence.md) | WNF-03 proxy numbers, collision checklist, residual steps |
| [upgrade-runbook.md](./upgrade-runbook.md) | Legacy Cursor Collections → Agent Collections for EOG |
| [findings-backlog.md](./findings-backlog.md) | Draft backlog notes (no auto-create Jira) |
