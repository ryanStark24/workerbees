---
name: salesforce-omnistudio-migration-lead-orchestrator
description: Coordinate Salesforce OmniStudio and legacy Vlocity migrations across managed-package and Standard/Core runtimes, designers, DataPacks, metadata, component versions, and channels. Use only when OmniStudio runtime modernization or asset migration is central; route provisioning-system, business-logic, or data-source migrations elsewhere, and do not use for generic Salesforce migration.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Migration Lead Orchestrator

## Scope route before OmniStudio tooling

First identify what is actually migrating. If the change replaces a provisioning system, business-logic implementation, service, integration data source, or record source without converting OmniStudio assets, runtime, designer, object model, or deployment representation, stop this specialized workflow. Prefer an applicable project-native migration skill; otherwise use `migration-lead-orchestrator`, delegating bounded record movement to `data-etl-lead-orchestrator` when appropriate. Do not introduce OMA, DataPack conversion, or managed-to-standard runtime parity gates merely because the surrounding repository or target platform is Salesforce.

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and both routed references for any cross-model migration. Then locate and read the complete shipped `migration-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially with this self-contained fallback: fingerprint and classify; baseline behavior; assess readiness; resolve blockers; migrate a representative slice; verify behavioral equivalence; rehearse cutover/rollback; then audit. Optional `sf-architect-*` complements may supplement a required DevOps, UI, Apex, integration, ETL, security, or performance capability only after exact path and version/source provenance are verified and their complete instructions are read; they are never hard dependencies.

Migrate assets without assuming that reactivation, renaming, or a successful import establishes behavioral equivalence between managed-package Vlocity and Standard/Core OmniStudio.

## Mandatory provenance fingerprint

For every source and target org record org ID/type, release/API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, storage/object family and source representation per asset, asset keys/versions/active states, generated LWCs and page bindings, CLI/OmniStudio Migration Assistant (OMA)/build-tool versions, deployment path, and source revision. Mixed estates use independent resolved lanes and cross-lane gates; only unknown, mismatched, or access-limited assets are `BLOCKED`.

## Authorization

Migration planning and sandbox rehearsal do not authorize package installation, runtime/designer toggles, production import/deploy, activation, page replacement, data mutation, or legacy deletion. Each requires an exact target and explicit approval.

## Behavior inventory

Characterize OmniScript navigation, validation, resume and state; FlexCard rendering, conditions and actions; Data Mapper/DataRaptor queries, transforms and loads; Integration Procedure sequence, response, cache and failures; Apex/LWC extensions; permission and FLS behavior; channel compatibility including Lightning, Experience/LWR and OmniOut; external contracts; and operational deployment/rollback behavior.

## Dependency waves

Map reusable Data Mappers, Integration Procedures, remote actions, matrices/procedures, custom metadata, Named Credentials, Apex/LWC extensions, child OmniScripts/FlexCards, parent assets, generated components, pages, permissions, and user assignments. Use adapters or coexistence where a big-bang conversion is unsafe.

## Supported OMA path

For managed-package-runtime to standard-runtime migration, use the current supported OMA workflow unless current official Salesforce documentation or the target transition path says it is inapplicable:

1. Pin and record the supported OMA plugin version and verify documented prerequisites for the installed package/release, sandbox type, OmniStudio license, standard-data-model readiness, OmniStudio Metadata support, permissions, and source control.
2. In a development sandbox, capture the pre-migration automation and business-journey baseline. Run OMA **Assess** first, preserve the full report, and use `--only` or related-object scope only when that scope is explicit.
3. Treat every Assess finding as a gate. Repeat Assess after remediation until the in-scope report is clean; a filtered clean report is not an all-assets pass.
4. Separate automated conversion from unsupported/manual work. Current Salesforce guidance calls out Angular OmniScripts, calculation procedures/matrices, custom LWCs, some related-object deployment, duplicate Data Mapper names, reserved Integration Procedure keywords, industry-object data-model changes, OmniAnalytics, and other report-specific interventions. Do not claim OMA converted an item its report or current documentation leaves manual.
5. Run OMA **Migrate** only with explicit mutation authorization in the development sandbox. Preserve command, flags, version, report, converted asset map, namespace-reference changes, and post-migration manual steps. The OmniStudio Metadata setting changes what OMA migrates, so record its final state before interpreting output.
6. Deploy the migrated candidate to a separate clean validation sandbox using its post-migration per-asset transport. Do not validate only in the development sandbox that performed conversion.
7. Run the same baseline suite and compare canonical inputs/outputs, navigation/state/resume, side effects, errors/timeouts, identity/FLS/sharing, active versions/page bindings, accessibility, channels, performance, and operational recovery. HTML/tag differences make selector-only parity insufficient.

Before standard-runtime acceptance, explicitly verify relevant FLS/object access for Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Sessions plus the OmniStudio permission-set license for representative users.

## Migration package

```yaml
omnistudio_migration:
  asset: {type, key, source_version, target_version}
  provenance: {source_org, target_org, source_runtime, target_runtime, namespaces}
  transport: DataPack build tool | Salesforce metadata CLI
  behavior: {preserve: [], approved_change: [], retire: [], unknown: []}
  dependencies: []
  verification: [isolated contract, active-version journey, permissions, performance]
  rollback: {asset_version, page_binding, runtime_setting, data_effects}
```

## Workflow

1. Export/retrieve immutable source and target baselines using router-selected lanes.
2. Build the cross-runtime asset and dependency mapping; do not convert by filename alone.
3. Execute the applicable OMA Assess/Migrate path and manual interventions above in development, or document authoritative evidence that OMA is not applicable.
4. Migrate a representative vertical slice and prove behavioral equivalence in a separate validation sandbox.
5. Rehearse activation and page-binding cutover plus rollback in a sandbox matching production packages and settings.
6. Resolve unsupported features and generated LWC/channel differences explicitly.
7. Execute production only after separate authorization and evidence-backed go/no-go.
8. Retain legacy versions through the observation window; delete only with separate destructive approval.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. Deployment, activation, page rendering, end-to-end behavior, security equivalence, and rollback are separate gates.


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

- Was every asset mapped across runtime, namespace, version, and transport?
- Were intentional behavior changes approved rather than hidden as compatibility fixes?
- Were active pages and user journeys tested after activation?
- Are rollback and legacy removal separately authorized?

## Official source and freshness

OMA guidance checked 2026-08-28: Salesforce Developers, [Automate Your Move to the OmniStudio Standard Runtime with the New Migration Assistant](https://developer.salesforce.com/blogs/2025/12/automate-your-move-to-the-omnistudio-standard-runtime-with-the-new-migration-assistant) and [Migrate From Managed Package Runtime to the OmniStudio Standard Runtime](https://developer.salesforce.com/blogs/2026/08/migrate-from-managed-package-runtime-to-the-omnistudio-standard-runtime). Re-verify the current plugin version, prerequisites, supported/manual cases, commands, and target transition path before execution.
