---
sidebar_position: 43
title: Promoting domain knowledge
---

# Promoting domain knowledge

**Folder:** `.ai/skills/eversis-promote-domain-knowledge/`  
**Used by:** Engineering Manager (Fine turn, optional second draft)

Evaluates whether a just-finished task produced durable, cross-task domain knowledge (a convention, a confirmed business rule, a reusable integration pattern) and, if so, prepares a promotion draft for the Fine turn. Writes to `docs/context/<project>/` only after explicit human approval, via the GitLab REST API — never a local `domain-context` checkout.

## Principles

- **No new gate** — this does not block Fine; it adds an optional, independently-approved second draft alongside the QA comment draft.
- Most tasks produce nothing worth promoting — that is the common case, not an exception.

## See also

- [Fine handoff](./fine-handoff) — the draft this skill feeds into
- [Domain context](../domain-context) — the mechanism this skill writes into
