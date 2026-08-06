#!/usr/bin/env node
/**
 * Interactive MCP UI: gate + checkbox (arrows / Space / Enter).
 * Prompts → stderr; selected server CSV → stdout only (safe for $(node …) in bash).
 */
import fs from 'node:fs';
import { confirm, checkbox } from '@inquirer/prompts';

const listPath = process.argv[2];
if (!listPath) {
  process.stderr.write('Usage: mcp-prompt.mjs <mcp-server-list.json>\n');
  process.exit(1);
}

if (!process.stdin.isTTY && !process.stdout.isTTY) {
  process.stderr.write('MCP prompt requires an interactive terminal.\n');
  process.exit(2);
}

const ui = { output: process.stderr };
const catalog = JSON.parse(fs.readFileSync(listPath, 'utf8'));
const defaultMinimal = 'eversis-collections';

try {
  const wantsConfigure = await confirm(
    {
      message: 'Do you want to configure MCPs?',
      default: true,
    },
    ui,
  );

  if (!wantsConfigure) {
    process.stdout.write(`${defaultMinimal}\n`);
    process.exit(0);
  }

  const selected = await checkbox(
    {
      message: 'Select MCP servers for .cursor/mcp.json (↑↓ move, Space toggle, Enter confirm)',
      choices: catalog.servers.map((id) => ({
        name: id,
        value: id,
        checked: catalog.defaultChecked?.includes(id) ?? false,
      })),
      loop: false,
      required: true,
    },
    ui,
  );

  if (!selected.length) {
    process.stderr.write('Select at least one MCP server.\n');
    process.exit(1);
  }

  process.stdout.write(`${selected.join(',')}\n`);
} catch (err) {
  if (err?.name === 'ExitPromptError') {
    process.exit(130);
  }
  throw err;
}
