# agent-collections — Task Baseline

## Baseline Summary

| Field | Value |
|---|---|
| Project | AC (current) and DHI (historical; was TASK — Jira project re-keyed; TASK-* rows below are stale/unverified against current Jira, kept for history) |
| Last Refreshed | 2026-10-27 |
| Primary Source of Truth | Jira |
| Notes | Full backlog under epic TASK-515 (children are Tasks, converted from Story 2026-07-31); spec-driven delivery mandatory; docs of agent-collections and cursor-collections fully separated. TASK-515's live Jira equivalent (DHI-515, "Multi-Agent AI Context Isolation & Standard") is now status **Done** — new epic **DHI-641** was created 2026-09-04 as a sibling, not a child, for follow-on docs UX/UI work. New Agent Collections backlog lives in project **AC**. |

**Delivery traceability:** see [`delivery-index.md`](./delivery-index.md) for Jira key → wave → paths on `main` (CQ2 waiver for missing per-story folders 530, 532–540).

## Current Epics

| Jira Key | Title | Priority | Status | Latest Session |
|---|---|---|---|---|
| TASK-515 | Multi-Agent AI Context Isolation & Standard | Medium | To Do | `docs/specs/cursor-collection-migration/` (stale — see Notes; live Jira key is DHI-515, status Done) |
| DHI-641 | Documentation Site: UX/UI Restructuring (Intent-Based IA) | Highest | To Do | `docs/specs/docs-ux-ui-analysis/` |
| AC-63 | Getting Started MCP Setup: guided onboarding and DevEx recovery | Highest | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-72 | Getting Started Installation: guided onboarding and DevEx recovery | Highest | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-91 | Integrations: Optional Chrome DevTools for diagnosis and performance | High | Backlog | `docs/specs/chrome-devtools-mcp/` |

## Current Tasks

| Jira Key | Parent Epic | Title | Priority | Status | Latest Session |
|---|---|---|---|---|---|
| TASK-516 | TASK-515 | Inventory legacy Cursor Collections assets | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-517 | TASK-515 | Define core neutral rules directory structure | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-518 | TASK-515 | Extract shared orchestration rules to core | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-519 | TASK-515 | Extract domain-scoped core rules | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-520 | TASK-515 | Port skills and prompts to core-neutral storage | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-521 | TASK-515 | Establish core versioning and upgrade contract | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-522 | TASK-515 | Encode spec-driven development as mandatory delivery standard | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-523 | TASK-515 | Define adapter architecture and mapping specification | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-524 | TASK-515 | Implement Cursor adapter | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-526 | TASK-515 | Implement Claude Code adapter | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-525 | TASK-515 | Define OpenCode future adapter manifest | Medium | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-527 | TASK-515 | Build adapter sync and generation tooling | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-528 | TASK-515 | Define cross-tool ignore and scoping strategy | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-529 | TASK-515 | Deliver synchronized ignore files | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-530 | TASK-515 | Implement monorepo glob scoping for team isolation | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-531 | TASK-515 | Define agnostic AGENTS.md template and role matrix | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-532 | TASK-515 | Publish reference AGENTS.md for agent-collections | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-533 | TASK-515 | Bootstrap self-contained agent-collections repository | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-534 | TASK-515 | Deliver multi-tool installation mechanism | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-536 | TASK-515 | Implement modular deployment profiles | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-535 | TASK-515 | Port framework MCP server to agent-collections | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-537 | TASK-515 | Document consumer upgrade path from central framework | Medium | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-538 | TASK-515 | Interactive bash install wizard — AI agent and MCP selection | Highest | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-539 | TASK-515 | Write migration guide from Cursor Collections | High | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-541 | TASK-515 | Publish README and getting-started documentation | Medium | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-542 | TASK-515 | Pilot deployment and context isolation validation | Medium | To Do | `docs/specs/cursor-collection-migration/` |
| TASK-540 | TASK-515 | Migrate and rebrand Docusaurus documentation site | High | To Do | `docs/specs/cursor-collection-migration/` |
| DHI-642 | DHI-641 | Reader can navigate the sidebar by intent instead of artifact type | Highest | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-643 | DHI-641 | Reader sees an explicit "start here" recommendation in every section | High | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-644 | DHI-641 | CTO or beginner reader can choose their path from the first screen | Medium | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-645 | DHI-641 | Reader sees plain-language framing before technical vocabulary on the Introduction page | High | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-646 | DHI-641 | Reader sees an explanation the first time SSOT, adapters, or MCP is used | Medium | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-647 | DHI-641 | Reader can scan the Framework Reference page as single-concept sections | Medium | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-648 | DHI-641 | Reader scans Agents/Skills/Prompts overview entries in one consistent format | High | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-649 | DHI-641 | Reader follows one canonical installation checklist regardless of entry page | High | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-650 | DHI-641 | Reader sees the homepage's pipeline diagram and outcome framing on the docs Introduction | Medium | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-651 | DHI-641 | Reader sees a verified trust signal on the docs Introduction | Low | To Do | `docs/specs/docs-ux-ui-analysis/` |
| DHI-652 | DHI-641 | Align README.md with the new intent-based docs site IA | Medium | To Do in Jira (implementation done, code review PASS, QA comment posted — status not yet transitioned) | `docs/specs/dhi-652/` |
| DHI-653 | DHI-641 | Align header navbar with the new 4-cluster docs IA | Medium | To Do (assignee: Piotr Niemirski) | `docs/specs/dhi-641/` |
| AC-15 | — | Add full OpenCode support | High | Backlog | `docs/specs/opencode-full-support/` |
| AC-115 | — | Full Pi Agent support (Epic) | Medium | Backlog (assignee: Piotr Niemirski) | `docs/specs/pi-agent-support/` |
| AC-14 | AC-115 | Add full Pi Agent support | Medium | In Progress (assignee: Piotr Niemirski) | `docs/specs/pi-agent-support/` |
| AC-111 | AC-115 (AC-14 blocks) | Team signs Pi in with a subscription and keeps model costs predictable | Medium | Backlog (assignee: Piotr Niemirski) | `docs/specs/pi-agent-support/` |
| AC-112 | AC-115 (AC-14 blocks) | Pi sessions use token-economy rules without skipping tests, review, or Fine | Medium | Backlog (assignee: Piotr Niemirski) | `docs/specs/pi-agent-support/` |
| AC-113 | AC-115 (AC-14 blocks) | Pi install keeps heavy and secret files out of the agent's reach | Medium | Backlog (assignee: Piotr Niemirski) | `docs/specs/pi-agent-support/` |
| AC-114 | AC-115 (AC-14 blocks) | Team can run the Pi agent in an isolated workspace with restricted network | Low | Backlog (assignee: Piotr Niemirski) | `docs/specs/pi-agent-support/` |
| AC-22 | AC-2 | Framework user can draft a domain fact without closing a ticket | Medium | Backlog (assignee: Piotr Niemirski) | `docs/specs/manual-domain-knowledge/` |
| AC-31 | — | Publish a technical blog for framework change write-ups | High | Backlog | `docs/specs/website-technical-blog/` |
| AC-32 | AC-2 | Name new spec folders with the ticket key and a short topic | Medium | Backlog | `docs/specs/spec-folder-naming/` |
| AC-64 | AC-63 | Reader gets a plain-language mental model for MCP | Highest | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-65 | AC-63 | Reader chooses a setup path by role | High | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-66 | AC-63 | Reader can complete core local server setup first | Highest | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-67 | AC-63 | Reader connects the core server via Cursor and Claude Code tabs | Highest | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-68 | AC-63 | Reader verifies that MCP connected successfully | Highest | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-69 | AC-63 | Reader understands the project folder requirement in plain language | High | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-70 | AC-63 | Optional integrations are clearly non-blocking | High | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-71 | AC-63 | Reader can self-recover via a troubleshooting table | High | Backlog | `docs/specs/mcp-setup-ux-recovery/` |
| AC-73 | AC-72 | Reader sees a clear three-step install framing | Highest | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-74 | AC-72 | Reader understands framework vs consumer project | Highest | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-75 | AC-72 | Reader follows OS-specific clone and environment steps | Highest | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-76 | AC-72 | Reader runs one recommended install command in their project | Highest | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-77 | AC-72 | Reader verifies that installation succeeded | Highest | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-78 | AC-72 | Advanced and maintainer content sits below the happy path | High | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-79 | AC-72 | Reader scans a short table of contents of major sections only | High | Backlog | `docs/specs/installation-ux-recovery/` |
| AC-82 | AC-91 | Integrations: Optional Chrome DevTools catalog entry | High | Backlog (Story, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-83 | AC-91 | Agent guidance: Browser job split for verification and diagnosis | High | Backlog (Story, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-84 | AC-91 | Frontend performance: Trace only when Chrome DevTools is enabled | Medium | Backlog (Story, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-85 | AC-82 | Maintainer can offer Chrome DevTools as an opt-in integration | High | Backlog (Sub-task, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-86 | AC-82 | Consumer can read what Chrome DevTools is for before opting in | High | Backlog (Sub-task, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-87 | AC-83 | UI reviewer can keep verifying screens with Playwright | High | Backlog (Sub-task, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-88 | AC-83 | Engineer can follow a written split of browser jobs | High | Backlog (Sub-task, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-89 | AC-84 | Engineer can get a performance trace before optimization advice | Medium | Backlog (Sub-task, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |
| AC-90 | AC-84 | Engineer can optimize without a missing Chrome DevTools tool | Medium | Backlog (Sub-task, assignee: Piotr Niemirski) | `docs/specs/chrome-devtools-mcp/` |

## Session Archive Index

| Session Folder | Summary |
|---|---|
| 2026-07-31 | Issue type conversion Story→Task for TASK-516–542 | `docs/specs/cursor-collection-migration/` |
| `docs/specs/cursor-collection-migration/` | Ideate → Jira push: Agent Collections migration backlog (27 stories) under TASK-515; Gate 1.5 S-01–S-04 accepted, S-05 rejected |
| `docs/specs/docs-ux-ui-analysis/` | 2026-09-04 — Analyzed external UX/UI benchmark report (Agent Collections docs vs. AI Hero) → 1 new epic (DHI-641) + 10 Tasks pushed to Jira project DHI, parented to a new epic (DHI-515 was Done, so a sibling epic was created instead). Gate 1 approved as presented; Quality Review Lite pass, 4/4 suggestions accepted (glossary creation gap, sidebar redirect gap, diagram accessibility gap, cross-audit dependency gate). Post-push verification passed — all summaries, parent links, priorities, and labels match `jira-tasks.md`. |
| `docs/specs/opencode-full-support/` | 2026-09-21 — Approved scope for full OpenCode support. Pushed as one Task AC-15 on Jira project AC (board convention matches AC-14). Post-push verification passed: summary, acceptance criteria, priority High, labels, status Backlog. No parent epic. |
| `docs/specs/pi-agent-support/` | 2026-09-21 — Approved intent for full Pi Agent support ([pi.dev](https://pi.dev/)). One Task created in project AC: AC-14. Shipped adapter for rules, skills, prompt templates, install, and docs. Same day: scope extended with the AC-2 follow-up — ~50% context budget on Pi only (`context_info`, `pi-rolling-compaction`); no window-fill trigger for Cursor or Claude Code. Lite quality review: 0 suggestions. Post-push verification passed.  2026-10-27 — Scope extension from “GitHub Copilot Pro a koszty API.md”: Tasks AC-111 – AC-114 (subscription costs, token-economy rules, file exclusions, isolated workspace), no parent, each blocked by AC-14; AC-113 relates DHI-529. Gate 0 approved (A–D in scope, Pi-only token rules); Task instead of Sub-task per AC hierarchy rule. Lite QR S-01 – S-06 accepted. AC-14 Out of Scope narrowed (sandbox → AC-114). Post-push verification passed. Then Epic AC-115 created as parent of AC-14 and AC-111 – AC-114; all assigned to Piotr Niemirski. |
| `docs/specs/manual-domain-knowledge/` | 2026-09-21 — One Sub-task AC-22 under AC-2: a person can start a command that drafts a durable domain fact without closing a ticket. Gate 0 approved (new skill, working-tree write, parent AC-2). Lite quality review: S-01–S-03 accepted. Post-push verification passed. Assignee: Piotr Niemirski. |
| `docs/specs/website-technical-blog/` | 2026-09-24 — One Task AC-31: docs-site blog for technical write-ups of framework changes. Gate 0 approved (notice / changelog / blog stay separate; a post deepens the team message). Lite quality review: 0 suggestions. No parent epic. Post-push verification passed. |
| `docs/specs/spec-folder-naming/` | 2026-09-24 — One Sub-task AC-32 under AC-2: new spec folders use the ticket key, then at most three topic words. Implement must find that folder from the key alone. Lite quality review: 0 suggestions. Post-push verification passed. |
| `docs/specs/mcp-setup-ux-recovery/` | 2026-10-14 — UX audit of `/docs/getting-started/mcp-setup` → Epic AC-63 + Tasks AC-64–AC-71. Gate 0 skipped (unambiguous); Gate 1 locked (no Claude Desktop tab; English-only; new AC epic). Lite QR S-01–S-04 accepted. Post-push verification passed (parent AC-63, Task type, Relates AC-37/AC-38, Blocks AC-66→67→68). |
| `docs/specs/installation-ux-recovery/` | 2026-10-14 — UX audit of `/docs/getting-started/installation` → Epic AC-72 + Tasks AC-73–AC-79. Gate 0 skipped (unambiguous); Gate 1 locked (new AC epic; Git Bash primary; English-only). Lite QR S-01–S-03 accepted. Post-push verification passed (parent AC-72, Task type, Relates AC-63/AC-37/AC-38/DHI-649, Blocks AC-74+AC-75→AC-76→AC-77). |
| `docs/specs/chrome-devtools-mcp/` | 2026-10-15 — Optional Chrome DevTools MCP catalog. Epics AC-82–AC-84 and Tasks AC-85–AC-90. Gate 0 approved; Gate 1 all six tasks; Lite QR S-01–S-04 accepted. Issue type Task. Assignee Piotr Niemirski. Post-push verification passed (parents AC-82/83/84, status Backlog, Blocks AC-82→83→84 and AC-86→88→89, Relates AC-85–86, AC-85–87, AC-89–90). |
