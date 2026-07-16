class_name PlayerStatsComponent
extends Node

var base_move_speed: float = 0.0
var base_attack_range: float = 0.0
var base_attack_damage: int = 0
var base_max_health: int = 0


func setup(initial_move_speed: float, initial_attack_range: float, initial_attack_damage: int, initial_max_health: int) -> void:
	name = "PlayerStatsComponent"
	base_move_speed = initial_move_speed
	base_attack_range = initial_attack_range
	base_attack_damage = initial_attack_damage
	base_max_health = initial_max_health


func calculate(equipment_state: Dictionary, current_health: int, current_max_health: int) -> Dictionary:
	var calculated_stats: Dictionary = BoneRulesService.player_stats_with_equipment(
		base_move_speed,
		base_attack_range,
		base_attack_damage,
		base_max_health,
		equipment_state
	)
	var new_max_health: int = int(calculated_stats["max_health"])
	var new_health: int = current_health
	if current_max_health > 0 and new_max_health > current_max_health:
		new_health += new_max_health - current_max_health
	new_health = clampi(new_health, 0, new_max_health)

	return {
		"move_speed": float(calculated_stats["move_speed"]),
		"attack_range": float(calculated_stats["attack_range"]),
		"attack_damage": int(calculated_stats["attack_damage"]),
		"max_health": new_max_health,
		"health": new_health,
		"equipment_weight": float(calculated_stats.get("equipment_weight", 0.0)),
		"inventory_weight": float(calculated_stats.get("inventory_weight", 0.0)),
		"load_speed_penalty": float(calculated_stats.get("load_speed_penalty", 0.0)),
		"quality_damage_percent": float(calculated_stats.get("quality_damage_percent", 0.0)),
		"quality_speed_percent": float(calculated_stats.get("quality_speed_percent", 0.0)),
		"quality_health_percent": float(calculated_stats.get("quality_health_percent", 0.0)),
		"quality_weight_percent": float(calculated_stats.get("quality_weight_percent", 0.0)),
	}
