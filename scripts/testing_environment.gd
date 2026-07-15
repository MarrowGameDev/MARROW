extends Node3D

const MAIN_MENU_PATH: String = "res://scenes/main_menu.tscn"
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")

@export var spawn_player_on_ready: bool = true
@export var spawn_initial_enemies: bool = true
@export var keep_enemy_respawn_disabled: bool = true
@export var dummy_only_mode: bool = false

var player: Node3D = null
var enemy_spawn_root: Node3D = null
var live_enemies: Array[Node] = []
var spawn_cursor: int = 0
var enemy_serial: int = 0
var status_label: Label = null
var validation_guide_index: int = 0


const P0_VALIDATION_GUIDES: Array[Dictionary] = [
	{
		"title": "Movement, camera, and jitter",
		"setup": "Use the walls, ramp, and open ground with the player in normal control.",
		"steps": [
			"Walk, sprint, stop, jump, and rotate the camera near tall and short walls.",
			"Open and close inventory, then repeat movement and camera rotation.",
			"Attack while moving and while idle, watching the body and camera follow.",
		],
		"expected": "No persistent camera/body jitter, no teleport, no stuck mouse capture, and control returns after inventory.",
	},
	{
		"title": "Inventory, equipment, and preview",
		"setup": "Open inventory with the seeded normal limbs and extra comparison bones.",
		"steps": [
			"Equip torso, arms, and legs, then deselect or unequip one piece at a time.",
			"Confirm duplicate bones remain counted and equipped copies are hidden from carried tiles.",
			"Watch the preview viewport while equipping and reopening inventory.",
		],
		"expected": "The preview stays isolated, reflects equipped parts, and does not duplicate nodes after reopen.",
	},
	{
		"title": "Pickups, drops, and enemy profiles",
		"setup": "Spawn normal, gorilla, lizard, ranged, and dummy enemies with number keys.",
		"steps": [
			"Defeat or damage each profile enough to observe drops or limb reactions.",
			"Collect available drops and confirm inventory updates without reopening.",
			"Remove latest enemy with Backspace and respawn to confirm scene recovery.",
		],
		"expected": "Drops stay slot-aware, pickups do not duplicate unexpectedly, and removed enemies do not leave stale UI state.",
	},
	{
		"title": "Backstab runtime geometry",
		"setup": "Use a dummy or normal enemy and approach from front, sides, and behind.",
		"steps": [
			"Try stealth finish from the front and both lateral angles.",
			"Rotate or respawn enemies at different markers and repeat behind checks.",
			"Confirm regular attack still works when stealth finish is unavailable.",
		],
		"expected": "Front and side attempts fail, behind succeeds, and no duplicate damage or stuck enemy state appears.",
	},
	{
		"title": "Rig and body progression",
		"setup": "Use seeded body parts and the RigPosePlatform area.",
		"steps": [
			"Observe head-only, torso, arms, and legs progression while equipping pieces.",
			"Move, jump, crawl if available, and attack after each equipment stage.",
			"Compare the world rig with the inventory preview state.",
		],
		"expected": "Sockets match equipped state, left/right parts are not swapped, and animation remains stable.",
	},
]


func _ready() -> void:
	if dummy_only_mode:
		name = "DummyTestingEnvironment"
	else:
		name = "TestingEnvironment"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	_build_world()
	_find_or_create_spawn_root()
	if spawn_player_on_ready:
		_spawn_player()
	if spawn_initial_enemies:
		_spawn_initial_enemy_set()
	_build_ui()
	_update_status()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().change_scene_to_file(MAIN_MENU_PATH)
			KEY_1:
				if not dummy_only_mode:
					_spawn_enemy_at_next_marker("normal")
			KEY_2:
				if dummy_only_mode:
					_try_spawn_dummy()
				else:
					_spawn_enemy_at_next_marker("gorilla")
			KEY_3:
				if not dummy_only_mode:
					_spawn_enemy_at_next_marker("lizard")
			KEY_4:
				if not dummy_only_mode:
					_spawn_enemy_at_next_marker("ranged")
			KEY_5:
				if dummy_only_mode:
					_try_spawn_dummy()
				else:
					_spawn_enemy_at_next_marker("dummy")
			KEY_BACKSPACE:
				_remove_latest_enemy()
			KEY_R:
				get_tree().reload_current_scene()
			KEY_F1:
				_cycle_validation_guide(1)
			KEY_F2:
				_cycle_validation_guide(-1)


func _build_world() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.55, 0.62, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 1.0, 1.0, 1.0)
	env.ambient_light_energy = 0.65
	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.name = "TestingSun"
	sun.rotation = Vector3(-0.9, 0.55, 0.0)
	sun.light_energy = 2.2
	sun.shadow_enabled = true
	add_child(sun)

	_make_box("Ground", Vector3(0.0, -0.1, 0.0), Vector3(52.0, 0.2, 52.0), Color(0.30, 0.40, 0.34, 1.0))
	_make_box("CameraWallTall", Vector3(-8.0, 2.0, -5.0), Vector3(1.2, 4.0, 8.0), Color(0.38, 0.34, 0.31, 1.0))
	_make_box("CameraWallShort", Vector3(7.5, 1.0, 4.0), Vector3(1.0, 2.0, 9.0), Color(0.38, 0.34, 0.31, 1.0))
	_make_box("EnemyCoverBlockA", Vector3(-3.0, 0.65, 8.0), Vector3(4.0, 1.3, 1.2), Color(0.42, 0.39, 0.33, 1.0))
	_make_box("EnemyCoverBlockB", Vector3(4.5, 0.65, -8.0), Vector3(4.5, 1.3, 1.2), Color(0.42, 0.39, 0.33, 1.0))
	_make_box("Ramp", Vector3(0.0, 0.48, -13.0), Vector3(5.5, 0.35, 7.0), Color(0.46, 0.40, 0.32, 1.0), Vector3(0.24, 0.0, 0.0))
	_make_box("RigPosePlatform", Vector3(12.0, 0.08, -11.0), Vector3(7.0, 0.16, 7.0), Color(0.24, 0.42, 0.48, 1.0))


func _make_box(box_name: String, pos: Vector3, size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = box_name
	body.position = pos
	body.rotation = rot
	add_child(body)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = box_name + "Mesh"
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _make_material(color)
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	collision.name = box_name + "Collision"
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material


func _find_or_create_spawn_root() -> void:
	enemy_spawn_root = get_node_or_null("EnemySpawnPoints") as Node3D
	if enemy_spawn_root == null:
		enemy_spawn_root = Node3D.new()
		enemy_spawn_root.name = "EnemySpawnPoints"
		add_child(enemy_spawn_root)

	if enemy_spawn_root.get_child_count() > 0:
		return

	if dummy_only_mode:
		_add_spawn_marker("DummySpawn", Vector3(0.0, 0.6, -2.0), "dummy")
		return

	_add_spawn_marker("NormalSpawn", Vector3(-7.0, 0.6, 9.0), "normal")
	_add_spawn_marker("GorillaSpawn", Vector3(7.0, 0.6, 9.0), "gorilla")
	_add_spawn_marker("LizardSpawn", Vector3(-7.0, 0.6, -9.0), "lizard")
	_add_spawn_marker("RangedSpawn", Vector3(7.0, 0.6, -9.0), "ranged")
	_add_spawn_marker("DummySpawn", Vector3(0.0, 0.6, -2.0), "dummy")


func _add_spawn_marker(marker_name: String, pos: Vector3, profile: String) -> void:
	var marker := Marker3D.new()
	marker.name = marker_name
	marker.position = pos
	marker.set_meta("enemy_profile", profile)
	enemy_spawn_root.add_child(marker)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as Node3D
	if player == null:
		return
	player.name = "TestingPlayer"
	player.position = Vector3(0.0, 1.05, 4.0)
	add_child(player)
	_seed_testing_inventory()


# Every NORMAL limb, one per slot, so a whole body can be assembled from the
# inventory and the animation driven at every stage: head-only -> torso -> arms
# -> legs. Ids follow EquipmentRulesService's generated-limb format
# (<source_profile>_<limb_key>_bone), which is what enemies actually drop.
const NORMAL_LIMB_BONES: Array[String] = [
	"normal_head_bone",
	"normal_body_bone",
	"normal_right_arm_bone",
	"normal_left_arm_bone",
	"normal_right_leg_bone",
	"normal_left_leg_bone",
]

# Hand-authored + enemy-profile pieces, kept for comparison against the normals.
const EXTRA_TESTING_BONES: Array[String] = [
	"arm_bone", "leg_bone", "heavy_bone", "rib_bone",
	"gorilla_right_arm_bone", "lizard_body_bone",
]


func _seed_testing_inventory() -> void:
	if player == null or not player.has_method("collect_bone"):
		return

	for bone_id in NORMAL_LIMB_BONES:
		player.call("collect_bone", bone_id)
	for bone_id in EXTRA_TESTING_BONES:
		player.call("collect_bone", bone_id)


func _spawn_initial_enemy_set() -> void:
	for marker in _spawn_markers():
		var profile: String = str(marker.get_meta("enemy_profile", "normal"))
		_spawn_enemy(profile, marker.global_position)


func _spawn_enemy_at_next_marker(profile: String) -> void:
	var markers: Array[Marker3D] = _spawn_markers()
	var spawn_position := Vector3(randf_range(-8.0, 8.0), 0.6, randf_range(-10.0, 10.0))
	if not markers.is_empty():
		var marker := markers[spawn_cursor % markers.size()]
		spawn_cursor += 1
		spawn_position = marker.global_position
	_spawn_enemy(profile, spawn_position)


func _spawn_markers() -> Array[Marker3D]:
	var markers: Array[Marker3D] = []
	if enemy_spawn_root == null:
		return markers
	for child in enemy_spawn_root.get_children():
		var marker := child as Marker3D
		if marker != null:
			markers.append(marker)
	return markers


func _spawn_enemy(profile: String, pos: Vector3) -> void:
	var enemy := ENEMY_SCENE.instantiate()
	if enemy == null:
		return

	enemy_serial += 1
	enemy.name = profile.capitalize() + "TestEnemy" + str(enemy_serial)
	enemy.set("respawn_enabled", not keep_enemy_respawn_disabled)
	enemy.set("idle_wander_enabled", true)
	enemy.set("detection_range", 16.0)
	enemy.set("vision_angle_degrees", 130.0)
	enemy.set("dropped_bone_id", _bone_for_profile(profile))
	_apply_profile(enemy, profile)

	var enemy_body := enemy as Node3D
	if enemy_body != null:
		enemy_body.position = pos
	add_child(enemy)
	live_enemies.append(enemy)
	_update_status()


func _apply_profile(enemy: Node, profile: String) -> void:
	match profile:
		"gorilla":
			enemy.set("gorilla_profile_mode", "Always")
			enemy.set("max_health", 8)
			enemy.set("contact_damage", 2)
			enemy.set("move_speed", 2.4)
		"lizard":
			enemy.set("lizard_profile_mode", "Always")
			enemy.set("max_health", 4)
			enemy.set("move_speed", 3.4)
		"ranged":
			enemy.set("ranged_attacker_enabled", true)
			enemy.set("max_health", 3)
			enemy.set("move_speed", 2.2)
			enemy.set("ranged_attack_range", 18.0)
		"dummy":
			enemy.set("dummy_target_enabled", true)
			enemy.set("max_health", 12)
			enemy.set("move_speed", 0.0)
			enemy.set("contact_damage", 0)
			enemy.set("detection_range", 0.0)
		_:
			enemy.set("max_health", 3)
			enemy.set("move_speed", 2.8)


func _bone_for_profile(profile: String) -> String:
	match profile:
		"gorilla":
			return "heavy_bone"
		"lizard":
			return "rib_bone"
		"ranged":
			return "arm_bone"
		"dummy":
			return "dummy_bone"
		_:
			return "dummy_bone"


# The dummy room is meant to hold exactly one target, so a respawn while the
# current dummy is still alive is refused instead of stacking a second one on the
# same marker. Once it is killed or removed with Backspace, respawning works again.
func _try_spawn_dummy() -> void:
	if _has_live_dummy():
		_update_status()
		return
	_spawn_enemy_at_next_marker("dummy")


func _has_live_dummy() -> bool:
	for enemy in live_enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if not bool(enemy.get("alive")):
			continue
		if bool(enemy.get("dummy_target_enabled")):
			return true
	return false


func _remove_latest_enemy() -> void:
	while not live_enemies.is_empty():
		var enemy := live_enemies.pop_back() as Node
		if enemy != null and is_instance_valid(enemy):
			enemy.queue_free()
			break
	_update_status()


func _on_enemy_defeated(_enemy: Node, _dropped_bone_id: String) -> void:
	_update_status()


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "TestingEnvironmentUI"
	canvas.layer = 20
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "TestingPanel"
	panel.position = Vector2(20.0, 20.0)
	panel.custom_minimum_size = Vector2(460.0, 0.0)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	status_label = Label.new()
	status_label.name = "TestingStatusLabel"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(status_label)


func _update_status() -> void:
	if status_label == null:
		return

	var alive_count: int = 0
	for enemy in live_enemies:
		if enemy != null and is_instance_valid(enemy) and bool(enemy.get("alive")):
			alive_count += 1

	if dummy_only_mode:
		status_label.text = "DUMMY TESTING ENVIRONMENT\n"
		status_label.text += "Passive target room for animation, damage, limb, and hitbox checks.\n\n"
	else:
		status_label.text = "TESTING ENVIRONMENT\n"
		status_label.text += "Camera, movement, enemy AI, animations, drops, and rig sandbox.\n\n"
	status_label.text += "Enemies active: " + str(alive_count) + "\n"
	if dummy_only_mode:
		if _has_live_dummy():
			status_label.text += "2 or 5: respawn dummy (blocked, dummy already up)\n"
		else:
			status_label.text += "2 or 5: respawn dummy target\n"
	else:
		status_label.text += "1 Normal   2 Gorilla   3 Lizard   4 Ranged   5 Dummy\n"
	status_label.text += "F1/F2: cycle P0 validation guide\n"
	status_label.text += "Backspace: remove latest enemy   R: reset scene   Esc: menu\n"
	status_label.text += "Edit EnemySpawnPoints in this scene to add/remove default enemy positions."
	status_label.text += "\n\n" + _current_validation_guide_text()


func _cycle_validation_guide(direction: int) -> void:
	if P0_VALIDATION_GUIDES.is_empty():
		return
	validation_guide_index = posmod(validation_guide_index + direction, P0_VALIDATION_GUIDES.size())
	_update_status()


func _current_validation_guide_text() -> String:
	if P0_VALIDATION_GUIDES.is_empty():
		return "P0 validation guide: no sections configured."

	var guide: Dictionary = P0_VALIDATION_GUIDES[validation_guide_index]
	var text := "P0 CHECK " + str(validation_guide_index + 1) + "/" + str(P0_VALIDATION_GUIDES.size()) + ": "
	text += str(guide.get("title", "Unnamed")) + "\n"
	text += "Setup: " + str(guide.get("setup", "n/a")) + "\n"
	text += "Steps:\n"
	var steps: Array = guide.get("steps", [])
	for i in range(steps.size()):
		text += "  " + str(i + 1) + ". " + str(steps[i]) + "\n"
	text += "Expected: " + str(guide.get("expected", "n/a")) + "\n"
	text += "Record: scene, resolution, enabled systems, observed result, and console errors."
	return text
