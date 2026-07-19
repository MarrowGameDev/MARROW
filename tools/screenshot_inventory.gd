extends SceneTree

# Renders the real inventory (and builds tab) to PNGs so the layout can be
# inspected visually. Must run WITHOUT --headless: headless has no renderer, so
# the captured image would be blank.
#
#   Godot --script tools/screenshot_inventory.gd -- <out_dir>

const SHOTS: Array = [
	{"res": Vector2i(1280, 720), "tab": "all", "name": "inv_1280x720"},
	{"res": Vector2i(1920, 1080), "tab": "all", "name": "inv_1920x1080"},
	# Selection state: highlighted card plus the paper-doll slots it fits.
	{"res": Vector2i(1280, 720), "tab": "all", "name": "inv_selected_1280x720", "select": "arm_bone"},
	{"res": Vector2i(1920, 1080), "tab": "all", "name": "inv_selected_1920x1080", "select": "leg_bone"},
	# Mid-drag state: gold on the slots that accept it, dimmed on the rest.
	{"res": Vector2i(1280, 720), "tab": "all", "name": "inv_drag_1280x720", "drag": "arm_bone"},
	{"res": Vector2i(1280, 720), "tab": "builds", "name": "builds_1280x720"},
	{"res": Vector2i(1920, 1080), "tab": "builds", "name": "builds_1920x1080"},
]


func _initialize() -> void:
	var out_dir := "res://.screenshots"
	var argv := OS.get_cmdline_user_args()
	if argv.size() > 0:
		out_dir = argv[0]
	DirAccess.make_dir_recursive_absolute(out_dir)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(30):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player found")
		quit(1)
		return
	var ui: Node = player.get("inventory_ui")
	if ui == null:
		print("FAIL: no inventory_ui")
		quit(1)
		return

	# The dummy scene already seeds a full set of limbs via
	# _seed_testing_inventory(); top up with the authored .tres bones so the
	# grid shows a mix. The API is collect_bone() -- an earlier version called
	# a non-existent add_bone_to_inventory() behind has_method(), so it
	# silently added nothing.
	if player.has_method("collect_bone"):
		for id in ["torso_bone", "head_bone", "arm_bone", "leg_bone"]:
			player.call("collect_bone", str(id))

	# Wear a couple of pieces and save them into build 1, so the Builds tab
	# captures a Currently Equipped build (banner, zero deltas) rather than
	# only missing/empty states.
	var torso_piece := ""
	var arm_piece := ""
	for item in player.call("get_inventory_items"):
		var candidate := str(item)
		if torso_piece == "" and EquipmentRulesService.compatible_slots_for_bone(candidate).has("torso"):
			torso_piece = candidate
		elif arm_piece == "" and EquipmentRulesService.compatible_slots_for_bone(candidate).has("right_arm"):
			arm_piece = candidate
	if torso_piece != "":
		player.call("equip_bone", torso_piece, "torso")
	if arm_piece != "":
		player.call("equip_bone", arm_piece, "right_arm")
	await process_frame
	if player.has_method("save_equipment_build"):
		player.call("save_equipment_build", 1)

	# Collapse the testing-scene guide panel so it does not sit on top of the
	# inventory in these captures (H hotkey, exercised here directly).
	if world.has_method("_cycle_overlay_mode"):
		world.call("_cycle_overlay_mode")
	ui.call("set_open", true)
	for shot in SHOTS:
		var res: Vector2i = shot["res"]
		root.size = res
		root.content_scale_size = res
		await process_frame
		ui.call("_select_inventory_category", str(shot["tab"]))
		# select_bone toggles, so clear any previous pick before setting this
		# shot's, otherwise the second selected shot would deselect instead.
		if str(ui.get("selected_bone_id")) != "":
			ui.call("select_bone", str(ui.get("selected_bone_id")))
		if shot.has("select"):
			ui.call("select_bone", str(shot["select"]))
		ui.call("end_bone_drag")
		if shot.has("drag"):
			ui.call("begin_bone_drag", str(shot["drag"]))
		for i in range(12):
			await process_frame
		var image: Image = root.get_texture().get_image()
		var path: String = out_dir + "/" + str(shot["name"]) + ".png"
		image.save_png(path)
		print("saved ", path, " ", image.get_size())

	quit(0)


func _find_player(node: Node) -> Node:
	if node.get("inventory_ui") != null:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null
