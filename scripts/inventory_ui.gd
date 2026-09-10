extends Control

# INVENTORY UI — skeleton / apothecary theme (brown line-art on cream).
# Built in code so your traced SVG atoms drop straight in. Everything is tinted from ONE
# brown so hover/selected/disabled states are trivial. The ARM icon is your real vectored
# asset; every other decorative piece (slot frame, diamonds, skull, dividers, LEG/TORSO/HEAD
# icons, nav boxes) is a clean PLACEHOLDER — each marked "SWAP:" so you can replace it with
# its SVG when traced (TextureRect for icons, NinePatchRect for the slot frame).

const INK := Color(0.55, 0.34, 0.15)            # theme brown — line / text
const INK_FAINT := Color(0.55, 0.34, 0.15, 0.45)
const PAPER := Color(0.972, 0.957, 0.930)       # cream page

const ARM_ICON: Texture2D = preload("res://assets/ui/inv_arm.svg")
const SLOT_TEX: Texture2D = preload("res://assets/ui/inv_slot.svg")
const SKULL_TEX: Texture2D = preload("res://assets/ui/inv_skull.svg")

const CATEGORIES := ["ARMS", "LEGS", "TORSOS", "HEADS"]
const GRID_COLS := 6
const GRID_ROWS := 3
const SLOT := 96
const ICON := 60

var _selected_tab := 0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_background()

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(m, 48)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 22)
	margin.add_child(col)

	col.add_child(_title_bar())
	col.add_child(_tabs())
	col.add_child(_grid())
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	col.add_child(_bottom_bar())


# ---- background --------------------------------------------------------------
func _background() -> void:
	var bg := ColorRect.new()
	bg.color = PAPER
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)


# ---- title: [line] ☠ I N V E N T O R Y ☠ [line] -----------------------------
func _title_bar() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(_center(_skull(40)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.add_child(_rule())
	row.add_child(_text("I N V E N T O R Y", 40))
	row.add_child(_rule())
	box.add_child(row)
	return box


# ---- category tabs: icon + label, diamond-separated --------------------------
func _tabs() -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	row.add_child(_nav_box())   # SWAP: prev nav ornament
	for i in CATEGORIES.size():
		if i > 0:
			row.add_child(_diamond(14))   # SWAP: diamond separator SVG
		row.add_child(_tab(i))
	row.add_child(_nav_box())   # SWAP: next nav ornament
	return _center(row)


func _tab(idx: int) -> Control:
	var tab := VBoxContainer.new()
	tab.alignment = BoxContainer.ALIGNMENT_CENTER
	tab.add_theme_constant_override("separation", 4)
	tab.custom_minimum_size.x = 96
	# icon: ARMS uses the real vectored asset; the rest are placeholders until traced
	if CATEGORIES[idx] == "ARMS":
		var tr := TextureRect.new()
		tr.texture = ARM_ICON
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(ICON, ICON)
		tr.modulate = INK
		tab.add_child(_center(tr))
	else:
		tab.add_child(_center(_icon_placeholder(CATEGORIES[idx][0])))   # SWAP: LEG/TORSO/HEAD icon SVG
	tab.add_child(_center(_text(CATEGORIES[idx], 15)))
	var faint := idx != _selected_tab
	tab.modulate = INK_FAINT if faint else Color.WHITE
	return tab


# ---- item grid: 6 x 3 slots (data-driven; empty for now) ---------------------
func _grid() -> Control:
	var grid := GridContainer.new()
	grid.columns = GRID_COLS
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for i in GRID_COLS * GRID_ROWS:
		grid.add_child(_slot())
	var left := HBoxContainer.new()   # keep the grid left-aligned like the mockup
	left.add_child(grid)
	return left


func _slot() -> Control:
	# the vectored slot frame (with its own centre sparkle); items get added on top later
	var slot := Control.new()
	slot.custom_minimum_size = Vector2(SLOT, SLOT)
	var frame := TextureRect.new()
	frame.texture = SLOT_TEX
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.modulate = INK
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(frame)
	return slot


# ---- bottom rule + Sort / Filter / Select / Back -----------------------------
func _bottom_bar() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	var rule := HBoxContainer.new()
	rule.alignment = BoxContainer.ALIGNMENT_CENTER
	rule.add_theme_constant_override("separation", 16)
	rule.add_child(_rule())
	rule.add_child(_skull(34))
	rule.add_child(_rule())
	box.add_child(rule)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 28)
	for name in ["Sort", "Filter", "Select", "Back"]:
		actions.add_child(_circle_button(name))
	box.add_child(actions)
	return box


func _circle_button(text: String) -> Control:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	var b := Button.new()                 # SWAP: button_circle SVG as the normal stylebox
	b.custom_minimum_size = Vector2(44, 44)
	b.flat = true
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = INK
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(22)
	b.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate()
	hover.bg_color = Color(INK.r, INK.g, INK.b, 0.12)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.pressed.connect(func(): print("[inventory] ", text, " pressed"))
	v.add_child(_center(b))
	v.add_child(_center(_text(text, 15)))
	return v


# ---- placeholder atoms (all SWAP for traced SVGs) ----------------------------
func _icon_placeholder(letter: String) -> Control:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(ICON, ICON)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = INK
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	p.add_theme_stylebox_override("panel", sb)
	var l := _text(letter, 22)
	l.set_anchors_preset(Control.PRESET_CENTER)
	p.add_child(l)
	return p


func _nav_box() -> Control:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(48, 34)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = INK
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	p.add_theme_stylebox_override("panel", sb)
	return _center(p)


func _skull(size: int) -> Control:
	var tr := TextureRect.new()
	tr.texture = SKULL_TEX
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(size, size)
	tr.modulate = INK
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


func _diamond(size: int) -> Control:
	return _text("♦", size)   # ◆ placeholder for the sparkle / separator


# ---- tiny UI helpers ---------------------------------------------------------
func _text(s: String, size: int) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", INK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _rule() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.custom_minimum_size = Vector2(40, 20)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := ColorRect.new()               # SWAP: 3-piece divider (endcaps + tileable line)
	r.color = INK
	r.anchor_left = 0.0; r.anchor_right = 1.0
	r.anchor_top = 0.5; r.anchor_bottom = 0.5
	r.offset_top = -1.0; r.offset_bottom = 1.0
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(r)
	return c


func _center(child: Control) -> Control:
	var cc := CenterContainer.new()
	cc.add_child(child)
	return cc
