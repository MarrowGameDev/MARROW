extends Node3D

# Inventory preview of the NEW main character (main_character.glb), showing only
# the part-meshes for the currently-equipped slots so the paper doll matches what
# the in-world player actually wears. Call sync(equipped_slots) whenever equipment
# changes (head / body / left_arm / right_arm / legs).

const CHARACTER: PackedScene = preload("res://assets/main_character.glb")

@export var preview_scale: float = 1.9
@export var preview_offset: Vector3 = Vector3(0, -1.0, 0)

var _model: Node3D
var _by_slot: Dictionary = {}   # slot -> Array[MeshInstance3D]


func _ready() -> void:
	scale = Vector3.ONE * preview_scale
	position = preview_offset
	var model := CHARACTER.instantiate()
	add_child(model)
	_model = model
	for mi in _meshes(model):
		var slot := _slot_of(String(mi.name))
		if not _by_slot.has(slot):
			_by_slot[slot] = []
		_by_slot[slot].append(mi)
		(mi as MeshInstance3D).visible = false   # start empty; sync() fills it in


# Show only the meshes whose slot is currently equipped.
func sync(equipped_slots: Array) -> void:
	for slot in _by_slot:
		var vis: bool = slot in equipped_slots
		for mi in _by_slot[slot]:
			if is_instance_valid(mi):
				(mi as MeshInstance3D).visible = vis


func _slot_of(name: String) -> String:
	var n := name.to_lower()
	if "rib" in n or "spine" in n or "hip" in n or "solar" in n or "shoulder" in n or "pelvis" in n or "neck" in n:
		return "body"
	if "skull" in n or "teeth" in n or "head" in n or "jaw" in n:
		return "head"
	if "leg" in n or "foot" in n or "knee" in n or "thigh" in n or "calf" in n or "shin" in n:
		return "legs"
	if "left" in n:
		return "left_arm"
	if "right" in n:
		return "right_arm"
	return "body"


func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out
