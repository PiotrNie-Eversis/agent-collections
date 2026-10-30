# Claude Code Editor/Terminal Prerequisite — Cleaned Transcript

## Meeting Metadata

| Field | Value |
|---|---|
| Date | Not stated in transcript (assumed recent — see Open Questions) |
| Duration | ~31 minutes 41 seconds (transcript captures two segments: 0:00–0:54 and 28:08–31:41; the middle ~27 minutes was not included in the provided transcript excerpt) |
| Topic | Onboarding feedback session — Agent Collections getting-started experience (Cursor vs. Claude Code) and future tooling vision |
| Context | Working session between the framework maintainer (Piotr Niemirski) and a hands-on user/analyst (Katarzyna Bogdanowicz) who is trialing the "code with an agent" workflow. Original transcript is in Polish; this document is an English translation/cleanup. |

## Participants

| Name | Role |
|---|---|
| Piotr Niemirski | Framework maintainer / Agent Collections author |
| Katarzyna Bogdanowicz | Analyst — trialing Claude Code onboarding, hands-on tester of the getting-started flow |

## Executive Summary

Piotr walks Katarzyna through the minimum setup needed to start "working with code via an agent": pick either Cursor or Claude Code. He then names a gap Katarzyna had already flagged separately — Cursor is self-contained, but Claude Code additionally requires a standalone code editor and/or terminal (e.g., VS Code, or any external terminal, including one built into an editor) to actually launch and use it. Later in the session, the conversation shifts to a longer-term vision: turning business requirements/workshop notes into agent-ready specifications (epics/stories) that plug into a shared tool connected to Confluence/Jira, so analysts and developers work from one structured source instead of hand-off documents that get reinterpreted by developers. Piotr commits to updating "the instructions" (i.e., onboarding documentation) from the developer's-eyes/newcomer's-eyes perspective and asks Katarzyna to send her session notes so he can turn them into concrete documentation tasks.

## Discussion Topics

### Getting started: Cursor vs. Claude Code

- To start "working with code" via an agent, the user needs to download either **Cursor** or **Claude Code**.
- Other editors/tools may be supported later; currently only these two are supported.
- Choosing one of these two tools is described as "the one thing you need to get started."
- **Gap Katarzyna identified**: for **Cursor**, this is sufficient — it is self-contained. For **Claude Code**, the user additionally needs a **separate code editor and/or terminal** — examples given: Visual Studio Code, an external terminal, or even a terminal built into an editor. The workflow described: open a plain/regular editor, then launch/click into Claude (Code) from its terminal.
- This requirement is not obvious to a newcomer and was the specific gap Katarzyna ran into while trying to follow the current onboarding steps.

### Future tooling vision (longer-term, not a documentation gap)

- Long-term idea: build a shared internal service/tool so Katarzyna does not need to install multiple pieces of tooling (Docker, etc.) herself; work would happen through one shared entry point connected to Confluence.
- Goal: analysts write business requirements once, in a form an agent can consume directly to generate epics/stories that plug straight into Jira as tickets — reducing the "analyst writes it one way, developer interprets it another way" gap.
- Katarzyna's proposed near-term working pattern: she keeps working her own way, then feeds her output into an agent to normalize it into a business-requirements format compatible with the shared workflow; tooling integration happens after that is validated.
- Both agreed this is valuable specifically because project-specific rules vary — a generic agent workflow without project context does not fit every project, and a poorly specified project ends up with the agent inventing scope on its own.

## Key Decisions

| # | Decision | Made By | Conditions / Caveats |
|---|----------|---------|---------------------|
| 1 | Update the onboarding instructions to explicitly cover the Claude Code editor/terminal requirement, written from a newcomer/developer-eyes perspective. | Piotr Niemirski | Depends on receiving Katarzyna's session notes first. |
| 2 | Longer-term direction: build a shared tool/service connecting business-requirements authoring to Confluence/Jira so specs are agent-ready before reaching development. | Piotr Niemirski, endorsed by Katarzyna | Exploratory — no scope, timeline, or owner assigned; described as a future direction, not a committed deliverable. |

## Action Items

| # | Action | Assigned To | Deadline |
|---|--------|-------------|----------|
| 1 | Send session notes from this meeting to Piotr. | Katarzyna Bogdanowicz | Not stated ("I'll have [them], I'm saving them now") |
| 2 | Turn Katarzyna's notes into concrete documentation-improvement tasks and update the onboarding instructions. | Piotr Niemirski | Not stated — contingent on Action Item 1 |

## Open Questions

| # | Question | Raised By | Notes |
|---|----------|-----------|-------|
| 1 | What exact wording/steps should be added to cover the Claude Code editor + terminal requirement — is VS Code the recommended default, or any editor/terminal acceptable? | Derived from discussion (not explicitly resolved) | The transcript names VS Code and "some external terminal, even a built-in one" as examples, but does not settle on a single recommended path. |
| 2 | Do Katarzyna's promised follow-up notes (Action Item 1) contain additional onboarding gaps beyond the editor/terminal one? | Derived from discussion | Not available at the time of this analysis — only the live conversation excerpt was provided as source material. |
| 3 | Meeting date not stated in the transcript export — needed for accurate baseline/session record-keeping. | Derived from processing | Ask user or check source recording metadata. |

## Preserved Context

> "W przypadku kursora to nie jest problem w przypadku cloud coda musimy mieć jakiś edytor kodu, ewentualnie terminal to może być visual studio kod to może być jakiś taki zewnętrzny terminal, nawet ten, który jest tutaj wbudowany..."
> — Piotr Niemirski, regarding the Claude Code editor/terminal prerequisite gap (0:36)
> (Translation: "In Cursor's case this isn't a problem; in Claude Code's case we need some kind of code editor, or alternatively a terminal — it could be Visual Studio Code, it could be some external terminal, even the one that's built in here...")

> "Brakującym krokiem i to jest coś, co? Co faktycznie zwróciłaś uwagę? Brakuje tutaj."
> — Piotr Niemirski, regarding the same gap (0:28–0:34)
> (Translation: "[This is] the missing step, and this is something — that you actually pointed out. It's missing here.")

> "Ja uzupełnię tą instrukcję tak żeby bo faktycznie zrozumiała z punktu widzenia dewelopera z twojego punktu widzenia trzeba tam dodać kilka punktów, więc jakbyś mogła, jakbyś miała notatki z tego spotkania, to jak chętnie je przygarnę, po prostu zamienię je w konkretne zadania do rozwoju dokumentacji."
> — Piotr Niemirski, regarding next steps (31:26)
> (Translation: "I'll fill out that instruction so it's actually understandable from a developer's point of view — from your point of view, a few points need to be added there, so if you could, if you had notes from this meeting, I'd gladly take them and turn them into concrete documentation-development tasks.")

