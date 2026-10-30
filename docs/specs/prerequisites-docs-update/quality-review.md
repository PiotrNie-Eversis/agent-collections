# Quality review (Lite) — Prerequisites docs update

**Date:** 2026-10-13  
**Input:** UX/technical audit report + existing AC-35 scope  
**Mode:** Lite (passes A, B, E, H applied informally)

## Findings applied to AC-35

| Pass | Finding | Resolution in ticket |
| --- | --- | --- |
| E — Precondition guards | No verification loop before Installation | Added AC + requirement for verify section with sample outputs |
| H — Error / boundary states | Windows Docker without WSL2 | Added WSL2 warning admonition requirement |
| A — Entity completeness | Tools listed without download paths | Quick matrix + official links |
| Role separation | Node.js ambiguity for QA/BA | Dedicated optional section + tip admonition |

## Suggestions (incorporated into AC-35 update)

1. **Accepted** — Use Docusaurus `<Tabs groupId="operating-system">` (report §4–5).
2. **Accepted** — GUI installers default; CLI alternatives secondary.
3. **Deferred (non-gating)** — UX KPIs (time-to-first-run, support questions, bounce → Installation) — track manually post-release; not in AC.

## Gate 1.5

User requested direct **AC-35 update** from report — suggestions above applied without separate turn-by-turn review.
