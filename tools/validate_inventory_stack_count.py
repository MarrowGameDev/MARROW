#!/usr/bin/env python3
"""Validate inventory visual stack-count behavior.

This is a static/simulated check for the UI contract: after equipped copies are
filtered out, equal visible bone ids collapse into one tile with a quantity.
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
    expected_groups: list[tuple[str, int]]


CASES = [
    Case(
        name="three copies collapse to one x3 tile",
        inventory=["arm_bone", "arm_bone", "arm_bone"],
        equipped={},
        expected_groups=[("arm_bone", 3)],
    ),
    Case(
        name="one equipped copy leaves one x2 tile",
        inventory=["arm_bone", "arm_bone", "arm_bone"],
        equipped={"right_arm": "arm_bone"},
        expected_groups=[("arm_bone", 2)],
    ),
    Case(
        name="canonical body-slot order overrides pickup order",
        inventory=["leg_bone", "arm_bone", "leg_bone"],
        equipped={},
        expected_groups=[("arm_bone", 1), ("leg_bone", 2)],
    ),
    Case(
        name="all equipped copies hide the stack",
        inventory=["arm_bone", "arm_bone"],
        equipped={"right_arm": "arm_bone", "left_arm": "arm_bone"},
        expected_groups=[],
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


def visible_stack_groups(inventory: list[str], equipment_state: dict[str, str]) -> list[tuple[str, int]]:
    equipped_counts = equipped_bone_counts(equipment_state)
    skipped_equipped_counts: dict[str, int] = {}
    visible_counts: dict[str, int] = {}
    visible_order: list[str] = []

    for bone_id in inventory:
        equipped_count = equipped_counts.get(bone_id, 0)
        skipped_count = skipped_equipped_counts.get(bone_id, 0)
        if skipped_count < equipped_count:
            skipped_equipped_counts[bone_id] = skipped_count + 1
            continue
        if bone_id not in visible_counts:
            visible_order.append(bone_id)
            visible_counts[bone_id] = 0
        visible_counts[bone_id] += 1

    visible_order.sort(key=inventory_sort_key)
    return [(bone_id, visible_counts[bone_id]) for bone_id in visible_order]


def inventory_sort_key(bone_id: str) -> tuple[int, str]:
    slots = {
        "head_bone": 0,
        "rib_bone": 1,
        "body_bone": 1,
        "arm_bone": 3,
        "dummy_bone": 3,
        "leg_bone": 5,
    }
    return (slots.get(bone_id, 99), bone_id)


def check_static_contract(inventory_ui: str, item_tile: str) -> list[str]:
    errors: list[str] = []
    required_inventory_fragments = [
        "var visible_counts: Dictionary = {}",
        "var visible_order: Array[String] = []",
        "visible_order.append(id)",
        'visible_order.sort_custom(Callable(self, "_compare_inventory_items"))',
        "visible_counts[id] = int(visible_counts[id]) + 1",
        "tile.setup(id, self, int(visible_counts.get(id, 1)))",
    ]
    for fragment in required_inventory_fragments:
        if fragment not in inventory_ui:
            errors.append(f"missing inventory UI stack fragment: {fragment}")

    required_tile_fragments = [
        "var stack_count: int = 1",
        "func setup(id: String, player_ref: Node, quantity: int = 1) -> void:",
        "stack_count = maxi(1, quantity)",
        # The count text is now unconditional and the CHIP carries the
        # visibility, so a single-copy tile shows no badge at all rather than
        # an empty label. Both halves are pinned so neither can drift away.
        '_stack_label.text = "x" + str(stack_count)',
        "_stack_badge.visible = stack_count > 1",
        'return {"bone_id": bone_id, "source": "item"}',
    ]
    for fragment in required_tile_fragments:
        if fragment not in item_tile:
            errors.append(f"missing item tile stack fragment: {fragment}")

    return errors


def run_cases() -> list[str]:
    errors: list[str] = []
    for case in CASES:
        actual = visible_stack_groups(case.inventory, case.equipped)
        if actual != case.expected_groups:
            errors.append(f"{case.name}: expected {case.expected_groups}, got {actual}")
            continue
        print(f"  [PASS] {case.name}: groups={actual}")
    return errors


def main() -> int:
    inventory_ui = read(INVENTORY_UI)
    item_tile = read(ITEM_TILE)

    print("Inventory stack count validation")
    print("--------------------------------")

    static_errors = check_static_contract(inventory_ui, item_tile)
    if static_errors:
        for error in static_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Runtime UI groups visible duplicates before creating tiles.")
        print("  [PASS] BoneItemTile exposes xN without changing drag payload.")

    case_errors = run_cases()

    print("--------------------------------")
    errors = static_errors + case_errors
    if errors:
        print(f"Result: FAIL ({len(errors)} error(s)).")
        return 1
    print("Result: OK (visual stack-count contract intact).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
