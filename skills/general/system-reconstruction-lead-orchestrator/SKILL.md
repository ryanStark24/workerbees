---
name: system-reconstruction-lead-orchestrator
description: Reconstruct an undocumented system's architecture, contracts, runtime journeys, ownership, and operations from source and evidence. Use for legacy takeover, due diligence, or onboarding where documentation must be verified; do not use for routine API reference generation or documenting every method mechanically.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# System Reconstruction Lead Orchestrator

Create trustworthy documentation for a system that lacks it. Prioritize the knowledge required to change, operate, debug, secure, and recover the system—not indiscriminate method catalogs.

## Compose with the execution substrate

This lead owns reconstruction questions, source-of-truth judgments, journey coverage, contradiction handling, and documentation usability. When `swarm-lead-orchestrator` is available, load it for capability negotiation, read-only work packages, dispatch, collision control, independent audit, and integration. Supply the domain units and evidence model below.

If the swarm skill or multiple workers are unavailable, inspect modules and journeys sequentially, maintain the same evidence inventory, resolve cross-module contracts before dependent narratives, and perform a final cold-read audit. Sequential execution must preserve contradictions rather than smoothing them into a single unsupported story.

## Boundaries

- Inspect read-only unless edits are explicitly requested.
- Treat comments, tickets, diagrams, generated docs, and names as hypotheses until source or runtime evidence corroborates them.
- Do not include secrets, personal data, private endpoints, or production payloads in published documentation.
- Mark runtime-dependent claims `UNVERIFIED` when no current runtime evidence exists.

## Outcomes

- `PASS`: required documentation surfaces are traced to current evidence and usability checks pass.
- `FAIL`: documentation contradicts source or a required journey cannot be followed.
- `BLOCKED`: critical repositories, runtime access, or ownership information is unavailable.
- `UNVERIFIED`: source reconstruction is complete but live behavior remains unobserved.

## Reconstruct by system questions

Decompose around questions a maintainer must answer:

- What enters and leaves the system?
- Which components own state and contracts?
- How do identity, authorization, and tenant boundaries work?
- What are the critical user and machine journeys?
- What runs synchronously, asynchronously, or on schedules?
- How is the system built, configured, deployed, observed, backed up, and recovered?
- Which dependencies, generated artifacts, and external systems are authoritative?
- Where are the known unknowns and operational hazards?

Use bounded work units for entrypoints and contracts, state and data ownership, identity and trust boundaries, critical journeys, build/deploy topology, and operations/recovery. Add edges from repository/environment provenance to all units; from producer and transport discovery to consumer journey traces; and from reconciled contracts to diagrams, runbooks, and onboarding tests. Treat generated documentation, symbol indexes, shared diagrams, local services, ports, databases, and evidence catalogs as collision-prone resources. Assign one integrator to shared narratives and diagrams while investigators submit evidence records.

## Evidence inventory

```yaml
reconstruction_item:
  claim: precise system statement
  surface: architecture | contract | journey | data | security | operation
  evidence: [{kind, revision, location, observed_at}]
  confidence: confirmed | likely | conflicting | unavailable
  consumers: []
  freshness_trigger: source, configuration, or runtime change that invalidates it
```

## Workflow

1. Establish repository, revision, environment, and documentation scope.
2. Inventory entrypoints, schemas, APIs, events, jobs, configuration, persistence, and deployment artifacts.
3. Trace critical journeys end to end across producers, transports, consumers, state changes, and failure paths.
4. Reconcile contradictory sources; preserve contradictions until evidence resolves them.
5. Produce small diagrams only where topology or sequence is materially clearer than prose.
6. Validate commands and onboarding steps in a safe environment.
7. Ask an uninformed reviewer—or simulate a cold read—to locate, run, diagnose, and recover representative workflows using only the documentation.

## Coverage model

Use AST or symbol tools to find public surfaces, but do not equate “every public method listed” with system comprehension. Coverage is complete when required contracts, ownership, journeys, state, operations, and failure behavior are represented and traceable.

Audit every unit for revision and environment provenance, source/runtime corroboration, unresolved contradictions, sensitive-data removal, downstream consumers, and freshness triggers. The integrated documents must survive representative locate, run, diagnose, and recover tasks; file counts or symbol coverage alone do not pass.

## Deliverables

Produce an architecture map, component ownership, data and contract catalog, critical sequence journeys, environment and deployment model, operational runbook, failure and recovery guide, glossary, evidence index, and known-unknowns register. Keep generated reference separate from human-authored explanation when appropriate.


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

- Can a new maintainer identify source of truth and safe change boundaries?
- Can operators diagnose and recover a representative failure?
- Does every material claim have current evidence or an uncertainty label?
- Were secrets and sensitive payloads excluded?
