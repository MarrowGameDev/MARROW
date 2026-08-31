extends Node3D

# A detached TORSO component (torso / hips / neck socket) HALF-BURIED in the ground, waiting to be
# recovered. It shows the real textured mesh from the character GLB and sits perfectly STILL until
# reached. Then it plays a reassembly animation like the head returning to its socket: it SHAKES in
# the ground, RISES and CIRCLES the invisible rig, and finally ATTACHES at its seat on the body.

const GLB: PackedScene = preload("res://assets/crab_head_character_optimized.glb")

signal assembled(part_name: String)

@export var part_name: String = "torso"
@export var scale_factor: float = 0.18   # match the creature so the attach is seamless
@export var buried_y: float = 0.0        # centroid at floor level while it waits => laid half-buried
@export var lay_pitch: float = -78.0     # tip it over so it LAYS on the ground (deg), not standing upright

@export_group("Reassembly animation")
@export var shake_dur: float = 1.1       # rumble side-to-side in the ground before it tears free (s)
@export var shake_amp: float = 0.12      # side-to-side displacement (m)
@export var shake_rate: float = 5.0      # side-to-side oscillations per second (Hz)
@export var orbit_dur: float = 1.15      # rise + circle the rig into the socket (s)
@export var orbit_turns: float = 1.6     # how many times it circles on the way in
@export var orbit_stretch: float = 0.45  # G-force stretch along the whirl, relaxing as it seats
@export var whirl_speed: float = 5.6     # spin while it circles (rad/s)

enum State { IDLE, SHAKE, ORBIT }

var _state: State = State.IDLE
var _ctrl: Node = null
var _model: Node3D
var _centered := false
var _cframe := 0
var _t := 0.0
var _base_pos := Vector3.ZERO   # buried rest pos (shake pivot / orbit start)
var _shake_dir := Vector3.RIGHT # primary horizontal axis it rattles along
var _shake_phase := 0.0         # per-part phase + rate so parts don't shake in unison
var _shake_phase2 := 0.0
var _shake_rate_mul := 1.0
var _shake_rate_mul2 := 1.0
var _r0 := 0.0                  # orbit start radius / angle / lift height
var _a0 := 0.0
var _lift0 := 0.0


func _ready() -> void:
	add_to_group("part_pickups")
	_model = GLB.instantiate()
	add_child(_model)
	scale = Vector3.ONE * scale_factor
	_show_only(_model)             # real textured mesh — no tint
	position.y = buried_y


# The creature reached the parts — tear free and reassemble (shake -> circle -> attach).
func begin_assembly(ctrl: Node) -> void:
	if _state != State.IDLE:
		return
	_ctrl = ctrl
	_state = State.SHAKE
	_t = 0.0
	_base_pos = global_position
	# each part gets its own axis, phase and frequency so the rattle looks uncoordinated, not in unison
	var a := randf() * TAU
	_shake_dir = Vector3(cos(a), 0.0, sin(a))
	_shake_phase = randf() * TAU
	_shake_phase2 = randf() * TAU
	_shake_rate_mul = randf_range(0.6, 1.5)
	_shake_rate_mul2 = randf_range(0.6, 1.5)
	remove_from_group("part_pickups")   # so the harness stops re-triggering it


func part() -> String:
	return part_name


func _process(delta: float) -> void:
	# skinned transforms are invalid on frame 0 — centre the part once they settle
	if not _centered:
		_cframe += 1
		if _cframe < 3:
			return
		_center_part()
		_centered = true

	match _state:
		State.IDLE:
			pass   # dead still, half-buried, until reached
		State.SHAKE:
			_t += delta
			var f := clampf(_t / maxf(shake_dur, 0.01), 0.0, 1.0)
			var amp := shake_amp * smoothstep(0.0, 0.2, f)   # ramp in fast, then sustain the sway
			# an erratic 2D wobble (primary axis + a weaker perpendicular one, each its own phase/rate)
			var perp := Vector3(-_shake_dir.z, 0.0, _shake_dir.x)
			var sa := sin(_t * TAU * shake_rate * _shake_rate_mul + _shake_phase)
			var sb := sin(_t * TAU * shake_rate * _shake_rate_mul2 + _shake_phase2)
			global_position = _base_pos + (_shake_dir * sa + perp * (sb * 0.6)) * amp
			if _t >= shake_dur:
				_state = State.ORBIT
				_t = 0.0
				rotation = Vector3.ZERO   # right itself (pivots about the centroid) for the flight in
				var center := _rig_center()
				var off := Vector3(global_position.x - center.x, 0.0, global_position.z - center.z)
				_r0 = maxf(off.length(), 0.7)
				_a0 = atan2(off.z, off.x)
				_lift0 = global_position.y
		State.ORBIT:
			_t += delta
			var e := smoothstep(0.0, 1.0, clampf(_t / maxf(orbit_dur, 0.01), 0.0, 1.0))
			var center := _rig_center()
			var socket := _socket()
			var angle := _a0 + orbit_turns * TAU * e
			var radius := lerpf(_r0, 0.05, e)
			var spiral := Vector3(center.x + cos(angle) * radius, lerpf(_lift0, socket.y, e), center.z + sin(angle) * radius)
			global_position = spiral.lerp(socket, smoothstep(0.65, 1.0, e))   # converge onto the exact seat
			_model.rotate_y(whirl_speed * delta)
			# G-force stretch (tall while whirling, relaxing to normal as it seats)
			var st := 1.0 + orbit_stretch * (1.0 - e)
			var inv := 1.0 / sqrt(st)
			scale = Vector3(scale_factor * inv, scale_factor * st, scale_factor * inv)
			if _t >= orbit_dur:
				scale = Vector3.ONE * scale_factor
				if _ctrl != null and _ctrl.has_method("equip_part"):
					_ctrl.equip_part(part_name)   # the part appears on the body at this exact seat
				assembled.emit(part_name)
				queue_free()


func _rig_center() -> Vector3:
	if _ctrl != null and _ctrl.has_method("part_socket_world"):
		return _ctrl.part_socket_world("torso")   # the trunk's vertical axis
	return _base_pos


func _socket() -> Vector3:
	if _ctrl != null and _ctrl.has_method("part_socket_world"):
		return _ctrl.part_socket_world(part_name)
	return _base_pos


func _show_only(n: Node) -> void:
	if n is MeshInstance3D:
		var m := n as MeshInstance3D
		m.visible = (m.name == part_name)   # keep the GLB's own material/texture
	for c in n.get_children():
		_show_only(c)


# Offset the model so the part's skinned centroid sits at our origin (otherwise it floats off to the
# side, wherever the skeleton places that piece).
func _center_part() -> void:
	var skel := _find_skel(_model)
	var mi := _find_mesh(_model, part_name)
	if skel == null or mi == null or mi.skin == null or mi.mesh == null:
		return
	var arr := mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var wts: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var skin := mi.skin
	var mats: Array[Transform3D] = []
	for bi in skin.get_bind_count():
		var b := skin.get_bind_bone(bi)
		if b < 0:
			b = bi
		mats.append(skel.get_bone_global_pose(b) * skin.get_bind_pose(bi))
	var sum := Vector3.ZERO
	var n := 0
	var step := maxi(1, verts.size() / 300)
	var i := 0
	while i < verts.size():
		var sk := Vector3.ZERO
		var per := bones.size() / maxi(verts.size(), 1)   # this rig is 8 bones/vertex, not 4
		for j in per:
			var w := wts[i * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[i * per + j]] * verts[i])
		sum += sk
		n += 1
		i += step
	if n > 0:
		# centre the piece's centroid on our origin — go through world space (to_local) so this is
		# correct regardless of how the skeleton is nested/scaled under the GLB root
		var c_world := skel.global_transform * (sum / n)
		_model.position -= to_local(c_world)
		# lay it down at a resting angle. The centroid is now at OUR origin, so rotating the pickup
		# tips the piece about its own centre (it stays put) — a part flopped on the ground.
		rotation = Vector3(deg_to_rad(lay_pitch), randf() * TAU, 0.0)


func _find_skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var r := _find_skel(c)
		if r != null:
			return r
	return null


func _find_mesh(n: Node, want: String) -> MeshInstance3D:
	if n is MeshInstance3D and (n as MeshInstance3D).name == want:
		return n as MeshInstance3D
	for c in n.get_children():
		var r := _find_mesh(c, want)
		if r != null:
			return r
	return null
