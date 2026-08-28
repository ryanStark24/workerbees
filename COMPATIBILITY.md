# Compatibility and evidence matrix

WorkerBees uses directory-based Agent Skill packages. Filesystem installation and runtime discovery are different evidence surfaces: a successful copy does not prove that a particular host version discovered or invoked a skill.

| Host | Project layout | Global layout | Current evidence | Runtime discovery |
|---|---|---|---|---|
| Cursor | `<project>/.cursor/skills/<skill>/SKILL.md` | `~/.cursor/skills/<skill>/SKILL.md` | Automated group, scope, clean, update, conflict, and dry-run tests | `UNVERIFIED` without a supported Cursor executable in CI |
| Google Antigravity IDE | `<project>/.agents/skills/<skill>/SKILL.md` | `~/.gemini/config/skills/<skill>/SKILL.md` | Automated group, scope, clean, update, conflict, and dry-run tests | `UNVERIFIED` without an Antigravity IDE discovery harness |
| Codex | `<project>/.agents/skills/<skill>/SKILL.md` | `~/.agents/skills/<skill>/SKILL.md` | Automated group, scope, clean, update, conflict, and dry-run tests | `UNVERIFIED` without a supported Codex discovery command in CI |
| Claude Code | `<project>/.claude/skills/<skill>/SKILL.md` | `~/.claude/skills/<skill>/SKILL.md` | Automated group, scope, clean, update, conflict, and dry-run tests | `UNVERIFIED` without a supported Claude Code discovery command in CI |

These paths were checked against current official host documentation on 2026-08-28: [Cursor Agent Skills](https://cursor.com/docs/skills), [Google Antigravity Skills](https://antigravity.google/docs/skills), [OpenAI Codex Skills](https://developers.openai.com/codex/skills/), and [Claude Code Skills](https://code.claude.com/docs/en/skills). Antigravity CLI plugin layouts are versioned separately by Google and are not claimed as supported by this target.

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
