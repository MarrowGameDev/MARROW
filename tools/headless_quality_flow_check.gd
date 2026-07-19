extends SceneTree

# End-to-end: does the REAL game flow carry per-instance quality? Runs the
# actual dummy testing scene, collects pieces through the real inventory
# component, equips them through the real equipment component, and checks the
# quality survives every step without being re-rolled.


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(20260718)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return

	var inventory: Variant = player.get("inventory_component")
	var items: Array = player.call("get_inventory_items")
	print("seeded inventory size: ", items.size())

	# Every carried piece must be a real instance with a real quality.
	var qualities: Dictionary = {}
	for entry in items:
		var id := str(entry)
		if not BoneInstanceService.is_instance_id(id):
			failures.append("inventory holds a non-instance entry: %s" % id)
			continue
		var q := BoneInstanceService.quality_id_of(id)
		if not BoneQualityService.is_quality_id(q):
			failures.append("%s has invalid quality %s" % [id, q])
		qualities[id] = q
	print("distinct qualities carried: ", _tally(qualities.values()))

	# Collecting an ALREADY CREATED piece must not change its quality.
	var existing := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	player.call("collect_bone", existing)
	await process_frame
	if BoneInstanceService.quality_id_of(existing) != BoneQualityService.QUALITY_PRISTINE:
		failures.append("collecting an existing piece changed its quality")
	var after_collect: Array = player.call("get_inventory_items")
	if not after_collect.has(existing):
		failures.append("collected instance did not land in the inventory")
	if after_collect.count(existing) != 1:
		failures.append("collected instance was duplicated")

	# Equipping must not re-roll, and the equipped stats must reflect quality.
	# The game requires a torso before limbs can attach, so equip one first --
	# otherwise the limb equip is refused and this would test nothing.
	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL)
	player.call("collect_bone", torso)
	await process_frame
	player.call("equip_bone", torso, EquipmentRulesService.slot_for_bone(torso))
	await process_frame

	var frail := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_FRAIL)
	player.call("collect_bone", frail)
	await process_frame
	var slot := EquipmentRulesService.slot_for_bone(frail)
	player.call("equip_bone", frail, slot)
	await process_frame
	if BoneInstanceService.quality_id_of(frail) != BoneQualityService.QUALITY_FRAIL:
		failures.append("equipping re-rolled the quality")
	var state: Dictionary = player.call("get_equipment_state")
	if str(state.get(slot, "")) != frail:
		failures.append("equipment state lost the instance id: %s" % str(state))
	print("equipped %s in %s -> state %s" % [frail, slot, str(state.get(slot, ""))])

	# Two pieces of the same type, different quality -> different totals.
	var strong := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	var totals_frail: Dictionary = BoneRulesService.aggregate_player_bonuses({slot: frail})
	var totals_strong: Dictionary = BoneRulesService.aggregate_player_bonuses({slot: strong})
	print("totals frail   : ", totals_frail)
	print("totals pristine: ", totals_strong)
	if totals_frail == totals_strong:
		failures.append("aggregate totals ignore quality")

	# Opening the inventory / rebuilding tiles must not re-roll anything.
	var before: Dictionary = {}
	for entry in player.call("get_inventory_items"):
		before[str(entry)] = BoneInstanceService.quality_id_of(str(entry))
	var ui: Variant = player.get("inventory_ui")
	if ui != null:
		ui.call("set_open", true)
		for i in range(5):
			await process_frame
		ui.call("rebuild_item_tiles")
		ui.call("notify_inventory_changed")
		await process_frame
	for entry_id in before:
		if BoneInstanceService.quality_id_of(str(entry_id)) != str(before[entry_id]):
			failures.append("%s changed quality when the inventory refreshed" % str(entry_id))

	# Stacks must not merge different qualities.
	if ui != null:
		var grid: Node = ui.get("items_grid")
		var seen_keys: Dictionary = {}
		for tile in grid.get_children():
			var tile_bone: Variant = tile.get("bone_id")
			if tile_bone == null or str(tile_bone) == "":
				continue
			var key := BoneInstanceService.stack_key_for(str(tile_bone))
			if seen_keys.has(key):
				failures.append("two tiles share stack key %s (stacks not merged)" % key)
			seen_keys[key] = true
		print("distinct stacks shown: ", seen_keys.size())

	print("")
	if failures.is_empty():
		print("QUALITY FLOW CHECK: PASS")
	else:
		print("QUALITY FLOW CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _tally(values: Array) -> Dictionary:
	var out: Dictionary = {}
	for v in values:
		out[str(v)] = int(out.get(str(v), 0)) + 1
	return out


func _find_player(node: Node) -> Node:
	if node.get("inventory_ui") != null:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null
