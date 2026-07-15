class_name EnemyRockProjectile
extends Area3D

@export var damage: int = 1
@export var lifetime: float = 4.0
@export var projectile_gravity: float = 24.0
@export var radius: float = 0.18

const PLAYER_BODY_HURTBOX_GROUP := "player_body_hurtboxes"

var velocity: Vector3 = Vector3.ZERO
var owner_enemy: Node = null
var _has_hit: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_build_visuals()

	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()


func configure(start_position: Vector3, launch_velocity: Vector3, hit_damage: int, source_enemy: Node, projectile_gravity: float = 24.0) -> void:
	global_position = start_position
	velocity = launch_velocity
	damage = hit_damage
	owner_enemy = source_enemy
	self.projectile_gravity = projectile_gravity


func _physics_process(delta: float) -> void:
	velocity.y -= projectile_gravity * delta
	global_position += velocity * delta
	rotation += Vector3(velocity.z, velocity.x, velocity.y) * delta * 0.8


func _on_body_entered(body: Node) -> void:
	if _has_hit or body == owner_enemy:
		return
	if body != null and body.is_in_group("enemies"):
		return
	if body != null and body.has_method("has_body_part_hitboxes") and bool(body.call("has_body_part_hitboxes")):
		return

	_has_hit = true
	if body != null and body.has_method("take_player_damage"):
		body.take_player_damage(damage, global_position)

	queue_free()


func _on_area_entered(area: Area3D) -> void:
	if _has_hit:
		return
	if not area.is_in_group(PLAYER_BODY_HURTBOX_GROUP):
		return

	var damage_owner := _damage_owner_for_area(area)
	if damage_owner == null or damage_owner == owner_enemy:
		return
	if damage_owner.has_method("take_player_body_part_damage"):
		_has_hit = true
		damage_owner.call("take_player_body_part_damage", _body_part_for_area(area), damage, global_position)
		queue_free()


func _damage_owner_for_area(area: Area3D) -> Node:
	return area.get_meta("damage_owner", null) as Node


func _body_part_for_area(area: Area3D) -> String:
	return str(area.get_meta("body_part", ""))


func _build_visuals() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var shape: CollisionShape3D = CollisionShape3D.new()
		var sphere: SphereShape3D = SphereShape3D.new()
		sphere.radius = radius
		shape.shape = sphere
		add_child(shape)

	if get_node_or_null("Visual") == null:
		var visual: MeshInstance3D = MeshInstance3D.new()
		visual.name = "Visual"
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = radius
		mesh.height = radius * 2.0
		visual.mesh = mesh
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(0.32, 0.28, 0.24, 1.0)
		material.roughness = 0.9
		visual.material_override = material
		add_child(visual)
