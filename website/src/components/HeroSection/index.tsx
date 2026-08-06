import Link from "@docusaurus/Link";
import AnimationCanvas from "@site/src/components/HeroSection/AnimationCanvas";
import styles from "./index.module.css";

const HeroSection = () => {
  return (
    <div className={styles.heroBanner}>
      <AnimationCanvas />
      <div className={styles.heroContent}>
        <h1 className={styles.heroTitle}>
          Agent
          <br />
          Collections
        </h1>
      </div>
      <div className={`${styles.heroRight} ${styles.heroContent}`}>
        <p className={styles.heroSub}>
          An opinionated <strong>vendor-neutral multi-agent</strong> product engineering
          framework — rules, prompts, MCP, and skills for the full SDLC.
          <br />
          <strong>Ideate → Implement → Review</strong> — with human gates at
          every step.
        </p>
        <div className={styles.heroActions}>
          <Link
            className={styles.btnPrimary}
            to="/docs/getting-started/start-here"
          >
            Get started
          </Link>
          <Link
            className={styles.btnSecondary}
            href="https://github.com/PiotrNie-Eversis/agent-collections"
            target="_blank"
            rel="noopener noreferrer"
          >
            See on GitHub
          </Link>
        </div>
        <p className={styles.heroProof}>
          Maintained by Eversis · MIT · vendor-neutral multi-agent
        </p>
      </div>
    </div>
  );
};

export default HeroSection;
