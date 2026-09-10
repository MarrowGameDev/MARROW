extends StaticBody3D

# A simple damageable target box for testing attacks: builds its own mesh + collision, sits
# in the "enemies" group so attacks find it, flashes white when hit, and breaks apart at 0 HP.

@export var health: int = 3
@export var box_size: float = 1.0
@export var tint: Color = Color(0.72, 0.5, 0.32)

var _mat: StandardMaterial3D
var _alive := true


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 1
	collision_mask = 1

	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new(); bm.size = Vector3.ONE * box_size
	mesh.mesh = bm
	_mat = StandardMaterial3D.new(); _mat.albedo_color = tint; _mat.roughness = 0.7
	mesh.material_override = _mat
	mesh.position.y = box_size * 0.5     # sit on the ground
	add_child(mesh)

	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new(); bs.size = Vector3.ONE * box_size
	cs.shape = bs; cs.position.y = box_size * 0.5
	add_child(cs)


# Called by the attack (and matches the enemy take_damage signature).
func take_damage(amount: int, _from: Vector3 = Vector3.ZERO, _attacker: Node = null, _src: String = "") -> void:
	if not _alive:
		return
	health -= amount
	_flash()
	if health <= 0:
		_die()


func _flash() -> void:
	_mat.albedo_color = Color(1, 1, 1)
	var t := create_tween()
	t.tween_property(self, "scale", Vector3.ONE * 0.85, 0.06)   # quick punch
	t.tween_property(self, "scale", Vector3.ONE, 0.10)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(self) and _alive:
		_mat.albedo_color = tint


func _die() -> void:
	_alive = false
	remove_from_group("enemies")
	var t := create_tween()
	t.tween_property(self, "scale", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await t.finished
	queue_free()
