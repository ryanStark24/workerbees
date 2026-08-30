# Requirements: WorkerBees delivery discipline (M1)

**Defined:** 2026-08-30
**Frozen at:** 552038df511f302bf59eec8122178442ff06c616
**Core Value:** A project using WorkerBees can answer "is this requirement
actually delivered?" from repository evidence alone, and cannot quietly grow its
scope while failing to finish.

## Honesty note on this milestone

These requirements were **reconstructed from work already implemented in the
working tree**, then frozen before any implementation commit. That is a weaker
guarantee than freezing before implementation, and it is recorded here rather
than hidden: a plan written after the code is the exact failure this milestone
exists to prevent, and M1 is partially guilty of it.

M2 will be frozen before work begins. The auditor's `UNTRACKED` count for M1
should be read with this in mind.

## Rules for this file

1. Written before the first implementation commit. Never edited to match the code.
2. Never rewritten. Changes are appended as dated amendments below.
3. Each requirement is observable by someone who did not write the code.
4. IDs are permanent and never renumbered.

## Requirements

- [ ] **R-001**: Delivery status for every requirement is computed from
      repository evidence — commits, gates, and pasted gate evidence — and is
      never asserted by an agent. Status distinguishes not-started, started,
      claimed-but-unevidenced, and evidenced.
- [ ] **R-002**: Every commit names the requirement it advances, enforced
      mechanically at commit time, on every host and for commits typed by hand.
      Unscoped work is possible but must state a reason and is reported as drift.
- [ ] **R-003**: Scope added after the freeze is detected and named, work in
      excess of a configured limit is reported, and new ideas have a durable
      place to go that is not the active milestone.
- [ ] **R-004**: A project is wired for Claude Code, Codex, Cursor, and
      Antigravity by a single command that never overwrites existing files,
      never corrupts existing configuration, and produces the same result when
      run repeatedly.
- [ ] **R-005**: Every repository gate runs to completion using only in-repo
      tooling on a machine that has never seen this project, so recorded gate
      evidence reproduces rather than decays.

## Explicit non-goals

Unrequested work is a fidelity violation. This milestone deliberately does not do
the following; each is parked in `BACKLOG.md` with rationale.

- Multi-vendor work-slice leasing, time-box escalation, interface contracts,
  convergence checkpoints, or a branch lifecycle protocol.
- Semantic correctness checking. The auditor proves a requirement was addressed
  and gated, never that the behaviour is right.
- Blocking scope growth. Scope creep is reported, not prevented.
- Replacing or migrating GSD `.planning/` content.

## Amendments

Append only. An amendment invalidates the baseline for every requirement it
touches; work in flight against those requirements must be re-baselined.

| Date | Requirement | Change | Reason | Approved by |
|---|---|---|---|---|
| | | | | |
