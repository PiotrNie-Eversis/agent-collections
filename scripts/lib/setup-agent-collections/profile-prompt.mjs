#!/usr/bin/env node
/**
 * Interactive domain profile UI: select (arrows / Enter).
 * Prompts → stderr; selected profile id → stdout only (safe for $(node …) in bash).
 */
import { select } from '@inquirer/prompts';

if (!process.stdin.isTTY && !process.stdout.isTTY) {
  process.stderr.write('Domain profile prompt requires an interactive terminal.\n');
  process.exit(2);
}

const ui = { output: process.stderr };

try {
  const selected = await select(
    {
      message: 'Select domain profile (↑↓ move, Enter confirm)',
      default: 'fullstack',
      choices: [
        { name: 'frontend  — FE-oriented rules/skills', value: 'frontend' },
        { name: 'backend   — BE-oriented rules/skills', value: 'backend' },
        {
          name: 'fullstack — full set + monorepo area scoping defaults',
          value: 'fullstack',
        },
      ],
      loop: false,
    },
    ui,
  );

  process.stdout.write(`${selected}\n`);
} catch (err) {
  if (err?.name === 'ExitPromptError') {
    process.exit(130);
  }
  throw err;
}
