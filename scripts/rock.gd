extends StaticBody3D

# One individual boulder pulled out of rock_boulders.glb (a cluster of ~17 separate
# meshes), so single rocks can be scattered instead of repeating the whole clump.
# mesh_index picks which boulder (-1 = stable-random from the node name). The mesh is
# centered on X/Z and grounded (bottom at y=0), with a box collision from its bounds.

const CLUSTER: PackedScene = preload("res://assets/rock_boulders.glb")

@export var mesh_index: int = -1
@export var give_collision: bool = true
@export var target_width: float = 1.6   # largest horizontal footprint in metres (0 = raw size)

static var _cache: Array = []   # [{mesh, mat}] shared across all rocks (extract once)


func _ready() -> void:
	var parts := _parts()
	if parts.is_empty():
		return
	var idx := mesh_index
	if idx < 0:
		idx = int(abs(hash(name))) % parts.size()
	idx = clampi(idx, 0, parts.size() - 1)
	var p: Dictionary = parts[idx]
	var mesh: Mesh = p["mesh"]

	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	if p["mat"] != null:
		mi.set_surface_override_material(0, p["mat"])
	var aabb := mesh.get_aabb()
	var center := aabb.position + aabb.size * 0.5
	mi.position = Vector3(-center.x, -aabb.position.y, -center.z)   # ground + center
	add_child(mi)

	# Normalise every boulder to a comparable footprint so wildly different source
	# sizes (pebble vs rock) can be scattered with predictable in-world sizes.
	if target_width > 0.0:
		var d := maxf(aabb.size.x, aabb.size.z)
		if d > 0.0001:
			scale = Vector3.ONE * (target_width / d)
	# Stable random yaw so repeats of the same boulder don't look cloned.
	rotation.y = deg_to_rad(float(int(abs(hash(name + "y"))) % 360))

	if give_collision:
		var cs := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = aabb.size * Vector3(0.85, 0.9, 0.85)
		cs.shape = box
		cs.position = Vector3(0, aabb.size.y * 0.5, 0)
		add_child(cs)


func _parts() -> Array:
	if not _cache.is_empty():
		return _cache
	var inst := CLUSTER.instantiate()
	for mi in _find_meshes(inst):
		var m := mi as MeshInstance3D
		if m.mesh != null:
			_cache.append({"mesh": m.mesh, "mat": m.get_active_material(0)})
	inst.free()
	return _cache


func _find_meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_find_meshes(c))
	return out
