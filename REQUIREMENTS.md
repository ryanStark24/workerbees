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

## Milestone 3 — are these skills actually worth having?

**Defined:** 2026-08-30 · **Frozen at:** PENDING_M3_COMMIT
**Core Value:** Every shipped skill is known to be selected when it is relevant
and to change what an agent does — or it is deleted.

Why this milestone exists: 25 gates prove structure — files exist, frontmatter
parses, composition strings are present. **None prove a model would ever select a
skill, or that following one changes any output.** Existence was made rigorously
measurable while value went unmeasured. Measured signal: every WorkerBees skill
appears in exactly 1 of 1010 session transcripts (this session's own), against
978 for `brainstorming`, `test-driven-development`, and `sf-architect-apex`; and
only 1 of 23 packages is installed anywhere an agent can see it. The pack is two
days old, so this is weak evidence of failure but zero evidence of value.

- [ ] **R-015**: Every skill is selected by a model when given realistic task
      descriptions from its stated domain, measured by an eval suite rather than
      by inspection of its description.
- [ ] **R-016**: Every skill demonstrably changes agent behaviour: for a task in
      its domain, output produced while following it differs in a stated,
      reviewable way from output produced without it.
- [ ] **R-017**: Skill descriptions route on concrete triggers rather than a
      subjective size judgement the model must make first, and no skill's
      selection surface is indistinguishable from a sibling's.
- [ ] **R-018**: Any skill that fails R-015 or R-016 is deleted or merged, and
      the removal is recorded. A skill that is never selected is worse than
      absent: it carries maintenance cost at zero value.

### M3 non-goals

- Rewriting skill *content* for quality. This milestone measures selection and
  behavioural effect, not domain correctness.
- Adding new skills. M3 may only reduce the set.

## Milestone 1 — residual work (not covered by R-001..R-005)

R-001 through R-005 are `DONE`: each has commits, a gate, and pasted evidence.
That is delivery evidence, **not** landing or field validation. These items were
never written as requirements, which is itself the finding.

- [ ] **R-019**: The M1 change is landed through this project's merge gate — pull
      request, internal code review, and independent technical *and* functional
      review — with every gate reported as run rather than assumed.
- [ ] **R-020**: The gate suite is proven to reproduce on a machine that has
      never seen this project, by CI executing on both platforms. Never yet run:
      the branch has no upstream and CI has zero executions.
- [ ] **R-021**: The Codex hook configuration is confirmed against a real Codex
      installation. It is currently a best reading of published documentation,
      never executed, and `wb-init` says so in its own output.
- [ ] **R-022**: The governance is validated on a project that is not this one,
      by running `wb-init` against a real repository and reporting what the
      auditor finds there.

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
| 2026-08-30 | R-015 | added | M3: skills are never selected in 1010 transcripts; no gate tests selection | owner |
| 2026-08-30 | R-016 | added | M3: no gate tests whether a skill changes behaviour | owner |
| 2026-08-30 | R-017 | added | M3: descriptions route on a subjective size judgement | owner |
| 2026-08-30 | R-018 | added | M3: unselected skills cost maintenance at zero value | owner |
| 2026-08-30 | R-019 | added | M1 residual: merge gate never run; landing was never a requirement | owner |
| 2026-08-30 | R-020 | added | M1 residual: CI has zero executions; reproducibility unproven off this machine | owner |
| 2026-08-30 | R-021 | added | M1 residual: Codex hook schema never executed by Codex | owner |
| 2026-08-30 | R-022 | added | M1 residual: governance never run against a real project | owner |
