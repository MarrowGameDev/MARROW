extends Area3D

# This label is what goes into the player's inventory.
# Later, different enemies can set this to different bone types.
@export var bone_id: String = "dummy_bone"

# How long the player must hold the interact button while standing near the bone.
@export var pickup_hold_time: float = 0.8

# This prevents the same pickup from being collected twice in one frame.
var collected: bool = false
var player_in_range: Node3D = null
var hold_progress: float = 0.0
var prompt_label: Label3D = null
var bone_material: StandardMaterial3D = null
var marker_material: StandardMaterial3D = null

@onready var bone_mesh: MeshInstance3D = $MeshInstance3D
@onready var pickup_marker: MeshInstance3D = $PickupMarker


# _ready runs once when this pickup enters the running scene.
func _ready() -> void:
	add_to_group("bone_pickups")
	prompt_label = get_node("PromptLabel") as Label3D
	_prepare_materials()
	_update_prompt()
	_update_appearance()

	# Area3D emits body_entered when a PhysicsBody3D, like our CharacterBody3D player, enters it.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# _process runs every rendered frame.
# We use it here because holding Interact is a small interaction timer, not physics movement.
func _process(delta: float) -> void:
	if collected or player_in_range == null:
		return

	if Input.is_action_pressed("interact"):
		hold_progress += delta
		_update_prompt()

		if hold_progress >= pickup_hold_time:
			_collect()
	else:
		if hold_progress > 0.0:
			hold_progress = 0.0
			_update_prompt()


# The enemy can call this right after instancing the pickup.
func set_bone_id(new_bone_id: String) -> void:
	bone_id = new_bone_id
	_update_prompt()
	_update_appearance()


# This function runs automatically because we connected it to body_entered in _ready.
func _on_body_entered(body: Node3D) -> void:
	if collected:
		return

	if body.has_method("collect_bone"):
		player_in_range = body
		hold_progress = 0.0
		body.call("enter_bone_pickup_range")
		_update_prompt()


# This function runs automatically because we connected it to body_exited in _ready.
func _on_body_exited(body: Node3D) -> void:
	if body != player_in_range:
		return

	if body.has_method("exit_bone_pickup_range"):
		body.call("exit_bone_pickup_range")

	player_in_range = null
	hold_progress = 0.0
	_update_prompt()


# This finishes the pickup after Interact has been held long enough.
func _collect() -> void:
	if collected or player_in_range == null:
		return

	collected = true
	if player_in_range.has_method("collect_bone"):
		player_in_range.call("collect_bone", bone_id)
	if player_in_range.has_method("exit_bone_pickup_range"):
		player_in_range.call("exit_bone_pickup_range")

	queue_free()


# This gives basic feedback while holding Interact near the pickup.
func _update_prompt() -> void:
	if prompt_label == null:
		return

	if player_in_range == null:
		prompt_label.text = BoneDatabase.display_name_with_slot(bone_id)
		return

	var percent := int((hold_progress / pickup_hold_time) * 100.0)
	prompt_label.text = "Hold " + _action_binding_text("interact") + ": " + BoneDatabase.display_name_with_slot(bone_id) + " " + str(percent) + "%"


func _action_binding_text(action: String) -> String:
	if not InputMap.has_action(action):
		return action
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return action
	var event := events[0]
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var key_name := OS.get_keycode_string(key_event.keycode)
		if key_name != "":
			return key_name
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		match mouse_event.button_index:
			MOUSE_BUTTON_LEFT:
				return "Left Click"
			MOUSE_BUTTON_RIGHT:
				return "Right Click"
			MOUSE_BUTTON_MIDDLE:
				return "Middle Click"
			_:
				return "Mouse " + str(mouse_event.button_index)
	return action


# Tier 1E: display name and color now come from the shared scripts/bone_database.gd.


# Duplicate scene materials so one pickup can be recolored without affecting every pickup.
func _prepare_materials() -> void:
	var raw_bone_material := bone_mesh.get_surface_override_material(0)
	if raw_bone_material != null:
		bone_material = raw_bone_material.duplicate() as StandardMaterial3D

	if bone_material == null:
		bone_material = StandardMaterial3D.new()
	bone_mesh.set_surface_override_material(0, bone_material)

	var raw_marker_material := pickup_marker.get_surface_override_material(0)
	if raw_marker_material != null:
		marker_material = raw_marker_material.duplicate() as StandardMaterial3D

	if marker_material == null:
		marker_material = StandardMaterial3D.new()
	pickup_marker.set_surface_override_material(0, marker_material)


# Apply the current bone type color to both the pickup and its marker.
func _update_appearance() -> void:
	var color := BoneDatabase.color(bone_id)

	if bone_material != null:
		bone_material.albedo_color = color
		bone_material.emission_enabled = true
		bone_material.emission = color
		bone_material.emission_energy_multiplier = 0.35

	if marker_material != null:
		marker_material.albedo_color = color
		marker_material.emission_enabled = true
		marker_material.emission = color
		marker_material.emission_energy_multiplier = 0.9

	if prompt_label != null:
		prompt_label.modulate = color
