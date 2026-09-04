---
sidebar_position: 23
title: Observability Implementation
---

# Observability Implementation

**Folder:** `.cursor/skills/eversis-implementing-observability/`
**Used by:** DevOps Engineer

Provides patterns for logging, monitoring, alerting, and distributed tracing across services.

## Three Pillars

| Pillar | Purpose | Tools |
|---|---|---|
| **Metrics** | Quantitative system health measurement | Prometheus, CloudWatch, Datadog |
| **Logs** | Structured event records for debugging | ELK Stack, CloudWatch Logs, Loki |
| **Traces** | Request flow across service boundaries | Jaeger, Zipkin, AWS X-Ray, OpenTelemetry |

## Alerting Guidelines

| Severity | Response Time | Example |
|---|---|---|
| **Critical** | Immediate (page) | Service down, data loss risk |
| **Warning** | Within hours | Disk >80%, elevated error rate |
| **Info** | Next business day | Deployment completed, scaling event |

## Structured Logging

- Use JSON format for machine-parseable logs.
- Include correlation IDs for request tracing.
- Log at appropriate levels (ERROR, WARN, INFO, DEBUG).
- Never log sensitive data (credentials, PII).

## Dashboard Design

- Start with the RED method: Rate, Errors, Duration.
- Add business-specific KPIs and SLO tracking.
- Use consistent layouts across services for familiarity.

## Connected Skills

- `eversis-implementing-kubernetes` — Monitoring Kubernetes workloads.
- `eversis-technical-context-discovering` — Discover existing monitoring patterns.
