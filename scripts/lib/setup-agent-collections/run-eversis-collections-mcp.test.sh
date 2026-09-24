#!/usr/bin/env bash
# run-eversis-collections-mcp.test.sh — runtime tests for the vendored Claude
# wrapper template and the bash -c locator emitted by mcp-merge.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/run-eversis-collections-mcp.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"
TEMPLATE="${REPO_ROOT}/templates/run-eversis-collections-mcp.sh"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

[[ -f "$TEMPLATE" ]] || { echo "FAIL: missing template ${TEMPLATE}"; exit 1; }
if grep -qF '/Users/' "$TEMPLATE"; then
  echo "FAIL: template contains a /Users/ path"; exit 1
fi
if grep -qF 'CLAUDE_PROJECT_DIR' "$TEMPLATE"; then
  echo "FAIL: template must not read CLAUDE_PROJECT_DIR"; exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

FAKE_ROOT="${WORK}/consumer"
mkdir -p "${FAKE_ROOT}/scripts" \
  "${FAKE_ROOT}/vendor/agent-collections" \
  "${FAKE_ROOT}/child" \
  "${WORK}/outside" \
  "${WORK}/bin"

# Stub docker first on PATH: record argv and CONSUMER_PROJECT_ROOT, exit 0.
DOCKER_LOG="${WORK}/docker.log"
cat > "${WORK}/bin/docker" <<EOF
#!/usr/bin/env bash
printf 'CONSUMER_PROJECT_ROOT=%s\n' "\${CONSUMER_PROJECT_ROOT-}" > "${DOCKER_LOG}"
printf 'ARGV=%s\n' "\$*" >> "${DOCKER_LOG}"
exit 0
EOF
chmod +x "${WORK}/bin/docker"
export PATH="${WORK}/bin:${PATH}"

# Minimal compose file so the wrapper accepts the path as a regular file.
touch "${FAKE_ROOT}/vendor/agent-collections/docker-compose.yml"

cp "$TEMPLATE" "${FAKE_ROOT}/scripts/run-eversis-collections-mcp.sh"
chmod +x "${FAKE_ROOT}/scripts/run-eversis-collections-mcp.sh"

echo "run-eversis-collections-mcp runtime tests"
echo ""

# --- Direct exec of the template in a fake tree ---
rm -f "$DOCKER_LOG"
if bash "${FAKE_ROOT}/scripts/run-eversis-collections-mcp.sh"; then
  :
else
  _fail "direct exec of wrapper exits 0 when compose file exists"
fi

if [[ -f "$DOCKER_LOG" ]]; then
  _pass "direct exec invokes stub docker"
else
  _fail "direct exec invokes stub docker"
fi

expected_f="${FAKE_ROOT}/vendor/agent-collections/docker-compose.yml"
if grep -qxF "CONSUMER_PROJECT_ROOT=${FAKE_ROOT}" "$DOCKER_LOG"; then
  _pass "CONSUMER_PROJECT_ROOT equals fake consumer root"
else
  _fail "CONSUMER_PROJECT_ROOT equals fake consumer root"
fi
if grep -qF "ARGV=compose -f ${expected_f} run --rm -T eversis-collections" "$DOCKER_LOG"; then
  _pass "-f argument is <fake>/vendor/agent-collections/docker-compose.yml"
else
  echo "  docker.log:"; cat "$DOCKER_LOG" >&2 || true
  _fail "-f argument is <fake>/vendor/agent-collections/docker-compose.yml"
fi

# --- Missing compose file: non-zero, docker not invoked ---
MISSING_ROOT="${WORK}/missing-compose"
mkdir -p "${MISSING_ROOT}/scripts"
cp "$TEMPLATE" "${MISSING_ROOT}/scripts/run-eversis-collections-mcp.sh"
chmod +x "${MISSING_ROOT}/scripts/run-eversis-collections-mcp.sh"
rm -f "$DOCKER_LOG"
set +e
bash "${MISSING_ROOT}/scripts/run-eversis-collections-mcp.sh"
missing_rc=$?
set -e
if [[ "$missing_rc" -ne 0 ]]; then
  _pass "missing compose file exits non-zero"
else
  _fail "missing compose file exits non-zero"
fi
if [[ ! -f "$DOCKER_LOG" ]]; then
  _pass "missing compose file does not invoke docker"
else
  _fail "missing compose file does not invoke docker"
fi

# --- Locator from vendored Claude merge (mcp-merge) ---
# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=mcp-merge.sh
source "${LIB_DIR}/mcp-merge.sh"
# shellcheck source=mcp-user-overlap.sh
source "${LIB_DIR}/mcp-user-overlap.sh"

MERGE_TARGET="${WORK}/merge-target"
mkdir -p "$MERGE_TARGET"
COLLECTIONS_HOME="$REPO_ROOT"
TARGET_DIR="$MERGE_TARGET"
SELECTED_AGENTS="claude"
VENDOR_MODE="copy"
unset MCP_SELECTED_IDS 2>/dev/null || true
merge_mcp_json

LOCATOR="$(node -e '
  const fs = require("fs");
  const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  const e = j.mcpServers["eversis-collections"];
  if (!e || e.command !== "bash" || e.args[0] !== "-c") process.exit(1);
  process.stdout.write(e.args[1]);
' "${MERGE_TARGET}/.mcp.json")" || _fail "read locator from vendored Claude merge"

# Install the same tree layout the locator expects under FAKE_ROOT (already has
# script + compose). Re-copy merge-produced script so locator tests use the
# installer-copied file as well.
cp "${MERGE_TARGET}/scripts/run-eversis-collections-mcp.sh" \
  "${FAKE_ROOT}/scripts/run-eversis-collections-mcp.sh"
chmod +x "${FAKE_ROOT}/scripts/run-eversis-collections-mcp.sh"

# Locator: cwd = child, CLAUDE_PROJECT_DIR = fake root → script runs
rm -f "$DOCKER_LOG"
set +e
(
  cd "${FAKE_ROOT}/child"
  export CLAUDE_PROJECT_DIR="$FAKE_ROOT"
  bash -c "$LOCATOR"
)
loc_rc=$?
set -e
if [[ "$loc_rc" -eq 0 ]] && [[ -f "$DOCKER_LOG" ]]; then
  _pass "locator with CLAUDE_PROJECT_DIR set finds script from child cwd"
else
  _fail "locator with CLAUDE_PROJECT_DIR set finds script from child cwd"
fi
if grep -qxF "CONSUMER_PROJECT_ROOT=${FAKE_ROOT}" "$DOCKER_LOG"; then
  _pass "locator (CLAUDE_PROJECT_DIR set) yields correct CONSUMER_PROJECT_ROOT"
else
  _fail "locator (CLAUDE_PROJECT_DIR set) yields correct CONSUMER_PROJECT_ROOT"
fi

# Locator: cwd = child, CLAUDE_PROJECT_DIR unset → upward walk
rm -f "$DOCKER_LOG"
set +e
(
  cd "${FAKE_ROOT}/child"
  unset CLAUDE_PROJECT_DIR
  bash -c "$LOCATOR"
)
loc_rc=$?
set -e
if [[ "$loc_rc" -eq 0 ]] && [[ -f "$DOCKER_LOG" ]]; then
  _pass "locator with CLAUDE_PROJECT_DIR unset walks up from child cwd"
else
  _fail "locator with CLAUDE_PROJECT_DIR unset walks up from child cwd"
fi

# Locator: cwd = child, CLAUDE_PROJECT_DIR explicitly empty → skip first branch, walk
rm -f "$DOCKER_LOG"
set +e
(
  cd "${FAKE_ROOT}/child"
  export CLAUDE_PROJECT_DIR=""
  bash -c "$LOCATOR"
)
loc_rc=$?
set -e
if [[ "$loc_rc" -eq 0 ]] && [[ -f "$DOCKER_LOG" ]]; then
  _pass "locator with empty CLAUDE_PROJECT_DIR walks up from child cwd"
else
  _fail "locator with empty CLAUDE_PROJECT_DIR walks up from child cwd"
fi
if grep -qxF "CONSUMER_PROJECT_ROOT=${FAKE_ROOT}" "$DOCKER_LOG"; then
  _pass "locator (empty CLAUDE_PROJECT_DIR) yields correct CONSUMER_PROJECT_ROOT"
else
  _fail "locator (empty CLAUDE_PROJECT_DIR) yields correct CONSUMER_PROJECT_ROOT"
fi

# Locator: CLAUDE_PROJECT_DIR unset, cwd outside fake root → non-zero, no docker
rm -f "$DOCKER_LOG"
set +e
(
  cd "${WORK}/outside"
  unset CLAUDE_PROJECT_DIR
  bash -c "$LOCATOR"
)
loc_rc=$?
set -e
if [[ "$loc_rc" -ne 0 ]]; then
  _pass "locator outside fake root exits non-zero"
else
  _fail "locator outside fake root exits non-zero"
fi
if [[ ! -f "$DOCKER_LOG" ]]; then
  _pass "locator outside fake root does not invoke docker"
else
  _fail "locator outside fake root does not invoke docker"
fi

echo ""
echo "  ✅  All ${PASS} run-eversis-collections-mcp runtime tests passed."
