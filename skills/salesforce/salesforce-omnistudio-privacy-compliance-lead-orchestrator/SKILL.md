---
name: salesforce-omnistudio-privacy-compliance-lead-orchestrator
description: Assess privacy and compliance controls in Salesforce OmniStudio and legacy Vlocity solutions with evidence and data-flow provenance. Use only when OmniScripts, FlexCards, Data Mappers or DataRaptors, Integration Procedures, and their extensions form the regulated-data path; do not use for generic Salesforce governance or legal certification.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Privacy Compliance Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `privacy-compliance-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially: classify; define the engineering-control boundary; trace fields and identities; test minimized evidence; separate proven gaps from legal judgment; retest. Optional `sf-architect-*` complements may add a required privacy, security, integration, Apex, UI, ETL, DevOps, or performance capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

Trace regulated data through capture, transformation, display, cache, logs, storage, integration, retention, deletion, and subject-rights workflows. This skill produces engineering evidence, not legal certification.

## Mandatory provenance fingerprint

Record org alias and ID, org type and region, Salesforce release and API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, storage/object/source/transport classification per asset, source revision, active asset versions, data classifications, identities, external processors, retention configuration, CLI/plugin versions, and environment. Mixed estates maintain separate field/source/evidence lanes connected by explicit data-flow edges; unknown or mismatch blocks only affected inventory and control claims.

Do not infer legal scope or namespace from “Vlocity,” “industry,” “Data Mapper,” or legacy “DataRaptor” labels.

## Authorization and handling

Use synthetic or minimized data by default. Require explicit authorization before accessing personal data, exporting payloads, invoking subject-rights flows, modifying retention, deploying or activating assets, toggling runtime settings, installing packages, or mutating production records. Any authorized mutation needs a rollback or compensating recovery plan and evidence cleanup procedure. Encrypt and access-control retained evidence; redact secrets and unnecessary identifiers.

## Control map

Trace fields through OmniScript inputs and saved state, FlexCard display and actions, Data Mapper extracts/transforms/loads, Integration Procedure request and response shaping, Apex/LWC extensions, object storage, files, platform and application logs, caches, analytics, Named Credentials, external APIs, and downstream processors.

For each element record purpose, classification, source, recipients, identity, lawful-policy owner, minimization, retention, deletion/correction/export behavior, security controls, runtime, namespace, active version, and evidence.

## Workflow

1. Confirm the policy/control framework, accountable owner, systems, identities, and environments.
2. Capture provenance and inventory entry points, fields, transformations, storage, logs, caches, and transfers.
3. Compare actual data flow with declared purpose, minimization, access, retention, and processor boundaries.
4. Verify CRUD/FLS/sharing, field masking, response minimization, logging, consent or preference propagation, and downstream contracts. For standard-runtime identities explicitly check Omni Process Compilation, Omni Data Transformation, and OmniScript Saved Session access plus the OmniStudio permission-set license.
5. Test correction, deletion, export, restriction, and retention workflows only with authorized synthetic or controlled records.
6. Separate proven gaps, plausible exposure, unavailable evidence, and legal interpretations requiring counsel.
7. Retest remediation through the same identity and end-to-end path.

## Verdict

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` against named engineering controls. Do not claim statutory compliance merely because technical checks pass.


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

- Is runtime, namespace, active-version, identity, and environment provenance complete?
- Can every regulated field be traced through all four OmniStudio component families where used?
- Were evidence collection and tests minimized and authorized?
- Are legal conclusions clearly reserved for accountable experts?
