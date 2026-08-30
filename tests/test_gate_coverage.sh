#!/usr/bin/env bash
# Every gate must name the requirement it proves, so no delivered work is
# orphaned and no gate proves something nobody asked for.
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$REPO_DIR/GATES.md" "$REPO_DIR/REQUIREMENTS.md" "$REPO_DIR" <<'PY'
import re, sys

import subprocess

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
log = subprocess.run(["git", "-C", repo, "log", "--format=%s%n%b"],
                     capture_output=True, text=True).stdout
started = {r for r in known if re.search(rf'\b{re.escape(r)}\b', log)}

covered = {r for g in gates for r in g['reqs']}
uncovered = sorted(started - covered)
if uncovered:
    print(f"  started but ungated: {', '.join(uncovered)}", file=sys.stderr)
    sys.exit(f'FAIL: {len(uncovered)} requirement(s) have commits but no gate')

planned_ungated = sorted(known - started - covered)
note = f'; {len(planned_ungated)} planned and not yet gated' if planned_ungated else ''
print(f'PASS: {len(gates)} gates cover {len(covered)} requirement(s), '
      f'{len(started)} of them started{note}')
PY
