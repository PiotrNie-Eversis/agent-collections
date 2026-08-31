#!/usr/bin/env bash
# selection-ssot.test.sh — omit vs empty --ssot-source; confluence preserve on load.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/selection-ssot.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

TARGET_DIR="$(mktemp -d)"
COLLECTIONS_HOME="${LIB_DIR}/../../.."
COLLECTIONS_HOME="$(cd "$COLLECTIONS_HOME" && pwd)"
VENDOR_MODE=""
SELECTED_AGENTS="cursor"
MCP_SELECTED_IDS="eversis-collections"
DOMAIN_PROFILE="frontend"
ARG_LINK_MODE="copy"
EFFECTIVE_LINK_MODE="copy"
SSOT_PROJECT_SLUG="consumer"
ARG_SSOT_SOURCE=""
ARG_SSOT_SOURCE_PASSED="false"
ARG_CONFLUENCE_SPACE_KEY=""
ARG_CONFLUENCE_SPACE_KEY_PASSED="false"
trap 'rm -rf "$TARGET_DIR"' EXIT

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=selection.sh
source "${LIB_DIR}/selection.sh"
# shellcheck source=upgrade.sh
source "${LIB_DIR}/upgrade.sh"

SEL="${TARGET_DIR}/.agent-collections/install-selection.json"

_ssot_field() {
  node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); const v=j.ssot&&j.ssot[process.argv[2]]; console.log(v===null?'null':v==null?'':String(v));" "$SEL" "$1"
}

echo "selection SSOT unit tests"
echo ""

ARG_SSOT_SOURCE=""
ARG_SSOT_SOURCE_PASSED="false"
write_install_selection >/dev/null
if [[ "$(_ssot_field externalSsotRepo)" == "null" ]]; then
  _pass "first write without --ssot-source records null"
else
  _fail "first write without --ssot-source records null"
fi

DUMMY_URL="https://gitlab3.eversis.com/dawis/domain-context.git"
ARG_SSOT_SOURCE="$DUMMY_URL"
ARG_SSOT_SOURCE_PASSED="true"
write_install_selection >/dev/null
if [[ "$(_ssot_field externalSsotRepo)" == "$DUMMY_URL" ]]; then
  _pass "write with --ssot-source URL records the URL"
else
  _fail "write with --ssot-source URL records the URL"
fi

ARG_SSOT_SOURCE=""
ARG_SSOT_SOURCE_PASSED="false"
load_selection_or_fail >/dev/null
if [[ "$ARG_SSOT_SOURCE" == "$DUMMY_URL" ]]; then
  _pass "upgrade load without flag restores externalSsotRepo"
else
  _fail "upgrade load without flag restores externalSsotRepo"
fi
write_install_selection >/dev/null
if [[ "$(_ssot_field externalSsotRepo)" == "$DUMMY_URL" ]]; then
  _pass "rewrite after omit-load keeps the URL"
else
  _fail "rewrite after omit-load keeps the URL"
fi

ARG_SSOT_SOURCE=""
ARG_SSOT_SOURCE_PASSED="true"
write_install_selection >/dev/null
if [[ "$(_ssot_field externalSsotRepo)" == "null" ]]; then
  _pass "empty --ssot-source (PASSED) clears to null"
else
  _fail "empty --ssot-source (PASSED) clears to null"
fi

node -e "
  const fs=require('fs');
  const p=process.argv[1];
  const j=JSON.parse(fs.readFileSync(p,'utf8'));
  j.ssot=j.ssot||{};
  j.ssot.externalSsotRepo='https://example.invalid/dc.git';
  j.ssot.confluenceSpaceKey='DAWIS';
  j.ssot.projectContextPath='docs/context/custom-project/';
  fs.writeFileSync(p, JSON.stringify(j,null,2)+'\n');
" "$SEL"

ARG_SSOT_SOURCE=""
ARG_SSOT_SOURCE_PASSED="false"
ARG_CONFLUENCE_SPACE_KEY=""
ARG_CONFLUENCE_SPACE_KEY_PASSED="false"
load_selection_or_fail >/dev/null
if [[ "$ARG_CONFLUENCE_SPACE_KEY" == "DAWIS" ]]; then
  _pass "upgrade load without confluence flag restores confluenceSpaceKey"
else
  _fail "upgrade load without confluence flag restores confluenceSpaceKey"
fi
write_install_selection >/dev/null
if [[ "$(_ssot_field confluenceSpaceKey)" == "DAWIS" ]] && \
   [[ "$(_ssot_field projectContextPath)" == "docs/context/custom-project/" ]]; then
  _pass "rewrite preserves confluence key and custom projectContextPath"
else
  _fail "rewrite preserves confluence key and custom projectContextPath"
fi

if bash "${COLLECTIONS_HOME}/scripts/setup-agent-collections.sh" --ssot-source >/dev/null 2>&1; then
  _fail "bare --ssot-source (no value) still errors"
else
  _pass "bare --ssot-source (no value) still errors"
fi

echo ""
echo "  ✅  All ${PASS} selection SSOT unit tests passed."
