import React from 'react';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import WorkflowShowcase from '@site/src/components/WorkflowShowcase';
import QuickWins from '@site/src/components/QuickWins';
import SocialProof from '@site/src/components/SocialProof';
import GettingStartedSection from '@site/src/components/GettingStartedSection';
import HeroSection from "@site/src/components/HeroSection";

import styles from './index.module.css';

export default function Home(): React.JSX.Element {
  const { siteConfig } = useDocusaurusContext();

  return (
    <Layout
      title={siteConfig.title}
      description="vendor-neutral multi-agent product engineering framework — Ideate → Implement → Review. Rules, prompts, MCP, and skills for the full SDLC."
    >
      <main className={styles.homePage}>
          <HeroSection />
          <div className={styles.divider} />
          <HomepageFeatures />
          <div className={styles.divider} />
          <SocialProof />
          <div className={styles.divider} />
          <WorkflowShowcase />
          <div className={styles.divider} />
          <QuickWins />
          <div className={styles.divider} />
          <GettingStartedSection />
      </main>
    </Layout>
  );
}
