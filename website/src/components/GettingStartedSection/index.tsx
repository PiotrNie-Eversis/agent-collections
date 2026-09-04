import React from "react";
import Link from "@docusaurus/Link";

import styles from "./styles.module.css";

const steps = [
  {
    num: 1,
    title: "Open in Cursor or Claude Code",
    description: (
      <>
        Open this repository in <strong>Cursor</strong> or{" "}
        <strong>Claude Code</strong> — canonical content under{" "}
        <code>.ai/</code> works in either.
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
    title: "Run your first prompt",
    description: (
      <>
        Attach <code>@eversis-implement</code> in Cursor, or run{" "}
        <code>/eversis-implement</code> (Cursor project command or Claude
        Code slash command) with your ticket or task text.
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
            build the <code>eversis-collections</code> MCP with Docker, run{" "}
            <code>eversis-*.md</code> prompts by stable id — <code>@</code>{" "}
            attach or <code>/eversis-*</code> in Cursor, the matching slash
            command in Claude Code.
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
              href="https://gitlab3.eversis.com/eversis-ai/agent-collections"
              target="_blank"
              rel="noopener noreferrer"
            >
              Get the repo on GitLab
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
          <Link className={styles.fullChecklistLink} to="/docs/getting-started/start-here">
            See the full 7-step checklist →
          </Link>
        </div>
      </div>
    </section>
  );
}
