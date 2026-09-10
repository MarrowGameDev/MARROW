extends Control
class_name CraftingUI
## CRAFTING DASHBOARD — the workbench screen: craft new parts / weapons / armor / torsos and
## IMPROVE the ones you own. Same apothecary theme and atoms as inventory_ui.gd (brown
## line-art on cream) so the two screens read as one system.
##
## Pure view: the CraftStation feeds it the CraftingSystem's recipes, materials and owned
## items (set_recipes / set_inventory / set_owned) and it emits craft_requested /
## improve_requested. It never mutates game state itself.

signal craft_requested(recipe_id: String)
signal improve_requested(recipe_id: String)
signal selection_changed(recipe: Dictionary)   # the blueprint on the table shows the selected recipe
signal closed

const INK := Color(0.55, 0.34, 0.15)
const INK_FAINT := Color(0.55, 0.34, 0.15, 0.45)
const OK_GREEN := Color(0.30, 0.50, 0.28)
const NO_RED := Color(0.62, 0.22, 0.16)
const PAPER := Color(0.972, 0.957, 0.930)
const SLOT_TEX: Texture2D = preload("res://assets/ui/inv_slot.svg")
const SKULL_TEX: Texture2D = preload("res://assets/ui/inv_skull.svg")
const CATEGORIES := ["PARTS", "WEAPONS", "ARMOR", "TORSOS"]
const MAX_LEVEL := 5

## The dashboard is a SIDE PANEL on the right; the rest of the screen shows the bench camera.
@export var panel_fraction: float = 0.42

var recipes: Array = []              # from CraftingSystem.recipes
var inventory: Dictionary = {}       # material id -> count
var owned: Array = []                # crafted items {uid, recipe_id, name, category, level}
var material_names: Dictionary = {}  # material id -> display name

var _prev_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED   # restored on close
var _panel: Control                    # right side: the book page with recipes (parts / weapons / armor / torsos)
var _page: Control                     # the page content that flips when you change section
var _page_label: Label                 # "PARTS · page 1 / 4"
var _flipping := false
var _materials_panel: PanelContainer   # bottom-left: the player's materials
var _materials_box: VBoxContainer
var _tab := 0
var _selected_id := ""
var _tab_row: HBoxContainer
var _list: VBoxContainer
var _detail: VBoxContainer
var _craft_btn: Button
var _improve_btn: Button
var _status: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS     # keeps working while the game is paused underneath
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP    # the whole screen owns the mouse while open (transparent left side included)
	# the visible dashboard lives in a panel on the right; the bench view shows to its left
	_panel = Control.new()
	_panel.anchor_left = 1.0 - panel_fraction
	_panel.anchor_right = 1.0
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 1.0
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	_background()
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(m, 28)
	margin.add_theme_constant_override("margin_left", 48)   # room for the spine
	_panel.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	margin.add_child(col)
	col.add_child(_title_bar())
	_tab_row = HBoxContainer.new()
	_tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_tab_row.add_theme_constant_override("separation", 14)
	col.add_child(_center(_tab_row))
	_page = _body()
	col.add_child(_page)
	col.add_child(_bottom_bar())
	_build_materials_panel()   # top-left tally of what the player is carrying
	_refresh()


# ---- public API ---------------------------------------------------------------
func open() -> void:
	visible = true
	get_tree().paused = true
	# free the cursor: the third-person camera keeps it captured during play
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh()

func close() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = _prev_mouse_mode   # hand the cursor back to the camera
	closed.emit()

func set_recipes(r: Array) -> void:
	recipes = r
	_selected_id = ""
	_refresh()

func set_inventory(items: Dictionary) -> void:
	inventory = items
	_refresh()

func set_owned(items: Array) -> void:
	owned = items
	_refresh()

## One-line feedback under the buttons ("Crafted Wooden Arm!" / "Not enough materials.").
func show_message(text: String, ok: bool) -> void:
	if _status == null:
		return
	_status.text = text
	_status.add_theme_color_override("font_color", OK_GREEN if ok else NO_RED)

func selected_recipe() -> Dictionary:
	for r in recipes:
		if r.get("id", "") == _selected_id:
			return r
	return {}


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_focus_next"):
		_on_tab((_tab + 1) % CATEGORIES.size())
		get_viewport().set_input_as_handled()


# ---- state helpers -------------------------------------------------------------
func _owned_for(recipe_id: String) -> Dictionary:
	var best: Dictionary = {}
	for it in owned:
		if it.get("recipe_id", "") == recipe_id and int(it.get("level", 1)) > int(best.get("level", 0)):
			best = it
	return best

func _owned_count(recipe_id: String) -> int:
	var n := 0
	for it in owned:
		if it.get("recipe_id", "") == recipe_id:
			n += 1
	return n

func _mat_name(id: String) -> String:
	return str(material_names.get(id, id.capitalize()))

func _can_afford(req: Array) -> bool:
	for ing in req:
		if int(inventory.get(str(ing.get("id", "")), 0)) < int(ing.get("qty", 1)):
			return false
	return true


# ---- refresh -------------------------------------------------------------------
func _refresh() -> void:
	if _tab_row == null:
		return
	for c in _tab_row.get_children():
		c.queue_free()
	for i in CATEGORIES.size():
		if i > 0:
			_tab_row.add_child(_text("♦", 14))
		var b := Button.new()
		b.text = CATEGORIES[i]
		b.flat = true
		b.add_theme_font_size_override("font_size", 16)
		b.add_theme_color_override("font_color", INK if i == _tab else INK_FAINT)
		b.add_theme_color_override("font_hover_color", INK)
		b.custom_minimum_size.x = 110
		b.pressed.connect(_on_tab.bind(i))
		_tab_row.add_child(b)
	for c in _list.get_children():
		c.queue_free()
	var visible_recipes: Array = recipes.filter(func(r): return r.get("category", "") == CATEGORIES[_tab])
	if visible_recipes.is_empty():
		_list.add_child(_text("Nothing to craft here yet.", 15))
	for r in visible_recipes:
		_list.add_child(_row(r))
	if _selected_id == "" and not visible_recipes.is_empty():
		_selected_id = visible_recipes[0].get("id", "")
	if _page_label != null:
		_page_label.text = "%s  ·  page %d / %d" % [CATEGORIES[_tab], _tab + 1, CATEGORIES.size()]
	_refresh_detail()
	_refresh_materials()


func _row(r: Dictionary) -> Control:
	var id: String = str(r.get("id", ""))
	var b := Button.new()
	b.flat = true
	b.custom_minimum_size = Vector2(0, 64)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.add_child(_icon_frame(52))
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var it := _owned_for(id)
	var title: String = str(r.get("name", "?")) + ("  ·  Lv %d" % int(it.get("level", 1)) if not it.is_empty() else "")
	var name_l := _text(title, 18)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var ok := _can_afford(r.get("ingredients", []))
	var status := _text("craftable" if ok else "missing materials", 13)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status.add_theme_color_override("font_color", OK_GREEN if ok else NO_RED)
	v.add_child(name_l)
	v.add_child(status)
	h.add_child(v)
	b.add_child(h)
	if id == _selected_id:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(INK.r, INK.g, INK.b, 0.10)
		sb.border_color = INK
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(6)
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
	b.pressed.connect(_on_select.bind(id))
	return b


func _refresh_detail() -> void:
	for c in _detail.get_children():
		c.queue_free()
	var r := selected_recipe()
	selection_changed.emit(r)
	if r.is_empty():
		_detail.add_child(_text("Select a recipe.", 16))
		_craft_btn.disabled = true
		_improve_btn.disabled = true
		return
	var id: String = str(r.get("id", ""))
	var it := _owned_for(id)
	var level: int = int(it.get("level", 1))
	_detail.add_child(_center(_icon_frame(96)))
	_detail.add_child(_text(str(r.get("name", "?")), 24))
	var desc := _text(str(r.get("desc", "")), 14)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 300
	_detail.add_child(desc)
	_detail.add_child(_text("Makes: %s" % r.get("result", ""), 14))
	var own_l := _text("Owned: Lv %d  (×%d)" % [level, _owned_count(id)] if not it.is_empty() else "Not crafted yet", 14)
	own_l.add_theme_color_override("font_color", OK_GREEN if not it.is_empty() else INK_FAINT)
	_detail.add_child(own_l)
	_detail.add_child(_rule())
	_detail.add_child(_section("TO CRAFT", r.get("ingredients", [])))
	if it.is_empty():
		_detail.add_child(_section("TO IMPROVE  (craft one first)", r.get("improve", [])))
	elif level >= MAX_LEVEL:
		_detail.add_child(_text("Max level reached.", 13))
	else:
		_detail.add_child(_section("TO IMPROVE  →  Lv %d" % (level + 1), r.get("improve", [])))
	_craft_btn.disabled = not _can_afford(r.get("ingredients", []))
	_improve_btn.disabled = it.is_empty() or level >= MAX_LEVEL or not _can_afford(r.get("improve", []))


func _section(label: String, req: Array) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	var head := _text(label, 13)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	v.add_child(head)
	for ing in req:
		var mid: String = str(ing.get("id", ""))
		var have: int = int(inventory.get(mid, 0))
		var need: int = int(ing.get("qty", 1))
		var line := _text("  %s   %d / %d" % [_mat_name(mid), have, need], 15)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line.add_theme_color_override("font_color", OK_GREEN if have >= need else NO_RED)
		v.add_child(line)
	return v


# ---- handlers ------------------------------------------------------------------
## Turn the page: the content folds toward the spine, the new section is laid out, and it opens.
func _on_tab(i: int) -> void:
	if i == _tab or _flipping or _page == null:
		return
	_flipping = true
	_page.pivot_offset = Vector2(0.0, _page.size.y * 0.5)   # hinge on the spine
	var tw := create_tween()
	tw.tween_property(_page, "scale:x", 0.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		_tab = i
		_selected_id = ""
		show_message("", true)
		_refresh())
	tw.tween_property(_page, "scale:x", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: _flipping = false)

func _on_select(id: String) -> void:
	_selected_id = id
	_refresh()

func _on_craft() -> void:
	if _selected_id != "":
		craft_requested.emit(_selected_id)

func _on_improve() -> void:
	if _selected_id != "":
		improve_requested.emit(_selected_id)


# ---- materials tally (top-left) ---------------------------------------------------
func _build_materials_panel() -> void:
	_materials_panel = PanelContainer.new()
	_materials_panel.anchor_left = 0.0
	_materials_panel.anchor_right = 0.0
	_materials_panel.anchor_top = 1.0            # bottom-left, growing upward
	_materials_panel.anchor_bottom = 1.0
	_materials_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_materials_panel.offset_left = 24.0
	_materials_panel.offset_top = -24.0
	_materials_panel.offset_bottom = -24.0
	_materials_panel.custom_minimum_size = Vector2(300, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(PAPER.r, PAPER.g, PAPER.b, 0.9)
	sb.border_color = INK
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 12.0
	sb.content_margin_bottom = 12.0
	_materials_panel.add_theme_stylebox_override("panel", sb)
	_materials_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_theme_constant_override("separation", 10)
	head.add_child(_vcenter(_skull(22)))
	head.add_child(_text("M A T E R I A L S", 16))
	v.add_child(head)
	v.add_child(_rule())
	_materials_box = VBoxContainer.new()
	_materials_box.add_theme_constant_override("separation", 4)
	v.add_child(_materials_box)
	_materials_panel.add_child(v)
	add_child(_materials_panel)


## One row per known material: white-grey dot, name, xN — owned first, the rest dimmed at x0.
func _refresh_materials() -> void:
	if _materials_box == null:
		return
	for c in _materials_box.get_children():
		c.queue_free()
	var ids: Array = material_names.keys()
	for id in inventory:
		if not ids.has(id):
			ids.append(id)
	ids.sort_custom(func(a, b): return int(inventory.get(a, 0)) > int(inventory.get(b, 0)))
	if ids.is_empty():
		_materials_box.add_child(_text("No materials yet — scavenge the piles.", 13))
		return
	for id in ids:
		var count: int = int(inventory.get(id, 0))
		var owned := count > 0
		var ink: Color = INK if owned else INK_FAINT
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(14, 14)
		var dsb := StyleBoxFlat.new()
		dsb.bg_color = Color(0.86, 0.86, 0.82, 1.0 if owned else 0.35)
		dsb.border_color = INK
		dsb.set_border_width_all(1)
		dsb.set_corner_radius_all(7)
		dot.add_theme_stylebox_override("panel", dsb)
		row.add_child(_vcenter(dot))
		var name_l := _text(_mat_name(str(id)), 15)
		name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.add_theme_color_override("font_color", ink)
		row.add_child(name_l)
		var cnt := _text("×%d" % count, 15)
		cnt.add_theme_color_override("font_color", ink)
		row.add_child(cnt)
		_materials_box.add_child(row)


func _vcenter(c: Control) -> Control:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(c)
	return v


# ---- layout pieces -------------------------------------------------------------
func _background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(PAPER.r, PAPER.g, PAPER.b, 0.9)   # slightly translucent paper, panel only
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	# STOP, not IGNORE: swallow clicks on empty space so the camera controller (which
	# re-captures the mouse on any unhandled click) never sees them while we're open
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_child(bg)
	# the book's spine along the panel's left edge: a darker paper band, an ink line, stitches
	var spine := ColorRect.new()
	spine.color = Color(0.86, 0.79, 0.66, 0.95)
	spine.anchor_top = 0.0
	spine.anchor_bottom = 1.0
	spine.offset_right = 16.0
	spine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(spine)
	var line := ColorRect.new()
	line.color = INK
	line.anchor_top = 0.0
	line.anchor_bottom = 1.0
	line.offset_left = 16.0
	line.offset_right = 18.0
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(line)
	for i in 7:                                          # stitch marks down the spine
		var st := ColorRect.new()
		st.color = INK_FAINT
		st.anchor_top = (i + 1) / 8.0
		st.anchor_bottom = (i + 1) / 8.0
		st.offset_left = 4.0
		st.offset_right = 12.0
		st.offset_top = -1.0
		st.offset_bottom = 1.0
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_panel.add_child(st)

func _title_bar() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(_center(_skull(32)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.add_child(_rule())
	row.add_child(_text("C R A F T I N G", 30))
	row.add_child(_rule())
	box.add_child(row)
	var sub := _text("the workbench  ·  craft and improve parts, weapons, armor, torsos", 12)
	sub.add_theme_color_override("font_color", INK_FAINT)
	box.add_child(sub)
	return box

func _body() -> Control:
	# narrow panel: recipe list on top, the selected recipe's detail + actions below
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)
	v.add_child(scroll)
	v.add_child(_rule())
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 6)
	_detail.custom_minimum_size.y = 230
	v.add_child(_detail)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 24)
	_craft_btn = _circle_button("Craft", _on_craft)
	_improve_btn = _circle_button("Improve", _on_improve)
	actions.add_child(_labeled(_craft_btn, "Craft"))
	actions.add_child(_labeled(_improve_btn, "Improve"))
	v.add_child(actions)
	_status = _text("", 14)
	_status.custom_minimum_size.y = 22
	v.add_child(_status)
	return v

func _bottom_bar() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	var rule := HBoxContainer.new()
	rule.alignment = BoxContainer.ALIGNMENT_CENTER
	rule.add_theme_constant_override("separation", 16)
	rule.add_child(_rule())
	rule.add_child(_skull(30))
	rule.add_child(_rule())
	box.add_child(rule)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 28)
	_page_label = _text("", 13)                          # "PARTS · page 1 / 4"
	_page_label.add_theme_color_override("font_color", INK_FAINT)
	_page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.add_child(_page_label)
	row.add_child(_labeled(_circle_button("Back", close), "Back  (Esc)"))
	box.add_child(row)
	return box


# ---- atoms (shared look with inventory_ui.gd) ----------------------------------
func _circle_button(text: String, on_pressed: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(46, 46)
	b.flat = true
	b.tooltip_text = text
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = INK
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(23)
	b.add_theme_stylebox_override("normal", sb)
	var hover := sb.duplicate()
	hover.bg_color = Color(INK.r, INK.g, INK.b, 0.12)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	var dis := sb.duplicate()
	dis.border_color = INK_FAINT
	b.add_theme_stylebox_override("disabled", dis)
	b.pressed.connect(on_pressed)
	return b

func _labeled(btn: Button, label: String) -> Control:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	v.add_child(_center(btn))
	v.add_child(_center(_text(label, 13)))
	return v

func _icon_frame(size: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(size, size)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fr := TextureRect.new()
	fr.texture = SLOT_TEX
	fr.set_anchors_preset(Control.PRESET_FULL_RECT)
	fr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fr.modulate = INK
	fr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(fr)
	return c

func _skull(size: int) -> Control:
	var tr := TextureRect.new()
	tr.texture = SKULL_TEX
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(size, size)
	tr.modulate = INK
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr

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
	var r := ColorRect.new()
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
