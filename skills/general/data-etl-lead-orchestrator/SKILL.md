---
name: data-etl-lead-orchestrator
description: Coordinate business-record extraction, transformation, cleansing, loading, and reconciliation across data stores. Use when mapping, partitioning, resumability, referential integrity, privacy, and data cutover require a controlled program; do not use for application, configuration, framework, or runtime conversion, which belongs to migration-lead-orchestrator.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Data ETL Lead Orchestrator

Move data without mistaking row counts for correctness. Design for deterministic reruns, traceable transformation, relationship preservation, privacy, and recoverable cutover.

## Ownership and execution composition

This lead owns business records and datasets: extract, map, cleanse, transform, load, reject handling, reconciliation, delta capture, and data cutover. It does not own application code, framework/runtime upgrades, component conversion, or configuration migration. When a broader modernization contains both, `migration-lead-orchestrator` owns the combined program and invokes this lead for bounded data waves.

When `swarm-lead-orchestrator` is available, load it for capability negotiation, work-package dispatch, collision control, worker audit, and integration. This lead supplies data-specific partition units, dependency edges, mutation controls, and reconciliation gates. If the swarm skill or workers are unavailable, process the same graph sequentially: snapshot and profile, mapping approval, parent/reference waves, dependent partitions, reconciliation, delta rehearsal, then authorized cutover. Do not weaken lineage or integrity gates.

## Authorization and data boundaries

- Record source and target owners, environments, datasets, data classes, residency, retention, permitted fields, and approved artifact locations.
- Read access does not authorize bulk export. Migration approval does not authorize production writes, deletion, source freeze, or cutover.
- Never put credentials, unrestricted production extracts, or unnecessary personal data in worker messages or repository artifacts.

## Outcomes

- `PASS`: all required reconciliation, integrity, privacy, performance, and cutover gates pass.
- `FAIL`: observed deltas or control failures exceed an approved criterion.
- `BLOCKED`: critical data access, mapping ownership, capacity, or authorization is missing.
- `UNVERIFIED`: the pipeline exists but representative or production evidence is unavailable.

## Establish the data contract

Inventory source snapshots, target schema, stable keys, ownership, volume and skew, null semantics, encodings, timezones, precision, duplicates, relationships, files, history, and deletion semantics. Every transformation rule needs an owner, deterministic implementation, and test examples.

## Partition safely

Do not shard by assumed contiguous numeric IDs. Choose immutable snapshot boundaries and stable partition keys or cursors. Account for gaps, skew, late-arriving changes, parent-child locality, cross-shard uniqueness, and ordering. Give every partition a manifest containing source bounds, schema version, row count, content digest, status, retry state, and output artifacts.

Use work units for source snapshot/profile, mapping and canonicalization, reference/parent datasets, independently bounded record partitions, rejects/remediation, cross-partition reconciliation, delta capture, and data cutover. Add edges from snapshot and mapping approval to every partition; from parent/reference loads to dependent records; from all partition manifests to global uniqueness and relationship checks; and from full plus delta reconciliation to cutover. Treat source snapshots, target tables, sequence/key allocators, mapping registries, checkpoints, reject queues, API quotas, staging storage, encryption keys, and cutover cursors as collision-prone resources. Parallelize only partitions whose keys, parents, uniqueness domains, and target write paths are demonstrably independent.

## ETL package

```yaml
etl_package:
  run_id: stable-id
  snapshot: {source, captured_at, boundary, schema_version}
  partition: {key, lower, upper, ordering, expected_rows}
  mapping: versioned mapping identifier
  controls: {pii, residency, encryption, retention}
  idempotency: stable operation and external keys
  dependencies: [parent partitions or reference datasets]
  reconciliation: [counts, key sets, field digests, relationships, business totals]
  rollback: exact compensating action and authority
```

## Workflow

1. Profile representative source data and establish a frozen or replayable snapshot.
2. Approve mappings, defaults, exception policy, and relationship order.
3. Build deterministic extraction, transformation, validation, and loading stages.
4. Run bounded partitions with idempotent writes and persistent checkpoints.
5. Quarantine errors without silently dropping or coercing records.
6. Reconcile counts, stable key sets, field-level digests, relationships, aggregates, and sampled business journeys.
7. Rehearse delta capture, cutover, restart, and rollback.
8. Execute production mutation only with explicit authorization and live monitoring.

## Verification

Zero job errors does not prove zero data loss. Absence claims require complete, uncapped evidence. Record rejected, skipped, duplicated, defaulted, truncated, and late-arriving records separately. Checksums must use canonical serialization and documented field ordering.

Audit every partition against its immutable manifest, mapping version, extraction bounds, checkpoints, retries, rejects, target effects, and digest. The integrated gate additionally requires global key-set, uniqueness, referential-integrity, business-total, privacy, and representative-journey reconciliation; per-partition counts cannot establish these properties.

## Completion report

Report snapshot and mapping versions, processed partitions, source/target counts, reconciliation results, exception inventory, privacy handling, performance, cutover state, rollback state, and retained artifacts.


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

- Can every target record be traced to source and transformation version?
- Can every partition resume without duplicate effects?
- Are cross-partition relationships and uniqueness verified?
- Are cutover, deletion, and rollback separately authorized?
