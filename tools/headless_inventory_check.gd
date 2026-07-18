extends SceneTree

# Headless smoke check for the inventory UI: builds the real player + inventory
# UI, switches through every tab, and applies the responsive layout at several
# viewport sizes. Reports any missing node or layout overflow.

const RESOLUTIONS: Array = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1920, 1080),
	Vector2i(2560, 1080),
	Vector2i(1024, 600),
]


func _initialize() -> void:
	var failures: Array[String] = []
	var player_scene: PackedScene = load("res://scenes/player.tscn")
	var player: Node = null
	if player_scene != null:
		player = player_scene.instantiate()
		root.add_child(player)
	else:
		failures.append("player.tscn could not be loaded")

	# The player builds its inventory UI in code (see player.gd _ready).
	await process_frame
	var ui: Node = null
	if player != null:
		ui = player.get("inventory_ui")
	if ui == null:
		failures.append("PlayerInventoryUI node not found on player")
		_report(failures)
		return

	await process_frame
	await process_frame

	var tabs: Dictionary = ui.get("inventory_tab_buttons")
	print("tabs: ", tabs.keys())
	if not tabs.has("builds"):
		failures.append("no top-level 'builds' tab")
	if not tabs.has("settings"):
		failures.append("no top-level 'settings' tab")

	# Builds must sit before settings in the tab bar (top of the menu).
	var container: Node = ui.get("inventory_tabs_container")
	if container != null and tabs.has("builds") and tabs.has("settings"):
		var builds_index: int = (tabs["builds"] as Node).get_index()
		var settings_index: int = (tabs["settings"] as Node).get_index()
		print("builds tab index=", builds_index, " settings tab index=", settings_index)
		if builds_index > settings_index:
			failures.append("builds tab is placed after settings")

	ui.call("set_open", true)
	await process_frame

	for res in RESOLUTIONS:
		root.content_scale_size = res
		var win: Window = root
		win.size = res
		await process_frame
		await process_frame
		for category in tabs.keys():
			ui.call("_select_inventory_category", str(category))
			await process_frame
			var safe_area: Control = ui.get("inventory_safe_area")
			if safe_area == null:
				failures.append("inventory_safe_area missing")
				continue
			var sz: Vector2 = safe_area.size
			if sz.x > float(res.x) + 1.0 or sz.y > float(res.y) + 1.0:
				failures.append("%s @ %dx%d: safe area %s overflows viewport" % [str(category), res.x, res.y, str(sz)])
		failures.append_array(_check_slot_rects(ui, res))
		print("resolution %dx%d OK" % [res.x, res.y])

	_report(failures)


func _check_slot_rects(ui: Node, res: Vector2i) -> Array[String]:
	# Each equip slot's *input* rect must match what the player sees, and no two
	# slots may overlap -- otherwise a drag drops into the wrong slot.
	var problems: Array[String] = []
	var widgets: Dictionary = ui.get("slot_widgets")
	var rects: Dictionary = {}
	for slot in widgets.keys():
		var w: Control = widgets[slot] as Control
		if w == null:
			continue
		# Rendered extent of the control rect, in doll-local space.
		var rect := Rect2(w.position, w.size * w.scale)
		rects[str(slot)] = rect
		var frame: Control = null
		for child in w.get_children():
			if child is PanelContainer:
				frame = child as Control
				break
		if frame != null:
			var visual := frame.size * w.scale
			if absf(visual.x - rect.size.x) > 1.0 or absf(visual.y - rect.size.y) > 1.0:
				problems.append("%s @ %dx%d: input rect %s != visual %s" % [str(slot), res.x, res.y, str(rect.size), str(visual)])

	var keys: Array = rects.keys()
	for i in range(keys.size()):
		for j in range(i + 1, keys.size()):
			var a: Rect2 = rects[keys[i]]
			var b: Rect2 = rects[keys[j]]
			if a.intersects(b):
				problems.append("%s and %s overlap @ %dx%d (%s vs %s)" % [keys[i], keys[j], res.x, res.y, str(a), str(b)])
	return problems


func _report(failures: Array[String]) -> void:
	print("")
	if failures.is_empty():
		print("INVENTORY CHECK: PASS")
	else:
		print("INVENTORY CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)
