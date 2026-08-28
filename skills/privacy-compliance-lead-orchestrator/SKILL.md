---
name: privacy-compliance-lead-orchestrator
description: Coordinate privacy engineering and compliance-evidence work across data inventories, purpose, access, retention, deletion, residency, and controls. Use when a system needs implementable privacy controls or audit-ready evidence; do not use to provide legal certification or as a substitute for counsel.
metadata:
  version: 1.1.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Privacy and Compliance Lead Orchestrator

Translate applicable obligations and organizational policy into traceable technical controls and current evidence. Do not declare legal compliance from a checklist.

## Compose with the execution substrate

This lead owns privacy scope, requirement-to-control mapping, data-lifecycle decomposition, operating-effectiveness tests, and technical evidence. Qualified policy or legal owners retain interpretation and certification authority. When `swarm-lead-orchestrator` is available, load it for capability negotiation, least-privileged work packages, dispatch, collision control, worker audits, and integration.

If the swarm skill or workers are unavailable, trace lifecycle surfaces sequentially: authoritative requirements, data inventory, control mapping, minimized tests, downstream propagation, then evidence reconciliation. Preserve separation of duties in the record even when one agent performs the technical steps; unavailable legal or control-owner review remains `BLOCKED` or `UNVERIFIED` as appropriate.

## Boundaries

- Identify the authoritative policy, jurisdiction, contract, or control framework and its owner. Flag legal interpretations for qualified counsel.
- Data discovery does not authorize unrestricted export. Deletion, anonymization, retention changes, consent changes, or cross-border transfer requires explicit authorization.
- Minimize personal data in prompts, logs, fixtures, reports, and evidence artifacts.

## Outcomes

- `PASS`: each in-scope requirement maps to an implemented control and current evidence.
- `FAIL`: a required control is absent, ineffective, or contradicted by evidence.
- `BLOCKED`: policy ownership, data access, system evidence, or authorization is unavailable.
- `UNVERIFIED`: control documentation exists but operating effectiveness was not observed.

## Establish scope

Record entities, jurisdictions, products, environments, data subjects, data categories, purposes, legal or policy bases, processors, transfers, retention schedules, and assessment period. Separate statutory requirements, contractual commitments, internal policy, and recommended hardening.

## Decompose by data lifecycle

- collection and notice;
- purpose, consent, and preference;
- classification and minimization;
- identity, access, sharing, and export;
- storage, encryption, residency, and transfer;
- retention, archival, deletion, anonymization, and backup propagation;
- data-subject access, correction, portability, objection, and erasure;
- monitoring, incident response, processor management, and evidence retention.

Use work units for authoritative-requirement extraction, data inventory and lineage, each lifecycle control family, operating-effectiveness sampling, downstream deletion/correction propagation, processor evidence, and gap remediation. Add edges from authoritative scope and inventory to control tests; from identity and retention decisions to access/deletion tests; from control implementation evidence to operating tests; and from all lifecycle results to the control matrix and conclusion. Treat production datasets, exports, subject identifiers, legal holds, retention jobs, processor portals, evidence repositories, test personas, and deletion queues as collision-prone resources. Minimize and serialize access to sensitive shared artifacts.

## Control package

```yaml
privacy_control:
  requirement: exact authoritative statement or identifier
  owner: policy and technical owners
  data: {category, subjects, purpose, systems, transfers}
  control: preventive | detective | corrective
  implementation: exact component and configuration
  evidence: {artifact, period, source, completeness}
  test: operating-effectiveness action and acceptance
  gaps: []
  remediation: {action, owner, due, authorization}
```

## Workflow

1. Build a provenance-backed data inventory and flow map.
2. Map each requirement to control owner, implementation, and evidence before testing.
3. Verify configuration and source, then test operating effectiveness with minimized or synthetic data where possible.
4. Trace deletion and correction across primary stores, caches, search indexes, analytics, backups, integrations, and derived data.
5. Confirm access and export boundaries using least-privileged personas.
6. Record exceptions, compensating controls, evidence periods, and remediation ownership.
7. Perform destructive privacy actions only with case-specific authorization, identity verification, retention checks, and audit receipts.

## Evidence rules

Policy prose is not implementation evidence; configuration is not operating evidence; one successful request does not prove continuous control. Record sampling, time period, scope, caps, stale evidence, and inaccessible systems. Never fabricate a certification or counsel conclusion.

Audit each unit for authoritative requirement and owner, exact data scope, least-privileged access, evidence period and completeness, implementation provenance, operating-test result, downstream coverage, redaction, and retention of the evidence itself. The integrated gate must expose gaps and conflicting obligations rather than averaging them into a compliance score.

## Completion report

Report scope, authoritative sources, data flows, control matrix, evidence, operating tests, gaps, risk owners, remediation, destructive actions performed, and remaining legal or external review.

## Final self-check

- Can each requirement be traced to implementation and evidence?
- Were data minimization and artifact handling applied to the assessment itself?
- Did deletion and correction reach derived and downstream stores?
- Are legal conclusions clearly separated from technical findings?
