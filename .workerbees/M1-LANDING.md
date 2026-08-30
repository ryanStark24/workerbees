# M1 landing record

Evidence that the Milestone 1 change was landed through this project's merge
gate, and that the gate suite reproduces on machines that have never seen this
project. Recorded because both facts are process events: they happen once, in
the open, and cannot be re-derived by running a command later.

Written 2026-08-30.

## R-019 — landed through the merge gate

M1 and M2 arrived on `master` as **pull request #1**, merged as `80adbcb`, a
merge commit with two parents. Not a direct push, not a fast-forward.

| Gate | How it ran | Result |
|---|---|---|
| Pull request | [#1](https://github.com/ryanStark24/workerbees/pull/1), branch `claude/next-session-859f15` | merged `80adbcb` |
| Internal code review | `/code-review` at level `high` on `master..HEAD` | 3 findings |
| Codex review | **excluded** by owner instruction; R-019 amended 2026-08-30 to drop it | n/a |
| CI | run `33314992824` | green, both platforms |

The three review findings, and what happened to each:

1. `wb-init` truncated an existing `.codex/hooks.json` instead of merging — **fixed** in #2.
2. G25's `EXPECT` hardcoded a count read from live git history, so the gate
   invalidated itself on ordinary commits — **fixed** in #2.
3. `ID` and `REQ_LINE` disagreed on what a requirement id is — **accepted** at the
   time as low severity, **fixed** later in #7.

## R-020 — the suite reproduces off this machine

CI executes every suite in `tests/` on `ubuntu-latest` and `macos-latest`, at
`fetch-depth: 0` because two gates compute status from commit history.

Run `33314992824`, on the M1 merge commit `80adbcb`:

| Job | Conclusion | Completed |
|---|---|---|
| `validate (ubuntu-latest)` | success | 2026-08-30T13:45:33Z |
| `validate (macos-latest)` | success | 2026-08-30T13:46:59Z |

Reproduced on every subsequent merge to `master`: `c6c842a`, `dcbd4c7`,
`a2a4619`, `90cb3b5`, `f185171`.

## What went wrong, recorded because it did

The merge of #3 (`85d49cd`) turned `master` red — run `33323384972`, failure.
Its merge summary named two requirements in prose; merge commits carry no
trailer because the hook exempts them, so the auditor read the mention as
delivery. The pull request itself was green; the merge commit it created was
not, and the pull request's checks were verified while `master`'s were not.
Fixed in #4 (`dcbd4c7`).

Recorded because a landing record that shows only the green runs is the kind of
asserted status this repository exists to prevent.

## What this does not prove

- The gates check that the merge is a real merge commit reachable from `HEAD`,
  and that CI is configured to run the whole suite on both platforms with full
  history. **They do not re-execute CI**, and cannot: a past execution is not a
  reproducible local command. The run ids above are the execution evidence.
- Codex review never ran, by instruction. One half of the original merge gate
  was removed rather than satisfied.
- Green gates prove each requirement was addressed and gated. They never prove
  the behaviour is right. Every bug fixed in #2 through #7 existed while the
  suite was green.
