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

echo "Case 1: release from develop"
before_master="$(git rev-parse master)"
bash scripts/release-to-master.sh >/dev/null
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

echo "Case 2: nothing to release"
out="$(bash scripts/release-to-master.sh)"
grep -q "nothing to release" <<< "$out" || fail "expected nothing-to-release"
ok "idempotent"

echo "Case 3: deletion on develop reaches master"
g rm -q docs/architecture/a.md && g commit -q -m "drop arch"
bash scripts/release-to-master.sh >/dev/null
git ls-tree -r --name-only master | grep -q "docs/architecture/a.md" && fail "deletion not released"
ok "deletions propagate"

echo "Case 4: dry run writes nothing"
echo "core v3" > core.txt && g commit -qam "core v3"
m="$(git rev-parse master)"
bash scripts/release-to-master.sh --dry-run | grep -q "dry run" || fail "dry-run message"
[[ "$(git rev-parse master)" == "$m" ]] || fail "dry run moved master"
ok "dry run"

echo "Case 5: diverged master is refused unless --allow-diverged"
g switch -q master
echo "hotfix" > hotfix.txt && g add hotfix.txt && g commit -q --no-verify -m "hotfix on master"
g switch -q develop
if bash scripts/release-to-master.sh >/dev/null 2>&1; then fail "diverged release should fail"; fi
bash scripts/release-to-master.sh --allow-diverged >/dev/null 2>&1 || fail "--allow-diverged should release"
git ls-tree -r --name-only master | grep -qx "hotfix.txt" && fail "snapshot should replace master-only file"
echo "core v4" > core.txt && g commit -qam "core v4"
bash scripts/release-to-master.sh >/dev/null 2>&1 || fail "commits replaced by an earlier release must not block the next one"
ok "divergence guard (only commits after the latest release count)"

echo "Case 6: refuses to run on the target branch"
g switch -q master
if bash scripts/release-to-master.sh >/dev/null 2>&1; then fail "should refuse on master"; fi
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
ok "hook blocks work-only docs on master only"

echo "PASS (${pass} cases)"
