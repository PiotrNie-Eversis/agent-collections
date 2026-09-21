---
name: eversis-import-confluence-knowledge
description: "One-time bootstrap of docs/context/<project>/<component>/index.md files for a project adopting the framework after the fact. Prefers a Confluence AS-IS Pack page when ssot.confluenceSpaceKey is set (via the already-connected atlassian MCP); falls back to clustering raw docs/specs/ task history for any module the As-IS Pack does not cover, or as the sole source when no As-Is Pack exists. Use for one-time adoption seeding, not as a recurring sync."
user-invocable: true
---

# Importing Confluence Knowledge

One-time bootstrap of domain-knowledge component files under `docs/context/<project>/` for a project that already has non-trivial history (a Confluence AS-IS Pack, a `docs/specs/` backlog, or both) before adopting this framework's `INDEX.md` router. Never runs automatically at install time (`--confluence-space-key` only records the key; see `docs/architecture/install-selection.md`), and never runs against a specific consumer repo's data as part of this framework's own Definition of Done — running it is that consumer repo's own adoption task.

<principles>
<one-time-not-live>
This is a one-shot import, not a live proxy. Do not re-run it as a sync mechanism, and do not build a tool that reads Confluence on every `eversis_context_get` call — the AS-IS Pack page format (one monolithic page, per-section human owners) does not map cleanly to the router's one-file-per-component shape on every read; splitting once, into `docs/context/<project>/<component>/index.md` files that are then edited/promoted normally (`eversis-promote-domain-knowledge`), is the correct fit (global-domain-context-ssot.research.md, Question 1).
</one-time-not-live>
<split-not-copy>
Do not create a single file that copies the whole page. Split by functional component, not by Confluence heading: one file per component at `docs/context/<project>/<component>/index.md` — the only path `eversis_context_get` resolves. Consolidate every section that belongs to the same component into that one file. Do not create a separate file per logical section (e.g. do not emit one file each for "Cel biznesowy", "Mapa modułów", "Known Issues", "Decision log"); those headings are source structure, not the output granularity.
</split-not-copy>
<confluence-first-specs-fallback>
A Confluence As-Is Pack, when one exists and is reasonably populated, is a cheaper and higher-quality seed than raw `docs/specs/` history — its module/feature map and per-module sections map closely onto `INDEX.md` rows and component-file bodies. Use it first. Fall back to clustering raw `docs/specs/*/` only for modules the As-Is Pack itself flags as undocumented (Step 6), or as the sole source when no As-Is Pack exists at all (see "No As-Is Pack at all" below). Never treat the two sources as interchangeable defaults — the ordering is deliberate, not stylistic.
</confluence-first-specs-fallback>
<draft-for-review-never-auto-write>
This skill's process produces a draft — proposed component files and `INDEX.md` rows — for human review, whichever source (Confluence, `docs/specs/`, or both) fed it. It never writes to `docs/context/` automatically; the human approves before anything is committed, the same gate `eversis-promote-domain-knowledge` uses for its own drafts.
</draft-for-review-never-auto-write>
</principles>

## When to run

- The human explicitly asks for the bootstrap (never triggered by the installer or by another skill automatically).
- Either `.agent-collections/install-selection.json` has a non-null `ssot.confluenceSpaceKey` (Confluence-first path below), or it does not and the human wants to bootstrap from `docs/specs/` history alone ("No As-Is Pack at all" branch below).

## Process (Confluence-first path)

1. **Read the confirmed key.** Read `ssot.confluenceSpaceKey` from `.agent-collections/install-selection.json`. If it is `null`, do not stop here — ask the human whether to (a) pass `--confluence-space-key` on a future `--sync` run and re-run this skill, or (b) proceed directly with the "No As-Is Pack at all" branch below, using `docs/specs/` history as the sole source.
2. **Locate the AS-IS Pack page.** Use the `atlassian` MCP (already configured, see `website/docs/integrations/atlassian.md`) to find the page in the given space (commonly named something like "As-Is Pack" or similar per the project's own Confluence conventions — do not assume an exact title, search the space).
3. **Read the page content.** Fetch the full page body. Identify its top-level sections and, where present, a module/feature map (a table of components with a per-module "documentation status" column is a strong, directly-usable candidate for `INDEX.md` rows).
4. **Split into component files.** Group sections by the component/functionality they are actually about (not the Confluence section's own generic label — see `eversis-promote-domain-knowledge` for the same component-naming convention), and write one file per component at `docs/context/<project>/<component>/index.md` — the same path shape `eversis-promote-domain-knowledge` uses and the only one `eversis_context_get` resolves. Consolidate every section belonging to the same component into that one file; do not create a separate file per Confluence section. Each file gets frontmatter:
   - `scope: project`
   - `source: confluence`
   - `confluence_url: <direct link to the source page/section anchor>`
   - `last_updated: <today, ISO date>`
   - `tags: [<relevant tags>]`
   - `code_paths: []` — present as an explicit empty array, not omitted. Populate it when the source section itself names code modules or paths; otherwise leave it empty and let a later task fill it in as the code is actually touched.
   - `related_specs: []` — present as an explicit empty array, not omitted (this is a Confluence-sourced seed, not yet tied to any `docs/specs/` task).
5. **Update the index.** Add one row per new component to `docs/context/<project>/INDEX.md` (created by the installer's scaffolding step — see `scripts/lib/setup-agent-collections/ssot.sh`). Two columns only: `| component | one-line summary |`.
6. **Fall back to `docs/specs/` clustering for uncovered modules.** For any module the As-Is Pack itself marks as undocumented, empty, or still a template placeholder — not for modules it already covers — cluster the raw `docs/specs/*/` folders that touch that module's code paths or topic, applying the same cross-task-worthiness judgment `eversis-promote-domain-knowledge` Step 1 already uses (a named convention, a confirmed business rule, or a reusable pattern — not a one-off implementation detail). Produce a candidate component file and `INDEX.md` row exactly as Step 4/5 would, with `source: docs-specs-cluster` and `related_specs` populated from the clustered folders instead of `confluence_url`.
7. **Report what was skipped.** Whether the source page is mostly filled-in content or still mostly template placeholders (`{{...}}`) is **project-dependent, not a default assumption** — a populated, actively-maintained As-Is Pack is a real, observed case (4/6 sections complete, a ready module map, several fully-described modules, existing manual cross-references into `docs/specs/`), not just the pessimistic template-only case described in `global-domain-context-ssot.research.md`, Question 1. Check the actual page before assuming either way. Do not invent content for genuinely empty placeholders — report which sections were empty and skipped (Confluence path) or which modules had no `docs/specs/` history to cluster (fallback path), so the human knows the bootstrap's real coverage.

## No As-Is Pack at all

When `ssot.confluenceSpaceKey` is `null` and the human does not want to set one (Step 1), or no equivalent structured current-state document exists for this project: skip Steps 2-3 and 7's Confluence half entirely. Cluster **all** components directly from raw `docs/specs/*/` history using Step 6's method — the same cross-task-worthiness judgment, the same candidate-file shape, `source: docs-specs-cluster` throughout. This is a distinct, named case, not an implicit fallthrough of the Confluence-first path: there is no page to report placeholders against, so Step 7 only reports which modules had no `docs/specs/` history to cluster.

## What this skill does NOT do

- Does not write anything back to Confluence.
- Does not run on a schedule or watch the page for changes.
- Does not decide what counts as cross-task, durable knowledge for a **currently active task** (that heuristic belongs to `eversis-promote-domain-knowledge`, run at Fine — this skill only handles one-time adoption bootstrap, before any task-level promotion begins).
- Does not, by itself, execute this process against a specific consumer repo's actual Confluence page or `docs/specs/` history — that execution is the consumer repo's own adoption task, never part of `agent-collections`' own Definition of Done for any ticket that changes this skill.
