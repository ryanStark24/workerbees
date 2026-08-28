---
name: salesforce-omnistudio-investigation-lead-orchestrator
description: Investigate Salesforce OmniStudio and legacy Vlocity failures across OmniScripts, FlexCards, Data Mappers or DataRaptors, Integration Procedures, packages, and runtime composition. Use only for OmniStudio-domain incidents or debugging; do not use for generic Salesforce or vendor-neutral investigations.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Investigation Lead Orchestrator

## Required composition

Locate and read the complete `salesforce-omnistudio-environment-router` package first, including every reference selected by its classification. Then locate and read the complete shipped `investigation-lead-orchestrator` core skill for hypothesis management, evidence trajectories, causal connection, contradiction handling, and integration. If either package is unavailable, report it and continue self-contained and sequentially: fingerprint and classify; reproduce safely; enumerate competing hypotheses; run bounded discriminating checks; connect cause to incident; audit evidence; then propose remediation. Do not pretend a missing skill was loaded.

Optional `sf-architect-*` complements are capability supplements, never dependencies. Load one only after the traced boundary requires UI, Apex, integration, DevOps, ETL, security, or performance expertise; record its exact name/path and version/source provenance and read it completely. If absent, apply the corresponding checks in this skill sequentially.

Find causal failures across designer, storage model, metadata, activation, runtime, data orchestration, security, and external systems without confusing a locally visible defect with proof of the reported incident.

## Detect before investigating

Treat **runtime**, **storage/data model**, and **transport** as three separate facts. They often align, but they are not interchangeable: a managed-package runtime can contain legacy namespaced custom-object assets, standard Omni objects, or a mixture. Runtime JSON passed between components is also different from DataPack JSON used to serialize legacy configuration.

Before selecting queries or parsers, establish the environment from read-only evidence:

1. Read the Managed Package Runtime and Designer settings and the OmniStudio license state.
2. Describe the org and inventory installed package namespaces and versions.
3. Probe for the affected asset by stable key in both applicable object families; never use absence from one family as proof without checking permissions and query caps.
4. Inspect the repository/export shape and deployment manifest independently of the org.
5. Record one classification: `STANDARD_NATIVE`, `MANAGED_LEGACY`, `MANAGED_STANDARD_MODEL`, `MIXED`, or `UNKNOWN`.

Then load the router's complete matching environment guidance:

- For `STANDARD_NATIVE` or `MANAGED_STANDARD_MODEL`, read the router package's [native/standard-object lane](../salesforce-omnistudio-environment-router/references/native-standard-lane.md).
- For `MANAGED_LEGACY`, read the router package's [legacy/DataPack lane](../salesforce-omnistudio-environment-router/references/legacy-datapack-lane.md).
- For `MIXED`, read both and keep separate evidence, query, parser, and transport lanes per asset; do not block resolved lanes merely because the estate is mixed.
- For `UNKNOWN`, do not guess object names, namespace, JSON schema, or deployment transport. Continue only with discovery-safe actions and mark dependent conclusions `BLOCKED`.

## Mandatory provenance fingerprint

Record org alias and ID, org type, Salesforce release/API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, runtime classification, storage/data-model classification, affected object API names, affected asset keys and active versions, source representation and deployment transport per asset, source revision, user and permission context, incident window/timezone, correlation IDs, and reproduction channel. A mixed estate uses isolated resolved lanes; only unknown, mismatched, or access-limited dependent conclusions are `BLOCKED`.

## Load complementary skills deliberately

Inspect the host's available skill catalog before loading a complement. Loading means reading that available skill's complete `SKILL.md` before continuing. Load only those required by the observed execution path, and report unavailable complements rather than pretending they were used.

| Observed boundary | Complement to load when available |
|---|---|
| Standard metadata retrieval, source tracking, activation drift, package or deployment failure | `sf-architect-devops` |
| OmniScript/FlexCard rendering, generated LWC, page binding, browser, accessibility | `sf-architect-ui` |
| Integration Procedure HTTP actions, Named Credentials, authentication, downstream APIs | `sf-architect-integrations` |
| Data Mapper/DataRaptor transformation plus business-record loading or reconciliation | capability `Salesforce ETL`; optionally `sf-architect-etl` |
| Remote Action, Apex exception, governor or transaction behavior | `sf-architect-apex` |
| CRUD/FLS, sharing, guest access, injection, secret or data exposure | `sf-architect-security` or `salesforce-omnistudio-security-audit-lead-orchestrator` |
| Latency, payload size, cache, concurrency, limits | `sf-architect-performance` or `salesforce-omnistudio-performance-capacity-lead-orchestrator` |
| Migration | `salesforce-omnistudio-migration-lead-orchestrator` |
| Partial release or rollback | `salesforce-omnistudio-release-cutover-lead-orchestrator` |
| Retry, degraded operation, or recovery | `salesforce-omnistudio-reliability-recovery-lead-orchestrator` |

This skill owns the OmniStudio runtime/object/JSON interpretation. Complementary skills add their specialist discipline; they must not replace the detected environment model or broaden authorization.

For a standard-object runtime path, explicitly verify the tested identity's relevant FLS/object access for Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Sessions plus the OmniStudio permission-set license. Admin/designer success is not end-user proof.

## Safety

Default to read-only. Preview execution, debug mode, trace flags, broad queries, DataPack export, cache invalidation, activation, and replay can expose data or alter load; bound them by org, user, asset, time, rows, logging duration, and cost. Never copy session IDs, auth URLs, tokens, unredacted payloads, or customer data into artifacts.

## Search trajectories

- asset identity across the correct object family, version lineage, activation, generated components, and page binding;
- runtime/designer/package/namespace mismatch;
- OmniScript state, navigation, resume, validation, and data JSON;
- FlexCard conditions, data source, actions, cache, and rendering context;
- Data Mapper/DataRaptor filters, mappings, null handling, FLS, DML, and output paths;
- Integration Procedure sequence, conditional branches, response shaping, timeout, retry, cache, and partial failure;
- Apex/LWC extensions, permissions, Named Credentials, remote endpoints, and external dependencies;
- deployment omissions, stale active versions, or incompatible DataPack/metadata transport.

## Investigation package

```yaml
omnistudio_investigation:
  hypothesis: concrete causal theory
  competing_explanation: plausible alternative
  provenance: {org, runtime, storage_model, object_api_names, designer, package, namespace, asset_version, transport, revision}
  frame: {user, channel, time_window, correlation_ids}
  action: exact bounded query, preview, trace, or inspection
  support: observable result
  refute: observable result
  evidence: {artifact, captured_at, limits, redaction}
```

## Workflow

1. Classify the environment, load the matching runtime guide, and load only the complementary skills required by the observed path.
2. Reproduce the user's exact channel and active version when safely possible.
3. Trace the runtime data JSON from UI input through Integration Procedure and Data Mapper to side effects and response; for legacy assets, separately trace the configuration stored in namespaced records and serialized in the DataPack.
4. Compare affected and known-good users, assets, orgs, or versions without changing multiple variables at once.
5. Inspect live evidence with recorded caps; capped results cannot support universal absence claims.
6. Verify runtime, object storage, transport, and source independently, then connect the defect to the incident using time, version, user, or correlation evidence.
7. Keep remediation proposed—not executed—unless the user authorizes a fix.

## Outcome

Use `RESOLVED`, `INCONCLUSIVE`, or `BLOCKED`. `RESOLVED` requires a causal chain across the affected active asset and runtime. A designer screenshot, stale DataPack, source diff, or matching error text alone is insufficient.

## Final self-check

- Did the investigation inspect the active runtime version, not only source?
- Did it prove the object family and distinguish runtime data JSON from DataPack/configuration JSON?
- Was every query, log, and preview bounded and redacted?
- Were FLS, user context, cache, and external dependency alternatives tested?
- Are runtime and namespace provenance attached to every material conclusion?
