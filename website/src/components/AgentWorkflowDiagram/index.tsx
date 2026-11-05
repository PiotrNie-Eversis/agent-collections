import React from 'react';

import { agents, type AgentId, type PhaseId } from './agents';
import styles from './styles.module.css';

type Marker = { type: 'gate' | 'issues' | 'approved'; text: string };

type Phase = {
  id: PhaseId;
  title: string;
  tone: 'amber' | 'blue' | 'violet' | 'green' | 'sky';
  process: string;
  after?: Marker;
};

const phases: Phase[] = [
  {
    id: 'ideate',
    title: 'Ideate',
    tone: 'amber',
    process: 'Turns workshop materials into Jira-ready stories.',
  },
  {
    id: 'start',
    title: 'Start',
    tone: 'blue',
    process: 'Prints the Implement readiness block and picks Quick or Full.',
  },
  {
    id: 'research',
    title: 'Research',
    tone: 'blue',
    process: 'Gathers context and writes *.research.md.',
    after: { type: 'gate', text: 'Person approves research' },
  },
  {
    id: 'plan',
    title: 'Plan',
    tone: 'blue',
    process: 'Writes *.plan.md with phases and acceptance checks.',
    after: { type: 'gate', text: 'Person approves plan' },
  },
  {
    id: 'implement',
    title: 'Implement',
    tone: 'violet',
    process: 'Changes the code, then runs lint, typecheck and tests.',
    after: { type: 'issues', text: 'BLOCKER: back to Implement' },
  },
  {
    id: 'review',
    title: 'Review',
    tone: 'green',
    process: 'Reports PASS, BLOCKER or SUGGESTION against the plan.',
    after: { type: 'approved', text: 'PASS' },
  },
  {
    id: 'fine',
    title: 'Fine',
    tone: 'sky',
    process: 'Writes the QA comment draft in the same turn.',
    after: { type: 'gate', text: 'Person approves publishing' },
  },
];

const markerClass = {
  gate: styles.gate,
  issues: styles.issues,
  approved: styles.approved,
};

const markerIcon = { gate: '✋', issues: '↺', approved: '✓' };

/** The delivery cycle, with the tools one coding agent uses at each stage. */
export default function AgentWorkflowDiagram({
  agent,
}: {
  agent: AgentId;
}): React.JSX.Element {
  const { name, tools } = agents[agent];
  return (
    <div className={styles.wrapper}>
      <p className={styles.pill}>Ticket or request</p>
      <ol className={styles.phases}>
        {phases.map((phase) => (
          <li key={phase.id} className={styles.item}>
            <span className={styles.line} aria-hidden="true" />
            <section className={`${styles.phase} ${styles[phase.tone]}`}>
              <h3 className={styles.title}>{phase.title}</h3>
              <div className={styles.columns}>
                <div>
                  <p className={styles.columnLabel}>Agent Collections</p>
                  <p className={styles.process}>{phase.process}</p>
                </div>
                <div>
                  <p className={styles.columnLabel}>{name}</p>
                  <ul className={styles.tools}>
                    {tools[phase.id].map((tool) => (
                      <li key={`${tool.kind}-${tool.name}`} className={styles.tool}>
                        <span className={styles.kind}>{tool.kind}</span>
                        <code className={styles.name}>{tool.name}</code>
                        {tool.note && <span className={styles.note}>{tool.note}</span>}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </section>
            {phase.after && (
              <>
                <span className={styles.line} aria-hidden="true" />
                <p className={`${styles.marker} ${markerClass[phase.after.type]}`}>
                  <span aria-hidden="true">{markerIcon[phase.after.type]}</span>
                  {phase.after.text}
                </p>
              </>
            )}
          </li>
        ))}
      </ol>
      <span className={styles.line} aria-hidden="true" />
      <p className={styles.pill}>Next ticket</p>
    </div>
  );
}
