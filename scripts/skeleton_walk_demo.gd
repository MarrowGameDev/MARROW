extends Node3D

# Phase 1 demo for the full skeleton-driven animator: the CC skeleton walks on
# its own bones. Hold W to walk (in place), A/D to turn the body toward a facing,
# and drag/wheel/right-drag to move the camera.
#
# Open scenes/skeleton_walk.tscn and run it (F6), or press J in a running build.

const SKELETON: PackedScene = preload("res://assets/godot_skeleton_experiment.glb")
const MAX_SPEED := 6.0

var _anim: SkeletonPoseAnimator
var _facing_yaw := 0.0

# orbit camera
var _cam: Camera3D
var _cam_target := Vector3.ZERO
var _cam_dist := 3.0
var _cam_yaw := 0.0
var _cam_pitch := -0.15
var _orbiting := false
var _panning := false
const ORBIT_SENS := 0.008
const ZOOM_STEP := 0.9
const MIN_DIST := 0.3


func _ready() -> void:
	_setup_environment()
	_ground()

	var model := SKELETON.instantiate()
	add_child(model)
	# The glb ships a static (unskinned) duplicate body on top of the skinned one;
	# hide it or it masks the animation in its rest T-pose.
	for mi in _find_meshes(model):
		if mi.skin == null:
			mi.visible = false
	var skeleton := _find_skeleton(model)
	if skeleton != null:
		_anim = SkeletonPoseAnimator.new(skeleton, model)

	_frame_camera(model)
	_setup_ui()


func _process(delta: float) -> void:
	if _anim == null:
		return
	if Input.is_key_pressed(KEY_A):
		_facing_yaw += delta * 2.2
	if Input.is_key_pressed(KEY_D):
		_facing_yaw -= delta * 2.2
	var walking := Input.is_key_pressed(KEY_W)
	var velocity := Vector3(0.0, 0.0, 1.0) * MAX_SPEED if walking else Vector3.ZERO
	var facing := Vector3(sin(_facing_yaw), 0.0, cos(_facing_yaw))
	_anim.update(delta, velocity, MAX_SPEED, facing)


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


# ---- scene scaffolding ----------------------------------------------------

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
	plane.size = Vector2(40, 40)
	mi.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.17, 0.19)
	mi.material_override = mat
	add_child(mi)


func _frame_camera(model: Node3D) -> void:
	var aabb := _merged_aabb(model)
	if aabb.size == Vector3.ZERO:
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1.8, 1))
	var center := aabb.position + aabb.size * 0.5
	var span := maxf(aabb.size.y, maxf(aabb.size.x, aabb.size.z))
	_cam_target = center
	_cam_dist = span * 1.9
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_update_camera()


func _handle_camera_input(event: InputEvent) -> bool:
	if _cam == null:
		return false
	var mb := event as InputEventMouseButton
	if mb != null:
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_cam_dist = maxf(MIN_DIST, _cam_dist * ZOOM_STEP)
					_update_camera()
				return true
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_cam_dist = _cam_dist / ZOOM_STEP
					_update_camera()
				return true
			MOUSE_BUTTON_LEFT:
				_orbiting = mb.pressed
				return true
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE:
				_panning = mb.pressed
				return true
		return false
	var mm := event as InputEventMouseMotion
	if mm != null and (_orbiting or _panning):
		if _orbiting:
			_cam_yaw -= mm.relative.x * ORBIT_SENS
			_cam_pitch = clampf(_cam_pitch - mm.relative.y * ORBIT_SENS, -1.4, 1.4)
		else:
			var basis := _cam.global_transform.basis
			var k := _cam_dist * 0.0015
			_cam_target += (-basis.x * mm.relative.x + basis.y * mm.relative.y) * k
		_update_camera()
		return true
	return false


func _update_camera() -> void:
	var cp := cos(_cam_pitch)
	var dir := Vector3(cp * sin(_cam_yaw), sin(_cam_pitch), cp * cos(_cam_yaw))
	_cam.global_position = _cam_target + dir * _cam_dist
	_cam.look_at(_cam_target, Vector3.UP)


func _merged_aabb(node: Node) -> AABB:
	var out := AABB()
	var seeded := false
	for child in node.get_children():
		if child is VisualInstance3D:
			var vi := child as VisualInstance3D
			var world := vi.global_transform * vi.get_aabb()
			out = world if not seeded else out.merge(world)
			seeded = true
		var sub := _merged_aabb(child)
		if sub.size != Vector3.ZERO:
			out = sub if not seeded else out.merge(sub)
			seeded = true
	return out


func _find_meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_find_meshes(c))
	return out


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var found := _find_skeleton(c)
		if found != null:
			return found
	return null


func _setup_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := Label.new()
	panel.position = Vector2(16, 12)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_color_override("font_color", Color.WHITE)
	panel.text = "SKELETON WALK — full skeleton-driven (phase 1)\n" + \
		"W walk · A/D turn\n" + \
		"drag orbit · wheel zoom · right-drag pan · R rebuild · ESC exit"
	layer.add_child(panel)
