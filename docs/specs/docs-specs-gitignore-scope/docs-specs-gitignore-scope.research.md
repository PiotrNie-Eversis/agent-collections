# docs-specs-gitignore-scope - Analysis Result

**Origin:** User request (this session) — `agent-collections` is open source; internal dev-process artifacts under `docs/specs/` must never ship in the public tree. `CHANGELOG.md` should be the only durable source of truth for what changed.
**Related Jira:** none (framework governance / repo hygiene, not DHI-scoped).
**Workflow:** Research **approved** (gap answers locked 2026-08-14: Q1 = A, Q2 = untrack going forward, Q3 = yes). Plan: broaden `.gitignore` + untrack 3 leaked folders + update convention docs.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | `docs/specs/dhi-*/` gitignore pattern misses non-DHI analysis, leaking internal artifacts into the OSS repo |
| Description | `.gitignore` only excludes `docs/specs/dhi-*/`. Analysis/plan work that does not originate from a DHI-prefixed ticket (ad-hoc framework-development tasks, this session's own `/eversis-implement` runs) creates folders that do **not** match the glob, so they are visible to `git add` / `git status` and end up committed unless someone remembers to gitignore or delete them by hand. |
| Priority | Medium — governance/hygiene, not blocking functionality, but already caused repeated real leaks (see Business Impact) |
| Reporter | User, this session |
| Created Date | 2026-08-14 |
| Due Date | n/a |
| Labels | agent-collections, governance, gitignore, spec-driven-development |
| Estimated Effort | Small — `.gitignore` pattern change + doc updates + decision on already-tracked leaked folders |

---

## Business Impact

- **Confirmed, repeated leakage, not a hypothetical.** `git ls-files docs/specs/` shows three already-committed folders that do not match `dhi-*` and are pure internal working artifacts:
  - `docs/specs/cursor-collection-migration/` (includes `jira-push-results.json`, `jira-subtasks-delete-results.json` — raw Jira API output)
  - `docs/specs/pilot-feedback-framework-deltas/`
  - `docs/specs/website-changelog-sync/`
- **Currently at risk of the same leak:** three untracked folders sit in the working tree right now, none ignored (`git check-ignore` confirms no match):
  - `docs/specs/claude-code-setup/`
  - `docs/specs/claude-code-setup-website-docs/`
  - `docs/specs/setup-framework-prefix-unknown-arg/`
- **Root cause is structural, not a one-off mistake.** The `.ai/rules/orchestration/agent-core.md` (embedded in `CLAUDE.md`) and `docs/specs/README.md` both document the *intent* — "story folders matching `docs/specs/dhi-*/` are gitignored" — but the actual gate a contributor/agent relies on (`.gitignore`) only implements the DHI-ticket case. Any task without a DHI ID (framework self-improvement, ad-hoc bugfixes, exploratory analysis like this one) silently falls outside the safety net.
- **Contradicts the stated policy.** `CHANGELOG.md` §Policy and the repo's own `0.0.1` changelog entry ("Local-only story specs — `docs/specs/dhi-*/` gitignored for MVP … not published with the framework tree") assume full coverage; the glob does not deliver that.

---

## Gathered Information

### Codebase

- **`.gitignore`** (repo root), lines 7–8:
  ```
  # Agent specs / research / plan — local only (MVP; DHI-521)
  docs/specs/dhi-*/
  ```
  Single glob, directory-only (trailing `/`), prefix-anchored to `dhi-`.

- **`docs/specs/README.md`** — "This repository (`agent-collections`)" section: *"Folders matching `docs/specs/dhi-*/` are gitignored (local-only MVP). Keep working copies on disk for active stories; they are not published with the framework tree."* States the pattern as the mechanism, not just intent.

- **`.ai/rules/orchestration/spec-driven-development.md`** — "This framework repository vs consumers": *"story folders matching `docs/specs/dhi-*/` are gitignored (local agent artifacts; MVP committed docs are README / CHANGELOG / `.ai/`)."* Same claim, embedded verbatim into `CLAUDE.md` (the always-loaded instruction surface for this session).

- Cross-references to the same `dhi-*` convention also appear in: `CHANGELOG.md`, `website/src/pages/changelog.md` (generated copy), `docs/context/agent-collections/delivery-index.md`, `docs/plans/README.md`, `docs/architecture/agents-md-standard.md`, `.ai/README.md`, `.ai/prompts/README.md`, `.ai/skills/README.md`. All describe the *intended* local-only behavior; none add a broader ignore rule.

### Verification performed this session

| Check | Result |
|---|---|
| `git ls-files docs/specs/` | 3 non-`dhi-*` folders already tracked/committed (listed above) |
| `git status --porcelain docs/specs/` | 3 more non-`dhi-*` folders currently untracked, unignored |
| `git check-ignore -v docs/specs/claude-code-setup/ docs/specs/claude-code-setup-website-docs/ docs/specs/setup-framework-prefix-unknown-arg/` | exit `1` — none matched by any ignore rule |
| `docs/specs/dhi-*/` folders present on disk | none currently — all live examples are non-DHI, i.e. the gitignore rule as written is currently protecting nothing in this working tree |

### Key files and directories

- `.gitignore:7-8` — the actual enforcement point; needs to change.
- `docs/specs/README.md` — human-facing convention doc; needs to match whatever `.gitignore` ends up doing.
- `.ai/rules/orchestration/spec-driven-development.md` — agent-facing SSOT for the same claim (flows into `CLAUDE.md`); needs to match.
- `docs/specs/cursor-collection-migration/`, `docs/specs/pilot-feedback-framework-deltas/`, `docs/specs/website-changelog-sync/` — already-tracked leaked folders; a decision is needed on whether to untrack them (`git rm --cached`) as part of the fix, independent of the `.gitignore` pattern fix (adding an ignore rule does **not** retroactively untrack already-committed paths).

---

## Current Implementation Status

### Existing Components

- `.gitignore` — present, narrow (`dhi-*` only); **needs modification**.
- `docs/specs/README.md` / `spec-driven-development.md` — present, describe the narrow rule as if it were general; **need modification** to match the new rule (whatever it becomes).
- No script or hook currently enforces or double-checks the ignore rule (no pre-commit hygiene check for `docs/specs/` scope).

---

## Gap Analysis

All missing information and gaps in task description, together with candidate answers for human decision.

### Question 1

#### What should the `.gitignore` rule actually match?

The user's own framing — "the only source of truth should be `CHANGELOG.md`" — implies **all** of `docs/specs/` content is local/internal by nature, regardless of whether the originating task happens to have a DHI ticket. The `dhi-*` prefix was never a meaningful boundary for "internal vs. publishable"; it was just this repo's ticket-naming habit at the time the rule was written (`# … MVP; DHI-521`).

| Option | Rule | Trade-off |
|---|---|---|
| **A — Broaden to all subfolders (recommended)** | `docs/specs/*/` (keep `docs/specs/README.md` tracked as a file; every subfolder ignored regardless of name) | Matches the stated intent exactly; zero maintenance (no prefix list to keep in sync with ticket systems); cannot leak by naming accident ever again. Downside: if a future *intentionally publishable* spec folder is wanted, it needs an explicit `!docs/specs/<name>/` negation — acceptable, rare, and explicit. |
| **B — Enumerate more prefixes** | e.g. `docs/specs/dhi-*/`, `docs/specs/local-*/`, … | Does not solve the actual problem: the user already describes analysis that originates "outside DHI ticket scope" with unpredictable naming (`claude-code-setup`, `setup-framework-prefix-unknown-arg` — plain kebab-task names, no prefix at all). Any enumerated list will miss the next ad-hoc name the same way `dhi-*` did. |
| **C — Enforce a mandatory local-only naming prefix** | Require agents to always create `docs/specs/local-<slug>/` (or similar) and ignore that prefix only | Solves it in theory, but pushes the burden onto every future agent run remembering a naming rule with no code enforcement — same failure mode as today (a rule stated in docs, not backed by tooling), just with a different string. |

**Recommendation: Option A.** It is the simplest change, directly matches the already-stated policy ("local-only story specs… not published with the framework tree" — no ticket-prefix qualifier in that original intent), and removes the naming-convention dependency entirely.

**Locked (2026-08-14): Option A.** `.gitignore` becomes `docs/specs/*/` (all subfolders local-only; `docs/specs/README.md` stays tracked as a file, unaffected by the trailing-slash directory glob).

### Question 2

#### Does broadening `.gitignore` retroactively fix the 3 already-committed leaked folders?

No. `git` ignore rules only affect **untracked** paths. `cursor-collection-migration/`, `pilot-feedback-framework-deltas/`, and `website-changelog-sync/` are already tracked in the repo (and its history/GitHub remote). A human decision is needed on scope:

| Option | Effect |
|---|---|
| **Untrack going forward** (`git rm -r --cached <path>` for the 3 folders, keep working-tree copies) | Stops them from appearing in future `git status`/diffs and from receiving further commits; **does not** remove them from git history (still visible via `git log`/GitHub for anyone who checks out an old commit or browses history) |
| **Also purge history** (interactive rebase / `git filter-repo` on the affected paths) | Removes any trace, but rewrites shared history — force-push required, breaks any existing clones/forks/PRs referencing those commits. Significantly higher blast radius. |
| **Leave already-committed folders as-is** | Only fixes the leak going forward; accepts that 3 folders remain visible in the current tree and history. |

This needs an explicit human call before planning, since two of the three options are irreversible or disruptive to collaborators. **No recommendation forced here** — flagging for the plan-approval conversation.

**Locked (2026-08-14): Untrack going forward.** `git rm -r --cached` the 3 already-committed folders (`cursor-collection-migration/`, `pilot-feedback-framework-deltas/`, `website-changelog-sync/`), keep the working-tree copies on disk, do not rewrite git history.

### Question 3

#### Should the docs that describe the convention (`docs/specs/README.md`, `spec-driven-development.md`, and downstream references) be updated in the same change?

Yes, functionally required regardless of which option is picked for Q1/Q2 — those docs currently assert the `dhi-*`-only rule as fact; leaving them unchanged after a `.gitignore` broadening would make the docs wrong in the other direction (claiming a narrower rule than what actually ships). This is plan-scope, not a further research question.

**Locked (2026-08-14): Yes.** `docs/specs/README.md`, `.ai/rules/orchestration/spec-driven-development.md` (regenerates `CLAUDE.md` via `npm run sync:adapters`), `docs/plans/README.md`, and `docs/architecture/agents-md-standard.md` all state the `dhi-*`-only rule as fact and move to plan scope. `CHANGELOG.md` gets a new `Unreleased` → `Fixed` entry (historical entries are not rewritten). The dead `docs/specs/dhi-*/` cross-links in `.ai/README.md`, `.ai/prompts/README.md`, `.ai/skills/README.md`, and `docs/context/agent-collections/delivery-index.md` are a separate, pre-existing problem (links into gitignored local-only folders) — out of scope here.

---

## Suggested next steps

1. ~~Human approves this research.~~ Done (Q1–Q3 locked 2026-08-14).
2. Human reviews and approves `docs-specs-gitignore-scope.plan.md` before implementation.
3. No code/behavioral changes beyond `.gitignore` and documentation — this is a repo-hygiene fix, not a feature.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-14 | Initial research: confirmed `.gitignore` only matches `docs/specs/dhi-*/`; found 3 already-committed and 3 currently-untracked non-DHI spec folders as concrete evidence of the leak; proposed broadening the ignore rule to `docs/specs/*/` and flagged the already-tracked-folder remediation as a human decision. |
| 2026-08-14 | Gap answers locked: Q1 = A (`docs/specs/*/`); Q2 = untrack going forward (`git rm -r --cached`, no history rewrite); Q3 = yes, update convention docs + CHANGELOG Unreleased. |
