# WorkerBees Swarm Skills

WorkerBees is a portable collection of evidence-gated orchestration skills for complex engineering and investigation work. The skills adapt to the tools a host actually exposes; they do not assume that agents, worktrees, browsers, credentials, or live systems are available.

## Included skills

WorkerBees contains **23 skill packages** in the native directory format: 11 vendor-neutral lifecycle skills, 11 dedicated Salesforce OmniStudio/Vlocity counterparts, and one shared OmniStudio environment router.

### General lifecycle skills

| Skill | Specialty |
|---|---|
| `swarm-lead-orchestrator` | Feature and system delivery |
| `investigation-lead-orchestrator` | Debugging, root-cause analysis, and incident response |
| `architecture-decision-lead-orchestrator` | Evidence-backed architecture decisions |
| `migration-lead-orchestrator` | Dependency-ordered modernization and behavioral equivalence |
| `security-audit-lead-orchestrator` | Authorized defensive security assessment |
| `data-etl-lead-orchestrator` | Restartable data movement and reconciliation |
| `system-reconstruction-lead-orchestrator` | Legacy-system archaeology and verified documentation |
| `release-cutover-lead-orchestrator` | Deployment, cutover, rollback, and stabilization |
| `performance-capacity-lead-orchestrator` | Performance diagnosis and capacity validation |
| `reliability-recovery-lead-orchestrator` | Failure handling, recovery, and resilience |
| `privacy-compliance-lead-orchestrator` | Privacy data-flow and engineering-control assessment |

### Salesforce OmniStudio lifecycle skills

Each core specialty has a strict OmniStudio counterpart:

```text
salesforce-omnistudio-build-lead-orchestrator
salesforce-omnistudio-investigation-lead-orchestrator
salesforce-omnistudio-architecture-decision-lead-orchestrator
salesforce-omnistudio-migration-lead-orchestrator
salesforce-omnistudio-security-audit-lead-orchestrator
salesforce-omnistudio-data-etl-lead-orchestrator
salesforce-omnistudio-system-reconstruction-lead-orchestrator
salesforce-omnistudio-release-cutover-lead-orchestrator
salesforce-omnistudio-performance-capacity-lead-orchestrator
salesforce-omnistudio-reliability-recovery-lead-orchestrator
salesforce-omnistudio-privacy-compliance-lead-orchestrator
```

These packages specialize only in OmniScripts, FlexCards, Data Mappers (legacy DataRaptors), Integration Procedures, their extensions, and their lifecycle. They are deliberately excluded from generic Salesforce work so that skill routing stays precise.

The additional `salesforce-omnistudio-environment-router` classifies every asset independently as `STANDARD_NATIVE`, `MANAGED_LEGACY`, `MANAGED_STANDARD_MODEL`, `MIXED`, or `UNKNOWN`. It records runtime, designer, storage/data model, object family, OmniStudio Metadata state, Omni Interaction Configuration, source representation, and transport separately. Transport is never selected from runtime alone.

All 11 lifecycle variants load that router and their shipped core counterpart. They retain a sequential fallback and treat external `sf-architect-*` packages as optional capability supplements whose path and version/source provenance must be verified. The router keeps runtime Data JSON separate from legacy persisted configuration JSON and exported DataPack JSON.

The migration variant uses the current OmniStudio Migration Assistant Assess/Migrate workflow, separates automated and manual conversion, and requires behavioral-equivalence evidence in a clean validation sandbox. ETL owns business-record movement only; configuration, DataPack, metadata, designer, and runtime conversion belong to migration.

The repository groups source packages by domain:

```text
skills/
├── general/<skill-name>/SKILL.md
└── salesforce/<skill-name>/SKILL.md
```

The categories are repository organization only. The installer places each package directly at the host's native `<skills-root>/<skill-name>/SKILL.md` location so automatic discovery remains compatible.

## Installation

The installer works from any current directory and verifies complete package trees before reporting success. It rejects package-destination symlinks, preflights every requested target before writing, and preserves differing destinations unless `--force` is supplied. Forced updates stage and verify a clean package, preserve the old directory for rollback during replacement, and remove stale package files.

Install interactively:

```bash
./install.sh
```

Install one or more targets:

```bash
./install.sh --target codex
./install.sh --target claude --target antigravity
./install.sh --target cursor --project-dir /path/to/project
```

Choose which skill family to install:

```bash
./install.sh --target codex --group general
./install.sh --target codex --group salesforce
./install.sh --target codex --group general --group salesforce
```

Choose project scope, global scope, or both:

```bash
./install.sh --all --group salesforce --scope project --project-dir /path/to/project
./install.sh --all --group general --scope global
./install.sh --target cursor --group all --scope project --scope global --project-dir /path/to/project
```

`--group all` is the default. If `--scope` is omitted, the backward-compatible defaults apply: Cursor installs into the project and Antigravity, Codex, and Claude Code install globally.

Install all targets:

```bash
./install.sh --all --project-dir /path/to/cursor-project
```

Preview without writing:

```bash
./install.sh --all --project-dir /path/to/project --dry-run
```

Update an existing WorkerBees installation only after reviewing local differences:

```bash
./install.sh --target codex --force
```

### Target layouts

| Target | Project scope | Global scope |
|---|---|---|
| Cursor | `<project>/.cursor/skills/<skill-name>/SKILL.md` | `~/.cursor/skills/<skill-name>/SKILL.md` |
| Antigravity | `<project>/.agents/skills/<skill-name>/SKILL.md` | `~/.gemini/config/skills/<skill-name>/SKILL.md` |
| Codex | `<project>/.agents/skills/<skill-name>/SKILL.md` | `~/.agents/skills/<skill-name>/SKILL.md` |
| Claude Code | `<project>/.claude/skills/<skill-name>/SKILL.md` | `~/.claude/skills/<skill-name>/SKILL.md` |

All four targets receive the same canonical directory-based skill packages. Cursor can also use a global directory by setting `CURSOR_SKILLS_DIR=~/.cursor/skills`.

See [COMPATIBILITY.md](COMPATIBILITY.md) for the distinction between filesystem installation evidence and end-to-end host discovery. The Antigravity target covers the Antigravity IDE global directory; it does not claim every Antigravity CLI layout.

## Installer options

```text
--all
--target cursor|antigravity|codex|claude
--group general|salesforce|all
--scope project|global
--project-dir PATH
--force
--dry-run
--help
```

`--target`, `--group`, and `--scope` may be repeated. Target-specific `<TARGET>_PROJECT_SKILLS_DIR` and `<TARGET>_GLOBAL_SKILLS_DIR` variables override scoped destinations. The legacy `CURSOR_SKILLS_DIR`, `ANTIGRAVITY_SKILLS_DIR`, `CODEX_HOME`, and `CLAUDE_HOME` overrides remain supported.

## Validation

Run the repository checks:

```bash
bash -n install.sh tests/*.sh
./tests/validate_skills.sh
./tests/validate_skills.sh --safety-only
./tests/test_installer.sh
./tests/test_routing_scenarios.sh
./tests/test_gate_evidence.sh
```

The checks validate all 23 native packages and their safety invariants. The routing suite exercises standard-native, managed-legacy, managed-standard-model, explicitly resolved mixed lanes, blocked mixed metadata, contradictory observations, unknown and malformed facts, metadata mismatch, and authorized/unauthorized mutation scenarios. The installer test exercises general-only, Salesforce-only, project, global, and combined-scope installation across all four targets. It also compares complete package trees including executable modes and verifies symlink and conflict refusal, stale-file cleanup, transactional conflict preflight, forced updates, and dry-run behavior.

## Release status

Every package remains `Candidate`. Filesystem packaging and repository behavior can pass while host discovery or live Salesforce behavior remains `UNVERIFIED`; see the compatibility matrix. WorkerBees is distributed under the [MIT License](LICENSE).

## Safety model

- Skills never create capabilities the host does not expose.
- External, destructive, costly, credentialed, and production mutations require authorization.
- Worker claims are untrusted until independently verified.
- Live or external acceptance criteria remain `BLOCKED` or `UNVERIFIED` when direct evidence is unavailable.
- Investigation artifacts minimize and redact secrets, personal data, and unnecessary customer payloads.
