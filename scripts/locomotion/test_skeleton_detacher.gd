extends SceneTree

# Headless test for SkeletonDetacher against the real rigged skeleton.
#   <godot> --headless --path . --script res://scripts/locomotion/test_skeleton_detacher.gd

const SKELETON_PATH := "res://assets/godot_skeleton_experiment.glb"

var _fail := 0


func _initialize() -> void:
	var packed: PackedScene = load(SKELETON_PATH)
	if packed == null:
		print("SKELETON_DETACH_TEST: could not load %s (imported?)" % SKELETON_PATH)
		quit(1)
		return

	var model: Node = packed.instantiate()
	get_root().add_child(model)
	var skel := _find_skeleton(model)

	_check("found a Skeleton3D in the rig", skel != null)
	if skel == null:
		print("SKELETON_DETACH_TEST: %d FAILURE(S)" % (_fail if _fail > 0 else 1))
		quit(1)
		return
	print("  bones: %d" % skel.get_bone_count())
	_check("skeleton has the expected CC bone count (89)", skel.get_bone_count() == 89)
	_check("left upper-arm bone exists", skel.find_bone("CC_Base_L_Upperarm") >= 0)

	var debris := Node3D.new()
	get_root().add_child(debris)
	var det := SkeletonDetacher.new(skel, debris)

	# The arm sub-tree must contain the forearm, hand and fingers, not just one bone.
	var arm_idx := skel.find_bone("CC_Base_L_Upperarm")
	var arm_sub := det.subtree(arm_idx)
	_check("left-arm sub-tree pulls in the whole limb (>10 bones)", arm_sub.size() > 10)
	_check("  ... and includes the hand", arm_sub.has(skel.find_bone("CC_Base_L_Hand")))

	# Sever the left arm.
	var r := det.sever("CC_Base_L_Upperarm")
	_check("sever returned a result", not r.is_empty())
	_check("one debris body was spawned", debris.get_child_count() == 1)
	_check("debris is a RigidBody3D", debris.get_child_count() > 0 and debris.get_child(0) is RigidBody3D)
	_check("arm bone collapsed (pose scale ~0)", skel.get_bone_pose_scale(arm_idx).x < 0.01)
	_check("detacher reports the arm as severed", det.is_severed("CC_Base_L_Upperarm"))

	# Re-sever guards.
	_check("re-severing the same arm is refused", det.sever("CC_Base_L_Upperarm").is_empty())
	_check("severing the forearm of an already-severed arm is refused",
		det.sever("CC_Base_L_Forearm").is_empty())

	# A different limb still works and adds a second debris body.
	var r2 := det.sever("CC_Base_R_Thigh")
	_check("severing the right leg succeeds", not r2.is_empty())
	_check("second debris body spawned", debris.get_child_count() == 2)

	if _fail == 0:
		print("SKELETON_DETACH_TEST: ALL PASS")
	else:
		print("SKELETON_DETACH_TEST: %d FAILURE(S)" % _fail)
	quit(_fail)


func _check(label: String, cond: bool) -> void:
	print(("  ok   " if cond else "  FAIL ") + label)
	if not cond:
		_fail += 1


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var found := _find_skeleton(c)
		if found != null:
			return found
	return null
