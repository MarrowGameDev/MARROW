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

# Sort modes for the item grid. "default" keeps the existing body-slot /
# rarity / quality / name ordering; the quality modes re-rank by the quality
# ladder first and fall back to the default order inside a tier.
# Rows the build report may occupy before it is clipped.
const BUILD_REPORT_MAX_LINES := 16
# The detail panel owns one preview rig, re-synced on selection, instead of one
# rig per saved build.
const BUILD_DETAIL_PREVIEW_KEY := 0
const BUILD_TABLE_SLOTS: Array = [
	EquipmentRulesService.SLOT_HEAD,
	EquipmentRulesService.SLOT_TORSO,
	EquipmentRulesService.SLOT_LEFT_ARM,
	EquipmentRulesService.SLOT_RIGHT_ARM,
	EquipmentRulesService.SLOT_LEFT_LEG,
	EquipmentRulesService.SLOT_RIGHT_LEG,
]

const INVENTORY_SORT_OPTIONS: Array = [
	{"mode": "default", "text": "Default"},
	{"mode": "quality_asc", "text": "Quality: Lowest first"},
	{"mode": "quality_desc", "text": "Quality: Highest first"},
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
# Head and torso are wider than the limb slots: they sit alone on their row
# and carry the longest names ("Gorilla Right Arm Bone" style), so the extra
# width buys legibility where there is free space anyway. Their x is
# (406 - 128) / 2 = 139, keeping them centred on the doll's axis.
const PAPER_DOLL_SLOT_POSITIONS := {
	"head": Vector2(139.0, 0.0),
	"left_arm": Vector2(0.0, 142.0),
	"right_arm": Vector2(318.0, 142.0),
	"left_leg": Vector2(0.0, 238.0),
	"right_leg": Vector2(318.0, 238.0),
	"torso": Vector2(139.0, 382.0),
}
const PAPER_DOLL_WIDE_SLOT_SIZE := Vector2(128.0, 88.0)
const PAPER_DOLL_WIDE_SLOTS: Array = ["head", "torso"]
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
var selected_bone_id: String = ""
var dragging_bone_id: String = ""
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
var inventory_quality_dropdown: OptionButton = null
var inventory_quality_label: Label = null
var inventory_sort_dropdown: OptionButton = null
var inventory_sort_label_control: Label = null
# Independent of the body-slot filter: both narrow the same grid together.
var inventory_quality_filter: String = "all"
var inventory_sort_mode: String = "default"
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
# Set by the responsive pass: a small panel gets a denser report (no blank
# separator rows, effects inline) so the Save/Apply buttons keep their room.
var builds_report_compact: bool = false
var builds_sidebar_panel: PanelContainer = null
var builds_sidebar_list: VBoxContainer = null
var builds_detail_panel: PanelContainer = null
var builds_detail_title: Label = null
var builds_detail_preview_frame: PanelContainer = null
var builds_stats_list: VBoxContainer = null
var builds_composition_list: VBoxContainer = null
var builds_effects_list: VBoxContainer = null
var builds_match_banner: Label = null
var builds_equipment_rows: Dictionary = {}
var builds_save_button: Button = null
var builds_apply_button: Button = null
var builds_rename_button: Button = null
var builds_delete_button: Button = null
var builds_rename_edit: LineEdit = null
var builds_new_button: Button = null
var builds_selected_index: int = 1
var builds_header_badge: Label = null
var builds_banner_panel: PanelContainer = null
var builds_slot_cards: Dictionary = {}
var builds_lower_cards: Array = []
var builds_detail_preview_container: Control = null
var builds_equipment_table_panel: PanelContainer = null
var builds_upper_row: HBoxContainer = null
var builds_action_row: HBoxContainer = null
var inventory_last_very_compact: bool = false
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
	_refresh_builds_screen()
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


# The card the player picked. Drives the highlighted tile, the highlighted
# paper-doll slot, and what the details panel falls back to when the cursor is
# not over anything.
func select_bone(bone_id: String) -> void:
	selected_bone_id = "" if bone_id == selected_bone_id else bone_id
	_refresh_selection_visuals()
	if selected_bone_id == "":
		clear_bone_info()
	else:
		show_bone_info(selected_bone_id)


func _refresh_selection_visuals() -> void:
	if items_grid != null:
		for tile in items_grid.get_children():
			if tile.has_method("set_selected"):
				tile.call("set_selected", str(tile.get("bone_id")) == selected_bone_id and selected_bone_id != "")
	# Show which slots the selected piece could go into.
	var compatible: Array[String] = []
	if selected_bone_id != "":
		compatible = EquipmentRulesService.compatible_slots_for_bone(selected_bone_id)
	for slot in slot_widgets:
		var widget := slot_widgets[slot] as Control
		if widget != null and widget.has_method("set_highlighted"):
			widget.call("set_highlighted", compatible.has(str(slot)))


# Called once when a bone starts being dragged, from either the item grid or a
# worn slot. Paints every slot at once so the player can see the whole board:
# gold where the piece fits, dimmed red where it does not.
func begin_bone_drag(bone_id: String) -> void:
	dragging_bone_id = bone_id
	var compatible: Array[String] = EquipmentRulesService.compatible_slots_for_bone(bone_id)
	for slot in slot_widgets:
		var widget := slot_widgets[slot] as Control
		if widget != null and widget.has_method("set_drag_state"):
			widget.call("set_drag_state", "compatible" if compatible.has(str(slot)) else "incompatible")
	if hover_info_label != null:
		hover_info_label.text = "Dragging %s\nCompatible with: %s" % [
			BoneRulesService.display_name_with_slot(bone_id),
			_slot_list_text(compatible),
		]


# Idempotent: fires from every slot when any drag ends, including cancelled
# drags and drops that landed outside the panel.
func end_bone_drag() -> void:
	if dragging_bone_id == "":
		return
	dragging_bone_id = ""
	for slot in slot_widgets:
		var widget := slot_widgets[slot] as Control
		if widget != null and widget.has_method("set_drag_state"):
			widget.call("set_drag_state", "")
	_refresh_selection_visuals()
	clear_bone_info()


func _slot_list_text(slots: Array[String]) -> String:
	if slots.is_empty():
		return "nothing (no matching slot)"
	var names: Array[String] = []
	for slot in slots:
		names.append(EquipmentRulesService.slot_display_name(slot))
	return " / ".join(names)


func show_bone_info(bone_id: String) -> void:
	if hover_info_label == null:
		return
	# A drag in flight owns the details panel. Without this, passing the
	# cursor over any card while dragging replaced the "Compatible with:"
	# message with that card's stats -- exactly when the player needs to know
	# where the dragged piece can land.
	if dragging_bone_id != "":
		return
	var quality_id := BoneInstanceService.quality_id_of(bone_id)
	var multiplier := BoneQualityService.multiplier_for(quality_id)
	var text := BoneRulesService.display_name_with_slot(bone_id) + "  [slot: " + EquipmentRulesService.slot_display_name(EquipmentRulesService.slot_for_bone(bone_id)) + "]\n"
	text += "%s  (x%s)\n" % [BoneQualityService.display_name_for(quality_id), _format_number(multiplier)]
	text += _base_vs_effective_text(bone_id)
	text += BoneRulesService.description_for(bone_id)
	text += _bone_comparison_text(bone_id)
	hover_info_label.text = text


# Base stats and the quality-scaled numbers side by side, so the multiplier is
# something the player can check rather than take on faith. Only the four
# stats that actually exist are listed; nothing is invented here.
func _base_vs_effective_text(bone_id: String) -> String:
	var base: Dictionary = BoneRulesService.player_bonus_for(bone_id)
	var effective: Dictionary = BoneRulesService.adjusted_player_bonus_for(bone_id)
	var rows: Array[String] = []
	for entry in [["move_speed", "Speed"], ["attack_range", "Reach"], ["attack_damage", "Damage"], ["max_health", "HP"]]:
		var key := str(entry[0])
		var label := str(entry[1])
		var base_value := float(base.get(key, 0.0))
		var effective_value := float(effective.get(key, 0.0))
		if absf(base_value) < 0.001 and absf(effective_value) < 0.001:
			continue
		if absf(base_value - effective_value) < 0.001:
			rows.append("%s %s" % [label, _format_number(effective_value)])
		else:
			rows.append("%s %s -> %s" % [label, _format_number(base_value), _format_number(effective_value)])
	var text := ""
	if not rows.is_empty():
		text = "base -> effective: " + ", ".join(rows) + "\n"

	# This piece's own percentage modifiers, which apply to the WHOLE player
	# total rather than to this bone's numbers. They are the reason a total can
	# exceed the sum of the pieces, so they belong on the piece that causes it.
	var percent_bits: Array[String] = []
	for entry in [
		[BoneRulesService.quality_damage_percent_for(bone_id), "damage"],
		[BoneRulesService.quality_speed_percent_for(bone_id), "speed"],
		[BoneRulesService.quality_health_percent_for(bone_id), "max HP"],
		[BoneRulesService.quality_weight_percent_for(bone_id), "weight"],
	]:
		var value := float(entry[0])
		if absf(value) < 0.0005:
			continue
		percent_bits.append("%+.0f%% %s" % [value * 100.0, str(entry[1])])
	if not percent_bits.is_empty():
		text += "while equipped: " + ", ".join(percent_bits) + "\n"
	return text


func _format_number(value: float) -> String:
	var text := "%.2f" % value
	while text.ends_with("0"):
		text = text.substr(0, text.length() - 1)
	if text.ends_with("."):
		text = text.substr(0, text.length() - 1)
	return text


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
	if hover_info_label == null:
		return
	if dragging_bone_id != "":
		return
	# Moving the cursor off a card falls back to whatever is selected rather
	# than blanking the panel, so a selection stays inspectable while the
	# player reaches for a slot.
	if selected_bone_id != "":
		show_bone_info(selected_bone_id)
		return
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

	inventory_filter_dropdown = _make_inventory_dropdown()
	inventory_filter_dropdown.name = "InventoryFilterDropdown"
	for entry in INVENTORY_FILTER_OPTIONS:
		inventory_filter_dropdown.add_item(str(entry["text"]))
		inventory_filter_dropdown.set_item_metadata(inventory_filter_dropdown.item_count - 1, str(entry["category"]))
	inventory_filter_dropdown.item_selected.connect(_on_inventory_filter_selected)
	inventory_tabs_container.add_child(inventory_filter_dropdown)

	inventory_quality_label = Label.new()
	inventory_quality_label.text = "Quality"
	inventory_quality_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_quality_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_tabs_container.add_child(inventory_quality_label)

	inventory_quality_dropdown = _make_inventory_dropdown()
	inventory_quality_dropdown.name = "InventoryQualityDropdown"
	inventory_quality_dropdown.add_item("All")
	inventory_quality_dropdown.set_item_metadata(0, "all")
	for quality_id in BoneQualityService.QUALITY_ORDER:
		inventory_quality_dropdown.add_item(BoneQualityService.display_name_for(str(quality_id)))
		inventory_quality_dropdown.set_item_metadata(inventory_quality_dropdown.item_count - 1, str(quality_id))
	inventory_quality_dropdown.item_selected.connect(_on_inventory_quality_selected)
	inventory_tabs_container.add_child(inventory_quality_dropdown)

	inventory_sort_label_control = Label.new()
	inventory_sort_label_control.text = "Sort"
	inventory_sort_label_control.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_sort_label_control.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_tabs_container.add_child(inventory_sort_label_control)

	inventory_sort_dropdown = _make_inventory_dropdown()
	inventory_sort_dropdown.name = "InventorySortDropdown"
	for entry in INVENTORY_SORT_OPTIONS:
		inventory_sort_dropdown.add_item(str(entry["text"]))
		inventory_sort_dropdown.set_item_metadata(inventory_sort_dropdown.item_count - 1, str(entry["mode"]))
	inventory_sort_dropdown.item_selected.connect(_on_inventory_sort_selected)
	inventory_tabs_container.add_child(inventory_sort_dropdown)

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


# Shared styling for every dropdown in the panel; the stock OptionButton theme
# is dark grey and reads as a different application dropped into the parchment.
func _make_inventory_dropdown() -> OptionButton:
	var dropdown := OptionButton.new()
	dropdown.process_mode = Node.PROCESS_MODE_ALWAYS
	dropdown.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var background := Color(1.0, 1.0, 1.0, 0.55)
		var border := Color(0.87, 0.63, 0.19, 0.85)
		if state == "hover" or state == "pressed":
			background = Color(1.0, 1.0, 1.0, 0.78)
			border = Color(0.0, 0.78, 0.78, 0.85)
		dropdown.add_theme_stylebox_override(state, _make_inventory_style(background, border, 1, 0))
	for color_role in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		dropdown.add_theme_color_override(color_role, Color(0.03, 0.33, 0.38, 1.0))

	var popup := dropdown.get_popup()
	popup.add_theme_stylebox_override("panel", _make_inventory_style(Color(0.99, 0.985, 0.955, 0.99), Color(0.87, 0.63, 0.19, 0.96), 2, 0))
	popup.add_theme_stylebox_override("hover", _make_inventory_style(Color(0.0, 0.78, 0.78, 0.22), Color(0.0, 0.78, 0.78, 0.0), 0, 0))
	popup.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	popup.add_theme_color_override("font_hover_color", Color(0.03, 0.33, 0.38, 1.0))
	return dropdown


func _on_inventory_quality_selected(index: int) -> void:
	if inventory_quality_dropdown == null:
		return
	inventory_quality_filter = str(inventory_quality_dropdown.get_item_metadata(index))
	rebuild_item_tiles()
	update_inventory_ui()


func _on_inventory_sort_selected(index: int) -> void:
	if inventory_sort_dropdown == null:
		return
	inventory_sort_mode = str(inventory_sort_dropdown.get_item_metadata(index))
	rebuild_item_tiles()
	update_inventory_ui()


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
		_refresh_builds_screen()
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
	# Builds is its own section: the inventory's filters do not apply to it,
	# and the header switches so "Builds" is the dominant title instead of
	# competing with "Inventory".
	if inventory_title_label != null:
		inventory_title_label.text = "Builds" if showing_builds else "Inventory"
	for filter_control in [inventory_filter_label, inventory_filter_dropdown, inventory_quality_dropdown, inventory_sort_dropdown]:
		if filter_control != null:
			(filter_control as Control).visible = not showing_builds
	for secondary_control in [inventory_quality_label, inventory_sort_label_control]:
		if secondary_control != null:
			(secondary_control as Control).visible = not showing_builds and not inventory_last_very_compact


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
	inventory_last_very_compact = very_compact
	if inventory_filter_label != null:
		inventory_filter_label.add_theme_font_size_override("font_size", tab_font_size)
		inventory_filter_label.custom_minimum_size = Vector2(0, tab_height)
	# Three dropdowns share the row now, so each takes a smaller slice and the
	# secondary labels drop out first when the row gets tight.
	var dropdown_width := clampf(float(content_width) * 0.13, 104.0, 210.0)
	for dropdown in [inventory_filter_dropdown, inventory_quality_dropdown, inventory_sort_dropdown]:
		if dropdown == null:
			continue
		dropdown.custom_minimum_size = Vector2(dropdown_width, float(tab_height))
		dropdown.add_theme_font_size_override("font_size", tab_font_size)
	for secondary_label in [inventory_quality_label, inventory_sort_label_control]:
		if secondary_label == null:
			continue
		secondary_label.add_theme_font_size_override("font_size", tab_font_size)
		secondary_label.custom_minimum_size = Vector2(0, tab_height)
		secondary_label.visible = not very_compact and inventory_category != "builds"
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

	builds_report_compact = compact or very_compact
	var box_margin: int = 8 if very_compact else (11 if compact else 14)
	_set_margin(builds_box_margin, box_margin, box_margin, box_margin, box_margin)

	# Sidebar keeps roughly a quarter of the width; the detail panel owns the
	# rest and is never squeezed to fit more cards -- the list scrolls.
	if builds_sidebar_panel != null:
		builds_sidebar_panel.custom_minimum_size = Vector2(clampf(float(content_width) * 0.25, 216.0, 320.0), 0.0)

	# The preview is the visual anchor: it shrinks last and only so far.
	if builds_detail_preview_container != null:
		var preview_size := Vector2(250, 340)
		if very_compact:
			preview_size = Vector2(160, 215)
		elif compact:
			preview_size = Vector2(185, 250)
		builds_detail_preview_container.custom_minimum_size = preview_size

	var card_size := Vector2(150, 64)
	if very_compact:
		card_size = Vector2(112, 54)
	elif compact:
		card_size = Vector2(132, 58)
	for slot_id in builds_slot_cards:
		var card := (builds_slot_cards[slot_id] as Dictionary).get("card") as Control
		if card != null:
			card.custom_minimum_size = card_size

	if builds_equipment_table_panel != null:
		builds_equipment_table_panel.custom_minimum_size = Vector2(230.0 if very_compact else (280.0 if compact else 330.0), 0.0)

	if build_preset_status_label != null:
		build_preset_status_label.add_theme_font_size_override("font_size", 11 if very_compact else 12)


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
		widget.resize(_paper_doll_slot_size(str(slot)) * doll_scale)


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


# Builds screen: a sidebar listing every saved build, and a wide detail panel
# describing the ONE selected build. Everything in the detail panel is derived
# from a single resolved snapshot (PlayerEquipmentBuildsComponent.get_build_report)
# so the piece table, slot cards, stats, composition, effects and preview can
# never disagree about what the build contains.
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
	_set_margin(margin, 14, 10, 14, 10)
	box.add_child(margin)

	# The screen's title is the main inventory header, which switches to
	# "Builds" while this tab is active (_refresh_inventory_mode), so the page
	# itself carries no second title competing with it.
	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	margin.add_child(columns)

	columns.add_child(_build_builds_sidebar())
	columns.add_child(_build_builds_detail_panel())

	call_deferred("_refresh_builds_screen")
	return scroll


func _build_builds_sidebar() -> Control:
	var panel := PanelContainer.new()
	panel.name = "SavedBuildsSidebar"
	# Fixed share of the width (sized by the responsive pass): the detail
	# panel must never be squeezed to fit more build cards, so the list
	# scrolls instead of growing.
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(250, 0)
	panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.22), Color(0.87, 0.63, 0.19, 0.60), 1, 0))
	builds_sidebar_panel = panel

	var margin := MarginContainer.new()
	_set_margin(margin, 10, 10, 10, 10)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var heading := Label.new()
	heading.text = "Saved Builds"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	column.add_child(heading)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	builds_sidebar_list = VBoxContainer.new()
	builds_sidebar_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	builds_sidebar_list.add_theme_constant_override("separation", 8)
	scroll.add_child(builds_sidebar_list)
	return panel


func _build_builds_detail_panel() -> Control:
	var panel := PanelContainer.new()
	panel.name = "BuildDetailPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.22), Color(0.87, 0.63, 0.19, 0.60), 1, 0))
	builds_detail_panel = panel

	var margin := MarginContainer.new()
	_set_margin(margin, 14, 10, 14, 10)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	# Header: build name plus one state badge. The bottom banner repeats the
	# state deliberately (same phrase, never a synonym).
	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 10)
	column.add_child(header)

	builds_detail_title = Label.new()
	builds_detail_title.text = "Build"
	builds_detail_title.add_theme_font_size_override("font_size", 20)
	builds_detail_title.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	header.add_child(builds_detail_title)

	builds_header_badge = Label.new()
	builds_header_badge.add_theme_font_size_override("font_size", 12)
	builds_header_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(builds_header_badge)

	# Upper zone, mirroring the reference: six slot cards hugging the preview
	# (head above, torso below, arms/legs flanking) and the Equipment table on
	# the right. The table is the primary read of the build's contents; the
	# cards echo it spatially.
	builds_upper_row = HBoxContainer.new()
	builds_upper_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	builds_upper_row.add_theme_constant_override("separation", 10)
	column.add_child(builds_upper_row)

	var left_col := VBoxContainer.new()
	left_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left_col.add_theme_constant_override("separation", 24)
	left_col.add_child(_make_build_slot_card(EquipmentRulesService.SLOT_LEFT_ARM, "L. Arm"))
	left_col.add_child(_make_build_slot_card(EquipmentRulesService.SLOT_LEFT_LEG, "L. Leg"))
	var lead_spacer := Control.new()
	lead_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lead_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	builds_upper_row.add_child(lead_spacer)
	builds_upper_row.add_child(left_col)

	var centre_col := VBoxContainer.new()
	centre_col.add_theme_constant_override("separation", 6)
	var head_card := _make_build_slot_card(EquipmentRulesService.SLOT_HEAD, "Head")
	head_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	centre_col.add_child(head_card)

	var preview_frame := PanelContainer.new()
	preview_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.46), 1, 0))
	builds_detail_preview_container = _build_build_preview(BUILD_DETAIL_PREVIEW_KEY)
	# The preview is the visual anchor of the panel; the responsive pass
	# scales this floor up on larger screens.
	builds_detail_preview_container.custom_minimum_size = Vector2(250, 340)
	preview_frame.add_child(builds_detail_preview_container)
	builds_detail_preview_frame = preview_frame
	centre_col.add_child(preview_frame)

	var torso_card := _make_build_slot_card(EquipmentRulesService.SLOT_TORSO, "Torso")
	torso_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	centre_col.add_child(torso_card)
	builds_upper_row.add_child(centre_col)

	var right_col := VBoxContainer.new()
	right_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right_col.add_theme_constant_override("separation", 24)
	right_col.add_child(_make_build_slot_card(EquipmentRulesService.SLOT_RIGHT_ARM, "R. Arm"))
	right_col.add_child(_make_build_slot_card(EquipmentRulesService.SLOT_RIGHT_LEG, "R. Leg"))
	builds_upper_row.add_child(right_col)

	var upper_spacer := Control.new()
	upper_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upper_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	builds_upper_row.add_child(upper_spacer)

	builds_upper_row.add_child(_build_equipment_table())

	# Lower zone: three compact cards. SHRINK_BEGIN keeps them at content
	# height instead of stretching into the dead space the old layout had.
	var lower := HBoxContainer.new()
	lower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	lower.add_theme_constant_override("separation", 10)
	column.add_child(lower)

	builds_lower_cards.clear()
	builds_stats_list = _build_detail_card(lower, "Stats")
	builds_composition_list = _build_detail_card(lower, "Build Composition")
	builds_effects_list = _build_detail_card(lower, "Active effects")

	# One banner, one phrase, tinted by state.
	builds_banner_panel = PanelContainer.new()
	builds_banner_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(builds_banner_panel)
	var banner_margin := MarginContainer.new()
	_set_margin(banner_margin, 10, 5, 10, 5)
	builds_banner_panel.add_child(banner_margin)
	builds_match_banner = Label.new()
	builds_match_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	builds_match_banner.add_theme_font_size_override("font_size", 14)
	banner_margin.add_child(builds_match_banner)

	# Actions sit directly under the banner, inside the panel they act on.
	column.add_child(_build_builds_action_row())

	build_preset_status_label = Label.new()
	build_preset_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	build_preset_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_preset_status_label.add_theme_font_size_override("font_size", 12)
	build_preset_status_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	column.add_child(build_preset_status_label)
	return panel


# One slot card hugging the preview: colour swatch, slot name, piece name and
# a quality badge. Fed exclusively from the same report the table reads.
func _make_build_slot_card(slot_id: String, title: String) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(150, 64)
	card.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.30), Color(0.87, 0.63, 0.19, 0.60), 1, 0))

	var margin := MarginContainer.new()
	_set_margin(margin, 7, 5, 7, 5)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	margin.add_child(row)

	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(22, 22)
	swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	swatch.color = Color(0.87, 0.63, 0.19, 0.14)
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(swatch)

	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_theme_constant_override("separation", 0)
	row.add_child(texts)

	var slot_label := Label.new()
	slot_label.text = title
	slot_label.add_theme_font_size_override("font_size", 12)
	slot_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	texts.add_child(slot_label)

	var piece_label := Label.new()
	piece_label.clip_text = true
	piece_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	piece_label.add_theme_font_size_override("font_size", 12)
	piece_label.add_theme_color_override("font_color", Color(0.16, 0.20, 0.22, 1.0))
	texts.add_child(piece_label)

	var quality_label := Label.new()
	quality_label.add_theme_font_size_override("font_size", 10)
	quality_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	texts.add_child(quality_label)

	builds_slot_cards[slot_id] = {
		"card": card,
		"swatch": swatch,
		"piece": piece_label,
		"quality": quality_label,
	}
	return card


func _build_detail_card(parent: HBoxContainer, heading_text: String) -> VBoxContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	card.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.26), Color(0.87, 0.63, 0.19, 0.55), 1, 0))
	parent.add_child(card)
	builds_lower_cards.append(card)

	var margin := MarginContainer.new()
	_set_margin(margin, 12, 7, 12, 8)
	card.add_child(margin)

	var wrapper := VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", 4)
	margin.add_child(wrapper)

	var heading := Label.new()
	heading.text = heading_text
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 15)
	heading.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	wrapper.add_child(heading)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 2)
	wrapper.add_child(list)
	return list


func _build_equipment_table() -> Control:
	var panel := PanelContainer.new()
	panel.name = "EquipmentTable"
	# Fixed-ish width on the right edge: letting it EXPAND was what pushed the
	# quality column to the far side of a huge empty row.
	panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size = Vector2(330, 0)
	panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.26), Color(0.87, 0.63, 0.19, 0.55), 1, 0))
	builds_equipment_table_panel = panel

	var margin := MarginContainer.new()
	_set_margin(margin, 12, 8, 12, 8)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var heading := Label.new()
	heading.text = "Equipment"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 16)
	heading.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	column.add_child(heading)

	builds_equipment_rows.clear()
	for slot_id in BUILD_TABLE_SLOTS:
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 8)
		column.add_child(row)

		var slot_label := Label.new()
		slot_label.text = EquipmentRulesService.slot_display_name(str(slot_id))
		slot_label.custom_minimum_size = Vector2(62, 0)
		slot_label.add_theme_font_size_override("font_size", 13)
		slot_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
		row.add_child(slot_label)

		var piece_label := Label.new()
		piece_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		piece_label.clip_text = true
		piece_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		piece_label.add_theme_font_size_override("font_size", 13)
		piece_label.add_theme_color_override("font_color", Color(0.16, 0.20, 0.22, 1.0))
		row.add_child(piece_label)

		var quality_badge := Label.new()
		quality_badge.custom_minimum_size = Vector2(66, 0)
		quality_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		quality_badge.add_theme_font_size_override("font_size", 11)
		row.add_child(quality_badge)

		builds_equipment_rows[str(slot_id)] = {
			"row": row,
			"piece": piece_label,
			"quality": quality_badge,
		}
	return panel


func _build_builds_action_row() -> Control:
	builds_action_row = HBoxContainer.new()
	builds_action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	builds_action_row.add_theme_constant_override("separation", 10)

	builds_save_button = _make_build_preset_button("Save Current")
	builds_save_button.pressed.connect(_on_save_current_pressed)
	builds_action_row.add_child(builds_save_button)

	builds_apply_button = _make_build_preset_button("Apply")
	builds_apply_button.pressed.connect(_on_apply_pressed)
	builds_action_row.add_child(builds_apply_button)

	builds_rename_button = _make_build_preset_button("Rename")
	builds_rename_button.pressed.connect(_on_rename_pressed)
	builds_action_row.add_child(builds_rename_button)

	builds_delete_button = _make_build_preset_button("Delete")
	builds_delete_button.add_theme_color_override("font_color", Color(0.62, 0.20, 0.16, 1.0))
	builds_delete_button.pressed.connect(_on_delete_pressed)
	builds_action_row.add_child(builds_delete_button)

	# Rename needs text entry, which this panel had none of. Hidden until the
	# player asks for it so the action row stays uncluttered.
	builds_rename_edit = LineEdit.new()
	builds_rename_edit.placeholder_text = "New name, then Enter"
	builds_rename_edit.custom_minimum_size = Vector2(190, 0)
	builds_rename_edit.process_mode = Node.PROCESS_MODE_ALWAYS
	builds_rename_edit.visible = false
	builds_rename_edit.text_submitted.connect(_on_rename_submitted)
	builds_action_row.add_child(builds_rename_edit)
	return builds_action_row


# Small filled badge: coloured background, dark text of the same hue, so state
# and quality never rely on colour alone -- the text is always there.
func _style_badge(label: Label, text: String, base_color: Color) -> void:
	if label == null:
		return
	label.text = text
	label.visible = text != ""
	var style := StyleBoxFlat.new()
	style.bg_color = Color(base_color.r, base_color.g, base_color.b, 0.18)
	style.border_color = Color(base_color.r, base_color.g, base_color.b, 0.55)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	label.add_theme_stylebox_override("normal", style)
	label.add_theme_color_override("font_color", base_color.darkened(0.35))


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
	for index in build_preview_rigs.keys():
		_sync_build_preview(int(index))


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

	# The detail preview mirrors whichever build is selected; each sidebar
	# thumbnail renders its own build.
	var state_index := builds_selected_index if index == BUILD_DETAIL_PREVIEW_KEY else index
	var build_state := _raw_build_state(state_index)
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
	return builds_component.call("build_slots", index) as Dictionary


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
	_refresh_builds_screen()


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
	_refresh_builds_screen()
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
	var button := _confirm_button_for(action)
	if button != null:
		button.text = "Confirm?"
	# The visible half of the two-press confirmation: the button changes AND
	# the status line spells it out, so Delete is never a silent double-tap.
	_set_build_preset_status("Press " + button_text + " again to confirm.")
	build_preset_confirm_timer = get_tree().create_timer(BUILD_PRESET_CONFIRM_WINDOW)
	build_preset_confirm_timer.timeout.connect(_on_build_preset_confirm_timeout.bind(key))
	return false


func _on_build_preset_confirm_timeout(expected_key: String) -> void:
	if build_preset_armed_action == expected_key:
		_disarm_build_preset_confirmation()
		_set_build_preset_status("Confirmation timed out.")


func _confirm_button_for(action: String) -> Button:
	match action:
		"apply":
			return builds_apply_button
		"save":
			return builds_save_button
		"delete":
			return builds_delete_button
	return null


func _disarm_build_preset_confirmation() -> void:
	build_preset_armed_action = ""
	build_preset_confirm_timer = null
	var defaults := {"save": "Save Current", "apply": "Apply", "delete": "Delete"}
	for action in defaults:
		var button := _confirm_button_for(str(action))
		if button != null and is_instance_valid(button):
			button.text = str(defaults[action])


# --- builds screen state -------------------------------------------------

func _on_new_build_pressed() -> void:
	if player == null or not player.has_method("create_equipment_build"):
		return
	builds_selected_index = int(player.call("create_equipment_build"))
	_disarm_build_preset_confirmation()
	_set_build_preset_status("Created " + _build_name_for(builds_selected_index) + ".")
	_refresh_builds_screen()


func _select_build(index: int) -> void:
	if builds_selected_index == index:
		return
	builds_selected_index = index
	# Selecting only changes what is being LOOKED at; it never equips.
	_disarm_build_preset_confirmation()
	_refresh_builds_screen()


func _on_save_current_pressed() -> void:
	if player == null or not player.has_method("save_equipment_build"):
		return
	if not _build_slot_is_empty(builds_selected_index):
		if not _consume_or_arm_confirmation("save", builds_selected_index, "Save Current"):
			return
	var result := player.call("save_equipment_build", builds_selected_index) as Dictionary
	_set_build_preset_status(str(result.get("message", "")))
	_refresh_builds_screen()


func _on_apply_pressed() -> void:
	if player == null or not player.has_method("apply_equipment_build"):
		return
	if not _consume_or_arm_confirmation("apply", builds_selected_index, "Apply"):
		return
	var result := player.call("apply_equipment_build", builds_selected_index) as Dictionary
	_set_build_preset_status(str(result.get("message", "")))
	_refresh_builds_screen()
	if bool(result.get("ok", false)):
		notify_equipment_changed()


func _on_rename_pressed() -> void:
	if builds_rename_edit == null:
		return
	builds_rename_edit.visible = not builds_rename_edit.visible
	if builds_rename_edit.visible:
		builds_rename_edit.text = _build_name_for(builds_selected_index)
		builds_rename_edit.grab_focus()
		_set_build_preset_status("Type a new name and press Enter.")


func _on_rename_submitted(new_name: String) -> void:
	if player == null or not player.has_method("rename_equipment_build"):
		return
	var result := player.call("rename_equipment_build", builds_selected_index, new_name) as Dictionary
	if builds_rename_edit != null:
		builds_rename_edit.visible = false
	# Renaming touches the label only: pieces and stats are untouched, so the
	# refresh below re-reads the same snapshot it had before.
	_set_build_preset_status(str(result.get("message", "")))
	_refresh_builds_screen()


func _on_delete_pressed() -> void:
	if player == null or not player.has_method("delete_equipment_build"):
		return
	# Two-press confirmation with a visible prompt (set by
	# _consume_or_arm_confirmation): "Press Delete again to confirm."
	if not _consume_or_arm_confirmation("delete", builds_selected_index, "Delete"):
		return
	var result := player.call("delete_equipment_build", builds_selected_index) as Dictionary
	builds_selected_index = _first_build_index()
	_set_build_preset_status(str(result.get("message", "")))
	_refresh_builds_screen()


func _first_build_index() -> int:
	var indices := _build_indices()
	return int(indices[0]) if not indices.is_empty() else 1


func _build_indices() -> Array:
	if player == null or not player.has_method("get_equipment_build_indices"):
		return []
	return player.call("get_equipment_build_indices") as Array


func _build_name_for(index: int) -> String:
	var report := _build_report_for(index)
	return str(report.get("name", "Build " + str(index)))


func _build_report_for(index: int) -> Dictionary:
	if player == null or not player.has_method("get_equipment_build_report"):
		return {}
	return player.call("get_equipment_build_report", index) as Dictionary


# Rebuilds the whole screen from ONE report per build. Called after every
# action, so the sidebar, slot cards, table, stats, composition, effects,
# banner, preview and button states can never drift apart.
func _refresh_builds_screen() -> void:
	if builds_sidebar_list == null:
		return
	var indices := _build_indices()
	if not indices.has(builds_selected_index) and not indices.is_empty():
		builds_selected_index = int(indices[0])

	for child in builds_sidebar_list.get_children():
		child.queue_free()
	for index in indices:
		builds_sidebar_list.add_child(_make_build_sidebar_card(int(index)))
	# New Build lives at the end of the list itself, not marooned at the
	# bottom of the screen.
	builds_sidebar_list.add_child(_make_new_build_card())

	var report := _build_report_for(builds_selected_index)
	_apply_build_report_to_detail(report)
	call_deferred("_sync_all_build_previews")


func _make_build_sidebar_card(index: int) -> Control:
	var report := _build_report_for(index)
	var selected: bool = index == builds_selected_index
	var state := str(report.get("state", "Empty"))
	var slots: Dictionary = report.get("slots", {})
	var missing := int(report.get("missing_count", 0))

	var card := Button.new()
	card.focus_mode = Control.FOCUS_NONE
	card.process_mode = Node.PROCESS_MODE_ALWAYS
	card.custom_minimum_size = Vector2(0, 78)
	card.pressed.connect(_select_build.bind(index))
	# Selection is carried by border weight AND fill, never colour alone.
	var background := Color(1.0, 0.94, 0.82, 0.90) if selected else Color(1.0, 1.0, 1.0, 0.16)
	var border := Color(0.0, 0.60, 0.62, 1.0) if selected else Color(0.87, 0.63, 0.19, 0.55)
	card.add_theme_stylebox_override("normal", _make_inventory_style(background, border, 3 if selected else 1, 0))
	card.add_theme_stylebox_override("hover", _make_inventory_style(background.lightened(0.05), border, 3 if selected else 1, 0))
	card.add_theme_stylebox_override("pressed", _make_inventory_style(background, border, 3, 0))

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_set_margin(margin, 8, 6, 8, 6)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 9)
	margin.add_child(row)

	# A real render of the build, like the reference: one small isolated
	# viewport per card. Cards are few, and each rebuild replaces the old rig.
	var mini := _build_build_preview(index)
	mini.custom_minimum_size = Vector2(54, 70)
	row.add_child(mini)

	var texts := VBoxContainer.new()
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_theme_constant_override("separation", 1)
	row.add_child(texts)

	var name_label := Label.new()
	name_label.text = str(report.get("name", "Build " + str(index)))
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.add_child(name_label)

	var state_label := Label.new()
	var state_text := state
	if state == "Missing parts":
		state_text = "Missing %d part%s" % [missing, "s" if missing != 1 else ""]
	state_label.text = state_text
	state_label.clip_text = true
	state_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	state_label.add_theme_font_size_override("font_size", 11)
	state_label.add_theme_color_override("font_color", _build_state_color(state))
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.add_child(state_label)

	var count_label := Label.new()
	count_label.text = "%d / 6 parts" % _build_parts_available(state, slots, missing)
	count_label.add_theme_font_size_override("font_size", 10)
	count_label.add_theme_color_override("font_color", Color(0.40, 0.40, 0.40, 1.0))
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.add_child(count_label)

	# The card clips long names/states, so the untruncated version is a hover
	# away instead of lost.
	card.tooltip_text = "%s\n%s" % [name_label.text, state_label.text]
	return card


# Out of the six body slots, how many this build can actually put on: the
# fixed head plus every saved piece that is still carried. An empty build is
# 0/6 -- it would change nothing when applied.
func _build_parts_available(state: String, slots: Dictionary, missing: int) -> int:
	if state == "Empty":
		return 0
	return 1 + maxi(0, slots.size() - missing)


func _make_new_build_card() -> Control:
	var card := Button.new()
	card.text = "+   New Build"
	card.focus_mode = Control.FOCUS_NONE
	card.process_mode = Node.PROCESS_MODE_ALWAYS
	card.custom_minimum_size = Vector2(0, 44)
	card.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 0.85))
	card.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.06), Color(0.87, 0.63, 0.19, 0.45), 1, 0))
	card.add_theme_stylebox_override("hover", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.28), Color(0.0, 0.78, 0.78, 0.75), 1, 0))
	card.pressed.connect(_on_new_build_pressed)
	return card


func _build_state_color(state: String) -> Color:
	match state:
		"Currently Equipped":
			return Color(0.10, 0.45, 0.25, 1.0)
		"Missing parts":
			return Color(0.62, 0.20, 0.16, 1.0)
		"Empty":
			return Color(0.42, 0.42, 0.42, 1.0)
	return Color(0.16, 0.34, 0.52, 1.0)


func _apply_build_report_to_detail(report: Dictionary) -> void:
	if builds_detail_title == null:
		return
	var state := str(report.get("state", "Empty"))
	var missing := int(report.get("missing_count", 0))
	builds_detail_title.text = str(report.get("name", "Build"))
	_style_badge(builds_header_badge, state, _build_state_color(state))

	# --- slot cards and equipment table: same slots dict for both ---------
	var slots: Dictionary = report.get("slots", {})
	var head_id := ""
	if player != null and player.has_method("get_equipped_bone_for_slot"):
		head_id = str(player.call("get_equipped_bone_for_slot", EquipmentRulesService.SLOT_HEAD))
	for slot_id in BUILD_TABLE_SLOTS:
		_fill_slot_widgets(str(slot_id), slots.get(str(slot_id), {}), head_id)

	# --- stats ------------------------------------------------------------
	_clear_children(builds_stats_list)
	var stats: Dictionary = report.get("stats", {})
	var comparison: Dictionary = report.get("comparison", {})
	if state == "Empty":
		builds_stats_list.add_child(_make_dim_row("No stats"))
	elif missing > 0:
		# Stats are only computed from resolvable pieces; a build that cannot
		# be applied is not presented as if its numbers were reliable.
		builds_stats_list.add_child(_make_dim_row("Unavailable - missing parts"))
	else:
		for entry in [["health", "Health"], ["damage", "Damage"], ["speed", "Speed"], ["reach", "Reach"], ["weight", "Weight"]]:
			var key := str(entry[0])
			if not stats.has(key):
				continue
			builds_stats_list.add_child(_make_stat_row(str(entry[1]), float(stats[key]), float(comparison.get(key, 0.0))))

	# --- composition ------------------------------------------------------
	_clear_children(builds_composition_list)
	var counts: Dictionary = report.get("quality_counts", {})
	if state == "Empty" or counts.is_empty():
		builds_composition_list.add_child(_make_dim_row("No parts saved"))
	else:
		var ordered: Array = BoneQualityService.QUALITY_ORDER.duplicate()
		ordered.reverse()
		for quality_id in ordered:
			var count := int(counts.get(str(quality_id), 0))
			# Zero-count tiers are omitted: listing all five every time buries
			# the ones the build actually has.
			if count <= 0:
				continue
			builds_composition_list.add_child(_make_composition_row(str(quality_id), count))
		if missing > 0:
			builds_composition_list.add_child(_make_dim_row("%d of these missing" % missing))

	# --- effects ----------------------------------------------------------
	_clear_children(builds_effects_list)
	var effects: Array = report.get("effects", [])
	if missing > 0:
		builds_effects_list.add_child(_make_dim_row("Unavailable - missing parts"))
	elif effects.is_empty():
		builds_effects_list.add_child(_make_dim_row("No active effects"))
	else:
		for effect in effects:
			var row := Label.new()
			row.text = str(effect)
			row.add_theme_font_size_override("font_size", 13)
			row.add_theme_color_override("font_color", Color(0.16, 0.20, 0.22, 1.0))
			builds_effects_list.add_child(row)

	# --- banner: one phrase, tinted by state ------------------------------
	var banner_color := _build_state_color(state)
	var banner_text := state
	match state:
		"Missing parts":
			banner_text = "Missing %d part%s - build cannot be applied" % [missing, "s" if missing != 1 else ""]
		"Empty":
			banner_text = "Empty build - save current equipment into it"
		"Saved":
			banner_text = "Saved build - differs from current equipment"
	builds_match_banner.text = banner_text
	builds_match_banner.add_theme_color_override("font_color", banner_color.darkened(0.15))
	if builds_banner_panel != null:
		builds_banner_panel.add_theme_stylebox_override("panel", _make_inventory_style(
			Color(banner_color.r, banner_color.g, banner_color.b, 0.12),
			Color(banner_color.r, banner_color.g, banner_color.b, 0.45), 1, 0))
		# The untruncated missing-piece names live on the banner.
		var missing_names: Array[String] = []
		for slot_id in slots:
			var entry: Dictionary = slots[slot_id]
			if not bool(entry.get("found", false)):
				missing_names.append(BoneRulesService.display_name_with_slot(str(entry.get("instance_id", ""))))
		var banner_tooltip := ""
		if not missing_names.is_empty():
			banner_tooltip = "Missing: " + ", ".join(missing_names)
		builds_banner_panel.tooltip_text = banner_tooltip

	# --- button availability ---------------------------------------------
	if builds_apply_button != null:
		# Empty: nothing to apply. Missing: must not apply partially.
		# Currently equipped: applying would be a no-op, so it is disabled to
		# say so rather than silently doing nothing.
		builds_apply_button.disabled = state == "Empty" or missing > 0 or bool(report.get("matches_current", false))
	if builds_delete_button != null:
		builds_delete_button.disabled = _build_indices().size() <= 1
	if builds_rename_button != null:
		builds_rename_button.disabled = false


func _fill_slot_widgets(slot_id: String, entry: Dictionary, head_id: String) -> void:
	var table: Dictionary = builds_equipment_rows.get(slot_id, {})
	var card: Dictionary = builds_slot_cards.get(slot_id, {})
	var piece_labels: Array = []
	if table.has("piece"):
		piece_labels.append(table["piece"])
	if card.has("piece"):
		piece_labels.append(card["piece"])

	var name_text := ""
	var tooltip_note := ""
	var name_color := Color(0.16, 0.20, 0.22, 1.0)
	var badge_text := ""
	var badge_color := Color(0.42, 0.42, 0.42, 1.0)
	var swatch_color := Color(0.87, 0.63, 0.19, 0.14)

	if slot_id == EquipmentRulesService.SLOT_HEAD and head_id != "":
		# The head is the fixed core: never saved in a build, always worn, so
		# both the card and the table show the head that applying would keep.
		name_text = BoneRulesService.display_name_with_slot(head_id)
		badge_text = BoneQualityService.display_name_for(BoneInstanceService.quality_id_of(head_id))
		badge_color = BoneQualityService.color_for(BoneInstanceService.quality_id_of(head_id))
		swatch_color = BoneRulesService.color_for(head_id)
	elif entry.is_empty():
		name_text = "-"
		badge_text = "Empty"
	else:
		var instance_id := str(entry.get("instance_id", ""))
		name_text = BoneRulesService.display_name_with_slot(instance_id)
		swatch_color = BoneRulesService.color_for(instance_id)
		if bool(entry.get("found", false)):
			# The badge always shows the quality of the piece that will
			# actually be equipped; when that is a substitute for a lost
			# saved copy, the tooltip says so instead of staying silent.
			var quality_id := str(entry.get("quality_id", ""))
			badge_text = BoneQualityService.display_name_for(quality_id)
			badge_color = BoneQualityService.color_for(quality_id)
			if bool(entry.get("substituted", false)):
				tooltip_note = "  (replaces the saved copy - different quality)"
		else:
			# Missing replaces the quality badge entirely so the two states
			# can never be confused.
			badge_text = "Missing"
			badge_color = Color(0.82, 0.24, 0.20, 1.0)
			name_color = Color(0.62, 0.20, 0.16, 1.0)
			swatch_color.a = 0.35

	for piece_label in piece_labels:
		var label := piece_label as Label
		label.text = name_text
		label.tooltip_text = (name_text + tooltip_note) if name_text != "-" else ""
		label.add_theme_color_override("font_color", name_color)
	if table.has("quality"):
		_style_badge(table["quality"] as Label, badge_text, badge_color)
	if card.has("quality"):
		_style_badge(card["quality"] as Label, badge_text, badge_color)
	if card.has("swatch"):
		(card["swatch"] as ColorRect).color = swatch_color


func _make_stat_row(stat_name: String, value: float, delta: float) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var name_label := Label.new()
	name_label.text = stat_name
	name_label.custom_minimum_size = Vector2(64, 0)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color(0.16, 0.20, 0.22, 1.0))
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.text = _format_number(value)
	value_label.custom_minimum_size = Vector2(44, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 13)
	value_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	row.add_child(value_label)

	# Zero deltas render nothing at all -- no "(+0)".
	if absf(delta) > 0.0:
		var delta_label := Label.new()
		delta_label.text = "%s%s" % ["+" if delta > 0.0 else "", _format_number(delta)]
		delta_label.add_theme_font_size_override("font_size", 12)
		# Sign carries the meaning; colour only supports it.
		delta_label.add_theme_color_override("font_color", Color(0.10, 0.45, 0.25, 1.0) if delta > 0.0 else Color(0.62, 0.20, 0.16, 1.0))
		row.add_child(delta_label)
	return row


func _make_composition_row(quality_id: String, count: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)

	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(10, 10)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.color = BoneQualityService.color_for(quality_id)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dot)

	var name_label := Label.new()
	name_label.text = BoneQualityService.display_name_for(quality_id)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color(0.16, 0.20, 0.22, 1.0))
	row.add_child(name_label)

	var count_label := Label.new()
	count_label.text = str(count)
	count_label.add_theme_font_size_override("font_size", 13)
	count_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	row.add_child(count_label)
	return row


func _make_dim_row(text: String) -> Control:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45, 1.0))
	return label


func _clear_children(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()


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
		_place_slot(doll, slot_id, str(slot_titles[slot_id]), PAPER_DOLL_SLOT_POSITIONS[slot_id], _paper_doll_slot_size(slot_id))
	return doll


func _paper_doll_slot_size(slot_id: String) -> Vector2:
	return PAPER_DOLL_WIDE_SLOT_SIZE if PAPER_DOLL_WIDE_SLOTS.has(slot_id) else PAPER_DOLL_SLOT_SIZE


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
	# Pieces stack only when they are the same type AND quality AND mutation
	# (BoneInstanceService.stack_key_for). Grouping by bone_id alone would put
	# a Frail and a Pristine arm in one pile and hide that they roll different
	# effective stats. Each group keeps a representative instance_id, so the
	# unit the player drags out of a stack is a real piece with a real
	# identity rather than an anonymous copy.
	var counts_by_key: Dictionary = {}
	var representative_by_key: Dictionary = {}
	var visible_order: Array[String] = []
	for bone_id in _bone_inventory():
		var id := str(bone_id)
		if not _bone_matches_inventory_category(id):
			continue
		# Quality filter stacks on top of the body-slot filter: both must
		# pass, so "Arms" + "Strong" shows only strong arms.
		if not _bone_matches_quality_filter(id):
			continue
		var equipped_count := int(equipped_counts.get(id, 0))
		var skipped_count := int(skipped_equipped_counts.get(id, 0))
		if skipped_count < equipped_count:
			skipped_equipped_counts[id] = skipped_count + 1
			continue
		var key := BoneInstanceService.stack_key_for(id)
		if not counts_by_key.has(key):
			counts_by_key[key] = 0
			representative_by_key[key] = id
			visible_order.append(id)
		counts_by_key[key] = int(counts_by_key[key]) + 1

	var counts_by_id: Dictionary = {}
	for key in representative_by_key:
		counts_by_id[str(representative_by_key[key])] = int(counts_by_key[key])

	var shown := 0
	visible_order.sort_custom(Callable(self, "_compare_inventory_items"))
	for id in visible_order:
		var tile := BoneItemTile.new()
		tile.setup(id, self, int(counts_by_id.get(id, 1)))
		items_grid.add_child(tile)
		shown += 1

	# Pad to the same row count the layout reserved height for, so the grid
	# panel is filled rather than leaving an empty band under the last row.
	var target_slots: int = maxi(12, items_grid.columns * maxi(1, inventory_visible_rows))
	for i in range(shown, target_slots):
		items_grid.add_child(_make_empty_inventory_slot())

	# Tiles are rebuilt on every responsive pass and on every inventory change,
	# so the selection has to be re-applied or it would visually vanish the
	# first time the window is resized or a bone is picked up.
	if selected_bone_id != "" and not visible_order.has(selected_bone_id):
		selected_bone_id = ""
	_refresh_selection_visuals()


func _bone_matches_inventory_category(bone_id: String) -> bool:
	if inventory_category == "all":
		return true
	return EquipmentRulesService.inventory_filter_matches_bone(inventory_category, bone_id)


func _bone_matches_quality_filter(bone_id: String) -> bool:
	if inventory_quality_filter == "all":
		return true
	return BoneInstanceService.quality_id_of(bone_id) == inventory_quality_filter


func _compare_inventory_items(a: String, b: String) -> bool:
	if inventory_sort_mode == "quality_asc" or inventory_sort_mode == "quality_desc":
		var rank_a := BoneQualityService.rank_for(BoneInstanceService.quality_id_of(a))
		var rank_b := BoneQualityService.rank_for(BoneInstanceService.quality_id_of(b))
		if rank_a != rank_b:
			return rank_a < rank_b if inventory_sort_mode == "quality_asc" else rank_a > rank_b
		# Same tier: fall through to the existing ordering so the grid stays
		# stable instead of shuffling within a quality band.
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
	# Percentage modifiers are a SEPARATE mechanism from the quality
	# multiplier and they move the final numbers, but nothing used to show
	# them: a piece could add +10% max HP with no visible cause, making the
	# totals impossible to reconcile by hand. Only non-zero ones are listed,
	# so the line stays quiet when nothing is modifying anything.
	var percent_bits: Array[String] = []
	for entry in [
		["quality_damage_percent", "Damage"],
		["quality_speed_percent", "Speed"],
		["quality_health_percent", "HP"],
		["quality_weight_percent", "Weight"],
	]:
		var value := float(stats.get(str(entry[0]), 0.0))
		if absf(value) < 0.0005:
			continue
		percent_bits.append("%s %+.0f%%" % [str(entry[1]), value * 100.0])
	var load_penalty := float(stats.get("load_speed_penalty", 0.0))
	if load_penalty > 0.0005:
		percent_bits.append("Load -%.0f%% Speed" % (load_penalty * 100.0))
	if not percent_bits.is_empty():
		text += "From equipped quality: " + ", ".join(percent_bits) + "\n"
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
