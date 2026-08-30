# Changelog

## Unreleased

### Added

- `discipline` skill group with `requirements-traceability-auditor`: freeze
  requirements before implementation, bind commits to them with a `Req:`
  trailer, and compute delivery status from repository evidence.
- `scripts/wb_trace.py` reports `NOT_STARTED`/`PARTIAL`/`UNVERIFIED`/`DONE` per
  requirement, plus `UNTRACKED`, `UNKNOWN_REF`, `ORPHAN_GATE`, and
  `DECLARED_NOT_EVIDENCED` findings. `--strict` exits non-zero for CI.
- `scripts/commit-msg` git hook enforcing a requirement reference on every
  commit, constraining every agent and hand-typed commits alike.
- Scope governance: `SCOPE_CREEP` (requirements added after the recorded freeze
  with no amendment) and `WIP_EXCEEDED` (`--wip-limit N`) findings.
- `templates/BACKLOG.md` parking lot, so new ideas are deferred rather than
  appended to an open milestone, and `scripts/wb-remind` for a SessionStart hook
  that states the current position and the scope rule without blocking.
- `scripts/wb-init` wires a project for all four hosts plus the host-independent
  git hook, and `templates/AGENTS.md.snippet` states the rules to any agent
  reading `AGENTS.md`/`CLAUDE.md`. Idempotent and non-destructive.
- Repository `BACKLOG.md` recording every deferred design decision with rationale.
- `tests/test_traceability.sh` and gates G16-G22.

### Fixed

- `tests/test_routing_scenarios.sh` failed deterministically (20/20) with exit 141.
  `printf ... | grep -q` under `set -o pipefail` reports failure via SIGPIPE when
  grep exits early on a match -- the assertion failed *because* it matched. The
  classifier was always correct. Rewritten to here-strings.
- G13 depended on an absolute path outside the repository and an uninstalled
  `pyyaml`, so it could only ever pass on one machine and never in CI. Rewritten
  to use in-repo tooling only.
- G13/G14 required `ripgrep`, absent from the gate runner and from CI images.
  Replaced with POSIX `grep`.

### Changed

- Installer accepts `--group discipline`; `--group all` now covers three groups.
- Package count 23 -> 24 across validation, installer tests, gates, and README.

### Known issues

- `tests/test_routing_scenarios.sh` fails at HEAD (`mixed classification
  mismatch`), which also fails gate G5. Pre-existing; unrelated to this change.


## Unreleased

- Organized source packages into `skills/general/` and `skills/salesforce/` while preserving flat host-native installation layouts.
- Added independently selectable `general` and `salesforce` installer groups plus explicit project and global scopes.
- Added project-native policy precedence for migration routing, release safety, and investigations; complement selection is now capability-first.

- Package lifecycle and Salesforce OmniStudio orchestration skills in native directory form.
- Install packages for Cursor, Google Antigravity IDE, Codex, and Claude Code.
- Add environment-aware OmniStudio routing for standard-native, managed-legacy, managed-standard-model, mixed, and unknown estates.
- Add installer conflict, symlink, stale-file, dry-run, and transactional-preflight verification.

The repository owner selected the MIT License, and all local release gates pass. Packages remain candidates until the intended Git snapshot and live host discovery are verified.
