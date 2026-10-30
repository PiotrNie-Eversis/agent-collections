# docs-architecture-necessity - Analysis Result

**Origin:** User request (this session, Polish: "przeprowadź analizę, które zweryfikuje czy ten folder jest niezbędny") — verify whether `docs/architecture/` is necessary in the `agent-collections` repository.
**Related Jira:** none (repo governance / documentation audit, not DHI/TASK-scoped).
**Workflow:** Research drafted this session — conclusion is unambiguous (keep, no removal), so no plan is expected to follow unless the human wants a smaller follow-up (see Suggested next steps).

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | Is `docs/architecture/` necessary in `agent-collections`? |
| Description | User asked for an analysis verifying whether the 5-file `docs/architecture/` folder is needed, or could be removed/consolidated. |
| Priority | Low — verification/audit, not a bug or blocker |
| Reporter | User, this session |
| Created Date | 2026-08-14 |
| Due Date | n/a |
| Labels | agent-collections, documentation, governance, audit |
| Estimated Effort | N/A — analysis only, conclusion does not require implementation |

---

## Business Impact

- If the folder were genuinely dead weight, removing it would reduce repo surface and avoid maintaining stale docs.
- If the folder is load-bearing (as this research finds), removing it would break the framework's own documented navigation (`README.md`, `AGENTS.md`, `.ai/README.md`) and delete the only canonical specification for several mechanisms that live code actually implements (adapter generation, ignore-triad enforcement, install-selection schema).

---

## Gathered Information

### Folder contents (read this session, all 5 files in full)

| File | Status header | Subject |
|---|---|---|
| `adapter-mapping.md` | "Canonical (committed)" | Single source of truth for how `.ai/` core maps to Cursor/Claude Code/OpenCode adapters — field maps, emit matrix, `rule-map.yaml` contract |
| `requirements-traceability.md` | (index, no status header) | Maps WF/WNF (wildly-important functional/non-functional) requirement IDs to docs and delivery waves |
| `agents-md-standard.md` | (normative standard) | Required structure for the root `AGENTS.md` file across all consumer installs |
| `install-selection.md` | (schema doc) | Documents `.agent-collections/install-selection.json` — the install-state file the installer's `--upgrade`/`--sync` flags depend on |
| `isolation-strategy.md` | "Canonical (committed)" | Single source of truth for cross-tool ignore (Cursor/Claude/OpenCode packaging isolation) and area/path profile scoping |

All five are substantial (up to 341 lines), cross-linked to each other, and tied to specific completed Jira stories (TASK-523, 528, 529, 531, etc. — visible in each file's header/body).

### Cross-reference check (who actually points at these files)

Ran repo-wide search for each filename (excluding `node_modules`, `.git`, `build`, `.docusaurus` generated output). Every file is referenced from **multiple** load-bearing, non-`docs/specs` locations:

| File | Referenced from (selected, non-`docs/specs` only) |
|---|---|
| `adapter-mapping.md` | `README.md` (repo structure map), `AGENTS.md` (Framework section), `.ai/README.md` ("**Canonical specification**... Prefer that document over this summary when implementing or extending adapters"), `adapters/{cursor,claude,opencode,README}.md`, `website/docs/framework-reference.md`, `website/docs/getting-started/migration-from-cursor-collections.md`, `CHANGELOG.md`, `documentation/agent-collection.md` |
| `requirements-traceability.md` | `README.md` (docs table: "WF / WNF → docs / stories"), `website/docs/framework-reference.md`, `website/docs/getting-started/start-here.md`, `CHANGELOG.md`, `documentation/agent-collection.md` |
| `agents-md-standard.md` | `AGENTS.md` (Framework section), `.ai/README.md`, `adapter-mapping.md` (cross-referenced), `isolation-strategy.md` (cross-referenced), `documentation/agent-collection.md` |
| `install-selection.md` | `README.md` ("Selection is recorded at `.agent-collections/install-selection.json` (schema: ...)"), `AGENTS.md`, `website/docs/getting-started/{start-here,installation,migration-from-cursor-collections}.md`, `website/docs/framework-reference.md`, `requirements-traceability.md` |
| `isolation-strategy.md` | `AGENTS.md`, `.ai/README.md` ("**Isolation strategy (canonical)**"), `adapter-mapping.md`, `website/docs/isolation.md`, `website/docs/framework-reference.md`, `adapters/profiles/{README,area-*}.yaml`, `documentation/agent-collection.md` |

None of the five files is orphaned — each has at least 4 independent, current, non-spec referrers, including the repo's own top-level `README.md` and `AGENTS.md` (the two files a new contributor or consuming agent reads first).

### Content accuracy check (is the documentation stale, or does it match live code?)

Spot-checked the smallest, most "could be stale" candidate — `install-selection.md`'s documented JSON schema (`frameworkVersion`, `agents`, `mcpServers`, `domainProfile`, `vendorMode`, `linkMode`, `recordedAt`) — against the actual installer code:

- `scripts/lib/setup-agent-collections/selection.sh` writes exactly `frameworkVersion`, `domainProfile`, `vendorMode`, `linkMode` (plus `agents`/`mcpServers` from earlier in the same object construction).
- `scripts/lib/setup-agent-collections/upgrade.sh` reads the file back and validates against `['frameworkVersion','agents','mcpServers','domainProfile','vendorMode','linkMode']` as required fields — matching the doc's schema table field-for-field.

The documentation is **not** stale — it accurately describes a schema that live, currently-running installer code both writes and depends on for its `--upgrade` fail-safe behavior.

### `.ai/README.md`'s own framing

`.ai/README.md` (the SSOT overview for the `.ai/` core tree) explicitly defers to two of these five files as canonical over its own summary text: *"Prefer that document over this summary when implementing or extending adapters"* (re: `adapter-mapping.md`), and labels `isolation-strategy.md` as *"canonical"* directly. This is the framework's own internal documentation hierarchy naming `docs/architecture/` as the authoritative layer — not a redundant or superseded one.

### Key files and directories

- `docs/architecture/*.md` (5 files) — subject of this analysis.
- `README.md:189,384,412` — top-level repo doc, links to 3 of the 5 files directly, plus a structural comment describing the whole folder's role.
- `AGENTS.md:15-17,36` — root agent-orientation file, links to 4 of the 5 files under "Framework" section (the section every framework session is expected to read).
- `.ai/README.md:35,37,39,74-75` — names `adapter-mapping.md` and `isolation-strategy.md` as canonical specs superior to its own inline summaries.
- `website/docs/framework-reference.md`, `website/docs/isolation.md` — docs-site pages that appear to summarize/mirror this content for the public site (not verified byte-identical; out of scope for this specific question).

---

## Current Implementation Status

No implementation involved — this is a verification-only analysis. The folder exists, is populated, is current, and is actively linked from the repo's primary orientation documents.

---

## Gap Analysis

### Question 1

#### Is `docs/architecture/` necessary?

Only one substantive question was in scope, and the evidence gathered answers it directly rather than presenting a real trade-off:

| Consideration | Finding |
|---|---|
| Orphaned / unreferenced? | No — every file has 4+ independent non-spec referrers, including `README.md` and `AGENTS.md` |
| Duplicated elsewhere (redundant)? | No — `.ai/README.md` explicitly defers to these files as canonical, meaning they are the *source*, not a copy |
| Stale vs. live code? | No — spot-checked `install-selection.md` against actual installer code (`selection.sh`/`upgrade.sh`); schema matches exactly |
| Tied to completed, real work? | Yes — each file documents specific completed stories (TASK-523, 528, 529, 531) with delivered generators/scripts in the repo (`adapters/cursor/`, `adapters/claude/`, ignore triad, `AGENTS.md` template) |

**Conclusion: `docs/architecture/` is necessary.** It is the framework's canonical specification layer for adapter packaging, cross-tool isolation, the `AGENTS.md` standard, the install-state file schema, and the WF/WNF requirements index — referenced from the two files (`README.md`, `AGENTS.md`) most likely to be read first by a new contributor or a fresh agent session, and from `.ai/README.md` as authoritative over its own inline summaries. No removal or consolidation is recommended.

**No lock needed — this is a factual finding, not a decision requiring a human choice between options.**

---

## Suggested next steps (superseded — see DELTA below for current recommendation)

1. ~~No action required — the folder should be kept as-is.~~ — necessity confirmed, but user flagged a real elegance problem (internal Jira links) not covered by the original question; see Question 2.
2. Optional, low-priority follow-up (not part of this analysis, flagging only if useful later): verify whether `website/docs/framework-reference.md` and `website/docs/isolation.md` are meant to be kept in sync with `docs/architecture/adapter-mapping.md` / `isolation-strategy.md` by a script (like `sync-changelog.mjs` does for `CHANGELOG.md`) or are hand-maintained summaries that could drift — this research did not diff their content, only confirmed they reference the architecture docs.

---

## DELTA — 2026-08-14: Internal Jira link leakage

**Trigger:** User accepted "necessary" but pushed back on elegance — specifically internal `eversis.atlassian.net` links baked into public framework documentation. Not covered by Question 1 (which only asked "necessary or not"); this is new scope on the same file set.

### Question 2

#### Are the internal Jira references in `docs/architecture/*.md` a real problem, and if so what's the better implementation?

**Scope of the problem (measured this session):**

| File | Live `eversis.atlassian.net` hyperlinks | Bare `TASK-nnn` mentions (unique) |
|---|---|---|
| `adapter-mapping.md` | 1 (header "Story:" line) | 12 |
| `isolation-strategy.md` | 3 (header + 2 table cells) | 7 |
| `agents-md-standard.md` | 0 | 2 |
| `requirements-traceability.md` | 0 | 4 |
| `install-selection.md` | 0 | 0 |

**Finding A — this contradicts a principle the repo already states for itself.** `isolation-strategy.md` §2 ("Open-source naming rule") says: *"Agent Collections is intended for a wide open-source audience... Do not embed internal or client monorepo names, private absolute paths, or workshop-only labels in framework documentation or examples."* That rule is phrased around path/monorepo names, but the same reasoning applies directly to a private company's Jira instance — `eversis.atlassian.net` is not reachable by any external contributor, so every one of those 4 links is dead-on-arrival for the audience the file itself says it's written for.

**Finding B — the links are not just inaccessible, they are now factually wrong.** Read `docs/specs/neutralize-issue-prefix/neutralize-issue-prefix.research.md` (prior session's work, already implemented per the current file content) to check provenance: `DHI` is confirmed as **the real Jira project key** (*"`DHI` is the Jira project key for the epic that funded building this framework repo itself"*). The neutralize-issue-prefix change was a **pure text substitution** — `DHI` → `TASK` — applied uniformly to file contents, with no carve-out for URLs. That means the current committed links, e.g. `https://eversis.atlassian.net/browse/TASK-523`, now point at a Jira issue key (`TASK-523`) that does not correspond to the real ticket (`DHI-523`) — the substitution silently broke the links even for someone *with* internal Jira access. So this isn't only an open-source-audience concern; the current state is actively wrong for every reader, internal or external.

**Finding C — the repo already has the right pattern to fall back on.** `CHANGELOG.md` documents the same delivery history using the identical bare `TASK-nnn` labels (e.g. `CHANGELOG.md:70-76`, "Adapter mapping specification... (TASK-523)", "Isolation strategy (TASK-528)") **without any hyperlink** — plain text provenance only. This matches this session's earlier-established principle (`docs-specs-gitignore-scope` research, same repo) that `CHANGELOG.md` should be the single durable source of truth for "what changed," not scattered ticket links in spec bodies.

### Options

| Option | Change | Trade-off |
|---|---|---|
| **A — Strip Jira hyperlinks, keep bare `TASK-nnn` labels** | Remove `[TASK-nnn](https://eversis.atlassian.net/browse/...)` markdown-link syntax, leave plain `TASK-nnn` text where it already reads naturally (e.g. header "Story:" lines, table cells) | Cheapest fix for Finding A (no more dead/wrong links). Does not address that individual `TASK-nnn` numbers are still meaningless to an external reader and, per Finding B, may not even be internally accurate anymore (some non-linked `TASK-nnn` mentions elsewhere in these files could carry the same silent mis-numbering, just never surfaced as a clickable link). |
| **B — Remove all Jira/story provenance from the 5 files entirely** (header "Story:" lines, inline `TASK-nnn` parentheticals), rely on `CHANGELOG.md` (Finding C) as the sole place delivery-provenance lives | Cleanest separation of concerns: `docs/architecture/*.md` becomes pure technical specification, `CHANGELOG.md` stays the historical/traceability record — matches the pattern the repo has already chosen elsewhere (Finding C) and the open-source-audience principle (Finding A) exactly. Loses the direct in-doc breadcrumb from "this spec" to "this delivery," but that breadcrumb is only useful to a reader with internal Jira access anyway, and (per Finding B) is currently unreliable even for them. | 
| **C — Replace Jira provenance with repo-relative provenance** (e.g. "delivered via `adapters/cursor/generate.mjs`", or "see `CHANGELOG.md` entry for `v0.x`") instead of a ticket ID | Keeps *some* in-doc breadcrumb, but points it at something every reader — internal or external — can actually open and verify, right now, in this repo | More editorial work than A or B (needs a real per-file decision about what to point at); marginal benefit over B for a technical spec whose audience mostly wants the spec itself, not its delivery history |
| **D — Leave as-is** | No change | Not recommended — leaves confirmed-broken links (Finding B) and a stated-but-violated repo principle (Finding A) in the framework's own canonical, most-referenced docs |

**Recommendation: B**, with `requirements-traceability.md` as a partial exception worth a separate look — its entire purpose is mapping WF/WNF IDs to "Story / wave," so wholesale removal may defeat the file's own point; for that one file specifically, Option C (point at `CHANGELOG.md` sections / wave labels instead of bare ticket numbers) may fit better than blanket removal. Flagging as a sub-decision rather than picking unilaterally.

**Locked (2026-08-14): Option C** — replace Jira provenance (hyperlinks + bare `TASK-nnn` labels) with repo-relative provenance (point at `CHANGELOG.md` entries / delivered artifacts) across all files that currently carry it, not only `requirements-traceability.md`. Applies to `adapter-mapping.md`, `isolation-strategy.md`, `agents-md-standard.md`, `requirements-traceability.md` (`install-selection.md` has none — no change).

### Scope note for planning

Option C touches 4 of the 5 files (`install-selection.md` has zero Jira references, confirmed above — no change needed there) — over the Quick Flow 3-file threshold, so this goes through Full Flow with a `*.plan.md`.

---

## DELTA — 2026-08-14: Proposal to move `docs/architecture/` into `documentation/` and delete `docs/architecture/`

**Trigger:** User proposed, alongside locking Option C, also consolidating the two top-level doc folders — move all 5 files from `docs/architecture/` into `documentation/`, then remove `docs/architecture/` entirely. Asked for analysis before implementation, not a direct build.

### Question 3

#### Should `docs/architecture/*.md` move into `documentation/`, removing `docs/architecture/` as a folder?

**What `documentation/` actually is today:** a single file, `documentation/agent-collection.md` (119 lines) — a condensed "framework reference" / table-of-contents page that points **out** to other docs, including a dedicated "Architecture docs" table (lines 96-104) linking all 5 `docs/architecture/*.md` files by path. `website/docs/framework-reference.md` (the public docs-site page) states explicitly: *"Repo source: `documentation/agent-collection.md`"* — i.e. `documentation/` is the on-repo source for one specific rendered docs-site page, not a general specs directory.

**What `README.md` says about the two folders — this is the key finding.** The repo's own structure diagram (`README.md` lines 375-386) lists them as two **separate, deliberately distinct** top-level entries, each with a one-line role:

```text
documentation/        # Framework reference (agent-collection.md)
...
docs/architecture/    # Mapping, isolation, AGENTS standard, selection, WF/WNF
```

This isn't incidental — the repo already documents these as two different kinds of thing (single condensed overview vs. deep canonical spec set), not as a naming accident waiting to be merged.

**Blast radius, measured this session.** Excluding gitignored `docs/specs/*` historical records, **16 files** reference the literal `docs/architecture` path and would need link updates on a move: `README.md`, `AGENTS.md`, `.ai/README.md`, `CHANGELOG.md`, `adapters/{README,claude/README,cursor/README,opencode/README,profiles/README}.md`, `docs/context/agent-collections/delivery-index.md`, `documentation/agent-collection.md` itself, and 5 `website/docs/**` pages. Plus the 5 files' own cross-links to each other (`adapter-mapping.md` ↔ `isolation-strategy.md` ↔ `agents-md-standard.md`) would need re-pointing since their relative depth would change if they move (though it stays a flat sibling move, so relative links between the 5 files themselves are actually **unaffected** — only inbound links from outside the folder break).

**What the move would and wouldn't fix:**

| Concern | Fixed by the move? |
|---|---|
| Internal Jira links (the original complaint) | No — already fully addressed by the locked Option C decision above, independent of file location |
| `docs/` vs `documentation/` naming overlap (two top-level folders that read as synonyms) | **Not resolved, arguably worsened** — `docs/` still exists afterward, holding `context/`, `plans/`, `specs/`; `documentation/` goes from "1 overview file" to "1 overview file + 5 deep specs," a more mixed, less obviously-scoped folder than either currently is |
| `docs/architecture/`'s alignment with the AGENTS.md standard's documented triad | Neutral — `agents-md-standard.md` (§"Project deliverables triad," one of the 5 files itself) defines the triad as `docs/context/`, `docs/plans/`, `docs/specs/` only; `docs/architecture/` was never part of that triad, so it isn't "escaping" a structural requirement either way |

**Assessment:** the move doesn't address the problem that motivated this whole analysis (already fixed independently by Option C), changes the documented, apparently-intentional role of `documentation/` from "single condensed public-facing reference" to "reference page + deep spec dump," requires touching 16 files purely for path relocation with no functional change, and leaves the `docs/` vs `documentation/` naming question exactly as confusing as before (or slightly more so, since `documentation/` becomes harder to describe in one line once it's mixed-content).

**Recommendation: do not move.** If the underlying discomfort is really "two top-level folders with near-synonymous names," that's a real, separate, larger question (would need to also decide what happens to `docs/context/`, `docs/plans/`, `docs/specs/` — none of which are in scope here) — worth raising explicitly as its own decision rather than folding into this fix, not something this analysis should resolve by moving one of the five as a side effect.

**Locked (2026-08-14): No move.** `docs/architecture/` stays as its own folder. Only Option C (Jira-provenance fix) proceeds to planning.

### Correction to Q2 file scope (superseded — see Q4 below)

The Q2 lock said Option C "applies to `adapter-mapping.md`, `isolation-strategy.md`, `agents-md-standard.md`, `requirements-traceability.md`." Re-checking the per-file count table above at plan time: **only `adapter-mapping.md` (1 link) and `isolation-strategy.md` (3 links) contain live `eversis.atlassian.net` hyperlinks** — the actual broken/dead-link problem (Findings A+B). `agents-md-standard.md` and `requirements-traceability.md` have **zero** hyperlinks; their `TASK-nnn` mentions are already bare, non-linked text.

**This narrowing was rejected by the user** (see Q4) — "not hyperlinked" is not the same as "neutral." A bare `TASK-nnn` mention is still a private-tracker identifier in a doc meant to be tool/audience-neutral, matching the same open-source-audience principle from Finding A regardless of whether it happens to render as a clickable link.

### Question 4

#### Should every `TASK-nnn` mention be removed from `docs/architecture/`, not just the hyperlinked ones?

**User's instruction (verbatim intent):** architecture docs should be neutral and fully separated from the Jira/ticket-tracker system — no `TASK-nnn` identifiers at all, hyperlinked or bare. Where a ticket number was standing in for real information (what was delivered, which artifact, which wave), that information should be written into the file directly rather than referenced by ticket number.

**Locked (2026-08-14): Yes — full removal.** Scope expands from 2 files to **4 files** (`adapter-mapping.md`: 30 mentions across body/tables/headings; `isolation-strategy.md`: 19 mentions including 2 section headings that embed the ID; `agents-md-standard.md`: 6 mentions; `requirements-traceability.md`: 6 mentions, one per table row — this file's whole "Story / wave" column is ID-driven). `install-selection.md` still has zero mentions — no change. Exact counts re-verified via `grep -n "TASK-[0-9]"` per file at plan time.

**Replacement approach:** most files already carry a parallel, framework-native, non-Jira label right next to the ticket ID — e.g. `**Story:** [TASK-523](...) (Work Stream 2 / Story 2.1)` already has "Work Stream 2 / Story 2.1" sitting there unused as a neutral alternative. Where no such adjacent label exists, substitute the ticket ID with the name of the artifact/feature it was denoting (e.g. `TASK-524` → "the Cursor generator", already named as `adapters/cursor/` in the same sentence in most cases) — this satisfies "move the content into the file" without inventing new claims, since the artifact name is already present in nearly every occurrence, just alongside the now-redundant ticket number. Full mapping table and per-file handling in the plan.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-14 | Initial research entry: confirmed all 5 files in `docs/architecture/` are actively referenced from `README.md`, `AGENTS.md`, `.ai/README.md`, website docs, and multiple `docs/specs/` records; spot-checked `install-selection.md` against live installer code and found it accurate, not stale. Conclusion: folder is necessary, no removal recommended. |
| 2026-08-14 | DELTA: user flagged internal Jira links as inelegant. Confirmed 4 live `eversis.atlassian.net` hyperlinks (in `adapter-mapping.md`, `isolation-strategy.md`) violate the repo's own stated open-source-audience principle (Finding A), and — more seriously — are now factually broken: the earlier `neutralize-issue-prefix` text substitution (`DHI`→`TASK`) was applied to URLs too, so linked issue keys no longer match the real Jira project key `DHI` (Finding B). Found `CHANGELOG.md` already carries the same provenance via bare, non-linked `TASK-nnn` labels (Finding C). Proposed options A–D; recommended B (strip Jira provenance from spec files, rely on `CHANGELOG.md`), with a possible C-style exception for `requirements-traceability.md`. Awaiting human decision before planning. |
| 2026-08-14 | Q2 locked: Option C (repo-relative provenance via `CHANGELOG.md`/delivered artifacts, not bare removal) across all 4 affected files. Q3 (new): analyzed user's proposal to move `docs/architecture/*.md` into `documentation/` and delete `docs/architecture/`. Found `README.md`'s own structure diagram documents the two folders as deliberately distinct (single overview vs. deep spec set); found 16 files reference `docs/architecture` paths (full blast radius for a pure relocation); found the move doesn't address the Jira-link problem (already fixed by Option C) and doesn't resolve — arguably worsens — the `docs/` vs `documentation/` naming overlap. Recommended against the move; flagged the naming-overlap discomfort as a separate, larger, not-yet-scoped question if the user wants to pursue it on its own. Awaiting human decision before planning. |
| 2026-08-14 | Q3 locked: no move, `docs/architecture/` stays. Plan written scoped to only the 2 files with live hyperlinks (`adapter-mapping.md`, `isolation-strategy.md`) — user rejected this narrower scope (Q4): bare, non-hyperlinked `TASK-nnn` mentions are equally non-neutral and must go too, with any real content moved into the file rather than referenced by ticket number. Q4 locked: full removal across `adapter-mapping.md` (30 mentions), `isolation-strategy.md` (19), `agents-md-standard.md` (6), `requirements-traceability.md` (6) — `install-selection.md` still clean. Plan rewritten accordingly. |
| 2026-08-14 | Plan approved and implemented. All 4 files edited per the mapping table; the 4 ID-driven index tables (`adapter-mapping.md` §8, `isolation-strategy.md` §8.3 + §9, `agents-md-standard.md` boundary table, `requirements-traceability.md` main table) rewritten with descriptive item names in place of ticket IDs. Verified: `grep -rn "TASK-[0-9]\|atlassian.net"` across `docs/architecture/` → zero matches; `git diff --stat` limited to the 4 planned files (73 insertions, 73 deletions); `install-selection.md` byte-identical; all rewritten tables re-read and confirmed no broken markdown or lost information. Review: PASS. |
