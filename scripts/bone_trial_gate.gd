extends Area3D

@export var trial_id: String = "trial"
@export var trial_name: String = "Bone Trial"
@export var required_bone_id: String = "arm_bone"

var completed: bool = false
var player_in_range: Node3D = null
var gate_material: StandardMaterial3D = null

@onready var gate_mesh: MeshInstance3D = $GateMesh
@onready var gate_label: Label3D = $GateLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_prepare_material()
	_update_appearance()
	_update_label()


func _process(_delta: float) -> void:
	if completed or player_in_range == null:
		return

	_try_complete_with(player_in_range)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("get_equipped_bone_id"):
		player_in_range = body
		_update_label()


func _on_body_exited(body: Node3D) -> void:
	if body == player_in_range:
		player_in_range = null
		_update_label()


func _try_complete_with(player: Node3D) -> void:
	# Multi-slot: pass if the required bone is worn in ANY slot.
	if not player.has_method("has_bone_equipped") or not player.call("has_bone_equipped", required_bone_id):
		_update_label()
		return

	completed = true
	monitoring = false
	_update_label()
	_set_gate_color(Color(0.35, 1.0, 0.35, 1.0))

	for manager in get_tree().get_nodes_in_group("arena_goal_managers"):
		if manager.has_method("register_trial_complete"):
			manager.call("register_trial_complete", trial_id, trial_name)


func _prepare_material() -> void:
	var raw_material := gate_mesh.get_surface_override_material(0)
	if raw_material != null:
		gate_material = raw_material.duplicate() as StandardMaterial3D
	if gate_material == null:
		gate_material = StandardMaterial3D.new()
	gate_mesh.set_surface_override_material(0, gate_material)


func _update_appearance() -> void:
	# Unknown required bones fall back to red, matching the old gate default.
	_set_gate_color(BoneDatabase.color(required_bone_id, Color(0.85, 0.18, 0.16, 1.0)))


func _update_label() -> void:
	if gate_label == null:
		return

	if completed:
		gate_label.text = trial_name + "\nComplete"
		return

	var required_name := BoneDatabase.display_name(required_bone_id)
	if player_in_range == null:
		gate_label.text = trial_name + "\nNeeds " + required_name
	elif player_in_range.has_method("has_bone_equipped") and player_in_range.call("has_bone_equipped", required_bone_id):
		gate_label.text = trial_name + "\nReady! (" + required_name + ")"
	else:
		gate_label.text = trial_name + "\nEquip " + required_name


func _set_gate_color(color: Color) -> void:
	if gate_material == null:
		return

	gate_material.albedo_color = color
	gate_material.emission_enabled = true
	gate_material.emission = color
	gate_material.emission_energy_multiplier = 0.35

	if gate_label != null:
		gate_label.modulate = color


# Tier 1E: display names and colors now come from the shared scripts/bone_database.gd.
