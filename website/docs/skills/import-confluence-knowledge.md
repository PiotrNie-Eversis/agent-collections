---
sidebar_position: 44
title: Importing Confluence knowledge
---

# Importing Confluence knowledge

**Folder:** `.ai/skills/eversis-import-confluence-knowledge/`  
**Used by:** Business Analyst, Context Engineer (one-time seeding)

One-time import of a Confluence AS-IS Pack page into `docs/context/<project>/` topic files, one file per section, via the already-connected `atlassian` MCP. Use when a project has a `confluenceSpaceKey` recorded in `install-selection.json` and wants to seed domain knowledge from an existing Confluence page rather than starting empty.

## Principles

- **One-time, not live** — this is a manual import, never run automatically at install time (`--confluence-space-key` only records the key).

## See also

- [Domain context](../domain-context) — the mechanism this skill seeds
- [Auditing domain knowledge](./audit-domain-knowledge) — the ongoing counterpart to this one-time import
