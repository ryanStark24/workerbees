---
name: salesforce-omnistudio-environment-router
description: Classify a Salesforce OmniStudio estate per asset by runtime, designer, storage model, object family, Metadata setting, source representation, and deployment transport. Use only as the required routing foundation for OmniStudio or legacy Vlocity work; do not use for generic Salesforce work.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Environment Router

Establish what an asset actually is before choosing object queries, JSON parsing, deployment tooling, or a complementary skill. Runtime, designer, storage/data model, object family, source representation, and transport are independent observations. Never infer one from the word Vlocity, a namespace, a UI label, or another dimension alone.

## Required read-only fingerprint

Capture the evidence source and timestamp for every field:

- org ID/alias/type, Salesforce release and API version, and OmniStudio entitlement;
- Managed Package Runtime and Managed Package Designer settings;
- installed OmniStudio/Industries package versions and namespaces;
- standard versus legacy storage/data model;
- object API names for each affected asset;
- OmniStudio Metadata setting and its enablement result, not only the initial toggle state;
- Omni Interaction Configuration representation where relevant (`OmniInteractionConfig` versus a namespaced legacy equivalent or neither);
- asset stable key, version, active state, and source revision;
- authoritative source representation: Salesforce metadata, DataPack JSON, both in separate lanes, or unknown;
- proposed transport and target environment.

The runtime data JSON passed among an OmniScript, FlexCard, Data Mapper, and Integration Procedure is not configuration storage and is not a DataPack.

## Classify per asset

Assign one classification only after the affected assets are inventoried:

- `STANDARD_NATIVE`: standard runtime and standard Omni object family.
- `MANAGED_LEGACY`: managed-package runtime and namespaced legacy custom-object family/configuration JSON.
- `MANAGED_STANDARD_MODEL`: managed-package runtime using the standard Omni object family.
- `MIXED`: multiple resolved, explicitly inventoried lanes. Mixed is not automatically blocked: represent each asset group as a homogeneous lane and validate each lane independently.
- `MISMATCH`: runtime, object, storage, interaction, or source observations contradict one another and have not been resolved into per-asset lanes. Block transport and mutation claims.
- `UNKNOWN`: evidence is missing, access-limited, capped, or cannot distinguish the lanes. Block compatibility and mutation claims; continue only with bounded discovery.

Read [references/native-standard-lane.md](references/native-standard-lane.md) for `STANDARD_NATIVE` and `MANAGED_STANDARD_MODEL`. Read [references/legacy-datapack-lane.md](references/legacy-datapack-lane.md) for `MANAGED_LEGACY`. Read both for `MIXED`; never merge their manifests, parsers, checksums, or verdicts.

## Select transport from facts, not runtime alone

- Standard Omni objects plus successfully enabled OmniStudio Metadata and an authoritative metadata representation: use supported Salesforce metadata tooling for that asset.
- Namespaced legacy custom objects plus an authoritative DataPack representation: use the OmniStudio Build Tool DataPack lane for that asset.
- Standard objects with OmniStudio Metadata disabled/failed, legacy objects represented only as Salesforce metadata, or disagreement between org and source: record `TRANSPORT_BLOCKED_MISMATCH` and investigate. Do not convert or deploy by assumption.
- A mixed release has explicit per-lane records and independent metadata and DataPack manifests, dependency graphs, validations, checkpoints, rollback actions, and verdicts. Treat top-level runtime as a derived aggregate (`standard`, `managed`, or `mixed`) and require it to agree with the lane runtimes. Every metadata lane requires both its own evidence and the org-wide final `metadata_enabled: true` state; aggregate source inventory must agree with all lanes. A valid DataPack lane never authorizes a blocked metadata lane. Cross-lane dependencies are explicit gates.

For repeatable classification of already-observed facts, run `python3 scripts/classify_environment.py --facts <file.json>`. The script never connects to an org and refuses an unauthorized mutation request. Its output is decision support; retained evidence remains authoritative.

## Standard-runtime access gate

Before claiming a standard-runtime journey works for the tested identity, verify the documented baseline grants: Omni Process Compilation **Read and Edit**, Omni Data Transformation **Read**, and OmniScript Saved Sessions **Read and Edit**, plus the required OmniStudio permission-set license. Verify the current release's exact object/field permissions and reduce them by persona where least privilege permits. Also check the configuration BPO permissions required for non-admin component authors when OmniStudio Metadata is enabled. Admin preview is not end-user proof.

## Optional complements

Load an `sf-architect-*` skill only when the current host exposes it and its declared capability is required by the traced boundary. Record the exact skill name/path, version or source revision, and when it was read. Treat it as optional: if absent, continue sequentially using the lifecycle skill's own Salesforce boundary checks. Never instruct installation, claim it was loaded, or make it a hard dependency without user authorization.

## Authorization and verdict

Classification is read-only. Org queries, exports, previews, trace collection, migration, deployment, activation, runtime/designer or Metadata setting changes, package operations, and business-data mutation each require their own authorization where they can expose data or change state. Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`, and attach provenance to every decisive claim.

## Freshness boundary

The supporting references were checked against official Salesforce sources on 2026-08-28. Salesforce release behavior, object support, settings, permissions, OMA, and deployment tools can change. Verify current official documentation and the target org before a release, migration, or compatibility claim.
