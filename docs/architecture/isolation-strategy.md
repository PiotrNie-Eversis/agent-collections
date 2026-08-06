# Cross-tool ignore and scoping strategy

**Status:** Canonical (committed)  
**Story:** [DHI-528](https://eversis.atlassian.net/browse/DHI-528) (Work Stream 3 / Story 3.1)  
**Audience:** Implementers of synchronized ignore files (DHI-529), monorepo area globs (DHI-530), install profiles (5.x), and later WNF-03 validation (DHI-542)

This document is the **single source of truth** for how Agent Collections isolates AI context in multi-tool, multi-area monorepos. It defines **what each tool indexes or excludes**, how **area profiles** map to path globs, and how to target **context reduction without losing project orientation**.

**Materialization** of ignore files and live path globs is **out of scope here** — see contracts in §8.

---

## 1. Purpose and two axes

Enterprise monorepos often install more than one AI tool and host more than one application area (for example a web app and an API). Without isolation, agents index unrelated trees, each other’s packaging, and heavy infrastructure — wasting tokens and confusing sessions.

Isolation has **two independent axes**:

| Axis | Meaning | Follow-on |
|------|---------|-----------|
| **Cross-tool packaging** | When more than one agent is installed, each tool must not index the others’ packaging surfaces | [DHI-529](https://eversis.atlassian.net/browse/DHI-529) ignore triad |
| **Area / path scoping** | Sessions can narrow to `frontend-scope`, `backend-scope`, or `fullstack` via path profiles — **independent of which tool(s) the user chose** | [DHI-530](https://eversis.atlassian.net/browse/DHI-530) (+ install profiles 5.3) |

```text
Monorepo (abstract reference layout)
  apps/web/**     packages/**     apps/api/**
        │               │               │
   area profile    light shared    area profile
        └───────┬───────┴───────┬───────┘
                ▼               ▼
      Installed agent(s) — any combination
      (Cursor and/or Claude Code and/or OpenCode placeholder)
      + cross-tool ignore when more than one tool is present
```

**Invariant:** Do **not** hard-code “Frontend must use Cursor” or “Backend must use Claude”. Teams may use one tool for everything, or any mix. Area profiles control **paths**; the installer / user controls **tools**.

---

## 2. Open-source naming rule

Agent Collections is intended for a **wide open-source audience**. Committed framework artifacts (this file, adapters, templates, README, website) must use **generic** path names only (`apps/web`, `apps/api`, `packages/*`, class names like “heavy infra”).

**Do not** embed internal or client monorepo names, private absolute paths, or workshop-only labels in framework documentation or examples. Consumer-specific mapping belongs in the consumer’s own docs or local-only specs — not in this repository’s published tree.

---

## 3. Reference layout (abstract)

Canonical layout for applying this strategy (and for Jira AC “reference layout”):

| Class | Abstract paths (examples) | Role |
|-------|---------------------------|------|
| Frontend app | `apps/web/**` | UI / client application |
| Backend app | `apps/api/**` | API / services / data access |
| Shared libraries | `packages/**` (narrow: types, UI kit, shared utils) | Reused by one or both apps |
| Light shared ops | `docs/**`, `scripts/**` | Orientation and runbooks (see §6) |
| Heavy infra | `charts/**`, database data dirs, reverse-proxy / mail / load-test stacks, large vendor dumps | Default **exclude** from application agents (see §6) |
| AI packaging | `.cursor/**`, `CLAUDE.md`, `opencode.json` / `opencode.jsonc`, `adapters/opencode/**` | Cross-tool ownership (see §4) |
| Framework core (when vendored) | `.ai/rules/**`, `.ai/skills/**`, `.ai/prompts/**` | Loaded via adapter / MCP / instructions — not as a full dump of every skill every session |
| Secrets / build | `.env*`, keys, `node_modules/`, `dist/`, `build/`, `.next/`, coverage | Always exclude from indexing |

### 3.1 Optional generic annex

Consumers rename folders freely. Map local names onto the abstract classes above (for example “our portal tree” → `apps/web/**` class; “our CMS/API tree” → `apps/api/**` class). Keep that mapping in **consumer** documentation.

---

## 4. Cross-tool packaging matrix

When a tool is **installed**, it indexes its **own** packaging and must **exclude** packaging owned by other tools (and always exclude secrets/build). Exact ignore syntax lands in DHI-529; classes below are the contract.

| Path class | Cursor | Claude Code | OpenCode (placeholder) |
|------------|--------|-------------|------------------------|
| `.cursor/**` (rules, commands, prompts mirrors if any) | **Index** (own) | **Exclude** | **Exclude** |
| Root `CLAUDE.md` and Claude-only config fragments | **Exclude** | **Index** (own) | **Exclude** |
| `opencode.json` / `opencode.jsonc`, `adapters/opencode/**` | **Exclude** | **Exclude** | **Index** (own) |
| Secrets / build / `node_modules` / large artifacts | **Exclude** | **Exclude** | **Exclude** |
| Application trees (`apps/**`, `packages/**`) | Per **area profile** (§5), not per tool brand | Same | Same (plus `instructions` → `.ai/rules` as configured) |

**Single-tool install:** only that tool’s packaging row applies; still apply secrets/build excludes and the chosen area profile.

**Multi-tool install:** apply the full cross-tool exclude set so tools do not index each other’s packaging. Default visibility rules are then **non-overlapping** on packaging surfaces (Jira AC #2).

### 4.1 Worked example (multi-tool, generic)

Given Cursor + Claude Code installed, profile `frontend-scope`:

- Cursor may index `.cursor/**` and `apps/web/**` (+ light shared); must not index `CLAUDE.md` or heavy infra / `apps/api/**` by default.
- Claude Code may load `CLAUDE.md` and, if the same profile is applied, the same `apps/web/**` (+ light shared); must not index `.cursor/**`.

Tool choice does not flip which area is “allowed” — the **profile** does.

---

## 5. Area profiles → globs

Profiles describe **path scope**, not tool assignment.

| Profile id | Default **include** | Default **exclude** / de-emphasize |
|------------|---------------------|-------------------------------------|
| `frontend-scope` | `apps/web/**`, narrow shared `packages/**` needed by the web app, light shared (`docs/**`, `scripts/**`) | `apps/api/**`, heavy infra (§6), other-tool packaging (§4) |
| `backend-scope` | `apps/api/**`, narrow shared `packages/**` needed by the API, light shared | `apps/web/**`, heavy infra, other-tool packaging |
| `fullstack` | `apps/web/**` + `apps/api/**` + light shared + relevant `packages/**` | heavy infra (unless the consumer explicitly relaxes), other-tool packaging |

**Notes for DHI-530 / install profiles:**

- Cursor may express area scope via additional `globs` / ignore patterns; today’s adapter `rule-map.yaml` often uses **file-type** globs (`**/*.tsx`) — monorepo **path** globs are a separate concern owned by this strategy + DHI-530.
- Claude Code MVP is a single root `CLAUDE.md`; path isolation leans on `.claudeignore` + session guidance until richer native scoping exists.
- OpenCode placeholder uses `instructions` for `.ai/rules`; application tree scoping still follows ignore + consumer profile.

### 5.1 Worked example (abstract paths)

| Profile | Example include globs | Example exclude globs |
|---------|----------------------|------------------------|
| `frontend-scope` | `apps/web/**`, `packages/ui/**`, `packages/shared-types/**`, `docs/**`, `scripts/**` | `apps/api/**`, `charts/**`, `**/node_modules/**` |
| `backend-scope` | `apps/api/**`, `packages/shared-types/**`, `docs/**`, `scripts/**` | `apps/web/**`, `charts/**`, `**/node_modules/**` |

---

## 6. Shared vs heavy infrastructure (defaults)

| Class | Examples | Default for application agents |
|-------|----------|--------------------------------|
| **Light shared** | `docs/**`, `scripts/**`, narrow `packages/**` (types, small shared libs) | **Include** with the active area profile (cheap orientation / contracts) |
| **Heavy infra** | `charts/**`, DB data volumes, nginx/HAProxy/mail/load-test stacks, large binary dumps | **Exclude** from default application agent indexes |

Consumers may loosen heavy-infra excludes for dedicated DevOps sessions; the **default** protects the WNF-03 reduction target.

---

## 7. Context reduction (WNF-03) and orientation without noise

### 7.1 What “context reduction” means

AI tools load repository material into a limited context window. Unscoped loading pulls unrelated apps, other tools’ packaging, and heavy infra into that window — raising token use and reducing answer quality.

**Context reduction** means the default indexed / attached set is intentionally smaller than “almost the whole monorepo”. The target is **30–50%** less material versus an unscoped baseline, measured with a transparent proxy (see §7.2). This is **not** deleting product features or shortening core rule text by 30%.

### 7.2 Estimation method (this story)

Until empirical validation (DHI-542):

1. Define **unscoped set** \(U\): application + packages + docs + scripts + infra trees typically visible without isolation (exclude only secrets/build/`node_modules` if already ignored).
2. Define **scoped set** \(S\): paths allowed by the active area profile + light shared + own-tool packaging − other-tool packaging − heavy infra.
3. Proxy reduction ≈ \(1 - |S|/|U|\) using file count, tree size, or approximate token weight of text files — document which proxy was used.
4. Design ignore patterns and profile globs so typical `frontend-scope` / `backend-scope` land in the **30–50%** band on the abstract layout. Adjust class membership (especially heavy infra) if estimates fall short.

**Empirical proof** on a live consumer install is **DHI-542**, not this document.

### 7.3 Orientation without noise

Reduction must **cut noise**, not erase project orientation. Keep a small, dense “getting started” layer:

| Layer | Role | Token posture |
|-------|------|----------------|
| **`AGENTS.md`** (DHI-531 / DHI-532) | Monorepo map, roles, framework entry points | Small, high value |
| **Always-on / orchestration rules** | How to work (gates, quality, handoff) | Bounded instruction set |
| **Active area tree** | Code relevant to the task | Where most useful tokens go |
| **Light shared** | Docs, scripts, narrow packages | Cheap shared orientation |
| **Skills / prompts on demand** | Deep domain help only when needed | Not a full dump every session |
| **Own-tool packaging only** | Cursor rules **or** `CLAUDE.md` **or** OpenCode config | Never index another tool’s packaging |

**Intuition:** give the agent a **catalog plus the right shelf**, not half the library at once.

---

## 8. Contracts for follow-on stories

### 8.1 DHI-529 — Synchronized ignore files

**Status:** Materialized in this repository’s **root** as `.cursorignore`, `.claudeignore`, and `.opencodeignore` (DHI-529). Hand-maintained triad — same path **classes**, tool-idiomatic syntax. No generator / no `adapters/sync.mjs` involvement.

**Scope of the framework-repo triad:** §4 cross-tool packaging + secrets/build only. **Heavy-infra** (§6) and abstract `apps/**` area excludes are **not** in the root triad (consumer / DHI-530). Align §6 defaults in consumer profiles or later templates when ignore is the right mechanism.

**Installer contract (5.2 / Q5):** Framework classes are merge-friendly (labeled sections). A future installer **merges missing** framework entries into consumer ignore files and **must not wipe** consumer-owned content without explicit opt-in (same rule as project-owned stack files).

#### Required class checklist (sync across the triad)

| Class | `.cursorignore` | `.claudeignore` | `.opencodeignore` |
|-------|-----------------|-----------------|-------------------|
| Secrets / build (`node_modules/`, `dist/`, `build/`, `.env*`, keys, …) | Exclude | Exclude | Exclude |
| `.cursor/` | *(own — do not exclude)* | Exclude | Exclude |
| `CLAUDE.md` | Exclude | *(own — do not exclude)* | Exclude |
| `opencode.json` / `opencode.jsonc`, `adapters/opencode/` | Exclude | Exclude | *(own — do not exclude)* |
| Heavy-infra / `apps/**` area paths | **Absent** in framework root | **Absent** | **Absent** |

Implementer check: after edits, confirm the three files still encode the same classes (not necessarily identical line text).
### 8.2 DHI-530 — Monorepo area glob scoping

Deliver profile-driven path scoping that:

- Implements `frontend-scope` / `backend-scope` / `fullstack` per §5 on the abstract layout
- Remains **independent of tool choice** (Q5)
- Coordinates with install domain profiles (Story 5.3) without requiring fixed tool↔team pairing
- Respects light shared vs heavy infra (§6)

### 8.3 Related (not this story)

| Story | Role |
|-------|------|
| **DHI-531** | `AGENTS.md` standard + template — [`agents-md-standard.md`](./agents-md-standard.md) |
| **DHI-532** | Reference `AGENTS.md` fill for this repository (orientation layer body) |
| **DHI-542** | Empirical WNF-03 validation on a consumer install; migration notes as needed |
| **DHI-523** | Adapter emit mapping — see [`adapter-mapping.md`](./adapter-mapping.md); ignore deferred here |

---

## 9. Sibling stories and out of scope

| Item | Status |
|------|--------|
| This document (`isolation-strategy.md`) | **DHI-528** deliverable |
| Root ignore triad materialization | **DHI-529** — **done** (root triad + §8.1 checklist) |
| Live monorepo path globs / profile wiring | **DHI-530** |
| Changing `adapters/*/rule-map.yaml` for path globs in this story | **Out of scope** |
| Installer / wizard | **5.x** |
| Embedding internal project names in framework docs | **Forbidden** (§2) |

---

## 10. Checklist for implementers (3.2–3.3)

- [x] Ignore triad encodes cross-tool packaging classes from §4
- [ ] Area profiles match §5 ids and abstract path classes
- [ ] Tool choice is not hard-coded to Frontend/Backend teams
- [ ] Heavy infra defaults follow §6 unless consumer opt-in
- [ ] Estimation / design notes acknowledge 30–50% target and orientation layer (§7)
- [ ] No internal/client monorepo names in committed framework examples
- [ ] Consumer ignore / stack files are not overwritten without opt-in
