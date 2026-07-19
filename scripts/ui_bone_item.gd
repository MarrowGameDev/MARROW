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
var _stack_badge: PanelContainer = null
var _frame: PanelContainer = null
var _selected: bool = false

const _BORDER_IDLE := Color(0.87, 0.63, 0.19, 0.78)
const _BORDER_SELECTED := Color(0.0, 0.60, 0.62, 1.0)
const _BG_IDLE := Color(1.0, 1.0, 1.0, 0.58)
const _BG_SELECTED := Color(0.86, 0.98, 0.98, 0.92)


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
	_frame = frame
	frame.position = Vector2(0, 0)
	frame.size = tile_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_tile_style(_BG_IDLE, _BORDER_IDLE, 1))
	add_child(frame)

	# Full name is always reachable on hover even though the card shows the
	# abbreviated one.
	tooltip_text = BoneRulesService.display_name_with_slot(id)

	# The top rule doubles as the quality accent: it is the one always-visible
	# mark of a piece's tier, so a Pristine and a Frail arm never look alike
	# even before reading the label.
	var top_rule := ColorRect.new()
	top_rule.color = BoneQualityService.color_for(BoneInstanceService.quality_id_of(id))
	top_rule.position = Vector2(pad + inner_width * 0.10, pad + maxf(1.0, tile_size.y * 0.03))
	top_rule.size = Vector2(inner_width * 0.80, maxf(2.0, tile_size.y * 0.035))
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_rule)

	# Non-colour quality indicator: one pip per rung of the ladder, so Frail
	# (1) through Pristine (5) are countable. The accent bar and the tier name
	# already carry the same information -- this third channel is what makes
	# the tiers distinguishable without relying on colour at all.
	var quality_id := BoneInstanceService.quality_id_of(id)
	var pip_count: int = BoneQualityService.rank_for(quality_id) + 1
	var pip_size: float = clampf(min_side * 0.055, 3.0, 6.0)
	var pip_gap: float = pip_size * 0.7
	var pip_total: float = float(pip_count) * pip_size + float(pip_count - 1) * pip_gap
	var pip_y: float = pad + maxf(1.0, tile_size.y * 0.03) + maxf(2.0, tile_size.y * 0.035) + pip_size * 0.6
	for i in range(pip_count):
		var pip := ColorRect.new()
		pip.color = BoneQualityService.color_for(quality_id)
		pip.size = Vector2(pip_size, pip_size)
		pip.position = Vector2(tile_size.x * 0.5 - pip_total * 0.5 + float(i) * (pip_size + pip_gap), pip_y)
		pip.rotation = PI / 4.0
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pip)

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

	# Stack count sits in the BOTTOM-RIGHT corner as a filled chip. It used to
	# be pale text floating over the artwork, where it competed with the
	# diamond and was easy to miss; a chip reads as a count at a glance.
	var badge_size := Vector2(maxf(20.0, inner_width * 0.30), maxf(14.0, tile_size.y * 0.17))
	_stack_badge = PanelContainer.new()
	_stack_badge.size = badge_size
	_stack_badge.position = Vector2(tile_size.x - pad - badge_size.x, tile_size.y - pad - badge_size.y)
	_stack_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack_badge.add_theme_stylebox_override("panel", _make_tile_style(Color(0.05, 0.35, 0.38, 0.92), Color(0.99, 0.97, 0.90, 0.55), 1))
	add_child(_stack_badge)

	_stack_label = Label.new()
	_stack_label.add_theme_font_size_override("font_size", clampi(int(min_side * 0.13), 9, 15))
	_stack_label.add_theme_color_override("font_color", Color(0.99, 0.97, 0.90, 1.0))
	_stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack_badge.add_child(_stack_label)

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

	# The badge occupies the bottom-right corner, so the slot caption gives up
	# that width instead of drawing underneath it.
	var caption_width: float = inner_width
	if stack_count > 1:
		caption_width = maxf(24.0, inner_width - badge_size.x - 4.0)
	_slot_label = Label.new()
	_slot_label.position = Vector2(pad, tile_size.y - slot_height - pad * 0.5)
	_slot_label.size = Vector2(caption_width, slot_height)
	# Quality as text next to the slot, so the accent colour is never the only
	# way to tell tiers apart.
	var slot_text := EquipmentRulesService.slot_display_name(EquipmentRulesService.slot_for_bone(id))
	if slot_text == "":
		slot_text = "Piece"
	_slot_label.text = "%s  ·  %s" % [BoneQualityService.display_name_for(BoneInstanceService.quality_id_of(id)), slot_text]
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


func _gui_input(event: InputEvent) -> void:
	# Left press selects. Godot only turns a press into a drag once the cursor
	# moves past its threshold, so selecting here does not interfere with
	# dragging the same card out to a slot.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player != null and player.has_method("select_bone"):
			player.call("select_bone", bone_id)


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
	# Abbreviated on the card; the full name lives in the tooltip and in the
	# details panel, so nothing is lost to the shortening.
	_label.text = BoneRulesService.short_display_name(bone_id)
	tooltip_text = BoneRulesService.display_name_with_slot(bone_id)
	if _stack_label != null:
		_stack_label.text = "x" + str(stack_count)
	if _stack_badge != null:
		_stack_badge.visible = stack_count > 1


# Painted by PlayerInventoryUI when the player picks a card.
func set_selected(value: bool) -> void:
	if _selected == value:
		return
	_selected = value
	_repaint()


func _repaint() -> void:
	if _frame == null:
		return
	var background := _BG_SELECTED if _selected else _BG_IDLE
	# Quality-tinted border, blended toward the panel's own accent so it stays
	# part of the parchment rather than five clashing outlines. Selection still
	# wins: knowing what you picked matters more than the tier.
	var quality_border: Color = _BORDER_IDLE.lerp(
		BoneQualityService.color_for(BoneInstanceService.quality_id_of(bone_id)), 0.55
	)
	quality_border.a = _BORDER_IDLE.a
	var border := _BORDER_SELECTED if _selected else quality_border
	# A selected card carries a heavier border plus a glow, so it is legible
	# as "the one I picked" even next to identically coloured siblings.
	var width: int = 3 if _selected else 1
	var style := _make_tile_style(background, border, width)
	if _selected:
		style.shadow_color = Color(0.0, 0.78, 0.78, 0.45)
		style.shadow_size = 8
		style.shadow_offset = Vector2.ZERO
	_frame.add_theme_stylebox_override("panel", style)


# Godot calls this when a drag begins on the tile. Returning data starts the drag.
func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(_make_preview())
	if player != null and player.has_method("begin_bone_drag"):
		player.call("begin_bone_drag", bone_id)
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
