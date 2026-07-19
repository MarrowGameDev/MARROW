#!/usr/bin/env python3
"""Validate bone quality and weight stat formulas.

This is a read-only static/simulated check. Godot remains the source of truth
for runtime behavior, but this catches accidental formula drift in the shared
rules service and the player stats component contract.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import math
import sys


ROOT = Path(__file__).resolve().parents[1]
BONE_RULES = ROOT / "scripts" / "bone_rules_service.gd"
PLAYER_STATS = ROOT / "scripts" / "player_stats_component.gd"

PERCENT_LIMIT = 0.75
FREE_WEIGHT = 3.0
PENALTY_PER_WEIGHT = 0.06
PENALTY_MAX = 0.30


@dataclass(frozen=True)
class Bone:
    move_speed_bonus: float
    attack_range_bonus: float
    attack_damage_bonus: int
    max_health_bonus: int
    quality_multiplier: float
    quality_damage_percent: float
    quality_speed_percent: float
    quality_health_percent: float
    quality_weight_percent: float
    equipment_weight: float
    inventory_weight: float


@dataclass(frozen=True)
class Case:
    name: str
    base_move_speed: float
    base_attack_range: float
    base_attack_damage: int
    base_max_health: int
    bones: list[Bone | None]
    expected: dict[str, float]


def godot_roundi(value: float) -> int:
    if value >= 0.0:
        return int(math.floor(value + 0.5))
    return int(math.ceil(value - 0.5))


def clamp(value: float, minimum: float, maximum: float) -> float:
    return max(minimum, min(maximum, value))


def calculate(case: Case) -> dict[str, float]:
    move_bonus = 0.0
    range_bonus = 0.0
    damage_bonus_float = 0.0
    health_bonus_float = 0.0
    damage_percent = 0.0
    speed_percent = 0.0
    health_percent = 0.0
    weight_percent = 0.0
    equipment_weight = 0.0
    inventory_weight = 0.0

    for bone in case.bones:
        if bone is None:
            continue
        move_bonus += bone.move_speed_bonus * bone.quality_multiplier
        range_bonus += bone.attack_range_bonus * bone.quality_multiplier
        # Sum as floats and round once after the loop (see
        # BoneRulesService.adjusted_player_bonus_for): rounding each bone's
        # bonus before summing would let per-bone fractions round up
        # independently and inflate the total as more pieces are equipped.
        damage_bonus_float += bone.attack_damage_bonus * bone.quality_multiplier
        health_bonus_float += bone.max_health_bonus * bone.quality_multiplier
        damage_percent += bone.quality_damage_percent
        speed_percent += bone.quality_speed_percent
        health_percent += bone.quality_health_percent
        weight_percent += bone.quality_weight_percent

        weight_multiplier = max(0.0, 1.0 + bone.quality_weight_percent)
        equipment_weight += bone.equipment_weight * weight_multiplier
        inventory_weight += bone.inventory_weight * weight_multiplier

    damage_percent = clamp(damage_percent, -PERCENT_LIMIT, PERCENT_LIMIT)
    speed_percent = clamp(speed_percent, -PERCENT_LIMIT, PERCENT_LIMIT)
    health_percent = clamp(health_percent, -PERCENT_LIMIT, PERCENT_LIMIT)
    weight_percent = clamp(weight_percent, -PERCENT_LIMIT, PERCENT_LIMIT)

    load_over_free = max(0.0, equipment_weight - FREE_WEIGHT)
    load_speed_penalty = clamp(load_over_free * PENALTY_PER_WEIGHT, 0.0, PENALTY_MAX)

    # The summed bonus stays a float all the way through the percentage
    # modifiers (matching BoneRulesService.aggregate_player_bonuses_exact and
    # player_stats_with_equipment). Rounding here and then applying a
    # percentage would compound two approximations: a 5.5 bonus would round to
    # 6, and +10% would turn 7 into 7.7 -> 8, where the exact path gives
    # 6.5 * 1.1 = 7.15 -> 7. One rounding, at the end of each stat.
    move_before_percent = case.base_move_speed + move_bonus
    move_multiplier = max(0.1, (1.0 + speed_percent) * (1.0 - load_speed_penalty))
    damage_before_percent = float(case.base_attack_damage) + damage_bonus_float
    health_before_percent = float(case.base_max_health) + health_bonus_float

    return {
        "move_speed": max(0.0, move_before_percent * move_multiplier),
        "attack_range": case.base_attack_range + range_bonus,
        "attack_damage": max(0, godot_roundi(damage_before_percent * max(0.1, 1.0 + damage_percent))),
        "max_health": max(1, godot_roundi(health_before_percent * max(0.1, 1.0 + health_percent))),
        "equipment_weight": equipment_weight,
        "inventory_weight": inventory_weight,
        "load_speed_penalty": load_speed_penalty,
        "quality_damage_percent": damage_percent,
        "quality_speed_percent": speed_percent,
        "quality_health_percent": health_percent,
        "quality_weight_percent": weight_percent,
    }


CASES = [
    Case(
        name="no equipment and empty slots return base stats",
        base_move_speed=6.0,
        base_attack_range=2.0,
        base_attack_damage=1,
        base_max_health=1,
        bones=[None],
        expected={
            "move_speed": 6.0,
            "attack_range": 2.0,
            "attack_damage": 1,
            "max_health": 1,
            "equipment_weight": 0.0,
            "inventory_weight": 0.0,
            "load_speed_penalty": 0.0,
        },
    ),
    Case(
        name="quality multiplier and percent modifiers affect player stats",
        base_move_speed=6.0,
        base_attack_range=2.0,
        base_attack_damage=1,
        base_max_health=1,
        bones=[
            Bone(
                move_speed_bonus=-1.5,
                attack_range_bonus=0.4,
                attack_damage_bonus=2,
                max_health_bonus=2,
                quality_multiplier=1.15,
                quality_damage_percent=0.12,
                quality_speed_percent=-0.05,
                quality_health_percent=0.1,
                quality_weight_percent=0.15,
                equipment_weight=2.0,
                inventory_weight=2.2,
            )
        ],
        expected={
            "move_speed": 4.06125,
            "attack_range": 2.46,
            # Single rounding, at the end. The bone's bonus is 2 * 1.15 = 2.3;
            # keeping that decimal through the percentage gives
            # (1 + 2.3) * 1.12 = 3.696 -> 4 for damage and
            # (1 + 2.3) * 1.10 = 3.63  -> 4 for health.
            # These were 3 and 3 while the sum was rounded to 2 BEFORE the
            # percentage was applied, which dropped 0.3 of real bonus.
            "attack_damage": 4,
            "max_health": 4,
            "equipment_weight": 2.3,
            "inventory_weight": 2.53,
            "load_speed_penalty": 0.0,
            "quality_damage_percent": 0.12,
            "quality_speed_percent": -0.05,
            "quality_health_percent": 0.1,
            "quality_weight_percent": 0.15,
        },
    ),
    Case(
        name="equipment load applies capped movement penalty",
        base_move_speed=6.0,
        base_attack_range=2.0,
        base_attack_damage=1,
        base_max_health=1,
        bones=[
            Bone(0.0, 0.0, 1, 2, 1.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.0),
            Bone(-1.5, 0.4, 2, 2, 1.15, 0.12, -0.05, 0.1, 0.15, 2.0, 2.2),
        ],
        expected={
            "equipment_weight": 3.5,
            "load_speed_penalty": 0.03,
            "quality_speed_percent": -0.05,
        },
    ),
    Case(
        name="fractional per-bone bonuses round once after summing, not per bone",
        base_move_speed=5.0,
        base_attack_range=1.0,
        base_attack_damage=0,
        base_max_health=1,
        bones=[
            # Three bones each contribute +0.5 damage and +0.5 health
            # (1 * 0.5 quality_multiplier). Rounding each bone before
            # summing would give 1+1+1=3 damage and 1+1+1+base(1)=4
            # health; rounding the 1.5 sum once gives 2 and 3 instead.
            Bone(0.0, 0.0, 1, 1, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
            Bone(0.0, 0.0, 1, 1, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
            Bone(0.0, 0.0, 1, 1, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        ],
        expected={
            "move_speed": 5.0,
            "attack_range": 1.0,
            "attack_damage": 2,
            "max_health": 3,
            "load_speed_penalty": 0.0,
        },
    ),
]


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"ERROR: missing required file: {path.relative_to(ROOT)}")


def check_static_contract(bone_rules: str, player_stats: str) -> list[str]:
    errors: list[str] = []
    required_rules = [
        "const PLAYER_STAT_MODIFIER_DEFAULTS",
        "const EQUIPMENT_FREE_WEIGHT := 3.0",
        "const EQUIPMENT_LOAD_SPEED_PENALTY_PER_WEIGHT := 0.06",
        "static func adjusted_player_bonus_for",
        "quality_multiplier_for(bone_id)",
        "static func aggregate_player_stat_modifiers",
        "quality_damage_percent_for(bone_id)",
        "quality_speed_percent_for(bone_id)",
        "quality_health_percent_for(bone_id)",
        "quality_weight_percent_for(bone_id)",
        "equipment_weight_for(bone_id)",
        "inventory_weight_for(bone_id)",
        'if bone_id == "":',
        '"load_speed_penalty"',
        "static func player_stats_with_equipment",
    ]
    for fragment in required_rules:
        if fragment not in bone_rules:
            errors.append(f"missing BoneRulesService formula fragment: {fragment}")

    required_component_fragments = [
        '"equipment_weight": float(calculated_stats.get("equipment_weight", 0.0))',
        '"inventory_weight": float(calculated_stats.get("inventory_weight", 0.0))',
        '"load_speed_penalty": float(calculated_stats.get("load_speed_penalty", 0.0))',
        '"quality_damage_percent": float(calculated_stats.get("quality_damage_percent", 0.0))',
        '"quality_speed_percent": float(calculated_stats.get("quality_speed_percent", 0.0))',
        '"quality_health_percent": float(calculated_stats.get("quality_health_percent", 0.0))',
        '"quality_weight_percent": float(calculated_stats.get("quality_weight_percent", 0.0))',
    ]
    for fragment in required_component_fragments:
        if fragment not in player_stats:
            errors.append(f"missing PlayerStatsComponent output fragment: {fragment}")

    return errors


def check_cases() -> list[str]:
    errors: list[str] = []
    for case in CASES:
        case_errors: list[str] = []
        actual = calculate(case)
        for key, expected_value in case.expected.items():
            actual_value = actual[key]
            if isinstance(expected_value, float):
                if not math.isclose(actual_value, expected_value, rel_tol=0.0, abs_tol=0.00001):
                    case_errors.append(f"{case.name}: {key} expected {expected_value}, got {actual_value}")
            elif actual_value != expected_value:
                case_errors.append(f"{case.name}: {key} expected {expected_value}, got {actual_value}")
        if case_errors:
            errors.extend(case_errors)
        else:
            print(f"  [PASS] {case.name}")
    return errors


def main() -> int:
    bone_rules = read(BONE_RULES)
    player_stats = read(PLAYER_STATS)

    print("Bone stat formula validation")
    print("----------------------------")
    static_errors = check_static_contract(bone_rules, player_stats)
    if static_errors:
        for error in static_errors:
            print(f"  [ERROR] {error}")
    else:
        print("  [PASS] BoneRulesService centralizes quality and weight formulas.")
        print("  [PASS] PlayerStatsComponent preserves formula outputs.")

    case_errors = check_cases()
    # These were computed and then silently dropped, so a numeric mismatch
    # showed up only as a count with no indication of which case failed.
    for error in case_errors:
        print(f"  [ERROR] {error}")
    errors = static_errors + case_errors
    print("----------------------------")
    if errors:
        print(f"Result: FAIL ({len(errors)} error(s)).")
        return 1
    print("Result: OK (bone stat formulas intact).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
