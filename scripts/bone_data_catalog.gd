class_name BoneDataCatalog

# Clean authoring schema for hand-authored bones.
#
# Keep gameplay code reading through BoneDatabase/BoneRulesService. The current
# migration path is Resource first, dictionary fallback second: each id listed in
# RESOURCE_PATHS loads a .tres BoneDefinition, while DEFINITIONS keeps temporary
# fallback data until every bone is safely authored as a Resource.

const RESOURCE_PATHS := {
	"arm_bone": "res://data/bones/arm_bone.tres",
	"leg_bone": "res://data/bones/leg_bone.tres",
	"heavy_bone": "res://data/bones/heavy_bone.tres",
	"dummy_bone": "res://data/bones/dummy_bone.tres",
	"rib_bone": "res://data/bones/rib_bone.tres",
}

const DEFINITIONS := {
	"arm_bone": {
		"identity": {
			"display_name": "Arm Bone",
			"quality": "Normal",
			"quality_rank": 1,
			"quality_score": 1.0,
			"quality_multiplier": 1.0,
			"quality_color": Color(1.0, 0.94, 0.68, 1.0),
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
			"quality_rank": 1,
			"quality_score": 1.0,
			"quality_multiplier": 1.0,
			"quality_color": Color(1.0, 0.94, 0.68, 1.0),
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
			"quality_rank": 3,
			"quality_score": 1.35,
			"quality_multiplier": 1.15,
			"quality_color": Color(0.65, 0.35, 1.0, 1.0),
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
			"quality_rank": 0,
			"quality_score": 0.75,
			"quality_multiplier": 0.9,
			"quality_color": Color(0.7, 0.68, 0.58, 1.0),
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
			"quality_rank": 3,
			"quality_score": 1.3,
			"quality_multiplier": 1.12,
			"quality_color": Color(0.35, 0.85, 0.95, 1.0),
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
	var ids: Array[String] = []
	for id in RESOURCE_PATHS.keys():
		ids.append(str(id))
	for id in DEFINITIONS.keys():
		var clean_id: String = str(id)
		if not ids.has(clean_id):
			ids.append(clean_id)
	return ids


static func has_bone(id: String) -> bool:
	return RESOURCE_PATHS.has(id) or DEFINITIONS.has(id)


static func clean_definition_for(id: String) -> Dictionary:
	var resource: BoneDefinition = resource_for(id)
	if resource == null:
		return {}
	return resource.to_clean_dictionary()


static func resource_for(id: String) -> BoneDefinition:
	var resource: BoneDefinition = _load_resource_for(id)
	if resource != null:
		return resource

	if not DEFINITIONS.has(id):
		return null
	var definition: Dictionary = DEFINITIONS[id]
	return BoneDefinition.from_clean_dictionary(id, definition)


static func legacy_definitions() -> Dictionary:
	var result: Dictionary = {}
	for id in all_ids():
		result[id] = legacy_definition_for(str(id))
	return result


static func legacy_definition_for(id: String) -> Dictionary:
	var resource: BoneDefinition = resource_for(id)
	if resource == null:
		return {}
	return resource.to_legacy_dictionary()


static func _load_resource_for(id: String) -> BoneDefinition:
	if not RESOURCE_PATHS.has(id):
		return null

	var path: String = str(RESOURCE_PATHS[id])
	if not ResourceLoader.exists(path):
		return null

	var loaded: Resource = ResourceLoader.load(path)
	if loaded is BoneDefinition:
		var definition: BoneDefinition = loaded
		if definition.bone_id == "":
			definition.bone_id = id
		return definition

	return null
