---
name: performance-capacity-lead-orchestrator
description: Coordinate performance diagnosis, capacity modeling, load experiments, and regression control across system boundaries. Use when latency, throughput, resource limits, concurrency, or scale require evidence-based analysis; do not use as a generic code-quality or security audit.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Performance and Capacity Lead Orchestrator

Measure, localize, change, and remeasure under comparable conditions. Do not optimize by aesthetic preference or turn a synthetic benchmark into an unsupported production forecast.

## Compose with the execution substrate

This lead owns workload validity, performance budgets, bottleneck hypotheses, experiment controls, capacity models, and before/after evidence. When `swarm-lead-orchestrator` is available, load it for capability negotiation, work-package dispatch, collision control, worker audits, and integration. Supply the performance-specific units, resource leases, and comparison gates below.

If the swarm skill or workers are unavailable, run the same experiments sequentially: validate telemetry, freeze baseline conditions, test competing hypotheses one bounded change at a time, remeasure comparably, and audit the capacity claim. Sequential execution is often preferable when experiments would contend for the same environment.

## Boundaries

- Load against production, paid services, shared environments, or third-party endpoints requires explicit authorization and agreed limits.
- Establish stop conditions for error rate, saturation, cost, customer impact, and data integrity.
- Protect sensitive payloads and credentials in traces, profiles, and test artifacts.

## Outcomes

- `PASS`: required service-level and resource criteria hold under the stated workload with reproducible evidence.
- `FAIL`: a required budget is exceeded under valid test conditions.
- `BLOCKED`: representative environment, workload, telemetry, or authorization is unavailable.
- `UNVERIFIED`: a change is plausible but comparable measurement was not obtained.

## Performance frame

Define the user or machine journey, workload model, data distribution, concurrency, arrival pattern, warmup, duration, environment, dependencies, caches, service-level indicators, budgets, and saturation signals. Separate latency percentiles from averages and throughput from concurrency.

## Decompose by resource boundary

Evaluate client/rendering, network, edge, application compute, runtime queues, persistence, locks, caches, external dependencies, background jobs, and infrastructure limits. Assign one trajectory to workload validity and one to observability quality when those are uncertain.

Use work units for telemetry validation, workload/dataset validation, baseline capture, bounded resource hypotheses, intervention experiments, saturation/recovery behavior, and regression controls. Add edges from telemetry and workload validation to baseline; from baseline to all diagnostic experiments; from a confirmed bottleneck to its intervention; and from comparable reruns to capacity modeling and regression thresholds. Treat load generators, target environments, datasets, caches, queues, databases, third-party quotas, profiler sessions, ports, and telemetry windows as collision-prone resources. Do not run concurrent experiments unless interference is intentionally modeled and measured.

## Experiment package

```yaml
performance_experiment:
  hypothesis: falsifiable bottleneck claim
  baseline: {revision, environment, configuration}
  workload: {journey, dataset, arrival, concurrency, duration, warmup}
  metrics: [latency percentiles, throughput, errors, saturation, cost]
  controls: {fixed_variables, stop_conditions, max_load}
  change: one bounded intervention
  comparison: statistical and operational acceptance criteria
```

## Workflow

1. Validate telemetry and capture a baseline before changing code or configuration.
2. Form competing bottleneck hypotheses from traces, profiles, query plans, and resource signals.
3. Run the smallest safe experiment that distinguishes them.
4. Change one material variable at a time unless interaction is the explicit subject.
5. Repeat under comparable conditions and quantify uncertainty or variance.
6. Test negative paths, saturation behavior, recovery, and downstream effects.
7. Convert the accepted budget into regression checks and monitoring.
8. Extrapolate capacity only with a stated model and verified scaling assumptions.

## Evidence rules

Record raw artifact locations, tool versions, timestamps, dataset identity, environment differences, sample counts, percentiles, errors, and saturation. Do not cherry-pick the best run. Client timings, server timings, and external dependency latency must remain distinguishable.

Audit each experiment for a falsifiable hypothesis, fixed and changed variables, warmup, sample sufficiency, stop-condition adherence, raw artifacts, variance, and negative effects. The integrated gate requires comparable baseline/intervention results plus a capacity envelope tied to measured saturation and recovery—not a collection of unrelated microbenchmarks.

## Completion report

Report baseline, workload validity, localized bottleneck, experiments, before/after metrics, statistical caveats, capacity envelope, failure behavior, regression controls, and remaining production uncertainty.


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

- Were before and after conditions comparable?
- Did the evidence localize causality rather than merely correlate metrics?
- Were load, cost, and production-impact limits respected?
- Is the claimed capacity bounded by measured assumptions?
