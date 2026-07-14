class_name BoneRulesService

const PLAYER_BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}
const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)


static func definition_for(bone_id: String) -> Dictionary:
	return BoneDatabase.get_def(bone_id)


static func slot_for(bone_id: String) -> String:
	return BoneDatabase.slot(bone_id)


static func slot_display_name(slot_id: String) -> String:
	return BoneDatabase.slot_display_name(slot_id)


static func display_name_with_slot(bone_id: String) -> String:
	return BoneDatabase.display_name_with_slot(bone_id)


static func quality_for(bone_id: String) -> String:
	return BoneDatabase.quality(bone_id)


static func color_for(bone_id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	return BoneDatabase.color(bone_id, fallback)


static func description_for(bone_id: String) -> String:
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


static func _format_signed_float(value: float) -> String:
	if value > 0.0:
		return "+" + str(value)
	return str(value)


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)
