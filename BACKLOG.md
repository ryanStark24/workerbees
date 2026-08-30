# Backlog: WorkerBees

Ideas live here until a milestone closes. **This file is not a queue of work — it
is a promise that the idea will not be lost.** That promise is what makes
deferring one possible; ideas that get lost are ideas you will refuse to defer.

Reviewed at milestone close only. Reviewing it mid-flight is how the milestone
stops closing.

## Parked

Everything below was designed in detail during the 2026-08-30 planning session,
then deliberately deferred. Rationale is recorded so a future decision does not
have to re-derive it. Full design detail is in the plan file referenced at the
bottom.

| Date | Idea | Why it is interesting | Why it is not now |
|---|---|---|---|
| 2026-08-30 | `work-ledger-protocol` — atomic work-slice claiming via `git update-ref` compare-and-swap on `refs/wb/leases/*`, dependency waiting on `refs/wb/done/*`, vendor roles, no-self-audit invariant | No prior art does cross-vendor claim leasing; the ref store is a genuine race-free lock shared by all worktrees | Three concurrent cross-vendor agents are a goal, not current practice. Build when the collision is observed, not anticipated |
| 2026-08-30 | `timebox-escalation-protocol` — time-boxed leases, breach detection, escalation record, `SCOUT` dispatch to a different vendor with no inherited context, reframe verdicts | A blown time-box is usually a wrong framing, not insufficient effort; denying the scout the failed frame is the whole point | Depends on the ledger. Also needs historical data to set budgets, which does not exist yet |
| 2026-08-30 | `interface-contract-protocol` — contract as a prerequisite work unit, `contract_sha` pinning, consumer-driven contract tests, mocks generated from the contract | Lets provider and consumer both progress from the moment the contract freezes | Already hand-rolled per slice as "Frozen integration contract" in `OpenFloor/PLAN.md`. Systematize only if that stops working |
| 2026-08-30 | `convergence-checkpoint-protocol` — barrier ref halting new claims, eight-audit set, architecture-doc update, checkpoint merge | The correction cycle for accumulated drift; also a natural context-reset boundary | Meaningful only with multiple concurrent workers to halt |
| 2026-08-30 | `branch-lifecycle-protocol` — design → implement → integrate → release → patch, phase exit gates, forward-port debt blocking releases | Forward-port debt is how hotfixes silently get lost | Branch discipline is already strong: 133/129 branches, nothing committed to `main`. Low marginal value |
| 2026-08-30 | `context-integrity-monitor` — semantic rot tripwires (contradicting a recorded decision, re-reading files, losing requirement ids) rather than percentage-of-window thresholds | Fires earlier and more accurately than a context-percentage warning | Pain #2 is `UNVERIFIED` — session-death causes were never established. Diagnose before building |
| 2026-08-30 | `currency-verification-protocol` — volatility-classified fact checking; dated primary-source citations required for high-volatility claims (APIs, SDK versions, pricing, deprecations) | Blanket "always search" is expensive and gets skipped; classification makes it cheap enough to follow | Pain #9 is `UNVERIFIED`; not measurable from the artifacts examined |
| 2026-08-30 | `execution-tier-router` — frontier tier plans, mid tier implements, small tier extracts; escalate a tier after repeated failure, de-escalate after plan freeze | Cost control plus a real quality lever | GSD already ships model profiles. Real but minor per the diagnosis |
| 2026-08-30 | `capability-surface-minimizer` — session-start tool/MCP inventory, minimum viable set, explicit disable list | Fewer tools means better tool-selection accuracy and a smaller injection surface | Real but minor. Note: Notion is unauthenticated and asana/github/pagerduty fail to connect — pure surface, zero capability |
| 2026-08-30 | `functional-acceptance-lead-orchestrator` — cold start, first screen, primary journey, empty/error/loading states, `BLOCKED` + human checklist when unreachable | Already solved once in Salesforce Query Chains (123 evidence dirs with stable test ids) but never carried to other repos — a portability problem, which is what a skills pack is for | Strongest remaining candidate. Deferred only to keep this milestone small; promote next |
| 2026-08-30 | `pre-commit` hook rejecting `REQUIREMENTS.md` additions with no matching amendment row | Would make scope freeze a hard block rather than a reminder | Offered and not requested. A tool that fights its owner gets uninstalled; escalate only if `SCOPE_CREEP` keeps appearing |
| 2026-08-30 | Migrate existing GSD `.planning/` content into the WorkerBees ledger | Would consolidate the two systems | Schema should prove itself on one real project first |
| 2026-08-30 | Notion sync for the requirements ledger | Matches the stated single-source-of-truth rule | The Notion MCP is unauthenticated; a Notion-primary ledger breaks silently |

## Promoted

| Date | Idea | Milestone it entered |
|---|---|---|
| 2026-08-30 | `requirements-traceability-auditor` — freeze, bind commits, compute status | Shipped: `skills/discipline/` |
| 2026-08-30 | Scope governance — backlog, `SCOPE_CREEP`, WIP limit, `wb-remind` | Shipped: same package |
| 2026-08-30 | Cross-host wiring — `wb-init` for Claude, Codex, Cursor, Antigravity | Shipped: same package |

## Declined

| Date | Idea | Reason |
|---|---|---|
| 2026-08-30 | Gate-evidence stop-hook blocking completion claims without pasted evidence | Falsified by measurement: `OpenFloor/GATES.md` has 59 EVIDENCE lines and **0 empty**. The failure it prevents is not occurring |
| 2026-08-30 | Four separate per-host enforcement adapters for commit rules | Superseded: one `commit-msg` git hook covers every host and hand-typed commits alike |
| 2026-08-30 | Rebuilding worktree/fleet management | Commodity — `git worktree`, `worktrunk`, Conductor, Vibe Kanban already do it |
| 2026-08-30 | Rebuilding spec-driven planning from scratch | Spec Kit and OpenSpec already define the conventions; adopt rather than reinvent |

---

Design detail for parked items: `~/.claude/plans/hey-rhea-i-have-greedy-dragon.md`.
Evidence behind the defer decisions: `.workerbees/diagnosis.md`.
