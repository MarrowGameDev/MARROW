extends Node

# Verlet cloth for the crab's HIPS skirt. The hips mesh is one skinned surface; its lower verts are a
# cloth-looking skirt. On this hopping creature the hip/leg bones don't animate, so we bake the skinned
# REST shape once, render the mesh SKINLESS (it still rides the body — it's a child of the Skeleton3D),
# and add a sway from a small VERLET CAGE (grid of particles) laid over the skirt. The top of the cage
# is pinned to the (moving) body; the rest swings under gravity + the body's motion (world-space verlet,
# so inertia comes for free). Each skirt vert is trilinearly bound to the cage, weighted by height, so
# the hem swings most and the waist stays put.

@export var cloth_start: float = 0.45     # normalized height (0=top .. 1=hem); verts BELOW this sway
@export var grid_x: int = 3
@export var grid_y: int = 4
@export var grid_z: int = 3
@export var gravity: float = 9.0          # world downward pull on the skirt
@export var stiffness: float = 0.10       # 0 = floppy .. 1 = barely moves (pulls the cage back to rigid, once/frame)
@export var damping: float = 0.90         # verlet velocity retention (higher = more momentum)
@export var iterations: int = 4           # constraint solve passes per frame
@export var max_offset: float = 0.9       # clamp the world sway so it can never explode
@export var floor_y: float = 0.0          # world height of the floor the cloth pools on
@export var floor_friction: float = 0.55  # 0 = slides freely on the floor .. 1 = sticks (drags hard as you move)

var _skel: Skeleton3D
var _mi: MeshInstance3D
var _mesh: ArrayMesh

var _rest := PackedVector3Array()         # skinned rest pos (skeleton-local) per vert
var _out := PackedVector3Array()          # working vertex buffer we write each frame
var _normals: Variant
var _uvs: Variant
var _tangents: Variant
var _colors: Variant
var _indices: Variant

var _cloth := PackedInt32Array()          # indices of verts that sway
var _cloth_fw := PackedFloat32Array()     # matching free-weights
var _corner := PackedInt32Array()         # 8 cage-corner indices per cloth vert
var _cw := PackedFloat32Array()           # 8 trilinear weights per cloth vert

var _grid_rest := PackedVector3Array()    # cage rest pos (skeleton-local)
var _pos := PackedVector3Array()          # cage current world pos
var _prev := PackedVector3Array()         # cage previous world pos
var _pin := PackedByteArray()             # 1 = pinned (follows the body rigidly)
var _edges := PackedInt32Array()          # structural cage edges (pairs)
var _mat: Material
var _root: Node
var _ok := false


func setup(root: Node) -> void:
	_root = root
	_skel = _find_skel(root)
	_mi = _find_mesh(root, "hips")
	if _skel != null and _mi != null and _mi.mesh != null:
		_build()


func _build() -> void:
	var arr: Array = _mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var wts: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	_normals = arr[Mesh.ARRAY_NORMAL]
	_uvs = arr[Mesh.ARRAY_TEX_UV]
	_tangents = arr[Mesh.ARRAY_TANGENT]
	_colors = arr[Mesh.ARRAY_COLOR]
	_indices = arr[Mesh.ARRAY_INDEX]

	# skinned rest positions (skeleton-local) — what GPU skinning shows at rest
	var skin := _mi.skin
	var mats: Array[Transform3D] = []
	for bi in skin.get_bind_count():
		var b := skin.get_bind_bone(bi)
		if b < 0:
			b = bi
		# bake from the REST pose so it's stable no matter what the body is doing at setup time
		mats.append(_skel.get_bone_global_rest(b) * skin.get_bind_pose(bi))
	var n := verts.size()
	var per := bones.size() / maxi(n, 1)   # bones/weights PER VERTEX (this rig uses 8, not 4)
	_rest.resize(n)
	var ylo := INF
	var yhi := -INF
	for i in n:
		var sk := Vector3.ZERO
		for j in per:
			var w := wts[i * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[i * per + j]] * verts[i])
		_rest[i] = sk
		ylo = minf(ylo, sk.y)
		yhi = maxf(yhi, sk.y)
	_out = _rest.duplicate()

	# which verts are CLOTH? lower verts (skirt/hem) sway; the waist stays put. free-weight ramps
	# smoothstep(cloth_start .. 1) from 0 at the waist to 1 at the hem.
	var span := maxf(yhi - ylo, 0.001)
	var mn := Vector3(INF, INF, INF)
	var mx := Vector3(-INF, -INF, -INF)
	for i in n:
		var t := 1.0 - clampf((_rest[i].y - ylo) / span, 0.0, 1.0)   # 0 at the waist .. 1 at the hem
		var fw := smoothstep(cloth_start, 1.0, t)
		if fw > 0.001:
			_cloth.append(i)
			_cloth_fw.append(fw)
			mn = Vector3(minf(mn.x, _rest[i].x), minf(mn.y, _rest[i].y), minf(mn.z, _rest[i].z))
			mx = Vector3(maxf(mx.x, _rest[i].x), maxf(mx.y, _rest[i].y), maxf(mx.z, _rest[i].z))
	if _cloth.is_empty():
		return

	# build the cage grid over the skirt bbox; pin the TOP y layer (the waist)
	grid_x = maxi(grid_x, 2)
	grid_y = maxi(grid_y, 2)
	grid_z = maxi(grid_z, 2)
	_grid_rest.resize(grid_x * grid_y * grid_z)
	_pin.resize(_grid_rest.size())
	for gz in grid_z:
		for gy in grid_y:
			for gx in grid_x:
				var k := _gk(gx, gy, gz)
				_grid_rest[k] = Vector3(
					lerpf(mn.x, mx.x, float(gx) / float(grid_x - 1)),
					lerpf(mn.y, mx.y, float(gy) / float(grid_y - 1)),
					lerpf(mn.z, mx.z, float(gz) / float(grid_z - 1)))
				_pin[k] = 1 if gy == grid_y - 1 else 0   # top layer pinned to the body
	_pos = _grid_rest.duplicate()
	_prev = _grid_rest.duplicate()

	# structural edges (x/y/z neighbours)
	for gz in grid_z:
		for gy in grid_y:
			for gx in grid_x:
				var k := _gk(gx, gy, gz)
				if gx + 1 < grid_x:
					_edges.append(k); _edges.append(_gk(gx + 1, gy, gz))
				if gy + 1 < grid_y:
					_edges.append(k); _edges.append(_gk(gx, gy + 1, gz))
				if gz + 1 < grid_z:
					_edges.append(k); _edges.append(_gk(gx, gy, gz + 1))

	# trilinear binding of each cloth vert to the cage
	var sz := Vector3(maxf(mx.x - mn.x, 1e-4), maxf(mx.y - mn.y, 1e-4), maxf(mx.z - mn.z, 1e-4))
	for ci in _cloth.size():
		var p := _rest[_cloth[ci]]
		var fx := clampf((p.x - mn.x) / sz.x, 0.0, 1.0) * (grid_x - 1)
		var fy := clampf((p.y - mn.y) / sz.y, 0.0, 1.0) * (grid_y - 1)
		var fz := clampf((p.z - mn.z) / sz.z, 0.0, 1.0) * (grid_z - 1)
		var gx := clampi(int(fx), 0, grid_x - 2)
		var gy := clampi(int(fy), 0, grid_y - 2)
		var gz := clampi(int(fz), 0, grid_z - 2)
		var wx := fx - gx
		var wy := fy - gy
		var wz := fz - gz
		for c in 8:
			var dx := c & 1
			var dy := (c >> 1) & 1
			var dz := (c >> 2) & 1
			_corner.append(_gk(gx + dx, gy + dy, gz + dz))
			_cw.append((wx if dx == 1 else 1.0 - wx) * (wy if dy == 1 else 1.0 - wy) * (wz if dz == 1 else 1.0 - wz))

	# rebuild the mesh SKINLESS so we can drive the verts directly (it still rides the skeleton node)
	_mat = _mi.get_active_material(0)   # capture before we swap the mesh
	_mesh = ArrayMesh.new()
	_write_surface()
	_mi.mesh = _mesh
	_mi.material_override = _mat        # keep the look even though the surface is rebuilt each frame
	_mi.skin = null
	_ok = true


func _write_surface() -> void:
	var out_arr := []
	out_arr.resize(Mesh.ARRAY_MAX)
	out_arr[Mesh.ARRAY_VERTEX] = _out
	out_arr[Mesh.ARRAY_NORMAL] = _normals
	out_arr[Mesh.ARRAY_TANGENT] = _tangents
	out_arr[Mesh.ARRAY_TEX_UV] = _uvs
	out_arr[Mesh.ARRAY_COLOR] = _colors
	out_arr[Mesh.ARRAY_INDEX] = _indices
	_mesh.clear_surfaces()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out_arr)


func _gk(x: int, y: int, z: int) -> int:
	return x + y * grid_x + z * grid_x * grid_y


func _process(delta: float) -> void:
	if not _ok or not _mi.visible:
		return
	var xf := _skel.global_transform
	var basis_inv := xf.basis.inverse()
	var dt := clampf(delta, 0.001, 0.05)
	var g := Vector3(0.0, -gravity, 0.0) * dt * dt

	# cage rigid world positions (where each point would be with no sim)
	var rigid := PackedVector3Array()
	rigid.resize(_grid_rest.size())
	for k in _grid_rest.size():
		rigid[k] = xf * _grid_rest[k]

	# verlet integrate the free points; pin the top layer to the moving body
	for k in _pos.size():
		if _pin[k] == 1:
			_pos[k] = rigid[k]
			_prev[k] = rigid[k]
		else:
			var vel := (_pos[k] - _prev[k]) * damping
			_prev[k] = _pos[k]
			_pos[k] = _pos[k] + vel + g

	# keep the cage edge lengths (shape) over several passes
	for _it in iterations:
		for e in range(0, _edges.size(), 2):
			var a := _edges[e]
			var b := _edges[e + 1]
			var rest_len := rigid[a].distance_to(rigid[b])
			var d := _pos[b] - _pos[a]
			var cur := d.length()
			if cur > 1e-5:
				var corr := d * ((cur - rest_len) / cur) * 0.5
				if _pin[a] == 0:
					_pos[a] += corr
				if _pin[b] == 0:
					_pos[b] -= corr
	# a gentle restoring pull toward the rigid (hanging) shape — ONCE, so the skirt can actually swing
	for k in _pos.size():
		if _pin[k] == 0:
			_pos[k] = _pos[k].lerp(rigid[k], stiffness)

	# FLOOR: cage points that reach the ground rest on it and DRAG — kill the downward motion and damp the
	# horizontal motion (friction), so as the body walks the pooled cloth sticks and gets pulled along.
	for k in _pos.size():
		if _pin[k] == 0 and _pos[k].y < floor_y:
			_pos[k].y = floor_y
			_prev[k].y = floor_y                                        # no bounce
			_prev[k].x = lerpf(_prev[k].x, _pos[k].x, floor_friction)   # friction -> horizontal drag
			_prev[k].z = lerpf(_prev[k].z, _pos[k].z, floor_friction)

	# deform the skirt verts: offset = cage sway (world) -> skeleton-local, scaled by free-weight
	var xf_inv := xf.affine_inverse()
	for ci in _cloth.size():
		var off := Vector3.ZERO
		var base := ci * 8
		for c in 8:
			var k := _corner[base + c]
			off += _cw[base + c] * (_pos[k] - rigid[k])
		if off.length() > max_offset:
			off = off.normalized() * max_offset
		var vi := _cloth[ci]
		_out[vi] = _rest[vi] + (basis_inv * off) * _cloth_fw[ci]
		# never let a skirt vert sink below the floor (it pools on top of it)
		var wp := xf * _out[vi]
		if wp.y < floor_y:
			wp.y = floor_y
			_out[vi] = xf_inv * wp

	# push the updated vertices to the mesh (material persists via material_override)
	_write_surface()


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
