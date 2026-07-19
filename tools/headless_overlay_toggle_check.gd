extends SceneTree

# Exercises the H hotkey that collapses the testing-scene guide panel:
# full -> compact -> hidden -> full, plus the guard that restores the panel
# when the observed-result field is opened while hidden.


func _initialize() -> void:
	var failures: Array[String] = []
	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(10):
		await process_frame

	var panel: Control = world.get("testing_panel")
	var label: Label = world.get("status_label")
	if panel == null or label == null:
		print("FAIL: panel or label missing")
		quit(1)
		return

	# FULL
	if not panel.visible:
		failures.append("FULL: panel hidden")
	if panel.custom_minimum_size.x <= 0.0:
		failures.append("FULL: panel lost its width floor")
	var full_len: int = label.text.length()
	if not label.text.contains("H:"):
		failures.append("FULL: no hint telling the player about H")
	await process_frame
	var full_size: Vector2 = panel.size
	print("FULL   visible=%s width=%.0f text_len=%d on-screen=%s" % [panel.visible, panel.custom_minimum_size.x, full_len, str(full_size)])

	# COMPACT
	world.call("_cycle_overlay_mode")
	await process_frame
	if not panel.visible:
		failures.append("COMPACT: panel hidden (should be visible but small)")
	if panel.custom_minimum_size.x > 0.0:
		failures.append("COMPACT: still pinned to the full width floor")
	var compact_len: int = label.text.length()
	if compact_len >= full_len:
		failures.append("COMPACT: text not shorter than full (%d vs %d)" % [compact_len, full_len])
	if not label.text.contains("H:"):
		failures.append("COMPACT: no hint on how to expand again")
	print("COMPACT visible=%s width=%.0f text_len=%d text=%s" % [panel.visible, panel.custom_minimum_size.x, compact_len, label.text])
	# What actually blocked the inventory was the panel's height (a tall block
	# down the left of the screen), so that is what has to collapse. Width
	# matters less: one short line is inherently narrow.
	await process_frame
	print("COMPACT on-screen=%s (was %s)" % [str(panel.size), str(full_size)])
	if panel.size.y > full_size.y * 0.2:
		failures.append("COMPACT: height %.0f is not a real collapse of %.0f" % [panel.size.y, full_size.y])
	if panel.size.x >= full_size.x:
		failures.append("COMPACT: width %.0f did not shrink below full %.0f" % [panel.size.x, full_size.x])

	# HIDDEN
	world.call("_cycle_overlay_mode")
	await process_frame
	if panel.visible:
		failures.append("HIDDEN: panel still visible")
	print("HIDDEN  visible=%s" % panel.visible)

	# Opening the notes field while hidden must restore the panel.
	world.call("_begin_notes_editing")
	await process_frame
	if not panel.visible:
		failures.append("notes editing while hidden left the field invisible")
	print("after notes-open visible=%s" % panel.visible)
	world.call("_cancel_notes_editing")
	await process_frame

	# Back round to FULL.
	world.call("_cycle_overlay_mode")
	await process_frame
	world.call("_cycle_overlay_mode")
	await process_frame
	world.call("_cycle_overlay_mode")
	await process_frame
	if not panel.visible or panel.custom_minimum_size.x <= 0.0:
		failures.append("cycle did not return to FULL")
	print("cycled back visible=%s width=%.0f" % [panel.visible, panel.custom_minimum_size.x])

	print("")
	if failures.is_empty():
		print("OVERLAY TOGGLE CHECK: PASS")
	else:
		print("OVERLAY TOGGLE CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)
