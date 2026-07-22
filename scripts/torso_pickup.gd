extends Area3D

# The player starts as a head; this is the TORSO (ribs + spine + hips) found
# HALF-BURIED in the ground, with a few ribs knocked loose and scattered around
# it. Walk into it to assemble it onto the head. It reuses the main character
# mesh, showing only the torso part-meshes.

const CHARACTER: PackedScene = preload("res://assets/main_character.glb")

@export var body_scale: float = 1.6
@export var bury_depth: float = 0.7                    # how deep the torso is sunk
@export var tilt_deg: Vector3 = Vector3(24, 35, 15)    # fallen / half-emerged angle
@export var loose_bone_count: int = 3                  # ribs knocked loose + scattered

var _model: Node3D
var _collected := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("bone_pickups")
	_rng.seed = int(hash(name)) + 7919      # stable scatter per pickup
	var model := CHARACTER.instantiate()
	add_child(model)
	_model = model
	model.scale = Vector3.ONE * body_scale
	model.rotation_degrees = tilt_deg       # laid over as if it fell / eroded out
	model.position.y = -bury_depth          # sink so it's half buried

	# Show only the torso; gather the ribs so a few can be knocked loose.
	var ribs: Array = []
	for mi in _meshes(model):
		var n := String(mi.name).to_lower()
		var is_torso := ("rib" in n or "spine" in n or "hip" in n or "solar" in n or "shoulder" in n or "pelvis" in n or "neck" in n)
		(mi as MeshInstance3D).visible = is_torso
		if is_torso and "rib" in n:
			ribs.append(mi)
	_scatter_loose_bones(ribs)

	var col := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 1.3                          # covers the torso + the scattered bones
	col.shape = sh
	add_child(col)
	body_entered.connect(_on_body_entered)
	call_deferred("_snap_to_ground")


# Knock a few ribs loose: hide them on the torso and lay rigid copies around it,
# each tilted and half-sunk into the sand.
func _scatter_loose_bones(ribs: Array) -> void:
	var count := mini(loose_bone_count, ribs.size())
	for i in range(count):
		var src := ribs[i] as MeshInstance3D
		if src.mesh == null:
			continue
		src.visible = false                  # this rib "detached" from the torso
		var a := src.mesh.get_aabb()
		var center := a.position + a.size * 0.5
		var cont := Node3D.new()
		add_child(cont)
		var ang := TAU * float(i) / float(count) + _rng.randf_range(-0.6, 0.6)
		var dist := _rng.randf_range(0.55, 0.95)
		# Lie flat on the sand (small tilt), heading random, barely sunk so it reads.
		cont.position = Vector3(cos(ang) * dist, _rng.randf_range(-0.04, 0.0), sin(ang) * dist)
		cont.rotation = Vector3(PI * 0.5 + _rng.randf_range(-0.4, 0.4), _rng.randf_range(0.0, TAU), _rng.randf_range(-0.35, 0.35))
		var dup := MeshInstance3D.new()
		dup.mesh = src.mesh
		dup.material_override = src.material_override
		dup.scale = Vector3.ONE * body_scale
		dup.position = -center * body_scale  # centre the bone on the container
		cont.add_child(dup)


# Drop onto the actual floor so the buried torso lines up with the ground wherever
# it spawned (the spawner may hand us the player's capsule-centre height).
func _snap_to_ground() -> void:
	if not is_inside_tree():
		return
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 2.0, global_position + Vector3.DOWN * 12.0)
	q.collide_with_areas = false
	var hit := space.intersect_ray(q)
	if hit:
		global_position.y = (hit.position as Vector3).y


func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if body != null and body.has_method("assemble_torso"):
		_collected = true
		body.assemble_torso()
		queue_free()


func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out
