#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
GATES_FILE="$REPO_DIR/GATES.md"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

cd "$REPO_DIR"
gate_count=0
for gate_id in $(sed -n 's/^- \[[ x]\] \(G[0-9][0-9]*\):.*/\1/p' "$GATES_FILE"); do
    gate_count=$((gate_count + 1))
    marker=$(sed -n "s/^- \[\([ x]\)\] $gate_id:.*/\1/p" "$GATES_FILE")
    check=$(sed -n "/^- \[[ x]\] $gate_id:/,/^$/s/^  CHECK: //p" "$GATES_FILE")
    expected=$(sed -n "/^- \[[ x]\] $gate_id:/,/^$/s/^  EXPECT: //p" "$GATES_FILE")
    evidence=$(sed -n "/^- \[[ x]\] $gate_id:/,/^$/s/^  EVIDENCE: //p" "$GATES_FILE")
    [ -n "$check" ] || fail "$gate_id has no CHECK command"
    [ -n "$expected" ] || fail "$gate_id has no EXPECT value"
    [ -n "$evidence" ] || fail "$gate_id has no EVIDENCE value"

    set +e
    output=$(bash -c "$check" 2>&1)
    status=$?
    set -e
    if [ "$marker" = "x" ]; then
        [ "$status" -eq 0 ] || fail "$gate_id is checked but its command failed: $output"
        printf '%s\n' "$output" | grep -Fqx -- "$expected" || fail "$gate_id command output does not contain its EXPECT value"
        [ "$evidence" = "$expected" ] || fail "$gate_id checked evidence is stale: expected '$expected', recorded '$evidence'"
    else
        [ "$status" -ne 0 ] || fail "$gate_id is unchecked but its command passes"
        case "$evidence" in
            blocked*|BLOCKED*) ;;
            *) fail "$gate_id unchecked evidence must state blocked status" ;;
        esac
    fi
done

# An exact count, deliberately: it catches a gate being deleted or the parser
# silently matching nothing. Unlike a count derived from commit history, this
# one only moves when somebody edits GATES.md in the same change, so it fails
# loudly and immediately rather than decaying underneath unrelated work.
[ "$gate_count" -eq 28 ] || fail "expected 28 gates, found $gate_count"
printf 'PASS: 28 gate commands and recorded evidence agree\n'
