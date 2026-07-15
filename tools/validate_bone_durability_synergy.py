#!/usr/bin/env python3
"""Validate bone durability, mutation and synergy rule contracts.

This is a read-only static/simulated check for the shared BoneRulesService
contract. Runtime state for individual item durability can be added later
without duplicating these formulas in UI or Player.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import math
import sys


ROOT = Path(__file__).resolve().parents[1]
BONE_DEFINITION = ROOT / "scripts" / "bone_definition.gd"
BONE_RULES = ROOT / "scripts" / "bone_rules_service.gd"
BONE_DATABASE = ROOT / "scripts" / "bone_database.gd"
EQUIPMENT_RULES = ROOT / "scripts" / "equipment_rules_service.gd"

CRACKED_THRESHOLD = 0.4


@dataclass(frozen=True)
class Bone:
    bone_id: str
    set_id: str
    set_name: str
    set_piece_key: str
    set_tags: list[str]
    synergy_ids: list[str]
    synergy_tags: list[str]
    synergy_score: float
    mutation_family: str
    mutation_intensity: float


def durability_state(current: int, maximum: int) -> str:
    if maximum <= 0 or current <= 0:
        return "broken"
    if current / maximum <= CRACKED_THRESHOLD:
        return "cracked"
    return "intact"


def synergy_summary(equipped: dict[str, Bone | None]) -> dict[str, object]:
    set_counts: dict[str, int] = {}
    synergy_counts: dict[str, int] = {}
    tag_counts: dict[str, int] = {}
    mutation_counts: dict[str, int] = {}
    total_synergy_score = 0.0
    total_mutation_intensity = 0.0

    for bone in equipped.values():
        if bone is None:
            continue
        if bone.set_id:
            set_counts[bone.set_id] = set_counts.get(bone.set_id, 0) + 1
        for synergy_id in bone.synergy_ids:
            synergy_counts[synergy_id] = synergy_counts.get(synergy_id, 0) + 1
        for tag in bone.set_tags + bone.synergy_tags:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1
        if bone.mutation_family:
            mutation_counts[bone.mutation_family] = mutation_counts.get(bone.mutation_family, 0) + 1
            total_mutation_intensity += bone.mutation_intensity
        total_synergy_score += bone.synergy_score

    return {
        "set_counts": set_counts,
        "active_set_ids": sorted(key for key, value in set_counts.items() if value >= 2),
        "synergy_counts": synergy_counts,
        "active_synergy_ids": sorted(key for key, value in synergy_counts.items() if value >= 2),
        "tag_counts": tag_counts,
        "mutation_counts": mutation_counts,
        "total_synergy_score": total_synergy_score,
        "total_mutation_intensity": total_mutation_intensity,
    }


STARTER_ARM = Bone(
    bone_id="arm_bone",
    set_id="starter_bones",
    set_name="Starter Bones",
    set_piece_key="arm",
    set_tags=["starter", "reach"],
    synergy_ids=["starter_bones", "reach_bones"],
    synergy_tags=["starter", "reach", "right_arm"],
    synergy_score=0.15,
    mutation_family="",
    mutation_intensity=0.0,
)

STARTER_LEG = Bone(
    bone_id="leg_bone",
    set_id="starter_bones",
    set_name="Starter Bones",
    set_piece_key="legs",
    set_tags=["starter", "speed"],
    synergy_ids=["starter_bones", "speed_bones"],
    synergy_tags=["starter", "speed", "legs"],
    synergy_score=0.15,
    mutation_family="",
    mutation_intensity=0.0,
)

RIB = Bone(
    bone_id="rib_bone",
    set_id="hybrid_bones",
    set_name="Hybrid Bones",
    set_piece_key="body",
    set_tags=["hybrid", "adaptive"],
    synergy_ids=["hybrid_bones", "body_bones"],
    synergy_tags=["hybrid", "adaptive", "body"],
    synergy_score=0.3,
    mutation_family="hibrido",
    mutation_intensity=0.25,
)


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"ERROR: missing required file: {path.relative_to(ROOT)}")


def check_static_contract(files: dict[Path, str]) -> list[str]:
    errors: list[str] = []
    required_fragments = {
        BONE_DEFINITION: [
            "const DURABILITY_INTACT",
            "@export_group(\"Durability\")",
            "durability_max",
            "durability_start",
            "durability_repair_cost",
            "durability_tags",
        ],
        BONE_DATABASE: [
            "static func durability_max",
            "static func durability_start",
            "static func durability_repair_cost",
            "static func durability_tags",
        ],
        EQUIPMENT_RULES: [
            "_generated_limb_durability_max",
            "_generated_limb_durability_start",
            "_generated_limb_durability_repair_cost",
            "_generated_limb_durability_tags",
        ],
        BONE_RULES: [
            "static func durability_profile_for",
            "static func durability_state_for",
            "static func mutation_profile_for",
            "static func synergy_profile_for",
            "static func equipment_synergy_summary",
            "active_set_ids",
            "active_synergy_ids",
        ],
    }

    for path, fragments in required_fragments.items():
        text = files[path]
        for fragment in fragments:
            if fragment not in text:
                errors.append(f"{path.relative_to(ROOT)} missing fragment: {fragment}")
    return errors


def check_simulated_cases() -> list[str]:
    errors: list[str] = []
    state_cases = [
        ("full durability is intact", 80, 80, "intact"),
        ("threshold durability is cracked", 32, 80, "cracked"),
        ("zero durability is broken", 0, 80, "broken"),
    ]
    for name, current, maximum, expected in state_cases:
        actual = durability_state(current, maximum)
        if actual != expected:
            errors.append(f"{name}: expected {expected}, got {actual}")
        else:
            print(f"  [PASS] {name}")

    summary = synergy_summary(
        {
            "right_arm": STARTER_ARM,
            "legs": STARTER_LEG,
            "body": RIB,
            "head": None,
        }
    )
    expected_active_sets = ["starter_bones"]
    if summary["active_set_ids"] != expected_active_sets:
        errors.append(f"active_set_ids expected {expected_active_sets}, got {summary['active_set_ids']}")
    if summary["synergy_counts"].get("starter_bones") != 2:
        errors.append("starter_bones synergy count should be 2")
    if summary["mutation_counts"].get("hibrido") != 1:
        errors.append("hibrido mutation count should be 1")
    if not math.isclose(float(summary["total_synergy_score"]), 0.6, rel_tol=0.0, abs_tol=0.00001):
        errors.append(f"total_synergy_score expected 0.6, got {summary['total_synergy_score']}")
    if not math.isclose(float(summary["total_mutation_intensity"]), 0.25, rel_tol=0.0, abs_tol=0.00001):
        errors.append(
            f"total_mutation_intensity expected 0.25, got {summary['total_mutation_intensity']}"
        )
    if not errors:
        print("  [PASS] equipment synergy summary activates repeated set ids")
    return errors


def main() -> int:
    files = {
        BONE_DEFINITION: read(BONE_DEFINITION),
        BONE_RULES: read(BONE_RULES),
        BONE_DATABASE: read(BONE_DATABASE),
        EQUIPMENT_RULES: read(EQUIPMENT_RULES),
    }

    print("Bone durability and synergy validation")
    print("--------------------------------------")
    errors = check_static_contract(files)
    if errors:
        for error in errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Shared durability, mutation and synergy APIs are present.")
    errors.extend(check_simulated_cases())
    print("--------------------------------------")
    if errors:
        print(f"Result: FAIL ({len(errors)} error(s)).")
        return 1
    print("Result: OK (durability and synergy contracts intact).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
