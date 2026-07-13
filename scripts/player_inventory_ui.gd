class_name PlayerInventoryUI
extends Node

const CONTROL_SETTINGS_PATH := "user://control_settings.cfg"
const CONTROL_BINDINGS: Array = [
	{"action": "move_forward", "label": "Move Forward"},
	{"action": "move_back", "label": "Move Back"},
	{"action": "move_left", "label": "Move Left"},
	{"action": "move_right", "label": "Move Right"},
	{"action": "jump", "label": "Jump"},
	{"action": "sprint", "label": "Sprint"},
	{"action": "attack", "label": "Attack"},
	{"action": "inventory", "label": "Inventory"},
	{"action": "interact", "label": "Interact"},
	{"action": "equip", "label": "Equip Next"},
	{"action": "stealth_finish", "label": "Stealth Finish"}
]

var player: Node = null
var equipped: Dictionary:
	get:
		return _equipment_state()

var inventory_root: Control = null
var inventory_label: Label = null
var hover_info_label: Label = null
var inventory_status_label: Label = null
var inventory_category: String = "all"
var inventory_tab_buttons: Dictionary = {}
var inventory_safe_area: MarginContainer = null
var inventory_panel: PanelContainer = null
var inventory_panel_margin: MarginContainer = null
var inventory_scroll: ScrollContainer = null
var inventory_content_root: VBoxContainer = null
var inventory_tabs_container: HBoxContainer = null
var inventory_body: HBoxContainer = null
var inventory_left_panel: VBoxContainer = null
var inventory_grid_panel: PanelContainer = null
var inventory_grid_margin: MarginContainer = null
var inventory_sort_label: Label = null
var inventory_right_panel: VBoxContainer = null
var inventory_preview_panel: PanelContainer = null
var inventory_preview_area: MarginContainer = null
var inventory_preview_container: SubViewportContainer = null
var inventory_preview_viewport: SubViewport = null
var inventory_details_panel: PanelContainer = null
var inventory_paper_doll: Control = null
var inventory_footer: HBoxContainer = null
var settings_panel: ScrollContainer = null
var settings_box_panel: PanelContainer = null
var settings_box_margin: MarginContainer = null
var settings_controls_list: VBoxContainer = null
var settings_title_label: Label = null
var settings_status_label: Label = null
var settings_reset_button: Button = null
var control_rows: Dictionary = {}
var control_labels: Dictionary = {}
var control_buttons: Dictionary = {}
var rebinding_action: String = ""
var rebinding_button: Button = null
var inventory_preview_rig: ModularSkeletonRig = null
var inventory_preview_root: Node3D = null
var slot_widgets: Dictionary = {}
var items_grid: GridContainer = null
var inventory_item_tile_size: Vector2 = Vector2(96, 86)
var inventory_empty_slot_size: Vector2 = Vector2(96, 86)


func setup(owner_player: Node) -> void:
	player = owner_player
	name = "PlayerInventoryUI"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_control_settings()
	_build_inventory_ui()
	get_viewport().size_changed.connect(Callable(self, "_apply_inventory_responsive_layout"))
	rebuild_item_tiles()
	update_inventory_ui()
	_apply_inventory_responsive_layout()


func handle_input(event: InputEvent) -> void:
	if rebinding_action == "":
		return
	if not _is_bindable_control_event(event):
		return

	get_viewport().set_input_as_handled()
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_cancel_rebinding()
			return

	_apply_control_binding(rebinding_action, event)


func set_open(open: bool) -> void:
	if inventory_root == null:
		return
	if open:
		_apply_inventory_responsive_layout()
		_refresh_inventory_mode()
		_refresh_control_buttons()
		update_inventory_ui()
		sync_preview()
	inventory_root.visible = open


func cycle_category() -> void:
	var categories: Array[String] = ["all", "right_arm", "legs", "body", "head", "settings"]
	var index: int = categories.find(inventory_category)
	if index < 0:
		index = 0
	index = (index + 1) % categories.size()
	_select_inventory_category(categories[index])


func notify_inventory_changed() -> void:
	rebuild_item_tiles()
	update_inventory_ui()


func notify_equipment_changed() -> void:
	update_inventory_ui()
	sync_preview()
	call_deferred("rebuild_item_tiles")


func get_inventory_tile_size() -> Vector2:
	return inventory_item_tile_size


func has_bone_equipped(bone_id: String) -> bool:
	return player != null and bool(player.call("has_bone_equipped", bone_id))


func equip_bone(bone_id: String) -> void:
	if player != null:
		player.call("equip_bone", bone_id)


func unequip_slot(slot: String) -> void:
	if player != null:
		player.call("unequip_slot", slot)


func show_bone_info(bone_id: String) -> void:
	if hover_info_label == null:
		return
	var text := BoneDatabase.quality(bone_id) + " " + BoneDatabase.display_name(bone_id) + "  [slot: " + BoneDatabase.slot(bone_id) + "]\n"
	text += BoneDatabase.effect_text(bone_id)
	text += BoneDatabase.description(bone_id)
	hover_info_label.text = text


func clear_bone_info() -> void:
	if hover_info_label != null:
		hover_info_label.text = "Select an item to view details."


func _build_inventory_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "InventoryCanvas"
	canvas.layer = 5
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	inventory_root = Control.new()
	inventory_root.name = "InventoryRoot"
	inventory_root.anchor_right = 1.0
	inventory_root.anchor_bottom = 1.0
	inventory_root.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_root.visible = false
	canvas.add_child(inventory_root)
	inventory_root.add_child(_build_inventory_blur_layer())

	inventory_safe_area = MarginContainer.new()
	inventory_safe_area.anchor_right = 1.0
	inventory_safe_area.anchor_bottom = 1.0
	inventory_safe_area.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_safe_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_root.add_child(inventory_safe_area)

	inventory_panel = PanelContainer.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(0.99, 0.985, 0.955, 0.86), Color(0.87, 0.63, 0.19, 0.96), 2, 0))
	inventory_safe_area.add_child(inventory_panel)

	inventory_panel_margin = MarginContainer.new()
	inventory_panel_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_panel_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_panel.add_child(inventory_panel_margin)

	inventory_scroll = ScrollContainer.new()
	inventory_scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_panel_margin.add_child(inventory_scroll)

	inventory_content_root = VBoxContainer.new()
	inventory_content_root.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_content_root.add_theme_constant_override("separation", 9)
	inventory_scroll.add_child(inventory_content_root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	inventory_content_root.add_child(header)
	header.add_child(_make_rule())

	var title := Label.new()
	title.text = "Inventory"
	title.custom_minimum_size = Vector2(260, 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	header.add_child(title)
	header.add_child(_make_rule())

	inventory_status_label = Label.new()
	inventory_status_label.custom_minimum_size = Vector2(140, 48)
	inventory_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	inventory_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_status_label.add_theme_font_size_override("font_size", 20)
	inventory_status_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	header.add_child(inventory_status_label)

	_build_inventory_tabs(inventory_content_root)

	var divider := ColorRect.new()
	divider.color = Color(0.87, 0.63, 0.19, 0.70)
	divider.custom_minimum_size = Vector2(0, 1)
	inventory_content_root.add_child(divider)

	inventory_body = HBoxContainer.new()
	inventory_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_body.add_theme_constant_override("separation", 18)
	inventory_content_root.add_child(inventory_body)

	inventory_left_panel = VBoxContainer.new()
	inventory_left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_left_panel.add_theme_constant_override("separation", 8)
	inventory_body.add_child(inventory_left_panel)

	inventory_grid_panel = PanelContainer.new()
	inventory_grid_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_grid_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_grid_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.28), Color(0.87, 0.63, 0.19, 0.75), 1, 0))
	inventory_left_panel.add_child(inventory_grid_panel)

	inventory_grid_margin = MarginContainer.new()
	inventory_grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_grid_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_grid_panel.add_child(inventory_grid_margin)

	items_grid = GridContainer.new()
	items_grid.process_mode = Node.PROCESS_MODE_ALWAYS
	items_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	items_grid.columns = 6
	inventory_grid_margin.add_child(items_grid)

	inventory_sort_label = Label.new()
	inventory_sort_label.text = "Sort: Newest    Empty slots show room for new pieces"
	inventory_sort_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_sort_label.add_theme_font_size_override("font_size", 16)
	inventory_sort_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_left_panel.add_child(inventory_sort_label)

	_build_right_inventory_panel()
	settings_panel = _build_settings_panel()
	inventory_content_root.add_child(settings_panel)

	inventory_footer = HBoxContainer.new()
	inventory_footer.alignment = BoxContainer.ALIGNMENT_END
	inventory_footer.add_theme_constant_override("separation", 16)
	inventory_content_root.add_child(inventory_footer)
	_add_footer_hint(inventory_footer, "Click", "Category")
	_add_footer_hint(inventory_footer, "Equip Key", "Equip Next")
	_add_footer_hint(inventory_footer, "Right Click", "Unequip")
	_add_footer_hint(inventory_footer, "Esc / Inventory", "Back")
	clear_bone_info()


func _build_right_inventory_panel() -> void:
	inventory_right_panel = VBoxContainer.new()
	inventory_right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_body.add_child(inventory_right_panel)

	inventory_preview_panel = PanelContainer.new()
	inventory_preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_preview_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.18), Color(0.87, 0.63, 0.19, 0.88), 1, 0))
	inventory_right_panel.add_child(inventory_preview_panel)

	inventory_preview_area = MarginContainer.new()
	inventory_preview_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_preview_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_preview_panel.add_child(inventory_preview_area)
	inventory_preview_area.add_child(_build_paper_doll())

	inventory_details_panel = PanelContainer.new()
	inventory_details_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_details_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.32), Color(0.87, 0.63, 0.19, 0.85), 1, 0))
	inventory_right_panel.add_child(inventory_details_panel)

	var details_margin := MarginContainer.new()
	_set_margin(details_margin, 18, 12, 18, 12)
	inventory_details_panel.add_child(details_margin)

	hover_info_label = Label.new()
	hover_info_label.name = "HoverInfoLabel"
	hover_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hover_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hover_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hover_info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hover_info_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	details_margin.add_child(hover_info_label)

	inventory_label = Label.new()
	inventory_label.name = "InventoryLabel"
	inventory_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_right_panel.add_child(inventory_label)


func _build_inventory_blur_layer() -> ColorRect:
	var blur := ColorRect.new()
	blur.name = "InventoryWorldBlur"
	blur.color = Color.WHITE
	blur.anchor_right = 1.0
	blur.anchor_bottom = 1.0
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float blur_strength = 1.0;
uniform vec4 veil_color : source_color = vec4(0.96, 0.95, 0.90, 0.24);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 p = vec2(0.0022, 0.0039) * blur_strength;
	vec4 c = texture(screen_texture, uv) * 0.20;
	c += texture(screen_texture, uv + vec2(p.x, 0.0)) * 0.10;
	c += texture(screen_texture, uv - vec2(p.x, 0.0)) * 0.10;
	c += texture(screen_texture, uv + vec2(0.0, p.y)) * 0.10;
	c += texture(screen_texture, uv - vec2(0.0, p.y)) * 0.10;
	c += texture(screen_texture, uv + p) * 0.10;
	c += texture(screen_texture, uv - p) * 0.10;
	c += texture(screen_texture, uv + vec2(p.x, -p.y)) * 0.10;
	c += texture(screen_texture, uv + vec2(-p.x, p.y)) * 0.10;
	vec3 tinted = mix(c.rgb, veil_color.rgb, veil_color.a);
	COLOR = vec4(tinted, 0.62);
}
"""

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("blur_strength", 1.0)
	material.set_shader_parameter("veil_color", Color(0.96, 0.95, 0.90, 0.24))
	blur.material = material
	return blur


func _build_inventory_tabs(parent: VBoxContainer) -> void:
	inventory_tabs_container = HBoxContainer.new()
	inventory_tabs_container.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_tabs_container.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(inventory_tabs_container)

	_add_inventory_tab(inventory_tabs_container, "all", "All")
	_add_inventory_tab(inventory_tabs_container, "right_arm", "Arms")
	_add_inventory_tab(inventory_tabs_container, "legs", "Legs")
	_add_inventory_tab(inventory_tabs_container, "body", "Torsos")
	_add_inventory_tab(inventory_tabs_container, "head", "Heads")
	_add_inventory_tab(inventory_tabs_container, "settings", "Settings")
	_refresh_inventory_tabs()


func _add_inventory_tab(parent: HBoxContainer, category: String, text: String) -> void:
	var button := Button.new()
	button.text = text
	button.flat = true
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.0), Color(0.87, 0.63, 0.19, 0.0), 0, 0))
	button.add_theme_stylebox_override("hover", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.32), Color(0.0, 0.78, 0.78, 0.65), 1, 0))
	button.pressed.connect(Callable(self, "_select_inventory_category").bind(category))
	parent.add_child(button)
	inventory_tab_buttons[category] = button


func _select_inventory_category(category: String) -> void:
	inventory_category = category
	_refresh_inventory_tabs()
	_refresh_inventory_mode()
	if inventory_category == "settings":
		_refresh_control_buttons()
	else:
		rebuild_item_tiles()
	update_inventory_ui()


func _refresh_inventory_tabs() -> void:
	for category in inventory_tab_buttons:
		var category_name: String = str(category)
		var button := inventory_tab_buttons[category_name] as Button
		if button == null:
			continue
		var selected: bool = category_name == inventory_category
		if selected:
			button.add_theme_color_override("font_color", Color(0.0, 0.78, 0.78, 1.0))
			button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.34), Color(0.0, 0.78, 0.78, 0.85), 1, 0))
		else:
			button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
			button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.0), Color(0.87, 0.63, 0.19, 0.0), 0, 0))


func _refresh_inventory_mode() -> void:
	var showing_settings := inventory_category == "settings"
	if inventory_body != null:
		inventory_body.visible = not showing_settings
	if settings_panel != null:
		settings_panel.visible = showing_settings


func _apply_inventory_responsive_layout() -> void:
	if inventory_root == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	var width: float = viewport_size.x
	var height: float = viewport_size.y
	var compact: bool = width < 1160.0 or height < 680.0
	var very_compact: bool = width < 860.0 or height < 560.0

	var outer_margin := 34
	var inner_margin := 24
	var tab_gap := 42
	var tab_width := 108
	var tab_height := 48
	var body_gap := 18
	var vertical_margin := 18
	var grid_columns := 6
	var tile_gap := 12
	var grid_inner_margin := 14
	var details_height := 96
	var label_height := 44
	var footer_gap := 16
	var header_height := 62
	var tabs_height := 52
	var sort_height := 26

	if compact:
		outer_margin = 16
		inner_margin = 16
		vertical_margin = 10
		tab_gap = 18
		tab_width = 94
		tab_height = 42
		body_gap = 12
		details_height = 84
		label_height = 40
		header_height = 52
		tabs_height = 46
		sort_height = 22
		grid_columns = 4
		tile_gap = 8
		grid_inner_margin = 10
		footer_gap = 8

	if very_compact:
		outer_margin = 8
		inner_margin = 10
		vertical_margin = 6
		tab_gap = 8
		tab_width = 78
		tab_height = 38
		body_gap = 8
		details_height = 78
		label_height = 34
		header_height = 46
		tabs_height = 40
		sort_height = 18
		grid_columns = 3
		tile_gap = 6
		grid_inner_margin = 7
		footer_gap = 6

	if width >= 1180.0 and height >= 680.0:
		grid_columns = 6
	elif width >= 980.0:
		grid_columns = 5

	var panel_height: int = maxi(320, int(height) - (vertical_margin * 2))
	var panel_width: int = maxi(360, int(width) - (outer_margin * 2))
	var content_width: int = maxi(320, panel_width - (inner_margin * 2))
	var top_inner_margin: int = maxi(8, inner_margin - 4)
	var bottom_inner_margin: int = maxi(8, inner_margin - 6)
	var content_height: int = maxi(280, panel_height - top_inner_margin - bottom_inner_margin)
	var body_height: int = maxi(190, content_height - (header_height + tabs_height + 10 + label_height + footer_gap))
	var body_width: int = maxi(320, content_width - body_gap)
	var min_left_width: int = 190 if very_compact else 300
	var min_right_width: int = 190 if very_compact else 300
	var max_right_width: int = mini(560, maxi(min_right_width, body_width - min_left_width))
	var right_width: int = clampi(int(float(body_width) * 0.36), min_right_width, max_right_width)
	var left_width: int = maxi(min_left_width, body_width - right_width)
	if left_width + right_width > body_width:
		left_width = maxi(160, body_width - right_width)
	if left_width + right_width > body_width:
		right_width = maxi(160, body_width - left_width)

	var preview_height: int = maxi(165, body_height - details_height - label_height - (body_gap * 2))
	var grid_height: int = maxi(170, body_height - sort_height)
	var grid_content_width: int = maxi(160, left_width - (grid_inner_margin * 2))
	var grid_content_height: int = maxi(140, grid_height - (grid_inner_margin * 2))
	var visible_rows := 4
	if height < 560.0:
		visible_rows = 3
	elif height > 820.0:
		visible_rows = 5
	var tile_width: float = floor(float(grid_content_width - (tile_gap * (grid_columns - 1))) / float(grid_columns))
	var tile_height: float = floor(float(grid_content_height - (tile_gap * (visible_rows - 1))) / float(visible_rows))
	inventory_item_tile_size = Vector2(clampf(tile_width, 58.0, 170.0), clampf(tile_height, 52.0, 150.0))
	inventory_empty_slot_size = inventory_item_tile_size

	var preview_inner_width: int = maxi(180, right_width - 24)
	var preview_inner_height: int = maxi(140, preview_height - 24)
	var doll_scale: float = clampf(minf(float(preview_inner_width) / 406.0, float(preview_inner_height) / 306.0), 0.55, 1.75)

	_set_margin(inventory_safe_area, outer_margin, vertical_margin, outer_margin, vertical_margin)
	_set_margin(inventory_panel_margin, inner_margin, top_inner_margin, inner_margin, bottom_inner_margin)
	_set_margin(inventory_grid_margin, grid_inner_margin, grid_inner_margin, grid_inner_margin, grid_inner_margin)
	_set_margin(inventory_preview_area, maxi(6, grid_inner_margin), maxi(6, grid_inner_margin), maxi(6, grid_inner_margin), maxi(6, grid_inner_margin))

	inventory_panel.custom_minimum_size = Vector2(panel_width, panel_height)
	inventory_scroll.custom_minimum_size = Vector2(content_width, content_height)
	inventory_content_root.custom_minimum_size = Vector2(content_width, content_height)
	inventory_content_root.add_theme_constant_override("separation", 6 if very_compact else 9)
	inventory_tabs_container.add_theme_constant_override("separation", tab_gap)
	inventory_body.custom_minimum_size = Vector2(body_width, body_height)
	inventory_body.add_theme_constant_override("separation", body_gap)
	inventory_footer.add_theme_constant_override("separation", footer_gap)

	for category in inventory_tab_buttons:
		var button := inventory_tab_buttons[String(category)] as Button
		if button == null:
			continue
		button.custom_minimum_size = Vector2(tab_width, tab_height)
		button.add_theme_font_size_override("font_size", 14 if very_compact else (15 if compact else 18))

	inventory_status_label.custom_minimum_size = Vector2(92 if compact else 140, 38 if compact else 48)
	inventory_status_label.add_theme_font_size_override("font_size", 16 if compact else 20)
	inventory_left_panel.custom_minimum_size = Vector2(left_width, body_height)
	inventory_left_panel.add_theme_constant_override("separation", 5 if very_compact else 8)
	inventory_grid_panel.custom_minimum_size = Vector2(left_width, grid_height)
	inventory_right_panel.custom_minimum_size = Vector2(right_width, body_height)
	inventory_right_panel.add_theme_constant_override("separation", body_gap)
	inventory_preview_panel.custom_minimum_size = Vector2(right_width, preview_height)
	inventory_details_panel.custom_minimum_size = Vector2(right_width, details_height)
	hover_info_label.custom_minimum_size = Vector2(maxi(180, right_width - 40), details_height - 24)
	hover_info_label.add_theme_font_size_override("font_size", 12 if very_compact else (14 if compact else 16))
	inventory_label.custom_minimum_size = Vector2(maxi(180, right_width), label_height)
	inventory_label.add_theme_font_size_override("font_size", 11 if very_compact else (12 if compact else 13))
	inventory_sort_label.custom_minimum_size = Vector2(left_width, sort_height)
	inventory_sort_label.add_theme_font_size_override("font_size", 11 if very_compact else (13 if compact else 16))
	items_grid.columns = grid_columns
	items_grid.custom_minimum_size = Vector2(grid_content_width, grid_content_height)
	items_grid.add_theme_constant_override("h_separation", tile_gap)
	items_grid.add_theme_constant_override("v_separation", tile_gap)

	inventory_paper_doll.scale = Vector2(doll_scale, doll_scale)
	inventory_paper_doll.custom_minimum_size = Vector2(406, 306) * doll_scale
	inventory_preview_viewport.size = Vector2i(int(210.0 * doll_scale), int(276.0 * doll_scale))

	_apply_settings_responsive_layout(content_width, body_height, compact, very_compact)
	rebuild_item_tiles()
	_refresh_inventory_tabs()


func _apply_settings_responsive_layout(content_width: int, content_height: int, compact: bool, very_compact: bool) -> void:
	var settings_width: int = maxi(280, content_width)
	var box_margin := 22
	var row_height := 42
	var title_size := 28
	var body_size := 15
	if compact:
		row_height = 38
		box_margin = 16
		title_size = 24
		body_size = 14
	if very_compact:
		row_height = 34
		box_margin = 10
		title_size = 20
		body_size = 12

	var usable_width: int = maxi(220, settings_width - (box_margin * 2))
	var label_width: int = clampi(int(float(usable_width) * 0.38), 110, 280)
	var button_width: int = maxi(120, usable_width - label_width - (8 if very_compact else 14))
	settings_panel.custom_minimum_size = Vector2(settings_width, content_height)
	settings_box_panel.custom_minimum_size = Vector2(settings_width, maxi(250, content_height - 16))
	_set_margin(settings_box_margin, box_margin, box_margin, box_margin, box_margin)
	settings_controls_list.add_theme_constant_override("separation", 7 if very_compact else 10)
	settings_title_label.add_theme_font_size_override("font_size", title_size)
	settings_status_label.add_theme_font_size_override("font_size", body_size)

	for action in control_rows:
		var row := control_rows[action] as HBoxContainer
		if row != null:
			row.custom_minimum_size = Vector2(0, row_height)
			row.add_theme_constant_override("separation", 8 if very_compact else 14)
		var label := control_labels[action] as Label
		if label != null:
			label.custom_minimum_size = Vector2(label_width, row_height)
			label.add_theme_font_size_override("font_size", maxi(13, body_size + 1))
		var button := control_buttons[action] as Button
		if button != null:
			button.custom_minimum_size = Vector2(button_width, row_height)
			button.add_theme_font_size_override("font_size", body_size)

	settings_reset_button.custom_minimum_size = Vector2(0, row_height)
	settings_reset_button.add_theme_font_size_override("font_size", body_size)


func _set_margin(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	if container == null:
		return
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)


func _build_settings_panel() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = "SettingsPanel"
	scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll.visible = false
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	settings_box_panel = PanelContainer.new()
	settings_box_panel.name = "ControlsSettingsBox"
	settings_box_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_box_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_box_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.34), Color(0.87, 0.63, 0.19, 0.86), 2, 0))
	scroll.add_child(settings_box_panel)

	settings_box_margin = MarginContainer.new()
	settings_box_panel.add_child(settings_box_margin)

	settings_controls_list = VBoxContainer.new()
	settings_controls_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_controls_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_box_margin.add_child(settings_controls_list)

	settings_title_label = Label.new()
	settings_title_label.text = "Control Settings"
	settings_title_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	settings_controls_list.add_child(settings_title_label)

	settings_status_label = Label.new()
	settings_status_label.text = "Click a button, then press the new key or mouse button. Esc cancels."
	settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_status_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	settings_controls_list.add_child(settings_status_label)

	var divider := ColorRect.new()
	divider.color = Color(0.87, 0.63, 0.19, 0.58)
	divider.custom_minimum_size = Vector2(0, 1)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_controls_list.add_child(divider)

	for binding in CONTROL_BINDINGS:
		var action := String(binding.get("action", ""))
		var label := String(binding.get("label", action))
		settings_controls_list.add_child(_build_control_binding_row(action, label))

	settings_reset_button = Button.new()
	settings_reset_button.text = "Reset Controls to Demo Defaults"
	settings_reset_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_reset_button.focus_mode = Control.FOCUS_NONE
	settings_reset_button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	settings_reset_button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.72), Color(0.87, 0.63, 0.19, 0.9), 1, 2))
	settings_reset_button.add_theme_stylebox_override("hover", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.92), Color(0.0, 0.78, 0.78, 0.85), 1, 2))
	settings_reset_button.pressed.connect(Callable(self, "_reset_control_defaults"))
	settings_controls_list.add_child(settings_reset_button)
	return scroll


func _build_control_binding_row(action: String, label_text: String) -> Control:
	var row := HBoxContainer.new()
	row.name = "ControlRow_" + action
	row.process_mode = Node.PROCESS_MODE_ALWAYS
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)

	var label := Label.new()
	label.text = label_text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	row.add_child(label)

	var button := Button.new()
	button.text = _binding_text(action)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.58), Color(0.87, 0.63, 0.19, 0.86), 1, 2))
	button.add_theme_stylebox_override("hover", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.86), Color(0.0, 0.78, 0.78, 0.85), 1, 2))
	button.pressed.connect(Callable(self, "_begin_rebinding").bind(action, button))
	row.add_child(button)

	control_rows[action] = row
	control_labels[action] = label
	control_buttons[action] = button
	return row


func _add_footer_hint(parent: HBoxContainer, key_text: String, action_text: String) -> void:
	var key := Label.new()
	key.text = key_text
	key.add_theme_font_size_override("font_size", 15)
	key.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	key.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.6), Color(0.03, 0.33, 0.38, 1.0), 1, 3))
	parent.add_child(key)

	var action := Label.new()
	action.text = action_text
	action.add_theme_font_size_override("font_size", 16)
	action.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	parent.add_child(action)


func _make_rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = Color(0.87, 0.63, 0.19, 0.82)
	rule.custom_minimum_size = Vector2(80, 1)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


func _make_inventory_style(bg: Color, border: Color, border_width: int = 1, radius: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	style.shadow_color = Color(0.21, 0.13, 0.04, 0.10)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	return style


func _make_empty_inventory_slot() -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = inventory_empty_slot_size
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var frame := PanelContainer.new()
	frame.position = Vector2.ZERO
	frame.size = inventory_empty_slot_size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.58), 1, 0))
	slot.add_child(frame)

	var diamond := ColorRect.new()
	diamond.color = Color(0.87, 0.63, 0.19, 0.16)
	diamond.position = Vector2((inventory_empty_slot_size.x - 18.0) * 0.5, (inventory_empty_slot_size.y - 18.0) * 0.5)
	diamond.size = Vector2(18, 18)
	diamond.rotation = PI / 4.0
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(diamond)
	return slot


func _build_character_preview_panel() -> Control:
	inventory_preview_container = SubViewportContainer.new()
	inventory_preview_container.name = "CharacterPreview"
	inventory_preview_container.position = Vector2(98.0, 15.0)
	inventory_preview_container.size = Vector2(210.0, 276.0)
	inventory_preview_container.stretch = true
	inventory_preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	inventory_preview_viewport = SubViewport.new()
	inventory_preview_viewport.size = Vector2i(210, 276)
	inventory_preview_viewport.transparent_bg = true
	inventory_preview_container.add_child(inventory_preview_viewport)

	var preview_scene := Node3D.new()
	preview_scene.name = "PreviewScene"
	inventory_preview_viewport.add_child(preview_scene)
	inventory_preview_root = preview_scene

	var light := DirectionalLight3D.new()
	light.name = "PreviewLight"
	light.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
	light.light_energy = 1.6
	preview_scene.add_child(light)

	var rig_holder := Node3D.new()
	rig_holder.name = "PreviewRigHolder"
	rig_holder.position = Vector3(0.0, -0.26, 0.0)
	rig_holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	rig_holder.scale = Vector3.ONE * 1.48
	preview_scene.add_child(rig_holder)

	inventory_preview_rig = ModularSkeletonRig.new()
	inventory_preview_rig.name = "PreviewModularSkeletonRig"
	rig_holder.add_child(inventory_preview_rig)

	var camera := Camera3D.new()
	camera.name = "PreviewCamera"
	camera.position = Vector3(0.0, 0.68, 2.85)
	camera.look_at(Vector3(0.0, 0.05, 0.0), Vector3.UP)
	camera.current = true
	preview_scene.add_child(camera)

	call_deferred("sync_preview")
	return inventory_preview_container


func sync_preview() -> void:
	if inventory_preview_rig == null or not is_instance_valid(inventory_preview_rig):
		return

	var current_slots: Array = inventory_preview_rig.equipped_ids.keys()
	for slot_id in current_slots:
		inventory_preview_rig.unequip_slot(str(slot_id))

	for slot in equipped:
		var bone_id: String = str(equipped[slot])
		var bone_def: Dictionary = BoneDatabase.get_def(bone_id)
		if not bone_def.is_empty():
			inventory_preview_rig.equip_bone(bone_id, bone_def)


func _build_paper_doll() -> Control:
	var doll := Control.new()
	inventory_paper_doll = doll
	doll.custom_minimum_size = Vector2(406, 306)
	doll.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center_frame := PanelContainer.new()
	center_frame.position = Vector2(88, 0)
	center_frame.size = Vector2(230, 306)
	center_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.46), 1, 0))
	doll.add_child(center_frame)

	var ring := ColorRect.new()
	ring.position = Vector2(171, 96)
	ring.size = Vector2(64, 64)
	ring.rotation = PI / 4.0
	ring.color = Color(0.87, 0.63, 0.19, 0.16)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	doll.add_child(ring)

	doll.add_child(_build_character_preview_panel())
	_place_slot(doll, "left_arm", "L. Arm", Vector2(0, 18))
	_place_slot(doll, "right_arm", "R. Arm", Vector2(324, 18))
	_place_slot(doll, "body", "Torso", Vector2(0, 116))
	_place_slot(doll, "legs", "Legs", Vector2(324, 116))
	return doll


func _place_slot(doll: Control, slot: String, short_name: String, pos: Vector2) -> void:
	var widget := BoneSlotWidget.new()
	widget.position = pos
	widget.setup(slot, short_name, self)
	doll.add_child(widget)
	slot_widgets[slot] = widget


func _begin_rebinding(action: String, button: Button) -> void:
	rebinding_action = action
	rebinding_button = button
	button.text = "Press a key..."
	if settings_status_label != null:
		settings_status_label.text = "Press the new button for " + _control_label(action) + ". Esc cancels."


func _cancel_rebinding() -> void:
	var action := rebinding_action
	rebinding_action = ""
	if rebinding_button != null and is_instance_valid(rebinding_button):
		rebinding_button.text = _binding_text(action)
	rebinding_button = null
	if settings_status_label != null:
		settings_status_label.text = "Canceled. Click a control to change it."


func _apply_control_binding(action: String, raw_event: InputEvent) -> void:
	var event := _clean_control_event(raw_event)
	if event == null:
		return
	var conflicting_action := _find_control_event_owner(event, action)
	if conflicting_action == "inventory" and action != "inventory":
		rebinding_action = ""
		if rebinding_button != null and is_instance_valid(rebinding_button):
			rebinding_button.text = _binding_text(action)
		rebinding_button = null
		if settings_status_label != null:
			settings_status_label.text = _event_text(event) + " opens Inventory. Change Inventory first, then reuse that button."
		return

	_remove_control_event_from_other_actions(action, event)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_save_control_settings()
	rebinding_action = ""
	rebinding_button = null
	_refresh_control_buttons()
	if settings_status_label != null:
		settings_status_label.text = _control_label(action) + " set to " + _event_text(event) + "."


func _is_bindable_control_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.pressed
	return false


func _clean_control_event(raw_event: InputEvent) -> InputEvent:
	if raw_event is InputEventKey:
		var source := raw_event as InputEventKey
		var cleaned_key := InputEventKey.new()
		cleaned_key.keycode = source.keycode
		cleaned_key.physical_keycode = source.physical_keycode
		cleaned_key.key_label = source.key_label
		cleaned_key.alt_pressed = source.alt_pressed
		cleaned_key.shift_pressed = source.shift_pressed
		cleaned_key.ctrl_pressed = source.ctrl_pressed
		cleaned_key.meta_pressed = source.meta_pressed
		return cleaned_key
	if raw_event is InputEventMouseButton:
		var source := raw_event as InputEventMouseButton
		var cleaned_mouse := InputEventMouseButton.new()
		cleaned_mouse.button_index = source.button_index
		cleaned_mouse.alt_pressed = source.alt_pressed
		cleaned_mouse.shift_pressed = source.shift_pressed
		cleaned_mouse.ctrl_pressed = source.ctrl_pressed
		cleaned_mouse.meta_pressed = source.meta_pressed
		return cleaned_mouse
	return null


func _remove_control_event_from_other_actions(target_action: String, event: InputEvent) -> void:
	for binding in CONTROL_BINDINGS:
		var action := String(binding.get("action", ""))
		if action == "" or action == target_action or not InputMap.has_action(action):
			continue
		for existing in InputMap.action_get_events(action):
			if _control_events_match(existing, event):
				InputMap.action_erase_event(action, existing)


func _control_events_match(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventKey and b is InputEventKey:
		var key_a := a as InputEventKey
		var key_b := b as InputEventKey
		return key_a.keycode == key_b.keycode \
			and key_a.alt_pressed == key_b.alt_pressed \
			and key_a.shift_pressed == key_b.shift_pressed \
			and key_a.ctrl_pressed == key_b.ctrl_pressed \
			and key_a.meta_pressed == key_b.meta_pressed
	if a is InputEventMouseButton and b is InputEventMouseButton:
		var mouse_a := a as InputEventMouseButton
		var mouse_b := b as InputEventMouseButton
		return mouse_a.button_index == mouse_b.button_index \
			and mouse_a.alt_pressed == mouse_b.alt_pressed \
			and mouse_a.shift_pressed == mouse_b.shift_pressed \
			and mouse_a.ctrl_pressed == mouse_b.ctrl_pressed \
			and mouse_a.meta_pressed == mouse_b.meta_pressed
	return false


func _find_control_event_owner(event: InputEvent, target_action: String) -> String:
	for binding in CONTROL_BINDINGS:
		var action := String(binding.get("action", ""))
		if action == "" or action == target_action or not InputMap.has_action(action):
			continue
		for existing in InputMap.action_get_events(action):
			if _control_events_match(existing, event):
				return action
	return ""


func _refresh_control_buttons() -> void:
	for action in control_buttons:
		var button := control_buttons[action] as Button
		if button != null and is_instance_valid(button):
			button.text = _binding_text(String(action))


func _binding_text(action: String) -> String:
	if not InputMap.has_action(action):
		return "Unbound"
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "Unbound"
	return _event_text(events[0])


func _event_text(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var parts: Array[String] = []
		if key_event.ctrl_pressed:
			parts.append("Ctrl")
		if key_event.alt_pressed:
			parts.append("Alt")
		if key_event.shift_pressed and key_event.keycode != KEY_SHIFT:
			parts.append("Shift")
		if key_event.meta_pressed:
			parts.append("Meta")
		var key_name := OS.get_keycode_string(key_event.keycode)
		if key_name == "":
			key_name = "Key " + str(key_event.keycode)
		parts.append(key_name)
		return " + ".join(parts)
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		match mouse_event.button_index:
			MOUSE_BUTTON_LEFT:
				return "Left Click"
			MOUSE_BUTTON_RIGHT:
				return "Right Click"
			MOUSE_BUTTON_MIDDLE:
				return "Middle Click"
			MOUSE_BUTTON_WHEEL_UP:
				return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN:
				return "Wheel Down"
			_:
				return "Mouse " + str(mouse_event.button_index)
	return "Unknown"


func _control_label(action: String) -> String:
	for binding in CONTROL_BINDINGS:
		if String(binding.get("action", "")) == action:
			return String(binding.get("label", action))
	return action


func _save_control_settings() -> void:
	var config := ConfigFile.new()
	for binding in CONTROL_BINDINGS:
		var action := String(binding.get("action", ""))
		if action == "" or not InputMap.has_action(action):
			continue
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			continue
		var event := events[0]
		if event is InputEventKey:
			var key_event := event as InputEventKey
			config.set_value(action, "type", "key")
			config.set_value(action, "keycode", key_event.keycode)
			config.set_value(action, "physical_keycode", key_event.physical_keycode)
			config.set_value(action, "key_label", key_event.key_label)
			config.set_value(action, "alt", key_event.alt_pressed)
			config.set_value(action, "shift", key_event.shift_pressed)
			config.set_value(action, "ctrl", key_event.ctrl_pressed)
			config.set_value(action, "meta", key_event.meta_pressed)
		elif event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			config.set_value(action, "type", "mouse")
			config.set_value(action, "button_index", mouse_event.button_index)
			config.set_value(action, "alt", mouse_event.alt_pressed)
			config.set_value(action, "shift", mouse_event.shift_pressed)
			config.set_value(action, "ctrl", mouse_event.ctrl_pressed)
			config.set_value(action, "meta", mouse_event.meta_pressed)
	config.save(CONTROL_SETTINGS_PATH)


func _load_control_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONTROL_SETTINGS_PATH) != OK:
		return
	for binding in CONTROL_BINDINGS:
		var action := String(binding.get("action", ""))
		if action == "" or not InputMap.has_action(action) or not config.has_section(action):
			continue
		var event := _event_from_config(config, action)
		if event == null:
			continue
		_remove_control_event_from_other_actions(action, event)
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)


func _event_from_config(config: ConfigFile, action: String) -> InputEvent:
	var event_type := String(config.get_value(action, "type", ""))
	if event_type == "key":
		var config_key_event := InputEventKey.new()
		config_key_event.keycode = int(config.get_value(action, "keycode", 0))
		config_key_event.physical_keycode = int(config.get_value(action, "physical_keycode", 0))
		config_key_event.key_label = int(config.get_value(action, "key_label", 0))
		config_key_event.alt_pressed = bool(config.get_value(action, "alt", false))
		config_key_event.shift_pressed = bool(config.get_value(action, "shift", false))
		config_key_event.ctrl_pressed = bool(config.get_value(action, "ctrl", false))
		config_key_event.meta_pressed = bool(config.get_value(action, "meta", false))
		return config_key_event
	if event_type == "mouse":
		var config_mouse_event := InputEventMouseButton.new()
		config_mouse_event.button_index = int(config.get_value(action, "button_index", 0))
		config_mouse_event.alt_pressed = bool(config.get_value(action, "alt", false))
		config_mouse_event.shift_pressed = bool(config.get_value(action, "shift", false))
		config_mouse_event.ctrl_pressed = bool(config.get_value(action, "ctrl", false))
		config_mouse_event.meta_pressed = bool(config.get_value(action, "meta", false))
		return config_mouse_event
	return null


func _reset_control_defaults() -> void:
	_cancel_rebinding()
	_set_default_control_key("move_forward", KEY_W)
	_set_default_control_key("move_back", KEY_S)
	_set_default_control_key("move_left", KEY_A)
	_set_default_control_key("move_right", KEY_D)
	_set_default_control_key("jump", KEY_SPACE)
	_set_default_control_key("sprint", KEY_SHIFT)
	_set_default_control_mouse("attack", MOUSE_BUTTON_LEFT)
	_set_default_control_key("inventory", KEY_TAB)
	_set_default_control_key("interact", KEY_E)
	_set_default_control_key("equip", KEY_Q)
	_set_default_control_key("stealth_finish", KEY_F)
	_save_control_settings()
	_refresh_control_buttons()
	if settings_status_label != null:
		settings_status_label.text = "Controls reset to the demo defaults."


func _set_default_control_key(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		return
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)


func _set_default_control_mouse(action: String, button_index: int) -> void:
	if not InputMap.has_action(action):
		return
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)


func rebuild_item_tiles() -> void:
	if items_grid == null:
		return
	for child in items_grid.get_children():
		child.free()

	var shown := 0
	for bone_id in _bone_inventory():
		if not _bone_matches_inventory_category(str(bone_id)):
			continue
		if has_bone_equipped(str(bone_id)):
			continue
		var tile := BoneItemTile.new()
		tile.setup(str(bone_id), self)
		items_grid.add_child(tile)
		shown += 1

	var target_slots: int = maxi(12, items_grid.columns * 4)
	for i in range(shown, target_slots):
		items_grid.add_child(_make_empty_inventory_slot())


func _bone_matches_inventory_category(bone_id: String) -> bool:
	if inventory_category == "all":
		return true
	var slot := BoneDatabase.slot(bone_id)
	if inventory_category == "right_arm":
		return slot == "right_arm" or slot == "left_arm"
	return slot == inventory_category


func update_inventory_ui() -> void:
	for slot in slot_widgets:
		var widget = slot_widgets[slot]
		if is_instance_valid(widget):
			widget.refresh()

	if items_grid != null:
		for tile in items_grid.get_children():
			if tile.has_method("refresh"):
				tile.refresh()

	if inventory_label == null:
		return

	var bones := _bone_inventory()
	if inventory_status_label != null:
		inventory_status_label.text = "Bones " + str(bones.size())

	var stats := _inventory_stats_snapshot()
	var text := "Stats: "
	text += "Speed " + str(stats.get("move_speed", 0.0))
	text += "   Reach " + str(stats.get("attack_range", 0.0))
	text += "   Damage " + str(stats.get("attack_damage", 0))
	text += "   HP " + str(stats.get("health", 0)) + "/" + str(stats.get("max_health", 0)) + "\n"
	text += "Drag a bone onto a matching slot. Right-click a worn bone slot to remove."
	inventory_label.text = text


func _bone_inventory() -> Array:
	if player == null:
		return []
	if player.has_method("get_inventory_items"):
		return player.call("get_inventory_items") as Array
	var value = player.get("bone_inventory")
	if typeof(value) == TYPE_ARRAY:
		return value as Array
	return []


func _equipment_state() -> Dictionary:
	if player == null:
		return {}
	if player.has_method("get_equipment_state"):
		return player.call("get_equipment_state") as Dictionary
	var value = player.get("equipped")
	if typeof(value) == TYPE_DICTIONARY:
		return value as Dictionary
	return {}


func _inventory_stats_snapshot() -> Dictionary:
	if player == null:
		return {}
	if player.has_method("get_inventory_stats_snapshot"):
		return player.call("get_inventory_stats_snapshot") as Dictionary
	return {
		"move_speed": player.get("move_speed"),
		"attack_range": player.get("attack_range"),
		"attack_damage": player.get("attack_damage"),
		"health": player.get("health"),
		"max_health": player.get("max_health"),
	}
