import React from 'react';

import styles from './styles.module.css';

export default function SdlcDiagram(): React.JSX.Element {
  return (
    <div
      className={styles.wrapper}
      role="img"
      aria-label="SDLC workflow: invoke eversis prompts with @ or / project commands. The flow moves from Human Intent to AI Agent to Ideate to Implement. Implement supports Quick and Full flow, where Quick skips research and planning delegates and Full uses them before implementation. Review can return issues or lead to approval, then Observe, Fine, QA Handoff, and Next Intent."
    >
      <div className={styles.diagram}>
        {/* Human Intent */}
        <div className={styles.pill}>
          <span className={styles.pip} />
          Human Intent + Context
        </div>
        <div className={`${styles.conn} ${styles.conn20}`} />

        {/* AI Agent */}
        <div className={styles.agentNode}>
          <div className={styles.agentTitle}>AI Agent</div>
          <div className={styles.agentSub}>Agent Collections</div>
        </div>
        <div className={`${styles.conn} ${styles.conn36}`} />

        {/* Ideation Phase */}
        <div className={`${styles.phase} ${styles.phaseIdeation}`}>
          <div className={styles.phaseHeader}>
            <span className={styles.phaseTag}>Ideate</span>
          </div>
          <div className={styles.card}>
            <div className={styles.cardCmd}>
              <div className={styles.cardPromptName}>eversis-analyze-materials</div>
              <div className={styles.cardAttachPath}>
                @eversis-analyze-materials
              </div>
            </div>
            <div className={styles.cardDesc}>
              Clean transcript → extract tasks → produce Jira-ready stories with
              full acceptance criteria
            </div>
          </div>
        </div>
        <div className={`${styles.conn} ${styles.conn36}`} />

        {/* Development Phase */}
        <div className={`${styles.phase} ${styles.phaseDev}`}>
          <div className={styles.phaseHeader}>
            <span className={styles.phaseTag}>Implement</span>
          </div>
          <div className={styles.card}>
            <div className={styles.cardCmd}>
              <div className={styles.cardPromptName}>
                eversis-implement
                <span
                  style={{
                    fontSize: '0.7rem',
                    opacity: 0.75,
                    marginLeft: '0.5rem',
                    fontWeight: 500,
                  }}
                >
                  Engineering Manager
                </span>
              </div>
              <div className={styles.cardAttachPath}>
                @eversis-implement
              </div>
            </div>
            <div className={styles.cardDesc}>
              Orchestrates the full cycle — research, planning, and
              implementation via specialized agents
            </div>
          </div>
          <div className={styles.flowModes}>
            <div className={styles.flowMode}>
              <strong className={styles.flowModeTitle}>Quick</strong>
              <span className={styles.flowModeText}>
                skips research and planning delegates
              </span>
            </div>
            <div className={styles.flowMode}>
              <strong className={styles.flowModeTitle}>Full</strong>
              <span className={styles.flowModeText}>
                uses the full delegate chain before implementation
              </span>
            </div>
          </div>
          <div className={styles.parallelLabel}>↓ delegates by selected flow</div>
          <div className={styles.grid3}>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <strong className={styles.cardCmdStrong}>Context Engineer</strong>
              </div>
              <div className={styles.cardDesc}>
                Research &amp; context gathering
              </div>
            </div>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <strong className={styles.cardCmdStrong}>Architect</strong>
              </div>
              <div className={styles.cardDesc}>
                Architecture &amp; implementation plan
              </div>
            </div>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <strong className={styles.cardCmdStrong}>Software Engineer</strong>
              </div>
              <div className={styles.cardDesc}>
                Backend, frontend, APIs, data layers
              </div>
            </div>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <strong className={styles.cardCmdStrong}>DevOps Engineer</strong>
              </div>
              <div className={styles.cardDesc}>
                Cloud and infrastructure
              </div>
            </div>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <strong className={styles.cardCmdStrong}>E2E Engineer</strong>
              </div>
              <div className={styles.cardDesc}>
                End-to-end tests
              </div>
            </div>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <strong className={styles.cardCmdStrong}>Prompt Engineer</strong>
              </div>
              <div className={styles.cardDesc}>
                LLM application prompts
              </div>
            </div>
          </div>
        </div>

        {/* Issues Found */}
        <div className={`${styles.conn} ${styles.conn20} ${styles.connOrange}`} />
        <div className={`${styles.badge} ${styles.badgeIssues}`}>
          <span className={styles.badgeIcon} aria-hidden="true">↑</span>
          Issues found
          <span className={styles.badgeIcon} aria-hidden="true">↓</span>
        </div>
        <div className={`${styles.conn} ${styles.conn20} ${styles.connOrange}`} />

        {/* Quality Phase */}
        <div className={`${styles.phase} ${styles.phaseQuality}`}>
          <div className={styles.phaseHeader}>
            <span className={styles.phaseTag}>Review</span>
          </div>
          <div className={styles.grid2}>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <div className={styles.cardPromptName}>eversis-review</div>
                <div className={styles.cardAttachPath}>
                  @eversis-review
                </div>
              </div>
              <div className={styles.cardDesc}>
                PASS / BLOCKER / SUGGESTION — security, perf, coding standards
              </div>
            </div>
            <div className={styles.card}>
              <div className={styles.cardCmd}>
                <div className={styles.cardPromptName}>eversis-review-ui</div>
                <div className={styles.cardAttachPath}>
                  @eversis-review-ui
                </div>
              </div>
              <div className={styles.cardDesc}>
                Playwright vs Figma · up to 5 auto-iterations
              </div>
            </div>
          </div>
        </div>

        {/* Approved */}
        <div className={`${styles.conn} ${styles.conn20} ${styles.connGreen}`} />
        <div className={`${styles.badge} ${styles.badgeApproved}`}>
          <span className={styles.badgeIcon} aria-hidden="true">✓</span>
          Approved
        </div>
        <div className={`${styles.conn} ${styles.conn20} ${styles.connGreen}`} />

        {/* Observe */}
        <div className={styles.observeWrap}>
          <div className={styles.observeDiamond} />
          <div className={styles.observeText}>Observe</div>
        </div>

        {/* Fine */}
        <div className={`${styles.conn} ${styles.conn20} ${styles.connBlue}`} />
        <div className={`${styles.badge} ${styles.badgeFine}`}>
          <span className={styles.badgeIcon} aria-hidden="true">✓</span>
          Fine
        </div>
        <div className={`${styles.conn} ${styles.conn20} ${styles.connBlue}`} />

        {/* QA Handoff */}
        <div className={`${styles.badge} ${styles.badgeHandoff}`}>
          <span className={styles.badgeIcon} aria-hidden="true">≡</span>
          QA Handoff
        </div>
        <div className={`${styles.conn} ${styles.conn20} ${styles.connViolet}`} />

        {/* Next Intent */}
        <div className={styles.pill}>
          <span className={styles.pip} />
          Next Intent
        </div>

        {/* Problem Return Arc */}
        <svg
          className={styles.returnSvg}
          viewBox="0 0 80 600"
          preserveAspectRatio="none"
          aria-hidden="true"
        >
          <defs>
            <marker
              id="arr-p"
              markerWidth="8"
              markerHeight="8"
              refX="4"
              refY="4"
              orient="auto"
            >
              <path d="M0,0 L0,8 L8,4 z" fill="#f97316" />
            </marker>
          </defs>
          <path
            d="M 8 555 Q 60 555 60 300 Q 60 55 8 55"
            stroke="#f97316"
            strokeWidth="1.5"
            fill="none"
            strokeDasharray="5,4"
            markerEnd="url(#arr-p)"
            opacity="0.6"
          />
          <text
            x="74"
            y="300"
            fill="rgba(249,115,22,0.8)"
            fontSize="8.5"
            fontFamily="DM Mono,monospace"
            letterSpacing="2.5"
            textAnchor="middle"
            transform="rotate(90,74,300)"
          >
            PROBLEM
          </text>
        </svg>
      </div>
    </div>
  );
}
