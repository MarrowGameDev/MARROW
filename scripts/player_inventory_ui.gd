class_name PlayerInventoryUI
extends Node

const INVENTORY_EMPTY_SLOT_SCRIPT: Script = preload("res://scripts/ui_inventory_empty_slot.gd")
const CONTROL_SETTINGS_PATH := "user://control_settings.cfg"
const INVENTORY_PREVIEW_BASE_SIZE := Vector2i(210, 276)
const BUILD_PREVIEW_BASE_SIZE := Vector2(120.0, 158.0)

# Paper-doll geometry, in unscaled design units. Single source of truth: these
# were previously written out in both _build_paper_doll() and the responsive
# pass, and the two copies drifting apart is exactly what desynced the slots
# before. Every consumer scales these by doll_scale.
# Item-grid filters, in dropdown order. Arms and legs are grouped rather than
# split per side: EquipmentRulesService.INVENTORY_FILTER_GROUPS owns what each
# grouped key actually matches, so this table stays presentation-only.
const INVENTORY_FILTER_OPTIONS: Array = [
	{"category": "all", "text": "All"},
	{"category": "head", "text": "Head"},
	{"category": "torso", "text": "Torso"},
	{"category": "group_arms", "text": "Arms"},
	{"category": "group_legs", "text": "Legs"},
]

const PAPER_DOLL_BASE_SIZE := Vector2(406.0, 470.0)
const PAPER_DOLL_SLOT_SIZE := Vector2(88.0, 88.0)
const PAPER_DOLL_FRAME_POSITION := Vector2(94.0, 92.0)
const PAPER_DOLL_FRAME_SIZE := Vector2(218.0, 284.0)
const PAPER_DOLL_PREVIEW_POSITION := Vector2(98.0, 96.0)
const PAPER_DOLL_RING_POSITION := Vector2(171.0, 177.0)
const PAPER_DOLL_RING_SIZE := Vector2(64.0, 64.0)
# Arms and legs are centred on the preview frame: the frame spans y 92..376,
# so its centre is y 234, and the arm+leg block (arms at y 142 through legs
# ending at y 326) is centred on that same 234. Head and torso stay anchored
# above and below the frame.
const PAPER_DOLL_SLOT_POSITIONS := {
	"head": Vector2(159.0, 0.0),
	"left_arm": Vector2(0.0, 142.0),
	"right_arm": Vector2(318.0, 142.0),
	"left_leg": Vector2(0.0, 238.0),
	"right_leg": Vector2(318.0, 238.0),
	"torso": Vector2(159.0, 382.0),
}
const CONTROL_BINDINGS: Array = [
	{"action": "move_forward", "label": "Move Forward"},
	{"action": "move_back", "label": "Move Back"},
	{"action": "move_left", "label": "Move Left"},
	{"action": "move_right", "label": "Move Right"},
	{"action": "jump", "label": "Jump"},
	{"action": "sprint", "label": "Sprint"},
	{"action": "attack", "label": "Attack"},
	{"action": "toggle_bow", "label": "Equip Bow"},
	{"action": "ranged_attack", "label": "Bow / Arrow"},
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
var inventory_safe_area: Control = null
var inventory_panel: PanelContainer = null
var inventory_panel_margin: MarginContainer = null
var inventory_scroll: ScrollContainer = null
var inventory_content_root: VBoxContainer = null
var inventory_header: HBoxContainer = null
var inventory_title_label: Label = null
var inventory_tabs_container: HBoxContainer = null
var inventory_filter_dropdown: OptionButton = null
var inventory_filter_label: Label = null
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
var inventory_preview_equipment_snapshot: Dictionary = {}
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
var builds_panel: ScrollContainer = null
# One isolated ModularSkeletonRig per build slot (1..BUILD_SLOT_COUNT),
# driven from that build's saved state, never the live player/preview.
var build_preview_rigs: Dictionary = {}
var build_preset_status_label: Label = null
var build_preset_summary_labels: Dictionary = {}
var build_preset_apply_buttons: Dictionary = {}
var build_preset_save_buttons: Dictionary = {}
# Per-card nodes kept so the builds tab can be laid out responsively like the
# rest of the inventory instead of staying at its authored size.
var build_preset_cards: Dictionary = {}
var build_preview_frames: Dictionary = {}
var build_preset_title_labels: Dictionary = {}
var builds_box_margin: MarginContainer = null
var builds_cards_row: HBoxContainer = null
var builds_title_label: Label = null
# "save:2" / "apply:1" style key for whichever button is armed and waiting
# for a second press to confirm; "" when nothing is armed.
var build_preset_armed_action: String = ""
var build_preset_confirm_timer: SceneTreeTimer = null
const BUILD_PRESET_CONFIRM_WINDOW := 4.0
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
# Rows the grid is currently sized for. rebuild_item_tiles() pads out to this
# many rows so the reserved height is actually filled instead of leaving a
# band of empty panel under the last row.
var inventory_visible_rows: int = 4
var inventory_empty_slot_size: Vector2 = Vector2(96, 86)


func setup(owner_player: Node) -> void:
	player = owner_player
	name = "PlayerInventoryUI"
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameEvents.inventory_changed.connect(_on_inventory_changed)
	GameEvents.bone_equipped.connect(_on_bone_equipped)
	GameEvents.bone_unequipped.connect(_on_bone_unequipped)
	_load_control_settings()
	_build_inventory_ui()
	_refresh_build_preset_rows()
	get_viewport().size_changed.connect(Callable(self, "_queue_inventory_responsive_layout"))
	rebuild_item_tiles()
	update_inventory_ui()
	_apply_inventory_responsive_layout()
	call_deferred("_apply_inventory_responsive_layout")


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
		inventory_root.visible = true
		if inventory_category != "all":
			_select_inventory_category("all")
		_apply_inventory_responsive_layout()
		call_deferred("_apply_inventory_responsive_layout")
		_refresh_inventory_mode()
		_refresh_control_buttons()
		update_inventory_ui()
		sync_preview()
	else:
		inventory_root.visible = false


func cycle_category() -> void:
	# Same order the dropdown shows, then the two panel modes.
	var categories: Array[String] = []
	for entry in INVENTORY_FILTER_OPTIONS:
		categories.append(str(entry["category"]))
	categories.append("builds")
	categories.append("settings")
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


func _on_inventory_changed(event_player: Node, _items: Array, _stats: Dictionary) -> void:
	if event_player != player:
		return
	notify_inventory_changed()


func _on_bone_equipped(_bone_id: String, _slot: String, event_player: Node) -> void:
	if event_player != player:
		return
	notify_equipment_changed()


func _on_bone_unequipped(_bone_id: String, _slot: String, event_player: Node) -> void:
	if event_player != player:
		return
	notify_equipment_changed()


func get_inventory_tile_size() -> Vector2:
	return inventory_item_tile_size


func has_bone_equipped(bone_id: String) -> bool:
	return player != null and bool(player.call("has_bone_equipped", bone_id))


func equip_bone(bone_id: String) -> void:
	if player != null:
		player.call("equip_bone", bone_id)


func equip_bone_in_slot(bone_id: String, slot: String) -> void:
	if player != null:
		player.call("equip_bone", bone_id, slot)


func unequip_slot(slot: String) -> void:
	if player != null:
		player.call("unequip_slot", slot)


func get_equipped_bone_for_slot(slot: String) -> String:
	return str(equipped.get(slot, ""))


func show_bone_info(bone_id: String) -> void:
	if hover_info_label == null:
		return
	var text := BoneRulesService.quality_for(bone_id) + " " + BoneRulesService.display_name_with_slot(bone_id) + "  [slot: " + EquipmentRulesService.slot_display_name(EquipmentRulesService.slot_for_bone(bone_id)) + "]\n"
	text += BoneRulesService.effect_text_for(bone_id)
	text += BoneRulesService.description_for(bone_id)
	text += _bone_comparison_text(bone_id)
	hover_info_label.text = text


# Compares against whatever is equipped in the same side/slot the hovered
# bone would occupy (slot_for_bone's default side for a bilateral bone).
# Only compares stats that actually exist on the player
# (move_speed/attack_range/attack_damage/max_health) -- no defense, weight,
# or other stat this project does not have.
func _bone_comparison_text(bone_id: String) -> String:
	var slot := EquipmentRulesService.slot_for_bone(bone_id)
	if slot == "":
		return ""
	var equipped_id := get_equipped_bone_for_slot(slot)
	if equipped_id == "" or equipped_id == bone_id:
		return ""

	var candidate: Dictionary = BoneRulesService.adjusted_player_bonus_for(bone_id)
	var current: Dictionary = BoneRulesService.adjusted_player_bonus_for(equipped_id)
	var deltas := {
		"Speed": float(candidate.get("move_speed", 0.0)) - float(current.get("move_speed", 0.0)),
		"Reach": float(candidate.get("attack_range", 0.0)) - float(current.get("attack_range", 0.0)),
		"Damage": float(candidate.get("attack_damage", 0.0)) - float(current.get("attack_damage", 0.0)),
		"HP": float(candidate.get("max_health", 0.0)) - float(current.get("max_health", 0.0)),
	}

	var text := "\nvs equipped " + BoneRulesService.display_name_with_slot(equipped_id) + ": "
	var wrote_any := false
	for label in ["Speed", "Reach", "Damage", "HP"]:
		var value: float = deltas[label]
		if absf(value) < 0.001:
			continue
		if wrote_any:
			text += ", "
		text += label + " " + ("+%.1f" % value if value > 0.0 else "%.1f" % value)
		wrote_any = true
	if not wrote_any:
		text += "no stat change"
	return text


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
	inventory_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventory_root.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_root.visible = false
	canvas.add_child(inventory_root)
	inventory_root.add_child(_build_inventory_blur_layer())

	inventory_safe_area = Control.new()
	inventory_safe_area.name = "InventorySafeArea"
	inventory_safe_area.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	inventory_safe_area.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_safe_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_safe_area.clip_contents = true
	inventory_root.add_child(inventory_safe_area)

	inventory_panel = PanelContainer.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	inventory_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_panel_margin.add_child(inventory_scroll)

	inventory_content_root = VBoxContainer.new()
	inventory_content_root.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_content_root.add_theme_constant_override("separation", 9)
	inventory_scroll.add_child(inventory_content_root)

	inventory_header = HBoxContainer.new()
	inventory_header.add_theme_constant_override("separation", 16)
	inventory_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_content_root.add_child(inventory_header)
	inventory_header.add_child(_make_rule())

	var title := Label.new()
	inventory_title_label = title
	title.text = "Inventory"
	title.custom_minimum_size = Vector2(260, 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_header.add_child(title)
	inventory_header.add_child(_make_rule())

	inventory_status_label = Label.new()
	inventory_status_label.custom_minimum_size = Vector2(140, 48)
	inventory_status_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	inventory_status_label.size_flags_stretch_ratio = 0.0
	inventory_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	inventory_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_status_label.clip_text = false
	inventory_status_label.add_theme_font_size_override("font_size", 20)
	inventory_status_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_header.add_child(inventory_status_label)

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
	inventory_sort_label.text = "Sort: Body slot, rarity, quality, name"
	inventory_sort_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_sort_label.add_theme_font_size_override("font_size", 16)
	inventory_sort_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_left_panel.add_child(inventory_sort_label)

	_build_right_inventory_panel()
	builds_panel = _build_equipment_builds_tab()
	inventory_content_root.add_child(builds_panel)
	settings_panel = _build_settings_panel()
	inventory_content_root.add_child(settings_panel)

	inventory_footer = HBoxContainer.new()
	inventory_footer.alignment = BoxContainer.ALIGNMENT_END
	inventory_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_footer.add_theme_constant_override("separation", 16)
	inventory_content_root.add_child(inventory_footer)
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
	inventory_preview_panel.clip_contents = true
	inventory_preview_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.18), Color(0.87, 0.63, 0.19, 0.88), 1, 0))
	inventory_right_panel.add_child(inventory_preview_panel)

	inventory_preview_area = MarginContainer.new()
	inventory_preview_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_preview_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_preview_area.clip_contents = true
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
	inventory_tabs_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	parent.add_child(inventory_tabs_container)

	inventory_filter_label = Label.new()
	inventory_filter_label.text = "Filter by"
	inventory_filter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_filter_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_tabs_container.add_child(inventory_filter_label)

	inventory_filter_dropdown = OptionButton.new()
	inventory_filter_dropdown.name = "InventoryFilterDropdown"
	inventory_filter_dropdown.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_filter_dropdown.focus_mode = Control.FOCUS_NONE
	# Match the parchment styling the rest of the panel uses; the stock
	# OptionButton theme is dark grey and reads as a different application.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var background := Color(1.0, 1.0, 1.0, 0.55)
		var border := Color(0.87, 0.63, 0.19, 0.85)
		if state == "hover" or state == "pressed":
			background = Color(1.0, 1.0, 1.0, 0.78)
			border = Color(0.0, 0.78, 0.78, 0.85)
		inventory_filter_dropdown.add_theme_stylebox_override(state, _make_inventory_style(background, border, 1, 0))
	for color_role in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		inventory_filter_dropdown.add_theme_color_override(color_role, Color(0.03, 0.33, 0.38, 1.0))

	var popup := inventory_filter_dropdown.get_popup()
	popup.add_theme_stylebox_override("panel", _make_inventory_style(Color(0.99, 0.985, 0.955, 0.99), Color(0.87, 0.63, 0.19, 0.96), 2, 0))
	popup.add_theme_stylebox_override("hover", _make_inventory_style(Color(0.0, 0.78, 0.78, 0.22), Color(0.0, 0.78, 0.78, 0.0), 0, 0))
	popup.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	popup.add_theme_color_override("font_hover_color", Color(0.03, 0.33, 0.38, 1.0))

	for entry in INVENTORY_FILTER_OPTIONS:
		inventory_filter_dropdown.add_item(str(entry["text"]))
		inventory_filter_dropdown.set_item_metadata(inventory_filter_dropdown.item_count - 1, str(entry["category"]))
	inventory_filter_dropdown.item_selected.connect(_on_inventory_filter_selected)
	inventory_tabs_container.add_child(inventory_filter_dropdown)

	# Builds and Settings stay as they were: they switch the whole panel's
	# mode, they are not filters over the item grid, so they do not belong in
	# a "Filter by" dropdown.
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_tabs_container.add_child(spacer)
	_add_inventory_tab(inventory_tabs_container, "builds", "Builds")
	_add_inventory_tab(inventory_tabs_container, "settings", "Settings")
	# Keeps the last tab off the panel's right border instead of flush to it.
	var end_pad := Control.new()
	end_pad.custom_minimum_size = Vector2(6.0, 0.0)
	end_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_tabs_container.add_child(end_pad)
	_refresh_inventory_tabs()


func _on_inventory_filter_selected(index: int) -> void:
	if inventory_filter_dropdown == null:
		return
	var category: Variant = inventory_filter_dropdown.get_item_metadata(index)
	if category == null:
		return
	_select_inventory_category(str(category))


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
	elif inventory_category == "builds":
		_refresh_build_preset_rows()
	else:
		rebuild_item_tiles()
	update_inventory_ui()


func _refresh_inventory_tabs() -> void:
	# Keep the dropdown showing the live filter. Entering Builds/Settings does
	# not clear it: those are modes, and the grid keeps its filter for when the
	# player comes back to it.
	if inventory_filter_dropdown != null:
		for i in range(inventory_filter_dropdown.item_count):
			if str(inventory_filter_dropdown.get_item_metadata(i)) == inventory_category:
				if inventory_filter_dropdown.selected != i:
					inventory_filter_dropdown.selected = i
				break

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
	var showing_builds := inventory_category == "builds"
	if inventory_body != null:
		inventory_body.visible = not showing_settings and not showing_builds
	if settings_panel != null:
		settings_panel.visible = showing_settings
	if builds_panel != null:
		builds_panel.visible = showing_builds


func _queue_inventory_responsive_layout() -> void:
	_apply_inventory_responsive_layout()
	call_deferred("_apply_inventory_responsive_layout")


func _apply_inventory_responsive_layout() -> void:
	if inventory_root == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	var root_size := inventory_root.size
	if root_size.x <= 0.0 or root_size.y <= 0.0:
		root_size = viewport_size
	var width: float = root_size.x
	var height: float = root_size.y
	var compact: bool = width < 1440.0 or height < 800.0
	var very_compact: bool = width < 1040.0 or height < 640.0

	var outer_margin_x := int(clampf(width * 0.025, 10.0, 60.0))
	var outer_margin_y := int(clampf(height * 0.022, 6.0, 24.0))
	var inner_margin := int(clampf(minf(width, height) * 0.018, 8.0, 24.0))
	var top_inner_margin: int = maxi(6, inner_margin - 2)
	var bottom_inner_margin: int = maxi(6, inner_margin - 2)
	var panel_height: int = maxi(320, int(height) - (outer_margin_y * 2))
	var available_panel_width: int = maxi(360, int(width) - (outer_margin_x * 2))
	var max_panel_width: int = int(minf(1800.0, width - float(outer_margin_x * 2)))
	var panel_width: int = mini(available_panel_width, max_panel_width)
	var panel_x: int = int(round((width - float(panel_width)) * 0.5))
	var content_width: int = maxi(320, panel_width - (inner_margin * 2))
	var content_height: int = maxi(280, panel_height - top_inner_margin - bottom_inner_margin)

	var content_gap := int(clampf(height * 0.008, 4.0, 10.0))
	var tab_gap := int(clampf(width * 0.018, 8.0, 42.0))
	var tab_width := int(clampf(width * 0.068, 72.0, 108.0))
	var tab_height := int(clampf(height * 0.052, 32.0, 48.0))
	var body_gap := int(clampf(width * 0.008, 8.0, 18.0))
	var tile_gap := int(clampf(width * 0.006, 5.0, 12.0))
	var grid_inner_margin := int(clampf(width * 0.007, 6.0, 14.0))
	var details_height := int(clampf(height * 0.095, 60.0, 96.0))
	var label_height := int(clampf(height * 0.052, 34.0, 46.0))
	var footer_height := int(clampf(height * 0.032, 20.0, 32.0))
	var header_height := int(clampf(height * 0.066, 38.0, 62.0))
	var tabs_height := int(clampf(height * 0.052, 34.0, 52.0))
	var sort_height := int(clampf(height * 0.03, 18.0, 26.0))
	var divider_height := 1
	var vertical_gaps := content_gap * 4
	var fixed_vertical: int = header_height + tabs_height + divider_height + sort_height + footer_height + vertical_gaps
	var body_height: int = maxi(190, content_height - fixed_vertical)
	var body_width: int = maxi(320, content_width - body_gap)
	var min_left_width: int = 180 if very_compact else (260 if compact else 360)
	var min_right_width: int = 220 if very_compact else (330 if compact else 360)
	var max_right_width: int = mini(600, maxi(min_right_width, body_width - min_left_width))
	var right_ratio := 0.39 if compact else 0.34
	var right_width: int = clampi(int(float(body_width) * right_ratio), min_right_width, max_right_width)
	var left_width: int = maxi(min_left_width, body_width - right_width)
	if left_width + right_width > body_width:
		left_width = maxi(160, body_width - right_width)
	if left_width + right_width > body_width:
		right_width = maxi(160, body_width - left_width)

	var preview_height: int = maxi(150, body_height - details_height - label_height - (body_gap * 2))
	var left_panel_gap := content_gap
	var grid_height: int = maxi(160, body_height - sort_height - left_panel_gap)
	var grid_content_width: int = maxi(160, left_width - (grid_inner_margin * 2))
	var grid_content_height: int = maxi(140, grid_height - (grid_inner_margin * 2))
	var visible_rows := 4
	if height < 660.0:
		visible_rows = 3
	elif height > 860.0:
		visible_rows = 5
	inventory_visible_rows = visible_rows
	var grid_columns := 6
	if grid_content_width < 520:
		grid_columns = 3
	elif grid_content_width < 760:
		grid_columns = 4
	elif grid_content_width < 980:
		grid_columns = 5
	var tile_width: float = floor(float(grid_content_width - (tile_gap * (grid_columns - 1))) / float(grid_columns))
	var tile_height: float = floor(float(grid_content_height - (tile_gap * (visible_rows - 1))) / float(visible_rows))
	inventory_item_tile_size = Vector2(clampf(tile_width, 58.0, 170.0), clampf(tile_height, 52.0, 150.0))
	inventory_empty_slot_size = inventory_item_tile_size

	var preview_inner_width: int = maxi(180, right_width - 24)
	var preview_inner_height: int = maxi(140, preview_height - 24)
	var doll_scale: float = clampf(minf(float(preview_inner_width) / 406.0, float(preview_inner_height) / 470.0), 0.55, 1.75)

	inventory_safe_area.position = Vector2(panel_x, outer_margin_y)
	inventory_safe_area.size = Vector2(panel_width, panel_height)
	inventory_safe_area.custom_minimum_size = Vector2(panel_width, panel_height)
	inventory_panel.position = Vector2.ZERO
	_set_margin(inventory_panel_margin, inner_margin, top_inner_margin, inner_margin, bottom_inner_margin)
	_set_margin(inventory_grid_margin, grid_inner_margin, grid_inner_margin, grid_inner_margin, grid_inner_margin)
	_set_margin(inventory_preview_area, maxi(6, grid_inner_margin), maxi(6, grid_inner_margin), maxi(6, grid_inner_margin), maxi(6, grid_inner_margin))

	inventory_panel.custom_minimum_size = Vector2(panel_width, panel_height)
	inventory_scroll.custom_minimum_size = Vector2(content_width, content_height)
	inventory_scroll.size = Vector2(content_width, content_height)
	inventory_content_root.custom_minimum_size = Vector2(content_width, content_height)
	inventory_content_root.size = Vector2(content_width, content_height)
	inventory_content_root.add_theme_constant_override("separation", content_gap)
	inventory_header.custom_minimum_size = Vector2(content_width, header_height)
	inventory_header.size = Vector2(content_width, header_height)
	inventory_tabs_container.add_theme_constant_override("separation", tab_gap)
	inventory_body.custom_minimum_size = Vector2(body_width, body_height)
	inventory_body.size = Vector2(body_width, body_height)
	inventory_body.add_theme_constant_override("separation", body_gap)
	inventory_footer.custom_minimum_size = Vector2(content_width, footer_height)
	inventory_footer.size = Vector2(content_width, footer_height)
	inventory_footer.alignment = BoxContainer.ALIGNMENT_CENTER
	inventory_footer.visible = true
	_apply_footer_responsive_layout(content_width, very_compact)

	for category in inventory_tab_buttons:
		var button := inventory_tab_buttons[String(category)] as Button
		if button == null:
			continue
		button.custom_minimum_size = Vector2(tab_width, tab_height)
		button.add_theme_font_size_override("font_size", 14 if very_compact else (15 if compact else 18))

	var tab_font_size: int = 14 if very_compact else (15 if compact else 18)
	if inventory_filter_label != null:
		inventory_filter_label.add_theme_font_size_override("font_size", tab_font_size)
		inventory_filter_label.custom_minimum_size = Vector2(0, tab_height)
	if inventory_filter_dropdown != null:
		inventory_filter_dropdown.custom_minimum_size = Vector2(clampf(float(content_width) * 0.16, 130.0, 260.0), float(tab_height))
		inventory_filter_dropdown.add_theme_font_size_override("font_size", tab_font_size)
	if inventory_tabs_container != null:
		inventory_tabs_container.add_theme_constant_override("separation", int(clampf(float(tab_gap) * 0.5, 6.0, 18.0)))

	if inventory_title_label != null:
		inventory_title_label.custom_minimum_size = Vector2(190 if compact else 260, header_height)
		inventory_title_label.add_theme_font_size_override("font_size", int(clampf(height * 0.048, 28.0, 38.0)))
	inventory_status_label.custom_minimum_size = Vector2(86 if compact else 118, header_height)
	inventory_status_label.add_theme_font_size_override("font_size", 12 if compact else 15)
	inventory_left_panel.custom_minimum_size = Vector2(left_width, body_height)
	inventory_left_panel.add_theme_constant_override("separation", left_panel_gap)
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

	_apply_paper_doll_responsive_layout(doll_scale)

	_apply_settings_responsive_layout(content_width, body_height, compact, very_compact)
	_apply_builds_responsive_layout(content_width, body_height, compact, very_compact)
	rebuild_item_tiles()
	_refresh_inventory_tabs()


# The builds tab gets the full inventory width to itself (no side preview), so
# its cards can be noticeably wider than the paper-doll slots. Everything here
# is derived from the available content box rather than authored constants, so
# the tab holds up at 1024x600 and at ultrawide alike.
func _apply_builds_responsive_layout(content_width: int, content_height: int, compact: bool, very_compact: bool) -> void:
	if builds_panel == null:
		return

	var slot_count: int = maxi(1, PlayerEquipmentBuildsComponent.BUILD_SLOT_COUNT)
	var box_margin: int = 8 if very_compact else (11 if compact else 14)
	var card_gap: int = 8 if very_compact else (13 if compact else 18)
	var card_margin: int = 6 if very_compact else (8 if compact else 10)

	var row_width: int = maxi(200, content_width - (box_margin * 2))
	var gaps_width: int = card_gap * (slot_count - 1)
	var card_width: float = floor(float(row_width - gaps_width) / float(slot_count))
	card_width = clampf(card_width, 120.0, 340.0)

	# Height budget: the tab title, status paragraph and divider, plus the
	# card's own title, its 3-line summary and the button row, all have to fit
	# around the preview. Measured against the rendered tab at 1280x720 and
	# 1920x1080 -- under-budgeting here is what pushed the buttons off-panel.
	var chrome_height: int = 210 if very_compact else (268 if compact else 292)
	var preview_height_budget: float = float(content_height) - float(chrome_height)
	var preview_width: float = maxf(70.0, card_width - float(card_margin * 2))
	var aspect: float = BUILD_PREVIEW_BASE_SIZE.y / BUILD_PREVIEW_BASE_SIZE.x
	var preview_height: float = preview_width * aspect
	if preview_height_budget > 60.0 and preview_height > preview_height_budget:
		preview_height = preview_height_budget
		preview_width = preview_height / aspect
	preview_height = maxf(90.0, preview_height)
	preview_width = maxf(70.0, preview_width)

	_set_margin(builds_box_margin, box_margin, box_margin, box_margin, box_margin)
	if builds_cards_row != null:
		builds_cards_row.add_theme_constant_override("separation", card_gap)
	if builds_title_label != null:
		builds_title_label.add_theme_font_size_override("font_size", 18 if very_compact else (21 if compact else 24))
	if build_preset_status_label != null:
		build_preset_status_label.add_theme_font_size_override("font_size", 11 if very_compact else (13 if compact else 15))
		build_preset_status_label.custom_minimum_size = Vector2(float(row_width), 0.0)

	for index in build_preset_cards:
		var card := build_preset_cards[index] as Control
		if card != null:
			card.custom_minimum_size = Vector2(card_width, 0.0)
		var frame := build_preview_frames.get(index) as Control
		if frame != null:
			frame.custom_minimum_size = Vector2(preview_width, preview_height)
		var card_title := build_preset_title_labels.get(index) as Label
		if card_title != null:
			card_title.add_theme_font_size_override("font_size", 13 if very_compact else (15 if compact else 17))
		var summary := build_preset_summary_labels.get(index) as Label
		if summary != null:
			var summary_font: int = 10 if very_compact else (12 if compact else 14)
			summary.add_theme_font_size_override("font_size", summary_font)
			# clip_text with a zero minimum height collapsed the label to
			# nothing, so reserve the height its 3 capped lines actually need.
			summary.custom_minimum_size = Vector2(preview_width, ceilf(float(summary_font) * 1.45 * 3.0))
		for button_source in [build_preset_save_buttons, build_preset_apply_buttons]:
			var button := (button_source as Dictionary).get(index) as Button
			if button == null:
				continue
			button.custom_minimum_size = Vector2(maxf(52.0, (preview_width - 8.0) * 0.5), 26.0 if very_compact else 30.0)
			button.add_theme_font_size_override("font_size", 11 if very_compact else (13 if compact else 15))


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


func _apply_paper_doll_responsive_layout(doll_scale: float) -> void:
	if inventory_paper_doll == null:
		return

	# Anatomical layout: head above the preview, torso below it, arms flanking
	# its sides and legs below the arms, with the arm+leg block centred on the
	# preview frame. All geometry comes from the PAPER_DOLL_* constants so this
	# pass and _build_paper_doll() can no longer disagree.
	var scaled_doll_size := PAPER_DOLL_BASE_SIZE * doll_scale
	inventory_paper_doll.scale = Vector2.ONE
	inventory_paper_doll.custom_minimum_size = scaled_doll_size
	inventory_paper_doll.clip_contents = true

	# The doll's children sit at absolute offsets from the doll's own origin,
	# so the doll must be exactly as big as the figure for it to read as
	# centred. By default the enclosing MarginContainer stretched it to the
	# whole panel (measured over 1000px wide against a ~500px figure), which
	# pinned the figure to the top-left and left every pixel of slack on the
	# right and bottom. SHRINK_CENTER makes the container size the doll to its
	# minimum and centre it, so the figure is centred by layout at any aspect
	# ratio rather than by a hand-computed offset.
	inventory_paper_doll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	inventory_paper_doll.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var center_frame := inventory_paper_doll.get_node_or_null("CenterFrame") as Control
	if center_frame != null:
		center_frame.position = PAPER_DOLL_FRAME_POSITION * doll_scale
		center_frame.size = PAPER_DOLL_FRAME_SIZE * doll_scale

	var ring := inventory_paper_doll.get_node_or_null("CenterRing") as ColorRect
	if ring != null:
		ring.position = PAPER_DOLL_RING_POSITION * doll_scale
		ring.size = PAPER_DOLL_RING_SIZE * doll_scale

	if inventory_preview_container != null:
		inventory_preview_container.position = PAPER_DOLL_PREVIEW_POSITION * doll_scale
		var preview_size := _inventory_preview_base_size() * doll_scale
		inventory_preview_container.custom_minimum_size = preview_size
		# inventory_preview_container.stretch is true (see
		# _build_character_preview_panel), so SubViewportContainer already
		# resizes its single SubViewport child to match this size on
		# NOTIFICATION_RESIZED. Do not add a manual SubViewport resize call
		# here again; see docs/inventory_flow.md for why that was removed
		# twice already.
		inventory_preview_container.size = preview_size

	# Keyed by slot_widgets' real keys (the six canonical body slots). An older
	# version kept its own copy of this table using "body"/"legs" keys that do
	# not exist in slot_widgets, so four widgets were silently never moved and
	# stayed frozen while the doll scaled around them. Sharing one constant
	# with _build_paper_doll() removes that whole class of drift.
	var slot_positions := PAPER_DOLL_SLOT_POSITIONS
	for slot in slot_positions:
		var widget := slot_widgets.get(slot) as Control
		if widget == null:
			continue
		var base_position: Vector2 = slot_positions[slot]
		widget.position = base_position * doll_scale
		# BoneSlotWidget.resize() re-lays-out its children for the new size, so
		# the slot is sized for real instead of being drawn through `scale`.
		# That keeps the control's input rect identical to what is drawn: an
		# earlier version set both `scale` and a scaled `size`, which left the
		# input rect at 88 * doll_scale^2 against visuals at 88 * doll_scale
		# and made neighbouring drop targets overlap.
		widget.resize(PAPER_DOLL_SLOT_SIZE * doll_scale)


func _apply_footer_responsive_layout(content_width: int, very_compact: bool) -> void:
	if inventory_footer == null:
		return

	var compact_footer := content_width < 1500
	var tight_footer := content_width < 1180 or very_compact
	inventory_footer.add_theme_constant_override("separation", 5 if compact_footer else 10)
	var footer_item_height := 20 if tight_footer else (22 if compact_footer else 24)
	var key_font_size := 10 if tight_footer else (11 if compact_footer else 14)
	var action_font_size := 10 if tight_footer else (11 if compact_footer else 15)

	for child in inventory_footer.get_children():
		var label := child as Label
		if label == null:
			continue
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var full_text := str(label.get_meta("inventory_footer_full_text", label.text))
		var role := str(label.get_meta("inventory_footer_role", ""))
		if role == "key":
			label.visible = true
			if compact_footer and full_text == "Esc / Inventory":
				label.text = "Esc"
			else:
				label.text = full_text
			label.custom_minimum_size = Vector2(0, footer_item_height)
			label.add_theme_font_size_override("font_size", key_font_size)
		elif role == "action":
			label.visible = true
			label.text = {
				"Unequip": "Drop",
				"Back": "Back"
			}.get(full_text, full_text)
			label.custom_minimum_size = Vector2(0, footer_item_height)
			label.add_theme_font_size_override("font_size", action_font_size)
		label.clip_text = false


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


func _build_equipment_builds_tab() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = "BuildsPanel"
	scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll.visible = false
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var box := PanelContainer.new()
	box.name = "EquipmentBuildsBox"
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.34), Color(0.87, 0.63, 0.19, 0.86), 2, 0))
	scroll.add_child(box)

	var margin := MarginContainer.new()
	builds_box_margin = margin
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	box.add_child(margin)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	margin.add_child(list)

	var title := Label.new()
	builds_title_label = title
	title.text = "Equipment Builds"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	list.add_child(title)

	build_preset_status_label = Label.new()
	build_preset_status_label.text = "Save the current worn bones, then apply them later when the pieces are available. Each build previews here in its own isolated render -- it is not visible in the world while you play."
	build_preset_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	build_preset_status_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	list.add_child(build_preset_status_label)

	var divider := ColorRect.new()
	divider.color = Color(0.87, 0.63, 0.19, 0.58)
	divider.custom_minimum_size = Vector2(0, 1)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list.add_child(divider)

	var cards := HBoxContainer.new()
	builds_cards_row = cards
	cards.name = "BuildCards"
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Take the leftover height so the cards can sit centred in it rather than
	# hugging the top of a tall panel.
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 18)
	list.add_child(cards)

	for index in range(1, PlayerEquipmentBuildsComponent.BUILD_SLOT_COUNT + 1):
		cards.add_child(_build_equipment_build_card(index))

	# Rig sockets are only populated once each preview rig's _ready() has
	# run (fires on tree entry, which just happened above via add_child);
	# defer so equip_bone() below never races that, matching the same
	# call_deferred("sync_preview") pattern _build_character_preview_panel
	# already uses for the live-equipped preview.
	call_deferred("_sync_all_build_previews")
	return scroll


func _build_equipment_build_card(index: int) -> Control:
	var card := PanelContainer.new()
	card.name = "EquipmentBuildCard_" + str(index)
	card.process_mode = Node.PROCESS_MODE_ALWAYS
	card.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.42), Color(0.87, 0.63, 0.19, 0.74), 1, 2))
	card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	build_preset_cards[index] = card

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	margin.add_child(list)

	var title := Label.new()
	title.text = "Build " + str(index)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	list.add_child(title)
	build_preset_title_labels[index] = title

	var preview_frame := PanelContainer.new()
	build_preview_frames[index] = preview_frame
	# custom_minimum_size is only a floor: left to FILL, the preview absorbed
	# all the card's spare height and pushed the summary and the Save/Apply
	# buttons out of the panel. SHRINK_CENTER pins it to the size the
	# responsive pass computes, leaving the rest of the card its own room.
	preview_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	preview_frame.custom_minimum_size = BUILD_PREVIEW_BASE_SIZE
	preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.46), 1, 0))
	preview_frame.add_child(_build_build_preview(index))
	list.add_child(preview_frame)

	var summary := Label.new()
	summary.text = "Empty"
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# A full six-slot build wraps to many lines; uncapped it grew the card
	# until the buttons fell off the bottom of the panel.
	summary.max_lines_visible = 3
	summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	summary.clip_text = true
	summary.custom_minimum_size = Vector2(BUILD_PREVIEW_BASE_SIZE.x, 0)
	summary.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	list.add_child(summary)
	build_preset_summary_labels[index] = summary

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	list.add_child(buttons)

	var save_button := _make_build_preset_button("Save")
	save_button.pressed.connect(Callable(self, "_save_equipment_build").bind(index))
	buttons.add_child(save_button)
	build_preset_save_buttons[index] = save_button

	var apply_button := _make_build_preset_button("Apply")
	apply_button.pressed.connect(Callable(self, "_apply_equipment_build").bind(index))
	buttons.add_child(apply_button)
	build_preset_apply_buttons[index] = apply_button
	return card


# Builds a small, fully isolated 3D preview (own SubViewport + World3D +
# ModularSkeletonRig) for one build slot, mirroring the shape of
# _build_character_preview_panel at a smaller size. This rig is never
# added to the live world, never shares state with inventory_preview_rig
# (the live-equipped-gear preview), and never touches the in-world player
# rig -- so a build's preview can never be seen by anything outside this
# card while the player is actually playing.
func _build_build_preview(index: int) -> Control:
	var container := SubViewportContainer.new()
	container.name = "BuildPreview_" + str(index)
	container.custom_minimum_size = BUILD_PREVIEW_BASE_SIZE
	container.size = BUILD_PREVIEW_BASE_SIZE
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var viewport := SubViewport.new()
	viewport.size = Vector2i(BUILD_PREVIEW_BASE_SIZE)
	viewport.transparent_bg = false
	viewport.world_3d = World3D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	container.add_child(viewport)

	var preview_scene := Node3D.new()
	preview_scene.name = "BuildPreviewScene_" + str(index)
	viewport.add_child(preview_scene)

	_build_preview_room(preview_scene)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-44.0, 30.0, 0.0)
	light.light_energy = 2.1
	preview_scene.add_child(light)

	var fill_light := OmniLight3D.new()
	fill_light.position = Vector3(0.0, 1.25, 1.6)
	fill_light.light_energy = 0.65
	fill_light.omni_range = 4.0
	preview_scene.add_child(fill_light)

	var rig_holder := Node3D.new()
	rig_holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	rig_holder.scale = Vector3.ONE * 1.08
	preview_scene.add_child(rig_holder)

	var rig := ModularSkeletonRig.new()
	rig.name = "BuildPreviewRig_" + str(index)
	# Must be set before add_child: _ready() reads this flag while
	# building sockets, same requirement as inventory_preview_rig above.
	rig.use_split_limbs = true
	rig_holder.add_child(rig)
	if rig.has_method("set_body_progression_enabled"):
		rig.set_body_progression_enabled(true)

	var camera := Camera3D.new()
	camera.fov = 36.0
	camera.current = true
	preview_scene.add_child(camera)
	camera.look_at_from_position(Vector3(0.0, 0.10, 4.15), Vector3(0.0, -0.08, 0.0), Vector3.UP)

	build_preview_rigs[index] = rig
	return container


func _sync_all_build_previews() -> void:
	for index in range(1, PlayerEquipmentBuildsComponent.BUILD_SLOT_COUNT + 1):
		_sync_build_preview(index)


# Renders whatever is currently SAVED in build `index` -- never the live
# equipped state -- on that build's own isolated rig. The player's head
# is always a fixed piece and never part of a saved build (see
# PlayerEquipmentBuildsComponent._sanitize_build_state), so it is shown
# here too, matching what applying the build would actually produce.
func _sync_build_preview(index: int) -> void:
	var rig := build_preview_rigs.get(index) as ModularSkeletonRig
	if rig == null or not is_instance_valid(rig):
		return

	for slot_id in rig.equipped_ids.keys():
		rig.unequip_slot(str(slot_id))

	var head_bone_id := ""
	if player != null and player.has_method("get_equipped_bone_for_slot"):
		head_bone_id = str(player.call("get_equipped_bone_for_slot", "head"))
	if head_bone_id == "":
		head_bone_id = "head_bone"
	_equip_bone_on_rig(rig, "head", head_bone_id)

	var build_state := _raw_build_state(index)
	for slot_id in build_state:
		_equip_bone_on_rig(rig, str(slot_id), str(build_state[slot_id]))


func _equip_bone_on_rig(rig: ModularSkeletonRig, slot_id: String, bone_id: String) -> void:
	if bone_id == "":
		return
	var bone_def: Dictionary = BoneRulesService.definition_for(bone_id).duplicate(true)
	if bone_def.is_empty():
		return
	bone_def["slot"] = EquipmentRulesService.normalize_slot_id(slot_id)
	rig.equip_bone(bone_id, bone_def)


# Raw slot_id -> bone_id dict for one saved build, read directly from
# PlayerEquipmentBuildsComponent -- not validated against current
# inventory (a preview should still show what was saved even if a piece
# was later lost), and never applied to live equipment.
func _raw_build_state(index: int) -> Dictionary:
	if player == null:
		return {}
	var builds_component = player.get("equipment_builds_component")
	if builds_component == null:
		return {}
	var builds: Dictionary = builds_component.get("builds")
	return builds.get(index, {}) as Dictionary


func _make_build_preset_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(64, 30)
	button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.64), Color(0.87, 0.63, 0.19, 0.86), 1, 2))
	button.add_theme_stylebox_override("hover", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.90), Color(0.0, 0.78, 0.78, 0.85), 1, 2))
	return button


func _save_equipment_build(index: int) -> void:
	if player == null or not player.has_method("save_equipment_build"):
		_set_build_preset_status("Equipment builds are not ready.")
		return
	# Saving into an empty slot is harmless; only overwriting an existing
	# build needs a second press.
	if not _build_slot_is_empty(index) and not _consume_or_arm_confirmation("save", index, "Save"):
		return
	var result := player.call("save_equipment_build", index) as Dictionary
	_set_build_preset_status(str(result.get("message", "")))
	_refresh_build_preset_rows()


func _apply_equipment_build(index: int) -> void:
	if player == null or not player.has_method("apply_equipment_build"):
		_set_build_preset_status("Equipment builds are not ready.")
		return
	# Applying always replaces currently worn gear, so it always needs a
	# second press to confirm.
	if not _consume_or_arm_confirmation("apply", index, "Apply"):
		return
	var result := player.call("apply_equipment_build", index) as Dictionary
	_set_build_preset_status(str(result.get("message", "")))
	_refresh_build_preset_rows()
	if bool(result.get("ok", false)):
		notify_equipment_changed()


func _build_slot_is_empty(index: int) -> bool:
	if player == null or not player.has_method("get_equipment_build_summaries"):
		return true
	var summaries := player.call("get_equipment_build_summaries") as Array
	for entry in summaries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if int(entry.get("index", 0)) == index:
			return bool(entry.get("is_empty", true))
	return true


# First press arms the given action+index and edits its button to prompt a
# second press; returns false without doing anything else. Second press
# within BUILD_PRESET_CONFIRM_WINDOW seconds on the SAME action+index
# disarms and returns true, letting the caller proceed. Pressing any other
# build button while one is armed just re-arms the new one instead of
# silently running it.
func _consume_or_arm_confirmation(action: String, index: int, button_text: String) -> bool:
	var key := action + ":" + str(index)
	if build_preset_armed_action == key:
		_disarm_build_preset_confirmation()
		return true

	_disarm_build_preset_confirmation()
	build_preset_armed_action = key
	var buttons: Dictionary = build_preset_apply_buttons if action == "apply" else build_preset_save_buttons
	var button := buttons.get(index) as Button
	if button != null:
		button.text = "Confirm?"
	_set_build_preset_status(button_text + " build " + str(index) + " again to confirm.")
	build_preset_confirm_timer = get_tree().create_timer(BUILD_PRESET_CONFIRM_WINDOW)
	build_preset_confirm_timer.timeout.connect(_on_build_preset_confirm_timeout.bind(key))
	return false


func _on_build_preset_confirm_timeout(expected_key: String) -> void:
	if build_preset_armed_action == expected_key:
		_disarm_build_preset_confirmation()
		_set_build_preset_status("Confirmation timed out.")


func _disarm_build_preset_confirmation() -> void:
	build_preset_armed_action = ""
	build_preset_confirm_timer = null
	for index in build_preset_save_buttons:
		var save_button := build_preset_save_buttons[index] as Button
		if save_button != null:
			save_button.text = "Save"
	for index in build_preset_apply_buttons:
		var apply_button := build_preset_apply_buttons[index] as Button
		if apply_button != null:
			apply_button.text = "Apply"


func _refresh_build_preset_rows() -> void:
	if player == null or not player.has_method("get_equipment_build_summaries"):
		return
	var summaries := player.call("get_equipment_build_summaries") as Array
	for entry in summaries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var index := int(entry.get("index", 0))
		var label := build_preset_summary_labels.get(index) as Label
		if label != null:
			label.text = str(entry.get("summary", "Empty"))
		_sync_build_preview(index)


func _set_build_preset_status(text: String) -> void:
	if build_preset_status_label != null:
		build_preset_status_label.text = text


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
	key.set_meta("inventory_footer_role", "key")
	key.set_meta("inventory_footer_full_text", key_text)
	key.add_theme_font_size_override("font_size", 15)
	key.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	key.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.6), Color(0.03, 0.33, 0.38, 1.0), 1, 3))
	parent.add_child(key)

	var action := Label.new()
	action.text = action_text
	action.set_meta("inventory_footer_role", "action")
	action.set_meta("inventory_footer_full_text", action_text)
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
	var slot := INVENTORY_EMPTY_SLOT_SCRIPT.new() as InventoryEmptySlot
	slot.setup(self, inventory_empty_slot_size)
	return slot


func _build_character_preview_panel() -> Control:
	inventory_preview_container = SubViewportContainer.new()
	inventory_preview_container.name = "CharacterPreview"
	inventory_preview_container.position = Vector2(98.0, 96.0)
	inventory_preview_container.custom_minimum_size = _inventory_preview_base_size()
	inventory_preview_container.size = _inventory_preview_base_size()
	inventory_preview_container.stretch = true
	inventory_preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	inventory_preview_viewport = SubViewport.new()
	inventory_preview_viewport.size = INVENTORY_PREVIEW_BASE_SIZE
	inventory_preview_viewport.transparent_bg = false
	inventory_preview_viewport.world_3d = World3D.new()
	inventory_preview_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	inventory_preview_container.add_child(inventory_preview_viewport)

	var preview_scene := Node3D.new()
	preview_scene.name = "PreviewScene"
	inventory_preview_viewport.add_child(preview_scene)
	inventory_preview_root = preview_scene

	_build_preview_room(preview_scene)

	var light := DirectionalLight3D.new()
	light.name = "PreviewLight"
	light.rotation_degrees = Vector3(-44.0, 30.0, 0.0)
	light.light_energy = 2.1
	preview_scene.add_child(light)

	var fill_light := OmniLight3D.new()
	fill_light.name = "PreviewFillLight"
	fill_light.position = Vector3(0.0, 1.25, 1.6)
	fill_light.light_energy = 0.65
	fill_light.omni_range = 4.0
	preview_scene.add_child(fill_light)

	var rig_holder := Node3D.new()
	rig_holder.name = "PreviewRigHolder"
	rig_holder.position = Vector3(0.0, 0.0, 0.0)
	rig_holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	rig_holder.scale = Vector3.ONE * 1.08
	preview_scene.add_child(rig_holder)

	inventory_preview_rig = ModularSkeletonRig.new()
	inventory_preview_rig.name = "PreviewModularSkeletonRig"
	# Must match the in-world player or the paper doll depicts a body the player
	# does not have (fat waist, wide-set whole legs). Set BEFORE add_child: _ready
	# fires on tree entry and builds the sockets from this flag.
	inventory_preview_rig.use_split_limbs = true
	rig_holder.add_child(inventory_preview_rig)
	if inventory_preview_rig.has_method("set_body_progression_enabled"):
		inventory_preview_rig.set_body_progression_enabled(true)
	inventory_preview_equipment_snapshot = {}

	var camera := Camera3D.new()
	camera.name = "PreviewCamera"
	camera.fov = 36.0
	camera.current = true
	preview_scene.add_child(camera)
	camera.look_at_from_position(Vector3(0.0, 0.10, 4.15), Vector3(0.0, -0.08, 0.0), Vector3.UP)

	call_deferred("sync_preview")
	return inventory_preview_container


func _inventory_preview_base_size() -> Vector2:
	return Vector2(float(INVENTORY_PREVIEW_BASE_SIZE.x), float(INVENTORY_PREVIEW_BASE_SIZE.y))


func _build_preview_room(parent: Node3D) -> void:
	var room_root := Node3D.new()
	room_root.name = "PreviewRoom"
	parent.add_child(room_root)

	room_root.add_child(_make_preview_room_box("PreviewFloor", Vector3(3.2, 0.05, 3.4), Vector3(0.0, -1.08, -0.10), Color(0.34, 0.31, 0.26, 1.0)))
	room_root.add_child(_make_preview_room_box("PreviewBackWall", Vector3(3.2, 2.7, 0.06), Vector3(0.0, 0.12, -1.45), Color(0.30, 0.39, 0.41, 1.0)))
	room_root.add_child(_make_preview_room_box("PreviewLeftWall", Vector3(0.06, 2.7, 3.2), Vector3(-1.62, 0.12, -0.05), Color(0.24, 0.31, 0.33, 1.0)))
	room_root.add_child(_make_preview_room_box("PreviewRightWall", Vector3(0.06, 2.7, 3.2), Vector3(1.62, 0.12, -0.05), Color(0.24, 0.31, 0.33, 1.0)))
	room_root.add_child(_make_preview_room_box("PreviewBaseLine", Vector3(2.3, 0.035, 0.035), Vector3(0.0, -1.02, -1.38), Color(0.70, 0.53, 0.24, 1.0)))


func _make_preview_room_box(name: String, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	mesh_instance.material_override = material
	return mesh_instance


func sync_preview() -> void:
	if inventory_preview_rig == null or not is_instance_valid(inventory_preview_rig):
		return

	var next_snapshot := _preview_equipment_snapshot()
	if _preview_snapshot_matches(next_snapshot):
		return

	var current_slots: Array = inventory_preview_rig.equipped_ids.keys()
	for slot_id in current_slots:
		inventory_preview_rig.unequip_slot(str(slot_id))

	# Only cache the slots that actually got a definition applied. If
	# BoneRulesService can't resolve a bone_id yet, leaving it out of the
	# cached snapshot means the next sync_preview() call still differs from
	# `equipped` and retries that slot, instead of the cache falsely
	# claiming the preview is already in sync with a piece it never drew.
	var applied_snapshot: Dictionary = {}
	for slot in next_snapshot:
		var bone_id: String = str(next_snapshot[slot])
		# Duplicate before mutating: definition_for() can return a cached
		# shared dictionary, and the preview rig must not equip pieces
		# under a non-canonical slot id (legacy defs may carry "body"
		# instead of "torso").
		var bone_def: Dictionary = BoneRulesService.definition_for(bone_id).duplicate(true)
		if bone_def.is_empty():
			continue
		bone_def["slot"] = EquipmentRulesService.normalize_slot_id(str(slot))
		inventory_preview_rig.equip_bone(bone_id, bone_def)
		applied_snapshot[slot] = bone_id
	inventory_preview_equipment_snapshot = applied_snapshot


func _preview_equipment_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for slot in equipped:
		var bone_id := str(equipped[slot])
		if bone_id == "":
			continue
		snapshot[str(slot)] = bone_id
	return snapshot


func _preview_snapshot_matches(next_snapshot: Dictionary) -> bool:
	if inventory_preview_equipment_snapshot.size() != next_snapshot.size():
		return false
	for slot in next_snapshot:
		if str(inventory_preview_equipment_snapshot.get(slot, "")) != str(next_snapshot[slot]):
			return false
	return true


# Anatomical paper-doll layout: head above the character preview, torso
# below it, arms flanking its left/right sides at preview-mid-height, legs
# below the arms. Replaces a previous 2-column grid (head/torso side by
# side at the top) that read as a jumble instead of a body, and whose
# responsive rescale (_apply_paper_doll_responsive_layout) had mismatched
# keys that silently froze 4 of the 6 slot widgets in place -- keep the
# positions below in sync with that function's slot_positions dict.
func _build_paper_doll() -> Control:
	var doll := Control.new()
	inventory_paper_doll = doll
	doll.custom_minimum_size = PAPER_DOLL_BASE_SIZE
	doll.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center_frame := PanelContainer.new()
	center_frame.name = "CenterFrame"
	center_frame.position = PAPER_DOLL_FRAME_POSITION
	center_frame.size = PAPER_DOLL_FRAME_SIZE
	center_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.46), 1, 0))
	doll.add_child(center_frame)

	var ring := ColorRect.new()
	ring.name = "CenterRing"
	ring.position = PAPER_DOLL_RING_POSITION
	ring.size = PAPER_DOLL_RING_SIZE
	ring.rotation = PI / 4.0
	ring.color = Color(0.87, 0.63, 0.19, 0.16)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	doll.add_child(ring)

	doll.add_child(_build_character_preview_panel())
	var slot_titles := {
		"head": "Head",
		"left_arm": "L. Arm",
		"right_arm": "R. Arm",
		"left_leg": "L. Leg",
		"right_leg": "R. Leg",
		"torso": "Torso",
	}
	for slot in PAPER_DOLL_SLOT_POSITIONS:
		var slot_id := str(slot)
		_place_slot(doll, slot_id, str(slot_titles[slot_id]), PAPER_DOLL_SLOT_POSITIONS[slot_id], PAPER_DOLL_SLOT_SIZE)
	return doll


func _place_slot(doll: Control, slot: String, short_name: String, pos: Vector2, slot_size: Vector2) -> void:
	var widget := BoneSlotWidget.new()
	widget.position = pos
	widget.setup(slot, short_name, self, slot_size)
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
		_ensure_required_control_bindings()
		return
	for binding in CONTROL_BINDINGS:
		var action := String(binding.get("action", ""))
		if action == "" or not InputMap.has_action(action) or not config.has_section(action):
			continue
		var event := _event_from_config(config, action)
		if event == null or not _control_event_is_usable(event):
			continue
		_remove_control_event_from_other_actions(action, event)
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
	_ensure_required_control_bindings()


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


func _control_event_is_usable(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.keycode != 0 or key_event.physical_keycode != 0 or key_event.key_label != 0
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.button_index > 0
	return false


func _ensure_required_control_bindings() -> void:
	_ensure_default_control_key("move_forward", KEY_W)
	_ensure_default_control_key("move_back", KEY_S)
	_ensure_default_control_key("move_left", KEY_A)
	_ensure_default_control_key("move_right", KEY_D)
	_ensure_default_control_key("jump", KEY_SPACE)
	_ensure_default_control_key("sprint", KEY_SHIFT)
	_ensure_default_control_mouse("attack", MOUSE_BUTTON_LEFT)
	_ensure_default_control_key("toggle_bow", KEY_1)
	_ensure_default_control_mouse("ranged_attack", MOUSE_BUTTON_RIGHT)
	_ensure_default_control_key("inventory", KEY_TAB)
	_ensure_default_control_key("interact", KEY_E)
	_ensure_default_control_key("equip", KEY_Q)
	_ensure_default_control_key("stealth_finish", KEY_F)


func _ensure_default_control_key(action: String, keycode: int) -> void:
	if _action_has_usable_event(action):
		return
	_set_default_control_key(action, keycode)


func _ensure_default_control_mouse(action: String, button_index: int) -> void:
	if _action_has_usable_event(action):
		return
	_set_default_control_mouse(action, button_index)


func _action_has_usable_event(action: String) -> bool:
	if not InputMap.has_action(action):
		return false
	for event in InputMap.action_get_events(action):
		if _control_event_is_usable(event):
			return true
	return false


func _reset_control_defaults() -> void:
	_cancel_rebinding()
	_set_default_control_key("move_forward", KEY_W)
	_set_default_control_key("move_back", KEY_S)
	_set_default_control_key("move_left", KEY_A)
	_set_default_control_key("move_right", KEY_D)
	_set_default_control_key("jump", KEY_SPACE)
	_set_default_control_key("sprint", KEY_SHIFT)
	_set_default_control_mouse("attack", MOUSE_BUTTON_LEFT)
	_set_default_control_key("toggle_bow", KEY_1)
	_set_default_control_mouse("ranged_attack", MOUSE_BUTTON_RIGHT)
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

	var equipped_counts := _equipped_bone_counts()
	var skipped_equipped_counts: Dictionary = {}
	var visible_counts: Dictionary = {}
	var visible_order: Array[String] = []
	for bone_id in _bone_inventory():
		var id := str(bone_id)
		if not _bone_matches_inventory_category(id):
			continue
		var equipped_count := int(equipped_counts.get(id, 0))
		var skipped_count := int(skipped_equipped_counts.get(id, 0))
		if skipped_count < equipped_count:
			skipped_equipped_counts[id] = skipped_count + 1
			continue
		if not visible_counts.has(id):
			visible_order.append(id)
			visible_counts[id] = 0
		visible_counts[id] = int(visible_counts[id]) + 1

	var shown := 0
	visible_order.sort_custom(Callable(self, "_compare_inventory_items"))
	for id in visible_order:
		var tile := BoneItemTile.new()
		tile.setup(id, self, int(visible_counts.get(id, 1)))
		items_grid.add_child(tile)
		shown += 1

	# Pad to the same row count the layout reserved height for, so the grid
	# panel is filled rather than leaving an empty band under the last row.
	var target_slots: int = maxi(12, items_grid.columns * maxi(1, inventory_visible_rows))
	for i in range(shown, target_slots):
		items_grid.add_child(_make_empty_inventory_slot())


func _bone_matches_inventory_category(bone_id: String) -> bool:
	if inventory_category == "all":
		return true
	return EquipmentRulesService.inventory_filter_matches_bone(inventory_category, bone_id)


func _compare_inventory_items(a: String, b: String) -> bool:
	return EquipmentRulesService.compare_bones_for_inventory(a, b)


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
		inventory_status_label.text = "Bones: " + str(bones.size())

	var stats := _inventory_stats_snapshot()
	var root_size := inventory_root.size if inventory_root != null else get_viewport().get_visible_rect().size
	var compact_text := root_size.x < 1400.0 or root_size.y < 780.0
	var text := "Stats: "
	text += "Speed " + str(stats.get("move_speed", 0.0))
	text += "   Reach " + str(stats.get("attack_range", 0.0))
	text += "   Damage " + str(stats.get("attack_damage", 0))
	text += "   HP " + str(stats.get("health", 0)) + "/" + str(stats.get("max_health", 0)) + "\n"
	if compact_text:
		text += "Drag to equip. Right-click worn slots to remove."
	else:
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


func _equipped_bone_counts() -> Dictionary:
	var counts: Dictionary = {}
	for bone_id in _equipment_state().values():
		var id := str(bone_id)
		if id == "":
			continue
		counts[id] = int(counts.get(id, 0)) + 1
	return counts


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
