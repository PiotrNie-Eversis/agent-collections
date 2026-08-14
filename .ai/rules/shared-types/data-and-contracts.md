# Data and contracts (seed)

> **Seed** from skill `eversis-sql-and-database-understanding` (guiding principles), framed for **shared types and data contracts**. Full SQL/ORM cookbooks arrive in **TASK-520**.

## Principles

- **Integrity first** — Enforce constraints at the data store where appropriate (nullability, uniqueness, foreign keys, checks). Do not rely only on application-level checks.
- **Schema as code** — Schema changes go through versioned migrations; avoid undocumented manual production edits.
- **Explicit over implicit** — Prefer explicit field lists and clear shared DTO / type contracts between packages; avoid opaque “grab everything” shapes in production paths.
- **Least privilege** — Application and service accounts should use only the permissions they need.
- **Measure before optimizing** — Diagnose real bottlenecks (e.g. explain plans) before adding indexes or rewriting queries.

Shared packages that expose types across frontend and backend should keep contracts stable, documented, and free of tool-specific UI assumptions.
