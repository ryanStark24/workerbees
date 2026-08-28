#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/workerbees-installer-test.XXXXXX")
trap 'rm -rf -- "$TEST_ROOT"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_same() {
    cmp -s -- "$1" "$2" || fail "files differ: $1 and $2"
}

assert_tree_same() {
    diff -qr -- "$1" "$2" >/dev/null || fail "package trees differ: $1 and $2"
    while IFS= read -r source_file; do
        relative=${source_file#"$1/"}
        destination_file="$2/$relative"
        if [ -x "$source_file" ]; then
            [ -x "$destination_file" ] || fail "executable mode differs: $source_file and $destination_file"
        else
            [ ! -x "$destination_file" ] || fail "executable mode differs: $source_file and $destination_file"
        fi
    done < <(find "$1" -type f -print | LC_ALL=C sort)
}

mkdir -p "$TEST_ROOT/home" "$TEST_ROOT/project"

(
    cd /tmp
    HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --all --project-dir "$TEST_ROOT/project"
)

installed_count=0
while IFS= read -r entrypoint; do
    package_dir=${entrypoint%/SKILL.md}
    skill_name=$(basename -- "$package_dir")
    assert_tree_same "$package_dir" "$TEST_ROOT/home/.gemini/config/skills/$skill_name"
    assert_tree_same "$package_dir" "$TEST_ROOT/home/.agents/skills/$skill_name"
    assert_tree_same "$package_dir" "$TEST_ROOT/home/.claude/skills/$skill_name"
    assert_tree_same "$package_dir" "$TEST_ROOT/project/.cursor/skills/$skill_name"
    installed_count=$((installed_count + 1))
done < <(find "$REPO_DIR/skills" -mindepth 3 -maxdepth 3 -type f -name SKILL.md -print | LC_ALL=C sort)
[ "$installed_count" -eq 23 ] || fail "expected 23 installed skill packages, found $installed_count"

printf '\n# local change\n' >> "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/SKILL.md"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "conflicting destination was overwritten without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
assert_same "$REPO_DIR/skills/general/swarm-lead-orchestrator/SKILL.md" "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/SKILL.md"

# A stale file, including an obsolete reference, must make the tree differ and
# must be removed by a forced staged replacement.
mkdir -p "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/references"
printf 'obsolete instructions\n' > "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/references/obsolete.md"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "stale destination files were accepted without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
[ ! -e "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/references" ] || fail "stale reference directory survived forced replacement"
assert_tree_same "$REPO_DIR/skills/general/swarm-lead-orchestrator" "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator"

# Executable-bit drift is a conflict and a forced install restores it.
chmod -x "$TEST_ROOT/home/.agents/skills/salesforce-omnistudio-environment-router/scripts/classify_environment.py"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "destination executable-mode change was accepted without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
[ -x "$TEST_ROOT/home/.agents/skills/salesforce-omnistudio-environment-router/scripts/classify_environment.py" ] || fail "forced install did not restore executable mode"
assert_tree_same "$REPO_DIR/skills/salesforce/salesforce-omnistudio-environment-router" "$TEST_ROOT/home/.agents/skills/salesforce-omnistudio-environment-router"

# File type changes are conflicts and a forced install restores the source type.
rm -- "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/SKILL.md"
mkdir "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/SKILL.md"
printf 'wrong type\n' > "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/SKILL.md/content"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "destination file-type change was accepted without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
[ -f "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator/SKILL.md" ] || fail "forced install did not restore regular file type"
assert_tree_same "$REPO_DIR/skills/general/swarm-lead-orchestrator" "$TEST_ROOT/home/.agents/skills/swarm-lead-orchestrator"

# Never follow an exact package-destination symlink, including with --force.
mkdir -p "$TEST_ROOT/symlink-victim"
printf 'do not overwrite\n' > "$TEST_ROOT/symlink-victim/SKILL.md"
rm -rf -- "$TEST_ROOT/home/.gemini/config/skills/swarm-lead-orchestrator"
ln -s "$TEST_ROOT/symlink-victim" "$TEST_ROOT/home/.gemini/config/skills/swarm-lead-orchestrator"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target antigravity --force >/dev/null 2>&1; then
    fail "forced install accepted a package-destination symlink"
fi
[ "$(cat "$TEST_ROOT/symlink-victim/SKILL.md")" = "do not overwrite" ] || fail "symlink victim was modified"
[ -L "$TEST_ROOT/home/.gemini/config/skills/swarm-lead-orchestrator" ] || fail "destination symlink was replaced"

# --all must discover every conflict before writing to any other target.
mkdir -p "$TEST_ROOT/transaction-home/.claude/skills/swarm-lead-orchestrator"
printf 'local conflict\n' > "$TEST_ROOT/transaction-home/.claude/skills/swarm-lead-orchestrator/SKILL.md"
if HOME="$TEST_ROOT/transaction-home" "$REPO_DIR/install.sh" --all --project-dir "$TEST_ROOT/transaction-project" >/dev/null 2>&1; then
    fail "multi-target install accepted a differing destination without --force"
fi
[ ! -e "$TEST_ROOT/transaction-home/.agents" ] || fail "Codex was partially installed before multi-target conflict"
[ ! -e "$TEST_ROOT/transaction-home/.gemini" ] || fail "Antigravity was partially installed before multi-target conflict"
[ ! -e "$TEST_ROOT/transaction-project" ] || fail "Cursor was partially installed before multi-target conflict"
[ "$(cat "$TEST_ROOT/transaction-home/.claude/skills/swarm-lead-orchestrator/SKILL.md")" = "local conflict" ] || fail "conflicting destination was modified"

# Users can install only the general group at project scope. Antigravity and
# Codex intentionally share the open-standard .agents/skills destination.
mkdir -p "$TEST_ROOT/group-project-home" "$TEST_ROOT/group-project"
HOME="$TEST_ROOT/group-project-home" "$REPO_DIR/install.sh" --all --group general --scope project --project-dir "$TEST_ROOT/group-project" >/dev/null
for skills_root in \
    "$TEST_ROOT/group-project/.cursor/skills" \
    "$TEST_ROOT/group-project/.agents/skills" \
    "$TEST_ROOT/group-project/.claude/skills"; do
    [ "$(find "$skills_root" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 11 ] || fail "general project-scope selection count is wrong: $skills_root"
    [ ! -e "$skills_root/salesforce-omnistudio-environment-router" ] || fail "Salesforce skill leaked into general selection: $skills_root"
done
for package_dir in "$REPO_DIR"/skills/general/*; do
    skill_name=$(basename -- "$package_dir")
    assert_tree_same "$package_dir" "$TEST_ROOT/group-project/.agents/skills/$skill_name"
done

# Users can independently install only the Salesforce group at global scope.
mkdir -p "$TEST_ROOT/group-global-home" "$TEST_ROOT/group-global-project"
HOME="$TEST_ROOT/group-global-home" "$REPO_DIR/install.sh" --all --group salesforce --scope global --project-dir "$TEST_ROOT/group-global-project" >/dev/null
for skills_root in \
    "$TEST_ROOT/group-global-home/.cursor/skills" \
    "$TEST_ROOT/group-global-home/.gemini/config/skills" \
    "$TEST_ROOT/group-global-home/.agents/skills" \
    "$TEST_ROOT/group-global-home/.claude/skills"; do
    [ "$(find "$skills_root" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 12 ] || fail "Salesforce global-scope selection count is wrong: $skills_root"
    [ ! -e "$skills_root/swarm-lead-orchestrator" ] || fail "general skill leaked into Salesforce selection: $skills_root"
done
for package_dir in "$REPO_DIR"/skills/salesforce/*; do
    skill_name=$(basename -- "$package_dir")
    assert_tree_same "$package_dir" "$TEST_ROOT/group-global-home/.agents/skills/$skill_name"
done

# Scope flags may be repeated to install the same selected group both ways.
mkdir -p "$TEST_ROOT/both-scope-home" "$TEST_ROOT/both-scope-project"
HOME="$TEST_ROOT/both-scope-home" "$REPO_DIR/install.sh" --target cursor --group salesforce --scope project --scope global --project-dir "$TEST_ROOT/both-scope-project" >/dev/null
[ "$(find "$TEST_ROOT/both-scope-project/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 12 ] || fail "Cursor project scope did not receive Salesforce selection"
[ "$(find "$TEST_ROOT/both-scope-home/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 12 ] || fail "Cursor global scope did not receive Salesforce selection"

if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --group invalid >/dev/null 2>&1; then
    fail "invalid group was accepted"
fi
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --scope invalid >/dev/null 2>&1; then
    fail "invalid scope was accepted"
fi

mkdir -p "$TEST_ROOT/dry-home"
HOME="$TEST_ROOT/dry-home" "$REPO_DIR/install.sh" --all --project-dir "$TEST_ROOT/dry-project" --dry-run >/dev/null
[ ! -e "$TEST_ROOT/dry-home/.agents" ] || fail "dry run wrote Codex files"
[ ! -e "$TEST_ROOT/dry-project" ] || fail "dry run wrote Cursor files"

if printf '' | HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" >/dev/null 2>&1; then
    fail "non-interactive invocation without a target should fail"
fi

printf 'PASS: installer groups, scopes, targets, full-tree verification, safe replacement, transactional preflight, and dry-run behavior\n'
