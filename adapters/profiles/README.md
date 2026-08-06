# Domain + area profiles for Agent Collections installer (DHI-536 / DHI-530)

| File | Role |
|------|------|
| `frontend.yaml` / `backend.yaml` / `fullstack.yaml` | Domain profile → domains + skill allowlist |
| `area-frontend-scope.yaml` / `area-backend-scope.yaml` / `area-fullstack.yaml` | Path scoping per isolation-strategy §5 |

Installer reads these via `--profile` / Fullstack defaults. Do not hardcode allowlists in bash.
