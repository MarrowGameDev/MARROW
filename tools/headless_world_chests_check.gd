extends SceneTree

# Content check for the placed containers in scenes/main.tscn. Everything here
# is an authoring mistake that would look fine in the editor and only surface as
# a chest that gives nothing, never opens, or quietly shares a save key with
# another chest and resurrects its loot.
#
#   godot --headless --path . --script tools/headless_world_chests_check.gd
#
# Runs against a scratch save path so loading the real scene -- which contains a
# SaveCoordinator that loads on start -- cannot read or write a player's save.

const SCRATCH_SAVE := "user://test_world_chests.json"
const GROUND_HALF_EXTENT := 50.0

var _world: Node = null


func _initialize() -> void:
	SaveService.set_save_path(SCRATCH_SAVE)
	SaveService.delete_save()

	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		print("WORLD CHESTS CHECK: FAIL\n  - scenes/main.tscn did not load")
		_cleanup()
		quit(1)
		return

	_world = scene.instantiate()
	root.add_child(_world)
	for i in range(20):
		await process_frame

	var failures: Array[String] = []
	failures.append_array(_check_chests())
	failures.append_array(_check_trial_links())
	failures.append_array(_check_save_coordinator())

	print("")
	if failures.is_empty():
		print("WORLD CHESTS CHECK: PASS")
	else:
		print("WORLD CHESTS CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)

	_cleanup()
	quit(0 if failures.is_empty() else 1)


func _check_chests() -> Array[String]:
	var failures: Array[String] = []
	var chests := get_nodes_in_group("loot_chests")

	if chests.is_empty():
		failures.append("no chests are placed in the scene")
		return failures

	var seen_ids: Dictionary = {}
	print("placed chests: %d" % chests.size())
	for chest in chests:
		var chest_name := str(chest.name)
		var id := str(chest.get("chest_id"))
		var table_id := str(chest.get("loot_table_id"))

		# Without an id the chest cannot be saved, so its loot respawns every
		# load. That is invisible until a player notices.
		if id == "":
			failures.append("chest '%s' has no chest_id and can never be saved" % chest_name)
		elif seen_ids.has(id):
			failures.append("chest_id '%s' is used by both '%s' and '%s'" % [id, str(seen_ids[id]), chest_name])
		else:
			seen_ids[id] = chest_name

		if not bool(chest.call("is_openable_source")):
			failures.append("chest '%s' names loot table '%s', which does not exist" % [chest_name, table_id])

		var position: Vector3 = (chest as Node3D).global_position
		if absf(position.x) > GROUND_HALF_EXTENT or absf(position.z) > GROUND_HALF_EXTENT:
			failures.append("chest '%s' sits at %s, off the playable ground" % [chest_name, str(position)])

		# A camp chest carries no table id: it is handed a one-item inline table
		# at build time, which is why is_openable_source() above still passes.
		var table := LootTableService.table_for(table_id)
		var summary := "inline single reward"
		if table != null:
			summary = "%d guaranteed + %d-%d rolls" % [
				table.guaranteed_bone_ids.size(),
				table.min_rolls,
				table.max_rolls,
			]
		print("  %-22s %-26s %-16s %s" % [chest_name, id, table_id if table_id != "" else "-", summary])

	return failures


# A TRIAL chest whose required_trial_id matches no gate in the scene can never
# be opened. Nothing at runtime would report that.
func _check_trial_links() -> Array[String]:
	var failures: Array[String] = []

	var trial_ids: Dictionary = {}
	for gate in get_nodes_in_group("bone_trial_gates"):
		trial_ids[str(gate.get("trial_id"))] = true
	print("trial gates: %s" % str(trial_ids.keys()))

	var chest_script: GDScript = load("res://scripts/chest.gd")
	var lock_modes: Dictionary = chest_script.get("LockMode")
	var trial_mode: int = int(lock_modes["TRIAL"])
	var bone_mode: int = int(lock_modes["EQUIPPED_BONE"])

	for chest in get_nodes_in_group("loot_chests"):
		var mode := int(chest.get("lock_mode"))
		if mode == trial_mode:
			var required := str(chest.get("required_trial_id"))
			if required == "":
				failures.append("chest '%s' is TRIAL-locked with no required_trial_id" % str(chest.name))
			elif not trial_ids.has(required):
				failures.append("chest '%s' waits on trial '%s', which no gate in the scene emits" % [str(chest.name), required])
		elif mode == bone_mode:
			var required_bone := str(chest.get("required_bone_id"))
			if required_bone == "":
				failures.append("chest '%s' is EQUIPPED_BONE-locked with no required_bone_id" % str(chest.name))
			elif BoneRulesService.definition_for(required_bone).is_empty():
				failures.append("chest '%s' requires '%s', which is not a real bone" % [str(chest.name), required_bone])

	return failures


func _check_save_coordinator() -> Array[String]:
	var failures: Array[String] = []
	var coordinators := get_nodes_in_group("save_coordinators")
	if coordinators.is_empty():
		failures.append("the playable scene has no SaveCoordinator; nothing would ever be saved")
	elif coordinators.size() > 1:
		failures.append("the scene has %d SaveCoordinators; they would fight over the same file" % coordinators.size())
	else:
		print("save coordinator: present, autosave=%s" % str(coordinators[0].get("autosave_enabled")))
	return failures


func _cleanup() -> void:
	SaveService.delete_save()
	SaveService.set_save_path("")
	if _world != null and is_instance_valid(_world):
		_world.free()
