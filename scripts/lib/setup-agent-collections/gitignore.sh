#!/usr/bin/env bash
# lib/setup-agent-collections/gitignore.sh — manage .gitignore local block (Agent Collections).

readonly _GITIGNORE_MARKER_START="# agent-collections local [begin]"
readonly _GITIGNORE_MARKER_END="# agent-collections local [end]"
readonly _GITIGNORE_ARTIFACTS_START="# agent-collections agent-artifacts [begin]"
readonly _GITIGNORE_ARTIFACTS_END="# agent-collections agent-artifacts [end]"

_local_gitignore_lines() {
  cat <<'LINES'
.cursor/mcp.json
.agent-collections/framework-home.txt
LINES
}

_artifact_gitignore_lines() {
  cat <<'LINES'
docs/specs/*/
docs/context/*/
LINES
}

_has_marker() {
  grep -qF "$_GITIGNORE_MARKER_START" "${1}" 2>/dev/null
}

_has_artifacts_subblock() {
  grep -qF "$_GITIGNORE_ARTIFACTS_START" "${1}" 2>/dev/null
}

_remove_marker_block() {
  local file="$1"
  if _has_marker "$file"; then
    local tmp
    tmp="$(mktemp)"
    awk -v start="${_GITIGNORE_MARKER_START}" -v end="${_GITIGNORE_MARKER_END}" '
      index($0, start) == 1 { skip=1; next }
      index($0, end) == 1 { skip=0; next }
      !skip { print }
    ' "$file" > "$tmp" && mv "$tmp" "$file"
    log_info "Removed local gitignore block from ${file}"
  fi
  # Also strip legacy cursor-collections markers if present
  if grep -qF "# cursor-collections local [begin]" "$file" 2>/dev/null; then
    local tmp
    tmp="$(mktemp)"
    awk '
      index($0, "# cursor-collections local [begin]") == 1 { skip=1; next }
      index($0, "# cursor-collections local [end]") == 1 { skip=0; next }
      !skip { print }
    ' "$file" > "$tmp" && mv "$tmp" "$file"
  fi
}

_append_local_block() {
  local file="$1"
  local with_artifacts="${2:-false}"

  {
    echo ""
    echo "$_GITIGNORE_MARKER_START"
    _local_gitignore_lines
    if [[ "$with_artifacts" == "true" ]]; then
      echo "$_GITIGNORE_ARTIFACTS_START"
      _artifact_gitignore_lines
      echo "$_GITIGNORE_ARTIFACTS_END"
    fi
    echo "$_GITIGNORE_MARKER_END"
  } >> "$file"
  log_ok "Added agent-collections local entries to ${file}"
}

_refresh_local_gitignore_block() {
  local file="$1"
  local with_artifacts="${2:-false}"
  _remove_marker_block "$file"
  _append_local_block "$file" "$with_artifacts"
  log_ok "Refreshed agent-collections local gitignore block"
}

manage_gitignore() {
  local gi="${TARGET_DIR}/.gitignore"
  local want_artifacts="false"
  [[ "${ARG_GITIGNORE_AGENT_ARTIFACTS:-false}" == "true" ]] && want_artifacts="true"

  if [[ "${VENDOR_MODE:-}" == "submodule" ]] || [[ "${VENDOR_MODE:-}" == "copy" ]]; then
    if [[ "$want_artifacts" == "true" ]]; then
      log_warn "--gitignore-agent-artifacts is ignored in vendor mode."
    fi
    _remove_marker_block "$gi"
    return 0
  fi

  if _has_marker "$gi"; then
    _refresh_local_gitignore_block "$gi" "$want_artifacts"
    return 0
  fi

  touch "$gi"
  _append_local_block "$gi" "$want_artifacts"
}
