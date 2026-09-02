class_name DemoEnemyCamp
extends Node3D

# A demo encounter pocket: enemies gather around a campfire, and the chest opens
# only after every registered camp enemy has been cleared.
#
# The camp owns ONE rule: are all my enemies dead yet. Everything about the
# container -- how it looks, how long the hold takes, what comes out, whether it
# was already emptied in a previous session -- belongs to the LootChest it
# instances, which is the same chest used everywhere else on the map.

const CHEST_SCENE: PackedScene = preload("res://scenes/chest.tscn")
const CHEST_OFFSET := Vector3(1.8, 0.0, 0.0)

@export var camp_name: String = "Enemy Camp"
# Single-reward compatibility path, kept so existing camps keep giving exactly
# what they gave before. Ignored when loot_table_id names a real table.
@export var reward_bone_id: String = "dummy_bone"
# Preferred for new camps: a real table, so a camp can hand out a small spread
# instead of one fixed bone.
@export var loot_table_id: String = ""
@export var chest_open_hold_time: float = 0.65
# Save key for this camp's chest. Left empty it falls back to the camp's node
# name, which tutorial_island_builder already makes unique per camp.
@export var chest_id: String = ""

var enemies: Array[Node] = []
var unlocked: bool = false
var opened: bool = false

var chest: LootChest = null
var label: Label3D = null
var flame_mesh: MeshInstance3D = null
var flame_time: float = 0.0


func _ready() -> void:
	add_to_group("enemy_camps")
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	GameEvents.chest_opened.connect(_on_chest_opened)
	GameEvents.chest_state_changed.connect(_on_chest_state_changed)
	_build_campfire()
	_build_label()
	_build_chest()
	_update_label()


# Only the campfire flicker lives here now. The chest runs its own hold timer,
# and only while a player is actually standing at it.
func _process(delta: float) -> void:
	if flame_mesh == null:
		return
	flame_time += delta
	flame_mesh.scale = Vector3.ONE * (1.0 + sin(flame_time * 8.0) * 0.12)


func register_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	if not enemies.has(enemy):
		enemies.append(enemy)
		enemy.set("respawn_enabled", false)
	_update_state()
	_emit_camp_state_changed()
	_update_label()


# Recount live enemies and re-derive the lock. Called after a save restore
# swaps this camp's enemies out from under it; also safe to call at any time.
func refresh_state() -> void:
	_update_state()
	_update_label()


func _update_state() -> void:
	if opened:
		return

	var all_cleared := _remaining_enemy_count() == 0
	if all_cleared == unlocked:
		return

	unlocked = all_cleared
	if chest != null:
		if unlocked:
			chest.unlock()
		else:
			chest.lock()
	_emit_camp_state_changed()
	_update_label()


func _on_enemy_defeated(enemy: Node, _dropped_bone_id: String) -> void:
	if not enemies.has(enemy):
		return
	_update_state()
	_update_label()


# The chest is the single source of truth for whether the reward was claimed.
# The camp mirrors it instead of tracking a second copy, which is what lets a
# save restore the chest alone and have the camp label follow.
func _on_chest_state_changed(changed_chest: Node, _chest_id: String, chest_unlocked: bool, chest_opened: bool) -> void:
	if changed_chest != chest:
		return
	if opened == chest_opened and unlocked == chest_unlocked:
		return

	opened = chest_opened
	unlocked = chest_unlocked or chest_opened
	_emit_camp_state_changed()
	_update_label()


func _on_chest_opened(opened_chest: Node, _chest_id: String, contents: Array, player: Node) -> void:
	if opened_chest != chest:
		return

	opened = true
	_emit_camp_state_changed()
	_update_label()
	# Kept for compatibility with anything still listening for the camp-specific
	# event. It reports the first piece, which is what the single reward_bone_id
	# path always produced.
	var reward_id: String = str(contents[0]) if not contents.is_empty() else ""
	GameEvents.camp_chest_opened.emit(self, reward_id, player)


func _emit_camp_state_changed() -> void:
	GameEvents.camp_state_changed.emit(self, unlocked, opened, _remaining_enemy_count())


func _remaining_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if enemy != null and is_instance_valid(enemy) and bool(enemy.get("alive")):
			count += 1
	return count


# --- construction ---------------------------------------------------------

func _build_chest() -> void:
	chest = CHEST_SCENE.instantiate() as LootChest
	if chest == null:
		push_warning("DemoEnemyCamp '%s': chest scene did not instantiate." % camp_name)
		return

	chest.name = "RewardChest"
	chest.position = CHEST_OFFSET
	chest.chest_id = chest_id if chest_id != "" else name + "_chest"
	chest.display_name = camp_name
	chest.open_hold_time = chest_open_hold_time
	# The camp decides when it opens, so the chest waits to be told.
	chest.lock_mode = LootChest.LockMode.EXTERNAL
	chest.delivery_mode = LootChest.DeliveryMode.DIRECT_TO_INVENTORY

	# Exactly one loot source, never both. Leaving the chest's default table id
	# in place while also handing it an inline table would work today (the
	# inline one wins) but would silently start handing out field loot the day
	# someone removed the inline call.
	chest.loot_table_id = loot_table_id
	add_child(chest)

	# After add_child so the chest is ready to receive it. The legacy single
	# bone becomes a one-item table and goes through the same roll path as
	# everything else.
	if loot_table_id == "":
		chest.use_single_bone_reward(reward_bone_id)

	if unlocked:
		chest.unlock()


func _build_campfire() -> void:
	var fire_root := Node3D.new()
	fire_root.name = "Campfire"
	add_child(fire_root)

	for i in range(3):
		var log_mesh := MeshInstance3D.new()
		var log_box := BoxMesh.new()
		log_box.size = Vector3(1.2, 0.18, 0.18)
		log_mesh.mesh = log_box
		log_mesh.position = Vector3(0.0, 0.12, 0.0)
		log_mesh.rotation.y = float(i) * TAU / 3.0
		log_mesh.material_override = _make_material(Color(0.30, 0.18, 0.09, 1.0))
		fire_root.add_child(log_mesh)

	flame_mesh = MeshInstance3D.new()
	var flame := SphereMesh.new()
	flame.radius = 0.34
	flame.height = 0.8
	flame_mesh.mesh = flame
	flame_mesh.position = Vector3(0.0, 0.62, 0.0)
	flame_mesh.material_override = _make_material(Color(1.0, 0.42, 0.08, 0.9), true)
	fire_root.add_child(flame_mesh)


func _build_label() -> void:
	label = Label3D.new()
	label.name = "CampLabel"
	label.position = Vector3(0.0, 2.2, 0.0)
	label.font_size = 34
	label.outline_size = 7
	label.outline_modulate = Color(0.03, 0.02, 0.01, 1.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


# The camp label reports the camp's own state only. Hold progress and the key
# prompt belong to the chest, which draws its own label -- duplicating them here
# is what used to force the camp to poll input every frame.
func _update_label() -> void:
	if label == null:
		return

	if opened:
		label.text = camp_name + "\nChest opened"
	elif not unlocked:
		label.text = camp_name + "\nClear enemies: " + str(_remaining_enemy_count())
	else:
		label.text = camp_name + "\nChest unlocked"


func _make_material(color: Color, glowing: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	if glowing:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.4
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
