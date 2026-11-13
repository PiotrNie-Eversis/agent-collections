#!/usr/bin/env node
/**
 * release-master.mjs — guided release of develop to master.
 *
 * A thin, interactive wrapper around scripts/release-to-master.sh, which does
 * the actual work (filtered snapshot of develop without the .release-exclude
 * paths, one "release: develop@<sha>" commit on local master). This wrapper adds
 * the steps around it:
 *
 *   1. refuse to run on master;
 *   2. git fetch origin, then stop when local develop or master differs from
 *      origin (an unpushed or stale develop would be released by mistake);
 *   3. show the dry run;
 *   4. ask before creating the release commit;
 *   5. ask before git push origin master.
 *
 * Ships with the framework core (also on master, so `npm run release:master`
 * resolves there), but step 1 makes it run only from develop or a feature branch.
 *
 * Usage (repo root, any branch except master):
 *   node scripts/release-master.mjs [--dry-run] [--yes] [--allow-diverged]
 *   npm run release:master -- [same options]
 *
 *   --dry-run         Fetch, check and show what the release would change; write nothing.
 *   --yes             Do not ask; create the release commit and push.
 *   --allow-diverged  Passed to release-to-master.sh (overwrite master-only commits).
 *
 * Stdlib only. Exit codes: 0 done or nothing to release, 1 stopped or failed.
 */

import { spawnSync } from "node:child_process";
import process from "node:process";
import readline from "node:readline/promises";

const SOURCE = "develop";
const TARGET = "master";
const REMOTE = "origin";

function fail(message) {
  console.error(`release-master: ${message}`);
  process.exit(1);
}

/** Runs git and returns trimmed stdout; stops on error unless allowFailure. */
function git(args, { allowFailure = false } = {}) {
  const r = spawnSync("git", args, { encoding: "utf8" });
  if (r.status !== 0 && !allowFailure) {
    fail(`git ${args.join(" ")} failed:\n${(r.stderr || r.stdout).trim()}`);
  }
  return r.status === 0 ? r.stdout.trim() : null;
}

/** Runs release-to-master.sh, echoes its output and returns it. */
function runRelease(extraArgs) {
  const r = spawnSync("bash", ["scripts/release-to-master.sh", ...extraArgs], { encoding: "utf8" });
  if (r.stdout) process.stdout.write(r.stdout);
  if (r.stderr) process.stderr.write(r.stderr);
  if (r.status !== 0) fail(`release-to-master.sh exited with ${r.status}.`);
  return r.stdout;
}

async function confirm(question, assumeYes) {
  if (assumeYes) return true;
  if (!process.stdin.isTTY) fail("no terminal to ask in; re-run with --yes to proceed without questions.");
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  try {
    const answer = (await rl.question(`${question} [y/N] `)).trim().toLowerCase();
    return answer === "y" || answer === "yes";
  } finally {
    rl.close();
  }
}

function parseArgs(argv) {
  const opts = { dryRun: false, yes: false, allowDiverged: false };
  for (const arg of argv) {
    if (arg === "--dry-run") opts.dryRun = true;
    else if (arg === "--yes") opts.yes = true;
    else if (arg === "--allow-diverged") opts.allowDiverged = true;
    else if (arg === "-h" || arg === "--help") {
      console.log("Usage: node scripts/release-master.mjs [--dry-run] [--yes] [--allow-diverged]");
      process.exit(0);
    } else fail(`unknown option: ${arg} (see --help)`);
  }
  return opts;
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const root = git(["rev-parse", "--show-toplevel"], { allowFailure: true });
  if (!root) fail("not inside a git repository.");
  process.chdir(root);

  const branch = git(["symbolic-ref", "--quiet", "--short", "HEAD"], { allowFailure: true });
  if (branch === TARGET) fail(`you are on '${TARGET}'. Switch to '${SOURCE}' (or any other branch) first.`);

  if (git(["status", "--porcelain", "--untracked-files=no"])) {
    console.warn(`release-master: note: you have uncommitted changes; the release uses the committed '${SOURCE}' only.`);
  }

  console.log(`release-master: fetching ${REMOTE}…`);
  git(["fetch", "--quiet", REMOTE]);
  for (const b of [SOURCE, TARGET]) {
    const local = git(["rev-parse", "--verify", "--quiet", `refs/heads/${b}`], { allowFailure: true });
    const remote = git(["rev-parse", "--verify", "--quiet", `refs/remotes/${REMOTE}/${b}`], { allowFailure: true });
    if (!local || !remote) fail(`branch '${b}' or '${REMOTE}/${b}' not found.`);
    if (local !== remote) {
      const [behind, ahead] = git(["rev-list", "--left-right", "--count", `${remote}...${local}`]).split(/\s+/);
      fail(`local '${b}' differs from '${REMOTE}/${b}' (${ahead} ahead, ${behind} behind). Push or pull '${b}' first.`);
    }
  }

  const passThrough = opts.allowDiverged ? ["--allow-diverged"] : [];
  const preview = runRelease(["--dry-run", ...passThrough]);
  if (preview.includes("nothing to release")) return;
  if (opts.dryRun) return;

  if (!(await confirm(`Create the release commit on local '${TARGET}'?`, opts.yes))) {
    console.log("release-master: stopped — nothing written.");
    return;
  }
  const before = git(["rev-parse", `refs/heads/${TARGET}`]);
  runRelease(passThrough);
  console.log(git(["show", "--stat", "--format=%h %s", TARGET]).split("\n").slice(0, 30).join("\n"));

  if (!(await confirm(`Push '${TARGET}' to ${REMOTE}?`, opts.yes))) {
    console.log(`release-master: not pushed. Publish later with: git push ${REMOTE} ${TARGET}`);
    console.log(`release-master: or drop the local release with: git update-ref refs/heads/${TARGET} ${before}`);
    return;
  }
  const push = spawnSync("git", ["push", REMOTE, TARGET], { stdio: "inherit" });
  if (push.status !== 0) fail(`git push ${REMOTE} ${TARGET} failed.`);
  console.log(`release-master: '${TARGET}' released and pushed.`);
}

await main();
