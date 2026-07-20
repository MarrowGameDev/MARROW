class_name SynergyRulesService

# Single source of truth for SET (family), SYMMETRY and QUALITY bonuses.
#
# A family is identified by `set_id` -- the one field that exists on both
# hand-authored bones (data/bones/*.tres) and generated enemy limbs
# (EquipmentRulesService.generated_limb_definition_for). `source_profile` was
# rejected as the family key because it only exists on generated pieces, and
# `mutation_family` because it is a different vocabulary entirely
# (corrupto/maldito/especial/hibrido).
#
# Deliberate design constraints:
#   * STATELESS. evaluate() is a pure function of the equipment state. Nothing
#     here stores an "active effect", and nothing emits an event that another
#     system applies on its own. That is what makes double application and
#     residual effects impossible by construction: unequipping a piece changes
#     the input, so the next recalculation simply produces a smaller result.
#     Do NOT add caching, signals or per-effect bookkeeping to this file.
#   * Tiers are EXCLUSIVE by default: four pieces award the 4-piece tier only,
#     not 2+4 stacked. A family that genuinely wants stacking sets
#     "cumulative": true, which is the only way accumulation can happen.
#   * Percentage output is fed into BoneRulesService.aggregate_player_stat_modifiers
#     BEFORE its clampf, so PLAYER_STAT_PERCENT_LIMIT (+/-0.75) stays the single
#     global ceiling. A synergy can never escape it.
#   * attack_range stays a FLAT bonus. The stat has no percentage path anywhere
#     in the stat formula, and adding one here would silently diverge from
#     player_stats_with_equipment.
#   * The UI never re-derives a condition. evaluate()["active"] carries the
#     label, the category, the tier and the resolved effect list, so a panel
#     renders what the stat pipeline actually applied instead of guessing.
#
# The rules live in a constant table rather than .tres Resources, matching the
# BoneQualityService.QUALITY_TABLE precedent. Migrating to Resources later is a
# swap of the table for a catalog lookup; the evaluate() contract does not move.

const BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0.0,
	"max_health": 0.0,
}
const MODIFIER_DEFAULTS := {
	"damage_percent": 0.0,
	"speed_percent": 0.0,
	"health_percent": 0.0,
	"weight_percent": 0.0,
}

const CATEGORY_FAMILY := "family"
const CATEGORY_SYMMETRY := "symmetry"
const CATEGORY_QUALITY := "quality"

const PAIR_ARMS := "arms"
const PAIR_LEGS := "legs"

# Tier is the piece threshold a family rule cleared. Symmetry and quality rules
# are not laddered, so they report 0 rather than inventing a tier.
const TIER_NONE := 0

# Player-facing stat names, so every panel spells an effect the same way.
const STAT_DISPLAY := {
	"move_speed": "Speed",
	"attack_range": "Reach",
	"attack_damage": "Damage",
	"max_health": "Health",
	"damage_percent": "Damage",
	"speed_percent": "Speed",
	"health_percent": "Health",
	"weight_percent": "Weight",
}

# Families held out of the first version, and why. Listed explicitly rather
# than merely omitted from FAMILY_RULES so the reason survives:
#   core_body       -- degenerate. The head is welded to head_bone
#                      (PlayerEquipmentComponent._can_equip_slot refuses
#                      SLOT_HEAD), so this family counts >=1 permanently and a
#                      2-piece tier would fire the moment a torso is worn.
#   training_bones  -- dummy_bone reaches 2 slots (both arms) and nothing else.
#   power_bones     -- heavy_bone is torso-only. Max 1 piece.
#   hybrid_bones    -- rib_bone is torso-only. Max 1 piece.
# evaluate() skips these even if a table entry appears, so adding one by
# accident cannot quietly ship a broken bonus.
const EXCLUDED_SET_IDS := [
	"core_body",
	"training_bones",
	"power_bones",
	"hybrid_bones",
]

# No family can reach six pieces: the head slot is permanently head_bone, which
# leaves torso + two arms + two legs = five equippable slots. Tiers above 4 are
# unreachable by design and must not be authored here.
const MAX_EQUIPPABLE_PIECES := 5

# The rank at which a piece counts as high quality. Taken from the canonical
# ladder, never from quality_multiplier: the multiplier is a tuning number and
# retuning it must not silently move this threshold.
const HIGH_QUALITY_MIN_RANK := 3

# set_id -> {label, cumulative, tiers[]}. Tiers are authored ascending by
# "pieces"; _apply_tiers does not rely on the order, but reading them in order
# is how a designer checks a ladder at a glance.
const FAMILY_RULES := {
	"gorilla_parts": {
		"label": "Gorilla Parts",
		"cumulative": false,
		"tiers": [
			{
				"pieces": 2,
				"modifiers": {"damage_percent": 0.02, "speed_percent": -0.01},
			},
			{
				"pieces": 4,
				"modifiers": {"damage_percent": 0.05, "speed_percent": -0.03},
			},
		],
	},
	"lizard_parts": {
		"label": "Lizard Parts",
		"cumulative": false,
		"tiers": [
			{
				"pieces": 2,
				"modifiers": {"speed_percent": 0.02, "health_percent": -0.01},
			},
			{
				"pieces": 4,
				"modifiers": {"speed_percent": 0.05, "health_percent": -0.03},
			},
		],
	},
	"normal_parts": {
		"label": "Enemy Parts",
		"cumulative": false,
		"tiers": [
			{
				"pieces": 2,
				"modifiers": {"health_percent": 0.02},
			},
			{
				"pieces": 4,
				"bonus": {"attack_range": 0.15},
				"modifiers": {"health_percent": 0.05},
			},
		],
	},
	"starter_bones": {
		"label": "Starter Bones",
		"cumulative": false,
		"tiers": [
			{
				"pieces": 2,
				"bonus": {"attack_range": 0.10},
			},
			{
				"pieces": 4,
				"bonus": {"attack_range": 0.20},
				"modifiers": {"damage_percent": -0.02},
			},
		],
	},
}

# Mirror pairs, keyed by PAIR_ARMS / PAIR_LEGS. A pair is two occupied slots
# holding the same bone TYPE; quality is deliberately not part of the test, so a
# Frail and a Pristine arm of the same type still pair. Each key appears once in
# the table, which is what guarantees each rule appears once in "active".
#
# Keys are spelled literally rather than via PAIR_ARMS/PAIR_LEGS so this stays
# a plain constant initializer; the literals and those constants are the same
# two strings, and symmetric_pairs() is the only producer of them.
const SYMMETRY_RULES := {
	"arms": {
		"id": "matching_arms",
		"label": "Matching Arms",
		"modifiers": {"damage_percent": 0.02},
	},
	"legs": {
		"id": "matching_legs",
		"label": "Matching Legs",
		"bonus": {"move_speed": 0.15},
		"modifiers": {"weight_percent": 0.02},
	},
}

# Quality-tier rules. `min_rank` is compared against the INSTANCE's rolled
# quality rank, so Frail/Worn/Normal (ranks 0-2) never count. The fixed head is
# not special-cased: it contributes if and only if its own rolled quality
# clears the bar, and nothing here touches how it is equipped.
const QUALITY_RULES := [
	{
		"id": "high_quality_assembly",
		"label": "High-Quality Assembly",
		"min_rank": HIGH_QUALITY_MIN_RANK,
		"pieces": 4,
		"modifiers": {
			"damage_percent": 0.02,
			"health_percent": 0.02,
			"weight_percent": 0.02,
		},
	},
]


# THE entry point. Input is the equipment state exactly as
# PlayerEquipmentComponent.get_equipment_state() produces it:
# {slot_id: instance_id}. It is NOT six entries -- only occupied slots appear,
# so never index it positionally.
#
# Returns:
#   {
#     "bonus":     {move_speed, attack_range, attack_damage, max_health},  # flat
#     "modifiers": {damage_percent, speed_percent, health_percent, weight_percent},
#     "active":    [{id, label, category, tier, pieces, bonuses[]}],
#   }
# All four bonus keys and all four modifier keys are always present, so callers
# never branch on existence. "bonuses" is the render-ready effect list:
# [{stat, value, is_percent, text}].
static func evaluate(equipment_state: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bonus": BONUS_DEFAULTS.duplicate(),
		"modifiers": MODIFIER_DEFAULTS.duplicate(),
		"active": [],
	}
	if equipment_state.is_empty():
		return result

	# Reuses the existing summary rather than counting set_ids a second time:
	# two counters would be two places to disagree about what a family is.
	var counts: Dictionary = family_counts(equipment_state)
	for set_id in FAMILY_RULES:
		var clean_set_id := str(set_id)
		if EXCLUDED_SET_IDS.has(clean_set_id):
			continue
		_apply_tiers(
			result,
			FAMILY_RULES[clean_set_id],
			clean_set_id,
			int(counts.get(clean_set_id, 0))
		)

	var pairs: Dictionary = symmetric_pairs(equipment_state)
	for pair_key in SYMMETRY_RULES:
		var clean_pair_key := str(pair_key)
		if str(pairs.get(clean_pair_key, "")) == "":
			continue
		var symmetry_rule: Dictionary = SYMMETRY_RULES[clean_pair_key]
		_accumulate(
			result,
			symmetry_rule,
			str(symmetry_rule.get("id", clean_pair_key)),
			str(symmetry_rule.get("label", clean_pair_key)),
			CATEGORY_SYMMETRY,
			TIER_NONE,
			2
		)

	# Counted once and reused: pieces_at_or_above_rank walks the whole state, so
	# recomputing it per rule would be quadratic for no reason.
	var rank_counts: Dictionary = quality_rank_counts(equipment_state)
	for rule_value in QUALITY_RULES:
		var quality_rule: Dictionary = rule_value
		var matching := _count_at_or_above(rank_counts, int(quality_rule.get("min_rank", 0)))
		if matching < int(quality_rule.get("pieces", 0)):
			continue
		_accumulate(
			result,
			quality_rule,
			str(quality_rule.get("id", "")),
			str(quality_rule.get("label", "")),
			CATEGORY_QUALITY,
			TIER_NONE,
			matching
		)

	return result


# --- counting helpers -----------------------------------------------------

# Pieces per family in the given state. Delegates to the existing
# equipment_synergy_summary so set_id resolution has exactly one implementation.
static func family_counts(equipment_state: Dictionary) -> Dictionary:
	var summary: Dictionary = BoneRulesService.equipment_synergy_summary(equipment_state)
	var raw: Dictionary = summary.get("set_counts", {})
	return raw.duplicate()


# Families that have a rule and are worth showing in a composition panel:
# {set_id: {"label", "count", "max"}}. Excluded families never appear.
static func family_composition(equipment_state: Dictionary) -> Dictionary:
	var counts: Dictionary = family_counts(equipment_state)
	var composition: Dictionary = {}
	for set_id in FAMILY_RULES:
		var clean_set_id := str(set_id)
		if EXCLUDED_SET_IDS.has(clean_set_id):
			continue
		var count := int(counts.get(clean_set_id, 0))
		if count <= 0:
			continue
		composition[clean_set_id] = {
			"label": str((FAMILY_RULES[clean_set_id] as Dictionary).get("label", clean_set_id)),
			"count": count,
			"max": MAX_EQUIPPABLE_PIECES,
		}
	return composition


# {"arms": bone_id_or_empty, "legs": bone_id_or_empty}.
#
# A pair is two slots holding the same bone TYPE. Quality is deliberately not
# part of the test: a Frail and a Pristine arm of the same type still pair. That
# keeps the rule readable at a glance in the paper doll, where the two pieces
# look like a matched set.
static func symmetric_pairs(equipment_state: Dictionary) -> Dictionary:
	return {
		PAIR_ARMS: _matched_bone_id(
			equipment_state,
			EquipmentRulesService.SLOT_LEFT_ARM,
			EquipmentRulesService.SLOT_RIGHT_ARM
		),
		PAIR_LEGS: _matched_bone_id(
			equipment_state,
			EquipmentRulesService.SLOT_LEFT_LEG,
			EquipmentRulesService.SLOT_RIGHT_LEG
		),
	}


static func has_symmetric_arms(equipment_state: Dictionary) -> bool:
	return str(symmetric_pairs(equipment_state).get(PAIR_ARMS, "")) != ""


static func has_symmetric_legs(equipment_state: Dictionary) -> bool:
	return str(symmetric_pairs(equipment_state).get(PAIR_LEGS, "")) != ""


# quality rank -> number of equipped pieces at that rank. Rank comes from the
# INSTANCE (BoneQualityService.rank_for on the rolled quality), never from the
# definition and never from quality_multiplier, so two copies of one bone type
# can land in different buckets and retuning a multiplier cannot move a
# threshold.
static func quality_rank_counts(equipment_state: Dictionary) -> Dictionary:
	var counts: Dictionary = {}
	for slot_id in equipment_state:
		var piece := str(equipment_state[slot_id])
		if piece == "":
			continue
		var rank := BoneQualityService.rank_for(BoneInstanceService.quality_id_of(piece))
		counts[rank] = int(counts.get(rank, 0)) + 1
	return counts


static func pieces_at_or_above_rank(equipment_state: Dictionary, min_rank: int) -> int:
	return _count_at_or_above(quality_rank_counts(equipment_state), min_rank)


# How many worn pieces clear the high-quality bar, for composition panels
# ("Strong or Pristine 4 / 6").
static func high_quality_piece_count(equipment_state: Dictionary) -> int:
	return pieces_at_or_above_rank(equipment_state, HIGH_QUALITY_MIN_RANK)


static func _count_at_or_above(rank_counts: Dictionary, min_rank: int) -> int:
	var total := 0
	for rank in rank_counts:
		if int(rank) >= min_rank:
			total += int(rank_counts[rank])
	return total


# --- tier resolution ------------------------------------------------------

# Picks the single highest tier the count satisfies. Four pieces award the
# 4-piece tier and NOT the 2-piece one on top of it, because a ladder that
# silently stacks makes every tier's printed value a lie. A rule that wants
# stacking opts in with "cumulative": true.
static func _apply_tiers(result: Dictionary, rule: Dictionary, id: String, count: int) -> void:
	if count <= 0:
		return

	var tiers: Array = rule.get("tiers", [])
	var cumulative := bool(rule.get("cumulative", false))
	var label := str(rule.get("label", id))
	var best: Dictionary = {}
	var best_pieces := -1

	for tier_value in tiers:
		var tier: Dictionary = tier_value
		var needed := int(tier.get("pieces", 0))
		if needed <= 0 or count < needed:
			continue
		if cumulative:
			_accumulate(result, tier, id, label, CATEGORY_FAMILY, needed, count)
		elif needed > best_pieces:
			best_pieces = needed
			best = tier

	if not cumulative and best_pieces >= 0:
		_accumulate(result, best, id, label, CATEGORY_FAMILY, best_pieces, count)


# Adds one rule's payload into the running totals and records it in "active".
# Missing "bonus"/"modifiers" sub-dictionaries are normal: a rule that only
# grants flat health has no percentages at all.
static func _accumulate(result: Dictionary, payload: Dictionary, id: String, label: String, category: String, tier: int, pieces: int) -> void:
	var effects: Array = []

	var bonus: Dictionary = result["bonus"]
	var payload_bonus: Dictionary = payload.get("bonus", {})
	for key in BONUS_DEFAULTS:
		var flat_value := float(payload_bonus.get(key, 0.0))
		if flat_value == 0.0:
			continue
		bonus[key] = float(bonus[key]) + flat_value
		effects.append(_effect_entry(str(key), flat_value, false))

	var modifiers: Dictionary = result["modifiers"]
	var payload_modifiers: Dictionary = payload.get("modifiers", {})
	for key in MODIFIER_DEFAULTS:
		var percent_value := float(payload_modifiers.get(key, 0.0))
		if percent_value == 0.0:
			continue
		modifiers[key] = float(modifiers[key]) + percent_value
		effects.append(_effect_entry(str(key), percent_value, true))

	var active: Array = result["active"]
	active.append({
		"id": id,
		"label": label,
		"category": category,
		"tier": tier,
		"pieces": pieces,
		"bonuses": effects,
	})


# --- presentation ---------------------------------------------------------

static func _effect_entry(stat: String, value: float, is_percent: bool) -> Dictionary:
	return {
		"stat": stat,
		"value": value,
		"is_percent": is_percent,
		"text": "%s %s" % [str(STAT_DISPLAY.get(stat, stat)), format_effect_value(value, is_percent)],
	}


static func format_effect_value(value: float, is_percent: bool) -> String:
	if is_percent:
		# Percentages are authored in hundredths (0.06 -> "+6%"). roundi keeps
		# 0.075 from rendering as "7.4999%".
		var percent := roundi(value * 100.0)
		return ("+" if percent > 0 else "") + str(percent) + "%"
	if is_equal_approx(value, roundf(value)):
		return ("+" if value > 0.0 else "") + str(roundi(value))
	return ("+" if value > 0.0 else "") + str(snappedf(value, 0.01))


# Header line for one active entry: "Gorilla Parts - 2-piece", "Matching Arms".
static func headline_for(entry: Dictionary) -> String:
	var label := str(entry.get("label", entry.get("id", "")))
	var tier := int(entry.get("tier", TIER_NONE))
	if tier <= TIER_NONE:
		return label
	return "%s - %d-piece" % [label, tier]


# Flat "Name - tier: Effect, Effect" line, for compact lists that cannot render
# a header plus indented effects.
static func summary_line_for(entry: Dictionary) -> String:
	var effects: Array = entry.get("bonuses", [])
	if effects.is_empty():
		return headline_for(entry)
	var parts: Array[String] = []
	for effect_value in effects:
		var effect: Dictionary = effect_value
		parts.append(str(effect.get("text", "")))
	return "%s: %s" % [headline_for(entry), ", ".join(parts)]


# Stable identity for comparing two evaluations (inventory "would activate" /
# "would break"). Includes the tier, so dropping from a 4-piece to a 2-piece
# tier registers as a change rather than as "still active".
static func entry_key_for(entry: Dictionary) -> String:
	return "%s|%d" % [str(entry.get("id", "")), int(entry.get("tier", TIER_NONE))]


# What changes between two equipment states, for a preview panel:
#   {"activated": [entry], "broken": [entry]}
# Pure comparison of two evaluate() results -- it applies nothing.
static func difference_between(current_state: Dictionary, candidate_state: Dictionary) -> Dictionary:
	var current_active: Array = evaluate(current_state)["active"]
	var candidate_active: Array = evaluate(candidate_state)["active"]

	var current_keys: Dictionary = {}
	for entry_value in current_active:
		current_keys[entry_key_for(entry_value)] = entry_value
	var candidate_keys: Dictionary = {}
	for entry_value in candidate_active:
		candidate_keys[entry_key_for(entry_value)] = entry_value

	var activated: Array = []
	for key in candidate_keys:
		if not current_keys.has(key):
			activated.append(candidate_keys[key])
	var broken: Array = []
	for key in current_keys:
		if not candidate_keys.has(key):
			broken.append(current_keys[key])

	return {"activated": activated, "broken": broken}


static func _matched_bone_id(equipment_state: Dictionary, slot_a: String, slot_b: String) -> String:
	var left := BoneInstanceService.bone_id_of(str(equipment_state.get(slot_a, "")))
	var right := BoneInstanceService.bone_id_of(str(equipment_state.get(slot_b, "")))
	if left == "" or left != right:
		return ""
	return left
