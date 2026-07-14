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

const SLOT_TO_SOCKETS := {
	"right_arm": ["right_arm"],
	"left_arm": ["left_arm"],
	"legs": ["left_leg", "right_leg"],
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
		"rarity": _generated_limb_rarity(source_profile),
		"rarity_rank": _generated_limb_rarity_rank(source_profile),
		"rarity_color": _generated_limb_rarity_color(source_profile),
		"rarity_drop_weight": _generated_limb_rarity_drop_weight(source_profile),
		"color": color,
		"slot": slot_id,
		"source_profile": source_profile,
		"limb_key": limb_key,
		"visual_scale": _generated_limb_visual_scale(source_profile, limb_key),
		"visual_offset": Vector3.ZERO,
		"visual_rotation": Vector3.ZERO,
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
			return "Heavy"
		"lizard":
			return "Strange"
		_:
			return "Normal"


static func _generated_limb_quality_rank(source_profile: String) -> int:
	match source_profile:
		"gorilla":
			return 3
		"lizard":
			return 2
		_:
			return 1


static func _generated_limb_quality_score(source_profile: String) -> float:
	match source_profile:
		"gorilla":
			return 1.35
		"lizard":
			return 1.2
		_:
			return 1.0


static func _generated_limb_quality_multiplier(source_profile: String) -> float:
	return _generated_limb_quality_score(source_profile)


static func _generated_limb_quality_color(source_profile: String) -> Color:
	match source_profile:
		"gorilla":
			return Color(0.65, 0.42, 0.22, 1.0)
		"lizard":
			return Color(0.23, 0.78, 0.34, 1.0)
		_:
			return UNKNOWN_COLOR


static func _generated_limb_rarity(source_profile: String) -> String:
	match source_profile:
		"gorilla":
			return "Uncommon"
		"lizard":
			return "Uncommon"
		_:
			return "Common"


static func _generated_limb_rarity_rank(source_profile: String) -> int:
	match source_profile:
		"gorilla", "lizard":
			return 2
		_:
			return 1


static func _generated_limb_rarity_color(source_profile: String) -> Color:
	match source_profile:
		"gorilla", "lizard":
			return Color(0.35, 0.85, 0.95, 1.0)
		_:
			return UNKNOWN_COLOR


static func _generated_limb_rarity_drop_weight(source_profile: String) -> float:
	match source_profile:
		"gorilla", "lizard":
			return 0.65
		_:
			return 1.0


static func _generated_limb_bonus(source_profile: String, limb_key: String) -> Dictionary:
	var bonus: Dictionary = PLAYER_BONUS_DEFAULTS.duplicate()
	match limb_key:
		"right_arm", "left_arm":
			bonus["attack_range"] = 0.8
		"right_leg", "left_leg":
			bonus["move_speed"] = 0.8
		"body":
			bonus["max_health"] = 1
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
