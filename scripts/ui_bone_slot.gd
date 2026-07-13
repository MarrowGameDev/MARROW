class_name BoneSlotWidget
extends Control

# One equip slot on the inventory paper-doll. Drop a matching bone here to equip
# it; drag the worn bone out (or right-click) to unequip.

var slot_name: String = ""
var short_name: String = ""
var player: Node = null

var _box: ColorRect
var _label: Label


func setup(slot: String, short: String, player_ref: Node) -> void:
	slot_name = slot
	short_name = short
	player = player_ref
	custom_minimum_size = Vector2(74, 72)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	var frame := PanelContainer.new()
	frame.position = Vector2(0, 0)
	frame.size = Vector2(74, 72)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_slot_style(Color(1.0, 1.0, 1.0, 0.20), Color(0.87, 0.63, 0.19, 0.35), 1))
	add_child(frame)

	_box = ColorRect.new()
	_box.position = Vector2(26, 12)
	_box.size = Vector2(22, 22)
	_box.rotation = PI / 4.0
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)

	_label = Label.new()
	_label.position = Vector2(2, 44)
	_label.size = Vector2(70, 26)
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	refresh()

	# Hovering a filled slot shows the worn bone's stats.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if player == null or not player.has_method("show_bone_info"):
		return
	var equipped: Dictionary = player.equipped
	if equipped.has(slot_name):
		player.show_bone_info(equipped[slot_name])


func _on_mouse_exited() -> void:
	if player != null and player.has_method("clear_bone_info"):
		player.clear_bone_info()


# Repaint the square to the worn bone's color, or dark grey when empty.
func refresh() -> void:
	var equipped: Dictionary = {}
	if player != null:
		equipped = player.equipped

	if equipped.has(slot_name):
		var bone_id: String = equipped[slot_name]
		_box.color = BoneDatabase.color(bone_id)
		_label.text = short_name + "\n" + BoneDatabase.display_name(bone_id)
	else:
		_box.color = Color(1.0, 0.94, 0.68, 0.0)
		_label.text = ""


# Drag the worn bone OUT of this slot.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if player == null:
		return null
	var equipped: Dictionary = player.equipped
	if not equipped.has(slot_name):
		return null

	var bone_id: String = equipped[slot_name]
	var wrap := Control.new()
	var rect := ColorRect.new()
	rect.color = BoneDatabase.color(bone_id)
	rect.size = Vector2(48, 48)
	rect.position = Vector2(-24, -24)
	wrap.add_child(rect)
	set_drag_preview(wrap)
	return {"bone_id": bone_id, "source": "slot", "slot": slot_name}


# Accept a bone only if it belongs to THIS slot.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("bone_id"):
		return false
	return BoneDatabase.slot(data["bone_id"]) == slot_name


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if player != null and player.has_method("equip_bone"):
		player.equip_bone(data["bone_id"])


# Right-click clears this slot.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if player != null and player.has_method("unequip_slot"):
			player.unequip_slot(slot_name)


func _make_slot_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	return style
