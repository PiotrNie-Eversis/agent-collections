/**
 * Claude Code PreToolUse / PostToolUse hook: spec artifact guard.
 *
 * Source template for .claude/hooks/eversis-validate-spec.cjs, written by
 * adapters/claude/generate-hooks.mjs (which fills in FRAMEWORK_PREFIX and
 * appends the GENERATED marker). Registered in .claude/settings.json as
 *   node "${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs"
 * twice: under PostToolUse with matcher Write|Edit|MultiEdit|Bash, and under
 * PreToolUse with matcher Bash. The launcher tells the cases apart from the
 * hook_event_name and tool_name fields of the hook input on stdin.
 *
 * After every Write / Edit / MultiEdit, the hook checks whether the written
 * file is a research (*.research.md) or plan (*.plan.md) file under
 * docs/specs/. If it is, the file is validated against the framework
 * template by scripts/validate-spec-artifacts.mjs. Gaps go to stderr with
 * exit code 2, which Claude Code shows to the model so it can fix the file
 * before a human gate. Every other write passes through untouched.
 *
 * Shell writes (printf >>, sed -i, tee, a script ...) do not say which files
 * they touch, so Bash is handled in two steps:
 *   - PreToolUse + Bash records the start time of the command in a marker
 *     file under <os tmp dir>/eversis-validate-spec-<uid>/ (a private 0700
 *     directory; a symlink or a directory owned by another user is never
 *     used). The key is session_id + tool_use_id, or a hash of session_id
 *     and the command when tool_use_id is missing. Markers older than 24
 *     hours are removed whenever a new one is written. This step never
 *     prints and always exits 0, whatever goes wrong, so it can never block
 *     a command.
 *   - PostToolUse + Bash reads and deletes that marker (no marker: exit 0,
 *     for example a settings file without the PreToolUse entry), lists the
 *     research and plan files under docs/specs/ modified since the start
 *     time (symlinks, node_modules and dot-directories are not walked), and
 *     validates each of them exactly like a Write. One gap report is printed
 *     per failing file, with the legacy hint and the end-of-life warning
 *     printed once at the end, and the exit code is 2. Files the command
 *     deleted are not reported.
 *
 * Why old-syntax CommonJS: an unsupported Node (older than 18) must still be
 * able to parse this file and print the Node version message instead of a
 * syntax error. So: no optional chaining, no nullish coalescing, no static
 * ES module syntax. The ESM validator is loaded through a Function-wrapped
 * dynamic import, which keeps this file parseable on old Node; the version
 * check runs before that wrapper is ever called.
 *
 * Exit codes (hook mode):
 *   0  not a spec artifact, malformed hook input, or the file passes; for
 *      Bash: always on PreToolUse, and on PostToolUse when no marker exists,
 *      no spec artifact changed, or every changed one passes
 *   2  the file has template gaps, Node is too old to validate, or the
 *      validator cannot be found (the guard never switches itself off
 *      silently for a spec file); for Bash the same applies to the spec
 *      artifacts the command changed
 *
 * Self-test mode (used by the installer's --doctor):
 *   node eversis-validate-spec.cjs --self-test
 * resolves the validator for the project exactly as a hook run does,
 * validates a built-in bad plan held in memory, and prints
 * "eversis-validate-spec self-test: ok" with exit 0 only when gaps are
 * reported. Any problem exits 1 with the reason. It reads no project spec
 * file and writes nothing.
 *
 * Stdlib only. main() runs only when executed directly, so tests can
 * require() the helpers.
 */
"use strict";

var crypto = require("crypto");
var fs = require("fs");
var os = require("os");
var path = require("path");
var url = require("url");

/**
 * Where the framework lives, relative to the project root, as passed to the
 * generator's --framework-prefix:
 *   ""                          self-host (framework is the project)
 *   "vendor/agent-collections"  vendored copy or submodule
 *   "${AGENT_COLLECTIONS_HOME}" local mode (machine-local checkout)
 */
var FRAMEWORK_PREFIX = "__EVERSIS_FRAMEWORK_PREFIX__";

var LOCAL_MODE_TOKEN = "${AGENT_COLLECTIONS_HOME}";
var VALIDATOR_REL = "scripts/validate-spec-artifacts.mjs";
var FRAMEWORK_HOME_FILE = ".agent-collections/framework-home.txt";
var SELF_TEST_OK = "eversis-validate-spec self-test: ok";
var MIN_NODE = 18;
var SUPPORTED_NODE = 22;
var SPEC_ARTIFACT = /^docs\/specs\/([^/]+\/)*[^/]+\.(plan|research)\.md$/;
var SPECS_DIR_REL = "docs/specs";
var MARKER_DIR_PREFIX = "eversis-validate-spec-";
var MARKER_SUFFIX = ".json";
var MARKER_MAX_AGE_MS = 24 * 60 * 60 * 1000;
/** Longer sanitised keys are hashed so the marker file name stays short. */
var MARKER_KEY_MAX = 128;

/**
 * A plan that breaks the template on purpose: no required sections and a
 * task without a [CREATE|MODIFY|REUSE] marker. Used only by --self-test.
 */
var SELF_TEST_PLAN = [
  "# PROJ-123 self-test - Implementation Plan",
  "",
  "## Implementation Plan",
  "",
  "### Phase 1: Example",
  "",
  "#### Task 1.1 - Task without a marker",
  "",
  "Body without the required fields.",
  "",
].join("\n");

/**
 * Node version policy: below 18 the validator cannot run, 18 to 21 still
 * works but is past end of life, 22 or newer is supported.
 * @param {string} version e.g. "22.3.0" or "v12.22.0"
 * @returns {"ok" | "warn" | "error"}
 */
function nodeVersionStatus(version) {
  var major = parseInt(String(version).replace(/^v/, "").split(".")[0], 10);
  if (isNaN(major) || major < MIN_NODE) return "error";
  if (major < SUPPORTED_NODE) return "warn";
  return "ok";
}

/** Forward slashes, collapsed "." / ".." segments, no trailing slash. */
function normalizeSlashes(p) {
  var normalized = path.posix.normalize(String(p).replace(/\\/g, "/"));
  if (normalized.length > 1 && normalized.charAt(normalized.length - 1) === "/") {
    normalized = normalized.slice(0, -1);
  }
  return normalized;
}

function isAbsoluteAnyOs(p) {
  return p.charAt(0) === "/" || /^[A-Za-z]:\//.test(p);
}

/** Relative tail of filePath under dir, or null (both already normalised). */
function relativeUnder(filePath, dir) {
  // Windows paths compare case-insensitively (drive letter and folders).
  var windows = /^[A-Za-z]:\//.test(dir) || /^[A-Za-z]:\//.test(filePath);
  var a = windows ? filePath.toLowerCase() : filePath;
  var b = windows ? dir.toLowerCase() : dir;
  if (b === "/") return a.charAt(0) === "/" ? filePath.slice(1) : null;
  if (a.indexOf(b + "/") !== 0) return null;
  return filePath.slice(dir.length + 1);
}

function realpathOrNull(p) {
  try {
    return normalizeSlashes(fs.realpathSync(p));
  } catch (err) {
    return null;
  }
}

/**
 * Map the file path from the hook input (absolute, possibly with Windows
 * backslashes) to a forward-slash path relative to the project root.
 * A relative path is taken as relative to the project root.
 * @param {string} filePath
 * @param {string} projectDir
 * @returns {string | null} null when the file is outside the project
 */
function toProjectRelative(filePath, projectDir) {
  if (typeof filePath !== "string" || filePath === "") return null;
  if (typeof projectDir !== "string" || projectDir === "") return null;
  var file = normalizeSlashes(filePath);
  var dir = normalizeSlashes(projectDir);
  var rel;
  if (!isAbsoluteAnyOs(file)) {
    rel = file;
  } else {
    rel = relativeUnder(file, dir);
    if (rel === null) {
      // The project dir may reach the file through a symlink (for example
      // /tmp and /private/tmp on macOS): compare the real paths too.
      var realFile = realpathOrNull(filePath);
      var realDir = realpathOrNull(projectDir);
      if (realFile && realDir) rel = relativeUnder(realFile, realDir);
    }
  }
  if (rel === null || rel === "" || rel === "." || rel === ".." || rel.indexOf("../") === 0) {
    return null;
  }
  return rel;
}

/** True for a *.plan.md or *.research.md file at any depth under docs/specs/. */
function isSpecArtifact(relPath) {
  return typeof relPath === "string" && SPEC_ARTIFACT.test(relPath);
}

function nonEmptyString(value) {
  return typeof value === "string" && value !== "" ? value : "";
}

function sha256Hex(text) {
  return crypto.createHash("sha256").update(text, "utf8").digest("hex");
}

/**
 * Marker file key for a Bash call, the same in its PreToolUse and
 * PostToolUse runs: session_id + tool_use_id reduced to [A-Za-z0-9_-].
 * Without tool_use_id, a hash of session_id and tool_input.command is used
 * instead. A sanitised key longer than MARKER_KEY_MAX is hashed too.
 * @param {{ session_id?: string, tool_use_id?: string, tool_input?: { command?: string } }} input
 * @returns {string} "" when the input carries nothing to build a key from
 */
function markerKey(input) {
  if (!input || typeof input !== "object") return "";
  var session = nonEmptyString(input.session_id);
  var toolUse = nonEmptyString(input.tool_use_id);
  var toolInput = input.tool_input && typeof input.tool_input === "object" ? input.tool_input : {};
  var command = nonEmptyString(toolInput.command);
  if (toolUse) {
    var key = (session + "-" + toolUse).replace(/[^A-Za-z0-9_-]/g, "");
    if (key.length > MARKER_KEY_MAX) return "k-" + sha256Hex(key).slice(0, 40);
    if (key.replace(/-/g, "") !== "") return key;
  }
  if (!session && !command) return "";
  return "h-" + sha256Hex(session + "\u0000" + command).slice(0, 40);
}

/**
 * Research and plan files under <projectDir>/docs/specs whose modification
 * time is at or after sinceMs. Symlinks below docs/specs are not followed
 * (neither directories nor files), and node_modules and dot-directories are
 * skipped. Unreadable entries are skipped silently.
 * @param {string} projectDir
 * @param {number} sinceMs
 * @returns {string[]} project-relative forward-slash paths, sorted
 */
function changedSpecArtifacts(projectDir, sinceMs) {
  var found = [];
  if (typeof projectDir !== "string" || projectDir === "") return found;
  if (typeof sinceMs !== "number" || isNaN(sinceMs)) return found;
  function visit(absDir, relDir) {
    var names;
    try {
      names = fs.readdirSync(absDir);
    } catch (err) {
      return;
    }
    for (var i = 0; i < names.length; i++) {
      var name = names[i];
      var abs = path.join(absDir, name);
      var rel = relDir + "/" + name;
      var stat;
      try {
        stat = fs.lstatSync(abs);
      } catch (err) {
        continue;
      }
      if (stat.isSymbolicLink()) continue;
      if (stat.isDirectory()) {
        if (name.charAt(0) === "." || name === "node_modules") continue;
        visit(abs, rel);
      } else if (stat.isFile() && isSpecArtifact(rel) && stat.mtimeMs >= sinceMs) {
        found.push(rel);
      }
    }
  }
  // docs/specs itself is read even when it is a symlink (the project chose
  // that layout); only links below it are skipped.
  visit(path.join(projectDir, SPECS_DIR_REL), SPECS_DIR_REL);
  return found.sort();
}

/** Current user id, or null where the platform has none (Windows). */
function currentUid() {
  return typeof process.getuid === "function" ? process.getuid() : null;
}

/** Name part for the marker directory: the uid, or the user name on Windows. */
function markerDirOwnerTag() {
  var uid = currentUid();
  if (uid !== null) return String(uid);
  try {
    var name = String(os.userInfo().username).replace(/[^A-Za-z0-9_-]/g, "");
    if (name) return name;
  } catch (err) {
    // fall through
  }
  return "user";
}

/**
 * Private marker directory, created with mode 0700 when missing. Returns
 * null when it cannot be used: not creatable, a symlink, not a directory,
 * owned by another user, or writable by group or others. On Windows, where
 * there are no uids, only the symlink and directory checks apply.
 * @returns {string | null}
 */
function markerDir() {
  var dir = path.join(os.tmpdir(), MARKER_DIR_PREFIX + markerDirOwnerTag());
  try {
    try {
      fs.mkdirSync(dir, 448); // 0700
    } catch (err) {
      if (!err || err.code !== "EEXIST") return null;
    }
    var stat = fs.lstatSync(dir);
    if (stat.isSymbolicLink() || !stat.isDirectory()) return null;
    var uid = currentUid();
    if (uid !== null) {
      if (stat.uid !== uid) return null;
      if ((stat.mode & 18) !== 0) return null; // 0022: group/other write
    }
    return dir;
  } catch (err) {
    return null;
  }
}

/** Remove marker files older than MARKER_MAX_AGE_MS. Errors are ignored. */
function removeStaleMarkers(dir, nowMs) {
  var names;
  try {
    names = fs.readdirSync(dir);
  } catch (err) {
    return;
  }
  for (var i = 0; i < names.length; i++) {
    if (names[i].slice(-MARKER_SUFFIX.length) !== MARKER_SUFFIX) continue;
    var file = path.join(dir, names[i]);
    try {
      var stat = fs.lstatSync(file);
      if (nowMs - stat.mtimeMs > MARKER_MAX_AGE_MS) fs.unlinkSync(file);
    } catch (err) {
      // ignore
    }
  }
}

/**
 * Framework root for the project, from the generated prefix. The
 * environment and framework-home.txt are consulted only in local mode, so
 * a vendored or self-host project is never redirected to another checkout.
 * @returns {{ root: string | null, reason: string }}
 */
function resolveFrameworkRoot(projectDir, prefix, env) {
  if (prefix === "") return { root: projectDir, reason: "self-host" };
  if (prefix !== LOCAL_MODE_TOKEN) {
    return { root: path.join(projectDir, prefix), reason: "vendored" };
  }
  var homeFile = path.join(projectDir, FRAMEWORK_HOME_FILE);
  var recorded = "";
  try {
    recorded = fs.readFileSync(homeFile, "utf8").split(/\r?\n/)[0].trim();
  } catch (err) {
    recorded = "";
  }
  if (recorded) return { root: recorded, reason: "local mode (" + FRAMEWORK_HOME_FILE + ")" };
  var fromEnv = env && env.AGENT_COLLECTIONS_HOME ? String(env.AGENT_COLLECTIONS_HOME).trim() : "";
  if (fromEnv) return { root: fromEnv, reason: "local mode (AGENT_COLLECTIONS_HOME)" };
  return {
    root: null,
    reason:
      "local mode, but " + FRAMEWORK_HOME_FILE + " is missing and AGENT_COLLECTIONS_HOME is not set",
  };
}

/**
 * Absolute validator path for the project, or an error message.
 * @returns {{ validator: string | null, error: string | null }}
 */
function locateValidator(projectDir, prefix, env) {
  var resolved = resolveFrameworkRoot(projectDir, prefix, env);
  if (!resolved.root) {
    return { validator: null, error: "framework root not found: " + resolved.reason };
  }
  var validator = path.resolve(resolved.root, VALIDATOR_REL);
  if (!fs.existsSync(validator)) {
    return {
      validator: null,
      error: "validator not found at " + validator + " (framework root: " + resolved.reason + ")",
    };
  }
  return { validator: validator, error: null };
}

/** Load the ESM validator. Kept behind Function so old Node still parses this file. */
function importValidator(validatorPath) {
  var dynamicImport = new Function("u", "return import(u)");
  return dynamicImport(url.pathToFileURL(validatorPath).href);
}

function versionMessage(version) {
  return (
    "eversis-validate-spec: Node " + version + " found, Agent Collections needs Node " +
    SUPPORTED_NODE + " or newer. The spec artifact check cannot run; install Node " +
    SUPPORTED_NODE + "+ from https://nodejs.org"
  );
}

function endOfLifeWarning(version) {
  return (
    "warning: Node " + version + " is past end of life; Agent Collections supports Node " +
    SUPPORTED_NODE + " or newer."
  );
}

function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch (err) {
    return "";
  }
}

function writeErr(text) {
  process.stderr.write(text + "\n");
}

/**
 * PreToolUse + Bash: record the command start time in the marker file.
 * Never prints and always returns 0: a failure here must not block the
 * command; the matching PostToolUse run then finds no marker and exits 0.
 * @returns {number}
 */
function runBashPre(data) {
  try {
    var key = markerKey(data);
    if (!key) return 0;
    var dir = markerDir();
    if (!dir) return 0;
    var now = Date.now();
    removeStaleMarkers(dir, now);
    var file = path.join(dir, key + MARKER_SUFFIX);
    // Replace, never write through, whatever is already at that name.
    try {
      fs.unlinkSync(file);
    } catch (err) {
      // usually not there
    }
    fs.writeFileSync(file, JSON.stringify({ time: now }) + "\n", { mode: 384, flag: "wx" }); // 0600
  } catch (err) {
    // Swallowed on purpose: see above.
  }
  return 0;
}

/**
 * Read and delete the marker for this Bash call.
 * The baseline is the earlier of the time stored in the marker and the
 * marker file's own modification time, so a file system clock that lags
 * Date.now() slightly cannot hide a write made right after PreToolUse.
 * @returns {number | null} start time in ms, or null when there is no usable marker
 */
function takeMarker(data) {
  var key = markerKey(data);
  if (!key) return null;
  var dir = markerDir();
  if (!dir) return null;
  var file = path.join(dir, key + MARKER_SUFFIX);
  var stat;
  try {
    stat = fs.lstatSync(file);
  } catch (err) {
    return null;
  }
  var stored = NaN;
  try {
    if (stat.isFile()) stored = Number(JSON.parse(fs.readFileSync(file, "utf8")).time);
  } catch (err) {
    stored = NaN;
  }
  try {
    fs.unlinkSync(file);
  } catch (err) {
    // ignore: the stale-marker sweep removes it later
  }
  if (!stat.isFile() || isNaN(stored)) return null;
  return Math.min(stored, stat.mtimeMs);
}

/**
 * PostToolUse + Bash: validate every spec artifact modified since the
 * matching PreToolUse run. Resolves to the exit code.
 */
function runBashPost(env, data) {
  var projectDir = env.CLAUDE_PROJECT_DIR || (typeof data.cwd === "string" ? data.cwd : "");
  var since;
  var changed;
  try {
    since = takeMarker(data);
    if (since === null || !projectDir) return Promise.resolve(0);
    changed = changedSpecArtifacts(projectDir, since);
  } catch (err) {
    return Promise.resolve(0);
  }
  if (changed.length === 0) return Promise.resolve(0);

  var version = process.versions.node;
  var status = nodeVersionStatus(version);
  if (status === "error") {
    writeErr(versionMessage(version));
    return Promise.resolve(2);
  }
  var located = locateValidator(projectDir, FRAMEWORK_PREFIX, env);
  if (!located.validator) {
    writeErr("eversis-validate-spec: cannot check " + changed.join(", ") + ": " + located.error);
    return Promise.resolve(2);
  }
  return importValidator(located.validator).then(function (mod) {
    // A validator that exports LEGACY_HINT can leave it out of each report
    // ({ hint: false }), so it is printed once after all of them. Otherwise
    // each report keeps whatever the validator puts in it.
    var hintOnce = typeof mod.LEGACY_HINT === "string" && mod.LEGACY_HINT !== "";
    var reports = [];
    for (var i = 0; i < changed.length; i++) {
      var rel = changed[i];
      var text;
      try {
        text = fs.readFileSync(path.join(projectDir, rel), "utf8");
      } catch (err) {
        continue; // removed again before we got here
      }
      var kind = mod.detectKind(rel);
      var result = mod.validateSpecArtifact({
        kind: kind,
        text: text,
        templateText: mod.readTemplate(kind),
      });
      if (result.ok) continue;
      reports.push(hintOnce ? mod.formatGapReport(rel, result.gaps, { hint: false }) : mod.formatGapReport(rel, result.gaps));
    }
    if (reports.length === 0) return 0;
    var output = reports.join("\n");
    if (hintOnce) output += "\n" + mod.LEGACY_HINT;
    if (status === "warn") output += "\n" + endOfLifeWarning(version);
    writeErr(output);
    return 2;
  });
}

/** Hook mode. Resolves to the exit code. */
function runHook(env, stdinText) {
  var data;
  try {
    data = JSON.parse(stdinText);
  } catch (err) {
    return Promise.resolve(0);
  }
  if (!data || typeof data !== "object") return Promise.resolve(0);
  if (data.tool_name === "Bash") {
    if (data.hook_event_name === "PreToolUse") return Promise.resolve(runBashPre(data));
    if (data.hook_event_name === "PostToolUse") return runBashPost(env, data);
    return Promise.resolve(0);
  }
  var toolInput = data.tool_input && typeof data.tool_input === "object" ? data.tool_input : {};
  var projectDir = env.CLAUDE_PROJECT_DIR || (typeof data.cwd === "string" ? data.cwd : "");
  var rel = toProjectRelative(toolInput.file_path, projectDir);
  if (!isSpecArtifact(rel)) return Promise.resolve(0);

  var version = process.versions.node;
  var status = nodeVersionStatus(version);
  if (status === "error") {
    writeErr(versionMessage(version));
    return Promise.resolve(2);
  }
  var located = locateValidator(projectDir, FRAMEWORK_PREFIX, env);
  if (!located.validator) {
    writeErr("eversis-validate-spec: cannot check " + rel + ": " + located.error);
    return Promise.resolve(2);
  }
  var text;
  try {
    text = fs.readFileSync(path.join(projectDir, rel), "utf8");
  } catch (err) {
    // Nothing on disk to check (for example a failed write).
    return Promise.resolve(0);
  }
  return importValidator(located.validator).then(function (mod) {
    var kind = mod.detectKind(rel);
    var result = mod.validateSpecArtifact({
      kind: kind,
      text: text,
      templateText: mod.readTemplate(kind),
    });
    if (result.ok) return 0;
    var report = mod.formatGapReport(rel, result.gaps);
    if (status === "warn") report += "\n" + endOfLifeWarning(version);
    writeErr(report);
    return 2;
  });
}

/** --self-test mode. Resolves to the exit code. */
function runSelfTest(env) {
  var projectDir = env.CLAUDE_PROJECT_DIR || path.resolve(__dirname, "..", "..");
  var version = process.versions.node;
  if (nodeVersionStatus(version) === "error") {
    writeErr(versionMessage(version));
    return Promise.resolve(1);
  }
  var located = locateValidator(projectDir, FRAMEWORK_PREFIX, env);
  if (!located.validator) {
    writeErr("eversis-validate-spec self-test: " + located.error);
    return Promise.resolve(1);
  }
  return importValidator(located.validator).then(function (mod) {
    var result = mod.validateSpecArtifact({
      kind: "plan",
      text: SELF_TEST_PLAN,
      templateText: mod.readTemplate("plan"),
    });
    if (result.ok || result.gaps.length === 0) {
      writeErr(
        "eversis-validate-spec self-test: the built-in bad plan passed validation (validator at " +
          located.validator + " reports no gaps)",
      );
      return 1;
    }
    process.stdout.write(SELF_TEST_OK + "\n");
    return 0;
  });
}

function main() {
  var args = process.argv.slice(2);
  var selfTest = args[0] === "--self-test";
  var run = selfTest ? runSelfTest(process.env) : runHook(process.env, readStdin());
  run.then(
    function (code) {
      process.exitCode = code;
    },
    function (err) {
      var message = err && err.message ? err.message : String(err);
      writeErr(
        (selfTest ? "eversis-validate-spec self-test: " : "eversis-validate-spec: ") +
          "validator failed: " + message,
      );
      process.exitCode = selfTest ? 1 : 2;
    },
  );
}

module.exports = {
  nodeVersionStatus: nodeVersionStatus,
  toProjectRelative: toProjectRelative,
  isSpecArtifact: isSpecArtifact,
  resolveFrameworkRoot: resolveFrameworkRoot,
  markerKey: markerKey,
  changedSpecArtifacts: changedSpecArtifacts,
  SELF_TEST_OK: SELF_TEST_OK,
};

if (require.main === module) {
  main();
}
