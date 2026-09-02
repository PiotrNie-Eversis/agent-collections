#!/usr/bin/env bash
# framework-home.test.sh — vendor mode must not write a machine-local home marker.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/framework-home.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

TARGET_DIR="$(mktemp -d)"
COLLECTIONS_HOME="/tmp/fake-agent-collections-home"
VENDOR_MODE=""
trap 'rm -rf "$TARGET_DIR"' EXIT

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=link-framework.sh
source "${LIB_DIR}/link-framework.sh"

echo "framework-home marker unit tests"
echo ""

# Local mode writes the absolute path
VENDOR_MODE=""
_write_or_clear_framework_home
if [[ -f "${TARGET_DIR}/.agent-collections/framework-home.txt" ]] && \
   grep -qxF "$COLLECTIONS_HOME" "${TARGET_DIR}/.agent-collections/framework-home.txt"; then
  _pass "local mode writes framework-home.txt"
else
  _fail "local mode writes framework-home.txt"
fi

# Vendor copy must not write, and must delete a leftover
echo "/old/machine/path" > "${TARGET_DIR}/.agent-collections/framework-home.txt"
VENDOR_MODE="copy"
_write_or_clear_framework_home
if [[ ! -e "${TARGET_DIR}/.agent-collections/framework-home.txt" ]]; then
  _pass "vendor copy removes leftover framework-home.txt"
else
  _fail "vendor copy removes leftover framework-home.txt"
fi

VENDOR_MODE="submodule"
echo "/old/machine/path" > "${TARGET_DIR}/.agent-collections/framework-home.txt"
_write_or_clear_framework_home
if [[ ! -e "${TARGET_DIR}/.agent-collections/framework-home.txt" ]]; then
  _pass "vendor submodule removes leftover framework-home.txt"
else
  _fail "vendor submodule removes leftover framework-home.txt"
fi

echo ""
echo "  ✅  All ${PASS} framework-home unit tests passed."
