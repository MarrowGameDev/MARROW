extends Area3D

signal hit_confirmed(target: Node)

# Tier 1D: short-lived visible attack area.
# This node is spawned by the player when left click is pressed.
# It checks which enemies overlap it, damages them once, then deletes itself.

@export var damage: int = 1
@export var lifetime: float = 0.16
@export var visual_enabled: bool = true
@export_enum("Box", "Sphere") var override_shape_type: String = "Box"
@export var override_shape_size: Vector3 = Vector3.ZERO
@export var override_sphere_radius: float = 0.0

const ENEMY_BODY_HURTBOX_GROUP := "enemy_body_hurtboxes"

# The player that created this hitbox.
# We use this so the attack does not accidentally hit the player.
var owner_player: Node = null
var follow_target: Node3D = null
var follow_offset_provider: Node = null
var follow_offset_method: String = ""
var follow_direction: Vector3 = Vector3.FORWARD
var follow_forward_offset: float = 0.0
var follow_height: float = 0.65

# Stores enemies already hit by this one attack.
# This prevents one attack flash from damaging the same enemy multiple times.
var already_hit: Dictionary = {}
var contact_confirmed := false

# The translucent box mesh we fade out over the attack's lifetime. It starts
# hidden in the scene so head-only attacks cannot flash it for one frame before
# this script receives `visual_enabled`.
@onready var _visual: MeshInstance3D = $Visual

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false

	# body_entered fires when a PhysicsBody3D enters the Area3D.
	# Enemy scenes that use CharacterBody3D, StaticBody3D, or RigidBody3D can be detected.
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Polish: fade the swing out instead of letting it pop off abruptly.
	_apply_shape_override()
	_apply_visual_state()
	_update_follow_position()

	# Wait one physics frame so Godot has time to calculate bodies that were already
	# inside the hitbox the moment it spawned.
	await get_tree().physics_frame
	_hit_current_overlaps()

	# Keep the attack flash alive briefly, then remove it from the scene tree.
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(_delta: float) -> void:
	if follow_target == null:
		return
	_update_follow_position()
	_hit_current_overlaps()


func _apply_shape_override() -> void:
	if override_shape_size == Vector3.ZERO and override_sphere_radius <= 0.0:
		return

	var shape_node := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if shape_node != null:
		if override_shape_type == "Sphere":
			var sphere := SphereShape3D.new()
			sphere.radius = _override_sphere_radius()
			shape_node.shape = sphere
		else:
			var box := BoxShape3D.new()
			box.size = override_shape_size
			shape_node.shape = box

	if _visual != null:
		if override_shape_type == "Sphere":
			var sphere_mesh := SphereMesh.new()
			sphere_mesh.radius = _override_sphere_radius()
			sphere_mesh.height = _override_sphere_radius() * 2.0
			_visual.mesh = sphere_mesh
		else:
			var box_mesh := BoxMesh.new()
			box_mesh.size = override_shape_size
			_visual.mesh = box_mesh


func _override_sphere_radius() -> float:
	if override_sphere_radius > 0.0:
		return override_sphere_radius
	return maxf(maxf(override_shape_size.x, override_shape_size.y), override_shape_size.z) * 0.5


func _update_follow_position() -> void:
	if follow_target == null:
		return

	var offset := Vector3.ZERO
	if follow_offset_provider != null and follow_offset_method != "" and follow_offset_provider.has_method(follow_offset_method):
		var offset_value: Variant = follow_offset_provider.call(follow_offset_method)
		if offset_value is Vector3:
			offset = offset_value

	var flat_direction := Vector3(follow_direction.x, 0.0, follow_direction.z)
	if flat_direction.length() <= 0.01:
		flat_direction = Vector3.FORWARD
	else:
		flat_direction = flat_direction.normalized()

	global_position = follow_target.global_position + offset + flat_direction * follow_forward_offset + Vector3.UP * follow_height
	look_at(global_position + flat_direction, Vector3.UP)

func _apply_visual_state() -> void:
	if _visual == null:
		return
	_visual.visible = visual_enabled
	if visual_enabled:
		_start_fade()


# Fade the box mesh's transparency from its starting alpha down to invisible.
func _start_fade() -> void:
	if _visual == null:
		return
	var base_material := _visual.material_override
	if base_material is StandardMaterial3D:
		# Duplicate so fading THIS swing does not touch other live swings.
		var material := (base_material as StandardMaterial3D).duplicate() as StandardMaterial3D
		_visual.material_override = material
		var tween := create_tween()
		tween.tween_property(material, "albedo_color:a", 0.0, lifetime)

func _hit_current_overlaps() -> void:
	# This catches enemies that are already inside the hitbox when it appears.
	for body in get_overlapping_bodies():
		_try_hit_body(body)
	for area in get_overlapping_areas():
		_try_hit_enemy_area(area)

func _on_body_entered(body: Node) -> void:
	_try_hit_body(body)

func _on_area_entered(area: Area3D) -> void:
	_try_hit_enemy_area(area)

func _try_hit_body(body: Node) -> void:
	# Never hit the player that created this attack.
	if body == owner_player:
		return
	if not _body_should_confirm_contact(body):
		return

	_confirm_contact(body)

	# Never hit the same body twice with this same attack flash.
	if already_hit.has(body):
		return

	# This keeps the hitbox generic: anything with take_damage() can be hit.
	if body.has_method("take_damage"):
		already_hit[body] = true
		body.take_damage(damage, global_position, owner_player)


func _body_should_confirm_contact(body: Node) -> bool:
	if body == null:
		return false
	if body.has_method("take_damage"):
		return true
	if body is StaticBody3D:
		return not _is_ground_like_body(body)
	return false


func _is_ground_like_body(body: Node) -> bool:
	var body_name := String(body.name).to_lower()
	return (
		body_name.contains("ground")
		or body_name.contains("floor")
		or body_name.contains("terrain")
		or body_name.contains("stagebody")
		or body_name.contains("ramp")
	)


func _try_hit_enemy_area(area: Area3D) -> void:
	if not area.is_in_group(ENEMY_BODY_HURTBOX_GROUP):
		return

	var damage_owner := _damage_owner_for_area(area)
	if damage_owner == null or damage_owner == owner_player:
		return
	if already_hit.has(damage_owner):
		return
	_confirm_contact(damage_owner)
	if damage_owner.has_method("take_enemy_body_part_damage"):
		already_hit[damage_owner] = true
		damage_owner.call(
			"take_enemy_body_part_damage",
			_body_part_for_area(area),
			damage,
			global_position,
			owner_player,
			"melee"
		)


func _damage_owner_for_area(area: Area3D) -> Node:
	return area.get_meta("damage_owner", null) as Node


func _body_part_for_area(area: Area3D) -> String:
	return str(area.get_meta("body_part", ""))


func _confirm_contact(target: Node) -> void:
	if contact_confirmed:
		return
	contact_confirmed = true
	hit_confirmed.emit(target)
