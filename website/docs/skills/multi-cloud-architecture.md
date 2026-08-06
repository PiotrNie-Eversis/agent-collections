---
sidebar_position: 26
title: Multi-Cloud Architecture
---

# Multi-Cloud Architecture Design

**Folder:** `.cursor/skills/eversis-designing-multi-cloud-architecture/`
**Used by:** DevOps Engineer, Architect

Provides a decision framework for designing multi-cloud architectures across AWS, Azure, and GCP — selecting and integrating best-of-breed services while avoiding vendor lock-in.

## When to Use Multi-Cloud

| Reason | Example |
|---|---|
| **Vendor lock-in avoidance** | Regulatory or strategic requirement for portability |
| **Best-of-breed services** | AWS for compute, GCP for ML/AI, Azure for enterprise integration |
| **Geographic coverage** | Regions available in one provider but not another |
| **Compliance** | Data sovereignty requiring specific cloud regions |

## Decision Framework

1. **Identify constraints** — Regulatory, contractual, or technical requirements.
2. **Map services** — Compare equivalent services across providers.
3. **Evaluate trade-offs** — Portability vs. depth of native integration.
4. **Choose abstraction level** — Kubernetes for portability, native services for optimization.
5. **Design connectivity** — Cross-cloud networking and identity federation.

## Abstraction Layers

| Layer | Portable | Provider-Native |
|---|---|---|
| **Compute** | Kubernetes (EKS/GKE/AKS) | Lambda, Cloud Functions, Azure Functions |
| **Database** | PostgreSQL, MySQL | Aurora, Cloud Spanner, Cosmos DB |
| **Messaging** | Kafka, RabbitMQ | SQS/SNS, Pub/Sub, Service Bus |
| **Storage** | S3-compatible | S3, GCS, Azure Blob |

## Connected Skills

- `eversis-optimizing-cloud-cost` — Cross-provider cost comparison.
- `eversis-implementing-terraform-modules` — Multi-provider Terraform modules.
- `eversis-implementing-kubernetes` — Portable workload orchestration.
