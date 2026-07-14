class_name BoneRulesService

const PLAYER_BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}
const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)


static func definition_for(bone_id: String) -> Dictionary:
	var definition: Dictionary = BoneDatabase.get_def(bone_id)
	if not definition.is_empty():
		return definition
	return EquipmentRulesService.generated_limb_definition_for(bone_id)


static func slot_for(bone_id: String) -> String:
	return EquipmentRulesService.slot_for_bone(bone_id)


static func slot_display_name(slot_id: String) -> String:
	return EquipmentRulesService.slot_display_name(slot_id)


static func display_name_with_slot(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("display_name", "Enemy Bone"))
	return BoneDatabase.display_name_with_slot(bone_id)


static func quality_for(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("quality", "Normal"))
	return BoneDatabase.quality(bone_id)


static func quality_rank_for(bone_id: String) -> int:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return int(definition.get("quality_rank", 1))
	return BoneDatabase.quality_rank(bone_id)


static func quality_score_for(bone_id: String) -> float:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return float(definition.get("quality_score", 1.0))
	return BoneDatabase.quality_score(bone_id)


static func quality_multiplier_for(bone_id: String) -> float:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return float(definition.get("quality_multiplier", 1.0))
	return BoneDatabase.quality_multiplier(bone_id)


static func quality_color_for(bone_id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		var color_value: Variant = definition.get("quality_color", fallback)
		if color_value is Color:
			return color_value
	return BoneDatabase.quality_color(bone_id, fallback)


static func rarity_for(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("rarity", "Common"))
	return BoneDatabase.rarity(bone_id)


static func rarity_rank_for(bone_id: String) -> int:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return int(definition.get("rarity_rank", 1))
	return BoneDatabase.rarity_rank(bone_id)


static func rarity_color_for(bone_id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		var color_value: Variant = definition.get("rarity_color", fallback)
		if color_value is Color:
			return color_value
	return BoneDatabase.rarity_color(bone_id, fallback)


static func rarity_drop_weight_for(bone_id: String) -> float:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return float(definition.get("rarity_drop_weight", 1.0))
	return BoneDatabase.rarity_drop_weight(bone_id)


static func mutation_id_for(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("mutation_id", ""))
	return BoneDatabase.mutation_id(bone_id)


static func mutation_family_for(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("mutation_family", ""))
	return BoneDatabase.mutation_family(bone_id)


static func mutation_stage_for(bone_id: String) -> int:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return int(definition.get("mutation_stage", 0))
	return BoneDatabase.mutation_stage(bone_id)


static func mutation_intensity_for(bone_id: String) -> float:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return float(definition.get("mutation_intensity", 0.0))
	return BoneDatabase.mutation_intensity(bone_id)


static func mutation_tags_for(bone_id: String) -> Array:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		var value: Variant = definition.get("mutation_tags", [])
		if value is Array:
			var tags: Array = value
			return tags.duplicate()
	return BoneDatabase.mutation_tags(bone_id)


static func weight_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("weight", 1.0))


static func weight_class_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("weight_class", "light"))


static func physical_weight_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("physical_weight", definition.get("weight", 1.0)))


static func equipment_weight_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("equipment_weight", definition.get("weight", 1.0)))


static func inventory_weight_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("inventory_weight", definition.get("weight", 1.0)))


static func color_for(bone_id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		var color_value: Variant = definition.get("color", fallback)
		if color_value is Color:
			return color_value
	return BoneDatabase.color(bone_id, fallback)


static func description_for(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
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
	return EquipmentRulesService.primary_limb_keys_for_slot(slot_id)


static func detachable_priority_for_bone(bone_id: String, detachable_limb_keys: Array[String], core_fall_order: Array[String]) -> Array[String]:
	var keys: Array[String] = DropPickupRulesService.detachable_priority_for_bone(bone_id)
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
	return DropPickupRulesService.pickup_limb_candidates_for_bone(bone_id)


static func drop_slot_matches_limb(bone_id: String, limb_key: String) -> bool:
	return DropPickupRulesService.drop_slot_matches_limb(bone_id, limb_key)


static func pickup_bone_id_for_limb(limb_key: String, source_profile: String = "normal") -> String:
	return DropPickupRulesService.pickup_bone_id_for_limb(limb_key, source_profile)


static func generated_limb_definition_for(bone_id: String) -> Dictionary:
	return EquipmentRulesService.generated_limb_definition_for(bone_id)


static func _format_signed_float(value: float) -> String:
	if value > 0.0:
		return "+" + str(value)
	return str(value)


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)
