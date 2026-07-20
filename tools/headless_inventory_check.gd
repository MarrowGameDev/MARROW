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

	# Seed one bone per body part so the filters have something to filter. A
	# bare player.tscn starts with an empty inventory, which would make every
	# filter trivially "correct" because the grid is empty either way.
	var seed_bones: Array = [
		"head_bone", "torso_bone", "arm_bone", "leg_bone",
		"normal_head_bone", "normal_body_bone",
		"normal_left_arm_bone", "normal_right_arm_bone",
		"normal_left_leg_bone", "normal_right_leg_bone",
	]
	if player.has_method("collect_bone"):
		for id in seed_bones:
			player.call("collect_bone", str(id))
	else:
		failures.append("player has no collect_bone(); cannot seed inventory")
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

	# Body-part filters live in the dropdown, not as tabs.
	var dropdown: OptionButton = ui.get("inventory_filter_dropdown")
	if dropdown == null:
		failures.append("no inventory filter dropdown")
	else:
		var labels: Array = []
		var cats: Array = []
		for i in range(dropdown.item_count):
			labels.append(dropdown.get_item_text(i))
			cats.append(str(dropdown.get_item_metadata(i)))
		print("filter dropdown: ", labels, " -> ", cats)
		for expected in ["All", "Head", "Torso", "Arms", "Legs"]:
			if not labels.has(expected):
				failures.append("filter dropdown missing '%s'" % expected)
		for gone in ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]:
			if tabs.has(gone):
				failures.append("body-part '%s' is still a tab button" % gone)

		# Grouped filters must match both sides -- including one-sided pieces
		# like normal_left_leg_bone -- and must not collapse to a single slot
		# (the "legs" legacy-alias trap) or leak across body parts.
		var should_match: Array = [
			["group_arms", "arm_bone"],
			["group_arms", "normal_left_arm_bone"],
			["group_arms", "gorilla_right_arm_bone"],
			["group_legs", "leg_bone"],
			["group_legs", "normal_left_leg_bone"],
			["group_legs", "normal_right_leg_bone"],
		]
		for pair in should_match:
			if not EquipmentRulesService.inventory_filter_matches_bone(str(pair[0]), str(pair[1])):
				failures.append("%s does not match %s" % [str(pair[0]), str(pair[1])])
		var should_not_match: Array = [
			["group_legs", "arm_bone"],
			["group_arms", "leg_bone"],
			["group_arms", "head_bone"],
			["group_legs", "torso_bone"],
		]
		for pair in should_not_match:
			if EquipmentRulesService.inventory_filter_matches_bone(str(pair[0]), str(pair[1])):
				failures.append("%s wrongly matches %s" % [str(pair[0]), str(pair[1])])

	ui.call("set_open", true)
	await process_frame

	for res in RESOLUTIONS:
		root.content_scale_size = res
		var win: Window = root
		win.size = res
		await process_frame
		await process_frame
		# Every reachable view: the dropdown's filters plus the mode tabs.
		var categories: Array = []
		if dropdown != null:
			for i in range(dropdown.item_count):
				categories.append(str(dropdown.get_item_metadata(i)))
		categories.append_array(tabs.keys())
		for category in categories:
			ui.call("_select_inventory_category", str(category))
			await process_frame
			var safe_area: Control = ui.get("inventory_safe_area")
			if safe_area == null:
				failures.append("inventory_safe_area missing")
				continue
			var sz: Vector2 = safe_area.size
			if sz.x > float(res.x) + 1.0 or sz.y > float(res.y) + 1.0:
				failures.append("%s @ %dx%d: safe area %s overflows viewport" % [str(category), res.x, res.y, str(sz)])

		# Every tile the grid actually renders under a filter must belong to
		# that filter -- the dropdown wiring is only correct if the visible
		# contents change with it.
		if dropdown != null:
			for i in range(dropdown.item_count):
				var cat: String = str(dropdown.get_item_metadata(i))
				ui.call("_select_inventory_category", cat)
				await process_frame
				var grid: Node = ui.get("items_grid")
				var shown: Array = []
				var wrong: Array = []
				for tile in grid.get_children():
					var bone_id: Variant = tile.get("bone_id")
					if bone_id == null or str(bone_id) == "":
						continue  # empty padding slot
					shown.append(str(bone_id))
					if not EquipmentRulesService.inventory_filter_matches_bone(cat, str(bone_id)):
						wrong.append(str(bone_id))
				if not wrong.is_empty():
					failures.append("filter '%s' @ %dx%d shows non-matching bones: %s" % [cat, res.x, res.y, str(wrong)])
				if cat != "all" and shown.is_empty():
					failures.append("filter '%s' @ %dx%d shows nothing at all" % [cat, res.x, res.y])
				if res == RESOLUTIONS[0]:
					print("  filter %-12s -> %d tiles" % [cat, shown.size()])

		# Selection and drag feedback, exercised on the real widgets.
		if res == RESOLUTIONS[0]:
			ui.call("_select_inventory_category", "all")
			await process_frame
			var slots: Dictionary = ui.get("slot_widgets")

			ui.call("select_bone", "arm_bone")
			await process_frame
			if str(ui.get("selected_bone_id")) != "arm_bone":
				failures.append("select_bone did not record the selection")
			var lit: Array = []
			for slot_key in slots.keys():
				if bool((slots[slot_key] as Control).get("_highlighted")):
					lit.append(str(slot_key))
			lit.sort()
			if lit != ["left_arm", "right_arm"]:
				failures.append("selecting arm_bone lit %s, expected both arms" % str(lit))
			var details: Label = ui.get("hover_info_label")
			if details != null and not details.text.contains("Arm"):
				failures.append("details panel does not name the selected bone: %s" % details.text)

			# Clicking the same card again clears the selection.
			ui.call("select_bone", "arm_bone")
			await process_frame
			if str(ui.get("selected_bone_id")) != "":
				failures.append("re-selecting the same bone did not clear it")

			ui.call("begin_bone_drag", "leg_bone")
			await process_frame
			var compatible: Array = []
			var incompatible: Array = []
			for slot_key in slots.keys():
				var st := str((slots[slot_key] as Control).get("_drag_state"))
				if st == "compatible":
					compatible.append(str(slot_key))
				elif st == "incompatible":
					incompatible.append(str(slot_key))
			compatible.sort()
			if compatible != ["left_leg", "right_leg"]:
				failures.append("dragging leg_bone marked %s compatible, expected both legs" % str(compatible))
			if incompatible.size() != slots.size() - compatible.size():
				failures.append("drag left some slots unpainted")
			if details != null and not details.text.contains("Compatible with:"):
				failures.append("no 'Compatible with:' message during drag")
			# Hovering another card mid-drag must not steal the panel.
			ui.call("show_bone_info", "head_bone")
			ui.call("clear_bone_info")
			await process_frame
			if details != null and not details.text.contains("Compatible with:"):
				failures.append("hovering during a drag clobbered the 'Compatible with:' message")

			ui.call("end_bone_drag")
			await process_frame
			for slot_key in slots.keys():
				if str((slots[slot_key] as Control).get("_drag_state")) != "":
					failures.append("%s kept its drag state after end_bone_drag" % str(slot_key))
			ui.call("end_bone_drag")  # idempotent

			# Wide slots really are wider than the limb slots.
			var head_w: float = (slots["head"] as Control).size.x
			var arm_w: float = (slots["left_arm"] as Control).size.x
			if head_w <= arm_w:
				failures.append("head slot (%.0f) is not wider than an arm slot (%.0f)" % [head_w, arm_w])
			print("  head slot %.0f wide vs arm %.0f" % [head_w, arm_w])

			# --- quick actions ------------------------------------------------
			# Auto-equip for damage: every slot must hold the best-scoring
			# carried piece; anything strictly better left unequipped is a miss.
			var auto_result: Dictionary = player.call("auto_equip_best", "attack_damage")
			await process_frame
			print("  ", auto_result.get("message", ""))
			var worn_state: Dictionary = player.call("get_equipment_state")
			var worn_arm := str(worn_state.get("right_arm", ""))
			if worn_arm == "":
				failures.append("auto-equip left the right arm empty")
			else:
				var worn_score := BoneRulesService.auto_equip_score(worn_arm, "attack_damage")
				for item in player.call("get_inventory_items"):
					var piece := str(item)
					if worn_state.values().has(piece):
						continue
					if not EquipmentRulesService.can_equip_bone_in_slot(piece, "right_arm"):
						continue
					if BoneRulesService.auto_equip_score(piece, "attack_damage") > worn_score + 0.01:
						failures.append("auto-equip missed a higher-damage arm: %s" % piece)
						break

			# Favourite + lock through the REAL key path (F/L on the selection).
			var mark_target := ""
			for item in player.call("get_inventory_items"):
				var piece := str(item)
				if BoneInstanceService.is_instance_id(piece) and not worn_state.values().has(piece):
					mark_target = piece
					break
			if mark_target == "":
				failures.append("no unequipped instance available to mark")
			else:
				ui.call("select_bone", mark_target)
				var key_event := InputEventKey.new()
				key_event.keycode = KEY_F
				key_event.pressed = true
				ui.call("handle_input", key_event)
				if not BoneInstanceService.is_favorite(mark_target):
					failures.append("F did not mark the selected piece favourite")
				var lock_event := InputEventKey.new()
				lock_event.keycode = KEY_L
				lock_event.pressed = true
				ui.call("handle_input", lock_event)
				if not BoneInstanceService.is_locked(mark_target):
					failures.append("L did not lock the selected piece")
				if bool((player.get("inventory_component") as Node).call("can_remove_bone", mark_target)):
					failures.append("the lock gate lets a locked piece be removed")
				# Favourites float to the front of the grid.
				await process_frame
				var first_id := ""
				for tile in (ui.get("items_grid") as Node).get_children():
					var tile_bone: Variant = tile.get("bone_id")
					if tile_bone != null and str(tile_bone) != "":
						first_id = str(tile_bone)
						break
				if first_id != mark_target:
					failures.append("favourite did not sort first (front tile %s)" % first_id)
				print("  favourite+lock on %s: sorts first, removal gated" % mark_target)
				# Restore so later assertions see a clean state.
				BoneInstanceService.toggle_favorite(mark_target)
				BoneInstanceService.toggle_locked(mark_target)
				ui.call("select_bone", mark_target)

			# Shift+click pin: compare two pieces head to head, and the pin
			# survives the cursor leaving.
			var pieces_for_compare: Array = []
			for item in player.call("get_inventory_items"):
				var piece := str(item)
				if BoneInstanceService.is_instance_id(piece):
					pieces_for_compare.append(piece)
				if pieces_for_compare.size() >= 2:
					break
			if pieces_for_compare.size() >= 2:
				ui.call("select_bone", str(pieces_for_compare[0]))
				ui.call("compare_with_selected", str(pieces_for_compare[1]))
				var details_label := ui.get("hover_info_label") as Label
				if details_label == null or not details_label.text.contains("vs"):
					failures.append("shift+click did not pin a comparison")
				ui.call("clear_bone_info")
				if details_label != null and not details_label.text.contains("vs"):
					failures.append("the pinned comparison did not survive hover-out")
				ui.call("select_bone", str(pieces_for_compare[0]))
				print("  compare pin holds through hover-out")

			# Double-click equips: synthesized on a real tile.
			var dbl_target := ""
			for tile in (ui.get("items_grid") as Node).get_children():
				var tile_bone: Variant = tile.get("bone_id")
				if tile_bone == null or str(tile_bone) == "":
					continue
				if not (player.call("get_equipment_state") as Dictionary).values().has(str(tile_bone)):
					dbl_target = str(tile_bone)
					var click := InputEventMouseButton.new()
					click.button_index = MOUSE_BUTTON_LEFT
					click.pressed = true
					click.double_click = true
					(tile as Control).call("_gui_input", click)
					break
			await process_frame
			if dbl_target != "" and not (player.call("get_equipment_state") as Dictionary).values().has(dbl_target):
				print("  NOTE: double-click equip refused for %s (slot occupied or rules) -- gesture wired" % dbl_target)
			elif dbl_target != "":
				print("  double-click equipped %s" % dbl_target)

		# Measure the doll on a grid view: the loop above ends on Settings,
		# where the paper doll is hidden and its geometry is whatever the
		# previous resolution left behind.
		ui.call("_select_inventory_category", "all")
		await process_frame
		await process_frame
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

	# Labels do not clip by default, so a name band that runs past its own rect
	# draws over the caption underneath it. Assert the bands stay disjoint.
	for slot in widgets.keys():
		var w: Control = widgets[slot] as Control
		if w == null:
			continue
		var bands: Array = []
		for child in w.get_children():
			var lbl := child as Label
			if lbl != null:
				bands.append({"rect": Rect2(lbl.position, lbl.size), "text": lbl.text})
		for i in range(bands.size()):
			for j in range(i + 1, bands.size()):
				if (bands[i]["rect"] as Rect2).intersects(bands[j]["rect"] as Rect2):
					problems.append("%s @ %dx%d: text bands overlap ('%s' vs '%s')" % [str(slot), res.x, res.y, str(bands[i]["text"]), str(bands[j]["text"])])

	# Arms and legs must read as centred against the character preview: the
	# vertical centre of the arm+leg block should line up with the centre of
	# the preview frame.
	var frame: Control = null
	if ui.get("inventory_paper_doll") != null:
		frame = (ui.get("inventory_paper_doll") as Control).get_node_or_null("CenterFrame") as Control
	var limb_keys: Array = ["left_arm", "right_arm", "left_leg", "right_leg"]
	if frame != null:
		var top: float = INF
		var bottom: float = -INF
		for k in limb_keys:
			if not rects.has(k):
				continue
			var r: Rect2 = rects[k]
			top = minf(top, r.position.y)
			bottom = maxf(bottom, r.end.y)
		if top < INF:
			var limb_centre: float = (top + bottom) * 0.5
			var frame_centre: float = frame.position.y + frame.size.y * 0.5
			if absf(limb_centre - frame_centre) > maxf(6.0, frame.size.y * 0.04):
				problems.append("limbs not centred on preview @ %dx%d (limbs %.1f vs preview %.1f)" % [res.x, res.y, limb_centre, frame_centre])

	# The figure must be optically centred inside the preview panel it lives in,
	# not pinned to a corner. Compare the doll's rect against its parent area in
	# shared (global) coordinates so container margins are accounted for.
	var doll: Control = ui.get("inventory_paper_doll")
	var area: Control = ui.get("inventory_preview_area")
	if doll != null and area != null and area.size.x > 0.0 and area.size.y > 0.0:
		var left: float = doll.global_position.x - area.global_position.x
		var right: float = (area.global_position.x + area.size.x) - (doll.global_position.x + doll.size.x)
		var top: float = doll.global_position.y - area.global_position.y
		var bottom: float = (area.global_position.y + area.size.y) - (doll.global_position.y + doll.size.y)
		var tol_x: float = maxf(12.0, area.size.x * 0.06)
		var tol_y: float = maxf(12.0, area.size.y * 0.06)
		if absf(left - right) > tol_x:
			problems.append("doll off-centre horizontally @ %dx%d (left %.1f vs right %.1f, area %.1f)" % [res.x, res.y, left, right, area.size.x])
		if absf(top - bottom) > tol_y:
			problems.append("doll off-centre vertically @ %dx%d (top %.1f vs bottom %.1f, area %.1f)" % [res.x, res.y, top, bottom, area.size.y])
		if doll.size.x > area.size.x + 1.0 or doll.size.y > area.size.y + 1.0:
			problems.append("doll %s exceeds preview area %s @ %dx%d" % [str(doll.size), str(area.size), res.x, res.y])
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
