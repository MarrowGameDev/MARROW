class_name BoneItemTile
extends Control

# A draggable square for one collected bone, shown in the inventory's item grid.
# Drag it onto its matching body slot to equip. It also accepts a bone dragged
# OUT of a slot (source == "slot") to unequip it.

var bone_id: String = ""
var player: Node = null
var _label: Label = null


# Called right after .new() to fill in the tile's look and data.
func setup(id: String, player_ref: Node) -> void:
	bone_id = id
	player = player_ref
	custom_minimum_size = Vector2(88, 82)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	var frame := PanelContainer.new()
	frame.position = Vector2(0, 0)
	frame.size = Vector2(88, 82)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_tile_style(Color(1.0, 1.0, 1.0, 0.62), Color(0.87, 0.63, 0.19, 0.72), 1))
	add_child(frame)

	# The colored square (matches the bone's color).
	var box := ColorRect.new()
	box.color = BoneDatabase.color(id)
	box.position = Vector2(30, 18)
	box.size = Vector2(28, 28)
	box.rotation = PI / 4.0
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)

	# The bone name under it, with a "(worn)" tag when it's currently equipped.
	_label = Label.new()
	_label.position = Vector2(4, 52)
	_label.size = Vector2(80, 24)
	_label.add_theme_font_size_override("font_size", 9)
	_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
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


# Updates the "(worn)" tag to match the current build (no rebuild needed).
func refresh() -> void:
	if _label == null:
		return
	var worn := ""
	if player != null and player.has_method("has_bone_equipped") and player.has_bone_equipped(bone_id):
		worn = "\n(worn)"
	_label.text = BoneDatabase.display_name(bone_id) + worn


# Godot calls this when a drag begins on the tile. Returning data starts the drag.
func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(_make_preview())
	return {"bone_id": bone_id, "source": "item"}


func _make_preview() -> Control:
	var wrap := Control.new()
	var rect := ColorRect.new()
	rect.color = BoneDatabase.color(bone_id)
	rect.size = Vector2(52, 52)
	rect.position = Vector2(-26, -26) # center the ghost on the cursor
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
	return style


# Accept a bone dragged out of a slot, to unequip it.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("source", "") == "slot"


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if player != null and player.has_method("unequip_slot"):
		player.unequip_slot(data.get("slot", ""))
