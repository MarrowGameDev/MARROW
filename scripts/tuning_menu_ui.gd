class_name TuningMenuUI
extends CanvasLayer

# Live tuning menu (key 4): walk speed, leap height, and whole-body rotation,
# so posture and gait can be dialled in-game instead of hunting exports.
# Debug-style raw keycode toggle, same precedent as arena_goal_manager's R.
# The testing environment's ranged-enemy spawn moved from 4 to 6 for this key.
# Writes go through the same paths the game uses: speed re-enters
# recalculate_player_stats() so bone bonuses keep stacking on top.

const TOGGLE_KEY := KEY_4

var _player: CharacterBody3D = null
var _animator: Node = null
var _panel: PanelContainer = null
var _rows: Dictionary = {}       # id -> {slider, value_label}
var _defaults: Dictionary = {}   # id -> float, captured at ready
var _was_mouse_captured := false

func _ready() -> void:
	layer = 50
	_player = get_parent() as CharacterBody3D
	if _player != null:
		_animator = _player.get_node_or_null("VisualRoot/ProceduralAnimator")
	_build_ui()
	_capture_defaults()
	_refresh_all()
	_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == TOGGLE_KEY:
		set_open(not _panel.visible)
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_ESCAPE and _panel.visible:
		set_open(false)
		get_viewport().set_input_as_handled()


func set_open(open: bool) -> void:
	_panel.visible = open
	if open:
		_was_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_refresh_all()
	elif _was_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# --- values ---------------------------------------------------------------

func _current_value(id: String) -> float:
	match id:
		"speed":
			return float(_player.base_move_speed) if _player != null else 0.0
		"leap":
			return float(_animator.ik_leap_height) if _animator != null else 0.0
		"reach":
			return float(_animator.ik_stride_reach_boost) if _animator != null else 0.0
		"stance":
			return float(_animator.ik_stance_width) if _animator != null else 0.0
		"rot_x":
			return float(_animator.whole_body_rotation_deg.x) if _animator != null else 0.0
		"rot_y":
			return float(_animator.whole_body_rotation_deg.y) if _animator != null else 0.0
		"rot_z":
			return float(_animator.whole_body_rotation_deg.z) if _animator != null else 0.0
	return 0.0


func _apply_value(id: String, value: float) -> void:
	match id:
		"speed":
			if _player == null:
				return
			_player.base_move_speed = value
			# Feed the stats pipeline, not move_speed directly, so bone
			# bonuses keep stacking exactly as equipment changes do.
			var stats: Node = _player.get("stats_component")
			if stats != null:
				stats.base_move_speed = value
			_player.recalculate_player_stats()
		"leap":
			if _animator != null:
				_animator.ik_leap_height = value
		"reach":
			if _animator != null:
				_animator.ik_stride_reach_boost = value
		"stance":
			if _animator != null:
				_animator.ik_stance_width = value
		"rot_x":
			if _animator != null:
				_animator.whole_body_rotation_deg.x = value
		"rot_y":
			if _animator != null:
				_animator.whole_body_rotation_deg.y = value
		"rot_z":
			if _animator != null:
				_animator.whole_body_rotation_deg.z = value
	_update_value_label(id, value)


func _capture_defaults() -> void:
	for id in _rows:
		_defaults[id] = _current_value(id)


func _reset_defaults() -> void:
	for id in _rows:
		var slider: HSlider = _rows[id]["slider"]
		slider.value = float(_defaults[id])  # value_changed applies it


func _refresh_all() -> void:
	for id in _rows:
		var slider: HSlider = _rows[id]["slider"]
		slider.set_value_no_signal(_current_value(id))
		_update_value_label(id, slider.value)


func _update_value_label(id: String, value: float) -> void:
	var label: Label = _rows[id]["value_label"]
	label.text = "%.2f" % value


# --- UI construction --------------------------------------------------------

func _build_ui() -> void:
	_panel = PanelContainer.new()
	# Lower-left, growing upward from the corner.
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_panel.offset_left = 24.0
	_panel.offset_bottom = -24.0
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# White frame on a solid black background (author-directed).
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	style.set_border_width_all(3)
	style.set_content_margin_all(20.0)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(520.0, 0.0)
	box.add_theme_constant_override("separation", 10)
	_panel.add_child(box)

	var title := Label.new()
	title.text = "Tuning (4 closes)"
	title.add_theme_font_size_override("font_size", 26)
	box.add_child(title)

	_add_row(box, "speed", "Walk speed (m/s)", 0.5, 6.0, 0.05)
	_add_row(box, "leap", "Step jump height (m)", 0.0, 0.35, 0.005)
	_add_row(box, "reach", "Leg forward reach (m)", 0.0, 0.6, 0.01)
	_add_row(box, "stance", "Stance width (m)", 0.0, 0.3, 0.01)
	_add_row(box, "rot_x", "Body pitch X (deg, - = back)", -60.0, 60.0, 0.5)
	_add_row(box, "rot_y", "Body yaw Y (deg)", -180.0, 180.0, 1.0)
	_add_row(box, "rot_z", "Body roll Z (deg)", -60.0, 60.0, 0.5)

	var reset := Button.new()
	reset.text = "Reset to defaults"
	reset.add_theme_font_size_override("font_size", 18)
	reset.pressed.connect(_reset_defaults)
	box.add_child(reset)

	var hint := Label.new()
	hint.text = "Values are live; edit the exports to make them permanent."
	hint.add_theme_font_size_override("font_size", 13)
	box.add_child(hint)


func _add_row(parent: VBoxContainer, id: String, text: String, min_v: float, max_v: float, step: float) -> void:
	var name_label := Label.new()
	name_label.text = text
	name_label.add_theme_font_size_override("font_size", 18)
	parent.add_child(name_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.custom_minimum_size = Vector2(0.0, 30.0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(func(v: float) -> void: _apply_value(id, v))
	row.add_child(slider)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(76.0, 0.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 18)
	row.add_child(value_label)

	_rows[id] = {"slider": slider, "value_label": value_label}
