---
name: architecture-decision-lead-orchestrator
description: Lead evidence-backed architecture decisions across competing designs, prototypes, constraints, and lifecycle costs. Use when a consequential technical choice needs explicit options and validation before implementation; do not use when the architecture is already decided or the change is routine.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Architecture Decision Lead Orchestrator

Turn an important technical question into a reversible, evidence-backed decision. The goal is not consensus theater or a decorative ADR; it is a decision whose assumptions, consequences, and invalidation conditions are visible.

## Compose with the execution substrate

This lead owns the decision frame, viable options, veto constraints, experiment design, and decision evidence. When `swarm-lead-orchestrator` is available, load it and use its capability negotiation, work packages, dispatch, collision control, independent worker audit, and integration rules. Give the swarm decision-specific units and gates from this skill; do not duplicate or weaken its execution controls.

If that skill or worker execution is unavailable, run the same units sequentially in the current agent: record the baseline, evaluate one bounded uncertainty at a time, preserve independent evidence for each option, audit it, and reconcile only after every prerequisite is resolved. Lack of parallelism is not a blocker; missing decisive evidence or decision ownership can be.

## Boundaries

- Follow the user's scope and the host's instruction hierarchy.
- Do not treat a prototype as production authorization, publish an ADR externally, or select a vendor based on invented pricing or capabilities.
- Separate requirements from preferences, facts from forecasts, and current constraints from assumed future scale.
- Use multiple workers only when options or evidence sources can be evaluated independently.

## Outcomes

- `DECIDED`: one option meets the stated decision criteria with adequate evidence and authorized decision ownership.
- `DEFERRED`: a deliberate reversible default is chosen while a named uncertainty remains.
- `INCONCLUSIVE`: evidence does not distinguish the viable options.
- `BLOCKED`: a critical constraint, stakeholder decision, or experiment is unavailable.

## Decision frame

Record the decision owner, deadline, affected systems, current baseline, must-have constraints, desired qualities, explicit non-goals, reversibility, and cost of delay. Define criteria before scoring options. Do not hide veto constraints inside weighted averages.

## Decompose by uncertainty

Create independent trajectories for the uncertainties that could change the decision:

- functional fit and contract compatibility;
- security, privacy, and compliance boundaries;
- reliability, failure isolation, and recovery;
- performance and capacity at realistic scale;
- operability, observability, migration, and rollback;
- delivery effort, vendor dependency, licensing, and exit cost.

Generate at least two genuinely different viable options when the choice is open. Include “keep the current design” when it is plausible. Do not invent a strawman alternative.

Model each uncertainty or option experiment as a work unit. Add edges from baseline/contract discovery to every option; from shared benchmark, threat-model, cost, or compatibility fixtures to experiments that consume them; and from all decisive experiments to reconciliation and the ADR. Treat shared prototypes, benchmark environments, test datasets, vendor accounts, rate limits, decision matrices, and the ADR as collision-prone resources. One owner writes a shared artifact at a time; option reviewers should not rewrite another option's evidence.

## Evidence package

```yaml
decision_package:
  question: exact decision
  owner: authorized decision owner
  baseline: current architecture and immutable revision when available
  constraints: [veto constraints]
  criteria: [{name, evidence_type, priority}]
  option: concrete design
  assumptions: []
  experiments: [{action, success_condition, limit}]
  lifecycle: {migration, operation, recovery, exit}
  risks: [{failure_mode, likelihood_basis, impact, mitigation}]
```

## Workflow

1. Verify the current architecture and contract surface before proposing replacements.
2. Define criteria and evidence standards with the decision owner.
3. Develop viable options at comparable depth.
4. Run the cheapest decisive experiment: spike, benchmark, threat model, compatibility check, or operational exercise.
5. Reconcile results without averaging away veto constraints or uncertainty.
6. Choose the smallest reversible commitment that satisfies the decision.
7. Record follow-up triggers: scale thresholds, vendor changes, incidents, or dates that require reconsideration.

## Verification

An architecture diagram or persuasive prose is review evidence, not behavioral proof. For each material claim record whether it is mechanical, observed, externally documented, inferred, or unavailable. Prototype results must identify environment, workload, data shape, revision, and differences from production.

Audit each unit for comparable option depth, provenance, reproducibility, assumption leakage, and veto-constraint coverage. The integrated decision must include the exact evidence that eliminated or favored options, not only scores or worker conclusions.

## Decision record

Report the context, options, criteria, evidence, decision, dissent, accepted tradeoffs, migration and rollback implications, invalidation triggers, and unresolved risks. Never claim “best practice” as the deciding evidence without connecting it to the stated constraints.

## Final self-check

- Did the process evaluate real alternatives rather than defend a preferred answer?
- Can a reviewer trace every decisive claim to evidence?
- Are reversibility, exit cost, and operational ownership explicit?
- Are unavailable facts represented as uncertainty instead of favorable assumptions?
