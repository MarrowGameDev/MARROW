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

	# An empty slot is capacity, not content: it should read as a faint guide
	# and never compete with a real bone for attention. Previously it carried
	# the same border weight as a filled tile plus a bright centre diamond, so
	# a mostly-empty grid looked as busy as a full one. The centre marker is
	# gone entirely and what remains is a barely-there outline.
	var frame := PanelContainer.new()
	frame.position = Vector2.ZERO
	frame.size = slot_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_slot_style(Color(1.0, 1.0, 1.0, 0.04), Color(0.87, 0.63, 0.19, 0.16), 1))
	add_child(frame)


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
	# No drop shadow: the shadow is what made empty capacity read as a card
	# sitting on the panel rather than a hole in it.
	return style
