#!/usr/bin/env bash
# Every gate must name the requirement it proves, so no delivered work is
# orphaned and no gate proves something nobody asked for.
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$REPO_DIR/GATES.md" "$REPO_DIR/REQUIREMENTS.md" "$REPO_DIR" <<'PY'
import os, re, sys

gates_path, reqs_path, repo = sys.argv[1], sys.argv[2], sys.argv[3]

known = set(re.findall(r'^\s*[-*]\s*\[[ xX]\]\s*\**(R-\d+)',
                       open(reqs_path, encoding='utf-8').read(), re.M))

gates, current = [], None
for line in open(gates_path, encoding='utf-8'):
    match = re.match(r'^- \[[ xX]\] (G\d+):\s*(.*)', line)
    if match:
        current = {'id': match.group(1), 'text': match.group(2).strip(), 'reqs': set()}
        gates.append(current)
        continue
    if current is None:
        continue
    if re.match(r'^\s*Req:', line):
        current['reqs'].update(re.findall(r'\bR-\d+\b', line))
    elif line.strip() and not line.startswith((' ', '\t', '-', '*')):
        current = None

if not gates:
    sys.exit('FAIL: no gates parsed from GATES.md')

orphans = [g for g in gates if not g['reqs']]
if orphans:
    for g in orphans:
        print(f"  orphan: {g['id']}  {g['text'][:70]}", file=sys.stderr)
    sys.exit(f'FAIL: {len(orphans)} gate(s) name no requirement')

unknown = [(g['id'], r) for g in gates for r in sorted(g['reqs']) if r not in known]
if unknown:
    for gid, ref in unknown:
        print(f"  {gid} cites {ref}, absent from REQUIREMENTS.md", file=sys.stderr)
    sys.exit(f'FAIL: {len(unknown)} gate reference(s) cite an unknown requirement')

# A requirement needs a gate once work on it has begun. Planned work does not:
# requiring a gate before the first commit would only invite placeholder gates.
#
# "Started" is decided by the auditor's own parser, not a second implementation
# here. Grepping the raw log for an id counts any commit that merely *mentions*
# a requirement -- including the `Req: none (reason)` commits that only edit its
# text -- which is the exact mis-attribution wb_trace.parse_commits exists to
# avoid. One rule, one implementation.
sys.dont_write_bytecode = True  # keep __pycache__ out of the skill package
sys.path.insert(0, os.path.join(
    repo, "skills/discipline/requirements-traceability-auditor/scripts"))
import wb_trace

started = {r for c in wb_trace.parse_commits(repo, "", 0) for r in c["refs"]} & known

covered = {r for g in gates for r in g['reqs']}
uncovered = sorted(started - covered)
if uncovered:
    print(f"  started but ungated: {', '.join(uncovered)}", file=sys.stderr)
    sys.exit(f'FAIL: {len(uncovered)} requirement(s) have commits but no gate')

planned_ungated = sorted(known - started - covered)

# Counts are diagnostics and move with ordinary work, so they go on their own
# line. The verdict line states the rule that was checked and nothing derived
# from commit history, so a gate can record it as EXPECT without the evidence
# decaying the next time somebody advances a requirement.
print(f'  coverage: {len(gates)} gates, {len(covered)} requirement(s) covered, '
      f'{len(started)} started, {len(planned_ungated)} planned and not yet gated')
print('PASS: every gate names a requirement, and every started requirement has a gate')
PY
