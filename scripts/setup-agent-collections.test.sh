#!/usr/bin/env bash
# Non-interactive smoke test for setup-agent-collections.sh (TASK-534 / 538).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ac-smoke.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "[smoke] framework-home unit tests"
bash "${ROOT}/scripts/lib/setup-agent-collections/framework-home.test.sh"

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
grep -qF '"command": "docker"' "${TARGET_CLAUDE}/.mcp.json" \
  || { echo "FAIL: .mcp.json eversis-collections entry is not docker-based"; exit 1; }
grep -qF '${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections/docker-compose.yml' "${TARGET_CLAUDE}/.mcp.json" \
  || { echo "FAIL: .mcp.json eversis-collections -f path is not the vendored docker-compose.yml"; exit 1; }
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

# Upgrade reuse
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --upgrade --sync --non-interactive

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

if [[ "$ELAPSED" -gt 300 ]]; then
  echo "WARN: smoke exceeded 5 minutes (${ELAPSED}s)"
else
  echo "[smoke] under 5 minutes OK"
fi

echo "[smoke] PASS"
