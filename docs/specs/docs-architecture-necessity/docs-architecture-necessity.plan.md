# Remove all Jira/TASK-nnn references from docs/architecture — Plan

Approved research: [`docs-architecture-necessity.research.md`](./docs-architecture-necessity.research.md) (Q1 = necessary/keep folder, Q3 = no move, Q4 = full removal of every `TASK-nnn` mention — not only hyperlinks — locked 2026-08-14).

## Goal

Make `docs/architecture/` fully neutral and independent of the internal Jira tracker: remove every `TASK-nnn` occurrence (hyperlinked or bare) across the 4 affected files, preserving any real information the ticket number was standing in for by writing it into the file directly.

## Replacement principle

Two patterns cover nearly every occurrence:

1. **Reuse an already-present neutral label.** Several header lines already carry a parallel, non-Jira label right next to the ticket ID (e.g. `**Story:** [TASK-523](...) (Work Stream 2 / Story 2.1)` — "Work Stream 2 / Story 2.1" is sitting there unused). Drop the ticket ID/link, keep the existing label.
2. **Name the artifact/feature the ticket denoted.** Most inline mentions already state the delivered artifact in the same sentence (e.g. "Generator: **TASK-524** (`adapters/cursor/`)") — the ticket ID becomes pure redundant noise once the artifact name is present; drop it. Where no artifact name is adjacent, substitute a short descriptive phrase per the mapping table below.

## Mapping table (used throughout)

| Old ID | Neutral replacement |
|---|---|
| `TASK-523` | *(self-referential — this document, `adapter-mapping.md`)* |
| `TASK-524` | the Cursor generator (`adapters/cursor/`) |
| `TASK-525` | the OpenCode placeholder (`adapters/opencode/`) |
| `TASK-526` | the Claude Code generator (`adapters/claude/`) |
| `TASK-527` | the adapter sync CLI (`adapters/sync.mjs`) |
| `TASK-528` | *(self-referential — this document, `isolation-strategy.md`)* |
| `TASK-529` | the ignore triad |
| `TASK-530` | monorepo area glob scoping |
| `TASK-531` | the AGENTS.md standard |
| `TASK-532` | the AGENTS.md reference fill (this repo) |
| `TASK-535` | MCP skill resolve |
| `TASK-539` | the multi-agent packaging closeout |
| `TASK-541` | docs + validation |
| `TASK-542` | empirical WNF-03 validation |
| `TASK-598` | Cursor thin slash commands |

## Files in scope

| File | Mentions (verified at plan time) |
|---|---|
| `docs/architecture/adapter-mapping.md` | 30 |
| `docs/architecture/isolation-strategy.md` | 19 |
| `docs/architecture/agents-md-standard.md` | 6 |
| `docs/architecture/requirements-traceability.md` | 6 (one per table row) |
| `docs/architecture/install-selection.md` | 0 — no change |

`docs/architecture/` itself is **not** moved or removed (Q3, locked).

## Phases

### Phase 1 — `adapter-mapping.md`

**Header (lines 4-5):**
```diff
-**Story:** [TASK-523](https://eversis.atlassian.net/browse/TASK-523) (Work Stream 2 / Story 2.1)  
+**Story:** Work Stream 2 / Story 2.1  
-**Audience:** Implementers of Cursor (TASK-524), Claude Code (TASK-526), OpenCode placeholder (TASK-525), and sync tooling (TASK-527)
+**Audience:** Implementers of the Cursor generator, the Claude Code generator, the OpenCode placeholder, and the adapter sync CLI
```

**Diagram (line 20)** and **emit-matrix cells (lines 23, 43-45)**: drop parenthetical ticket refs, keep the artifact names already present in the same line (e.g. "Generator: **TASK-524** + **TASK-598** (`adapters/cursor/`)" → "Generator: `adapters/cursor/` (Cursor generator + thin slash commands)"; "resolve via MCP after TASK-535" → "resolve via MCP skill resolution").

**§4.2/4.3 (lines 132-133, 178, 193, 195):** drop `(TASK-524)` / `(TASK-526)` parentheticals — the surrounding sentence already names the artifact in every case (e.g. `**File (TASK-524):**` → `**File:**`; `### 4.3 Generator expectations (TASK-524)` → `### 4.3 Generator expectations`).

**§6 OpenCode (lines 247, 256, 279, 280, 284, 289):** drop `(TASK-525)` parentheticals; for line 280 drop the redundant `(TASK-528)` (the `[isolation strategy]` link right before it already covers the reference) and keep `(**TASK-529**)` → "triad materialized at repo root" (drop ID, artifact already named); line 284 drop `(**TASK-531**)` / `**TASK-532**` — the doc names are already linked/stated.

**§7 maturity legend (line 310):** drop all 4 ticket refs in this paragraph (`TASK-524`, `TASK-526`, `TASK-528`, `TASK-529`, `TASK-530`) — every artifact is already named (`adapters/cursor/`, `adapters/claude/`, `isolation-strategy.md`, `.claude/settings.json permissions.deny`); for the trailing "monorepo path globs remain **TASK-530**" replace with "monorepo path globs remain a follow-up (see isolation strategy §8.2)".

**§8 "Sibling stories and out of scope" table (lines 316-328) — full rewrite**, renaming the ID column to descriptive items:

```diff
-| Story | Responsibility |
+| Item | Responsibility |
 |-------|----------------|
-| **TASK-523 (this)** | Mapping specification (this file) + pointer from `.ai/README.md` |
-| **TASK-524** | Cursor generator, `adapters/cursor/`, live `rule-map.yaml`, replace framework symlinks (**done** in this repo for mapped rules) |
-| **TASK-526** | Claude `CLAUDE.md` generator (`adapters/claude/`) — **done** in this repo |
-| **TASK-525** | OpenCode placeholder materialization from §6 (**done** — `adapters/opencode/` + root `opencode.jsonc`) |
-| **TASK-527** | Sync / generation CLI — **done**: `node adapters/sync.mjs` (`--check`, optional `--out`; npm `sync:adapters` / `sync:adapters:check`) |
-| **TASK-535** | MCP skill resolve from `.ai/skills/` |
-| **TASK-528** | Canonical isolation strategy — [`isolation-strategy.md`](./isolation-strategy.md) (**done** in this story's delivery) |
-| **TASK-529** | Ignore triad materialization (root `.cursorignore` / `.claudeignore` / `.opencodeignore`) — **done** |
-| **TASK-530** | Monorepo area glob scoping (consume isolation strategy) |
-| **TASK-531** | AGENTS.md standard + template — [`agents-md-standard.md`](./agents-md-standard.md) |
-| **TASK-532** | Reference `AGENTS.md` fill for this repository |
+| **Adapter mapping (this document)** | Mapping specification (this file) + pointer from `.ai/README.md` |
+| **Cursor generator** | `adapters/cursor/`, live `rule-map.yaml`, replace framework symlinks (**done** in this repo for mapped rules) |
+| **Claude Code generator** | `CLAUDE.md` generator (`adapters/claude/`) — **done** in this repo |
+| **OpenCode placeholder** | Materialization from §6 (**done** — `adapters/opencode/` + root `opencode.jsonc`) |
+| **Adapter sync CLI** | Sync / generation CLI — **done**: `node adapters/sync.mjs` (`--check`, optional `--out`; npm `sync:adapters` / `sync:adapters:check`) |
+| **MCP skill resolve** | Resolve skills from `.ai/skills/` via MCP |
+| **Isolation strategy** | Canonical cross-tool isolation — [`isolation-strategy.md`](./isolation-strategy.md) (**done**) |
+| **Ignore triad** | Materialization (root `.cursorignore` / `.claudeignore` / `.opencodeignore`) — **done** |
+| **Monorepo area glob scoping** | Consumes isolation strategy |
+| **AGENTS.md standard** | Standard + template — [`agents-md-standard.md`](./agents-md-standard.md) |
+| **AGENTS.md reference fill** | Reference `AGENTS.md` fill for this repository |
```

**Line 330:** drop `TASK-523` / `TASK-598` refs — "Out of scope for the original TASK-523 mapping-only delivery" → "Out of scope for this mapping-only document"; "emit matrix (TASK-598)" → "emit matrix".

**§9 checklist (lines 338-339):** drop `TASK-526` / `TASK-525` parentheticals — artifact paths already stated.

### Phase 2 — `isolation-strategy.md`

**Header (lines 4-5):** same pattern as Phase 1 — drop the link, keep "Work Stream 3 / Story 3.1"; drop the 3 ticket refs in the Audience line (artifacts already named).

**§1 table (lines 21-22):** already speced in the prior (superseded) plan revision:
```diff
-| **Cross-tool packaging** | ... | [TASK-529](https://eversis.atlassian.net/browse/TASK-529) ignore triad |
+| **Cross-tool packaging** | ... | Ignore triad — see §8.1 below |
-| **Area / path scoping** | ... | [TASK-530](https://eversis.atlassian.net/browse/TASK-530) (+ install profiles 5.3) |
+| **Area / path scoping** | ... | Monorepo area glob scoping — see §8.2 below (+ install profiles 5.3) |
```

**Body (lines 71, 106, 108, 144, 151, 159):** drop each bare ticket ref, replacing with the artifact name or a `§8.x` same-document pointer where the ID's meaning lives in a later section (e.g. line 71 "Exact ignore syntax lands in TASK-529" → "Exact ignore syntax lands in the ignore triad (§8.1)"; line 151 "is **TASK-542**, not this document" → "is tracked separately (§8.3), not this document").

**Section headings (lines 172, 193) — drop the embedded ID:**
```diff
-### 8.1 TASK-529 — Synchronized ignore files
+### 8.1 Synchronized ignore files
-### 8.2 TASK-530 — Monorepo area glob scoping
+### 8.2 Monorepo area glob scoping
```
(Plain-text `§8.1`/`§8.2` references elsewhere still resolve correctly — this plan never relies on generated heading-anchor slugs, consistent with the prior plan revision's reasoning.)

**§8.1/§8.2 body (lines 174, 176):** drop `(TASK-529)` / `(consumer / TASK-530)` — replace the latter with `(consumer follow-up — see §8.2)`.

**§8.3 "Related" table (lines 206-209) — full rewrite:**
```diff
-| Story | Role |
+| Item | Role |
 |-------|------|
-| **TASK-531** | `AGENTS.md` standard + template — [`agents-md-standard.md`](./agents-md-standard.md) |
-| **TASK-532** | Reference `AGENTS.md` fill for this repository (orientation layer body) |
-| **TASK-542** | Empirical WNF-03 validation on a consumer install; migration notes as needed |
-| **TASK-523** | Adapter emit mapping — see [`adapter-mapping.md`](./adapter-mapping.md); ignore deferred here |
+| **AGENTS.md standard** | `AGENTS.md` standard + template — [`agents-md-standard.md`](./agents-md-standard.md) |
+| **AGENTS.md reference fill** | Reference `AGENTS.md` fill for this repository (orientation layer body) |
+| **Empirical WNF-03 validation** | On a consumer install; migration notes as needed |
+| **Adapter mapping** | Adapter emit mapping — see [`adapter-mapping.md`](./adapter-mapping.md); ignore deferred here |
```

**§9 "Sibling stories" table (lines 217-219) — full rewrite:**
```diff
-| This document (`isolation-strategy.md`) | **TASK-528** deliverable |
-| Root ignore triad materialization | **TASK-529** — **done** (root triad + §8.1 checklist) |
-| Live monorepo path globs / profile wiring | **TASK-530** |
+| This document (`isolation-strategy.md`) | Canonical isolation strategy specification |
+| Root ignore triad materialization | **done** (root triad + §8.1 checklist) |
+| Live monorepo path globs / profile wiring | Follow-up (§8.2) |
```

### Phase 3 — `agents-md-standard.md`

```diff
-Normative standard for the root **`AGENTS.md`** orientation file in Agent Collections (TASK-531 / BRD WF-04).
+Normative standard for the root **`AGENTS.md`** orientation file in Agent Collections (BRD WF-04).

-**Related:** ... Reference fill for this repository is **TASK-532** (out of scope here). ...
+**Related:** ... Reference fill for this repository is out of scope here (see the repository's own `AGENTS.md`). ...

-For future installer / bootstrap (Work Stream 5; **not implemented in TASK-531**):
+For future installer / bootstrap (Work Stream 5; **not implemented in this standard**):

-## Boundary with TASK-532
+## Boundary with the AGENTS.md reference fill

-| Story | Delivers |
+| Item | Delivers |
 |-------|----------|
-| **TASK-531** (this) | Standard + template + root `AGENTS.md` **restructured** to template shape with placeholders / short pointers |
-| **TASK-532** | Complete **reference** `AGENTS.md` for `agent-collections` (filled areas, maintainer roles, install entry points) |
+| **This standard** | Standard + template + root `AGENTS.md` **restructured** to template shape with placeholders / short pointers |
+| **AGENTS.md reference fill** | Complete **reference** `AGENTS.md` for `agent-collections` (filled areas, maintainer roles, install entry points) |
```

### Phase 4 — `requirements-traceability.md`

Full table rewrite — rename "Story / wave" column to "Wave", drop every ticket ID, keep the wave labels (already neutral, framework-native) and describe any ID-only cell with its meaning from the mapping table:

```diff
-| ID | Intent (summary) | Primary docs | Story / wave |
+| ID | Intent (summary) | Primary docs | Wave |
 |----|------------------|--------------|--------------|
-| **WF-01** | ... | ... | Waves A–C; docs TASK-541 |
+| **WF-01** | ... | ... | Waves A–C; docs + validation |
-| **WF-02** | ... | ... | Wave C; TASK-541 |
+| **WF-02** | ... | ... | Wave C; docs + validation |
-| **WF-03** | ... | ... | Wave C; TASK-541 |
+| **WF-03** | ... | ... | Wave C; docs + validation |
-| **WF-04** | ... | ... | Waves B–D; TASK-539 |
+| **WF-04** | ... | ... | Waves B–D; multi-agent packaging closeout |
-| **WF-05** | ... | ... | Framework-wide; TASK-541 |
+| **WF-05** | ... | ... | Framework-wide; docs + validation |
-| **WNF-02** | ... | ... | TASK-528/529; pilot TASK-542 |
+| **WNF-02** | ... | ... | Isolation strategy + ignore triad; pilot empirical validation |
-| **WNF-03** | ... | ... | TASK-542 |
+| **WNF-03** | ... | ... | Empirical validation (pilot) |
```

(`...` = "Intent (summary)" and "Primary docs" columns unchanged — only the last column and header are edited.)

### Phase 5 — Verify

1. `grep -rn "TASK-[0-9]"` across `docs/architecture/` → expect **no output**.
2. `grep -rn "atlassian.net"` across `docs/architecture/` → expect **no output** (already required, re-confirmed here).
3. Re-read all 4 edited files in full — confirm every table still has matching column counts, every heading still makes sense standalone, no dangling "see below" references point at a now-renamed section.
4. `git diff --stat` — confirm only the 4 files changed; `install-selection.md` and everything outside `docs/architecture/` untouched.

## Acceptance checks

- [ ] Zero `TASK-[0-9]` matches remain anywhere in `docs/architecture/`.
- [ ] Zero `eversis.atlassian.net` matches remain anywhere in `docs/architecture/`.
- [ ] All 4 renamed tables (`adapter-mapping.md` §8, `isolation-strategy.md` §8.3 + §9, `agents-md-standard.md` boundary table, `requirements-traceability.md` main table) have their ID/Story column replaced with descriptive items, no information lost (every row still distinguishable and traceable to a real artifact).
- [ ] Section headings `### 8.1` / `### 8.2` in `isolation-strategy.md` no longer embed a ticket ID.
- [ ] `install-selection.md` byte-identical to before (no changes).
- [ ] `docs/architecture/` folder still exists with all 5 original files (Q3 — no move, no deletion).
- [ ] No unrelated content changed outside `docs/architecture/`.

## Out of scope

- Moving or deleting `docs/architecture/` (Q3, locked: no move).
- Any change to `CHANGELOG.md`, `README.md`, `AGENTS.md`, `.ai/README.md`, website docs, or `adapters/*/README.md` — none of them are inside `docs/architecture/`; their own `TASK-nnn` usage (e.g. `CHANGELOG.md`'s delivery-history entries) is a separate concern not raised in this analysis.
- `docs/specs/*` historical research/plan records that mention `docs/architecture` paths or `TASK-nnn` — gitignored, local-only, out of the public tree, not touched.
