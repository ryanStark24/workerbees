# Diagnosis: is the failure missing tooling or unused tooling?

Date: 2026-08-30 · Method: read-only inspection of local session history, `.planning` artifacts, and `git log` across active repos. Every finding below cites the command or path it came from.

## Verdict

**Neither.** Both hypotheses are falsified by the evidence.

The methodology is **present, self-invented, high quality, and applied consistently across every active project.** It has exactly **one structural break**: nothing binds plan items to the code that implements them.

The self-assessment that opened this work — *"I have been planning, reviewing and developing my projects aimlessly"* — is not supported by the evidence. The practice is better than most professional teams'. What is missing is one link in a chain that is otherwise complete.

## What already exists (falsifies "missing tooling")

Measured across `live-bridge`, `OpenFloor`, and `Salesforce Query Chains`:

| Artifact | Evidence |
|---|---|
| Plan of record | `PLAN.md` in every active repo — OpenFloor 661 lines with identified slices `P1-S1`…`P1-S5`; live-bridge 82 lines |
| Evidence gates | `GATES.md` in every active repo. OpenFloor: **10/10 gates checked, 51 CHECK lines, 59 EVIDENCE lines, 0 empty EVIDENCE**. live-bridge: 39 CHECK / 55 EVIDENCE. OpenFloor also has per-area `GATES-INTEGRATION.md`, `GATES-ROOM-CONTROL.md` |
| Architecture doc | `live-bridge/ARCHITECTURE.md`, 898 lines |
| Interface contracts | OpenFloor `PLAN.md` has a **"Frozen integration contract"** section per slice |
| Collision control | OpenFloor and live-bridge `PLAN.md` both have a **"File ownership"** section per slice |
| Functional QA | SQC `.planning/codex-qa-evidence/` — **123 evidence directories** with stable test IDs (`A11Y-FOCUS-01`, `CM-DRY-AGG-01`) |
| Bug tracking | SQC `.planning/codex-qa-bugs/` — **42 structured reports** (`BUG-001`…) |
| Cross-vendor audit | `CODEX_QA_PROMPT.md`, `CODEX_QA_TEST_PLAN.md` (2730 lines), `claude-design-handoff/` (7 docs incl. component inventory, user stories, screenshots-needed) |
| Design system | SQC `.planning/design-system-v1/` with mockups, previews, UI kits |
| Commit convention | **91–100% conventional commits**: live-bridge 182/200, OpenFloor 200/200, SQC 173/200, salesforceMCP 196/200 |
| Branch isolation | Never working on `main`. live-bridge 133 branches, OpenFloor 129, all active work on `codex/*` branches |

Nearly every concept proposed in the deferred 13-skill design already exists here in hand-rolled form.

## The single break (the actual root cause)

**Identifiers exist at every level except the one that connects them to code.**

- Plan slices are identified: `P1-S1`…`P1-S5` (`OpenFloor/PLAN.md`)
- Gates are identified: `G1`…`G10` (`OpenFloor/GATES.md`)
- Test evidence is identified: `A11Y-FOCUS-01` etc. (SQC)
- **Commits reference none of them.**

```
git log --format='%s%n%b' -200 | grep -cE '\bP[0-9]+(\.[0-9]+)?-S[0-9]+\b'   -> 0   (OpenFloor)
git log --format='%s%n%b' -200 | grep -cE '\bG[0-9]+\b'                       -> 0   (OpenFloor)
git log --format='%b'    -200 | grep -cE '^(Plan|Gate|Refs|Closes):'          -> 0   (OpenFloor)
```
Identical result in `live-bridge`. **0 of 400 commits** carry a plan or gate reference in subject, body, or trailer.

This one gap explains four of the nine reported pains as symptoms rather than independent problems:

- **#1 "no tracker of what's done"** — completion cannot be computed. The plan says what was intended; the log says what happened; nothing joins them.
- **#5 "design not mirrored 1:1"** — divergence cannot be detected. Neither omission nor unrequested addition is visible without the join.
- **#4 "no checkpoint accountability"** — a checkpoint cannot verify "did we build what we agreed" when agreed-work and built-work share no key.
- **#8 "losing track of things"** — the ledger the practice needs is derivable from this join and from nothing else.

## Secondary findings

- **Session volume ramped 33×**: 18 sessions (Jun) → 29 (Jul) → **963 (Aug)**, 1010 total (`find ~/.claude/projects -name '*.jsonl'`). At ~31/day, work is being chopped into many short sessions. Consistent with pain #2, though this measures volume, not cause.
- **GSD is effectively unused**: 1 `PLAN.md` and 1 `VERIFICATION.md` across all projects, in `salesforceMCP` only, last touched June. The two most active repos use the hand-rolled `PLAN.md`/`GATES.md` pattern instead. **The hand-rolled system won on merit.** Do not replace it — systematize it.
- **Merge gate partially followed**: branch discipline is strong, but merges are mostly local rather than through PRs — live-bridge 1 PR-style of 44 merges, OpenFloor 1 of 7, SQC 13 of 22, salesforceMCP 3 of 5.
- **Tool surface**: 9 plugins enabled; several MCP servers are pure surface with zero capability (Notion unauthenticated; asana/github/pagerduty fail to connect).

## Smallest intervention that would change the outcome

Not 13 skills. Not a ledger, adapters, or coordination protocol. **One convention plus one auditor:**

1. **Bind commits to plan slices.** A trailer — `Plan: P1-S3` / `Gate: G4` — on every commit. Optionally enforced by a `commit-msg` hook, which is where mechanical enforcement is actually cheap.
2. **A coverage auditor** that computes, from `PLAN.md` + `GATES.md` + `git log`: which plan slices have no commits (not started), which have commits but no passing gate (unverified), which gates have no plan slice (unrequested work — the `EXTRA` case), and which commits reference nothing (untracked drift).

That is the whole fix for pains #1, #4, #5 and #8. It composes with the existing practice instead of replacing it.

## Which pains survive as real, independent gaps

| Pain | Status |
|---|---|
| #1 tracker, #4 checkpoints, #5 1:1 mirroring, #8 ledger | **Symptoms of the single break.** Fixed by the intervention above |
| #6 functional verification | **Already solved** in SQC (123 evidence dirs); **not carried** to live-bridge/OpenFloor. Portability problem, not a capability gap |
| #3 model tiers, #7 tool surface | **Real but minor.** Low cost, low payoff relative to the above |
| #2 context rot | **UNVERIFIED.** Session volume is suggestive; the cause was not established |
| #9 currency checking | **UNVERIFIED.** Not measurable from these artifacts |

## Limits of this diagnosis

- Session-death patterns (Q3) were **not** established; the transcript sampling was inconclusive. Pain #2 remains unverified.
- Design-to-code divergence (Q4) was **not** measured directly — design artifacts were found and inventoried, but no requirement-by-requirement comparison was run. That comparison is impossible until the intervention above exists, which is itself corroborating evidence.
- Per-session tool-usage counts (Q5) were not extracted; only the enabled-plugin count.
- Concurrency (Q6) rests on the user's own statement plus the presence of `codex/*` branches; genuine simultaneity was not measured.

---

# Addendum — the requirements anchor (supersedes part of the verdict above)

Added after investigating "they never delivered what I asked at the start." This **corrects** the earlier statement *"GSD lost on merit — do not adopt it."* That was wrong on one axis, and the axis matters most.

## Finding 1: the plan is written after the code

| Repo | First commit | `PLAN.md` created | Commits landed **before** a plan existed |
|---|---|---|---|
| live-bridge | 2026-08-24 | 2026-08-28 | **254 of 375 (68%)** |
| OpenFloor | 2026-08-25 | 2026-08-27 | **116 of 453 (26%)** |

`OpenFloor/PLAN.md` was then revised **40 times in 2 days** (+591 lines net). Neither PLAN.md contains a single intent-anchor phrase (`original ask`, `acceptance criteria`, `as requested`) — count is 0 in both.

**A document written after the work, and rewritten 40 times, cannot answer "are we building what was asked."** There is no stable thing to check against. The original request survives only in ephemeral session transcripts (1010 `.jsonl` files) — never promoted to a durable, identified artifact. Drift happens at the very first translation, before any code is written, and is therefore invisible for the rest of the project.

## Finding 2: the one project that did it right is the GSD one

`salesforceMCP/.planning/REQUIREMENTS.md` (GSD-generated, dated 2026-05-17) is the strongest artifact in the estate:

- **25 identified requirements** — `W1-01`, `W1-02`, `W2-01`… — each a testable, observable statement naming concrete files
- a **"Core Value"** anchor sentence stating what the milestone is *for*
- per-requirement checkboxes for status
- **49 commits in that repo reference `W-` ids** (`git log --format='%s%n%b' -300 | grep -cE '\bW[0-9][a-z]?-[0-9]+\b'`)

**The plan→commit join I reported as universally missing is not missing there.** It works, in the one project that used GSD's requirements discipline.

Its only failure: **0 requirements checked `[x]`, 17 still `[ ]`.** The evidence to compute completion exists in the commit log; nobody computed it. That is precisely the auditor's job, and it proves the auditor's input format already exists and works in practice.

## Corrected verdict

| Axis | live-bridge / OpenFloor (hand-rolled) | salesforceMCP (GSD) |
|---|---|---|
| Requirements captured first, with IDs | absent | **present, excellent** |
| Commits reference requirement IDs | 0 of 400 | **49** |
| Evidence-backed gates | **present, excellent** (0 empty EVIDENCE) | thin |
| Functional QA evidence | absent (present in SQC) | absent |
| Status computed from evidence | absent | absent |

Neither system is complete. The correct target is the **union**: GSD's requirements anchor + the hand-rolled gates/evidence discipline + an auditor that computes status instead of relying on hand-ticked boxes.

## What this changes about the build

The auditor is unchanged in shape but gains a level. The chain it must verify, continuously:

```
REQUIREMENTS.md (frozen, IDed, written FIRST)
      -> plan slices        (P1-S3)
      -> commits            (trailer: Req: W1-02)
      -> gates              (GATES.md, pasted EVIDENCE)
      -> functional evidence(test IDs, as in SQC)
```

A requirement is `DONE` only when every link is present. Anything else is `PARTIAL` / `UNVERIFIED`, computed, with no model opinion involved.

**One new rule earns its place:** requirements must be frozen *before* the first implementation commit, and amended only by dated amendment — never rewritten. `OpenFloor/PLAN.md`'s 40 revisions in 2 days is the failure mode this prevents.

---

# Correction 2 — process quality is not delivery

The user reports that **none of these projects is successfully implemented.** That
invalidates the most confident claim in this document — *"the practice is better
than most professional teams'"* — because that claim measured **artifact quality**
and silently treated it as evidence of **delivery**. It is not.

Re-read against outcome, the same numbers say something different:

| Repo | Commits | Window | Branches | Delivered |
|---|---|---|---|---|
| OpenFloor | 453 | ~5 days | 129 | no |
| live-bridge | 375 | ~6 days | 133 | no |
| salesforceMCP | 341 | — | 7 | no (abandoned June) |
| Salesforce Query Chains | 886 | — | 12 | no (abandoned ~May) |

Plus 963 Claude sessions in August alone (18 in June, 29 in July).

**The pattern is very high output, very high process ceremony, and no
convergence.** Gates being 10/10 evidenced does not mean a project shipped; it
means the gates that were written were passed. If the gate set does not span the
requirement set, passing every gate proves nothing about delivery — and with no
requirements file in either active repo, it cannot span anything.

`wb_trace.py` reproduces the user's own verdict on first run against real data:

```
salesforceMCP: 17 requirements — PARTIAL=17, DONE=0
               18 of 341 commits (5%) carry a requirement reference
```

Seventeen requirements, none delivered, in the best-tracked project in the estate.
The tool agrees with the user, mechanically, and disagrees with this document's
original optimistic reading.

## What this changes

Nothing about the build — the auditor is what makes non-convergence visible on
day two instead of month three. But it changes what the auditor is *for*.

It was framed as a completeness checker. Its real value is as a **convergence
signal**: the ratio of `DONE` to total requirements over time. Flat or falling
while commit volume climbs is the measurable signature of the failure actually
being experienced, and it is invisible without a frozen requirement set.

**The auditor makes non-convergence visible. It does not cause convergence.**
That requires a bounded requirement set, frozen, and finished before new scope is
admitted — a discipline decision no tool can make. The `EXTRA`/`UNKNOWN_REF`
findings are the enforcement surface for it, not a substitute.

## A small instance of the same disease, in this repo — since fixed

`tests/test_routing_scenarios.sh` failed at pristine `HEAD` while `GATES.md`
recorded gate G5 as `[x]` with `EVIDENCE: PASS: 14 OmniStudio routing and
authorization scenarios validated`. The recorded evidence no longer reproduced:
a stale green, in the repository that ships the discipline.

**Root cause (2026-08-30):** not the classifier. `printf ... | grep -q` under
`set -o pipefail` — `grep -q` exits on first match, `printf` takes SIGPIPE, and
the pipeline returns 141, so the assertion failed *because* it matched.
Reproduced 20/20. Rewritten to here-strings; now passes 10/10 and reproduces the
recorded evidence exactly.

Two further non-reproducible gates surfaced and were fixed at the same time:

- **G13** invoked an absolute path outside the repository
  (`~/.codex/skills/.system/skill-creator/scripts/quick_validate.py`) requiring
  an uninstalled `pyyaml`. It could only ever pass on one machine, and never in
  CI. Rewritten to use in-repo tooling only.
- **G13/G14** required `ripgrep`, absent from the gate runner and from CI images.
  Replaced with POSIX `grep`.

The lesson generalizes past these three: **a gate that cannot run on a clean
machine is not a gate.** Every gate now runs from repository tooling alone, and
the whole suite is green — 24 packages, 22 gates, 6 test files.
