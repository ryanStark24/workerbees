# Status model

`wb-trace` computes one status per requirement from repository evidence. No
status is ever asserted by an agent, and none is inferred from confidence.

| Status | Meaning | Evidence required |
|---|---|---|
| `NOT_STARTED` | No commit references the requirement | — |
| `PARTIAL` | Commits exist, but no gate claims it | ≥1 commit with a `Req:` trailer |
| `UNVERIFIED` | A gate claims it, but carries no evidence | commit + gate, `EVIDENCE:` empty or gate unchecked |
| `DONE` | Delivery is evidenced end to end | commit + checked gate + non-empty `EVIDENCE:` |

## Cross-cutting findings

| Finding | Meaning |
|---|---|
| `UNTRACKED` | Commits carrying no requirement reference — drift, and the volume matters more than any single instance |
| `UNKNOWN_REF` | A commit cites an id absent from the requirements file — work against a requirement that was never recorded |
| `ORPHAN_GATE` | A gate claims no requirement — candidate unrequested work |
| `DECLARED_NOT_EVIDENCED` | A requirement ticked `[x]` by hand whose evidence does not support it |

## What this does not catch

The status ladder is structural. It proves a requirement was *addressed* and
*verified by a gate*, not that the implementation is semantically correct. A
function that is committed, gated, evidenced, and simply wrong about the domain
will read `DONE`.

Semantic correctness is what functional acceptance and adversarial review are
for. Do not let a green `wb-trace` run substitute for either. The auditor
narrows where humans and reviewers must look; it does not replace them.
