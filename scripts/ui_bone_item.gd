class_name BoneItemTile
extends Control

# A draggable square for one collected bone, shown in the inventory's item grid.
# Drag it onto its matching body slot to equip. It also accepts a bone dragged
# OUT of a slot (source == "slot") to unequip it.

var bone_id: String = ""
var player: Node = null
var _label: Label = null
var _slot_label: Label = null


# Called right after .new() to fill in the tile's look and data.
func setup(id: String, player_ref: Node) -> void:
	bone_id = id
	player = player_ref
	var tile_size := Vector2(96, 86)
	if player != null and player.has_method("get_inventory_tile_size"):
		var requested_size: Variant = player.call("get_inventory_tile_size")
		if typeof(requested_size) == TYPE_VECTOR2:
			tile_size = requested_size
	var x_scale := tile_size.x / 96.0
	var y_scale := tile_size.y / 86.0
	custom_minimum_size = tile_size
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	var frame := PanelContainer.new()
	frame.position = Vector2(0, 0)
	frame.size = tile_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_tile_style(Color(1.0, 1.0, 1.0, 0.58), Color(0.87, 0.63, 0.19, 0.78), 1))
	add_child(frame)

	var top_rule := ColorRect.new()
	top_rule.color = Color(0.87, 0.63, 0.19, 0.36)
	top_rule.position = Vector2(12.0 * x_scale, 10.0 * y_scale)
	top_rule.size = Vector2(72.0 * x_scale, 1)
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_rule)

	# The colored square (matches the bone's color).
	var glow := ColorRect.new()
	glow.color = BoneRulesService.color_for(id).lightened(0.18)
	glow.position = Vector2(31.0 * x_scale, 17.0 * y_scale)
	glow.size = Vector2(34.0 * x_scale, 34.0 * y_scale)
	glow.rotation = PI / 4.0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)

	var core := ColorRect.new()
	core.color = BoneRulesService.color_for(id)
	core.position = Vector2(35.0 * x_scale, 21.0 * y_scale)
	core.size = Vector2(26.0 * x_scale, 26.0 * y_scale)
	core.rotation = PI / 4.0
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(core)

	# The bone name under it, with a "(worn)" tag when it's currently equipped.
	_label = Label.new()
	_label.position = Vector2(5.0 * x_scale, 50.0 * y_scale)
	_label.size = Vector2(86.0 * x_scale, 22.0 * y_scale)
	_label.add_theme_font_size_override("font_size", maxi(10, int(10.0 * minf(x_scale, y_scale))))
	_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	_slot_label = Label.new()
	_slot_label.position = Vector2(5.0 * x_scale, 72.0 * y_scale)
	_slot_label.size = Vector2(86.0 * x_scale, 12.0 * y_scale)
	var slot_text := EquipmentRulesService.slot_display_name(EquipmentRulesService.slot_for_bone(id))
	if slot_text == "":
		slot_text = "Piece"
	_slot_label.text = slot_text
	_slot_label.add_theme_font_size_override("font_size", maxi(8, int(8.0 * minf(x_scale, y_scale))))
	_slot_label.add_theme_color_override("font_color", Color(0.44, 0.32, 0.12, 0.95))
	_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_slot_label)
	refresh()

	# Hovering shows this bone's stats in the inventory's info area.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


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
