---
name: salesforce-omnistudio-system-reconstruction-lead-orchestrator
description: Reconstruct and document Salesforce OmniStudio and legacy Vlocity systems from deployed assets and executable evidence. Use only for OmniStudio-domain archaeology across OmniScripts, FlexCards, Data Mappers or DataRaptors, Integration Procedures, and their extensions; do not use for generic Salesforce documentation.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio System Reconstruction Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `system-reconstruction-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially: classify; inventory; parse each source lane; trace representative journeys; reconcile runtime evidence; document coverage; have a clean-context verifier follow the result. Optional `sf-architect-*` complements may add a required UI, Apex, integration, DevOps, ETL, security, or performance capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

Build a provenance-backed map of what actually executes, including active versions and runtime-dependent deployment formats. Do not turn naming conventions or stale exports into architectural facts.

## Mandatory provenance fingerprint

Record org alias and ID, org type, Salesforce release and API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, storage/object/source/transport classification per asset, source revision and status, retrieval/export timestamp, active asset versions, page bindings, CLI/plugin versions, and target environment. Parse metadata and DataPack JSON in separate lanes; mixed is valid when every lane is resolved, while unknown or mismatch blocks affected topology claims.

Vlocity terminology alone is not namespace provenance. Data Mapper may appear as legacy DataRaptor terminology depending on runtime and history.

## Safety

Default to read-only retrieval, export, source inspection, and authorized preview. Do not deploy, activate, mutate live data, install packages, toggle runtime settings, or invoke side-effecting Integration Procedures or Data Mappers without explicit authorization. Redact secrets and customer payloads from documentation.

## Reconstruction map

Inventory OmniScripts, FlexCards, Data Mappers/DataRaptors, Integration Procedures, active and inactive versions, generated LWCs, Apex/LWC extensions, remote actions, object and field dependencies, permissions, Named Credentials, caches, pages, communities, downstream APIs, and deployment manifests.

For each node record stable key, display name, type, version, active state, namespace, runtime, source location, inputs, outputs, callers, callees, identities, side effects, and evidence location. Label every edge `CONFIRMED`, `INFERRED`, or `UNKNOWN`.

## Workflow

1. Capture the runtime fingerprint and obtain the authoritative export/retrieval.
2. Parse structural references and version lineage without assuming the active path.
3. Divide by cohesive journey or domain while keeping shared dependencies centrally indexed.
4. Trace representative entry points through UI, orchestration, mappings, extensions, data, and integrations.
5. Reconcile source definitions with page binding, permissions, and authorized runtime observations.
6. For standard-runtime user journeys, document explicit access to Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Sessions plus the OmniStudio permission-set license.
7. Generate diagrams, contract tables, deployment notes, ownership gaps, and onboarding runbooks.
8. Have a verifier follow the runbook from a clean context and record every ambiguity.

## Coverage gate

Report measured totals for discovered, parsed, documented, unreachable, dynamic, and blocked assets. A repository scan does not establish deployed or active coverage; a designer listing does not establish source completeness.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. Documentation is complete only against a declared inventory and provenance boundary.

## Final self-check

- Does every public journey and reusable asset have an evidence-linked contract?
- Are active version, runtime, namespace, and org provenance explicit?
- Are inferred and dynamic edges visibly separated from confirmed ones?
- Can a new operator retrieve and trace the system without tribal knowledge?
