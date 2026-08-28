#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SKILLS_DIR="$REPO_DIR/skills"
MODE=${1:-all}

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

frontmatter_value() {
    local key=$1
    local file=$2
    awk -v wanted="$key" '
        NR == 1 && $0 == "---" { in_frontmatter = 1; next }
        in_frontmatter && $0 == "---" { exit }
        in_frontmatter && index($0, wanted ":") == 1 {
            sub("^[^:]+:[[:space:]]*", "")
            print
            exit
        }
    ' "$file"
}

validate_safety() {
    local file=$1
    grep -Eiq 'authoriz|approval|permission' "$file" || fail "missing authorization boundary: $file"
    grep -Eiq 'production|live data|destructive|mutation' "$file" || fail "missing hazardous-operation boundary: $file"
    grep -Eiq 'rollback|recover|revers|compensat|restore|cleanup' "$file" || fail "missing recovery boundary: $file"
}

case "$MODE" in
    all|--safety-only) ;;
    *) fail "unknown mode: $MODE" ;;
esac

skill_count=0
omnistudio_count=0
omnistudio_lifecycle_count=0
names_file=$(mktemp "${TMPDIR:-/tmp}/workerbees-names.XXXXXX")
descriptions_file=$(mktemp "${TMPDIR:-/tmp}/workerbees-descriptions.XXXXXX")
trap 'rm -f -- "$names_file" "$descriptions_file"' EXIT

while IFS= read -r file; do
    package_dir=${file%/SKILL.md}
    [ -f "$file" ] || fail "missing SKILL.md: $package_dir"
    folder_name=$(basename -- "$package_dir")
    category=$(basename -- "$(dirname -- "$package_dir")")
    case "$category:$folder_name" in
        general:salesforce-*) fail "Salesforce skill is misplaced in general category: $package_dir" ;;
        salesforce:salesforce-*) ;;
        salesforce:*) fail "Non-Salesforce skill is misplaced in Salesforce category: $package_dir" ;;
        general:*) ;;
        *) fail "unknown skill category: $category" ;;
    esac

    if [ "$MODE" = "--safety-only" ]; then
        case "$folder_name" in
            *security*|*data-etl*|*privacy*|*release-cutover*|*reliability-recovery*|*migration*)
                validate_safety "$file"
                ;;
        esac
        continue
    fi

    skill_count=$((skill_count + 1))
    name=$(frontmatter_value name "$file")
    description=$(frontmatter_value description "$file")
    [ "$name" = "$folder_name" ] || fail "frontmatter name does not match folder: $file"
    [ -n "$description" ] || fail "missing description: $file"
    case "$name" in
        *[!a-z0-9-]*) fail "invalid skill name: $name" ;;
    esac
    [ "$(wc -l < "$file" | tr -d ' ')" -ge 40 ] || fail "skill is too thin: $file"
    ! grep -Eiq 'TO[D]O|T[B]D|PLACE[H]OLDER|COMING[[:space:]]SOON' "$file" || fail "unfinished marker: $file"
    printf '%s\n' "$name" >> "$names_file"
    printf '%s\n' "$description" >> "$descriptions_file"

    case "$folder_name" in
        salesforce-omnistudio-*)
            omnistudio_count=$((omnistudio_count + 1))
            grep -Eiq 'runtime' "$file" || fail "missing runtime provenance: $file"
            grep -Eiq 'namespace' "$file" || fail "missing namespace provenance: $file"
            grep -Eiq 'provenance' "$file" || fail "missing provenance language: $file"
            grep -Eiq 'do not use for (generic|general) Salesforce' "$file" || fail "description lacks strict domain exclusion: $file"
            case "$folder_name" in
                salesforce-omnistudio-environment-router)
                    grep -q 'MANAGED_STANDARD_MODEL' "$file" || fail "router lacks managed-standard-model classification"
                    grep -q 'OmniStudio Metadata' "$file" || fail "router lacks Metadata-setting provenance"
                    grep -q 'Omni Interaction Configuration' "$file" || fail "router lacks interaction-configuration provenance"
                    ;;
                *)
                    omnistudio_lifecycle_count=$((omnistudio_lifecycle_count + 1))
                    grep -q 'salesforce-omnistudio-environment-router' "$file" || fail "lifecycle skill does not load environment router: $file"
                    grep -Eiq 'complete shipped .* core skill|complete shipped `swarm-lead-orchestrator` core skill' "$file" || fail "lifecycle skill does not compose with its core skill: $file"
                    grep -Eiq 'sequential' "$file" || fail "lifecycle skill lacks no-worker fallback: $file"
                    grep -Eiq 'version/source provenance|path and version|path, version/source' "$file" || fail "optional complement lacks provenance check: $file"
                    grep -Eiq 'Omni Process Compilation' "$file" || fail "lifecycle skill lacks explicit standard-runtime access gate: $file"
                    ! grep -Eq '\*\*Standard/Core runtime:\*\*|\*\*Managed Package runtime:\*\*' "$file" || fail "lifecycle skill still selects transport from runtime alone: $file"
                    ;;
            esac
            ;;
    esac
done < <(find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -type f -name SKILL.md -print | LC_ALL=C sort)

if [ "$MODE" = "--safety-only" ]; then
    printf 'PASS: safety invariants validated\n'
    exit 0
fi

[ "$skill_count" -eq 23 ] || fail "expected 23 skill packages, found $skill_count"
[ "$omnistudio_count" -eq 12 ] || fail "expected 12 OmniStudio skill packages, found $omnistudio_count"
[ "$omnistudio_lifecycle_count" -eq 11 ] || fail "expected 11 OmniStudio lifecycle skills, found $omnistudio_lifecycle_count"
[ "$(sort "$names_file" | uniq -d | wc -l | tr -d ' ')" -eq 0 ] || fail "duplicate skill names"
[ "$(sort "$descriptions_file" | uniq -d | wc -l | tr -d ' ')" -eq 0 ] || fail "duplicate skill descriptions"

router_dir="$SKILLS_DIR/salesforce/salesforce-omnistudio-environment-router"
[ -f "$router_dir/references/native-standard-lane.md" ] || fail "missing native/standard runtime guide"
[ -f "$router_dir/references/legacy-datapack-lane.md" ] || fail "missing managed legacy/DataPack guide"
[ -x "$router_dir/scripts/classify_environment.py" ] || fail "environment classifier is not executable"

for core_name in architecture-decision data-etl migration performance-capacity privacy-compliance release-cutover reliability-recovery security-audit system-reconstruction; do
    core_file="$SKILLS_DIR/general/$core_name-lead-orchestrator/SKILL.md"
    grep -q 'swarm-lead-orchestrator' "$core_file" || fail "core lifecycle skill does not compose with swarm: $core_file"
    grep -Eiq 'sequential' "$core_file" || fail "core lifecycle skill lacks sequential fallback: $core_file"
    grep -Eiq 'collision|contend|shared resource' "$core_file" || fail "core lifecycle skill lacks resource-collision guidance: $core_file"
done

grep -q 'OMA \*\*Assess\*\*' "$SKILLS_DIR/salesforce/salesforce-omnistudio-migration-lead-orchestrator/SKILL.md" || fail "migration skill lacks OMA Assess gate"
grep -q 'separate clean validation sandbox' "$SKILLS_DIR/salesforce/salesforce-omnistudio-migration-lead-orchestrator/SKILL.md" || fail "migration skill lacks independent validation sandbox"
grep -q 'business-record ETL' "$SKILLS_DIR/salesforce/salesforce-omnistudio-data-etl-lead-orchestrator/SKILL.md" || fail "OmniStudio ETL ownership is ambiguous"
grep -Eq 'Omni Process Compilation.*Read and Edit' "$router_dir/SKILL.md" || fail "router lacks exact Omni Process Compilation baseline grant"
grep -Eq 'Omni Data Transformation.*Read' "$router_dir/SKILL.md" || fail "router lacks exact Omni Data Transformation baseline grant"
grep -Eq 'OmniScript Saved Sessions.*Read and Edit' "$router_dir/SKILL.md" || fail "router lacks exact OmniScript Saved Sessions baseline grant"
grep -q 'VlocityDataPack__c' "$router_dir/references/legacy-datapack-lane.md" || fail "legacy lane lacks optional DataPack object discovery mapping"

sf_migration="$SKILLS_DIR/salesforce/salesforce-omnistudio-migration-lead-orchestrator/SKILL.md"
general_release="$SKILLS_DIR/general/release-cutover-lead-orchestrator/SKILL.md"
sf_release="$SKILLS_DIR/salesforce/salesforce-omnistudio-release-cutover-lead-orchestrator/SKILL.md"
general_investigation="$SKILLS_DIR/general/investigation-lead-orchestrator/SKILL.md"
sf_investigation="$SKILLS_DIR/salesforce/salesforce-omnistudio-investigation-lead-orchestrator/SKILL.md"

grep -Eiq 'provisioning system|provisioning-system' "$sf_migration" || fail "OmniStudio migration lacks non-Omni provisioning route"
grep -q 'migration-lead-orchestrator' "$sf_migration" || fail "OmniStudio migration does not route non-Omni migration to the general lead"
for release_file in "$general_release" "$sf_release"; do
    grep -Eiq 'repository instructions' "$release_file" || fail "release skill lacks repository-policy precedence: $release_file"
    grep -Eiq 'retrieve-and-diff' "$release_file" || fail "release skill lacks retrieve-and-diff gate: $release_file"
    grep -Eiq 'allowlist' "$release_file" || fail "release skill lacks target allowlist gate: $release_file"
done
for investigation_file in "$general_investigation" "$sf_investigation"; do
    grep -Eiq 'project-native investigation' "$investigation_file" || fail "investigation skill does not prefer project-native capabilities: $investigation_file"
done
grep -q 'Required capability' "$sf_investigation" || fail "OmniStudio investigation complement routing is not capability-first"

printf 'PASS: 23 skill packages validated\n'
