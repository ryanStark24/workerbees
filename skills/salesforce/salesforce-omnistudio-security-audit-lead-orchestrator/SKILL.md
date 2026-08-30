---
name: salesforce-omnistudio-security-audit-lead-orchestrator
description: Coordinate authorized defensive security reviews of Salesforce OmniStudio and legacy Vlocity solutions. Use only for OmniStudio-specific security across OmniScripts, FlexCards, Data Mappers or DataRaptors, Integration Procedures, and their extensions; do not use for generic Salesforce or general application security.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Salesforce OmniStudio Security Audit Lead Orchestrator

## Required composition

First locate and read the complete `salesforce-omnistudio-environment-router` package and its routed references. Then locate and read the complete shipped `security-audit-lead-orchestrator` core skill. If either is unavailable, report it and continue sequentially: classify assets; establish authorization; inventory trust boundaries; test server-side controls with safe evidence; deduplicate causes; verify remediation; audit. Optional `sf-architect-*` complements may add a required security, Apex, integration, UI, DevOps, ETL, or performance capability only after exact path and version/source provenance are verified and complete instructions are read; they are never hard dependencies.

Audit the effective security path from rendered experience through every server-side action and data source. Client configuration, hidden fields, and UI conditions are not authorization controls.

## Mandatory provenance fingerprint

Record org alias and ID, org type, Salesforce release and API version, OmniStudio license, Managed Package Runtime and Designer settings, OmniStudio Metadata final state, Omni Interaction Configuration representation, installed package versions and namespaces, storage/object/source/transport classification per asset, source revision, asset versions and active state, user personas, permission sets, external credentials, and target environment. Mixed estates keep separate control-evidence lanes; unknown or mismatched assets block only dependent coverage claims.

Never infer a namespace from the word Vlocity. Data Mapper and legacy DataRaptor terminology do not establish storage or runtime provenance.

## Authorization boundary

Record permitted orgs, identities, dates, techniques, data classes, rate limits, and prohibited actions. Do not modify production data, deploy or activate assets, toggle runtime settings, install packages, probe third parties, exfiltrate records, or execute destructive or denial-of-service tests without explicit authorization for that action.

## Attack surfaces

Trace least-privilege access through OmniScript and FlexCard inputs, URL and session context, Data Mapper extracts and loads, Integration Procedure remote actions, Apex/LWC extensions, sharing, CRUD/FLS, guest and community users, Named and External Credentials, caches, logs, error payloads, and downstream APIs.

For every candidate finding, preserve the exact entry point, transformations, server-side enforcement, sink, identity, asset version, environment, and evidence artifact. A designer preview, scanner alert, or missing client-side condition alone is not proof of exploitability.

## Workflow

1. Establish written authorization and the runtime fingerprint.
2. Inventory active assets, entry points, identities, data classes, and trust boundaries.
3. Review non-overlapping surfaces using read-only source and configuration evidence first.
4. Validate CRUD, FLS, sharing, input validation, output minimization, credentials, and cache isolation. On standard-runtime paths verify the documented baseline grants for each tested persona: Omni Process Compilation **Read and Edit**, Omni Data Transformation **Read**, and OmniScript Saved Sessions **Read and Edit**, plus the OmniStudio permission-set license. Re-check release-specific object/field permissions and apply least privilege rather than granting the baseline blindly to every persona.
5. Use harmless test payloads only in an authorized isolated environment.
6. Deduplicate by root cause and rate demonstrated impact, prerequisites, and compensating controls.
7. Verify remediation through the same identity and execution path.

## Findings and verdict

Classify findings as `CONFIRMED`, `PLAUSIBLE`, `NOT_REPRODUCED`, or `BLOCKED`. Overall gates use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. Redact secrets and customer data; do not require an unsafe exploit when an exact control failure is already proven.


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

- Was runtime, namespace, identity, active version, and environment provenance captured?
- Were server-side controls evaluated rather than UI visibility alone?
- Did every test remain inside authorization?
- Are managed-package and Standard/Core remediation paths kept distinct?
