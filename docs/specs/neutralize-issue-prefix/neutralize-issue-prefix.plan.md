# Neutralize internal issue prefix ("DHI-") — Plan

Approved research: [`neutralize-issue-prefix.research.md`](./neutralize-issue-prefix.research.md).

## Goal

Replace every `DHI`/`dhi` token (case-preserving → `TASK`/`task`, numbers kept)
across all 60 git-tracked files that contain it, with zero remaining `dhi-`
matches afterward, and without hand-editing generated files.

## Critical constraint: generated files

Two derived artifacts must **not** be hand-edited — they're regenerated from
other sources and a direct edit would either be silently overwritten or cause
CI-style drift:

| Generated file(s) | Source | Regenerate via |
|---|---|---|
| `CLAUDE.md`, `.cursor/rules/eversis-{spec-driven-development,fine-handoff,engineering-manager,code-reviewer}.mdc` | `.ai/rules/**/*.md` | `npm run sync:adapters` |
| `website/src/pages/changelog.md` | `CHANGELOG.md` | `node scripts/sync-changelog.mjs` (or `npm run website:changelog:sync`) |

So the 60 files split into:
- **13 `.ai/rules/**` source files** — edit directly (regeneration picks up the change).
- **`CHANGELOG.md`** — edit directly (regeneration picks up the change).
- **5 generated files** (`CLAUDE.md` + 4 `.mdc` + `website/src/pages/changelog.md`) — do **not** touch; they update via the regenerate step.
- **41 remaining hand-authored files** — edit directly.

## Replacement rule

Case-preserving, word-boundary regex, applied to file contents:

```
DHI  → TASK
Dhi  → Task   (defensive; not observed in the corpus but keep case-symmetry)
dhi  → task
```

Numbers/hyphens/en-dash ranges/asterisks around the token are left untouched
(`DHI-515` → `TASK-515`, `dhi-*/` → `task-*/`, `DHI-528–530` → `TASK-528–530`,
`non-DHI` → `non-TASK`, `| DHI |` → `| TASK |`).

## Phases

### Phase 1 — Build and dry-run the substitution

1. Write a small one-off script (perl or node, run via Bash — not committed)
   that applies the three case variants above to a given file list.
2. Dry-run against a copy of 3–4 representative files covering every match
   shape from the research doc (`docs/context/agent-collections/delivery-index.md`
   for ranges/table/title, `docs/context/eog/upgrade-runbook.md` for the branch
   name example, `AGENTS.md` for the bare-word/path-glob shape, `adapters/claude/generate.mjs`
   for a code comment). Manually diff the dry-run output to confirm no
   over-matching (e.g. does not touch the `website/package-lock.json` incidental
   substrings — that file has no real match anyway per research and is excluded
   from the file list going in).

### Phase 2 — Apply to the 55 directly-editable files

Apply the substitution to:
- the 13 `.ai/rules/**` files,
- `CHANGELOG.md`,
- the 41 remaining hand-authored files (root `AGENTS.md`, `.claudeignore`,
  `.cursorignore`, `.opencodeignore`, `opencode.jsonc`, `.ai/README.md`,
  `.ai/prompts/README.md`, `.ai/skills/README.md`, `.ai/skills/eversis-fine-handoff/SKILL.md`,
  `.ai/skills/eversis-creating-prompts/SKILL.md`,
  `.ai/skills/eversis-jira-task-formatting/jira-task.example.md`,
  `docs/architecture/*.md` (4 files), `docs/context/agent-collections/*.md` (2 files),
  `docs/context/eog/*.md` (3 files), `adapters/**` code/config/README (18 files),
  `scripts/**` (3 files), `website/docs/**` (3 files)).

Do **not** touch `CLAUDE.md`, the 4 `.cursor/rules/*.mdc` files, or
`website/src/pages/changelog.md` in this phase.

### Phase 3 — Regenerate derived artifacts

1. `npm run sync:adapters` — regenerates `CLAUDE.md` and the `.cursor/rules/*.mdc`
   files from the now-updated `.ai/rules/**`.
2. `node scripts/sync-changelog.mjs` — regenerates `website/src/pages/changelog.md`
   from the now-updated `CHANGELOG.md`.

### Phase 4 — Verify

1. `git ls-files | xargs grep -il "dhi-"` → expect **no output**.
2. `npm run sync:adapters:check` → expect exit 0 (no drift between `.ai/rules`
   and the generated Claude/Cursor files).
3. `node scripts/sync-changelog.mjs --check` (or `npm run website:changelog:check`)
   → expect exit 0.
4. Spot-check by eye: `docs/context/agent-collections/delivery-index.md` and
   `task-baseline.md` (heaviest files, tables/ranges), `CHANGELOG.md`, and one
   regenerated file (`CLAUDE.md`) — confirm markdown tables/links are intact and
   case was preserved correctly.
5. `git diff --stat` review before handing back — confirm only the expected ~60
   files (55 direct + 5 regenerated) changed, nothing else.

## Acceptance checks

- [ ] Zero `dhi-` (case-insensitive) matches remain in any git-tracked file.
- [ ] `CLAUDE.md` / `.cursor/rules/*.mdc` / `website/src/pages/changelog.md`
      were never hand-edited — only produced by the regenerate scripts.
- [ ] `npm run sync:adapters:check` passes.
- [ ] `node scripts/sync-changelog.mjs --check` passes.
- [ ] No unrelated content changed (diff limited to the DHI→TASK substitution).
- [ ] `eversis-` prefixed ids/branding are untouched (out of scope, confirmed
      not collaterally affected since the regex only targets `DHI`/`dhi`).

## Out of scope (per research)

- Gitignored local `docs/specs/dhi-*/` working folders (optional follow-up).
- Renaming the `eversis-` branding prefix.
- Redacting other Jira-shaped metadata in `task-baseline.md` beyond the prefix.
