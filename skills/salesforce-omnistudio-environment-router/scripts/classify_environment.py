#!/usr/bin/env python3
"""Classify explicit OmniStudio observations without connecting to Salesforce."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


VALID = {
    "runtime": {"standard", "managed", "mixed", "unknown"},
    "designer": {"standard", "managed", "unknown"},
    "storage_model": {"standard", "legacy", "mixed", "unknown"},
    "object_family": {"standard", "legacy", "mixed", "unknown"},
    "interaction_config": {"standard", "legacy", "mixed", "none", "unknown"},
    "source_representation": {"metadata", "datapack-json", "both", "unknown"},
    "requested_action": {"read-only", "mutate"},
}


def validate_mixed_lanes(
    raw_lanes: object,
    aggregate_runtime: str,
    org_metadata_enabled: bool | None,
    aggregate_source: str,
) -> tuple[list[dict], list[str]]:
    """Validate independently authorized transport lanes for a mixed estate."""
    if not isinstance(raw_lanes, list) or len(raw_lanes) < 2:
        return [], ["mixed classification requires at least two explicit lane records"]

    lanes: list[dict] = []
    errors: list[str] = []
    seen_ids: set[str] = set()
    for index, lane in enumerate(raw_lanes):
        label = f"lanes[{index}]"
        if not isinstance(lane, dict):
            errors.append(f"{label} must be an object")
            continue
        lane_id = lane.get("lane_id")
        if not isinstance(lane_id, str) or not lane_id.strip():
            errors.append(f"{label}.lane_id must be a non-empty string")
        elif lane_id in seen_ids:
            errors.append(f"{label}.lane_id must be unique")
        else:
            seen_ids.add(lane_id)

        runtime = lane.get("runtime")
        storage = lane.get("storage_model")
        objects = lane.get("object_family")
        source = lane.get("source_representation")
        metadata = lane.get("metadata_enabled")
        if storage == objects == "standard" and runtime in {"standard", "managed"}:
            if source != "metadata" or metadata is not True:
                errors.append(f"{label} standard lane requires metadata source and metadata_enabled true")
                continue
            transport = "SALESFORCE_METADATA"
        elif runtime == "managed" and storage == objects == "legacy":
            if source != "datapack-json":
                errors.append(f"{label} legacy lane requires datapack-json source")
                continue
            transport = "OMNISTUDIO_BUILD_TOOL_DATAPACK"
        else:
            errors.append(f"{label} runtime, storage_model, and object_family do not form a homogeneous lane")
            continue
        lanes.append({**lane, "transport": transport})
    transports = {lane["transport"] for lane in lanes}
    runtimes = {lane["runtime"] for lane in lanes}
    expected_runtime = next(iter(runtimes)) if len(runtimes) == 1 else "mixed"
    if aggregate_runtime != expected_runtime:
        errors.append(f"aggregate runtime must be {expected_runtime} for the resolved lanes")
    if "SALESFORCE_METADATA" in transports and org_metadata_enabled is not True:
        errors.append("metadata lane requires the org-wide final metadata_enabled state to be true")
    expected_source = (
        "both"
        if transports == {"SALESFORCE_METADATA", "OMNISTUDIO_BUILD_TOOL_DATAPACK"}
        else "metadata"
        if transports == {"SALESFORCE_METADATA"}
        else "datapack-json"
        if transports == {"OMNISTUDIO_BUILD_TOOL_DATAPACK"}
        else "unknown"
    )
    if expected_source != "both":
        errors.append("mixed classification requires independently valid metadata and DataPack lanes")
    if aggregate_source != expected_source:
        errors.append(f"aggregate source_representation must be {expected_source} for the resolved lanes")
    return lanes, errors


def normalize(facts: dict) -> tuple[dict, list[str]]:
    errors: list[str] = []
    out = dict(facts)
    defaults = {
        "runtime": "unknown",
        "designer": "unknown",
        "storage_model": "unknown",
        "object_family": "unknown",
        "interaction_config": "unknown",
        "source_representation": "unknown",
        "requested_action": "read-only",
        "metadata_enabled": None,
        "mutation_authorized": False,
    }
    for key, default in defaults.items():
        out.setdefault(key, default)
    for key, allowed in VALID.items():
        if not isinstance(out[key], str) or out[key] not in allowed:
            errors.append(f"{key} must be one of {sorted(allowed)}")
    if out["metadata_enabled"] is not None and not isinstance(out["metadata_enabled"], bool):
        errors.append("metadata_enabled must be true, false, or null")
    if not isinstance(out["mutation_authorized"], bool):
        errors.append("mutation_authorized must be boolean")
    return out, errors


def classify(raw: dict) -> dict:
    if not isinstance(raw, dict):
        return {
            "classification": "UNKNOWN",
            "transport": "BLOCKED_INVALID_FACTS",
            "action": "BLOCKED",
            "reasons": ["facts must be a JSON object"],
        }
    facts, errors = normalize(raw)
    reasons: list[str] = []
    if errors:
        return {"classification": "UNKNOWN", "transport": "BLOCKED_INVALID_FACTS", "action": "BLOCKED", "reasons": errors}

    storage = facts["storage_model"]
    objects = facts["object_family"]
    runtime = facts["runtime"]
    interaction = facts["interaction_config"]
    model_signals = {value for value in (storage, objects, interaction) if value not in {"none", "unknown"}}
    contradictory = {"standard", "legacy"}.issubset(model_signals)
    if contradictory:
        classification = "MISMATCH"
        reasons.append("runtime, storage, object, or interaction observations contradict one another")
    elif "mixed" in model_signals:
        classification = "MIXED"
        reasons.append("storage and object observations require isolated lanes")
    elif "unknown" in (runtime, storage, objects):
        classification = "UNKNOWN"
        reasons.append("runtime, storage model, and object family are all required")
    elif runtime == "standard" and storage == objects == "standard":
        classification = "STANDARD_NATIVE"
    elif runtime == "managed" and storage == objects == "legacy":
        classification = "MANAGED_LEGACY"
    elif runtime == "managed" and storage == objects == "standard":
        classification = "MANAGED_STANDARD_MODEL"
    else:
        classification = "MISMATCH"
        reasons.append("runtime, storage, and object observations contradict a homogeneous lane")

    source = facts["source_representation"]
    metadata = facts["metadata_enabled"]
    if classification == "MANAGED_LEGACY" and source == "datapack-json":
        transport = "OMNISTUDIO_BUILD_TOOL_DATAPACK"
    elif classification in {"STANDARD_NATIVE", "MANAGED_STANDARD_MODEL"} and source == "metadata" and metadata is True:
        transport = "SALESFORCE_METADATA"
    elif classification == "MIXED":
        resolved_lanes, lane_errors = validate_mixed_lanes(
            facts.get("lanes"), runtime, metadata, source
        )
        if lane_errors:
            transport = "BLOCKED_MISMATCH"
            reasons.extend(lane_errors)
        else:
            transport = "ISOLATED_METADATA_AND_DATAPACK_LANES"
    elif classification == "MISMATCH":
        transport = "BLOCKED_MISMATCH"
    elif classification == "UNKNOWN":
        transport = "BLOCKED_UNKNOWN"
    else:
        transport = "BLOCKED_MISMATCH"
        reasons.append("source representation or OmniStudio Metadata state does not support the classified lane")

    action = "ALLOWED_READ_ONLY"
    if facts["requested_action"] == "mutate":
        if not facts["mutation_authorized"]:
            action = "BLOCKED_UNAUTHORIZED_MUTATION"
            reasons.append("mutation requested without explicit authorization")
        elif transport.startswith("BLOCKED"):
            action = "BLOCKED_TRANSPORT"
        else:
            action = "AUTHORIZED_NOT_EXECUTED"

    result = {
        "classification": classification,
        "transport": transport,
        "action": action,
        "observed_dimensions": {
            key: facts[key]
            for key in (
                "runtime",
                "designer",
                "storage_model",
                "object_family",
                "metadata_enabled",
                "interaction_config",
                "source_representation",
            )
        },
        "reasons": reasons,
    }
    if classification == "MIXED":
        result["resolved_lanes"] = resolved_lanes
    return result


FIXTURES = {
    "standard-native": ({"runtime": "standard", "storage_model": "standard", "object_family": "standard", "metadata_enabled": True, "source_representation": "metadata"}, ("STANDARD_NATIVE", "SALESFORCE_METADATA", "ALLOWED_READ_ONLY")),
    "managed-legacy": ({"runtime": "managed", "storage_model": "legacy", "object_family": "legacy", "metadata_enabled": False, "source_representation": "datapack-json"}, ("MANAGED_LEGACY", "OMNISTUDIO_BUILD_TOOL_DATAPACK", "ALLOWED_READ_ONLY")),
    "managed-standard-model": ({"runtime": "managed", "storage_model": "standard", "object_family": "standard", "metadata_enabled": True, "source_representation": "metadata"}, ("MANAGED_STANDARD_MODEL", "SALESFORCE_METADATA", "ALLOWED_READ_ONLY")),
    "mixed": ({"runtime": "managed", "storage_model": "mixed", "object_family": "mixed", "metadata_enabled": True, "source_representation": "both", "lanes": [{"lane_id": "standard-assets", "runtime": "managed", "storage_model": "standard", "object_family": "standard", "metadata_enabled": True, "source_representation": "metadata"}, {"lane_id": "legacy-assets", "runtime": "managed", "storage_model": "legacy", "object_family": "legacy", "metadata_enabled": False, "source_representation": "datapack-json"}]}, ("MIXED", "ISOLATED_METADATA_AND_DATAPACK_LANES", "ALLOWED_READ_ONLY")),
    "unknown": ({}, ("UNKNOWN", "BLOCKED_UNKNOWN", "ALLOWED_READ_ONLY")),
    "metadata-mismatch": ({"runtime": "standard", "storage_model": "standard", "object_family": "standard", "metadata_enabled": False, "source_representation": "metadata"}, ("STANDARD_NATIVE", "BLOCKED_MISMATCH", "ALLOWED_READ_ONLY")),
    "unauthorized-mutation": ({"runtime": "managed", "storage_model": "legacy", "object_family": "legacy", "metadata_enabled": False, "source_representation": "datapack-json", "requested_action": "mutate", "mutation_authorized": False}, ("MANAGED_LEGACY", "OMNISTUDIO_BUILD_TOOL_DATAPACK", "BLOCKED_UNAUTHORIZED_MUTATION")),
}


def self_test() -> int:
    failures = []
    for name, (facts, expected) in FIXTURES.items():
        actual = classify(facts)
        observed = (actual["classification"], actual["transport"], actual["action"])
        if observed != expected:
            failures.append({"fixture": name, "expected": expected, "actual": observed})
    print(json.dumps({"passed": len(FIXTURES) - len(failures), "total": len(FIXTURES), "failures": failures}, indent=2))
    return 1 if failures else 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--facts", type=Path, help="JSON file of explicit observed facts; use - for stdin")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    if not args.facts:
        parser.error("--facts or --self-test is required")
    try:
        raw = json.load(sys.stdin if str(args.facts) == "-" else args.facts.open(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(json.dumps({"classification": "UNKNOWN", "transport": "BLOCKED_INVALID_INPUT", "action": "BLOCKED", "reasons": [str(exc)]}))
        return 2
    result = classify(raw)
    print(json.dumps(result, indent=2))
    is_blocked = result["action"].startswith("BLOCKED") or result["transport"].startswith("BLOCKED")
    return 1 if is_blocked else 0


if __name__ == "__main__":
    raise SystemExit(main())
