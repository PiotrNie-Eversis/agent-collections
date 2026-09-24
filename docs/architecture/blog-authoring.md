# Blog authoring

Maintainer checklist and editorial standard for technical write-ups on the documentation site (`website/blog/`). This file is an internal framework guide and is not a public docs page. Do not copy it into `website/docs/` or into `website/blog/`.

---

## 1. When a change earns a post

Write a blog post when a framework change introduces or fundamentally alters a core mechanism worth explaining in depth:
- Context read budgets and token window governance.
- Session lifecycle and execution continuity state machines.
- Structural separation of knowledge types (e.g. ADRs vs. domain facts).
- Container isolation, MCP tooling integration, or upgrade contracts.

**What stays in the changelog:**
- Bug fixes, configuration tweaks, minor patch releases, and one-line adjustments stay strictly in the root [`CHANGELOG.md`](../../CHANGELOG.md) (and `/changelog/`).
- Never publish a blog post for every individual changelog bullet or routine release.

---

## 2. Separation of Concerns

A blog post serves a distinct audience and purpose from release notes or team notices:

| Channel | Target Audience | Primary Content |
| :--- | :--- | :--- |
| **Team / Slack Notice** | Daily practitioners (BAs, Devs, QA) | Role-specific checklists, chat command how-tos, and copy-paste upgrade scripts. |
| **Changelog (`/changelog/`)** | Maintainers and consumers | Bulleted SemVer release history and technical change logs. |
| **Technical Blog (`/blog/`)** | Engineers & architects | Deep-dive explanation of *why* things broke, *how* the new architecture works under the hood, and where the boundaries lie. |

### Strictly Forbidden in Blog Posts
To keep the blog focused on high-level architecture:
- **No role-specific checklists** (e.g. "For BAs: ...", "For QA: ...").
- **No chat how-to prompt walkthroughs** (e.g. "Type eversis-record-decision into chat...").
- **No raw terminal upgrade blocks** (e.g. copy-paste bash scripts with `cd vendor/...`).
- Reference user documentation (`/docs/getting-started/start-here`) or team announcements for operational guides.

---

## 3. Editorial & Content Standards

A successful technical blog post must give readers an authentic look under the hood. Follow these five core writing principles:

### A. Problem-First Framing (Engineering Failure Modes)
Never open with a dry list of policies or rules. Always ground the article in the concrete engineering failure mode that motivated the change:
- Describe the exact breakdown (e.g., token window bloat, the *Lost in the Middle* attention degradation phenomenon, premature session halts from unobservable IDE metrics).
- Show how the previous behavior degraded agent performance or team workflow.

### B. "Under the Hood" Mechanics & State Machines
Move past high-level summaries into concrete technical mechanics:
- Explain the data flows, single-entry routers, and retrieval limits.
- Detail the exact state machine triggers (e.g., when a checkpoint fires, how in-turn continuation occurs, and how crash recovery scans previous logs).
- Detail the container architecture, environment variables (`CONSUMER_PROJECT_ROOT`), and volume mounting contracts.

### C. Visual Architectural Artifacts
Abstract multi-step workflows and knowledge models become significantly easier to follow when illustrated visually:
- **Mermaid Flowcharts:** Use to contrast old vs. new architectural patterns (e.g., unbounded reads vs. two-cost budgets).
- **Mermaid Sequence Diagrams:** Use to illustrate agent lifecycle interactions (e.g., implement → test → checkpoint → resume → review → QA draft).
- **Comparison Tables / Matrices:** Use when explaining decoupled systems or separated concerns (e.g., domain facts vs. ADRs).

### D. Invariant Boundaries & What Did Not Change
Clearly articulate what remains constant to reassure engineers about system stability:
- State explicitly what the framework does *not* do automatically.
- Reiterate that human approval gates remain inviolable before any persistent disk write or external tool publication.
- Clarify that SemVer releases remain anchored in `/changelog/`.

### E. Standard Five-Part Structure
Every article should follow this general progression:
1. **The Hook & Problem Space:** High-level problem statement and context.
2. **Failure Modes & Architectural Solutions:** Detailed technical breakdown of 3–4 core pillars, complete with diagrams and mechanics.
3. **Operational Boundaries:** Clear distinction between project-owned vs. framework-managed code.
4. **What Did Not Change:** Stable invariants and human gates.
5. **Summary & References:** Concise recap linking to `/changelog/` and getting-started docs.

---

## 4. Frontmatter and Layout Conventions

- **File Path:** `website/blog/YYYY-MM-DD-<slug>.md` (date prefix matches the calendar day the post is published).
- **Language:** English only.
- **Author Byline:** Optional. If omitted, the post renders cleanly without an author card (recommended for team/framework posts). If included, use inline frontmatter:
  ```yaml
  authors:
    - name: Firstname Lastname
  ```
- **Truncation:** Place `<!-- truncate -->` after the introductory overview so the `/blog` index stays clean and readable.
- **Changelog Link:** Always link to `/changelog/` (never edit generated changelog files directly).

---

## 5. Review & Human Approval Gate

Before any post is committed as final or deployed:
1. A human must review and approve the draft wording.
2. Verify quality commands from the repository root:
   ```bash
   npm run website:build
   npm run website:changelog:check
   ```
3. Ensure no Docusaurus build warnings, broken links, or syntax errors in Mermaid diagrams.
