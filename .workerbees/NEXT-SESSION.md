# Handoff — next session

## State
- Branch `claude/project-planning-workflow-651c7e`, 19 commits, clean tree, **never pushed**.
- Full suite green: validate_skills (24), installer, routing, traceability, gate coverage, gate evidence (25 gates).
- This repo is governed by its own rules: `REQUIREMENTS.md` frozen, `commit-msg` hook live in the
  shared gitdir, `Req:` trailer required on every commit.

## Milestones
- **M1 (R-001..R-005)** DONE — auditor, commit hook, scope governance, cross-host wiring, reproducible gates.
- **M2 (R-006..R-008)** DONE — legacy families covered by requirements, 22 lifecycle leads bound to
  the requirement set, install contract preserved. R-009..R-014 are `EVIDENCED_UNTRACED` (gated, no
  commits name them — they predate the trailer convention).
- **M3 (R-015..R-018)** NOT STARTED — do skills get *selected*, do they *change behaviour*, delete what fails.
- **M1 residual (R-019..R-022)** NOT STARTED — land it, prove CI, verify Codex config, run on a real project.

## Check status any time
    python3 skills/discipline/requirements-traceability-auditor/scripts/wb_trace.py . --wip-limit 8 --range master..HEAD

## What the subagent probes established (2026-08-30)
- `commit-msg` hook **fires correctly**: commit with no `Req:` trailer rejected, exit 1, no commit created.
- Instruction layer also works: an agent that read `AGENTS.md` first complied without the hook firing.
- `swarm-lead-orchestrator` **was selected** for a multi-module refactor task, over `superpowers:*`
  and `gsd:plan-phase` competitors. Output carried the skill's distinctive structure.
- No over-triggering: a trivial file-read task invoked no skill.
- `requirements-traceability-auditor` was **not selectable** at probe time — skill discovery had not
  yet picked up the mid-session install. Re-test in a fresh session.

## First thing to do after restart
1. Confirm the skill list includes `requirements-traceability-auditor` (it should now).
2. Re-run the M3 selection probe in a fresh session: give a subagent a task like *"work out which of my
   planned requirements are actually finished"* WITHOUT naming any skill, and see whether it invokes
   the auditor. That is R-015's first real data point.
3. Decide on the stale global copy (see below).

## Open decisions for the user
- `~/.claude/skills/swarm-lead-orchestrator` is from 2026-08-28 and **differs from this repo** — it
  lacks the M2 "Bind delivery to requirements" section. Update with
  `./install.sh --target claude --group all --scope global --force` (overwrites) or leave it.
- Codex reviews are excluded per user instruction — R-019 and R-021 need amending to drop the Codex
  halves. NOT yet done.
- No other project is wired: live-bridge, OpenFloor, Salesforce Query Chains all lack the hook (R-022).
