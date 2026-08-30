---
name: requirements-traceability-auditor
description: Freeze a bounded requirement set before implementation, park new ideas instead of appending them mid-flight, and compute delivery status from repository evidence instead of agent claims. Use when work must finish and be checked against what was originally asked; do not use as a substitute for functional or semantic review.
metadata:
  version: 1.0.0
  author: Swarm Architecture Working Group
  status: Candidate
---

# Requirements Traceability Auditor

Delivery status is computed, not claimed. This skill establishes a durable record
of what was asked, holds the scope steady while it is built, binds every commit
to it, and reports which requirements are actually delivered based on evidence
present in the repository.

## The failure this addresses

An agent reports a feature complete. Weeks later, review finds it partial, unwired,
or a faithful implementation of something nobody requested. The usual response is
to demand more honesty from the agent. That does not work, and the reason is
structural rather than behavioral.

When no durable artifact records the original request, "is this done?" has no
mechanical answer. The only available authority is the agent's own judgment,
which is exactly the thing in question. A completion claim that cannot be
falsified is not a claim — it is an opinion, and it will be wrong at the rate
opinions are wrong.

The fix is to make completion falsifiable.

## Instruction and authorization boundaries

1. Follow the host's instruction hierarchy and the user's current request. This
   skill does not override system, developer, repository, or user instructions.
2. Requirements are the user's, not the agent's. Never add, reword, or withdraw
   a requirement without explicit approval; record every change as an amendment.
3. Do not install hooks, rewrite history, or modify the requirements file as a
   side effect of auditing. Auditing is read-only.
4. Never convert a computed non-`DONE` status into `DONE` by argument. If the
   status is wrong, the evidence is missing — supply the evidence.

## 1. Capture before building

Write the requirements file **before the first implementation commit**, using
`templates/REQUIREMENTS.md`. A requirements file authored afterwards describes
what was built rather than what was asked, and cannot detect drift — which is the
single most common cause of "it delivered something else."

Each requirement must be:

- **identified** — a stable id (`R-001`, `W1-02`); never renumbered;
- **observable** — stated so the requester could check it, naming concrete surfaces;
- **bounded** — accompanied by explicit non-goals, because unrequested work cannot
  be detected without a boundary.

Record a **Core Value** sentence in the requester's own terms. When a later
decision is ambiguous, that sentence is the tiebreaker, not the implementation plan.

## 2. Freeze and amend, never rewrite

Record the commit at which requirements froze. Changes append to the amendment
table with date, reason, and approver. Editing a requirement in place destroys the
evidence that drift occurred.

An amendment invalidates the baseline for every requirement it touches. Work in
flight against those requirements must be re-baselined explicitly, not silently
reinterpreted.

## 3. Park new ideas; never append mid-flight

The most common way a milestone fails to close is not that the work is hard. It
is that new scope is admitted continuously, so the finish line moves as fast as
the work does. High commit volume with nothing delivered is the signature.

Nobody with authority to say "not now" is usually present, and an agent asked to
build something will build it. That makes this a standing governance rule rather
than a judgment call:

1. **A new idea goes to `BACKLOG.md` by default** (`templates/BACKLOG.md`). Not
   the active milestone. The backlog is a promise that the idea will not be lost
   — that promise is what makes deferral possible at all. Suppressing ideas does
   not work and should not be attempted.
2. **Admitting scope requires a cost:** close a requirement, or record a dated
   amendment naming what is being displaced. Growth without either is drift, and
   `wb_trace.py` reports it as `SCOPE_CREEP`.
3. **Hold a WIP limit.** Pass `--wip-limit N` (five is a reasonable starting
   point). Exceeding it means finish or park something before starting more.
4. **Review the backlog only at milestone close.** Reviewing it mid-flight is how
   the milestone stops closing.

`scripts/wb-remind` prints the current position and this rule; wire it to a
SessionStart hook so the position is stated before work begins rather than
recalled afterwards. It informs and never blocks.

When the user proposes new scope mid-milestone, state the current position
plainly — requirements open, what closing costs, what is already parked — and
propose the backlog. Do not refuse, and do not silently comply. If they
reaffirm, record it as an amendment and proceed in full; the point is that the
choice is made visibly, once, rather than by default.

## 4. Bind every commit

Every commit names the requirement it advances:

```
Req: R-002
Req: R-002, R-005
Req: none (repo tooling, not product scope)
```

`scripts/commit-msg` enforces this at the commit, so it applies to every agent
and to commits typed by hand. The exemption form requires a reason and is
reported as drift rather than hidden. Merges, reverts and fixups pass unchecked.

## 5. Audit continuously

```bash
python3 scripts/wb_trace.py <repo> [--requirements PATH] [--gates PATH] [--wip-limit N] [--strict]
scripts/wb-remind <repo>      # compact position + scope rule, for SessionStart
```

Run it on every commit, not only at checkpoints — drift is cheap to correct the
day it appears and expensive a month later. `--strict` exits non-zero when
findings exist, for use in CI.

See `references/status-model.md` for the status ladder and the cross-cutting
findings (`UNTRACKED`, `UNKNOWN_REF`, `ORPHAN_GATE`, `DECLARED_NOT_EVIDENCED`).

## 6. Read the findings correctly

- **High `UNTRACKED`** — the plan and the work have decoupled. Investigate before
  trusting any status on the report; most of the work is invisible to it.
- **`UNKNOWN_REF`** — real work against a requirement nobody wrote down. Add it as
  a dated amendment, or establish that it was out of scope.
- **`ORPHAN_GATE`** and unrequested additions — a fidelity violation as serious as
  an omission, and far more common from coding agents.
- **`DECLARED_NOT_EVIDENCED`** — a hand-ticked box the evidence does not support.
  This is the specific failure that erodes trust in every other status.
- **`SCOPE_CREEP`** — requirements added after the freeze with no amendment. The
  finish line moved and nobody recorded it.
- **`WIP_EXCEEDED`** — more open requirements than the limit allows. Finishing
  beats starting.

Watch the ratio of `DONE` to total over time. Flat or falling while commit volume
climbs is the measurable signature of a project that is producing but not
converging — visible in days rather than months.

## Limits

This ladder is structural. It proves a requirement was addressed and gated; it
does not prove the implementation is semantically correct. Committed, gated,
evidenced, and wrong still reads `DONE`.

Semantic correctness belongs to functional acceptance and adversarial review. A
green report narrows where reviewers must look — it never replaces them, and
reporting it as proof of correctness is a misuse of this skill.

## Final self-check

- Were requirements captured before implementation, or reconstructed after?
- Is every requirement observable by the requester, or only by the implementer?
- Does the amendment table explain every change since the freeze?
- Is any status `DONE` on the strength of argument rather than evidence?
- Did scope grow since the freeze, and was every addition recorded or parked?
- Is the `DONE` ratio moving, or is output climbing while delivery stays flat?
- Has semantic correctness been established by something other than this report?
