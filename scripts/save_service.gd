class_name SaveService

# Reads and writes one save file, and knows the ORDER a game state has to be
# rebuilt in. It owns no scene state and holds no reference to anything: a
# caller hands it the player and the world root, it hands back a Dictionary.
# SaveCoordinator is what decides WHEN any of this happens.
#
# What is saved, and why that is the whole list:
#
#   instances  The piece registry. Restored FIRST, because every id in
#              inventory and equipment is only meaningful once its instance
#              exists. Quality is restored, never re-rolled.
#   inventory  The ids the player carries.
#   equipment  Slot -> id. Applied through the equipment component's own
#              apply path, torso before limbs.
#   world      Which containers were emptied and which trials were passed.
#              Keyed by chest_id / trial_id, so moving a chest in the editor
#              does not resurrect its loot.
#   player     Health and position.
#   rng        Where the loot and quality generators had got to, so loading
#              does not replay the same rolls.
#
# Equipment build presets are deliberately NOT here: they already persist
# separately and correctly in user://equipment_builds.cfg, and they are a
# player preference that should survive starting a new game.

const DEFAULT_SAVE_PATH := "user://marrow_save.json"
# Bumped only when an older file can no longer be read as-is. load_from_disk
# refuses a version it does not understand rather than half-applying it.
const SAVE_VERSION := 1

static var _save_path: String = DEFAULT_SAVE_PATH


static func save_path() -> String:
	return _save_path


# Test hook: point the service at a scratch file so a check can never clobber a
# real player's save. Pass "" to go back to the default.
static func set_save_path(path: String) -> void:
	_save_path = path if path != "" else DEFAULT_SAVE_PATH

# A camp's reward chest is a LootChest like any other and is already in the
# chest group, so camps need no entry of their own here -- they mirror their
# chest's state through GameEvents.chest_state_changed.
const CHEST_GROUP := "loot_chests"
const TRIAL_GROUP := "bone_trial_gates"
# Permanent roster, unlike "enemies" which a dying enemy leaves. See Enemy._ready.
const ENEMY_RECORD_GROUP := "enemy_records"
const CAMP_GROUP := "enemy_camps"


# --- disk -----------------------------------------------------------------

static func has_save() -> bool:
	return FileAccess.file_exists(_save_path)


static func save_to_disk(data: Dictionary) -> bool:
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveService: could not open %s for writing (error %d)." % [_save_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


# Returns an empty Dictionary for "no usable save". A corrupt or future-version
# file is treated the same way as no file at all: refusing is recoverable,
# half-applying is not.
static func load_from_disk() -> Dictionary:
	if not has_save():
		return {}

	var file := FileAccess.open(_save_path, FileAccess.READ)
	if file == null:
		push_warning("SaveService: could not open %s for reading (error %d)." % [_save_path, FileAccess.get_open_error()])
		return {}

	var raw := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		push_warning("SaveService: %s is not valid save JSON; ignoring it." % _save_path)
		return {}

	var data: Dictionary = parsed
	var version := int(data.get("version", 0))
	if version != SAVE_VERSION:
		push_warning("SaveService: save version %d cannot be read by version %d; ignoring it." % [version, SAVE_VERSION])
		return {}
	return data


static func delete_save() -> bool:
	if not has_save():
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(_save_path)) == OK


# --- capture --------------------------------------------------------------

# `defeated_keys` carries enemies that died and were freed before this capture.
# A non-respawning enemy queue_frees itself, so by save time it is not in the
# tree to be asked -- and without this it would come back alive on load, which
# is exactly the inconsistency the world state is supposed to prevent. The
# caller (SaveCoordinator) collects them from enemy_defeated as they happen.
static func capture(player: Node, world_root: Node, defeated_keys: Array = []) -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"instances": BoneInstanceService.serialize(),
		"inventory": _capture_inventory(player),
		"equipment": _capture_equipment(player),
		"player": _capture_player(player),
		"world": capture_world(world_root, defeated_keys),
		"rng": {
			"loot_state": LootTableService.rng_state(),
		},
	}


static func capture_world(world_root: Node, defeated_keys: Array = []) -> Dictionary:
	return {
		"chests": _capture_chests(world_root),
		"trials": _capture_completed_ids(world_root, TRIAL_GROUP, "trial_id", "completed"),
		"enemies": _capture_enemies(world_root, defeated_keys),
	}


# How an enemy is identified across sessions: its path under the world root.
# Scene-placed enemies and the ones tutorial_island_builder creates both have
# fixed names, so the path is stable. An enemy renamed in the editor loses its
# saved state, which is the right trade -- the alternative is an authored id on
# every enemy and a validator to keep them unique.
static func enemy_save_key(world_root: Node, enemy: Node) -> String:
	if world_root == null or enemy == null or not is_instance_valid(enemy):
		return ""
	if not world_root.is_inside_tree() or not enemy.is_inside_tree():
		return ""
	return str(world_root.get_path_to(enemy))


# --- restore --------------------------------------------------------------

# Rebuilds the game state from `data`. Returns a report describing what was
# applied and what could not be, so a caller can surface a real message instead
# of guessing. An empty or unusable `data` is a no-op, not an error.
#
# Order is the contract: instances, then inventory, then equipment. Reversing
# any two of those restores a player wearing pieces that do not exist.
static func apply(data: Dictionary, player: Node, world_root: Node) -> Dictionary:
	var report := {
		"applied": false,
		"instances": 0,
		"inventory": 0,
		"dropped": [],
		"equipment": {},
		"equipment_complete": true,
		"world": {},
	}
	if data.is_empty():
		return report

	# 1. The pieces themselves. Everything below is ids into this registry.
	var instances: Dictionary = data.get("instances", {})
	if not instances.is_empty():
		BoneInstanceService.restore(instances)
	report["instances"] = BoneInstanceService.instance_count()

	# 2. What the player carries.
	var inventory_component: Node = player.get("inventory_component") if player != null else null
	if inventory_component != null and inventory_component.has_method("restore_items"):
		var inventory_report: Dictionary = inventory_component.call("restore_items", data.get("inventory", []))
		report["inventory"] = int(inventory_report.get("restored", 0))
		report["dropped"] = inventory_report.get("dropped", [])

	# 3. What the player wears. Through the equipment component's own apply
	#    path, so a restore obeys the same rules as equipping by hand.
	var equipment_component: Node = player.get("equipment_component") if player != null else null
	var target_state: Dictionary = _sanitize_equipment(data.get("equipment", {}))
	if equipment_component != null and equipment_component.has_method("apply_equipment_state"):
		equipment_component.call("apply_equipment_state", target_state)
		report["equipment"] = equipment_component.call("get_equipment_state")
		report["equipment_complete"] = bool(equipment_component.call("matches_equipment_state", target_state))

	_restore_player(player, data.get("player", {}))
	report["world"] = restore_world(world_root, data.get("world", {}))

	var rng: Dictionary = data.get("rng", {})
	if rng.has("loot_state"):
		LootTableService.set_rng_state(int(rng["loot_state"]))

	report["applied"] = true
	return report


# Marks already-emptied containers and already-passed trials. Chests that no
# longer exist are ignored on purpose: the save is a record of ids, not a
# guarantee that the map still contains them.
static func restore_world(world_root: Node, world_data: Dictionary) -> Dictionary:
	var applied := {"chests": 0, "trials": 0, "enemies": 0}
	if world_root == null or world_data.is_empty():
		return applied

	# Enemies first. Camps count live enemies, and a camp asked to recount
	# before its enemies are restored would unlock a chest the player never
	# earned -- or re-lock one they did.
	applied["enemies"] = _restore_enemies(world_root, world_data.get("enemies", []))
	_refresh_camps(world_root)

	applied["chests"] = _restore_chests(world_root, world_data.get("chests", []))
	applied["trials"] = _restore_completed(world_root, TRIAL_GROUP, "trial_id", world_data.get("trials", []), "restore_completed_state")
	return applied


# --- internals ------------------------------------------------------------

static func _capture_inventory(player: Node) -> Array:
	if player == null or not player.has_method("get_inventory_items"):
		return []
	return player.call("get_inventory_items")


static func _capture_equipment(player: Node) -> Dictionary:
	if player == null:
		return {}
	var equipment_component: Node = player.get("equipment_component")
	if equipment_component == null or not equipment_component.has_method("get_equipment_state"):
		return {}
	return _sanitize_equipment(equipment_component.call("get_equipment_state"))


static func _capture_player(player: Node) -> Dictionary:
	if player == null:
		return {}
	var player_node := player as Node3D
	var position: Vector3 = player_node.global_position if player_node != null and player_node.is_inside_tree() else Vector3.ZERO
	return {
		"health": int(player.get("health")),
		"position": [position.x, position.y, position.z],
	}


static func _restore_player(player: Node, player_data: Dictionary) -> void:
	if player == null or player_data.is_empty():
		return

	if player_data.has("health"):
		player.set("health", int(player_data["health"]))
		if player.has_method("recalculate_player_stats"):
			player.call("recalculate_player_stats")

	var raw_position: Array = player_data.get("position", [])
	var player_node := player as Node3D
	if raw_position.size() == 3 and player_node != null and player_node.is_inside_tree():
		player_node.global_position = Vector3(float(raw_position[0]), float(raw_position[1]), float(raw_position[2]))


# The head is the fixed core and is equipped by equip_starting_core, never by a
# restore. Dropping it here keeps a save from fighting that.
static func _sanitize_equipment(raw_state: Dictionary) -> Dictionary:
	var state: Dictionary = {}
	for raw_slot in raw_state:
		var slot_id := EquipmentRulesService.normalize_slot_id(str(raw_slot))
		var bone_id := str(raw_state[raw_slot])
		if slot_id == "" or bone_id == "" or slot_id == EquipmentRulesService.SLOT_HEAD:
			continue
		state[slot_id] = bone_id
	return state


# Chests store both flags. A chest that is still locked and unopened is left
# out entirely: it is in its authored state, so recording it would only grow the
# file. A chest with no chest_id is skipped and warned about -- silently
# dropping it would look like working persistence until a player noticed loot
# respawning.
static func _capture_chests(world_root: Node) -> Array:
	var states: Array = []
	if world_root == null or world_root.get_tree() == null:
		return states

	var seen: Dictionary = {}
	for node in world_root.get_tree().get_nodes_in_group(CHEST_GROUP):
		var unlocked := bool(node.get("unlocked"))
		var opened := bool(node.get("opened"))
		if not unlocked and not opened:
			continue

		var id := str(node.get("chest_id"))
		if id == "":
			push_warning("SaveService: a chest named '%s' has no chest_id and cannot be saved." % node.name)
			continue
		if seen.has(id):
			push_warning("SaveService: chest_id '%s' is used more than once; only the first is saved." % id)
			continue

		seen[id] = true
		states.append({"id": id, "unlocked": unlocked, "opened": opened})
	return states


static func _restore_chests(world_root: Node, saved_chests: Array) -> int:
	if world_root.get_tree() == null:
		return 0

	var wanted: Dictionary = {}
	for raw_entry in saved_chests:
		if not (raw_entry is Dictionary):
			continue
		var entry: Dictionary = raw_entry
		wanted[str(entry.get("id", ""))] = entry

	var applied := 0
	for node in world_root.get_tree().get_nodes_in_group(CHEST_GROUP):
		var id := str(node.get("chest_id"))
		if id == "" or not wanted.has(id):
			continue
		if not node.has_method("restore_state"):
			continue
		var entry: Dictionary = wanted[id]
		node.call("restore_state", bool(entry.get("unlocked", false)), bool(entry.get("opened", false)))
		applied += 1
	return applied


static func _capture_enemies(world_root: Node, defeated_keys: Array) -> Array:
	var states: Array = []
	if world_root == null or world_root.get_tree() == null:
		return states

	var seen: Dictionary = {}
	for enemy in world_root.get_tree().get_nodes_in_group(ENEMY_RECORD_GROUP):
		var key := enemy_save_key(world_root, enemy)
		if key == "" or seen.has(key) or not enemy.has_method("capture_save_state"):
			continue
		seen[key] = true
		var state: Dictionary = enemy.call("capture_save_state")
		state["key"] = key
		states.append(state)

	# Enemies that are already gone. They cannot describe themselves, so all
	# that is recorded is that they are dead -- which is the only thing that
	# still matters about them.
	for raw_key in defeated_keys:
		var key := str(raw_key)
		if key == "" or seen.has(key):
			continue
		seen[key] = true
		states.append({"key": key, "alive": false})

	return states


static func _restore_enemies(world_root: Node, saved_enemies: Array) -> int:
	if world_root.get_tree() == null:
		return 0

	var wanted: Dictionary = {}
	for raw_entry in saved_enemies:
		if raw_entry is Dictionary:
			wanted[str((raw_entry as Dictionary).get("key", ""))] = raw_entry

	var applied := 0
	for enemy in world_root.get_tree().get_nodes_in_group(ENEMY_RECORD_GROUP):
		var key := enemy_save_key(world_root, enemy)
		if key == "" or not wanted.has(key):
			continue
		if not enemy.has_method("restore_save_state"):
			continue
		enemy.call("restore_save_state", wanted[key])
		applied += 1
	return applied


# Camps derive their unlock from how many of their enemies are alive, so after
# enemies change underneath them they have to recount. Without this a camp
# whose enemies were all restored dead would still show "Clear enemies: 2".
static func _refresh_camps(world_root: Node) -> void:
	if world_root.get_tree() == null:
		return
	for camp in world_root.get_tree().get_nodes_in_group(CAMP_GROUP):
		if camp.has_method("refresh_state"):
			camp.call("refresh_state")


static func _capture_completed_ids(world_root: Node, group: String, id_property: String, flag_property: String) -> Array:
	var ids: Array = []
	if world_root == null or world_root.get_tree() == null:
		return ids
	for node in world_root.get_tree().get_nodes_in_group(group):
		if not bool(node.get(flag_property)):
			continue
		var id := str(node.get(id_property))
		if id == "" or ids.has(id):
			continue
		ids.append(id)
	return ids


static func _restore_completed(world_root: Node, group: String, id_property: String, saved_ids: Array, restore_method: String) -> int:
	if world_root.get_tree() == null:
		return 0

	var wanted: Dictionary = {}
	for raw_id in saved_ids:
		wanted[str(raw_id)] = true

	var applied := 0
	for node in world_root.get_tree().get_nodes_in_group(group):
		var id := str(node.get(id_property))
		if id == "" or not wanted.has(id):
			continue
		if not node.has_method(restore_method):
			continue
		node.call(restore_method, true)
		applied += 1
	return applied
