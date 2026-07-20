extends SceneTree

# Headless test for SkeletonPoseAnimator (full skeleton-driven, phase 1).
#   <godot> --headless --path . --script res://scripts/locomotion/test_skeleton_pose_animator.gd
# Drives a walk cycle in-tree and checks the real bones actually move, then that
# they settle back to rest when idle.

const SKELETON_PATH := "res://assets/godot_skeleton_experiment.glb"
const DT := 1.0 / 60.0

var _skel: Skeleton3D
var _anim: SkeletonPoseAnimator
var _thigh := -1
var _arm := -1
var _rest_thigh: Quaternion
var _rest_arm: Quaternion
var _walk_thigh_max := 0.0
var _walk_arm_max := 0.0
var _walk_arm_min := 1000.0
var _frame := 0
var _fail := 0
var _done := false


func _initialize() -> void:
	var model: Node = (load(SKELETON_PATH) as PackedScene).instantiate()
	get_root().add_child(model)
	_skel = _find_skeleton(model)
	if _skel != null:
		_anim = SkeletonPoseAnimator.new(_skel, model as Node3D)
		_thigh = _skel.find_bone("CC_Base_L_Thigh")
		_arm = _skel.find_bone("CC_Base_R_Upperarm")


func _process(_dt: float) -> bool:
	_frame += 1
	if _frame == 1:
		return false                       # let the model settle in-tree
	if _frame == 2:
		_rest_thigh = _skel.get_bone_pose_rotation(_thigh)
		_rest_arm = _skel.get_bone_pose_rotation(_arm)
	if _frame >= 2 and _frame <= 42:       # ~0.7s of walking
		_anim.update(DT, Vector3(0, 0, 1) * 6.0, 6.0, Vector3.ZERO)
		_walk_thigh_max = maxf(_walk_thigh_max, _rest_thigh.angle_to(_skel.get_bone_pose_rotation(_thigh)))
		var arm_dev := _rest_arm.angle_to(_skel.get_bone_pose_rotation(_arm))
		_walk_arm_max = maxf(_walk_arm_max, arm_dev)
		_walk_arm_min = minf(_walk_arm_min, arm_dev)
		return false
	if _frame <= 200:                      # ~2.6s of idle, speed decays to ~0
		_anim.update(DT, Vector3.ZERO, 6.0, Vector3.ZERO)
		return false
	if _done:
		return true
	_done = true
	_run_checks()
	if _fail == 0:
		print("SKELETON_POSE_TEST: ALL PASS")
	else:
		print("SKELETON_POSE_TEST: %d FAILURE(S)" % _fail)
	quit(_fail)
	return true


func _run_checks() -> void:
	_check("found a Skeleton3D", _skel != null)
	_check("thigh + shoulder bones exist", _thigh >= 0 and _arm >= 0)
	_check("thigh strides during walk (>0.1 rad)", _walk_thigh_max > 0.1)
	_check("shoulder swings through the cycle (range >0.1 rad)", (_walk_arm_max - _walk_arm_min) > 0.1)
	print("   walk: thigh peak=%.3f rad, shoulder swing range=%.3f rad" % [_walk_thigh_max, _walk_arm_max - _walk_arm_min])
	var idle_thigh := _rest_thigh.angle_to(_skel.get_bone_pose_rotation(_thigh))
	var idle_arm := _rest_arm.angle_to(_skel.get_bone_pose_rotation(_arm))
	print("   idle residual: thigh=%.4f rad, shoulder-from-Tpose=%.4f rad" % [idle_thigh, idle_arm])
	_check("legs straighten to rest when idle (<0.05 rad)", idle_thigh < 0.05)
	_check("arms hang down (dropped well off the T-pose) when idle (>0.8 rad)", idle_arm > 0.8)
	_check("speed_ratio decayed to ~0 when idle", _anim.speed_ratio < 0.02)


func _check(label: String, cond: bool) -> void:
	print(("  ok   " if cond else "  FAIL ") + label)
	if not cond:
		_fail += 1


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _find_skeleton(c)
		if f != null:
			return f
	return null
