class_name SkeletonDetacher
extends RefCounted

# Fidelity "A" limb detachment for a SKINNED Skeleton3D (see the roadmap note in
# detachment.gd for the graph-level severing this pairs with).
#
# A rigged character is ONE skinned mesh welded to a bone hierarchy, so a limb
# cannot simply be reparented out — its triangles belong to the body mesh. This
# does the pragmatic thing:
#
#   1. collect the target bone + its whole descendant sub-tree (the limb),
#   2. spawn a RigidBody3D PROXY (a capsule spanning the limb) at the bone's
#      world pose and launch it, then
#   3. COLLAPSE the sub-tree (pose scale -> ~0) so the skinned limb folds to a
#      point and visually disappears from the body.
#
# Rough seams, but a real, testable "the arm comes off" mechanic. Fidelity "B"
# (splitting the skinned mesh into per-limb geometry) replaces step 2/3 later.
#
# Pure of scene setup — it only needs the Skeleton3D and a node to park debris
# under — so the logic is headless-testable (test_skeleton_detacher.gd).

var skeleton: Skeleton3D
var debris_parent: Node3D            # world-space node the debris bodies live under
var _severed: Dictionary = {}        # root bone idx -> true (re-sever guard)


func _init(skel: Skeleton3D, debris_root: Node3D) -> void:
	skeleton = skel
	debris_parent = debris_root


# The bone + every bone that descends from it (BFS over parent links).
func subtree(bone_idx: int) -> Array:
	var out: Array = [bone_idx]
	var i := 0
	while i < out.size():
		var b: int = out[i]
		for c in range(skeleton.get_bone_count()):
			if skeleton.get_bone_parent(c) == b:
				out.append(c)
		i += 1
	return out


# World transform of a bone (skeleton space -> global). Falls back to the
# skeleton's local transform when it isn't mounted in the tree yet (e.g. under a
# headless test) so it never trips a get_global_transform warning.
func bone_world(bone_idx: int) -> Transform3D:
	var base := skeleton.global_transform if skeleton.is_inside_tree() else skeleton.transform
	return base * skeleton.get_bone_global_pose(bone_idx)


# Is any ANCESTOR of this bone already severed? (Don't double-detach a forearm
# whose whole arm already came off.)
func _ancestor_severed(bone_idx: int) -> bool:
	var p := skeleton.get_bone_parent(bone_idx)
	while p >= 0:
		if _severed.has(p):
			return true
		p = skeleton.get_bone_parent(p)
	return false


func is_severed(bone_name: String) -> bool:
	var idx := skeleton.find_bone(bone_name)
	return idx >= 0 and _severed.has(idx)


# Sever the limb rooted at `bone_name`. `launch` is an added world-space velocity
# (m/s); omit it to fling the limb outward from the body and up. Returns
#   { root:int, bones:Array, debris:RigidBody3D }  on success, or {} if the bone
# is unknown / already gone / hangs off an already-severed limb.
func sever(bone_name: String, launch: Vector3 = Vector3.INF) -> Dictionary:
	var idx := skeleton.find_bone(bone_name)
	if idx < 0 or _severed.has(idx) or _ancestor_severed(idx):
		return {}

	var bones := subtree(idx)

	# Measure the limb: farthest descendant from the root, so the proxy capsule
	# spans hip->foot / shoulder->hand rather than a single bone segment.
	var root_w := bone_world(idx)
	var tip := root_w.origin
	var reach := 0.0
	for b in bones:
		var o := bone_world(b).origin
		var d := root_w.origin.distance_to(o)
		if d > reach:
			reach = d
			tip = o
	var length := maxf(reach, 0.08)

	var body := _make_proxy(root_w.origin, tip, length)

	# Launch it. Default: away from the skeleton's vertical axis, with lift.
	var v := launch
	if v == Vector3.INF:
		var skel_origin := skeleton.global_transform.origin if skeleton.is_inside_tree() else skeleton.transform.origin
		var out_dir := root_w.origin - skel_origin
		out_dir.y = 0.0
		out_dir = out_dir.normalized() if out_dir.length() > 0.01 else Vector3.RIGHT
		v = out_dir * (length * 2.0 + 0.6) + Vector3.UP * (length * 2.5 + 0.8)
	body.linear_velocity = v
	body.angular_velocity = Vector3(2.5, 1.0, -2.0)

	# Collapse the limb: zeroing the root's pose scale folds the whole sub-tree
	# (children inherit the parent's global pose) to the bone origin.
	skeleton.set_bone_pose_scale(idx, Vector3.ONE * 0.001)

	_severed[idx] = true
	return {"root": idx, "bones": bones, "debris": body}


# Build a capsule RigidBody3D spanning root->tip, parented under debris_parent.
func _make_proxy(root_pos: Vector3, tip: Vector3, length: float) -> RigidBody3D:
	var radius := clampf(length * 0.16, 0.02, 0.12)
	var height := maxf(length, radius * 2.0 + 0.02)

	var body := RigidBody3D.new()

	var mi := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.83, 0.77)
	mi.material_override = mat
	body.add_child(mi)

	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = radius
	cap.height = height
	shape.shape = cap
	body.add_child(shape)

	debris_parent.add_child(body)

	# Orient so the capsule's long (+Y) axis points root->tip, centred on the span.
	var mid := (root_pos + tip) * 0.5
	var xform := Transform3D(Basis(), mid)
	var axis := tip - root_pos
	if axis.length() > 0.001:
		var yy := axis.normalized()
		var ref := Vector3.UP if absf(yy.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
		var xx := ref.cross(yy).normalized()
		var zz := xx.cross(yy).normalized()
		xform.basis = Basis(xx, yy, zz)
	# `xform` is world-space. Assign it as global when mounted; off-tree (tests)
	# fall back to a local assign so we don't trip a set_global_transform warning.
	if body.is_inside_tree():
		body.global_transform = xform
	else:
		body.transform = xform
	return body
