import React from 'react';

import PeleDiagram from '../PeleDiagram';

/**
 * The Agent Collections delivery flow, drawn as Mermaid and rendered by Pele.
 * The approval nodes and the posting node are the only human steps.
 */
const sdlcFlow = `flowchart TB
    intent(["Human intent + context"]) --> agent["<b>AI agent</b><br/>Agent Collections"]
    agent --> ideate["<b>Ideate</b><br/>eversis-analyze-materials<br/>Jira-ready stories"]
    ideate --> implement["<b>/eversis-implement</b><br/>Engineering Manager delegates<br/>to specialist agents"]
    implement --> flow{"Quick or Full?"}
    flow -- Full --> research["Research"]
    research --> approveResearch["Approve research<br/>(your approval)"]
    approveResearch --> plan["Plan"]
    plan --> planReview["Plan review"]
    planReview --> approvePlan["Approve plan<br/>with the review summary"]
    approvePlan --> code["Code + quality checks<br/>+ UI verification for Figma work"]
    flow -- Quick --> code
    code --> review{"Code review<br/>eversis-review<br/>(same run)"}
    review -- BLOCKER --> code
    review -- PASS --> fine["<b>Fine</b><br/>+ QA comment draft"]
    fine --> post["You decide whether to<br/>post the QA comment"]
    post --> next(["Next intent"])`;

const sdlcLabel =
  'Agent Collections workflow: human intent and context go to the AI agent. ' +
  'Ideate turns workshop materials into Jira-ready stories with eversis-analyze-materials. ' +
  '/eversis-implement starts the Engineering Manager, which delegates to specialist agents and picks Quick or Full flow. ' +
  'Full flow runs research, then you approve the research, then the plan and plan review, then you approve the plan with the review summary. ' +
  'Both flows then write code with quality checks, plus UI verification for Figma work. ' +
  'Code review (eversis-review) runs in the same run: a BLOCKER goes back to the code, a PASS leads to Fine with a QA comment draft. ' +
  'You decide whether to post the QA comment, then the next intent starts.';

export default function SdlcDiagram(): React.JSX.Element {
  return <PeleDiagram id="sdlc-flow" source={sdlcFlow} label={sdlcLabel} />;
}
