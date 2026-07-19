extends SceneTree

# Exercises the redesigned Builds screen through its real handlers: selection,
# New Build, Save Current, Rename, Delete (with its visible confirmation), and
# the preview-residue rule when switching between builds.


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(555777)

	# Deterministic slate: wipe any builds file left by earlier runs.
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://equipment_builds.cfg"))

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return
	var ui: Variant = player.get("inventory_ui")
	var builds: Variant = player.get("equipment_builds_component")
	# The file may have been loaded before the wipe took effect; reset state.
	(builds.get("builds") as Dictionary).clear()
	builds.call("_ensure_minimum_builds")

	# Wear torso + arm so there is something to save.
	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL)
	var arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_STRONG)
	for piece in [torso, arm]:
		player.call("collect_bone", piece)
		await process_frame
	player.call("equip_bone", torso, "torso")
	await process_frame
	player.call("equip_bone", arm, "right_arm")
	await process_frame

	ui.call("set_open", true)
	await process_frame
	ui.call("_select_inventory_category", "builds")
	for i in range(4):
		await process_frame

	# Builds view owns the header: filters hidden, title switched.
	var title := ui.get("inventory_title_label") as Label
	if title != null and title.text != "Builds":
		failures.append("header title is '%s' in Builds view" % title.text)
	var filter_dropdown := ui.get("inventory_filter_dropdown") as Control
	if filter_dropdown != null and filter_dropdown.visible:
		failures.append("inventory filters still visible in Builds view")

	# --- 1. Save Current into empty build 1 -> Currently Equipped ---------
	ui.set("builds_selected_index", 1)
	ui.call("_on_save_current_pressed")
	for i in range(3):
		await process_frame
	var report: Dictionary = builds.call("get_build_report", 1)
	if str(report.get("state", "")) != "Currently Equipped":
		failures.append("saved build is '%s', expected Currently Equipped" % str(report.get("state", "")))
	var banner := ui.get("builds_match_banner") as Label
	if banner != null and banner.text != "Currently Equipped":
		failures.append("banner says '%s', expected the single phrase 'Currently Equipped'" % banner.text)
	var apply_button := ui.get("builds_apply_button") as Button
	if apply_button != null and not apply_button.disabled:
		failures.append("Apply enabled while the build is currently equipped")
	print("1. save-current -> %s / banner '%s' / apply disabled=%s" % [
		str(report.get("state", "")), banner.text if banner != null else "?", str(apply_button.disabled if apply_button != null else "?")])

	# --- 3. selecting another build looks, never equips --------------------
	var equipment_before: Dictionary = player.call("get_equipment_state")
	ui.call("_select_build", 3)
	for i in range(3):
		await process_frame
	if player.call("get_equipment_state") != equipment_before:
		failures.append("selecting a build changed the real equipment")
	var detail_title := ui.get("builds_detail_title") as Label
	if detail_title != null and not detail_title.text.begins_with("Build 3"):
		failures.append("detail title did not follow selection: '%s'" % detail_title.text)
	# Empty build: preview must hold only the fixed head, no residue.
	var rig := (ui.get("build_preview_rigs") as Dictionary).get(0) as ModularSkeletonRig
	if rig != null:
		var worn_slots: Array = rig.equipped_ids.keys()
		if worn_slots != ["head"]:
			failures.append("empty build preview holds %s, expected only the head" % str(worn_slots))
	print("3. selected empty build 3: equipment untouched, preview slots=%s" % str(rig.equipped_ids.keys() if rig != null else "?"))

	# Switch back and forth; the preview must always mirror the selection.
	ui.call("_select_build", 1)
	for i in range(3):
		await process_frame
	if rig != null and not rig.equipped_ids.has("torso"):
		failures.append("preview lost the saved torso after re-selecting build 1")

	# --- 9. rename changes only the label ---------------------------------
	var slots_before := str(builds.call("build_slots", 1))
	ui.set("builds_selected_index", 1)
	ui.call("_on_rename_submitted", "Heavy Striker")
	for i in range(3):
		await process_frame
	if builds.call("build_display_name", 1) != "Heavy Striker":
		failures.append("rename did not stick")
	if str(builds.call("build_slots", 1)) != slots_before:
		failures.append("rename altered the build's pieces")
	print("9. renamed to '%s', pieces unchanged" % str(builds.call("build_display_name", 1)))

	# --- New Build then Delete with visible confirmation -------------------
	var before_count: int = (builds.call("build_indices") as Array).size()
	ui.call("_on_new_build_pressed")
	for i in range(3):
		await process_frame
	var after_new: int = (builds.call("build_indices") as Array).size()
	if after_new != before_count + 1:
		failures.append("New Build did not add a build (%d -> %d)" % [before_count, after_new])
	var new_index := int(ui.get("builds_selected_index"))

	ui.call("_on_delete_pressed")
	await process_frame
	var status := ui.get("build_preset_status_label") as Label
	if status != null and not status.text.contains("again to confirm"):
		failures.append("first Delete press shows no visible confirmation: '%s'" % status.text)
	if (builds.call("build_indices") as Array).size() != after_new:
		failures.append("first Delete press already deleted the build")
	ui.call("_on_delete_pressed")
	for i in range(3):
		await process_frame
	if (builds.call("build_indices") as Array).has(new_index):
		failures.append("second Delete press did not remove the build")
	if player.call("get_equipment_state") != equipment_before:
		failures.append("deleting a build changed the real equipment")
	print("delete: confirmed in two presses, equipment untouched")

	print("")
	if failures.is_empty():
		print("BUILDS UI CHECK: PASS")
	else:
		print("BUILDS UI CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _find_player(node: Node) -> Node:
	if node.get("inventory_ui") != null:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null
