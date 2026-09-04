---
sidebar_position: 24
title: Secrets Management
---

# Secrets Management

**Folder:** `.cursor/skills/eversis-managing-secrets/`
**Used by:** DevOps Engineer

Provides patterns for secure credential storage, rotation, and CI/CD authentication across cloud and Kubernetes environments.

## Secret Storage Options

| Solution | Use Case |
|---|---|
| **AWS Secrets Manager** | Application secrets with automatic rotation |
| **AWS SSM Parameter Store** | Configuration values and simple secrets |
| **Azure Key Vault** | Secrets, keys, and certificates for Azure workloads |
| **GCP Secret Manager** | Secrets with IAM-based access control |
| **HashiCorp Vault** | Multi-cloud secrets with dynamic credentials |
| **Kubernetes Secrets** | Pod-level secrets (use with external secrets operator) |

## Security Principles

- **Never hardcode** secrets in source code, configuration files, or IaC.
- **Rotate regularly** — Automate rotation with provider-specific mechanisms.
- **Least privilege** — Grant access only to the services that need each secret.
- **Audit access** — Enable logging for all secret access events.
- **Encrypt at rest** — Use KMS-managed encryption keys.

## CI/CD Authentication

| Platform | Recommended Approach |
|---|---|
| **GitHub Actions** | OIDC for cloud providers, encrypted secrets for other values |
| **GitLab CI** | Vault integration or CI/CD variables with masked/protected flags |
| **Bitbucket** | Repository or workspace-level secure variables |

## Connected Skills

- `eversis-implementing-ci-cd` — Secrets in CI/CD pipelines.
- `eversis-implementing-kubernetes` — Secrets in Kubernetes workloads.
- `eversis-implementing-terraform-modules` — Secrets in Terraform configurations.
