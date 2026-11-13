#!/usr/bin/env bash
# Non-interactive smoke test for setup-agent-collections.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ac-smoke.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "[smoke] framework-home unit tests"
bash "${ROOT}/scripts/lib/setup-agent-collections/framework-home.test.sh"
echo "[smoke] selection SSOT unit tests"
bash "${ROOT}/scripts/lib/setup-agent-collections/selection-ssot.test.sh"

TARGET="${TMP}/consumer"
mkdir -p "$TARGET"
(cd "$TARGET" && git init -q)

echo "[smoke] target=${TARGET}"
START="$(date +%s)"

bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --non-interactive \
  --build-mcp \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy

END="$(date +%s)"
ELAPSED=$((END - START))
echo "[smoke] elapsed=${ELAPSED}s"

SEL="${TARGET}/.agent-collections/install-selection.json"
[[ -f "$SEL" ]] || { echo "FAIL: missing selection"; exit 1; }
node -e '
  const j=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));
  const req=["frameworkVersion","agents","mcpServers","domainProfile","vendorMode","linkMode"];
  for (const k of req) if (j[k]==null) { console.error("missing",k); process.exit(1); }
  if (!j.agents.includes("cursor")) process.exit(1);
  if (j.domainProfile!=="frontend") process.exit(1);
  if (j.ssot && j.ssot.externalSsotRepo !== null) {
    console.error("FAIL: first install without --ssot-source must record externalSsotRepo null");
    process.exit(1);
  }
  console.log("selection OK", JSON.stringify(j,null,2));
' "$SEL"

[[ -f "${TARGET}/.cursor/mcp.json" ]] || { echo "FAIL: missing mcp.json"; exit 1; }
grep -q 'AGENT_COLLECTIONS_HOME' "${TARGET}/.cursor/mcp.json" \
  || { echo "FAIL: mcp.json missing AGENT_COLLECTIONS_HOME"; exit 1; }
[[ -f "${TARGET}/AGENTS.md" ]] || { echo "FAIL: missing AGENTS.md"; exit 1; }
[[ -f "${TARGET}/.agent-collections/area-profile.txt" ]] || { echo "FAIL: missing area profile"; exit 1; }
grep -q 'frontend-scope' "${TARGET}/.agent-collections/area-profile.txt"
[[ -f "${TARGET}/docs/context/README.md" ]] || { echo "FAIL: missing docs/context/README.md"; exit 1; }
[[ -f "${TARGET}/docs/plans/README.md" ]] || { echo "FAIL: missing docs/plans/README.md"; exit 1; }
[[ -f "${TARGET}/docs/decisions/INDEX.md" ]] || { echo "FAIL: missing docs/decisions/INDEX.md"; exit 1; }

# .cursor/skills/ — content parity with .ai/skills/ SSOT (same guarantee
# .claude/skills/ already has), including for the specific skill reported
# unreachable in docs/specs/promote-skill-cursor-packaging/.
CURSOR_SKILL_SRC="${ROOT}/.ai/skills/eversis-promote-domain-knowledge/SKILL.md"
CURSOR_SKILL_DST="${TARGET}/.cursor/skills/eversis-promote-domain-knowledge/SKILL.md"
[[ -f "$CURSOR_SKILL_DST" ]] || { echo "FAIL: missing .cursor/skills/eversis-promote-domain-knowledge/SKILL.md"; exit 1; }
cmp -s "$CURSOR_SKILL_SRC" "$CURSOR_SKILL_DST" \
  || { echo "FAIL: .cursor/skills/.../SKILL.md content diverges from .ai/skills/ SSOT"; exit 1; }
grep -qF 'user-invocable: false' "$CURSOR_SKILL_DST" \
  || { echo "FAIL: .cursor/skills/.../SKILL.md lost user-invocable: false"; exit 1; }

EXPECTED_HOME="$(cd "$ROOT" && pwd)"
HOME_MARKER="${TARGET}/.agent-collections/framework-home.txt"
[[ -f "$HOME_MARKER" ]] \
  || { echo "FAIL: local mode missing .agent-collections/framework-home.txt"; exit 1; }
grep -qxF "$EXPECTED_HOME" "$HOME_MARKER" \
  || { echo "FAIL: local framework-home.txt does not match collections home (${EXPECTED_HOME})"; cat "$HOME_MARKER"; exit 1; }

# --agents=claude, vendored (--vendor=copy) — exercises Phases A/B/D of the
# claude-code-setup plan: .mcp.json (not .cursor/mcp.json), and CLAUDE.md
# pointing at the vendored .ai/ prefix instead of the dangling bare .ai/...
# paths from F11.
TARGET_CLAUDE="${TMP}/consumer-claude"
mkdir -p "$TARGET_CLAUDE"
(cd "$TARGET_CLAUDE" && git init -q)

CLAUDE_INSTALL_LOG="${TMP}/consumer-claude-install.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_CLAUDE" \
  --non-interactive \
  --vendor=copy \
  --agents=claude \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  | tee "$CLAUDE_INSTALL_LOG"

# F12 regression: printed "Next steps" must point Claude customisation at
# .claude/CLAUDE.md, never AGENTS.md, and Deselection must mention the
# Phase C/D pruned surfaces (.claude/commands|rules|skills), not just
# CLAUDE.md/.claudeignore.
grep -qF 'Customise AGENTS.md' "$CLAUDE_INSTALL_LOG" \
  && { echo "FAIL: Next steps still tells Claude users to customise AGENTS.md (F12)"; exit 1; }
grep -qF 'Customise .claude/CLAUDE.md' "$CLAUDE_INSTALL_LOG" \
  || { echo "FAIL: Next steps missing 'Customise .claude/CLAUDE.md' line"; exit 1; }
grep -qF 'Review AGENTS.md' "$CLAUDE_INSTALL_LOG" \
  || { echo "FAIL: Next steps missing the AGENTS.md reminder for --agents=claude"; exit 1; }
grep -qF '.claude/skills/' "$CLAUDE_INSTALL_LOG" \
  || { echo "FAIL: Deselection paragraph doesn't mention .claude/skills/ pruning"; exit 1; }

[[ -f "${TARGET_CLAUDE}/.agent-collections/framework-home.txt" ]] \
  && { echo "FAIL: vendor mode wrote machine-local .agent-collections/framework-home.txt"; exit 1; }

[[ -f "${TARGET_CLAUDE}/.mcp.json" ]] || { echo "FAIL: missing .mcp.json for --agents=claude"; exit 1; }
[[ -f "${TARGET_CLAUDE}/.cursor/mcp.json" ]] && { echo "FAIL: .cursor/mcp.json should not exist for --agents=claude"; exit 1; }
grep -qF '${env:' "${TARGET_CLAUDE}/.mcp.json" \
  && { echo "FAIL: .mcp.json still contains \${env:...} (Claude Code can't expand it)"; exit 1; }
grep -qF '"command": "bash"' "${TARGET_CLAUDE}/.mcp.json" \
  || { echo "FAIL: .mcp.json eversis-collections command is not bash"; exit 1; }
node -e '
  const fs = require("fs");
  const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  const e = j.mcpServers["eversis-collections"];
  if (!e || e.command !== "bash" || !e.args || e.args[0] !== "-c") process.exit(1);
  const locator = e.args[1] || "";
  if (!locator.includes("$CLAUDE_PROJECT_DIR")) process.exit(2);
  if (locator.includes("${CLAUDE_PROJECT_DIR")) process.exit(3);
' "${TARGET_CLAUDE}/.mcp.json" \
  || { echo "FAIL: .mcp.json -c locator missing bare \$CLAUDE_PROJECT_DIR or still has \${CLAUDE_PROJECT_DIR"; exit 1; }
grep -qF '${CLAUDE_PROJECT_DIR' "${TARGET_CLAUDE}/.mcp.json" \
  && { echo "FAIL: .mcp.json still contains \${CLAUDE_PROJECT_DIR brace form"; exit 1; }
[[ -f "${TARGET_CLAUDE}/scripts/run-eversis-collections-mcp.sh" ]] \
  || { echo "FAIL: missing scripts/run-eversis-collections-mcp.sh for vendored Claude"; exit 1; }
grep -qF 'dist/index.js' "${TARGET_CLAUDE}/.mcp.json" \
  && { echo "FAIL: .mcp.json still references the pre-Docker dist/index.js entry"; exit 1; }
grep -qF 'vendor/agent-collections/.ai/prompts/public/' "${TARGET_CLAUDE}/CLAUDE.md" \
  || { echo "FAIL: CLAUDE.md How-to section doesn't point at the vendored .ai/ prefix (F11)"; exit 1; }

# .claude/commands/ (Phase C) — native slash command parity with Cursor.
[[ -f "${TARGET_CLAUDE}/.claude/commands/eversis-implement.md" ]] \
  || { echo "FAIL: missing .claude/commands/eversis-implement.md"; exit 1; }
grep -qF 'argument-hint:' "${TARGET_CLAUDE}/.claude/commands/eversis-implement.md" \
  || { echo "FAIL: .claude/commands/eversis-implement.md missing argument-hint frontmatter"; exit 1; }

# .claude/skills/ (Phase D) — content parity with .ai/skills/ SSOT, and
# user-invocable: false must survive the copy untouched (menu-hiding gate).
SKILL_SRC="${ROOT}/.ai/skills/eversis-orchestrating-implementation/SKILL.md"
SKILL_DST="${TARGET_CLAUDE}/.claude/skills/eversis-orchestrating-implementation/SKILL.md"
[[ -f "$SKILL_DST" ]] || { echo "FAIL: missing .claude/skills/eversis-orchestrating-implementation/SKILL.md"; exit 1; }
cmp -s "$SKILL_SRC" "$SKILL_DST" \
  || { echo "FAIL: .claude/skills/.../SKILL.md content diverges from .ai/skills/ SSOT"; exit 1; }
grep -qF 'user-invocable: false' "$SKILL_DST" \
  || { echo "FAIL: .claude/skills/.../SKILL.md lost user-invocable: false"; exit 1; }

# .claude/CLAUDE.md (Phase G) — seeded once, and its @AGENTS.md import must
# be resolvable: Claude Code resolves @-imports relative to the importing
# file's own directory, not the working directory, so from inside .claude/
# the import must be @../AGENTS.md, not a bare @AGENTS.md (which would
# resolve to a nonexistent .claude/AGENTS.md).
CLAUDE_PROJECT_MD="${TARGET_CLAUDE}/.claude/CLAUDE.md"
[[ -f "$CLAUDE_PROJECT_MD" ]] || { echo "FAIL: missing .claude/CLAUDE.md"; exit 1; }
grep -qF '@../AGENTS.md' "$CLAUDE_PROJECT_MD" \
  || { echo "FAIL: .claude/CLAUDE.md import is not @../AGENTS.md (would not resolve from .claude/)"; exit 1; }
IMPORT_REL="$(head -1 "$CLAUDE_PROJECT_MD" | sed 's/^@//')"
[[ -f "$(dirname "$CLAUDE_PROJECT_MD")/${IMPORT_REL}" ]] \
  || { echo "FAIL: .claude/CLAUDE.md's @-import (resolved relative to its own directory, per Claude Code docs) does not point at a real file"; exit 1; }

# Deselecting Claude on re-run must prune ALL framework-generated .claude/*
# artifacts (commands, rules, skills, CLAUDE.md, .claudeignore) — not just
# the ones whose own generator happens to run again. Regression coverage
# for a code-review finding: .claude/commands/*.md and .claude/rules/*.md
# used to survive a --agents=cursor re-run because their orphan-cleanup
# only fires as a side effect of the (now-skipped) Claude generators.
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_CLAUDE" \
  --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy

shopt -s nullglob
LEFTOVER_COMMANDS=("${TARGET_CLAUDE}/.claude/commands/"eversis-*.md)
LEFTOVER_RULES=("${TARGET_CLAUDE}/.claude/rules/"eversis-*.md)
LEFTOVER_SKILLS=("${TARGET_CLAUDE}/.claude/skills/"eversis-*)
shopt -u nullglob
[[ ${#LEFTOVER_COMMANDS[@]} -eq 0 ]] \
  || { echo "FAIL: .claude/commands/eversis-*.md survived deselecting Claude: ${LEFTOVER_COMMANDS[*]}"; exit 1; }
[[ ${#LEFTOVER_RULES[@]} -eq 0 ]] \
  || { echo "FAIL: .claude/rules/eversis-*.md survived deselecting Claude: ${LEFTOVER_RULES[*]}"; exit 1; }
[[ ${#LEFTOVER_SKILLS[@]} -eq 0 ]] \
  || { echo "FAIL: .claude/skills/eversis-* survived deselecting Claude: ${LEFTOVER_SKILLS[*]}"; exit 1; }
# Note: .mcp.json itself is intentionally left in place on deselect — same
# convention as .cursor/mcp.json when Cursor is deselected. Only the
# per-server *contents* are pruned by mcp-merge.mjs's "kept" logic, not the
# host config file; deleting host config files on deselect is out of scope.

# --agents=cursor, vendored (--vendor=copy) — the exact scenario reported in
# docs/specs/promote-skill-cursor-packaging/: a Cursor-only, vendored consumer
# install. Regression coverage for both halves of that fix: (A) .cursor/commands/
# SSOT pointers must resolve under the vendored .ai/ prefix, not the dangling
# bare .ai/... paths; (B) .cursor/skills/ must mirror .ai/skills/, matching
# .claude/skills/'s existing guarantee.
TARGET_CURSOR_VENDORED="${TMP}/consumer-cursor-vendored"
mkdir -p "$TARGET_CURSOR_VENDORED"
(cd "$TARGET_CURSOR_VENDORED" && git init -q)

bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_CURSOR_VENDORED" \
  --non-interactive \
  --vendor=copy \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy

grep -qF 'vendor/agent-collections/.ai/prompts/public/' "${TARGET_CURSOR_VENDORED}/.cursor/commands/eversis-implement.md" \
  || { echo "FAIL: .cursor/commands/eversis-implement.md SSOT is not vendor-prefixed (fix regression)"; exit 1; }
grep -qF '**SSOT:** `.ai/prompts/public/eversis-implement.md`' "${TARGET_CURSOR_VENDORED}/.cursor/commands/eversis-implement.md" \
  && { echo "FAIL: .cursor/commands/eversis-implement.md still has the dangling unprefixed SSOT path"; exit 1; }

CURSOR_VENDORED_SKILL_DST="${TARGET_CURSOR_VENDORED}/.cursor/skills/eversis-promote-domain-knowledge/SKILL.md"
[[ -f "$CURSOR_VENDORED_SKILL_DST" ]] \
  || { echo "FAIL: missing .cursor/skills/eversis-promote-domain-knowledge/SKILL.md in vendored cursor-only install"; exit 1; }
cmp -s "${ROOT}/.ai/skills/eversis-promote-domain-knowledge/SKILL.md" "$CURSOR_VENDORED_SKILL_DST" \
  || { echo "FAIL: vendored .cursor/skills/.../SKILL.md content diverges from .ai/skills/ SSOT"; exit 1; }

# Deselecting Cursor on re-run must prune .cursor/skills/eversis-* — same
# guarantee .claude/skills/ already has for a Claude deselect.
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_CURSOR_VENDORED" \
  --non-interactive \
  --agents=claude \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy

shopt -s nullglob
LEFTOVER_CURSOR_SKILLS=("${TARGET_CURSOR_VENDORED}/.cursor/skills/"eversis-*)
shopt -u nullglob
[[ ${#LEFTOVER_CURSOR_SKILLS[@]} -eq 0 ]] \
  || { echo "FAIL: .cursor/skills/eversis-* survived deselecting Cursor: ${LEFTOVER_CURSOR_SKILLS[*]}"; exit 1; }

# Cursor User MCP overlap (warn-only). Isolate from the real ~/.cursor/mcp.json.
TARGET_OVERLAP="${TMP}/consumer-overlap"
mkdir -p "$TARGET_OVERLAP"
(cd "$TARGET_OVERLAP" && git init -q)
USER_MCP_FIXTURE="${TMP}/user-mcp/mcp.json"
mkdir -p "$(dirname "$USER_MCP_FIXTURE")"
printf '%s\n' '{"mcpServers":{"eversis-collections":{"command":"node","args":["/unused/dist/index.js"]},"personal-only":{"command":"true"}}}' > "$USER_MCP_FIXTURE"
USER_MCP_BEFORE="$(cksum "$USER_MCP_FIXTURE")"
OVERLAP_LOG="${TMP}/overlap-install.log"
AGENT_COLLECTIONS_USER_MCP="$USER_MCP_FIXTURE" \
  bash "${ROOT}/scripts/setup-agent-collections.sh" \
    --collections-home "$ROOT" \
    --target "$TARGET_OVERLAP" \
    --non-interactive \
    --agents=cursor \
    --mcp-servers=eversis-collections \
    --profile=frontend \
    --link-mode=copy \
    > "$OVERLAP_LOG" 2>&1
grep -q 'Cursor User MCP already has catalog server(s): eversis-collections' "$OVERLAP_LOG" \
  || { echo "FAIL: expected User MCP overlap warning"; cat "$OVERLAP_LOG"; exit 1; }
grep -q 'badge User' "$OVERLAP_LOG" \
  || { echo "FAIL: overlap warning missing Cursor User vs project badge hint"; cat "$OVERLAP_LOG"; exit 1; }
grep -q 'does not edit the User file' "$OVERLAP_LOG" \
  || { echo "FAIL: overlap warning missing 'does not edit the User file'"; cat "$OVERLAP_LOG"; exit 1; }
[[ -f "${TARGET_OVERLAP}/.cursor/mcp.json" ]] \
  || { echo "FAIL: overlap run did not write project .cursor/mcp.json"; exit 1; }
[[ "$(cksum "$USER_MCP_FIXTURE")" == "$USER_MCP_BEFORE" ]] \
  || { echo "FAIL: installer modified the User MCP fixture"; exit 1; }

TARGET_NO_USER="${TMP}/consumer-no-user-mcp"
mkdir -p "$TARGET_NO_USER"
(cd "$TARGET_NO_USER" && git init -q)
NO_USER_LOG="${TMP}/no-user-mcp-install.log"
AGENT_COLLECTIONS_USER_MCP="${TMP}/missing-user-mcp.json" \
  bash "${ROOT}/scripts/setup-agent-collections.sh" \
    --collections-home "$ROOT" \
    --target "$TARGET_NO_USER" \
    --non-interactive \
    --agents=cursor \
    --mcp-servers=eversis-collections \
    --profile=frontend \
    --link-mode=copy \
    > "$NO_USER_LOG" 2>&1
grep -q 'Cursor User MCP already has catalog' "$NO_USER_LOG" \
  && { echo "FAIL: warned about User MCP overlap when User file is missing"; cat "$NO_USER_LOG"; exit 1; }
[[ -f "${TARGET_NO_USER}/.cursor/mcp.json" ]] \
  || { echo "FAIL: missing-User-file run did not write project .cursor/mcp.json"; exit 1; }

# Invalid User JSON must not fail install.
TARGET_BAD_USER="${TMP}/consumer-bad-user-mcp"
mkdir -p "$TARGET_BAD_USER"
(cd "$TARGET_BAD_USER" && git init -q)
BAD_USER_MCP="${TMP}/bad-user-mcp.json"
echo '{not-json' > "$BAD_USER_MCP"
BAD_USER_LOG="${TMP}/bad-user-mcp-install.log"
AGENT_COLLECTIONS_USER_MCP="$BAD_USER_MCP" \
  bash "${ROOT}/scripts/setup-agent-collections.sh" \
    --collections-home "$ROOT" \
    --target "$TARGET_BAD_USER" \
    --non-interactive \
    --agents=cursor \
    --mcp-servers=eversis-collections \
    --profile=frontend \
    --link-mode=copy \
    > "$BAD_USER_LOG" 2>&1 \
  || { echo "FAIL: invalid User MCP JSON should not fail install"; cat "$BAD_USER_LOG"; exit 1; }
[[ -f "${TARGET_BAD_USER}/.cursor/mcp.json" ]] \
  || { echo "FAIL: invalid-User-JSON run did not write project .cursor/mcp.json"; exit 1; }

# Upgrade reuse
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --upgrade --sync --non-interactive

SSOT_URL="https://gitlab3.eversis.com/dawis/domain-context.git"
node -e "
  const fs=require('fs');
  const p=process.argv[1];
  const j=JSON.parse(fs.readFileSync(p,'utf8'));
  j.ssot=j.ssot||{};
  j.ssot.externalSsotRepo=process.argv[2];
  j.ssot.confluenceSpaceKey='DAWIS';
  fs.writeFileSync(p, JSON.stringify(j,null,2)+'\n');
" "${TARGET}/.agent-collections/install-selection.json" "$SSOT_URL"
# Restore fills ARG_SSOT_SOURCE; seed_ssot_global skips when global/ already exists (Q4).
mkdir -p "${TARGET}/docs/context/global"

bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --upgrade --sync --non-interactive

node -e "
  const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));
  if (j.ssot.externalSsotRepo !== process.argv[2]) { console.error('FAIL: upgrade wiped externalSsotRepo'); process.exit(1); }
  if (j.ssot.confluenceSpaceKey !== 'DAWIS') { console.error('FAIL: upgrade wiped confluenceSpaceKey'); process.exit(1); }
  console.log('upgrade preserved ssot.externalSsotRepo and confluenceSpaceKey');
" "${TARGET}/.agent-collections/install-selection.json" "$SSOT_URL"

bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --upgrade --sync --non-interactive \
  --ssot-source=

node -e "
  const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));
  if (j.ssot.externalSsotRepo !== null) { console.error('FAIL: empty --ssot-source did not clear externalSsotRepo'); process.exit(1); }
  if (j.ssot.confluenceSpaceKey !== 'DAWIS') { console.error('FAIL: clear ssot-source also wiped confluenceSpaceKey'); process.exit(1); }
  console.log('empty --ssot-source cleared externalSsotRepo and kept confluenceSpaceKey');
" "${TARGET}/.agent-collections/install-selection.json"

# Fail-safe missing selection
BAD="${TMP}/bad"
mkdir -p "$BAD"
(cd "$BAD" && git init -q)
if bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$BAD" \
  --upgrade --non-interactive 2>/tmp/ac-upgrade-fail.txt; then
  echo "FAIL: upgrade without selection should fail"
  exit 1
fi
grep -qi 'install-selection' /tmp/ac-upgrade-fail.txt \
  || { echo "FAIL: expected fail-safe message"; cat /tmp/ac-upgrade-fail.txt; exit 1; }

# Corrupt selection
mkdir -p "${BAD}/.agent-collections"
echo '{not-json' > "${BAD}/.agent-collections/install-selection.json"
if bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$BAD" \
  --upgrade --non-interactive 2>/tmp/ac-upgrade-corrupt.txt; then
  echo "FAIL: corrupt selection should fail"
  exit 1
fi
grep -qiE 'invalid|corrupt|wizard|missing' /tmp/ac-upgrade-corrupt.txt \
  || { echo "FAIL: expected corrupt fail-safe"; cat /tmp/ac-upgrade-corrupt.txt; exit 1; }

# ---------------------------------------------------------------------------
# Pi agent. Counts are computed from .ai/ — never hard-coded.
# ---------------------------------------------------------------------------
PI_MARKER='GENERATED by adapters/pi/generate.mjs'
PI_EXPECTED_PROMPTS="$(node -e '
  const fs = require("fs"), path = require("path");
  const root = process.argv[1];
  const denyFile = path.join(root, "adapters/claude/command-deny.yaml");
  const deny = new Set();
  if (fs.existsSync(denyFile)) {
    for (const line of fs.readFileSync(denyFile, "utf8").split("\n")) {
      if (/^\s*#/.test(line)) continue;
      for (const m of line.matchAll(/eversis-[A-Za-z0-9-]+/g)) deny.add(m[0]);
    }
  }
  let n = 0;
  for (const dir of ["public", "internal"]) {
    for (const f of fs.readdirSync(path.join(root, ".ai/prompts", dir))) {
      if (/^eversis-.*\.md$/.test(f) && !deny.has(f.replace(/\.md$/, ""))) n++;
    }
  }
  console.log(n);
' "$ROOT")"
PI_EXPECTED_SKILLS="$(find "${ROOT}/.ai/skills" -mindepth 1 -maxdepth 1 -type d -name 'eversis-*' | wc -l | tr -d ' ')"

# Asserts the recorded selection agents equal $2 (JSON array text).
_assert_selection_agents() {
  local target="$1" expected="$2" label="$3"
  node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    if (JSON.stringify(j.agents) !== process.argv[2]) {
      console.error("agents=" + JSON.stringify(j.agents));
      process.exit(1);
    }
  ' "${target}/.agent-collections/install-selection.json" "$expected" \
    || { echo "FAIL: ${label}: selection agents are not ${expected}"; exit 1; }
}

# Asserts a full, successful Pi tree under $1.
_assert_pi_tree() {
  local target="$1" label="$2"
  grep -qF "$PI_MARKER" "${target}/.pi/APPEND_SYSTEM.md" 2>/dev/null \
    || { echo "FAIL: ${label}: missing generated .pi/APPEND_SYSTEM.md"; exit 1; }
  local prompts roles
  prompts="$(find "${target}/.pi/prompts" -maxdepth 1 -name 'eversis-*.md' -type f | wc -l | tr -d ' ')"
  [[ "$prompts" == "$PI_EXPECTED_PROMPTS" ]] \
    || { echo "FAIL: ${label}: .pi/prompts has ${prompts} eversis-*.md, expected ${PI_EXPECTED_PROMPTS}"; exit 1; }
  roles="$(grep -lF "$PI_MARKER" "${target}/.pi/skills"/eversis-rule-*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$roles" == "6" ]] \
    || { echo "FAIL: ${label}: expected 6 generated eversis-rule-* role skills, found ${roles}"; exit 1; }
  local src name mirrored=0
  for src in "${ROOT}/.ai/skills"/eversis-*; do
    [[ -d "$src" ]] || continue
    name="$(basename "$src")"
    cmp -s "${src}/SKILL.md" "${target}/.pi/skills/${name}/SKILL.md" \
      || { echo "FAIL: ${label}: .pi/skills/${name}/SKILL.md missing or diverges from .ai/skills/"; exit 1; }
    mirrored=$((mirrored + 1))
  done
  local mirror_count
  mirror_count="$(find "${target}/.pi/skills" -mindepth 1 -maxdepth 1 -name 'eversis-*' ! -name 'eversis-rule-*' | wc -l | tr -d ' ')"
  [[ "$mirror_count" == "$PI_EXPECTED_SKILLS" && "$mirrored" == "$PI_EXPECTED_SKILLS" ]] \
    || { echo "FAIL: ${label}: .pi/skills mirror has ${mirror_count} entries, expected ${PI_EXPECTED_SKILLS}"; exit 1; }
  grep -qF "$PI_MARKER" "${target}/.pi/extensions/eversis-context-budget.ts" 2>/dev/null \
    || { echo "FAIL: ${label}: missing generated .pi/extensions/eversis-context-budget.ts"; exit 1; }
  grep -qF "$PI_MARKER" "${target}/.pi/extensions/eversis-process-rules.ts" 2>/dev/null \
    || { echo "FAIL: ${label}: missing generated .pi/extensions/eversis-process-rules.ts"; exit 1; }
  grep -qF "$PI_MARKER" "${target}/.pi/extensions/eversis-review.ts" 2>/dev/null \
    || { echo "FAIL: ${label}: missing generated .pi/extensions/eversis-review.ts"; exit 1; }
  [[ -f "${target}/.pi/settings.json" ]] \
    || { echo "FAIL: ${label}: missing seeded .pi/settings.json"; exit 1; }
  node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    const e = j.mcpServers && j.mcpServers["eversis-collections"];
    if (!e || e.command !== "bash" || !e.args || e.args[0] !== "-c") process.exit(1);
    if (j.inputs !== undefined) process.exit(2);
    const all = JSON.stringify(j);
    if (all.includes("${workspaceFolder}") || all.includes("${env:") || all.includes("CLAUDE_PROJECT_DIR")) process.exit(3);
  ' "${target}/.pi/mcp.json" \
    || { echo "FAIL: ${label}: .pi/mcp.json missing or not the Pi bash -c shape"; exit 1; }
}

# PATH without the pi CLI (node, git and docker kept) — exercises the
# "pi CLI not found" summary warning regardless of the dev machine.
PI_NO_CLI_BIN="${TMP}/no-pi-bin"
mkdir -p "$PI_NO_CLI_BIN"
for _cmd in node git docker; do
  _cmd_path="$(command -v "$_cmd" || true)"
  [[ -n "$_cmd_path" ]] && ln -sf "$_cmd_path" "${PI_NO_CLI_BIN}/${_cmd}"
done
PI_NO_CLI_PATH="${PI_NO_CLI_BIN}:/usr/bin:/bin:/usr/sbin:/sbin"

# (a) --agents=pi --vendor=copy — Pi-only, vendored; no Cursor / Claude output.
TARGET_PI="${TMP}/consumer-pi"
mkdir -p "$TARGET_PI"
(cd "$TARGET_PI" && git init -q)
PI_LOG="${TMP}/consumer-pi-install.log"
PATH="$PI_NO_CLI_PATH" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI" \
  --non-interactive \
  --vendor=copy \
  --agents=pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$PI_LOG" 2>&1 \
  || { echo "FAIL: (a) --agents=pi install failed"; cat "$PI_LOG"; exit 1; }
_assert_pi_tree "$TARGET_PI" "(a) --agents=pi"
grep -qF 'vendor/agent-collections/.ai/prompts/public/eversis-implement.md' "${TARGET_PI}/.pi/prompts/eversis-implement.md" \
  || { echo "FAIL: (a) .pi/prompts SSOT pointer is not vendor-prefixed"; exit 1; }
[[ -x "${TARGET_PI}/scripts/run-eversis-collections-mcp.sh" ]] \
  || { echo "FAIL: (a) vendored Pi did not copy scripts/run-eversis-collections-mcp.sh"; exit 1; }
[[ -e "${TARGET_PI}/.cursor/commands" ]] && { echo "FAIL: (a) --agents=pi generated .cursor/commands/"; exit 1; }
[[ -e "${TARGET_PI}/.cursor/skills" ]] && { echo "FAIL: (a) --agents=pi mirrored .cursor/skills/"; exit 1; }
[[ -e "${TARGET_PI}/.cursor/mcp.json" ]] && { echo "FAIL: (a) --agents=pi wrote .cursor/mcp.json"; exit 1; }
[[ -e "${TARGET_PI}/.claude" ]] && { echo "FAIL: (a) --agents=pi generated .claude/"; exit 1; }
[[ -e "${TARGET_PI}/.mcp.json" ]] && { echo "FAIL: (a) --agents=pi wrote .mcp.json"; exit 1; }
grep -rlF 'GENERATED by adapters/cursor/generate.mjs' "${TARGET_PI}/.cursor" >/dev/null 2>&1 \
  && { echo "FAIL: (a) --agents=pi left Cursor-generated files"; exit 1; }
[[ -f "${TARGET_PI}/CLAUDE.md" ]] && { echo "FAIL: (a) --agents=pi generated CLAUDE.md"; exit 1; }
_assert_selection_agents "$TARGET_PI" '["pi"]' "(a) --agents=pi"
grep -qF "'pi' CLI not found on PATH" "$PI_LOG" \
  || { echo "FAIL: (a) missing 'pi CLI not found' summary warning"; cat "$PI_LOG"; exit 1; }
grep -qF 'grant project trust' "$PI_LOG" \
  || { echo "FAIL: (a) summary missing Pi next steps (project trust)"; exit 1; }
grep -qF 'completed with failures' "$PI_LOG" \
  && { echo "FAIL: (a) successful Pi install printed a failure headline"; exit 1; }

# (a2) re-run: role skills survive the .pi/skills mirror stale-prune.
PI_RERUN_LOG="${TMP}/consumer-pi-rerun.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI" \
  --non-interactive \
  --vendor=copy \
  --agents=pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$PI_RERUN_LOG" 2>&1 \
  || { echo "FAIL: (a2) --agents=pi re-run failed"; cat "$PI_RERUN_LOG"; exit 1; }
grep -qF 'stale skill package(s) from .pi/skills/' "$PI_RERUN_LOG" \
  && { echo "FAIL: (a2) re-run stale-pruned .pi/skills/ entries (role skills?)"; exit 1; }
_assert_pi_tree "$TARGET_PI" "(a2) --agents=pi re-run"

# (g) --upgrade keeps Pi: from the record, and from generator markers when the
# record no longer lists it.
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI" \
  --upgrade --sync --non-interactive \
  > "${TMP}/consumer-pi-upgrade.log" 2>&1 \
  || { echo "FAIL: (g) --upgrade on a Pi install failed"; cat "${TMP}/consumer-pi-upgrade.log"; exit 1; }
_assert_selection_agents "$TARGET_PI" '["pi"]' "(g) --upgrade"
_assert_pi_tree "$TARGET_PI" "(g) --upgrade"
node -e '
  const fs = require("fs");
  const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  j.agents = [];
  fs.writeFileSync(process.argv[1], JSON.stringify(j, null, 2) + "\n");
' "${TARGET_PI}/.agent-collections/install-selection.json"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI" \
  --upgrade --sync --non-interactive \
  > "${TMP}/consumer-pi-upgrade-detect.log" 2>&1 \
  || { echo "FAIL: (g) --upgrade with a record missing pi failed"; cat "${TMP}/consumer-pi-upgrade-detect.log"; exit 1; }
_assert_selection_agents "$TARGET_PI" '["pi"]' "(g) --upgrade detects Pi from markers"
[[ -e "${TARGET_PI}/.cursor/mcp.json" ]] && { echo "FAIL: (g) Pi upgrade fell back to Cursor"; exit 1; }

# (b) --agents=cursor,pi (local mode).
TARGET_CURSOR_PI="${TMP}/consumer-cursor-pi"
mkdir -p "$TARGET_CURSOR_PI"
(cd "$TARGET_CURSOR_PI" && git init -q)
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_CURSOR_PI" \
  --non-interactive \
  --agents=cursor,pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "${TMP}/consumer-cursor-pi.log" 2>&1 \
  || { echo "FAIL: (b) --agents=cursor,pi install failed"; cat "${TMP}/consumer-cursor-pi.log"; exit 1; }
_assert_pi_tree "$TARGET_CURSOR_PI" "(b) --agents=cursor,pi"
[[ -f "${TARGET_CURSOR_PI}/.cursor/commands/eversis-implement.md" ]] \
  || { echo "FAIL: (b) missing .cursor/commands/eversis-implement.md"; exit 1; }
[[ -f "${TARGET_CURSOR_PI}/.cursor/mcp.json" ]] || { echo "FAIL: (b) missing .cursor/mcp.json"; exit 1; }
[[ -f "${TARGET_CURSOR_PI}/.cursor/skills/eversis-promote-domain-knowledge/SKILL.md" ]] \
  || { echo "FAIL: (b) missing .cursor/skills mirror"; exit 1; }
grep -qF '${AGENT_COLLECTIONS_HOME}/.ai/prompts/public/eversis-implement.md' "${TARGET_CURSOR_PI}/.pi/prompts/eversis-implement.md" \
  || { echo "FAIL: (b) local-mode .pi/prompts SSOT pointer is not \${AGENT_COLLECTIONS_HOME}-prefixed"; exit 1; }
_assert_selection_agents "$TARGET_CURSOR_PI" '["cursor","pi"]' "(b) --agents=cursor,pi"

# (c) re-run with --agents=cursor prunes Pi generated files only.
mkdir -p "${TARGET_CURSOR_PI}/.pi/prompts" "${TARGET_CURSOR_PI}/.pi/skills/my-team-skill"
echo 'hand-made' > "${TARGET_CURSOR_PI}/.pi/prompts/eversis-handmade.md"
echo 'hand-made' > "${TARGET_CURSOR_PI}/.pi/prompts/team.md"
echo 'hand-made' > "${TARGET_CURSOR_PI}/.pi/skills/my-team-skill/SKILL.md"
# .pi/eversis-state/ is created by the extension at runtime, never by the installer.
mkdir -p "${TARGET_CURSOR_PI}/.pi/eversis-state"
echo '*' > "${TARGET_CURSOR_PI}/.pi/eversis-state/.gitignore"
echo '{"plan":"docs/specs/proj-1/proj-1.plan.md"}' > "${TARGET_CURSOR_PI}/.pi/eversis-state/active-plan.json"
PI_DESELECT_LOG="${TMP}/consumer-cursor-pi-deselect.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_CURSOR_PI" \
  --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$PI_DESELECT_LOG" 2>&1 \
  || { echo "FAIL: (c) Pi deselect re-run failed"; cat "$PI_DESELECT_LOG"; exit 1; }
[[ -e "${TARGET_CURSOR_PI}/.pi/APPEND_SYSTEM.md" ]] && { echo "FAIL: (c) .pi/APPEND_SYSTEM.md survived Pi deselect"; exit 1; }
[[ -e "${TARGET_CURSOR_PI}/.pi/extensions/eversis-context-budget.ts" ]] \
  && { echo "FAIL: (c) .pi/extensions/eversis-context-budget.ts survived Pi deselect"; exit 1; }
[[ -e "${TARGET_CURSOR_PI}/.pi/extensions/eversis-process-rules.ts" ]] \
  && { echo "FAIL: (c) .pi/extensions/eversis-process-rules.ts survived Pi deselect"; exit 1; }
[[ -e "${TARGET_CURSOR_PI}/.pi/extensions/eversis-review.ts" ]] \
  && { echo "FAIL: (c) .pi/extensions/eversis-review.ts survived Pi deselect"; exit 1; }
[[ -e "${TARGET_CURSOR_PI}/.pi/eversis-state" ]] \
  && { echo "FAIL: (c) .pi/eversis-state/ survived Pi deselect"; exit 1; }
grep -lF "$PI_MARKER" "${TARGET_CURSOR_PI}/.pi/prompts"/*.md >/dev/null 2>&1 \
  && { echo "FAIL: (c) generated .pi/prompts survived Pi deselect"; exit 1; }
shopt -s nullglob
LEFTOVER_PI_SKILLS=("${TARGET_CURSOR_PI}/.pi/skills/"eversis-*)
shopt -u nullglob
[[ ${#LEFTOVER_PI_SKILLS[@]} -eq 0 ]] \
  || { echo "FAIL: (c) .pi/skills/eversis-* survived Pi deselect: ${LEFTOVER_PI_SKILLS[*]}"; exit 1; }
[[ -f "${TARGET_CURSOR_PI}/.pi/settings.json" ]] || { echo "FAIL: (c) Pi deselect removed .pi/settings.json"; exit 1; }
[[ -f "${TARGET_CURSOR_PI}/.pi/mcp.json" ]] || { echo "FAIL: (c) Pi deselect removed .pi/mcp.json"; exit 1; }
for _keep in .pi/prompts/eversis-handmade.md .pi/prompts/team.md .pi/skills/my-team-skill/SKILL.md; do
  [[ -f "${TARGET_CURSOR_PI}/${_keep}" ]] || { echo "FAIL: (c) Pi deselect removed hand-made ${_keep}"; exit 1; }
done
[[ -f "${TARGET_CURSOR_PI}/.cursor/commands/eversis-implement.md" ]] \
  || { echo "FAIL: (c) Pi deselect affected Cursor output"; exit 1; }
grep -qF '.pi/settings.json and' "$PI_DESELECT_LOG" \
  || { echo "FAIL: (c) Deselection paragraph does not describe Pi surfaces"; exit 1; }
grep -qF '.pi/extensions/eversis-review.ts' "$PI_DESELECT_LOG" \
  || { echo "FAIL: (c) Deselection paragraph does not list .pi/extensions/eversis-review.ts"; exit 1; }
_assert_selection_agents "$TARGET_CURSOR_PI" '["cursor"]' "(c) Pi deselect"

# (d) induced Pi generation failure (.pi is a regular file) with cursor,pi.
TARGET_PI_FAIL="${TMP}/consumer-pi-fail"
mkdir -p "$TARGET_PI_FAIL"
(cd "$TARGET_PI_FAIL" && git init -q)
echo 'not a directory' > "${TARGET_PI_FAIL}/.pi"
PI_FAIL_LOG="${TMP}/consumer-pi-fail.log"
_rc=0
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI_FAIL" \
  --non-interactive \
  --agents=cursor,pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$PI_FAIL_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 1 ]] || { echo "FAIL: (d) induced Pi failure with cursor,pi exited ${_rc}, expected 1"; cat "$PI_FAIL_LOG"; exit 1; }
grep -qF 'pi: Pi adapter generation failed' "$PI_FAIL_LOG" \
  || { echo "FAIL: (d) missing dedicated pi failure line"; cat "$PI_FAIL_LOG"; exit 1; }
grep -qF 'exists and is not a directory' "$PI_FAIL_LOG" \
  || { echo "FAIL: (d) pi failure does not name the cause"; cat "$PI_FAIL_LOG"; exit 1; }
grep -qE 'failed: +pi' "$PI_FAIL_LOG" \
  || { echo "FAIL: (d) partial-failure report does not list pi"; cat "$PI_FAIL_LOG"; exit 1; }
grep -qF 'agent-collections setup completed with failures (pi)' "$PI_FAIL_LOG" \
  || { echo "FAIL: (d) missing 'completed with failures (pi)' headline"; cat "$PI_FAIL_LOG"; exit 1; }
[[ -f "${TARGET_PI_FAIL}/.cursor/commands/eversis-implement.md" ]] \
  || { echo "FAIL: (d) Cursor output missing after a Pi failure"; exit 1; }
[[ -f "${TARGET_PI_FAIL}/.cursor/mcp.json" ]] || { echo "FAIL: (d) .cursor/mcp.json missing after a Pi failure"; exit 1; }
[[ -f "${TARGET_PI_FAIL}/.pi" ]] || { echo "FAIL: (d) installer replaced the user's .pi file"; exit 1; }
_assert_selection_agents "$TARGET_PI_FAIL" '["cursor"]' "(d) Pi failure with cursor,pi"

# (e) same induced failure with --agents=pi alone: exit 1 right after the Pi
# stage, nothing recorded as a Cursor install.
TARGET_PI_ONLY_FAIL="${TMP}/consumer-pi-only-fail"
mkdir -p "$TARGET_PI_ONLY_FAIL"
(cd "$TARGET_PI_ONLY_FAIL" && git init -q)
echo 'not a directory' > "${TARGET_PI_ONLY_FAIL}/.pi"
PI_ONLY_FAIL_LOG="${TMP}/consumer-pi-only-fail.log"
_rc=0
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI_ONLY_FAIL" \
  --non-interactive \
  --agents=pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$PI_ONLY_FAIL_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 1 ]] || { echo "FAIL: (e) induced Pi-only failure exited ${_rc}, expected 1"; cat "$PI_ONLY_FAIL_LOG"; exit 1; }
grep -qF 'pi: Pi adapter generation failed' "$PI_ONLY_FAIL_LOG" \
  || { echo "FAIL: (e) missing dedicated pi failure line"; cat "$PI_ONLY_FAIL_LOG"; exit 1; }
if [[ -f "${TARGET_PI_ONLY_FAIL}/.agent-collections/install-selection.json" ]]; then
  grep -qF '"cursor"' "${TARGET_PI_ONLY_FAIL}/.agent-collections/install-selection.json" \
    && { echo "FAIL: (e) Pi-only failure recorded a cursor selection"; exit 1; }
fi
[[ -e "${TARGET_PI_ONLY_FAIL}/.cursor/mcp.json" ]] && { echo "FAIL: (e) Pi-only failure wrote .cursor/mcp.json"; exit 1; }
[[ -e "${TARGET_PI_ONLY_FAIL}/.cursor/commands" ]] && { echo "FAIL: (e) Pi-only failure generated .cursor/commands/"; exit 1; }

# (f) malformed existing .pi/mcp.json with cursor,pi: Pi failure, Cursor MCP
# written, exit 1 at the end, pi left out of the selection.
TARGET_PI_BAD_MCP="${TMP}/consumer-pi-bad-mcp"
mkdir -p "${TARGET_PI_BAD_MCP}/.pi"
(cd "$TARGET_PI_BAD_MCP" && git init -q)
echo '{not-json' > "${TARGET_PI_BAD_MCP}/.pi/mcp.json"
PI_BAD_MCP_LOG="${TMP}/consumer-pi-bad-mcp.log"
_rc=0
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_PI_BAD_MCP" \
  --non-interactive \
  --agents=cursor,pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$PI_BAD_MCP_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 1 ]] || { echo "FAIL: (f) malformed .pi/mcp.json exited ${_rc}, expected 1"; cat "$PI_BAD_MCP_LOG"; exit 1; }
grep -qF 'pi: .pi/mcp.json merge failed' "$PI_BAD_MCP_LOG" \
  || { echo "FAIL: (f) missing dedicated pi MCP failure line"; cat "$PI_BAD_MCP_LOG"; exit 1; }
grep -qE 'failed: +pi' "$PI_BAD_MCP_LOG" \
  || { echo "FAIL: (f) partial-failure report does not list pi"; cat "$PI_BAD_MCP_LOG"; exit 1; }
grep -qE 'failed: +mcp-merge' "$PI_BAD_MCP_LOG" \
  && { echo "FAIL: (f) Pi MCP failure reported as mcp-merge"; exit 1; }
[[ -f "${TARGET_PI_BAD_MCP}/.cursor/mcp.json" ]] || { echo "FAIL: (f) .cursor/mcp.json not written"; exit 1; }
[[ "$(cat "${TARGET_PI_BAD_MCP}/.pi/mcp.json")" == "{not-json" ]] \
  || { echo "FAIL: (f) installer overwrote the malformed .pi/mcp.json"; exit 1; }
_assert_selection_agents "$TARGET_PI_BAD_MCP" '["cursor"]' "(f) malformed .pi/mcp.json"

# ---------------------------------------------------------------------------
# Hand-ported Pi, linked worktree slug, legacy generator report, Pi
# mirror copied. Fixtures reproduce the failures seen when upgrading a hand-ported Pi setup.
# ---------------------------------------------------------------------------
LEGACY_PI_MARKER_LINE='<!-- GENERATED by scripts/gen-pi-adapter.mjs — do not edit; re-run `yarn sync:agents` -->'

# Prints one checksum line per file under $1 (excluding .git), sorted.
_tree_checksum() {
  (cd "$1" && find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | while IFS= read -r f; do
    printf '%s  %s\n' "$(cksum < "$f" | tr -s ' ' | tr ' ' '-')" "$f"
  done; find . -path ./.git -prune -o -type l -print | LC_ALL=C sort)
}

# (h) hand-ported .pi/ + record ["cursor"] + --upgrade --sync → stop before any
# write; then an explicit --agents cursor,pi migrates with .bak copies.
TARGET_HAND="${TMP}/consumer-pi-hand-port"
mkdir -p "$TARGET_HAND"
(cd "$TARGET_HAND" && git init -q)
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_HAND" \
  --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "${TMP}/consumer-pi-hand-port-install.log" 2>&1 \
  || { echo "FAIL: (h) cursor install failed"; cat "${TMP}/consumer-pi-hand-port-install.log"; exit 1; }
mkdir -p "${TARGET_HAND}/.pi/prompts" "${TARGET_HAND}/.pi/skills/eversis-fine-handoff" \
  "${TARGET_HAND}/.pi/skills/eversis-code-reviewer"
printf '%s\n# hand-ported always-on prompt\n' "$LEGACY_PI_MARKER_LINE" > "${TARGET_HAND}/.pi/APPEND_SYSTEM.md"
printf '%s\n# hand-ported implement command\n' "$LEGACY_PI_MARKER_LINE" > "${TARGET_HAND}/.pi/prompts/eversis-implement.md"
printf -- '---\nname: eversis-fine-handoff\n---\nhand-ported copy, no marker\n' > "${TARGET_HAND}/.pi/skills/eversis-fine-handoff/SKILL.md"
# No framework counterpart (.ai/skills/ has eversis-code-reviewing, not this).
printf -- '---\nname: eversis-code-reviewer\n---\n%s\nhand-ported reviewer\n' "$LEGACY_PI_MARKER_LINE" \
  > "${TARGET_HAND}/.pi/skills/eversis-code-reviewer/SKILL.md"
# A hand-made regular file under a mirror name (S-B): counted by the stop and
# backed up like a folder.
echo 'hand-ported notes file' > "${TARGET_HAND}/.pi/skills/eversis-notes.md"
[[ -e "${ROOT}/.ai/skills/eversis-code-reviewer" ]] \
  && { echo "FAIL: (h) fixture assumes .ai/skills/eversis-code-reviewer does not exist"; exit 1; }
PI_SKILL_BACKUP="${TARGET_HAND}/.pi/pre-agent-collections-backup/skills"
# Asserts every backup entry under $1 belongs to eversis-code-reviewer,
# eversis-fine-handoff or eversis-notes.md — a mirror copy identical to
# .ai/skills/ is never backed up.
_assert_only_hand_made_backups() {
  local dir="$1" label="$2" b
  for b in "$dir"/*; do
    [[ -e "$b" ]] || continue
    case "$(basename "$b")" in
      eversis-code-reviewer|eversis-code-reviewer.*|eversis-fine-handoff|eversis-fine-handoff.*) ;;
      eversis-notes.md|eversis-notes.md.*) ;;
      *) echo "FAIL: ${label}: unexpected skill backup $(basename "$b")"; exit 1 ;;
    esac
  done
}
HAND_BEFORE="$(_tree_checksum "$TARGET_HAND")"
HAND_STOP_LOG="${TMP}/consumer-pi-hand-port-stop.log"
_rc=0
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_HAND" \
  --upgrade --sync --non-interactive \
  > "$HAND_STOP_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 1 ]] || { echo "FAIL: (h) hand-ported .pi/ upgrade exited ${_rc}, expected 1"; cat "$HAND_STOP_LOG"; exit 1; }
grep -qF -- '--agents cursor,pi' "$HAND_STOP_LOG" \
  || { echo "FAIL: (h) stop message does not name --agents cursor,pi"; cat "$HAND_STOP_LOG"; exit 1; }
grep -qE -- '--agents cursor$' "$HAND_STOP_LOG" \
  || { echo "FAIL: (h) stop message does not name --agents cursor"; cat "$HAND_STOP_LOG"; exit 1; }
[[ "$(_tree_checksum "$TARGET_HAND")" == "$HAND_BEFORE" ]] \
  || { echo "FAIL: (h) stopped upgrade changed files under the target"; cat "$HAND_STOP_LOG"; exit 1; }
HAND_MIGRATE_LOG="${TMP}/consumer-pi-hand-port-migrate.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_HAND" \
  --upgrade --sync --non-interactive \
  --agents cursor,pi \
  > "$HAND_MIGRATE_LOG" 2>&1 \
  || { echo "FAIL: (h) --agents cursor,pi migration failed"; cat "$HAND_MIGRATE_LOG"; exit 1; }
_assert_pi_tree "$TARGET_HAND" "(h) --agents cursor,pi migration"
_assert_selection_agents "$TARGET_HAND" '["cursor","pi"]' "(h) --agents cursor,pi migration"
for _bak in .pi/APPEND_SYSTEM.md.pre-agent-collections.bak .pi/prompts/eversis-implement.md.pre-agent-collections.bak; do
  grep -qF 'GENERATED by scripts/gen-pi-adapter.mjs' "${TARGET_HAND}/${_bak}" 2>/dev/null \
    || { echo "FAIL: (h) migration did not back up the hand-made file to ${_bak}"; exit 1; }
done
# B1: hand-made .pi/skills/eversis-* entries are copied aside before the mirror
# replaces (eversis-fine-handoff, differs) or stale-prunes (eversis-code-reviewer,
# no counterpart) them.
grep -qF 'hand-ported copy, no marker' "${PI_SKILL_BACKUP}/eversis-fine-handoff/SKILL.md" 2>/dev/null \
  || { echo "FAIL: (h) migration did not back up the hand-made eversis-fine-handoff skill"; cat "$HAND_MIGRATE_LOG"; exit 1; }
grep -qF 'hand-ported reviewer' "${PI_SKILL_BACKUP}/eversis-code-reviewer/SKILL.md" 2>/dev/null \
  || { echo "FAIL: (h) migration did not back up the hand-made eversis-code-reviewer skill"; cat "$HAND_MIGRATE_LOG"; exit 1; }
[[ -e "${TARGET_HAND}/.pi/skills/eversis-code-reviewer" ]] \
  && { echo "FAIL: (h) stale hand-made eversis-code-reviewer stayed in .pi/skills/"; exit 1; }
_assert_only_hand_made_backups "$PI_SKILL_BACKUP" "(h) migration"
grep -qF "Backed up .pi/skills/eversis-code-reviewer to .pi/pre-agent-collections-backup/skills/eversis-code-reviewer (no matching framework skill)" "$HAND_MIGRATE_LOG" \
  || { echo "FAIL: (h) skill backup (no counterpart) not logged"; cat "$HAND_MIGRATE_LOG"; exit 1; }
grep -qF "Backed up .pi/skills/eversis-fine-handoff to .pi/pre-agent-collections-backup/skills/eversis-fine-handoff (differs from the framework skill)" "$HAND_MIGRATE_LOG" \
  || { echo "FAIL: (h) skill backup (differs) not logged"; cat "$HAND_MIGRATE_LOG"; exit 1; }
grep -qF 'hand-ported notes file' "${PI_SKILL_BACKUP}/eversis-notes.md" 2>/dev/null \
  || { echo "FAIL: (h) migration did not back up the hand-made regular file eversis-notes.md"; cat "$HAND_MIGRATE_LOG"; exit 1; }
[[ -e "${TARGET_HAND}/.pi/skills/eversis-notes.md" ]] \
  && { echo "FAIL: (h) stale eversis-notes.md stayed in .pi/skills/"; exit 1; }
# After the migration only the .bak copies and the skill backup folder carry
# the legacy marker; they must not count as a hand port or a legacy finding.
_left_legacy="$(TARGET_DIR="$TARGET_HAND" bash -c 'source "$1/common.sh"; source "$1/legacy-pi.sh"; _legacy_pi_marked_files' _ "${ROOT}/scripts/lib/setup-agent-collections")"
[[ -z "$_left_legacy" ]] \
  || { echo "FAIL: (h) legacy-marked files after migration: ${_left_legacy}"; exit 1; }

# (h2) explicit deselect of the migrated install: hand-made skill entries are
# backed up (timestamped, since they differ from the first backups), identical
# mirror copies are not, and the log names the unmarked and legacy-marked files
# it leaves. Once those are deleted, a plain upgrade does not stop — the
# backup folder (holding a legacy-marked copy) is not a hand port.
mkdir -p "${TARGET_HAND}/.pi/skills/eversis-code-reviewer"
printf -- '---\nname: eversis-code-reviewer\n---\n%s\ndeselect hand-made reviewer\n' "$LEGACY_PI_MARKER_LINE" \
  > "${TARGET_HAND}/.pi/skills/eversis-code-reviewer/SKILL.md"
echo 'deselect edit' >> "${TARGET_HAND}/.pi/skills/eversis-fine-handoff/SKILL.md"
echo 'deselect notes file' > "${TARGET_HAND}/.pi/skills/eversis-notes.md"
echo 'hand-made team notes' > "${TARGET_HAND}/.pi/prompts/eversis-team-notes.md"
printf '%s\nlegacy notes\n' "$LEGACY_PI_MARKER_LINE" > "${TARGET_HAND}/.pi/prompts/legacy-notes.md"
HAND_DESELECT_LOG="${TMP}/consumer-pi-hand-port-deselect.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_HAND" \
  --upgrade --sync --non-interactive \
  --agents cursor \
  > "$HAND_DESELECT_LOG" 2>&1 \
  || { echo "FAIL: (h2) explicit Pi deselect failed"; cat "$HAND_DESELECT_LOG"; exit 1; }
grep -rqF 'deselect hand-made reviewer' "$PI_SKILL_BACKUP" \
  || { echo "FAIL: (h2) deselect did not back up the hand-made eversis-code-reviewer skill"; cat "$HAND_DESELECT_LOG"; exit 1; }
grep -rqF 'deselect edit' "$PI_SKILL_BACKUP" \
  || { echo "FAIL: (h2) deselect did not back up the edited eversis-fine-handoff skill"; cat "$HAND_DESELECT_LOG"; exit 1; }
grep -lF 'deselect notes file' "${PI_SKILL_BACKUP}"/eversis-notes.md.* >/dev/null 2>&1 \
  || { echo "FAIL: (h2) deselect did not back up the regular file eversis-notes.md (timestamped)"; cat "$HAND_DESELECT_LOG"; exit 1; }
grep -qF 'hand-ported notes file' "${PI_SKILL_BACKUP}/eversis-notes.md" \
  || { echo "FAIL: (h2) deselect overwrote the earlier eversis-notes.md backup"; exit 1; }
grep -qF 'hand-ported copy, no marker' "${PI_SKILL_BACKUP}/eversis-fine-handoff/SKILL.md" \
  || { echo "FAIL: (h2) deselect overwrote the earlier eversis-fine-handoff backup"; exit 1; }
_assert_only_hand_made_backups "$PI_SKILL_BACKUP" "(h2) deselect"
shopt -s nullglob
LEFTOVER_HAND_SKILLS=("${TARGET_HAND}/.pi/skills/"eversis-*)
shopt -u nullglob
[[ ${#LEFTOVER_HAND_SKILLS[@]} -eq 0 ]] \
  || { echo "FAIL: (h2) .pi/skills/eversis-* survived Pi deselect: ${LEFTOVER_HAND_SKILLS[*]}"; exit 1; }
for _left in .pi/prompts/eversis-team-notes.md .pi/prompts/legacy-notes.md; do
  grep -qF "  ${_left}" "$HAND_DESELECT_LOG" \
    || { echo "FAIL: (h2) deselect leftovers log does not name ${_left}"; cat "$HAND_DESELECT_LOG"; exit 1; }
done
rm -f "${TARGET_HAND}/.pi/prompts/eversis-team-notes.md" "${TARGET_HAND}/.pi/prompts/legacy-notes.md"
HAND_PLAIN_LOG="${TMP}/consumer-pi-hand-port-plain.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_HAND" \
  --upgrade --sync --non-interactive \
  > "$HAND_PLAIN_LOG" 2>&1 \
  || { echo "FAIL: (h2) plain upgrade after deselect stopped (backup folder counted as a hand port?)"; cat "$HAND_PLAIN_LOG"; exit 1; }
grep -qF 'Legacy Pi generator found' "$HAND_PLAIN_LOG" \
  && { echo "FAIL: (h2) backup folder reported as a legacy Pi finding"; cat "$HAND_PLAIN_LOG"; exit 1; }
_assert_selection_agents "$TARGET_HAND" '["cursor"]' "(h2) plain upgrade after deselect"

# (i) linked worktree: docs/context/ is named after the main project; an
# explicit --project-name replaces it and the recorded projectContextPath.
WT_MAIN="${TMP}/Main_Proj"
mkdir -p "$WT_MAIN"
git -C "$WT_MAIN" init -q
git -C "$WT_MAIN" config user.email test@example.com
git -C "$WT_MAIN" config user.name test
echo "main" > "${WT_MAIN}/README.md"
git -C "$WT_MAIN" add README.md
git -C "$WT_MAIN" commit -q -m "init"
WT_TARGET="${TMP}/main-proj-pi-test"
git -C "$WT_MAIN" worktree add -q "$WT_TARGET" -b pi-test
WT_LOG="${TMP}/consumer-worktree.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$WT_TARGET" \
  --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$WT_LOG" 2>&1 \
  || { echo "FAIL: (i) linked worktree install failed"; cat "$WT_LOG"; exit 1; }
[[ -f "${WT_TARGET}/docs/context/main-proj/INDEX.md" ]] \
  || { echo "FAIL: (i) linked worktree did not use docs/context/main-proj/"; ls "${WT_TARGET}/docs/context"; exit 1; }
[[ -e "${WT_TARGET}/docs/context/main-proj-pi-test" ]] \
  && { echo "FAIL: (i) linked worktree created docs/context/<worktree-name>/"; exit 1; }
grep -qF "linked worktree 'main-proj-pi-test'" "$WT_LOG" \
  || { echo "FAIL: (i) missing linked worktree info line"; cat "$WT_LOG"; exit 1; }
WT_NAME_LOG="${TMP}/consumer-worktree-name.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$WT_TARGET" \
  --upgrade --sync --non-interactive \
  --project-name custom \
  > "$WT_NAME_LOG" 2>&1 \
  || { echo "FAIL: (i) --project-name custom upgrade failed"; cat "$WT_NAME_LOG"; exit 1; }
[[ -f "${WT_TARGET}/docs/context/custom/INDEX.md" ]] \
  || { echo "FAIL: (i) --project-name custom did not create docs/context/custom/"; exit 1; }
node -e '
  const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
  if (j.ssot.projectContextPath !== "docs/context/custom/") { console.error(j.ssot.projectContextPath); process.exit(1); }
' "${WT_TARGET}/.agent-collections/install-selection.json" \
  || { echo "FAIL: (i) recorded projectContextPath is not docs/context/custom/"; exit 1; }
# SSOT_PROJECT_SLUG is explicit too: kebab-cased, scaffolded and recorded.
SSOT_PROJECT_SLUG="Env_Name" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$WT_TARGET" \
  --upgrade --sync --non-interactive \
  > "${TMP}/consumer-worktree-env.log" 2>&1 \
  || { echo "FAIL: (i) SSOT_PROJECT_SLUG upgrade failed"; cat "${TMP}/consumer-worktree-env.log"; exit 1; }
[[ -f "${WT_TARGET}/docs/context/env-name/INDEX.md" ]] \
  || { echo "FAIL: (i) SSOT_PROJECT_SLUG=Env_Name did not create docs/context/env-name/"; exit 1; }
node -e '
  const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
  if (j.ssot.projectContextPath !== "docs/context/env-name/") { console.error(j.ssot.projectContextPath); process.exit(1); }
' "${WT_TARGET}/.agent-collections/install-selection.json" \
  || { echo "FAIL: (i) recorded projectContextPath is not docs/context/env-name/"; exit 1; }

# (j) legacy Pi generator files + sync:agents scripts → each named, exit 0.
# (k) default link mode → .pi/skills mirror is a copy; writes stay in .pi/.
TARGET_LEGACY="${TMP}/consumer-pi-legacy"
mkdir -p "${TARGET_LEGACY}/scripts"
(cd "$TARGET_LEGACY" && git init -q)
echo '// legacy' > "${TARGET_LEGACY}/scripts/gen-pi-adapter.mjs"
echo 'rules: []' > "${TARGET_LEGACY}/scripts/pi-rule-map.yaml"
cat > "${TARGET_LEGACY}/package.json" <<'PKG_EOF'
{
  "name": "consumer",
  "scripts": {
    "sync:agents": "node adapters/sync.mjs && node scripts/gen-pi-adapter.mjs",
    "sync:agents:pi": "node scripts/gen-pi-adapter.mjs",
    "sync:agents:pi:check": "node scripts/gen-pi-adapter.mjs --check",
    "pi:rules": "cat scripts/pi-rule-map.yaml",
    "build": "echo build"
  }
}
PKG_EOF
FRAMEWORK_SKILL_SUM="$(cksum < "${ROOT}/.ai/skills/eversis-fine-handoff/SKILL.md")"
LEGACY_LOG="${TMP}/consumer-pi-legacy.log"
PATH="$PI_NO_CLI_PATH" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_LEGACY" \
  --non-interactive \
  --agents=cursor,pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  > "$LEGACY_LOG" 2>&1 \
  || { echo "FAIL: (j) install with a legacy Pi generator failed"; cat "$LEGACY_LOG"; exit 1; }
for _finding in 'scripts/gen-pi-adapter.mjs' 'scripts/pi-rule-map.yaml' \
    'package.json script "sync:agents"' 'package.json script "sync:agents:pi"' \
    'package.json script "sync:agents:pi:check"' 'package.json script "pi:rules"'; do
  grep -qF -- "- ${_finding}" "$LEGACY_LOG" \
    || { echo "FAIL: (j) legacy report does not name ${_finding}"; cat "$LEGACY_LOG"; exit 1; }
done
grep -qF 'package.json script "build"' "$LEGACY_LOG" \
  && { echo "FAIL: (j) legacy report named an unrelated script"; exit 1; }
grep -qF 'Legacy Pi:' "$LEGACY_LOG" \
  || { echo "FAIL: (j) summary does not repeat the legacy Pi findings"; cat "$LEGACY_LOG"; exit 1; }
[[ -f "${TARGET_LEGACY}/scripts/gen-pi-adapter.mjs" ]] \
  || { echo "FAIL: (j) legacy report removed a consumer file"; exit 1; }
_assert_pi_tree "$TARGET_LEGACY" "(k) default link mode"
[[ -L "${TARGET_LEGACY}/.pi/skills/eversis-fine-handoff" ]] \
  && { echo "FAIL: (k) .pi/skills/eversis-fine-handoff is a symlink in default link mode"; exit 1; }
[[ -d "${TARGET_LEGACY}/.pi/skills/eversis-fine-handoff" ]] \
  || { echo "FAIL: (k) .pi/skills/eversis-fine-handoff is not a directory"; exit 1; }
if [[ "$(uname -s)" != MINGW* ]] && [[ "$(uname -s)" != CYGWIN* ]]; then
  [[ -L "${TARGET_LEGACY}/.cursor/skills/eversis-fine-handoff" ]] \
    || { echo "FAIL: (k) .cursor/skills link behaviour changed (expected a symlink)"; exit 1; }
  node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    if (j.linkMode !== "symlink") { console.error("linkMode=" + j.linkMode); process.exit(1); }
  ' "${TARGET_LEGACY}/.agent-collections/install-selection.json" \
    || { echo "FAIL: (k) recorded linkMode changed by the Pi copy mirror"; exit 1; }
fi
echo 'written by a legacy generator' >> "${TARGET_LEGACY}/.pi/skills/eversis-fine-handoff/SKILL.md"
[[ "$(cksum < "${ROOT}/.ai/skills/eversis-fine-handoff/SKILL.md")" == "$FRAMEWORK_SKILL_SUM" ]] \
  || { echo "FAIL: (k) write into .pi/skills/ changed the framework copy"; exit 1; }

# (k2) a symlinked .pi/skills/eversis-* entry from an older install becomes a
# real directory on upgrade; the framework directory it pointed at is untouched.
# The entry edited in (k) differs from .ai/skills/, so it is backed up first.
SYMLINK_SKILL="eversis-implementing-filters"
SYMLINK_SRC="${ROOT}/.ai/skills/${SYMLINK_SKILL}"
rm -rf "${TARGET_LEGACY}/.pi/skills/${SYMLINK_SKILL}"
ln -s "$SYMLINK_SRC" "${TARGET_LEGACY}/.pi/skills/${SYMLINK_SKILL}"
SYMLINK_SRC_SUM="$(_tree_checksum "$SYMLINK_SRC")"
SYMLINK_LOG="${TMP}/consumer-pi-legacy-symlink.log"
PATH="$PI_NO_CLI_PATH" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_LEGACY" \
  --upgrade --sync --non-interactive \
  > "$SYMLINK_LOG" 2>&1 \
  || { echo "FAIL: (k2) upgrade over a symlinked .pi/skills entry failed"; cat "$SYMLINK_LOG"; exit 1; }
[[ -L "${TARGET_LEGACY}/.pi/skills/${SYMLINK_SKILL}" ]] \
  && { echo "FAIL: (k2) symlinked .pi/skills/${SYMLINK_SKILL} was not converted"; exit 1; }
[[ -d "${TARGET_LEGACY}/.pi/skills/${SYMLINK_SKILL}" ]] \
  || { echo "FAIL: (k2) .pi/skills/${SYMLINK_SKILL} is not a directory after upgrade"; exit 1; }
[[ -d "$SYMLINK_SRC" ]] && [[ ! -L "$SYMLINK_SRC" ]] \
  || { echo "FAIL: (k2) the symlink target ${SYMLINK_SRC} is gone or replaced"; exit 1; }
[[ "$(_tree_checksum "$SYMLINK_SRC")" == "$SYMLINK_SRC_SUM" ]] \
  || { echo "FAIL: (k2) converting the symlink changed the framework skill"; exit 1; }
_assert_pi_tree "$TARGET_LEGACY" "(k2) symlinked mirror entry converted"
[[ -e "${TARGET_LEGACY}/.pi/pre-agent-collections-backup/skills/${SYMLINK_SKILL}" ]] \
  && { echo "FAIL: (k2) a symlinked mirror entry was backed up"; exit 1; }
grep -qF 'written by a legacy generator' \
  "${TARGET_LEGACY}/.pi/pre-agent-collections-backup/skills/eversis-fine-handoff/SKILL.md" 2>/dev/null \
  || { echo "FAIL: (k2) the edited .pi/skills/eversis-fine-handoff was not backed up"; cat "$SYMLINK_LOG"; exit 1; }

if [[ "$ELAPSED" -gt 300 ]]; then
  echo "WARN: smoke exceeded 5 minutes (${ELAPSED}s)"
else
  echo "[smoke] under 5 minutes OK"
fi

echo "[smoke] PASS"
