extends SceneTree
const OUT := "/private/tmp/claude-501/-Users-juliantorres-Documents-Codex-2026-07-08-MARROW/2f7a6e17-54ce-4b7f-b243-8c47d83dcc3c/scratchpad/"
var _loco: RetargetedLocomotion
var _char: Node3D
var _cam: Camera3D
var _f := 0
func _initialize() -> void:
	var env := Environment.new(); env.background_mode = Environment.BG_COLOR; env.background_color = Color(0.14,0.15,0.17)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color = Color(0.5,0.5,0.55); env.ambient_light_energy = 0.85
	var we := WorldEnvironment.new(); we.environment = env; get_root().add_child(we)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-50,-40,0); get_root().add_child(sun)
	var g := MeshInstance3D.new(); var pm := PlaneMesh.new(); pm.size = Vector2(20,20); g.mesh = pm
	var gm := StandardMaterial3D.new(); gm.albedo_color = Color(0.22,0.23,0.25); g.material_override = gm; get_root().add_child(g)
	_char = Node3D.new(); get_root().add_child(_char)
	var cc := (load("res://assets/godot_skeleton_experiment.glb") as PackedScene).instantiate(); _char.add_child(cc)
	for mi in _meshes(cc):
		if mi.skin == null: mi.visible = false
	var lib := (load("res://assets/animation_library.glb") as PackedScene).instantiate(); get_root().add_child(lib)
	for mi in _meshes(lib): mi.visible = false
	_loco = RetargetedLocomotion.new(lib, _skel(cc), get_root(), "Idle_No", "Walk_Carry")
	_cam = Camera3D.new(); _cam.fov = 45; get_root().add_child(_cam)
func _process(_d) -> bool:
	_f += 1
	if _f < 2: return false
	_loco.update(1.0/60.0, 1.0)
	_loco.ground(_char)
	_cam.global_position = Vector3(3.2, 1.0, 2.6); _cam.look_at(Vector3(0, 0.85, 0), Vector3.UP)
	if _f == 40 or _f == 55:
		get_root().get_texture().get_image().save_png(OUT + "arms_%d.png" % _f); print("saved %d" % _f)
	return false
func _meshes(n):
	var o = []
	if n is MeshInstance3D: o.append(n)
	for c in n.get_children(): o.append_array(_meshes(c))
	return o
func _skel(n):
	if n is Skeleton3D: return n
	for c in n.get_children():
		var f=_skel(c)
		if f: return f
	return null
