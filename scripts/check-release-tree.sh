#!/usr/bin/env bash
# check-release-tree.sh — fail when a commit carries work-only paths.
#
# master is production and must contain only the framework core; the work-only
# paths listed in .release-exclude (docs/specs, docs/context/<project>, ...)
# belong on develop. scripts/release-to-master.sh strips them and
# .githooks/pre-commit blocks them locally, but a push from a clone without the
# hook (or with --no-verify) would still reach master. This check runs in CI on
# every master pipeline and fails the pipeline when such paths are present.
#
# Usage (repo root):
#   bash scripts/check-release-tree.sh [<ref>]   # default: HEAD
#
# Exit codes: 0 clean, 1 work-only paths found (listed on stderr), 2 usage/setup error.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/release-paths.sh
source "${SCRIPT_DIR}/lib/release-paths.sh"

ref="${1:-HEAD}"
git rev-parse --verify --quiet "${ref}^{commit}" >/dev/null || {
  echo "check-release-tree: '${ref}' is not a commit" >&2
  exit 2
}

if ! found="$(list_release_excluded_in_tree "$ref")"; then
  echo "check-release-tree: could not read .release-exclude or the tree of '${ref}'" >&2
  exit 2
fi

if [[ -n "$found" ]]; then
  count="$(printf '%s\n' "$found" | wc -l | tr -d ' ')"
  echo "check-release-tree: ${count} work-only path(s) on $(git rev-parse --short "$ref") — they belong on develop, not on master:" >&2
  printf '%s\n' "$found" | sed 's/^/  /' >&2
  echo "Fix: the next 'bash scripts/release-to-master.sh --allow-diverged' (run from develop) replaces master with a clean snapshot; make sure the change is on develop first." >&2
  exit 1
fi

subject="$(git log -1 --format=%s "$ref")"
if [[ "$subject" != release:* ]]; then
  echo "check-release-tree: note: '${subject}' is not a release commit — master should change only via scripts/release-to-master.sh." >&2
fi
echo "check-release-tree: OK — no work-only paths on $(git rev-parse --short "$ref")."
