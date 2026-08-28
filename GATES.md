# Gates: WorkerBees lifecycle and Salesforce OmniStudio skill families

Scope: Ship eleven vendor-neutral lifecycle skills, eleven Salesforce OmniStudio/Vlocity lifecycle variants, and one shared OmniStudio environment router as portable candidate packages.

- [x] G1: The vendor-neutral lifecycle family contains eleven skill packages.
  CHECK: test "$(find skills/general -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')" = "11" && echo CORE_COUNT_PASS
  EXPECT: CORE_COUNT_PASS
  EVIDENCE: CORE_COUNT_PASS

- [x] G2: The Salesforce family contains eleven lifecycle variants plus one environment router.
  CHECK: test "$(find skills/salesforce -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')" = "12" && test -f skills/salesforce/salesforce-omnistudio-environment-router/SKILL.md && echo OMNISTUDIO_COUNT_PASS
  EXPECT: OMNISTUDIO_COUNT_PASS
  EVIDENCE: OMNISTUDIO_COUNT_PASS

- [x] G3: Every skill package passes repository structural and composition validation.
  CHECK: ./tests/validate_skills.sh
  EXPECT: PASS: 23 skill packages validated
  EVIDENCE: PASS: 23 skill packages validated

- [x] G4: Installer group, scope, full-tree, symlink, stale-file, transactional-preflight, conflict, force, and dry-run tests pass for all four targets.
  CHECK: ./tests/test_installer.sh | tail -n 1
  EXPECT: PASS: installer groups, scopes, targets, full-tree verification, safe replacement, transactional preflight, and dry-run behavior
  EVIDENCE: PASS: installer groups, scopes, targets, full-tree verification, safe replacement, transactional preflight, and dry-run behavior

- [x] G5: OmniStudio environment classification and mutation authorization scenarios pass.
  CHECK: ./tests/test_routing_scenarios.sh
  EXPECT: PASS: 14 OmniStudio routing and authorization scenarios validated
  EVIDENCE: PASS: 14 OmniStudio routing and authorization scenarios validated

- [x] G6: Every OmniStudio lifecycle variant composes with the shipped router and its core lead.
  CHECK: for file in skills/salesforce/salesforce-omnistudio-*-lead-orchestrator/SKILL.md; do grep -q salesforce-omnistudio-environment-router "$file" && grep -Eqi 'complete shipped .* core skill|complete shipped `swarm-lead-orchestrator` core skill' "$file" || exit 1; done; echo OMNISTUDIO_COMPOSITION_PASS
  EXPECT: OMNISTUDIO_COMPOSITION_PASS
  EVIDENCE: OMNISTUDIO_COMPOSITION_PASS

- [x] G7: Every newer core lifecycle lead composes with the swarm execution substrate and preserves a sequential fallback.
  CHECK: for name in architecture-decision data-etl migration performance-capacity privacy-compliance release-cutover reliability-recovery security-audit system-reconstruction; do file="skills/general/$name-lead-orchestrator/SKILL.md"; grep -q swarm-lead-orchestrator "$file" && grep -qi sequential "$file" || exit 1; done; echo CORE_COMPOSITION_PASS
  EXPECT: CORE_COMPOSITION_PASS
  EVIDENCE: CORE_COMPOSITION_PASS

- [x] G8: OmniStudio migration includes OMA Assess/Migrate, manual cases, and clean-sandbox behavioral equivalence.
  CHECK: file=skills/salesforce/salesforce-omnistudio-migration-lead-orchestrator/SKILL.md; grep -q 'OMA \*\*Assess\*\*' "$file" && grep -q 'OMA \*\*Migrate\*\*' "$file" && grep -q 'separate clean validation sandbox' "$file" && grep -q 'behavioral equivalence' "$file" && echo OMA_MIGRATION_PASS
  EXPECT: OMA_MIGRATION_PASS
  EVIDENCE: OMA_MIGRATION_PASS

- [x] G9: ETL owns business records while migration owns application, configuration, framework, and runtime conversion.
  CHECK: grep -q 'business-record ETL' skills/salesforce/salesforce-omnistudio-data-etl-lead-orchestrator/SKILL.md && grep -q 'does not own application code' skills/general/data-etl-lead-orchestrator/SKILL.md && grep -q 'semantic owner for application code, configuration' skills/general/migration-lead-orchestrator/SKILL.md && echo OWNERSHIP_PASS
  EXPECT: OWNERSHIP_PASS
  EVIDENCE: OWNERSHIP_PASS

- [x] G10: Security, ETL, privacy, release, recovery, and migration skills preserve authorization and recovery boundaries.
  CHECK: ./tests/validate_skills.sh --safety-only
  EXPECT: PASS: safety invariants validated
  EVIDENCE: PASS: safety invariants validated

- [x] G11: Documentation lists 23 packages, environment routing, candidate status, installation scope, and compatibility evidence.
  CHECK: grep -q '23 skill packages' README.md && grep -q salesforce-omnistudio-environment-router README.md && grep -q 'Release status' README.md && test -f COMPATIBILITY.md && test -f CHANGELOG.md && echo DOCS_PASS
  EXPECT: DOCS_PASS
  EVIDENCE: DOCS_PASS

- [x] G12: CI covers Ubuntu and macOS repository checks.
  CHECK: test -f .github/workflows/ci.yml && grep -q ubuntu-latest .github/workflows/ci.yml && grep -q macos-latest .github/workflows/ci.yml && grep -q test_routing_scenarios .github/workflows/ci.yml && grep -q test_gate_evidence .github/workflows/ci.yml && echo CI_MATRIX_PASS
  EXPECT: CI_MATRIX_PASS
  EVIDENCE: CI_MATRIX_PASS

- [x] G13: Shell, Python, Skill Creator, unfinished-marker, and diff checks pass.
  CHECK: bash -n install.sh tests/*.sh && python3 -c 'compile(open("skills/salesforce/salesforce-omnistudio-environment-router/scripts/classify_environment.py", encoding="utf-8").read(), "classify_environment.py", "exec")' && for skill in skills/general/* skills/salesforce/*; do python3 /Users/anshulmehta/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$skill" >/dev/null || exit 1; done && ! rg -n 'TODO|TBD|PLACEHOLDER|<fill|coming soon' skills tests README.md COMPATIBILITY.md CHANGELOG.md && git diff --check && echo REPO_CLEAN_PASS
  EXPECT: REPO_CLEAN_PASS
  EVIDENCE: REPO_CLEAN_PASS

- [x] G14: Candidate status and external-proof limitations are explicit rather than promoted from filesystem tests.
  CHECK: test "$(rg -l 'status: Candidate' skills/general/*/SKILL.md skills/salesforce/*/SKILL.md | wc -l | tr -d ' ')" = "23" && grep -q 'Runtime discovery' COMPATIBILITY.md && grep -q UNVERIFIED COMPATIBILITY.md && echo CANDIDATE_BOUNDARY_PASS
  EXPECT: CANDIDATE_BOUNDARY_PASS
  EVIDENCE: CANDIDATE_BOUNDARY_PASS

- [x] G15: Repository owner has selected explicit distribution license terms.
  CHECK: test -f LICENSE && echo LICENSE_PRESENT
  EXPECT: LICENSE_PRESENT
  EVIDENCE: LICENSE_PRESENT
