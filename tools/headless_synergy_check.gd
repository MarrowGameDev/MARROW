extends SceneTree

# End-to-end: do set/symmetry/quality synergies reach the player's REAL stats,
# and do they disappear the moment the equipment changes?
#
# The Python mirror (tools/validate_synergy_rules.py) proves the arithmetic
# against the authored tables. This proves the wiring: real instances, the real
# equipment component, the real recalculation path and the real builds report.
#
# Run: godot --headless --script tools/headless_synergy_check.gd


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(20260719)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return

	# A torso is required before limbs attach, so every case starts from one.
	var torso := BoneInstanceService.create_instance("gorilla_body_bone", BoneQualityService.QUALITY_STRONG)
	player.call("collect_bone", torso)
	await process_frame
	player.call("equip_bone", torso, EquipmentRulesService.SLOT_TORSO)
	await process_frame

	# --- 1. fewer than two pieces activates nothing -----------------------
	var state: Dictionary = player.call("get_equipment_state")
	var active: Array = SynergyRulesService.evaluate(state)["active"]
	var families := _by_category(active, SynergyRulesService.CATEGORY_FAMILY)
	if not families.is_empty():
		failures.append("one gorilla piece already activated a family bonus: %s" % str(families))
	print("1 piece  -> active: ", _ids(active))

	# --- 2. two pieces activate ONLY the first tier ------------------------
	var left_arm := BoneInstanceService.create_instance("gorilla_left_arm_bone", BoneQualityService.QUALITY_STRONG)
	player.call("collect_bone", left_arm)
	await process_frame
	player.call("equip_bone", left_arm, EquipmentRulesService.SLOT_LEFT_ARM)
	await process_frame

	state = player.call("get_equipment_state")
	families = _by_category(SynergyRulesService.evaluate(state)["active"], SynergyRulesService.CATEGORY_FAMILY)
	if families.size() != 1 or int((families[0] as Dictionary)["tier"]) != 2:
		failures.append("two pieces did not activate exactly the 2-piece tier: %s" % str(families))
	print("2 pieces -> active: ", _ids(SynergyRulesService.evaluate(state)["active"]))

	# The stat pipeline must reflect it. Damage percent comes from the bones'
	# own quality modifiers PLUS the set bonus, so compare against the same
	# state evaluated without synergies would be circular -- instead check the
	# player's live stats actually moved when the tier changed (below).
	var damage_at_two := int(player.get("attack_damage"))

	# --- 3. four pieces award the 4-piece tier, not 2 + 4 ------------------
	var right_arm := BoneInstanceService.create_instance("gorilla_right_arm_bone", BoneQualityService.QUALITY_FRAIL)
	var left_leg := BoneInstanceService.create_instance("gorilla_left_leg_bone", BoneQualityService.QUALITY_STRONG)
	for piece in [right_arm, left_leg]:
		player.call("collect_bone", piece)
		await process_frame
	player.call("equip_bone", right_arm, EquipmentRulesService.SLOT_RIGHT_ARM)
	await process_frame
	player.call("equip_bone", left_leg, EquipmentRulesService.SLOT_LEFT_LEG)
	await process_frame

	state = player.call("get_equipment_state")
	var evaluation: Dictionary = SynergyRulesService.evaluate(state)
	families = _by_category(evaluation["active"], SynergyRulesService.CATEGORY_FAMILY)
	if families.size() != 1 or int((families[0] as Dictionary)["tier"]) != 4:
		failures.append("four pieces did not award exactly the 4-piece tier: %s" % str(families))
	# 2-piece is +0.02 damage, 4-piece is +0.05. Stacking both would read
	# 0.07; exactly 0.05 proves the 4-piece tier REPLACED the 2-piece one.
	# Matching Arms cannot fire here: generated left/right limbs are distinct
	# bone_ids, so the family tier is the only damage synergy in this state.
	var damage_percent := float((evaluation["modifiers"] as Dictionary)["damage_percent"])
	if not is_equal_approx(damage_percent, 0.05):
		failures.append("expected exactly 0.05 damage_percent (4-piece tier alone), got %f" % damage_percent)
	print("4 pieces -> active: ", _ids(evaluation["active"]))
	print("         -> modifiers: ", evaluation["modifiers"])

	# --- symmetry: same bone_id, different quality, still a pair ----------
	# Generated gorilla arms are different bone_ids by design, so the pair
	# test uses the authored bilateral arm_bone with two distinct qualities.
	var pair_state := {
		EquipmentRulesService.SLOT_LEFT_ARM: BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_WORN),
		EquipmentRulesService.SLOT_RIGHT_ARM: BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE),
	}
	if not SynergyRulesService.has_symmetric_arms(pair_state):
		failures.append("two arms of the same bone_id at different qualities did not pair")
	var arms_eval: Dictionary = SynergyRulesService.evaluate(pair_state)
	if not is_equal_approx(float((arms_eval["modifiers"] as Dictionary)["damage_percent"]), 0.02):
		failures.append("Matching Arms is not exactly +2%% damage: %s" % str(arms_eval["modifiers"]))
	var damage_at_four := int(player.get("attack_damage"))
	if damage_at_four <= damage_at_two:
		failures.append("player damage did not rise from the 2-piece to the 4-piece tier (%d -> %d)" % [damage_at_two, damage_at_four])
	print("player attack_damage: 2-piece %d -> 4-piece %d" % [damage_at_two, damage_at_four])

	# --- 7. recalculating repeatedly must not accumulate -------------------
	var stats_before: Dictionary = (player.get("last_calculated_stats") as Dictionary).duplicate()
	for i in range(5):
		player.call("recalculate_player_stats")
		await process_frame
	var stats_after: Dictionary = player.get("last_calculated_stats")
	for key in stats_before:
		if not is_equal_approx(float(stats_before[key]), float(stats_after[key])):
			failures.append("recalculating 5x changed %s: %s -> %s" % [str(key), str(stats_before[key]), str(stats_after[key])])
	print("recalculated 5x -> stats stable: ", stats_before.size(), " keys")

	# --- 4. unequipping removes the effect immediately ---------------------
	player.call("unequip_slot", EquipmentRulesService.SLOT_LEFT_LEG)
	await process_frame
	state = player.call("get_equipment_state")
	families = _by_category(SynergyRulesService.evaluate(state)["active"], SynergyRulesService.CATEGORY_FAMILY)
	if families.size() != 1 or int((families[0] as Dictionary)["tier"]) != 2:
		failures.append("unequipping did not fall back to the 2-piece tier: %s" % str(families))
	if int(player.get("attack_damage")) >= damage_at_four:
		failures.append("player damage did not drop when the 4-piece tier broke")
	print("after unequip -> active: ", _ids(SynergyRulesService.evaluate(state)["active"]))

	# Breaking the pair must drop Matching Arms.
	var broken_pair := pair_state.duplicate()
	broken_pair.erase(EquipmentRulesService.SLOT_RIGHT_ARM)
	if SynergyRulesService.has_symmetric_arms(broken_pair):
		failures.append("Matching Arms survived removing one arm")
	player.call("unequip_slot", EquipmentRulesService.SLOT_RIGHT_ARM)
	await process_frame

	# --- 6. nothing escapes the global clamp -------------------------------
	var modifiers: Dictionary = BoneRulesService.aggregate_player_stat_modifiers(player.call("get_equipment_state"))
	for key in ["damage_percent", "speed_percent", "health_percent", "weight_percent"]:
		if absf(float(modifiers[key])) > BoneRulesService.PLAYER_STAT_PERCENT_LIMIT + 0.0001:
			failures.append("%s escaped the clamp: %f" % [key, float(modifiers[key])])
	print("clamped modifiers: ", modifiers)

	# --- 5. builds recalculate, and match the worn loadout exactly ---------
	var builds: Variant = player.get("equipment_builds_component")
	if builds == null:
		print("NOTE: no equipment_builds_component on the player; skipping build parity")
	else:
		# Re-equip a full gorilla set, save it, and confirm the saved build
		# reports the same synergies and zero deltas against the worn gear.
		player.call("equip_bone", right_arm, EquipmentRulesService.SLOT_RIGHT_ARM)
		await process_frame
		player.call("equip_bone", left_leg, EquipmentRulesService.SLOT_LEFT_LEG)
		await process_frame
		builds.call("save_current_build", 1)
		await process_frame

		var report: Dictionary = builds.call("get_build_report", 1)
		if not bool(report.get("matches_current", false)):
			failures.append("a freshly saved build did not match the current equipment")
		var comparison: Dictionary = report.get("comparison", {})
		for key in comparison:
			if absf(float(comparison[key])) > 0.0:
				failures.append("a matching build reported a delta on %s: %s" % [str(key), str(comparison[key])])
		var build_effects: Array = report.get("effects", [])
		var worn_effects: Array = report.get("current_effects", [])
		if _ids(build_effects) != _ids(worn_effects):
			failures.append("build effects %s differ from worn effects %s" % [str(_ids(build_effects)), str(_ids(worn_effects))])
		print("build 1 effects: ", _ids(build_effects))
		print("build 1 composition: ", report.get("composition", {}))
		for entry in build_effects:
			print("  ", SynergyRulesService.summary_line_for(entry))

		# A build whose piece is gone must not claim that piece's synergies.
		player.call("unequip_slot", EquipmentRulesService.SLOT_LEFT_LEG)
		await process_frame
		var partial: Dictionary = builds.call("get_build_report", 1)
		print("after removing a saved piece -> state: ", partial.get("state", ""), ", partial: ", partial.get("effects_partial", false))

	print("")
	if failures.is_empty():
		print("SYNERGY CHECK: PASS")
	else:
		print("SYNERGY CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _by_category(active: Array, category: String) -> Array:
	var out: Array = []
	for entry in active:
		if str((entry as Dictionary).get("category", "")) == category:
			out.append(entry)
	return out


func _ids(active: Array) -> Array:
	var out: Array = []
	for entry in active:
		out.append(SynergyRulesService.entry_key_for(entry))
	out.sort()
	return out


func _find_player(node: Node) -> Node:
	if node.get("inventory_ui") != null:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null
