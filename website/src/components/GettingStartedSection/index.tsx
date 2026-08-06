import React from "react";
import Link from "@docusaurus/Link";

import styles from "./styles.module.css";

const steps = [
  {
    num: 1,
    title: "Open in Cursor",
    description: (
      <>
        Open this repository in <strong>Cursor</strong> (
        <code>File → Open Folder</code>).
      </>
    ),
  },
  {
    num: 2,
    title: "Read AGENTS.md + framework",
    description: (
      <>
        Read <code>AGENTS.md</code> and the{" "}
        <Link to="/docs/framework">Framework reference</Link> (or{" "}
        <code>documentation/agent-collection.md</code> in the repo).
      </>
    ),
  },
  {
    num: 3,
    title: "Configure rules",
    description: (
      <>
        Start with <code>eversis-agent-core.mdc</code> and edit{" "}
        <code>eversis-project-stack.mdc</code> for your stack.
      </>
    ),
  },
  {
    num: 4,
    title: "Run your first prompt",
    description: (
      <>
        Attach <code>@eversis-implement</code> or use{" "}
        <code>/eversis-implement</code> with your ticket or task text.
      </>
    ),
  },
  {
    num: 5,
    title: "Build MCP",
    description: (
      <>
        <code>
          cd mcp/eversis-collections-mcp && npm install && npm run build
        </code>
        — enable <code>eversis-collections</code> from{" "}
        <code>.cursor/mcp.json</code>.
      </>
    ),
  },
  {
    num: 6,
    title: "Use skills via MCP",
    description: (
      <>
        With MCP enabled, Agent calls <code>eversis_skills_list</code> /{" "}
        <code>eversis_skills_get</code> — see{" "}
        <Link to="/docs/skills/overview">Skills overview</Link>.
      </>
    ),
  },
];

export default function GettingStartedSection(): React.JSX.Element {
  return (
    <section className={styles.gettingStarted}>
      <div className={styles.gettingStartedInner}>
        <div className={styles.leftCol}>
          <h2>
            Set up once.
            <br />
            Works across
            <br />
            every project.
          </h2>
          <p className={styles.sub}>
            <strong>Ideate → Implement → Review</strong> — clone or bootstrap,
            build <code>eversis-collections</code>, attach{" "}
            <code>eversis-*.md</code> prompts with <code>@</code> or{" "}
            <code>/eversis-*</code> project commands.
          </p>
          <div className={styles.gsActions}>
            <Link
              className={styles.btnPrimary}
              to="/docs/getting-started/start-here"
            >
              Start here
            </Link>
            <Link
              className={styles.btnSecondary}
              href="https://github.com/PiotrNie-Eversis/agent-collections"
              target="_blank"
              rel="noopener noreferrer"
            >
              Get the repo on GitHub
            </Link>
          </div>
        </div>
        <div className={styles.steps}>
          {steps.map((step, idx) => (
            <div
              key={step.num}
              className={`${styles.step} ${idx === 0 ? styles.stepFirst : ""} ${idx === steps.length - 1 ? styles.stepLast : ""}`}
            >
              <div className={styles.stepNum}>{step.num}</div>
              <div className={styles.stepContent}>
                <h4>{step.title}</h4>
                <p>{step.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
