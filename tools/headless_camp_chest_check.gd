extends SceneTree

# Guards the DemoEnemyCamp refactor: the camp now composes a LootChest instead
# of drawing and driving one itself, and this check pins the behaviour that must
# NOT have changed -- locked until every registered enemy is dead, one reward,
# and the same camp_state_changed / camp_chest_opened events other systems
# already listen for.
#
# Built the way tutorial_island_builder builds camps (a bare Node3D with the
# script attached and exports set before add_child), so the construction path
# under test is the real one.
#
#   godot --headless --path . --script tools/headless_camp_chest_check.gd
#
# Dynamic loading throughout, for the reason documented in
# tools/headless_chest_check.gd: autoloads are not registered while a --script
# entry point compiles.

var _camp_script: GDScript = null
var _events: Node = null
var _world: Node3D = null

var _state_events: Array = []
var _camp_reward_events: Array = []


class FakeEnemy:
	extends Node3D

	var alive: bool = true
	var respawn_enabled: bool = true


class FakePlayer:
	extends Node3D

	var collected: Array[String] = []
	var interact_reservations: int = 0

	func collect_bone(instance_id: String) -> void:
		collected.append(instance_id)

	func has_bone_equipped(_bone_id: String) -> bool:
		return false

	func enter_interact_range() -> void:
		interact_reservations += 1

	func exit_interact_range() -> void:
		interact_reservations = maxi(interact_reservations - 1, 0)


func _initialize() -> void:
	var setup_error: String = await _setup()
	if setup_error != "":
		print("CAMP CHEST CHECK: FAIL\n  - ", setup_error)
		quit(1)
		return

	var failures: Array[String] = []
	failures.append_array(await _check_clear_to_unlock())
	failures.append_array(await _check_loot_table_camp())
	failures.append_array(await _check_restore_opened())

	print("")
	if failures.is_empty():
		print("CAMP CHEST CHECK: PASS")
	else:
		print("CAMP CHEST CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)

	_world.free()
	quit(0 if failures.is_empty() else 1)


func _setup() -> String:
	_events = root.get_node_or_null("GameEvents")
	if _events == null:
		return "the GameEvents autoload is not available"

	_camp_script = load("res://scripts/demo_enemy_camp.gd") as GDScript
	if _camp_script == null:
		return "scripts/demo_enemy_camp.gd did not compile"

	_world = Node3D.new()
	root.add_child(_world)
	await process_frame

	_events.connect("camp_state_changed", _on_camp_state_changed)
	_events.connect("camp_chest_opened", _on_camp_chest_opened)
	LootTableService.seed_all(8080)
	return ""


# --- the behaviour that must survive the refactor -------------------------

func _check_clear_to_unlock() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var camp = await _make_camp("ClearCamp", {"reward_bone_id": "heavy_bone"})
	var enemy_a := _make_enemy()
	var enemy_b := _make_enemy()

	camp.register_enemy(enemy_a)
	camp.register_enemy(enemy_b)

	# Registering must switch respawn off, or a camp could never be cleared.
	if enemy_a.respawn_enabled or enemy_b.respawn_enabled:
		failures.append("registering an enemy did not disable its respawn")

	var chest = camp.chest
	if chest == null:
		failures.append("the camp did not build a chest")
		_teardown([camp, enemy_a, enemy_b, player])
		return failures

	_enter(chest, player)
	if camp.unlocked:
		failures.append("a camp with two live enemies reported itself unlocked")
	if chest.can_be_opened_now():
		failures.append("the chest was openable with enemies still alive")
	if not chest.open().is_empty():
		failures.append("a locked camp chest handed out loot")

	# One down, one to go.
	enemy_a.alive = false
	_events.emit_signal("enemy_defeated", enemy_a, "")
	if camp.unlocked:
		failures.append("the camp unlocked with one enemy still alive")
	if camp._remaining_enemy_count() != 1:
		failures.append("remaining count was %d after one death, expected 1" % camp._remaining_enemy_count())

	# A death the camp does not own must be ignored.
	var stranger := _make_enemy()
	stranger.alive = false
	_events.emit_signal("enemy_defeated", stranger, "")
	if camp.unlocked:
		failures.append("an unrelated enemy's death unlocked the camp")

	_state_events.clear()
	enemy_b.alive = false
	_events.emit_signal("enemy_defeated", enemy_b, "")

	if not camp.unlocked:
		failures.append("clearing every enemy did not unlock the camp")
	if not chest.unlocked:
		failures.append("the camp unlocked but did not unlock its chest")
	if not _has_state_event(true, false):
		failures.append("no camp_state_changed(unlocked) was emitted; the tutorial hint would never fire")

	# Claim the reward.
	_camp_reward_events.clear()
	var contents: Array[String] = chest.open()

	if contents.size() != 1:
		failures.append("the single-reward camp produced %d pieces, expected 1" % contents.size())
	elif BoneInstanceService.bone_id_of(contents[0]) != "heavy_bone":
		failures.append("the camp gave '%s' instead of its reward_bone_id" % BoneInstanceService.bone_id_of(contents[0]))
	if player.collected != contents:
		failures.append("the camp reward did not go straight into the inventory")
	if not camp.opened:
		failures.append("opening the chest did not mark the camp opened")
	if _camp_reward_events.size() != 1:
		failures.append("expected one camp_chest_opened event, got %d" % _camp_reward_events.size())
	if not _has_state_event(true, true):
		failures.append("no camp_state_changed(opened) was emitted")

	# The interact reservation must come back, exactly as before the refactor.
	if player.interact_reservations != 0:
		failures.append("opening left %d interact reservations" % player.interact_reservations)

	print("clear-to-unlock: locked at 2 alive, locked at 1, unlocked at 0, reward %s" % str(_describe(contents)))
	_teardown([camp, enemy_a, enemy_b, stranger, player])
	return failures


func _check_loot_table_camp() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	# A camp given a real table must use it and ignore the legacy single bone.
	var camp = await _make_camp("TableCamp", {"reward_bone_id": "heavy_bone", "loot_table_id": "reach_cache"})
	var enemy := _make_enemy()
	camp.register_enemy(enemy)

	enemy.alive = false
	_events.emit_signal("enemy_defeated", enemy, "")

	var chest = camp.chest
	_enter(chest, player)
	var contents: Array[String] = chest.open()

	var bone_ids: Array[String] = []
	for instance_id in contents:
		bone_ids.append(BoneInstanceService.bone_id_of(instance_id))

	if contents.size() < 2:
		failures.append("a table-backed camp produced %d pieces; reach_cache rolls at least 2" % contents.size())
	if not bone_ids.has("arm_bone"):
		failures.append("the table's guaranteed arm_bone was missing; got %s" % str(bone_ids))
	if bone_ids.has("heavy_bone"):
		failures.append("loot_table_id did not take precedence over reward_bone_id")

	print("table-backed camp: %s" % str(_describe(contents)))
	_teardown([camp, enemy, player])
	return failures


func _check_restore_opened() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var camp = await _make_camp("RestoredCamp", {"reward_bone_id": "rib_bone"})
	var enemy := _make_enemy()
	camp.register_enemy(enemy)

	_camp_reward_events.clear()
	camp.chest.restore_state(true, true)

	if not camp.opened:
		failures.append("restoring the chest did not mark the camp opened")
	if not _camp_reward_events.is_empty():
		failures.append("restoring an already-claimed camp re-fired camp_chest_opened")

	_enter(camp.chest, player)
	if not camp.chest.open().is_empty():
		failures.append("a restored-as-opened camp chest handed out loot again")
	if not player.collected.is_empty():
		failures.append("a restored-as-opened camp gave the player pieces")

	# A restored camp must not re-lock itself when its state is next evaluated.
	camp._update_state()
	if camp.chest.opened != true:
		failures.append("re-evaluating a restored camp reopened its chest")

	print("restored camp: stays claimed, gives nothing")
	_teardown([camp, enemy, player])
	return failures


# --- helpers --------------------------------------------------------------

func _make_camp(camp_name: String, exports: Dictionary):
	# Mirrors tutorial_island_builder._create_enemy_camp exactly.
	var camp := Node3D.new()
	camp.name = camp_name
	camp.set_script(_camp_script)
	camp.set("camp_name", camp_name)
	for key in exports:
		camp.set(str(key), exports[key])
	_world.add_child(camp)
	await process_frame
	return camp


func _make_enemy() -> FakeEnemy:
	var enemy := FakeEnemy.new()
	_world.add_child(enemy)
	return enemy


func _make_player() -> FakePlayer:
	var player := FakePlayer.new()
	_world.add_child(player)
	return player


func _enter(chest, player) -> void:
	chest.interact_area.body_entered.emit(player)


func _has_state_event(unlocked: bool, opened: bool) -> bool:
	for event in _state_events:
		var record: Dictionary = event
		if bool(record["unlocked"]) == unlocked and bool(record["opened"]) == opened:
			return true
	return false


func _teardown(nodes: Array) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			node.free()


func _describe(instance_ids: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for instance_id in instance_ids:
		out.append("%s[%s]" % [
			BoneInstanceService.bone_id_of(instance_id),
			BoneInstanceService.quality_id_of(instance_id),
		])
	return out


func _on_camp_state_changed(_camp: Node, unlocked: bool, opened: bool, remaining: int) -> void:
	_state_events.append({"unlocked": unlocked, "opened": opened, "remaining": remaining})


func _on_camp_chest_opened(_camp: Node, reward_bone_id: String, player: Node) -> void:
	_camp_reward_events.append({"reward": reward_bone_id, "player": player})
