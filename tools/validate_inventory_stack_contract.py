#!/usr/bin/env python3
"""Validate the current inventory duplicate/stack contract.

The runtime UI still renders one tile per carried copy. This read-only check
locks the existing rule before adding visual stack counts: equipped copies are
filtered by count, while extra duplicates remain visible and stackable.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
INVENTORY_UI = ROOT / "scripts" / "player_inventory_ui.gd"
ITEM_TILE = ROOT / "scripts" / "ui_bone_item.gd"


@dataclass(frozen=True)
class Case:
    name: str
    inventory: list[str]
    equipped: dict[str, str]
    expected_visible: list[str]


CASES = [
    Case(
        name="one equipped copy leaves one duplicate visible",
        inventory=["arm_bone", "arm_bone", "leg_bone"],
        equipped={"right_arm": "arm_bone"},
        expected_visible=["arm_bone", "leg_bone"],
    ),
    Case(
        name="two equipped copies hide only two carried copies",
        inventory=["arm_bone", "arm_bone", "arm_bone"],
        equipped={"right_arm": "arm_bone", "left_arm": "arm_bone"},
        expected_visible=["arm_bone"],
    ),
    Case(
        name="equipped ids do not hide different ids",
        inventory=["arm_bone", "leg_bone"],
        equipped={"body": "torso_bone"},
        expected_visible=["arm_bone", "leg_bone"],
    ),
    Case(
        name="empty equipment keeps all duplicates visible",
        inventory=["head_bone", "head_bone"],
        equipped={},
        expected_visible=["head_bone", "head_bone"],
    ),
]


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"ERROR: missing required file: {path.relative_to(ROOT)}")


def equipped_bone_counts(equipment_state: dict[str, str]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for bone_id in equipment_state.values():
        if bone_id == "":
            continue
        counts[bone_id] = counts.get(bone_id, 0) + 1
    return counts


def visible_inventory_copies(inventory: list[str], equipment_state: dict[str, str]) -> list[str]:
    equipped_counts = equipped_bone_counts(equipment_state)
    skipped_equipped_counts: dict[str, int] = {}
    visible: list[str] = []

    for bone_id in inventory:
        equipped_count = equipped_counts.get(bone_id, 0)
        skipped_count = skipped_equipped_counts.get(bone_id, 0)
        if skipped_count < equipped_count:
            skipped_equipped_counts[bone_id] = skipped_count + 1
            continue
        visible.append(bone_id)

    return visible


def count_visible(visible: list[str]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for bone_id in visible:
        counts[bone_id] = counts.get(bone_id, 0) + 1
    return counts


def check_static_contract(inventory_ui: str, item_tile: str) -> list[str]:
    errors: list[str] = []
    required_inventory_fragments = [
        "var equipped_counts := _equipped_bone_counts()",
        "var skipped_equipped_counts: Dictionary = {}",
        "if skipped_count < equipped_count:",
        "skipped_equipped_counts[id] = skipped_count + 1",
        "func _equipped_bone_counts() -> Dictionary:",
        "counts[id] = int(counts.get(id, 0)) + 1",
    ]
    for fragment in required_inventory_fragments:
        if fragment not in inventory_ui:
            errors.append(f"missing inventory UI contract fragment: {fragment}")

    required_tile_fragments = [
        "Inventory tiles represent carried copies.",
        "duplicate items can stay stackable",
        "_label.text = BoneRulesService.display_name_with_slot(bone_id)",
    ]
    for fragment in required_tile_fragments:
        if fragment not in item_tile:
            errors.append(f"missing item tile contract fragment: {fragment}")

    return errors


def run_cases() -> list[str]:
    errors: list[str] = []
    for case in CASES:
        actual = visible_inventory_copies(case.inventory, case.equipped)
        if actual != case.expected_visible:
            errors.append(f"{case.name}: expected {case.expected_visible}, got {actual}")
            continue
        print(f"  [PASS] {case.name}: visible={actual}, counts={count_visible(actual)}")
    return errors


def main() -> int:
    inventory_ui = read(INVENTORY_UI)
    item_tile = read(ITEM_TILE)

    print("Inventory stack contract validation")
    print("-----------------------------------")

    static_errors = check_static_contract(inventory_ui, item_tile)
    if static_errors:
        for error in static_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Runtime UI still filters equipped copies by count.")
        print("  [PASS] Item tiles still represent carried copies without worn labels.")

    case_errors = run_cases()

    print("-----------------------------------")
    errors = static_errors + case_errors
    if errors:
        print(f"Result: FAIL ({len(errors)} error(s)).")
        return 1
    print("Result: OK (duplicate/stack contract intact; visual xN not implemented here).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
