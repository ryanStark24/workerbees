---
name: salesforce-omnistudio-data-etl-lead-orchestrator
description: Coordinate business-record extraction, transformation, loading, and reconciliation when Salesforce OmniStudio Data Mappers or legacy DataRaptors and Integration Procedures are central. Use only for OmniStudio-driven record movement; do not use for generic Salesforce loading, vendor-neutral ETL, or configuration, DataPack, metadata, designer, or runtime migration.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Data ETL Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `data-etl-lead-orchestrator` core skill. If either is unavailable, report it and run the self-contained fallback sequentially: classify configuration assets only to understand the execution path; define the business-record contract; profile read-only; map referential waves; rehearse; execute only when authorized; reconcile; audit. Optional `sf-architect-*` skills can supplement a required ETL, integration, security, performance, Apex, UI, or DevOps capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

This skill owns **business-record ETL**: records consumed or produced by Data Mappers/DataRaptors and Integration Procedures. It does not own migration of OmniStudio configuration, runtime, designers, DataPacks, or metadata; route that work to `salesforce-omnistudio-migration-lead-orchestrator` or the release skill. Configuration provenance is read-only context here, never an ETL workstream.

## Mandatory provenance fingerprint

Record source and target org IDs and types, release and API versions, OmniStudio licenses, Managed Package Runtime and Designer settings, installed package versions and namespaces, source revision, active asset versions, object schema, record volumes, locale/currency/time-zone rules, CLI and plugin versions, and target environment.

- Classify the Data Mapper/DataRaptor and Integration Procedure assets per the router, but do not deploy or convert them in this skill.
- Mixed configuration estates use isolated read-only context lanes. Unknown configuration provenance blocks only affected mapping/execution claims, not unrelated business-record profiling.

The runtime path for configuration does not authorize business-data mutation. “Data Mapper” and legacy “DataRaptor” names are not proof that mappings are equivalent.

## Authorization and safety

Require explicit authorization for target orgs, objects, volumes, identities, maintenance windows, permitted inserts/updates/deletes, rollback, and external calls. Default to dry-run, extract, validate, and reconciliation work. Never mutate production data, activate assets, toggle runtime settings, install packages, or run destructive DataPack operations without exact approval.

## Decomposition

Build a dependency graph across reference data, parent-child records, polymorphic lookups, junctions, product/catalog structures, effective dates, files, external IDs, Data Mapper/DataRaptor mappings, Integration Procedure orchestration, and downstream systems. Shard only inside dependency-safe waves and allocate disjoint record keys.

## Batch contract

```yaml
omnistudio_etl_batch:
  provenance: {source_org, target_org, runtime, namespace, revision}
  selection: immutable query and shard key
  schema: mappings, defaults, transforms, validation
  dependencies: predecessor waves
  idempotency: external keys and retry behavior
  authorization: allowed operations and environment
  reconciliation: counts, hashes, rejects, referential checks
  rollback: compensating plan and evidence
```

## Workflow

1. Freeze business-record mappings and capture source/target fingerprints without modifying OmniStudio configuration.
2. Profile counts, nulls, duplicates, skew, restricted values, and references read-only.
3. Rehearse representative data in an authorized non-production target.
4. Validate Data Mappers and Integration Procedures with success, missing, duplicate, timeout, and partial-failure inputs.
5. Execute dependency waves with checkpoints, idempotency keys, retry limits, and quarantine.
6. Reconcile source, accepted, rejected, written, skipped, and duplicate counts; verify referential integrity and sampled business semantics.
7. For standard-runtime paths, verify relevant Omni Data Transformation access and every business object/field permission for the actual execution identity; also check Omni Process Compilation and OmniScript Saved Session access when the journey uses them.
8. Keep target acceptance `BLOCKED` until authorized live reconciliation is complete.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. Transport success, zero command errors, and equal total counts are not sufficient without mapping, reject, integrity, and semantic evidence.


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

- Are runtime and namespace provenance explicit for every configuration asset?
- Are shards dependency-safe, non-overlapping, idempotent, and restartable?
- Did counts reconcile including rejects and duplicates?
- Was every mutation explicitly authorized and recoverable?
