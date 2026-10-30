# Spec folder naming — Cleaned Transcript

## Meeting Metadata

| Field | Value |
|---|---|
| Date | 2026-09-24 |
| Duration | Single written recommendation (not a timed meeting) |
| Topic | Topic slug in `docs/specs/` folder and file names |
| Context | Follow-up to a discussion of how an agent, at the start of Implement, decides which old spec is useful when the folder name is only a ticket key. The requester asked to analyze one specific recommendation. |

## Participants

| Name | Role |
|---|---|
| Piotr Niemirski | Requester |

## Executive Summary

The recommendation keeps the ticket key at the start of the spec folder and file names, and adds a short topic after it (`ac-2-context-management`). A topic-first name (`context-ac-2-management`) is rejected because Implement opens `docs/specs/<issue-kebab>/` from the key alone. A short topic in the first heading of the research file is called more useful than a longer folder name. The folder name does not replace an `INDEX.md` row. Existing folders are not mass-renamed. Changing `spec-driven-development.md` is called out as its own decision.

## Discussion Topics

### Why a ticket-only name is a weak signal

- Folders such as `docs/specs/ac-2/` do not say what is inside.
- An agent may search filenames without a limit. It may fully open at most one or two spec files.
- Usefulness is judged from grep hits on headings and lines, not from the key alone.
- A first heading that is only `# AC-2 - Analysis Result` does not help that judgment.

### Recommended name shape

- Keep the ticket key at the front: `ac-2-context-management`.
- Matching files: `ac-2-context-management.research.md` and `ac-2-context-management.plan.md`.
- A glob on the topic word `context` hits the folder. A search on `ac-2` still hits it.
- Do not put the topic first (`context-ac-2-management`). After `/eversis-implement AC-2`, the agent opens `docs/specs/ac-2/`. A folder that does not start with that path looks missing, and a second folder gets created.

### What the name does not do

- It helps filename search only. The decision to open a file still comes from headings.
- A short topic in the first heading helps more than a longer folder name.
- The folder name is the label of one ticket. An `INDEX.md` row is the label of a fact that should outlive that ticket. The naming change does not replace promotion into the index.
- Do not mass-rename old folders. In this repository `docs/specs/*/` is gitignored. The new convention is for later tasks.
- Editing the naming rule in `spec-driven-development.md` is a separate decision, not a rename of existing folders.

## Key Decisions

| # | Decision | Made By | Conditions / Caveats |
|---|----------|---------|---------------------|
| 1 | New spec folders use the ticket key, then a short topic. The written convention in `spec-driven-development.md` changes with that. Old folders stay. `INDEX.md` promotion stays as it is. | Piotr Niemirski | Approved 2026-09-24 ("Ok" after the convention-text explanation). |

## Action Items

| # | Action | Assigned To | Deadline |
|---|--------|-------------|----------|
| 1 | Record an intent brief and stop for scope approval before extraction. | Analyst | This session |

## Open Questions

| # | Question | Raised By | Notes |
|---|----------|-----------|-------|
| 1 | Is the rule change in `spec-driven-development.md` in scope, given the source calls it a separate decision? | Analyst | Without the rule, Implement still opens the key-only path. |
| 2 | Must the first heading of a research file carry the topic, or only the folder and file names? | Analyst | The source says the heading helps more than the folder name. |

## Preserved Context

> "Lepszy kształt to `ac-2-context-management` oraz pliki `ac-2-context-management.research.md` i `ac-2-context-management.plan.md`."
> — recommendation under analysis, regarding the name shape

> "`context-ac-2-management` psuje odczyt, którego Implement używa w pierwszej kolejności."
> — recommendation under analysis, regarding topic-first names

> "Nie zastępuje to wiersza w `INDEX.md`. [...] Starych katalogów nie trzeba masowo przerabiać. [...] Zmiana reguły w `spec-driven-development.md` to już osobna decyzja, nie poprawka nazwy."
> — recommendation under analysis, regarding limits of the change
