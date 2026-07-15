#!/usr/bin/env python3
"""Static diagnostics for player/camera/rig update-order jitter risks.

This script is intentionally read-only. It does not prove the runtime cause of
jitter; it records whether the current code still matches the expected update
contract and highlights spots that need manual isolation in Godot.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
PLAYER = ROOT / "scripts" / "player.gd"
CAMERA = ROOT / "scripts" / "player_camera_controller.gd"
ANIMATOR = ROOT / "scripts" / "rig" / "procedural_player_animator.gd"


@dataclass
class Finding:
    level: str
    message: str


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"ERROR: missing required file: {path.relative_to(ROOT)}")


def line_number(text: str, needle: str) -> int:
    index = text.find(needle)
    if index < 0:
        return 0
    return text[:index].count("\n") + 1


def function_body(text: str, name: str) -> str:
    pattern = re.compile(rf"^func {re.escape(name)}\b.*?(?=^func |\Z)", re.M | re.S)
    match = pattern.search(text)
    return match.group(0) if match else ""


def add_contains(
    findings: list[Finding],
    text: str,
    needle: str,
    ok_message: str,
    error_message: str,
) -> None:
    findings.append(Finding("PASS" if needle in text else "ERROR", ok_message if needle in text else error_message))


def check_player(player_text: str) -> list[Finding]:
    findings: list[Finding] = []
    physics = function_body(player_text, "_physics_process")
    procedural = function_body(player_text, "_update_procedural_animation")
    camera_offset = function_body(player_text, "_update_camera_animation_follow_offset")

    add_contains(
        findings,
        physics,
        "move_and_slide()",
        "Player movement/collision is driven from _physics_process with move_and_slide().",
        "Player._physics_process must keep move_and_slide() as the movement authority.",
    )
    add_contains(
        findings,
        procedural,
        "animator.update_from_player(delta, velocity, max_speed, last_facing_direction, rig.get_equipped_bone_defs())",
        "Player feeds resolved velocity and equipped bone defs into ProceduralPlayerAnimator.",
        "Player._update_procedural_animation no longer calls animator.update_from_player with the expected contract.",
    )
    add_contains(
        findings,
        camera_offset,
        "set_animation_follow_offset",
        "Player sends animation follow offsets through PlayerCameraController.",
        "Player no longer routes animation follow offsets through PlayerCameraController.",
    )

    if physics and procedural:
        move_index = physics.find("move_and_slide()")
        anim_index = physics.find("_update_procedural_animation")
        if move_index >= 0 and anim_index > move_index:
            findings.append(Finding("PASS", "Procedural animation runs after move_and_slide() in the same physics tick."))
        else:
            findings.append(Finding("ERROR", "Procedural animation should run after move_and_slide() so it reads resolved velocity."))

    if procedural and camera_offset:
        anim_index = procedural.find("animator.update_from_player")
        offset_index = procedural.find("_update_camera_animation_follow_offset")
        if anim_index >= 0 and offset_index > anim_index:
            findings.append(Finding("PASS", "Camera animation offset is refreshed after animator.update_from_player()."))
        else:
            findings.append(Finding("ERROR", "Camera animation offset should refresh after animator.update_from_player()."))

    direct_position_writes = []
    for line_no, line in enumerate(player_text.splitlines(), start=1):
        stripped = line.strip()
        if stripped.startswith("global_position +=") or stripped.startswith("global_position ="):
            direct_position_writes.append(f"line {line_no}: {stripped}")

    if direct_position_writes:
        findings.append(
            Finding(
                "WARN",
                "Player has direct global_position writes to isolate during jitter repro: "
                + "; ".join(direct_position_writes),
            )
        )
    else:
        findings.append(Finding("PASS", "No direct Player global_position writes were found."))

    return findings


def check_camera(camera_text: str) -> list[Finding]:
    findings: list[Finding] = []
    ready = function_body(camera_text, "_ready")
    physics = function_body(camera_text, "_physics_process")
    process = function_body(camera_text, "_process")

    add_contains(
        findings,
        ready,
        "top_level = true",
        "Camera pivot is top_level, so follow is explicitly world-space.",
        "PlayerCameraController should declare its top_level behavior explicitly.",
    )
    add_contains(
        findings,
        physics,
        "global_position = global_position.lerp(_target_pivot_position(), follow_alpha)",
        "Camera follow smoothing runs in _physics_process with Player movement.",
        "Camera follow smoothing should run in _physics_process with Player movement.",
    )
    add_contains(
        findings,
        physics,
        "animation_follow_offset = animation_follow_offset.lerp(target_animation_follow_offset, animation_alpha)",
        "Animation follow offset is smoothed before pivot follow in physics.",
        "Animation follow offset smoothing should run before camera follow in _physics_process.",
    )
    if process and "global_position = global_position.lerp(_target_pivot_position(), follow_alpha)" in process:
        findings.append(Finding("ERROR", "Camera follow smoothing must not also run in _process."))
    else:
        findings.append(Finding("PASS", "Camera follow smoothing is not duplicated in _process."))
    add_contains(
        findings,
        camera_text,
        "target.global_position + Vector3.UP * pivot_height + animation_follow_offset",
        "Camera target position combines player global position, pivot height, and animation offset.",
        "Camera target pivot no longer combines player global position with animation offset as expected.",
    )

    return findings


def check_animator(animator_text: str) -> list[Finding]:
    findings: list[Finding] = []
    update = function_body(animator_text, "update_from_player")

    add_contains(
        findings,
        update,
        "_time += delta",
        "Procedural animator advances from the delta passed by Player.",
        "Procedural animator update_from_player no longer advances from Player-provided delta.",
    )
    add_contains(
        findings,
        update,
        "var horizontal := Vector3(velocity.x, 0.0, velocity.z)",
        "Procedural animator derives movement from horizontal resolved velocity.",
        "Procedural animator no longer derives movement from horizontal resolved velocity.",
    )
    add_contains(
        findings,
        update,
        "_apply_attack_overlay()",
        "Attack overlay participates in the same update_from_player frame.",
        "Attack overlay was not found in update_from_player.",
    )

    if "Tween.TWEEN_PROCESS_PHYSICS" in animator_text:
        findings.append(Finding("PASS", "Animator demo tween uses physics process mode when it is active."))
    elif "create_tween()" in animator_text:
        findings.append(Finding("WARN", "Animator creates a tween but no Tween.TWEEN_PROCESS_PHYSICS guard was found."))

    return findings


def print_group(title: str, findings: list[Finding]) -> int:
    errors = 0
    print(title)
    for finding in findings:
        print(f"  [{finding.level}] {finding.message}")
        if finding.level == "ERROR":
            errors += 1
    return errors


def main() -> int:
    player_text = read(PLAYER)
    camera_text = read(CAMERA)
    animator_text = read(ANIMATOR)

    errors = 0
    print("Jitter update contract diagnostics")
    print("----------------------------------")
    errors += print_group("Player", check_player(player_text))
    errors += print_group("Camera", check_camera(camera_text))
    errors += print_group("ProceduralPlayerAnimator", check_animator(animator_text))

    print("----------------------------------")
    if errors:
        print(f"Result: FAIL ({errors} contract error(s)).")
        return 1
    print("Result: OK (static contract intact; runtime jitter cause still unproven).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
