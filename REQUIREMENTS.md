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

## Milestone 2 — bring the existing skill families under governance

**Defined:** 2026-08-30 · **Frozen at:** d9dec6d6134bb501f117a01651ebe6c9000cc487
**Core Value:** The 23 pre-existing skills are as measurable as the new one, and
any work they orchestrate is requirement-bound by default.

- [ ] **R-006**: Every pre-existing skill family is covered by a recorded
      requirement, and every gate names the requirement it proves, so the
      auditor reports no orphan gates for delivered work.
- [ ] **R-007**: Every lifecycle lead binds delivery to requirements by
      composing with the traceability auditor at its planning step, so
      orchestrated work is requirement-bound without anyone remembering to ask.
- [ ] **R-008**: Restructuring changes nothing about the installed layout or
      host discovery contract, proven by the existing installer tests across all
      four targets and every group.

### Coverage of the pre-existing families (delivered before the trailer convention)

Recorded so the existing gates prove something named. These describe work already
shipped; the auditor reports them `EVIDENCED_UNTRACED` because a gate evidences
each one but no commit names it. That is accurate, not a defect.

- [ ] **R-009**: A vendor-neutral lifecycle skill exists for each major
      engineering lifecycle domain, and each composes with the swarm execution
      substrate while retaining a sequential fallback when no workers exist.
- [ ] **R-010**: A Salesforce OmniStudio counterpart exists for each lifecycle
      domain, and each classifies its environment through the shared router
      before selecting a transport or acting on an asset.
- [ ] **R-011**: OmniStudio migration and business-record ETL have unambiguous,
      non-overlapping ownership, and migration requires behavioral-equivalence
      evidence gathered in a clean validation sandbox.
- [ ] **R-012**: Skills that touch production, live data, or destructive
      operations state their authorization, hazardous-operation, and recovery
      boundaries explicitly.
- [ ] **R-013**: Every skill package installs completely and identically across
      all four hosts at both scopes, without clobbering an existing installation
      or leaving stale files behind.
- [ ] **R-014**: Repository claims are backed by reproducible evidence —
      structural validation, routing scenarios, two-platform CI, explicit
      candidate status, documented compatibility limits, and a license.

### M2 non-goals

- **Consolidating the Salesforce variants.** Measured and rejected: 734 lines
  across 11 variants share only 10 distinct lines, all section headings. The
  premise of "~1,100 lines of near-duplication" was wrong. See Declined in
  `BACKLOG.md`.
- **Regrouping the taxonomy.** Parked: high churn across `install.sh`, tests,
  gates, and every path, with no evidence of need. Reconsider only after a
  concrete selection problem is observed.

## Amendments

Append only. An amendment invalidates the baseline for every requirement it
touches; work in flight against those requirements must be re-baselined.

| Date | Requirement | Change | Reason | Approved by |
|---|---|---|---|---|
| 2026-08-30 | R-006 | added | M2: auditor reported ORPHAN_GATE=12; pre-existing skills have no recorded requirements | owner |
| 2026-08-30 | R-007 | added | M2: make orchestrated work requirement-bound by default | owner |
| 2026-08-30 | R-008 | added | M2: protect the install contract while restructuring | owner |
| 2026-08-30 | R-009 | added | M2/R-006: name what the general lifecycle family delivers | owner |
| 2026-08-30 | R-010 | added | M2/R-006: name what the OmniStudio family delivers | owner |
| 2026-08-30 | R-011 | added | M2/R-006: name the migration/ETL ownership boundary | owner |
| 2026-08-30 | R-012 | added | M2/R-006: name the safety-boundary guarantee | owner |
| 2026-08-30 | R-013 | added | M2/R-006: name the installation guarantee | owner |
| 2026-08-30 | R-014 | added | M2/R-006: name the evidence-reproducibility guarantee | owner |
