---
name: reliability-recovery-lead-orchestrator
description: Coordinate failure-mode analysis, resilience tests, backup restoration, disaster recovery, and convergence verification. Use when a system must tolerate partial failure or recover from loss; do not use for routine bug fixing or uncontrolled chaos testing.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Reliability and Recovery Lead Orchestrator

Prove how a system fails and returns to a trustworthy state. “Retry exists” and “backup completed” are not recovery evidence.

## Compose with the execution substrate

This lead owns failure models, resilience scenarios, recovery objectives, state invariants, restoration, and convergence evidence. When `swarm-lead-orchestrator` is available, load it for capability negotiation, isolated work packages, resource leases, safe dispatch, worker audits, and integration. Supply the reliability-specific scenarios and gates from this skill.

If the swarm skill or workers are unavailable, run scenarios sequentially. Establish the healthy baseline, authorize and inject one bounded fault, observe, restore and reconcile fully, reset the environment, then begin the next scenario. Never overlap faults merely to simulate parallel work.

## Authorization boundary

Fault injection, process termination, failover, restore, traffic manipulation, data corruption, deletion, or rollback against shared or production systems requires explicit authorization, exact targets, stop conditions, and recovery ownership.

## Outcomes

- `PASS`: required failure and recovery scenarios converge within stated objectives without violating invariants.
- `FAIL`: observed loss, duplication, unsafe state, or recovery time violates a required criterion.
- `BLOCKED`: fault controls, backups, isolated environments, telemetry, or authorization are unavailable.
- `UNVERIFIED`: design or unit evidence exists but operational recovery was not exercised.

## Reliability frame

Record critical services and data, availability objectives, recovery time and point objectives, consistency and durability invariants, dependency assumptions, degraded modes, ownership, escalation, and unacceptable failure states.

## Decompose by failure boundary

- process, host, zone, region, network, dependency, identity, storage, queue, scheduler, configuration, deploy, operator, and capacity failure;
- timeout, duplicate, reorder, partial commit, stale read, split brain, poison message, retry storm, and corrupted backup;
- detection, containment, failover, restoration, reconciliation, and return to normal.

Use work units for dependency/state mapping, backup verification, detection paths, one bounded fault scenario per failure boundary, restore or failover, canonical-state reconciliation, and regression drills. Add edges from healthy baseline and authorization to fault injection; from each fault to its detection and containment observations; from containment to recovery; from recovery to reconciliation; and from a fully reset environment to any later scenario. Treat environments, traffic, processes, regions, databases, queues, clocks, backup sets, failover controls, credentials, and incident channels as collision-prone resources. One fault controller owns shared state; evidence review may proceed in parallel only after artifacts are immutable.

## Scenario package

```yaml
recovery_scenario:
  fault: exact injected or observed failure
  target: isolated component and environment
  preconditions: [backups, traffic, invariants]
  authorization: owner and approved window
  stop_conditions: []
  expected_degradation: []
  recovery: {automatic, manual_steps, owner, timeout}
  invariants: [no loss, no duplicate effect, authorization, ordering]
  evidence: [telemetry, state comparison, restore artifacts]
```

## Workflow

1. Map dependencies, state ownership, failure propagation, and recovery controls.
2. Rank scenarios by impact and uncertainty, not theatrical severity.
3. Verify backups for completeness, integrity, encryption, retention, and restore compatibility.
4. Exercise one controlled fault at a time in the safest representative environment.
5. Observe detection, degraded behavior, isolation, retry, and operator signals.
6. Restore or converge, then reconcile canonical state, side effects, queues, and external consumers.
7. Repeat after fixing gaps and encode regression drills.
8. Run production exercises only with separate authorization and a rehearsed abort path.

## Verification rules

A successful restart does not prove recovery. Verify data, identity, authorization, ordering, deduplication, downstream effects, backlog drain, monitoring, and return-to-service timing. A backup is not valid until restored and reconciled.

Audit each scenario for exact baseline and fault, authorization, blast radius, stop conditions, telemetry continuity, recovery timing, point-in-time state, invariant results, downstream effects, and environment reset. The integrated gate requires cross-scenario coverage of common-mode dependencies and proof that recovery actions do not compromise later operation.

## Completion report

Report scenarios, exact faults, environments, observed degradation, detection, recovery time and point, invariant results, manual interventions, backup restore evidence, unresolved single points of failure, and drill cadence.


## Bind delivery to requirements

Before decomposing work, load `requirements-traceability-auditor` when it is
available. It owns the frozen requirement set, the commit-to-requirement
binding, and the computed delivery status; this skill owns the domain work.

Consequences that hold for every unit dispatched from here:

- A unit exists to advance a recorded requirement. If it advances none, either
  record the requirement first or park the idea — do not build it unnamed.
- Every commit names its requirement. Completion is read from the auditor's
  computed status, never asserted from a worker's report or your own judgement.
- New scope discovered mid-flight goes to the backlog, or enters through a dated
  amendment. It is never absorbed silently into the open milestone.

If that skill is unavailable, keep the same discipline manually: state which
recorded requirement each unit serves, and report anything unevidenced as
`UNVERIFIED` rather than complete.

## Final self-check

- Did every injected fault stay within authorization?
- Was canonical state reconciled after recovery?
- Were retry storms, duplicates, and partial effects checked?
- Are recovery objectives supported by exercises rather than documentation?
