#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CLASSIFIER="$REPO_DIR/skills/salesforce/salesforce-omnistudio-environment-router/scripts/classify_environment.py"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_case() {
    local name=$1
    local facts=$2
    local expected_classification=$3
    local expected_transport=$4
    local expected_action=$5
    local expected_status=$6
    local output
    local status

    set +e
    output=$(printf '%s\n' "$facts" | python3 "$CLASSIFIER" --facts - 2>&1)
    status=$?
    set -e

    [ "$status" -eq "$expected_status" ] || fail "$name returned $status, expected $expected_status: $output"
    printf '%s\n' "$output" | grep -q '"classification": "'"$expected_classification"'"' || fail "$name classification mismatch: $output"
    printf '%s\n' "$output" | grep -q '"transport": "'"$expected_transport"'"' || fail "$name transport mismatch: $output"
    printf '%s\n' "$output" | grep -q '"action": "'"$expected_action"'"' || fail "$name action mismatch: $output"
}

self_test_output=$(python3 "$CLASSIFIER" --self-test)
printf '%s\n' "$self_test_output" | grep -q '"passed": 7' || fail "classifier self-test did not pass 7 fixtures"
printf '%s\n' "$self_test_output" | grep -q '"failures": \[\]' || fail "classifier self-test reported failures"

assert_case standard_native \
    '{"runtime":"standard","designer":"standard","storage_model":"standard","object_family":"standard","metadata_enabled":true,"interaction_config":"standard","source_representation":"metadata"}' \
    STANDARD_NATIVE SALESFORCE_METADATA ALLOWED_READ_ONLY 0

assert_case managed_legacy \
    '{"runtime":"managed","designer":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"interaction_config":"legacy","source_representation":"datapack-json"}' \
    MANAGED_LEGACY OMNISTUDIO_BUILD_TOOL_DATAPACK ALLOWED_READ_ONLY 0

assert_case managed_standard_model \
    '{"runtime":"managed","designer":"managed","storage_model":"standard","object_family":"standard","metadata_enabled":true,"interaction_config":"standard","source_representation":"metadata"}' \
    MANAGED_STANDARD_MODEL SALESFORCE_METADATA ALLOWED_READ_ONLY 0

assert_case mixed \
    '{"runtime":"managed","designer":"managed","storage_model":"mixed","object_family":"mixed","metadata_enabled":true,"interaction_config":"mixed","source_representation":"both","lanes":[{"lane_id":"standard-assets","runtime":"managed","storage_model":"standard","object_family":"standard","metadata_enabled":true,"source_representation":"metadata"},{"lane_id":"legacy-assets","runtime":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"source_representation":"datapack-json"}]}' \
    MIXED ISOLATED_METADATA_AND_DATAPACK_LANES ALLOWED_READ_ONLY 0

assert_case mixed_metadata_disabled \
    '{"runtime":"managed","designer":"managed","storage_model":"mixed","object_family":"mixed","metadata_enabled":false,"interaction_config":"mixed","source_representation":"both","lanes":[{"lane_id":"standard-assets","runtime":"managed","storage_model":"standard","object_family":"standard","metadata_enabled":false,"source_representation":"metadata"},{"lane_id":"legacy-assets","runtime":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"source_representation":"datapack-json"}]}' \
    MIXED BLOCKED_MISMATCH ALLOWED_READ_ONLY 1

assert_case mixed_org_lane_metadata_disagreement \
    '{"runtime":"managed","designer":"managed","storage_model":"mixed","object_family":"mixed","metadata_enabled":false,"interaction_config":"mixed","source_representation":"both","lanes":[{"lane_id":"standard-assets","runtime":"managed","storage_model":"standard","object_family":"standard","metadata_enabled":true,"source_representation":"metadata"},{"lane_id":"legacy-assets","runtime":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"source_representation":"datapack-json"}]}' \
    MIXED BLOCKED_MISMATCH ALLOWED_READ_ONLY 1

assert_case mixed_aggregate_source_disagreement \
    '{"runtime":"managed","designer":"managed","storage_model":"mixed","object_family":"mixed","metadata_enabled":true,"interaction_config":"mixed","source_representation":"metadata","lanes":[{"lane_id":"standard-assets","runtime":"managed","storage_model":"standard","object_family":"standard","metadata_enabled":true,"source_representation":"metadata"},{"lane_id":"legacy-assets","runtime":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"source_representation":"datapack-json"}]}' \
    MIXED BLOCKED_MISMATCH ALLOWED_READ_ONLY 1

assert_case mixed_aggregate_runtime_disagreement \
    '{"runtime":"standard","designer":"standard","storage_model":"mixed","object_family":"mixed","metadata_enabled":true,"interaction_config":"mixed","source_representation":"both","lanes":[{"lane_id":"standard-assets","runtime":"managed","storage_model":"standard","object_family":"standard","metadata_enabled":true,"source_representation":"metadata"},{"lane_id":"legacy-assets","runtime":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"source_representation":"datapack-json"}]}' \
    MIXED BLOCKED_MISMATCH ALLOWED_READ_ONLY 1

assert_case contradictory_observations \
    '{"runtime":"standard","designer":"standard","storage_model":"legacy","object_family":"legacy","metadata_enabled":true,"interaction_config":"standard","source_representation":"both"}' \
    MISMATCH BLOCKED_MISMATCH ALLOWED_READ_ONLY 1

assert_case unknown \
    '{}' \
    UNKNOWN BLOCKED_UNKNOWN ALLOWED_READ_ONLY 1

assert_case metadata_mismatch \
    '{"runtime":"standard","designer":"standard","storage_model":"standard","object_family":"standard","metadata_enabled":false,"interaction_config":"standard","source_representation":"metadata"}' \
    STANDARD_NATIVE BLOCKED_MISMATCH ALLOWED_READ_ONLY 1

assert_case unauthorized_mutation \
    '{"runtime":"managed","designer":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"interaction_config":"legacy","source_representation":"datapack-json","requested_action":"mutate","mutation_authorized":false}' \
    MANAGED_LEGACY OMNISTUDIO_BUILD_TOOL_DATAPACK BLOCKED_UNAUTHORIZED_MUTATION 1

assert_case authorized_not_executed \
    '{"runtime":"managed","designer":"managed","storage_model":"legacy","object_family":"legacy","metadata_enabled":false,"interaction_config":"legacy","source_representation":"datapack-json","requested_action":"mutate","mutation_authorized":true}' \
    MANAGED_LEGACY OMNISTUDIO_BUILD_TOOL_DATAPACK AUTHORIZED_NOT_EXECUTED 0

assert_case invalid_fact_types \
    '{"runtime":[],"metadata_enabled":1}' \
    UNKNOWN BLOCKED_INVALID_FACTS BLOCKED 1

printf 'PASS: 14 OmniStudio routing and authorization scenarios validated\n'
