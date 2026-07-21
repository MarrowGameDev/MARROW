extends Node3D

# Skeleton detachment EXPERIMENT (fidelity "B" — real mesh).
#
# Loads the rigged CC skeleton, splits its skinned mesh into per-limb geometry
# (SkeletonSegmenter), then lets you knock limbs off at runtime: each number key
# reparents that limb's real triangles into a RigidBody3D that tumbles away,
# leaving an open cut on the torso. R rebuilds, ESC leaves.
#
# Open scenes/detach_experiment.tscn and run it (F6 in the editor), or press H in
# a running build. Drag to orbit, wheel to zoom, right-drag to pan.

const SKELETON: PackedScene = preload("res://assets/main_character.glb")

# key -> [root bone name, label]. Major anatomical joints only; twist/share/finger
# bones ride along inside each limb's sub-tree.
const LIMBS := {
	KEY_1: ["CC_Base_L_Upperarm", "left arm"],
	KEY_2: ["CC_Base_R_Upperarm", "right arm"],
	KEY_3: ["CC_Base_L_Thigh", "left leg"],
	KEY_4: ["CC_Base_R_Thigh", "right leg"],
	KEY_5: ["CC_Base_Head", "head"],
	KEY_6: ["CC_Base_L_Forearm", "left forearm"],
	KEY_7: ["CC_Base_R_Forearm", "right forearm"],
	KEY_8: ["CC_Base_L_Calf", "left shin"],
	KEY_9: ["CC_Base_R_Calf", "right shin"],
}

var _skeleton: Skeleton3D
var _segmenter: SkeletonSegmenter
var _label: Label

# Orbit camera state.
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
	_skeleton = _find_skeleton(model)

	var body_root := Node3D.new()
	body_root.name = "Body"
	add_child(body_root)
	var debris := Node3D.new()
	debris.name = "Debris"
	add_child(debris)

	if _skeleton != null:
		# Fidelity B: split the skinned mesh into per-limb geometry up front, so a
		# severed limb is real geometry and the torso is left with an open cut.
		_segmenter = SkeletonSegmenter.new(_skeleton, body_root, debris)
		# The main character is already modeled as separate per-limb part-meshes, so
		# detach whole parts along the artist's seams instead of re-splitting them.
		_segmenter.whole_parts = true
		_segmenter.build(model)

	_frame_camera(model)
	_setup_ui()
	if _skeleton == null:
		_status("ERROR: no Skeleton3D found in the model")


func _unhandled_input(event: InputEvent) -> void:
	if _handle_camera_input(event):
		return

	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_ESCAPE:
		if ResourceLoader.exists("res://scenes/main_menu.tscn"):
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	if key.keycode == KEY_R:
		get_tree().reload_current_scene()
		return
	if _segmenter != null and LIMBS.has(key.keycode):
		var info: Array = LIMBS[key.keycode]
		var r := _segmenter.sever(info[0])
		if r.is_empty():
			_status("%s — already gone" % info[1])
		else:
			_status("severed %s  (%d mesh pieces)" % [info[1], r["pieces"]])


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
	var floor_body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 0.2, 40)
	col.shape = box
	col.position = Vector3(0, -0.1, 0)
	floor_body.add_child(col)

	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40, 40)
	mi.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.17, 0.19)
	mi.material_override = mat
	floor_body.add_child(mi)
	add_child(floor_body)


# Frame the camera on the model's combined visual bounds, so it works whatever
# scale the export came in at. Seeds the orbit state; the camera can then be
# moved freely (see _handle_camera_input).
func _frame_camera(model: Node3D) -> void:
	var aabb := _merged_aabb(model)
	if aabb.size == Vector3.ZERO:
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1.8, 1))
	var center := aabb.position + aabb.size * 0.5
	var span := maxf(aabb.size.y, maxf(aabb.size.x, aabb.size.z))

	_cam_target = center
	_cam_dist = span * 1.9
	_cam_yaw = 0.0
	_cam_pitch = -0.15

	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_update_camera()


# Drag-to-orbit, wheel-to-zoom, right-drag-to-pan. Returns true if the event was
# a camera control (so limb hotkeys don't also see it).
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
		else:  # panning: slide the look-at target in the view plane
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


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var found := _find_skeleton(c)
		if found != null:
			return found
	return null


# ---- overlay --------------------------------------------------------------

func _setup_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := Label.new()
	panel.position = Vector2(16, 12)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_color_override("font_color", Color.WHITE)
	panel.text = "SKELETON DETACH — fidelity B (real mesh)\n" + \
		"1 L-arm  2 R-arm  3 L-leg  4 R-leg  5 head\n" + \
		"6 L-forearm  7 R-forearm  8 L-shin  9 R-shin\n" + \
		"drag orbit · wheel zoom · right-drag pan\n" + \
		"R rebuild   ESC exit"
	layer.add_child(panel)

	_label = Label.new()
	_label.position = Vector2(16, 112)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
	layer.add_child(_label)


func _status(msg: String) -> void:
	if _label != null:
		_label.text = msg
