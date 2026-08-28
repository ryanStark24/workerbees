# Compatibility and evidence matrix

WorkerBees uses directory-based Agent Skill packages. Filesystem installation and runtime discovery are different evidence surfaces: a successful copy does not prove that a particular host version discovered or invoked a skill.

| Host | Supported installation layout | Current evidence | Runtime discovery |
|---|---|---|---|
| Cursor | `<project>/.cursor/skills/<skill>/SKILL.md` or `CURSOR_SKILLS_DIR` | Automated clean, update, conflict, and dry-run tests | `UNVERIFIED` without a supported Cursor executable in CI |
| Google Antigravity IDE | `~/.gemini/config/skills/<skill>/SKILL.md` or `ANTIGRAVITY_SKILLS_DIR` | Automated clean, update, conflict, and dry-run tests | `UNVERIFIED` without an Antigravity IDE discovery harness |
| Codex | `${CODEX_HOME:-~/.codex}/skills/<skill>/SKILL.md` | Automated clean, update, conflict, and dry-run tests | `UNVERIFIED` without a supported Codex discovery command in CI |
| Claude Code | `${CLAUDE_HOME:-~/.claude}/skills/<skill>/SKILL.md` | Automated clean, update, conflict, and dry-run tests | `UNVERIFIED` without a supported Claude Code discovery command in CI |

The Antigravity target above covers the Antigravity IDE global skill directory. Antigravity CLI plugin and global-skill layouts are versioned separately by Google and are not claimed as supported by this target.

## Shell matrix

The installer requires Bash and does not claim POSIX `sh` compatibility.

| Environment | Gate |
|---|---|
| macOS | Repository tests run on the local macOS development environment and in CI |
| Ubuntu Linux | Repository tests run in CI |
| Windows | Use a Bash environment; native PowerShell installation is not currently supported |

## Evidence policy

- `PASS` means the named automated filesystem behavior was exercised.
- `UNVERIFIED` means the layout follows current vendor documentation but end-to-end host discovery was not exercised.
- Host-version-specific behavior must be rechecked before a compatibility claim is promoted.
