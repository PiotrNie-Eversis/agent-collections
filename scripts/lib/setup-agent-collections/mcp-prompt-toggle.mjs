#!/usr/bin/env node
/**
 * Interactive MCP selection (gate + toggle list).
 * UI → stderr (visible when invoked as $(node …)); result CSV → stdout only.
 */
import fs from 'node:fs';
import readline from 'node:readline';

const listPath = process.argv[2];
if (!listPath) {
  process.stderr.write('Usage: mcp-prompt-toggle.mjs <mcp-server-list.json>\n');
  process.exit(1);
}

if (!process.stdin.isTTY && !process.stdout.isTTY) {
  process.stderr.write('MCP prompt requires an interactive terminal.\n');
  process.exit(2);
}

const catalog = JSON.parse(fs.readFileSync(listPath, 'utf8'));
const servers = catalog.servers ?? [];
const defaultMinimal = 'eversis-collections';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stderr,
  terminal: true,
});

let closed = false;
rl.on('close', () => {
  closed = true;
});

function say(text = '') {
  process.stderr.write(`${text}\n`);
}

function finish(csv) {
  rl.close();
  process.stdout.write(`${csv}\n`);
  process.exit(0);
}

function askGate() {
  say('');
  say('Do you want to configure MCPs? [Y/n]');
  rl.question('> ', (answer) => {
    if (closed) {
      process.exit(130);
    }
    const trimmed = (answer ?? '').trim();
    if (/^[Nn]/.test(trimmed)) {
      finish(defaultMinimal);
      return;
    }
    runToggle(new Set(catalog.defaultChecked ?? []));
  });
}

function render(selected) {
  say('');
  say('Select MCP servers — type a number to toggle [x], Enter on empty line to confirm:');
  say('(Type server numbers to toggle, e.g. 1 or 1,3,11 — then Enter on empty line to confirm.)');
  say('');
  servers.forEach((id, index) => {
    const mark = selected.has(id) ? 'x' : ' ';
    say(`  [${mark}] ${index + 1}) ${id}`);
  });
  say('');
}

function runToggle(selected) {
  render(selected);
  rl.question('Toggle server number (or Enter to confirm): ', (answer) => {
    if (closed) {
      process.exit(130);
    }

    const trimmed = (answer ?? '').trim();
    if (!trimmed) {
      if (selected.size === 0) {
        say('Select at least one MCP server.');
        runToggle(selected);
        return;
      }
      finish([...selected].join(','));
      return;
    }

    if (/[,\s]/.test(trimmed)) {
      const parts = trimmed.split(/[\s,]+/).filter(Boolean);
      for (const part of parts) {
        if (!/^\d+$/.test(part)) {
          say(`Invalid number in list: "${part}"`);
          runToggle(selected);
          return;
        }
        const idx = Number(part) - 1;
        if (idx < 0 || idx >= servers.length) {
          say(`Invalid number: ${part}`);
          runToggle(selected);
          return;
        }
        const sid = servers[idx];
        if (selected.has(sid)) {
          selected.delete(sid);
        } else {
          selected.add(sid);
        }
      }
      runToggle(selected);
      return;
    }

    if (!/^\d+$/.test(trimmed)) {
      say(`Invalid input: "${trimmed}" — enter one number, or comma-separated numbers (e.g. 1,3,11).`);
      runToggle(selected);
      return;
    }

    const index = Number(trimmed) - 1;
    if (index < 0 || index >= servers.length) {
      say(`Invalid number: ${trimmed}`);
      runToggle(selected);
      return;
    }

    const id = servers[index];
    if (selected.has(id)) {
      selected.delete(id);
    } else {
      selected.add(id);
    }
    runToggle(selected);
  });
}

process.on('SIGINT', () => {
  if (!closed) {
    rl.close();
  }
  process.exit(130);
});

askGate();
