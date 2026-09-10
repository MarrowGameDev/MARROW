extends Area3D
class_name InteractStation
## Base for world stations the hand walks up to: detects the player (group "player"), floats a
## prompt above itself, and calls _on_interact() when "interact" (E) is pressed in range.
## Sizes are WORLD metres — divided by the node's global scale, so a station stays the same
## real size under a 1x or a 7x-scaled parent. Subclasses: craft_station.gd, scavenge_station.gd.
##
## FOCUS: when the player stands inside several stations at once (a crate beside the bench),
## only the one the CAMERA is looking at is "focused" — it alone shows its prompt and takes E.
## A station with require_camera_facing only ever counts when looked at (the workbench), so
## a neighbour can always be reached by turning toward it.

static var _active: Array = []     # stations the player is currently inside

@export var trigger_size: Vector3 = Vector3(3.0, 2.5, 3.0)
@export var prompt_text: String = "Press E"
@export var prompt_height: float = 1.6
@export var require_camera_facing: bool = false   # only respond when the camera looks at it
@export var facing_threshold: float = 0.45        # cos of the widest accepted angle (~63°)

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


func _exit_tree() -> void:
	_active.erase(self)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body
		if not _active.has(self):
			_active.append(self)
		_update_prompt_visibility()


func _on_body_exited(body: Node3D) -> void:
	if body == _player:
		_player = null
		_active.erase(self)
		_prompt.visible = false


func _process(_delta: float) -> void:
	if _player != null:
		_update_prompt_visibility()   # focus follows the camera, so re-evaluate each frame


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or not _can_interact() or not is_focused():
		return
	if event.is_action_pressed("interact"):
		_on_interact()
		get_viewport().set_input_as_handled()


# ---- focus (which station gets E when several overlap) --------------------------
## How squarely the camera is looking at this station: 1 = dead centre, 0 = 90° off.
func facing_score() -> float:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return 1.0
	var target: Vector3 = global_position + Vector3.UP * (prompt_height * 0.5)
	var dir: Vector3 = (target - cam.global_position).normalized()
	return (-cam.global_transform.basis.z).dot(dir)

func _eligible() -> bool:
	return not require_camera_facing or facing_score() >= facing_threshold

## True if this is the station the player should interact with right now: among all the
## stations the player is inside, the eligible one the camera is looking at most.
func is_focused() -> bool:
	if _player == null:
		return false
	if get_viewport().get_camera_3d() == null:
		return true   # no camera (headless / tests): everything is reachable
	var best: InteractStation = null
	var best_score := -2.0
	for s in _active:
		if not is_instance_valid(s) or s._player == null or not s._eligible():
			continue
		var sc: float = s.facing_score()
		if sc > best_score:
			best_score = sc
			best = s
	return best == self


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

func _update_prompt_visibility() -> void:
	if _prompt != null:
		_prompt.visible = _player != null and _prompt_allowed() and is_focused()

## The persistent prompt (e.g. "Press E to scavenge (2 left)").
func set_prompt(text: String) -> void:
	_base_prompt = text
	if not _flashing and _prompt != null:
		_prompt.text = text

## Briefly replace the prompt (e.g. "Scavenged!"), then fall back to the persistent one.
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
