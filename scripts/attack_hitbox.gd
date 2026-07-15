extends Area3D

signal hit_confirmed(target: Node)

# Tier 1D: short-lived visible attack area.
# This node is spawned by the player when left click is pressed.
# It checks which enemies overlap it, damages them once, then deletes itself.

@export var damage: int = 1
@export var lifetime: float = 0.16
@export var visual_enabled: bool = true

const ENEMY_BODY_HURTBOX_GROUP := "enemy_body_hurtboxes"

# The player that created this hitbox.
# We use this so the attack does not accidentally hit the player.
var owner_player: Node = null

# Stores enemies already hit by this one attack.
# This prevents one attack flash from damaging the same enemy multiple times.
var already_hit: Dictionary = {}
var contact_confirmed := false

# The translucent box mesh we fade out over the attack's lifetime.
@onready var _visual: MeshInstance3D = $Visual

func _ready() -> void:
	# body_entered fires when a PhysicsBody3D enters the Area3D.
	# Enemy scenes that use CharacterBody3D, StaticBody3D, or RigidBody3D can be detected.
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Polish: fade the swing out instead of letting it pop off abruptly.
	_apply_visual_state()

	# Wait one physics frame so Godot has time to calculate bodies that were already
	# inside the hitbox the moment it spawned.
	await get_tree().physics_frame
	_hit_current_overlaps()

	# Keep the attack flash alive briefly, then remove it from the scene tree.
	await get_tree().create_timer(lifetime).timeout
	queue_free()

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
	if body.has_method("has_body_part_hitboxes") and bool(body.call("has_body_part_hitboxes")):
		return

	_confirm_contact(body)

	# Never hit the same body twice with this same attack flash.
	if already_hit.has(body):
		return

	# This keeps the hitbox generic: anything with take_damage() can be hit.
	if body.has_method("take_damage"):
		already_hit[body] = true
		body.take_damage(damage, global_position, owner_player)


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
