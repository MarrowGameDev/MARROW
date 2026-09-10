extends Control
class_name CraftingUI
## CRAFTING DASHBOARD — the workbench screen: craft new parts / weapons / armor / torsos and
## IMPROVE the ones you have. Same apothecary theme and atoms as inventory_ui.gd (brown
## line-art on cream) so the two screens read as one system.
##
## Data-driven and decoupled: feed it recipes + the player's item counts, and it emits
## craft_requested / improve_requested. The real crafting system (Phase 1 parts model)
## connects to those signals; the placeholder recipes below define the data contract.
## Opened by craft_station.gd when the hand is at the workbench.

signal craft_requested(recipe_id: String)
signal improve_requested(recipe_id: String)
signal closed

const INK := Color(0.55, 0.34, 0.15)
const INK_FAINT := Color(0.55, 0.34, 0.15, 0.45)
const OK_GREEN := Color(0.30, 0.50, 0.28)
const NO_RED := Color(0.62, 0.22, 0.16)
const PAPER := Color(0.972, 0.957, 0.930)
const SLOT_TEX: Texture2D = preload("res://assets/ui/inv_slot.svg")
const SKULL_TEX: Texture2D = preload("res://assets/ui/inv_skull.svg")
const CATEGORIES := ["PARTS", "WEAPONS", "ARMOR", "TORSOS"]

## Recipe contract (placeholders until the parts data model lands):
##   id, name, category, desc, result, level,
##   ingredients: [{id, name, qty}]   -> needed to CRAFT
##   improve:     [{id, name, qty}]   -> needed to IMPROVE (level + 1)
var recipes: Array = [
	{"id": "wooden_arm", "name": "Wooden Arm", "category": "PARTS", "level": 1,
	 "desc": "A jointed puppet limb. Grants Strike I and a little reach.", "result": "Arm part",
	 "ingredients": [{"id": "wood_limb", "name": "Wood limb", "qty": 2}, {"id": "brass_pin", "name": "Brass pin", "qty": 1}],
	 "improve": [{"id": "wood_limb", "name": "Wood limb", "qty": 1}, {"id": "marrow", "name": "Marrow", "qty": 5}]},
	{"id": "spring_leg", "name": "Spring Leg", "category": "PARTS", "level": 1,
	 "desc": "A coiled leg. Grants Jump I and Speed I.", "result": "Leg part",
	 "ingredients": [{"id": "wood_limb", "name": "Wood limb", "qty": 2}, {"id": "iron_spring", "name": "Iron spring", "qty": 1}],
	 "improve": [{"id": "iron_spring", "name": "Iron spring", "qty": 1}, {"id": "marrow", "name": "Marrow", "qty": 5}]},
	{"id": "jaw_head", "name": "Jaw Head", "category": "PARTS", "level": 1,
	 "desc": "A carved head with a hinged jaw. Grants Bite I.", "result": "Head part",
	 "ingredients": [{"id": "wood_block", "name": "Wood block", "qty": 1}, {"id": "brass_pin", "name": "Brass pin", "qty": 2}],
	 "improve": [{"id": "wood_block", "name": "Wood block", "qty": 1}, {"id": "marrow", "name": "Marrow", "qty": 6}]},
	{"id": "splinter_blade", "name": "Splinter Blade", "category": "WEAPONS", "level": 1,
	 "desc": "A sharpened splinter lashed to a grip. Strike damage up.", "result": "Weapon",
	 "ingredients": [{"id": "wood_limb", "name": "Wood limb", "qty": 1}, {"id": "iron_nail", "name": "Iron nail", "qty": 3}],
	 "improve": [{"id": "iron_nail", "name": "Iron nail", "qty": 3}, {"id": "marrow", "name": "Marrow", "qty": 8}]},
	{"id": "nail_spitter", "name": "Nail Spitter", "category": "WEAPONS", "level": 1,
	 "desc": "A spring-loaded tube. Grants Spit I.", "result": "Weapon",
	 "ingredients": [{"id": "iron_spring", "name": "Iron spring", "qty": 1}, {"id": "iron_nail", "name": "Iron nail", "qty": 5}],
	 "improve": [{"id": "iron_spring", "name": "Iron spring", "qty": 1}, {"id": "marrow", "name": "Marrow", "qty": 8}]},
	{"id": "plank_chest", "name": "Plank Chestplate", "category": "ARMOR", "level": 1,
	 "desc": "Strapped planks over the torso. Health up.", "result": "Armor",
	 "ingredients": [{"id": "wood_block", "name": "Wood block", "qty": 2}, {"id": "rope", "name": "Rope", "qty": 1}],
	 "improve": [{"id": "wood_block", "name": "Wood block", "qty": 1}, {"id": "marrow", "name": "Marrow", "qty": 6}]},
	{"id": "tin_shell", "name": "Tin Shell", "category": "ARMOR", "level": 1,
	 "desc": "Hammered tin plates. Health up, Sneak down.", "result": "Armor",
	 "ingredients": [{"id": "tin_plate", "name": "Tin plate", "qty": 2}, {"id": "brass_pin", "name": "Brass pin", "qty": 2}],
	 "improve": [{"id": "tin_plate", "name": "Tin plate", "qty": 1}, {"id": "marrow", "name": "Marrow", "qty": 8}]},
	{"id": "animal_torso", "name": "Animal Torso", "category": "TORSOS", "level": 1,
	 "desc": "A carved quadruped core: 4 leg sockets, head, tail. Becomes your body.", "result": "Torso core",
	 "ingredients": [{"id": "wood_block", "name": "Wood block", "qty": 3}, {"id": "brass_pin", "name": "Brass pin", "qty": 4}, {"id": "marrow", "name": "Marrow", "qty": 20}],
	 "improve": [{"id": "wood_block", "name": "Wood block", "qty": 2}, {"id": "marrow", "name": "Marrow", "qty": 15}]},
	{"id": "mech_torso", "name": "Mechanical Torso", "category": "TORSOS", "level": 1,
	 "desc": "A tin-and-gear core: 2 wheel mounts, 2 arm mounts, head. Becomes your body.", "result": "Torso core",
	 "ingredients": [{"id": "tin_plate", "name": "Tin plate", "qty": 3}, {"id": "iron_spring", "name": "Iron spring", "qty": 2}, {"id": "marrow", "name": "Marrow", "qty": 25}],
	 "improve": [{"id": "tin_plate", "name": "Tin plate", "qty": 2}, {"id": "marrow", "name": "Marrow", "qty": 15}]},
]
var inventory: Dictionary = {}     # item_id -> count the player is carrying

var _tab := 0
var _selected_id := ""
var _tab_row: HBoxContainer
var _list: VBoxContainer
var _detail: VBoxContainer
var _craft_btn: Button
var _improve_btn: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS     # keeps working while the game is paused underneath
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_background()
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(m, 48)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	margin.add_child(col)
	col.add_child(_title_bar())
	_tab_row = HBoxContainer.new()
	_tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_tab_row.add_theme_constant_override("separation", 14)
	col.add_child(_center(_tab_row))
	col.add_child(_body())
	col.add_child(_bottom_bar())
	_refresh()


# ---- public API ---------------------------------------------------------------
func open() -> void:
	visible = true
	get_tree().paused = true
	_refresh()

func close() -> void:
	get_tree().paused = false
	visible = false
	closed.emit()

func set_inventory(items: Dictionary) -> void:
	inventory = items
	_refresh()

func set_recipes(r: Array) -> void:
	recipes = r
	_selected_id = ""
	_refresh()

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
		_tab = (_tab + 1) % CATEGORIES.size()
		_selected_id = ""
		_refresh()
		get_viewport().set_input_as_handled()


# ---- refresh -------------------------------------------------------------------
func _refresh() -> void:
	if _tab_row == null:
		return
	# tabs
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
	# recipe list for the current tab
	for c in _list.get_children():
		c.queue_free()
	var visible_recipes: Array = recipes.filter(func(r): return r.get("category", "") == CATEGORIES[_tab])
	if visible_recipes.is_empty():
		_list.add_child(_text("Nothing to craft here yet.", 15))
	for r in visible_recipes:
		_list.add_child(_row(r))
	if _selected_id == "" and not visible_recipes.is_empty():
		_selected_id = visible_recipes[0].get("id", "")
	_refresh_detail()


func _row(r: Dictionary) -> Control:
	var b := Button.new()
	b.flat = true
	b.custom_minimum_size = Vector2(0, 64)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var selected: bool = r.get("id", "") == _selected_id
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.add_child(_icon_frame(52))
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_l := _text("%s  ·  Lv %d" % [r.get("name", "?"), int(r.get("level", 1))], 18)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var status := _text("craftable" if _can_afford(r.get("ingredients", [])) else "missing materials", 13)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status.add_theme_color_override("font_color", OK_GREEN if _can_afford(r.get("ingredients", [])) else NO_RED)
	v.add_child(name_l)
	v.add_child(status)
	h.add_child(v)
	b.add_child(h)
	if selected:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(INK.r, INK.g, INK.b, 0.10)
		sb.border_color = INK
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(6)
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
	b.pressed.connect(_on_select.bind(r.get("id", "")))
	return b


func _refresh_detail() -> void:
	for c in _detail.get_children():
		c.queue_free()
	var r := selected_recipe()
	if r.is_empty():
		_detail.add_child(_text("Select a recipe.", 16))
		_craft_btn.disabled = true
		_improve_btn.disabled = true
		return
	_detail.add_child(_center(_icon_frame(96)))
	var title := _text("%s  ·  Lv %d" % [r.get("name", "?"), int(r.get("level", 1))], 24)
	_detail.add_child(title)
	var desc := _text(str(r.get("desc", "")), 14)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 300
	_detail.add_child(desc)
	_detail.add_child(_text("Makes: %s" % r.get("result", ""), 14))
	_detail.add_child(_rule())
	_detail.add_child(_section("TO CRAFT", r.get("ingredients", [])))
	_detail.add_child(_section("TO IMPROVE  →  Lv %d" % (int(r.get("level", 1)) + 1), r.get("improve", [])))
	_craft_btn.disabled = not _can_afford(r.get("ingredients", []))
	_improve_btn.disabled = not _can_afford(r.get("improve", []))


func _section(label: String, req: Array) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	var head := _text(label, 13)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	v.add_child(head)
	for ing in req:
		var have: int = int(inventory.get(ing.get("id", ""), 0))
		var need: int = int(ing.get("qty", 1))
		var line := _text("  %s   %d / %d" % [ing.get("name", "?"), have, need], 15)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line.add_theme_color_override("font_color", OK_GREEN if have >= need else NO_RED)
		v.add_child(line)
	return v


func _can_afford(req: Array) -> bool:
	for ing in req:
		if int(inventory.get(ing.get("id", ""), 0)) < int(ing.get("qty", 1)):
			return false
	return true


# ---- handlers ------------------------------------------------------------------
func _on_tab(i: int) -> void:
	_tab = i
	_selected_id = ""
	_refresh()

func _on_select(id: String) -> void:
	_selected_id = id
	_refresh()

func _on_craft() -> void:
	if _selected_id != "":
		craft_requested.emit(_selected_id)

func _on_improve() -> void:
	if _selected_id != "":
		improve_requested.emit(_selected_id)


# ---- layout pieces -------------------------------------------------------------
func _background() -> void:
	var bg := ColorRect.new()
	bg.color = PAPER
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func _title_bar() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(_center(_skull(40)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.add_child(_rule())
	row.add_child(_text("C R A F T I N G", 40))
	row.add_child(_rule())
	box.add_child(row)
	var sub := _text("the workbench  ·  craft and improve parts, weapons, armor, torsos", 13)
	sub.add_theme_color_override("font_color", INK_FAINT)
	box.add_child(sub)
	return box

func _body() -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 28)
	h.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# left: scrollable recipe list
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)
	h.add_child(scroll)
	# right: detail + actions
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 340
	right.add_theme_constant_override("separation", 12)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 8)
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_detail)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 24)
	_craft_btn = _circle_button("Craft", _on_craft)
	_improve_btn = _circle_button("Improve", _on_improve)
	actions.add_child(_labeled(_craft_btn, "Craft"))
	actions.add_child(_labeled(_improve_btn, "Improve"))
	right.add_child(actions)
	h.add_child(right)
	return h

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
