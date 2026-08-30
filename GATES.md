# Gates: WorkerBees lifecycle and Salesforce OmniStudio skill families

Scope: Ship eleven vendor-neutral lifecycle skills, eleven Salesforce OmniStudio/Vlocity lifecycle variants, and one shared OmniStudio environment router as portable candidate packages.

- [x] G1: The vendor-neutral lifecycle family contains eleven skill packages.
  Req: R-009
  CHECK: test "$(find skills/general -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')" = "11" && echo CORE_COUNT_PASS
  EXPECT: CORE_COUNT_PASS
  EVIDENCE: CORE_COUNT_PASS

- [x] G2: The Salesforce family contains eleven lifecycle variants plus one environment router.
  Req: R-010
  CHECK: test "$(find skills/salesforce -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')" = "12" && test -f skills/salesforce/salesforce-omnistudio-environment-router/SKILL.md && echo OMNISTUDIO_COUNT_PASS
  EXPECT: OMNISTUDIO_COUNT_PASS
  EVIDENCE: OMNISTUDIO_COUNT_PASS

- [x] G3: Every skill package passes repository structural and composition validation.
  Req: R-005, R-014
  CHECK: ./tests/validate_skills.sh
  EXPECT: PASS: 24 skill packages validated
  EVIDENCE: PASS: 24 skill packages validated

- [x] G4: Installer group, scope, full-tree, symlink, stale-file, transactional-preflight, conflict, force, and dry-run tests pass for all four targets.
  Req: R-013
  CHECK: ./tests/test_installer.sh | tail -n 1
  EXPECT: PASS: installer groups, scopes, targets, full-tree verification, safe replacement, transactional preflight, and dry-run behavior
  EVIDENCE: PASS: installer groups, scopes, targets, full-tree verification, safe replacement, transactional preflight, and dry-run behavior

- [x] G5: OmniStudio environment classification and mutation authorization scenarios pass.
  Req: R-005, R-014
  CHECK: ./tests/test_routing_scenarios.sh
  EXPECT: PASS: 14 OmniStudio routing and authorization scenarios validated
  EVIDENCE: PASS: 14 OmniStudio routing and authorization scenarios validated

- [x] G6: Every OmniStudio lifecycle variant composes with the shipped router and its core lead.
  Req: R-010
  CHECK: for file in skills/salesforce/salesforce-omnistudio-*-lead-orchestrator/SKILL.md; do grep -q salesforce-omnistudio-environment-router "$file" && grep -Eqi 'complete shipped .* core skill|complete shipped `swarm-lead-orchestrator` core skill' "$file" || exit 1; done; echo OMNISTUDIO_COMPOSITION_PASS
  EXPECT: OMNISTUDIO_COMPOSITION_PASS
  EVIDENCE: OMNISTUDIO_COMPOSITION_PASS

- [x] G7: Every newer core lifecycle lead composes with the swarm execution substrate and preserves a sequential fallback.
  Req: R-009
  CHECK: for name in architecture-decision data-etl migration performance-capacity privacy-compliance release-cutover reliability-recovery security-audit system-reconstruction; do file="skills/general/$name-lead-orchestrator/SKILL.md"; grep -q swarm-lead-orchestrator "$file" && grep -qi sequential "$file" || exit 1; done; echo CORE_COMPOSITION_PASS
  EXPECT: CORE_COMPOSITION_PASS
  EVIDENCE: CORE_COMPOSITION_PASS

- [x] G8: OmniStudio migration includes OMA Assess/Migrate, manual cases, and clean-sandbox behavioral equivalence.
  Req: R-011
  CHECK: file=skills/salesforce/salesforce-omnistudio-migration-lead-orchestrator/SKILL.md; grep -q 'OMA \*\*Assess\*\*' "$file" && grep -q 'OMA \*\*Migrate\*\*' "$file" && grep -q 'separate clean validation sandbox' "$file" && grep -q 'behavioral equivalence' "$file" && echo OMA_MIGRATION_PASS
  EXPECT: OMA_MIGRATION_PASS
  EVIDENCE: OMA_MIGRATION_PASS

- [x] G9: ETL owns business records while migration owns application, configuration, framework, and runtime conversion.
  Req: R-011
  CHECK: grep -q 'business-record ETL' skills/salesforce/salesforce-omnistudio-data-etl-lead-orchestrator/SKILL.md && grep -q 'does not own application code' skills/general/data-etl-lead-orchestrator/SKILL.md && grep -q 'semantic owner for application code, configuration' skills/general/migration-lead-orchestrator/SKILL.md && echo OWNERSHIP_PASS
  EXPECT: OWNERSHIP_PASS
  EVIDENCE: OWNERSHIP_PASS

- [x] G10: Security, ETL, privacy, release, recovery, and migration skills preserve authorization and recovery boundaries.
  Req: R-012
  CHECK: ./tests/validate_skills.sh --safety-only
  EXPECT: PASS: safety invariants validated
  EVIDENCE: PASS: safety invariants validated

- [x] G11: Documentation lists 24 packages, environment routing, candidate status, installation scope, and compatibility evidence.
  Req: R-014
  CHECK: grep -q '24 skill packages' README.md && grep -q salesforce-omnistudio-environment-router README.md && grep -q 'Release status' README.md && test -f COMPATIBILITY.md && test -f CHANGELOG.md && echo DOCS_PASS
  EXPECT: DOCS_PASS
  EVIDENCE: DOCS_PASS

- [x] G12: CI covers Ubuntu and macOS repository checks.
  Req: R-014
  CHECK: test -f .github/workflows/ci.yml && grep -q ubuntu-latest .github/workflows/ci.yml && grep -q macos-latest .github/workflows/ci.yml && grep -q test_routing_scenarios .github/workflows/ci.yml && grep -q test_gate_evidence .github/workflows/ci.yml && echo CI_MATRIX_PASS
  EXPECT: CI_MATRIX_PASS
  EVIDENCE: CI_MATRIX_PASS

- [x] G13: Shell, Python, package-structure, unfinished-marker, and diff checks pass using only in-repo tooling.
  Req: R-005, R-014
  CHECK: bash -n install.sh tests/*.sh skills/discipline/*/scripts/commit-msg skills/discipline/*/scripts/wb-remind && for py in skills/salesforce/salesforce-omnistudio-environment-router/scripts/classify_environment.py skills/discipline/requirements-traceability-auditor/scripts/wb_trace.py; do python3 -c "compile(open('$py', encoding='utf-8').read(), '$py', 'exec')" || exit 1; done && ./tests/validate_skills.sh >/dev/null && ! grep -rnE 'TODO|TBD|PLACEHOLDER|<fill|coming soon' skills tests README.md COMPATIBILITY.md CHANGELOG.md && git diff --check && echo REPO_CLEAN_PASS
  EXPECT: REPO_CLEAN_PASS
  EVIDENCE: REPO_CLEAN_PASS

- [x] G14: Candidate status and external-proof limitations are explicit rather than promoted from filesystem tests.
  Req: R-014
  CHECK: test "$(grep -l 'status: Candidate' skills/general/*/SKILL.md skills/salesforce/*/SKILL.md skills/discipline/*/SKILL.md | wc -l | tr -d ' ')" = "24" && grep -q 'Runtime discovery' COMPATIBILITY.md && grep -q UNVERIFIED COMPATIBILITY.md && echo CANDIDATE_BOUNDARY_PASS
  EXPECT: CANDIDATE_BOUNDARY_PASS
  EVIDENCE: CANDIDATE_BOUNDARY_PASS

- [x] G15: Repository owner has selected explicit distribution license terms.
  Req: R-014
  CHECK: test -f LICENSE && echo LICENSE_PRESENT
  EXPECT: LICENSE_PRESENT
  EVIDENCE: LICENSE_PRESENT

- [x] G16: The discipline family ships a requirements-traceability auditor with an executable script, commit hook, template, and status model.
  Req: R-001, R-002, R-003
  CHECK: d=skills/discipline/requirements-traceability-auditor; test -x "$d/scripts/wb_trace.py" && test -x "$d/scripts/commit-msg" && test -x "$d/scripts/wb-remind" && test -x "$d/scripts/wb-init" && test -f "$d/templates/REQUIREMENTS.md" && test -f "$d/templates/BACKLOG.md" && test -f "$d/templates/AGENTS.md.snippet" && test -f "$d/references/status-model.md" && echo DISCIPLINE_PACKAGE_PASS
  EXPECT: DISCIPLINE_PACKAGE_PASS
  EVIDENCE: DISCIPLINE_PACKAGE_PASS

- [x] G17: The auditor computes the status ladder, enforces scope freeze and WIP limits, and the commit hook enforces requirement references.
  Req: R-001, R-002, R-003
  CHECK: ./tests/test_traceability.sh
  EXPECT: PASS: traceability auditor, scope governance, cross-host wiring, and commit-msg hook validated
  EVIDENCE: PASS: traceability auditor, scope governance, cross-host wiring, and commit-msg hook validated

- [x] G18: The auditor states that it does not establish semantic correctness.
  Req: R-001
  CHECK: grep -Eiq 'does not prove|not replace' skills/discipline/requirements-traceability-auditor/SKILL.md && grep -q 'semantically correct' skills/discipline/requirements-traceability-auditor/references/status-model.md && echo AUDITOR_LIMITS_PASS
  EXPECT: AUDITOR_LIMITS_PASS
  EVIDENCE: AUDITOR_LIMITS_PASS

- [x] G19: The installer accepts the discipline group at both scopes.
  Req: R-004
  CHECK: d=$(mktemp -d) && CLAUDE_GLOBAL_SKILLS_DIR="$d/skills" ./install.sh --target claude --group discipline --scope global --dry-run >/dev/null && rm -rf "$d" && echo DISCIPLINE_GROUP_PASS
  EXPECT: DISCIPLINE_GROUP_PASS
  EVIDENCE: DISCIPLINE_GROUP_PASS

- [x] G20: Scope governance defaults new ideas to a backlog rather than the active milestone.
  Req: R-003
  CHECK: d=skills/discipline/requirements-traceability-auditor; grep -q 'goes to `BACKLOG.md` by default' "$d/SKILL.md" && grep -q 'not a queue of work' "$d/templates/BACKLOG.md" && grep -q 'RULE:' "$d/scripts/wb-remind" && echo SCOPE_GOVERNANCE_PASS
  EXPECT: SCOPE_GOVERNANCE_PASS
  EVIDENCE: SCOPE_GOVERNANCE_PASS

- [x] G21: Project wiring reaches all four hosts and resolves the git hook directory correctly, including worktrees and core.hooksPath.
  Req: R-004
  CHECK: d=skills/discipline/requirements-traceability-auditor/scripts/wb-init; grep -q '.claude/settings.json' "$d" && grep -q '.cursor/hooks.json' "$d" && grep -q '.agents/hooks.json' "$d" && grep -q '.codex/hooks.json' "$d" && grep -q 'AGENTS.md' "$d" && grep -q 'core.hooksPath' "$d" && grep -q 'git-path hooks' "$d" && grep -q 'commit-msg' "$d" && echo CROSS_HOST_WIRING_PASS
  EXPECT: CROSS_HOST_WIRING_PASS
  EVIDENCE: CROSS_HOST_WIRING_PASS

- [x] G22: Deferred design decisions are parked with recorded rationale rather than lost.
  Req: R-003
  CHECK: test -f BACKLOG.md && grep -q 'work-ledger-protocol' BACKLOG.md && grep -q '## Declined' BACKLOG.md && grep -q 'not a queue of work' BACKLOG.md && echo BACKLOG_PASS
  EXPECT: BACKLOG_PASS
  EVIDENCE: BACKLOG_PASS

- [x] G23: Every lifecycle lead binds delivery to the recorded requirement set.
  Req: R-007
  CHECK: for f in skills/general/*-lead-orchestrator/SKILL.md skills/salesforce/salesforce-omnistudio-*-lead-orchestrator/SKILL.md; do grep -q 'Bind delivery to requirements' "$f" && grep -q 'requirements-traceability-auditor' "$f" || exit 1; done; echo LEAD_BINDING_PASS
  EXPECT: LEAD_BINDING_PASS
  EVIDENCE: LEAD_BINDING_PASS

- [x] G24: Restructuring preserved the installed layout and host discovery contract.
  Req: R-008
  CHECK: ./tests/test_installer.sh >/dev/null && t=$(mktemp -d) && ./install.sh --all --group all --scope project --project-dir "$t" >/dev/null && test "$(find "$t" -name SKILL.md | wc -l | tr -d ' ')" = "72" && rm -rf "$t" && echo INSTALL_CONTRACT_PASS
  EXPECT: INSTALL_CONTRACT_PASS
  EVIDENCE: INSTALL_CONTRACT_PASS

- [x] G25: Every gate names the requirement it proves, and every requirement has a gate.
  Req: R-006
  CHECK: ./tests/test_gate_coverage.sh
  EXPECT: PASS: every gate names a requirement, and every started requirement has a gate
  EVIDENCE: PASS: every gate names a requirement, and every started requirement has a gate

- [x] G26: Committed host configurations reference the reminder portably, not by machine path.
  Req: R-004
  CHECK: for f in .claude/settings.json .cursor/hooks.json .agents/hooks.json .codex/hooks.json; do test -f "$f" || { echo "missing $f"; exit 1; }; done; ! grep -nE '"command"[[:space:]]*:[[:space:]]*"(/|[^"]*//)' .claude/settings.json .cursor/hooks.json .agents/hooks.json .codex/hooks.json && echo PORTABLE_HOOKS_PASS
  EXPECT: PORTABLE_HOOKS_PASS
  EVIDENCE: PORTABLE_HOOKS_PASS

- [x] G27: The milestone landed on master through a pull request merge, not a direct push.
  Req: R-019
  CHECK: test -f .workerbees/M1-LANDING.md && git merge-base --is-ancestor 80adbcb HEAD && [ "$(git rev-list --parents -n1 80adbcb | wc -w)" -ge 3 ] && grep -q 80adbcb .workerbees/M1-LANDING.md && echo M1_LANDED_PASS
  EXPECT: M1_LANDED_PASS
  EVIDENCE: M1_LANDED_PASS

- [x] G28: CI runs every suite on both platforms with the history the gates need.
  Req: R-020
  CHECK: for t in tests/*.sh; do grep -q "$(basename "$t")" .github/workflows/ci.yml || exit 1; done; grep -q ubuntu-latest .github/workflows/ci.yml && grep -q macos-latest .github/workflows/ci.yml && grep -q 'fetch-depth: 0' .github/workflows/ci.yml && grep -q 33314992824 .workerbees/M1-LANDING.md && echo CI_REPRODUCTION_PASS
  EXPECT: CI_REPRODUCTION_PASS
  EVIDENCE: CI_REPRODUCTION_PASS
