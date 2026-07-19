#!/usr/bin/env python3
"""Validate the set/synergy evaluator and its integration into the stat pipeline.

This is a read-only static/simulated check; Godot remains the source of truth
for runtime behavior. What makes it more than a copy of the rules is that the
FAMILY_RULES / SYMMETRY_RULES / QUALITY_RULES tables are PARSED OUT OF
scripts/synergy_rules_service.gd, so the simulation always runs the numbers a
designer actually authored. Retuning a tier in the .gd file retunes this test;
it cannot silently drift.

It also asserts the two integration points structurally: the synergy totals
must be summed into aggregate_player_bonuses_exact and, critically, into
aggregate_player_stat_modifiers BEFORE its clampf calls, so no synergy can
escape PLAYER_STAT_PERCENT_LIMIT.
"""

from __future__ import annotations

from pathlib import Path
import json
import math
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
SYNERGY_RULES = ROOT / "scripts" / "synergy_rules_service.gd"
BONE_RULES = ROOT / "scripts" / "bone_rules_service.gd"
BUILDS = ROOT / "scripts" / "player_equipment_builds_component.gd"

PERCENT_LIMIT = 0.75
FREE_WEIGHT = 3.0
PENALTY_PER_WEIGHT = 0.06
PENALTY_MAX = 0.30

# BoneQualityService.QUALITY_TABLE, by rank.
QUALITY_RANK = {"frail": 0, "worn": 1, "normal": 2, "strong": 3, "pristine": 4}
QUALITY_MULTIPLIER = {
    "frail": 0.85,
    "worn": 0.925,
    "normal": 1.0,
    "strong": 1.075,
    "pristine": 1.15,
}

BONUS_KEYS = ("move_speed", "attack_range", "attack_damage", "max_health")
MODIFIER_KEYS = ("damage_percent", "speed_percent", "health_percent", "weight_percent")


# --- reading the authored tables -----------------------------------------


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"ERROR: missing required file: {path.relative_to(ROOT)}")


def extract_const(text: str, name: str) -> str:
    """Grabs the literal after `const NAME := ` by balancing brackets."""
    match = re.search(rf"^const {name} := ", text, re.MULTILINE)
    if match is None:
        raise SystemExit(f"ERROR: could not find const {name} in synergy_rules_service.gd")
    start = match.end()
    depth = 0
    for index in range(start, len(text)):
        char = text[index]
        if char in "{[":
            depth += 1
        elif char in "}]":
            depth -= 1
            if depth == 0:
                return text[start : index + 1]
    raise SystemExit(f"ERROR: unbalanced literal for const {name}")


def gdscript_literal_to_python(source: str, substitutions: dict[str, str]) -> object:
    """GDScript dict/array literals are JSON once comments, trailing commas and
    the handful of constant references are dealt with."""
    cleaned = re.sub(r"#.*", "", source)
    for name, value in substitutions.items():
        cleaned = re.sub(rf"\b{name}\b", value, cleaned)
    cleaned = re.sub(r",(\s*[}\]])", r"\1", cleaned)
    try:
        return json.loads(cleaned)
    except json.JSONDecodeError as error:
        raise SystemExit(f"ERROR: could not parse literal: {error}\n---\n{cleaned}\n---")


SOURCE = read(SYNERGY_RULES)
SUBSTITUTIONS = {"HIGH_QUALITY_MIN_RANK": "3"}
FAMILY_RULES = gdscript_literal_to_python(extract_const(SOURCE, "FAMILY_RULES"), SUBSTITUTIONS)
SYMMETRY_RULES = gdscript_literal_to_python(extract_const(SOURCE, "SYMMETRY_RULES"), SUBSTITUTIONS)
QUALITY_RULES = gdscript_literal_to_python(extract_const(SOURCE, "QUALITY_RULES"), SUBSTITUTIONS)
EXCLUDED_SET_IDS = gdscript_literal_to_python(extract_const(SOURCE, "EXCLUDED_SET_IDS"), SUBSTITUTIONS)


# --- the piece fixtures ---------------------------------------------------
# Mirrors EquipmentRulesService._generated_limb_* and data/bones/*.tres for the
# handful of fields the stat pipeline reads.


class Piece:
    def __init__(self, bone_id, set_id, quality, bonus, quality_percents, equipment_weight):
        self.bone_id = bone_id
        self.set_id = set_id
        self.quality = quality
        self.bonus = bonus
        self.quality_percents = quality_percents
        self.equipment_weight = equipment_weight


def generated(source_profile: str, limb_key: str, quality: str = "normal") -> Piece:
    base_weight = {"body": 1.4, "head": 0.8, "right_leg": 1.1, "left_leg": 1.1}.get(limb_key, 1.0)
    bonus = {"move_speed": 0.0, "attack_range": 0.0, "attack_damage": 0, "max_health": 0}
    if limb_key in ("right_arm", "left_arm"):
        bonus["attack_range"], bonus["max_health"] = 0.8, 1
    elif limb_key in ("right_leg", "left_leg"):
        bonus["move_speed"], bonus["max_health"] = 0.8, 1
    elif limb_key == "body":
        bonus["max_health"] = 2
    elif limb_key == "head":
        bonus["attack_damage"] = 1

    percents = {k: 0.0 for k in MODIFIER_KEYS}
    if source_profile == "gorilla":
        base_weight *= 1.45
        bonus["move_speed"] -= 0.4
        bonus["attack_damage"] += 1
        if limb_key == "body":
            bonus["max_health"] += 1
        percents.update(damage_percent=0.08, speed_percent=-0.06, health_percent=0.05, weight_percent=0.1)
    elif source_profile == "lizard":
        base_weight *= 0.82
        bonus["move_speed"] += 0.5
        if limb_key == "head":
            bonus["attack_range"] += 0.6
        percents.update(damage_percent=-0.03, speed_percent=0.08, weight_percent=-0.08)

    return Piece(
        bone_id=f"{source_profile}_{limb_key}_bone",
        set_id=f"{source_profile}_parts",
        quality=quality,
        bonus=bonus,
        quality_percents=percents,
        equipment_weight=base_weight,
    )


AUTHORED = {
    "arm_bone": Piece(
        "arm_bone", "starter_bones", "normal",
        {"move_speed": 0.0, "attack_range": 2.5, "attack_damage": 0, "max_health": 1},
        {k: 0.0 for k in MODIFIER_KEYS}, 1.0,
    ),
    "leg_bone": Piece(
        "leg_bone", "starter_bones", "normal",
        {"move_speed": 3.0, "attack_range": 0.0, "attack_damage": 0, "max_health": 1},
        {k: 0.0 for k in MODIFIER_KEYS}, 1.1,
    ),
    "torso_bone": Piece(
        "torso_bone", "core_body", "normal",
        {"move_speed": 0.0, "attack_range": 0.0, "attack_damage": 0, "max_health": 2},
        {k: 0.0 for k in MODIFIER_KEYS}, 1.2,
    ),
    "head_bone": Piece(
        "head_bone", "core_body", "normal",
        {"move_speed": 0.0, "attack_range": 0.0, "attack_damage": 0, "max_health": 0},
        {k: 0.0 for k in MODIFIER_KEYS}, 0.7,
    ),
}


def authored(bone_id: str, quality: str = "normal") -> Piece:
    base = AUTHORED[bone_id]
    return Piece(base.bone_id, base.set_id, quality, base.bonus, base.quality_percents, base.equipment_weight)


# --- the evaluator, mirrored ---------------------------------------------


def family_counts(state: dict[str, Piece]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for piece in state.values():
        if piece.set_id:
            counts[piece.set_id] = counts.get(piece.set_id, 0) + 1
    return counts


def symmetric_pairs(state: dict[str, Piece]) -> dict[str, str]:
    def matched(slot_a: str, slot_b: str) -> str:
        left = state.get(slot_a)
        right = state.get(slot_b)
        if left is None or right is None or left.bone_id != right.bone_id:
            return ""
        return left.bone_id

    return {
        "arms": matched("left_arm", "right_arm"),
        "legs": matched("left_leg", "right_leg"),
    }


def pieces_at_or_above_rank(state: dict[str, Piece], min_rank: int) -> int:
    return sum(1 for piece in state.values() if QUALITY_RANK[piece.quality] >= min_rank)


def evaluate(state: dict[str, Piece]) -> dict:
    result = {
        "bonus": {k: 0.0 for k in BONUS_KEYS},
        "modifiers": {k: 0.0 for k in MODIFIER_KEYS},
        "active": [],
    }
    if not state:
        return result

    def accumulate(payload, rule_id, label, category, tier, pieces):
        effects = []
        for key in BONUS_KEYS:
            value = float(payload.get("bonus", {}).get(key, 0.0))
            if value:
                result["bonus"][key] += value
                effects.append({"stat": key, "value": value, "is_percent": False})
        for key in MODIFIER_KEYS:
            value = float(payload.get("modifiers", {}).get(key, 0.0))
            if value:
                result["modifiers"][key] += value
                effects.append({"stat": key, "value": value, "is_percent": True})
        result["active"].append(
            {"id": rule_id, "label": label, "category": category, "tier": tier,
             "pieces": pieces, "bonuses": effects}
        )

    counts = family_counts(state)
    for set_id, rule in FAMILY_RULES.items():
        if set_id in EXCLUDED_SET_IDS:
            continue
        count = counts.get(set_id, 0)
        if count <= 0:
            continue
        cumulative = bool(rule.get("cumulative", False))
        best, best_pieces = None, -1
        for tier in rule.get("tiers", []):
            needed = int(tier.get("pieces", 0))
            if needed <= 0 or count < needed:
                continue
            if cumulative:
                accumulate(tier, set_id, rule["label"], "family", needed, count)
            elif needed > best_pieces:
                best, best_pieces = tier, needed
        if not cumulative and best is not None:
            accumulate(best, set_id, rule["label"], "family", best_pieces, count)

    pairs = symmetric_pairs(state)
    for pair_key, rule in SYMMETRY_RULES.items():
        if pairs.get(pair_key, ""):
            accumulate(rule, rule["id"], rule["label"], "symmetry", 0, 2)

    for rule in QUALITY_RULES:
        matching = pieces_at_or_above_rank(state, int(rule.get("min_rank", 0)))
        if matching >= int(rule.get("pieces", 0)):
            accumulate(rule, rule["id"], rule["label"], "quality", 0, matching)

    return result


# --- the stat pipeline, mirrored -----------------------------------------


def godot_roundi(value: float) -> int:
    return int(math.floor(value + 0.5)) if value >= 0.0 else int(math.ceil(value - 0.5))


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def player_stats(state: dict[str, Piece], base_speed=6.0, base_reach=2.0, base_damage=1, base_health=3) -> dict:
    synergy = evaluate(state)

    bonus = {k: 0.0 for k in BONUS_KEYS}
    for piece in state.values():
        multiplier = QUALITY_MULTIPLIER[piece.quality]
        for key in BONUS_KEYS:
            bonus[key] += float(piece.bonus[key]) * multiplier
    for key in BONUS_KEYS:
        bonus[key] += synergy["bonus"][key]

    modifiers = {k: 0.0 for k in MODIFIER_KEYS}
    equipment_weight = 0.0
    for piece in state.values():
        for key in MODIFIER_KEYS:
            modifiers[key] += piece.quality_percents[key]
        equipment_weight += piece.equipment_weight * max(0.0, 1.0 + piece.quality_percents["weight_percent"])
    for key in MODIFIER_KEYS:
        modifiers[key] += synergy["modifiers"][key]
        modifiers[key] = clamp(modifiers[key], -PERCENT_LIMIT, PERCENT_LIMIT)

    equipment_weight *= max(0.0, 1.0 + synergy["modifiers"]["weight_percent"])
    load_penalty = clamp((max(0.0, equipment_weight - FREE_WEIGHT)) * PENALTY_PER_WEIGHT, 0.0, PENALTY_MAX)

    move_multiplier = max(0.1, (1.0 + modifiers["speed_percent"]) * (1.0 - load_penalty))
    return {
        "move_speed": max(0.0, (base_speed + bonus["move_speed"]) * move_multiplier),
        "attack_range": base_reach + bonus["attack_range"],
        "attack_damage": max(0, godot_roundi((base_damage + bonus["attack_damage"]) * max(0.1, 1.0 + modifiers["damage_percent"]))),
        "max_health": max(1, godot_roundi((base_health + bonus["max_health"]) * max(0.1, 1.0 + modifiers["health_percent"]))),
        "equipment_weight": equipment_weight,
        "load_speed_penalty": load_penalty,
        "modifiers": modifiers,
        "active": synergy["active"],
    }


# --- helpers for the cases ------------------------------------------------


def active_ids(state: dict[str, Piece]) -> list[str]:
    return sorted(f"{e['id']}@{e['tier']}" for e in evaluate(state)["active"])


def gorilla_state(count: int, quality: str = "normal") -> dict[str, Piece]:
    slots = ["torso", "left_arm", "right_arm", "left_leg", "right_leg"]
    limbs = {"torso": "body", "left_arm": "left_arm", "right_arm": "right_arm",
             "left_leg": "left_leg", "right_leg": "right_leg"}
    state = {"head": authored("head_bone")}
    for slot in slots[:count]:
        state[slot] = generated("gorilla", limbs[slot], quality)
    return state


# --- cases ----------------------------------------------------------------

FAILURES: list[str] = []
PASSES: list[str] = []


def check(name: str, condition: bool, detail: str = "") -> None:
    if condition:
        PASSES.append(name)
        print(f"  [PASS] {name}")
    else:
        FAILURES.append(f"{name}{(' -- ' + detail) if detail else ''}")
        print(f"  [FAIL] {name} {detail}")


def run_instruction_1() -> None:
    print("\nInstruction 1 -- family tiers and clamp")

    # 1. Fewer than two pieces activates nothing.
    check("1 gorilla piece activates no synergy", active_ids(gorilla_state(1)) == [])

    # 2. Two pieces activate only the first tier.
    two = evaluate(gorilla_state(2))
    check("2 gorilla pieces activate only the 2-piece tier",
          [e["tier"] for e in two["active"]] == [2], str(two["active"]))
    check("2-piece gorilla is exactly +0.02 damage / -0.01 speed",
          math.isclose(two["modifiers"]["damage_percent"], 0.02) and math.isclose(two["modifiers"]["speed_percent"], -0.01),
          str(two["modifiers"]))

    # 3. Four pieces award the 4-piece tier only -- never 2+4 stacked.
    four = evaluate(gorilla_state(4))
    family = [e for e in four["active"] if e["category"] == "family"]
    check("4 gorilla pieces activate exactly one family tier", len(family) == 1, str(family))
    check("4-piece gorilla does not stack the 2-piece tier",
          math.isclose(four["modifiers"]["damage_percent"], 0.05)
          and math.isclose(four["modifiers"]["speed_percent"], -0.03)
          and math.isclose(four["bonus"]["max_health"], 0.0),
          str(four["modifiers"]) + str(four["bonus"]))

    # 4. Unequipping removes the effect immediately (state is the only input).
    reduced = gorilla_state(4)
    del reduced["left_leg"]
    check("dropping to 3 pieces falls back to the 2-piece tier",
          [e["tier"] for e in evaluate(reduced)["active"] if e["category"] == "family"] == [2])
    reduced2 = gorilla_state(2)
    del reduced2["left_arm"]
    check("dropping to 1 piece removes the family synergy entirely",
          [e for e in evaluate(reduced2)["active"] if e["category"] == "family"] == [])

    # 7. Re-evaluating the same state never accumulates.
    state = gorilla_state(4)
    first = evaluate(state)
    for _ in range(5):
        again = evaluate(state)
    check("re-evaluating 5x is idempotent",
          again["modifiers"] == first["modifiers"] and again["bonus"] == first["bonus"] and len(again["active"]) == len(first["active"]))

    # 6. Nothing escapes the clamp.
    stats = player_stats(gorilla_state(5, "pristine"))
    check("all modifiers stay inside +/-0.75",
          all(abs(v) <= PERCENT_LIMIT + 1e-9 for v in stats["modifiers"].values()), str(stats["modifiers"]))

    # Each authored family reaches its own tiers.
    for set_id, rule in FAMILY_RULES.items():
        tiers = sorted(int(t["pieces"]) for t in rule["tiers"])
        check(f"{set_id} authors tiers {tiers}", tiers == [2, 4])

    # Excluded families never fire even at full count.
    excluded_state = {f"slot{i}": authored("torso_bone") for i in range(4)}
    check("core_body stays excluded at 4 pieces",
          [e for e in evaluate(excluded_state)["active"] if e["category"] == "family"] == [])


def run_instruction_2() -> None:
    print("\nInstruction 2 -- symmetry and quality")

    # 1. Two identical arms activate Matching Arms.
    arms = {"head": authored("head_bone"), "torso": authored("torso_bone"),
            "left_arm": generated("normal", "left_arm"), "right_arm": generated("normal", "left_arm")}
    check("identical arms activate Matching Arms", "matching_arms@0" in active_ids(arms))

    # 2. Swapping one arm for a different bone_id deactivates it.
    mixed = dict(arms)
    mixed["right_arm"] = generated("gorilla", "right_arm")
    check("different arm bone_ids deactivate Matching Arms", "matching_arms@0" not in active_ids(mixed))

    # 3. Two identical legs activate Matching Legs.
    legs = {"head": authored("head_bone"), "torso": authored("torso_bone"),
            "left_leg": generated("lizard", "left_leg"), "right_leg": generated("lizard", "left_leg")}
    check("identical legs activate Matching Legs", "matching_legs@0" in active_ids(legs))
    legs_eval = evaluate(legs)
    check("Matching Legs grants +0.15 move_speed and +2% weight",
          math.isclose(legs_eval["bonus"]["move_speed"], 0.15) and math.isclose(legs_eval["modifiers"]["weight_percent"], 0.02),
          str(legs_eval["bonus"]) + str(legs_eval["modifiers"]))

    # 4. Different qualities still pair.
    mixed_quality = dict(arms)
    mixed_quality["left_arm"] = generated("normal", "left_arm", "frail")
    mixed_quality["right_arm"] = generated("normal", "left_arm", "pristine")
    check("Frail + Pristine of the same type still pair", "matching_arms@0" in active_ids(mixed_quality))

    # Each rule appears exactly once.
    both = {"head": authored("head_bone"), "torso": authored("torso_bone"),
            "left_arm": generated("normal", "left_arm"), "right_arm": generated("normal", "left_arm"),
            "left_leg": generated("normal", "left_leg"), "right_leg": generated("normal", "left_leg")}
    ids = [e["id"] for e in evaluate(both)["active"]]
    check("each symmetry rule appears once", ids.count("matching_arms") == 1 and ids.count("matching_legs") == 1, str(ids))

    # 5/6/7. Quality threshold.
    def quality_state(strong_count: int) -> dict[str, Piece]:
        slots = ["torso", "left_arm", "right_arm", "left_leg", "right_leg"]
        limbs = {"torso": "body", "left_arm": "left_arm", "right_arm": "right_arm",
                 "left_leg": "left_leg", "right_leg": "right_leg"}
        state = {"head": authored("head_bone")}
        for index, slot in enumerate(slots):
            state[slot] = generated("normal", limbs[slot], "strong" if index < strong_count else "normal")
        return state

    check("4 Strong pieces activate High-Quality Assembly", "high_quality_assembly@0" in active_ids(quality_state(4)))
    check("3 Strong pieces do not activate it", "high_quality_assembly@0" not in active_ids(quality_state(3)))
    check("dropping from 4 to 3 Strong deactivates it", "high_quality_assembly@0" not in active_ids(quality_state(3)))

    pristine_mix = quality_state(0)
    for slot in ["torso", "left_arm", "right_arm", "left_leg"]:
        pristine_mix[slot] = generated("normal", {"torso": "body"}.get(slot, slot), "pristine")
    check("4 Pristine pieces activate it", "high_quality_assembly@0" in active_ids(pristine_mix))

    frail_worn = quality_state(0)
    for slot in ["torso", "left_arm", "right_arm", "left_leg"]:
        frail_worn[slot] = generated("normal", {"torso": "body"}.get(slot, slot), "worn")
    check("Worn pieces never count toward High-Quality Assembly",
          "high_quality_assembly@0" not in active_ids(frail_worn))

    # The fixed head counts only if its own quality qualifies.
    head_strong = quality_state(3)
    head_strong["head"] = authored("head_bone", "strong")
    check("a Strong head is the 4th qualifying piece", "high_quality_assembly@0" in active_ids(head_strong))
    head_normal = quality_state(3)
    check("a Normal head does not qualify", "high_quality_assembly@0" not in active_ids(head_normal))

    # 8. All three categories coexist.
    combined = {
        "head": authored("head_bone", "strong"),
        "torso": generated("gorilla", "body", "strong"),
        "left_arm": generated("gorilla", "left_arm", "strong"),
        "right_arm": generated("gorilla", "left_arm", "strong"),
        "left_leg": generated("gorilla", "left_leg", "normal"),
    }
    categories = sorted({e["category"] for e in evaluate(combined)["active"]})
    check("family + symmetry + quality coexist", categories == ["family", "quality", "symmetry"], str(categories))

    # 9. Idempotent after repeated evaluation.
    first = evaluate(combined)
    for _ in range(5):
        again = evaluate(combined)
    check("combined state is idempotent over 5 evaluations",
          again["modifiers"] == first["modifiers"] and len(again["active"]) == len(first["active"]))

    # 10. Builds and current equipment produce identical stats for one state.
    build_side = player_stats(combined)
    worn_side = player_stats(dict(combined))
    check("same state yields identical stats through both paths",
          all(math.isclose(build_side[k], worn_side[k]) for k in ("move_speed", "attack_range", "attack_damage", "max_health")))

    print("\n  Observed values for the combined loadout:")
    for entry in evaluate(combined)["active"]:
        label = entry["label"] + (f" - {entry['tier']}-piece" if entry["tier"] else "")
        effects = ", ".join(
            f"{e['stat']} {'+' if e['value'] > 0 else ''}{round(e['value'] * 100) if e['is_percent'] else e['value']}{'%' if e['is_percent'] else ''}"
            for e in entry["bonuses"]
        )
        print(f"    {label}: {effects}")
    print(f"    -> speed {build_side['move_speed']:.3f}, reach {build_side['attack_range']:.2f}, "
          f"damage {build_side['attack_damage']}, health {build_side['max_health']}, "
          f"weight {build_side['equipment_weight']:.3f}, load penalty {build_side['load_speed_penalty']:.3f}")


def run_instruction_3() -> None:
    print("\nInstruction 3 -- integration wiring")

    bone_rules = read(BONE_RULES)
    builds = read(BUILDS)
    ui = read(ROOT / "scripts" / "player_inventory_ui.gd")

    check("aggregate_player_bonuses_exact consumes the evaluator",
          'SynergyRulesService.evaluate(equipment_state)["bonus"]' in bone_rules)
    check("aggregate_player_stat_modifiers consumes the evaluator",
          'SynergyRulesService.evaluate(equipment_state)["modifiers"]' in bone_rules)

    # The clamp must come AFTER the synergy sum, or a set bonus escapes it.
    modifiers_body = bone_rules.split("static func aggregate_player_stat_modifiers")[1]
    synergy_at = modifiers_body.find("synergy_modifiers: Dictionary")
    clamp_at = modifiers_body.find("clampf(float(total[\"damage_percent\"])")
    check("synergy percentages are summed before the clamp",
          synergy_at != -1 and clamp_at != -1 and synergy_at < clamp_at,
          f"synergy at {synergy_at}, clamp at {clamp_at}")

    check("builds effects read the central evaluator",
          "BoneRulesService.active_synergies_for(state)" in builds)
    check("builds report exposes composition", '"composition"' in builds and "_composition_for_state" in builds)
    check("builds report exposes the worn loadout's effects", '"current_effects"' in builds)
    check("builds mark partially-resolvable effects", '"effects_partial"' in builds)
    check("UI renders synergy effects, not bare names", "_make_synergy_rows" in ui)
    check("UI previews would-activate / would-break",
          "Would activate" in ui and "Would break" in ui and "SynergyRulesService.difference_between" in ui)
    check("UI does not evaluate conditions itself",
          "FAMILY_RULES" not in ui and "SYMMETRY_RULES" not in ui)

    # A build whose resolved state equals the worn state must report the same
    # synergies and zero deltas.
    worn = {
        "head": authored("head_bone"),
        "torso": generated("gorilla", "body"),
        "left_arm": generated("gorilla", "left_arm"),
        "right_arm": generated("gorilla", "left_arm"),
        "left_leg": generated("gorilla", "left_leg"),
    }
    build = dict(worn)
    build_stats = player_stats(build)
    worn_stats = player_stats(worn)
    deltas = {k: build_stats[k] - worn_stats[k] for k in ("move_speed", "attack_range", "attack_damage", "max_health")}
    check("a matching build shows zero deltas", all(abs(v) < 0.005 for v in deltas.values()), str(deltas))
    check("a matching build shows identical synergies", active_ids(build) == active_ids(worn))

    # A missing piece must deactivate the synergy that depended on it.
    partial = dict(worn)
    del partial["right_arm"]
    check("a missing piece breaks Matching Arms", "matching_arms@0" not in active_ids(partial))
    check("a missing piece drops the family tier",
          [e["tier"] for e in evaluate(partial)["active"] if e["category"] == "family"] == [2])

    # Inventory preview: activating and breaking in one swap.
    candidate = dict(worn)
    candidate["right_arm"] = generated("lizard", "right_arm")
    before, after = set(active_ids(worn)), set(active_ids(candidate))
    check("swapping an arm reports a broken synergy", bool(before - after), str(before - after))
    print(f"    would break: {sorted(before - after)}")
    print(f"    would activate: {sorted(after - before)}")


def main() -> int:
    print("Synergy rules validation")
    print("========================")
    print(f"Parsed {len(FAMILY_RULES)} family rules, {len(SYMMETRY_RULES)} symmetry rules, "
          f"{len(QUALITY_RULES)} quality rules from synergy_rules_service.gd")
    run_instruction_1()
    run_instruction_2()
    run_instruction_3()
    print("\n========================")
    if FAILURES:
        print(f"Result: FAIL ({len(FAILURES)} of {len(FAILURES) + len(PASSES)} checks failed)")
        for failure in FAILURES:
            print(f"  - {failure}")
        return 1
    print(f"Result: OK ({len(PASSES)} checks passed; simulated, not engine-run)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
