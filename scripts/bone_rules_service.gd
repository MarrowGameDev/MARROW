class_name BoneRulesService

const PLAYER_BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}
const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)
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


static func definition_for(bone_id: String) -> Dictionary:
	var definition: Dictionary = BoneDatabase.get_def(bone_id)
	if not definition.is_empty():
		return definition
	return generated_limb_definition_for(bone_id)


static func slot_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("slot", ""))


static func slot_display_name(slot_id: String) -> String:
	return BoneDatabase.slot_display_name(slot_id)


static func display_name_with_slot(bone_id: String) -> String:
	var definition: Dictionary = generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("display_name", "Enemy Bone"))
	return BoneDatabase.display_name_with_slot(bone_id)


static func quality_for(bone_id: String) -> String:
	var definition: Dictionary = generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("quality", "Normal"))
	return BoneDatabase.quality(bone_id)


static func color_for(bone_id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	var definition: Dictionary = generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		var color_value: Variant = definition.get("color", fallback)
		if color_value is Color:
			return color_value
	return BoneDatabase.color(bone_id, fallback)


static func description_for(bone_id: String) -> String:
	var definition: Dictionary = generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("description", ""))
	return BoneDatabase.description(bone_id)


static func effect_text_for(bone_id: String) -> String:
	var text: String = ""
	var bonus: Dictionary = player_bonus_for(bone_id)
	var move_bonus: float = float(bonus.get("move_speed", 0.0))
	var range_bonus: float = float(bonus.get("attack_range", 0.0))
	var damage_bonus: int = int(bonus.get("attack_damage", 0))
	var health_bonus: int = int(bonus.get("max_health", 0))

	if move_bonus != 0.0:
		text += "- " + _format_signed_float(move_bonus) + " move speed\n"
	if range_bonus != 0.0:
		text += "- " + _format_signed_float(range_bonus) + " attack range\n"
	if damage_bonus != 0:
		text += "- " + _format_signed_int(damage_bonus) + " attack damage\n"
	if health_bonus != 0:
		text += "- " + _format_signed_int(health_bonus) + " max health\n"

	if text == "":
		text = "- No effect\n"
	return text


static func player_bonus_for(bone_id: String) -> Dictionary:
	var definition: Dictionary = definition_for(bone_id)
	if definition.is_empty():
		return PLAYER_BONUS_DEFAULTS.duplicate()

	return {
		"move_speed": float(definition.get("move_speed_bonus", 0.0)),
		"attack_range": float(definition.get("attack_range_bonus", 0.0)),
		"attack_damage": int(definition.get("attack_damage_bonus", 0)),
		"max_health": int(definition.get("max_health_bonus", 0)),
	}


static func aggregate_player_bonuses(equipment_state: Dictionary) -> Dictionary:
	var total: Dictionary = PLAYER_BONUS_DEFAULTS.duplicate()
	for slot_id in equipment_state:
		var bone_id: String = str(equipment_state[slot_id])
		var bonus: Dictionary = player_bonus_for(bone_id)
		total["move_speed"] = float(total["move_speed"]) + float(bonus["move_speed"])
		total["attack_range"] = float(total["attack_range"]) + float(bonus["attack_range"])
		total["attack_damage"] = int(total["attack_damage"]) + int(bonus["attack_damage"])
		total["max_health"] = int(total["max_health"]) + int(bonus["max_health"])
	return total


static func player_stats_with_equipment(base_move_speed: float, base_attack_range: float, base_attack_damage: int, base_max_health: int, equipment_state: Dictionary) -> Dictionary:
	var bonus: Dictionary = aggregate_player_bonuses(equipment_state)
	return {
		"move_speed": base_move_speed + float(bonus["move_speed"]),
		"attack_range": base_attack_range + float(bonus["attack_range"]),
		"attack_damage": base_attack_damage + int(bonus["attack_damage"]),
		"max_health": base_max_health + int(bonus["max_health"]),
	}


static func enemy_profile_for(bone_id: String, fallback_flee_chance: float) -> Dictionary:
	var definition: Dictionary = definition_for(bone_id)
	return {
		"is_defined": not definition.is_empty(),
		"move_speed_bonus": float(definition.get("enemy_move_speed_bonus", 0.0)),
		"attack_range_bonus": float(definition.get("enemy_attack_range_bonus", 0.0)),
		"contact_damage_bonus": int(definition.get("enemy_contact_damage_bonus", 0)),
		"max_health_bonus": int(definition.get("enemy_max_health_bonus", 0)),
		"detection_range_bonus": float(definition.get("enemy_detection_range_bonus", 0.0)),
		"flee_chance": float(definition.get("enemy_flee_chance", fallback_flee_chance)),
		"visual_scale": float(definition.get("enemy_visual_scale", 1.0)),
	}


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


static func detachable_priority_for_bone(bone_id: String, detachable_limb_keys: Array[String], core_fall_order: Array[String]) -> Array[String]:
	var keys: Array[String] = []
	for limb_key in primary_limb_keys_for_slot(slot_for(bone_id)):
		if core_fall_order.has(limb_key):
			continue
		if not keys.has(limb_key):
			keys.append(limb_key)
	for limb_key in detachable_limb_keys:
		if core_fall_order.has(limb_key):
			continue
		if not keys.has(limb_key):
			keys.append(limb_key)
	for core_key in core_fall_order:
		if not keys.has(core_key):
			keys.append(core_key)
	return keys


static func pickup_limb_candidates_for_bone(bone_id: String) -> Array[String]:
	return primary_limb_keys_for_slot(slot_for(bone_id))


static func drop_slot_matches_limb(bone_id: String, limb_key: String) -> bool:
	return primary_limb_keys_for_slot(slot_for(bone_id)).has(limb_key)


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


static func _format_signed_float(value: float) -> String:
	if value > 0.0:
		return "+" + str(value)
	return str(value)


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)
