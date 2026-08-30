#!/usr/bin/env python3
"""Compute requirement delivery status from repository evidence.

Reads a frozen requirements file, a gates file, and the commit log, then reports
one status per requirement. Status is computed from evidence that exists in the
repository; it is never asserted by an agent and never inferred from confidence.

Statuses
    NOT_STARTED        no commit references it and no gate evidences it
    EVIDENCED_UNTRACED  a gate evidences it, but no commit names it (pre-convention work)
    PARTIAL             commits exist, but no gate claims the requirement
    UNVERIFIED          a gate claims it, but the gate carries no evidence
    DONE                commits, a checked gate, and non-empty evidence all present

Also reported
    UNTRACKED    commits carrying no requirement reference (drift)
    UNKNOWN_REF  commits citing an id absent from the requirements file
    ORPHAN_GATE  gates claiming no requirement (candidate unrequested work)

Exit codes: 0 clean, 1 findings present, 2 usage or input error.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys

# W1-01, W2a-03, R-001, REQ-12, FR-3
ID = re.compile(r"\b((?:W\d+[a-z]?|R|REQ|FR|REQ)-\d+)\b")
# - [ ] **W1-01**: text     /     - [x] W1-01 - text
REQ_LINE = re.compile(r"^\s*[-*]\s*\[( |x|X)\]\s*\**([A-Za-z]+\d*[a-z]?-\d+)\**\s*[:\-–]?\s*(.*)$")
GATE_LINE = re.compile(r"^\s*[-*]\s*\[( |x|X)\]\s*(G\d+)\s*[:\.]?\s*(.*)$")
EVIDENCE = re.compile(r"^\s*EVIDENCE:\s*(.*)$")
TRAILER = re.compile(r"^\s*(?:Req|Requirement|Refs|Closes)\s*:\s*(.+)$", re.I)
# `Req: none (reason)` -- the commit-msg hook's documented exemption.
EXEMPT = re.compile(r"^\s*(?:Req|Requirement|Refs|Closes)\s*:\s*none\b", re.I)
FROZEN = re.compile(r"^\s*\**Frozen at:?\**\s*:?\s*`?([0-9a-f]{7,40})`?", re.I | re.M)

SEP = "\x1e"


def run(repo: str, *args: str) -> str:
    try:
        out = subprocess.run(
            ["git", "-C", repo, *args],
            capture_output=True, text=True, check=True,
        )
        return out.stdout
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        raise SystemExit(f"error: git failed in {repo}: {exc}")


def find_file(repo: str, explicit: str | None, names: list[str]) -> str | None:
    if explicit:
        path = explicit if os.path.isabs(explicit) else os.path.join(repo, explicit)
        return path if os.path.isfile(path) else None
    for name in names:
        for sub in ("", ".planning", "docs"):
            path = os.path.join(repo, sub, name)
            if os.path.isfile(path):
                return path
    return None


def parse_requirements(path: str) -> dict[str, dict]:
    reqs: dict[str, dict] = {}
    with open(path, encoding="utf-8", errors="replace") as handle:
        for num, line in enumerate(handle, 1):
            match = REQ_LINE.match(line)
            if not match:
                continue
            checked, rid, text = match.groups()
            reqs[rid] = {
                "id": rid,
                "text": text.strip()[:90],
                "declared_done": checked.lower() == "x",
                "line": num,
                "commits": [],
                "gates": [],
            }
    return reqs


def frozen_sha(path: str) -> str | None:
    with open(path, encoding="utf-8", errors="replace") as handle:
        match = FROZEN.search(handle.read())
    return match.group(1) if match else None


def amended_ids(path: str) -> set[str]:
    """Requirement ids named in the amendment table."""
    ids: set[str] = set()
    in_table = False
    with open(path, encoding="utf-8", errors="replace") as handle:
        for line in handle:
            if re.match(r"^\s*#+\s*Amendments", line, re.I):
                in_table = True
                continue
            if in_table and re.match(r"^\s*#+\s", line):
                in_table = False
            if in_table and line.lstrip().startswith("|"):
                ids.update(ID.findall(line))
    return ids


def frozen_requirement_ids(repo: str, sha: str, rel_path: str) -> set[str] | None:
    """Requirement ids as they stood at the freeze commit."""
    try:
        out = subprocess.run(
            ["git", "-C", repo, "show", f"{sha}:{rel_path}"],
            capture_output=True, text=True, check=True,
        ).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    ids = set()
    for line in out.splitlines():
        match = REQ_LINE.match(line)
        if match:
            ids.add(match.group(2))
    return ids


def parse_gates(path: str | None) -> list[dict]:
    """A gate claims every requirement id appearing in its block."""
    if not path:
        return []
    gates: list[dict] = []
    current: dict | None = None
    with open(path, encoding="utf-8", errors="replace") as handle:
        for line in handle:
            match = GATE_LINE.match(line)
            if match:
                checked, gid, text = match.groups()
                current = {
                    "id": gid,
                    "checked": checked.lower() == "x",
                    "text": text.strip()[:80],
                    "requirements": set(ID.findall(text)),
                    "evidence": "",
                }
                gates.append(current)
                continue
            if current is None:
                continue
            if line.strip() and not line.startswith((" ", "\t", "-", "*")):
                current = None
                continue
            current["requirements"].update(ID.findall(line))
            ev = EVIDENCE.match(line)
            if ev:
                current["evidence"] = (current["evidence"] + " " + ev.group(1)).strip()
    return gates


def parse_commits(repo: str, rev_range: str, limit: int) -> list[dict]:
    """Commits that can carry delivery evidence.

    Merge commits are skipped. The commit-msg hook exempts them from the trailer
    rule, so they never carry one, and a merge summary naturally names the
    requirements its branch touched -- which the fallback below would then read
    as delivery. Their content is already counted through the commits they
    merge, so dropping them loses nothing and stops a merge from marking work
    started that has no commit behind it.
    """
    fmt = f"%H{SEP}%s{SEP}%P{SEP}%b"
    args = ["log", f"--format={fmt}%x00"]
    if limit:
        args.append(f"-{limit}")
    if rev_range:
        args.append(rev_range)
    raw = run(repo, *args)
    commits = []
    for chunk in raw.split("\0"):
        chunk = chunk.strip("\n")
        if not chunk.strip():
            continue
        parts = chunk.split(SEP)
        if len(parts) < 2:
            continue
        sha, subject = parts[0], parts[1]
        parents = parts[2].split() if len(parts) > 2 else []
        body = parts[3] if len(parts) > 3 else ""
        if len(parents) > 1:
            continue
        refs: set[str] = set()
        exempt = False
        for line in body.splitlines():
            if EXEMPT.match(line):
                exempt = True
                continue
            trailer = TRAILER.match(line)
            if trailer:
                refs.update(ID.findall(trailer.group(1)))
        # Fall back to any id mentioned anywhere in the message -- but not when
        # the commit claims the hook's `Req: none (reason)` exemption. A commit
        # that only edits a requirement's text names ids in prose, and counting
        # those would report the requirement as started by its own rewording.
        # Exempt commits still carry no refs, so they remain UNTRACKED drift.
        if not refs and not exempt:
            refs.update(ID.findall(subject))
            refs.update(ID.findall(body))
        commits.append({"sha": sha[:9], "subject": subject[:70], "refs": refs})
    return commits


def classify(req: dict, gates_by_id: dict[str, dict]) -> str:
    claiming = [gates_by_id[g] for g in req["gates"] if g in gates_by_id]
    evidenced = any(g["checked"] and g["evidence"] for g in claiming)
    if not req["commits"]:
        # Work predating the trailer convention: a gate proves it, but no commit
        # names it. Honest about both halves rather than calling it not started.
        return "EVIDENCED_UNTRACED" if evidenced else "NOT_STARTED"
    if not claiming:
        return "PARTIAL"
    if not evidenced:
        return "UNVERIFIED"
    return "DONE"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("repo", nargs="?", default=".", help="repository path (default: cwd)")
    ap.add_argument("--requirements", help="path to the frozen requirements file")
    ap.add_argument("--gates", help="path to the gates file")
    ap.add_argument("--range", dest="rev_range", default="", help="git rev-range (default: all history)")
    ap.add_argument("--limit", type=int, default=0, help="max commits to scan (0 = no limit)")
    ap.add_argument("--strict", action="store_true", help="exit 1 when any finding is present")
    ap.add_argument("--wip-limit", type=int, default=0,
                    help="maximum requirements allowed to be open at once (0 = no limit)")
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    # .git is a file inside a worktree, so test the work tree rather than the path.
    try:
        inside = subprocess.run(
            ["git", "-C", repo, "rev-parse", "--is-inside-work-tree"],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        inside = ""
    if inside != "true":
        print(f"error: not a git work tree: {repo}", file=sys.stderr)
        return 2

    req_path = find_file(repo, args.requirements, ["REQUIREMENTS.md", "PLAN.md"])
    if not req_path:
        print("error: no requirements file found (looked for REQUIREMENTS.md, PLAN.md "
              "in repo root, .planning/, docs/). Pass --requirements.", file=sys.stderr)
        return 2
    gate_path = find_file(repo, args.gates, ["GATES.md"])

    reqs = parse_requirements(req_path)
    if not reqs:
        print(f"error: no identified requirements found in {os.path.relpath(req_path, repo)}.\n"
              "       Expected lines like:  - [ ] **W1-01**: observable statement",
              file=sys.stderr)
        return 2

    gates = parse_gates(gate_path)
    gates_by_id = {g["id"]: g for g in gates}
    commits = parse_commits(repo, args.rev_range, args.limit)

    untracked, unknown_ref = [], []
    for commit in commits:
        if not commit["refs"]:
            untracked.append(commit)
            continue
        for ref in commit["refs"]:
            if ref in reqs:
                reqs[ref]["commits"].append(commit)
            else:
                unknown_ref.append((commit, ref))

    for gate in gates:
        for ref in gate["requirements"]:
            if ref in reqs:
                reqs[ref]["gates"].append(gate["id"])

    orphan_gates = [g for g in gates if not (g["requirements"] & set(reqs))]

    tally: dict[str, int] = {}
    rows = []
    for rid in sorted(reqs):
        req = reqs[rid]
        status = classify(req, gates_by_id)
        tally[status] = tally.get(status, 0) + 1
        rows.append((rid, status, req))

    rel = lambda p: os.path.relpath(p, repo) if p else "(none)"
    print(f"wb-trace  repo={os.path.basename(repo)}")
    print(f"  requirements: {rel(req_path)} ({len(reqs)} identified)")
    print(f"  gates:        {rel(gate_path)} ({len(gates)} found)")
    print(f"  commits:      {len(commits)} scanned{' in ' + args.rev_range if args.rev_range else ''}")
    print()
    width = max((len(r) for r in reqs), default=6)
    swidth = max(len(s) for _, s, _ in rows) if rows else 11
    swidth = max(swidth, 6)
    print(f"  {'ID'.ljust(width)}  {'STATUS'.ljust(swidth)}  {'CMTS':>4}  GATES     REQUIREMENT")
    print(f"  {'-' * width}  {'-' * swidth}  ----  --------  {'-' * 40}")
    for rid, status, req in rows:
        gate_list = ",".join(sorted(set(req["gates"]))) or "-"
        flag = "  <- declared done" if req["declared_done"] and status != "DONE" else ""
        print(f"  {rid.ljust(width)}  {status.ljust(swidth)}  {len(req['commits']):>4}  "
              f"{gate_list[:8].ljust(8)}  {req['text'][:40]}{flag}")

    print()
    print("  summary: " + "  ".join(f"{k}={v}" for k, v in sorted(tally.items())))

    findings = 0

    if untracked:
        findings += len(untracked)
        pct = 100 * len(untracked) // max(len(commits), 1)
        print(f"\n  UNTRACKED  {len(untracked)}/{len(commits)} commits ({pct}%) carry no requirement reference")
        for commit in untracked[:5]:
            print(f"    {commit['sha']}  {commit['subject']}")
        if len(untracked) > 5:
            print(f"    ... and {len(untracked) - 5} more")
    if unknown_ref:
        findings += len(unknown_ref)
        print(f"\n  UNKNOWN_REF  {len(unknown_ref)} commit reference(s) cite an id absent from the requirements file")
        for commit, ref in unknown_ref[:5]:
            print(f"    {commit['sha']}  cites {ref}  {commit['subject']}")
    if orphan_gates:
        findings += len(orphan_gates)
        print(f"\n  ORPHAN_GATE  {len(orphan_gates)} gate(s) claim no requirement (candidate unrequested work)")
        for gate in orphan_gates[:5]:
            print(f"    {gate['id']}  {gate['text']}")

    # ---- scope governance -------------------------------------------------
    sha = frozen_sha(req_path)
    rel_req = os.path.relpath(req_path, repo)
    if sha:
        baseline = frozen_requirement_ids(repo, sha, rel_req)
        if baseline is None:
            print(f"\n  SCOPE  frozen sha {sha} does not resolve; freeze unverifiable")
        else:
            added = sorted(set(reqs) - baseline)
            recorded = amended_ids(req_path)
            unrecorded = [r for r in added if r not in recorded]
            print(f"\n  SCOPE  frozen at {sha[:9]} with {len(baseline)} requirement(s); "
                  f"{len(reqs)} now present")
            if unrecorded:
                findings += len(unrecorded)
                print(f"  SCOPE_CREEP  {len(unrecorded)} requirement(s) added after freeze "
                      f"with no amendment entry")
                for rid in unrecorded[:8]:
                    print(f"    {rid}  {reqs[rid]['text'][:56]}")
                print("    -> record each as a dated amendment, or move it to BACKLOG.md")
            elif added:
                print(f"  {len(added)} requirement(s) added after freeze, all recorded as amendments")
    else:
        print("\n  SCOPE  no freeze marker found; add '**Frozen at:** <sha>' to "
              "REQUIREMENTS.md at the first implementation commit")

    open_reqs = [rid for rid, status, _ in rows if status != "DONE"]
    if args.wip_limit and len(open_reqs) > args.wip_limit:
        findings += 1
        print(f"\n  WIP_EXCEEDED  {len(open_reqs)} requirements open, limit is {args.wip_limit}")
        print("    Finishing beats starting. Close or park work before admitting more.")

    mismatched = [r for _, s, r in rows if r["declared_done"] and s != "DONE"]
    if mismatched:
        findings += len(mismatched)
        print(f"\n  DECLARED_NOT_EVIDENCED  {len(mismatched)} requirement(s) ticked [x] without supporting evidence")

    if args.strict and findings:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
