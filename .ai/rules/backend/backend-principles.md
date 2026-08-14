# Backend principles (seed)

> **Seed** from skill `eversis-implementing-backend` (guiding principles). Full procedures, patterns, and playbooks arrive in **TASK-520**.

## Guiding principles

| Principle | Application |
|-----------|-------------|
| **SRP** | Each module has one reason to change. Separate HTTP/transport, business logic, and data access. |
| **DRY** | Extract shared validation, mapping, and query logic; do not copy-paste across endpoints. |
| **KISS** | Prefer simple, readable solutions; avoid premature abstractions. |
| **YAGNI** | Implement what is needed now; do not build speculative infrastructure. |
| **Pragmatism** | Follow patterns when they add value; document intentional deviations. |

## Structure preference

Organize by **domain / feature** (vertical slice) when the codebase supports it, rather than only by technical layer — keep related handlers, services, and data access for a feature close together.

Prefer project patterns in `docs/context/` and the consumer stack over inventing a new layout.
