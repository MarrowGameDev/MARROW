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
SLOT_WIDGET = ROOT / "scripts" / "ui_bone_slot.gd"
EQUIPMENT_RULES = ROOT / "scripts" / "equipment_rules_service.gd"
EQUIPMENT_COMPONENT = ROOT / "scripts" / "player_equipment_component.gd"

CANONICAL_SLOTS = ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]


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
        # The card shows the abbreviated name so it cannot be cut off mid-word;
        # the full display_name_with_slot has to stay reachable on the tile via
        # the tooltip, which is what these two fragments together guarantee.
        "_label.text = BoneRulesService.short_display_name(bone_id)",
        "tooltip_text = BoneRulesService.display_name_with_slot(bone_id)",
    ]
    for fragment in required_tile_fragments:
        if fragment not in item_tile:
            errors.append(f"missing item tile contract fragment: {fragment}")

    return errors


def check_body_slot_contract(
    inventory_ui: str,
    slot_widget: str,
    equipment_rules: str,
) -> list[str]:
    errors: list[str] = []
    for slot in CANONICAL_SLOTS:
        if f'"{slot}"' not in equipment_rules:
            errors.append(f"missing canonical slot in EquipmentRulesService: {slot}")
        if f'"{slot}"' not in inventory_ui:
            errors.append(f"missing canonical slot in PlayerInventoryUI: {slot}")

    required_fragments = [
        "EquipmentRulesService.inventory_filter_matches_bone",
        "EquipmentRulesService.compare_bones_for_inventory",
        "static func compatible_slots_for_bone(bone_id: String) -> Array[String]:",
        "EquipmentRulesService.can_equip_bone_in_slot",
        "player.equip_bone_in_slot",
    ]
    for fragment in required_fragments:
        haystack = inventory_ui + "\n" + slot_widget + "\n" + equipment_rules
        if fragment not in haystack:
            errors.append(f"missing inventory equipment contract fragment: {fragment}")

    if '"body": "torso"' not in equipment_rules:
        errors.append("legacy body alias must normalize to torso")
    if '"legs": "right_leg"' not in equipment_rules:
        errors.append("legacy legs alias must normalize to right_leg (single-value display default only)")

    return errors


def check_bilateral_equip_contract(equipment_component: str) -> list[str]:
    """A bilateral bone (generic legs/right_arm data) is compatible with two
    slots. Without an explicit target_slot, resolving to a static "first"
    slot every time means a second bone of the same kind could never reach
    the other side (verified in Godot 4.7 headless: two generic leg_bone
    pieces equipped via equip-next both landed on right_leg before this
    fix). This only checks the fix's source markers are present -- it
    cannot drive the actual scene tree; see docs/inventory_flow.md for the
    real runtime verification steps and evidence."""
    errors: list[str] = []
    if "func _first_open_compatible_slot(bone_id: String) -> String:" not in equipment_component:
        errors.append("missing _first_open_compatible_slot helper for bilateral slot resolution")
    if "return _first_open_compatible_slot(bone_id)" not in equipment_component:
        errors.append("_slot_for_request must resolve unclaimed bilateral slots via _first_open_compatible_slot")
    if "str(equipped.get(slot, \"\")) == \"\"" not in equipment_component:
        errors.append("_first_open_compatible_slot must check actual equipped state, not just return the first compatible slot")
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
    slot_widget = read(SLOT_WIDGET)
    equipment_rules = read(EQUIPMENT_RULES)
    equipment_component = read(EQUIPMENT_COMPONENT)

    print("Inventory stack contract validation")
    print("-----------------------------------")

    static_errors = check_static_contract(inventory_ui, item_tile)
    if static_errors:
        for error in static_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Runtime UI still filters equipped copies by count.")
        print("  [PASS] Item tiles still represent carried copies without worn labels.")

    slot_errors = check_body_slot_contract(inventory_ui, slot_widget, equipment_rules)
    if slot_errors:
        for error in slot_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Inventory exposes six canonical body slots through shared rules.")
        print("  [PASS] Slot drops use shared compatibility instead of UI-local rules.")

    bilateral_errors = check_bilateral_equip_contract(equipment_component)
    if bilateral_errors:
        for error in bilateral_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Equip-next resolves bilateral bones (legs/arms) to an open slot, not always the same side.")

    case_errors = run_cases()

    print("-----------------------------------")
    errors = static_errors + slot_errors + bilateral_errors + case_errors
    if errors:
        print(f"Result: FAIL ({len(errors)} error(s)).")
        return 1
    print("Result: OK (duplicate/stack contract intact; visual xN not implemented here).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
