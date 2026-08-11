# Domain + area profiles for Agent Collections installer (DHI-536 / DHI-530)

| File | Role |
|------|------|
| `frontend.yaml` / `backend.yaml` / `fullstack.yaml` | Domain profile → domains + skill allowlist |
| `area-frontend-scope.yaml` / `area-backend-scope.yaml` / `area-fullstack.yaml` | Path scoping per isolation-strategy §5 |

**Note:** Default area excludes do **not** list generic `charts/**` — some monorepos use `charts/` as a **product app** name (EOG pilot). Apply consumer-specific heavy-infra excludes via overlay; see [isolation-strategy.md](../../docs/architecture/isolation-strategy.md) §6.

Installer reads these via `--profile` / Fullstack defaults. Do not hardcode allowlists in bash.
