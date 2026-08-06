#!/usr/bin/env bash
# Non-interactive smoke test for setup-agent-collections.sh (DHI-534 / 538).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ac-smoke.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

TARGET="${TMP}/consumer"
mkdir -p "$TARGET"
(cd "$TARGET" && git init -q)

echo "[smoke] target=${TARGET}"
START="$(date +%s)"

bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --non-interactive \
  --build-mcp \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=frontend \
  --link-mode=copy

END="$(date +%s)"
ELAPSED=$((END - START))
echo "[smoke] elapsed=${ELAPSED}s"

SEL="${TARGET}/.agent-collections/install-selection.json"
[[ -f "$SEL" ]] || { echo "FAIL: missing selection"; exit 1; }
node -e '
  const j=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));
  const req=["frameworkVersion","agents","mcpServers","domainProfile","vendorMode","linkMode"];
  for (const k of req) if (j[k]==null) { console.error("missing",k); process.exit(1); }
  if (!j.agents.includes("cursor")) process.exit(1);
  if (j.domainProfile!=="frontend") process.exit(1);
  console.log("selection OK", JSON.stringify(j,null,2));
' "$SEL"

[[ -f "${TARGET}/.cursor/mcp.json" ]] || { echo "FAIL: missing mcp.json"; exit 1; }
grep -q 'AGENT_COLLECTIONS_HOME' "${TARGET}/.cursor/mcp.json" \
  || { echo "FAIL: mcp.json missing AGENT_COLLECTIONS_HOME"; exit 1; }
[[ -f "${TARGET}/AGENTS.md" ]] || { echo "FAIL: missing AGENTS.md"; exit 1; }
[[ -f "${TARGET}/.agent-collections/area-profile.txt" ]] || { echo "FAIL: missing area profile"; exit 1; }
grep -q 'frontend-scope' "${TARGET}/.agent-collections/area-profile.txt"

# Upgrade reuse
bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$TARGET" \
  --upgrade --sync --non-interactive

# Fail-safe missing selection
BAD="${TMP}/bad"
mkdir -p "$BAD"
(cd "$BAD" && git init -q)
if bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$BAD" \
  --upgrade --non-interactive 2>/tmp/ac-upgrade-fail.txt; then
  echo "FAIL: upgrade without selection should fail"
  exit 1
fi
grep -qi 'install-selection' /tmp/ac-upgrade-fail.txt \
  || { echo "FAIL: expected fail-safe message"; cat /tmp/ac-upgrade-fail.txt; exit 1; }

# Corrupt selection
mkdir -p "${BAD}/.agent-collections"
echo '{not-json' > "${BAD}/.agent-collections/install-selection.json"
if bash "${ROOT}/scripts/setup-agent-collections.sh" \
  --collections-home "$ROOT" \
  --target "$BAD" \
  --upgrade --non-interactive 2>/tmp/ac-upgrade-corrupt.txt; then
  echo "FAIL: corrupt selection should fail"
  exit 1
fi
grep -qiE 'invalid|corrupt|wizard|missing' /tmp/ac-upgrade-corrupt.txt \
  || { echo "FAIL: expected corrupt fail-safe"; cat /tmp/ac-upgrade-corrupt.txt; exit 1; }

if [[ "$ELAPSED" -gt 300 ]]; then
  echo "WARN: smoke exceeded 5 minutes (${ELAPSED}s)"
else
  echo "[smoke] under 5 minutes OK"
fi

echo "[smoke] PASS"
