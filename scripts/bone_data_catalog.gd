class_name BoneDataCatalog

# Clean authoring schema for hand-authored bones.
#
# Keep gameplay code reading through BoneDatabase/BoneRulesService. This catalog
# still stores temporary in-code data, but each entry is now converted through
# BoneDefinition so the next step can move authoring to .tres assets without
# changing inventory, equipment, combat, drops, or UI.

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
	var resource: BoneDefinition = resource_for(id)
	if resource == null:
		return {}
	return resource.to_clean_dictionary()


static func resource_for(id: String) -> BoneDefinition:
	if not DEFINITIONS.has(id):
		return null
	var definition: Dictionary = DEFINITIONS[id]
	return BoneDefinition.from_clean_dictionary(id, definition)


static func legacy_definitions() -> Dictionary:
	var result: Dictionary = {}
	for id in DEFINITIONS.keys():
		result[id] = legacy_definition_for(str(id))
	return result


static func legacy_definition_for(id: String) -> Dictionary:
	var resource: BoneDefinition = resource_for(id)
	if resource == null:
		return {}
	return resource.to_legacy_dictionary()
