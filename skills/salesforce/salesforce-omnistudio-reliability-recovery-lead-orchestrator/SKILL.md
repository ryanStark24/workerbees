---
name: salesforce-omnistudio-reliability-recovery-lead-orchestrator
description: Validate failure handling, recoverability, and operational resilience of Salesforce OmniStudio and legacy Vlocity journeys. Use only for OmniStudio-specific reliability across OmniScripts, FlexCards, Data Mappers or DataRaptors, Integration Procedures, and extensions; do not use for generic Salesforce operations.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Reliability Recovery Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `reliability-recovery-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially: classify; map state and side effects; establish healthy controls; inject the smallest authorized fault; reconcile recovery; restore; rerun controls. Optional `sf-architect-*` complements may add a required reliability, integration, Apex, UI, ETL, DevOps, security, or performance capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

Prove bounded failure, safe retry, resumability, and recovery across the complete experience. A friendly UI error is insufficient when server work partially completed.

## Mandatory provenance fingerprint

Record org alias and ID, org type, Salesforce release and API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, storage/object/source/transport classification per asset, source revision, active asset versions, identity, data cohort, external dependencies, cache state, observability, CLI/plugin versions, and environment. Mixed estates use isolated recovery/deployment lanes and explicit cross-lane recovery order; unknown or mismatch blocks only affected assumptions.

Vlocity and Data Mapper/DataRaptor naming alone do not establish runtime behavior.

## Authorization boundary

Require explicit approval for fault injection, retries with side effects, data mutation, cache changes, deployment, activation, package installation, runtime toggles, and production exercises. Prefer mocks, test users, synthetic records, sandboxes, and reversible experiments. Define stop conditions and an emergency owner.

## Failure model

Cover browser interruption, navigation and resume, duplicate submission, expired session, insufficient permissions, malformed or missing data, Data Mapper partial load, Integration Procedure branch failure, Apex exception, callout timeout, downstream outage, stale cache, version mismatch, deployment partial failure, and observability loss.

For each scenario define trigger, blast radius, expected user state, server side effects, retry/idempotency behavior, telemetry, recovery objective, cleanup, and evidence.

## Workflow

1. Capture provenance and map the journey's state and side-effect boundaries.
2. Establish healthy control evidence and recovery objectives.
3. Rehearse faults at the smallest isolated boundary first.
4. Verify OmniScript/FlexCard messaging and state alongside server records and external effects.
5. For standard-runtime identities, verify Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Session access plus the OmniStudio permission-set license before attributing a failure to recovery logic.
6. Confirm Data Mapper and Integration Procedure retries do not duplicate, corrupt, or silently omit work.
7. Test operator detection, diagnosis, mitigation, per-lane rollback, and restart from documented instructions.
8. Restore the environment and re-run healthy controls.
9. Run broader or production exercises only when explicitly authorized.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. Recovery requires evidence of restored service and correct state; absence of visible errors is not recovery proof.

## Final self-check

- Are runtime, namespace, active version, identity, and environment provenance explicit?
- Were client state and server/external side effects reconciled?
- Are retries bounded and demonstrably idempotent where required?
- Was every injected failure authorized, reversible, and cleaned up?
