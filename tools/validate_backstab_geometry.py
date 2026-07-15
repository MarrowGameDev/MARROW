#!/usr/bin/env python3
"""Validate Marrow stealth-finish/backstab geometry cases.

This is intentionally read-only and engine-free. It mirrors the current
`Enemy._is_player_behind()` geometry so we can lock down the expected cases
before changing gameplay code or touching the enemy hotspot.
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
    enemy_path = root / "scripts" / "enemy.gd"
    threshold = parse_stealth_behind_dot(enemy_path)
    verify_enemy_formula_shape(enemy_path)

    results = [run_case(case, threshold) for case in build_cases()]
    failures = [result for result in results if result.actual != result.case.expected]

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

    if failures:
        print(f"\nFAILED: {len(failures)} backstab geometry case(s) changed")
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


def verify_enemy_formula_shape(enemy_path: Path) -> None:
    text = enemy_path.read_text(encoding="utf-8")
    required_snippets = [
        "func _is_player_behind(player: Node3D) -> bool:",
        "enemy_forward.normalized().dot(to_player.normalized()) <= -stealth_behind_dot",
        "func _facing_from_rotation() -> Vector3:",
        "Vector3(sin(rotation.y), 0.0, cos(rotation.y)).normalized()",
    ]
    missing = [snippet for snippet in required_snippets if snippet not in text]
    if missing:
        print("WARNING: Enemy backstab implementation shape changed:")
        for snippet in missing:
            print(f"- missing snippet: {snippet}")


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
