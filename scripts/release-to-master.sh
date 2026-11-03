#!/usr/bin/env bash
# release-to-master.sh — publish develop to master as a filtered snapshot.
#
# master is the production branch and carries only the framework core. It is
# never merged from develop (a merge would bring the work-only docs along).
# Instead this script takes the tree of the source branch, removes every path
# listed in .release-exclude, and records it as ONE new commit on master whose
# only parent is the previous master commit:
#
#   release: develop@<sha>
#
# Deletions and renames on develop reach master because the whole tree is
# replaced; work-only paths never do. The script only moves the local master
# ref — it never pushes. Review, then `git push origin master`.
#
# Usage (repo root, any branch except master):
#   bash scripts/release-to-master.sh [--dry-run] [--from <ref>] [--to <branch>]
#                                     [--allow-diverged]
#
#   --dry-run          Show what the release would change; write nothing.
#   --from <ref>       Source of the snapshot (default: develop).
#   --to <branch>      Target branch (default: master).
#   --allow-diverged   Release even when the target has commits that are not
#                      releases and not in the source (they would be overwritten
#                      by the snapshot). Without it the script stops and lists them.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/release-paths.sh
source "${SCRIPT_DIR}/lib/release-paths.sh"

FROM="develop"
TO="master"
DRY_RUN="false"
ALLOW_DIVERGED="false"

die() { echo "release-to-master: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN="true"; shift ;;
    --allow-diverged) ALLOW_DIVERGED="true"; shift ;;
    --from) [[ $# -ge 2 ]] || die "--from requires a ref"; FROM="$2"; shift 2 ;;
    --from=*) FROM="${1#*=}"; shift ;;
    --to) [[ $# -ge 2 ]] || die "--to requires a branch"; TO="$2"; shift 2 ;;
    --to=*) TO="${1#*=}"; shift ;;
    -h|--help)
      awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"
      exit 0 ;;
    *) die "unknown option: $1 (see --help)" ;;
  esac
done

cd "$(git rev-parse --show-toplevel)" || die "not inside a git repository"

target_ref="refs/heads/${TO}"
git rev-parse --verify --quiet "${FROM}^{commit}" >/dev/null || die "source '${FROM}' not found"
git rev-parse --verify --quiet "${target_ref}" >/dev/null || die "target branch '${TO}' not found"

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [[ "$current_branch" == "$TO" ]]; then
  die "you are on '${TO}'. Switch to another branch first (the script moves the '${TO}' ref without touching your working tree)."
fi

source_sha="$(git rev-parse "${FROM}^{commit}")"
target_sha="$(git rev-parse "${target_ref}")"
source_short="$(git rev-parse --short "$source_sha")"

# Warn when the local branches lag their remote-tracking copies (no fetch here).
for b in "$FROM" "$TO"; do
  if git rev-parse --verify --quiet "refs/remotes/origin/${b}" >/dev/null &&
     git rev-parse --verify --quiet "refs/heads/${b}" >/dev/null; then
    if [[ "$(git rev-parse "refs/heads/${b}")" != "$(git rev-parse "refs/remotes/origin/${b}")" ]]; then
      echo "release-to-master: warning: local ${b} differs from origin/${b} (run git fetch / pull first if that is unexpected)" >&2
    fi
  fi
done

# Commits on the target that are neither releases nor part of the source would
# be silently overwritten by the snapshot (e.g. a hotfix made only on master).
diverged="$(git log --format='%h %s' "${source_sha}..${target_sha}" | grep -v -E '^[0-9a-f]+ release: ' || true)"
if [[ -n "$diverged" ]]; then
  echo "release-to-master: '${TO}' has commits that are not in '${FROM}' and are not releases:" >&2
  echo "$diverged" | sed 's/^/  /' >&2
  if [[ "$ALLOW_DIVERGED" != "true" ]]; then
    die "bring those changes into '${FROM}' first, or re-run with --allow-diverged to overwrite them with the snapshot."
  fi
  echo "release-to-master: --allow-diverged given — the snapshot replaces them." >&2
fi

# Build the filtered tree in a throwaway index (the real index is untouched).
load_release_exclude_specs || die "cannot read .release-exclude"
tmp_index="$(mktemp "${TMPDIR:-/tmp}/release-to-master.index.XXXXXX")"
trap 'rm -f "$tmp_index"' EXIT
GIT_INDEX_FILE="$tmp_index" git read-tree "$source_sha"
GIT_INDEX_FILE="$tmp_index" git rm -r --cached -f -q --ignore-unmatch -- "${RELEASE_EXCLUDE_SPECS[@]}"
release_tree="$(GIT_INDEX_FILE="$tmp_index" git write-tree)"

leaked="$(list_release_excluded_in_tree "$release_tree")"
[[ -z "$leaked" ]] || die "internal error: work-only paths left in the release tree:
${leaked}"

if [[ "$release_tree" == "$(git rev-parse "${target_sha}^{tree}")" ]]; then
  echo "release-to-master: nothing to release — '${TO}' already matches ${FROM}@${source_short} without work-only paths."
  exit 0
fi

echo "release-to-master: ${FROM}@${source_short} → ${TO} (changes vs current ${TO}):"
git diff --stat "$target_sha" "$release_tree" | tail -n 25

if [[ "$DRY_RUN" == "true" ]]; then
  echo "release-to-master: dry run — nothing written."
  exit 0
fi

message="release: ${FROM}@${source_short}

Snapshot of ${FROM} ${source_sha} without the work-only paths
listed in .release-exclude (produced by scripts/release-to-master.sh)."

release_commit="$(git commit-tree "$release_tree" -p "$target_sha" -m "$message")"
# Compare-and-swap: fails if the target moved while the script ran.
git update-ref -m "release-to-master: ${FROM}@${source_short}" "$target_ref" "$release_commit" "$target_sha"

echo "release-to-master: ${TO} is now $(git rev-parse --short "$release_commit") (release: ${FROM}@${source_short})."
echo "Review:  git show --stat ${TO}"
echo "Publish: git push origin ${TO}"
