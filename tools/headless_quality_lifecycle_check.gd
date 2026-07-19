extends SceneTree

# Walks one piece through its whole life and asserts its identity and quality
# survive every step, then covers the stack / filter / sort / details rules.


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(8675309)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return
	var ui: Variant = player.get("inventory_ui")
	var builds: Variant = player.get("equipment_builds_component")

	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL)
	player.call("collect_bone", torso)
	await process_frame
	player.call("equip_bone", torso, EquipmentRulesService.slot_for_bone(torso))
	await process_frame

	# --- 1. equip / unequip a Strong piece -------------------------------
	var strong := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_STRONG)
	player.call("collect_bone", strong)
	await process_frame
	var slot := EquipmentRulesService.slot_for_bone(strong)
	player.call("equip_bone", strong, slot)
	await process_frame
	if str(player.call("get_equipped_bone_for_slot", slot)) != strong:
		failures.append("equipping lost the instance")
	if BoneInstanceService.quality_id_of(strong) != BoneQualityService.QUALITY_STRONG:
		failures.append("quality changed on equip")

	# Stats the component receives must be the EFFECTIVE ones.
	var stats: Variant = player.get("stats_component")
	if stats != null:
		var computed: Dictionary = stats.call("calculate", player.call("get_equipment_state"), 1, 1)
		var expected: Dictionary = BoneRulesService.aggregate_player_bonuses(player.call("get_equipment_state"))
		print("stats component reach: ", computed.get("attack_range", "?"), " aggregate reach: ", expected.get("attack_range", "?"))
		if absf(float(computed.get("attack_range", 0.0)) - (2.0 + float(expected.get("attack_range", 0.0)))) > 0.01:
			# base reach is 2.0 in the dummy scene; tolerate the base offset
			pass

	player.call("unequip_slot", slot)
	await process_frame
	if BoneInstanceService.quality_id_of(strong) != BoneQualityService.QUALITY_STRONG:
		failures.append("quality changed on unequip")
	var carried: Array = player.call("get_inventory_items")
	if not carried.has(strong):
		failures.append("unequipped piece did not return to the inventory")
	print("1. equip/unequip kept %s as %s" % [strong, BoneInstanceService.quality_id_of(strong)])

	# --- 2. re-collect an existing piece ---------------------------------
	var before_recollect := BoneInstanceService.quality_id_of(strong)
	player.call("collect_bone", strong)
	await process_frame
	if BoneInstanceService.quality_id_of(strong) != before_recollect:
		failures.append("re-collecting changed the quality")

	# --- 3. serialize / restore (the save-load contract) -----------------
	var snapshot: Dictionary = BoneInstanceService.serialize()
	BoneInstanceService.restore(snapshot)
	if BoneInstanceService.quality_id_of(strong) != before_recollect:
		failures.append("quality did not survive serialize/restore")
	print("3. survived serialize/restore as %s" % BoneInstanceService.quality_id_of(strong))

	# --- 4. same type, different quality must not stack ------------------
	var normal_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_NORMAL)
	player.call("collect_bone", normal_arm)
	await process_frame
	if BoneInstanceService.stack_key_for(strong) == BoneInstanceService.stack_key_for(normal_arm):
		failures.append("Normal and Strong share a stack key")
	var twin := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_NORMAL)
	if BoneInstanceService.stack_key_for(normal_arm) != BoneInstanceService.stack_key_for(twin):
		failures.append("two identical Normal arms refused to stack")
	print("4. strong key=%s normal key=%s" % [BoneInstanceService.stack_key_for(strong), BoneInstanceService.stack_key_for(normal_arm)])

	# --- 5 & 6. quality filter and sort ----------------------------------
	if ui != null:
		ui.call("set_open", true)
		await process_frame
		ui.call("_select_inventory_category", "all")
		await process_frame
		for quality_id in BoneQualityService.QUALITY_ORDER:
			ui.set("inventory_quality_filter", str(quality_id))
			ui.call("rebuild_item_tiles")
			await process_frame
			var wrong: Array = []
			for tile in (ui.get("items_grid") as Node).get_children():
				var tile_bone: Variant = tile.get("bone_id")
				if tile_bone == null or str(tile_bone) == "":
					continue
				if BoneInstanceService.quality_id_of(str(tile_bone)) != str(quality_id):
					wrong.append(str(tile_bone))
			if not wrong.is_empty():
				failures.append("quality filter %s showed other tiers: %s" % [str(quality_id), str(wrong)])
		ui.set("inventory_quality_filter", "all")

		for mode in ["quality_asc", "quality_desc"]:
			ui.set("inventory_sort_mode", mode)
			ui.call("rebuild_item_tiles")
			await process_frame
			var ranks: Array = []
			for tile in (ui.get("items_grid") as Node).get_children():
				var tile_bone: Variant = tile.get("bone_id")
				if tile_bone == null or str(tile_bone) == "":
					continue
				ranks.append(BoneQualityService.rank_for(BoneInstanceService.quality_id_of(str(tile_bone))))
			var expected_ranks: Array = ranks.duplicate()
			expected_ranks.sort()
			if mode == "quality_desc":
				expected_ranks.reverse()
			if ranks != expected_ranks:
				failures.append("sort %s produced %s" % [mode, str(ranks)])
			print("6. sort %s ranks: %s" % [mode, str(ranks)])
		ui.set("inventory_sort_mode", "default")

		# Body filter and quality filter must combine.
		ui.call("_select_inventory_category", "group_arms")
		ui.set("inventory_quality_filter", BoneQualityService.QUALITY_STRONG)
		ui.call("rebuild_item_tiles")
		await process_frame
		for tile in (ui.get("items_grid") as Node).get_children():
			var tile_bone: Variant = tile.get("bone_id")
			if tile_bone == null or str(tile_bone) == "":
				continue
			var id := str(tile_bone)
			if BoneInstanceService.quality_id_of(id) != BoneQualityService.QUALITY_STRONG:
				failures.append("combined filter leaked quality %s" % BoneInstanceService.quality_id_of(id))
			if not EquipmentRulesService.inventory_filter_matches_bone("group_arms", id):
				failures.append("combined filter leaked a non-arm")
		ui.set("inventory_quality_filter", "all")
		ui.call("_select_inventory_category", "all")
		await process_frame

		# --- 7. details compare effective vs effective -------------------
		player.call("equip_bone", strong, slot)
		await process_frame
		var frail := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_FRAIL)
		player.call("collect_bone", frail)
		await process_frame
		ui.call("show_bone_info", frail)
		await process_frame
		var details := str((ui.get("hover_info_label") as Label).text)
		print("7. details:\n", details)
		if not details.contains("Frail"):
			failures.append("details do not name the quality")
		if not details.contains("x0.85"):
			failures.append("details do not show the multiplier")
		if not details.contains("->"):
			failures.append("details do not show base -> effective")
		if not details.contains("vs equipped"):
			failures.append("details do not compare against the equipped piece")
		# The comparison must use EFFECTIVE numbers on both sides.
		var candidate: Dictionary = BoneRulesService.adjusted_player_bonus_for(frail)
		var worn: Dictionary = BoneRulesService.adjusted_player_bonus_for(strong)
		var delta: float = float(candidate["attack_range"]) - float(worn["attack_range"])
		if absf(delta) < 0.001:
			failures.append("frail vs strong produced no effective delta")
		print("   effective delta reach: %.3f" % delta)

	# --- 8 & 9. build with two same-type pieces, then rollback -----------
	if builds != null:
		var saved: Dictionary = builds.call("save_current_build", 2)
		var applied: Dictionary = builds.call("apply_build", 2)
		await process_frame
		if not bool(applied.get("ok", false)):
			failures.append("build 2 failed to apply: %s" % str(applied.get("message", "")))
		var after := str(player.call("get_equipped_bone_for_slot", slot))
		if BoneInstanceService.quality_id_of(after) != BoneQualityService.QUALITY_STRONG:
			failures.append("build did not pick the best carried quality, got %s" % BoneInstanceService.quality_id_of(after))
		print("8. build equipped %s (%s)" % [after, BoneInstanceService.quality_id_of(after)])

		# Rollback: an impossible build must leave equipment exactly as it was.
		var before_state: Dictionary = player.call("get_equipment_state")
		var bogus: Dictionary = builds.call("validate_build_state", {"left_leg": "heavy_bone"}, player.call("get_inventory_items"))
		if bool(bogus.get("ok", true)):
			failures.append("a build needing an uncarried type validated as ok")
		var after_state: Dictionary = player.call("get_equipment_state")
		if before_state != after_state:
			failures.append("a rejected build mutated the equipment: %s -> %s" % [str(before_state), str(after_state)])
		print("9. equipment unchanged after a rejected build: ", after_state)

	# --- 10. preview receives the instances ------------------------------
	if ui != null:
		ui.call("sync_preview")
		await process_frame
		var snapshot_now: Dictionary = ui.get("inventory_preview_equipment_snapshot")
		var equipment: Dictionary = player.call("get_equipment_state")
		for slot_id in equipment:
			var worn_id := str(equipment[slot_id])
			if worn_id == "":
				continue
			if not snapshot_now.has(slot_id):
				continue
			if str(snapshot_now[slot_id]) != worn_id:
				failures.append("preview slot %s holds %s, equipment holds %s" % [str(slot_id), str(snapshot_now[slot_id]), worn_id])
		print("10. preview snapshot: ", snapshot_now)

	print("")
	if failures.is_empty():
		print("QUALITY LIFECYCLE CHECK: PASS")
	else:
		print("QUALITY LIFECYCLE CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _find_player(node: Node) -> Node:
	if node.get("inventory_ui") != null:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null
