extends Node3D

# Retargeted locomotion demo: Mixamo mutant clips drive the CC skeleton.
#   W walk · A/D turn · SPACE jump · E / click attack · drag/wheel orbit camera.
#
# Open scenes/skeleton_locomotion.tscn and run it (F6), or press K in a build.

const CC_SCENE: PackedScene = preload("res://assets/godot_skeleton_experiment.glb")
const CLIPS := {
	"idle": "res://assets/mutant_breathing_idle.fbx",
	# mutant_walking is a clean loop (start == end); the human walking.fbx is not
	# authored as a loop and snapped ~40deg at the seam.
	"walk": "res://assets/mutant_walking.fbx",
	"turn_l": "res://assets/mutant_left_turn.fbx",
	"turn_r": "res://assets/mutant_right_turn.fbx",
	"jump": "res://assets/mutant_jumping.fbx",
	"attack": "res://assets/mutant_swiping.fbx",
}
const WALK_SPEED := 2.0   # quicker, lighter gait
const TURN_RATE := 3.0

var _loco: RetargetedLocomotion
var _char: Node3D
var _speed_ratio := 0.0
var _facing_yaw := 0.0

# orbit follow camera
var _cam: Camera3D
var _cam_target := Vector3.ZERO
var _cam_dist := 3.0
var _cam_yaw := -PI / 2   # start behind the +X-facing character
var _cam_pitch := -0.18
var _orbiting := false
const ORBIT_SENS := 0.008
const ZOOM_STEP := 0.9
const MIN_DIST := 0.4


func _ready() -> void:
	_setup_environment()
	_ground()

	_char = Node3D.new()
	add_child(_char)
	var cc_model := CC_SCENE.instantiate()
	_char.add_child(cc_model)
	for mi in _meshes(cc_model):
		if mi.skin == null:
			mi.visible = false          # hide the static duplicate
	var cc_skel := _skel(cc_model)

	if cc_skel != null:
		_loco = RetargetedLocomotion.new(CLIPS, cc_skel, self)
		_loco.time_scale = 1.3        # quicker cadence = lighter
		_loco.jump_lift_scale = 1.7   # floatier, higher hop

	var span := _frame_camera(cc_model)
	_cam_target = _char.global_position + Vector3(0, span * 0.45, 0)
	_update_camera()
	_setup_ui()


func _process(delta: float) -> void:
	if _loco == null:
		return
	if Input.is_key_pressed(KEY_A):
		_facing_yaw += delta * TURN_RATE
	if Input.is_key_pressed(KEY_D):
		_facing_yaw -= delta * TURN_RATE
	var walking := Input.is_key_pressed(KEY_W)
	_speed_ratio = lerpf(_speed_ratio, 1.0 if walking else 0.0, 1.0 - exp(-8.0 * delta))

	_loco.update(delta, _speed_ratio)
	_loco.ground(_char)

	_char.rotation.y = _facing_yaw
	# The CC model's own forward is +X, so move along the character's basis X —
	# not a hand-rolled +Z vector, which slid the body 90° off its stride.
	var fwd := _char.global_transform.basis.x
	fwd.y = 0.0
	_char.position += fwd.normalized() * _speed_ratio * WALK_SPEED * delta

	_cam_target = _cam_target.lerp(_char.global_position + Vector3(0, 0.9, 0), 1.0 - exp(-6.0 * delta))
	_update_camera()


func _unhandled_input(event: InputEvent) -> void:
	if _handle_camera_input(event):
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_ESCAPE and ResourceLoader.exists("res://scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif key.keycode == KEY_R:
		get_tree().reload_current_scene()
	elif key.keycode == KEY_SPACE:
		_loco.trigger_jump()
	elif key.keycode == KEY_E:
		_loco.trigger_attack()
	elif key.keycode == KEY_A and _speed_ratio < 0.25:
		_loco.trigger_turn(true)
	elif key.keycode == KEY_D and _speed_ratio < 0.25:
		_loco.trigger_turn(false)


# ---- scaffolding ----------------------------------------------------------

func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.09, 0.10, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.35, 0.37, 0.42)
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -35, 0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)


func _ground() -> void:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	mi.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.17, 0.19)
	mi.material_override = mat
	add_child(mi)
	# Reference pillars so the character's movement is visible.
	for i in range(-2, 3):
		for j in range(-2, 3):
			if i == 0 and j == 0:
				continue
			var p := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.2, 1.0, 0.2)
			p.mesh = bm
			p.position = Vector3(i * 2.5, 0.5, j * 2.5)
			var pmat := StandardMaterial3D.new()
			pmat.albedo_color = Color(0.28, 0.29, 0.33)
			p.material_override = pmat
			add_child(p)


func _frame_camera(model: Node3D) -> float:
	var aabb := _aabb(model)
	if aabb.size == Vector3.ZERO:
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1.8, 1))
	var span := maxf(aabb.size.y, maxf(aabb.size.x, aabb.size.z))
	_cam_dist = span * 2.0
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	return span


func _handle_camera_input(event: InputEvent) -> bool:
	if _cam == null:
		return false
	var mb := event as InputEventMouseButton
	if mb != null:
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_cam_dist = maxf(MIN_DIST, _cam_dist * ZOOM_STEP)
				return true
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_cam_dist = _cam_dist / ZOOM_STEP
				return true
			MOUSE_BUTTON_LEFT:
				_orbiting = mb.pressed
				return true
		return false
	var mm := event as InputEventMouseMotion
	if mm != null and _orbiting:
		_cam_yaw -= mm.relative.x * ORBIT_SENS
		_cam_pitch = clampf(_cam_pitch - mm.relative.y * ORBIT_SENS, -1.4, 1.4)
		return true
	return false


func _update_camera() -> void:
	var cp := cos(_cam_pitch)
	var dir := Vector3(cp * sin(_cam_yaw), sin(_cam_pitch), cp * cos(_cam_yaw))
	_cam.global_position = _cam_target + dir * _cam_dist
	_cam.look_at(_cam_target, Vector3.UP)


func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out


func _skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _skel(c)
		if f != null:
			return f
	return null


func _aabb(node: Node) -> AABB:
	var out := AABB()
	var seeded := false
	for child in node.get_children():
		if child is VisualInstance3D:
			var vi := child as VisualInstance3D
			var w := vi.global_transform * vi.get_aabb()
			out = w if not seeded else out.merge(w)
			seeded = true
		var sub := _aabb(child)
		if sub.size != Vector3.ZERO:
			out = sub if not seeded else out.merge(sub)
			seeded = true
	return out


func _setup_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := Label.new()
	panel.position = Vector2(16, 12)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_color_override("font_color", Color.WHITE)
	panel.text = "SKELETON LOCOMOTION — retargeted Mixamo mutant clips\n" + \
		"W walk · A/D turn · SPACE jump · E attack\n" + \
		"drag orbit · wheel zoom · R rebuild · ESC exit"
	layer.add_child(panel)
