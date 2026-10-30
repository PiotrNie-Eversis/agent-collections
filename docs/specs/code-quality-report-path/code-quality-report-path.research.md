# code-quality-report-path - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | [AC-62](https://eversis.atlassian.net/browse/AC-62) |
| Title | Why `code-quality-report.md` lands in repo root instead of `docs/` |
| Description | Analyze output path of `/eversis-review-codebase` vs project docs conventions |
| Priority | — |
| Reporter | User (chat) |
| Created Date | 2026-10-14 |
| Labels | framework, prompts, docs layout |
| Estimated Effort | Small (prompt/docs path change if approved) |

## Business Impact

Agent-generated quality reports currently sit at the repository root. That conflicts with the docs triad (`docs/context/`, `docs/plans/`, `docs/specs/`) and pollutes the working tree / PR noise. Aligning the prompt output path with `docs/` keeps deliverables discoverable and consistent with other agent artifacts.

## Gathered Information

### Knowledge Base & Task Management Tools

No Jira ticket for this analysis. Trigger: `/eversis-implement` + `przeanalizuj` against `eversis-review-codebase` and the existing root file `code-quality-report.md`.

### Codebase

**Root cause (by design in the prompt SSOT):** `.ai/prompts/public/eversis-review-codebase.md` explicitly instructs agents to write the report at the **repository root**:

1. **Output section** (≈ line 79): *A `code-quality-report.md` file saved to the repository root*
2. **Phase 4 Report Generation** (≈ line 169): *Save the report as `code-quality-report.md` in the repository root.*

The website mirror (`website/docs/reference/prompts/public/eversis-review-codebase.md`) repeats the same wording (synced from `.ai/`).

**Not caused by:**

| Suspect | Finding |
|---|---|
| Skill `eversis-codebase-analysing` | Does **not** set `code-quality-report.md` or root. Standalone skill uses `./codebase-analysis.example.md` template; when invoked by this prompt it **defers** to the caller's output file. |
| Adapter / Cursor command shim | Thin pointer only; no alternate path. |
| Installer / MCP | No generation of this file. |
| Agent improvisation | Agent followed the prompt literally (file exists at root; dated 2026-10-13 AC-36 audit). |

**History:** Prompt introduced in commit `e54eb18` (2026-08-06) with root path from day one — not a later regression.

**Gitignore:** `.gitignore` does **not** ignore `code-quality-report.md`. Root report is trackable and can appear as accidental dirty/commit noise (current git status shows it modified). Contrast: `docs/specs/*/` is gitignored in this framework repo.

### Relevant Links

- `.ai/prompts/public/eversis-review-codebase.md` — canonical Output + Phase 4 path
- `.ai/skills/eversis-codebase-analysing/SKILL.md` — analysis process; no root report path
- `docs/specs/README.md` — agent research/plan under `docs/specs/`
- `docs/plans/README.md` — optional flat plans under `docs/plans/`
- `AGENTS.md` — deliverables triad: `docs/context/`, `docs/plans/`, `docs/specs/`

### Relevant Charts & Diagrams

```text
User → eversis-review-codebase (Architect)
         → skills: codebase-analysing / technical-context / code-reviewing
         → Phase 4: MUST write ./code-quality-report.md  ← SSOT path
                                                    ≠ docs/...
```

## Current Implementation Status

### Existing Components

- `eversis-review-codebase` prompt — **needs modification** (path strings in Output + Phase 4 + any docs sync)
- Website prompt reference — **needs sync** after `.ai/` change (`npm run sync:adapters` / docs sync as used by this repo)
- Skill `eversis-codebase-analysing` — **can be reused** unchanged (no path ownership)
- Live artifact `code-quality-report.md` at repo root — **existing; relocate or leave** as a one-off cleanup if path policy changes

### Key Files and Directories

- `.ai/prompts/public/eversis-review-codebase.md` — sole SSOT defining root output
- `website/docs/reference/prompts/public/eversis-review-codebase.md` — published copy
- `code-quality-report.md` — current root artifact (AC-36 focused audit)
- `docs/` — triad for agent deliverables; **no** dedicated `docs/reports/` or quality-report convention today

## Gap Analysis

### Question 1
#### Where under `docs/` should the report live?
**Answer (2026-10-14):** **B** — `docs/reports/code-quality-report.md` (+ README for the folder).

| Option | Path | Pros | Cons |
|---|---|---|---|
| A | `docs/code-quality-report.md` (flat under `docs/`) | Simple; visible next to architecture READMEs | Single overwrite; no history per run |
| B | `docs/reports/code-quality-report.md` | Clear “generated reports” bucket | New folder; need README + convention |
| C | `docs/specs/<topic>/code-quality-report.md` or dated name | Fits specs workflow; gitignored here | Harder to find; name collision with research/plan |
| D | Keep root but **gitignore** the file | Minimal prompt change | Still wrong place for docs triad |

### Question 2
#### Should existing root `code-quality-report.md` be moved in the same change?
**Answer (2026-10-14):** **MOVE** — relocate root file to `docs/reports/code-quality-report.md` in the same change as the prompt path update.

### Question 3
#### Consumer projects: is root path intentional for “drop file where humans look first”?
**Answer (2026-10-14):** **OK** — original root-visibility intent acknowledged; superseded by `docs/reports/` for alignment with the docs triad. Call out in CHANGELOG.

## Human gates

1. ~~Approve research~~ — done (`Q1. B.` / `Q2. MOVE;` / `Q3. OK;`)
2. ~~Approve plan~~ — done (`Plan is ok.`)
3. ~~Create Jira ticket~~ — done ([AC-62](https://eversis.atlassian.net/browse/AC-62))
4. Implement → Review → Fine

## Suggested next steps (after research approval)

1. Plan: change prompt Output + Phase 4 to `docs/reports/code-quality-report.md`; create `docs/reports/README.md`; sync website docs; MOVE root artifact; CHANGELOG + AGENTS deliverables row.
2. Skill `eversis-codebase-analysing` unchanged unless later requested.
3. Do **not** gitignore `docs/reports/` by default (trackable artifact, unlike `docs/specs/*/`).

## Website impact (commit `4d1a30c7c`)

**Question (2026-10-14):** Do the AC-62 path changes require updates under `website/`?

**Answer: Yes — and they are already shipped in that commit.** No further `website/` work is needed for this scope.

| Required? | Path | Role | Status in `4d1a30c7c` |
|---|---|---|---|
| **Yes** | `website/docs/reference/prompts/public/eversis-review-codebase.md` | Generated mirror of `.ai/` prompt SSOT — must show `docs/reports/…` not root | Updated (Output + Phase 4) |
| **Yes** | `website/src/pages/changelog.md` | Published Unreleased changelog | AC-62 bullet added |
| No | `docs/reports/README.md`, moved report, `AGENTS.md` | Repo-internal deliverables / orientation | Not website surfaces |
| No | Other `website/docs/**` pages | No other published docs cited the old root path | Grep clean post-commit |

**Sync rule reminder:** edit `.ai/prompts/…` then `npm run sync:website-docs` (do not hand-edit the prompt mirror). Changelog: root `CHANGELOG.md` → `npm run website:changelog:sync` / check.

**Residual gap:** none for website. SSOT vs mirror differ only by the generator footer comment on the website copy.

## Changelog

| Date | Change |
|---|---|
| 2026-10-14 | **DELTA** — Post-ship analysis of `4d1a30c7c`: website **was required** (prompt mirror + changelog); both included in the commit; no extra `website/` follow-up. |
