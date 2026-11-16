#!/usr/bin/env bash
# lib/setup-agent-collections/ignore-triad.sh — merge framework ignore classes without wipe.

merge_ignore_triad() {
  require_cmd node "Install Node.js 22 or newer"
  node "${LIB_DIR}/merge-ignore-triad.mjs" \
    --home "${COLLECTIONS_HOME}" \
    --target "${TARGET_DIR}" \
    --agents "${SELECTED_AGENTS:-cursor}" \
    || log_warn "Ignore triad merge reported issues (non-fatal)."
  return 0
}
