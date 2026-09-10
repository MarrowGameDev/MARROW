extends Node3D

# A detached body PART that trails a leader (the head, or the part in front of it) on the ground,
# ROLLING as it goes. Used by the head+torso crouch-crawl: the head goes head-only and the torso/
# hips/neck detach and roll along behind it like a little train.

const GLB: PackedScene = preload("res://assets/crab_head_character_optimized.glb")

@export var part_name: String = "torso"
@export var scale_factor: float = 0.18
@export var follow_dist: float = 0.5     # how far this part trails the one in front
@export var roll_radius: float = 0.22    # smaller = spins faster as it rolls
@export var ground_y: float = 0.15       # fallback rest height until the mesh extent is measured
@export var tumble_frac: float = 0.55    # how much extra, off-axis tumble each part adds (0 = clean single-axis roll)
@export var gravity: float = 22.0        # it drops off the detaching body and falls onto the ground
@export var return_lift: float = 0.25    # extra arc height as it flies back up into the body when standing
@export var scatter_drag: float = 2.5    # how fast the initial outward burst bleeds off as it flies

var _model: Node3D
var _tumble_axis := Vector3.UP           # a random axis so each part tumbles independently, ball-like
var _tumble_dir := 1.0
var _grounded := false                    # false until it has fallen onto the floor
var _vel_y := 0.0                         # fall velocity while still in the air
var _scatter_vel := Vector3.ZERO          # initial outward burst so the parts don't land in one pile
var _vis: MeshInstance3D = null           # the visible part mesh
var _low_pts: PackedVector3Array = PackedVector3Array()   # sampled skinned points (node-local, unscaled) to find the lowest as it tumbles
var _measured := false
var _from := Vector3.ZERO                 # where it left the ground when the stand-up began
var _from_rot := Quaternion.IDENTITY      # its tumbled orientation at that moment (un-tumbles as it flies home)


func _ready() -> void:
	_model = GLB.instantiate()
	add_child(_model)
	scale = Vector3.ONE * scale_factor
	_show_only(_model)
	# each part gets its OWN random tumble axis + spin sense, so they roll/tumble independently
	# (ball-like) instead of all spinning in lock-step about the same axis
	_tumble_axis = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized()
	_tumble_dir = 1.0 if randf() < 0.5 else -1.0
	# centre + measure NOW (both are independent of where we get placed), so the mesh is aligned from
	# the very first frame instead of snapping into place a few frames later
	_center_part()
	_measure_extent()


func part() -> String:
	return part_name


# While airborne: fall straight down onto the ground (don't chase yet). Once grounded: chase the
# leader, keeping follow_dist behind it, and roll — but keep the lowest point pinned to the floor so
# tumbling never lifts it into the air.
func follow(leader_pos: Vector3, delta: float) -> void:
	var rest_y := _rest_y()   # y that seats the CURRENT-orientation lowest point on the floor
	if not _grounded:
		_vel_y -= gravity * delta
		var fp := global_position
		fp.y += _vel_y * delta
		fp += _scatter_vel * delta                     # burst outward so the parts spread apart
		_scatter_vel *= exp(-scatter_drag * delta)     # ...easing off as it settles
		if fp.y <= rest_y and _vel_y <= 0.0:
			fp.y = rest_y
			_vel_y = 0.0
			_scatter_vel = Vector3.ZERO
			_grounded = true
		global_position = fp
		return   # it just fell off the body — it lies still until the head pulls it along
	var target := Vector3(leader_pos.x, global_position.y, leader_pos.z)
	var to := target - global_position
	to.y = 0.0
	var d := to.length()
	if d > follow_dist:
		var dir := to / d
		var move := dir * (d - follow_dist)
		global_position += move
		var spin := move.length() / maxf(roll_radius, 0.01)
		var axis := Vector3(dir.z, 0.0, -dir.x)   # horizontal axis across travel -> ball rolls forward
		global_rotate(axis, spin)
		# plus an independent off-axis tumble, so it wobbles/tumbles like a real ball, not a wheel
		global_rotate(_tumble_axis, spin * tumble_frac * _tumble_dir)
	var gp := global_position
	gp.y = _rest_y()   # re-pin AFTER rolling: keeps it flush with the floor at its new orientation
	global_position = gp


# Orient the part to match the body it just detached from (its facing), so the swap from body-mesh to
# this loose part has no rotational pop. `q` is the body's world rotation.
func face_body(q: Quaternion) -> void:
	transform.basis = Basis(q).scaled(Vector3.ONE * scale_factor)


# Burst the part off the detaching body: `horiz` throws it outward, `pop` kicks it up so it arcs and
# lands scattered instead of dropping straight into a pile.
func launch_scatter(horiz: Vector3, pop: float) -> void:
	_scatter_vel = horiz
	_vel_y = pop
	_grounded = false


# --- standing back up: fly home from the ground into the body, un-tumbling on the way -------------
func begin_return() -> void:
	_from = global_position
	_from_rot = global_transform.basis.get_rotation_quaternion()


# Arc from where it lay on the ground back to its seat on the body, righting itself to the body's
# facing (target_rot) as it goes, so it lands flush and the swap back to the body-mesh has no pop.
# t: 0 at the start of standing up .. 1 fully home.
func return_to(target: Vector3, target_rot: Quaternion, t: float) -> void:
	var e := smoothstep(0.0, 1.0, clampf(t, 0.0, 1.0))
	var p := _from.lerp(target, e)
	p.y += return_lift * sin(PI * e)   # a little hop up over the flight
	global_position = p
	var q := _from_rot.slerp(target_rot, e)   # settle to the body's orientation
	transform.basis = Basis(q).scaled(Vector3.ONE * scale_factor)


# The origin height that seats the part's lowest (skinned) point on the floor (y=0), in its CURRENT
# orientation — so as it tumbles and rocks it stays flush with the ground instead of lifting off.
func _rest_y() -> float:
	if not _measured or _low_pts.is_empty():
		return ground_y
	var b := global_transform.basis   # current roll rotation + scale
	var lowest := INF
	for pt in _low_pts:
		lowest = minf(lowest, (b * pt).y)
	return -lowest   # lift the origin so the lowest point sits exactly on the floor


func _vis_mesh() -> MeshInstance3D:
	if _vis == null or not is_instance_valid(_vis):
		_vis = _find_mesh(_model, part_name)
	return _vis


# Sample the actual skinned vertices ONCE and store them in our (unscaled) local frame, so _rest_y()
# can find the true lowest point in any orientation. get_aabb() doesn't track the skinned pose, hence this.
func _measure_extent() -> void:
	var skel := _find_skel(_model)
	var mi := _vis_mesh()
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
	var gi := global_transform.affine_inverse()
	var st := skel.global_transform
	_low_pts = PackedVector3Array()
	var step := maxi(1, verts.size() / 160)
	var i := 0
	while i < verts.size():
		var sk := Vector3.ZERO
		var per := bones.size() / maxi(verts.size(), 1)   # this rig is 8 bones/vertex, not 4
		for j in per:
			var w := wts[i * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[i * per + j]] * verts[i])
		_low_pts.append(gi * (st * sk))
		i += step
	_measured = true


func _show_only(n: Node) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).visible = ((n as MeshInstance3D).name == part_name)
	for c in n.get_children():
		_show_only(c)


# Centre the part's skinned centroid on our origin (so it rolls about its own centre).
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
		# centre the part's centroid on OUR origin — via world space (to_local) so it's correct
		# regardless of how the skeleton is nested/scaled under the GLB root (it rolls about its centre)
		_model.position -= to_local(skel.global_transform * (sum / n))


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
