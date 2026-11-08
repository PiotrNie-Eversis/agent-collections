#!/usr/bin/env bash
# scripts/lib/release-paths.sh — shared helpers for the work-only path list.
#
# Sourced by scripts/release-to-master.sh and .githooks/pre-commit. The list of
# work-only paths lives in <repo>/.release-exclude (one git pathspec per line);
# these helpers read it and report which files in a tree or in the index match.
# Callers must run from inside the repository.

# Prints the pathspecs from .release-exclude, one per line (comments and blank
# lines removed). Returns 1 when the file is missing or has no pathspecs.
release_exclude_pathspecs() {
  local root file line found=0
  root="$(git rev-parse --show-toplevel)" || return 1
  file="${root}/.release-exclude"
  [[ -f "$file" ]] || { echo "release-paths: missing ${file}" >&2; return 1; }
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" == \#* ]] && continue
    printf '%s\n' "$line"
    found=1
  done < "$file"
  [[ "$found" -eq 1 ]] || { echo "release-paths: no pathspecs in ${file}" >&2; return 1; }
}

# Loads the pathspecs into the global array RELEASE_EXCLUDE_SPECS.
load_release_exclude_specs() {
  local specs line
  specs="$(release_exclude_pathspecs)" || return 1
  RELEASE_EXCLUDE_SPECS=()
  while IFS= read -r line; do
    RELEASE_EXCLUDE_SPECS+=("$line")
  done <<< "$specs"
}

# Lists work-only files present in the tree of <ref> (commit or tree-ish).
# Uses a throwaway index because `git ls-tree` does not understand pathspec magic.
list_release_excluded_in_tree() {
  local ref="$1" tmp_index rc=0
  load_release_exclude_specs || return 1
  tmp_index="$(mktemp "${TMPDIR:-/tmp}/release-paths.index.XXXXXX")" || return 1
  GIT_INDEX_FILE="$tmp_index" git read-tree "$ref" || rc=$?
  if [[ "$rc" -eq 0 ]]; then
    GIT_INDEX_FILE="$tmp_index" git ls-files -- "${RELEASE_EXCLUDE_SPECS[@]}" || rc=$?
  fi
  rm -f "$tmp_index"
  return "$rc"
}

# Lists staged (added / modified / renamed / copied) files that are work-only.
list_release_excluded_staged() {
  load_release_exclude_specs || return 1
  git diff --cached --name-only --diff-filter=ACMR -- "${RELEASE_EXCLUDE_SPECS[@]}"
}
