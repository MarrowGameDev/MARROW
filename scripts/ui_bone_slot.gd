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
var _diamond_back: ColorRect
var _slot_size: Vector2 = Vector2(82, 80)
var _frame: PanelContainer
var _unequip_button: Button = null
var _highlighted: bool = false
var _drag_state: String = ""
const _FRAME_BORDER_DEFAULT := Color(0.87, 0.63, 0.19, 0.68)
const _FRAME_BORDER_VALID := Color(0.34, 0.78, 0.36, 0.85)
const _FRAME_BORDER_INVALID := Color(0.82, 0.24, 0.20, 0.85)
# Gold: this slot accepts the piece currently being dragged or selected.
const _FRAME_BORDER_TARGET := Color(0.95, 0.72, 0.16, 1.0)


func setup(slot: String, short: String, player_ref: Node, requested_size: Vector2 = Vector2(96, 96)) -> void:
	slot_name = slot
	short_name = short
	player = player_ref
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	_frame = PanelContainer.new()
	_frame.position = Vector2(0, 0)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_theme_stylebox_override("panel", _make_slot_style(Color(1.0, 1.0, 1.0, 0.22), _FRAME_BORDER_DEFAULT, 1))
	add_child(_frame)

	_slot_label = Label.new()
	_slot_label.text = short_name
	_slot_label.add_theme_color_override("font_color", Color(0.44, 0.32, 0.12, 1.0))
	_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_slot_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_slot_label.clip_text = true
	_slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_slot_label)

	_diamond_back = ColorRect.new()
	_diamond_back.rotation = PI / 4.0
	_diamond_back.color = Color(0.87, 0.63, 0.19, 0.14)
	_diamond_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_diamond_back)

	_box = ColorRect.new()
	_box.rotation = PI / 4.0
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)

	_label = Label.new()
	_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Without a line cap a two-line bone name overflows the label's rect and
	# draws on top of whatever sits below it. Labels do not clip by default.
	_label.max_lines_visible = 2
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_label.clip_text = true
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	# Compact "remove" affordance for the worn piece. An 88px slot cannot hold
	# the word "Unequip" without clipping it -- which is the exact failure this
	# pass is meant to fix -- so the glyph carries the label in its tooltip.
	_unequip_button = Button.new()
	_unequip_button.text = "✕"
	_unequip_button.flat = true
	_unequip_button.focus_mode = Control.FOCUS_NONE
	_unequip_button.process_mode = Node.PROCESS_MODE_ALWAYS
	_unequip_button.tooltip_text = "Unequip (or right-click the slot)"
	_unequip_button.add_theme_color_override("font_color", Color(0.55, 0.20, 0.16, 0.95))
	_unequip_button.add_theme_color_override("font_hover_color", Color(0.82, 0.24, 0.20, 1.0))
	_unequip_button.pressed.connect(_on_unequip_pressed)
	_unequip_button.visible = false
	add_child(_unequip_button)

	resize(requested_size)
	refresh()

	# Hovering a filled slot shows the worn bone's stats. Connected here in
	# setup(), never in resize(), which runs again on every layout pass.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# Re-lay-out every child for a new slot size. The paper doll calls this on each
# responsive pass instead of setting `scale`, so the control's input rect always
# matches what is drawn and neighbouring slots can never overlap.
func resize(target_size: Vector2) -> void:
	_slot_size = Vector2(maxf(24.0, target_size.x), maxf(24.0, target_size.y))
	custom_minimum_size = _slot_size
	size = _slot_size
	scale = Vector2.ONE
	if _frame == null:
		return

	_frame.size = _slot_size
	var pad: float = maxf(3.0, _slot_size.y * 0.05)
	var min_side: float = minf(_slot_size.x, _slot_size.y)
	var inner_width: float = maxf(8.0, _slot_size.x - (pad * 2.0))

	# Three stacked bands: slot name, diamond art, worn bone name. Reserving the
	# text bands up front is what keeps the name from colliding with the label.
	var top_height: float = maxf(12.0, _slot_size.y * 0.20)
	var bottom_height: float = maxf(15.0, _slot_size.y * 0.30)
	var art_top: float = pad + top_height
	var art_height: float = maxf(8.0, _slot_size.y - bottom_height - art_top - pad)

	_slot_label.position = Vector2(pad, pad)
	_slot_label.size = Vector2(inner_width, top_height)
	_slot_label.add_theme_font_size_override("font_size", clampi(int(min_side * 0.13), 9, 16))

	_place_diamond(_diamond_back, Vector2(_slot_size.x * 0.5, art_top + art_height * 0.5), minf(inner_width, art_height) * 0.62)
	_place_diamond(_box, Vector2(_slot_size.x * 0.5, art_top + art_height * 0.5), minf(inner_width, art_height) * 0.40)

	_label.position = Vector2(pad, _slot_size.y - bottom_height - pad)
	_label.size = Vector2(inner_width, bottom_height)
	_label.add_theme_font_size_override("font_size", clampi(int(min_side * 0.115), 8, 14))

	if _unequip_button != null:
		var button_side: float = clampf(min_side * 0.22, 14.0, 22.0)
		_unequip_button.size = Vector2(button_side, button_side)
		_unequip_button.position = Vector2(_slot_size.x - button_side - pad, pad)
		_unequip_button.add_theme_font_size_override("font_size", clampi(int(button_side * 0.62), 9, 14))


# A ColorRect rotated 45 degrees turns about its own origin, so its visual
# centre lands at position + (0, side * sqrt(2) / 2). Solve for the position
# that puts that centre exactly where we want it.
func _place_diamond(rect: ColorRect, centre: Vector2, bounding_side: float) -> void:
	if rect == null:
		return
	var side: float = maxf(2.0, bounding_side / sqrt(2.0))
	rect.size = Vector2(side, side)
	rect.position = centre - Vector2(0.0, side * sqrt(2.0) * 0.5)


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
		# Abbreviated in the slot, full name on hover -- the slot is far too
		# narrow for names like "Gorilla Right Arm Bone".
		_label.text = BoneRulesService.short_display_name(bone_id)
		tooltip_text = BoneRulesService.display_name_with_slot(bone_id)
	else:
		_box.color = Color(0.87, 0.63, 0.19, 0.28)
		_label.text = "Empty"
		tooltip_text = short_name + " slot (empty)"
	if _unequip_button != null:
		_unequip_button.visible = bone_id != ""


func _on_unequip_pressed() -> void:
	if player != null and player.has_method("unequip_slot"):
		player.unequip_slot(slot_name)


# Painted when a bone is selected in the grid: shows where it could go.
func set_highlighted(value: bool) -> void:
	if _highlighted == value:
		return
	_highlighted = value
	_repaint()


# "" = no drag, "compatible" / "incompatible" while one is in flight.
func set_drag_state(state: String) -> void:
	if _drag_state == state:
		return
	_drag_state = state
	_repaint()


func _repaint() -> void:
	if _frame == null:
		return
	var border := _FRAME_BORDER_DEFAULT
	var background := Color(1.0, 1.0, 1.0, 0.22)
	var width := 1
	var alpha := 1.0
	# A border alone was almost invisible against the parchment panel, so a
	# targeted slot also gets a warm fill. Both cues change together.
	if _drag_state == "compatible":
		border = _FRAME_BORDER_TARGET
		background = Color(1.0, 0.85, 0.45, 0.55)
		width = 4
	elif _drag_state == "incompatible":
		border = _FRAME_BORDER_INVALID
		# Attenuated rather than hidden: the player still needs to see the
		# slot exists, just not consider it a target.
		alpha = 0.35
	elif _highlighted:
		border = _FRAME_BORDER_TARGET
		background = Color(1.0, 0.87, 0.52, 0.40)
		width = 3
	var style := _make_slot_style(background, border, width)
	if _drag_state == "compatible" or _highlighted:
		style.shadow_color = Color(0.95, 0.72, 0.16, 0.45)
		style.shadow_size = 6
		style.shadow_offset = Vector2.ZERO
	_frame.add_theme_stylebox_override("panel", style)
	modulate = Color(1.0, 1.0, 1.0, alpha)


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
	if player != null and player.has_method("begin_bone_drag"):
		player.call("begin_bone_drag", bone_id)
	return {"bone_id": bone_id, "source": "slot", "slot": slot_name}


# Accept a bone only if it belongs to THIS slot. Also paints the frame
# border green/red while the drag hovers this slot, so the player sees
# whether dropping here would work before releasing.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("bone_id"):
		return false
	# Border colour is painted centrally for every slot when the drag starts
	# (see PlayerInventoryUI.begin_bone_drag), so this only answers the
	# question Godot is actually asking.
	return EquipmentRulesService.can_equip_bone_in_slot(str(data["bone_id"]), slot_name)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if player != null and player.has_method("equip_bone_in_slot"):
		player.equip_bone_in_slot(str(data["bone_id"]), slot_name)


# _can_drop_data stops being called once the cursor leaves this control
# without a drop, so the border would otherwise stay tinted from the last
# hover. NOTIFICATION_DRAG_END fires on every widget when any drag ends
# anywhere, which resets it even if the piece was dropped elsewhere.
func _notification(what: int) -> void:
	# Fires on every Control when any drag ends, including drops that landed
	# somewhere else or were cancelled. Routed through the owner so all slots
	# and the details panel are reset together; calling it once per slot is
	# harmless because end_bone_drag is idempotent.
	if what == NOTIFICATION_DRAG_END:
		if player != null and player.has_method("end_bone_drag"):
			player.call("end_bone_drag")


# Right-click clears this slot. Deferred: unequipping refreshes the paper
# doll, and freeing widgets while the viewport is dispatching this event makes
# it re-deliver to whatever ends up under the cursor (see the tile's handler).
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		accept_event()
		if player != null and player.has_method("unequip_slot"):
			player.call_deferred("unequip_slot", slot_name)


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
