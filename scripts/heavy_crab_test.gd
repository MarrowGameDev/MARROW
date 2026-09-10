extends Node3D

# Preview scene for the heavy crab enemy: a lit ground and the crab, which wanders
# around on its own (no player present, so it never enters chase). Just run and watch.

func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.5, 0.55, 0.62)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.8, 0.8)
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new(); we.environment = env; add_child(we)

	var l := DirectionalLight3D.new()
	l.rotation_degrees = Vector3(-50, -30, 0)
	l.light_energy = 2.0; l.shadow_enabled = true; add_child(l)

	# ground
	var gb := StaticBody3D.new(); add_child(gb)
	var gm := MeshInstance3D.new(); var pm := PlaneMesh.new(); pm.size = Vector2(40, 40); gm.mesh = pm
	var mat := StandardMaterial3D.new(); mat.albedo_color = Color(0.45, 0.5, 0.4); gm.material_override = mat
	gb.add_child(gm)
	var cs := CollisionShape3D.new(); var bs := BoxShape3D.new(); bs.size = Vector3(40, 0.2, 40)
	cs.shape = bs; cs.position.y = -0.1; gb.add_child(cs)

	# the enemy
	var crab := (load("res://scenes/heavy_crab_enemy.tscn") as PackedScene).instantiate()
	crab.position = Vector3(0, 0.2, 0)
	add_child(crab)

	# camera
	var cam := Camera3D.new()
	cam.position = Vector3(0, 3.5, 7.0)
	cam.rotation_degrees = Vector3(-22, 0, 0)
	cam.fov = 55.0
	add_child(cam)
