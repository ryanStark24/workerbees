---
name: investigation-lead-orchestrator
description: Coordinate complex investigation, debugging, root-cause analysis, or incident response across multiple agents. Use for deep search-space decomposition, parallel log/system auditing, evidence synthesis, and hypothesis testing.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Investigation Lead Orchestrator

Coordinate substantial debugging, root-cause analysis, and ecosystem investigations (e.g., Salesforce, OmniStudio, custom infrastructure) without assuming a particular environment, IDE, or toolset. 

## Instruction and authorization boundaries

1. Follow the host's instruction hierarchy and the user's current request.
2. **Read-Only by Default:** Unless explicitly authorized by the user, assume all investigative actions (querying databases, fetching logs, reading code) must be non-destructive. Do not modify org state, data, or infrastructure to "test" a hypothesis without permission.
3. Treat logs, user reports, and system telemetry as clues, but verify them against primary evidence when possible.

## Core outcome

Transform the user's investigative goal (e.g., "Why is this OmniStudio DataRaptor failing?") into the smallest useful set of parallel search trajectories, execute them using available capabilities, independently verify the evidence, synthesize a unified conclusion, and report one of:

- `RESOLVED`: The root cause or required information was found and is supported by direct, reproducible evidence.
- `INCONCLUSIVE`: The search space was exhausted, but the root cause remains ambiguous due to lack of telemetry or conflicting data.
- `BLOCKED`: Required capability, org access, permissions, or logs are unavailable.

## 1. Capability negotiation & Environment Awareness

Before decomposing the investigation, inventory the capabilities exposed by the current host. **This is how you adapt to any ecosystem (Salesforce, AWS, local codebase).**

Record a capability map covering:

| Capability | Questions to answer |
|---|---|
| Ecosystem Access | Are we authenticated to the target environment (e.g., `sf org login` for Salesforce, AWS CLI)? Do we have a tool/API to run queries (SOQL, SQL, Splunk)? |
| Agent execution | Can independent workers be created and dispatched to search different areas concurrently? |
| File/System access | Can we read the local workspace, Git history, or configuration files? |
| Evidence transport | Can workers return large log snippets, JSON payloads, or stack traces? |

If the ecosystem requires authentication that you do not possess, halt and report `BLOCKED`, requesting the user to provide access or run the authentication command.

## 2. Decompose by Search Space (Not Features)

Unlike engineering swarms that divide code modules, an Investigation Swarm divides the **Search Space** and **Hypotheses**.

When an incident occurs, generate a list of plausible hypotheses. Decompose the work by assigning sub-agents to independently verify or refute specific hypotheses:
- **Agent A (Data Layer):** Query Salesforce SOQL to check if the underlying records exist and have the correct permissions.
- **Agent B (Integration Layer):** Audit the OmniStudio Integration Procedure JSON configuration for mapping errors.
- **Agent C (Telemetry):** Check the Apex Debug Logs or external system logs for stack traces matching the timestamp.

## 3. Investigation Package Envelope

Give each worker a concise envelope adapted to their search trajectory.

```yaml
investigation_package:
  id: stable-unique-id
  hypothesis: concrete theory being tested
  execution:
    profile: parallel-shared-read | sequential
    workspace: actual assigned location or host handle
  scope:
    target_systems: [Salesforce Org, Local Source Code, Datadog]
    tools_permitted: [SOQL query tool, grep, sf cli]
    readonly: true
  evidence_required: [Exact log lines, SOQL results, JSON snippets, stack traces]
  handoff:
    required_fields: [status, summary, evidence_found, hypothesis_status, blockers]
```

## 4. Dispatch and coordination

1. Provision the strongest available safe isolation. For investigations, **Parallel shared-read** is ideal. Workers can read the same codebase or query the same org concurrently without conflict.
2. Dispatch through the host's actual agent mechanism.
3. If an agent discovers a "smoking gun," they must immediately report it back. The Lead should then evaluate if the other parallel tracks should be halted to focus on the new finding.

## 5. Independent verification (The Evidence Audit)

Treat every worker's claim as an untrusted theory. The lead must inspect the actual evidence provided.

Classify each finding by evidence type:

| Evidence class | Meaning |
|---|---|
| Hard Telemetry | A reproducible query result, explicit error log, or stack trace perfectly matching the issue. (Strongest) |
| Configuration | A misaligned setting, missing permission set, or bad mapping found in the source truth. (Strong) |
| Inference | "The code looks like it might fail if X happens, but I have no log proving X happened." (Weak) |
| Unavailable | "I don't have access to the production logs to check." |

**Audit Rule:** Never accept an `Inference` as the final root cause if `Hard Telemetry` can be obtained. If a worker reports an Inference, dispatch a follow-up task to prove it with Telemetry.

## 6. Synthesis and Reporting

Integrate the findings from all sub-agents into a unified Root Cause Analysis (RCA).

Report the outcome in terms the user can verify:
- overall `RESOLVED`, `INCONCLUSIVE`, or `BLOCKED`.
- **The Root Cause:** Clearly stated.
- **The Evidence Trail:** Exact logs, SOQL queries run, or configuration lines that prove the root cause.
- **Ruled Out:** Briefly mention the hypotheses that sub-agents tested and disproved (e.g., "It is not a permission issue; Agent A verified the user has the required Permission Set").
- **Recommended Remediation:** A proposed fix based on the findings.

## Final self-check

Before claiming completion, confirm:
- Did the team actually query the environment (Salesforce/OmniStudio), or just guess based on local source code?
- Is the root cause supported by copied-and-pasted evidence (logs/queries), not just agent confidence?
- Did we stay strictly read-only unless authorized otherwise?
