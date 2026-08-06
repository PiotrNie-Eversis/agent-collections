---
sidebar_position: 22
title: Terraform Modules
---

# Terraform Modules

**Folder:** `.cursor/skills/eversis-implementing-terraform-modules/`
**Used by:** DevOps Engineer

Provides patterns for building reusable Terraform modules for AWS, Azure, and GCP infrastructure following IaC best practices.

## Module Structure

```
modules/
  <module-name>/
    main.tf          # Core resources
    variables.tf     # Input variables with descriptions and defaults
    outputs.tf       # Output values for consumers
    versions.tf      # Provider and Terraform version constraints
    README.md        # Usage documentation
```

## Design Principles

- **Composable** — Modules should be combined to build larger systems.
- **Configurable** — Use variables for all environment-specific values.
- **Documented** — Every variable and output has a description.
- **Versioned** — Pin module versions in consumers; use semantic versioning.

## Naming & Tagging

| Convention | Example |
|---|---|
| **Resources** | `<project>-<env>-<service>-<resource>` |
| **Variables** | Snake case with descriptive names |
| **Tags** | `Project`, `Environment`, `Team`, `CostCenter`, `ManagedBy` |

## Safety

- Always run `terraform plan` before `terraform apply`.
- Use remote state with locking (S3 + DynamoDB, GCS, Azure Blob).
- Enable `prevent_destroy` lifecycle rules for critical resources.
- Include cost estimates in every proposal.

## Connected Skills

- `eversis-optimizing-cloud-cost` — Cost estimation and optimization.
- `eversis-managing-secrets` — Secure credential management in Terraform.
