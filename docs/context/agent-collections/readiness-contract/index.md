---
scope: project
source: agent-discovered
status: approved
last_updated: "2026-10-20"
tags: [orchestration, readiness-contract, context-router]
code_paths:
  - ".ai/rules/orchestration/engineering-manager.md"
  - ".ai/skills/eversis-orchestrating-implementation/SKILL.md"
  - ".ai/rules/orchestration/spec-driven-development.md"
  - ".ai/rules/orchestration/README.md"
  - ".ai/prompts/public/eversis-implement.md"
  - "mcp/eversis-collections-mcp/src/context.ts"
confluence_url: null
related_specs: ["docs/specs/ac-2/"]
---

# Implement readiness contract — Layer A / Layer B

The Implement readiness block's **line-count wording** is asserted in five files, but its **literal shape** (the `Flow` enum, the set of optional lines) is defined in only two of them:

- **Layer A** (defines the block): `engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`.
- **Layer B** (only delegates, rewords line-count phrasing): `spec-driven-development.md`, `orchestration/README.md`, `eversis-implement.md`.

**Never duplicate the block's shape into Layer B.** A shape change (a new optional line, a new enum value) touches only the two Layer A files; a wording-only change ("four required lines...") touches all five. Getting this backwards — requiring "identical" treatment across all five — forces duplicating the block definition into files that deliberately delegate it, which is the exact SSOT regression AC-2 itself was written to prevent elsewhere.

Also: a new orchestration signal that answers an orthogonal question (e.g. "is this a resumed session?") must never be added as a value of an existing enum that answers a different question (e.g. `Flow`, "which workflow?") — model it as its own independent optional field instead. `agent-collections` shipped exactly this category error once (`Resume` as a `Flow` value) before catching and reverting it.

An AC-26 checkpoint does not end the session. The same turn writes `RESUMED` and the session continues through the remaining tasks, Review, and Fine, unless the person asks to stop. `Resume` on a later session applies only while that checkpoint stays unconsumed.

Separately: `docs/context/<project>/INDEX.md` rows must stay exactly two columns (`| component | one-line summary |`) — `context.ts`'s parser is anchored right after the second column and silently drops any row with a third column, with no error or log.
