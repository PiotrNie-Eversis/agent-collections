#!/usr/bin/env node
/**
 * Interactive agents UI: checkbox (arrows / Space / Enter).
 * Prompts → stderr; selected agent CSV → stdout only (safe for $(node …) in bash).
 */
import { checkbox } from '@inquirer/prompts';

if (!process.stdin.isTTY && !process.stdout.isTTY) {
  process.stderr.write('Agents prompt requires an interactive terminal.\n');
  process.exit(2);
}

const ui = { output: process.stderr };

const choices = [
  { name: 'cursor', value: 'cursor', checked: true },
  { name: 'claude', value: 'claude', checked: false },
  {
    name: 'opencode (placeholder — not a full adapter)',
    value: 'opencode',
    checked: false,
  },
];

try {
  const selected = await checkbox(
    {
      message: 'Select agent adapters (↑↓ move, Space toggle, Enter confirm)',
      choices,
      loop: false,
      required: true,
    },
    ui,
  );

  if (!selected.length) {
    process.stderr.write('Select at least one agent adapter.\n');
    process.exit(1);
  }

  process.stdout.write(`${selected.join(',')}\n`);
} catch (err) {
  if (err?.name === 'ExitPromptError') {
    process.exit(130);
  }
  throw err;
}
