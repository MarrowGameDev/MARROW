class_name BoneSlotWidget
extends Control

# One equip slot on the inventory paper-doll. Drop a matching bone here to equip
# it; drag the worn bone out (or right-click) to unequip.

var slot_name: String = ""
var short_name: String = ""
var player: Node = null

var _box: ColorRect
var _label: Label
var _slot_label: Label
var _slot_size: Vector2 = Vector2(82, 80)
var _frame: PanelContainer
const _FRAME_BORDER_DEFAULT := Color(0.87, 0.63, 0.19, 0.68)
const _FRAME_BORDER_VALID := Color(0.34, 0.78, 0.36, 0.85)
const _FRAME_BORDER_INVALID := Color(0.82, 0.24, 0.20, 0.85)


func setup(slot: String, short: String, player_ref: Node, requested_size: Vector2 = Vector2(96, 96)) -> void:
	slot_name = slot
	short_name = short
	player = player_ref
	_slot_size = requested_size
	var x_scale := _slot_size.x / 82.0
	var y_scale := _slot_size.y / 80.0
	var min_scale := minf(x_scale, y_scale)
	custom_minimum_size = _slot_size
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	_frame = PanelContainer.new()
	_frame.position = Vector2(0, 0)
	_frame.size = _slot_size
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_theme_stylebox_override("panel", _make_slot_style(Color(1.0, 1.0, 1.0, 0.22), _FRAME_BORDER_DEFAULT, 1))
	add_child(_frame)

	_slot_label = Label.new()
	_slot_label.position = Vector2(4.0 * x_scale, 5.0 * y_scale)
	_slot_label.size = Vector2(74.0 * x_scale, 17.0 * y_scale)
	_slot_label.text = short_name
	_slot_label.add_theme_font_size_override("font_size", maxi(11, int(10.0 * min_scale)))
	_slot_label.add_theme_color_override("font_color", Color(0.44, 0.32, 0.12, 1.0))
	_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_slot_label)

	var diamond_back := ColorRect.new()
	diamond_back.position = Vector2(30.0 * x_scale, 25.0 * y_scale)
	diamond_back.size = Vector2(22.0 * min_scale, 22.0 * min_scale)
	diamond_back.rotation = PI / 4.0
	diamond_back.color = Color(0.87, 0.63, 0.19, 0.14)
	diamond_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(diamond_back)

	_box = ColorRect.new()
	_box.position = Vector2(34.0 * x_scale, 29.0 * y_scale)
	_box.size = Vector2(14.0 * min_scale, 14.0 * min_scale)
	_box.rotation = PI / 4.0
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)

	_label = Label.new()
	_label.position = Vector2(6.0 * x_scale, 56.0 * y_scale)
	_label.size = Vector2(70.0 * x_scale, 28.0 * y_scale)
	_label.add_theme_font_size_override("font_size", maxi(10, int(9.0 * min_scale)))
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
	var bone_id := _equipped_bone_id()
	if bone_id != "":
		player.show_bone_info(bone_id)


func _on_mouse_exited() -> void:
	if player != null and player.has_method("clear_bone_info"):
		player.clear_bone_info()


# Repaint the square to the worn bone's color, or dark grey when empty.
func refresh() -> void:
	var bone_id := _equipped_bone_id()
	if bone_id != "":
		_box.color = BoneRulesService.color_for(bone_id)
		_label.text = BoneRulesService.display_name_with_slot(bone_id)
	else:
		_box.color = Color(0.87, 0.63, 0.19, 0.28)
		_label.text = "Empty"


# Drag the worn bone OUT of this slot.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if player == null:
		return null
	var bone_id := _equipped_bone_id()
	if bone_id == "":
		return null

	var wrap := Control.new()
	var rect := ColorRect.new()
	rect.color = BoneRulesService.color_for(bone_id)
	var preview_size: float = clampf(minf(_slot_size.x, _slot_size.y) * 0.56, 48.0, 64.0)
	rect.size = Vector2(preview_size, preview_size)
	rect.position = Vector2(-preview_size * 0.5, -preview_size * 0.5)
	rect.rotation = PI / 4.0
	wrap.add_child(rect)
	set_drag_preview(wrap)
	return {"bone_id": bone_id, "source": "slot", "slot": slot_name}


# Accept a bone only if it belongs to THIS slot. Also paints the frame
# border green/red while the drag hovers this slot, so the player sees
# whether dropping here would work before releasing.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("bone_id"):
		_set_frame_border(_FRAME_BORDER_DEFAULT)
		return false
	var valid := EquipmentRulesService.can_equip_bone_in_slot(str(data["bone_id"]), slot_name)
	_set_frame_border(_FRAME_BORDER_VALID if valid else _FRAME_BORDER_INVALID)
	return valid


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_set_frame_border(_FRAME_BORDER_DEFAULT)
	if player != null and player.has_method("equip_bone_in_slot"):
		player.equip_bone_in_slot(str(data["bone_id"]), slot_name)


# _can_drop_data stops being called once the cursor leaves this control
# without a drop, so the border would otherwise stay tinted from the last
# hover. NOTIFICATION_DRAG_END fires on every widget when any drag ends
# anywhere, which resets it even if the piece was dropped elsewhere.
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_set_frame_border(_FRAME_BORDER_DEFAULT)


func _set_frame_border(color: Color) -> void:
	if _frame == null:
		return
	var style := _frame.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null or style.border_color == color:
		return
	style.border_color = color


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
	style.shadow_color = Color(0.21, 0.13, 0.04, 0.10)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 2)
	return style


func _equipped_bone_id() -> String:
	if player == null:
		return ""
	if player.has_method("get_equipped_bone_for_slot"):
		return str(player.get_equipped_bone_for_slot(slot_name))
	var equipped_value: Variant = player.get("equipped")
	if typeof(equipped_value) != TYPE_DICTIONARY:
		return ""
	var equipped: Dictionary = equipped_value as Dictionary
	return str(equipped.get(slot_name, ""))
