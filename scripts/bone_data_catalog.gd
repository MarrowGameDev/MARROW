class_name BoneDataCatalog

# Clean authoring schema for hand-authored bones.
#
# Keep gameplay code reading through BoneDatabase/BoneRulesService. This catalog
# is intentionally data-only so it can later move to JSON, Resources, or a
# spreadsheet export without changing inventory, equipment, combat, drops, or UI.

const DEFAULT_PLAYER_STATS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"attack_damage": 0,
	"max_health": 0,
}

const DEFAULT_ENEMY_STATS := {
	"move_speed": 0.0,
	"attack_range": 0.0,
	"contact_damage": 0,
	"max_health": 0,
	"detection_range": 0.0,
	"visual_scale": 1.0,
	"flee_chance": 0.45,
}

const DEFINITIONS := {
	"arm_bone": {
		"identity": {
			"display_name": "Arm Bone",
			"quality": "Normal",
			"color": Color(1.0, 0.85, 0.18, 1.0),
			"slot": "right_arm",
			"tags": ["reach"],
			"description": "Longer reach on your swing.",
		},
		"player_stats": {
			"attack_range": 2.5,
		},
		"enemy_stats": {
			"attack_range": 1.0,
			"detection_range": 1.0,
			"visual_scale": 1.05,
			"flee_chance": 0.35,
		},
	},
	"leg_bone": {
		"identity": {
			"display_name": "Leg Bone",
			"quality": "Normal",
			"color": Color(0.25, 0.95, 0.55, 1.0),
			"slot": "legs",
			"tags": ["speed"],
			"description": "Faster movement.",
		},
		"player_stats": {
			"move_speed": 3.0,
		},
		"enemy_stats": {
			"move_speed": 1.4,
			"detection_range": 2.0,
			"visual_scale": 0.95,
			"flee_chance": 1.0,
		},
	},
	"heavy_bone": {
		"identity": {
			"display_name": "Heavy Bone",
			"quality": "Strong",
			"color": Color(0.65, 0.35, 1.0, 1.0),
			"slot": "body",
			"tags": ["power"],
			"description": "More health and harder hits, but slows you down.",
		},
		"visual": {
			"weight": 2.0,
			"visual_scale": Vector3(1.3, 1.3, 1.3),
		},
		"player_stats": {
			"move_speed": -1.5,
			"attack_damage": 2,
			"max_health": 2,
		},
		"enemy_stats": {
			"move_speed": -0.5,
			"attack_range": 0.2,
			"contact_damage": 1,
			"max_health": 2,
			"visual_scale": 1.22,
			"flee_chance": 0.15,
		},
	},
	"dummy_bone": {
		"identity": {
			"display_name": "Training Bone",
			"quality": "Cracked",
			"color": Color(1.0, 0.94, 0.68, 1.0),
			"slot": "right_arm",
			"tags": [],
			"description": "A plain practice bone with no special effect.",
		},
	},
	"rib_bone": {
		"identity": {
			"display_name": "Rib Bone",
			"quality": "Strong",
			"color": Color(0.35, 0.85, 0.95, 1.0),
			"slot": "body",
			"tags": ["hybrid", "bonus"],
			"description": "A bit of everything: some extra reach and speed.",
		},
		"player_stats": {
			"move_speed": 1.5,
			"attack_range": 1.0,
			"max_health": 1,
		},
		"enemy_stats": {
			"move_speed": 0.7,
			"attack_range": 0.4,
			"max_health": 1,
			"detection_range": 1.0,
			"visual_scale": 1.08,
			"flee_chance": 0.55,
		},
	},
}


static func all_ids() -> Array:
	return DEFINITIONS.keys()


static func has_bone(id: String) -> bool:
	return DEFINITIONS.has(id)


static func clean_definition_for(id: String) -> Dictionary:
	if not DEFINITIONS.has(id):
		return {}
	var definition: Dictionary = DEFINITIONS[id]
	return _deep_duplicate_dictionary(definition)


static func legacy_definitions() -> Dictionary:
	var result: Dictionary = {}
	for id in DEFINITIONS.keys():
		result[id] = legacy_definition_for(str(id))
	return result


static func legacy_definition_for(id: String) -> Dictionary:
	var clean: Dictionary = clean_definition_for(id)
	if clean.is_empty():
		return {}

	var identity: Dictionary = _dictionary(clean, "identity")
	var visual: Dictionary = _dictionary(clean, "visual")
	var player_stats: Dictionary = _merged_stats(DEFAULT_PLAYER_STATS, _dictionary(clean, "player_stats"))
	var enemy_stats: Dictionary = _merged_stats(DEFAULT_ENEMY_STATS, _dictionary(clean, "enemy_stats"))

	var legacy: Dictionary = {
		"display_name": str(identity.get("display_name", "Unknown Bone")),
		"quality": str(identity.get("quality", "Normal")),
		"color": identity.get("color", Color(1.0, 0.94, 0.68, 1.0)),
		"slot": str(identity.get("slot", "")),
		"move_speed_bonus": float(player_stats.get("move_speed", 0.0)),
		"attack_range_bonus": float(player_stats.get("attack_range", 0.0)),
		"attack_damage_bonus": int(player_stats.get("attack_damage", 0)),
		"max_health_bonus": int(player_stats.get("max_health", 0)),
		"enemy_move_speed_bonus": float(enemy_stats.get("move_speed", 0.0)),
		"enemy_attack_range_bonus": float(enemy_stats.get("attack_range", 0.0)),
		"enemy_contact_damage_bonus": int(enemy_stats.get("contact_damage", 0)),
		"enemy_max_health_bonus": int(enemy_stats.get("max_health", 0)),
		"enemy_detection_range_bonus": float(enemy_stats.get("detection_range", 0.0)),
		"enemy_visual_scale": float(enemy_stats.get("visual_scale", 1.0)),
		"enemy_flee_chance": float(enemy_stats.get("flee_chance", 0.45)),
		"tags": _array(identity, "tags"),
		"description": str(identity.get("description", "")),
	}

	for key in visual.keys():
		legacy[key] = visual[key]
	return legacy


static func _dictionary(source: Dictionary, key: String) -> Dictionary:
	var value: Variant = source.get(key, {})
	if value is Dictionary:
		var dictionary_value: Dictionary = value
		return dictionary_value
	return {}


static func _array(source: Dictionary, key: String) -> Array:
	var value: Variant = source.get(key, [])
	if value is Array:
		var array_value: Array = value
		return array_value.duplicate()
	return []


static func _merged_stats(defaults: Dictionary, overrides: Dictionary) -> Dictionary:
	var result: Dictionary = defaults.duplicate()
	for key in overrides.keys():
		result[key] = overrides[key]
	return result


static func _deep_duplicate_dictionary(source: Dictionary) -> Dictionary:
	var copy: Dictionary = {}
	for key in source.keys():
		var value: Variant = source[key]
		if value is Dictionary:
			copy[key] = _deep_duplicate_dictionary(value)
		elif value is Array:
			copy[key] = value.duplicate()
		else:
			copy[key] = value
	return copy
