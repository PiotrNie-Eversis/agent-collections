#!/usr/bin/env bash
# release-to-master.sh — publish develop to master without the work-only paths.
#
# master is the production branch and carries only the framework core. It is
# never merged from develop (a merge would bring the work-only docs along).
# The work-only paths are listed in .release-exclude. Two modes:
#
# Copy mode (default) copies each core commit of the source branch to the
# target as its own commit, in source order (like `git cherry-pick -x`):
#
#   - Base: the latest "release: <from>@<sha>" commit on the target. Its body
#     line "Snapshot of <from> <full sha>" names the source commit it covers.
#     No such commit: the script stops — run --snapshot once to create one.
#   - Already released: commits on the target after that release commit whose
#     message ends with "(cherry picked from commit <full sha>)", where <full
#     sha> is in base..<from>. They are not copied again. A target commit after
#     the base without such a line (e.g. a hotfix made only on master, or a
#     cherry-pick from another branch) stops the script.
#   - Every other commit in base..<from>, oldest first:
#       only work-only paths  → skipped ("skip (work-only)");
#       no changes            → skipped ("skip (empty)");
#       no change on target   → skipped ("skip (already on <to>)");
#       only core paths       → copied with the original author and author
#                               date, plus the "(cherry picked from commit …)"
#                               line; the committer is the person releasing;
#       core and work-only    → stop (name the commit; release with --snapshot);
#       merge commit          → stop (name the commit);
#       copy conflict         → stop (name the commit and the paths).
#   - Post-check: the new target tree must equal the source tree without the
#     work-only paths. Otherwise the script stops and shows the difference.
#   Deletions count as changes. Nothing is written until every commit is
#   copied and the post-check passes; then the target ref moves once.
#   Copy mode needs git 2.40 or later (`git merge-tree --merge-base`).
#
# Snapshot mode (--snapshot, repair) takes the tree of the source branch,
# removes every .release-exclude path, and records it as ONE new commit on the
# target whose only parent is the previous target commit:
#
#   release: develop@<sha>
#
# Deletions and renames reach master because the whole tree is replaced. Use
# it once to create the first base, and to repair: after a mixed commit, a
# master-only commit (with --allow-diverged), or a post-check mismatch.
#
# In both modes work-only paths never reach master, the working tree and
# index are not touched, and the script only moves the local target ref — it
# never pushes. Review, then `git push origin master`.
#
# Usage (repo root, any branch except master):
#   bash scripts/release-to-master.sh [--dry-run] [--from <ref>] [--to <branch>]
#                                     [--snapshot [--allow-diverged]]
#
#   --dry-run          Show what the release would do (copy mode: one
#                      "copy <sha> <subject>" or "skip (...) <sha> <subject>"
#                      line per commit); write nothing.
#   --from <ref>       Source branch (default: develop).
#   --to <branch>      Target branch (default: master).
#   --snapshot         Release one filtered snapshot instead of copying commits.
#   --allow-diverged   Only with --snapshot. Release even when the target has
#                      commits that are not releases and not in the source (they
#                      would be overwritten by the snapshot). Copies made by
#                      copy mode count as releases. Without it the script stops
#                      and lists them.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/release-paths.sh
source "${SCRIPT_DIR}/lib/release-paths.sh"

FROM="develop"
TO="master"
DRY_RUN="false"
ALLOW_DIVERGED="false"
SNAPSHOT="false"

die() { echo "release-to-master: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN="true"; shift ;;
    --snapshot) SNAPSHOT="true"; shift ;;
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

if [[ "$ALLOW_DIVERGED" == "true" && "$SNAPSHOT" != "true" ]]; then
  die "--allow-diverged works only with --snapshot (copy mode never overwrites target commits; see --help)"
fi

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

load_release_exclude_specs || die "cannot read .release-exclude"

# Prints the tree of <ref> without the .release-exclude paths. Builds it in a
# throwaway index (the real index is untouched). Used by both modes: as the
# snapshot itself, and as the copy-mode post-check. It runs inside "$(...)",
# where set -e does not apply, so every step checks its own status. Returns 1
# (message on stderr, nothing on stdout) on any failure or an empty result;
# callers must check the status: tree="$(filtered_tree <ref>)" || die ...
filtered_tree() {
  local ref="$1" tmp_index tree leaked
  tmp_index="$(mktemp "${TMPDIR:-/tmp}/release-to-master.index.XXXXXX")" || {
    echo "release-to-master: cannot create a temporary index in ${TMPDIR:-/tmp}" >&2; return 1; }
  if ! GIT_INDEX_FILE="$tmp_index" git read-tree "$ref" ||
     ! GIT_INDEX_FILE="$tmp_index" git rm -r --cached -f -q --ignore-unmatch -- "${RELEASE_EXCLUDE_SPECS[@]}" ||
     ! tree="$(GIT_INDEX_FILE="$tmp_index" git write-tree)"; then
    rm -f "$tmp_index"
    echo "release-to-master: cannot build the filtered tree of ${ref}" >&2
    return 1
  fi
  rm -f "$tmp_index"
  if [[ -z "$tree" || "$tree" == "$EMPTY_TREE" ]]; then
    echo "release-to-master: the filtered tree of ${ref} is empty — refusing to release it" >&2
    return 1
  fi
  leaked="$(list_release_excluded_in_tree "$tree")" || {
    echo "release-to-master: cannot check the filtered tree of ${ref} for work-only paths" >&2; return 1; }
  if [[ -n "$leaked" ]]; then
    printf 'release-to-master: internal error: work-only paths left in the release tree:\n%s\n' "$leaked" >&2
    return 1
  fi
  printf '%s\n' "$tree"
}

# The empty tree (no files); a filtered tree must never be this.
EMPTY_TREE="$(git hash-object -t tree /dev/null)"

short_of() { git rev-parse --short "$1"; }
subject_of() { git log -1 --format=%s "$1"; }

# Prints the source sha of the last "(cherry picked from commit <sha>)" line in
# the message of <commit>, or nothing.
trailer_sha() {
  git log -1 --format=%B "$1" |
    sed -nE 's/^\(cherry picked from commit ([0-9a-f]{40})\)$/\1/p' | tail -n 1
}

# --- Snapshot mode (--snapshot) ----------------------------------------------

release_snapshot() {
  # Commits on the target that are neither releases nor part of the source would
  # be silently overwritten by the snapshot (e.g. a hotfix made only on master).
  # Only commits after the latest release count: anything older was already
  # replaced (or deliberately overridden with --allow-diverged) by that release.
  # Copies made by copy mode ("(cherry picked from commit <sha>)" with <sha> in
  # the source) are releases too.
  local last_release range diverged="" t ts release_tree message release_commit
  # Match the subject only (a body line "release: …" does not make a release).
  last_release="$(git log --format='%H %s' "$target_sha" |
    awk '!found && substr($0, 42, 9) == "release: " { print substr($0, 1, 40); found = 1 }')"
  range=("^${source_sha}" "$target_sha")
  [[ -n "$last_release" ]] && range+=("^${last_release}")
  while IFS= read -r t; do
    [[ -n "$t" ]] || continue
    [[ "$(subject_of "$t")" == "release: "* ]] && continue
    ts="$(trailer_sha "$t")"
    [[ -n "$ts" ]] && git merge-base --is-ancestor "$ts" "$source_sha" 2>/dev/null && continue
    diverged+="$(short_of "$t") $(subject_of "$t")"$'\n'
  done < <(git rev-list "${range[@]}")
  diverged="${diverged%$'\n'}"
  if [[ -n "$diverged" ]]; then
    echo "release-to-master: '${TO}' has commits that are not in '${FROM}' and are not releases:" >&2
    echo "$diverged" | sed 's/^/  /' >&2
    if [[ "$ALLOW_DIVERGED" != "true" ]]; then
      die "bring those changes into '${FROM}' first, or re-run with --snapshot --allow-diverged to overwrite them with the snapshot."
    fi
    echo "release-to-master: --allow-diverged given — the snapshot replaces them." >&2
  fi

  release_tree="$(filtered_tree "$source_sha")" || die "stopped — nothing written."

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
}

if [[ "$SNAPSHOT" == "true" ]]; then
  release_snapshot
  exit 0
fi

# --- Copy mode (default) -----------------------------------------------------

# git merge-tree --merge-base needs git 2.40.
git_version="$(git version | sed -nE 's/^git version ([0-9]+)\.([0-9]+).*/\1 \2/p')"
read -r git_major git_minor <<< "${git_version:-0 0}"
if (( git_major < 2 || (git_major == 2 && git_minor < 40) )); then
  die "copy mode needs git 2.40 or later (found: $(git version)). Upgrade git, or release with --snapshot."
fi

# Prints "<release commit> <source sha>" for the latest "release: <from>@…"
# commit on the target. The source sha comes from the body line
# "Snapshot of <from> <40-hex sha>"; fallback: the short sha in the subject.
find_release_base() {
  local prefix="release: ${FROM}@" commit subject body sha="" line
  commit="$(git log --format='%H %s' "$target_sha" |
    awk -v p="$prefix" '!found && substr($0, 42, length(p)) == p { print substr($0, 1, 40); found = 1 }')"
  [[ -n "$commit" ]] || return 0
  body="$(git log -1 --format=%B "$commit")"
  while IFS= read -r line; do
    if [[ "$line" == "Snapshot of ${FROM} "* ]]; then
      line="${line#"Snapshot of ${FROM} "}"
      if [[ "${line:0:40}" =~ ^[0-9a-f]{40}$ ]]; then sha="${line:0:40}"; break; fi
    fi
  done <<< "$body"
  if [[ -z "$sha" ]]; then
    subject="$(subject_of "$commit")"
    sha="$(git rev-parse --verify --quiet "${subject#"$prefix"}^{commit}" || true)"
  fi
  [[ -n "$sha" ]] || die "cannot tell which ${FROM} commit the release $(short_of "$commit") covers. Run --snapshot once to create a new base."
  printf '%s %s\n' "$commit" "$sha"
}

# Paths changed by <commit> against its parent (deletions count), sorted.
# Extra args are pathspecs.
changed_paths() {
  local c="$1"; shift
  git -c core.quotePath=false diff-tree --no-renames --no-commit-id -r --name-only "${c}^" "$c" "$@" |
    LC_ALL=C sort -u
}

base_line="$(find_release_base)"
if [[ -z "$base_line" ]]; then
  die "'${TO}' has no 'release: ${FROM}@…' commit to start from. Run 'bash scripts/release-to-master.sh --snapshot' once; later releases copy commits."
fi
read -r base_release base_sha <<< "$base_line"
git cat-file -e "${base_sha}^{commit}" 2>/dev/null ||
  die "base commit ${base_sha} (from release $(short_of "$base_release")) is not in this repository. Fetch it, or release with --snapshot."
git merge-base --is-ancestor "$base_sha" "$source_sha" ||
  die "base commit $(short_of "$base_sha") (from release $(short_of "$base_release")) is not in '${FROM}' (history rewritten?). Release with --snapshot."

# Commits on the target after the base release: copies (with the trailer
# naming a commit in base..<from>) are already released; anything else (no
# trailer, or a trailer naming a commit outside that range, e.g. a cherry-pick
# from a feature branch) was made on the target only.
released=""
diverged=""
while IFS= read -r t; do
  [[ -n "$t" ]] || continue
  ts="$(trailer_sha "$t")"
  if [[ -n "$ts" ]] &&
     git merge-base --is-ancestor "$ts" "$source_sha" 2>/dev/null &&
     ! git merge-base --is-ancestor "$ts" "$base_sha" 2>/dev/null; then
    released+="${ts}"$'\n'
  else
    diverged+="$(short_of "$t") $(subject_of "$t")"$'\n'
  fi
done < <(git rev-list "${base_release}..${target_sha}")
if [[ -n "$diverged" ]]; then
  echo "release-to-master: '${TO}' has commits after release $(short_of "$base_release") that are not copies from '${FROM}':" >&2
  printf '%s' "$diverged" | sed 's/^/  /' >&2
  die "bring those changes into '${FROM}' first, then re-run with --snapshot --allow-diverged (the snapshot replaces them)."
fi

merges="$(git log --merges --format='%h %s' "${base_sha}..${source_sha}")"
if [[ -n "$merges" ]]; then
  echo "release-to-master: '${FROM}' has merge commits after release base $(short_of "$base_sha"):" >&2
  printf '%s\n' "$merges" | sed 's/^/  /' >&2
  die "copy mode cannot copy merge commits. Release with --snapshot."
fi

echo "release-to-master: ${FROM}@${source_short} → ${TO} (copy mode, base ${FROM}@$(short_of "$base_sha") from release $(short_of "$base_release")):"

gpg_args=()
[[ "$DRY_RUN" == "true" ]] && gpg_args=(--no-gpg-sign)

tip="$target_sha"
copied=0
while IFS= read -r c; do
  [[ -n "$c" ]] || continue
  grep -qxF "$c" <<< "$released" && continue
  short="$(short_of "$c")"
  subject="$(subject_of "$c")"

  all="$(changed_paths "$c")"
  if [[ -z "$all" ]]; then
    echo "  skip (empty) ${short} ${subject}"
    continue
  fi
  work="$(changed_paths "$c" -- "${RELEASE_EXCLUDE_SPECS[@]}")"
  core="$(LC_ALL=C comm -23 <(printf '%s\n' "$all") <(printf '%s\n' "$work"))"
  if [[ -z "$core" ]]; then
    echo "  skip (work-only) ${short} ${subject}"
    continue
  fi
  if [[ -n "$work" ]]; then
    {
      echo "release-to-master: ${short} ${subject} — mixes framework core and work-only paths (.release-exclude)."
      echo "Core paths:"
      printf '%s\n' "$core" | sed 's/^/  /'
      echo "Work-only paths:"
      printf '%s\n' "$work" | sed 's/^/  /'
    } >&2
    die "copy mode cannot split a commit. Release with --snapshot, and keep core and work-only paths in separate commits."
  fi

  rc=0
  merge_out="$(git merge-tree --write-tree --name-only --no-messages --merge-base="${c}^" "$tip" "$c")" || rc=$?
  if [[ "$rc" -eq 1 ]]; then
    {
      echo "release-to-master: ${short} ${subject} — does not apply cleanly to '${TO}'. Conflicting paths:"
      printf '%s\n' "$merge_out" | tail -n +2 | sed '/^$/d' | sed 's/^/  /'
    } >&2
    die "nothing written. Check how '${TO}' differs from '${FROM}', or release with --snapshot."
  elif [[ "$rc" -ne 0 ]]; then
    die "git merge-tree failed for ${short} (exit ${rc})."
  fi
  new_tree="$(head -n 1 <<< "$merge_out")"
  if [[ "$new_tree" == "$(git rev-parse "${tip}^{tree}")" ]]; then
    echo "  skip (already on ${TO}) ${short} ${subject}"
    continue
  fi

  message="$(git log -1 --format=%B "$c")"
  tip="$(printf '%s\n\n(cherry picked from commit %s)\n' "$message" "$c" |
    GIT_AUTHOR_NAME="$(git log -1 --format=%an "$c")" \
    GIT_AUTHOR_EMAIL="$(git log -1 --format=%ae "$c")" \
    GIT_AUTHOR_DATE="$(git log -1 --format=%ad --date=raw "$c")" \
    git commit-tree ${gpg_args[@]+"${gpg_args[@]}"} "$new_tree" -p "$tip" -F -)"
  copied=$((copied + 1))
  echo "  copy ${short} ${subject}"
done < <(git rev-list --reverse --topo-order "${base_sha}..${source_sha}")

# Post-check: the copies must give exactly the filtered source tree.
expected_tree="$(filtered_tree "$source_sha")" || die "stopped — nothing written."
if [[ "$(git rev-parse "${tip}^{tree}")" != "$expected_tree" ]]; then
  {
    echo "release-to-master: after copying, '${TO}' would differ from ${FROM}@${source_short} without work-only paths:"
    git diff --stat "$tip" "$expected_tree" | tail -n 25
  } >&2
  die "nothing written. Release with --snapshot to bring '${TO}' in line."
fi

if [[ "$copied" -eq 0 ]]; then
  echo "release-to-master: nothing to release — '${TO}' already has every core commit of ${FROM}@${source_short}."
  exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo "release-to-master: dry run — ${copied} commit(s) would be copied; nothing written."
  exit 0
fi

# Compare-and-swap: fails if the target moved while the script ran.
git update-ref -m "release-to-master: copy ${FROM}@${source_short}" "$target_ref" "$tip" "$target_sha"

echo "release-to-master: ${TO} is now $(short_of "$tip") (${copied} commit(s) copied from ${FROM}@${source_short})."
echo "Review:  git log --stat ${target_sha:0:12}..${TO}"
echo "Publish: git push origin ${TO}"
