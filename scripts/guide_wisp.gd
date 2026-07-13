extends Node3D

# Neutral helper AI: hovers near the player, avoids enemies, and points toward
# the closest known hunt target so the world feels less empty between fights.

@export var follow_distance: float = 2.4
@export var hover_height: float = 1.65
@export var follow_speed: float = 4.2
@export var enemy_avoid_radius: float = 4.0
@export var enemy_avoid_strength: float = 3.0
@export var target_scan_interval: float = 0.35

var player: Node3D = null
var guide_target: Node3D = null
var scan_timer: float = 0.0
var float_time: float = 0.0

@onready var orb: MeshInstance3D = $Orb
@onready var label: Label3D = $Label3D


func _ready() -> void:
	add_to_group("friendly_ai")
	_prepare_material()


func _process(delta: float) -> void:
	float_time += delta
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
		if player == null:
			return

	scan_timer -= delta
	if scan_timer <= 0.0:
		scan_timer = target_scan_interval
		guide_target = _find_closest_enemy_target()

	_update_motion(delta)
	_update_label()


func _update_motion(delta: float) -> void:
	var side := Vector3(-0.65, 0.0, 0.75).normalized()
	var desired := player.global_position + side * follow_distance
	desired.y = player.global_position.y + hover_height + sin(float_time * 2.4) * 0.18

	var avoid := Vector3.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_body := enemy as Node3D
		if enemy_body == null:
			continue
		var away := global_position - enemy_body.global_position
		away.y = 0.0
		var distance := away.length()
		if distance > 0.01 and distance < enemy_avoid_radius:
			avoid += away.normalized() * ((enemy_avoid_radius - distance) / enemy_avoid_radius)

	desired += avoid * enemy_avoid_strength
	global_position = global_position.lerp(desired, 1.0 - exp(-follow_speed * delta))

	if guide_target != null and is_instance_valid(guide_target):
		var flat_target := guide_target.global_position
		flat_target.y = global_position.y
		if global_position.distance_to(flat_target) > 0.1:
			look_at(flat_target, Vector3.UP)


func _find_closest_enemy_target() -> Node3D:
	var best: Node3D = null
	var best_distance := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_body := enemy as Node3D
		if enemy_body == null:
			continue
		var distance := player.global_position.distance_to(enemy_body.global_position)
		if distance < best_distance:
			best = enemy_body
			best_distance = distance
	return best


func _update_label() -> void:
	if label == null:
		return

	if guide_target == null or not is_instance_valid(guide_target):
		label.text = "Wisp\nNo target"
		return

	if guide_target.has_method("get_drop_display_name"):
		label.text = "Wisp\nHunt: " + str(guide_target.call("get_drop_display_name"))
	else:
		label.text = "Wisp\nHunt nearby"


func _prepare_material() -> void:
	if orb == null:
		return

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.35, 0.85, 1.0, 0.78)
	material.emission_enabled = true
	material.emission = Color(0.35, 0.85, 1.0, 1.0)
	material.emission_energy_multiplier = 1.2
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	orb.material_override = material
