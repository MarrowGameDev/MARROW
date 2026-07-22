extends Area3D

# The player starts as a head; this is the TORSO (ribs + spine + hips) lying on
# the floor. Walk into it to assemble it onto the head. It reuses the main
# character mesh, showing only the torso part-meshes.

const CHARACTER: PackedScene = preload("res://assets/main_character.glb")

@export var body_scale: float = 1.6
@export var ground_y: float = -0.55    # drop so the hips rest on the floor
@export var spin_speed: float = 0.6    # slow idle spin so it reads as a pickup

var _model: Node3D
var _collected := false


func _ready() -> void:
	add_to_group("bone_pickups")
	var model := CHARACTER.instantiate()
	add_child(model)
	_model = model
	model.scale = Vector3.ONE * body_scale
	model.position.y = ground_y
	# Show only the torso; hide head + limbs.
	for mi in _meshes(model):
		var n := String(mi.name).to_lower()
		mi.visible = ("rib" in n or "spine" in n or "hip" in n or "solar" in n or "shoulder" in n or "pelvis" in n or "neck" in n)

	# Pickup trigger volume.
	var col := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.9
	col.shape = sh
	col.position = Vector3(0, 0.3, 0)
	add_child(col)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _model != null and spin_speed != 0.0:
		_model.rotate_y(spin_speed * delta)


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
