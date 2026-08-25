---
name: eversis-import-confluence-knowledge
description: "One-time import of a Confluence AS-IS Pack page into docs/context/<project>/ topic files, one file per section, via the already-connected atlassian MCP. Use when a project has a confluenceSpaceKey recorded in install-selection.json and wants to seed domain knowledge from an existing Confluence page rather than starting empty."
user-invocable: true
---

# Importing Confluence Knowledge

Splits one Confluence AS-IS Pack page into per-topic domain-knowledge files under `docs/context/<project>/`. One-time, manual — never runs automatically at install time (`--confluence-space-key` only records the key; see `docs/architecture/install-selection.md`).

<principles>
<one-time-not-live>
This is a one-shot import, not a live proxy. Do not re-run it as a sync mechanism, and do not build a tool that reads Confluence on every `eversis_context_get` call — the AS-IS Pack page format (one monolithic page, per-section human owners) does not map cleanly to per-topic file granularity on every read; splitting once, into files that are then edited/promoted normally (`eversis-promote-domain-knowledge`), is the correct fit (global-domain-context-ssot.research.md, Question 1).
</one-time-not-live>
<split-not-copy>
Do not create a single file that copies the whole page. Split it into one file per logical section (e.g. "Cel biznesowy", "Mapa modułów", "Known Issues", "Decision log" — the actual section headings on the source page vary per project, follow what is really there).
</split-not-copy>
</principles>

## When to run

- `.agent-collections/install-selection.json` has a non-null `ssot.confluenceSpaceKey`.
- The human explicitly asks for the import (never triggered by the installer or by another skill automatically).

## Process

1. **Read the confirmed key.** Read `ssot.confluenceSpaceKey` from `.agent-collections/install-selection.json`. If it is `null`, stop and tell the human to either pass `--confluence-space-key` on a future `--sync` run, or provide the Confluence space/page URL directly.
2. **Locate the AS-IS Pack page.** Use the `atlassian` MCP (already configured, see `website/docs/integrations/atlassian.md`) to find the page in the given space (commonly named something like "As-Is Pack" or similar per the project's own Confluence conventions — do not assume an exact title, search the space).
3. **Read the page content.** Fetch the full page body. Identify its top-level sections.
4. **Split into topic files.** For each section, create `docs/context/<project>/<domena>/<temat>.md` where `<domena>` is the component/functionality the section is actually about (not the Confluence section's own generic label — see `eversis-promote-domain-knowledge` for the same `<domena>` = component convention). Each file gets frontmatter:
   - `scope: project`
   - `source: confluence`
   - `confluence_url: <direct link to the source page/section anchor>`
   - `last_updated: <today, ISO date>`
   - `tags: [<relevant tags>]`
5. **Update the index.** Add one row per new component to `docs/context/<project>/INDEX.md` (created by the installer's scaffolding step — see `scripts/lib/setup-agent-collections/ssot.sh`).
6. **Report what was skipped.** The source page is very likely still mostly template placeholders (`{{...}}`) rather than filled-in content (confirmed pattern in `global-domain-context-ssot.research.md`, Question 1) — do not invent content for empty placeholders. Report which sections were empty and skipped, so the human knows the import's real coverage.

## What this skill does NOT do

- Does not write anything back to Confluence.
- Does not run on a schedule or watch the page for changes.
- Does not decide what counts as cross-task, durable knowledge (that heuristic belongs to `eversis-promote-domain-knowledge`, for knowledge discovered during a task — this skill only handles the one-time Confluence seed).
