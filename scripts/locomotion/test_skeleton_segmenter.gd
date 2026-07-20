extends SceneTree

# Headless test for SkeletonSegmenter (fidelity B) against the real rig.
#   <godot> --headless --path . --script res://scripts/locomotion/test_skeleton_segmenter.gd
# Runs the checks on the 2nd frame so nodes are inside the tree (reparent + global
# transforms need that).

const SKELETON_PATH := "res://assets/godot_skeleton_experiment.glb"
const ORIGINAL_TRIS := 9402   # skinned body surface

var _skel: Skeleton3D
var _seg: SkeletonSegmenter
var _body: Node3D
var _model: Node
var _frame := 0
var _fail := 0
var _done := false


func _initialize() -> void:
	var packed: PackedScene = load(SKELETON_PATH)
	_model = packed.instantiate()
	get_root().add_child(_model)
	_skel = _find_skeleton(_model)
	_body = Node3D.new()
	get_root().add_child(_body)
	var debris := Node3D.new()
	get_root().add_child(debris)
	if _skel != null:
		_seg = SkeletonSegmenter.new(_skel, _body, debris)


func _process(_dt: float) -> bool:
	_frame += 1
	if _frame < 2 or _done:
		return _done
	_done = true
	_run()
	if _fail == 0:
		print("SKELETON_SEGMENTER_TEST: ALL PASS")
	else:
		print("SKELETON_SEGMENTER_TEST: %d FAILURE(S)" % _fail)
	quit(_fail)
	return true


func _run() -> void:
	_check("found a Skeleton3D", _skel != null)
	if _skel == null:
		return

	_seg.build(_model)

	# Every major segment exists with real geometry (not all dumped into core) —
	# a wrong bone/skin mapping would collapse everything to one bucket.
	for seg_id in ["core", "head", "l_upperarm", "r_upperarm", "l_thigh", "r_thigh"]:
		_check("segment '%s' has geometry (>50 verts)" % seg_id, _seg_verts(seg_id) > 50)
	_check("left/right arms are roughly symmetric",
		absf(_seg_verts("l_upperarm") - _seg_verts("r_upperarm")) < _seg_verts("l_upperarm"))

	# Invariant: every triangle lands in exactly one segment — none lost/duplicated.
	_check("segment triangles sum to the original (%d)" % ORIGINAL_TRIS, _total_tris() == ORIGINAL_TRIS)

	# Cut boundaries are capped (a cap MeshInstance rides as a child of a segment).
	_check("cut caps were generated", _count_caps() > 0)
	_check("torso is capped where limbs attach", _seg_has_cap("core"))

	# Originals hidden so we don't double-draw the body.
	var visible_originals := 0
	for mi in _find_meshes(_model):
		if mi.visible:
			visible_originals += 1
	_check("original body meshes hidden", visible_originals == 0)

	# Sever the left arm: its 3 segments move into one rigidbody, leave the body.
	var before := _body.get_child_count()
	var r := _seg.sever("CC_Base_L_Upperarm")
	_check("sever returned a result", not r.is_empty())
	_check("severed 3 arm segments (upperarm+forearm+hand)",
		not r.is_empty() and (r["segments"] as Array).size() == 3)
	_check("a debris RigidBody3D was spawned",
		not r.is_empty() and r["debris"] is RigidBody3D)
	_check("arm segments left the body", _body.get_child_count() < before)
	_check("core is still attached", _seg.segments.has("core"))
	_check("left arm reports severed", _seg.is_severed("CC_Base_L_Upperarm"))
	_check("re-severing the arm is refused", _seg.sever("CC_Base_L_Upperarm").is_empty())
	_check("severing the already-gone forearm is refused",
		_seg.sever("CC_Base_L_Forearm").is_empty())

	# The debris body carries real mesh pieces + convex colliders.
	if not r.is_empty():
		var body: RigidBody3D = r["debris"]
		var meshes := 0
		var shapes := 0
		for c in body.get_children():
			if c is MeshInstance3D:
				meshes += 1
			elif c is CollisionShape3D:
				shapes += 1
		_check("debris has real limb meshes", meshes >= 3)
		_check("debris has convex colliders", shapes >= 3)
		# The open stumps (shoulder, elbow) are capped; already-solid pieces
		# (the hand is a separate closed mesh) need none.
		_check("severed limb's open stumps are capped", _caps_under(body) >= 2)


func _seg_verts(seg_id: String) -> int:
	if not _seg.segments.has(seg_id):
		return 0
	var n := 0
	for mi in _seg.segments[seg_id]:
		n += (mi.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
	return n


# A cap is a MeshInstance3D child of a segment's MeshInstance3D.
func _count_caps() -> int:
	var n := 0
	for seg_id in _seg.segments.keys():
		for mi in _seg.segments[seg_id]:
			for c in (mi as Node).get_children():
				if c is MeshInstance3D:
					n += 1
	return n


func _seg_has_cap(seg_id: String) -> bool:
	if not _seg.segments.has(seg_id):
		return false
	for mi in _seg.segments[seg_id]:
		for c in (mi as Node).get_children():
			if c is MeshInstance3D:
				return true
	return false


func _caps_under(node: Node) -> int:
	var n := 0
	for c in node.get_children():
		if c is MeshInstance3D and node is MeshInstance3D:
			n += 1
		n += _caps_under(c)
	return n


func _total_tris() -> int:
	var n := 0
	for seg_id in _seg.segments.keys():
		for mi in _seg.segments[seg_id]:
			n += (mi.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_INDEX].size() / 3
	return n


func _check(label: String, cond: bool) -> void:
	print(("  ok   " if cond else "  FAIL ") + label)
	if not cond:
		_fail += 1


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
		var f := _find_skeleton(c)
		if f != null:
			return f
	return null
