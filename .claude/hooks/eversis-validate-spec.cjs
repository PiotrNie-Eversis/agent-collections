/**
 * Claude Code PostToolUse hook: spec artifact guard.
 *
 * Source template for .claude/hooks/eversis-validate-spec.cjs, written by
 * adapters/claude/generate-hooks.mjs (which fills in FRAMEWORK_PREFIX and
 * appends the GENERATED marker). Registered in .claude/settings.json as
 *   node "${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs"
 * with matcher Write|Edit|MultiEdit.
 *
 * After every Write / Edit / MultiEdit, the hook checks whether the written
 * file is a research (*.research.md) or plan (*.plan.md) file under
 * docs/specs/. If it is, the file is validated against the framework
 * template by scripts/validate-spec-artifacts.mjs. Gaps go to stderr with
 * exit code 2, which Claude Code shows to the model so it can fix the file
 * before a human gate. Every other write passes through untouched.
 *
 * Why old-syntax CommonJS: an unsupported Node (older than 18) must still be
 * able to parse this file and print the Node version message instead of a
 * syntax error. So: no optional chaining, no nullish coalescing, no static
 * ES module syntax. The ESM validator is loaded through a Function-wrapped
 * dynamic import, which keeps this file parseable on old Node; the version
 * check runs before that wrapper is ever called.
 *
 * Exit codes (hook mode):
 *   0  not a spec artifact, malformed hook input, or the file passes
 *   2  the file has template gaps, Node is too old to validate, or the
 *      validator cannot be found (the guard never switches itself off
 *      silently for a spec file)
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

var fs = require("fs");
var path = require("path");
var url = require("url");

/**
 * Where the framework lives, relative to the project root, as passed to the
 * generator's --framework-prefix:
 *   ""                          self-host (framework is the project)
 *   "vendor/agent-collections"  vendored copy or submodule
 *   "${AGENT_COLLECTIONS_HOME}" local mode (machine-local checkout)
 */
var FRAMEWORK_PREFIX = "";

var LOCAL_MODE_TOKEN = "${AGENT_COLLECTIONS_HOME}";
var VALIDATOR_REL = "scripts/validate-spec-artifacts.mjs";
var FRAMEWORK_HOME_FILE = ".agent-collections/framework-home.txt";
var SELF_TEST_OK = "eversis-validate-spec self-test: ok";
var MIN_NODE = 18;
var SUPPORTED_NODE = 22;
var SPEC_ARTIFACT = /^docs\/specs\/([^/]+\/)*[^/]+\.(plan|research)\.md$/;

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

/** Hook mode. Resolves to the exit code. */
function runHook(env, stdinText) {
  var data;
  try {
    data = JSON.parse(stdinText);
  } catch (err) {
    return Promise.resolve(0);
  }
  if (!data || typeof data !== "object") return Promise.resolve(0);
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
  SELF_TEST_OK: SELF_TEST_OK,
};

if (require.main === module) {
  main();
}

// GENERATED by adapters/claude/generate-hooks.mjs — do not edit; re-run the generator
