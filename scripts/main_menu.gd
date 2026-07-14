extends Control

const DEMO_SCENE_PATH: String = "res://scenes/main.tscn"
const TESTING_SCENE_PATH: String = "res://scenes/testing_environment.tscn"


func _ready() -> void:
	_build_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _build_menu() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	backdrop.color = Color(0.04, 0.055, 0.06, 1.0)
	add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "MenuPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260.0
	panel.offset_top = -190.0
	panel.offset_right = 260.0
	panel.offset_bottom = 190.0
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "MARROW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Demo tools and playable build"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	layout.add_child(subtitle)

	layout.add_child(_make_menu_button("PLAY DEMO", Callable(self, "_open_demo")))
	layout.add_child(_make_menu_button("TESTING ENVIRONMENT", Callable(self, "_open_testing_environment")))

	var hint := Label.new()
	hint.text = "Use the testing environment for camera, enemy, movement, animation, and rig checks."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(hint)


func _make_menu_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 56.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(callback)
	return button


func _open_demo() -> void:
	get_tree().change_scene_to_file(DEMO_SCENE_PATH)


func _open_testing_environment() -> void:
	get_tree().change_scene_to_file(TESTING_SCENE_PATH)
