---
sidebar_position: 20
title: CI/CD Implementation
---

# CI/CD Implementation

**Folder:** `.cursor/skills/eversis-implementing-ci-cd/`
**Used by:** DevOps Engineer

Provides CI/CD pipeline design patterns and deployment strategies for GitHub Actions, GitLab CI, Bitbucket Pipelines, and other platforms.

## Pipeline Design Principles

- **Fail fast** — Run linting and unit tests before expensive operations.
- **Cache aggressively** — Cache dependencies, Docker layers, and build artifacts.
- **Parallelize** — Run independent jobs concurrently to reduce total build time.
- **Environment protection** — Require approvals for production deployments.

## Deployment Strategies

| Strategy | When to Use |
|---|---|
| **Blue/Green** | Zero-downtime deployments with instant rollback capability |
| **Canary** | Gradual rollout to a subset of users for risk mitigation |
| **Rolling** | Sequential updates across instances with health checks |
| **Feature flags** | Decouple deployment from release for safe feature rollouts |

## Security

- Secrets referenced via environment variables, never hardcoded.
- Minimal permissions for deployment service accounts.
- Dependency scanning and vulnerability checks in pipeline.

## Connected Skills

- `eversis-managing-secrets` — Secure credential storage and rotation for CI/CD.
- `eversis-technical-context-discovering` — Discover existing pipeline patterns.
