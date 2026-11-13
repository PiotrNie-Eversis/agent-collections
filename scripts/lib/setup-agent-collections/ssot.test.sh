#!/usr/bin/env bash
# ssot.test.sh — unit tests for ssot.sh scaffolding + best-effort seed logic.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/ssot.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0
SKIP=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }
_skip() { echo "  ⚬ $1 (skipped)"; SKIP=$(( SKIP + 1 )); }

TARGET_DIR="$(mktemp -d)"
REMOTE_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR" "$REMOTE_DIR"' EXIT

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=ssot.sh
source "${LIB_DIR}/ssot.sh"

echo "ssot.sh unit tests"
echo ""

git -C "$TARGET_DIR" init -q -b main
echo "consumer project" > "${TARGET_DIR}/README.md"
git -C "$TARGET_DIR" add README.md
git -C "$TARGET_DIR" -c user.email=test@example.com -c user.name=test commit -q -m "init"

# Case 1: scaffold_ssot_project derives a slug from the target dir basename
unset SSOT_PROJECT_SLUG || true
scaffold_ssot_project
slug="$(basename "$TARGET_DIR" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
if [[ -f "${TARGET_DIR}/docs/context/${slug}/INDEX.md" ]] && grep -qF "domain knowledge index" "${TARGET_DIR}/docs/context/${slug}/INDEX.md"; then
  _pass "scaffold_ssot_project creates docs/context/<slug>/INDEX.md"
else
  _fail "scaffold_ssot_project creates docs/context/<slug>/INDEX.md"
fi

# Case 2: scaffold_ssot_project is idempotent — does not overwrite existing INDEX.md
echo "hand-edited" >> "${TARGET_DIR}/docs/context/${slug}/INDEX.md"
scaffold_ssot_project
if grep -qF "hand-edited" "${TARGET_DIR}/docs/context/${slug}/INDEX.md"; then
  _pass "scaffold_ssot_project does not overwrite an existing INDEX.md"
else
  _fail "scaffold_ssot_project does not overwrite an existing INDEX.md"
fi

# Slug precedence: --project-name → SSOT_PROJECT_SLUG → recorded
# ssot.projectContextPath → main worktree name (linked worktree toplevel) →
# target basename. Runs on its own temp tree; TARGET_DIR is restored after.
SLUG_ROOT="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR" "$REMOTE_DIR" "$SLUG_ROOT"' EXIT
_saved_target="$TARGET_DIR"
_slug_of() {
  # Args: target dir. Prints the slug with the caller's ARG_* / env settings.
  ( TARGET_DIR="$1"; _ssot_project_slug 2>/dev/null )
}
_expect_slug() {
  local got="$1" want="$2" label="$3"
  if [[ "$got" == "$want" ]]; then
    _pass "$label"
  else
    _fail "${label} (got '${got}', want '${want}')"
  fi
}
_write_record() {
  mkdir -p "$1/.agent-collections"
  printf '{"ssot":{"projectContextPath":"%s"}}\n' "$2" > "$1/.agent-collections/install-selection.json"
}

MAIN_REPO="${SLUG_ROOT}/Main_Project"
mkdir -p "$MAIN_REPO"
git -C "$MAIN_REPO" init -q -b main
git -C "$MAIN_REPO" config user.email test@example.com
git -C "$MAIN_REPO" config user.name test
echo "main" > "${MAIN_REPO}/README.md"
mkdir -p "${MAIN_REPO}/packages/web-app"
echo "web" > "${MAIN_REPO}/packages/web-app/README.md"
git -C "$MAIN_REPO" add -A
git -C "$MAIN_REPO" commit -q -m "init"
WORKTREE="${SLUG_ROOT}/main-project-pi-test"
git -C "$MAIN_REPO" worktree add -q "$WORKTREE" -b pi-test
# Plain repo whose git dir lives elsewhere (--separate-git-dir) under another
# name: its basename (plain-repo) differs from what the worktree / bare-repo
# rules would derive from the git dir (other-store), so the case below tells
# the rules apart.
PLAIN_REPO="${SLUG_ROOT}/Plain_Repo"
mkdir -p "${SLUG_ROOT}/stores"
git init -q --separate-git-dir "${SLUG_ROOT}/stores/other-store.git" "$PLAIN_REPO"
# Bare repo + worktrees layout: Bare_Proj/.bare holds the repo, worktrees sit
# beside it. The hidden bare dir must not name the project ("bare").
BARE_PROJ="${SLUG_ROOT}/Bare_Proj"
mkdir -p "$BARE_PROJ"
git clone -q --bare "$MAIN_REPO" "${BARE_PROJ}/.bare"
git -C "${BARE_PROJ}/.bare" worktree add -q "${BARE_PROJ}/feature-x" -b feature-x
NON_REPO="${SLUG_ROOT}/Plain Folder"
mkdir -p "$NON_REPO"

unset SSOT_PROJECT_SLUG || true
ARG_PROJECT_NAME="" ARG_PROJECT_NAME_PASSED="false"

ARG_PROJECT_NAME="Custom Name" ARG_PROJECT_NAME_PASSED="true"
_expect_slug "$(SSOT_PROJECT_SLUG=from-env _slug_of "$WORKTREE")" "custom-name" \
  "--project-name wins over SSOT_PROJECT_SLUG (and is kebab-cased)"
ARG_PROJECT_NAME="" ARG_PROJECT_NAME_PASSED="false"

_write_record "$WORKTREE" "docs/context/recorded/"
_expect_slug "$(SSOT_PROJECT_SLUG=From_Env _slug_of "$WORKTREE")" "from-env" \
  "SSOT_PROJECT_SLUG wins over the record and the worktree name (and is kebab-cased)"
_expect_slug "$(_slug_of "$WORKTREE")" "recorded" \
  "recorded ssot.projectContextPath wins over the linked worktree name"
rm -rf "${WORKTREE}/.agent-collections"

_expect_slug "$(_slug_of "$WORKTREE")" "main-project" \
  "linked worktree toplevel uses the main worktree's name"
if ( TARGET_DIR="$WORKTREE"; _ssot_project_slug 2>&1 >/dev/null ) | grep -qF "linked worktree"; then
  _pass "linked worktree rule logs one info line"
else
  _fail "linked worktree rule logs one info line"
fi
_expect_slug "$(_slug_of "${WORKTREE}/packages/web-app")" "web-app" \
  "subdirectory of a linked worktree keeps its own basename"
_expect_slug "$(_slug_of "$PLAIN_REPO")" "plain-repo" \
  "main worktree (plain repo, git dir elsewhere) uses its own basename, not the git dir's name"
_expect_slug "$(_slug_of "${BARE_PROJ}/feature-x")" "bare-proj" \
  "linked worktree of a proj/.bare repo uses the parent folder's name"
_expect_slug "$(_slug_of "$NON_REPO")" "plain-folder" \
  "non-repo target uses its basename"
TARGET_DIR="$_saved_target"

# Case 3: seed_ssot_global with no ARG_SSOT_SOURCE — succeeds, creates nothing
ARG_SSOT_SOURCE=""
seed_ssot_global
if [[ ! -d "${TARGET_DIR}/docs/context/global" ]]; then
  _pass "seed_ssot_global without --ssot-source does not create docs/context/global/"
else
  _fail "seed_ssot_global without --ssot-source does not create docs/context/global/"
fi

# Case 4: seed_ssot_global with an unreachable remote — warns, does not exit non-zero
ARG_SSOT_SOURCE="/nonexistent/path/does-not-exist"
if seed_ssot_global; then
  if [[ ! -d "${TARGET_DIR}/docs/context/global" ]]; then
    _pass "seed_ssot_global with unreachable remote does not block install"
  else
    _fail "seed_ssot_global with unreachable remote does not block install"
  fi
else
  _fail "seed_ssot_global with unreachable remote does not block install (non-zero exit)"
fi

# Case 5: seed_ssot_global with a reachable local remote — requires `git subtree`.
# `git subtree` (bare) exits non-zero (usage message) even when available, and
# `--help` shells out to `man` and fails on systems without man pages installed —
# neither is usable directly under `set -o pipefail`. Capture output first so the
# probe's own non-zero exit never feeds into a pipeline status.
_subtree_probe="$(git subtree 2>&1 || true)"
if echo "$_subtree_probe" | grep -q "usage: git subtree"; then
  (
    cd "$REMOTE_DIR"
    git init -q -b main
    echo "# domain-context" > INDEX.md
    git add INDEX.md
    git -c user.email=test@example.com -c user.name=test commit -q -m "seed"
  )
  ARG_SSOT_SOURCE="$REMOTE_DIR"
  ARG_SSOT_BRANCH="main"
  seed_ssot_global
  if [[ -f "${TARGET_DIR}/docs/context/global/INDEX.md" ]]; then
    _pass "seed_ssot_global with reachable remote seeds docs/context/global/"
  else
    _fail "seed_ssot_global with reachable remote seeds docs/context/global/"
  fi
else
  _skip "seed_ssot_global with reachable remote (git subtree not available in this environment)"
fi

echo ""
echo "  ✅  ${PASS} passed, ${SKIP} skipped, ${FAIL} failed."
