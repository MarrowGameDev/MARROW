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
			"quality": "comun",
			"quality_rank": 2,
			"quality_score": 1.0,
			"quality_multiplier": 1.0,
			"quality_color": Color(1.0, 0.94, 0.68, 1.0),
			"quality_damage_percent": 0.0,
			"quality_speed_percent": 0.0,
			"quality_health_percent": 0.0,
			"quality_drop_percent": 0.0,
			"quality_weight_percent": 0.0,
			"rarity": "Common",
			"rarity_rank": 1,
			"rarity_color": Color(1.0, 0.94, 0.68, 1.0),
			"rarity_drop_weight": 1.0,
			"color": Color(1.0, 0.85, 0.18, 1.0),
			"slot": "right_arm",
			"tags": ["reach"],
			"description": "Longer reach on your swing.",
		},
		"visual": {
			"weight": 1.0,
			"weight_class": "light",
			"physical_weight": 1.0,
			"equipment_weight": 1.0,
			"inventory_weight": 0.8,
		},
		"attack_combo": {
			"attack_type": "melee",
			"attack_tags": ["melee", "reach"],
			"combo_family": "starter_strikes",
			"combo_step": 1,
			"combo_window": 0.35,
			"combo_tags": ["starter", "strike"],
			"combo_finisher": false,
		},
		"set": {
			"id": "starter_bones",
			"name": "Starter Bones",
			"piece_key": "arm",
			"tags": ["starter", "reach"],
		},
		"synergy": {
			"ids": ["starter_bones", "reach_bones"],
			"tags": ["starter", "reach", "right_arm"],
			"score": 0.15,
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
			"quality": "comun",
			"quality_rank": 2,
			"quality_score": 1.0,
			"quality_multiplier": 1.0,
			"quality_color": Color(1.0, 0.94, 0.68, 1.0),
			"quality_damage_percent": 0.0,
			"quality_speed_percent": 0.0,
			"quality_health_percent": 0.0,
			"quality_drop_percent": 0.0,
			"quality_weight_percent": 0.0,
			"rarity": "Common",
			"rarity_rank": 1,
			"rarity_color": Color(1.0, 0.94, 0.68, 1.0),
			"rarity_drop_weight": 1.0,
			"color": Color(0.25, 0.95, 0.55, 1.0),
			"slot": "legs",
			"tags": ["speed"],
			"description": "Faster movement.",
		},
		"visual": {
			"weight": 1.1,
			"weight_class": "medium",
			"physical_weight": 1.1,
			"equipment_weight": 1.1,
			"inventory_weight": 0.9,
		},
		"attack_combo": {
			"attack_type": "movement",
			"attack_tags": ["movement", "speed"],
			"combo_family": "starter_mobility",
			"combo_step": 0,
			"combo_window": 0.0,
			"combo_tags": ["starter", "mobility"],
			"combo_finisher": false,
		},
		"set": {
			"id": "starter_bones",
			"name": "Starter Bones",
			"piece_key": "legs",
			"tags": ["starter", "speed"],
		},
		"synergy": {
			"ids": ["starter_bones", "speed_bones"],
			"tags": ["starter", "speed", "legs"],
			"score": 0.15,
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
			"quality": "fuerte",
			"quality_rank": 3,
			"quality_score": 1.3,
			"quality_multiplier": 1.15,
			"quality_color": Color(0.35, 0.85, 0.95, 1.0),
			"quality_damage_percent": 0.12,
			"quality_speed_percent": -0.05,
			"quality_health_percent": 0.1,
			"quality_drop_percent": -0.05,
			"quality_weight_percent": 0.15,
			"rarity": "Uncommon",
			"rarity_rank": 2,
			"rarity_color": Color(0.35, 0.85, 0.95, 1.0),
			"rarity_drop_weight": 0.7,
			"color": Color(0.65, 0.35, 1.0, 1.0),
			"slot": "body",
			"tags": ["power"],
			"description": "More health and harder hits, but slows you down.",
		},
		"visual": {
			"weight": 2.0,
			"weight_class": "heavy",
			"physical_weight": 2.0,
			"equipment_weight": 2.0,
			"inventory_weight": 2.2,
			"visual_scale": Vector3(1.3, 1.3, 1.3),
		},
		"attack_combo": {
			"attack_type": "melee",
			"attack_tags": ["melee", "heavy"],
			"combo_family": "power_strikes",
			"combo_step": 3,
			"combo_window": 0.45,
			"combo_tags": ["power", "finisher"],
			"combo_finisher": true,
		},
		"set": {
			"id": "power_bones",
			"name": "Power Bones",
			"piece_key": "body",
			"tags": ["power", "heavy"],
		},
		"synergy": {
			"ids": ["power_bones", "body_bones"],
			"tags": ["power", "heavy", "body"],
			"score": 0.25,
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
			"quality": "chatarra",
			"quality_rank": 0,
			"quality_score": 0.75,
			"quality_multiplier": 0.9,
			"quality_color": Color(0.7, 0.68, 0.58, 1.0),
			"quality_damage_percent": -0.05,
			"quality_speed_percent": -0.05,
			"quality_health_percent": -0.05,
			"quality_drop_percent": 0.05,
			"quality_weight_percent": -0.05,
			"rarity": "Common",
			"rarity_rank": 1,
			"rarity_color": Color(1.0, 0.94, 0.68, 1.0),
			"rarity_drop_weight": 1.2,
			"color": Color(1.0, 0.94, 0.68, 1.0),
			"slot": "right_arm",
			"tags": [],
			"description": "A plain practice bone with no special effect.",
		},
		"visual": {
			"weight": 0.6,
			"weight_class": "light",
			"physical_weight": 0.6,
			"equipment_weight": 0.6,
			"inventory_weight": 0.5,
		},
		"attack_combo": {
			"attack_type": "training",
			"attack_tags": ["training"],
			"combo_family": "training",
			"combo_step": 0,
			"combo_window": 0.0,
			"combo_tags": ["training"],
			"combo_finisher": false,
		},
		"set": {
			"id": "training_bones",
			"name": "Training Bones",
			"piece_key": "arm",
			"tags": ["training"],
		},
		"synergy": {
			"ids": ["training_bones"],
			"tags": ["training", "right_arm"],
			"score": 0.0,
		},
	},
	"rib_bone": {
		"identity": {
			"display_name": "Rib Bone",
			"quality": "fuerte",
			"quality_rank": 3,
			"quality_score": 1.3,
			"quality_multiplier": 1.12,
			"quality_color": Color(0.35, 0.85, 0.95, 1.0),
			"quality_damage_percent": 0.05,
			"quality_speed_percent": 0.05,
			"quality_health_percent": 0.05,
			"quality_drop_percent": -0.05,
			"quality_weight_percent": 0.05,
			"rarity": "Rare",
			"rarity_rank": 3,
			"rarity_color": Color(0.65, 0.35, 1.0, 1.0),
			"rarity_drop_weight": 0.4,
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
		"mutation": {
			"id": "rib_hybrid",
			"family": "hybrid_growth",
			"stage": 1,
			"intensity": 0.25,
			"tags": ["hybrid", "adaptive"],
		},
		"visual": {
			"weight": 1.4,
			"weight_class": "medium",
			"physical_weight": 1.4,
			"equipment_weight": 1.4,
			"inventory_weight": 1.1,
		},
		"attack_combo": {
			"attack_type": "hybrid",
			"attack_tags": ["hybrid", "melee"],
			"combo_family": "hybrid_flow",
			"combo_step": 2,
			"combo_window": 0.4,
			"combo_tags": ["hybrid", "adaptive"],
			"combo_finisher": false,
		},
		"set": {
			"id": "hybrid_bones",
			"name": "Hybrid Bones",
			"piece_key": "body",
			"tags": ["hybrid", "adaptive"],
		},
		"synergy": {
			"ids": ["hybrid_bones", "body_bones"],
			"tags": ["hybrid", "adaptive", "body"],
			"score": 0.3,
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
