class_name BoneDatabase

# Compatibility API for bone definitions.
#
# Gameplay code should keep reading through BoneDatabase or BoneRulesService.
# Hand-authored bone data now lives in BoneDataCatalog using a cleaner nested
# schema, then gets normalized here to the legacy flat fields that current
# systems already expect.

# Color used for any bone id that is not listed below (kept neutral/cream).
const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)

static var BONES: Dictionary = {}


# True if the given id is a defined bone type.
static func has_bone(id: String) -> bool:
	return _bones().has(id)


# Every defined bone id, e.g. for iterating in tools or tests.
static func all_ids() -> Array:
	return _bones().keys()


# The full definition dictionary for an id, or an empty one if unknown.
static func get_def(id: String) -> Dictionary:
	if _bones().has(id):
		return _bones()[id]
	return {}


static func get_clean_def(id: String) -> Dictionary:
	return BoneDataCatalog.clean_definition_for(id)


static func reload_from_catalog() -> void:
	BONES = BoneDataCatalog.legacy_definitions()


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
