class_name BoneDefinition
extends Resource

# Resource version of a hand-authored bone.
#
# Designers can later create .tres assets from this type. Runtime code should
# still read through BoneDatabase/BoneRulesService while the migration is in
# progress.

const DEFAULT_COLOR := Color(1.0, 0.94, 0.68, 1.0)

@export_group("Identity")
@export var bone_id: String = ""
@export var display_name: String = "Unknown Bone"
@export var quality: String = "Normal"
@export var quality_rank: int = 1
@export var quality_score: float = 1.0
@export var quality_multiplier: float = 1.0
@export var quality_color: Color = DEFAULT_COLOR
@export var rarity: String = "Common"
@export var rarity_rank: int = 1
@export var rarity_color: Color = DEFAULT_COLOR
@export var rarity_drop_weight: float = 1.0
@export var color: Color = DEFAULT_COLOR
@export var slot: String = ""
@export var tags: Array[String] = []
@export_multiline var description: String = ""

@export_group("Mutation")
@export var mutation_id: String = ""
@export var mutation_family: String = ""
@export var mutation_stage: int = 0
@export_range(0.0, 1.0, 0.01) var mutation_intensity: float = 0.0
@export var mutation_tags: Array[String] = []

@export_group("Set / Synergy")
@export var set_id: String = ""
@export var set_name: String = ""
@export var set_piece_key: String = ""
@export var set_tags: Array[String] = []
@export var synergy_ids: Array[String] = []
@export var synergy_tags: Array[String] = []
@export var synergy_score: float = 0.0

@export_group("Player Stats")
@export var player_move_speed: float = 0.0
@export var player_attack_range: float = 0.0
@export var player_attack_damage: int = 0
@export var player_max_health: int = 0

@export_group("Enemy Stats")
@export var enemy_move_speed: float = 0.0
@export var enemy_attack_range: float = 0.0
@export var enemy_contact_damage: int = 0
@export var enemy_max_health: int = 0
@export var enemy_detection_range: float = 0.0
@export var enemy_visual_scale: float = 1.0
@export_range(0.0, 1.0, 0.01) var enemy_flee_chance: float = 0.45

@export_group("Visual")
@export var weight: float = 1.0
@export var weight_class: String = "light"
@export var physical_weight: float = 1.0
@export var equipment_weight: float = 1.0
@export var inventory_weight: float = 1.0
@export var visual_scale: Vector3 = Vector3.ONE
@export var visual_offset: Vector3 = Vector3.ZERO
@export var visual_rotation: Vector3 = Vector3.ZERO


func to_clean_dictionary() -> Dictionary:
	var visual: Dictionary = {
		"weight": weight,
		"weight_class": weight_class,
		"physical_weight": physical_weight,
		"equipment_weight": equipment_weight,
		"inventory_weight": inventory_weight,
		"visual_scale": visual_scale,
	}
	if visual_offset != Vector3.ZERO:
		visual["visual_offset"] = visual_offset
	if visual_rotation != Vector3.ZERO:
		visual["visual_rotation"] = visual_rotation

	return {
		"identity": {
			"display_name": display_name,
			"quality": quality,
			"quality_rank": quality_rank,
			"quality_score": quality_score,
			"quality_multiplier": quality_multiplier,
			"quality_color": quality_color,
			"rarity": rarity,
			"rarity_rank": rarity_rank,
			"rarity_color": rarity_color,
			"rarity_drop_weight": rarity_drop_weight,
			"color": color,
			"slot": slot,
			"tags": tags.duplicate(),
			"description": description,
		},
		"player_stats": {
			"move_speed": player_move_speed,
			"attack_range": player_attack_range,
			"attack_damage": player_attack_damage,
			"max_health": player_max_health,
		},
		"mutation": {
			"id": mutation_id,
			"family": mutation_family,
			"stage": mutation_stage,
			"intensity": mutation_intensity,
			"tags": mutation_tags.duplicate(),
		},
		"set": {
			"id": set_id,
			"name": set_name,
			"piece_key": set_piece_key,
			"tags": set_tags.duplicate(),
		},
		"synergy": {
			"ids": synergy_ids.duplicate(),
			"tags": synergy_tags.duplicate(),
			"score": synergy_score,
		},
		"enemy_stats": {
			"move_speed": enemy_move_speed,
			"attack_range": enemy_attack_range,
			"contact_damage": enemy_contact_damage,
			"max_health": enemy_max_health,
			"detection_range": enemy_detection_range,
			"visual_scale": enemy_visual_scale,
			"flee_chance": enemy_flee_chance,
		},
		"visual": visual,
	}


func to_legacy_dictionary() -> Dictionary:
	var legacy: Dictionary = {
		"display_name": display_name,
		"quality": quality,
		"quality_rank": quality_rank,
		"quality_score": quality_score,
		"quality_multiplier": quality_multiplier,
		"quality_color": quality_color,
		"rarity": rarity,
		"rarity_rank": rarity_rank,
		"rarity_color": rarity_color,
		"rarity_drop_weight": rarity_drop_weight,
		"mutation_id": mutation_id,
		"mutation_family": mutation_family,
		"mutation_stage": mutation_stage,
		"mutation_intensity": mutation_intensity,
		"mutation_tags": mutation_tags.duplicate(),
		"set_id": set_id,
		"set_name": set_name,
		"set_piece_key": set_piece_key,
		"set_tags": set_tags.duplicate(),
		"synergy_ids": synergy_ids.duplicate(),
		"synergy_tags": synergy_tags.duplicate(),
		"synergy_score": synergy_score,
		"color": color,
		"slot": slot,
		"move_speed_bonus": player_move_speed,
		"attack_range_bonus": player_attack_range,
		"attack_damage_bonus": player_attack_damage,
		"max_health_bonus": player_max_health,
		"enemy_move_speed_bonus": enemy_move_speed,
		"enemy_attack_range_bonus": enemy_attack_range,
		"enemy_contact_damage_bonus": enemy_contact_damage,
		"enemy_max_health_bonus": enemy_max_health,
		"enemy_detection_range_bonus": enemy_detection_range,
		"enemy_visual_scale": enemy_visual_scale,
		"enemy_flee_chance": enemy_flee_chance,
		"tags": tags.duplicate(),
		"description": description,
		"weight_class": weight_class,
		"physical_weight": physical_weight,
		"equipment_weight": equipment_weight,
		"inventory_weight": inventory_weight,
	}

	if weight != 1.0:
		legacy["weight"] = weight
	if visual_scale != Vector3.ONE:
		legacy["visual_scale"] = visual_scale
	if visual_offset != Vector3.ZERO:
		legacy["visual_offset"] = visual_offset
	if visual_rotation != Vector3.ZERO:
		legacy["visual_rotation"] = visual_rotation

	return legacy


static func from_clean_dictionary(id: String, clean: Dictionary) -> BoneDefinition:
	var definition := BoneDefinition.new()
	definition.bone_id = id

	var identity: Dictionary = _dictionary(clean, "identity")
	var player_stats: Dictionary = _dictionary(clean, "player_stats")
	var mutation: Dictionary = _dictionary(clean, "mutation")
	var set_data: Dictionary = _dictionary(clean, "set")
	var synergy: Dictionary = _dictionary(clean, "synergy")
	var enemy_stats: Dictionary = _dictionary(clean, "enemy_stats")
	var visual: Dictionary = _dictionary(clean, "visual")

	definition.display_name = str(identity.get("display_name", definition.display_name))
	definition.quality = str(identity.get("quality", definition.quality))
	definition.quality_rank = int(identity.get("quality_rank", definition.quality_rank))
	definition.quality_score = float(identity.get("quality_score", definition.quality_score))
	definition.quality_multiplier = float(identity.get("quality_multiplier", definition.quality_multiplier))
	definition.quality_color = _color(identity.get("quality_color", definition.quality_color), definition.quality_color)
	definition.rarity = str(identity.get("rarity", definition.rarity))
	definition.rarity_rank = int(identity.get("rarity_rank", definition.rarity_rank))
	definition.rarity_color = _color(identity.get("rarity_color", definition.rarity_color), definition.rarity_color)
	definition.rarity_drop_weight = float(identity.get("rarity_drop_weight", definition.rarity_drop_weight))
	definition.color = _color(identity.get("color", definition.color), definition.color)
	definition.slot = str(identity.get("slot", definition.slot))
	definition.tags = _string_array(identity.get("tags", []))
	definition.description = str(identity.get("description", definition.description))

	definition.mutation_id = str(mutation.get("id", definition.mutation_id))
	definition.mutation_family = str(mutation.get("family", definition.mutation_family))
	definition.mutation_stage = int(mutation.get("stage", definition.mutation_stage))
	definition.mutation_intensity = float(mutation.get("intensity", definition.mutation_intensity))
	definition.mutation_tags = _string_array(mutation.get("tags", []))

	definition.set_id = str(set_data.get("id", definition.set_id))
	definition.set_name = str(set_data.get("name", definition.set_name))
	definition.set_piece_key = str(set_data.get("piece_key", definition.set_piece_key))
	definition.set_tags = _string_array(set_data.get("tags", []))
	definition.synergy_ids = _string_array(synergy.get("ids", []))
	definition.synergy_tags = _string_array(synergy.get("tags", []))
	definition.synergy_score = float(synergy.get("score", definition.synergy_score))

	definition.player_move_speed = float(player_stats.get("move_speed", definition.player_move_speed))
	definition.player_attack_range = float(player_stats.get("attack_range", definition.player_attack_range))
	definition.player_attack_damage = int(player_stats.get("attack_damage", definition.player_attack_damage))
	definition.player_max_health = int(player_stats.get("max_health", definition.player_max_health))

	definition.enemy_move_speed = float(enemy_stats.get("move_speed", definition.enemy_move_speed))
	definition.enemy_attack_range = float(enemy_stats.get("attack_range", definition.enemy_attack_range))
	definition.enemy_contact_damage = int(enemy_stats.get("contact_damage", definition.enemy_contact_damage))
	definition.enemy_max_health = int(enemy_stats.get("max_health", definition.enemy_max_health))
	definition.enemy_detection_range = float(enemy_stats.get("detection_range", definition.enemy_detection_range))
	definition.enemy_visual_scale = float(enemy_stats.get("visual_scale", definition.enemy_visual_scale))
	definition.enemy_flee_chance = float(enemy_stats.get("flee_chance", definition.enemy_flee_chance))

	definition.weight = float(visual.get("weight", definition.weight))
	definition.weight_class = str(visual.get("weight_class", definition.weight_class))
	definition.physical_weight = float(visual.get("physical_weight", visual.get("weight", definition.physical_weight)))
	definition.equipment_weight = float(visual.get("equipment_weight", visual.get("weight", definition.equipment_weight)))
	definition.inventory_weight = float(visual.get("inventory_weight", visual.get("weight", definition.inventory_weight)))
	definition.visual_scale = _vector3(visual.get("visual_scale", definition.visual_scale), definition.visual_scale)
	definition.visual_offset = _vector3(visual.get("visual_offset", definition.visual_offset), definition.visual_offset)
	definition.visual_rotation = _vector3(visual.get("visual_rotation", definition.visual_rotation), definition.visual_rotation)

	return definition


static func _dictionary(source: Dictionary, key: String) -> Dictionary:
	var value: Variant = source.get(key, {})
	if value is Dictionary:
		var dictionary_value: Dictionary = value
		return dictionary_value
	return {}


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		var source: Array = value
		for item in source:
			result.append(str(item))
	return result


static func _color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		var color_value: Color = value
		return color_value
	return fallback


static func _vector3(value: Variant, fallback: Vector3) -> Vector3:
	if value is Vector3:
		var vector_value: Vector3 = value
		return vector_value
	return fallback
