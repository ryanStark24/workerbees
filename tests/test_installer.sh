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
for package_dir in "$REPO_DIR"/skills/*; do
    [ -d "$package_dir" ] || continue
    skill_name=$(basename -- "$package_dir")
    assert_tree_same "$package_dir" "$TEST_ROOT/home/.gemini/config/skills/$skill_name"
    assert_tree_same "$package_dir" "$TEST_ROOT/home/.codex/skills/$skill_name"
    assert_tree_same "$package_dir" "$TEST_ROOT/home/.claude/skills/$skill_name"
    assert_tree_same "$package_dir" "$TEST_ROOT/project/.cursor/skills/$skill_name"
    installed_count=$((installed_count + 1))
done
[ "$installed_count" -eq 23 ] || fail "expected 23 installed skill packages, found $installed_count"

printf '\n# local change\n' >> "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/SKILL.md"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "conflicting destination was overwritten without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
assert_same "$REPO_DIR/skills/swarm-lead-orchestrator/SKILL.md" "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/SKILL.md"

# A stale file, including an obsolete reference, must make the tree differ and
# must be removed by a forced staged replacement.
mkdir -p "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/references"
printf 'obsolete instructions\n' > "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/references/obsolete.md"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "stale destination files were accepted without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
[ ! -e "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/references" ] || fail "stale reference directory survived forced replacement"
assert_tree_same "$REPO_DIR/skills/swarm-lead-orchestrator" "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator"

# Executable-bit drift is a conflict and a forced install restores it.
chmod -x "$TEST_ROOT/home/.codex/skills/salesforce-omnistudio-environment-router/scripts/classify_environment.py"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "destination executable-mode change was accepted without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
[ -x "$TEST_ROOT/home/.codex/skills/salesforce-omnistudio-environment-router/scripts/classify_environment.py" ] || fail "forced install did not restore executable mode"
assert_tree_same "$REPO_DIR/skills/salesforce-omnistudio-environment-router" "$TEST_ROOT/home/.codex/skills/salesforce-omnistudio-environment-router"

# File type changes are conflicts and a forced install restores the source type.
rm -- "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/SKILL.md"
mkdir "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/SKILL.md"
printf 'wrong type\n' > "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/SKILL.md/content"
if HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex >/dev/null 2>&1; then
    fail "destination file-type change was accepted without --force"
fi
HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" --target codex --force >/dev/null
[ -f "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator/SKILL.md" ] || fail "forced install did not restore regular file type"
assert_tree_same "$REPO_DIR/skills/swarm-lead-orchestrator" "$TEST_ROOT/home/.codex/skills/swarm-lead-orchestrator"

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
[ ! -e "$TEST_ROOT/transaction-home/.codex" ] || fail "Codex was partially installed before multi-target conflict"
[ ! -e "$TEST_ROOT/transaction-home/.gemini" ] || fail "Antigravity was partially installed before multi-target conflict"
[ ! -e "$TEST_ROOT/transaction-project" ] || fail "Cursor was partially installed before multi-target conflict"
[ "$(cat "$TEST_ROOT/transaction-home/.claude/skills/swarm-lead-orchestrator/SKILL.md")" = "local conflict" ] || fail "conflicting destination was modified"

mkdir -p "$TEST_ROOT/dry-home"
HOME="$TEST_ROOT/dry-home" "$REPO_DIR/install.sh" --all --project-dir "$TEST_ROOT/dry-project" --dry-run >/dev/null
[ ! -e "$TEST_ROOT/dry-home/.codex" ] || fail "dry run wrote Codex files"
[ ! -e "$TEST_ROOT/dry-project" ] || fail "dry run wrote Cursor files"

if printf '' | HOME="$TEST_ROOT/home" "$REPO_DIR/install.sh" >/dev/null 2>&1; then
    fail "non-interactive invocation without a target should fail"
fi

printf 'PASS: installer targets, full-tree verification, safe replacement, transactional preflight, and dry-run behavior\n'
