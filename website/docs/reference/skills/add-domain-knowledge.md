---
sidebar_position: 46
title: Adding domain knowledge
---

# Adding domain knowledge

**Folder:** `.ai/skills/eversis-add-domain-knowledge/`  
**Used by:** the person, on purpose, when they already know a durable fact and no ticket is closing. Not the Fine turn.

Person-started draft of one durable fact into `docs/context/<project>/`. Show the draft first. Nothing is written until that specific draft is approved. After approval, the write is a local working-tree edit of `docs/context/<project>/` that also updates a row in `docs/context/<project>/INDEX.md` when the summary is new or changed; the person commits. The agent does not open a merge request and does not run `git commit`. **Do not** treat this as Fine close-out promotion — that remains [Promoting domain knowledge](./promote-domain-knowledge).

## Principles

- **Draft before write** — show the component file and the two-column index row; write nothing until that specific draft is approved.
- **One-off produces nothing** — a rename, a typo, or a single timeout is not a draft. Starting the command is not proof the fact is durable. Accept only a team convention, a confirmed business rule, or a reusable pattern.
- **Missing index stops** — if `INDEX.md` under `ssot.projectContextPath` does not exist, say so and do not create a second store. An empty index is not missing.

Close-out promotion stays a separate path and is not this command.

import PeleDiagram from '@site/src/components/PeleDiagram';

export const addFactFlow = `flowchart TD
    person["Person knows a durable fact<br/>no ticket is closing"] --> cmd["eversis-add-domain-knowledge<br/>user-invocable: true"]
    cmd --> bar{"Convention, rule,<br/>or pattern?"}
    bar -->|no, one-off detail| nodraft["No draft<br/>files unchanged"]
    bar -->|yes| idx{"Project INDEX.md<br/>exists?"}
    idx -->|no| say["Say the index is missing<br/>no second store"]
    idx -->|yes, including empty| match{"Matching topic?"}
    match -->|yes| ext["Draft extends that topic"]
    match -->|no| neu["Draft of a new topic<br/>and index row"]
    ext --> show["Show the draft<br/>write nothing yet"]
    neu --> show
    show --> gate{"That draft<br/>approved?"}
    gate -->|no| unchanged["Files unchanged"]
    gate -->|yes| local["Working-tree edit<br/>person commits<br/>no merge request"]

    fine["Ticket close-out"] --> promote["eversis-promote-domain-knowledge<br/>user-invocable: false<br/>GitLab merge request"]`;

<PeleDiagram
  id="add-fact-flow"
  source={addFactFlow}
  label="A person knows a durable fact and no ticket is closing, so they run eversis-add-domain-knowledge, which a person can invoke. A one-off detail gets no draft and files stay unchanged. If the project INDEX.md does not exist, the agent says the index is missing and creates no second store. If it exists, even empty, the draft extends a matching topic or proposes a new topic and index row. The agent shows the draft and writes nothing yet. If the draft is not approved, files stay unchanged. If it is approved, it becomes a working-tree edit the person commits, with no merge request. Separately, ticket close-out uses eversis-promote-domain-knowledge, which a person does not invoke, through a GitLab merge request."
/>

## See also

- [Domain context](../../domain-context) — how knowledge is saved
- [Promoting domain knowledge](./promote-domain-knowledge) — close-out promotion at Fine (`user-invocable: false`); not this command
