class_name InventoryEmptySlot
extends Control

var inventory_owner: Node = null
var slot_size: Vector2 = Vector2(96, 86)


func setup(owner_ref: Node, requested_size: Vector2) -> void:
	inventory_owner = owner_ref
	slot_size = requested_size
	custom_minimum_size = slot_size
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	var frame := PanelContainer.new()
	frame.position = Vector2.ZERO
	frame.size = slot_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_slot_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.58), 1))
	add_child(frame)

	var diamond := ColorRect.new()
	diamond.color = Color(0.87, 0.63, 0.19, 0.16)
	diamond.position = Vector2((slot_size.x - 18.0) * 0.5, (slot_size.y - 18.0) * 0.5)
	diamond.size = Vector2(18, 18)
	diamond.rotation = PI / 4.0
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(diamond)

	var diamond_inner := ColorRect.new()
	diamond_inner.color = Color(0.98, 0.975, 0.955, 0.92)
	diamond_inner.position = Vector2((slot_size.x - 10.0) * 0.5, (slot_size.y - 10.0) * 0.5)
	diamond_inner.size = Vector2(10, 10)
	diamond_inner.rotation = PI / 4.0
	diamond_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(diamond_inner)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	var drop: Dictionary = data as Dictionary
	return drop.get("source", "") == "slot" and drop.get("slot", "") != ""


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if inventory_owner == null or not inventory_owner.has_method("unequip_slot"):
		return
	var drop: Dictionary = data as Dictionary
	inventory_owner.unequip_slot(str(drop.get("slot", "")))


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
