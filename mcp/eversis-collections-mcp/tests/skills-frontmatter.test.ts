import assert from "node:assert/strict";
import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import { parseSkillFrontmatter, resolveUserInvocable } from "../src/frontmatter.ts";
import { listSkills } from "../src/skills.ts";
import { validateAllSkills } from "../src/validate.ts";

function skillMd(name: string, extra: string): string {
  return `---\nname: ${name}\ndescription: Test skill ${name}.\n${extra}---\n\n# ${name}\n`;
}

/** Temp repo root under os.tmpdir() with one `.ai/skills/<id>/SKILL.md` per fixture. */
async function makeSkillsRoot(fixtures: Record<string, string>): Promise<string> {
  const root = await mkdtemp(path.join(tmpdir(), "eversis-skills-fm-test-"));
  for (const [id, extra] of Object.entries(fixtures)) {
    const dir = path.join(root, ".ai", "skills", id);
    await mkdir(dir, { recursive: true });
    await writeFile(path.join(dir, "SKILL.md"), skillMd(id, extra), "utf8");
  }
  return root;
}

function fm(extra: string) {
  return parseSkillFrontmatter(skillMd("eversis-x", extra)).frontmatter;
}

test("parser — new key user-invocable: false / False / true / True", () => {
  assert.equal(fm("user-invocable: false\n")["user-invocable"], false);
  assert.equal(fm("user-invocable: False\n")["user-invocable"], false);
  assert.equal(fm("user-invocable: true\n")["user-invocable"], true);
  assert.equal(fm("user-invocable: True\n")["user-invocable"], true);
  assert.equal(resolveUserInvocable(fm("user-invocable: false\n")), false);
  assert.equal(resolveUserInvocable(fm("user-invocable: true\n")), true);
});

test("parser — quoted \"false\" and 'false' are stripped before the boolean check", () => {
  assert.equal(fm('user-invocable: "false"\n')["user-invocable"], false);
  assert.equal(fm("user-invocable: 'false'\n")["user-invocable"], false);
  assert.equal(resolveUserInvocable(fm('user-invocable: "false"\n')), false);
  assert.equal(fm('user-invokable: "false"\n')["user-invokable"], false);
});

test("parser — legacy key user-invokable is still read", () => {
  const f = fm("user-invokable: false\n");
  assert.equal(f["user-invokable"], false);
  assert.equal(f["user-invocable"], undefined);
  assert.equal(resolveUserInvocable(f), false);
  assert.equal(resolveUserInvocable(fm("user-invokable: True\n")), true);
});

test("resolver — new key wins when both keys are present", () => {
  assert.equal(resolveUserInvocable(fm("user-invocable: true\nuser-invokable: false\n")), true);
  assert.equal(resolveUserInvocable(fm("user-invocable: false\nuser-invokable: true\n")), false);
});

test("resolver — missing key gives true", () => {
  assert.equal(resolveUserInvocable(fm("")), true);
  assert.equal(resolveUserInvocable({}), true);
});

test("resolver — non-boolean value counts as the default true", () => {
  const f = fm("user-invocable: yes\n");
  assert.equal(f["user-invocable"], "yes");
  assert.equal(resolveUserInvocable(f), true);
  assert.equal(resolveUserInvocable(fm("user-invocable:\n")), true);
});

test("parser — nested (indented) invocation keys are ignored", () => {
  const f = fm("metadata:\n  user-invocable: false\n  user-invokable: false\n");
  assert.equal(f["user-invocable"], undefined);
  assert.equal(f["user-invokable"], undefined);
  assert.equal(resolveUserInvocable(f), true);
});

test("listSkills — userInvocable and legacy userInvokable carry the same value", async () => {
  const root = await makeSkillsRoot({
    "eversis-new-hidden": "user-invocable: false\n",
    "eversis-legacy-hidden": "user-invokable: false\n",
    "eversis-both": "user-invocable: true\nuser-invokable: false\n",
    "eversis-default": "",
  });
  try {
    const byId = new Map(listSkills(root).map((s) => [s.id, s]));
    const expected: Record<string, boolean> = {
      "eversis-new-hidden": false,
      "eversis-legacy-hidden": false,
      "eversis-both": true,
      "eversis-default": true,
    };
    assert.equal(byId.size, 4);
    for (const [id, value] of Object.entries(expected)) {
      const s = byId.get(id);
      assert.ok(s, `missing ${id}`);
      assert.equal(s.userInvocable, value, `${id} userInvocable`);
      assert.equal(s.userInvokable, value, `${id} userInvokable`);
    }
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("listSkills — entry without SKILL.md has no flag", async () => {
  const root = await makeSkillsRoot({});
  await mkdir(path.join(root, ".ai", "skills", "eversis-empty"), { recursive: true });
  try {
    const [s] = listSkills(root);
    assert.equal(s.id, "eversis-empty");
    assert.equal(s.userInvocable, undefined);
    assert.equal(s.userInvokable, undefined);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("validateAllSkills — legacy key gives one warning; ok by default, not ok when strict", async () => {
  const root = await makeSkillsRoot({
    "eversis-legacy": "user-invokable: false\n",
    "eversis-new": "user-invocable: false\n",
    "eversis-default": "",
  });
  try {
    const result = validateAllSkills(root);
    assert.equal(result.skillCount, 3);
    assert.equal(result.issues.length, 1);
    const [issue] = result.issues;
    assert.equal(issue.level, "warning");
    assert.equal(issue.path, path.join(".ai", "skills", "eversis-legacy", "SKILL.md"));
    assert.match(issue.message, /user-invokable/);
    assert.match(issue.message, /user-invocable/);
    assert.equal(result.ok, true);

    const strict = validateAllSkills(root, { treatWarningsAsErrors: true });
    assert.equal(strict.ok, false);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("validateAllSkills — new key alone gives no warning", async () => {
  const root = await makeSkillsRoot({ "eversis-new": "user-invocable: false\n" });
  try {
    const result = validateAllSkills(root, { treatWarningsAsErrors: true });
    assert.deepEqual(result.issues, []);
    assert.equal(result.ok, true);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
