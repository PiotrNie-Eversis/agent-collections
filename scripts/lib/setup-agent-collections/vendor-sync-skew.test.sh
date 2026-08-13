#!/usr/bin/env bash
# vendor-sync-skew.test.sh — unit tests for vendor-sync-skew.sh
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=vendor-sync-skew.sh
source "${LIB_DIR}/vendor-sync-skew.sh"

write_sync_mjs() {
  local path="$1"
  local with_flag="$2"
  mkdir -p "$(dirname "$path")"
  if [[ "$with_flag" == "yes" ]]; then
    cat > "$path" <<'EOF'
#!/usr/bin/env node
if (process.argv.includes("--help") || process.argv.includes("-h")) {
  console.log("Usage: node adapters/sync.mjs [--out <dir>] [--framework-prefix <path>]");
  process.exit(0);
}
if (process.argv.includes("--framework-prefix")) process.exit(0);
console.error("error: unknown argument: " + (process.argv[2] || ""));
process.exit(1);
EOF
  else
    cat > "$path" <<'EOF'
#!/usr/bin/env node
if (process.argv.includes("--help") || process.argv.includes("-h")) {
  console.log("Usage: node adapters/sync.mjs [--out <dir>] [--agents cursor,claude]");
  process.exit(0);
}
if (process.argv[2] && process.argv[2].startsWith("-") && process.argv[2] !== "--out" && process.argv[2] !== "--agents" && process.argv[2] !== "--check") {
  console.error("error: unknown argument: " + process.argv[2]);
  process.exit(1);
}
process.exit(0);
EOF
  fi
}

init_git_repo() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email "test@example.com"
  git -C "$dir" config user.name "Test"
  git -C "$dir" config commit.gpgsign false
  echo "x" > "${dir}/README"
  git -C "$dir" add README
  git -C "$dir" commit -qm "init"
}

echo "vendor-sync-skew.sh unit tests"
echo ""

OLD_SYNC="${TMP}/old/adapters/sync.mjs"
NEW_SYNC="${TMP}/new/adapters/sync.mjs"
write_sync_mjs "$OLD_SYNC" "no"
write_sync_mjs "$NEW_SYNC" "yes"

# (1) probe false when sync.mjs has no --framework-prefix
if _sync_mjs_supports_flag "$OLD_SYNC" "--framework-prefix"; then
  _fail "probe false when sync.mjs has no --framework-prefix"
else
  _pass "probe false when sync.mjs has no --framework-prefix"
fi

# (2) probe true when it does
if _sync_mjs_supports_flag "$NEW_SYNC" "--framework-prefix"; then
  _pass "probe true when sync.mjs documents --framework-prefix"
else
  _fail "probe true when sync.mjs documents --framework-prefix"
fi

# (3) die-message contract: submodule + flag, not only unknown argument
msg="$(_vendor_sync_skew_message "--framework-prefix" "dirty vendor worktree" "aaa" "bbb")"
if echo "$msg" | grep -q "submodule" \
  && echo "$msg" | grep -qF -- "--framework-prefix" \
  && ! echo "$msg" | grep -qF -- "unknown argument: --framework-prefix"; then
  _pass "die message names submodule and flag (not unknown-argument-only)"
else
  echo "$msg"
  _fail "die message names submodule and flag (not unknown-argument-only)"
fi

# (4) no checkout when porcelain is non-empty
INSTALLER="${TMP}/installer.git"
VENDOR="${TMP}/vendor.git"
init_git_repo "$INSTALLER"
init_git_repo "$VENDOR"
mkdir -p "${VENDOR}/adapters"
write_sync_mjs "${VENDOR}/adapters/sync.mjs" "no"
git -C "$VENDOR" add adapters/sync.mjs
git -C "$VENDOR" commit -qm "old sync"
echo "dirty-file" > "${VENDOR}/uncommitted.txt"

INSTALLER_FRAMEWORK_HOME="$INSTALLER"
COLLECTIONS_HOME="$VENDOR"
VENDOR_MODE="submodule"
ARG_UPGRADE="true"
ARG_SYNC="true"
ADAPTER_SYNC_EXTRA_FLAGS=("--framework-prefix")
export INSTALLER_FRAMEWORK_HOME COLLECTIONS_HOME VENDOR_MODE ARG_UPGRADE ARG_SYNC

vendor_head_before="$(git -C "$VENDOR" rev-parse HEAD)"
rc=0
align_out="$(align_vendor_sync_cli_or_die 2>&1)" || rc=$?
vendor_head_after="$(git -C "$VENDOR" rev-parse HEAD)"

if [[ "$rc" -ne 0 ]] \
  && echo "$align_out" | grep -q "submodule" \
  && echo "$align_out" | grep -qF -- "--framework-prefix" \
  && [[ "$vendor_head_before" == "$vendor_head_after" ]]; then
  _pass "dirty vendor: die with submodule+flag and no checkout"
else
  echo "$align_out"
  _fail "dirty vendor: die with submodule+flag and no checkout"
fi

# skip-when-supported: matching flag → return 0, no die
VENDOR2="${TMP}/vendor-ok.git"
init_git_repo "$VENDOR2"
mkdir -p "${VENDOR2}/adapters"
write_sync_mjs "${VENDOR2}/adapters/sync.mjs" "yes"
git -C "$VENDOR2" add adapters/sync.mjs
git -C "$VENDOR2" commit -qm "new sync"
COLLECTIONS_HOME="$VENDOR2"
head_before="$(git -C "$VENDOR2" rev-parse HEAD)"
rc=0
align_vendor_sync_cli_or_die || rc=$?
head_after="$(git -C "$VENDOR2" rev-parse HEAD)"
if [[ "$rc" -eq 0 && "$head_before" == "$head_after" ]]; then
  _pass "skip-when-supported: no checkout when vendored CLI has the flag"
else
  _fail "skip-when-supported: no checkout when vendored CLI has the flag"
fi

# clean align: old pin + installer SHA already in object db → checkout
ALIGN_VENDOR="${TMP}/align-vendor.git"
init_git_repo "$ALIGN_VENDOR"
mkdir -p "${ALIGN_VENDOR}/adapters"
write_sync_mjs "${ALIGN_VENDOR}/adapters/sync.mjs" "no"
git -C "$ALIGN_VENDOR" add adapters/sync.mjs
git -C "$ALIGN_VENDOR" commit -qm "old sync"
old_sha="$(git -C "$ALIGN_VENDOR" rev-parse HEAD)"
write_sync_mjs "${ALIGN_VENDOR}/adapters/sync.mjs" "yes"
git -C "$ALIGN_VENDOR" add adapters/sync.mjs
git -C "$ALIGN_VENDOR" commit -qm "new sync"
new_sha="$(git -C "$ALIGN_VENDOR" rev-parse HEAD)"
git clone -q "$ALIGN_VENDOR" "${TMP}/align-installer.git"
git -C "$ALIGN_VENDOR" checkout -q "$old_sha"
INSTALLER_FRAMEWORK_HOME="${TMP}/align-installer.git"
COLLECTIONS_HOME="$ALIGN_VENDOR"
VENDOR_MODE="submodule"
rc=0
align_out="$(align_vendor_sync_cli_or_die 2>&1)" || rc=$?
aligned_sha="$(git -C "$ALIGN_VENDOR" rev-parse HEAD)"
if [[ "$rc" -eq 0 && "$aligned_sha" == "$new_sha" ]] && echo "$align_out" | grep -q "Aligned vendor submodule"; then
  _pass "clean align: checkout installer SHA then continue"
else
  echo "$align_out"
  _fail "clean align: checkout installer SHA then continue"
fi

# local / copy modes do not checkout
VENDOR_MODE="copy"
COLLECTIONS_HOME="$VENDOR"
rc=0
align_vendor_sync_cli_or_die || rc=$?
if [[ "$rc" -eq 0 && "$(git -C "$VENDOR" rev-parse HEAD)" == "$vendor_head_before" ]]; then
  _pass "copy mode: no checkout"
else
  _fail "copy mode: no checkout"
fi
VENDOR_MODE=""
rc=0
align_vendor_sync_cli_or_die || rc=$?
if [[ "$rc" -eq 0 ]]; then
  _pass "local mode: no checkout"
else
  _fail "local mode: no checkout"
fi

echo ""
echo "Passed: ${PASS}"
if [[ "$FAIL" -ne 0 ]]; then
  echo "Failed: ${FAIL}"
  exit 1
fi
