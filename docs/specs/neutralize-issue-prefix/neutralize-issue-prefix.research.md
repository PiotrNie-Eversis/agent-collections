# Neutralize internal issue prefix ("DHI-") — Research

## Task

Replace all instances of the phrase "dhi-" (the internal Jira project-key prefix used
throughout this repo's own delivery history) with a neutral term, so that tracked
repo content does not indicate eversis's internal Jira/ticketing process to an
external reader (e.g. website visitors, or the repo if ever made public/shared).

## What "DHI-" actually is

`DHI` is the Jira project key for the epic that funded building *this framework
repo itself* (epic `DHI-515`, "Multi-Agent AI Context Isolation & Standard").
Every `DHI-<number>` token in the tree is a **traceability reference** — a pointer
from a piece of shipped content back to the ticket that produced it. It is never
used as:
- a functional string match / regex in code,
- a glob pattern component that `.gitignore`/`.claudeignore`/etc. actually rely on
  (the real gitignore rule is `docs/specs/*/`, broadened off `dhi-*/` per
  `CHANGELOG.md`),
- a runtime config key.

Confirmed by inspecting every `.mjs`/`.sh`/`.yaml` hit (`adapters/sync.mjs`,
`adapters/claude/generate.mjs`, `adapters/cursor/generate.mjs`,
`adapters/claude/generate-commands.mjs`, `scripts/lib/setup-agent-collections/*`,
`adapters/profiles/*.yaml`) — all occurrences are inside comments. This is a
**pure text/documentation rename**, not a behavior change.

## Scope (git-tracked files only)

`docs/specs/dhi-*/` and `website/build/` are both gitignored (confirmed via
`git check-ignore`), so the ~80 non-tracked files under those trees are **out of
scope** — they're local-only working artifacts / generated build output, never
shipped or committed, and don't leak externally. `website/build/` regenerates
from `website/docs/` via the normal Docusaurus build, so fixing the docs source
is sufficient.

The real scope is **60 git-tracked files**, ~390 occurrences total
(`git ls-files | xargs grep -il "dhi-"`, counted case-insensitively). Heaviest
concentrations:

| File | Occurrences | Nature |
|---|---|---|
| `docs/context/agent-collections/delivery-index.md` | 77 | Internal Jira-epic-to-wave traceability table |
| `docs/context/agent-collections/task-baseline.md` | 58 | Internal Jira backlog export (keys, parents, summaries) |
| `docs/architecture/adapter-mapping.md` | 48 | Architecture doc, inline ticket refs |
| `docs/architecture/isolation-strategy.md` | 27 | Architecture doc, inline ticket refs |
| `.ai/README.md` | 26 | Core orientation doc, status/roadmap pointers |
| `website/src/pages/changelog.md` | 22 | **Public Docusaurus site** — mirrors CHANGELOG.md |
| `CHANGELOG.md` | 22 | Release history |
| remaining 53 files | 1–9 each | Code comments, README pointers, `.ai/rules/*`, `.cursor/rules/*.mdc`, adapter YAML headers, `website/docs/**` (public) |

Full per-file counts captured during research (reproducible via the grep above);
not duplicated here to keep this doc short.

## Match shapes observed

All occurrences reduce to one of these text shapes (case-insensitive on the
`DHI` token; numbers/hyphens vary):

1. `DHI-515` / `DHI-598` — single ticket reference (majority of hits).
2. `DHI-528–530` / `DHI-533–538, 530, 532` — en-dash ranges / comma lists (only
   the first number in a list carries the explicit prefix; trailing bare
   numbers are left as-is, which is fine — a bare number alone reveals nothing).
3. `docs/specs/dhi-522/`, `docs/specs/dhi-*/` — lowercase prefix inside an
   illustrative path/glob shown in prose (not an actual glob evaluated by any
   ignore file — the real `.gitignore` rule is `docs/specs/*/`).
4. `dhi-542-agent-collections-pilot` — lowercase prefix inside an example git
   branch name (`docs/context/eog/upgrade-runbook.md`).
5. Bare `DHI` as a table cell / word, e.g. `| Project | DHI |`, "non-DHI work"
   (`AGENTS.md`, `CHANGELOG.md`, `task-baseline.md`).
6. `# DHI-515 — Delivery index` — document title.

No occurrence of `dhi` appears as a substring of an unrelated word (verified via
a broader case-insensitive scan); the two incidental `dhi` substring hits inside
`website/package-lock.json` (base64-ish hash fragments) are not real tokens and
are excluded already by requiring the literal `dhi-` (with hyphen) match used to
build the file scope.

## Decisions (confirmed with the requester)

- **Replacement term:** `TASK` (case-preserving: `DHI`→`TASK`, `dhi`→`task`).
  Numbers are kept as-is, so `DHI-515` → `TASK-515`, `dhi-522` → `task-522`.
  This preserves every existing cross-reference/traceability link (a reader can
  still correlate "TASK-515" mentions across files) while removing the
  Jira-project-specific, eversis-internal token.
- **Scope:** apply everywhere tracked, including historical/internal-only docs
  (`CHANGELOG.md`, `docs/context/agent-collections/delivery-index.md`,
  `task-baseline.md`) — not just the public-facing subset. No file is left with
  a residual `dhi-` string.

## Explicit non-goals (kept out of this task)

- **Not renaming the `eversis-` prefix.** That's the framework's actual public
  branding (skill/prompt ids like `eversis-implement`, `eversis-review-plan`)
  and was not part of the request — only `dhi-` is in scope.
- **Not renaming gitignored local files** — `docs/specs/dhi-*/` folders on disk
  are untracked working artifacts; renaming them is optional local hygiene, not
  required to satisfy "don't indicate the internal process to an external
  reader" (they're never committed/shipped). Flagged as an optional follow-up,
  not part of this plan.
- **Not redacting other Jira metadata** — `task-baseline.md` also contains
  priorities/status/assignee-shaped columns that are internal-process signals
  independent of the `DHI` string. Out of scope; the request was specifically
  about the `dhi-` phrase.

## Risk / correctness notes for the plan

- Pure find/replace on prose and comments; zero functional/code-behavior risk
  (confirmed no code parses/matches on the literal string).
- Must preserve case pattern and must not touch the two incidental
  `website/package-lock.json` substring hits (they don't match `dhi-` with a
  hyphen, so a hyphen-anchored replace already skips them — verify post-hoc).
- `website/build/` is generated; do not hand-edit it — rebuilding the site from
  the fixed `website/docs/` sources (or leaving the stale build untouched, since
  it's gitignored and regenerates before publish) is sufficient.
- Verification: re-run `git ls-files | xargs grep -il "dhi-"` after the change —
  expect zero matches.
