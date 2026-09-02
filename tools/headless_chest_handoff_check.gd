extends SceneTree

# The bug this pins, reported from play: you hold Interact at a chest, the chest
# opens, and the loot "never drops". It did drop -- and was then swallowed by
# the SAME keypress, because a pickup that spawns under a finger already down
# counted that press as its own hold and collected itself before it was visible.
#
# Drives a REAL player in the REAL scene with the REAL interact action, because
# nothing short of that reproduces it: calling chest.open() directly never
# touches the input path where the bug lives.
#
#   godot --headless --path . --script tools/headless_chest_handoff_check.gd
#
# Runs against a scratch save path so the SaveCoordinator in main.tscn cannot
# touch a real save. Dynamic loading, per tools/headless_chest_check.gd.

const SCRATCH_SAVE := "user://test_chest_handoff.json"
# Headless runs uncapped, so a frame is worth far less than 1/60 s of hold. The
# budget is generous on purpose; the assertions are about what happens, not when.
const MAX_HOLD_FRAMES := 4000

var _world: Node = null
var _player: Node = null


func _initialize() -> void:
	SaveService.set_save_path(SCRATCH_SAVE)
	SaveService.delete_save()

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_finish(["scenes/main.tscn did not load"])
		return

	_world = scene.instantiate()
	root.add_child(_world)
	for i in range(60):
		await process_frame

	_player = _find_player(_world)
	if _player == null:
		_finish(["no player in main.tscn"])
		return

	var failures: Array[String] = []
	failures.append_array(await _check_loot_survives_the_opening_hold())
	failures.append_array(_check_fresh_press_rule())
	_finish(failures)


func _check_loot_survives_the_opening_hold() -> Array[String]:
	var failures: Array[String] = []

	var chest: Node3D = _world.get_node_or_null("WorldChests/HubChest")
	if chest == null:
		failures.append("WorldChests/HubChest is missing from main.tscn")
		return failures

	# Stand at the chest like a player would.
	(_player as Node3D).global_position = chest.global_position + Vector3(0, 1.05, -1.2)
	for i in range(10):
		await process_frame

	var inventory_before: int = (_player.call("get_inventory_items") as Array).size()

	# Hold Interact and never let go -- the exact input that lost the loot.
	Input.action_press(DropPickupRulesService.PICKUP_ACTION)
	var frames := 0
	while not bool(chest.get("opened")) and frames < MAX_HOLD_FRAMES:
		await process_frame
		frames += 1

	if not bool(chest.get("opened")):
		Input.action_release(DropPickupRulesService.PICKUP_ACTION)
		failures.append("the chest never opened while Interact was held for %d frames" % frames)
		return failures

	# Keep holding well past the pickup hold time.
	for i in range(240):
		await process_frame

	var alive: Array[Node] = _live_pickups()
	var inventory_mid: int = (_player.call("get_inventory_items") as Array).size()

	if alive.is_empty():
		failures.append("the chest opened but no pickup survived; the loot was swallowed by the opening hold")
	if inventory_mid != inventory_before:
		failures.append(
			"%d piece(s) went straight into the inventory while Interact was still held; a SPAWN_PICKUPS chest must drop them on the floor"
			% (inventory_mid - inventory_before)
		)

	# At least one piece has to land on the player's side of the chest. Loot
	# that always spawns behind the box reads as nothing having happened.
	var nearest := INF
	for pickup in alive:
		nearest = minf(nearest, (pickup as Node3D).global_position.distance_to((_player as Node3D).global_position))
	if nearest > 3.0:
		failures.append("the nearest dropped piece is %.2f m away; loot should land toward whoever opened it" % nearest)

	# The label has to say what came out, not "Empty".
	var label := str(chest.get("_last_prompt"))
	if label.contains("Empty"):
		failures.append("the opened chest still reads 'Empty': %s" % label.replace("\n", " | "))
	for pickup in alive:
		var piece_name := BoneRulesService.display_name_with_slot(str(pickup.get("bone_id")))
		if not label.contains(piece_name):
			failures.append("the chest label does not name '%s'; label was: %s" % [piece_name, label.replace("\n", " | ")])

	print("held through opening: %d piece(s) survived, nearest %.2f m, inventory unchanged (%d)" % [
		alive.size(), nearest, inventory_before,
	])
	print("label: %s" % label.replace("\n", " | "))

	# Releasing and pressing again must collect normally -- the rule delays a
	# hold, it must not break picking things up.
	Input.action_release(DropPickupRulesService.PICKUP_ACTION)
	for i in range(10):
		await process_frame

	var target: Node3D = alive[0] as Node3D
	(_player as Node3D).global_position = target.global_position + Vector3(0, 1.05, 0.4)
	for i in range(10):
		await process_frame

	Input.action_press(DropPickupRulesService.PICKUP_ACTION)
	frames = 0
	var was_collected := false
	while frames < MAX_HOLD_FRAMES:
		await process_frame
		frames += 1
		# A collected pickup frees itself, so a freed node IS the success case.
		if not is_instance_valid(target) or bool(target.get("collected")):
			was_collected = true
			break
	Input.action_release(DropPickupRulesService.PICKUP_ACTION)
	for i in range(10):
		await process_frame

	var inventory_after: int = (_player.call("get_inventory_items") as Array).size()
	if not was_collected:
		failures.append("a fresh press did not collect a dropped piece; the rule is blocking normal pickups")
	elif inventory_after <= inventory_before:
		failures.append("a piece was collected but the inventory did not grow")
	else:
		# More than one can arrive from a single press when the pickup areas
		# overlap, which is long-standing pickup behaviour and not what this
		# check is about. All that matters here is that a fresh press still
		# works at all.
		print("fresh press after release: collected normally (+%d)" % (inventory_after - inventory_before))

	return failures


# The rule itself, independent of any scene.
func _check_fresh_press_rule() -> Array[String]:
	var failures: Array[String] = []

	# Latched and still held -> stays latched (must not count this press).
	if not DropPickupRulesService.next_fresh_press_latch(true, true):
		failures.append("a latched hold cleared while the button was still down")
	# Latched and released -> clears, so the next press counts.
	if DropPickupRulesService.next_fresh_press_latch(true, false):
		failures.append("releasing the button did not clear the latch")
	# Never latched -> never blocks.
	if DropPickupRulesService.next_fresh_press_latch(false, true):
		failures.append("an unlatched hold was blocked")
	if DropPickupRulesService.next_fresh_press_latch(false, false):
		failures.append("an unlatched, unheld frame was blocked")

	print("fresh-press rule: blocks only a press that was already underway")
	return failures


func _live_pickups() -> Array[Node]:
	var alive: Array[Node] = []
	for node in root.get_tree().get_nodes_in_group("bone_pickups"):
		if not bool(node.get("collected")):
			alive.append(node)
	return alive


func _find_player(node: Node) -> Node:
	if node.is_in_group("player"):
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null


func _finish(failures: Array[String]) -> void:
	Input.action_release(DropPickupRulesService.PICKUP_ACTION)
	print("")
	if failures.is_empty():
		print("CHEST HANDOFF CHECK: PASS")
	else:
		print("CHEST HANDOFF CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)

	SaveService.delete_save()
	SaveService.set_save_path("")
	if _world != null and is_instance_valid(_world):
		_world.free()
	quit(0 if failures.is_empty() else 1)
