class_name BoneItemTile
extends Control

# A draggable square for one collected bone, shown in the inventory's item grid.
# Drag it onto its matching body slot to equip. It also accepts a bone dragged
# OUT of a slot (source == "slot") to unequip it.

var bone_id: String = ""
var player: Node = null
var stack_count: int = 1
var _label: Label = null
var _slot_label: Label = null
var _stack_label: Label = null


# Called right after .new() to fill in the tile's look and data.
func setup(id: String, player_ref: Node, quantity: int = 1) -> void:
	bone_id = id
	player = player_ref
	stack_count = maxi(1, quantity)
	var tile_size := Vector2(96, 86)
	if player != null and player.has_method("get_inventory_tile_size"):
		var requested_size: Variant = player.call("get_inventory_tile_size")
		if typeof(requested_size) == TYPE_VECTOR2:
			tile_size = requested_size
	tile_size = Vector2(maxf(32.0, tile_size.x), maxf(32.0, tile_size.y))
	custom_minimum_size = tile_size
	size = tile_size
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Bands are measured from the tile's real size instead of scaling a fixed
	# 96x86 design, so the name and the slot caption keep their own room at
	# every resolution rather than drawing over each other.
	var pad: float = maxf(3.0, tile_size.y * 0.05)
	var min_side: float = minf(tile_size.x, tile_size.y)
	var inner_width: float = maxf(8.0, tile_size.x - (pad * 2.0))
	var name_height: float = maxf(16.0, tile_size.y * 0.26)
	var slot_height: float = maxf(10.0, tile_size.y * 0.15)
	var art_top: float = pad + maxf(2.0, tile_size.y * 0.06)
	var art_height: float = maxf(8.0, tile_size.y - name_height - slot_height - art_top - pad)

	var frame := PanelContainer.new()
	frame.position = Vector2(0, 0)
	frame.size = tile_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_tile_style(Color(1.0, 1.0, 1.0, 0.58), Color(0.87, 0.63, 0.19, 0.78), 1))
	add_child(frame)

	var top_rule := ColorRect.new()
	top_rule.color = Color(0.87, 0.63, 0.19, 0.36)
	top_rule.position = Vector2(pad + inner_width * 0.10, pad + maxf(1.0, tile_size.y * 0.03))
	top_rule.size = Vector2(inner_width * 0.80, 1)
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_rule)

	var art_centre := Vector2(tile_size.x * 0.5, art_top + art_height * 0.5)
	var art_span: float = minf(inner_width, art_height)

	# The colored square (matches the bone's color).
	var glow := ColorRect.new()
	glow.color = BoneRulesService.color_for(id).lightened(0.18)
	glow.rotation = PI / 4.0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	_place_diamond(glow, art_centre, art_span * 0.92)

	var core := ColorRect.new()
	core.color = BoneRulesService.color_for(id)
	core.rotation = PI / 4.0
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(core)
	_place_diamond(core, art_centre, art_span * 0.70)

	_stack_label = Label.new()
	_stack_label.size = Vector2(maxf(16.0, inner_width * 0.30), maxf(12.0, art_height * 0.34))
	_stack_label.position = Vector2(tile_size.x - pad - _stack_label.size.x, art_top)
	_stack_label.add_theme_font_size_override("font_size", clampi(int(min_side * 0.13), 9, 15))
	_stack_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.72, 1.0))
	_stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stack_label)

	# The bone name under it.
	_label = Label.new()
	_label.position = Vector2(pad, tile_size.y - slot_height - name_height - pad * 0.5)
	_label.size = Vector2(inner_width, name_height)
	_label.add_theme_font_size_override("font_size", clampi(int(min_side * 0.125), 9, 15))
	_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# A name like "Enemy Left Arm Bone" wraps to more lines than the band is
	# tall; labels do not clip by default, so without this cap the overflow
	# drew straight over the slot caption below.
	_label.max_lines_visible = 2
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_label.clip_text = true
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	_slot_label = Label.new()
	_slot_label.position = Vector2(pad, tile_size.y - slot_height - pad * 0.5)
	_slot_label.size = Vector2(inner_width, slot_height)
	var slot_text := EquipmentRulesService.slot_display_name(EquipmentRulesService.slot_for_bone(id))
	if slot_text == "":
		slot_text = "Piece"
	_slot_label.text = slot_text
	_slot_label.add_theme_font_size_override("font_size", clampi(int(min_side * 0.10), 8, 13))
	_slot_label.add_theme_color_override("font_color", Color(0.44, 0.32, 0.12, 0.95))
	_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_slot_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_slot_label.clip_text = true
	_slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_slot_label)
	refresh()

	# Hovering shows this bone's stats in the inventory's info area.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# A ColorRect rotated 45 degrees turns about its own origin, so its visual
# centre lands at position + (0, side * sqrt(2) / 2). Solve for the position
# that puts that centre exactly where we want it.
func _place_diamond(rect: ColorRect, centre: Vector2, bounding_side: float) -> void:
	var side: float = maxf(2.0, bounding_side / sqrt(2.0))
	rect.size = Vector2(side, side)
	rect.position = centre - Vector2(0.0, side * sqrt(2.0) * 0.5)


func _on_mouse_entered() -> void:
	if player != null and player.has_method("show_bone_info"):
		player.show_bone_info(bone_id)


func _on_mouse_exited() -> void:
	if player != null and player.has_method("clear_bone_info"):
		player.clear_bone_info()


# Inventory tiles represent carried copies. Equipped copies are filtered out by
# PlayerInventoryUI, so duplicate items can stay stackable without false labels.
func refresh() -> void:
	if _label == null:
		return
	_label.text = BoneRulesService.display_name_with_slot(bone_id)
	if _stack_label != null:
		_stack_label.text = "x" + str(stack_count) if stack_count > 1 else ""
		_stack_label.visible = stack_count > 1


# Godot calls this when a drag begins on the tile. Returning data starts the drag.
func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(_make_preview())
	return {"bone_id": bone_id, "source": "item"}


func _make_preview() -> Control:
	var wrap := Control.new()
	var rect := ColorRect.new()
	rect.color = BoneRulesService.color_for(bone_id)
	rect.size = Vector2(50, 50)
	rect.position = Vector2(-25, -25) # center the ghost on the cursor
	rect.rotation = PI / 4.0
	wrap.add_child(rect)
	return wrap


func _make_tile_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
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
	style.shadow_color = Color(0.21, 0.13, 0.04, 0.12)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 2)
	return style


# Accept a bone dragged out of a slot, to unequip it.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("source", "") == "slot"


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if player != null and player.has_method("unequip_slot"):
		player.unequip_slot(str(data.get("slot", "")))
