extends SceneTree

# Exercises the LootChest state machine against a real scene instance: every
# lock mode, both delivery modes, the once-only open contract, the interact-lock
# balance and the save-restore path.
#
# The player is a stand-in that implements only the four methods a chest is
# allowed to call on it. That is the point: if the chest ever reaches for
# anything else on the player, this check fails loudly.
#
#   godot --headless --path . --script tools/headless_chest_check.gd
#
# Everything that touches chest.gd is reached DYNAMICALLY -- loaded at runtime,
# untyped locals, enum values read off the script resource. Under --script the
# GameEvents autoload is not registered while this file compiles, so any
# compile-time reference to chest.gd (a preload, a `LootChest` annotation, a
# `LootChest.LockMode.NONE`) would drag in bone.gd and fail to compile before
# the first line runs. headless_backstab_club_check.gd stays dynamic for the
# same reason. None of this applies to game code, which compiles after
# autoloads are up -- chest.gd uses GameEvents and preload directly.

var _chest_scene: PackedScene = null
var _chest_script: GDScript = null
var _lock: Dictionary = {}
var _delivery: Dictionary = {}
var _spawn_height: float = 0.05
var _events: Node = null

var _world: Node3D = null
var _opened_events: Array = []
var _state_events: Array = []


class FakePlayer:
	extends Node3D

	var collected: Array[String] = []
	var equipped: Array[String] = []
	# Mirrors Player.nearby_bone_pickups: must return to 0 or the real player
	# would stop responding to Interact everywhere else.
	var interact_reservations: int = 0

	func collect_bone(instance_id: String) -> void:
		collected.append(instance_id)

	func has_bone_equipped(bone_id: String) -> bool:
		return equipped.has(bone_id)

	func enter_interact_range() -> void:
		interact_reservations += 1

	func exit_interact_range() -> void:
		interact_reservations = maxi(interact_reservations - 1, 0)


# Async throughout: a node added during _initialize does not actually enter the
# tree until the main loop ticks, so its @onready references stay null until a
# frame has passed. Every helper that adds a node awaits one before handing it
# back. headless_backstab_club_check.gd warms up its scene the same way.
func _initialize() -> void:
	var setup_error: String = await _setup()
	if setup_error != "":
		print("CHEST CHECK: FAIL\n  - ", setup_error)
		quit(1)
		return

	var failures: Array[String] = []
	failures.append_array(await _check_direct_delivery())
	failures.append_array(await _check_open_is_once_only())
	failures.append_array(await _check_external_lock())
	failures.append_array(await _check_trial_lock())
	failures.append_array(await _check_equipped_bone_lock())
	failures.append_array(await _check_spawn_pickups())
	failures.append_array(await _check_save_restore())
	failures.append_array(await _check_interact_lock_balance())
	failures.append_array(await _check_missing_table_is_survivable())

	print("")
	if failures.is_empty():
		print("CHEST CHECK: PASS")
	else:
		print("CHEST CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)

	_world.free()
	quit(0 if failures.is_empty() else 1)


# Returns a reason on failure, "" on success. A degraded run must stop here
# rather than report PASS because every later assertion silently no-opped.
func _setup() -> String:
	_events = root.get_node_or_null("GameEvents")
	if _events == null:
		return "the GameEvents autoload is not available"

	_chest_script = load("res://scripts/chest.gd") as GDScript
	if _chest_script == null:
		return "scripts/chest.gd did not compile"

	_chest_scene = load("res://scenes/chest.tscn") as PackedScene
	if _chest_scene == null:
		return "scenes/chest.tscn did not load"

	# Enum values and constants read off the real script, so this check can
	# never drift from chest.gd's own definitions.
	_lock = _chest_script.get("LockMode")
	_delivery = _chest_script.get("DeliveryMode")
	_spawn_height = float(_chest_script.get("SPAWN_HEIGHT"))
	if _lock.is_empty() or _delivery.is_empty():
		return "could not read LockMode/DeliveryMode off chest.gd"

	_world = Node3D.new()
	root.add_child(_world)
	await process_frame

	var probe = _chest_scene.instantiate()
	if probe == null or not probe.has_method("open"):
		return "chest.tscn did not instantiate a working LootChest"
	probe.free()

	_events.connect("chest_opened", _on_chest_opened)
	_events.connect("chest_state_changed", _on_chest_state_changed)
	LootTableService.seed_all(24601)
	return ""


# --- the normal case ------------------------------------------------------

func _check_direct_delivery() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("direct_test", "reach_cache", _lock["NONE"], _delivery["DIRECT_TO_INVENTORY"])

	_enter(chest, player)
	if not chest.can_be_opened_now():
		failures.append("an unlocked chest with a player present reported itself unopenable")

	_opened_events.clear()
	var contents: Array[String] = chest.open()

	if contents.is_empty():
		failures.append("open() produced no contents")
	if player.collected != contents:
		failures.append("DIRECT_TO_INVENTORY did not hand the player exactly the opened contents")

	# Every piece must be a real instance with a rolled quality, and no two
	# pieces may share an identity.
	var seen: Dictionary = {}
	for instance_id in contents:
		if not BoneInstanceService.is_instance_id(instance_id):
			failures.append("content '%s' is not an instance id" % instance_id)
		if seen.has(instance_id):
			failures.append("chest handed out the same instance twice: %s" % instance_id)
		seen[instance_id] = true
		if not BoneQualityService.is_quality_id(BoneInstanceService.quality_id_of(instance_id)):
			failures.append("content '%s' has no valid quality" % instance_id)

	# reach_cache guarantees an arm_bone.
	var bone_ids: Array[String] = []
	for instance_id in contents:
		bone_ids.append(BoneInstanceService.bone_id_of(instance_id))
	if not bone_ids.has("arm_bone"):
		failures.append("reach_cache did not deliver its guaranteed arm_bone; got %s" % str(bone_ids))

	# Resolving a piece must never re-roll it.
	if not contents.is_empty():
		var first: String = contents[0]
		var original := BoneInstanceService.quality_id_of(first)
		for i in range(20):
			BoneRulesService.adjusted_player_bonus_for(first)
			BoneInstanceService.resolve(first)
		if BoneInstanceService.quality_id_of(first) != original:
			failures.append("a chest piece changed quality after being resolved")

	if _opened_events.size() != 1:
		failures.append("expected exactly one chest_opened event, got %d" % _opened_events.size())
	elif str((_opened_events[0] as Dictionary)["chest_id"]) != "direct_test":
		failures.append("chest_opened reported the wrong chest_id")

	print("direct delivery: %s" % str(_describe(contents)))
	_teardown(chest, player)
	return failures


func _check_open_is_once_only() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("once_test", "field_cache", _lock["NONE"], _delivery["DIRECT_TO_INVENTORY"])

	_enter(chest, player)
	var first: Array[String] = chest.open()
	_opened_events.clear()
	var second: Array[String] = chest.open()

	if first.is_empty():
		failures.append("the first open produced nothing")
	if not second.is_empty():
		failures.append("a second open produced loot; a chest must empty exactly once")
	if player.collected.size() != first.size():
		failures.append("reopening handed the player extra pieces")
	if not _opened_events.is_empty():
		failures.append("reopening an empty chest still emitted chest_opened")
	if chest.can_be_opened_now():
		failures.append("an opened chest still reports itself openable")

	print("once-only: first %d pieces, second %d" % [first.size(), second.size()])
	_teardown(chest, player)
	return failures


# --- locks ----------------------------------------------------------------

func _check_external_lock() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("external_test", "field_cache", _lock["EXTERNAL"], _delivery["DIRECT_TO_INVENTORY"])

	_enter(chest, player)
	if chest.can_be_opened_now():
		failures.append("an EXTERNAL chest was openable before anyone unlocked it")
	if not chest.open().is_empty():
		failures.append("a locked EXTERNAL chest handed out loot")

	chest.unlock()
	if not chest.can_be_opened_now():
		failures.append("unlock() did not make the chest openable")
	if chest.open().is_empty():
		failures.append("an unlocked EXTERNAL chest produced nothing")

	print("external lock: refused while locked, opened after unlock()")
	_teardown(chest, player)
	return failures


func _check_trial_lock() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("trial_test", "quickroot_cache", _lock["TRIAL"], _delivery["DIRECT_TO_INVENTORY"])
	chest.required_trial_id = "leg_trial"

	_enter(chest, player)
	_events.emit_signal("trial_completed", "arm_trial", "Arm Trial")
	if chest.unlocked:
		failures.append("an unrelated trial unlocked the chest")

	_events.emit_signal("trial_completed", "leg_trial", "Leg Trial")
	if not chest.unlocked:
		failures.append("the matching trial did not unlock the chest")
	if chest.open().is_empty():
		failures.append("a trial-unlocked chest produced nothing")

	print("trial lock: ignored 'arm_trial', opened on 'leg_trial'")
	_teardown(chest, player)
	return failures


func _check_equipped_bone_lock() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("equipped_test", "heavy_cache", _lock["EQUIPPED_BONE"], _delivery["DIRECT_TO_INVENTORY"])
	chest.required_bone_id = "arm_bone"

	_enter(chest, player)
	if chest.can_be_opened_now():
		failures.append("an EQUIPPED_BONE chest opened without the required piece")

	# Equipping while standing at the chest must take effect with no event.
	player.equipped.append("arm_bone")
	if not chest.can_be_opened_now():
		failures.append("equipping the required bone did not make the chest openable")

	# ...and unequipping must close it again.
	player.equipped.clear()
	if chest.can_be_opened_now():
		failures.append("unequipping the required bone left the chest openable")

	player.equipped.append("arm_bone")
	if chest.open().is_empty():
		failures.append("an EQUIPPED_BONE chest produced nothing once satisfied")

	print("equipped-bone lock: tracks equip and unequip live")
	_teardown(chest, player)
	return failures


# --- delivery -------------------------------------------------------------

func _check_spawn_pickups() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("spawn_test", "elder_cache", _lock["NONE"], _delivery["SPAWN_PICKUPS"])

	var before: int = _world.get_child_count()
	_enter(chest, player)
	var contents: Array[String] = chest.open()
	var spawned: int = _world.get_child_count() - before

	if contents.is_empty():
		failures.append("elder_cache produced nothing")
	if spawned != contents.size():
		failures.append("expected %d spawned pickups, found %d" % [contents.size(), spawned])
	if not player.collected.is_empty():
		failures.append("SPAWN_PICKUPS put pieces straight into the inventory")

	# Each spawned pickup must carry one of the created instances, sit at ground
	# height, and hold a distinct position so two pieces never overlap.
	var carried: Array[String] = []
	var positions: Array[Vector3] = []
	for child in _world.get_children():
		if not child.has_method("set_bone_id"):
			continue
		var pickup := child as Node3D
		if pickup == null:
			continue
		carried.append(str(pickup.get("bone_id")))
		positions.append(pickup.global_position)
		if absf(pickup.global_position.y - _spawn_height) > 0.001:
			failures.append("a pickup spawned at y=%.3f instead of ground height" % pickup.global_position.y)

	for instance_id in contents:
		if not carried.has(instance_id):
			failures.append("no pickup carries instance %s" % instance_id)

	for i in range(positions.size()):
		for j in range(i + 1, positions.size()):
			if positions[i].distance_to(positions[j]) < 0.01:
				failures.append("two pickups spawned on the same spot")

	print("spawn delivery: %d pickups for %d pieces -> %s" % [spawned, contents.size(), str(_describe(contents))])
	_teardown(chest, player)
	return failures


# --- persistence seam -----------------------------------------------------

func _check_save_restore() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("restore_test", "field_cache", _lock["EXTERNAL"], _delivery["DIRECT_TO_INVENTORY"])

	_opened_events.clear()
	var before: int = _world.get_child_count()
	chest.restore_state(true, true)

	if not chest.opened:
		failures.append("restore_state(true, true) did not mark the chest opened")
	if not _opened_events.is_empty():
		failures.append("restoring a saved chest re-fired chest_opened")
	if _world.get_child_count() != before:
		failures.append("restoring a saved chest spawned loot again")

	_enter(chest, player)
	if chest.can_be_opened_now():
		failures.append("a restored-as-opened chest is openable again")
	if not chest.open().is_empty():
		failures.append("a restored-as-opened chest handed out loot again")
	if not player.collected.is_empty():
		failures.append("a restored-as-opened chest gave the player pieces")

	print("save restore: silent, gives nothing, stays empty")
	_teardown(chest, player)
	return failures


func _check_interact_lock_balance() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("balance_test", "field_cache", _lock["NONE"], _delivery["DIRECT_TO_INVENTORY"])

	# Walk in and out repeatedly without opening.
	for i in range(5):
		_enter(chest, player)
		if player.interact_reservations != 1:
			failures.append("entering reserved %d interact locks, expected 1" % player.interact_reservations)
		_exit(chest, player)
		if player.interact_reservations != 0:
			failures.append("leaving left %d interact locks reserved" % player.interact_reservations)

	# Opening releases the lock, and walking out afterwards must not double-release.
	_enter(chest, player)
	chest.open()
	if player.interact_reservations != 0:
		failures.append("opening left %d interact locks reserved" % player.interact_reservations)
	_exit(chest, player)
	if player.interact_reservations != 0:
		failures.append("leaving after opening drove reservations to %d" % player.interact_reservations)

	print("interact lock: balanced across 5 enter/exit cycles and an open")
	_teardown(chest, player)
	return failures


func _check_missing_table_is_survivable() -> Array[String]:
	var failures: Array[String] = []
	var player := _make_player()
	var chest = await _make_chest("broken_test", "table_that_does_not_exist", _lock["NONE"], _delivery["DIRECT_TO_INVENTORY"])

	if chest.is_openable_source():
		failures.append("a chest with an unknown table claimed a valid loot source")

	_enter(chest, player)
	# It still "opens" -- the player pressed the button and got feedback -- it
	# just has nothing in it. What must NOT happen is a crash.
	if not chest.open().is_empty():
		failures.append("an unknown table produced loot")

	# The single-reward compatibility path must rescue exactly this case.
	var rescued = await _make_chest("rescued_test", "table_that_does_not_exist", _lock["NONE"], _delivery["DIRECT_TO_INVENTORY"])
	rescued.use_single_bone_reward("dummy_bone")
	if not rescued.is_openable_source():
		failures.append("use_single_bone_reward did not give the chest a loot source")
	_enter(rescued, player)
	var rescued_contents: Array[String] = rescued.open()
	if rescued_contents.size() != 1 or BoneInstanceService.bone_id_of(rescued_contents[0]) != "dummy_bone":
		failures.append("use_single_bone_reward did not deliver exactly its one bone")
	else:
		print("single reward path: %s" % str(_describe(rescued_contents)))

	_teardown(chest, player)
	_teardown(rescued, null)
	return failures


# --- helpers --------------------------------------------------------------

func _make_player() -> FakePlayer:
	var player := FakePlayer.new()
	_world.add_child(player)
	return player


# Exported values are set BEFORE add_child so _ready sees the configured chest,
# exactly like a chest placed in a scene file. The awaited frame is what makes
# the @onready node references resolve.
func _make_chest(id: String, table_id: String, lock_mode: int, delivery: int):
	var chest = _chest_scene.instantiate()
	chest.chest_id = id
	chest.loot_table_id = table_id
	chest.lock_mode = lock_mode
	chest.delivery_mode = delivery
	_world.add_child(chest)
	await process_frame
	return chest


# Drives the real Area3D handler rather than poking player_in_range, so the
# entry path this check covers is the one the game actually uses.
func _enter(chest, player: FakePlayer) -> void:
	chest.interact_area.body_entered.emit(player)


func _exit(chest, player: FakePlayer) -> void:
	chest.interact_area.body_exited.emit(player)


func _teardown(chest, player) -> void:
	if chest != null:
		chest.free()
	if player != null:
		player.free()
	for child in _world.get_children():
		if child.has_method("set_bone_id"):
			child.free()


func _describe(instance_ids: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for instance_id in instance_ids:
		out.append("%s[%s]" % [
			BoneInstanceService.bone_id_of(instance_id),
			BoneInstanceService.quality_id_of(instance_id),
		])
	return out


func _on_chest_opened(_chest: Node, chest_id: String, contents: Array, player: Node) -> void:
	_opened_events.append({"chest_id": chest_id, "contents": contents, "player": player})


func _on_chest_state_changed(_chest: Node, chest_id: String, unlocked: bool, opened: bool) -> void:
	_state_events.append({"chest_id": chest_id, "unlocked": unlocked, "opened": opened})
