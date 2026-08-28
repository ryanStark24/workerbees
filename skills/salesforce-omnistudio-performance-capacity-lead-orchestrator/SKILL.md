---
name: salesforce-omnistudio-performance-capacity-lead-orchestrator
description: Diagnose and validate performance and capacity for Salesforce OmniStudio and legacy Vlocity journeys. Use only when OmniScripts, FlexCards, Data Mappers or DataRaptors, Integration Procedures, or their extensions dominate the latency or scale path; do not use for generic Salesforce performance work.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Performance Capacity Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `performance-capacity-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially: classify; establish comparable baselines and budgets; isolate one bottleneck; run bounded experiments; verify correctness and tails; retest the complete journey. Optional `sf-architect-*` complements may add a required performance, Apex, integration, UI, ETL, DevOps, or security capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

Measure complete user journeys and isolate cost by component, identity, data shape, cache state, and external dependency. Never optimize from designer impressions or a single warm run.

## Mandatory provenance fingerprint

Record org alias and ID, org type, Salesforce release and API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, package versions and namespaces, storage/object/source/transport classification per asset, source revision, active asset versions, user identity, browser/device, data-volume shape, cache state, external endpoints, CLI/plugin versions, and environment. Mixed lanes can be measured independently; comparisons require equivalent lane, version, identity, data, and cache provenance. Unknown or mismatched facts block only affected comparisons.

Data Mapper and legacy DataRaptor labels are not proof of identical execution behavior.

## Safety and authorization

Default to source review, existing telemetry, synthetic payloads, and authorized non-production tests. Do not load-test production, mutate live data, clear shared caches, activate or deploy assets, toggle runtime settings, install packages, or stress third-party services without explicit scope, rate limits, monitoring, and stop authority.

## Budget model

Define user-visible budgets for initial render, step transition, action response, and completion; server budgets for Integration Procedure and Data Mapper duration, query/callout counts, payload size, cache hit rate, CPU and heap; and reliability budgets for error and timeout rates. Pin sample size, percentiles, concurrency, warm/cold state, and data cohorts.

## Workflow

1. Capture a repeatable baseline with immutable provenance.
2. Trace OmniScript and FlexCard calls into Data Mappers, Integration Procedures, Apex, queries, callouts, and downstream systems.
3. Assign independent bottleneck hypotheses without overlapping load generators.
4. Test representative small, typical, large, skewed, missing, error, and timeout payloads.
5. Separate client rendering, network, platform execution, cache, and downstream time.
6. For standard-runtime tests, verify Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Session access plus the OmniStudio permission-set license so permission failures are not misreported as performance.
7. Change one causal variable per experiment and compare equivalent cohorts.
8. Run authorized concurrency and endurance tests only after single-request correctness and stop controls pass.
9. Re-run the baseline and regression journeys; document residual capacity and invalidation conditions.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` against declared budgets. A faster median with worse tails, errors, data correctness, security, or cache isolation is not a pass.

## Final self-check

- Are runtime, namespace, version, identity, data, and cache provenance comparable?
- Were all four OmniStudio component families isolated where present?
- Were warm/cold and percentile effects measured?
- Did every load action remain authorized and bounded?
