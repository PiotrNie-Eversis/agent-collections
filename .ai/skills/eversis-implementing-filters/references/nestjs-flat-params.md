# Nest.js Flat List Query Patterns

Nest.js + shared Zod contract patterns for `eversis-implementing-filters`. Load when the monorepo uses flat camelCase query params (not bracket `filter[field]` notation).

## Table of Contents

- [Shared contracts](#shared-contracts)
- [Nest controller](#nest-controller)
- [URL alignment](#url-alignment)
- [Multi-value and JSON params](#multi-value-and-json-params)
- [Anti-patterns](#anti-patterns)

## Shared contracts

Define list queries once in a shared package (e.g. `libs/contracts`):

```typescript
import { z } from "zod";

export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const offersListQuerySchema = paginationSchema.extend({
  q: z.string().optional(),
  city: z.string().optional(),
  sortBy: z.enum(["createdAt", "relevance"]).default("relevance"),
  sortOrder: z.enum(["asc", "desc"]).default("asc"),
});
```

Frontend filter schema **property names must match** Zod keys used in URLs and API clients.

## Nest controller

```typescript
@Get()
list(@Query() query: unknown) {
  const parsed = offersListQuerySchema.parse(query);
  return this.service.list(parsed);
}
```

Parse at the boundary — services receive typed, validated input.

## URL alignment

Frontend serialize/deserialize should emit the same keys the schema expects:

| Filter state (TS) | URL | API query |
| --- | --- | --- |
| `{ city: "Warsaw", page: 2 }` | `?city=Warsaw&page=2` | identical |

Use debounced `router.replace` in Next.js App Router when syncing UI → URL (see `nextjs-patterns.md`).

Reuse project helpers (`*-public-list-url.ts`) when they already encode canonical URL strings.

## Multi-value and JSON params

| Pattern | URL | Zod |
| --- | --- | --- |
| Repeated keys | `?tag=a&tag=b` | `z.union([z.string(), z.array(z.string())])` + normalize to array |
| CSV | `?tags=a,b` | `z.string().transform(s => s.split(","))` |
| JSON blob | `?registryFilters=[...]` | `z.string().transform(JSON.parse).pipe(z.array(...))` |

Document project-specific encodings in `docs/context/` — do not invent new encodings without plan approval.

## Anti-patterns

| Anti-pattern | Instead do |
| --- | --- |
| Bracket `filter[field]` in URL when API expects flat keys | One variant per feature — match contracts |
| Duplicate query types in web and api | Single Zod schema in shared contracts |
| Parsing query manually in service | `schema.parse` in controller |
| URL keys that differ from API keys | Same names end-to-end |

**Backend list implementation details** → `eversis-implementing-backend` (repositories, pagination SQL).
