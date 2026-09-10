extends Area3D
class_name CraftStation
## Drop-in workbench trigger. Put this as a CHILD of the workbench (puppet_workshop) and size
## the box to cover the bench. When the player (group "player") is inside and presses
## "interact" (E), it opens the crafting dashboard on its own CanvasLayer (the UI pauses the
## game underneath). A floating prompt shows while the player is in range. Same drop-in
## pattern as torch_fire.tscn, so main.tscn never needs hand-editing.

const CRAFTING_UI: PackedScene = preload("res://scenes/crafting_ui.tscn")

@export var trigger_size: Vector3 = Vector3(3.0, 2.5, 3.0)   # size to cover the bench
@export var prompt_text: String = "Press E to craft"
@export var prompt_height: float = 1.6

var _player: Node3D = null
var _prompt: Label3D
var _layer: CanvasLayer = null
var _ui: CraftingUI = null


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = trigger_size
	shape.shape = box
	shape.position.y = trigger_size.y * 0.5   # box rests on the floor rather than centring on it
	add_child(shape)

	_prompt = Label3D.new()
	_prompt.text = prompt_text
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = true
	_prompt.font_size = 48
	_prompt.pixel_size = 0.004
	_prompt.outline_size = 10
	_prompt.modulate = Color(0.97, 0.95, 0.90)          # cream text, ink outline — matches the UI
	_prompt.outline_modulate = Color(0.22, 0.13, 0.05)
	_prompt.position.y = prompt_height
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body
		_prompt.visible = _ui == null


func _on_body_exited(body: Node3D) -> void:
	if body == _player:
		_player = null
		_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or _ui != null:
		return
	if event.is_action_pressed("interact"):
		open_menu()
		get_viewport().set_input_as_handled()


func open_menu() -> void:
	if _ui != null:
		return
	_layer = CanvasLayer.new()
	_layer.layer = 50
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_layer)
	_ui = CRAFTING_UI.instantiate() as CraftingUI
	_layer.add_child(_ui)
	_ui.closed.connect(_on_menu_closed)
	# the real crafting system plugs in here (Phase 1 parts model); for now just log the intent
	_ui.craft_requested.connect(func(id: String): print("[craft_station] craft requested: ", id))
	_ui.improve_requested.connect(func(id: String): print("[craft_station] improve requested: ", id))
	_ui.open()
	_prompt.visible = false


func _on_menu_closed() -> void:
	if _layer != null:
		_layer.queue_free()
	_layer = null
	_ui = null
	_prompt.visible = _player != null
