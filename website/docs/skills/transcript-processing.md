---
sidebar_position: 12
title: Transcript Processing
---

# Transcript Processing

**Folder:** `.cursor/skills/eversis-transcript-processing/`  
**Used by:** Business Analyst

Cleans raw workshop or meeting transcripts from small talk, filler words, and off-topic tangents. Extracts and structures business-relevant content into a standardized format.

## Process

### Step 1: Identify Transcript Format

Determine the input format:
- Speaker-labelled transcript (e.g., `[Speaker Name]: text`)
- Plain text notes without speaker labels
- Timestamped transcript (e.g., `[00:12:34] text`)
- Mixed format

Extract meeting metadata: date, duration, topic, and context.

### Step 2: Identify Participants

Scan for participant names and infer roles where obvious from context (e.g., "Product Owner", "Developer"). Do not guess roles when unclear.

### Step 3: Remove Non-Business Content

Systematically remove:
- Greetings and sign-offs
- Small talk and personal anecdotes
- Filler words and verbal tics
- Technical difficulties discussion
- Off-topic tangents
- Repetitive restatements (keep the clearest version)

:::tip
When in doubt about whether content is business-relevant, **keep it**. It is better to preserve potentially useful context than to accidentally remove important information.
:::

### Step 4: Group by Discussion Topics

Organize cleaned content into logical topics with descriptive headings and bullet points. Maintain chronological order and consolidate disconnected parts of the same topic.

### Step 5: Extract Key Decisions

Identify explicit decisions ("We agreed to...") and implicit decisions (discussion converging on a direction). Note what was decided, who endorsed it, and any conditions.

### Step 6: Extract Action Items and Open Questions

Scan for commitments, assigned tasks, unanswered questions, and deferred items. Note the what, who, and any deadlines.

### Step 7: Preserve Critical Raw Context

Keep exact quotes where the original wording matters: requirements in business language, constraints from stakeholders, conflicting viewpoints, and domain-specific terminology.

### Step 8: Save Output

Generate the cleaned transcript following the `cleaned-transcript.example.md` template. Save to `specifications/<workshop-name>/cleaned-transcript.md`.

## Connected Skills

- `eversis-task-extracting` — Uses the cleaned transcript as primary input for identifying epics and stories.
