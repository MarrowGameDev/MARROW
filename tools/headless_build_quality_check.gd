extends SceneTree

# Builds reference EXACT pieces: a build re-equips the very instance it was
# saved with, never a different-quality copy of the same bone. (The earlier
# best-quality-wins rule was reversed because re-resolving to a better copy
# made a freshly saved build disagree with the gear it came from.)


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(31337)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return
	var builds: Variant = player.get("equipment_builds_component")
	if builds == null:
		print("FAIL: no builds component"); quit(1); return

	# A torso is required before limbs attach.
	var torso := BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL)
	player.call("collect_bone", torso)
	await process_frame
	player.call("equip_bone", torso, EquipmentRulesService.slot_for_bone(torso))
	await process_frame

	# Save a build while wearing a deliberately mediocre arm.
	var worn_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_WORN)
	player.call("collect_bone", worn_arm)
	await process_frame
	var arm_slot := EquipmentRulesService.slot_for_bone(worn_arm)
	player.call("equip_bone", worn_arm, arm_slot)
	await process_frame
	var saved: Dictionary = builds.call("save_current_build", 1)
	print("saved build: ", saved.get("state", {}))

	# The build must remember the individual piece, not just its type.
	var saved_state: Dictionary = saved.get("state", {})
	if str(saved_state.get(arm_slot, "")) != worn_arm:
		failures.append("build stored %s for the arm slot, expected the worn instance %s" % [str(saved_state.get(arm_slot, "")), worn_arm])

	# Now carry better and worse copies of the same type.
	var frail_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_FRAIL)
	var pristine_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	var strong_arm := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_STRONG)
	for piece in [frail_arm, pristine_arm, strong_arm]:
		player.call("collect_bone", piece)
		await process_frame

	# Drop the exact piece the build was saved with, to prove the build no
	# longer depends on it.
	var inventory: Variant = player.get("inventory_component")
	player.call("unequip_slot", arm_slot)
	await process_frame

	var applied: Dictionary = builds.call("apply_build", 1)
	await process_frame
	print("apply result: ok=%s msg=%s" % [str(applied.get("ok", false)), str(applied.get("message", ""))])
	if not bool(applied.get("ok", false)):
		failures.append("build failed to apply: %s" % str(applied.get("message", "")))

	var equipped := str(player.call("get_equipped_bone_for_slot", arm_slot))
	var equipped_quality := BoneInstanceService.quality_id_of(equipped)
	print("equipped %s (%s)" % [equipped, equipped_quality])
	if equipped != worn_arm:
		failures.append("build equipped %s, expected the exact saved piece %s" % [equipped, worn_arm])
	if equipped_quality != BoneQualityService.QUALITY_WORN:
		failures.append("build equipped %s quality, expected the saved piece's worn" % equipped_quality)
	if equipped == pristine_arm:
		failures.append("build silently upgraded to a different-quality copy")

	# Two slots naming two different instances must resolve to those two.
	var left := EquipmentRulesService.SLOT_LEFT_ARM
	var right := EquipmentRulesService.SLOT_RIGHT_ARM
	var two_arm_state := {left: frail_arm, right: pristine_arm}
	var resolved: Dictionary = builds.call("_resolve_build_to_instances", two_arm_state)
	print("two-arm resolution: ", resolved)
	if resolved.size() != 2:
		failures.append("two arm slots resolved to %d pieces" % resolved.size())
	elif str(resolved[left]) != frail_arm or str(resolved[right]) != pristine_arm:
		failures.append("slots did not resolve to their own saved instances: %s" % str(resolved))

	# A piece that is not carried must fail, never be substituted.
	var impossible := {left: "bone#999999"}
	var validation: Dictionary = builds.call("validate_build_state", impossible, [])
	if bool(validation.get("ok", true)):
		failures.append("a build needing an uncarried type validated as applicable")

	print("")
	if failures.is_empty():
		print("BUILD QUALITY CHECK: PASS")
	else:
		print("BUILD QUALITY CHECK: FAIL")
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
