extends Control

const DEMO_SCENE_PATH: String = "res://scenes/main.tscn"
const TESTING_SCENE_PATH: String = "res://scenes/testing_environment.tscn"
const DUMMY_TESTING_SCENE_PATH: String = "res://scenes/dummy_testing_environment.tscn"


func _ready() -> void:
	get_tree().paused = false
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
	panel.offset_top = -230.0
	panel.offset_right = 260.0
	panel.offset_bottom = 230.0
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

	# NEW RUN always starts from a clean world. CONTINUE is the only path that
	# loads a save, and it is disabled outright when there is nothing to load --
	# a button that silently does nothing is worse than one that is greyed out.
	layout.add_child(_make_menu_button("NEW RUN", Callable(self, "_open_demo")))

	var continue_button := _make_menu_button("CONTINUE", Callable(self, "_continue_demo"))
	continue_button.disabled = not SaveService.has_save()
	if continue_button.disabled:
		continue_button.tooltip_text = "No saved run yet. Use SAVE in-game first."
	layout.add_child(continue_button)

	layout.add_child(_make_menu_button("TESTING ENVIRONMENT", Callable(self, "_open_testing_environment")))
	layout.add_child(_make_menu_button("DUMMY TESTING", Callable(self, "_open_dummy_testing_environment")))

	var hint := Label.new()
	hint.text = "Progress is not saved automatically. Use SAVE in-game, then CONTINUE here.\nUse testing rooms for camera, enemy, movement, animation, damage, and rig checks."
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
	# Explicitly clears the request, so a CONTINUE that was clicked and then
	# backed out of cannot leak into a fresh run.
	SaveCoordinator.load_requested_on_start = false
	get_tree().paused = false
	get_tree().change_scene_to_file(DEMO_SCENE_PATH)


func _continue_demo() -> void:
	# The flag is static because change_scene_to_file frees this menu; the
	# SaveCoordinator in the demo scene reads and clears it.
	SaveCoordinator.load_requested_on_start = true
	get_tree().paused = false
	get_tree().change_scene_to_file(DEMO_SCENE_PATH)


func _open_testing_environment() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TESTING_SCENE_PATH)


func _open_dummy_testing_environment() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(DUMMY_TESTING_SCENE_PATH)
