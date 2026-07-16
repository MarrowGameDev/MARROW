class_name BoneRulesService

const PLAYER_BONUS_DEFAULTS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}
const PLAYER_STAT_MODIFIER_DEFAULTS := {
	"damage_percent": 0.0,
	"speed_percent": 0.0,
	"health_percent": 0.0,
	"weight_percent": 0.0,
	"equipment_weight": 0.0,
	"inventory_weight": 0.0,
	"load_speed_penalty": 0.0,
}
const PLAYER_STAT_PERCENT_LIMIT := 0.75
const EQUIPMENT_FREE_WEIGHT := 3.0
const EQUIPMENT_LOAD_SPEED_PENALTY_PER_WEIGHT := 0.06
const EQUIPMENT_LOAD_SPEED_PENALTY_MAX := 0.30
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
	var base_name := BoneDatabase.display_name(bone_id)
	var slot_label := EquipmentRulesService.slot_display_name(EquipmentRulesService.slot_for_bone(bone_id))
	if slot_label == "":
		return base_name

	var clean_name := base_name
	if clean_name.ends_with(" Bone"):
		clean_name = clean_name.substr(0, clean_name.length() - " Bone".length())

	var clean_lower := clean_name.to_lower()
	var slot_lower := slot_label.to_lower()
	if slot_lower.contains(clean_lower):
		return slot_label + " Bone"
	return clean_name + " " + slot_label


static func quality_for(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("quality", BoneDefinition.QUALITY_COMMON))
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


static func quality_damage_percent_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("quality_damage_percent", 0.0))


static func quality_speed_percent_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("quality_speed_percent", 0.0))


static func quality_health_percent_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("quality_health_percent", 0.0))


static func quality_drop_percent_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("quality_drop_percent", 0.0))


static func quality_weight_percent_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("quality_weight_percent", 0.0))


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
		return str(definition.get("rarity", BoneDefinition.RARITY_COMMON))
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


static func attack_type_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("attack_type", "melee"))


static func attack_tags_for(bone_id: String) -> Array:
	var definition: Dictionary = definition_for(bone_id)
	var value: Variant = definition.get("attack_tags", [])
	if value is Array:
		var tags: Array = value
		return tags.duplicate()
	return []


static func combo_family_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("combo_family", ""))


static func combo_step_for(bone_id: String) -> int:
	var definition: Dictionary = definition_for(bone_id)
	return int(definition.get("combo_step", 0))


static func combo_window_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("combo_window", 0.0))


static func combo_tags_for(bone_id: String) -> Array:
	var definition: Dictionary = definition_for(bone_id)
	var value: Variant = definition.get("combo_tags", [])
	if value is Array:
		var tags: Array = value
		return tags.duplicate()
	return []


static func combo_finisher_for(bone_id: String) -> bool:
	var definition: Dictionary = definition_for(bone_id)
	return bool(definition.get("combo_finisher", false))


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


static func set_id_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("set_id", ""))


static func set_name_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("set_name", ""))


static func set_piece_key_for(bone_id: String) -> String:
	var definition: Dictionary = definition_for(bone_id)
	return str(definition.get("set_piece_key", ""))


static func set_tags_for(bone_id: String) -> Array:
	var definition: Dictionary = definition_for(bone_id)
	var value: Variant = definition.get("set_tags", [])
	if value is Array:
		var tags: Array = value
		return tags.duplicate()
	return []


static func synergy_ids_for(bone_id: String) -> Array:
	var definition: Dictionary = definition_for(bone_id)
	var value: Variant = definition.get("synergy_ids", [])
	if value is Array:
		var ids: Array = value
		return ids.duplicate()
	return []


static func synergy_tags_for(bone_id: String) -> Array:
	var definition: Dictionary = definition_for(bone_id)
	var value: Variant = definition.get("synergy_tags", [])
	if value is Array:
		var tags: Array = value
		return tags.duplicate()
	return []


static func synergy_score_for(bone_id: String) -> float:
	var definition: Dictionary = definition_for(bone_id)
	return float(definition.get("synergy_score", 0.0))


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


# Returns the quality-adjusted bonus for a single bone as floats. Callers
# that aggregate several bones must sum these floats first and round once
# at the end (see aggregate_player_bonuses): rounding attack_damage/max_health
# per bone before summing would let each bone's fraction round up
# independently (e.g. three bones at +0.5 would total +3 instead of the
# correct +2 for a combined +1.5), inflating stats with more equipped
# pieces even when the underlying bonus total is unchanged.
static func adjusted_player_bonus_for(bone_id: String) -> Dictionary:
	var bonus := player_bonus_for(bone_id)
	var multiplier := quality_multiplier_for(bone_id)
	return {
		"move_speed": float(bonus["move_speed"]) * multiplier,
		"attack_range": float(bonus["attack_range"]) * multiplier,
		"attack_damage": float(bonus["attack_damage"]) * multiplier,
		"max_health": float(bonus["max_health"]) * multiplier,
	}


static func aggregate_player_bonuses(equipment_state: Dictionary) -> Dictionary:
	var total: Dictionary = PLAYER_BONUS_DEFAULTS.duplicate()
	var attack_damage_total := 0.0
	var max_health_total := 0.0
	for slot_id in equipment_state:
		var bone_id: String = str(equipment_state[slot_id])
		if bone_id == "":
			continue
		var bonus: Dictionary = adjusted_player_bonus_for(bone_id)
		total["move_speed"] = float(total["move_speed"]) + float(bonus["move_speed"])
		total["attack_range"] = float(total["attack_range"]) + float(bonus["attack_range"])
		attack_damage_total += float(bonus["attack_damage"])
		max_health_total += float(bonus["max_health"])
	total["attack_damage"] = roundi(attack_damage_total)
	total["max_health"] = roundi(max_health_total)
	return total


static func aggregate_player_stat_modifiers(equipment_state: Dictionary) -> Dictionary:
	var total: Dictionary = PLAYER_STAT_MODIFIER_DEFAULTS.duplicate()
	for slot_id in equipment_state:
		var bone_id: String = str(equipment_state[slot_id])
		if bone_id == "":
			continue
		total["damage_percent"] = float(total["damage_percent"]) + quality_damage_percent_for(bone_id)
		total["speed_percent"] = float(total["speed_percent"]) + quality_speed_percent_for(bone_id)
		total["health_percent"] = float(total["health_percent"]) + quality_health_percent_for(bone_id)
		total["weight_percent"] = float(total["weight_percent"]) + quality_weight_percent_for(bone_id)

		var weight_multiplier := maxf(0.0, 1.0 + quality_weight_percent_for(bone_id))
		total["equipment_weight"] = float(total["equipment_weight"]) + equipment_weight_for(bone_id) * weight_multiplier
		total["inventory_weight"] = float(total["inventory_weight"]) + inventory_weight_for(bone_id) * weight_multiplier

	total["damage_percent"] = clampf(float(total["damage_percent"]), -PLAYER_STAT_PERCENT_LIMIT, PLAYER_STAT_PERCENT_LIMIT)
	total["speed_percent"] = clampf(float(total["speed_percent"]), -PLAYER_STAT_PERCENT_LIMIT, PLAYER_STAT_PERCENT_LIMIT)
	total["health_percent"] = clampf(float(total["health_percent"]), -PLAYER_STAT_PERCENT_LIMIT, PLAYER_STAT_PERCENT_LIMIT)
	total["weight_percent"] = clampf(float(total["weight_percent"]), -PLAYER_STAT_PERCENT_LIMIT, PLAYER_STAT_PERCENT_LIMIT)

	var load_over_free := maxf(0.0, float(total["equipment_weight"]) - EQUIPMENT_FREE_WEIGHT)
	total["load_speed_penalty"] = clampf(
		load_over_free * EQUIPMENT_LOAD_SPEED_PENALTY_PER_WEIGHT,
		0.0,
		EQUIPMENT_LOAD_SPEED_PENALTY_MAX
	)
	return total


static func player_stats_with_equipment(base_move_speed: float, base_attack_range: float, base_attack_damage: int, base_max_health: int, equipment_state: Dictionary) -> Dictionary:
	var bonus: Dictionary = aggregate_player_bonuses(equipment_state)
	var modifiers: Dictionary = aggregate_player_stat_modifiers(equipment_state)

	var move_before_percent := base_move_speed + float(bonus["move_speed"])
	var move_multiplier := maxf(
		0.1,
		(1.0 + float(modifiers["speed_percent"])) * (1.0 - float(modifiers["load_speed_penalty"]))
	)
	var damage_before_percent := float(base_attack_damage + int(bonus["attack_damage"]))
	var health_before_percent := float(base_max_health + int(bonus["max_health"]))
	return {
		"move_speed": maxf(0.0, move_before_percent * move_multiplier),
		"attack_range": base_attack_range + float(bonus["attack_range"]),
		"attack_damage": maxi(0, roundi(damage_before_percent * maxf(0.1, 1.0 + float(modifiers["damage_percent"])))),
		"max_health": maxi(1, roundi(health_before_percent * maxf(0.1, 1.0 + float(modifiers["health_percent"])))),
		"equipment_weight": float(modifiers["equipment_weight"]),
		"inventory_weight": float(modifiers["inventory_weight"]),
		"load_speed_penalty": float(modifiers["load_speed_penalty"]),
		"quality_damage_percent": float(modifiers["damage_percent"]),
		"quality_speed_percent": float(modifiers["speed_percent"]),
		"quality_health_percent": float(modifiers["health_percent"]),
		"quality_weight_percent": float(modifiers["weight_percent"]),
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
