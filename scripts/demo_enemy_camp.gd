class_name DemoEnemyCamp
extends Node3D

# A demo encounter pocket: enemies gather around a campfire, and the chest opens
# only after every registered camp enemy has been cleared.

@export var camp_name: String = "Enemy Camp"
@export var reward_bone_id: String = "dummy_bone"
@export var chest_open_hold_time: float = 0.65

var enemies: Array[Node] = []
var unlocked: bool = false
var opened: bool = false
var player_in_range: Node3D = null
var interact_reserved: bool = false
var hold_progress: float = 0.0

var label: Label3D = null
var chest_mesh: MeshInstance3D = null
var flame_mesh: MeshInstance3D = null
var chest_material: StandardMaterial3D = null
var flame_time: float = 0.0


func _ready() -> void:
	add_to_group("enemy_camps")
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	_build_visuals()
	_update_label()


func register_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	if not enemies.has(enemy):
		enemies.append(enemy)
		enemy.set("respawn_enabled", false)
	_update_state()
	_emit_camp_state_changed()
	_update_label()


func _process(delta: float) -> void:
	flame_time += delta
	if flame_mesh != null:
		var pulse := 1.0 + sin(flame_time * 8.0) * 0.12
		flame_mesh.scale = Vector3.ONE * pulse

	if opened or not unlocked or player_in_range == null:
		if hold_progress > 0.0:
			hold_progress = 0.0
			_update_label()
		return

	if Input.is_action_pressed(DropPickupRulesService.PICKUP_ACTION):
		hold_progress += delta
		_update_label()
		if hold_progress >= chest_open_hold_time:
			_open_chest()
	else:
		if hold_progress > 0.0:
			hold_progress = 0.0
			_update_label()


func _update_state() -> void:
	if opened:
		return

	var all_cleared := true
	for enemy in enemies:
		if enemy != null and is_instance_valid(enemy) and bool(enemy.get("alive")):
			all_cleared = false
			break

	if all_cleared != unlocked:
		unlocked = all_cleared
		_update_chest_visual()
		_emit_camp_state_changed()
		_update_label()


func _on_enemy_defeated(enemy: Node, _dropped_bone_id: String) -> void:
	if not enemies.has(enemy):
		return
	_update_state()
	_update_label()


func _emit_camp_state_changed() -> void:
	GameEvents.camp_state_changed.emit(self, unlocked, opened, _remaining_enemy_count())


func _open_chest() -> void:
	if opened or not unlocked:
		return

	opened = true
	hold_progress = 0.0
	_update_chest_visual()
	_emit_camp_state_changed()

	if player_in_range != null and reward_bone_id != "" and player_in_range.has_method("collect_bone"):
		player_in_range.call("collect_bone", reward_bone_id)

	GameEvents.camp_chest_opened.emit(self, reward_bone_id, player_in_range)
	_release_player_interact_lock()
	_update_label()


func _on_chest_body_entered(body: Node3D) -> void:
	if body.has_method("collect_bone"):
		player_in_range = body
		_reserve_player_interact_lock()
		hold_progress = 0.0
		_update_label()


func _on_chest_body_exited(body: Node3D) -> void:
	if body != player_in_range:
		return

	_release_player_interact_lock()
	player_in_range = null
	hold_progress = 0.0
	_update_label()


func _reserve_player_interact_lock() -> void:
	if interact_reserved or player_in_range == null:
		return
	if player_in_range.has_method("enter_interact_range"):
		player_in_range.call("enter_interact_range")
		interact_reserved = true


func _release_player_interact_lock() -> void:
	if not interact_reserved or player_in_range == null:
		return
	if player_in_range.has_method("exit_interact_range"):
		player_in_range.call("exit_interact_range")
	interact_reserved = false


func _build_visuals() -> void:
	_build_campfire()
	_build_chest()

	label = Label3D.new()
	label.name = "CampLabel"
	label.position = Vector3(0.0, 2.2, 0.0)
	label.font_size = 34
	label.outline_size = 7
	label.outline_modulate = Color(0.03, 0.02, 0.01, 1.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


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


func _build_chest() -> void:
	var chest_root := Node3D.new()
	chest_root.name = "RewardChest"
	chest_root.position = Vector3(1.8, 0.35, 0.0)
	add_child(chest_root)

	chest_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.1, 0.7, 0.8)
	chest_mesh.mesh = box
	chest_material = _make_material(Color(0.30, 0.18, 0.08, 1.0))
	chest_mesh.material_override = chest_material
	chest_root.add_child(chest_mesh)

	var lid := MeshInstance3D.new()
	var lid_box := BoxMesh.new()
	lid_box.size = Vector3(1.2, 0.18, 0.9)
	lid.mesh = lid_box
	lid.position = Vector3(0.0, 0.44, 0.0)
	lid.material_override = _make_material(Color(0.55, 0.38, 0.16, 1.0))
	chest_root.add_child(lid)

	var area := Area3D.new()
	area.name = "ChestOpenArea"
	area.collision_layer = 0
	area.collision_mask = 1
	chest_root.add_child(area)

	var shape_node := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.5
	shape_node.shape = sphere
	area.add_child(shape_node)

	area.body_entered.connect(Callable(self, "_on_chest_body_entered"))
	area.body_exited.connect(Callable(self, "_on_chest_body_exited"))


func _update_chest_visual() -> void:
	if chest_material == null:
		return

	if opened:
		chest_material.albedo_color = Color(0.16, 0.48, 0.20, 1.0)
		chest_mesh.rotation.x = -0.12
	elif unlocked:
		chest_material.albedo_color = Color(0.82, 0.62, 0.22, 1.0)
	else:
		chest_material.albedo_color = Color(0.30, 0.18, 0.08, 1.0)


func _update_label() -> void:
	if label == null:
		return

	if opened:
		label.text = camp_name + "\nChest opened"
	elif not unlocked:
		label.text = camp_name + "\nClear enemies: " + str(_remaining_enemy_count())
	elif player_in_range == null:
		label.text = camp_name + "\nChest unlocked"
	else:
		var percent := int((hold_progress / chest_open_hold_time) * 100.0)
		label.text = camp_name + "\nHold " + DropPickupRulesService.action_binding_text(DropPickupRulesService.PICKUP_ACTION) + " to open: " + str(percent) + "%"


func _remaining_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if enemy != null and is_instance_valid(enemy) and bool(enemy.get("alive")):
			count += 1
	return count


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
