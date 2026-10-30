# start-here-onboarding-ux — Cleaned Transcript

## Meeting metadata

| Field | Value |
|---|---|
| Date | 2026-10-13 |
| Topic | UX / IA / readability review of **Start here** (`/docs/getting-started/start-here/`) |
| Format | Structured written analysis (Polish), not a spoken meeting |
| Participants | Post-deploy UX reviewer (QA / BA / PO lens); Agent Collections documentation maintainers |
| Related pages | Live `website/docs/getting-started/start-here.md`; sibling Prerequisites / Installation / MCP setup |

## Discussion topics

### Executive verdict

- Start here works as a **technical cheat sheet for engineers** who already know the stack.
- It does **not** meet expectations for a true **onboarding / “Start here”** page for non-technical readers.
- Despite the tip (“map, not encyclopedia”), the page has **cognitive overload**, weak information hierarchy, and (at review time) **broken internal links**.

### Checklist item 1 is a wall of text

- Item 1 of “First successful install checklist” repeats almost the entire Prerequisites story (Cursor vs Claude Code, Node.js paths, VS Code, IT accounts).
- Checklists should be **scannable** (1–2 short sentences per step).
- Recommendation: keep item 1 as a short pointer, e.g. install Cursor or Claude Code, Docker Desktop, and Git → link to Prerequisites.

### Two competing checklists

- Page has **First successful install checklist** (7 steps) and **Setup checklist (maintainers)** (6 steps).
- QA / BA / PO cannot tell which path is theirs or how “user install” differs from “maintainer”.
- Recommendation: Docusaurus **Tabs** or explicit **user journeys**:
  - Path A: End user (QA / BA / consultant)
  - Path B: Framework contributor (maintainer / MCP developer)

### Hermetic jargon without explanation

- Steps 2–7 expose shell/env concepts (`export AGENT_COLLECTIONS_HOME`), installer flags (`--build-mcp --non-interactive`, local/submodule/copy), file names (`install-selection.json`, `docs/context/<project>/INDEX.md`), and “MCP skills list / readiness block”.
- For QA / BA these are entry barriers; they need copy-paste guides on Installation, not a dense map page.

### Redundant “In this section”

- Footer list duplicates left sidebar and Previous/Next pagination.
- Adds no value; also carried broken relative links at review time.

### Proposed page shape (reviewer mockup)

- Short product one-liner + lifecycle quote.
- Tip: try install on a sample/empty folder first.
- **Step 1:** Prerequisites (short + link).
- **Step 2:** Role table (QA/BA/PO → Cursor; Dev/QA Tech → Cursor or Claude Code; Maintainer MCP → Node + MCP setup) with links to Installation / MCP setup.
- **Success criteria:** installer exit 0; `.agent-collections/` + `docs/context/<project>/INDEX.md` exist; `@eversis-implement` responds in chat.
- **Next steps:** Quick wins; Main Flow — remove encyclopedic GitLab/canonical blocks from the critical path (or demote).

## Key decisions (reviewer recommendations)

1. Do **not** duplicate Prerequisites prose inside Start here checklist item 1.
2. Replace dual checklists with **role-based** guidance (tabs or table).
3. Keep Start here as a **map**: short steps, success criteria, next links.
4. Remove or demote redundant **In this section**.
5. English remains docs SSOT; Polish mockup is intent, not literal copy.

## Action items

| Action | Owner | Notes |
|---|---|---|
| Analyze materials → epics/stories | BA workflow | This engagement |
| Fix Start here internal links | Docs (in progress / related AC-36 delta) | Absolute `/docs/...` paths |

## Open questions

| # | Question | Status |
|---|---|---|
| 1 | Tabs vs single role table for path choice? | Open — default proposal: **role table** (simpler, no MDX Tabs required on Start here) |
| 2 | Keep “Requirements traceability” / GitLab canonical refs on Start here or move to Framework reference only? | Open — default: **demote** off primary onboarding path (footer or Framework reference) |
| 3 | Should Installation page get a “copy-paste for QA” subsection in the same epic, or only Start here rewrite? | Open — default: **Start here only**; Installation jargon deferred unless Gate 1 expands scope |

## Preserved context (verbatim intent)

> Strona spełnia swoją rolę jako techniczna ściągawka dla inżynierów… ale **nie spełnia założeń dobrej strony „Start here” / Onboarding UX**.

> Checklista powinna być **skanowalna** (1–2 zwięzłe zdania na punkt).

> Zastosowanie zakładek… lub jasnych ścieżek: *Użytkownik końcowy (QA / BA / Konsultant)* vs *Współtwórca frameworka (Maintainer / MCP Developer)*.
