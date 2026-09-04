---
sidebar_position: 45
title: Auditing domain knowledge
---

# Auditing domain knowledge

**Folder:** `.ai/skills/eversis-audit-domain-knowledge/`  
**Used by:** Anyone running a scheduled review (team-chosen cadence, starting point: quarterly)

Periodic review of `docs/context/<project>/` component files, classifying each into Keep/Update/Consolidate/Replace/Delete using `last_consulted` and `code_paths` as signals. Run manually on a schedule the team chooses — never automatically, never as part of a single task's Fine turn.

## Principles

- **Closed outcome set** — every file gets exactly one of the five classifications; no open-ended commentary.
- Closes the loop [Promoting domain knowledge](./promote-domain-knowledge) cannot close by itself: whether knowledge that was written is still accurate.

## See also

- [Domain context](../../domain-context) — the mechanism being audited
- [Promoting domain knowledge](./promote-domain-knowledge) — where entries originate
