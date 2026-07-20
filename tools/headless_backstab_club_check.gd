extends SceneTree

# The stealth finish tears the player's LEFT arm off and clubs the target's
# head with it. This drives the real animator and asserts the mechanics:
# the arm comes off on trigger, rides the attack, snaps home after, the
# impact signal still fires exactly once, and a one-armed player falls back
# to the old finisher (nothing to tear off).


func _initialize() -> void:
	var failures: Array[String] = []
	BoneInstanceService.reset(424242)

	var scene: PackedScene = load("res://scenes/dummy_testing_environment.tscn")
	var world: Node = scene.instantiate()
	root.add_child(world)
	for i in range(20):
		await process_frame

	var player: Node = _find_player(world)
	if player == null:
		print("FAIL: no player"); quit(1); return
	var animator: Variant = player.get("animator")
	if animator == null:
		print("FAIL: no animator"); quit(1); return

	# Torso first, then both arms: the club needs one arm to swing and one to
	# BE the weapon.
	var pieces := {
		"torso": BoneInstanceService.create_instance("torso_bone", BoneQualityService.QUALITY_NORMAL),
		"left_arm": BoneInstanceService.create_instance("gorilla_left_arm_bone", BoneQualityService.QUALITY_NORMAL),
		"right_arm": BoneInstanceService.create_instance("gorilla_right_arm_bone", BoneQualityService.QUALITY_NORMAL),
	}
	for slot in ["torso", "left_arm", "right_arm"]:
		player.call("collect_bone", pieces[slot])
		await process_frame
		player.call("equip_bone", pieces[slot], slot)
		await process_frame

	# --- ready stance rides the REAL availability path ---------------------
	# The player refreshes set_stealth_ready every frame from the prompt scan,
	# so a manual override is stomped immediately -- which is the wiring
	# working. The stance is therefore tested the way the game produces it:
	# stand behind the dummy and let the scan decide.
	var enemy: Node3D = null
	for candidate in root.get_tree().get_nodes_in_group("enemies"):
		if (candidate as Node3D) != null:
			enemy = candidate
			break
	var ready_engaged := false
	if enemy == null:
		print("NOTE: no enemy in the scene; ready stance untested")
	else:
		var facing: Vector3 = (enemy.get("facing_direction") as Vector3).normalized()
		(player as Node3D).global_position = enemy.global_position - facing * 1.4
		for i in range(60):
			await process_frame
			if float(animator.get("_stealth_ready_blend")) > 0.6:
				ready_engaged = true
				break
		if player.get("stealth_target") == null:
			print("NOTE: dummy did not qualify for stealth from behind; stance untested")
		elif not ready_engaged:
			failures.append("a real stealth target did not raise the ready stance (blend %.3f)" % float(animator.get("_stealth_ready_blend")))
		else:
			print("behind dummy -> ready stance blend=%.3f" % float(animator.get("_stealth_ready_blend")))
			# The stance is a real crouch: knees flexed, hips sunk low.
			var rig := animator.get("rig") as Node
			var thigh := rig.call("get_socket", "right_leg") as Node3D
			if thigh != null and thigh.rotation.x > -0.25:
				failures.append("knees not flexed in the ready stance (thigh x %.3f)" % thigh.rotation.x)
			var torso_socket := rig.call("get_socket", "body") as Node3D
			if torso_socket != null:
				print("   crouch: thigh x=%.3f  hips y=%.3f" % [thigh.rotation.x if thigh != null else 0.0, torso_socket.position.y])

	var impacts := [0]
	animator.attack_impact_reached.connect(func() -> void: impacts[0] += 1)

	# --- both arms: the club plays -----------------------------------------
	animator.call("trigger_stealth_finish_attack")
	for i in range(6):
		await process_frame
	if not bool(animator.call("is_arm_sword_held")):
		failures.append("the arm did not tear off on the stealth trigger")
	if ready_engaged and float(animator.get("_stealth_ready_blend")) > 0.6:
		failures.append("ready stance did not yield to the club swing (blend %.3f)" % float(animator.get("_stealth_ready_blend")))
	var hold_mid := float(animator.get("_arm_sword_hold"))
	print("mid-swing: held=%s hold=%.3f" % [str(animator.call("is_arm_sword_held")), hold_mid])
	if hold_mid < 0.3:
		failures.append("hold blend %.3f barely engaged mid-swing" % hold_mid)

	# Let the whole attack and the snap-home play out. Headless frames are not
	# 60fps, so wait on the CONDITION with a generous frame cap instead of
	# assuming a frame count maps to seconds.
	var settled := false
	for i in range(900):
		await process_frame
		if not bool(animator.call("is_arm_sword_held")) and float(animator.get("_arm_sword_hold")) <= 0.05:
			settled = true
			break
	if not settled:
		failures.append("the arm never snapped home after the finish (held=%s hold=%.3f)" % [
			str(animator.call("is_arm_sword_held")), float(animator.get("_arm_sword_hold"))])
	var hold_after := float(animator.get("_arm_sword_hold"))
	if impacts[0] != 1:
		failures.append("impact signal fired %d times, expected exactly 1" % impacts[0])
	print("after: held=%s hold=%.3f impacts=%d" % [str(animator.call("is_arm_sword_held")), hold_after, impacts[0]])

	# --- one arm: fallback, nothing to tear off ----------------------------
	player.call("unequip_slot", "left_arm")
	await process_frame
	impacts[0] = 0
	animator.call("trigger_stealth_finish_attack")
	for i in range(6):
		await process_frame
	if bool(animator.call("is_arm_sword_held")):
		failures.append("a one-armed player still tore an arm off")
	for i in range(900):
		await process_frame
		if impacts[0] >= 1 and float(animator.get("_attack_timer")) <= 0.0:
			break
	if impacts[0] != 1:
		failures.append("fallback finisher impact fired %d times, expected 1" % impacts[0])
	print("one-armed fallback: held=%s impacts=%d" % [str(animator.call("is_arm_sword_held")), impacts[0]])

	# --- non-lethal ambush: both arms, but NO arm tear ---------------------
	# Only an execution earns the club; a damage-only backstab keeps the
	# quick finisher even with both arms available.
	player.call("collect_bone", pieces["left_arm"])
	await process_frame
	player.call("equip_bone", pieces["left_arm"], "left_arm")
	await process_frame
	animator.call("trigger_stealth_finish_attack", false)
	for i in range(6):
		await process_frame
	if bool(animator.call("is_arm_sword_held")):
		failures.append("a NON-lethal ambush still tore the arm off")
	for i in range(900):
		await process_frame
		if float(animator.get("_attack_timer")) <= 0.0:
			break
	print("non-lethal ambush: held=%s (finisher pose, no tear)" % str(animator.call("is_arm_sword_held")))

	if enemy != null and ready_engaged:
		(player as Node3D).global_position = enemy.global_position + Vector3(25, 0, 25)
		for i in range(10):
			await process_frame
		if bool(animator.get("_stealth_ready_requested")):
			failures.append("ready stance stayed requested after leaving stealth range")
		else:
			print("walked away -> ready stance dropped")

	print("")
	if failures.is_empty():
		print("BACKSTAB CLUB CHECK: PASS")
	else:
		print("BACKSTAB CLUB CHECK: FAIL")
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
