extends Area3D

@export var bone_id: String = "dummy_bone"
@export var pickup_hold_time: float = 0.8

var collected: bool = false
var player_in_range: Node3D = null
var hold_progress: float = 0.0
var prompt_label: Label3D = null


func _ready() -> void:
	add_to_group("bone_pickups")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label = get_node_or_null("PromptLabel") as Label3D
	_update_prompt()
	_update_prompt_color()


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


func set_bone_id(new_bone_id: String) -> void:
	bone_id = new_bone_id
	_update_prompt()
	_update_prompt_color()


func _on_body_entered(body: Node3D) -> void:
	if collected:
		return

	if body.has_method("collect_bone"):
		player_in_range = body
		hold_progress = 0.0
		body.call("enter_bone_pickup_range")
		_update_prompt()


func _on_body_exited(body: Node3D) -> void:
	if body != player_in_range:
		return

	if body.has_method("exit_bone_pickup_range"):
		body.call("exit_bone_pickup_range")

	player_in_range = null
	hold_progress = 0.0
	_update_prompt()


func _collect() -> void:
	if collected or player_in_range == null:
		return

	collected = true
	if player_in_range.has_method("collect_bone"):
		player_in_range.call("collect_bone", bone_id)
	if player_in_range.has_method("exit_bone_pickup_range"):
		player_in_range.call("exit_bone_pickup_range")

	var root := get_parent()
	if root != null:
		root.queue_free()
	else:
		queue_free()


func _update_prompt() -> void:
	if prompt_label == null:
		return

	if player_in_range == null:
		prompt_label.text = BoneRulesService.display_name_with_slot(bone_id)
		return

	var percent := int((hold_progress / pickup_hold_time) * 100.0)
	prompt_label.text = "Hold " + _action_binding_text("interact") + ": " + BoneRulesService.display_name_with_slot(bone_id) + " " + str(percent) + "%"


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


func _update_prompt_color() -> void:
	if prompt_label == null:
		return

	prompt_label.modulate = BoneRulesService.color_for(bone_id)
