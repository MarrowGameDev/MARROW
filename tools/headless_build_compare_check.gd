extends SceneTree

# The reported bug: saving the current equipment into a build and immediately
# comparing it produced phantom deltas ("Speed +0.32") against gear that had
# not changed, because the build re-resolved to the best-quality copy instead
# of the pieces actually worn.


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(999001)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return
	var builds: Variant = player.get("equipment_builds_component")

	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL)
	player.call("collect_bone", torso)
	await process_frame
	player.call("equip_bone", torso, EquipmentRulesService.slot_for_bone(torso))
	await process_frame

	# Wear the WORSE of two copies, and carry a better one. Under the old
	# best-quality rule this is exactly what produced false deltas.
	var worn_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_WORN)
	var better_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	for piece in [worn_arm, better_arm]:
		player.call("collect_bone", piece)
		await process_frame
	var arm_slot := EquipmentRulesService.slot_for_bone(worn_arm)
	player.call("equip_bone", worn_arm, arm_slot)
	await process_frame

	# --- 1. save current -> must match exactly, no deltas -----------------
	builds.call("save_current_build", 1)
	var report: Dictionary = builds.call("get_build_report", 1)
	print("state: %s   message: %s" % [str(report.get("state", "")), str(report.get("message", ""))])
	print("stats: ", report.get("stats", {}))
	print("deltas: ", report.get("comparison", {}))
	if str(report.get("state", "")) != "Currently Equipped":
		failures.append("a build saved from current gear is not 'Currently Equipped', got '%s'" % str(report.get("state", "")))
	if not bool(report.get("matches_current", false)):
		failures.append("matches_current is false right after saving current equipment")
	for key in report.get("comparison", {}):
		var delta := float((report["comparison"] as Dictionary)[key])
		if absf(delta) > 0.0:
			failures.append("phantom delta on %s: %+.4f (build equals current gear)" % [str(key), delta])

	# The screen's numbers must agree with the game's real ones: the Builds
	# panel once fed player.max_health (already equipment-derived) back into
	# the formula as the BASE, double-counting every equipped HP bonus -- a
	# worn set showed Health 22 while the real in-game maximum was 10.
	var screen_health := int(float((report.get("stats", {}) as Dictionary).get("health", -1)))
	var real_max := int(player.get("max_health"))
	if screen_health != real_max:
		failures.append("Builds screen Health %d != real max_health %d (double-count regression)" % [screen_health, real_max])
	print("   screen Health %d == real max %d" % [screen_health, real_max])

	# The saved build must reference the WORN piece, not the better copy.
	var slots: Dictionary = report.get("slots", {})
	var saved_arm := str((slots.get(arm_slot, {}) as Dictionary).get("instance_id", ""))
	if saved_arm != worn_arm:
		failures.append("build stored %s but the worn piece was %s" % [saved_arm, worn_arm])
	if str((slots.get(arm_slot, {}) as Dictionary).get("quality_id", "")) != BoneQualityService.QUALITY_WORN:
		failures.append("build did not keep the worn piece's quality")
	print("1. saved arm=%s quality=%s (better copy %s ignored)" % [
		saved_arm, str((slots.get(arm_slot, {}) as Dictionary).get("quality_id", "")), better_arm])

	# --- 2. swapping to the better copy makes it differ, with real deltas --
	player.call("unequip_slot", arm_slot)
	await process_frame
	player.call("equip_bone", better_arm, arm_slot)
	await process_frame
	var report2: Dictionary = builds.call("get_build_report", 1)
	print("2. after swapping to the pristine copy: state=%s deltas=%s" % [
		str(report2.get("state", "")), str(report2.get("comparison", {}))])
	if str(report2.get("state", "")) != "Saved":
		failures.append("build should read 'Saved' once the gear differs, got '%s'" % str(report2.get("state", "")))
	var any_delta := false
	for key in report2.get("comparison", {}):
		if absf(float((report2["comparison"] as Dictionary)[key])) > 0.0:
			any_delta = true
	if not any_delta:
		failures.append("no delta reported although a different-quality piece is worn")

	# --- 3. applying restores the exact saved instance --------------------
	var applied: Dictionary = builds.call("apply_build", 1)
	await process_frame
	if not bool(applied.get("ok", false)):
		failures.append("apply failed: %s" % str(applied.get("message", "")))
	if str(player.call("get_equipped_bone_for_slot", arm_slot)) != worn_arm:
		failures.append("apply did not restore the exact saved instance")
	var report3: Dictionary = builds.call("get_build_report", 1)
	if str(report3.get("state", "")) != "Currently Equipped":
		failures.append("after applying, the build is not 'Currently Equipped'")
	print("3. applied -> %s, state=%s" % [str(player.call("get_equipped_bone_for_slot", arm_slot)), str(report3.get("state", ""))])

	# --- 4a. dropping the exact piece: a carried copy of the type fills in --
	var inventory: Variant = player.get("inventory_component")
	var carried: Array = inventory.get("bone_inventory")
	carried.erase(worn_arm)
	var report4: Dictionary = builds.call("get_build_report", 1)
	print("4a. exact piece dropped: state=%s" % str(report4.get("state", "")))
	if str(report4.get("state", "")) == "Missing parts":
		failures.append("build reads Missing although a same-type copy is carried")
	var entry4: Dictionary = (report4.get("slots", {}) as Dictionary).get(arm_slot, {})
	if not bool(entry4.get("substituted", false)):
		failures.append("slot did not report the substitution")
	if str(entry4.get("quality_id", "")) != BoneQualityService.QUALITY_PRISTINE:
		failures.append("substitute is %s, expected the best carried (pristine)" % str(entry4.get("quality_id", "")))
	var applied4: Dictionary = builds.call("apply_build", 1)
	await process_frame
	if not bool(applied4.get("ok", false)):
		failures.append("substituted build failed to apply: %s" % str(applied4.get("message", "")))
	if str(player.call("get_equipped_bone_for_slot", arm_slot)) != better_arm:
		failures.append("apply did not equip the substitute")
	print("    applied substitute %s (%s)" % [better_arm, BoneInstanceService.quality_id_of(better_arm)])

	# --- 4b. no copy of the type at all -> Missing parts, apply refused ----
	# The test scene seeds several arm_bone copies of its own, and the
	# type-fallback legitimately finds them -- so proving the missing state
	# requires purging EVERY carried copy of the type, not just ours.
	for i in range(carried.size() - 1, -1, -1):
		if BoneInstanceService.bone_id_of(str(carried[i])) == "arm_bone":
			carried.remove_at(i)
	player.call("unequip_slot", arm_slot)
	await process_frame
	var report4b: Dictionary = builds.call("get_build_report", 1)
	print("4b. no copies left: state=%s missing=%d" % [
		str(report4b.get("state", "")), int(report4b.get("missing_count", 0))])
	if str(report4b.get("state", "")) != "Missing parts":
		failures.append("typeless build should read Missing parts, got '%s'" % str(report4b.get("state", "")))
	if not (report4b.get("stats", {}) as Dictionary).is_empty():
		failures.append("a missing build still exposes stats")
	var blocked: Dictionary = builds.call("apply_build", 1)
	if bool(blocked.get("ok", false)):
		failures.append("a build with no carried copies was applied anyway")
	if str(player.call("get_equipped_bone_for_slot", arm_slot)) != "":
		failures.append("a refused apply still changed equipment (partial application)")
	print("    apply refused: %s" % str(blocked.get("message", "")))

	# --- 5. restoring the exact piece resolves it exactly again ------------
	carried.append(worn_arm)
	var report5: Dictionary = builds.call("get_build_report", 1)
	if str(report5.get("state", "")) == "Missing parts":
		failures.append("build still reads Missing after the piece came back")
	var reapplied: Dictionary = builds.call("apply_build", 1)
	await process_frame
	if not bool(reapplied.get("ok", false)):
		failures.append("build did not apply after the piece was restored: %s" % str(reapplied.get("message", "")))
	if str(player.call("get_equipped_bone_for_slot", arm_slot)) != worn_arm:
		failures.append("restored apply did not prefer the exact instance")
	print("5. restored and re-applied exactly %s" % worn_arm)

	print("")
	if failures.is_empty():
		print("BUILD COMPARE CHECK: PASS")
	else:
		print("BUILD COMPARE CHECK: FAIL")
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
