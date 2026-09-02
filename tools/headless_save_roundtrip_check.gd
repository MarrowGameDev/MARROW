extends SceneTree

# The check the whole persistence design rests on: a real player, real pieces
# with mixed qualities, a worn set, an emptied chest and a passed trial go to
# disk, get wiped from memory, and come back IDENTICAL.
#
# The assertion that matters most is piece identity. If a load re-rolled even
# one quality, BoneInstanceService's once-only contract would be broken and
# every stat on the player would quietly change between sessions.
#
#   godot --headless --path . --script tools/headless_save_roundtrip_check.gd
#
# Writes to a scratch file, never to the real save (see SaveService.set_save_path).
# Dynamic loading throughout, for the reason documented in
# tools/headless_chest_check.gd.

const SCRATCH_SAVE := "user://test_save_roundtrip.json"

var _events: Node = null
var _world: Node = null
var _player: Node = null
var _chest_scene: PackedScene = null
var _gate_scene: PackedScene = null
# Names of the checks that ran all the way through. See _initialize.
var _completed: Array[String] = []


func _initialize() -> void:
	var setup_error: String = await _setup()
	if setup_error != "":
		print("SAVE ROUNDTRIP CHECK: FAIL\n  - ", setup_error)
		_cleanup()
		quit(1)
		return

	var failures: Array[String] = []
	failures.append_array(await _check_roundtrip())
	failures.append_array(await _check_enemy_world_state())
	failures.append_array(_check_unreadable_saves_are_refused())

	# A GDScript runtime error aborts the function it happens in and returns an
	# empty failure list, which reads as PASS. Each check stamps its name as its
	# last act, so an aborted one is reported instead of silently skipped.
	for expected in ["roundtrip", "enemies", "refusals"]:
		if not _completed.has(expected):
			failures.append("the '%s' check did not run to completion (see the errors above)" % expected)

	print("")
	if failures.is_empty():
		print("SAVE ROUNDTRIP CHECK: PASS")
	else:
		print("SAVE ROUNDTRIP CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)

	_cleanup()
	quit(0 if failures.is_empty() else 1)


func _setup() -> String:
	_events = root.get_node_or_null("GameEvents")
	if _events == null:
		return "the GameEvents autoload is not available"

	SaveService.set_save_path(SCRATCH_SAVE)
	SaveService.delete_save()

	_chest_scene = load("res://scenes/chest.tscn") as PackedScene
	_gate_scene = load("res://scenes/bone_trial_gate.tscn") as PackedScene
	if _chest_scene == null or _gate_scene == null:
		return "chest.tscn or bone_trial_gate.tscn did not load"

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	if scene == null:
		return "dummy_testing_environment.tscn did not load"
	_world = scene.instantiate()
	root.add_child(_world)
	for i in range(20):
		await process_frame

	_player = _find_player(_world)
	if _player == null:
		return "no player in the testing environment"

	# Seed the ROLLS only. Wiping the instance registry here would orphan the
	# pieces the testing environment already handed the player, and the restore
	# would (correctly) drop them -- turning a working save into a test failure.
	# Starting from a player who already owns things is also the realistic case.
	LootTableService.seed_all(1337)
	return ""


# --- the round trip -------------------------------------------------------

func _check_roundtrip() -> Array[String]:
	var failures: Array[String] = []

	# --- build a state worth saving --------------------------------------
	# Deliberately mixed qualities: if a load re-rolled, a uniform set could
	# hide it.
	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_STRONG)
	var left_arm := BoneInstanceService.create_instance("gorilla_left_arm_bone", BoneQualityService.QUALITY_FRAIL)
	var right_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	var spare := BoneInstanceService.create_instance("leg_bone", BoneQualityService.QUALITY_WORN)

	for piece in [torso, left_arm, right_arm, spare]:
		_player.call("collect_bone", piece)
		await process_frame

	for pair in [[torso, "torso"], [left_arm, "left_arm"], [right_arm, "right_arm"]]:
		_player.call("equip_bone", str(pair[0]), str(pair[1]))
		await process_frame

	var chest = await _add_chest("saved_chest", 0)   # LockMode.NONE
	var trial_chest = await _add_chest("trial_chest", 2)  # LockMode.TRIAL
	trial_chest.required_trial_id = "saved_trial"
	var gate = await _add_gate("saved_trial")

	# Empty one chest, unlock the other by passing its trial.
	chest.player_in_range = _player
	var chest_contents: Array[String] = chest.open()
	_events.emit_signal("trial_completed", "saved_trial", "Saved Trial")
	gate.completed = true

	if not trial_chest.unlocked:
		failures.append("the trial did not unlock the trial-locked chest before saving")

	# --- capture the truth, then save ------------------------------------
	var expected_inventory: Array = (_player.call("get_inventory_items") as Array).duplicate()
	var expected_equipment: Dictionary = (_player.get("equipment_component").call("get_equipment_state") as Dictionary).duplicate()
	var expected_stats: Dictionary = _stat_snapshot()
	var expected_qualities: Dictionary = {}
	for instance_id in expected_inventory:
		expected_qualities[str(instance_id)] = BoneInstanceService.quality_id_of(str(instance_id))
	var expected_instance_count: int = BoneInstanceService.instance_count()

	var data := SaveService.capture(_player, _world)
	if not SaveService.save_to_disk(data):
		failures.append("save_to_disk reported failure")
	if not SaveService.has_save():
		failures.append("no save file exists after save_to_disk")

	print("saved: %d pieces, %d carried, equipment %s" % [
		expected_instance_count,
		expected_inventory.size(),
		str(expected_equipment),
	])
	print("       chest emptied with %s" % str(_describe(chest_contents)))

	# --- wipe everything the save is supposed to restore ------------------
	_player.call("unequip_slot", "left_arm")
	_player.call("unequip_slot", "right_arm")
	_player.call("unequip_slot", "torso")
	await process_frame
	_player.get("inventory_component").call("restore_items", [])
	await process_frame
	BoneInstanceService.reset(-1)

	# Fresh containers, as if the scene had just been loaded from disk.
	chest.free()
	trial_chest.free()
	gate.free()
	await process_frame
	var new_chest = await _add_chest("saved_chest", 0)
	var new_trial_chest = await _add_chest("trial_chest", 2)
	new_trial_chest.required_trial_id = "saved_trial"
	var new_gate = await _add_gate("saved_trial")

	if BoneInstanceService.instance_count() != 0:
		failures.append("the instance registry was not actually wiped before the load")
	if not (_player.call("get_inventory_items") as Array).is_empty():
		failures.append("the inventory was not actually emptied before the load")

	# --- load it back -----------------------------------------------------
	var loaded := SaveService.load_from_disk()
	if loaded.is_empty():
		failures.append("load_from_disk returned nothing for a file just written")
		return failures

	var report := SaveService.apply(loaded, _player, _world)
	await process_frame

	# --- identity ---------------------------------------------------------
	if BoneInstanceService.instance_count() != expected_instance_count:
		failures.append("restored %d instances, expected %d" % [BoneInstanceService.instance_count(), expected_instance_count])

	var restored_inventory: Array = _player.call("get_inventory_items")
	if restored_inventory != expected_inventory:
		failures.append("inventory came back as %s, expected %s" % [str(restored_inventory), str(expected_inventory)])

	# THE assertion: same piece, same quality, no re-roll.
	for instance_id in expected_qualities:
		var before := str(expected_qualities[instance_id])
		var after := BoneInstanceService.quality_id_of(str(instance_id))
		if before != after:
			failures.append("piece %s came back as %s, was %s -- quality was re-rolled" % [str(instance_id), after, before])

	var restored_equipment: Dictionary = _player.get("equipment_component").call("get_equipment_state")
	for slot in expected_equipment:
		if str(restored_equipment.get(slot, "")) != str(expected_equipment[slot]):
			failures.append("slot %s came back as '%s', expected '%s'" % [
				str(slot),
				str(restored_equipment.get(slot, "")),
				str(expected_equipment[slot]),
			])
	if not bool(report.get("equipment_complete", false)):
		failures.append("the restore reported incomplete equipment")

	# Stats are derived from pieces, so identical pieces must mean identical
	# stats. This is what a player would actually notice.
	var restored_stats := _stat_snapshot()
	for key in expected_stats:
		if absf(float(restored_stats.get(key, 0.0)) - float(expected_stats[key])) > 0.0001:
			failures.append("stat %s came back as %.4f, expected %.4f" % [
				str(key),
				float(restored_stats.get(key, 0.0)),
				float(expected_stats[key]),
			])
	print("restored: %s" % str(restored_stats))

	# --- world ------------------------------------------------------------
	if not new_chest.opened:
		failures.append("the emptied chest came back unopened; its loot would respawn")
	if new_chest.can_be_opened_now():
		failures.append("the restored chest is openable again")
	if not new_gate.completed:
		failures.append("the passed trial came back incomplete")
	if not new_trial_chest.unlocked:
		failures.append("the trial-unlocked chest came back locked; the trial never re-fires, so it would be shut forever")
	if new_trial_chest.opened:
		failures.append("an unopened chest came back opened")

	print("world: chest opened=%s, trial complete=%s, trial chest unlocked=%s" % [
		str(new_chest.opened),
		str(new_gate.completed),
		str(new_trial_chest.unlocked),
	])

	# A second load must be idempotent, not additive. Compared against the state
	# right after the FIRST load rather than the pre-save snapshot: the testing
	# environment keeps handing the player pieces in the background, so only a
	# load-to-load comparison isolates what the restore itself did.
	var after_first_load: Array = (_player.call("get_inventory_items") as Array).duplicate()
	var equipment_after_first: Dictionary = (_player.get("equipment_component").call("get_equipment_state") as Dictionary).duplicate()

	var second := SaveService.apply(SaveService.load_from_disk(), _player, _world)
	await process_frame

	if not bool(second.get("applied", false)):
		failures.append("the second load reported nothing applied")
	if (_player.call("get_inventory_items") as Array) != after_first_load:
		failures.append("loading twice changed the inventory; the restore is not idempotent")
	if (_player.get("equipment_component").call("get_equipment_state") as Dictionary) != equipment_after_first:
		failures.append("loading twice changed the equipment; the restore is not idempotent")

	_completed.append("roundtrip")
	return failures


# A dead enemy must stay dead across a load, and must not pay out a second
# time. This is the "el mundo queda inconsistente" case: progress persisted but
# the enemies came back.
func _check_enemy_world_state() -> Array[String]:
	var failures: Array[String] = []

	var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")

	# The dead one must still EXIST to be asked about itself, so it respawns --
	# with a delay long enough that it cannot come back mid-check. A
	# non-respawning enemy queue_frees itself the moment it dies, which is the
	# case the defeated-keys path at the end of this function covers.
	var dead := enemy_scene.instantiate()
	dead.name = "SavedDeadEnemy"
	dead.respawn_enabled = true
	dead.near_respawn_delay = 9999.0
	dead.far_respawn_delay = 9999.0

	var wounded := enemy_scene.instantiate()
	wounded.name = "SavedWoundedEnemy"
	wounded.respawn_enabled = false

	_world.add_child(dead)
	_world.add_child(wounded)
	await process_frame

	var dead_key := SaveService.enemy_save_key(_world, dead)
	var wounded_key := SaveService.enemy_save_key(_world, wounded)
	if dead_key == "" or wounded_key == "":
		failures.append("an enemy in the tree produced no save key")
		return failures

	wounded.health = 7
	# Killed silently: die() is a coroutine that drops loot and frees the node,
	# and what is under test is the SAVE, not the death animation.
	dead._become_dead_silently()
	await process_frame

	var drops_before: int = _pickup_count()
	var data := SaveService.capture(_player, _world, [])
	var saved_enemies: Array = (data.get("world", {}) as Dictionary).get("enemies", [])

	var saved_dead: Dictionary = _entry_for(saved_enemies, dead_key)
	var saved_wounded: Dictionary = _entry_for(saved_enemies, wounded_key)
	if saved_dead.is_empty():
		failures.append("the dead enemy was not captured")
	elif bool(saved_dead.get("alive", true)):
		failures.append("the dead enemy was captured as alive")
	if int(saved_wounded.get("health", -1)) != 7:
		failures.append("the wounded enemy's health was not captured (got %s)" % str(saved_wounded.get("health")))

	if not is_instance_valid(dead):
		failures.append("the dead enemy freed itself despite respawn being enabled; it cannot be restored")
		return failures

	# Bring both back to full life, as a fresh scene would.
	dead.alive = true
	dead.add_to_group("enemies")
	dead.visible = true
	wounded.health = wounded.max_health
	await process_frame

	SaveService.apply(data, _player, _world)
	await process_frame

	if bool(dead.get("alive")):
		failures.append("the dead enemy came back alive after a load")
	if dead.is_in_group("enemies"):
		failures.append("a restored-dead enemy is still on the live roster")
	if int(wounded.get("health")) != 7:
		failures.append("the wounded enemy's health was not restored (got %d)" % int(wounded.get("health")))
	if _pickup_count() != drops_before:
		failures.append("restoring a dead enemy paid out its loot a second time")

	# An enemy that died and was FREED before the save is the case the live tree
	# cannot answer for; the caller passes its key in explicitly.
	var freed_key := "FreedEnemyPath"
	var with_freed := SaveService.capture(_player, _world, [freed_key])
	var freed_entry: Dictionary = _entry_for((with_freed.get("world", {}) as Dictionary).get("enemies", []), freed_key)
	if freed_entry.is_empty():
		failures.append("a defeated-and-freed enemy was not recorded")
	elif bool(freed_entry.get("alive", true)):
		failures.append("a defeated-and-freed enemy was recorded as alive")

	print("enemies: dead stayed dead, wounded kept %d hp, no double drops, freed enemy recorded" % int(wounded.get("health")))
	dead.free()
	wounded.free()
	_completed.append("enemies")
	return failures


func _entry_for(entries: Array, key: String) -> Dictionary:
	for raw_entry in entries:
		if raw_entry is Dictionary and str((raw_entry as Dictionary).get("key", "")) == key:
			return raw_entry
	return {}


func _pickup_count() -> int:
	return root.get_tree().get_nodes_in_group("bone_pickups").size()


# --- a save that cannot be trusted must be refused, not half-applied ------

func _check_unreadable_saves_are_refused() -> Array[String]:
	var failures: Array[String] = []

	var future := FileAccess.open(SaveService.save_path(), FileAccess.WRITE)
	future.store_string(JSON.stringify({"version": SaveService.SAVE_VERSION + 99, "inventory": ["bone#1"]}))
	future.close()
	if not SaveService.load_from_disk().is_empty():
		failures.append("a save from a future version was accepted")

	var corrupt := FileAccess.open(SaveService.save_path(), FileAccess.WRITE)
	corrupt.store_string("{ this is not json")
	corrupt.close()
	if not SaveService.load_from_disk().is_empty():
		failures.append("a corrupt save was accepted")

	# Applying nothing must be a no-op, not a wipe.
	var before: Array = _player.call("get_inventory_items")
	var report := SaveService.apply({}, _player, _world)
	if bool(report.get("applied", true)):
		failures.append("applying an empty save reported success")
	if (_player.call("get_inventory_items") as Array).size() != before.size():
		failures.append("applying an empty save changed the inventory")

	SaveService.delete_save()
	if SaveService.has_save():
		failures.append("delete_save left the file behind")

	print("refusals: future version rejected, corrupt file rejected, empty apply is a no-op")
	_completed.append("refusals")
	return failures


# --- helpers --------------------------------------------------------------

func _add_chest(id: String, lock_mode: int):
	var chest = _chest_scene.instantiate()
	chest.chest_id = id
	chest.loot_table_id = "field_cache"
	chest.lock_mode = lock_mode
	chest.delivery_mode = 1  # DIRECT_TO_INVENTORY, so loot lands somewhere checkable
	_world.add_child(chest)
	await process_frame
	return chest


func _add_gate(trial_id: String):
	var gate = _gate_scene.instantiate()
	gate.trial_id = trial_id
	gate.trial_name = "Saved Trial"
	_world.add_child(gate)
	await process_frame
	return gate


func _stat_snapshot() -> Dictionary:
	return {
		"move_speed": float(_player.get("move_speed")),
		"attack_range": float(_player.get("attack_range")),
		"attack_damage": float(_player.get("attack_damage")),
		"max_health": float(_player.get("max_health")),
	}


func _describe(instance_ids: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for instance_id in instance_ids:
		out.append("%s[%s]" % [
			BoneInstanceService.bone_id_of(instance_id),
			BoneInstanceService.quality_id_of(instance_id),
		])
	return out


func _find_player(node: Node) -> Node:
	if node.has_method("collect_bone") and node.has_method("equip_bone"):
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null


func _cleanup() -> void:
	SaveService.delete_save()
	SaveService.set_save_path("")
	if _world != null and is_instance_valid(_world):
		_world.free()
