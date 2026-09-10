#!/usr/bin/env python3
"""Read-only contract checks for the inventory 3D preview."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Check:
    name: str
    snippet: str
    scope: str | None = None


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warning(self, message: str) -> None:
        self.warnings.append(message)


SCRIPT_CHECKS = [
    Check("preview container variable", "var inventory_preview_container: SubViewportContainer = null"),
    Check("preview viewport variable", "var inventory_preview_viewport: SubViewport = null"),
    Check("preview rig variable", "var inventory_preview_rig: ModularSkeletonRig = null"),
    Check("preview root variable", "var inventory_preview_root: Node3D = null"),
    Check("inventory changed event connected", "GameEvents.inventory_changed.connect(_on_inventory_changed)", "setup"),
    Check("bone equipped event connected", "GameEvents.bone_equipped.connect(_on_bone_equipped)", "setup"),
    Check("bone unequipped event connected", "GameEvents.bone_unequipped.connect(_on_bone_unequipped)", "setup"),
    Check("open inventory syncs preview", "sync_preview()", "set_open"),
    Check("equipment notification syncs preview", "sync_preview()", "notify_equipment_changed"),
    Check("preview uses SubViewportContainer", "SubViewportContainer.new()", "_build_character_preview_panel"),
    Check("preview container is named", 'inventory_preview_container.name = "CharacterPreview"', "_build_character_preview_panel"),
    Check("preview container stretches", "inventory_preview_container.stretch = true", "_build_character_preview_panel"),
    Check("preview ignores mouse", "inventory_preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE", "_build_character_preview_panel"),
    Check("preview uses SubViewport", "SubViewport.new()", "_build_character_preview_panel"),
    Check("preview has fixed base size", "inventory_preview_viewport.size = Vector2i(210, 276)", "_build_character_preview_panel"),
    Check("preview uses isolated World3D", "inventory_preview_viewport.world_3d = World3D.new()", "_build_character_preview_panel"),
    Check("preview renders when visible", "SubViewport.UPDATE_WHEN_VISIBLE", "_build_character_preview_panel"),
    Check("preview scene is inside viewport", "inventory_preview_viewport.add_child(preview_scene)", "_build_character_preview_panel"),
    Check("preview room is built", "_build_preview_room(preview_scene)", "_build_character_preview_panel"),
    Check("preview light exists", 'light.name = "PreviewLight"', "_build_character_preview_panel"),
    Check("preview fill light exists", 'fill_light.name = "PreviewFillLight"', "_build_character_preview_panel"),
    Check("preview rig holder exists", 'rig_holder.name = "PreviewRigHolder"', "_build_character_preview_panel"),
    Check("preview rig is modular rig", "inventory_preview_rig = ModularSkeletonRig.new()", "_build_character_preview_panel"),
    Check("preview rig has progression enabled", "inventory_preview_rig.set_body_progression_enabled(true)", "_build_character_preview_panel"),
    Check("preview camera exists", "Camera3D.new()", "_build_character_preview_panel"),
    Check("preview camera is current", "camera.current = true", "_build_character_preview_panel"),
    Check("preview defers initial sync", 'call_deferred("sync_preview")', "_build_character_preview_panel"),
    Check("preview room root named", 'room_root.name = "PreviewRoom"', "_build_preview_room"),
    Check("preview floor exists", '"PreviewFloor"', "_build_preview_room"),
    Check("preview back wall exists", '"PreviewBackWall"', "_build_preview_room"),
    Check("preview left wall exists", '"PreviewLeftWall"', "_build_preview_room"),
    Check("preview right wall exists", '"PreviewRightWall"', "_build_preview_room"),
    Check("sync guards rig validity", "is_instance_valid(inventory_preview_rig)", "sync_preview"),
    Check("sync clears previous slots", "inventory_preview_rig.unequip_slot(str(slot_id))", "sync_preview"),
    Check("sync reads bone definitions through service", "BoneRulesService.definition_for(bone_id)", "sync_preview"),
    Check("sync equips preview rig", "inventory_preview_rig.equip_bone(bone_id, bone_def)", "sync_preview"),
    Check("paper doll contains preview panel", "doll.add_child(_build_character_preview_panel())", "_build_paper_doll"),
    Check("responsive layout resizes preview", "inventory_preview_container.size = Vector2(210.0, 276.0) * doll_scale", "_apply_paper_doll_responsive_layout"),
]

DOC_CHECKS = [
    Check("inventory doc mentions SubViewport", "SubViewport"),
    Check("inventory doc says preview is isolated", "aislado"),
    Check("inventory doc requires preview equip validation", "confirmar que el preview agrega"),
]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate the inventory preview architecture contract."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Project root. Defaults to the parent of tools/.",
    )
    args = parser.parse_args()

    root = args.root.resolve()
    script_path = root / "scripts" / "player_inventory_ui.gd"
    inventory_doc_path = root / "docs" / "inventory_flow.md"
    equipment_doc_path = root / "docs" / "equipment_flow.md"

    script_text = script_path.read_text(encoding="utf-8")
    inventory_doc_text = inventory_doc_path.read_text(encoding="utf-8")
    equipment_doc_text = equipment_doc_path.read_text(encoding="utf-8")

    report = Report()
    run_script_checks(script_text, report)
    run_doc_checks(inventory_doc_text, equipment_doc_text, report)
    print_report(report)
    return 1 if report.errors else 0


def run_script_checks(script_text: str, report: Report) -> None:
    for check in SCRIPT_CHECKS:
        haystack = script_text
        if check.scope is not None:
            haystack = extract_function(script_text, check.scope, report)
        if check.snippet not in haystack:
            location = f" in {check.scope}()" if check.scope is not None else ""
            report.error(f"{check.name}{location}: missing `{check.snippet}`")

    preview_function = extract_function(script_text, "_build_character_preview_panel", report)
    if preview_function.count("World3D.new()") != 1:
        report.error("preview should create exactly one isolated World3D")
    if preview_function.count("SubViewport.new()") != 1:
        report.error("preview should create exactly one SubViewport")
    if preview_function.count("Camera3D.new()") != 1:
        report.error("preview should create exactly one preview camera")

    if "inventory_preview_viewport.world_3d = get_viewport().world_3d" in script_text:
        report.error("preview must not reuse the playable viewport world")
    if "inventory_preview_rig = player" in script_text:
        report.error("preview must not reference the live player rig as its rig")


def run_doc_checks(inventory_doc_text: str, equipment_doc_text: str, report: Report) -> None:
    for check in DOC_CHECKS:
        if check.snippet not in inventory_doc_text:
            report.warning(f"{check.name}: docs/inventory_flow.md missing `{check.snippet}`")
    if "Confirmar que el preview cambia igual que el jugador." not in equipment_doc_text:
        report.warning("docs/equipment_flow.md should keep manual preview validation steps")


def extract_function(script_text: str, function_name: str, report: Report) -> str:
    match = re.search(
        rf"^func {re.escape(function_name)}\([^)]*\).*:$",
        script_text,
        re.MULTILINE,
    )
    if not match:
        report.error(f"missing function `{function_name}`")
        return ""

    start = match.start()
    next_match = re.search(r"^func \w+", script_text[match.end() :], re.MULTILINE)
    if next_match is None:
        return script_text[start:]
    return script_text[start : match.end() + next_match.start()]


def print_report(report: Report) -> None:
    print("Inventory preview contract validation")
    print(f"- checks: {len(SCRIPT_CHECKS) + len(DOC_CHECKS) + 4}")

    if report.warnings:
        print("\nWarnings:")
        for warning in report.warnings:
            print(f"- {warning}")

    if report.errors:
        print("\nErrors:")
        for error in report.errors:
            print(f"- {error}")
        print(f"\nFAILED: {len(report.errors)} error(s), {len(report.warnings)} warning(s)")
        return

    print(f"\nOK: 0 errors, {len(report.warnings)} warning(s)")


if __name__ == "__main__":
    sys.exit(main())
