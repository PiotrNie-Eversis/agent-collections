export type ToolKind =
  | 'Command'
  | 'Extension'
  | 'File'
  | 'MCP'
  | 'Rule'
  | 'Skill'
  | 'Sub-agent'
  | 'Tools';

export type AgentTool = {
  kind: ToolKind;
  name: string;
  note?: string;
};

export type PhaseId =
  | 'ideate'
  | 'start'
  | 'research'
  | 'plan'
  | 'implement'
  | 'review'
  | 'fine';

export type AgentId = 'claude' | 'cursor' | 'pi';

type AgentDefinition = {
  name: string;
  tools: Record<PhaseId, AgentTool[]>;
};

const ideate: AgentTool = {
  kind: 'Command',
  name: '/eversis-analyze-materials',
  note: 'Optional. Starts from workshop materials.',
};

const fineMcp: AgentTool = {
  kind: 'MCP',
  name: 'atlassian',
  note: 'Posts the comment only after approval.',
};

const contextMcp: AgentTool = {
  kind: 'MCP',
  name: 'eversis-collections, atlassian',
  note: 'Skills, domain context and the ticket.',
};

/** Claude Code and Cursor share the delegation chain; only their paths differ. */
const delegatedPhases = (
  skillsDir: string,
  tools: string,
): Pick<AgentDefinition['tools'], 'research' | 'plan' | 'implement' | 'review' | 'fine'> => ({
  research: [
    { kind: 'Sub-agent', name: 'Context Engineer', note: 'Runs the eversis-research prompt.' },
    { kind: 'Skill', name: `${skillsDir}/eversis-orchestrating-implementation` },
    contextMcp,
  ],
  plan: [
    { kind: 'Sub-agent', name: 'Architect', note: 'Runs the eversis-plan prompt.' },
    { kind: 'Skill', name: `${skillsDir}/eversis-creating-implementation-plans` },
  ],
  implement: [
    {
      kind: 'Sub-agent',
      name: 'Software Engineer',
      note: 'Runs the eversis-implement-common-task prompt.',
    },
    { kind: 'Tools', name: tools },
  ],
  review: [
    {
      kind: 'Sub-agent',
      name: 'Code Reviewer',
      note: 'Runs eversis-review in a separate context, in the same Implement run.',
    },
  ],
  fine: [{ kind: 'Skill', name: `${skillsDir}/eversis-fine-handoff` }, fineMcp],
});

export const agents: Record<AgentId, AgentDefinition> = {
  claude: {
    name: 'Claude Code',
    tools: {
      ideate: [ideate],
      start: [
        {
          kind: 'Command',
          name: '/eversis-implement <ticket>',
          note: 'A thin pointer in .claude/commands/ to the prompt in .ai/prompts/.',
        },
        { kind: 'File', name: 'CLAUDE.md', note: 'Six rules, always on.' },
        {
          kind: 'Rule',
          name: '.claude/rules/eversis-accessibility.md',
          note: 'Loads for matching UI files.',
        },
      ],
      ...delegatedPhases('.claude/skills', 'file edits and terminal'),
    },
  },
  cursor: {
    name: 'Cursor',
    tools: {
      ideate: [ideate],
      start: [
        {
          kind: 'Command',
          name: '/eversis-implement <ticket>',
          note: 'Or attach @eversis-implement.',
        },
        {
          kind: 'Rule',
          name: '.cursor/rules/*.mdc',
          note: 'Two rules always on, accessibility for UI files, four attach-only.',
        },
      ],
      ...delegatedPhases('.cursor/skills', 'file edits and terminal'),
    },
  },
  pi: {
    name: 'Pi',
    tools: {
      ideate: [ideate],
      start: [
        { kind: 'Command', name: '/eversis-implement <ticket>' },
        {
          kind: 'Extension',
          name: 'eversis-process-rules',
          note: 'Adds five rule skills and shows a notice.',
        },
        { kind: 'File', name: '.pi/APPEND_SYSTEM.md', note: 'The small core, always on.' },
      ],
      research: [
        {
          kind: 'Skill',
          name: 'eversis-orchestrating-implementation',
          note: 'Pi has no sub-agents, so this runs in the same session.',
        },
        contextMcp,
      ],
      plan: [
        { kind: 'Skill', name: 'eversis-creating-implementation-plans' },
        {
          kind: 'Extension',
          name: 'eversis-process-rules',
          note: 'Saves .pi/eversis-state/active-plan.json, so a new session starts with the rules on.',
        },
      ],
      implement: [
        { kind: 'Tools', name: 'edit, write, bash' },
        { kind: 'Skill', name: '.pi/skills/eversis-*', note: 'Domain skills the plan calls for.' },
        {
          kind: 'Extension',
          name: 'eversis-context-budget',
          note: 'Compacts once at 50% and resumes the task.',
        },
      ],
      review: [
        {
          kind: 'Command',
          name: '/new, then /eversis-review <ticket>',
          note: 'Only a new session gives an independent review.',
        },
        { kind: 'Skill', name: 'eversis-rule-code-reviewer' },
      ],
      fine: [{ kind: 'Skill', name: 'eversis-fine-handoff' }, fineMcp],
    },
  },
};
