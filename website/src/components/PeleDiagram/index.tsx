import React from 'react';
import { render } from 'pele';

import styles from './styles.module.css';

type PeleDiagramProps = {
  /** Mermaid source. Authored in this repository, so it is trusted input. */
  source: string;
  /** Plain-language description for screen readers. */
  label: string;
  /** Unique per page: only letters, digits, `-` and `_`. */
  id: string;
};

/**
 * Renders Mermaid with Pele. Colours come from the site tokens through the
 * `--pele-*` variables, so the diagram follows the light and dark themes.
 */
export default function PeleDiagram({
  source,
  label,
  id,
}: PeleDiagramProps): React.JSX.Element {
  const { svg } = render(source, { fontSize: 14, idPrefix: id });
  return (
    <figure
      className={styles.figure}
      role="img"
      aria-label={label}
      dangerouslySetInnerHTML={{ __html: svg }}
    />
  );
}
