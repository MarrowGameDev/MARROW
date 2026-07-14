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

	var was_holding := Input.is_action_pressed(DropPickupRulesService.PICKUP_ACTION)
	var next_progress := DropPickupRulesService.next_pickup_hold_progress(hold_progress, delta, was_holding)
	if was_holding:
		hold_progress = next_progress
		_update_prompt()
		if DropPickupRulesService.pickup_hold_is_complete(hold_progress, pickup_hold_time):
			_collect()
	else:
		if hold_progress > 0.0:
			hold_progress = next_progress
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
		GameEvents.pickup_focus_changed.emit(self, bone_id, body, true)
		_update_prompt()


func _on_body_exited(body: Node3D) -> void:
	if body != player_in_range:
		return

	if body.has_method("exit_bone_pickup_range"):
		body.call("exit_bone_pickup_range")

	GameEvents.pickup_focus_changed.emit(self, bone_id, body, false)
	player_in_range = null
	hold_progress = 0.0
	_update_prompt()


func _collect() -> void:
	if collected or player_in_range == null:
		return

	collected = true
	if player_in_range.has_method("collect_bone"):
		player_in_range.call("collect_bone", bone_id)
	GameEvents.pickup_collected.emit(bone_id, self, player_in_range)
	GameEvents.pickup_focus_changed.emit(self, bone_id, player_in_range, false)
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

	prompt_label.text = DropPickupRulesService.pickup_prompt_text(bone_id, hold_progress, pickup_hold_time, player_in_range != null)


func _update_prompt_color() -> void:
	if prompt_label == null:
		return

	prompt_label.modulate = BoneRulesService.color_for(bone_id)
