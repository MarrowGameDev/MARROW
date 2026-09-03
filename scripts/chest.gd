class_name LootChest
extends Node3D

# A container the player holds Interact to open. What comes out is decided by a
# LootTableDefinition; when it can be opened is decided by lock_mode.
#
# Responsibilities kept OUT of this script on purpose:
#   * What loot exists            -> LootTableService / data/loot_tables/*.tres
#   * When a piece exists         -> BoneInstanceService.create_instance
#   * How long a hold takes/reads -> DropPickupRulesService
#   * Whether it was opened before -> the caller restoring a save (see
#     restore_state), never this node guessing.
#
# What is left here is exactly one thing: the state machine of one container.

enum LockMode {
	# Openable immediately.
	NONE,
	# Someone else owns the unlock and calls unlock(). Used by DemoEnemyCamp.
	EXTERNAL,
	# Unlocks when GameEvents.trial_completed fires for required_trial_id.
	TRIAL,
	# Unlocks while the player has required_bone_id equipped. Same contract as
	# BoneTrialGate, so a "prove you have arms" chest reads identically to a
	# "prove you have arms" gate.
	EQUIPPED_BONE,
}

enum DeliveryMode {
	# Pieces drop as real pickups the player then collects. Default because it
	# reuses the pickup flow players already know and needs no new UI.
	SPAWN_PICKUPS,
	# Pieces go straight into the inventory. For rewards that must not be
	# missable, e.g. a container in a spot the player cannot return to.
	DIRECT_TO_INVENTORY,
}

const BONE_SCENE: PackedScene = preload("res://scenes/bone.tscn")

const LOCKED_COLOR := Color(0.30, 0.18, 0.08, 1.0)
const UNLOCKED_COLOR := Color(0.82, 0.62, 0.22, 1.0)
const OPENED_COLOR := Color(0.16, 0.48, 0.20, 1.0)
const OPEN_LID_ANGLE := -1.15

# Pickups land on a ring so several pieces never spawn inside each other.
const SPAWN_RADIUS := 0.9
const SPAWN_HEIGHT := 0.05
# The ring is centred on LootSpawnPoint, which sits in FRONT of the chest, but
# "in front" is the chest's own +Z -- if a chest is rotated, or the player walks
# around it, the loot can land behind the box and read as nothing happening.
# The ring is therefore rotated so its first piece faces whoever opened it.
const SPAWN_TOWARD_OPENER := true

# Cached presentation state, so the per-frame refreshers can no-op.
const VISUAL_LOCKED := 0
const VISUAL_UNLOCKED := 1
const VISUAL_OPENED := 2

@export_group("Identity")
# Must be unique per placed chest: this is the key a save uses to remember the
# chest was already emptied. Empty means "not persisted" -- fine for a test
# scene, wrong for the real map.
@export var chest_id: String = ""
@export var display_name: String = "Chest"

@export_group("Contents")
@export var loot_table_id: String = "field_cache"
@export var delivery_mode: DeliveryMode = DeliveryMode.SPAWN_PICKUPS

@export_group("Access")
@export var lock_mode: LockMode = LockMode.NONE
@export var required_trial_id: String = ""
@export var required_bone_id: String = ""
@export var open_hold_time: float = 0.65

var unlocked: bool = false
var opened: bool = false

var player_in_range: Node3D = null
var interact_reserved: bool = false
var hold_progress: float = 0.0
# See DropPickupRulesService.next_fresh_press_latch. Walking from one container
# to the next without letting go must not open the second one for free.
var awaiting_fresh_press: bool = false

# Set when a chest opens from an inline table instead of loot_table_id. Lets
# DemoEnemyCamp keep its single reward_bone_id without a second reward path.
var _inline_table: LootTableDefinition = null

# What this chest just handed over, in display names. Kept only while the
# player who opened it is still standing here: the label has to answer "what did
# I just get?", and once they walk away the answer stops being useful.
var _last_contents_names: Array[String] = []

var _base_material: StandardMaterial3D = null
var _lid_material: StandardMaterial3D = null
var _last_visual_state: int = -1
var _last_prompt: String = ""

@onready var chest_base: MeshInstance3D = $ChestBody/Base
@onready var chest_lid: Node3D = $ChestBody/LidPivot
@onready var lid_mesh: MeshInstance3D = $ChestBody/LidPivot/Lid
@onready var interact_area: Area3D = $InteractArea
@onready var prompt_label: Label3D = $PromptLabel
@onready var loot_spawn_point: Marker3D = $LootSpawnPoint


func _ready() -> void:
	add_to_group("loot_chests")
	_prepare_materials()

	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

	if lock_mode == LockMode.NONE:
		unlocked = true
	elif lock_mode == LockMode.TRIAL:
		GameEvents.trial_completed.connect(_on_trial_completed)

	# Nothing to tick until a player is actually standing here.
	set_process(false)
	_refresh_visuals()
	_refresh_prompt()
	_emit_state_changed()


# Ticks only while a player is standing here (see _update_processing). The
# openable check is re-evaluated every frame rather than latched, because an
# EQUIPPED_BONE chest can become openable without any event firing -- the player
# just equips the piece while standing at it.
func _process(delta: float) -> void:
	var is_holding: bool = Input.is_action_pressed(DropPickupRulesService.PICKUP_ACTION)
	awaiting_fresh_press = DropPickupRulesService.next_fresh_press_latch(awaiting_fresh_press, is_holding)

	if can_be_opened_now() and not awaiting_fresh_press:
		hold_progress = DropPickupRulesService.next_pickup_hold_progress(hold_progress, delta, is_holding)
		if is_holding and DropPickupRulesService.pickup_hold_is_complete(hold_progress, open_hold_time):
			open()
			return
	elif hold_progress > 0.0:
		hold_progress = 0.0

	_refresh_prompt()
	_refresh_visuals()


# --- public state ---------------------------------------------------------

# Called by whatever owns an EXTERNAL lock (a camp clearing its enemies, a
# future quest step). Safe to call repeatedly.
func unlock() -> void:
	if unlocked:
		return
	unlocked = true
	_refresh_visuals()
	_refresh_prompt()
	_update_processing()
	_emit_state_changed()


func lock() -> void:
	if not unlocked or opened:
		return
	unlocked = false
	_refresh_visuals()
	_refresh_prompt()
	_emit_state_changed()


# The single reward id path, kept so a container that only knows one bone does
# not need an authored .tres. Applying it does NOT open the chest.
func use_single_bone_reward(bone_id: String) -> void:
	if bone_id == "":
		_inline_table = null
		return
	_inline_table = LootTableService.single_bone_table(bone_id)


func is_openable_source() -> bool:
	return _inline_table != null or LootTableService.has_table(loot_table_id)


func can_be_opened_now() -> bool:
	if opened or player_in_range == null:
		return false
	return _lock_is_satisfied()


# Restores this chest from a save. Deliberately silent: it fires no
# chest_opened, spawns no loot and plays no animation, because whatever the
# player did here they did in an earlier session.
#
# Restoring `unlocked` matters as much as `opened`. A TRIAL chest is unlocked by
# an event that a loaded game never replays -- the trial gate restores itself
# silently, precisely so listeners do not re-fire -- so without this a chest the
# player earned would stay shut forever.
#
# EXTERNAL is the exception: something else in the scene owns that unlock and
# re-derives it from live state (a camp counts its enemies). Letting a save
# override it would put the two out of step, so the flag is ignored and only
# `opened` is honoured.
func restore_state(was_unlocked: bool, was_opened: bool) -> void:
	var target_unlocked: bool = was_unlocked
	if lock_mode == LockMode.EXTERNAL:
		target_unlocked = unlocked
	# An emptied chest is unlocked by definition, whatever the flags say.
	if was_opened:
		target_unlocked = true

	if target_unlocked == unlocked and was_opened == opened:
		return

	unlocked = target_unlocked
	opened = was_opened
	hold_progress = 0.0
	_refresh_visuals(false)
	_refresh_prompt()
	_update_processing()
	_emit_state_changed()


func open() -> Array[String]:
	var contents: Array[String] = []
	if opened or not _lock_is_satisfied():
		return contents

	opened = true
	hold_progress = 0.0

	contents = _create_contents()
	_deliver(contents)
	_announce(contents)

	_refresh_visuals()
	_refresh_prompt()
	_release_interact_lock()
	_update_processing()

	GameEvents.chest_opened.emit(self, chest_id, contents, player_in_range)
	_emit_state_changed()
	return contents


# Tells the player what they got. Without this the only feedback was the lid
# tilting and a label reading "Empty", which is indistinguishable from a chest
# that really had nothing -- and with SPAWN_PICKUPS the pieces land on the floor
# where they are easy to walk past.
func _announce(instance_ids: Array[String]) -> void:
	_last_contents_names.clear()
	for instance_id in instance_ids:
		_last_contents_names.append("%s (%s)" % [
			BoneRulesService.display_name_with_slot(instance_id),
			BoneRulesService.quality_display_name_for(instance_id),
		])

	if _last_contents_names.is_empty():
		GameEvents.tutorial_hint_requested.emit(self, "chest_empty", display_name + " was empty.", 2)
		return

	var verb := "Taken" if delivery_mode == DeliveryMode.DIRECT_TO_INVENTORY else "Dropped at your feet"
	GameEvents.tutorial_hint_requested.emit(
		self,
		"chest_opened",
		"%s -- %s:\n%s" % [display_name, verb, "\n".join(_last_contents_names)],
		2
	)
	print("Chest ", _identity(), " gave: ", ", ".join(_last_contents_names))


# --- contents -------------------------------------------------------------

# The one place a chest's pieces come into existence. Each entry is created
# with the quality the table already rolled for it, so the roll happens exactly
# once per piece -- BoneInstanceService never re-rolls what it is handed.
func _create_contents() -> Array[String]:
	var instance_ids: Array[String] = []
	var loot: Array[Dictionary] = _roll_loot()
	if loot.is_empty():
		push_warning("LootChest '%s': loot table '%s' produced nothing." % [_identity(), loot_table_id])
		return instance_ids

	for entry in loot:
		instance_ids.append(BoneInstanceService.create_instance(str(entry["bone_id"]), str(entry["quality_id"])))
	return instance_ids


func _roll_loot() -> Array[Dictionary]:
	if _inline_table != null:
		return LootTableService.roll_loot_from(_inline_table)
	return LootTableService.roll_loot(loot_table_id)


func _deliver(instance_ids: Array[String]) -> void:
	if delivery_mode == DeliveryMode.DIRECT_TO_INVENTORY and player_in_range != null and player_in_range.has_method("collect_bone"):
		for instance_id in instance_ids:
			player_in_range.call("collect_bone", instance_id)
		return

	for i in range(instance_ids.size()):
		_spawn_pickup(instance_ids[i], i, instance_ids.size())


# Mirrors how Enemy drops a standard bone: instance the shared pickup scene into
# the world, hand it the instance_id, and announce it. Keeping the two identical
# is what lets a chest piece and an enemy piece behave the same afterwards.
func _spawn_pickup(instance_id: String, index: int, total: int) -> void:
	var world: Node = get_parent()
	if world == null:
		return

	var pickup: Node = BONE_SCENE.instantiate()
	world.add_child(pickup)

	var pickup_node := pickup as Node3D
	if pickup_node != null:
		pickup_node.global_position = _spawn_position(index, total)

	if pickup.has_method("set_bone_id"):
		pickup.call("set_bone_id", instance_id)

	GameEvents.drop_spawned.emit(instance_id, pickup, self)


func _spawn_position(index: int, total: int) -> Vector3:
	var origin: Vector3 = global_position
	if loot_spawn_point != null:
		origin = loot_spawn_point.global_position

	# Ground height is absolute: the pickup has to end up ON the floor, not at
	# whatever height the chest happens to sit.
	if total <= 1:
		return Vector3(origin.x, SPAWN_HEIGHT, origin.z)

	var base_angle: float = 0.0
	if SPAWN_TOWARD_OPENER and player_in_range != null and is_instance_valid(player_in_range):
		var toward_player: Vector3 = player_in_range.global_position - origin
		if Vector2(toward_player.x, toward_player.z).length() > 0.01:
			base_angle = atan2(toward_player.z, toward_player.x)

	var angle: float = base_angle + TAU * float(index) / float(total)
	return Vector3(
		origin.x + cos(angle) * SPAWN_RADIUS,
		SPAWN_HEIGHT,
		origin.z + sin(angle) * SPAWN_RADIUS
	)


# --- access ---------------------------------------------------------------

func _lock_is_satisfied() -> bool:
	match lock_mode:
		LockMode.NONE:
			return true
		LockMode.EQUIPPED_BONE:
			# Evaluated live rather than latched: unequipping the piece closes
			# the chest again, exactly like BoneTrialGate re-blocks.
			return _player_has_required_bone()
		_:
			return unlocked


func _player_has_required_bone() -> bool:
	if required_bone_id == "" or player_in_range == null:
		return false
	if not player_in_range.has_method("has_bone_equipped"):
		return false
	return bool(player_in_range.call("has_bone_equipped", required_bone_id))


func _on_trial_completed(trial_id: String, _trial_name: String) -> void:
	if lock_mode == LockMode.TRIAL and trial_id == required_trial_id:
		unlock()


func _on_body_entered(body: Node3D) -> void:
	if opened or player_in_range != null:
		return
	if not body.has_method("collect_bone"):
		return

	player_in_range = body
	hold_progress = 0.0
	awaiting_fresh_press = DropPickupRulesService.interact_is_held()
	_reserve_interact_lock()
	_update_processing()
	_refresh_prompt()
	_refresh_visuals()


func _on_body_exited(body: Node3D) -> void:
	if body != player_in_range:
		return

	_release_interact_lock()
	player_in_range = null
	hold_progress = 0.0
	# The "here is what you got" label is for the person who just opened it.
	_last_contents_names.clear()
	_update_processing()
	_refresh_prompt()
	_refresh_visuals()


func _update_processing() -> void:
	set_process(player_in_range != null and not opened)


# The player counts nearby interactables so Interact is not consumed by two
# things at once. Reserving and releasing must stay balanced or the count
# drifts and E stops working elsewhere.
func _reserve_interact_lock() -> void:
	if interact_reserved or player_in_range == null:
		return
	if player_in_range.has_method("enter_interact_range"):
		player_in_range.call("enter_interact_range")
		interact_reserved = true


func _release_interact_lock() -> void:
	if not interact_reserved or player_in_range == null:
		return
	if player_in_range.has_method("exit_interact_range"):
		player_in_range.call("exit_interact_range")
	interact_reserved = false


# --- presentation ---------------------------------------------------------

# Every chest owns copies of its materials, so recolouring one never bleeds
# into another chest that happens to share the scene's material resource.
func _prepare_materials() -> void:
	_base_material = _own_material(chest_base)
	_lid_material = _own_material(lid_mesh)


func _own_material(mesh: MeshInstance3D) -> StandardMaterial3D:
	if mesh == null:
		return null
	var existing := mesh.get_surface_override_material(0)
	var material: StandardMaterial3D = null
	if existing != null:
		material = existing.duplicate() as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
	mesh.set_surface_override_material(0, material)
	return material


# Both refreshers below are idempotent: they compare against what is already on
# screen and return early when nothing changed. That is what makes it safe for
# _process to call them every frame while the player stands here, instead of
# every state transition having to remember to call them.
func _refresh_visuals(animate: bool = true) -> void:
	var state: int = _visual_state()
	if state == _last_visual_state:
		return
	_last_visual_state = state

	var color: Color = LOCKED_COLOR
	match state:
		VISUAL_OPENED:
			color = OPENED_COLOR
		VISUAL_UNLOCKED:
			color = UNLOCKED_COLOR
		_:
			color = LOCKED_COLOR

	if _base_material != null:
		_base_material.albedo_color = color
	if _lid_material != null:
		_lid_material.albedo_color = color.lightened(0.2)

	if chest_lid == null:
		return
	var target_angle: float = OPEN_LID_ANGLE if opened else 0.0
	if not animate or not is_inside_tree():
		chest_lid.rotation.x = target_angle
		return
	var tween := create_tween()
	tween.tween_property(chest_lid, "rotation:x", target_angle, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _visual_state() -> int:
	if opened:
		return VISUAL_OPENED
	if unlocked or _lock_is_satisfied():
		return VISUAL_UNLOCKED
	return VISUAL_LOCKED


# Label3D rebuilds its text mesh on every assignment, so only assign on change.
func _refresh_prompt() -> void:
	if prompt_label == null:
		return
	var text: String = _prompt_text()
	if text == _last_prompt:
		return
	_last_prompt = text
	prompt_label.text = text


func _prompt_text() -> String:
	if opened:
		# "Empty" alone read as "this chest had nothing in it". Name the pieces
		# while the opener is still here, and say "Already opened" after, which
		# describes the chest rather than accusing it of being empty.
		if not _last_contents_names.is_empty():
			return display_name + "\n" + "\n".join(_last_contents_names)
		return display_name + "\nAlready opened"
	if not is_openable_source():
		return display_name + "\nNo loot table"

	match lock_mode:
		LockMode.EQUIPPED_BONE:
			if not _player_has_required_bone():
				return display_name + "\nEquip " + BoneRulesService.display_name_with_slot(required_bone_id)
		LockMode.TRIAL:
			if not unlocked:
				return display_name + "\nLocked"
		LockMode.EXTERNAL:
			if not unlocked:
				return display_name + "\nLocked"
		_:
			pass

	if player_in_range == null:
		return display_name + "\nUnlocked"

	var percent: int = clampi(int((hold_progress / maxf(0.01, open_hold_time)) * 100.0), 0, 100)
	return display_name + "\nHold " + DropPickupRulesService.action_binding_text(DropPickupRulesService.PICKUP_ACTION) + " to open: " + str(percent) + "%"


func _emit_state_changed() -> void:
	GameEvents.chest_state_changed.emit(self, chest_id, unlocked, opened)


func _identity() -> String:
	return chest_id if chest_id != "" else name
