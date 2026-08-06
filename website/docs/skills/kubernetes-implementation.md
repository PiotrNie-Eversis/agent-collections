---
sidebar_position: 21
title: Kubernetes Implementation
---

# Kubernetes Implementation

**Folder:** `.cursor/skills/eversis-implementing-kubernetes/`
**Used by:** DevOps Engineer

Provides Kubernetes deployment patterns, Helm chart conventions, and cluster management best practices.

## Deployment Patterns

- **Deployments** — Standard stateless workloads with rolling updates.
- **StatefulSets** — Stateful applications requiring stable network identities.
- **DaemonSets** — Node-level agents (monitoring, logging).
- **CronJobs** — Scheduled batch workloads.

## Resource Management

| Resource | Approach |
|---|---|
| **Requests** | Set to the average resource usage |
| **Limits** | Set to the peak resource usage with headroom |
| **HPA** | Configure horizontal pod autoscaling based on CPU/memory or custom metrics |
| **PDB** | Set Pod Disruption Budgets to maintain availability during rollouts |

## Health Probes

| Probe | Purpose |
|---|---|
| **Liveness** | Restart the pod if the application is stuck |
| **Readiness** | Remove from service until the application is ready to serve traffic |
| **Startup** | Allow slower startup for applications with long initialization |

## Security

- Run containers as non-root with read-only file systems.
- Use NetworkPolicies to restrict pod-to-pod communication.
- Configure RBAC with least-privilege service accounts.

## Connected Skills

- `eversis-managing-secrets` — Secrets management for Kubernetes.
- `eversis-implementing-observability` — Monitoring and alerting for workloads.
