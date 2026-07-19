extends SceneTree

# Renders the real inventory (and builds tab) to PNGs so the layout can be
# inspected visually. Must run WITHOUT --headless: headless has no renderer, so
# the captured image would be blank.
#
#   Godot --script tools/screenshot_inventory.gd -- <out_dir>

const SHOTS: Array = [
	{"res": Vector2i(1280, 720), "tab": "all", "name": "inv_1280x720"},
	{"res": Vector2i(1920, 1080), "tab": "all", "name": "inv_1920x1080"},
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

	# Give the player some bones so the grid is populated like a real session.
	if player.has_method("add_bone_to_inventory"):
		for id in ["torso_bone", "head_bone", "arm_bone", "leg_bone"]:
			player.call("add_bone_to_inventory", id)

	ui.call("set_open", true)
	for shot in SHOTS:
		var res: Vector2i = shot["res"]
		root.size = res
		root.content_scale_size = res
		await process_frame
		ui.call("_select_inventory_category", str(shot["tab"]))
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
