class_name EquipmentRulesService

const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)
const PLAYER_BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}

const SLOT_DISPLAY := {
	"right_arm": "Right Arm",
	"left_arm": "Left Arm",
	"legs": "Legs",
	"body": "Body",
	"head": "Head",
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
	"legs": ["left_leg", "right_leg", "left_leg_lower", "right_leg_lower", "left_foot", "right_foot"],
	"body": ["body"],
	"head": ["head"],
}

const LIMB_TO_SLOT := {
	"right_arm": "right_arm",
	"left_arm": "left_arm",
	"right_leg": "legs",
	"left_leg": "legs",
	"body": "body",
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
	var definition: Dictionary = BoneDatabase.get_def(bone_id)
	if definition.is_empty():
		definition = generated_limb_definition_for(bone_id)
	return str(definition.get("slot", ""))


static func slot_display_name(slot_id: String) -> String:
	return str(SLOT_DISPLAY.get(slot_id, ""))


static func socket_keys_for_slot(slot_id: String) -> Array:
	return SLOT_TO_SOCKETS.get(slot_id, [])


static func primary_limb_keys_for_slot(slot_id: String) -> Array[String]:
	match slot_id:
		"right_arm":
			return ["right_arm", "left_arm"]
		"left_arm":
			return ["left_arm", "right_arm"]
		"legs":
			return ["right_leg", "left_leg"]
		"body":
			return ["body"]
		"head":
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


static func generated_limb_definition_for(bone_id: String) -> Dictionary:
	var parsed: Dictionary = _parse_generated_limb_bone_id(bone_id)
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
