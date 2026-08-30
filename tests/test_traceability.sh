#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PKG="$REPO_DIR/skills/discipline/requirements-traceability-auditor"
TRACE="$PKG/scripts/wb_trace.py"
HOOK="$PKG/scripts/commit-msg"

TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/workerbees-trace-test.XXXXXX")
trap 'rm -rf -- "$TEST_ROOT"' EXIT

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# ---------- commit-msg hook ----------
hook_repo="$TEST_ROOT/hook"
git init -q "$hook_repo"
git -C "$hook_repo" config user.email t@example.com
git -C "$hook_repo" config user.name Tester
cp "$HOOK" "$hook_repo/.git/hooks/commit-msg"
chmod +x "$hook_repo/.git/hooks/commit-msg"

commit_try() {
    local repo=$1 file=$2; shift 2
    date +%s%N > "$repo/$file"
    git -C "$repo" add "$file"
    git -C "$repo" commit "$@" >/dev/null 2>&1
}

commit_try "$hook_repo" a.txt -m "feat: no trailer" \
    && fail "hook accepted a commit with no requirement reference"
commit_try "$hook_repo" a.txt -m "feat: tracked" -m "Req: R-001" \
    || fail "hook rejected a commit carrying a valid trailer"
commit_try "$hook_repo" b.txt -m "chore: bare exemption" -m "Req: none" \
    && fail "hook accepted an exemption with no reason"
commit_try "$hook_repo" b.txt -m "chore: justified" -m "Req: none (repo tooling)" \
    || fail "hook rejected a justified exemption"
commit_try "$hook_repo" c.txt -m "Merge branch 'x'" \
    || fail "hook blocked a merge commit"
commit_try "$hook_repo" d.txt -m "feat: multi" -m "Req: R-001, R-002" \
    || fail "hook rejected a multi-requirement trailer"

# ---------- auditor status ladder ----------
aud="$TEST_ROOT/audit"
git init -q "$aud"
git -C "$aud" config user.email t@example.com
git -C "$aud" config user.name Tester

cat > "$aud/REQUIREMENTS.md" <<'REQ'
# Requirements: fixture
- [ ] **R-001**: delivered end to end
- [ ] **R-002**: committed but ungated
- [ ] **R-003**: never started
- [x] **R-004**: hand-ticked without evidence
REQ

cat > "$aud/GATES.md" <<'GATE'
- [x] G1: R-001 is observable end to end.
  CHECK: run the thing
  EXPECT: OK
  EVIDENCE: OK
- [x] G9: unrelated concern with no requirement.
  CHECK: something
  EVIDENCE: fine
GATE

git -C "$aud" add . && git -C "$aud" commit -q -m "docs: baseline" -m "Req: none (fixture setup)"
echo 1 > "$aud/x"; git -C "$aud" add x; git -C "$aud" commit -q -m "feat: one" -m "Req: R-001"
echo 2 > "$aud/y"; git -C "$aud" add y; git -C "$aud" commit -q -m "feat: two" -m "Req: R-002"
echo 3 > "$aud/z"; git -C "$aud" add z; git -C "$aud" commit -q -m "feat: stray"
echo 4 > "$aud/w"; git -C "$aud" add w; git -C "$aud" commit -q -m "feat: ghost" -m "Req: R-099"

out=$(python3 "$TRACE" "$aud" 2>&1) || true

check() { grep -Eq "$1" <<<"$out" || fail "$2"; }

check '^  R-001  DONE'         "R-001 should be DONE (commit + checked gate + evidence)"
check '^  R-002  PARTIAL'      "R-002 should be PARTIAL (commit, no gate)"
check '^  R-003  NOT_STARTED'  "R-003 should be NOT_STARTED"
check 'UNTRACKED'              "auditor did not report untracked commits"
check 'UNKNOWN_REF'            "auditor did not report the unknown R-099 reference"
check 'ORPHAN_GATE'            "auditor did not report the orphan gate G9"
check 'DECLARED_NOT_EVIDENCED' "auditor did not flag hand-ticked R-004"

python3 "$TRACE" "$aud" --strict >/dev/null 2>&1 \
    && fail "--strict returned 0 despite findings"

# clean repo: no findings, strict exits 0
clean="$TEST_ROOT/clean"
git init -q "$clean"
git -C "$clean" config user.email t@example.com
git -C "$clean" config user.name Tester
printf '# Requirements\n- [ ] **R-001**: delivered\n' > "$clean/REQUIREMENTS.md"
printf -- '- [x] G1: R-001 holds.\n  EVIDENCE: OK\n' > "$clean/GATES.md"
git -C "$clean" add . && git -C "$clean" commit -q -m "feat: deliver" -m "Req: R-001"
python3 "$TRACE" "$clean" --strict >/dev/null 2>&1 \
    || fail "--strict returned non-zero on a clean repository"

# ---------- exemption trailer suppresses the prose fallback ----------
# `Req: none (reason)` is the hook's documented escape hatch. The auditor must
# honour it: a commit that only edits a requirement's text names ids in prose,
# and must not thereby be counted as delivering them.
exempt="$TEST_ROOT/exempt"
git init -q "$exempt"
git -C "$exempt" config user.email t@example.com
git -C "$exempt" config user.name Tester

printf '# Requirements\n- [ ] **R-001**: delivered\n- [ ] **R-002**: only ever named in prose\n' \
    > "$exempt/REQUIREMENTS.md"
printf -- '- [x] G1: R-001 holds.\n  EVIDENCE: OK\n' > "$exempt/GATES.md"
git -C "$exempt" add . && git -C "$exempt" commit -q -m "docs: baseline" -m "Req: none (fixture setup)"
echo 1 > "$exempt/x"; git -C "$exempt" add x
git -C "$exempt" commit -q -m "feat: deliver" -m "Req: R-001"
echo 2 > "$exempt/y"; git -C "$exempt" add y
git -C "$exempt" commit -q -m "docs: reword R-002 and cross-check R-001" \
    -m "Body also names R-001 and R-002." -m "Req: none (requirement amendment)"

out=$(python3 "$TRACE" "$exempt" 2>&1) || true

grep -Eq '^  R-002  NOT_STARTED' <<<"$out" \
    || fail "an exempt commit naming R-002 in prose was counted as starting it"
grep -Eq '^  R-001  DONE +1 ' <<<"$out" \
    || fail "an exempt commit naming R-001 in prose inflated its commit count"
grep -q 'UNTRACKED' <<<"$out" \
    || fail "exempt commits must still be reported as drift"

# merge commits carry no requirement trailer -- the commit-msg hook exempts them
# by design -- so the auditor must not fall back to scanning their message. A
# merge summary naturally names the requirements the branch touched, and reading
# those as delivery marks work started that has no commit behind it.
merges="$TEST_ROOT/merges"
git init -q "$merges"
git -C "$merges" config user.email t@example.com
git -C "$merges" config user.name Tester
printf '# Requirements\n- [ ] **R-001**: delivered\n- [ ] **R-002**: never worked on\n' \
    > "$merges/REQUIREMENTS.md"
printf -- '- [x] G1: R-001 holds.\n  EVIDENCE: OK\n' > "$merges/GATES.md"
git -C "$merges" add . && git -C "$merges" commit -q -m "docs: baseline" -m "Req: none (fixture)"
git -C "$merges" checkout -q -b side
echo 1 > "$merges/f"; git -C "$merges" add f
git -C "$merges" commit -q -m "feat: deliver" -m "Req: R-001"
git -C "$merges" checkout -q -
git -C "$merges" merge -q --no-ff side \
    -m "Merge branch 'side'" -m "Delivers R-001 and mentions R-002 in passing."

out=$(python3 "$TRACE" "$merges" 2>&1) || true
grep -Eq '^  R-002  NOT_STARTED' <<<"$out" \
    || fail "a merge commit naming R-002 in its summary was read as starting it"
grep -Eq '^  R-001  DONE +1 ' <<<"$out" \
    || fail "the merge commit inflated R-001's commit count"
grep -q "Merge branch" <<<"$out" \
    && fail "merge commits should not be reported as untracked drift"

# ---------- scope governance ----------
scope="$TEST_ROOT/scope"
git init -q "$scope"
git -C "$scope" config user.email t@example.com
git -C "$scope" config user.name Tester

printf '# Requirements: fixture\n**Frozen at:** SHA\n- [ ] **R-001**: one\n- [ ] **R-002**: two\n' \
    > "$scope/REQUIREMENTS.md"
git -C "$scope" add . && git -C "$scope" commit -q -m "docs: freeze" -m "Req: none (freeze)"
freeze_sha=$(git -C "$scope" rev-parse HEAD)
sed -i.bak "s/SHA/$freeze_sha/" "$scope/REQUIREMENTS.md" && rm -f "$scope/REQUIREMENTS.md.bak"
git -C "$scope" add . && git -C "$scope" commit -q -m "docs: sha" -m "Req: none (freeze)"

out=$(python3 "$TRACE" "$scope" 2>&1) || true
grep -q 'SCOPE_CREEP' <<<"$out" && fail "reported scope creep on an unchanged requirement set"
grep -Eq 'SCOPE  frozen at' <<<"$out" || fail "did not report the freeze baseline"

printf -- '- [ ] **R-003**: appended mid-flight\n' >> "$scope/REQUIREMENTS.md"
git -C "$scope" add . && git -C "$scope" commit -q -m "docs: append" -m "Req: none (scope)"
out=$(python3 "$TRACE" "$scope" 2>&1) || true
grep -q 'SCOPE_CREEP' <<<"$out" || fail "did not detect a requirement appended after freeze"
grep -q 'R-003' <<<"$out" || fail "scope creep report does not name the added requirement"

# recording it as an amendment clears the finding
cat >> "$scope/REQUIREMENTS.md" <<'AMD'

## Amendments

| Date | Requirement | Change | Reason | Approved by |
|---|---|---|---|---|
| 2026-08-30 | R-003 | added | displaces R-002 | owner |
AMD
git -C "$scope" add . && git -C "$scope" commit -q -m "docs: amend" -m "Req: none (amendment)"
out=$(python3 "$TRACE" "$scope" 2>&1) || true
grep -q 'SCOPE_CREEP' <<<"$out" && fail "amendment did not clear the scope-creep finding"
grep -q 'all recorded as amendments' <<<"$out" || fail "did not acknowledge the recorded amendment"

out=$(python3 "$TRACE" "$scope" --wip-limit 1 2>&1) || true
grep -q 'WIP_EXCEEDED' <<<"$out" || fail "wip limit not enforced"
out=$(python3 "$TRACE" "$scope" --wip-limit 99 2>&1) || true
grep -q 'WIP_EXCEEDED' <<<"$out" && fail "wip limit fired below the configured limit"

# ---------- reminder ----------
REMIND="$PKG/scripts/wb-remind"
out=$("$REMIND" "$scope" 2>&1) || fail "wb-remind exited non-zero on a valid repo"
grep -q 'RULE:' <<<"$out" || fail "wb-remind did not state the scope rule"
grep -q 'BACKLOG.md' <<<"$out" || fail "wb-remind did not point new ideas at the backlog"

empty="$TEST_ROOT/empty"
git init -q "$empty"
"$REMIND" "$empty" >/dev/null 2>&1 || fail "wb-remind must never block, even with no requirements file"

[ -f "$PKG/templates/BACKLOG.md" ] || fail "missing backlog template"

# ---------- cross-host wiring ----------
INIT="$PKG/scripts/wb-init"
wired="$TEST_ROOT/wired"
git init -q "$wired"
git -C "$wired" config user.email t@example.com
git -C "$wired" config user.name Tester

# pre-existing configuration that must survive
mkdir -p "$wired/.claude"
printf '{\n  "model": "opus"\n}\n' > "$wired/.claude/settings.json"
printf '# Project\n\nExisting instructions.\n' > "$wired/AGENTS.md"
printf '#!/bin/sh\necho legacy\n' > "$wired/.git/hooks/commit-msg"
chmod +x "$wired/.git/hooks/commit-msg"
mkdir -p "$wired/.codex"
# Shape taken from a real Codex project: every hook nests under "hooks".
cat > "$wired/.codex/hooks.json" <<'J'
{
  "hooks": {
    "PostToolUse": [ { "hooks": [ { "command": "/usr/local/bin/legacy-guard" } ] } ],
    "Stop":        [ { "hooks": [ { "command": "/usr/local/bin/legacy-session" } ] } ]
  }
}
J

"$INIT" "$wired" >/dev/null 2>&1 || fail "wb-init failed on a clean repository"

[ -f "$wired/REQUIREMENTS.md" ] || fail "wb-init did not create REQUIREMENTS.md"
[ -f "$wired/BACKLOG.md" ] || fail "wb-init did not create BACKLOG.md"
[ -x "$wired/.git/hooks/commit-msg" ] || fail "wb-init did not install the commit-msg hook"
grep -q 'WorkerBees commit-msg hook' "$wired/.git/hooks/commit-msg" || fail "installed hook is not the WorkerBees hook"
[ -f "$wired/.git/hooks/commit-msg.pre-workerbees" ] || fail "wb-init did not back up the pre-existing hook"
grep -q 'Existing instructions' "$wired/AGENTS.md" || fail "wb-init destroyed existing AGENTS.md content"
grep -q 'Scope governance (non-negotiable)' "$wired/AGENTS.md" || fail "AGENTS.md was not governed"
grep -q 'Scope governance (non-negotiable)' "$wired/CLAUDE.md" || fail "CLAUDE.md was not governed"

for cfg in .claude/settings.json .cursor/hooks.json .agents/hooks.json .codex/hooks.json; do
    [ -f "$wired/$cfg" ] || fail "wb-init did not write $cfg"
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$wired/$cfg" \
        || fail "$cfg is not valid JSON"
    grep -q 'wb-remind' "$wired/$cfg" || fail "$cfg does not reference the reminder"
done
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d.get('model')=='opus' else 1)" \
    "$wired/.claude/settings.json" || fail "wb-init clobbered existing Claude settings"
grep -q 'legacy-session' "$wired/.codex/hooks.json" \
    || fail "wb-init clobbered an existing Codex Stop hook"
grep -q 'legacy-guard' "$wired/.codex/hooks.json" \
    || fail "wb-init dropped an unrelated Codex hook block (PostToolUse)"
python3 -c "
import json,sys
d = json.load(open(sys.argv[1]))
hooks = d.get('hooks', {})
assert 'SessionStart' in hooks, 'SessionStart not nested under hooks'
assert 'SessionStart' not in d, 'SessionStart stranded at the top level'
assert 'PostToolUse' in hooks and 'Stop' in hooks, 'existing blocks lost'
" "$wired/.codex/hooks.json" || fail "wb-init wired Codex at the wrong nesting level"

# idempotency: three runs must not duplicate anything
"$INIT" "$wired" >/dev/null 2>&1
"$INIT" "$wired" >/dev/null 2>&1
count_json() { python3 -c "
import json,sys
d=json.load(open(sys.argv[1]))
for k in sys.argv[2:]:
    d = d[k]
print(len(d))" "$@"; }
[ "$(count_json "$wired/.claude/settings.json" hooks SessionStart)" = "1" ] \
    || fail "wb-init duplicated the Claude SessionStart hook"
[ "$(count_json "$wired/.cursor/hooks.json" hooks sessionStart)" = "1" ] \
    || fail "wb-init duplicated the Cursor hook"
[ "$(count_json "$wired/.agents/hooks.json" PreInvocation)" = "1" ] \
    || fail "wb-init duplicated the Antigravity hook"
[ "$(count_json "$wired/.codex/hooks.json" hooks SessionStart)" = "1" ] \
    || fail "wb-init duplicated the Codex hook across runs"

# a project wired by an older wb-init carries SessionStart at the top level;
# re-running must move our entry under "hooks" and not leave a stale copy.
legacy="$TEST_ROOT/legacy-codex"
git init -q "$legacy"
mkdir -p "$legacy/.codex"
cat > "$legacy/.codex/hooks.json" <<'J'
{
  "SessionStart": [
    { "hooks": [ { "command": "/old/path/to/wb-remind" } ] },
    { "hooks": [ { "command": "/usr/local/bin/somebody-elses-top-level-hook" } ] }
  ]
}
J
"$INIT" "$legacy" >/dev/null 2>&1 || fail "wb-init failed on a legacy-shaped Codex config"
python3 -c "
import json,sys
d = json.load(open(sys.argv[1]))
top = json.dumps(d.get('SessionStart', []))
nested = json.dumps(d.get('hooks', {}).get('SessionStart', []))
assert 'wb-remind' not in top, 'stale wb-remind left at the top level'
assert 'wb-remind' in nested, 'wb-remind not migrated under hooks'
assert 'somebody-elses-top-level-hook' in top, 'a foreign top-level hook was removed'
" "$legacy/.codex/hooks.json" || fail "wb-init mishandled a legacy-shaped Codex config"
[ "$(grep -c 'Scope governance (non-negotiable)' "$wired/AGENTS.md")" = "1" ] \
    || fail "wb-init duplicated the AGENTS.md governance block"

# in-project package: the wired command must not pin an absolute machine path.
# A repository that vendors the skill and commits its host configs would
# otherwise publish paths that exist on exactly one machine.
inproj="$TEST_ROOT/inproj"
git init -q "$inproj"
git -C "$inproj" config user.email t@example.com
git -C "$inproj" config user.name Tester
mkdir -p "$inproj/skills/discipline"
cp -R "$PKG" "$inproj/skills/discipline/requirements-traceability-auditor"
"$inproj/skills/discipline/requirements-traceability-auditor/scripts/wb-init" "$inproj" >/dev/null 2>&1 \
    || fail "wb-init failed when the package lives inside the project"

for cfg in .claude/settings.json .cursor/hooks.json .agents/hooks.json .codex/hooks.json; do
    grep -q 'wb-remind' "$inproj/$cfg" || fail "$cfg lost the reminder for an in-project package"
    if grep -qE '"command": *"/' "$inproj/$cfg"; then
        fail "$cfg pins an absolute path for a package that lives inside the project"
    fi
    grep -q "$TEST_ROOT" "$inproj/$cfg" \
        && fail "$cfg leaks the absolute project location"
done

# package IS the project root. A glob of "$project"/* also matches when the two
# are equal, so a naive prefix strip becomes a no-op and emits "./" glued to a
# full absolute path -- a command that resolves nowhere and reads as relative.
selfproj="$TEST_ROOT/selfproj"
cp -R "$PKG" "$selfproj"
git init -q "$selfproj"
git -C "$selfproj" config user.email t@example.com
git -C "$selfproj" config user.name Tester
"$selfproj/scripts/wb-init" "$selfproj" >/dev/null 2>&1 \
    || fail "wb-init failed when the package is the project root"
selfcmd=$(python3 -c "
import json,sys
print(json.load(open(sys.argv[1]))['hooks']['SessionStart'][0]['hooks'][0]['command'])" \
    "$selfproj/.claude/settings.json")
[ "$selfcmd" = "./scripts/wb-remind" ] \
    || fail "package-as-project wired '$selfcmd', expected ./scripts/wb-remind"
case "$selfcmd" in
    *//*) fail "package-as-project produced a doubled slash: $selfcmd" ;;
esac
( cd "$selfproj" && bash -c "$selfcmd" >/dev/null 2>&1 ) \
    || fail "the wired command does not execute from the project root"

# out-of-project package: absolute is still correct, since nothing else resolves.
grep -qE '"command": *"/' "$wired/.claude/settings.json" \
    || fail "wb-init should keep an absolute path when the package is outside the project"

# a deliberately customised invocation is the user's, not ours. wb-init may
# skip it, but must never delete it: the command mentions wb-remind, it is not
# a bare call to it.
custom="$TEST_ROOT/custom"
git init -q "$custom"
mkdir -p "$custom/.claude"
cat > "$custom/.claude/settings.json" <<'J'
{ "hooks": { "SessionStart": [
  { "hooks": [ { "type": "command", "command": "bash -c 'my-logger start && ./skills/discipline/requirements-traceability-auditor/scripts/wb-remind'" } ] }
] } }
J
"$INIT" "$custom" >/dev/null 2>&1 || fail "wb-init failed on a customised hook"
grep -q 'my-logger' "$custom/.claude/settings.json" \
    || fail "wb-init deleted a user's customised wb-remind invocation"

# a malformed value where a list belongs must not abort the run and strand the
# remaining hosts unwired.
odd="$TEST_ROOT/oddshape"
git init -q "$odd"
mkdir -p "$odd/.claude"
printf '{ "hooks": { "SessionStart": {} } }\n' > "$odd/.claude/settings.json"
"$INIT" "$odd" >/dev/null 2>&1 || fail "wb-init aborted on a non-list SessionStart"
for cfg in .claude/settings.json .cursor/hooks.json .agents/hooks.json .codex/hooks.json; do
    [ -f "$odd/$cfg" ] || fail "wb-init left $cfg unwired after a malformed config"
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$odd/$cfg" \
        || fail "$cfg is not valid JSON after recovering from a malformed config"
    grep -q 'wb-remind' "$odd/$cfg" || fail "$cfg has no reminder after recovery"
done

# worktrees: .git is a file and hooks live in the shared common directory
wt_main="$TEST_ROOT/wt-main"
git init -q "$wt_main"
git -C "$wt_main" config user.email t@example.com
git -C "$wt_main" config user.name Tester
printf 'x\n' > "$wt_main/seed.txt"
git -C "$wt_main" add seed.txt
git -C "$wt_main" commit -q -m "chore: seed"
git -C "$wt_main" worktree add -q -b wb-test "$TEST_ROOT/wt-child" >/dev/null 2>&1 \
    || fail "could not create a test worktree"
[ -f "$TEST_ROOT/wt-child/.git" ] || fail "expected .git to be a file in the worktree"

"$INIT" "$TEST_ROOT/wt-child" >/dev/null 2>&1 \
    || fail "wb-init failed inside a git worktree"
common=$(git -C "$TEST_ROOT/wt-child" rev-parse --git-common-dir)
[ -x "$common/hooks/commit-msg" ] \
    || fail "wb-init did not install the hook into the worktree's shared hook directory"
grep -q 'WorkerBees commit-msg hook' "$common/hooks/commit-msg" \
    || fail "worktree hook is not the WorkerBees hook"
[ -d "$TEST_ROOT/wt-child/.git" ] \
    && fail "wb-init created a stray .git directory in the worktree"

date +%s > "$TEST_ROOT/wt-child/g.txt"
git -C "$TEST_ROOT/wt-child" add g.txt
git -C "$TEST_ROOT/wt-child" commit -m "feat: untracked in worktree" >/dev/null 2>&1 \
    && fail "worktree accepted a commit with no requirement reference"

# the auditor must also work inside a worktree (.git is a file there)
printf '# Requirements\n- [ ] **R-001**: worktree support\n' > "$TEST_ROOT/wt-child/REQUIREMENTS.md"
git -C "$TEST_ROOT/wt-child" add REQUIREMENTS.md
git -C "$TEST_ROOT/wt-child" commit -q -m "docs: reqs" -m "Req: R-001"
python3 "$TRACE" "$TEST_ROOT/wt-child" >/dev/null 2>&1 \
    || fail "auditor failed inside a git worktree"

# core.hooksPath must be honoured when set
hp="$TEST_ROOT/custom-hooks"
git -C "$wt_main" config core.hooksPath "$hp"
"$INIT" "$wt_main" >/dev/null 2>&1 || fail "wb-init failed with core.hooksPath set"
[ -x "$hp/commit-msg" ] || fail "wb-init ignored core.hooksPath"

# the installed hook actually governs commits in the wired repo
date +%s > "$wired/f.txt"; git -C "$wired" add f.txt
git -C "$wired" commit -m "feat: untracked" >/dev/null 2>&1 \
    && fail "wired repo accepted a commit with no requirement reference"

printf 'PASS: traceability auditor, scope governance, cross-host wiring, and commit-msg hook validated\n'
