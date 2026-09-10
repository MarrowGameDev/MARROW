extends CanvasLayer
class_name PickupFeed
## Raft-style pickup feed. When materials enter the inventory, small entries appear on the
## right side of the screen — "● Screws  ×3" — stack up, merge repeats into one line with a
## growing count, and fade out after a moment. Spawned by CraftingSystem on ready and wired
## to its material_gained signal, so it needs no scene setup. Apothecary theme (ink on cream).

const INK := Color(0.55, 0.34, 0.15)
const PAPER := Color(0.972, 0.957, 0.930, 0.94)
const GLOW := Color(0.86, 0.86, 0.82)

@export var hold_time: float = 3.0     # seconds an entry stays (restarts when merged)
@export var max_entries: int = 6

var _box: VBoxContainer
var _entries: Dictionary = {}          # material id -> {panel, label, qty, timer}


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS   # keeps fading even if a menu pauses the game
	_box = VBoxContainer.new()
	_box.anchor_left = 1.0
	_box.anchor_right = 1.0
	_box.anchor_top = 0.5
	_box.anchor_bottom = 0.5
	_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_box.grow_vertical = Control.GROW_DIRECTION_BOTH
	_box.offset_right = -24.0
	_box.alignment = BoxContainer.ALIGNMENT_END
	_box.add_theme_constant_override("separation", 6)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)
	var sys := get_parent()
	if sys != null and sys.has_signal("material_gained"):
		sys.connect("material_gained", on_gained)


## Show (or merge into) an entry for a material gain.
func on_gained(id: String, qty: int) -> void:
	var sys = get_parent()
	var shown: String = sys.material_name(id) if sys != null and sys.has_method("material_name") else id.capitalize()
	if _entries.has(id):
		var e: Dictionary = _entries[id]
		e["qty"] = int(e["qty"]) + qty
		(e["label"] as Label).text = "%s   ×%d" % [shown, int(e["qty"])]
		(e["timer"] as Timer).start(hold_time)
		_pop(e["panel"] as Control)
		return

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PAPER
	sb.border_color = INK
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", sb)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dot := Panel.new()                 # the little white-grey material sphere, as an icon
	dot.custom_minimum_size = Vector2(14, 14)
	var dsb := StyleBoxFlat.new()
	dsb.bg_color = GLOW
	dsb.border_color = INK
	dsb.set_border_width_all(1)
	dsb.set_corner_radius_all(7)
	dot.add_theme_stylebox_override("panel", dsb)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(_vcenter(dot))
	var label := Label.new()
	label.text = "%s   ×%d" % [shown, qty]
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(label)
	panel.add_child(h)
	panel.modulate.a = 0.0
	_box.add_child(panel)

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = hold_time
	panel.add_child(timer)
	timer.timeout.connect(_fade_out.bind(id))
	timer.start()

	_entries[id] = {"panel": panel, "label": label, "qty": qty, "timer": timer}
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.18)
	_trim()


func entry_count() -> int:
	return _entries.size()

func entry_text(id: String) -> String:
	return (_entries[id]["label"] as Label).text if _entries.has(id) else ""


# ---- internals ----------------------------------------------------------------
func _pop(panel: Control) -> void:
	panel.pivot_offset = panel.size * 0.5
	var tw := create_tween()
	tw.tween_property(panel, "scale", Vector2(1.08, 1.08), 0.08)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.12)

func _fade_out(id: String) -> void:
	if not _entries.has(id):
		return
	var e: Dictionary = _entries[id]
	_entries.erase(id)
	var panel := e["panel"] as Control
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 0.0, 0.4)
	tw.tween_callback(panel.queue_free)

func _trim() -> void:
	while _box.get_child_count() > max_entries:
		var oldest := _box.get_child(0)
		for id in _entries.keys():
			if _entries[id]["panel"] == oldest:
				_entries.erase(id)
				break
		_box.remove_child(oldest)
		oldest.queue_free()

func _vcenter(c: Control) -> Control:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(c)
	return v
