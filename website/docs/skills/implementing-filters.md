---
sidebar_position: 42
title: Implementing Filters
---

# Implementing Filters

**Folder:** `.cursor/skills/eversis-implementing-filters/`  
**Used by:** Software Engineer on filterable **list** tasks (when stack policy allows)

URL-synced filter lists for **Next.js** with shareable query state, aligned to REST list APIs. Headless patterns: filter schema, serialize/deserialize, `useFilters`-style hooks, `push` vs `replace` navigation.

:::warning Stack-specific
**Do not load** in Liferay/OData portals, static marketing sites, or when `eversis-project-stack.mdc` excludes this skill. Read **Agent skills policy** first.
:::

## When to use

- New public or admin **list page** with filters in the **URL** (bookmarkable / shareable).
- Next.js **App Router** + Nest (or REST) with flat Zod list queries **or** bracket notation (`filter[field]=value`).
- Refactoring duplicated `*-public-list-url.ts` helpers into a shared pattern.

## When NOT to use

- Liferay Headless OData `filter` strings, Elasticsearch facet search, bespoke Pages Router facet utilities — follow **project** `docs/context/`.
- Client-only filters intentionally kept in React state (many panel admin lists).
- Backend-only list endpoint work without URL — use `eversis-implementing-backend` (no dedicated docs page yet).

## API variants

| Variant | URL shape | Backend |
| --- | --- | --- |
| **Bracket notation** | `filter[field]=value`, `sort[field]=ASC` | See skill § Variant A |
| **Nest flat + Zod** | `city=Warsaw&page=1&sortBy=createdAt` | Shared `*ListQuerySchema` — see `references/nestjs-flat-params.md` |

## References (in skill package)

- `references/nextjs-patterns.md` — App Router (preferred)
- `references/nestjs-flat-params.md` — Nest + Zod monorepos
- `references/react-patterns.md` — React Router (legacy)

## Connected skills

- `eversis-implementing-backend` — list endpoints (skill package; no docs page yet)
- [Implementing Frontend](./frontend-implementation) — filter UI components
- [Writing Hooks](./writing-hooks) — hook conventions
- [Framework reference](../framework) — Agent skills policy
