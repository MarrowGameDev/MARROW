#!/usr/bin/env python3
"""Validate the static contract for the P0 runtime validation suite."""

from __future__ import annotations

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "scripts" / "testing_environment.gd"
SCENE_PATH = ROOT / "scenes" / "testing_environment.tscn"

EXPECTED_GUIDES = [
    "Movement, camera, and jitter",
    "Inventory, equipment, and preview",
    "Pickups, drops, and enemy profiles",
    "Backstab runtime geometry",
    "Rig and body progression",
]


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    script = read_text(SCRIPT_PATH, errors)
    scene = read_text(SCENE_PATH, errors)
    if errors:
        print_report(errors, warnings)
        return 1

    require("const P0_VALIDATION_GUIDES", script, "testing environment declares P0 validation guides", errors)
    require("KEY_F1", script, "F1 cycles to the next P0 guide", errors)
    require("KEY_F2", script, "F2 cycles to the previous P0 guide", errors)
    require("_current_validation_guide_text", script, "guide text is rendered into the status panel", errors)
    require("res://scripts/testing_environment.gd", scene, "testing scene uses the validation suite script", errors)

    for title in EXPECTED_GUIDES:
        require(title, script, f"guide exists: {title}", errors)

    if "Record: scene, resolution, enabled systems" not in script:
        warnings.append("guide does not ask testers to record scene/resolution/enabled systems")

    print("P0 runtime validation suite")
    print(f"- guides expected: {len(EXPECTED_GUIDES)}")
    print(f"- script: {SCRIPT_PATH.relative_to(ROOT)}")
    print(f"- scene: {SCENE_PATH.relative_to(ROOT)}")
    print_report(errors, warnings)
    return 1 if errors else 0


def read_text(path: Path, errors: list[str]) -> str:
    if not path.exists():
        errors.append(f"missing required file: {path.relative_to(ROOT)}")
        return ""
    return path.read_text(encoding="utf-8")


def require(needle: str, haystack: str, label: str, errors: list[str]) -> None:
    if needle not in haystack:
        errors.append(label)


def print_report(errors: list[str], warnings: list[str]) -> None:
    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"- {warning}")
    if errors:
        print("\nErrors:")
        for error in errors:
            print(f"- {error}")
        print(f"\nFAILED: {len(errors)} error(s), {len(warnings)} warning(s)")
    else:
        print(f"\nOK: 0 errors, {len(warnings)} warning(s)")


if __name__ == "__main__":
    sys.exit(main())
