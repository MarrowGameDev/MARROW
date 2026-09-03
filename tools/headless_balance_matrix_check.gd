extends SceneTree

# Contract test for combat-scale and build identity. All equipment results go
# through the production BoneRulesService; this file only derives hit counts.
#
# Run: godot --headless --path . --script tools/headless_balance_matrix_check.gd

const BASE_SPEED := 6.0
const BASE_REACH := 2.0
const BASE_DAMAGE := 10
const BASE_HEALTH := 50
const NORMAL_ENEMY_HEALTH := 40
const NORMAL_ENEMY_DAMAGE := 10


func _initialize() -> void:
	BoneInstanceService.reset(20260725)
	var failures: Array[String] = []
	var builds := {
		"Unequipped": {},
		"Starter": _state(["torso_bone", "arm_bone", "arm_bone", "leg_bone", "leg_bone"]),
		"Normal": _state(["normal_body_bone", "normal_left_arm_bone", "normal_right_arm_bone", "normal_left_leg_bone", "normal_right_leg_bone"]),
		"Gorilla": _state(["gorilla_body_bone", "gorilla_left_arm_bone", "gorilla_right_arm_bone", "gorilla_left_leg_bone", "gorilla_right_leg_bone"]),
		"Lizard": _state(["lizard_body_bone", "lizard_left_arm_bone", "lizard_right_arm_bone", "lizard_left_leg_bone", "lizard_right_leg_bone"]),
		"Heavy": _state(["heavy_bone", "normal_left_arm_bone", "normal_right_arm_bone", "normal_left_leg_bone", "normal_right_leg_bone"]),
		"Hybrid": _state(["rib_bone", "gorilla_left_arm_bone", "lizard_right_arm_bone", "normal_left_leg_bone", "lizard_right_leg_bone"]),
	}
	var results: Dictionary = {}

	print("BUILD       DMG  HP   SPEED  REACH  WEIGHT  LOAD%  HTK  HTD")
	for build_name in builds:
		var stats := _stats(builds[build_name])
		results[build_name] = stats
		print("%-11s %3d  %3d  %5.2f  %5.2f  %6.2f  %4.0f%%  %3d  %3d" % [
			build_name,
			int(stats["attack_damage"]),
			int(stats["max_health"]),
			float(stats["move_speed"]),
			float(stats["attack_range"]),
			float(stats["equipment_weight"]),
			float(stats["load_speed_penalty"]) * 100.0,
			_hits_to_kill(NORMAL_ENEMY_HEALTH, int(stats["attack_damage"])),
			_hits_to_kill(int(stats["max_health"]), NORMAL_ENEMY_DAMAGE),
		])

	var starter: Dictionary = results["Starter"]
	var normal: Dictionary = results["Normal"]
	var gorilla: Dictionary = results["Gorilla"]
	var lizard: Dictionary = results["Lizard"]
	var heavy: Dictionary = results["Heavy"]
	var hybrid: Dictionary = results["Hybrid"]
	_expect(int(gorilla["attack_damage"]) > int(normal["attack_damage"]), "Gorilla must out-damage Normal", failures)
	_expect(int(gorilla["attack_damage"]) > int(starter["attack_damage"]), "Gorilla must out-damage Starter", failures)
	_expect(_hits_to_kill(NORMAL_ENEMY_HEALTH, int(gorilla["attack_damage"])) >= 2, "Gorilla must not one-shot a normal enemy", failures)
	_expect(float(lizard["move_speed"]) > float(gorilla["move_speed"]), "Lizard must be faster than Gorilla", failures)
	_expect(int(lizard["max_health"]) < int(gorilla["max_health"]), "Lizard must be less durable than Gorilla", failures)
	_expect(int(heavy["max_health"]) > int(starter["max_health"]), "Heavy must be tougher than Starter", failures)
	_expect(float(heavy["move_speed"]) < float(starter["move_speed"]), "Heavy must pay a speed cost", failures)
	_expect(int(hybrid["attack_damage"]) < int(gorilla["attack_damage"]), "Hybrid must not beat the damage specialist", failures)
	_expect(float(hybrid["move_speed"]) < float(lizard["move_speed"]), "Hybrid must not beat the speed specialist", failures)
	_expect(int(hybrid["max_health"]) < int(gorilla["max_health"]), "Hybrid must not beat the health specialist", failures)

	for build_name in builds:
		var modifiers := BoneRulesService.aggregate_player_stat_modifiers(builds[build_name])
		for key in ["damage_percent", "speed_percent", "health_percent", "weight_percent"]:
			_expect(absf(float(modifiers[key])) < BoneRulesService.PLAYER_STAT_PERCENT_LIMIT, "%s hits the %s global clamp" % [build_name, key], failures)

	var normal_arm := _single_piece_stats("arm_bone", BoneQualityService.QUALITY_NORMAL)
	var pristine_arm := _single_piece_stats("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	_expect(float(pristine_arm["attack_range"]) >= float(normal_arm["attack_range"]), "Pristine cannot reduce a positive arm bonus", failures)
	_expect(float(pristine_arm["attack_range"]) - float(normal_arm["attack_range"]) <= 0.04, "Pristine arm exceeds the 10% quality budget", failures)

	if failures.is_empty():
		print("BALANCE MATRIX CHECK: PASS")
		quit(0)
	else:
		print("BALANCE MATRIX CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)
		quit(1)


func _state(bone_ids: Array) -> Dictionary:
	var state: Dictionary = {}
	for bone_id_value in bone_ids:
		var bone_id := str(bone_id_value)
		var piece := BoneInstanceService.create_instance(bone_id, BoneQualityService.QUALITY_NORMAL)
		var slot := EquipmentRulesService.slot_for_bone(piece)
		if bone_id in ["arm_bone", "dummy_bone"]:
			slot = EquipmentRulesService.SLOT_LEFT_ARM if not state.has(EquipmentRulesService.SLOT_LEFT_ARM) else EquipmentRulesService.SLOT_RIGHT_ARM
		elif bone_id == "leg_bone":
			slot = EquipmentRulesService.SLOT_LEFT_LEG if not state.has(EquipmentRulesService.SLOT_LEFT_LEG) else EquipmentRulesService.SLOT_RIGHT_LEG
		state[slot] = piece
	return state


func _stats(state: Dictionary) -> Dictionary:
	return BoneRulesService.player_stats_with_equipment(BASE_SPEED, BASE_REACH, BASE_DAMAGE, BASE_HEALTH, state)


func _single_piece_stats(bone_id: String, quality_id: String) -> Dictionary:
	var piece := BoneInstanceService.create_instance(bone_id, quality_id)
	return _stats({EquipmentRulesService.slot_for_bone(piece): piece})


func _hits_to_kill(health: int, damage: int) -> int:
	return ceili(float(health) / float(maxi(1, damage)))


func _expect(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
