---
sidebar_position: 25
title: Cloud Cost Optimization
---

# Cloud Cost Optimization

**Folder:** `.cursor/skills/eversis-optimizing-cloud-cost/`
**Used by:** DevOps Engineer

Provides strategies for cloud cost optimization through resource rightsizing, tagging compliance, reserved instances, and spending analysis.

## Optimization Strategies

| Strategy | Impact |
|---|---|
| **Rightsizing** | Match instance types to actual workload requirements |
| **Reserved Instances / Savings Plans** | Commit to usage for 30–60% savings |
| **Spot / Preemptible instances** | Use for fault-tolerant workloads at 60–90% discount |
| **Storage tiering** | Move infrequent data to cheaper tiers (S3 Glacier, Coldline) |
| **Idle resource cleanup** | Remove unused EBS, disks, load balancers, static IPs |

## Tagging / Labeling Policy

| Tag/Label | Purpose |
|---|---|
| `Project` | Associate resources with business projects |
| `Environment` | Distinguish dev/staging/production |
| `Team` | Identify responsible team |
| `CostCenter` | Map to financial reporting |
| `ManagedBy` | Terraform, Helm, manual |

## Cost Governance

- Include cost estimates in every infrastructure proposal.
- Flag proposals exceeding 10% spend increase.
- Run regular cost audits (monthly minimum).
- Set up budget alerts and anomaly detection.

## Connected Skills

- `eversis-implementing-terraform-modules` — Cost-aware infrastructure provisioning.
- `eversis-designing-multi-cloud-architecture` — Cross-provider cost comparison.
