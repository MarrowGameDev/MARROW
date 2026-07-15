class_name ArrowProjectile
extends Area3D

@export var damage: int = 1
@export var lifetime: float = 3.0
@export var projectile_gravity: float = 6.0
@export var radius: float = 0.08

const PLAYER_BODY_HURTBOX_GROUP := "player_body_hurtboxes"
const ENEMY_BODY_HURTBOX_GROUP := "enemy_body_hurtboxes"

var arrow_velocity: Vector3 = Vector3.ZERO
var owner_body: Node = null
var damages_player: bool = false
var projectile_style: String = "arrow"
var _has_hit: bool = false
# Spawn point recorded by configure(), applied once the node is in the tree.
var _spawn_position: Vector3 = Vector3.ZERO
var _has_spawn_position: bool = false


func _ready() -> void:
	# Applied here rather than in configure(): callers must configure BEFORE
	# add_child so _build_visuals() below can see projectile_style and radius, but
	# at that point the node is not in the tree and global_position is unusable.
	if _has_spawn_position:
		global_position = _spawn_position
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_build_visuals()

	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()


# Safe to call before OR after add_child. Every caller currently calls it before,
# so writing global_position here logged
# `Condition "!is_inside_tree()" is true` for every projectile fired.
func configure(start_position: Vector3, launch_velocity: Vector3, hit_damage: int, source_body: Node, should_damage_player: bool, gravity_value: float = 6.0, visual_style: String = "arrow") -> void:
	_spawn_position = start_position
	_has_spawn_position = true
	if is_inside_tree():
		global_position = start_position
	arrow_velocity = launch_velocity
	damage = hit_damage
	owner_body = source_body
	damages_player = should_damage_player
	projectile_gravity = gravity_value
	projectile_style = visual_style
	if projectile_style == "saliva":
		radius = 0.13


func _physics_process(delta: float) -> void:
	arrow_velocity.y -= projectile_gravity * delta
	global_position += arrow_velocity * delta
	if arrow_velocity.length() > 0.01:
		look_at(global_position + arrow_velocity.normalized(), Vector3.UP)


func _on_body_entered(body: Node) -> void:
	if _has_hit or body == owner_body:
		return

	if damages_player:
		if body != null and body.has_method("has_body_part_hitboxes") and bool(body.call("has_body_part_hitboxes")):
			return
		if body != null and body.has_method("take_player_damage"):
			_has_hit = true
			body.take_player_damage(damage, global_position)
			queue_free()
		elif body != null and not body.is_in_group("enemies"):
			_has_hit = true
			queue_free()
		return

	if body != null and body.has_method("take_damage"):
		_has_hit = true
		body.take_damage(damage, global_position, owner_body, projectile_style)
		queue_free()
	elif body != null and body != owner_body:
		_has_hit = true
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	if _has_hit:
		return

	if damages_player:
		_try_hit_body_part_area(area, PLAYER_BODY_HURTBOX_GROUP, "take_player_body_part_damage", [])
		return

	_try_hit_body_part_area(area, ENEMY_BODY_HURTBOX_GROUP, "take_enemy_body_part_damage", [owner_body, projectile_style])


func _try_hit_body_part_area(area: Area3D, group_name: String, method_name: String, extra_args: Array) -> void:
	if not area.is_in_group(group_name):
		return

	var damage_owner := _damage_owner_for_area(area)
	if damage_owner == null or damage_owner == owner_body:
		return
	if not damage_owner.has_method(method_name):
		return

	_has_hit = true
	var call_args: Array = [_body_part_for_area(area), damage, global_position]
	call_args.append_array(extra_args)
	damage_owner.callv(method_name, call_args)
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
		var material: StandardMaterial3D = StandardMaterial3D.new()
		if projectile_style == "saliva":
			var saliva_mesh: SphereMesh = SphereMesh.new()
			saliva_mesh.radius = 0.13
			saliva_mesh.height = 0.22
			visual.mesh = saliva_mesh
			material.albedo_color = Color(0.48, 1.0, 0.28, 0.82)
			material.emission_enabled = true
			material.emission = Color(0.35, 1.0, 0.18, 1.0)
			material.emission_energy_multiplier = 0.45
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		elif projectile_style == "finger_bone":
			var finger_mesh: CapsuleMesh = CapsuleMesh.new()
			finger_mesh.radius = 0.055
			finger_mesh.height = 0.42
			visual.mesh = finger_mesh
			material.albedo_color = Color(0.96, 0.88, 0.66, 1.0)
		else:
			var arrow_mesh: CylinderMesh = CylinderMesh.new()
			arrow_mesh.top_radius = 0.025
			arrow_mesh.bottom_radius = 0.04
			arrow_mesh.height = 0.75
			visual.mesh = arrow_mesh
			material.albedo_color = Color(0.62, 0.38, 0.16, 1.0)
		visual.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		material.roughness = 0.75
		visual.material_override = material
		add_child(visual)
