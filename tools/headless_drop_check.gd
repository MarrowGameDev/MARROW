extends SceneTree

# Drop-to-ground contract: right-clicking an inventory tile removes ONE carried
# copy and spawns a world pickup that carries the SAME instance (quality and
# marks survive the round trip). Locked pieces refuse and say why; the worn
# copy of a stack is never the one dropped.

var fails: int = 0


func _check(name: String, ok: bool, detail: String = "") -> void:
	if ok:
		print("  ok: ", name)
	else:
		fails += 1
		print("  FAIL: ", name, "  ", detail)


func _find_player(n: Node) -> Node:
	if n.get("inventory_ui") != null:
		return n
	for c in n.get_children():
		var f := _find_player(c)
		if f != null:
			return f
	return null


func _find_item(player: Node, type_id: String) -> String:
	for item in player.call("get_inventory_items"):
		if BoneInstanceService.bone_id_of(str(item)) == type_id:
			return str(item)
	return ""


func _pickup_with_id(instance_id: String) -> Node:
	for node in root.get_tree().get_nodes_in_group("bone_pickups"):
		if str(node.get("bone_id")) == instance_id:
			return node
	return null


func _initialize() -> void:
	BoneInstanceService.reset(77)
	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)

	var player: Node = null
	for i in range(600):
		await process_frame
		player = _find_player(world)
		if player != null and _find_item(player, "normal_body_bone") != "":
			break
	var ui: Variant = player.get("inventory_ui")
	var label: Label = ui.get("hover_info_label")

	# 1. Dropping a free carried piece removes it and spawns a pickup with the
	#    exact same instance id.
	var target := _find_item(player, "heavy_bone")
	var quality_before := BoneInstanceService.quality_id_of(target)
	var count_before: int = (player.call("get_inventory_items") as Array).size()
	ui.call("drop_bone", target)
	await process_frame
	_check("drop removes the piece from the inventory",
		not (player.call("get_inventory_items") as Array).has(target))
	_check("inventory shrank by exactly one",
		(player.call("get_inventory_items") as Array).size() == count_before - 1)
	var pickup := _pickup_with_id(target)
	_check("a world pickup carries the same instance id", pickup != null)
	_check("instance quality survived the drop",
		BoneInstanceService.quality_id_of(target) == quality_before)
	_check("details panel confirms the drop", label.text.begins_with("Dropped"))

	# 2. Collecting the pickup brings back the SAME instance, never a re-roll.
	if pickup != null:
		player.call("collect_bone", str(pickup.get("bone_id")))
		await process_frame
		_check("recollecting restores the same instance",
			(player.call("get_inventory_items") as Array).has(target))
		_check("quality unchanged after the round trip",
			BoneInstanceService.quality_id_of(target) == quality_before)
		pickup.queue_free()

	# 3. A locked piece refuses to drop and the reason is shown.
	var locked := _find_item(player, "rib_bone")
	BoneInstanceService.toggle_locked(locked)
	ui.call("drop_bone", locked)
	await process_frame
	_check("locked piece stays in the inventory",
		(player.call("get_inventory_items") as Array).has(locked))
	_check("locked refusal names the reason", label.text.contains("locked"))
	BoneInstanceService.toggle_locked(locked)

	# 4. The worn copy of a stack is never dropped: with a single carried copy
	#    equipped, dropping it refuses outright.
	var torso := _find_item(player, "normal_body_bone")
	player.call("equip_bone", torso, "torso")
	await process_frame
	ui.call("drop_bone", torso)
	await process_frame
	_check("worn piece refuses to drop",
		(player.call("get_inventory_items") as Array).has(torso))
	_check("worn refusal names the reason", label.text.contains("worn"))

	if fails == 0:
		print("\nDROP CHECK: PASS")
		quit(0)
	else:
		print("\nDROP CHECK: FAIL (", fails, ")")
		quit(1)
