#!/usr/bin/env bash
# release-to-master.test.sh — tests for scripts/release-to-master.sh and
# .githooks/pre-commit in a throwaway repository (no network, no remote).
#
# Usage (repo root): bash scripts/release-to-master.test.sh

set -euo pipefail

SRC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/release-to-master.test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

pass=0
fail() { echo "FAIL: $*" >&2; exit 1; }
ok() { pass=$((pass + 1)); echo "  ok - $*"; }

g() { git -c user.email=test@example.com -c user.name=test -c commit.gpgsign=false "$@"; }

REPO="${WORK}/repo"
mkdir -p "$REPO"
cd "$REPO"
g init -q -b master
mkdir -p scripts/lib .githooks
cp "${SRC_ROOT}/.release-exclude" .
cp "${SRC_ROOT}/scripts/release-to-master.sh" scripts/
cp "${SRC_ROOT}/scripts/check-release-tree.sh" scripts/
cp "${SRC_ROOT}/scripts/lib/release-paths.sh" scripts/lib/
cp "${SRC_ROOT}/.githooks/pre-commit" .githooks/
chmod +x .githooks/pre-commit
echo "core v1" > core.txt
mkdir -p docs/architecture && echo "arch" > docs/architecture/a.md
g add -A && g commit -q -m "initial core"

# develop: core change + work-only docs + kept READMEs.
g switch -q -c develop
echo "core v2" > core.txt
mkdir -p docs/specs/ac-1-x docs/context/proj/comp docs/reports docs/plans docs/decisions
echo "spec" > docs/specs/ac-1-x/ac-1-x.plan.md
echo "specs readme" > docs/specs/README.md
echo "idx" > docs/context/proj/INDEX.md
echo "comp" > docs/context/proj/comp/index.md
echo "ctx readme" > docs/context/README.md
echo "report" > docs/reports/r1.md
echo "reports readme" > docs/reports/README.md
echo "plans readme" > docs/plans/README.md
echo "plan" > docs/plans/p1.md
echo "dec" > docs/decisions/0001-x.md
echo "dec idx" > docs/decisions/INDEX.md
echo "dec readme" > docs/decisions/README.md
echo "zażółć" > "docs/specs/ac-1-x/Porównanie okna.md"
g add -A && g commit -q -m "develop work"

echo "Case 1: snapshot release from develop"
before_master="$(git rev-parse master)"
bash scripts/release-to-master.sh --snapshot >/dev/null
files="$(git ls-tree -r --name-only master)"
for kept in core.txt docs/architecture/a.md docs/specs/README.md docs/context/README.md \
            docs/reports/README.md docs/plans/README.md docs/decisions/README.md .release-exclude; do
  grep -qxF "$kept" <<< "$files" || fail "kept path missing on master: $kept"
done
for gone in docs/specs/ac-1-x/ac-1-x.plan.md docs/context/proj/INDEX.md docs/context/proj/comp/index.md \
            docs/reports/r1.md docs/plans/p1.md docs/decisions/0001-x.md docs/decisions/INDEX.md; do
  grep -qxF "$gone" <<< "$files" && fail "work-only path leaked to master: $gone"
done
git ls-tree -r --name-only master | grep -q "Porównanie" && fail "non-ASCII work-only path leaked"
[[ "$(git show master:core.txt)" == "core v2" ]] || fail "core change not released"
[[ "$(git rev-parse master^)" == "$before_master" ]] || fail "release parent is not previous master"
[[ "$(git log -1 --format=%P master | wc -w | tr -d ' ')" == "1" ]] || fail "release commit must have one parent"
git log -1 --format=%s master | grep -q "^release: develop@" || fail "release subject"
ok "work-only paths stripped, READMEs and core kept, single-parent release commit"

echo "Case 2: nothing to release (snapshot)"
out="$(bash scripts/release-to-master.sh --snapshot)"
grep -q "nothing to release" <<< "$out" || fail "expected nothing-to-release"
ok "idempotent"

echo "Case 3: deletion on develop reaches master (snapshot)"
g rm -q docs/architecture/a.md && g commit -q -m "drop arch"
bash scripts/release-to-master.sh --snapshot >/dev/null
git ls-tree -r --name-only master | grep -q "docs/architecture/a.md" && fail "deletion not released"
ok "deletions propagate"

echo "Case 4: snapshot dry run writes nothing"
echo "core v3" > core.txt && g commit -qam "core v3"
m="$(git rev-parse master)"
bash scripts/release-to-master.sh --snapshot --dry-run | grep -q "dry run" || fail "dry-run message"
[[ "$(git rev-parse master)" == "$m" ]] || fail "dry run moved master"
ok "dry run"

echo "Case 5: diverged master is refused unless --snapshot --allow-diverged"
g switch -q master
echo "hotfix" > hotfix.txt && g add hotfix.txt && g commit -q --no-verify -m "hotfix on master"
g switch -q develop
if bash scripts/release-to-master.sh --snapshot >/dev/null 2>&1; then fail "diverged release should fail"; fi
bash scripts/release-to-master.sh --snapshot --allow-diverged >/dev/null 2>&1 || fail "--allow-diverged should release"
git ls-tree -r --name-only master | grep -qx "hotfix.txt" && fail "snapshot should replace master-only file"
echo "core v4" > core.txt && g commit -qam "core v4"
bash scripts/release-to-master.sh --snapshot >/dev/null 2>&1 || fail "commits replaced by an earlier release must not block the next one"
ok "divergence guard (only commits after the latest release count)"

echo "Case 6: refuses to run on the target branch"
g switch -q master
if bash scripts/release-to-master.sh --snapshot >/dev/null 2>&1; then fail "should refuse on master"; fi
if bash scripts/release-to-master.sh >/dev/null 2>&1; then fail "copy mode should refuse on master"; fi
ok "branch guard"

echo "Case 7: pre-commit hook"
git config core.hooksPath .githooks
mkdir -p docs/specs/ac-2 && echo "x" > docs/specs/ac-2/a.md && g add docs/specs/ac-2/a.md
if g commit -q -m "should be blocked" 2>/dev/null; then fail "hook should block docs on master"; fi
g reset -q
echo "core fix" >> core.txt && g add core.txt
g commit -q -m "core fix on master" || fail "hook should allow core files on master"
echo "readme" > docs/specs/README.md && g add docs/specs/README.md
g commit -q -m "readme on master" || fail "hook should allow README on master"
g switch -q develop
mkdir -p docs/specs/ac-3 && echo "y" > docs/specs/ac-3/a.md && g add docs/specs/ac-3/a.md
g commit -q -m "spec on develop" || fail "hook should allow docs on develop"
ok "hook blocks work-only paths on master, allows them alone on develop"

echo "Case 8: CI check (scripts/check-release-tree.sh)"
bash scripts/check-release-tree.sh master >/dev/null 2>&1 || fail "clean master should pass"
if bash scripts/check-release-tree.sh develop >/dev/null 2>&1; then fail "develop has work-only paths and should fail"; fi
g switch -q master
mkdir -p docs/reports && echo "leak" > docs/reports/leak.md && g add docs/reports/leak.md
g commit -q --no-verify -m "bypass hook"
rc=0; bash scripts/check-release-tree.sh HEAD >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 1 ]] || fail "hook-bypassing commit on master should exit 1 (got $rc)"
rc=0; bash scripts/check-release-tree.sh no-such-ref >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 2 ]] || fail "unknown ref should exit 2 (got $rc)"
ok "CI check passes clean master, fails on work-only paths (exit 1) and bad refs (exit 2)"

echo "Case 9: pre-commit hook rejects mixed core + work-only commits off master"
g switch -q develop
mkdir -p adapters/x docs/specs/ac-4
echo "a1" > adapters/x/a.md && echo "s1" > docs/specs/ac-4/a.md
g add adapters/x/a.md docs/specs/ac-4/a.md
err="$(g commit -q -m "mixed" 2>&1 >/dev/null)" && fail "hook should reject a mixed commit on develop"
grep -qx "  adapters/x/a.md" <<< "$err" || fail "mixed message should list the core path"
grep -qx "  docs/specs/ac-4/a.md" <<< "$err" || fail "mixed message should list the work-only path"
grep -q "git restore --staged" <<< "$err" || fail "mixed message should show how to split"
grep -q "ALLOW_MIXED_COMMIT=1" <<< "$err" || fail "mixed message should mention the escape hatch"
g restore --staged docs/specs/ac-4/a.md
g commit -q -m "core only" || fail "hook should allow a core-only commit on develop"
g add docs/specs/ac-4/a.md
g commit -q -m "docs(ac-4)" || fail "hook should allow a work-only-only commit on develop"
echo "specs readme v2" > docs/specs/README.md && echo "a2" > adapters/x/a.md
g add docs/specs/README.md adapters/x/a.md
g commit -q -m "readme + core" || fail "hook should treat docs/specs/README.md as core"
g rm -q docs/specs/ac-4/a.md && echo "a3" > adapters/x/a.md && g add adapters/x/a.md
if g commit -q -m "delete spec + core" 2>/dev/null; then fail "hook should reject a work-only deletion mixed with core"; fi
ALLOW_MIXED_COMMIT=1 g commit -q -m "deliberate mix" || fail "ALLOW_MIXED_COMMIT=1 should allow a mixed commit"
g switch -q --detach
echo "a4" > adapters/x/a.md && mkdir -p docs/specs/ac-5 && echo "s5" > docs/specs/ac-5/a.md
g add adapters/x/a.md docs/specs/ac-5/a.md
if g commit -q -m "mixed detached" 2>/dev/null; then fail "hook should reject a mixed commit on detached HEAD"; fi
g reset -q --hard && rm -rf docs/specs/ac-5
g switch -q master
mkdir -p docs/specs/ac-6 && echo "z" > docs/specs/ac-6/a.md && g add docs/specs/ac-6/a.md
if g commit -q -m "spec on master" 2>/dev/null; then fail "hook should still block work-only paths on master"; fi
if ALLOW_MIXED_COMMIT=1 g commit -q -m "spec on master" 2>/dev/null; then
  fail "ALLOW_MIXED_COMMIT must not lift the master block"
fi
g reset -q && rm -rf docs/specs/ac-6
ok "mixed commits rejected off master (incl. deletions, detached HEAD); single-group, README and ALLOW_MIXED_COMMIT pass; master block unchanged"

# --- Copy mode (default) ------------------------------------------------------
# A fresh repository: master gets a first snapshot (the base), then develop
# gains core, work-only, empty, deletion and rename commits.

# new_repo <dir>: master with core files, develop with work-only docs, the
# release scripts and the hook enabled. Leaves the shell in <dir> on develop.
new_repo() {
  mkdir -p "$1" && cd "$1"
  g init -q -b master
  mkdir -p scripts/lib .githooks
  cp "${SRC_ROOT}/.release-exclude" .
  cp "${SRC_ROOT}/scripts/release-to-master.sh" "${SRC_ROOT}/scripts/check-release-tree.sh" scripts/
  cp "${SRC_ROOT}/scripts/lib/release-paths.sh" scripts/lib/
  cp "${SRC_ROOT}/.githooks/pre-commit" .githooks/ && chmod +x .githooks/pre-commit
  echo "core v1" > core.txt && echo "old" > old.txt
  mkdir -p docs/architecture && echo "arch" > docs/architecture/a.md
  g add -A && g commit -q -m "initial core"
  git config core.hooksPath .githooks
  g switch -q -c develop
  mkdir -p docs/specs/ac-1-x && echo "spec" > docs/specs/ac-1-x/ac-1-x.plan.md
  g add -A && g commit -q -m "docs(ac-1): spec"
  echo "readme" > README.md && g add README.md && g commit -q -m "docs: readme"
}

# commit_as <message> — commit staged changes with a fixed author and date.
commit_as() {
  GIT_AUTHOR_NAME="Alice Author" GIT_AUTHOR_EMAIL="alice@example.com" \
    GIT_AUTHOR_DATE="1700000000 +0100" g commit -q --allow-empty -m "$1"
}

new_repo "${WORK}/copy"
bash scripts/release-to-master.sh --snapshot >/dev/null
base_master="$(git rev-parse master)"

echo "Case 10 (a, i): copy mode copies only core commits, in order, with author, date and trailer"
echo "core v2" > core.txt && g add core.txt && commit_as "feat: core v2"
c1="$(git rev-parse HEAD)"
mkdir -p docs/context/proj && echo "idx" > docs/context/proj/INDEX.md
g add docs/context/proj/INDEX.md && commit_as "docs(context): index"
w1="$(git rev-parse HEAD)"
mkdir -p adapters && echo "adapter" > adapters/y.md && g add adapters/y.md && commit_as "feat: adapter"
c2="$(git rev-parse HEAD)"
commit_as "chore: empty"
e1="$(git rev-parse HEAD)"
g rm -q old.txt && commit_as "chore: drop old"
c3="$(git rev-parse HEAD)"
g mv docs/architecture/a.md docs/architecture/renamed.md && commit_as "docs: rename arch"
c4="$(git rev-parse HEAD)"
out="$(bash scripts/release-to-master.sh)"
grep -q "skip (work-only) $(git rev-parse --short "$w1")" <<< "$out" || fail "work-only commit should be listed as skipped"
grep -q "skip (empty) $(git rev-parse --short "$e1")" <<< "$out" || fail "empty commit should be listed as skipped"
[[ "$(git log --format=%s --reverse "${base_master}..master" | tr '\n' '|')" == \
   "feat: core v2|feat: adapter|chore: drop old|docs: rename arch|" ]] || fail "copied subjects or order wrong"
[[ "$(git rev-list --merges "${base_master}..master" | wc -l | tr -d ' ')" == "0" ]] || fail "copies must be single-parent"
i=0
for src in "$c1" "$c2" "$c3" "$c4"; do
  copy="$(git rev-list --reverse "${base_master}..master" | sed -n "$((i + 1))p")"
  i=$((i + 1))
  [[ "$(git log -1 --format='%an <%ae> %ad' --date=raw "$copy")" == "Alice Author <alice@example.com> 1700000000 +0100" ]] ||
    fail "copy of ${src} should keep the original author and date"
  git log -1 --format=%B "$copy" | grep -qx "(cherry picked from commit ${src})" || fail "copy of ${src} lacks the trailer"
done
[[ "$(git show master:core.txt)" == "core v2" ]] || fail "core change not copied"
git ls-tree -r --name-only master | grep -qx "old.txt" && fail "deletion not copied"
git ls-tree -r --name-only master | grep -qx "docs/architecture/renamed.md" || fail "rename not copied"
git ls-tree -r --name-only master | grep -qx "docs/architecture/a.md" && fail "rename source left on master"
git ls-tree -r --name-only master | grep -q "^docs/context/proj/" && fail "work-only path copied"
ok "core commits copied one by one (incl. deletion and rename); work-only and empty skipped"

echo "Case 11 (b): a second run copies nothing"
m="$(git rev-parse master)"
out="$(bash scripts/release-to-master.sh)"
grep -q "nothing to release" <<< "$out" || fail "second run should report nothing to release"
[[ "$(git rev-parse master)" == "$m" ]] || fail "second run moved master"
ok "already released commits are not copied again"

echo "Case 12 (d): CI check passes on master after a copy, without the note"
err="$(bash scripts/check-release-tree.sh master 2>&1 >/dev/null)" || fail "check-release-tree should pass after copy"
grep -q "note:" <<< "$err" && fail "no note expected for a copied commit"
g switch -q master
err="$(g commit -q --allow-empty -m "manual on master" 2>&1 && bash scripts/check-release-tree.sh HEAD 2>&1 >/dev/null)" ||
  fail "check-release-tree should pass on a clean manual commit"
grep -q "note:" <<< "$err" || fail "a manual master commit should get the note"
g reset -q --hard "$m" && g switch -q develop
ok "check-release-tree accepts copies, still notes other commits"

echo "Case 13 (g): copy-mode dry run lists commits and writes nothing"
echo "core v3" > core.txt && g add core.txt && commit_as "feat: core v3"
c5="$(git rev-parse HEAD)"
m="$(git rev-parse master)"
out="$(bash scripts/release-to-master.sh --dry-run)"
grep -q "  copy $(git rev-parse --short "$c5") feat: core v3" <<< "$out" || fail "dry run should list the copy"
grep -q "skip (work-only) $(git rev-parse --short "$w1")" <<< "$out" || fail "dry run should list skips"
grep -q "dry run" <<< "$out" || fail "dry-run message"
grep -q "nothing to release" <<< "$out" && fail "dry run with copies must not say nothing to release"
[[ "$(git rev-parse master)" == "$m" ]] || fail "dry run moved master"
bash scripts/release-to-master.sh >/dev/null || fail "release after dry run"
[[ "$(git show master:core.txt)" == "core v3" ]] || fail "core v3 not copied"
ok "dry run"

echo "Case 14 (c): a mixed commit stops the copy and is named"
echo "core v4" > core.txt && echo "s2" > docs/specs/ac-1-x/note.md
g add core.txt docs/specs/ac-1-x/note.md
ALLOW_MIXED_COMMIT=1 commit_as "feat: mixed"
mixed="$(git rev-parse --short HEAD)"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "mixed commit should stop the release"
grep -q "${mixed} feat: mixed" <<< "$err" || fail "mixed commit should be named"
grep -qx "  core.txt" <<< "$err" || fail "mixed message should list the core path"
grep -qx "  docs/specs/ac-1-x/note.md" <<< "$err" || fail "mixed message should list the work-only path"
grep -q -- "--snapshot" <<< "$err" || fail "mixed message should suggest --snapshot"
[[ "$(git rev-parse master)" == "$m" ]] || fail "mixed commit moved master"
bash scripts/release-to-master.sh --snapshot >/dev/null || fail "--snapshot should repair after a mixed commit"
bash scripts/release-to-master.sh | grep -q "nothing to release" || fail "copy mode should start from the new snapshot base"
ok "mixed commit stops, master unchanged; --snapshot sets a new base"

echo "Case 15 (e): a merge commit stops the copy"
g switch -q -c feature
echo "f" > feature.txt && g add feature.txt && commit_as "feat: feature"
g switch -q develop
echo "d" > dev.txt && g add dev.txt && commit_as "feat: dev"
g merge -q --no-ff --no-edit feature
merge="$(git rev-parse --short HEAD)"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh --dry-run 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "merge commit should stop the release"
grep -q "  ${merge} " <<< "$err" || fail "merge commit should be named"
[[ "$(git rev-parse master)" == "$m" ]] || fail "merge commit moved master"
bash scripts/release-to-master.sh --snapshot >/dev/null || fail "--snapshot should release past the merge"
ok "merge commit stops the copy"

echo "Case 16 (f): a master-only commit stops the copy; --allow-diverged needs --snapshot"
g switch -q master
echo "hotfix" > hotfix.txt && g add hotfix.txt && g commit -q -m "hotfix on master"
hotfix="$(git rev-parse --short HEAD)"
g switch -q develop
echo "core v5" > core.txt && g add core.txt && commit_as "feat: core v5"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "master-only commit should stop the release"
grep -q "  ${hotfix} hotfix on master" <<< "$err" || fail "master-only commit should be named"
grep -q -- "--snapshot --allow-diverged" <<< "$err" || fail "should suggest --snapshot --allow-diverged"
[[ "$(git rev-parse master)" == "$m" ]] || fail "master-only commit: master moved"
rc=0; err="$(bash scripts/release-to-master.sh --allow-diverged 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] && grep -q "only with --snapshot" <<< "$err" || fail "--allow-diverged without --snapshot should be refused"
bash scripts/release-to-master.sh --snapshot --allow-diverged >/dev/null 2>&1 || fail "--snapshot --allow-diverged should repair"
ok "master-only commit stops copy mode; --allow-diverged only with --snapshot"

echo "Case 17: a copy that does not apply stops, names the commit and paths"
# A hand-made master commit that claims to copy a develop commit (after the
# base) but has different content.
echo "core v6" > core.txt && g add core.txt && commit_as "feat: core v6"
x6="$(git rev-parse HEAD)"
g switch -q master
echo "core v6 on master" > core.txt && g add core.txt
g commit -q -m "fake copy" -m "(cherry picked from commit ${x6})"
g switch -q develop
echo "core v7" > core.txt && g add core.txt && commit_as "feat: core v7"
c7="$(git rev-parse --short HEAD)"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "conflicting copy should stop the release"
grep -q "${c7} feat: core v7 — does not apply cleanly" <<< "$err" || fail "conflicting commit should be named"
grep -qx "  core.txt" <<< "$err" || fail "conflicting path should be listed"
[[ "$(git rev-parse master)" == "$m" ]] || fail "conflict moved master"
ok "copy conflict stops, master unchanged"

echo "Case 18: post-check mismatch stops and writes nothing"
g reset -q --hard HEAD^ 2>/dev/null
bash scripts/release-to-master.sh --snapshot --allow-diverged >/dev/null 2>&1 || fail "repair snapshot"
echo "x2" > x2.txt && g add x2.txt && commit_as "feat: x2"
x2="$(git rev-parse HEAD)"
g switch -q master
echo "x2" > x2.txt && echo "extra" > extra.txt && g add x2.txt extra.txt
g commit -q -m "fake copy 2" -m "(cherry picked from commit ${x2})"
g switch -q develop
echo "core v8" > core.txt && g add core.txt && commit_as "feat: core v8"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "post-check mismatch should stop the release"
grep -q "would differ from develop@" <<< "$err" || fail "post-check message"
grep -q "extra.txt" <<< "$err" || fail "post-check should show the difference"
grep -q -- "--snapshot" <<< "$err" || fail "post-check should suggest --snapshot"
[[ "$(git rev-parse master)" == "$m" ]] || fail "post-check mismatch moved master"
ok "post-check mismatch stops, master unchanged"

echo "Case 19 (h): no release base on master stops with a hint"
new_repo "${WORK}/nobase"
echo "core v2" > core.txt && g add core.txt && commit_as "feat: core v2"
rc=0; err="$(bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "no base should stop the release"
grep -q "no 'release: develop@" <<< "$err" || fail "no-base message"
grep -q -- "--snapshot" <<< "$err" || fail "no-base message should suggest --snapshot"
[[ -z "$(git log --format=%s master | grep '^release:' || true)" ]] || fail "no-base run wrote a release"
ok "no base stops with a --snapshot hint"

echo "Case 20: copy mode stops on git older than 2.40"
mkdir -p "${WORK}/oldgit"
real_git="$(command -v git)"
cat > "${WORK}/oldgit/git" <<SH
#!/usr/bin/env bash
if [[ "\${1:-}" == "version" || "\${1:-}" == "--version" ]]; then echo "git version 2.39.5"; exit 0; fi
exec "${real_git}" "\$@"
SH
chmod +x "${WORK}/oldgit/git"
rc=0; err="$(PATH="${WORK}/oldgit:${PATH}" bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] && grep -q "needs git 2.40" <<< "$err" || fail "old git should stop copy mode"
ok "git < 2.40 stops copy mode with a clear message"

echo "Case 21: a failing filtered tree (bad TMPDIR) stops both modes, master unchanged"
new_repo "${WORK}/badtmp"
bash scripts/release-to-master.sh --snapshot >/dev/null
echo "core v2" > core.txt && g add core.txt && commit_as "feat: core v2"
m="$(git rev-parse master)"
rc=0; TMPDIR=/nonexistent bash scripts/release-to-master.sh --snapshot >/dev/null 2>&1 || rc=$?
[[ "$rc" -ne 0 ]] || fail "--snapshot with a bad TMPDIR should fail"
[[ "$(git rev-parse master)" == "$m" ]] || fail "--snapshot with a bad TMPDIR moved master"
rc=0; TMPDIR=/nonexistent bash scripts/release-to-master.sh >/dev/null 2>&1 || rc=$?
[[ "$rc" -ne 0 ]] || fail "copy mode with a bad TMPDIR should fail"
[[ "$(git rev-parse master)" == "$m" ]] || fail "copy mode with a bad TMPDIR moved master"
bash scripts/release-to-master.sh >/dev/null || fail "release with a good TMPDIR"
ok "filtered-tree failures stop the release instead of writing an empty tree"

echo "Case 22: a cherry-pick from another branch on master counts as diverged"
g switch -q -c feature2
echo "f" > f.txt && g add f.txt && commit_as "feat: feature only"
g switch -q master
g cherry-pick -x feature2 >/dev/null
picked="$(git rev-parse --short HEAD)"
g switch -q develop
echo "core v3" > core.txt && g add core.txt && commit_as "feat: core v3"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "foreign cherry-pick on master should stop copy mode"
grep -q "  ${picked} feat: feature only" <<< "$err" || fail "foreign cherry-pick should be named"
grep -q "not copies from 'develop'" <<< "$err" || fail "foreign cherry-pick should be reported as diverged"
[[ "$(git rev-parse master)" == "$m" ]] || fail "foreign cherry-pick: master moved"
ok "a trailer naming a commit outside base..develop is not a release"

echo "Case 23: a body line 'release: …' does not make a commit a release (snapshot guard)"
new_repo "${WORK}/bodyrelease"
bash scripts/release-to-master.sh --snapshot >/dev/null
g switch -q master
echo "hotfix" > hotfix.txt && g add hotfix.txt && g commit -q -m "hotfix on master"
g switch -q develop
echo "core v2" > core.txt && g add core.txt && commit_as "feat: core v2"
x="$(git rev-parse HEAD)"
g switch -q master
echo "core v2" > core.txt && g add core.txt
g commit -q -m "feat: core v2" -m "release: x" -m "(cherry picked from commit ${x})"
g switch -q develop
echo "core v3" > core.txt && g add core.txt && commit_as "feat: core v3"
m="$(git rev-parse master)"
rc=0; err="$(bash scripts/release-to-master.sh --snapshot 2>&1 >/dev/null)" || rc=$?
[[ "$rc" -eq 1 ]] || fail "hotfix hidden behind a body 'release:' line should stop --snapshot"
grep -q "hotfix on master" <<< "$err" || fail "hotfix should be listed"
[[ "$(git rev-parse master)" == "$m" ]] || fail "snapshot guard: master moved"
ok "snapshot guard looks at release subjects only"

echo "PASS (${pass} cases)"
