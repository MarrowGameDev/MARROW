extends Area3D
class_name InteractStation
## Base for world stations the hand walks up to: detects the player (group "player"), floats a
## prompt above itself, and calls _on_interact() when "interact" (E) is pressed in range.
## Sizes are WORLD metres — divided by the node's global scale, so a station stays the same
## real size under a 1x or a 7x-scaled parent. Subclasses: craft_station.gd, scavenge_station.gd.

@export var trigger_size: Vector3 = Vector3(3.0, 2.5, 3.0)
@export var prompt_text: String = "Press E"
@export var prompt_height: float = 1.6

var _player: Node3D = null
var _prompt: Label3D
var _base_prompt: String
var _flashing := false
var _flash_id := 0


func _ready() -> void:
	var s: Vector3 = global_transform.basis.get_scale()
	s = Vector3(maxf(s.x, 0.001), maxf(s.y, 0.001), maxf(s.z, 0.001))

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = trigger_size / s
	shape.shape = box
	shape.position.y = (trigger_size.y * 0.5) / s.y   # rests on the floor
	add_child(shape)

	_base_prompt = prompt_text
	_prompt = Label3D.new()
	_prompt.text = prompt_text
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = true
	_prompt.font_size = 48
	_prompt.pixel_size = 0.004 / s.y
	_prompt.outline_size = 10
	_prompt.modulate = Color(0.97, 0.95, 0.90)          # cream text, ink outline — matches the UI
	_prompt.outline_modulate = Color(0.22, 0.13, 0.05)
	_prompt.position.y = prompt_height / s.y
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body
		_prompt.visible = _prompt_allowed()


func _on_body_exited(body: Node3D) -> void:
	if body == _player:
		_player = null
		_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or not _can_interact():
		return
	if event.is_action_pressed("interact"):
		_on_interact()
		get_viewport().set_input_as_handled()


# ---- subclass hooks -----------------------------------------------------------
func _can_interact() -> bool:
	return true

func _prompt_allowed() -> bool:
	return true

func _on_interact() -> void:
	pass


# ---- prompt helpers -----------------------------------------------------------
func player_near() -> bool:
	return _player != null

## The persistent prompt (e.g. "Press E to scavenge (2 left)").
func set_prompt(text: String) -> void:
	_base_prompt = text
	if not _flashing and _prompt != null:
		_prompt.text = text

## Briefly replace the prompt (e.g. "+2 Wood limb"), then fall back to the persistent one.
func flash(text: String, seconds: float = 1.6) -> void:
	_flash_id += 1
	var my_id := _flash_id
	_flashing = true
	_prompt.text = text
	await get_tree().create_timer(seconds).timeout
	if my_id == _flash_id and is_instance_valid(_prompt):
		_flashing = false
		_prompt.text = _base_prompt

## The CraftingSystem autoload, found by path so headless tests can provide one too.
func system() -> Node:
	return get_tree().root.get_node_or_null("CraftingSystem")
