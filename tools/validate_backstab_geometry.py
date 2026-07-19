#!/usr/bin/env python3
"""Validate Marrow stealth-finish/backstab geometry cases.

This is intentionally read-only and engine-free. It mirrors the current
`BackstabRulesService.is_attacker_behind_target()` geometry so we can lock down
the expected cases before changing gameplay code further.
"""

from __future__ import annotations

import argparse
import math
import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Vec3:
    x: float
    y: float
    z: float

    def flat(self) -> Vec3:
        return Vec3(self.x, 0.0, self.z)

    def length(self) -> float:
        return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)

    def normalized(self) -> Vec3:
        length = self.length()
        if length <= 0.000001:
            return Vec3(0.0, 0.0, 0.0)
        return Vec3(self.x / length, self.y / length, self.z / length)

    def dot(self, other: Vec3) -> float:
        return self.x * other.x + self.y * other.y + self.z * other.z

    def __sub__(self, other: Vec3) -> Vec3:
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)


@dataclass(frozen=True)
class Case:
    name: str
    enemy_position: Vec3
    enemy_forward: Vec3
    player_position: Vec3
    expected: bool


@dataclass(frozen=True)
class CaseResult:
    case: Case
    dot: float | None
    actual: bool


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate expected stealth-finish geometry cases."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Project root. Defaults to the parent of tools/.",
    )
    args = parser.parse_args()

    root = args.root.resolve()
    player_path = root / "scripts" / "player.gd"
    enemy_path = root / "scripts" / "enemy.gd"
    service_path = root / "scripts" / "backstab_rules_service.gd"
    threshold = parse_stealth_behind_dot(enemy_path)
    shape_errors = verify_backstab_service_shape(service_path)
    shape_errors += verify_enemy_uses_backstab_service(enemy_path)
    shape_errors += verify_backstab_execution_contract(player_path, enemy_path)

    results = [run_case(case, threshold) for case in build_cases()]
    case_failures = [result for result in results if result.actual != result.case.expected]

    print("Backstab geometry validation")
    print(f"- threshold: {threshold:.2f}")
    print(f"- cases: {len(results)}")
    for result in results:
        status = "PASS" if result.actual == result.case.expected else "FAIL"
        dot_text = "n/a" if result.dot is None else f"{result.dot:.3f}"
        expected = "behind" if result.case.expected else "blocked"
        actual = "behind" if result.actual else "blocked"
        print(
            f"- {status}: {result.case.name}: dot={dot_text}, "
            f"expected={expected}, actual={actual}"
        )

    # These used to only print WARNING and never affect the exit code, so
    # the entire contract could be gutted (e.g. the double-damage guard, or
    # the freeze fix below) and this validator would still exit 0. They now
    # count as real failures.
    if shape_errors:
        print(f"\n- {len(shape_errors)} contract shape error(s):")
        for error in shape_errors:
            print(f"  [ERROR] {error}")

    if case_failures or shape_errors:
        print(f"\nFAILED: {len(case_failures)} geometry case(s), {len(shape_errors)} contract shape error(s)")
        return 1

    print("\nOK: all backstab geometry cases match the current expected rule")
    return 0


def parse_stealth_behind_dot(enemy_path: Path) -> float:
    text = enemy_path.read_text(encoding="utf-8")
    match = re.search(
        r"@export_range\([^)]*\)\s+var\s+stealth_behind_dot:\s*float\s*=\s*([0-9.]+)",
        text,
    )
    if not match:
        raise SystemExit("Could not find Enemy.stealth_behind_dot export")
    return float(match.group(1))


def verify_backstab_service_shape(service_path: Path) -> list[str]:
    text = service_path.read_text(encoding="utf-8")
    required_snippets = [
        "class_name BackstabRulesService",
        "static func is_attacker_behind_target(",
        "to_attacker.y = 0.0",
        "flat_forward.y = 0.0",
        "flat_forward.normalized().dot(to_attacker.normalized()) <= -behind_dot",
    ]
    return [f"BackstabRulesService missing: {s}" for s in required_snippets if s not in text]


def verify_enemy_uses_backstab_service(enemy_path: Path) -> list[str]:
    text = enemy_path.read_text(encoding="utf-8")
    required_snippets = [
        "func _is_player_behind(player: Node3D) -> bool:",
        "enemy_forward = _facing_from_rotation()",
        "BackstabRulesService.is_attacker_behind_target(",
        "stealth_behind_dot",
        # global_transform.basis.z, not rotation.y: _is_player_behind()
        # compares this against a GLOBAL player position, and rotation.y
        # is local to this node's parent. A rotated parent would silently
        # skew the behind-cone check with the old formula.
        "func _facing_from_rotation() -> Vector3:\n\treturn global_transform.basis.z.normalized()",
    ]
    errors = [f"Enemy missing: {s}" for s in required_snippets if s not in text]

    # The victim must not turn to face its attacker while a backstab is
    # anticipated or held -- that would give away the whole point of a
    # stealth kill from behind, and previously happened every frame.
    begin_fn = extract_gd_function(text, "_begin_stealth_execution")
    hold_fn = extract_gd_function(text, "_update_stealth_execution_hold")
    if "_turn_toward(" in begin_fn:
        errors.append("_begin_stealth_execution must not _turn_toward() the player")
    if "_turn_toward(" in hold_fn:
        errors.append("_update_stealth_execution_hold must not _turn_toward() the player")
    return errors


def verify_backstab_execution_contract(player_path: Path, enemy_path: Path) -> list[str]:
    player_text = player_path.read_text(encoding="utf-8")
    enemy_text = enemy_path.read_text(encoding="utf-8")

    player_required = [
        "backstab_execution_target",
        "backstab_execution_impact_timer",
        "backstab_execution_damage_applied",
        "func _update_backstab_execution(delta: float) -> void:",
        '"apply_stealth_finish_impact"',
        "func _is_backstab_executing() -> bool:",
        "not _is_backstab_executing()",
        # Freeze-fix contract: a plain bool tracks "in progress" because
        # GDScript compares a freed Object as equal to null, so checking
        # backstab_execution_target directly silently misreports "not
        # executing" once the target is queue_free()'d mid-execution,
        # skipping cleanup and leaving can_attack stuck false forever.
        "var backstab_execution_in_progress: bool = false",
        "return backstab_execution_in_progress",
        # Player-death/pause freeze fix: cancellation must run before the
        # early return that stops _update_backstab_execution from being
        # called again, not after (where it was unreachable).
        "if _is_backstab_executing():\n\t\t\t_cancel_backstab_execution()",
        # Impact synced to the animator's strike phase, not only a fixed
        # timer guessed to line up with the animation.
        "func _on_backstab_animator_impact() -> void:",
        "attack_impact_reached.connect(_on_backstab_animator_impact)",
        # Distinct finisher pose, not the plain swing overlay.
        # The trigger now carries whether the finish will EXECUTE (instant kill)
    # or only deal ambush damage, so the animator can pick the arm-tear club
    # versus the quick finisher. Same contract: the player still triggers the
    # stealth-finish animation from this one place.
    "animator.trigger_stealth_finish_attack(lethal_finish)",
    ]
    enemy_required = [
        "stealth_execution_player",
        "stealth_execution_impact_applied",
        "func apply_stealth_finish_impact(",
        "if stealth_execution_impact_applied:",
        "func finish_stealth_execution(",
        "func cancel_stealth_execution(",
        "func _update_stealth_execution_hold() -> bool:",
    ]
    errors = [f"Player missing: {s}" for s in player_required if s not in player_text]
    errors += [f"Enemy missing: {s}" for s in enemy_required if s not in enemy_text]
    return errors


def extract_gd_function(text: str, function_name: str) -> str:
    match = re.search(rf"^func {re.escape(function_name)}\(.*?:\n((?:\t.*\n?)*)", text, re.MULTILINE)
    return match.group(1) if match else ""


def build_cases() -> list[Case]:
    origin = Vec3(0.0, 0.0, 0.0)
    yaw_0_forward = facing_from_rotation(0.0)
    yaw_90_forward = facing_from_rotation(math.radians(90.0))
    yaw_neg_90_forward = facing_from_rotation(math.radians(-90.0))
    yaw_180_forward = facing_from_rotation(math.radians(180.0))

    return [
        Case(
            "yaw 0: front is blocked",
            origin,
            yaw_0_forward,
            Vec3(0.0, 0.0, 1.0),
            False,
        ),
        Case(
            "yaw 0: behind is valid",
            origin,
            yaw_0_forward,
            Vec3(0.0, 0.0, -1.0),
            True,
        ),
        Case(
            "yaw 0: left side is blocked",
            origin,
            yaw_0_forward,
            Vec3(-1.0, 0.0, 0.0),
            False,
        ),
        Case(
            "yaw 0: right side is blocked",
            origin,
            yaw_0_forward,
            Vec3(1.0, 0.0, 0.0),
            False,
        ),
        Case(
            "yaw 90: rotated front is blocked",
            origin,
            yaw_90_forward,
            Vec3(1.0, 0.0, 0.0),
            False,
        ),
        Case(
            "yaw 90: rotated behind is valid",
            origin,
            yaw_90_forward,
            Vec3(-1.0, 0.0, 0.0),
            True,
        ),
        Case(
            "yaw -90: rotated front is blocked",
            origin,
            yaw_neg_90_forward,
            Vec3(-1.0, 0.0, 0.0),
            False,
        ),
        Case(
            "yaw -90: rotated behind is valid",
            origin,
            yaw_neg_90_forward,
            Vec3(1.0, 0.0, 0.0),
            True,
        ),
        Case(
            "yaw 180: rotated behind is valid",
            origin,
            yaw_180_forward,
            Vec3(0.0, 0.0, 1.0),
            True,
        ),
        Case(
            "behind cone: shallow rear angle is valid",
            origin,
            yaw_0_forward,
            Vec3(1.0, 0.0, -1.0),
            True,
        ),
        Case(
            "behind cone: side-biased angle is blocked",
            origin,
            yaw_0_forward,
            Vec3(2.0, 0.0, -0.8),
            False,
        ),
        Case("stacked positions are blocked", origin, yaw_0_forward, origin, False),
        Case(
            "vertical offset is ignored for behind",
            origin,
            yaw_0_forward,
            Vec3(0.0, 2.5, -1.0),
            True,
        ),
    ]


def facing_from_rotation(yaw_radians: float) -> Vec3:
    return Vec3(math.sin(yaw_radians), 0.0, math.cos(yaw_radians)).normalized()


def run_case(case: Case, threshold: float) -> CaseResult:
    to_player = (case.player_position - case.enemy_position).flat()
    if to_player.length() <= 0.01:
        return CaseResult(case, None, False)

    enemy_forward = case.enemy_forward.flat()
    if enemy_forward.length() <= 0.01:
        return CaseResult(case, None, False)

    dot = enemy_forward.normalized().dot(to_player.normalized())
    return CaseResult(case, dot, dot <= -threshold)


if __name__ == "__main__":
    sys.exit(main())
