class_name SkeletonSegmenter
extends RefCounted

# Fidelity "B" limb detachment: split a rigged character's SKINNED mesh into
# per-limb plain meshes, so a severed limb is REAL geometry (an open cut on the
# torso), not a proxy capsule.
#
# How: skin every vertex to its current pose (Σ wᵢ · Sᵢ · v, where Sᵢ = bone
# global pose · bind pose), tag each vertex with its dominant bone's body
# segment, then hand every triangle to the segment its vertices vote for. Each
# segment becomes a plain MeshInstance3D parked under `body_root`; the original
# skinned mesh AND its static duplicate are hidden. Severing a joint reparents
# the segment meshes below the cut into a RigidBody3D and flings them.
#
# Baked once at rest — the segmented body no longer skins to the skeleton, which
# is exactly what this static detach experiment wants (see the roadmap note in
# detachment.gd for wiring it to a live, animated body later).

# bone name -> segment id. A segment spans a cut bone down to the next cut.
const CUT_ROOTS := {
	"CC_Base_Head": "head",
	"CC_Base_L_Upperarm": "l_upperarm", "CC_Base_L_Forearm": "l_forearm", "CC_Base_L_Hand": "l_hand",
	"CC_Base_R_Upperarm": "r_upperarm", "CC_Base_R_Forearm": "r_forearm", "CC_Base_R_Hand": "r_hand",
	"CC_Base_L_Thigh": "l_thigh", "CC_Base_L_Calf": "l_calf", "CC_Base_L_Foot": "l_foot",
	"CC_Base_R_Thigh": "r_thigh", "CC_Base_R_Calf": "r_calf", "CC_Base_R_Foot": "r_foot",
}
const CORE := "core"

var skeleton: Skeleton3D
var body_root: Node3D                 # live (undetached) segment meshes hang here
var debris_parent: Node3D
var segments: Dictionary = {}         # segment id -> Array[MeshInstance3D]
var _seg_of_bone: Dictionary = {}     # bone idx -> segment id
var _severed: Dictionary = {}         # cut-root bone idx -> true
var _cap_material: StandardMaterial3D = null
# When the model is ALREADY split into per-limb part-meshes (like the main
# character: separate "left arm", "left forearm", "left hand"… meshes), assign
# each whole part-mesh to its dominant limb instead of splitting triangles by
# bone. Respects the artist's separation and needs no caps (the parts are already
# open at the joints), so detaching a limb keeps each part intact.
var whole_parts := false
const WHOLE_PART_MIN := 0.85          # keep a part whole only if this fraction is one limb


func _init(skel: Skeleton3D, body: Node3D, debris: Node3D) -> void:
	skeleton = skel
	body_root = body
	debris_parent = debris
	_map_bones_to_segments()


# ---- build ----------------------------------------------------------------

# Split every skinned mesh under `model` into segment meshes, then hide the
# originals (skinned + any static duplicate) so only the segments show.
func build(model: Node) -> void:
	body_root.global_transform = _skel_world()
	var meshes := _find_mesh_instances(model)
	for mi in meshes:
		if mi.skin != null and mi.mesh != null:
			_split(mi)
	for mi in meshes:
		mi.visible = false


func _split(mi: MeshInstance3D) -> void:
	var skin := mi.skin
	# bind index -> skinning transform Sᵢ, and -> skeleton bone.
	var bind_count := skin.get_bind_count()
	var s_of_bind: Array = []
	var bone_of_bind: Array = []
	for i in range(bind_count):
		var bone := skin.get_bind_bone(i)
		if bone < 0:
			bone = skeleton.find_bone(skin.get_bind_name(i))
		bone_of_bind.append(bone)
		var sm := Transform3D() if bone < 0 else skeleton.get_bone_global_pose(bone) * skin.get_bind_pose(i)
		s_of_bind.append(sm)

	var mesh := mi.mesh
	for surf in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surf)
		_split_surface(arrays, s_of_bind, bone_of_bind, mesh.surface_get_material(surf))


func _split_surface(arrays: Array, s_of_bind: Array, bone_of_bind: Array, material: Material) -> void:
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV] != null else PackedVector2Array()
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

	var vcount := verts.size()
	if vcount == 0 or bones.is_empty():
		return
	var infl := bones.size() / vcount            # weights per vertex (4 for glTF)
	var has_uv := uvs.size() == vcount

	# Bake each vertex to its posed position/normal and find its segment.
	var pos := PackedVector3Array(); pos.resize(vcount)
	var nrm := PackedVector3Array(); nrm.resize(vcount)
	var seg := PackedStringArray(); seg.resize(vcount)
	for v in range(vcount):
		var p := Vector3.ZERO
		var n := Vector3.ZERO
		var wsum := 0.0
		var best_w := -1.0
		var best_seg := CORE
		for k in range(infl):
			var idx := v * infl + k
			var w := weights[idx]
			if w <= 0.0:
				continue
			var bind := bones[idx]
			var s: Transform3D = s_of_bind[bind] if bind < s_of_bind.size() else Transform3D()
			p += (s * verts[v]) * w
			n += (s.basis * normals[v]) * w
			wsum += w
			if w > best_w:
				best_w = w
				var bone: int = bone_of_bind[bind] if bind < bone_of_bind.size() else -1
				best_seg = _seg_of_bone.get(bone, CORE)
		if wsum > 0.0:
			p /= wsum
		else:
			p = verts[v]
			n = normals[v]
		pos[v] = p
		nrm[v] = n.normalized() if n.length() > 0.0001 else Vector3.UP
		seg[v] = best_seg

	# Whole-part mode: if this artist-authored part sits almost entirely in ONE
	# limb, keep it intact (send every triangle there, no re-mesh, no cap). Parts
	# that straddle a joint — the "hips" (both thighs + pelvis) or a combined
	# thigh+calf "leg" mesh — fall back to the per-triangle split so the cut still
	# lands at the joint instead of the whole part flying off with one side.
	var forced_seg := ""
	if whole_parts:
		var counts: Dictionary = {}
		var best_c := 0
		for v in range(vcount):
			var c: int = counts.get(seg[v], 0) + 1
			counts[seg[v]] = c
			if c > best_c:
				best_c = c
				forced_seg = seg[v]
		if float(best_c) / float(vcount) < WHOLE_PART_MIN:
			forced_seg = ""

	# Vote each triangle to a segment. Also record CUT-boundary edges — an edge
	# whose two triangles landed in different segments — so those loops can be
	# capped and a severed limb / torso socket reads as solid, not hollow.
	# Corner indices accumulate in plain Arrays (by-reference, so appends stick
	# and there's no copy-on-write blow-up).
	var seg_tri: Dictionary = {}      # seg id -> Array of original corner indices (3/tri)
	var edge_first: Dictionary = {}   # edge key -> [seg, a, b] for its first triangle
	var border: Dictionary = {}       # seg id -> Array of [a, b] cut edges
	for t in range(0, indices.size(), 3):
		var a := indices[t]
		var b := indices[t + 1]
		var c := indices[t + 2]
		var target := forced_seg if forced_seg != "" else _vote(seg[a], seg[b], seg[c])
		if not seg_tri.has(target):
			seg_tri[target] = []
		var lst: Array = seg_tri[target]
		lst.append(a)
		lst.append(b)
		lst.append(c)
		for e in [[a, b], [b, c], [c, a]]:
			var key := (mini(e[0], e[1]) * vcount) + maxi(e[0], e[1])
			if edge_first.has(key):
				var prev: Array = edge_first[key]
				if prev[0] != target:                       # two segments meet here
					_add_border(border, prev[0], prev[1], prev[2])
					_add_border(border, target, e[0], e[1])
				edge_first.erase(key)                       # manifold edge: 2 triangles
			else:
				edge_first[key] = [target, e[0], e[1]]

	for seg_id in seg_tri.keys():
		_emit_segment(seg_id, seg_tri[seg_id], pos, nrm, uvs, has_uv, material,
			border.get(seg_id, []))


# Build one segment's mesh from the flat list of original corner indices, de-dup
# vertices into a compact buffer, and park a MeshInstance3D under body_root. Its
# cut boundary (if any) gets a capped-over child so the segment isn't hollow.
func _emit_segment(seg_id: String, ovis: Array, pos: PackedVector3Array,
		nrm: PackedVector3Array, uvs: PackedVector2Array, has_uv: bool, material: Material,
		border_edges: Array) -> void:
	if ovis.is_empty():
		return
	var vbuf := PackedVector3Array()
	var nbuf := PackedVector3Array()
	var uvbuf := PackedVector2Array()
	var ibuf := PackedInt32Array()
	var remap: Dictionary = {}
	for ov in ovis:
		if not remap.has(ov):
			remap[ov] = vbuf.size()
			vbuf.append(pos[ov])
			nbuf.append(nrm[ov])
			if has_uv:
				uvbuf.append(uvs[ov])
		ibuf.append(remap[ov])

	var a: Array = []
	a.resize(Mesh.ARRAY_MAX)
	a[Mesh.ARRAY_VERTEX] = vbuf
	a[Mesh.ARRAY_NORMAL] = nbuf
	if has_uv:
		a[Mesh.ARRAY_TEX_UV] = uvbuf
	a[Mesh.ARRAY_INDEX] = ibuf

	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, a)
	if material != null:
		am.surface_set_material(0, material)

	var mi := MeshInstance3D.new()
	mi.mesh = am
	body_root.add_child(mi)

	# Cap the cut. The cap rides as a child so it reparents with the limb on
	# sever; on the torso side it sits inside the body, revealed when a limb goes.
	if not border_edges.is_empty():
		var cap := _build_cap(border_edges, pos)
		if cap != null:
			var cap_mi := MeshInstance3D.new()
			cap_mi.mesh = cap
			cap_mi.material_override = _get_cap_material()
			mi.add_child(cap_mi)

	if not segments.has(seg_id):
		segments[seg_id] = []
	(segments[seg_id] as Array).append(mi)


# Fan-triangulate the cut boundary. Cut edges are grouped into loops (connected
# components) and each loop is filled from its own centroid, so a segment with
# several cuts (e.g. the torso: 2 shoulders, 2 hips, neck) caps each hole.
func _build_cap(border_edges: Array, pos: PackedVector3Array) -> ArrayMesh:
	var adj: Dictionary = {}
	for e in border_edges:
		if not adj.has(e[0]):
			adj[e[0]] = []
		if not adj.has(e[1]):
			adj[e[1]] = []
		(adj[e[0]] as Array).append(e[1])
		(adj[e[1]] as Array).append(e[0])

	var comp: Dictionary = {}     # vertex -> loop id
	var csum: Dictionary = {}     # loop id -> summed position
	var ccount: Dictionary = {}   # loop id -> vertex count
	var cid := 0
	for start in adj.keys():
		if comp.has(start):
			continue
		var stack: Array = [start]
		comp[start] = cid
		var sum := Vector3.ZERO
		var cnt := 0
		while not stack.is_empty():
			var u = stack.pop_back()
			sum += pos[u]
			cnt += 1
			for w in adj[u]:
				if not comp.has(w):
					comp[w] = cid
					stack.append(w)
		csum[cid] = sum
		ccount[cid] = cnt
		cid += 1
	if cid == 0:
		return null

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for e in border_edges:
		var id: int = comp[e[0]]
		var center: Vector3 = csum[id] / float(ccount[id])
		st.add_vertex(pos[e[0]])
		st.add_vertex(pos[e[1]])
		st.add_vertex(center)
	st.generate_normals()
	return st.commit()


func _get_cap_material() -> StandardMaterial3D:
	if _cap_material == null:
		_cap_material = StandardMaterial3D.new()
		_cap_material.albedo_color = Color(0.55, 0.16, 0.15)   # marrow / interior
		_cap_material.roughness = 0.9
		_cap_material.cull_mode = BaseMaterial3D.CULL_DISABLED  # double-sided
	return _cap_material


func _add_border(border: Dictionary, seg_id: String, a: int, b: int) -> void:
	if not border.has(seg_id):
		border[seg_id] = []
	(border[seg_id] as Array).append([a, b])


# ---- sever ----------------------------------------------------------------

# Detach the limb rooted at `bone_name`: reparent every segment below the cut
# into a RigidBody3D and fling it. `launch` overrides the default outward toss.
func sever(bone_name: String, launch: Vector3 = Vector3.INF) -> Dictionary:
	var idx := _fb(bone_name)
	if idx < 0 or _severed.has(idx) or _ancestor_severed(idx):
		return {}
	var sub := _subtree(idx)

	# Which segments live below the cut? (Their cut-root bone is in the sub-tree.)
	var take: Array = []
	for seg_id in CUT_ROOTS.values():
		var root_bone := _fb(_cut_root_name(seg_id))
		if root_bone in sub and segments.has(seg_id):
			take.append(seg_id)
	if take.is_empty():
		return {}

	var body := RigidBody3D.new()
	debris_parent.add_child(body)
	body.global_position = _bone_world(idx).origin   # pivot at the joint

	var moved: Array = []
	for seg_id in take:
		for mi in segments[seg_id]:
			mi.reparent(body, true)
			moved.append(mi)
			var cs := CollisionShape3D.new()
			cs.shape = (mi.mesh as ArrayMesh).create_convex_shape()
			cs.transform = mi.transform
			body.add_child(cs)
		segments.erase(seg_id)

	var v := launch
	if v == Vector3.INF:
		var out_dir := body.global_position - _skel_world().origin
		out_dir.y = 0.0
		out_dir = out_dir.normalized() if out_dir.length() > 0.01 else Vector3.RIGHT
		v = out_dir * 2.2 + Vector3.UP * 2.6
	body.linear_velocity = v
	body.angular_velocity = Vector3(2.0, 1.0, -1.5)

	_severed[idx] = true
	return {"root": idx, "segments": take, "debris": body, "pieces": moved.size()}


func is_severed(bone_name: String) -> bool:
	var idx := _fb(bone_name)
	return idx >= 0 and _severed.has(idx)


# Resolve a CC bone name with or without the "CC_Base_" prefix, so the segmenter
# drives both the CC_Base_* skeleton and the prefix-less main character.
func _fb(name: String) -> int:
	var b := skeleton.find_bone(name)
	if b < 0:
		b = skeleton.find_bone(name.trim_prefix("CC_Base_"))
	return b


# ---- helpers --------------------------------------------------------------

func _map_bones_to_segments() -> void:
	for b in range(skeleton.get_bone_count()):
		var cur := b
		var found := CORE
		while cur >= 0:
			var nm := skeleton.get_bone_name(cur)
			var key := nm if CUT_ROOTS.has(nm) else "CC_Base_" + nm
			if CUT_ROOTS.has(key):
				found = CUT_ROOTS[key]
				break
			cur = skeleton.get_bone_parent(cur)
		_seg_of_bone[b] = found


func _cut_root_name(seg_id: String) -> String:
	for nm in CUT_ROOTS.keys():
		if CUT_ROOTS[nm] == seg_id:
			return nm
	return ""


func _vote(x: String, y: String, z: String) -> String:
	if x == y or x == z:
		return x
	if y == z:
		return y
	return x


func _subtree(bone_idx: int) -> Array:
	var out: Array = [bone_idx]
	var i := 0
	while i < out.size():
		for c in range(skeleton.get_bone_count()):
			if skeleton.get_bone_parent(c) == out[i]:
				out.append(c)
		i += 1
	return out


func _ancestor_severed(bone_idx: int) -> bool:
	var p := skeleton.get_bone_parent(bone_idx)
	while p >= 0:
		if _severed.has(p):
			return true
		p = skeleton.get_bone_parent(p)
	return false


func _bone_world(bone_idx: int) -> Transform3D:
	return _skel_world() * skeleton.get_bone_global_pose(bone_idx)


func _skel_world() -> Transform3D:
	return skeleton.global_transform if skeleton.is_inside_tree() else skeleton.transform


func _find_mesh_instances(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_find_mesh_instances(c))
	return out
