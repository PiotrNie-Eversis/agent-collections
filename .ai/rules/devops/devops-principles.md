# DevOps principles (seed)

> **Seed** from skills `eversis-implementing-ci-cd`, `eversis-implementing-kubernetes`, and `eversis-managing-secrets` (intent-level). Full pipeline/runbook content arrives in **DHI-520**.

## Principles

- **Automate delivery** — Prefer CI/CD stages that are independent and cacheable (e.g. lint → test → build → deploy). Detect the project’s existing CI platform; do not invent a second one without agreement.
- **Infrastructure as code** — Prefer versioned, reviewable infra definitions over manual production changes.
- **Secrets least privilege** — Credentials in CI/CD and runtime should be scoped narrowly; never commit secrets to the repository.
- **Safe deploys** — Choose a deployment strategy (rolling, blue-green, canary, etc.) that matches risk and rollback needs; document the choice when non-obvious.
- **Observe before and after** — Align releases with basic observability expectations from the project stack / context.

Defer detailed Helm charts, platform YAML, and tool-specific recipes to the corresponding skills (DHI-520) and project docs.
