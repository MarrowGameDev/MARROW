extends Node3D

# The detached HEAD used for the assembled creature's headbutt: instead of the whole head+torso
# running the attack, the head POPS OUT of the neck socket, lunges/somersaults forward to strike, then
# flies back into the socket — the torso stays planted. This node just shows the head mesh centred on
# its own origin (so it pivots about the head's centre); the controller drives its world transform.

const GLB: PackedScene = preload("res://assets/crab_head_character_optimized.glb")

@export var part_name: String = "head"

var _model: Node3D


func _ready() -> void:
	_model = GLB.instantiate()
	add_child(_model)
	_show_only(_model)
	_center_part()   # head centroid on our origin, so somersaults pivot about the head's centre


func _show_only(n: Node) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).visible = ((n as MeshInstance3D).name == part_name)
	for c in n.get_children():
		_show_only(c)


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
