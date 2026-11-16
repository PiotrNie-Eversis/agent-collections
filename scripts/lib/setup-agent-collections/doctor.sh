#!/usr/bin/env bash
# lib/setup-agent-collections/doctor.sh — read-only install health check (--doctor).
#
# Sourced after common.sh and link-framework.sh. The entry script calls
# run_doctor right after detect_os, before require_node_version and before
# anything that resolves, clones, fetches, links, syncs or writes. Everything
# here only reads: no mkdir, no temp files, no git commands that change state,
# and Node is started only for read-only JSON parsing and the hook launcher's
# --self-test (which reads no project file and writes nothing).
#
# Each check prints exactly one line, and every check runs even when an earlier
# one failed, so one run shows every problem. A Node that cannot run the
# framework scripts (status "error") skips only the checks that need Node,
# each with a line saying so; the settings entry check then falls back to grep.

# Launcher path as it appears in the framework hook command in
# .claude/settings.json (see claude-settings-merge.mjs). Also the launcher's
# location relative to the target.
DOCTOR_HOOK_LAUNCHER_REL=".claude/hooks/eversis-validate-spec.cjs"
DOCTOR_SELF_TEST_OK="eversis-validate-spec self-test: ok"

DOCTOR_FAILED=0
DOCTOR_CHECKS=0

# One result line. Args: status (ok | warn | fail | skip), check name, detail.
# Only "fail" makes the doctor exit 1; "warn" and "skip" are informational
# (a skip is always paired with the failed check that caused it).
_doctor_line() {
  local status="$1" name="$2" detail="$3" tag
  DOCTOR_CHECKS=$((DOCTOR_CHECKS + 1))
  case "$status" in
    ok)   tag="${_GREEN}OK  ${_RESET}" ;;
    warn) tag="${_YELLOW}WARN${_RESET}" ;;
    skip) tag="${_CYAN}SKIP${_RESET}" ;;
    *)    tag="${_RED}FAIL${_RESET}"; DOCTOR_FAILED=$((DOCTOR_FAILED + 1)) ;;
  esac
  echo "  [${tag}] ${name}: ${detail}"
}

# Prints the target directory without side effects: --target, else the git
# root of the current directory, else the current directory. Unlike
# resolve_target_dir it never prompts (the doctor must not wait for input) and
# never dies. Returns 1 (and prints nothing) when --target is not a directory.
_doctor_target_dir() {
  if [[ -n "${ARG_TARGET:-}" ]]; then
    (cd "$ARG_TARGET" 2>/dev/null && pwd) || return 1
    return 0
  fi
  local git_root=""
  if command -v git >/dev/null 2>&1; then
    git_root="$(git rev-parse --show-toplevel 2>/dev/null)" || git_root=""
  fi
  if [[ -n "$git_root" ]]; then
    echo "$git_root"
  else
    pwd
  fi
}

# Prints the vendorMode recorded in $1 (install-selection.json), or nothing.
# Uses Node when $2 is "true", otherwise a line-based read of the JSON the
# installer writes (one "key": "value" pair per line).
_doctor_recorded_vendor_mode() {
  local sel="$1" node_ok="$2"
  [[ -f "$sel" ]] || return 0
  if [[ "$node_ok" == "true" ]]; then
    node -e "
      try {
        const j = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'));
        if (typeof j.vendorMode === 'string') process.stdout.write(j.vendorMode);
      } catch (e) { /* reported by the agents check */ }
    " "$sel" 2>/dev/null || true
    return 0
  fi
  sed -n 's/.*"vendorMode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$sel" 2>/dev/null | head -n 1
}

# Prints the first line of .agent-collections/framework-home.txt, or nothing.
_doctor_framework_home_file() {
  local file="$1/.agent-collections/framework-home.txt"
  [[ -f "$file" ]] || return 0
  head -n 1 "$file" 2>/dev/null | tr -d '\r'
}

# True when $1 looks like a framework checkout (same marker as
# ensure_framework_checkout).
_doctor_is_framework() {
  [[ -n "$1" ]] && [[ -d "$1/.ai/skills" ]]
}

# Agents CSV from install-selection.json ($1) via Node. Returns 1 when the
# file is unreadable, not JSON or has no agents array.
_doctor_recorded_agents() {
  node -e "
    let j;
    try { j = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); }
    catch (e) { process.exit(1); }
    if (!Array.isArray(j.agents)) process.exit(1);
    process.stdout.write(j.agents.map((s) => String(s).trim()).filter(Boolean).join(','));
  " "$1" 2>/dev/null
}

# Agents whose skills mirror is present on disk under $1 (claude, cursor).
_doctor_agents_on_disk() {
  local target="$1" out=""
  [[ -d "${target}/.claude/skills" ]] && out="claude"
  [[ -d "${target}/.cursor/skills" ]] && out="${out:+${out},}cursor"
  printf '%s' "$out"
}

# One line for one skills mirror, reusing _verify_skills_mirror (run in a
# subshell with this run's framework home and target; its own log lines are
# captured and folded into the single result line).
_doctor_check_mirror() {
  local agent="$1" dst_rel="$2" label="$3" home="$4" target="$5" agents="$6"
  if ! echo ",${agents}," | grep -q ",${agent},"; then
    _doctor_line skip "$label" "${agent} not selected"
    return 0
  fi
  if ! _doctor_is_framework "$home"; then
    _doctor_line fail "$label" "cannot check ${dst_rel}/: framework home not found"
    return 0
  fi
  local out
  if out="$(COLLECTIONS_HOME="$home" TARGET_DIR="$target" _verify_skills_mirror "$agent" "$dst_rel" 2>&1)"; then
    _doctor_line ok "$label" "$(printf '%s\n' "$out" | sed -n 's/.*\(Verified .*\)/\1/p' | head -n 1)"
    return 0
  fi
  local missing
  missing="$(printf '%s\n' "$out" | sed -n "s|.*missing: ${dst_rel}/\([^/]*\)/SKILL.md.*|\1|p" | paste -sd ',' - | sed 's/,/, /g')"
  _doctor_line fail "$label" "no readable SKILL.md for ${missing:-some skill packages} in ${dst_rel}/; fix: re-run with --upgrade --sync --link-mode copy"
}

# Read-only health check of an existing install. Prints one line per check
# and a summary; returns 0 when every check passes, 1 otherwise. Never dies,
# never writes: safe to run on a broken install.
run_doctor() {
  DOCTOR_FAILED=0
  DOCTOR_CHECKS=0
  echo "Agent Collections doctor (read-only)"

  # --- Node -----------------------------------------------------------------
  local node_status node_version node_ok="false"
  read -r node_status node_version <<< "$(node_version_status)"
  case "$node_status" in
    ok)
      node_ok="true"
      _doctor_line ok "Node" "${node_version}"
      ;;
    warn)
      node_ok="true"
      _doctor_line warn "Node" "${node_version} is end-of-life and not tested; use Node ${NODE_MIN_SUPPORTED_MAJOR} or newer"
      ;;
    *)
      case "$node_version" in
        missing) _doctor_line fail "Node" "node not found on PATH; Agent Collections needs Node ${NODE_MIN_SUPPORTED_MAJOR} or newer. $(node_version_hint)" ;;
        unknown) _doctor_line fail "Node" "could not read the Node version; Agent Collections needs Node ${NODE_MIN_SUPPORTED_MAJOR} or newer. $(node_version_hint)" ;;
        *)       _doctor_line fail "Node" "Node ${node_version} found, Agent Collections needs Node ${NODE_MIN_SUPPORTED_MAJOR} or newer. $(node_version_hint)" ;;
      esac
      ;;
  esac

  # --- Target ---------------------------------------------------------------
  local target
  if ! target="$(_doctor_target_dir)" || [[ -z "$target" ]]; then
    _doctor_line fail "Target" "cannot access --target directory: ${ARG_TARGET:-}"
    echo "Doctor: cannot continue without a target directory."
    return 1
  fi
  _doctor_line ok "Target" "$target"
  local sel="${target}/.agent-collections/install-selection.json"

  # --- Framework home (read-only lookup, never cloned) ----------------------
  # 1. vendor mode recorded in install-selection.json; 2. no record:
  # vendor/agent-collections, then framework-home.txt; 3. this installer's
  # own checkout.
  local home="" home_source="" home_error=""
  local vendor_mode
  vendor_mode="$(_doctor_recorded_vendor_mode "$sel" "$node_ok")"
  case "$vendor_mode" in
    submodule|copy)
      home="${target}/vendor/agent-collections"
      home_source="recorded vendor mode ${vendor_mode}"
      _doctor_is_framework "$home" || home_error="recorded vendor mode is ${vendor_mode}, but ${home} has no .ai/skills; fix: git submodule update --init --recursive, or re-run the installer with --upgrade --sync"
      ;;
    local)
      home="$(_doctor_framework_home_file "$target")"
      home_source="recorded vendor mode local, .agent-collections/framework-home.txt"
      if [[ -z "$home" ]]; then
        home_error="recorded vendor mode is local, but .agent-collections/framework-home.txt is missing or empty; fix: re-run the installer with --upgrade --sync"
      elif ! _doctor_is_framework "$home"; then
        home_error="recorded vendor mode is local, but ${home} (from .agent-collections/framework-home.txt) has no .ai/skills"
      fi
      ;;
    *)
      if _doctor_is_framework "${target}/vendor/agent-collections"; then
        home="${target}/vendor/agent-collections"
        home_source="vendor/agent-collections"
      else
        home="$(_doctor_framework_home_file "$target")"
        if _doctor_is_framework "$home"; then
          home_source=".agent-collections/framework-home.txt"
        else
          home="$(cd "${SETUP_SCRIPT_DIR}/.." 2>/dev/null && pwd)"
          home_source="this installer's checkout"
          _doctor_is_framework "$home" || home_error="no framework found (no vendor/agent-collections, no usable .agent-collections/framework-home.txt, and ${home} has no .ai/skills)"
        fi
      fi
      ;;
  esac
  if [[ -n "$home_error" ]]; then
    _doctor_line fail "Framework home" "$home_error"
  else
    _doctor_line ok "Framework home" "${home} (${home_source})"
  fi

  # --- Selected agents ------------------------------------------------------
  local agents="" agents_source=""
  if [[ -n "${ARG_AGENTS:-}" ]]; then
    agents="${ARG_AGENTS// /}"
    _doctor_line ok "Agents" "${agents} (from --agents)"
  elif [[ -f "$sel" ]] && [[ "$node_ok" == "true" ]]; then
    if agents="$(_doctor_recorded_agents "$sel")"; then
      _doctor_line ok "Agents" "${agents:-none} (from .agent-collections/install-selection.json)"
    else
      agents="$(_doctor_agents_on_disk "$target")"
      _doctor_line fail "Agents" ".agent-collections/install-selection.json is not valid JSON or has no agents list; checking the mirrors on disk (${agents:-none}); fix: re-run the installer"
    fi
  else
    agents="$(_doctor_agents_on_disk "$target")"
    if [[ -f "$sel" ]]; then
      agents_source="Node cannot parse .agent-collections/install-selection.json, so the mirrors on disk are checked"
    else
      agents_source="no .agent-collections/install-selection.json, so the mirrors on disk are checked"
    fi
    if [[ -z "$agents" ]] && [[ ! -f "$sel" ]]; then
      _doctor_line fail "Agents" "no install found (no .agent-collections/install-selection.json, no .claude/skills/ or .cursor/skills/); run the installer first"
    else
      _doctor_line ok "Agents" "${agents:-none} (${agents_source})"
    fi
  fi

  # --- Skills mirrors -------------------------------------------------------
  _doctor_check_mirror claude .claude/skills "Claude skills mirror" "$home" "$target" "$agents"
  _doctor_check_mirror cursor .cursor/skills "Cursor skills mirror" "$home" "$target" "$agents"

  # --- Claude spec artifact hook -------------------------------------------
  if ! echo ",${agents}," | grep -q ',claude,'; then
    _doctor_line skip "Claude hook entry" "claude not selected"
    _doctor_line skip "Claude hook launcher" "claude not selected"
    _doctor_line skip "Claude hook self-test" "claude not selected"
  else
    local settings="${target}/.claude/settings.json"
    local launcher="${target}/${DOCTOR_HOOK_LAUNCHER_REL}"
    local hook_fix="fix: re-run the installer with --upgrade --sync"

    # Entry: the two framework entries claude-settings-merge.mjs writes must
    # both run the launcher (a hook whose command names the launcher, same
    # rule as isFrameworkHook in claude-settings-merge.mjs):
    #   - a PreToolUse entry whose matcher matches Bash (records when a shell
    #     command starts);
    #   - a PostToolUse entry whose matcher includes Bash (validates spec
    #     artifacts written by Write/Edit/MultiEdit or changed by a shell
    #     command).
    # A matcher is split on "|"; "*" or an empty / missing matcher matches
    # every tool. Node prints "ok" or the problems, comma-separated:
    # "missing PreToolUse entry", "missing PostToolUse entry", or "PostToolUse
    # matcher without Bash" (a PostToolUse entry runs the launcher, but none
    # covers Bash, as in the older single Write|Edit|MultiEdit entry; a plain
    # --upgrade --sync rewrites it). grep fallback when Node cannot run: a
    # text match on the launcher path only.
    if [[ ! -f "$settings" ]]; then
      _doctor_line fail "Claude hook entry" ".claude/settings.json is missing; ${hook_fix}"
    elif [[ "$node_ok" == "true" ]]; then
      local entry_state
      if entry_state="$(node -e "
        let j;
        try { j = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); }
        catch (e) { process.exit(2); }
        const launcher = process.argv[2];
        const hooks = j && typeof j === 'object' && j.hooks && typeof j.hooks === 'object' ? j.hooks : {};
        const runsLauncher = (e) => e && Array.isArray(e.hooks) && e.hooks.some((h) =>
          h && typeof h.command === 'string' && h.command.replace(/\\\\/g, '/').includes(launcher));
        const matchesBash = (e) => {
          const m = typeof e.matcher === 'string' ? e.matcher.trim() : '';
          if (m === '' || m === '*') return true;
          return m.split('|').map((s) => s.trim()).some((s) => s === 'Bash' || s === '*');
        };
        const framework = (event) => (Array.isArray(hooks[event]) ? hooks[event] : []).filter(runsLauncher);
        const pre = framework('PreToolUse');
        const post = framework('PostToolUse');
        const missing = [];
        if (!pre.some(matchesBash)) missing.push('missing PreToolUse entry');
        if (post.length === 0) missing.push('missing PostToolUse entry');
        else if (!post.some(matchesBash)) missing.push('PostToolUse matcher without Bash');
        process.stdout.write(missing.length ? missing.join(', ') : 'ok');
      " "$settings" "$DOCTOR_HOOK_LAUNCHER_REL" 2>/dev/null)"; then
        if [[ "$entry_state" == "ok" ]]; then
          _doctor_line ok "Claude hook entry" ".claude/settings.json PreToolUse (Bash) and PostToolUse (with Bash) run ${DOCTOR_HOOK_LAUNCHER_REL}"
        else
          _doctor_line fail "Claude hook entry" ".claude/settings.json framework hook: ${entry_state} (both PreToolUse with Bash and PostToolUse with Bash must run ${DOCTOR_HOOK_LAUNCHER_REL}); ${hook_fix}"
        fi
      else
        _doctor_line fail "Claude hook entry" ".claude/settings.json is not valid JSON; fix the file by hand, then re-run the installer with --upgrade --sync"
      fi
    elif grep -qF "$DOCTOR_HOOK_LAUNCHER_REL" "$settings" 2>/dev/null; then
      _doctor_line ok "Claude hook entry" ".claude/settings.json mentions ${DOCTOR_HOOK_LAUNCHER_REL} (text match; Node cannot parse the file)"
    else
      _doctor_line fail "Claude hook entry" ".claude/settings.json does not mention ${DOCTOR_HOOK_LAUNCHER_REL}; ${hook_fix}"
    fi

    local launcher_ok="false"
    if [[ -f "$launcher" ]] && [[ -r "$launcher" ]]; then
      launcher_ok="true"
      _doctor_line ok "Claude hook launcher" "${DOCTOR_HOOK_LAUNCHER_REL} present"
    else
      _doctor_line fail "Claude hook launcher" "${DOCTOR_HOOK_LAUNCHER_REL} is missing; ${hook_fix}"
    fi

    if [[ "$node_ok" != "true" ]]; then
      _doctor_line skip "Claude hook self-test" "skipped: Node ${node_version} cannot run the launcher"
    elif [[ "$launcher_ok" != "true" ]]; then
      _doctor_line skip "Claude hook self-test" "skipped: launcher missing"
    else
      local st_out st_rc=0
      st_out="$(CLAUDE_PROJECT_DIR="$target" node "$launcher" --self-test 2>&1)" || st_rc=$?
      if [[ "$st_rc" -eq 0 ]] && printf '%s\n' "$st_out" | grep -qxF "$DOCTOR_SELF_TEST_OK"; then
        _doctor_line ok "Claude hook self-test" "$DOCTOR_SELF_TEST_OK"
      else
        local reason
        reason="$(printf '%s\n' "$st_out" | grep -v '^[[:space:]]*$' | head -n 1)"
        _doctor_line fail "Claude hook self-test" "exit ${st_rc}, no '${DOCTOR_SELF_TEST_OK}' line${reason:+: ${reason}}; ${hook_fix}"
      fi
    fi
  fi

  if [[ "$DOCTOR_FAILED" -eq 0 ]]; then
    echo "Doctor: all ${DOCTOR_CHECKS} checks passed."
    return 0
  fi
  echo "Doctor: ${DOCTOR_FAILED} of ${DOCTOR_CHECKS} checks failed."
  return 1
}
