---
name: salesforce-omnistudio-release-cutover-lead-orchestrator
description: Coordinate release, deployment, activation, cutover, and rollback for Salesforce OmniStudio and legacy Vlocity solutions. Use only when OmniStudio assets and their runtime-specific transport are central; do not use for generic Salesforce releases or vendor-neutral deployment work.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Release Cutover Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and every routed reference used by the release. Then locate and read the complete shipped `release-cutover-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially: classify per asset; pin manifests; validate prerequisites; rehearse each lane and cross-lane gates; obtain go/no-go; execute only when authorized; verify; observe or roll back. Optional `sf-architect-*` complements may add a required DevOps, UI, Apex, integration, ETL, security, or performance capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

Release the exact tested asset versions through the transport required by their actual runtime. Treat deployment, activation, page binding, cache behavior, and user acceptance as separate gates.

## Mandatory provenance fingerprint

Record source and target org IDs and types, release and API versions, OmniStudio licenses, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, storage/object/source/transport classification per asset, source revision and clean/dirty status, active asset versions, manifest/export identity, CLI/plugin versions, deployment identity, and change window. A mixed release uses separate metadata and DataPack manifests, dependency graphs, commands, checkpoints, rollback actions, evidence, and verdicts; cross-lane dependencies are explicit gates. Unknown or mismatched assets block their lane, not automatically every independent lane.

Data Mapper versus legacy DataRaptor terminology and the word Vlocity do not prove namespace or deployment format.

## Authorization boundary

Require explicit approval for each target org, deployment, asset activation/deactivation, page reassignment, cache operation, runtime/designer toggle, package change, business-data mutation, and rollback. Prepare and validate read-only plans freely; do not enter the production change window without named authority and stop conditions.

## Release manifest

Pin OmniScripts, FlexCards, Data Mappers/DataRaptors, Integration Procedures, generated LWCs, Apex/LWC extensions, permissions, page/community bindings, credentials, dependencies, and business-data prerequisites. Record version, active state, namespace, runtime, source hash, deployment order, validation, owner, and rollback action.

## Workflow

1. Capture provenance and prove the source revision matches the reviewed candidate.
2. Build separate router-selected transport manifests and dependency graphs, then an explicit cross-lane gate map.
3. Validate target prerequisites, permissions, package versions, capacity, data, and external services.
4. Rehearse deployment, activation order, smoke tests, monitoring, abort, and rollback in an authorized non-production environment.
5. Hold go/no-go with explicit acceptance gates and evidence owners.
6. During an authorized cutover, journal each command, result, asset version, activation, and deviation.
7. Verify representative OmniScript and FlexCard journeys plus isolated Data Mapper and Integration Procedure success, error, timeout, and authorization paths. For standard-runtime identities, explicitly verify Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Session access plus the OmniStudio permission-set license.
8. Observe the defined stability window before closing or execute the rehearsed per-lane and cross-lane rollback when a stop condition fires.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. A successful deploy command is not proof that the intended version is active, bound, permitted, or functioning end to end.

## Final self-check

- Was every asset moved with the correct runtime and namespace provenance?
- Were activation and page binding separately authorized and verified?
- Can rollback restore the previous executable state, not only source files?
- Is production acceptance backed by direct, timestamped evidence?
