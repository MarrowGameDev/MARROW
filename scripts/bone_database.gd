class_name BoneDatabase

# Compatibility API for bone definitions.
#
# Gameplay code should keep reading through BoneDatabase or BoneRulesService.
# Hand-authored bone data now resolves through BoneDataCatalog, which loads
# BoneDefinition .tres assets first and uses dictionary data only as temporary
# fallback. Definitions get normalized here to the legacy flat fields that
# current systems already expect.

# Color used for any bone id that is not listed below (kept neutral/cream).
const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)

static var BONES: Dictionary = {}


static func _static_init() -> void:
	reload_from_catalog()


# True if the given id is a defined bone type.
static func has_bone(id: String) -> bool:
	return _bones().has(id)


# Every defined bone id, e.g. for iterating in tools or tests.
static func all_ids() -> Array:
	return _bones().keys()


static func definitions() -> Dictionary:
	return _bones()


# The full definition dictionary for an id, or an empty one if unknown.
static func get_def(id: String) -> Dictionary:
	if _bones().has(id):
		return _bones()[id]
	return {}


static func get_clean_def(id: String) -> Dictionary:
	return BoneDataCatalog.clean_definition_for(id)


static func get_resource(id: String) -> BoneDefinition:
	return BoneDataCatalog.resource_for(id)


static func reload_from_catalog() -> void:
	BONES = BoneDataCatalog.legacy_definitions()


static func reset_cache() -> void:
	reload_from_catalog()


static func display_name(id: String) -> String:
	if _bones().has(id):
		return _bones()[id]["display_name"]
	return "Unknown Bone"


static func display_name_with_slot(id: String) -> String:
	var base_name := display_name(id)
	var slot_label := slot_display_name(slot(id))
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


static func slot_display_name(slot_id: String) -> String:
	match slot_id:
		"right_arm":
			return "Right Arm"
		"left_arm":
			return "Left Arm"
		"body":
			return "Body"
		"legs":
			return "Legs"
		"head":
			return "Head"
		_:
			return ""


# The bone's color. Callers that want a different miss color (e.g. an enemy's
# natural red) can pass their own fallback for ids that are not defined.
static func color(id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	if _bones().has(id):
		return _bones()[id]["color"]
	return fallback


static func slot(id: String) -> String:
	if _bones().has(id):
		return _bones()[id]["slot"]
	return ""


static func move_speed_bonus(id: String) -> float:
	if _bones().has(id):
		return _bones()[id]["move_speed_bonus"]
	return 0.0


static func attack_range_bonus(id: String) -> float:
	if _bones().has(id):
		return _bones()[id]["attack_range_bonus"]
	return 0.0


static func attack_damage_bonus(id: String) -> int:
	if _bones().has(id):
		return _bones()[id]["attack_damage_bonus"]
	return 0


static func max_health_bonus(id: String) -> int:
	if _bones().has(id):
		return int(_bones()[id].get("max_health_bonus", 0))
	return 0


static func quality(id: String) -> String:
	if _bones().has(id):
		return _bones()[id].get("quality", "Normal")
	return "Unknown"


static func quality_rank(id: String) -> int:
	if _bones().has(id):
		return int(_bones()[id].get("quality_rank", 0))
	return 0


static func quality_score(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("quality_score", 0.0))
	return 0.0


static func quality_multiplier(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("quality_multiplier", 1.0))
	return 1.0


static func quality_color(id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	if _bones().has(id):
		var color_value: Variant = _bones()[id].get("quality_color", fallback)
		if color_value is Color:
			return color_value
	return fallback


static func rarity(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("rarity", "Common"))
	return "Unknown"


static func rarity_rank(id: String) -> int:
	if _bones().has(id):
		return int(_bones()[id].get("rarity_rank", 0))
	return 0


static func rarity_color(id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	if _bones().has(id):
		var color_value: Variant = _bones()[id].get("rarity_color", fallback)
		if color_value is Color:
			return color_value
	return fallback


static func rarity_drop_weight(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("rarity_drop_weight", 1.0))
	return 0.0


static func mutation_id(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("mutation_id", ""))
	return ""


static func mutation_family(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("mutation_family", ""))
	return ""


static func mutation_stage(id: String) -> int:
	if _bones().has(id):
		return int(_bones()[id].get("mutation_stage", 0))
	return 0


static func mutation_intensity(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("mutation_intensity", 0.0))
	return 0.0


static func mutation_tags(id: String) -> Array:
	if _bones().has(id):
		var value: Variant = _bones()[id].get("mutation_tags", [])
		if value is Array:
			var tags: Array = value
			return tags.duplicate()
	return []


static func attack_type(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("attack_type", "melee"))
	return ""


static func attack_tags(id: String) -> Array:
	if _bones().has(id):
		var value: Variant = _bones()[id].get("attack_tags", [])
		if value is Array:
			var tags: Array = value
			return tags.duplicate()
	return []


static func combo_family(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("combo_family", ""))
	return ""


static func combo_step(id: String) -> int:
	if _bones().has(id):
		return int(_bones()[id].get("combo_step", 0))
	return 0


static func combo_window(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("combo_window", 0.0))
	return 0.0


static func combo_tags(id: String) -> Array:
	if _bones().has(id):
		var value: Variant = _bones()[id].get("combo_tags", [])
		if value is Array:
			var tags: Array = value
			return tags.duplicate()
	return []


static func combo_finisher(id: String) -> bool:
	if _bones().has(id):
		return bool(_bones()[id].get("combo_finisher", false))
	return false


static func weight(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("weight", 1.0))
	return 1.0


static func weight_class(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("weight_class", "light"))
	return ""


static func physical_weight(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("physical_weight", weight(id)))
	return 0.0


static func equipment_weight(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("equipment_weight", weight(id)))
	return 0.0


static func inventory_weight(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("inventory_weight", weight(id)))
	return 0.0


static func set_id(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("set_id", ""))
	return ""


static func set_name(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("set_name", ""))
	return ""


static func set_piece_key(id: String) -> String:
	if _bones().has(id):
		return str(_bones()[id].get("set_piece_key", ""))
	return ""


static func set_tags(id: String) -> Array:
	if _bones().has(id):
		var value: Variant = _bones()[id].get("set_tags", [])
		if value is Array:
			var tags: Array = value
			return tags.duplicate()
	return []


static func synergy_ids(id: String) -> Array:
	if _bones().has(id):
		var value: Variant = _bones()[id].get("synergy_ids", [])
		if value is Array:
			var ids: Array = value
			return ids.duplicate()
	return []


static func synergy_tags(id: String) -> Array:
	if _bones().has(id):
		var value: Variant = _bones()[id].get("synergy_tags", [])
		if value is Array:
			var tags: Array = value
			return tags.duplicate()
	return []


static func synergy_score(id: String) -> float:
	if _bones().has(id):
		return float(_bones()[id].get("synergy_score", 0.0))
	return 0.0


static func enemy_float_bonus(id: String, key: String, fallback: float = 0.0) -> float:
	if _bones().has(id):
		return float(_bones()[id].get(key, fallback))
	return fallback


static func enemy_int_bonus(id: String, key: String, fallback: int = 0) -> int:
	if _bones().has(id):
		return int(_bones()[id].get(key, fallback))
	return fallback


static func description(id: String) -> String:
	if _bones().has(id):
		return _bones()[id]["description"]
	return ""


# Builds the "- +X move speed" style lines the inventory UI shows for a bone.
static func effect_text(id: String) -> String:
	var text := ""
	var move_bonus := move_speed_bonus(id)
	var range_bonus := attack_range_bonus(id)
	var damage_bonus := attack_damage_bonus(id)
	var health_bonus := max_health_bonus(id)

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


static func _format_signed_float(value: float) -> String:
	if value > 0.0:
		return "+" + str(value)
	return str(value)


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)


static func _bones() -> Dictionary:
	if BONES.is_empty():
		BONES = BoneDataCatalog.legacy_definitions()
	return BONES
