extends Node3D

# Builds the grey-box demo island inspired by the reference: a safe village edge,
# river split, bridges, fields, ruins, and a mountain-backed path.
# It is intentionally code-built so the demo layout can be reshaped quickly.

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")
const BONE_PICKUP_SCENE: PackedScene = preload("res://scenes/bone.tscn")
const CAMP_SCRIPT: Script = preload("res://scripts/demo_enemy_camp.gd")

@export var enabled: bool = true
@export var spawn_extra_enemy_packs: bool = true

var material_cache: Dictionary = {}


func _ready() -> void:
	if not enabled:
		return

	call_deferred("_build_demo_island")


func _build_demo_island() -> void:
	_resize_base_ground()
	_place_player_start()
	_spawn_starter_torso_pickup()
	_layout_stage_regions()
	_layout_story_nodes()
	_build_island_visuals()
	if spawn_extra_enemy_packs:
		_spawn_tutorial_enemy_packs()


func _resize_base_ground() -> void:
	var ground_mesh := get_node_or_null("../Ground/MeshInstance3D") as MeshInstance3D
	var ground_collision := get_node_or_null("../Ground/CollisionShape3D") as CollisionShape3D
	if ground_mesh != null and ground_mesh.mesh is BoxMesh:
		(ground_mesh.mesh as BoxMesh).size = Vector3(132.0, 0.15, 108.0)
	if ground_collision != null and ground_collision.shape is BoxShape3D:
		(ground_collision.shape as BoxShape3D).size = Vector3(132.0, 0.15, 108.0)


func _place_player_start() -> void:
	var player := get_node_or_null("../Player") as Node3D
	if player != null:
		player.position = Vector3(0.0, 1.05, 38.0)

	var wisp := get_node_or_null("../GuideWisp") as Node3D
	if wisp != null:
		wisp.position = Vector3(-2.0, 2.0, 40.0)


func _spawn_starter_torso_pickup() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null or scene_root.get_node_or_null("StarterTorsoPickup") != null:
		return

	var pickup: Node = BONE_PICKUP_SCENE.instantiate()
	pickup.name = "StarterTorsoPickup"
	if pickup.has_method("set_bone_id"):
		pickup.call("set_bone_id", "torso_bone")
	var pickup_body: Node3D = pickup as Node3D
	if pickup_body != null:
		pickup_body.position = Vector3(0.0, 0.45, 34.5)
	scene_root.add_child(pickup)


func _layout_stage_regions() -> void:
	_configure_stage("BonefieldHub", Vector3(-24.0, 0.0, 27.0), Vector3(22.0, 4.0, 18.0), "Cliffside Village", 1, "None", "Safe demo village. Learn movement, inventory, and the river route.", Color(0.34, 0.62, 0.38, 1.0))
	_configure_stage("FirstHuntField", Vector3(2.0, 0.0, 18.0), Vector3(26.0, 4.0, 18.0), "First Hunt Field", 2, "Any", "Low-risk field enemies. Learn vision, stealth finish, and limb drops.", Color(0.78, 0.58, 0.25, 1.0))
	_configure_stage("ReachRidge", Vector3(-34.0, 0.0, -8.0), Vector3(24.0, 4.0, 18.0), "Reach Ridge", 3, "Arm Bone", "Cliff-side enemies reward longer attack reach.", Color(1.0, 0.82, 0.18, 1.0))
	_configure_stage("QuickrootRun", Vector3(31.0, 0.0, 9.0), Vector3(28.0, 4.0, 20.0), "Quickroot Run", 4, "Leg Bone", "Open paths and fleeing enemies. Speed matters here.", Color(0.25, 0.95, 0.55, 1.0))
	_configure_stage("HeavyRuin", Vector3(10.0, 0.0, -25.0), Vector3(28.0, 4.0, 22.0), "Heavy Ruin", 5, "Heavy Bone", "Ruined arena with heavier enemies and pack alerts.", Color(0.65, 0.35, 1.0, 1.0))
	_configure_stage("RibfenBonus", Vector3(-30.0, 0.0, 6.0), Vector3(20.0, 4.0, 16.0), "Ribfen Bonus", 4, "Hybrid", "Optional river-side pocket for the Rib Bone.", Color(0.35, 0.85, 0.95, 1.0))
	_configure_stage("ElderMarrowGate", Vector3(33.0, 0.0, -40.0), Vector3(30.0, 4.0, 18.0), "Elder Marrow Gate", 7, "All bones", "Mountain gate preview. This marks where later tiers open up.", Color(0.85, 0.22, 0.22, 1.0))


func _configure_stage(node_name: String, pos: Vector3, trigger_size: Vector3, stage_name: String, difficulty: int, recommended: String, description: String, color: Color) -> void:
	var stage := get_node_or_null("../OpenWorldStages/" + node_name) as Node3D
	if stage == null:
		return

	stage.position = pos
	stage.set("stage_name", stage_name)
	stage.set("difficulty", difficulty)
	stage.set("recommended_bone", recommended)
	stage.set("description", description)
	stage.set("stage_color", color)
	stage.set("trigger_size", trigger_size)

	var stage_mesh := stage.get_node_or_null("StageBody/StageMesh") as MeshInstance3D
	if stage_mesh != null:
		var mesh := BoxMesh.new()
		mesh.size = Vector3(trigger_size.x, 0.18, trigger_size.z)
		stage_mesh.mesh = mesh
		stage_mesh.material_override = _get_material(color)

	var stage_label := stage.get_node_or_null("StageLabel") as Label3D
	if stage_label != null:
		stage_label.text = stage_name + "\nDifficulty " + str(difficulty)
		stage_label.modulate = color

	if stage.has_method("refresh_runtime_mesh"):
		stage.call_deferred("refresh_runtime_mesh")


func _layout_story_nodes() -> void:
	_move_node("../EnemyCenter", Vector3(4.0, 0.6, 15.0))
	_move_node("../EnemyLeft", Vector3(28.0, 0.6, 9.0))
	_move_node("../EnemyRight", Vector3(11.0, 0.6, -24.0))
	_move_node("../EnemyBonus", Vector3(-29.0, 0.6, 5.0))

	_move_node("../ArmTrialGate", Vector3(-36.0, 0.2, -2.0))
	_move_node("../LegTrialGate", Vector3(38.0, 0.2, 15.0))
	_move_node("../HeavyTrialGate", Vector3(14.0, 0.2, -35.0))
	_move_node("../ExitPortal", Vector3(34.0, 0.2, -48.0))

	var sight_walls := get_node_or_null("../SightTestWalls") as Node3D
	if sight_walls != null:
		sight_walls.position = Vector3(0.0, 0.0, 20.0)


func _move_node(path: String, pos: Vector3) -> void:
	var node := get_node_or_null(path) as Node3D
	if node != null:
		node.position = pos


func _build_island_visuals() -> void:
	var old := get_node_or_null("GeneratedTutorialIsland")
	if old != null:
		old.queue_free()

	var root := Node3D.new()
	root.name = "GeneratedTutorialIsland"
	add_child(root)

	_build_ocean_and_river(root)
	_build_paths(root)
	_build_landmarks(root)
	_build_mountain_wall(root)
	_build_tree_belts(root)
	_build_enemy_camps(root)


func _build_ocean_and_river(root: Node3D) -> void:
	_make_box(root, "OceanNorth", Vector3(0.0, -0.18, -66.0), Vector3(170.0, 0.04, 26.0), Color(0.05, 0.22, 0.34, 1.0), false)
	_make_box(root, "OceanSouth", Vector3(0.0, -0.18, 66.0), Vector3(170.0, 0.04, 26.0), Color(0.05, 0.22, 0.34, 1.0), false)
	_make_box(root, "OceanWest", Vector3(-78.0, -0.18, 0.0), Vector3(24.0, 0.04, 118.0), Color(0.05, 0.22, 0.34, 1.0), false)
	_make_box(root, "OceanEast", Vector3(78.0, -0.18, 0.0), Vector3(24.0, 0.04, 118.0), Color(0.05, 0.22, 0.34, 1.0), false)

	_make_box(root, "RiverNorth", Vector3(-7.0, 0.02, -29.0), Vector3(9.0, 0.04, 34.0), Color(0.04, 0.42, 0.62, 1.0), false, 0.22)
	_make_box(root, "CentralLake", Vector3(-8.0, 0.025, -3.0), Vector3(24.0, 0.04, 16.0), Color(0.04, 0.42, 0.62, 1.0), false, -0.1)
	_make_box(root, "RiverSouthEast", Vector3(17.0, 0.02, 22.0), Vector3(9.0, 0.04, 42.0), Color(0.04, 0.42, 0.62, 1.0), false, -0.65)
	_make_box(root, "RiverWestFall", Vector3(-30.0, 0.02, 3.0), Vector3(8.0, 0.04, 24.0), Color(0.04, 0.42, 0.62, 1.0), false, 0.85)

	_make_box(root, "VillageBridge", Vector3(-20.0, 0.12, 8.0), Vector3(13.0, 0.18, 2.4), Color(0.43, 0.30, 0.16, 1.0), true, 0.45)
	_make_box(root, "FieldBridge", Vector3(8.0, 0.12, 11.0), Vector3(13.0, 0.18, 2.4), Color(0.43, 0.30, 0.16, 1.0), true, -0.45)
	_make_box(root, "NorthBridge", Vector3(-4.0, 0.12, -18.0), Vector3(12.0, 0.18, 2.2), Color(0.43, 0.30, 0.16, 1.0), true, 1.55)


func _build_paths(root: Node3D) -> void:
	var path_color := Color(0.62, 0.53, 0.38, 1.0)
	_make_box(root, "StartPath", Vector3(0.0, 0.03, 30.0), Vector3(6.0, 0.05, 24.0), path_color, false, 0.05)
	_make_box(root, "VillagePath", Vector3(-17.0, 0.03, 22.0), Vector3(6.0, 0.05, 30.0), path_color, false, 1.05)
	_make_box(root, "FieldPath", Vector3(6.0, 0.03, 13.0), Vector3(5.0, 0.05, 22.0), path_color, false, -0.6)
	_make_box(root, "QuickrootPath", Vector3(26.0, 0.03, 15.0), Vector3(5.0, 0.05, 32.0), path_color, false, -0.2)
	_make_box(root, "RidgePath", Vector3(-30.0, 0.03, -5.0), Vector3(5.0, 0.05, 28.0), path_color, false, -0.45)
	_make_box(root, "RuinPath", Vector3(6.0, 0.03, -22.0), Vector3(6.0, 0.05, 38.0), path_color, false, 0.25)


func _build_landmarks(root: Node3D) -> void:
	# Cliffside village / tutorial hub.
	_make_box(root, "VillageCliff", Vector3(-27.0, 0.45, 28.0), Vector3(24.0, 1.0, 16.0), Color(0.38, 0.36, 0.32, 1.0), true)
	_make_box(root, "VillageKeep", Vector3(-29.0, 1.35, 27.0), Vector3(7.0, 2.7, 6.0), Color(0.70, 0.65, 0.56, 1.0), true)
	_make_box(root, "VillageRoof", Vector3(-29.0, 3.0, 27.0), Vector3(8.0, 0.45, 7.0), Color(0.86, 0.56, 0.20, 1.0), false)
	_make_box(root, "VillageTower", Vector3(-39.0, 1.7, 25.0), Vector3(3.0, 3.4, 3.0), Color(0.72, 0.68, 0.58, 1.0), true)

	# First field / training meadow.
	_make_box(root, "TrainingRing", Vector3(2.0, 0.08, 18.0), Vector3(12.0, 0.12, 10.0), Color(0.52, 0.45, 0.30, 1.0), false, 0.3)
	_make_box(root, "TrainingCoverA", Vector3(-5.0, 0.9, 18.0), Vector3(5.0, 1.8, 0.7), Color(0.42, 0.45, 0.50, 1.0), true, 0.4)
	_make_box(root, "TrainingCoverB", Vector3(8.0, 0.9, 21.0), Vector3(4.5, 1.8, 0.7), Color(0.42, 0.45, 0.50, 1.0), true, -0.65)

	# Ruin arena.
	_make_box(root, "RuinArenaFloor", Vector3(9.0, 0.05, -25.0), Vector3(22.0, 0.12, 16.0), Color(0.45, 0.38, 0.30, 1.0), false)
	_make_box(root, "RuinWallNorth", Vector3(9.0, 1.0, -33.0), Vector3(20.0, 2.0, 1.2), Color(0.36, 0.33, 0.34, 1.0), true)
	_make_box(root, "RuinWallWest", Vector3(-2.0, 1.0, -25.0), Vector3(1.2, 2.0, 14.0), Color(0.36, 0.33, 0.34, 1.0), true)
	_make_box(root, "RuinPillarA", Vector3(3.5, 1.5, -22.0), Vector3(1.2, 3.0, 1.2), Color(0.60, 0.56, 0.50, 1.0), true)
	_make_box(root, "RuinPillarB", Vector3(15.0, 1.1, -28.0), Vector3(1.2, 2.2, 1.2), Color(0.60, 0.56, 0.50, 1.0), true)

	# Far mountain gate preview.
	_make_box(root, "ElderGateLeft", Vector3(24.0, 2.0, -48.0), Vector3(4.0, 4.0, 10.0), Color(0.22, 0.20, 0.24, 1.0), true)
	_make_box(root, "ElderGateRight", Vector3(43.0, 2.0, -48.0), Vector3(4.0, 4.0, 10.0), Color(0.22, 0.20, 0.24, 1.0), true)


func _build_mountain_wall(root: Node3D) -> void:
	var mountain_color := Color(0.18, 0.18, 0.22, 1.0)
	for i in range(9):
		var x := -38.0 + float(i) * 10.0
		var height := 5.0 + float(i % 3) * 2.0
		_make_box(root, "NorthSpire" + str(i), Vector3(x, height * 0.5, -52.0 + randf_range(-2.0, 2.0)), Vector3(5.0, height, 7.0), mountain_color, true, randf_range(-0.5, 0.5))
	for i in range(5):
		_make_box(root, "EastCliff" + str(i), Vector3(58.0, 2.0 + float(i), -30.0 + float(i) * 16.0), Vector3(5.0, 4.0 + float(i), 14.0), mountain_color, true, randf_range(-0.35, 0.35))


func _build_tree_belts(root: Node3D) -> void:
	for i in range(28):
		var x := randf_range(-58.0, -42.0)
		var z := randf_range(-5.0, 42.0)
		_make_tree(root, "WestTree" + str(i), Vector3(x, 0.0, z))
	for i in range(24):
		var x := randf_range(30.0, 54.0)
		var z := randf_range(-4.0, 38.0)
		_make_tree(root, "EastFieldTree" + str(i), Vector3(x, 0.0, z))
	for i in range(18):
		var x := randf_range(-16.0, 18.0)
		var z := randf_range(34.0, 48.0)
		_make_tree(root, "StartTree" + str(i), Vector3(x, 0.0, z))


func _spawn_tutorial_enemy_packs() -> void:
	_spawn_enemy("TutorialDummyEnemy", Vector3(2.0, 0.6, 24.0), "dummy_bone", {"max_health": 2, "move_speed": 2.0, "detection_range": 7.0})
	_spawn_enemy("FirstFieldArmLookout", Vector3(-4.0, 0.6, 9.0), "arm_bone", {"vision_angle_degrees": 115.0, "detection_range": 12.0})
	_spawn_enemy("ReachRidgeReachEnemy", Vector3(-36.0, 0.6, -10.0), "arm_bone", {"attack_range": 2.4, "detection_range": 13.0})
	_spawn_enemy("ReachRidgeArcher", Vector3(-28.0, 0.6, -15.0), "arm_bone", {"ranged_attacker_enabled": true, "detection_range": 14.0, "vision_angle_degrees": 125.0})
	_spawn_enemy("RibfenHybrid", Vector3(-35.0, 0.6, 7.0), "rib_bone", {"detection_range": 10.0})
	_spawn_enemy("WallPhasingLizard", Vector3(7.5, 0.6, 18.0), "rib_bone", {"lizard_profile_mode": "Always", "detection_range": 13.0, "vision_angle_degrees": 135.0})


func _build_enemy_camps(root: Node3D) -> void:
	var camps_root := Node3D.new()
	camps_root.name = "EnemyCamps"
	root.add_child(camps_root)

	_create_enemy_camp(
		camps_root,
		"Quickroot Runner Camp",
		Vector3(35.0, 0.0, 11.0),
		"leg_bone",
		[
			{"name": "QuickrootCampRunnerA", "offset": Vector3(-2.8, 0.6, -2.0), "bone": "leg_bone", "overrides": {"low_health_flee_chance": 1.0}},
			{"name": "QuickrootCampRunnerB", "offset": Vector3(2.6, 0.6, 1.8), "bone": "leg_bone", "overrides": {"low_health_flee_chance": 1.0, "move_speed": 3.4}},
		]
	)

	_create_enemy_camp(
		camps_root,
		"Heavy Ruin Camp",
		Vector3(10.0, 0.0, -26.0),
		"heavy_bone",
		[
			{"name": "HeavyCampGuardA", "offset": Vector3(-4.0, 0.6, -1.5), "bone": "heavy_bone", "overrides": {"ally_alert_range": 11.0}},
			{"name": "HeavyCampGuardB", "offset": Vector3(4.2, 0.6, 2.0), "bone": "heavy_bone", "overrides": {"ally_alert_range": 11.0}},
			{"name": "HeavyCampRunner", "offset": Vector3(0.0, 0.6, 4.3), "bone": "leg_bone", "overrides": {"low_health_flee_chance": 1.0}},
		]
	)

	_create_enemy_camp(
		camps_root,
		"Reach Ridge Camp",
		Vector3(-37.0, 0.0, -9.5),
		"arm_bone",
		[
			{"name": "ReachCampLookout", "offset": Vector3(-2.5, 0.6, -2.0), "bone": "arm_bone", "overrides": {"vision_angle_degrees": 125.0, "detection_range": 13.0}},
			{"name": "ReachCampGuard", "offset": Vector3(2.8, 0.6, 1.7), "bone": "arm_bone", "overrides": {"attack_range": 2.5}},
			{"name": "ReachCampArcher", "offset": Vector3(0.2, 0.6, 4.0), "bone": "arm_bone", "overrides": {"ranged_attacker_enabled": true, "detection_range": 14.0, "vision_angle_degrees": 130.0}},
		]
	)

	_create_enemy_camp(
		camps_root,
		"Lizard Sink Camp",
		Vector3(19.0, 0.0, 24.0),
		"rib_bone",
		[
			{"name": "LizardSinkSpitter", "offset": Vector3(-1.8, 0.6, -1.2), "bone": "rib_bone", "overrides": {"lizard_profile_mode": "Always", "respawn_enabled": false}},
			{"name": "LizardSinkGuard", "offset": Vector3(2.2, 0.6, 1.5), "bone": "leg_bone", "overrides": {"move_speed": 3.2, "low_health_flee_chance": 0.7}},
		]
	)


func _create_enemy_camp(parent: Node3D, camp_name: String, pos: Vector3, reward_bone_id: String, enemy_defs: Array) -> void:
	var camp := Node3D.new()
	camp.name = camp_name.replace(" ", "")
	camp.position = pos
	camp.set_script(CAMP_SCRIPT)
	camp.set("camp_name", camp_name)
	camp.set("reward_bone_id", reward_bone_id)
	parent.add_child(camp)

	_make_camp_ring(parent, camp_name + "Ground", pos)

	for enemy_def in enemy_defs:
		if not (enemy_def is Dictionary):
			continue
		var enemy_name: String = str(enemy_def.get("name", "CampEnemy"))
		var offset: Vector3 = _dict_vector3(enemy_def, "offset", Vector3.ZERO)
		var bone_id: String = str(enemy_def.get("bone", reward_bone_id))
		var overrides: Dictionary = _dict_dictionary(enemy_def, "overrides")
		overrides["respawn_enabled"] = false
		var enemy := _spawn_enemy(enemy_name, pos + offset, bone_id, overrides)
		if enemy != null and camp.has_method("register_enemy"):
			camp.call("register_enemy", enemy)


func _make_camp_ring(parent: Node3D, ring_name: String, pos: Vector3) -> void:
	_make_box(parent, ring_name, pos + Vector3(0.0, 0.04, 0.0), Vector3(9.0, 0.08, 7.0), Color(0.34, 0.28, 0.19, 1.0), false)


func _dict_vector3(data: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value = data.get(key, fallback)
	if value is Vector3:
		return value
	return fallback


func _dict_dictionary(data: Dictionary, key: String) -> Dictionary:
	var value = data.get(key, {})
	if value is Dictionary:
		return (value as Dictionary).duplicate()
	return {}


func _spawn_enemy(enemy_name: String, pos: Vector3, bone_id: String, overrides: Dictionary) -> Node:
	var scene_root := get_tree().current_scene
	if scene_root == null or scene_root.get_node_or_null(enemy_name) != null:
		return null

	var enemy := ENEMY_SCENE.instantiate()
	enemy.name = enemy_name
	enemy.set("dropped_bone_id", bone_id)
	for key in overrides:
		enemy.set(key, overrides[key])
	var enemy_body := enemy as Node3D
	if enemy_body != null:
		enemy_body.position = pos
	scene_root.add_child(enemy)
	return enemy


func _make_box(parent: Node, box_name: String, pos: Vector3, size: Vector3, color: Color, collision: bool, yaw: float = 0.0) -> Node3D:
	var host: Node3D
	if collision:
		var body := StaticBody3D.new()
		host = body
	else:
		host = Node3D.new()
	host.name = box_name
	host.position = pos
	host.rotation.y = yaw
	parent.add_child(host)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _get_material(color)
	host.add_child(mesh_instance)

	if collision:
		var collision_shape := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision_shape.shape = shape
		host.add_child(collision_shape)

	return host


func _make_tree(parent: Node, tree_name: String, pos: Vector3) -> void:
	var tree := Node3D.new()
	tree.name = tree_name
	tree.position = pos
	parent.add_child(tree)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := BoxMesh.new()
	trunk_mesh.size = Vector3(0.35, 1.2, 0.35)
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0.0, 0.6, 0.0)
	trunk.material_override = _get_material(Color(0.28, 0.18, 0.10, 1.0))
	tree.add_child(trunk)

	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = randf_range(0.75, 1.15)
	crown_mesh.height = crown_mesh.radius * 1.7
	crown.mesh = crown_mesh
	crown.position = Vector3(0.0, 1.55, 0.0)
	crown.material_override = _get_material(Color(0.12, randf_range(0.34, 0.48), 0.16, 1.0))
	tree.add_child(crown)


func _get_material(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if material_cache.has(key):
		return material_cache[key]

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	material_cache[key] = material
	return material
