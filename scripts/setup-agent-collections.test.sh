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

# --doctor on a healthy local-mode Cursor install: the framework home comes
# from the recorded vendor mode (local → framework-home.txt), Claude checks
# are skipped, exit 0.
LOCAL_DOCTOR_LOG="${TMP}/consumer-doctor-local.log"
bash "${ROOT}/scripts/setup-agent-collections.sh" --doctor --target "$TARGET" > "$LOCAL_DOCTOR_LOG" 2>&1 \
  || { echo "FAIL: --doctor on a healthy local-mode install should exit 0"; cat "$LOCAL_DOCTOR_LOG"; exit 1; }
grep -qF "Framework home: ${EXPECTED_HOME} (recorded vendor mode local" "$LOCAL_DOCTOR_LOG" \
  || { echo "FAIL: --doctor did not resolve the local-mode framework home from framework-home.txt"; cat "$LOCAL_DOCTOR_LOG"; exit 1; }
grep -qF 'Cursor skills mirror: Verified' "$LOCAL_DOCTOR_LOG" \
  || { echo "FAIL: --doctor did not verify the Cursor skills mirror"; cat "$LOCAL_DOCTOR_LOG"; exit 1; }
grep -qF 'Claude hook entry: claude not selected' "$LOCAL_DOCTOR_LOG" \
  || { echo "FAIL: --doctor should skip the Claude hook checks for a Cursor-only install"; cat "$LOCAL_DOCTOR_LOG"; exit 1; }

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

# Role subagents, the spec artifact hook launcher and its settings entry.
for agent in eversis-context-engineer eversis-architect eversis-code-reviewer; do
  grep -qF 'GENERATED by adapters/claude/generate-agents.mjs' "${TARGET_CLAUDE}/.claude/agents/${agent}.md" \
    || { echo "FAIL: missing generated .claude/agents/${agent}.md"; exit 1; }
done
grep -qF 'vendor/agent-collections/.ai/prompts/internal/eversis-plan.md' "${TARGET_CLAUDE}/.claude/agents/eversis-architect.md" \
  || { echo "FAIL: .claude/agents/eversis-architect.md read path is not vendor-prefixed"; exit 1; }
HOOK_LAUNCHER="${TARGET_CLAUDE}/.claude/hooks/eversis-validate-spec.cjs"
grep -qF 'var FRAMEWORK_PREFIX = "vendor/agent-collections";' "$HOOK_LAUNCHER" \
  || { echo "FAIL: hook launcher missing or not generated with the vendor prefix"; exit 1; }
CLAUDE_PROJECT_DIR="$TARGET_CLAUDE" node "$HOOK_LAUNCHER" --self-test | grep -qxF 'eversis-validate-spec self-test: ok' \
  || { echo "FAIL: hook launcher --self-test did not pass in the vendored install"; exit 1; }
_framework_hook_count() {
  node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    const post = (j.hooks && j.hooks.PostToolUse) || [];
    console.log(post.filter((e) => (e.hooks || []).some((h) => h.command === process.argv[2])).length);
  ' "${TARGET_CLAUDE}/.claude/settings.json" 'node "${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs"'
}
[[ "$(_framework_hook_count)" == "1" ]] \
  || { echo "FAIL: .claude/settings.json should hold exactly one framework PostToolUse entry (got $(_framework_hook_count))"; exit 1; }

# Consumer-owned agent and hook entry that a Claude deselect must keep.
printf -- '---\nname: my-agent\ndescription: consumer agent\n---\nHand-made.\n' > "${TARGET_CLAUDE}/.claude/agents/my-agent.md"
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks.PostToolUse.push({ matcher: "Bash", hooks: [{ type: "command", command: "echo consumer-hook" }] });
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "${TARGET_CLAUDE}/.claude/settings.json"

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
shopt -s nullglob
LEFTOVER_AGENTS=("${TARGET_CLAUDE}/.claude/agents/"eversis-*.md)
LEFTOVER_HOOKS=("${TARGET_CLAUDE}/.claude/hooks/"eversis-*.cjs)
shopt -u nullglob
[[ ${#LEFTOVER_AGENTS[@]} -eq 0 ]] \
  || { echo "FAIL: .claude/agents/eversis-*.md survived deselecting Claude: ${LEFTOVER_AGENTS[*]}"; exit 1; }
[[ ${#LEFTOVER_HOOKS[@]} -eq 0 ]] \
  || { echo "FAIL: .claude/hooks/eversis-*.cjs survived deselecting Claude: ${LEFTOVER_HOOKS[*]}"; exit 1; }
[[ -f "${TARGET_CLAUDE}/.claude/agents/my-agent.md" ]] \
  || { echo "FAIL: hand-made .claude/agents/my-agent.md removed on Claude deselect"; exit 1; }
[[ "$(_framework_hook_count)" == "0" ]] \
  || { echo "FAIL: framework PostToolUse entry survived deselecting Claude"; exit 1; }
grep -qF 'echo consumer-hook' "${TARGET_CLAUDE}/.claude/settings.json" \
  || { echo "FAIL: consumer PostToolUse hook removed on Claude deselect"; exit 1; }
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

# Prints only the "Legacy Pi:" block of the end-of-run summary in log $1. The
# start-of-run warning ("Legacy Pi generator found") prints its own marker
# count into the same log, so summary assertions must not read the whole log.
_legacy_summary_block() {
  sed -n '/Legacy Pi:/,/Next steps:/p' "$1"
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
# The printed installer path depends on AGENT_COLLECTIONS_HOME, so the
# developer's shell value is removed here and set explicitly below.
env -u AGENT_COLLECTIONS_HOME bash "${ROOT}/scripts/setup-agent-collections.sh" \
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
# Installer outside the project, no AGENT_COLLECTIONS_HOME: both commands use
# the quoted absolute path of the running script.
for _cmd_agents in 'cursor,pi' 'cursor'; do
  grep -qxF "      bash \"${ROOT}/scripts/setup-agent-collections.sh\" --upgrade --sync --agents ${_cmd_agents}" "$HAND_STOP_LOG" \
    || { echo "FAIL: (h) stop command for --agents ${_cmd_agents} does not use the quoted absolute installer path"; cat "$HAND_STOP_LOG"; exit 1; }
done
# Same stop with AGENT_COLLECTIONS_HOME naming this framework: the commands
# use "$AGENT_COLLECTIONS_HOME/…", for the person's shell to expand.
HAND_STOP_ENV_LOG="${TMP}/consumer-pi-hand-port-stop-env.log"
_rc=0
AGENT_COLLECTIONS_HOME="$ROOT" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_HAND" \
  --upgrade --sync --non-interactive \
  > "$HAND_STOP_ENV_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 1 ]] || { echo "FAIL: (h) stop with AGENT_COLLECTIONS_HOME exited ${_rc}, expected 1"; cat "$HAND_STOP_ENV_LOG"; exit 1; }
for _cmd_agents in 'cursor,pi' 'cursor'; do
  # shellcheck disable=SC2016
  grep -qxF "      bash \"\$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh\" --upgrade --sync --agents ${_cmd_agents}" "$HAND_STOP_ENV_LOG" \
    || { echo "FAIL: (h) stop command for --agents ${_cmd_agents} does not use \"\$AGENT_COLLECTIONS_HOME/…\""; cat "$HAND_STOP_ENV_LOG"; exit 1; }
done
[[ "$(_tree_checksum "$TARGET_HAND")" == "$HAND_BEFORE" ]] \
  || { echo "FAIL: (h) stopped upgrade with AGENT_COLLECTIONS_HOME changed files under the target"; exit 1; }
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
# The summary recounts after the Pi stage: the 3 legacy-marked files of the
# fixture were migrated, so it says so instead of the start-of-run count, and
# the run reaches its final line (a zero recount must not stop it).
_hand_summary="$(_legacy_summary_block "$HAND_MIGRATE_LOG")"
grep -qF -- '- 3 legacy-marked .pi/ file(s) were migrated (the old copies are in *.pre-agent-collections*.bak files and .pi/pre-agent-collections-backup/)' <<< "$_hand_summary" \
  || { echo "FAIL: (h) summary does not say the legacy-marked files were migrated"; cat "$HAND_MIGRATE_LOG"; exit 1; }
grep -qF 'still carry' <<< "$_hand_summary" \
  && { echo "FAIL: (h) summary still reports the start-of-run legacy marker count"; cat "$HAND_MIGRATE_LOG"; exit 1; }
grep -qF 'remove the old Pi generator' <<< "$_hand_summary" \
  && { echo "FAIL: (h) summary tells to remove an old generator after a migration"; cat "$HAND_MIGRATE_LOG"; exit 1; }
grep -qF 'Done.' "$HAND_MIGRATE_LOG" \
  || { echo "FAIL: (h) migration run did not reach its final Done. line"; cat "$HAND_MIGRATE_LOG"; exit 1; }

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
# Two legacy-marked files at the start (the reviewer skill and legacy-notes.md);
# the deselect removed the skill, so the summary shows the current count 1 and
# never says "migrated".
_hand_summary="$(_legacy_summary_block "$HAND_DESELECT_LOG")"
grep -qF -- "- 1 .pi/ file(s) still carry the legacy marker" <<< "$_hand_summary" \
  || { echo "FAIL: (h2) summary does not show the current legacy marker count 1"; cat "$HAND_DESELECT_LOG"; exit 1; }
grep -qF -- "- 2 .pi/ file(s)" <<< "$_hand_summary" \
  && { echo "FAIL: (h2) summary shows the start-of-run legacy marker count"; cat "$HAND_DESELECT_LOG"; exit 1; }
grep -qF 'migrated' <<< "$_hand_summary" \
  && { echo "FAIL: (h2) summary says migrated after a Pi deselect"; cat "$HAND_DESELECT_LOG"; exit 1; }
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

# (h4) explicit Pi deselect that removes every legacy-marked .pi/ file: a Pi
# install gets two legacy-marked skill entries (a folder and a regular file
# under a mirror name), and --agents cursor backs them up and removes them.
# The count goes from 2 at the start to 0, so the summary has no marker line
# and never says "migrated"; with no other legacy finding there is no
# "Legacy Pi:" block at all.
TARGET_DESEL_ZERO="${TMP}/consumer-pi-deselect-zero"
mkdir -p "$TARGET_DESEL_ZERO"
(cd "$TARGET_DESEL_ZERO" && git init -q)
env -u AGENT_COLLECTIONS_HOME bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_DESEL_ZERO" \
  --non-interactive \
  --agents=cursor,pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "${TMP}/consumer-pi-deselect-zero-install.log" 2>&1 \
  || { echo "FAIL: (h4) --agents=cursor,pi install failed"; cat "${TMP}/consumer-pi-deselect-zero-install.log"; exit 1; }
mkdir -p "${TARGET_DESEL_ZERO}/.pi/skills/eversis-code-reviewer"
printf -- '---\nname: eversis-code-reviewer\n---\n%s\nlegacy reviewer\n' "$LEGACY_PI_MARKER_LINE" \
  > "${TARGET_DESEL_ZERO}/.pi/skills/eversis-code-reviewer/SKILL.md"
printf '%s\nlegacy notes file\n' "$LEGACY_PI_MARKER_LINE" > "${TARGET_DESEL_ZERO}/.pi/skills/eversis-notes.md"
DESEL_ZERO_LOG="${TMP}/consumer-pi-deselect-zero.log"
_rc=0
env -u AGENT_COLLECTIONS_HOME bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_DESEL_ZERO" \
  --upgrade --sync --non-interactive \
  --agents cursor \
  > "$DESEL_ZERO_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 0 ]] || { echo "FAIL: (h4) explicit Pi deselect exited ${_rc}, expected 0"; cat "$DESEL_ZERO_LOG"; exit 1; }
grep -qF 'Done.' "$DESEL_ZERO_LOG" \
  || { echo "FAIL: (h4) deselect run did not reach its final Done. line"; cat "$DESEL_ZERO_LOG"; exit 1; }
# Start count > 0: the start-of-run warning reports both marked entries.
grep -qF -- '- 2 .pi/ file(s) still carry the legacy marker' "$DESEL_ZERO_LOG" \
  || { echo "FAIL: (h4) start-of-run warning does not report the 2 legacy-marked files"; cat "$DESEL_ZERO_LOG"; exit 1; }
# End count 0: no legacy-marked file is left under .pi/.
_left_legacy="$(TARGET_DIR="$TARGET_DESEL_ZERO" bash -c 'source "$1/common.sh"; source "$1/legacy-pi.sh"; _legacy_pi_marked_files' _ "${ROOT}/scripts/lib/setup-agent-collections")"
[[ -z "$_left_legacy" ]] \
  || { echo "FAIL: (h4) legacy-marked files after the deselect: ${_left_legacy}"; exit 1; }
_desel_summary="$(_legacy_summary_block "$DESEL_ZERO_LOG")"
grep -qF 'still carry' <<< "$_desel_summary" \
  && { echo "FAIL: (h4) summary shows a legacy marker line after the deselect removed every marked file"; cat "$DESEL_ZERO_LOG"; exit 1; }
grep -qF 'migrated' <<< "$_desel_summary" \
  && { echo "FAIL: (h4) summary says migrated after a Pi deselect"; cat "$DESEL_ZERO_LOG"; exit 1; }
[[ -z "$_desel_summary" ]] \
  || { echo "FAIL: (h4) summary has a Legacy Pi: block with no legacy finding left"; cat "$DESEL_ZERO_LOG"; exit 1; }
_assert_selection_agents "$TARGET_DESEL_ZERO" '["cursor"]' "(h4) Pi deselect"

# (h3) vendored install, hand-ported .pi/, upgrade run from the project root
# with the vendored installer and no --target. The stop commands use the
# project-relative installer path, which works from the project root (the
# target comes from git rev-parse, a resolved path, while the script folder is
# not resolved: macOS /var vs /private/var). "Found" lists the skill entry
# first, once, although 5 other findings sort before .pi/skills/.
TARGET_VEND_HAND="${TMP}/consumer-pi-hand-port-vendored"
mkdir -p "$TARGET_VEND_HAND"
(cd "$TARGET_VEND_HAND" && git init -q)
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_VEND_HAND" \
  --non-interactive \
  --vendor=copy \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "${TMP}/consumer-pi-hand-port-vendored-install.log" 2>&1 \
  || { echo "FAIL: (h3) vendored cursor install failed"; cat "${TMP}/consumer-pi-hand-port-vendored-install.log"; exit 1; }
mkdir -p "${TARGET_VEND_HAND}/.pi/extensions" "${TARGET_VEND_HAND}/.pi/prompts" \
  "${TARGET_VEND_HAND}/.pi/skills/eversis-hand-notes"
for _f in APPEND_SYSTEM.md extensions/legacy-a.ts extensions/legacy-b.ts \
    prompts/eversis-implement.md prompts/eversis-review.md skills/eversis-hand-notes/SKILL.md; do
  printf '%s\nhand-ported file\n' "$LEGACY_PI_MARKER_LINE" > "${TARGET_VEND_HAND}/.pi/${_f}"
done
VEND_HAND_BEFORE="$(_tree_checksum "$TARGET_VEND_HAND")"
VEND_HAND_STOP_LOG="${TMP}/consumer-pi-hand-port-vendored-stop.log"
_rc=0
(cd "$TARGET_VEND_HAND" && env -u AGENT_COLLECTIONS_HOME \
  bash vendor/agent-collections/scripts/setup-agent-collections.sh --upgrade --sync --non-interactive) \
  > "$VEND_HAND_STOP_LOG" 2>&1 || _rc=$?
[[ "$_rc" -eq 1 ]] || { echo "FAIL: (h3) vendored hand-port upgrade exited ${_rc}, expected 1"; cat "$VEND_HAND_STOP_LOG"; exit 1; }
[[ "$(_tree_checksum "$TARGET_VEND_HAND")" == "$VEND_HAND_BEFORE" ]] \
  || { echo "FAIL: (h3) stopped vendored upgrade changed files under the target"; cat "$VEND_HAND_STOP_LOG"; exit 1; }
for _cmd_agents in 'cursor,pi' 'cursor'; do
  grep -qxF "      bash vendor/agent-collections/scripts/setup-agent-collections.sh --upgrade --sync --agents ${_cmd_agents}" "$VEND_HAND_STOP_LOG" \
    || { echo "FAIL: (h3) stop command for --agents ${_cmd_agents} does not use the project-relative installer path"; cat "$VEND_HAND_STOP_LOG"; exit 1; }
done
_vend_cmd_path="$(sed -n 's/^      bash \([^ ]*\) --upgrade --sync --agents cursor,pi$/\1/p' "$VEND_HAND_STOP_LOG" | head -n 1)"
(cd "$TARGET_VEND_HAND" && [[ -n "$_vend_cmd_path" && -f "$_vend_cmd_path" ]]) \
  || { echo "FAIL: (h3) printed installer path '${_vend_cmd_path}' is not a file from the project root"; exit 1; }
_vend_found="$(sed -n '/^  Found:/,/An upgrade without --agents/p' "$VEND_HAND_STOP_LOG" | sed -n '2,6p')"
grep -qxF '    .pi/skills/eversis-hand-notes' <<< "$_vend_found" \
  || { echo "FAIL: (h3) skill entry is not in the first 5 Found lines"; cat "$VEND_HAND_STOP_LOG"; exit 1; }
[[ "$(grep -c 'eversis-hand-notes' "$VEND_HAND_STOP_LOG" || true)" == "1" ]] \
  || { echo "FAIL: (h3) skill entry is not listed exactly once in the stop message"; cat "$VEND_HAND_STOP_LOG"; exit 1; }
grep -qxF '    … and 1 more' "$VEND_HAND_STOP_LOG" \
  || { echo "FAIL: (h3) Found list lost its '… and N more' line"; cat "$VEND_HAND_STOP_LOG"; exit 1; }

# ---------------------------------------------------------------------------
# Pi skills manifest (.agent-collections/pi-skills-mirror.json): the installer
# records a content hash per .pi/skills/ entry it copied, so its own outdated
# copy is replaced or removed without a backup, while a hand-edited copy is
# still backed up.
# ---------------------------------------------------------------------------
PI_MANIFEST_HELPER="${ROOT}/scripts/lib/setup-agent-collections/pi-skills-manifest.mjs"

# (p0) helper properties, called directly.
PM_DIR="${TMP}/pi-manifest-props"
mkdir -p "${PM_DIR}/skills/tree/sub" "${PM_DIR}/skills/empty-dir"
printf 'skill body\n' > "${PM_DIR}/skills/tree/SKILL.md"
printf 'hidden\n' > "${PM_DIR}/skills/tree/.hidden"
printf 'nested\n' > "${PM_DIR}/skills/tree/sub/a.txt"
printf 'outside one\n' > "${PM_DIR}/outside-one.txt"
printf 'outside two\n' > "${PM_DIR}/outside-two.txt"
ln -s ../../outside-one.txt "${PM_DIR}/skills/tree/link"
: > "${PM_DIR}/empty-file"
PM_MANIFEST="${PM_DIR}/state/manifest.json"
# Runs `match` for $1 against $2; asserts exit code $3 and empty stdout.
_pm_match() {
  local name="$1" entry="$2" want="$3" label="$4" out rc=0
  out="$(node "$PI_MANIFEST_HELPER" match "${5:-$PM_MANIFEST}" "$name" "$entry")" || rc=$?
  [[ "$rc" -eq "$want" ]] || { echo "FAIL: (p0) ${label}: match exited ${rc}, expected ${want}"; exit 1; }
  [[ -z "$out" ]] || { echo "FAIL: (p0) ${label}: match printed to stdout: ${out}"; exit 1; }
}
node "$PI_MANIFEST_HELPER" write "$PM_MANIFEST" "${PM_DIR}/skills" tree empty-dir \
  || { echo "FAIL: (p0) write failed (parent folder missing?)"; exit 1; }
_pm_match tree "${PM_DIR}/skills/tree" 0 "unchanged tree"
chmod 600 "${PM_DIR}/skills/tree/SKILL.md"
touch -t 200001010000 "${PM_DIR}/skills/tree/SKILL.md" "${PM_DIR}/skills/tree/sub"
_pm_match tree "${PM_DIR}/skills/tree" 0 "mode and mtime ignored"
printf 'hidden edit\n' > "${PM_DIR}/skills/tree/.hidden"
_pm_match tree "${PM_DIR}/skills/tree" 1 "dotfile change"
printf 'hidden\n' > "${PM_DIR}/skills/tree/.hidden"
_pm_match tree "${PM_DIR}/skills/tree" 0 "dotfile restored"
printf 'outside one, edited\n' > "${PM_DIR}/outside-one.txt"
_pm_match tree "${PM_DIR}/skills/tree" 0 "symlink target content not followed"
ln -sfn ../../outside-two.txt "${PM_DIR}/skills/tree/link"
_pm_match tree "${PM_DIR}/skills/tree" 1 "symlink text change"
ln -sfn ../../outside-one.txt "${PM_DIR}/skills/tree/link"
_pm_match tree "${PM_DIR}/skills/tree" 0 "symlink text restored"
_pm_match empty-dir "${PM_DIR}/empty-file" 1 "file against a directory hash"
_pm_match empty-dir "${PM_DIR}/skills/empty-dir" 0 "empty directory"
_pm_match not-recorded "${PM_DIR}/skills/tree" 1 "name not in the manifest"
_pm_match tree "${PM_DIR}/skills/missing" 1 "entry path missing"
_pm_match tree "${PM_DIR}/skills/tree" 1 "manifest missing" "${PM_DIR}/no-such-manifest.json"
sed 's/"version": 1/"version": 2/' "$PM_MANIFEST" > "${PM_DIR}/v2.json"
_pm_match tree "${PM_DIR}/skills/tree" 1 "version 2" "${PM_DIR}/v2.json"
echo '{not-json' > "${PM_DIR}/bad.json"
_pm_match tree "${PM_DIR}/skills/tree" 1 "invalid JSON" "${PM_DIR}/bad.json"
# An entry type other than file, directory or symlink fails closed: no match,
# and `write` leaves the name out.
mkdir -p "${PM_DIR}/skills/with-fifo"
mkfifo "${PM_DIR}/skills/with-fifo/pipe"
node "$PI_MANIFEST_HELPER" write "${PM_DIR}/fifo.json" "${PM_DIR}/skills" with-fifo tree \
  || { echo "FAIL: (p0) write with a fifo entry failed"; exit 1; }
grep -qF '"with-fifo"' "${PM_DIR}/fifo.json" && { echo "FAIL: (p0) write recorded an entry holding a fifo"; exit 1; }
grep -qF '"tree"' "${PM_DIR}/fifo.json" || { echo "FAIL: (p0) write dropped a valid entry next to a fifo entry"; exit 1; }
_pm_match with-fifo "${PM_DIR}/skills/with-fifo" 1 "fifo inside a tree" "${PM_DIR}/fifo.json"
# Byte-stable output: name order and duplicates do not change the file.
node "$PI_MANIFEST_HELPER" write "${PM_DIR}/fwd.json" "${PM_DIR}/skills" empty-dir tree
node "$PI_MANIFEST_HELPER" write "${PM_DIR}/rev.json" "${PM_DIR}/skills" tree empty-dir
node "$PI_MANIFEST_HELPER" write "${PM_DIR}/dup.json" "${PM_DIR}/skills" tree empty-dir tree
cmp -s "${PM_DIR}/fwd.json" "${PM_DIR}/rev.json" && cmp -s "${PM_DIR}/fwd.json" "${PM_DIR}/dup.json" \
  || { echo "FAIL: (p0) manifest bytes depend on name order or duplicates"; diff "${PM_DIR}/fwd.json" "${PM_DIR}/dup.json" || true; exit 1; }
[[ "$(tail -c 1 "${PM_DIR}/fwd.json" | od -An -c | tr -d ' ')" == '\n' ]] \
  || { echo "FAIL: (p0) manifest does not end with a newline"; exit 1; }
node "$PI_MANIFEST_HELPER" write "${PM_DIR}/zero.json" "${PM_DIR}/skills" \
  || { echo "FAIL: (p0) write with zero names failed"; exit 1; }
node -e '
  const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
  if (j.version !== 1 || JSON.stringify(j.skills) !== "{}") process.exit(1);
' "${PM_DIR}/zero.json" || { echo "FAIL: (p0) zero names did not write an empty skills object"; exit 1; }

# Names of the framework skills (.ai/skills/eversis-* folders), one per line.
_framework_skill_names() {
  local src
  for src in "${ROOT}/.ai/skills"/eversis-*; do
    [[ -d "$src" ]] && basename "$src"
  done
  return 0
}
# Asserts the manifest under target $1 is version 1 and its keys are exactly
# the framework skill names.
_assert_pi_manifest_keys() {
  local target="$1" label="$2"
  node -e '
    const fs = require("fs");
    const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const want = fs.readFileSync(0, "utf8").split("\n").filter(Boolean).sort();
    const got = Object.keys(j.skills || {}).sort();
    if (j.version !== 1 || JSON.stringify(got) !== JSON.stringify(want)) {
      console.error("keys=" + JSON.stringify(got));
      process.exit(1);
    }
    if (!Object.values(j.skills).every((v) => /^sha256:[0-9a-f]{64}$/.test(v))) process.exit(1);
  ' "${target}/.agent-collections/pi-skills-mirror.json" <<< "$(_framework_skill_names)" \
    || { echo "FAIL: ${label}: .agent-collections/pi-skills-mirror.json keys are not exactly the framework skills"; exit 1; }
}
# Records the current .pi/skills/ content of every framework skill name plus
# any extra names in $2… in the manifest of target $1, as if the installer had
# copied them.
_record_pi_manifest() {
  local target="$1"
  shift
  # shellcheck disable=SC2046
  node "$PI_MANIFEST_HELPER" write "${target}/.agent-collections/pi-skills-mirror.json" \
    "${target}/.pi/skills" $(_framework_skill_names) "$@" \
    || { echo "FAIL: could not record the Pi skills manifest fixture"; exit 1; }
}
# Runs `--upgrade --sync` on target $1 with log $2 and any extra args.
_pm_upgrade() {
  local target="$1" log="$2"
  shift 2
  bash "${ROOT}/scripts/setup-agent-collections.sh" \
    --collections-home "$ROOT" \
    --target "$target" \
    --upgrade --sync --non-interactive "$@" \
    > "$log" 2>&1 \
    || { echo "FAIL: upgrade of ${target} failed"; cat "$log"; exit 1; }
}

TARGET_MAN="${TMP}/consumer-pi-manifest"
mkdir -p "$TARGET_MAN"
(cd "$TARGET_MAN" && git init -q)
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_MAN" \
  --non-interactive \
  --agents=cursor,pi \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "${TMP}/consumer-pi-manifest-install.log" 2>&1 \
  || { echo "FAIL: (p1) --agents=cursor,pi install failed"; cat "${TMP}/consumer-pi-manifest-install.log"; exit 1; }
MAN_FILE="${TARGET_MAN}/.agent-collections/pi-skills-mirror.json"
MAN_BACKUP="${TARGET_MAN}/.pi/pre-agent-collections-backup/skills"
MAN_OUTDATED="eversis-fine-handoff"
MAN_EDITED="eversis-task-analysing"
MAN_RETIRED="eversis-retired-example"
[[ -d "${ROOT}/.ai/skills/${MAN_OUTDATED}" && -d "${ROOT}/.ai/skills/${MAN_EDITED}" ]] \
  || { echo "FAIL: (p) fixture skills ${MAN_OUTDATED} / ${MAN_EDITED} are not in .ai/skills/"; exit 1; }
[[ -e "${ROOT}/.ai/skills/${MAN_RETIRED}" ]] \
  && { echo "FAIL: (p) fixture assumes .ai/skills/${MAN_RETIRED} does not exist"; exit 1; }

# (p1) a Pi install writes the manifest with every framework skill name.
_assert_pi_manifest_keys "$TARGET_MAN" "(p1) Pi install"
_pm_match "$MAN_OUTDATED" "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}" 0 "installed copy matches its record" "$MAN_FILE"

# (p2) outdated framework copy (recorded) → replaced, no backup, no warning.
# (p3) recorded copy whose name left .ai/skills/ → stale-pruned, no backup.
# (p4) copy edited after it was recorded → backed up (differs).
echo 'line from an older framework release' >> "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}/SKILL.md"
cp -R "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}" "${TARGET_MAN}/.pi/skills/${MAN_RETIRED}"
_record_pi_manifest "$TARGET_MAN" "$MAN_RETIRED"
echo 'hand edit after the install' >> "${TARGET_MAN}/.pi/skills/${MAN_EDITED}/SKILL.md"
MAN_LOG="${TMP}/consumer-pi-manifest-upgrade.log"
_pm_upgrade "$TARGET_MAN" "$MAN_LOG"
cmp -s "${ROOT}/.ai/skills/${MAN_OUTDATED}/SKILL.md" "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}/SKILL.md" \
  || { echo "FAIL: (p2) outdated copy was not replaced by the framework skill"; exit 1; }
grep -qF "Backed up .pi/skills/${MAN_OUTDATED} " "$MAN_LOG" \
  && { echo "FAIL: (p2) recorded outdated copy was backed up"; cat "$MAN_LOG"; exit 1; }
ls "$MAN_BACKUP"/"${MAN_OUTDATED}"* >/dev/null 2>&1 \
  && { echo "FAIL: (p2) backup folder holds the recorded outdated copy"; exit 1; }
[[ -e "${TARGET_MAN}/.pi/skills/${MAN_RETIRED}" ]] \
  && { echo "FAIL: (p3) recorded stale entry stayed in .pi/skills/"; exit 1; }
grep -qF "Backed up .pi/skills/${MAN_RETIRED} " "$MAN_LOG" \
  && { echo "FAIL: (p3) recorded stale entry was backed up"; cat "$MAN_LOG"; exit 1; }
ls "$MAN_BACKUP"/"${MAN_RETIRED}"* >/dev/null 2>&1 \
  && { echo "FAIL: (p3) backup folder holds the recorded stale entry"; exit 1; }
grep -qF "Backed up .pi/skills/${MAN_EDITED} to .pi/pre-agent-collections-backup/skills/${MAN_EDITED} (differs from the framework skill)" "$MAN_LOG" \
  || { echo "FAIL: (p4) hand-edited copy backup not logged"; cat "$MAN_LOG"; exit 1; }
grep -qF 'hand edit after the install' "${MAN_BACKUP}/${MAN_EDITED}/SKILL.md" 2>/dev/null \
  || { echo "FAIL: (p4) hand-edited copy was not backed up"; exit 1; }
_assert_pi_manifest_keys "$TARGET_MAN" "(p2) upgrade rewrites the manifest"
_assert_pi_tree "$TARGET_MAN" "(p2) upgrade"

# (p5) no manifest → today's behaviour once (backup), then a manifest.
rm -f "$MAN_FILE"
echo 'edit without a manifest' >> "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}/SKILL.md"
MAN_NONE_LOG="${TMP}/consumer-pi-manifest-none.log"
_pm_upgrade "$TARGET_MAN" "$MAN_NONE_LOG"
[[ "$(grep -c 'Backed up .pi/skills/' "$MAN_NONE_LOG" || true)" == "1" ]] \
  || { echo "FAIL: (p5) expected exactly one skill backup without a manifest"; cat "$MAN_NONE_LOG"; exit 1; }
grep -qF "Backed up .pi/skills/${MAN_OUTDATED} " "$MAN_NONE_LOG" \
  || { echo "FAIL: (p5) copy without a manifest was not backed up"; cat "$MAN_NONE_LOG"; exit 1; }
grep -rqF 'edit without a manifest' "$MAN_BACKUP" \
  || { echo "FAIL: (p5) backup without a manifest does not hold the edited copy"; exit 1; }
_assert_pi_manifest_keys "$TARGET_MAN" "(p5) upgrade without a manifest"

# (p6) invalid manifest counts as absent: backup, then a valid manifest.
echo '{not-json' > "$MAN_FILE"
echo 'edit with an invalid manifest' >> "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}/SKILL.md"
MAN_BAD_LOG="${TMP}/consumer-pi-manifest-invalid.log"
_pm_upgrade "$TARGET_MAN" "$MAN_BAD_LOG"
grep -qF "Backed up .pi/skills/${MAN_OUTDATED} " "$MAN_BAD_LOG" \
  || { echo "FAIL: (p6) copy with an invalid manifest was not backed up"; cat "$MAN_BAD_LOG"; exit 1; }
grep -rqF 'edit with an invalid manifest' "$MAN_BACKUP" \
  || { echo "FAIL: (p6) backup with an invalid manifest does not hold the edited copy"; exit 1; }
_assert_pi_manifest_keys "$TARGET_MAN" "(p6) upgrade with an invalid manifest"

# (p7) a names value from the caller's environment never reaches the manifest:
# both names survive the run (a non-eversis entry and a generated role skill).
mkdir -p "${TARGET_MAN}/.pi/skills/my-notes"
echo 'team notes' > "${TARGET_MAN}/.pi/skills/my-notes/SKILL.md"
MAN_ROLE="$(basename "$(find "${TARGET_MAN}/.pi/skills" -mindepth 1 -maxdepth 1 -name 'eversis-rule-*' | LC_ALL=C sort | head -n 1)")"
[[ -n "$MAN_ROLE" && -d "${TARGET_MAN}/.pi/skills/${MAN_ROLE}" ]] \
  || { echo "FAIL: (p7) no generated eversis-rule-* skill to use as a fixture"; exit 1; }
MAN_ENV_LOG="${TMP}/consumer-pi-manifest-env.log"
PI_MIRROR_COPIED_NAMES="my-notes ${MAN_ROLE}" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_MAN" \
  --upgrade --sync --non-interactive \
  > "$MAN_ENV_LOG" 2>&1 \
  || { echo "FAIL: (p7) upgrade with pre-set names failed"; cat "$MAN_ENV_LOG"; exit 1; }
_assert_pi_manifest_keys "$TARGET_MAN" "(p7) pre-set names in the environment"
rm -rf "${TARGET_MAN}/.pi/skills/my-notes"

# (p8) deselect: a recorded outdated copy is removed with no backup, and the
# manifest is removed.
echo 'line from an older framework release' >> "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}/SKILL.md"
_record_pi_manifest "$TARGET_MAN"
MAN_BACKUPS_BEFORE="$(ls "$MAN_BACKUP" | LC_ALL=C sort)"
MAN_DESELECT_LOG="${TMP}/consumer-pi-manifest-deselect.log"
_pm_upgrade "$TARGET_MAN" "$MAN_DESELECT_LOG" --agents cursor
[[ -e "$MAN_FILE" ]] && { echo "FAIL: (p8) Pi deselect left .agent-collections/pi-skills-mirror.json"; exit 1; }
[[ -e "${TARGET_MAN}/.pi/skills/${MAN_OUTDATED}" ]] \
  && { echo "FAIL: (p8) Pi deselect left .pi/skills/${MAN_OUTDATED}"; exit 1; }
grep -qF 'Backed up .pi/skills/' "$MAN_DESELECT_LOG" \
  && { echo "FAIL: (p8) Pi deselect backed up a recorded copy"; cat "$MAN_DESELECT_LOG"; exit 1; }
[[ "$(ls "$MAN_BACKUP" | LC_ALL=C sort)" == "$MAN_BACKUPS_BEFORE" ]] \
  || { echo "FAIL: (p8) Pi deselect added a skill backup"; exit 1; }

# (p9) deselect with .pi/ already gone still removes the manifest.
_pm_upgrade "$TARGET_MAN" "${TMP}/consumer-pi-manifest-reselect.log" --agents cursor,pi
[[ -f "$MAN_FILE" ]] || { echo "FAIL: (p9) Pi re-select did not write the manifest"; exit 1; }
rm -rf "${TARGET_MAN}/.pi"
_pm_upgrade "$TARGET_MAN" "${TMP}/consumer-pi-manifest-nopi.log" --agents cursor
[[ -e "$MAN_FILE" ]] && { echo "FAIL: (p9) Pi deselect without .pi/ left .agent-collections/pi-skills-mirror.json"; exit 1; }

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

# ---------------------------------------------------------------------------
# Node version gate and skills mirror fallback. Faults are injected with stub
# executables first on PATH (node, ln, cp); production code has no test switch.
# ---------------------------------------------------------------------------
REAL_NODE="$(command -v node)"

# Writes a stub `node` into $1 that answers the version query with $2. Every
# other call either runs the real node ($3 = delegate) or fails the way Node 12
# fails on the framework scripts ($3 = syntax-error).
_write_node_stub() {
  local dir="$1" version="$2" other="$3"
  mkdir -p "$dir"
  {
    echo '#!/bin/sh'
    echo 'if [ "$1" = "-p" ] && [ "$2" = "process.versions.node" ]; then'
    echo "  echo ${version}"
    echo '  exit 0'
    echo 'fi'
    if [[ "$other" == "delegate" ]]; then
      echo "exec \"${REAL_NODE}\" \"\$@\""
    else
      echo "echo \"SyntaxError: Unexpected token '?'\" >&2"
      echo 'exit 1'
    fi
  } > "${dir}/node"
  chmod +x "${dir}/node"
}

# (n1) Node 12 first on PATH → the run stops on the Node check, before any
# other Node call (no vendor-skew message, no SyntaxError from a later step).
NODE12_BIN="${TMP}/node12-bin"
_write_node_stub "$NODE12_BIN" "12.22.0" "syntax-error"
TARGET_NODE12="${TMP}/consumer-node12"
mkdir -p "$TARGET_NODE12"
(cd "$TARGET_NODE12" && git init -q)
NODE12_LOG="${TMP}/consumer-node12.log"
if PATH="${NODE12_BIN}:${PATH}" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_NODE12" \
  --non-interactive \
  --vendor=copy \
  --agents=claude \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$NODE12_LOG" 2>&1; then
  echo "FAIL: (n1) install under Node 12 should exit non-zero"; cat "$NODE12_LOG"; exit 1
fi
grep -qF 'Node 12.22.0 found' "$NODE12_LOG" \
  || { echo "FAIL: (n1) missing 'Node 12.22.0 found'"; cat "$NODE12_LOG"; exit 1; }
grep -qF 'Rejected CLI flag' "$NODE12_LOG" \
  && { echo "FAIL: (n1) Node 12 reported as a vendor skew"; cat "$NODE12_LOG"; exit 1; }
grep -qF 'SyntaxError' "$NODE12_LOG" \
  && { echo "FAIL: (n1) a Node call ran before the Node check"; cat "$NODE12_LOG"; exit 1; }
[[ -e "${TARGET_NODE12}/vendor" ]] \
  && { echo "FAIL: (n1) vendor setup ran before the Node check"; exit 1; }

# (n2) Node 20 (end-of-life) → warning, then the install continues.
NODE20_BIN="${TMP}/node20-bin"
_write_node_stub "$NODE20_BIN" "20.11.0" "delegate"
TARGET_NODE20="${TMP}/consumer-node20"
mkdir -p "$TARGET_NODE20"
(cd "$TARGET_NODE20" && git init -q)
NODE20_LOG="${TMP}/consumer-node20.log"
PATH="${NODE20_BIN}:${PATH}" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_NODE20" \
  --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "$NODE20_LOG" 2>&1 \
  || { echo "FAIL: (n2) install under Node 20 should succeed"; cat "$NODE20_LOG"; exit 1; }
grep -qF 'Node 20.11.0 is end-of-life and not tested; use Node 22 or newer' "$NODE20_LOG" \
  || { echo "FAIL: (n2) missing the end-of-life warning"; cat "$NODE20_LOG"; exit 1; }
grep -qF 'Done.' "$NODE20_LOG" \
  || { echo "FAIL: (n2) install under Node 20 did not finish"; cat "$NODE20_LOG"; exit 1; }

# (s1) `ln` always fails with --link-mode symlink → every skill is copied
# instead, with a warning, and the run succeeds.
LN_FAIL_BIN="${TMP}/ln-fail-bin"
mkdir -p "$LN_FAIL_BIN"
printf '#!/bin/sh\necho "ln: stub failure" >&2\nexit 1\n' > "${LN_FAIL_BIN}/ln"
chmod +x "${LN_FAIL_BIN}/ln"
TARGET_LN_FAIL="${TMP}/consumer-ln-fail"
mkdir -p "$TARGET_LN_FAIL"
(cd "$TARGET_LN_FAIL" && git init -q)
LN_FAIL_LOG="${TMP}/consumer-ln-fail.log"
PATH="${LN_FAIL_BIN}:${PATH}" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_LN_FAIL" \
  --non-interactive \
  --agents=claude \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=symlink \
  > "$LN_FAIL_LOG" 2>&1 \
  || { echo "FAIL: (s1) install with failing ln should fall back to copy and succeed"; cat "$LN_FAIL_LOG"; exit 1; }
grep -qF 'Link failed for eversis-' "$LN_FAIL_LOG" \
  || { echo "FAIL: (s1) missing the 'Link failed … copied instead' warning"; cat "$LN_FAIL_LOG"; exit 1; }
grep -qF 'copied after a failed link' "$LN_FAIL_LOG" \
  || { echo "FAIL: (s1) final mirror log line does not count the fallbacks"; cat "$LN_FAIL_LOG"; exit 1; }
_ln_fail_checked=0
for _src in "${ROOT}/.ai/skills"/eversis-*; do
  [[ -d "$_src" ]] || continue
  _dst="${TARGET_LN_FAIL}/.claude/skills/$(basename "$_src")"
  [[ -L "$_dst" ]] && { echo "FAIL: (s1) ${_dst} is a link despite the failing ln"; exit 1; }
  [[ -f "${_dst}/SKILL.md" ]] && [[ ! -L "${_dst}/SKILL.md" ]] && [[ -r "${_dst}/SKILL.md" ]] \
    || { echo "FAIL: (s1) ${_dst}/SKILL.md is not a regular readable file"; exit 1; }
  _ln_fail_checked=$((_ln_fail_checked + 1))
done
[[ "$_ln_fail_checked" -gt 0 ]] || { echo "FAIL: (s1) no skills checked"; exit 1; }

# (s2) `ln` and `cp` of skill packages both fail → the run exits non-zero
# with the link-framework step failed, never a silent success.
LN_CP_FAIL_BIN="${TMP}/ln-cp-fail-bin"
mkdir -p "$LN_CP_FAIL_BIN"
cp "${LN_FAIL_BIN}/ln" "${LN_CP_FAIL_BIN}/ln"
REAL_CP="$(command -v cp)"
{
  echo '#!/bin/sh'
  echo 'for a in "$@"; do'
  echo '  case "$a" in'
  echo '    */.ai/skills/eversis-*) echo "cp: stub failure" >&2; exit 1 ;;'
  echo '  esac'
  echo 'done'
  echo "exec \"${REAL_CP}\" \"\$@\""
} > "${LN_CP_FAIL_BIN}/cp"
chmod +x "${LN_CP_FAIL_BIN}/cp"
TARGET_LN_CP_FAIL="${TMP}/consumer-ln-cp-fail"
mkdir -p "$TARGET_LN_CP_FAIL"
(cd "$TARGET_LN_CP_FAIL" && git init -q)
LN_CP_FAIL_LOG="${TMP}/consumer-ln-cp-fail.log"
if PATH="${LN_CP_FAIL_BIN}:${PATH}" bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_LN_CP_FAIL" \
  --non-interactive \
  --agents=claude \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=symlink \
  > "$LN_CP_FAIL_LOG" 2>&1; then
  echo "FAIL: (s2) install with failing ln and cp should exit non-zero"; cat "$LN_CP_FAIL_LOG"; exit 1
fi
grep -qE 'failed: +link-framework' "$LN_CP_FAIL_LOG" \
  || { echo "FAIL: (s2) failure not reported as the link-framework step"; cat "$LN_CP_FAIL_LOG"; exit 1; }
grep -qF 'Done.' "$LN_CP_FAIL_LOG" \
  && { echo "FAIL: (s2) run reported Done. after a failed skills mirror"; exit 1; }

# (s3) _verify_skills_mirror on its own: one .claude/skills/eversis-* entry
# replaced by a text file (a symlink checked out as text) → returns 1 and
# names that skill. Reuses the healthy mirror from (s1).
VERIFY_SKILL="$(basename "$(find "${ROOT}/.ai/skills" -mindepth 1 -maxdepth 1 -type d -name 'eversis-*' | LC_ALL=C sort | head -n 1)")"
VERIFY_LOG="${TMP}/verify-skills-mirror.log"
(
  # shellcheck disable=SC1091
  source "${ROOT}/scripts/lib/setup-agent-collections/common.sh"
  # shellcheck disable=SC1091
  source "${ROOT}/scripts/lib/setup-agent-collections/link-framework.sh"
  COLLECTIONS_HOME="$ROOT" TARGET_DIR="$TARGET_LN_FAIL"
  _verify_skills_mirror claude .claude/skills
) > "$VERIFY_LOG" 2>&1 \
  || { echo "FAIL: (s3) healthy mirror reported incomplete"; cat "$VERIFY_LOG"; exit 1; }
rm -rf "${TARGET_LN_FAIL}/.claude/skills/${VERIFY_SKILL}"
printf '../../.ai/skills/%s' "$VERIFY_SKILL" > "${TARGET_LN_FAIL}/.claude/skills/${VERIFY_SKILL}"
if (
  # shellcheck disable=SC1091
  source "${ROOT}/scripts/lib/setup-agent-collections/common.sh"
  # shellcheck disable=SC1091
  source "${ROOT}/scripts/lib/setup-agent-collections/link-framework.sh"
  COLLECTIONS_HOME="$ROOT" TARGET_DIR="$TARGET_LN_FAIL"
  _verify_skills_mirror claude .claude/skills
) > "$VERIFY_LOG" 2>&1; then
  echo "FAIL: (s3) mirror with a text-file entry reported complete"; cat "$VERIFY_LOG"; exit 1
fi
grep -qF "${VERIFY_SKILL}" "$VERIFY_LOG" \
  || { echo "FAIL: (s3) incomplete-mirror message does not name ${VERIFY_SKILL}"; cat "$VERIFY_LOG"; exit 1; }
grep -qF -- '--link-mode copy' "$VERIFY_LOG" \
  || { echo "FAIL: (s3) incomplete-mirror message lacks the --link-mode copy hint"; cat "$VERIFY_LOG"; exit 1; }

# ---------------------------------------------------------------------------
# --doctor: read-only health check. Faults are injected by editing the
# install under test (and the Node 12 stub from (n1)); each case restores what
# it broke, and the tree must be byte-identical after every doctor run.
# ---------------------------------------------------------------------------
bash "${ROOT}/scripts/setup-agent-collections.sh" --help | grep -qF -- '--doctor' \
  || { echo "FAIL: --help does not document --doctor"; exit 1; }

TARGET_DOCTOR="${TMP}/consumer-doctor"
mkdir -p "$TARGET_DOCTOR"
(cd "$TARGET_DOCTOR" && git init -q)
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET_DOCTOR" \
  --non-interactive \
  --vendor=copy \
  --agents=claude,cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy \
  > "${TMP}/consumer-doctor-install.log" 2>&1 \
  || { echo "FAIL: (d) install for the doctor cases failed"; cat "${TMP}/consumer-doctor-install.log"; exit 1; }

# Prints one line per path under $1 (directories, links and files, .git
# included), with a shasum for every regular file, sorted.
_doctor_tree_snapshot() {
  (cd "$1" && find . -print | LC_ALL=C sort \
    && find . -type f -exec shasum {} + | LC_ALL=C sort -k 2)
}

# Runs --doctor on TARGET_DOCTOR with any extra PATH prefix in $1, writes the
# output to $2 and returns the doctor's exit code. Fails the smoke test when
# the run changed the tree.
_run_doctor_case() {
  local path_prefix="$1" log="$2" before after rc=0
  before="$(_doctor_tree_snapshot "$TARGET_DOCTOR")"
  PATH="${path_prefix}${PATH}" bash "${ROOT}/scripts/setup-agent-collections.sh" \
    --doctor --target "$TARGET_DOCTOR" > "$log" 2>&1 || rc=$?
  after="$(_doctor_tree_snapshot "$TARGET_DOCTOR")"
  if [[ "$before" != "$after" ]]; then
    echo "FAIL: (d) --doctor changed the install tree"
    diff <(printf '%s\n' "$before") <(printf '%s\n' "$after") || true
    exit 1
  fi
  return "$rc"
}

# (d1) healthy install → exit 0, every check line OK, tree unchanged.
DOCTOR_LOG="${TMP}/consumer-doctor.log"
_run_doctor_case "" "$DOCTOR_LOG" \
  || { echo "FAIL: (d1) --doctor on a healthy install should exit 0"; cat "$DOCTOR_LOG"; exit 1; }
for _line in 'Node: ' 'Framework home: ' 'Agents: claude,cursor' 'Claude skills mirror: Verified' \
  'Cursor skills mirror: Verified' 'Claude hook entry: ' 'Claude hook launcher: ' \
  'Claude hook self-test: eversis-validate-spec self-test: ok' 'Doctor: all '; do
  grep -qF "$_line" "$DOCTOR_LOG" \
    || { echo "FAIL: (d1) --doctor output lacks '${_line}'"; cat "$DOCTOR_LOG"; exit 1; }
done
grep -qF 'FAIL' "$DOCTOR_LOG" && { echo "FAIL: (d1) healthy --doctor run printed a FAIL line"; cat "$DOCTOR_LOG"; exit 1; }
grep -qF "Framework home: $(cd "$TARGET_DOCTOR" && pwd)/vendor/agent-collections (recorded vendor mode copy)" "$DOCTOR_LOG" \
  || { echo "FAIL: (d1) --doctor did not take the framework home from the recorded vendor mode"; cat "$DOCTOR_LOG"; exit 1; }

# (d2) Node 12 first on PATH → exit 1, the Node version is reported, and the
# other checks still print (the self-test is skipped with a line saying so;
# the settings entry falls back to a text match).
_run_doctor_case "${NODE12_BIN}:" "$DOCTOR_LOG" \
  && { echo "FAIL: (d2) --doctor under Node 12 should exit 1"; cat "$DOCTOR_LOG"; exit 1; }
grep -qF 'Node 12.22.0 found' "$DOCTOR_LOG" \
  || { echo "FAIL: (d2) --doctor did not report the Node version"; cat "$DOCTOR_LOG"; exit 1; }
grep -qF 'Claude skills mirror: Verified' "$DOCTOR_LOG" \
  || { echo "FAIL: (d2) --doctor under Node 12 did not print the skills-mirror line"; cat "$DOCTOR_LOG"; exit 1; }
grep -qF 'Claude hook self-test: skipped: Node 12.22.0' "$DOCTOR_LOG" \
  || { echo "FAIL: (d2) --doctor under Node 12 did not report the skipped self-test"; cat "$DOCTOR_LOG"; exit 1; }
grep -qF 'SyntaxError' "$DOCTOR_LOG" \
  && { echo "FAIL: (d2) --doctor ran a Node script under Node 12"; cat "$DOCTOR_LOG"; exit 1; }

# (d3) one .claude/skills/eversis-* entry replaced by a text file → exit 1
# naming that skill.
DOCTOR_SKILL="$VERIFY_SKILL"
mv "${TARGET_DOCTOR}/.claude/skills/${DOCTOR_SKILL}" "${TMP}/doctor-skill-backup"
printf '../../.ai/skills/%s' "$DOCTOR_SKILL" > "${TARGET_DOCTOR}/.claude/skills/${DOCTOR_SKILL}"
_run_doctor_case "" "$DOCTOR_LOG" \
  && { echo "FAIL: (d3) --doctor with a broken skills mirror should exit 1"; cat "$DOCTOR_LOG"; exit 1; }
grep -F 'Claude skills mirror' "$DOCTOR_LOG" | grep -qF "$DOCTOR_SKILL" \
  || { echo "FAIL: (d3) --doctor did not name ${DOCTOR_SKILL}"; cat "$DOCTOR_LOG"; exit 1; }
grep -qF 'Claude hook self-test: eversis-validate-spec self-test: ok' "$DOCTOR_LOG" \
  || { echo "FAIL: (d3) later checks did not run after the mirror failure"; cat "$DOCTOR_LOG"; exit 1; }
rm -f "${TARGET_DOCTOR}/.claude/skills/${DOCTOR_SKILL}"
mv "${TMP}/doctor-skill-backup" "${TARGET_DOCTOR}/.claude/skills/${DOCTOR_SKILL}"

# (d4) framework hook entry removed from .claude/settings.json → exit 1
# naming the hook.
DOCTOR_SETTINGS="${TARGET_DOCTOR}/.claude/settings.json"
cp "$DOCTOR_SETTINGS" "${TMP}/doctor-settings-backup.json"
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  delete j.hooks;
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$DOCTOR_SETTINGS"
_run_doctor_case "" "$DOCTOR_LOG" \
  && { echo "FAIL: (d4) --doctor without the hook entry should exit 1"; cat "$DOCTOR_LOG"; exit 1; }
grep -F 'FAIL' "$DOCTOR_LOG" | grep -F 'Claude hook entry' | grep -qF '.claude/hooks/eversis-validate-spec.cjs' \
  || { echo "FAIL: (d4) --doctor did not name the missing hook entry"; cat "$DOCTOR_LOG"; exit 1; }
cp "${TMP}/doctor-settings-backup.json" "$DOCTOR_SETTINGS"

# (d5) launcher replaced by one that always exits 0 without the marker line
# → exit 1.
DOCTOR_LAUNCHER="${TARGET_DOCTOR}/.claude/hooks/eversis-validate-spec.cjs"
cp "$DOCTOR_LAUNCHER" "${TMP}/doctor-launcher-backup.cjs"
printf '"use strict";\nprocess.exitCode = 0;\n' > "$DOCTOR_LAUNCHER"
_run_doctor_case "" "$DOCTOR_LOG" \
  && { echo "FAIL: (d5) --doctor with a launcher that prints no marker should exit 1"; cat "$DOCTOR_LOG"; exit 1; }
grep -F 'FAIL' "$DOCTOR_LOG" | grep -qF 'Claude hook self-test' \
  || { echo "FAIL: (d5) --doctor did not fail the hook self-test"; cat "$DOCTOR_LOG"; exit 1; }
cp "${TMP}/doctor-launcher-backup.cjs" "$DOCTOR_LAUNCHER"

# (d6) vendored validator removed → exit 1 naming the missing validator.
DOCTOR_VALIDATOR="${TARGET_DOCTOR}/vendor/agent-collections/scripts/validate-spec-artifacts.mjs"
mv "$DOCTOR_VALIDATOR" "${TMP}/doctor-validator-backup.mjs"
_run_doctor_case "" "$DOCTOR_LOG" \
  && { echo "FAIL: (d6) --doctor without the vendored validator should exit 1"; cat "$DOCTOR_LOG"; exit 1; }
grep -F 'Claude hook self-test' "$DOCTOR_LOG" | grep -qF 'validator not found at' \
  || { echo "FAIL: (d6) --doctor did not name the missing validator"; cat "$DOCTOR_LOG"; exit 1; }
mv "${TMP}/doctor-validator-backup.mjs" "$DOCTOR_VALIDATOR"

# (d7) everything restored → healthy again.
_run_doctor_case "" "$DOCTOR_LOG" \
  || { echo "FAIL: (d7) --doctor after restoring the install should exit 0"; cat "$DOCTOR_LOG"; exit 1; }

if [[ "$ELAPSED" -gt 300 ]]; then
  echo "WARN: smoke exceeded 5 minutes (${ELAPSED}s)"
else
  echo "[smoke] under 5 minutes OK"
fi

echo "[smoke] PASS"
