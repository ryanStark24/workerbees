---
name: salesforce-omnistudio-architecture-decision-lead-orchestrator
description: Lead Salesforce OmniStudio architecture choices involving OmniScripts, FlexCards, Data Mappers, Integration Procedures, Flow, LWC, Apex, middleware, and standard versus managed-package runtime. Use only for consequential OmniStudio-domain design decisions; do not use for generic Salesforce architecture.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Architecture Decision Lead

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `architecture-decision-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially with a self-contained fallback: classify each asset; frame the decision; define veto constraints; develop comparable options; run decisive experiments; record the decision and invalidation triggers; audit the evidence. Optional `sf-architect-*` complements may add a required UI, Apex, integration, DevOps, ETL, security, or performance capability only after their exact path and version/source provenance are verified and their complete instructions are read; they are never hard dependencies.

Choose the right OmniStudio boundary from evidence, not from a rule that every declarative problem belongs in OmniStudio or every complex problem belongs in Apex.

## Mandatory provenance fingerprint

Record org ID/type, release/API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, package versions and namespaces, storage/object family and source representation per asset, supported industry cloud, target channels, active asset provenance, and lifecycle horizon. Choose metadata or DataPack transport per asset through the router. Mixed estates use isolated lanes; unknown or mismatched facts block dependent decisions.

## Decision surfaces

Evaluate OmniScript versus Flow or custom LWC for guided interaction; FlexCard versus standard Lightning UI for contextual display; Data Mapper versus SOQL/Apex/middleware for data access and transformation; Integration Procedure versus Flow/Apex/middleware for orchestration; standard versus managed runtime; generated LWC versus standard components; synchronous versus asynchronous boundaries; and reusable service versus channel-specific composition.

## Veto constraints

Do not average away unsupported runtime features, namespace/package dependencies, Experience Cloud/LWR or OmniOut requirements, FLS and sharing, transactionality, governor limits, external-system SLAs, accessibility, localization, deployment support, or rollback. Verify current support against authoritative Salesforce documentation and the target org.

## Decision package

```yaml
omnistudio_decision:
  question: exact boundary choice
  provenance: {org, runtime, designer, package, namespace, release}
  channels: [Lightning, Experience, mobile, off-platform]
  contract: {input, output, state, error, transaction}
  options: [{design, assets, dependencies, lifecycle}]
  criteria: [supportability, security, performance, operability, reuse, migration]
  experiments: [{prototype, success_condition, environment}]
```

## Workflow

1. Trace the current or proposed end-to-end JSON and transaction boundaries.
2. Generate genuinely viable options at comparable depth, including standard platform alternatives.
3. Prototype the uncertain boundary in an org matching the target runtime and package state.
4. Measure response size, server calls, CPU/query usage, client behavior, errors, caching, and accessibility where relevant.
5. Evaluate source control, dependency ordering, activation, rollback, upgrades, and designer/runtime migration.
6. For standard-runtime options, include explicit Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Session FLS/object access plus OmniStudio permission-set-license checks.
7. Record `DECIDED`, `DEFERRED`, `INCONCLUSIVE`, or `BLOCKED`, with invalidation triggers.

## Evidence rules

Designer availability does not prove channel support; preview does not prove user permissions; a successful Integration Procedure does not prove OmniScript composition; package documentation does not prove the org's installed version. Attach provenance to every decisive claim.

## Final self-check

- Was the OmniStudio option compared with relevant Flow, LWC, Apex, and middleware alternatives?
- Did the prototype use the actual runtime and namespace model?
- Are deployment, upgrade, observability, and recovery costs included?
- Are unsupported or live-only claims explicitly non-pass?
