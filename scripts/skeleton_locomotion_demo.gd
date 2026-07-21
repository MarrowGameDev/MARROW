extends Node3D

# Retargeted locomotion demo driving the main character.
#   W walk · SHIFT+W run · S back · A/D turn · Q turn-180 · SPACE jump · E attack.
#   Third-person follow camera (drag to orbit, wheel to zoom).
#
# Open scenes/skeleton_locomotion.tscn and run it (F6), or press K in a build.

const CC_SCENE: PackedScene = preload("res://assets/main_character.glb")
const CLIPS := {
	"idle": "res://assets/breathing_idle.fbx",
	# Locomotion clips are loop-ified (trimmed to their natural cycle) at load.
	"walk": "res://assets/walking.fbx",
	"run": "res://assets/running.fbx",
	"backward": "res://assets/running_backward.fbx",
	"turn_l": "res://assets/mutant_left_turn.fbx",
	"turn_r": "res://assets/mutant_right_turn.fbx",
	"turn180": "res://assets/running_turn180.fbx",
	"jump": "res://assets/running_jump.fbx",
	"attack": "res://assets/mutant_swiping.fbx",
}
const WALK_SPEED := 1.6   # movement at full-walk blend (0.5)
const RUN_SPEED := 3.4    # movement at full-run blend (1.0)
const BACK_SPEED := 1.5
const TURN_RATE := 2.5

var _loco: RetargetedLocomotion
var _char: Node3D
var _speed_ratio := 0.0
var _facing_yaw := 0.0
var _jump_launch_speed := 0.0   # gait speed at takeoff, held through the jump
var _base_forward := Vector3(0, 0, 1)   # the character's own forward (from its rig)
var _backward := 0.0
var _cam_orbit := 0.0   # user orbit offset on top of the auto follow-behind

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
		_base_forward = _forward_of(cc_skel)
		_cam_yaw = atan2(-_base_forward.x, -_base_forward.z)   # start behind the character
		_loco = RetargetedLocomotion.new(CLIPS, cc_skel, self)
		_loco.time_scale = 1.0        # normal pace (not agile)
		_loco.jump_lift_scale = 3.5   # boost the small character's hop to read well
		_loco.uprightness = 0.2       # mild unhunch (attack/turn clips are mutant)
		_loco.idle_normalize = 0.0    # real breathing idle already stands normally

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

	var running := Input.is_key_pressed(KEY_SHIFT)
	var fwd_in := Input.is_key_pressed(KEY_W)
	var back_in := Input.is_key_pressed(KEY_S)
	var target_speed := 0.0
	var target_back := 0.0
	if fwd_in:
		target_speed = 1.0 if running else 0.5   # blendspace: 0.5 walk, 1.0 run
	elif back_in:
		target_back = 1.0
	if _loco.is_jumping():
		target_speed = maxf(target_speed, _jump_launch_speed)
	_speed_ratio = lerpf(_speed_ratio, target_speed, 1.0 - exp(-8.0 * delta))
	_backward = lerpf(_backward, target_back, 1.0 - exp(-8.0 * delta))

	_loco.update(delta, _speed_ratio, _backward)
	_loco.ground(_char, delta)

	_char.rotation.y = _facing_yaw
	# Move along the character's OWN forward (derived from its rig), rotated by facing.
	var fwd := (Basis(Vector3.UP, _facing_yaw) * _base_forward)
	fwd.y = 0.0
	fwd = fwd.normalized()
	var fwd_speed := (_speed_ratio / 0.5) * WALK_SPEED if _speed_ratio <= 0.5 \
		else lerpf(WALK_SPEED, RUN_SPEED, (_speed_ratio - 0.5) / 0.5)
	_char.position += fwd * fwd_speed * delta
	_char.position -= fwd * _backward * BACK_SPEED * delta

	_update_follow_camera(delta)


# Third-person: the camera trails behind the character's facing and follows it,
# with the mouse adding an orbit offset.
func _update_follow_camera(delta: float) -> void:
	_cam_target = _cam_target.lerp(_char.global_position + Vector3(0, 0.6, 0), 1.0 - exp(-9.0 * delta))
	var fwd := Basis(Vector3.UP, _facing_yaw) * _base_forward
	var behind := atan2(-fwd.x, -fwd.z)
	_cam_yaw = lerp_angle(_cam_yaw, behind + _cam_orbit, 1.0 - exp(-4.0 * delta))
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
		_jump_launch_speed = _speed_ratio
		_loco.trigger_jump()
	elif key.keycode == KEY_E:
		_loco.trigger_attack()
	elif key.keycode == KEY_Q:
		_loco.trigger_turn180()
		_facing_yaw += PI          # the turn reverses facing
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
		_cam_orbit -= mm.relative.x * ORBIT_SENS   # offset on top of the follow-behind
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


# The character's forward in world space (at rest): the toe points forward, so
# use foot->toe. Falls back to lateral x up if there's no toe bone.
func _forward_of(skel: Skeleton3D) -> Vector3:
	var foot := _bone(skel, "L_Foot")
	var toe := _bone(skel, "L_ToeBase")
	if foot >= 0 and toe >= 0:
		var f := _wp(skel, toe) - _wp(skel, foot)
		f.y = 0.0
		if f.length() > 0.01:
			return f.normalized()
	var hip := _bone(skel, "Hip")
	var head := _bone(skel, "Head")
	var lt := _bone(skel, "L_Thigh")
	var rt := _bone(skel, "R_Thigh")
	if hip >= 0 and head >= 0 and lt >= 0 and rt >= 0:
		var up := (_wp(skel, head) - _wp(skel, hip)).normalized()
		var lat := (_wp(skel, lt) - _wp(skel, rt)).normalized()
		var f := lat.cross(up)
		f.y = 0.0
		if f.length() > 0.01:
			return f.normalized()
	return Vector3(0, 0, 1)


func _wp(skel: Skeleton3D, bone: int) -> Vector3:
	return (skel.global_transform * skel.get_bone_global_pose(bone)).origin


func _bone(skel: Skeleton3D, name: String) -> int:
	var b := skel.find_bone(name)
	if b < 0:
		b = skel.find_bone("CC_Base_" + name)
	return b


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
	panel.text = "SKELETON LOCOMOTION — third-person\n" + \
		"W walk · SHIFT+W run · S back · A/D turn · Q turn-180\n" + \
		"SPACE jump · E attack · drag orbit · wheel zoom · R rebuild · ESC exit"
	layer.add_child(panel)
