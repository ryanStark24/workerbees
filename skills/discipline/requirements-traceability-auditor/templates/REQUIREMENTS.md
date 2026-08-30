# Requirements: <initiative name>

**Defined:** <YYYY-MM-DD>
**Frozen at:** <commit sha, filled when the first implementation commit lands>
**Core Value:** <one sentence saying what this milestone is FOR — the thing that
would make the requester consider it delivered. Written in their terms, not the
implementation's.>

## Rules for this file

1. **Written before the first implementation commit.** A requirements file
   authored after the code describes what was built, not what was asked, and
   cannot detect drift.
2. **Never rewritten.** Changes are appended as dated amendments (see below).
   Editing a requirement in place destroys the record that drift occurred.
3. **Each requirement is observable.** State what will be true, in terms the
   requester could check. "Refactor the parser" is not a requirement; "the
   parser handles conditional directives without dropping bound expressions" is.
4. **IDs are permanent.** Never renumber. A withdrawn requirement is struck
   through with an amendment reference, not deleted.

## Requirements

Use stable IDs. Any of `W1-01` (wave), `R-001`, `REQ-12`, `FR-3` is recognized
by `wb-trace`; be consistent within a file.

- [ ] **R-001**: <observable statement — what is true when this is delivered,
      naming the concrete surfaces it touches>
- [ ] **R-002**: <observable statement>
- [ ] **R-003**: <observable statement>

## Explicit non-goals

State what this milestone deliberately does *not* do. Unrequested work is a
fidelity violation, and it cannot be detected without a boundary.

- <non-goal>

## Amendments

Append only. Each entry records what changed, why, and who approved it. An
amendment invalidates the frozen baseline for every requirement it touches;
work in flight against those requirements must be re-baselined.

| Date | Requirement | Change | Reason | Approved by |
|---|---|---|---|---|
| | | | | |
