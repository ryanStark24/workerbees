---
name: migration-lead-orchestrator
description: Coordinate application, configuration, framework, and runtime conversion while preserving intentional behavior. Use when migration order, compatibility, coexistence, cutover, and rollback require coordinated work; use data-etl-lead-orchestrator for bounded business-record movement, while this lead owns combined application-and-data migration programs.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Migration Lead Orchestrator

Move a system between architectures or runtimes without confusing test preservation with behavioral equivalence. Preserve intentional contracts, identify legacy defects explicitly, and keep cutover recoverable.

## Ownership and execution composition

This lead is the semantic owner for application code, configuration, component, framework, platform, and runtime conversion. It also owns the overall outcome when those changes form a combined program with business-data movement. Delegate each bounded record-extract/transform/load/reconciliation wave to `data-etl-lead-orchestrator` when that skill is available; consume its gate without taking over its mapping and reconciliation semantics. Pure business-record movement belongs to ETL instead.

When `swarm-lead-orchestrator` is available, load it for capability negotiation, dependency-aware work packages, dispatch, collision control, worker audits, and integration. This lead supplies migration units, dependency edges, equivalence gates, and cutover semantics. If the swarm skill or workers are unavailable, execute the same dependency graph sequentially: baseline, contracts, prerequisites, bounded conversions, ETL waves if any, equivalence audit, rehearsal, then authorized cutover. Missing parallelism is not a blocker.

## Boundaries

- Migration approval does not authorize production cutover, data mutation, destructive cleanup, or removal of the legacy path.
- Establish source and target versions, support windows, licenses, deployment topology, and immutable baselines before decomposition.
- Do not preserve a known defect merely because an old test encodes it. Record intentional fixes as approved behavior changes.

## Outcomes

- `PASS`: target behavior, compatibility, migration, and rollback criteria have current evidence.
- `FAIL`: evidence shows a required contract or cutover criterion is unmet.
- `BLOCKED`: required source access, target runtime, representative data, or authorization is unavailable.
- `UNVERIFIED`: implementation may be complete but equivalence or live cutover evidence is missing.

## Characterize before changing

Build a behavior inventory covering public APIs, user journeys, persisted data, events, timing, error semantics, security boundaries, operational jobs, integrations, and unsupported behavior. Classify each item as preserve, intentionally change, retire, or unknown, with an owner for every intentional change.

## Dependency-first decomposition

Construct a graph of runtime dependencies, not only file imports. Include schemas, configuration, generated artifacts, shared state, identity, external consumers, deployment order, and rollback dependencies. Migrate prerequisites before consumers when required, but use adapters or strangler seams when coexistence reduces risk.

Use bounded units for baseline/behavior capture, target foundation, shared contracts and adapters, component or configuration conversion, integration compatibility, ETL data waves, equivalence verification, cutover rehearsal, and legacy retirement. Add edges from target foundation and shared contracts to consumers; from schema/configuration conversion to dependent code and ETL mappings; from bounded conversions and ETL reconciliation to integrated rehearsal; and from rehearsal to cutover. Treat schemas, migration manifests, generated code, shared adapters, compatibility fixtures, environments, databases, deployment slots, and cutover runbooks as collision-prone resources. Serialize their writers even when source files differ.

## Migration package

```yaml
migration_package:
  component: bounded migration unit
  source: {runtime, version, revision}
  target: {runtime, version, revision}
  dependencies: []
  behavior: {preserve: [], change: [], retire: [], unknown: []}
  compatibility: {upstream: [], downstream: [], coexistence: []}
  verification: {golden: [], differential: [], negative: [], live: []}
  cutover: {entry, observation, rollback, point_of_no_return}
```

## Workflow

1. Inventory behavior and telemetry from the current system.
2. Freeze source and target baselines plus compatibility constraints.
3. Create dependency waves and explicit coexistence contracts.
4. Migrate one bounded slice with deterministic transforms and idempotent reruns.
5. Compare old and new behavior using golden masters, differential tests, contract tests, and representative journeys.
6. Run a rehearsal with realistic data, concurrency, integrations, and failure injection.
7. Cut over only with explicit authorization, observability, rollback ownership, and a point-of-no-return decision.
8. Remove legacy paths only after the agreed observation period and separate destructive approval.

## Equivalence rules

The legacy test suite is evidence, not the entire contract. Require non-vacuous target tests, output and side-effect comparison, error-path comparison, security equivalence, performance budgets, and live evidence where the acceptance criterion is live. Explain every accepted delta.

Audit each conversion unit for exact source/target provenance, dependency satisfaction, deterministic transformations, compatibility in both coexistence directions, negative paths, and rollback. For delegated ETL waves, require record lineage, mapping version, rejects, referential integrity, business-total reconciliation, and idempotent rerun evidence before the migration program can pass.

## Completion report

Report migrated and unmigrated scope, compatibility state, preserved and intentionally changed behavior, rehearsals, cutover status, rollback readiness, live evidence, remaining coexistence, and deferred cleanup.


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

- Are behavior and data contracts traced across producers and consumers?
- Can the migration be rerun safely?
- Is rollback tested rather than merely documented?
- Are legacy removals separately authorized?
