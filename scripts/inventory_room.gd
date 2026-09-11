extends Node3D
class_name InventoryRoom
## A pitch-black enclosed room where a COPY of the marionette sits in a chair under a standing
## lamp while the inventory is open: a scriptless duplicate of the player's visuals (the hand
## and everything equipped on it), stood upright on the seat facing the camera and breathing its
## idle — the same picture no matter where the real hand stands or what it was doing. The real
## player never moves. The inventory page covers the LEFT ~45% of the screen, so the room's
## camera is shifted sideways (Camera3D.h_offset) to frame the chair + character in the RIGHT
## part of the view. Everything is built from primitives in _ready(); drop real models into
## `chair_scene` / `lamp_scene` later (a Marker3D named "Seat" inside the chair scene is used
## as the seat if present). The caller adds the room to the scene root at any position (e.g.
## Vector3(0, -300, 0)) and calls enter(player) / leave(). Works while the tree is paused.

## Interior size of the room in metres (width, height, depth). The floor is at local y = 0.
@export var room_size: Vector3 = Vector3(10, 5, 10)
## Optional real chair model; primitives are built when empty.
@export var chair_scene: PackedScene = null
## Optional real lamp model; primitives are built when empty. Its Light3D children flicker.
@export var lamp_scene: PackedScene = null
## Where the lamp stands, relative to the chair (chair faces +Z, the camera side).
@export var lamp_offset: Vector3 = Vector3(-0.85, 0.0, -0.25)
## Metres from the chair to the camera, on the chair's +Z side.
@export var camera_distance: float = 2.4
## Camera height above the floor; it looks slightly down at `camera_focus_height`.
@export var camera_height: float = 1.25
## Height above the floor the camera aims at (the seated character's centre).
@export var camera_focus_height: float = 0.85
## Camera3D.h_offset, metres. NEGATIVE moves the camera to its left, so the chair lands in the
## RIGHT part of the frame (the left is covered by the inventory page).
@export var camera_side_shift: float = -1.0
@export var camera_fov: float = 50.0
## Extra lift of the copy above the seat top (its lowest visible point is put on the seat).
@export var seat_player_lift: float = 0.0
## Height the copy is scaled to, metres, so it fits the chair (0 = the real hand's size).
@export var copy_height: float = 0.8
## Clip names tried, in order, for the copy's breathing pose (substring match, case-insensitive).
@export var idle_clips: Array[String] = ["idle", "loop", "walk"]
## Radians of turn per pixel of mouse drag (drag anywhere on the room side to spin the character).
@export var rotate_sensitivity: float = 0.012
## Lamp flicker depth (GlowFX.fire amount); 0 = steady.
@export var flicker_strength: float = 0.08

const WALL_COLOR := Color(0.02, 0.02, 0.02)
const WOOD_COLOR := Color(0.20, 0.13, 0.08)
const METAL_COLOR := Color(0.08, 0.07, 0.06)
const SHADE_COLOR := Color(0.85, 0.60, 0.35)
const LAMP_COLOR := Color(1.0, 0.82, 0.6)
const WALL_T := 0.1
const SEAT_SIZE := Vector3(0.5, 0.06, 0.5)
const SEAT_Y := 0.48                       # seat centre; top surface = SEAT_Y + half thickness
const SEAT_TOP := SEAT_Y + 0.03
const BACK_SIZE := Vector3(0.5, 0.55, 0.05)
const LEG_SIZE := Vector3(0.045, 0.45, 0.045)
const POLE_H := 1.6

var camera: Camera3D = null
var seat: Marker3D = null

var _player: Node3D = null
var _copy: Node3D = null           # the stand-in on the seat (freed by leave())
var _dragging := false             # left mouse button held over the room: spinning the copy
var _prev_cam: Camera3D = null
var _lights: Array[Light3D] = []
var _light_energies: PackedFloat32Array = PackedFloat32Array()
var _t: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_room()
	_build_chair()
	_build_lamp()
	_build_camera()


## Drag with the left mouse button over the room (the book's controls eat their own clicks) to
## turn the seated character around; runs while the tree is paused. The hand's camera
## controller ignores these clicks (look is disabled while the inventory is open).
func _unhandled_input(event: InputEvent) -> void:
	if _copy == null or not is_instance_valid(_copy) or camera == null or not camera.current:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_dragging = (event as InputEventMouseButton).pressed
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _dragging:
		_copy.rotate_y(-(event as InputEventMouseMotion).relative.x * rotate_sensitivity)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _lights.is_empty() or flicker_strength <= 0.0:
		return
	_t += delta
	for i in _lights.size():
		var light: Light3D = _lights[i]
		if not is_instance_valid(light):
			continue
		light.light_energy = _light_energies[i] * GlowFX.fire(_t, float(i) * 2.3, flicker_strength)


# ---------------------------------------------------------------- public API

## Seat a copy of `player` and show the room through `camera`. Remembers the current camera so
## leave() can hand the view back. The real player is left exactly where it is.
func enter(player: Node3D) -> void:
	if player == null or not is_instance_valid(player):
		return
	if _copy != null:
		leave()
	_player = player
	var prev := get_viewport().get_camera_3d()
	_prev_cam = prev if prev != camera else null
	_seat_copy(player)
	camera.current = true


## Free the copy and hand the view back to the previous camera.
func leave() -> void:
	if _copy != null and is_instance_valid(_copy):
		_copy.queue_free()
	_copy = null
	_dragging = false
	_player = null
	if _prev_cam != null and is_instance_valid(_prev_cam):
		_prev_cam.current = true
	elif camera.current:
		camera.current = false      # the viewport picks the next available camera
	_prev_cam = null


## The stand-in: a duplicate of the player's visuals (its VisualRoot — the hand and everything
## equipped on it, in its current state) with no scripts, signals or groups, stripped of any
## collision, stood on the seat facing the camera at the real hand's scale, playing its idle.
func _seat_copy(player: Node3D) -> void:
	var src: Node3D = player.get_node_or_null("VisualRoot") as Node3D
	if src == null:
		src = player
	_copy = src.duplicate(0) as Node3D
	_copy.name = "PlayerCopy"
	_copy.process_mode = Node.PROCESS_MODE_ALWAYS      # it breathes while the game is paused
	add_child(_copy)
	for co in _copy.find_children("*", "CollisionObject3D", true, false):
		co.get_parent().remove_child(co)
		co.queue_free()
	# upright on the seat, facing +Z (the camera), same scale as the real hand
	var seat_xf := seat_transform()
	var face: Vector3 = seat_xf.basis.z
	face.y = 0.0
	var yaw: float = atan2(face.x, face.z) if face.length() > 0.001 else 0.0
	var scale_v: Vector3 = src.global_transform.basis.get_scale()
	_copy.global_transform = Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(scale_v), seat_xf.origin)
	# scaled to copy_height so it fits the chair, its lowest visible point on the seat top
	var lowest := INF
	var highest := -INF
	for mi in _copy.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null or not m.is_visible_in_tree():
			continue
		var box: AABB = m.global_transform * m.get_aabb()
		lowest = minf(lowest, box.position.y)
		highest = maxf(highest, box.end.y)
	if lowest != INF:
		var height: float = highest - lowest
		if copy_height > 0.0 and height > 0.001:
			var k: float = copy_height / height
			_copy.scale *= k
			lowest = _copy.global_position.y + (lowest - _copy.global_position.y) * k   # scaled about the copy's origin
		_copy.global_position.y += seat_xf.origin.y - lowest
	_copy.global_position += seat_xf.basis.y.normalized() * seat_player_lift
	# a neutral, breathing pose — whatever the real hand was doing
	var aps := _copy.find_children("*", "AnimationPlayer", true, false)
	if not aps.is_empty():
		var ap := aps[0] as AnimationPlayer
		var clip := ""
		for want in idle_clips:
			for a in ap.get_animation_list():
				if String(a).to_lower().contains(want.to_lower()):
					clip = a
					break
			if clip != "":
				break
		if clip == "" and not ap.get_animation_list().is_empty():
			clip = ap.get_animation_list()[0]
		if clip != "":
			ap.play(clip)


func copy() -> Node3D:
	return _copy


## Global transform of the seat's top surface; +Z is the way a seated character faces.
func seat_transform() -> Transform3D:
	return seat.global_transform


func is_occupied() -> bool:
	return _player != null and is_instance_valid(_player)


# ---------------------------------------------------------------- construction

func _build_room() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = WALL_COLOR
	mat.roughness = 1.0
	mat.metallic = 0.0
	var w: float = room_size.x
	var h: float = room_size.y
	var d: float = room_size.z
	var floor_size := Vector3(w + WALL_T * 2.0, WALL_T, d + WALL_T * 2.0)
	_box("Floor", floor_size, Vector3(0.0, -WALL_T * 0.5, 0.0), mat, self)
	_box("Ceiling", floor_size, Vector3(0.0, h + WALL_T * 0.5, 0.0), mat, self)
	var side := Vector3(WALL_T, h, d + WALL_T * 2.0)
	var front := Vector3(w + WALL_T * 2.0, h, WALL_T)
	_box("WallEast", side, Vector3(w * 0.5 + WALL_T * 0.5, h * 0.5, 0.0), mat, self)
	_box("WallWest", side, Vector3(-w * 0.5 - WALL_T * 0.5, h * 0.5, 0.0), mat, self)
	_box("WallSouth", front, Vector3(0.0, h * 0.5, d * 0.5 + WALL_T * 0.5), mat, self)
	_box("WallNorth", front, Vector3(0.0, h * 0.5, -d * 0.5 - WALL_T * 0.5), mat, self)
	_collider("FloorBody", floor_size, Vector3(0.0, -WALL_T * 0.5, 0.0), self)


func _build_chair() -> void:
	var chair: Node3D
	if chair_scene != null:
		chair = chair_scene.instantiate() as Node3D
		if chair == null:
			chair = Node3D.new()
	else:
		chair = Node3D.new()
		var wood := StandardMaterial3D.new()
		wood.albedo_color = WOOD_COLOR
		wood.roughness = 0.85
		_box("SeatBoard", SEAT_SIZE, Vector3(0.0, SEAT_Y, 0.0), wood, chair)
		# backrest on the -Z side: the chair faces +Z, toward the camera
		_box("Backrest", BACK_SIZE, Vector3(0.0, SEAT_TOP + BACK_SIZE.y * 0.5, -SEAT_SIZE.z * 0.5 + BACK_SIZE.z * 0.5), wood, chair)
		var lx: float = SEAT_SIZE.x * 0.5 - LEG_SIZE.x
		var lz: float = SEAT_SIZE.z * 0.5 - LEG_SIZE.z
		var i := 0
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				_box("Leg%d" % i, LEG_SIZE, Vector3(lx * sx, LEG_SIZE.y * 0.5, lz * sz), wood, chair)
				i += 1
		_collider("SeatBody", SEAT_SIZE, Vector3(0.0, SEAT_Y, 0.0), chair)
	chair.name = "Chair"
	add_child(chair)

	# a "Seat" marker inside a real chair model wins; otherwise the primitive seat top.
	# The marker is a child of the ROOM (not the chair) so a scaled model can't stretch it.
	var found := chair.find_child("Seat", true, false)
	if found is Marker3D:
		seat = found as Marker3D
	else:
		seat = Marker3D.new()
		seat.name = "Seat"
		seat.position = Vector3(0.0, SEAT_TOP, 0.0)     # identity basis: +Z faces the camera
		add_child(seat)


func _build_lamp() -> void:
	var lamp: Node3D
	if lamp_scene != null:
		lamp = lamp_scene.instantiate() as Node3D
		if lamp == null:
			lamp = Node3D.new()
	else:
		lamp = Node3D.new()
		var metal := StandardMaterial3D.new()
		metal.albedo_color = METAL_COLOR
		metal.roughness = 0.6
		metal.metallic = 0.4
		_cylinder("Base", 0.16, 0.16, 0.03, Vector3(0.0, 0.015, 0.0), metal, lamp)
		_cylinder("Pole", 0.02, 0.02, POLE_H, Vector3(0.0, POLE_H * 0.5, 0.0), metal, lamp)
		# open cone shade, seen from inside too; the omni light sits in it so the shade glows
		var shade_mat := StandardMaterial3D.new()
		shade_mat.albedo_color = SHADE_COLOR
		shade_mat.roughness = 0.9
		shade_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		shade_mat.emission_enabled = true
		shade_mat.emission = LAMP_COLOR
		shade_mat.emission_energy_multiplier = 0.6
		var shade_h := 0.26
		var shade_y: float = POLE_H + shade_h * 0.5 - 0.07
		var shade := _cylinder("Shade", 0.08, 0.24, shade_h, Vector3(0.0, shade_y, 0.0), shade_mat, lamp)
		(shade.mesh as CylinderMesh).cap_bottom = false
		shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED

		var omni := OmniLight3D.new()
		omni.name = "Glow"
		omni.light_color = LAMP_COLOR
		omni.light_energy = 3.0
		omni.omni_range = 7.0
		omni.shadow_enabled = true
		omni.position = Vector3(0.0, shade_y, 0.0)
		lamp.add_child(omni)

		var spot := SpotLight3D.new()
		spot.name = "Beam"
		spot.light_color = LAMP_COLOR
		spot.light_energy = 2.0
		spot.spot_range = 5.0
		spot.spot_angle = 38.0
		spot.shadow_enabled = true
		# just under the shade rim, aimed at the seat (lamp-local: the chair is at -lamp_offset)
		var spot_pos := Vector3(0.0, shade_y - shade_h * 0.5 - 0.02, 0.0)
		var to_seat: Vector3 = (-lamp_offset + Vector3(0.0, SEAT_TOP, 0.0)) - spot_pos
		var up := Vector3.UP if absf(to_seat.normalized().dot(Vector3.UP)) < 0.99 else Vector3.BACK
		spot.transform = Transform3D(Basis.looking_at(to_seat, up), spot_pos)
		lamp.add_child(spot)
	lamp.name = "Lamp"
	lamp.position = lamp_offset
	add_child(lamp)

	_lights.clear()
	_light_energies.clear()
	for n in lamp.find_children("*", "Light3D", true, false):
		var light := n as Light3D
		_lights.append(light)
		_light_energies.append(light.light_energy)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "RoomCamera"
	camera.fov = camera_fov
	var pos := Vector3(0.0, camera_height, camera_distance)
	var target := Vector3(0.0, camera_focus_height, 0.0)
	camera.transform = Transform3D(Basis.looking_at(target - pos, Vector3.UP), pos)
	camera.h_offset = camera_side_shift
	# own environment: the level's sky must never light the room
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.BLACK
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.BLACK
	env.ambient_light_energy = 0.0
	env.glow_enabled = false
	env.fog_enabled = false
	camera.environment = env
	add_child(camera)


func _box(node_name: String, size: Vector3, pos: Vector3, mat: Material, parent: Node) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi


func _cylinder(node_name: String, top_r: float, bottom_r: float, height: float, pos: Vector3, mat: Material, parent: Node) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bottom_r
	mesh.height = height
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi


func _collider(node_name: String, size: Vector3, pos: Vector3, parent: Node) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	var shape := BoxShape3D.new()
	shape.size = size
	var cs := CollisionShape3D.new()
	cs.shape = shape
	cs.position = pos
	body.add_child(cs)
	parent.add_child(body)
	return body
