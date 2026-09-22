---
sidebar_position: 46
title: Adding domain knowledge
---

# Adding domain knowledge

**Folder:** `.ai/skills/eversis-add-domain-knowledge/`  
**Used by:** the person, on purpose, when they already know a durable fact and no ticket is closing. Not the Fine turn.

Person-started draft of one durable fact into `docs/context/<project>/`. Show the draft first. After that draft is approved, write a local working-tree edit; the person commits. The agent does not open a merge request and does not run `git commit`. This is not close-out promotion.

## Principles

- **Draft before write** — show the component file and the two-column index row; write nothing until that specific draft is approved.
- **One-off produces nothing** — a rename, a typo, or a single timeout is not a draft. Starting the command is not proof the fact is durable. Accept only a team convention, a confirmed business rule, or a reusable pattern.
- **Missing index stops** — if `INDEX.md` under `ssot.projectContextPath` does not exist, say so and do not create a second store. An empty index is not missing.

Close-out promotion stays a separate path and is not this command.

```mermaid
flowchart TD
    person["Person knows a durable fact\nno ticket is closing"] --> cmd["eversis-add-domain-knowledge\nuser-invocable: true"]
    cmd --> bar{"Convention, rule,\nor pattern?"}
    bar -->|no, one-off detail| nodraft["No draft\nfiles unchanged"]
    bar -->|yes| idx{"Project INDEX.md\nexists?"}
    idx -->|no| say["Say the index is missing\nno second store"]
    idx -->|yes, including empty| match{"Matching topic?"}
    match -->|yes| ext["Draft extends that topic"]
    match -->|no| neu["Draft of a new topic\nand index row"]
    ext --> show["Show the draft\nwrite nothing yet"]
    neu --> show
    show --> gate{"That draft\napproved?"}
    gate -->|no| unchanged["Files unchanged"]
    gate -->|yes| local["Working-tree edit\nperson commits\nno merge request"]

    fine["Ticket close-out"] --> promote["eversis-promote-domain-knowledge\nuser-invocable: false\nGitLab merge request"]
```

## See also

- [Domain context](../../domain-context) — how knowledge is saved
- [Promoting domain knowledge](./promote-domain-knowledge) — close-out promotion at Fine (`user-invocable: false`); not this command
