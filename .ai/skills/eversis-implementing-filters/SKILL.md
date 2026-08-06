---
name: eversis-implementing-filters
user-invocable: false
description: "URL-synced filter lists for Next.js (App Router preferred) with shareable query state aligned to REST list APIs. Use when AC requires public/admin list pages with filters persisted in the URL and a defined list-query contract. Do NOT use for Liferay/OData portals, Next Pages Router legacy facet systems, static marketing sites, client-only filter state, panel lists that intentionally omit URL sync, or when eversis-project-stack.mdc excludes this skill. Prefer existing repo helpers in docs/context/ before inventing new hooks."
---

# Implementing Filters

Provides patterns for type-safe URL filter synchronization — schema definition, serialize/deserialize layers, router-bound hooks, and push/replace navigation strategies.

## When to use / When NOT to use

| Use this skill | Do NOT use |
| --- | --- |
| New or refactored **filterable list** with **shareable URL** | Liferay Headless **OData** `filter` strings, Elasticsearch facet URLs, bespoke `generateRouterQuery` — follow **project patterns** |
| Next.js **App Router** + `useSearchParams` / `router.replace` | Marketing sites with no list API; filters only in `useState` |
| Nest (or REST) list API with **documented flat or bracket** query contract | Task keywords alone ("filter", "search") without stack policy + plan |
| Align URL serialize layer with `libs/contracts` Zod schemas | Forcing bracket notation `filter[field]` when project uses flat camelCase params |

**Before Step 1:** Read **`eversis-project-stack.mdc` § Agent skills policy** and **`docs/context/*.md`**. Reuse existing URL helpers in the repo when present.

## Table of Contents

- [Principles](#principles)
- [Filter Implementation Process](#filter-implementation-process)
- [Serialization Quick Reference](#serialization-quick-reference)
- [API Contract](#api-contract)
  - [Variant A — Bracket notation (nested query params)](#variant-a--bracket-notation-nested-query-params)
  - [Variant B — Nest flat query + Zod (common Eversis consumer)](#variant-b--nest-flat-query--zod-common-eversis-consumer)
  - [Backend Considerations](#backend-considerations)
- [Filter Quality Checklist](#filter-quality-checklist)
- [Anti-Patterns](#anti-patterns)
- [Framework-Specific Patterns](#framework-specific-patterns)
- [Connected Skills](#connected-skills)

<principles>

<url-is-the-source-of-truth>
Filter state lives in the URL, not in component state. The URL is the single source of truth — components derive their state by parsing the URL. This enables shareable links, back/forward navigation, and SSR hydration without state mismatch. Never store canonical filter state in `useState` or a store and then sync it to the URL — read from the URL, write to the URL.
</url-is-the-source-of-truth>

<path-vs-query-golden-rule>
If removing a parameter changes what page or resource you are looking at, it belongs in the path. If removing it just narrows or broadens the same list, it belongs in a query string. Path = identity; query string = modifier. Category hierarchies go in the path (`/products/shoes/running`). Filters, sort, pagination, and search terms go in query strings (`?filter[color]=blue&sort[price]=ASC&page=2`).
</path-vs-query-golden-rule>

<type-safe-serialization>
Define a TypeScript schema for every filter set. Parse URL params through the schema on read (deserialize), and serialize through the schema on write. **Serialization shape follows the API contract** (bracket notation for DataGrid-style list APIs; flat camelCase for many Nest+Zod monorepos). Never pass raw `string | null` from `searchParams` into application code — always validate and coerce to the schema type. Invalid or missing values fall back to schema defaults.
</type-safe-serialization>

<api-first-serialization>
The URL serialization format must match the API it talks to. **Bracket notation** (`filter[field]=value`) suits list APIs that expect nested filter keys. **Flat camelCase** (`status=active&page=1`) is common in Nest + shared Zod `*ListQuerySchema` packages. Adapt only the serialize/deserialize functions — the filter schema, hook shape (`{ filters, updateFilters, resetFilters }`), and navigation strategy stay the same.
</api-first-serialization>

</principles>

## Filter Implementation Process

Use the checklist below and track progress:

```
Progress:
- [ ] Step 0: Confirm stack policy, existing repo URL helpers, and API contract variant
- [ ] Step 1: Define the filter schema
- [ ] Step 2: Choose the URL structure
- [ ] Step 3: Implement serialization/deserialization
- [ ] Step 4: Create the filter sync hook
- [ ] Step 5: Wire up navigation strategy
```

**Step 0: Confirm scope and contract**

- Stack policy allows this skill (`eversis-project-stack.mdc` § Agent skills policy).
- Acceptance criteria require **shareable URL** filter state (not client-only unless migrating to URL).
- Identify API variant: **bracket notation** vs **Nest flat Zod** vs project-specific — see [API Contract](#api-contract).
- Search codebase for existing helpers (`*-public-list-url.ts`, `generateRouterQuery`, etc.) — **extend, do not replace** without approval.

**Step 1: Define the filter schema**

Define a TypeScript type or interface for each filter set. Every filter parameter must have an explicit type and a default value.

Supported filter parameter types:

| Type           | Example                              | Serialized                                                          |
| -------------- | ------------------------------------ | ------------------------------------------------------------------- |
| Single value   | `color: string`                      | `filter[color]=blue`                                                |
| Multi-select   | `tags: string[]`                     | `filter[tags]=a&filter[tags]=b` (repeated bracket key)              |
| Range          | `priceMin: number; priceMax: number` | `filter[price_min]=10&filter[price_max]=50` (separate bracket keys) |
| Boolean toggle | `inStock: boolean`                   | `filter[in_stock]=true`                                             |
| Numeric        | `page: number`                       | `page=2` (top-level, not bracketed)                                 |

Rules:

- Filters use bracket notation: `filter[field_name]=value`. Range filters use separate bracket keys: `filter[price_min]=10&filter[price_max]=50`.
- Use `snake_case` for bracket key names — readable in URLs.
- Use `camelCase` for TypeScript property names.
- Define defaults for every param — defaults are used when a param is absent from the URL.

Example schema shape:

```typescript
type SortDirection = "ASC" | "DESC";

interface ProductSort {
  field: "relevance" | "price" | "createdAt";
  direction: SortDirection;
}

interface ProductFilters {
  color: string; // default: ""                                  → filter[color]=blue
  tags: string[]; // default: []                                 → filter[tags]=a&filter[tags]=b
  priceMin: number; // default: 0                                → filter[price_min]=0
  priceMax: number; // default: 10000                            → filter[price_max]=10000
  inStock: boolean; // default: false                            → filter[in_stock]=true
  sort: ProductSort; // default: { field: "relevance", direction: "ASC" } → sort[relevance]=ASC
  page: number; // default: 1                                    → page=1
}
```

**Step 2: Choose the URL structure**

Apply the path-vs-query golden rule to classify each piece of your URL:

| Element                 | URL part     | Example                               | Rationale                                        |
| ----------------------- | ------------ | ------------------------------------- | ------------------------------------------------ |
| Resource category       | Path segment | `/products/shoes`                     | Removing "shoes" changes what you are looking at |
| Subcategory / hierarchy | Path segment | `/products/shoes/running`             | Still defines identity                           |
| Filter (color, size)    | Query string | `?filter[color]=blue&filter[size]=10` | Removing it shows the same page, broader list    |
| Sort order              | Query string | `?sort[price]=ASC`                    | Display modifier, not identity                   |
| Pagination              | Query string | `?page=2&limit=20`                    | Display modifier                                 |
| Search term             | Query string | `?search=lightweight`                 | Display modifier                                 |

**API alignment rule**: The URL serialization must match the API it communicates with. For APIs that use bracket notation, serialize as `filter[field]=value`. For APIs with different conventions, adapt the serialize/deserialize functions to match the external format. Common external patterns:

| External API Pattern   | Example                    | Adaptation                                                          |
| ---------------------- | -------------------------- | ------------------------------------------------------------------- |
| Flat keys              | `color=blue&price_min=10`  | Serialize filters as top-level params without `filter[...]` wrapper |
| Comma-separated values | `colors=blue,red,green`    | Join arrays with commas instead of repeated keys                    |
| JSON-encoded           | `filters={"color":"blue"}` | JSON-stringify the filter object into a single param                |
| Custom prefix          | `f_color=blue&f_size=10`   | Use the API's prefix convention in serialize/deserialize            |

The filter schema, hook shape (`{ filters, updateFilters, resetFilters }`), and navigation strategy (push/replace) are API-agnostic — only the serialization layer changes per API.

**Step 3: Implement serialization/deserialization**

Build two functions tied to the filter schema: one to serialize the typed filter object into `URLSearchParams`, and one to deserialize `URLSearchParams` back into the typed filter object.

**Serialize** (typed object → `URLSearchParams`):

- Iterate over schema keys.
- Skip params whose value matches the default — keeps the URL clean.
- Wrap filter params in bracket notation: `filter[field_name]=value`. Use `snake_case` inside brackets.
- Ranges use separate bracket keys: `filter[price_min]=10&filter[price_max]=50`.
- Arrays use repeated bracket keys: `filter[tags]=a&filter[tags]=b`.
- Sort params use `sort[field]=direction` format.
- Booleans serialize as `"true"` / `"false"`.

**Deserialize** (`URLSearchParams` → typed object):

Deserialization is a two-phase pipeline:

1. **Extract bracket keys** — parse `filter[...]` and `sort[...]` keys from `URLSearchParams`, producing a flat key-value object with `camelCase` property names. Handle repeated bracket keys (`getAll()`) for multi-value filters and separate range keys (`filter[price_min]`, `filter[price_max]`). This phase is URL-format-aware but type-unaware.
2. **Validate and coerce** — pass the flat object through the filter schema. Coerce types (`Number()` for numerics, `=== 'true'` for booleans), apply defaults for missing params, and reject out-of-range or malformed values by falling back to schema defaults. Never propagate garbage into application code.

> **Prefer schema validation**: Use a library like [Zod](https://zod.dev) or [Valibot](https://valibot.dev) for phase 2 — define a schema that mirrors the filter interface, with `.default()` for fallbacks and `.coerce` for type conversions. The schema validates domain types (`color: string`, `priceMin: number`) without knowing anything about URL serialization format. Fall back to manual `Number()` / `=== 'true'` only when adding a validation library is not feasible.

Key rules:

- Bracket notation for all filter params: `filter[field]=value`.
- Repeated bracket keys for multi-value filters: `filter[field]=a&filter[field]=b`.
- Omit default values from URL — cleaner URLs, same result.
- Never trust raw URL params — always parse through the schema.

**Step 4: Create the filter sync hook**

Create a custom hook (e.g., `useFilters`) that connects the filter schema to the router. The hook:

1. Reads current URL search params via the router.
2. Deserializes them into the typed filter state using the schema.
3. Provides an `updateFilters(partial)` function that merges partial updates with current filters, serializes the result, and navigates.
4. Provides a `resetFilters()` function that navigates to the URL with all defaults (effectively clearing query params).

The hook accepts configuration:

- The filter schema defaults object.
- The serialization/deserialization functions.

The hook returns:

- `filters` — the current typed filter state, derived from the URL.
- `updateFilters(partial, options?)` — merges partial filter updates and navigates.
- `resetFilters()` — clears all filters back to defaults.

Framework binding:

| Framework        | Read params         | Navigate                               |
| ---------------- | ------------------- | -------------------------------------- |
| React Router v6+ | `useSearchParams()` | `setSearchParams()` or `useNavigate()` |

The hook must:

- Handle partial updates — merge incoming changes with current filter state, not replace entirely. Use flat properties for ranges (e.g., `priceMin`, `priceMax`) so that partial updates merge correctly with shallow spread.
- Be type-safe end-to-end — input partial → serialization → URL → deserialization → output typed.
- Derive state from the URL on every render — never cache filter state in local `useState`.

**Step 5: Wire up navigation strategy**

Choose `push` or `replace` navigation based on the type of filter change:

| Action                  | Strategy                                 | Rationale                                            |
| ----------------------- | ---------------------------------------- | ---------------------------------------------------- |
| Category toggle (major) | `push`                                   | User can press Back to undo                          |
| Sort change             | `push`                                   | Intentional user action, should be undoable          |
| Search-as-you-type      | `replace`                                | Don't flood history with every keystroke             |
| Pagination              | `push`                                   | User expects Back to go to previous page             |
| Filter toggle (facet)   | `push`                                   | User expects Back to undo filter                     |
| Debounced range slider  | `replace` during drag, `push` on release | Balance between history cleanliness and undo-ability |

The `updateFilters` function should accept an optional `{ replace?: boolean }` option. Default to `push`. Callers override to `replace` for as-you-type or continuous inputs.

```typescript
// Push (default) — for discrete filter actions
updateFilters({ color: "blue" });

// Replace — for as-you-type search input
updateFilters({ search: searchTerm }, { replace: true });
```

For debounced inputs (range sliders, search fields), use `replace` during rapid changes and `push` on the final committed value.

## Serialization Quick Reference

| TypeScript type                  | Serialized format                     | Deserialize with                |
| -------------------------------- | ------------------------------------- | ------------------------------- |
| `string`                         | `filter[key]=value`                   | Parse bracket key, `get()`      |
| `number`                         | `filter[key]=123`                     | Parse bracket key, `Number()`   |
| `boolean`                        | `filter[key]=true`                    | Parse bracket key, `=== 'true'` |
| `string[]`                       | `filter[key]=a&filter[key]=b`         | Parse bracket key, `getAll()`   |
| `keyMin: number; keyMax: number` | `filter[key_min]=1&filter[key_max]=9` | `Number()` for each key         |
| sort                             | `sort[field]=ASC`                     | Parse bracket key               |
| search                           | `search=text`                         | `get('search')`                 |
| pagination                       | `page=1&limit=20`                     | `get('page')`, `get('limit')`   |

## API Contract

Pick **one variant** per feature. URL serialize/deserialize must match what the list endpoint expects. List **endpoint design** (Nest controller, DTO, repository) → **`eversis-implementing-backend`**; URL/hooks → this skill.

### Variant A — Bracket notation (nested query params)

#### Query Parameter Structure

| Concern                   | Format                  | Example                                          |
| ------------------------- | ----------------------- | ------------------------------------------------ |
| Filters                   | `filter[field]=value`   | `filter[first_name]=Ewa`                         |
| Multi-value filter (OR)   | Repeated bracket key    | `filter[first_name]=Ewa&filter[first_name]=Adam` |
| Range filter              | Separate bracket keys   | `filter[price_min]=10&filter[price_max]=50`      |
| Pagination                | Top-level keys          | `page=1&limit=100`                               |
| Sort                      | `sort[field]=direction` | `sort[last_name]=ASC`                            |
| Full-text search          | Top-level key           | `search=test`                                    |

#### Filter Logic

- **Same field, multiple values → OR**; **different fields → AND**.
- Partial-text match: backend defines strategy (prefix, contains, fuzzy).

#### Example API Response Envelope

```typescript
interface ApiResponse<T> {
  meta: {
    pagination: { page: number; total: number; limit: number; totalPages: number };
    filter: Record<string, string | string[]>;
    sort: Record<string, "ASC" | "DESC">;
    search: string;
  };
  data: T[];
}
```

When `meta` echoes applied filters, verify it matches deserialized URL state.

### Variant B — Nest flat query + Zod (common Eversis consumer)

Typical in Next + Nest monorepos with shared `libs/contracts`:

| Concern | Format | Example |
| --- | --- | --- |
| Filters | Flat camelCase keys | `?status=active&city=Warsaw` |
| Multi-value | Repeated key or CSV | `?occupationCodeIn=a&occupationCodeIn=b` or `?tags=a,b` |
| Pagination | `page`, `limit` | `?page=1&limit=20` |
| Sort | `sortBy`, `sortOrder` | `?sortBy=createdAt&sortOrder=desc` |
| Search | `q` or `keyword` | `?q=engineer` |

**Rules:**

- Define `*ListQuerySchema` in shared contracts; parse in Nest with `schema.parse(query)`.
- URL serialize/deserialize must produce the **same key names** the API expects.
- Optional packed short links (e.g. base64 `q` param) are project-specific — document in `docs/context/`.

See `./references/nestjs-flat-params.md` and `./references/nextjs-patterns.md`.

### Backend Considerations

- **Pagination resets**: When filters change, reset the page parameter to 1 to avoid requesting pages beyond the new result set.
- **Filter echoing**: If the API returns applied filters in the response (e.g., in a `meta` object), compare them against the URL state to detect sync issues.

## Filter Quality Checklist

```
Filter:
- [ ] Filter schema defined with TypeScript types and defaults
- [ ] URL structure follows path-vs-query golden rule
- [ ] Serialization matches chosen API variant (bracket **or** flat — not both)
- [ ] If bracket notation: filters use `filter[field]=value`; sort uses `sort[field]=ASC|DESC`
- [ ] Serialization omits default values from URL
- [ ] Deserialization validates and coerces types
- [ ] Range filters use separate bracket keys (filter[price_min]=10&filter[price_max]=50)
- [ ] Multi-value filters use repeated bracket keys (OR logic)
- [ ] If external API, serialization adapted to match API's expected format
- [ ] Cross-field filters combine as AND
- [ ] Text search values contain only the raw search term — no backend-specific operators or wildcards
- [ ] Hook returns typed filter state, updateFilters, resetFilters
- [ ] Push/Replace strategy documented for each filter action
- [ ] Search-as-you-type inputs use Replace navigation
- [ ] No raw string params leak into application code
- [ ] Back/Forward navigation correctly restores filter state
- [ ] Shareable URL reproduces the exact filter state
- [ ] API response meta echoed back matches URL state
```

## Anti-Patterns

| Anti-Pattern                                                       | Instead Do                                                                                                            |
| ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| Storing filter state in `useState` and syncing to URL              | Derive filter state FROM the URL — URL is the source of truth                                                         |
| Using flat keys when API expects bracket notation | Match serialize layer to API — flat is valid when contract is Nest/Zod flat |
| Hardcoding filter params as magic strings          | Define a filter schema type and derive param names from it                  |
| Using `push` for search-as-you-type                                | Use `replace` to avoid flooding browser history                                                                       |
| Putting optional filters in path segments (`/products/color/blue`) | Put filters in query strings — path is for resource identity only                                                     |
| Serializing default values in URL (`?page=1&sort[relevance]=ASC`)  | Omit defaults — cleaner URLs, same behavior                                                                           |
| Parsing URL params without type coercion                           | Validate with a schema library (Zod, Valibot) or manually coerce: `Number()`, `=== 'true'`, with fallback to defaults |
| Building one monolithic filter hook for all pages                  | Create filter schemas per-page/per-feature, share the serialization utility                                           |
| Treating multi-value filter as AND                                 | Same-field repeated values are OR; different fields are AND                                                           |
| Ignoring API response `meta` object                                | Verify URL filter state matches what the backend echoed in `meta`                                                     |
| Using bracket notation when the external API expects flat keys     | Adapt serialization to match the API contract — bracket notation is one pattern, not a universal rule             |

## Framework-Specific Patterns

The patterns above are framework-agnostic. For framework-specific implementation guidance, load the appropriate reference:

- **Next.js App Router** (preferred): See `./references/nextjs-patterns.md` — `useSearchParams`, `router.push()`/`router.replace()`, debounced URL sync.
- **Nest + flat Zod list queries**: See `./references/nestjs-flat-params.md` — shared contracts, controller parse, URL alignment.
- **React Router v6+** (legacy): See `./references/react-patterns.md` — `setSearchParams()` hook binding.

## Connected Skills

- `eversis-implementing-backend` — list endpoint, DTO/Zod parse, repository query (not URL hooks)
- `eversis-implementing-frontend` — filter UI components consuming headless hook output
- `eversis-implementing-forms` — form-based filter UIs wired to `updateFilters`
- `eversis-writing-hooks` — hook composition and stable return shapes
- `eversis-technical-context-discovering` — project conventions before introducing new URL helpers
- `eversis-optimizing-frontend` — rendering optimization for filter-heavy pages
- `eversis-ensuring-accessibility` — accessible filter controls (keyboard, ARIA)
- `eversis-sql-and-database-understanding` — query performance behind list APIs
