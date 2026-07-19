class_name EquipmentRulesService

const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)
const PLAYER_BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}

const SLOT_HEAD := "head"
const SLOT_TORSO := "torso"
const SLOT_LEFT_ARM := "left_arm"
const SLOT_RIGHT_ARM := "right_arm"
const SLOT_LEFT_LEG := "left_leg"
const SLOT_RIGHT_LEG := "right_leg"
const CANONICAL_BODY_SLOTS := [
	SLOT_HEAD,
	SLOT_TORSO,
	SLOT_LEFT_ARM,
	SLOT_RIGHT_ARM,
	SLOT_LEFT_LEG,
	SLOT_RIGHT_LEG,
]
# Only aliases with a real consumer in data/bones/*.tres or generated bone
# definitions belong here. "body" and "legs" are the raw slot values still
# authored in existing .tres files; "ribs"/"ribcage"/"chest"/"arm_left"/
# "arm_right"/"leg_left"/"leg_right" were removed because no data file or
# script ever produces them (verified: grep -rn for each across scripts/,
# data/, docs/ found zero matches outside this map itself).
const LEGACY_SLOT_ALIASES := {
	"body": "torso",
	"legs": "right_leg",
}
const SLOT_DISPLAY := {
	"head": "Head",
	"torso": "Torso",
	"left_arm": "Left Arm",
	"right_arm": "Right Arm",
	"left_leg": "Left Leg",
	"right_leg": "Right Leg",
}
# Grouped filters for the inventory dropdown, which offers Arms and Legs rather
# than one entry per side. These belong to the FILTER vocabulary only and are
# never equipment slot ids -- hence the prefix. A bare "legs" key would be
# actively wrong here: LEGACY_SLOT_ALIASES already maps "legs" to right_leg, so
# normalize_slot_id would quietly turn a both-legs filter into a right-leg one.
const INVENTORY_FILTER_GROUPS := {
	"group_arms": [SLOT_LEFT_ARM, SLOT_RIGHT_ARM],
	"group_legs": [SLOT_LEFT_LEG, SLOT_RIGHT_LEG],
}

# Which SOCKETS a slot paints. The *_lower keys are the split forearms/shins, and
# listing them here is the whole equipment change: equip_bone already loops these
# per slot, so an equipped arm covers both halves in the bone's colour and scale
# with no new branching, and unequip_slot restores both.
#
# Safe to list even when the rig is unsplit: equip_bone does sockets.get(key) and
# skips nulls. Do NOT add the *_lower keys to LIMB_TO_SLOT, primary_limb_keys_for_slot,
# LIMB_DISPLAY or DropPickupRulesService's limb lists — they are a render/hitbox
# concern only. A lower key reaching the drop vocabulary generates a bone id like
# "normal_right_arm_lower_bone", which slot_for_bone cannot parse, so the drop
# silently no-ops.
const SLOT_TO_SOCKETS := {
	"right_arm": ["right_arm", "right_arm_lower"],
	"left_arm": ["left_arm", "left_arm_lower"],
	"right_leg": ["right_leg", "right_leg_lower", "right_foot"],
	"left_leg": ["left_leg", "left_leg_lower", "left_foot"],
	"torso": ["body", "body_lower"],
	"head": ["head"],
}

const LIMB_TO_SLOT := {
	"right_arm": "right_arm",
	"left_arm": "left_arm",
	"right_leg": "right_leg",
	"left_leg": "left_leg",
	"body": "torso",
	"head": "head",
}

const LIMB_DISPLAY := {
	"right_arm": "Right Arm",
	"left_arm": "Left Arm",
	"right_leg": "Right Leg",
	"left_leg": "Left Leg",
	"body": "Torso",
	"head": "Head",
}

const SOURCE_DISPLAY := {
	"normal": "Enemy",
	"gorilla": "Gorilla",
	"lizard": "Lizard",
}

const SOURCE_COLOR := {
	"normal": Color(1.0, 0.94, 0.68, 1.0),
	"gorilla": Color(0.62, 0.42, 0.22, 1.0),
	"lizard": Color(0.23, 0.78, 0.34, 1.0),
}


static func slot_for_bone(bone_id: String) -> String:
	var slots := compatible_slots_for_bone(bone_id)
	if not slots.is_empty():
		return slots[0]
	return ""


static func compatible_slots_for_bone(bone_id: String) -> Array[String]:
	# Build the result via an explicitly declared Array[String] and
	# .append(), not array literals/casts: a plain `[a, b]` literal (or
	# `[a, b] as Array[String]`) built inside this function does not
	# reliably carry Array[String] runtime typing across a static-function
	# call from another class, which raised "Trying to assign an array of
	# type Array to a variable of type Array[String]" for every caller
	# outside this file that assigned the return value to a typed local.
	var result: Array[String] = []
	# Resolving here covers slot_for_bone, can_equip_bone_in_slot and
	# inventory_filter_matches_bone, which all funnel through this function.
	var resolved_id := BoneInstanceService.bone_id_of(bone_id)
	var definition: Dictionary = BoneDatabase.get_def(resolved_id)
	if definition.is_empty():
		definition = generated_limb_definition_for(resolved_id)
	if definition.is_empty():
		return result

	var raw_slot := str(definition.get("slot", ""))
	if raw_slot == "legs":
		result.append(SLOT_RIGHT_LEG)
		result.append(SLOT_LEFT_LEG)
		return result
	if not definition.has("limb_key") and raw_slot == SLOT_RIGHT_ARM:
		result.append(SLOT_RIGHT_ARM)
		result.append(SLOT_LEFT_ARM)
		return result

	var normalized := normalize_slot_id(raw_slot)
	if normalized != "":
		result.append(normalized)
	return result


static func can_equip_bone_in_slot(bone_id: String, slot_id: String) -> bool:
	return compatible_slots_for_bone(bone_id).has(normalize_slot_id(slot_id))


static func normalize_slot_id(slot_id: String) -> String:
	var clean_slot := slot_id.strip_edges()
	if SLOT_DISPLAY.has(clean_slot):
		return clean_slot
	return str(LEGACY_SLOT_ALIASES.get(clean_slot, ""))


static func slot_display_name(slot_id: String) -> String:
	return str(SLOT_DISPLAY.get(normalize_slot_id(slot_id), ""))


static func socket_keys_for_slot(slot_id: String) -> Array:
	return SLOT_TO_SOCKETS.get(normalize_slot_id(slot_id), [])


static func slot_sort_index(slot_id: String) -> int:
	var normalized := normalize_slot_id(slot_id)
	var index := CANONICAL_BODY_SLOTS.find(normalized)
	return index if index >= 0 else CANONICAL_BODY_SLOTS.size()


static func inventory_filter_matches_bone(filter_slot: String, bone_id: String) -> bool:
	# Group filters are checked before normalising: normalize_slot_id does not
	# know these keys and would return "" for them, matching every bone.
	if INVENTORY_FILTER_GROUPS.has(filter_slot):
		var compatible: Array[String] = compatible_slots_for_bone(bone_id)
		for grouped_slot in INVENTORY_FILTER_GROUPS[filter_slot]:
			if compatible.has(grouped_slot):
				return true
		return false
	var normalized_filter := normalize_slot_id(filter_slot)
	if normalized_filter == "":
		return true
	return compatible_slots_for_bone(bone_id).has(normalized_filter)


static func compare_bones_for_inventory(a: String, b: String) -> bool:
	var a_slot_index := slot_sort_index(slot_for_bone(a))
	var b_slot_index := slot_sort_index(slot_for_bone(b))
	if a_slot_index != b_slot_index:
		return a_slot_index < b_slot_index

	var a_rarity := _definition_rank(a, "rarity_rank")
	var b_rarity := _definition_rank(b, "rarity_rank")
	if a_rarity != b_rarity:
		return a_rarity > b_rarity

	var a_quality := _definition_rank(a, "quality_rank")
	var b_quality := _definition_rank(b, "quality_rank")
	if a_quality != b_quality:
		return a_quality > b_quality

	return _definition_display_name(a).nocasecmp_to(_definition_display_name(b)) < 0


static func primary_limb_keys_for_slot(slot_id: String) -> Array[String]:
	match normalize_slot_id(slot_id):
		SLOT_RIGHT_ARM:
			return ["right_arm"]
		SLOT_LEFT_ARM:
			return ["left_arm"]
		SLOT_RIGHT_LEG:
			return ["right_leg"]
		SLOT_LEFT_LEG:
			return ["left_leg"]
		SLOT_TORSO:
			return ["body"]
		SLOT_HEAD:
			return ["head"]
		_:
			return []


static func pickup_bone_id_for_limb(limb_key: String, source_profile: String = "normal") -> String:
	if not LIMB_TO_SLOT.has(limb_key):
		return ""

	var clean_source: String = source_profile
	if not SOURCE_DISPLAY.has(clean_source):
		clean_source = "normal"
	return clean_source + "_" + limb_key + "_bone"


static func generated_limb_definition_for(raw_id: String) -> Dictionary:
	# Accepts an instance_id as well as a bone_id; see BoneInstanceService.
	var parsed: Dictionary = _parse_generated_limb_bone_id(BoneInstanceService.bone_id_of(raw_id))
	if parsed.is_empty():
		return {}

	var source_profile: String = str(parsed["source"])
	var limb_key: String = str(parsed["limb"])
	var slot_id: String = str(LIMB_TO_SLOT.get(limb_key, ""))
	if slot_id == "":
		return {}

	var source_name: String = str(SOURCE_DISPLAY.get(source_profile, "Enemy"))
	var limb_name: String = str(LIMB_DISPLAY.get(limb_key, "Part"))
	var color_value: Variant = SOURCE_COLOR.get(source_profile, UNKNOWN_COLOR)
	var color: Color = UNKNOWN_COLOR
	if color_value is Color:
		color = color_value
	var bonus: Dictionary = _generated_limb_bonus(source_profile, limb_key)
	return {
		"display_name": source_name + " " + limb_name + " Bone",
		"quality": _generated_limb_quality(source_profile),
		"quality_rank": _generated_limb_quality_rank(source_profile),
		"quality_score": _generated_limb_quality_score(source_profile),
		"quality_multiplier": _generated_limb_quality_multiplier(source_profile),
		"quality_color": _generated_limb_quality_color(source_profile),
		"quality_damage_percent": _generated_limb_quality_damage_percent(source_profile),
		"quality_speed_percent": _generated_limb_quality_speed_percent(source_profile),
		"quality_health_percent": _generated_limb_quality_health_percent(source_profile),
		"quality_drop_percent": _generated_limb_quality_drop_percent(source_profile),
		"quality_weight_percent": _generated_limb_quality_weight_percent(source_profile),
		"rarity": _generated_limb_rarity(source_profile),
		"rarity_rank": _generated_limb_rarity_rank(source_profile),
		"rarity_color": _generated_limb_rarity_color(source_profile),
		"rarity_drop_weight": _generated_limb_rarity_drop_weight(source_profile),
		"durability_max": _generated_limb_durability_max(source_profile, limb_key),
		"durability_start": _generated_limb_durability_start(source_profile, limb_key),
		"durability_repair_cost": _generated_limb_durability_repair_cost(source_profile, limb_key),
		"durability_tags": _generated_limb_durability_tags(source_profile, limb_key),
		"mutation_id": _generated_limb_mutation_id(source_profile, limb_key),
		"mutation_family": _generated_limb_mutation_family(source_profile),
		"mutation_stage": _generated_limb_mutation_stage(source_profile),
		"mutation_intensity": _generated_limb_mutation_intensity(source_profile),
		"mutation_tags": _generated_limb_mutation_tags(source_profile, limb_key),
		"attack_type": _generated_limb_attack_type(limb_key),
		"attack_tags": _generated_limb_attack_tags(source_profile, limb_key),
		"combo_family": _generated_limb_combo_family(source_profile, limb_key),
		"combo_step": _generated_limb_combo_step(limb_key),
		"combo_window": _generated_limb_combo_window(source_profile, limb_key),
		"combo_tags": _generated_limb_combo_tags(source_profile, limb_key),
		"combo_finisher": _generated_limb_combo_finisher(limb_key),
		"weight": _generated_limb_weight(source_profile, limb_key),
		"weight_class": _generated_limb_weight_class(source_profile, limb_key),
		"physical_weight": _generated_limb_physical_weight(source_profile, limb_key),
		"equipment_weight": _generated_limb_equipment_weight(source_profile, limb_key),
		"inventory_weight": _generated_limb_inventory_weight(source_profile, limb_key),
		"set_id": _generated_limb_set_id(source_profile),
		"set_name": _generated_limb_set_name(source_profile),
		"set_piece_key": limb_key,
		"set_tags": _generated_limb_set_tags(source_profile),
		"synergy_ids": _generated_limb_synergy_ids(source_profile, limb_key),
		"synergy_tags": _generated_limb_synergy_tags(source_profile, limb_key),
		"synergy_score": _generated_limb_synergy_score(source_profile, limb_key),
		"color": color,
		"slot": slot_id,
		"source_profile": source_profile,
		"limb_key": limb_key,
		"visual_scale": _generated_limb_visual_scale(source_profile, limb_key),
		"visual_offset": Vector3.ZERO,
		"visual_rotation": Vector3.ZERO,
		"head_socket_offset": _generated_limb_head_socket_offset(source_profile, limb_key),
		"hitbox_size": Vector3.ZERO,
		"hitbox_offset": Vector3.ZERO,
		"hitbox_scale": _generated_limb_visual_scale(source_profile, limb_key),
		"hitbox_rotation": Vector3.ZERO,
		"move_speed_bonus": float(bonus.get("move_speed", 0.0)),
		"attack_range_bonus": float(bonus.get("attack_range", 0.0)),
		"attack_damage_bonus": int(bonus.get("attack_damage", 0)),
		"max_health_bonus": int(bonus.get("max_health", 0)),
		"enemy_move_speed_bonus": 0.0,
		"enemy_attack_range_bonus": 0.0,
		"enemy_contact_damage_bonus": 0,
		"enemy_max_health_bonus": 0,
		"enemy_detection_range_bonus": 0.0,
		"enemy_visual_scale": 1.0,
		"enemy_flee_chance": 0.45,
		"tags": [source_profile, limb_key],
		"description": source_name + " " + limb_name.to_lower() + " part. Equipping it changes that body slot's shape.",
	}


static func _parse_generated_limb_bone_id(bone_id: String) -> Dictionary:
	for source_profile in SOURCE_DISPLAY.keys():
		var prefix: String = str(source_profile) + "_"
		if not bone_id.begins_with(prefix) or not bone_id.ends_with("_bone"):
			continue
		var limb_key: String = bone_id.substr(prefix.length(), bone_id.length() - prefix.length() - "_bone".length())
		if LIMB_TO_SLOT.has(limb_key):
			return {
				"source": str(source_profile),
				"limb": limb_key,
			}
	return {}


static func _definition_for_sort(bone_id: String) -> Dictionary:
	var definition: Dictionary = BoneDatabase.get_def(bone_id)
	if not definition.is_empty():
		return definition
	return generated_limb_definition_for(bone_id)


static func _definition_rank(bone_id: String, key: String) -> int:
	return int(_definition_for_sort(bone_id).get(key, 0))


static func _definition_display_name(bone_id: String) -> String:
	var definition := _definition_for_sort(bone_id)
	return str(definition.get("display_name", bone_id))


static func _generated_limb_quality(source_profile: String) -> String:
	match source_profile:
		"gorilla":
			return BoneDefinition.QUALITY_STRONG
		"lizard":
			return BoneDefinition.QUALITY_FRAGILE
		_:
			return BoneDefinition.QUALITY_COMMON


static func _generated_limb_quality_rank(source_profile: String) -> int:
	return BoneDefinition.default_quality_rank(_generated_limb_quality(source_profile))


static func _generated_limb_quality_score(source_profile: String) -> float:
	return BoneDefinition.default_quality_score(_generated_limb_quality(source_profile))


static func _generated_limb_quality_multiplier(source_profile: String) -> float:
	return BoneDefinition.default_quality_multiplier(_generated_limb_quality(source_profile))


static func _generated_limb_quality_damage_percent(source_profile: String) -> float:
	match source_profile:
		"gorilla":
			return 0.08
		"lizard":
			return -0.03
		_:
			return 0.0


static func _generated_limb_quality_speed_percent(source_profile: String) -> float:
	match source_profile:
		"gorilla":
			return -0.06
		"lizard":
			return 0.08
		_:
			return 0.0


static func _generated_limb_quality_health_percent(source_profile: String) -> float:
	match source_profile:
		"gorilla":
			return 0.05
		_:
			return 0.0


static func _generated_limb_quality_drop_percent(source_profile: String) -> float:
	match source_profile:
		"lizard":
			return 0.03
		_:
			return 0.0


static func _generated_limb_quality_weight_percent(source_profile: String) -> float:
	match source_profile:
		"gorilla":
			return 0.1
		"lizard":
			return -0.08
		_:
			return 0.0


static func _generated_limb_quality_color(source_profile: String) -> Color:
	return BoneDefinition.default_quality_color(_generated_limb_quality(source_profile))


static func _generated_limb_rarity(source_profile: String) -> String:
	match source_profile:
		"gorilla":
			return BoneDefinition.RARITY_SPECIAL
		"lizard":
			return BoneDefinition.RARITY_CORRUPT
		_:
			return BoneDefinition.RARITY_COMMON


static func _generated_limb_rarity_rank(source_profile: String) -> int:
	return BoneDefinition.default_rarity_rank(_generated_limb_rarity(source_profile))


static func _generated_limb_rarity_color(source_profile: String) -> Color:
	return BoneDefinition.default_rarity_color(_generated_limb_rarity(source_profile))


static func _generated_limb_rarity_drop_weight(source_profile: String) -> float:
	return BoneDefinition.default_rarity_drop_weight(_generated_limb_rarity(source_profile))


static func _generated_limb_durability_max(source_profile: String, limb_key: String) -> int:
	var base := 80
	match limb_key:
		"body":
			base = 120
		"head":
			base = 100
		"right_leg", "left_leg":
			base = 85

	match source_profile:
		"gorilla":
			return roundi(float(base) * 1.25)
		"lizard":
			return roundi(float(base) * 0.85)
		_:
			return base


static func _generated_limb_durability_start(source_profile: String, limb_key: String) -> int:
	return _generated_limb_durability_max(source_profile, limb_key)


static func _generated_limb_durability_repair_cost(source_profile: String, limb_key: String) -> int:
	match source_profile:
		"gorilla":
			return 3
		"lizard":
			return 1
		_:
			return 2 if limb_key == "body" else 1


static func _generated_limb_durability_tags(source_profile: String, limb_key: String) -> Array[String]:
	var tags: Array[String] = [limb_key]
	match source_profile:
		"gorilla":
			tags.append("reinforced")
		"lizard":
			tags.append("fragile")
	if limb_key == "body" or limb_key == "head":
		tags.append("core")
	return tags


static func _generated_limb_mutation_id(source_profile: String, limb_key: String) -> String:
	if source_profile == "normal":
		return ""
	return source_profile + "_" + limb_key


static func _generated_limb_mutation_family(source_profile: String) -> String:
	match source_profile:
		"gorilla":
			return BoneDefinition.MUTATION_SPECIAL
		"lizard":
			return BoneDefinition.MUTATION_CORRUPT
		_:
			return BoneDefinition.MUTATION_NONE


static func _generated_limb_mutation_stage(source_profile: String) -> int:
	match source_profile:
		"gorilla", "lizard":
			return 1
		_:
			return 0


static func _generated_limb_mutation_intensity(source_profile: String) -> float:
	match source_profile:
		"gorilla":
			return 0.35
		"lizard":
			return 0.3
		_:
			return 0.0


static func _generated_limb_mutation_tags(source_profile: String, limb_key: String) -> Array[String]:
	if source_profile == "normal":
		return []
	return [source_profile, limb_key]


static func _generated_limb_attack_type(limb_key: String) -> String:
	match limb_key:
		"right_arm", "left_arm":
			return "melee"
		"right_leg", "left_leg":
			return "movement"
		"head":
			return "sense"
		"body":
			return "guard"
		_:
			return "melee"


static func _generated_limb_attack_tags(source_profile: String, limb_key: String) -> Array[String]:
	return [source_profile, limb_key, _generated_limb_attack_type(limb_key)]


static func _generated_limb_combo_family(source_profile: String, limb_key: String) -> String:
	match limb_key:
		"right_arm", "left_arm":
			return source_profile + "_strikes"
		"right_leg", "left_leg":
			return source_profile + "_mobility"
		"head":
			return source_profile + "_focus"
		"body":
			return source_profile + "_guard"
		_:
			return source_profile + "_combo"


static func _generated_limb_combo_step(limb_key: String) -> int:
	match limb_key:
		"right_arm":
			return 1
		"left_arm":
			return 2
		"body":
			return 3
		_:
			return 0


static func _generated_limb_combo_window(source_profile: String, limb_key: String) -> float:
	if _generated_limb_combo_step(limb_key) == 0:
		return 0.0
	if source_profile == "gorilla":
		return 0.45
	if source_profile == "lizard":
		return 0.3
	return 0.35


static func _generated_limb_combo_tags(source_profile: String, limb_key: String) -> Array[String]:
	var tags: Array[String] = [source_profile, _generated_limb_attack_type(limb_key)]
	if _generated_limb_combo_finisher(limb_key):
		tags.append("finisher")
	return tags


static func _generated_limb_combo_finisher(limb_key: String) -> bool:
	return limb_key == "body"


static func _generated_limb_weight(source_profile: String, limb_key: String) -> float:
	return _generated_limb_equipment_weight(source_profile, limb_key)


static func _generated_limb_weight_class(source_profile: String, limb_key: String) -> String:
	var equipment_weight: float = _generated_limb_equipment_weight(source_profile, limb_key)
	if equipment_weight >= 1.5:
		return "heavy"
	if equipment_weight >= 1.15:
		return "medium"
	return "light"


static func _generated_limb_physical_weight(source_profile: String, limb_key: String) -> float:
	var base_weight := 1.0
	match limb_key:
		"body":
			base_weight = 1.4
		"head":
			base_weight = 0.8
		"right_leg", "left_leg":
			base_weight = 1.1

	match source_profile:
		"gorilla":
			base_weight *= 1.45
		"lizard":
			base_weight *= 0.82
	return base_weight


static func _generated_limb_equipment_weight(source_profile: String, limb_key: String) -> float:
	return _generated_limb_physical_weight(source_profile, limb_key)


static func _generated_limb_inventory_weight(source_profile: String, limb_key: String) -> float:
	return _generated_limb_physical_weight(source_profile, limb_key) * 0.85


static func _generated_limb_set_id(source_profile: String) -> String:
	return source_profile + "_parts"


static func _generated_limb_set_name(source_profile: String) -> String:
	return str(SOURCE_DISPLAY.get(source_profile, "Enemy")) + " Parts"


static func _generated_limb_set_tags(source_profile: String) -> Array[String]:
	return [source_profile, "enemy_part"]


static func _generated_limb_synergy_ids(source_profile: String, limb_key: String) -> Array[String]:
	return [source_profile + "_parts", source_profile + "_" + limb_key]


static func _generated_limb_synergy_tags(source_profile: String, limb_key: String) -> Array[String]:
	return [source_profile, limb_key, str(LIMB_TO_SLOT.get(limb_key, ""))]


static func _generated_limb_synergy_score(source_profile: String, limb_key: String) -> float:
	if source_profile == "normal":
		return 0.1
	if limb_key == "body" or limb_key == "head":
		return 0.3
	return 0.2


static func _generated_limb_bonus(source_profile: String, limb_key: String) -> Dictionary:
	var bonus: Dictionary = PLAYER_BONUS_DEFAULTS.duplicate()
	match limb_key:
		"right_arm", "left_arm":
			bonus["attack_range"] = 0.8
			bonus["max_health"] = 1
		"right_leg", "left_leg":
			bonus["move_speed"] = 0.8
			bonus["max_health"] = 1
		"body":
			bonus["max_health"] = 2
		"head":
			bonus["attack_damage"] = 1

	match source_profile:
		"gorilla":
			bonus["move_speed"] = float(bonus["move_speed"]) - 0.4
			bonus["attack_damage"] = int(bonus["attack_damage"]) + 1
			if limb_key == "body":
				bonus["max_health"] = int(bonus["max_health"]) + 1
		"lizard":
			bonus["move_speed"] = float(bonus["move_speed"]) + 0.5
			if limb_key == "head":
				bonus["attack_range"] = float(bonus["attack_range"]) + 0.6
	return bonus


static func _generated_limb_visual_scale(source_profile: String, limb_key: String) -> Vector3:
	match source_profile:
		"gorilla":
			match limb_key:
				"right_arm", "left_arm":
					return Vector3(1.55, 1.35, 1.55)
				"right_leg", "left_leg":
					return Vector3(1.35, 1.0, 1.35)
				"body":
					return Vector3(1.45, 1.25, 1.45)
				"head":
					return Vector3(1.25, 1.15, 1.25)
		"lizard":
			match limb_key:
				"right_arm", "left_arm":
					return Vector3(0.78, 0.85, 0.78)
				"right_leg", "left_leg":
					return Vector3(0.82, 0.75, 1.18)
				"body":
					return Vector3(0.95, 0.7, 1.45)
				"head":
					return Vector3(0.9, 0.75, 1.25)
	return Vector3.ONE


static func _generated_limb_head_socket_offset(source_profile: String, limb_key: String) -> Vector3:
	if limb_key != "body":
		return Vector3.ZERO

	match source_profile:
		"gorilla":
			return Vector3(0.0, 0.54, -0.08)
		"lizard":
			return Vector3(0.0, 0.32, -0.36)
		_:
			return Vector3(0.0, 0.42, 0.0)
