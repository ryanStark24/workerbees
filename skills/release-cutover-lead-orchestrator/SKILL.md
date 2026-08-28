---
name: release-cutover-lead-orchestrator
description: Coordinate release readiness, phased rollout, cutover, rollback, hypercare, and evidence-based go or no-go decisions. Use when a consequential change crosses environments or user populations; do not use for ordinary local builds or deployment execution without release authority.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Release Cutover Lead Orchestrator

Turn a tested change into a controlled production outcome. A green build is an input, not a release decision.

## Compose with the execution substrate

This lead owns release semantics: readiness gates, decision authority, rollout ordering, abort signals, rollback, and hypercare evidence. When `swarm-lead-orchestrator` is available, load it for capability negotiation, work packages, dispatch, collision control, independent worker audits, and integration. Supply the release-specific units and mutation gates from this skill.

If the swarm skill or workers are unavailable, execute the readiness graph sequentially and keep mutations paused at their authorization gates. Validate artifact provenance and dependencies, rehearse, collect each surface decision, conduct go/no-go, then execute and observe only when authorized. Parallelism is never a prerequisite for a safe release.

## Authorization boundary

Planning and validation do not authorize deployment, traffic changes, feature enablement, schema mutation, source freeze, rollback, or external communication. Record who owns each go/no-go and mutation decision.

## Outcomes

- `GO`: all required readiness gates pass and the authorized decision owner approves execution.
- `NO-GO`: evidence shows a required gate is unmet or risk exceeds tolerance.
- `HOLD`: a time-bounded dependency or decision is pending while the release remains recoverable.
- `BLOCKED`: required environment, evidence, authority, or rollback capability is unavailable.

Execution and verification also use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` per gate.

## Release contract

Record exact artifact identifiers, source revision, target environments, included and excluded changes, configuration and data dependencies, compatibility window, rollout units, success and abort signals, observation periods, rollback authority, and point of no return.

## Decompose by readiness surface

- artifact provenance and supply chain;
- environment and dependency readiness;
- schema, configuration, and data compatibility;
- security, privacy, compliance, and access;
- functional and integration verification;
- performance, capacity, and reliability;
- observability, support, communications, and ownership;
- rollback, restore, and forward-fix rehearsal.

Make these bounded work units and add edges from immutable artifact/environment provenance to all readiness checks; from schema, configuration, and data prerequisites to deploy steps; from all required readiness gates and rehearsal to go/no-go; from authorization to production mutation; and from each rollout cohort's observation gate to the next cohort. Treat release manifests, deployment environments, traffic controls, feature flags, schema locks, migration jobs, communication channels, dashboards, and the cutover runbook as collision-prone resources. Assign one cutover controller for shared mutations and decision state.

## Cutover package

```yaml
cutover_package:
  release_id: stable-id
  artifact: immutable identifiers and digests
  target: exact environment and population
  prerequisites: []
  steps: [{action, owner, authorization, expected, timeout}]
  rollout: {strategy, units, promotion_gate, pause_gate}
  signals: {success: [], abort: [], dashboards: []}
  rollback: {trigger, action, owner, tested_at, data_consequences}
  point_of_no_return: explicit decision step
```

## Workflow

1. Resolve artifact and environment provenance; reject mutable or ambiguous candidates.
2. Build a dependency-ordered runbook with owners, timeouts, verification, and compensating actions.
3. Rehearse on the closest safe environment with realistic data and integrations.
4. Hold a go/no-go review using evidence, not schedule pressure.
5. Execute only after explicit authorization; capture each step and observed result.
6. Roll out progressively where possible, pausing between cohorts for telemetry.
7. Trigger rollback immediately when an approved abort condition occurs; do not improvise destructive recovery.
8. Verify user journeys, data, integrations, security, and operational signals during hypercare.
9. Close only after the observation window and ownership handoff.

## Verification rules

Deployment success does not prove release success. Test downstream consumers, data invariants, background work, permissions, monitoring, and rollback viability. When external or live evidence is unavailable, report `UNVERIFIED` rather than promoting source inspection to production proof.

Audit each readiness unit for exact artifact and target provenance, authorized owner, current evidence, expiry window, dependencies, rollback consequence, and explicit result. During execution, preserve step timestamps, expected versus observed state, deviations, abort decisions, cohort telemetry, and post-release user/data/integration evidence.

## Completion report

Report artifact, target, decision, executed steps, deviations, rollout state, success and abort signals, live evidence, incidents, rollback readiness or use, hypercare ownership, and remaining follow-ups.

## Final self-check

- Was the exact release candidate immutable and verified?
- Did every mutation have an authorized owner?
- Were rollback and restore actually rehearsed?
- Is production behavior proven beyond deployment status?
