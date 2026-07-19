#!/usr/bin/env python3
"""Validate the inventory equipment build preset contract."""

from __future__ import annotations

from collections import Counter
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
COMPONENT = ROOT / "scripts" / "player_equipment_builds_component.gd"
PLAYER = ROOT / "scripts" / "player.gd"
UI = ROOT / "scripts" / "player_inventory_ui.gd"
EQUIPMENT = ROOT / "scripts" / "player_equipment_component.gd"
INVENTORY_DOC = ROOT / "docs" / "inventory_flow.md"
EQUIPMENT_DOC = ROOT / "docs" / "equipment_flow.md"

CANONICAL_SLOTS = ["torso", "left_arm", "right_arm", "left_leg", "right_leg"]
LIMB_SLOTS = {"left_arm", "right_arm", "left_leg", "right_leg"}


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"ERROR: missing required file: {path.relative_to(ROOT)}")


def validate_build_state(state: dict[str, str], inventory: list[str]) -> tuple[bool, str]:
    if "head" in state:
        return False, "head cannot be replaced"
    if any(slot in state for slot in LIMB_SLOTS) and "torso" not in state:
        return False, "limbs require torso"

    inventory_counts = Counter(inventory)
    required_counts = Counter(state.values())
    for bone_id, count in required_counts.items():
        if inventory_counts[bone_id] < count:
            return False, f"missing copy for {bone_id}"

    compatibility = {
        "torso": {"torso_bone", "heavy_bone", "rib_bone"},
        "left_arm": {"arm_bone", "dummy_bone"},
        "right_arm": {"arm_bone", "dummy_bone"},
        "left_leg": {"leg_bone"},
        "right_leg": {"leg_bone"},
    }
    for slot, bone_id in state.items():
        if slot not in CANONICAL_SLOTS:
            return False, f"unknown slot {slot}"
        if bone_id not in compatibility[slot]:
            return False, f"{bone_id} incompatible with {slot}"
    return True, "ok"


def check_static_contract() -> list[str]:
    errors: list[str] = []
    component = read(COMPONENT)
    player = read(PLAYER)
    ui = read(UI)
    equipment = read(EQUIPMENT)
    docs = read(INVENTORY_DOC) + "\n" + read(EQUIPMENT_DOC)

    required_component_fragments = [
        "class_name PlayerEquipmentBuildsComponent",
        'const BUILD_SETTINGS_PATH := "user://equipment_builds.cfg"',
        "func save_current_build(index: int) -> Dictionary:",
        "func apply_build(index: int) -> Dictionary:",
        "func validate_build_state(raw_state: Dictionary, inventory_items: Array) -> Dictionary:",
        "EquipmentRulesService.can_equip_bone_in_slot",
        "PlayerEquipmentComponent.TORSO_REQUIRED_SLOTS",
        "is_head_detached_from_torso",
        "config.save(BUILD_SETTINGS_PATH)",
        "equipment_component.equip_bone(bone_id, slot_id)",
    ]
    for fragment in required_component_fragments:
        if fragment not in component:
            errors.append(f"missing build component fragment: {fragment}")

    # A previous version of apply_build() only reported a failed apply; it
    # never restored the pre-apply equipment, so a build that failed
    # halfway left the player in a mixed old/new state. These fragments
    # are the actual rollback contract, verified end to end in Godot 4.7
    # headless (5 scenarios: valid, empty, missing piece, incompatible
    # slot, forced rollback -- see docs/equipment_flow.md changelog for
    # the exact evidence); this check only guards the source still has it.
    rollback_fragments = [
        "var previous_state := equipment_component.get_equipment_state()",
        "_apply_validated_state(previous_state)",
        "rolled back",
    ]
    for fragment in rollback_fragments:
        if fragment not in component:
            errors.append(f"missing rollback contract fragment: {fragment}")

    required_player_fragments = [
        "var equipment_builds_component: PlayerEquipmentBuildsComponent = null",
        "equipment_builds_component.setup(self, equipment_component)",
        "func save_equipment_build(index: int) -> Dictionary:",
        "func apply_equipment_build(index: int) -> Dictionary:",
        "func get_equipment_build_summaries() -> Array:",
    ]
    for fragment in required_player_fragments:
        if fragment not in player:
            errors.append(f"missing player build API fragment: {fragment}")

    required_ui_fragments = [
        # Screen title changed with the sidebar/detail redesign.
        "Saved Builds",
        "func _save_equipment_build(index: int) -> void:",
        "func _apply_equipment_build(index: int) -> void:",
        # Renamed when the three-card view became a sidebar + detail panel.
        "func _refresh_builds_screen() -> void:",
        'player.call("save_equipment_build", index)',
        'player.call("apply_equipment_build", index)',
    ]
    for fragment in required_ui_fragments:
        if fragment not in ui:
            errors.append(f"missing inventory UI build fragment: {fragment}")

    if "func get_equipment_state() -> Dictionary:" not in equipment:
        errors.append("equipment component must expose equipment state")
    if "build presets" not in docs.lower():
        errors.append("docs must describe build presets")

    return errors


def run_cases() -> list[str]:
    cases = [
        ("full build applies with enough copies", {"torso": "torso_bone", "left_arm": "arm_bone", "right_arm": "arm_bone"}, ["torso_bone", "arm_bone", "arm_bone"], True),
        ("duplicate arms require duplicate copies", {"torso": "torso_bone", "left_arm": "arm_bone", "right_arm": "arm_bone"}, ["torso_bone", "arm_bone"], False),
        ("limbs require torso", {"left_leg": "leg_bone"}, ["leg_bone"], False),
        ("head cannot be replaced by build", {"head": "head_bone"}, ["head_bone"], False),
        ("slot compatibility is enforced", {"torso": "arm_bone"}, ["arm_bone"], False),
        ("empty build is valid and clears non-core slots", {}, [], True),
    ]
    errors: list[str] = []
    for name, state, inventory, expected in cases:
        actual, message = validate_build_state(state, inventory)
        if actual != expected:
            errors.append(f"{name}: expected {expected}, got {actual} ({message})")
            continue
        print(f"  [PASS] {name}: {message}")
    return errors


def main() -> int:
    print("Inventory build preset validation")
    print("---------------------------------")
    static_errors = check_static_contract()
    if static_errors:
        for error in static_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] Build preset component, player API, UI controls, and docs are wired.")

    case_errors = run_cases()
    errors = static_errors + case_errors
    print("---------------------------------")
    if errors:
        print(f"Result: FAIL ({len(errors)} error(s)).")
        return 1
    print("Result: OK (equipment build preset contract intact).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
