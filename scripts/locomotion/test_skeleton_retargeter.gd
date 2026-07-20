extends SceneTree

# Headless test for SkeletonRetargeter: a rotation on a source (mannequin) bone
# propagates to the mapped CC bone. (The AnimationPlayer->retarget integration is
# covered by the rendered demo; headless AnimationMixer doesn't flush poses.)
#   <godot> --headless --path . --script res://scripts/locomotion/test_skeleton_retargeter.gd

const CC_PATH := "res://assets/godot_skeleton_experiment.glb"
const LIB_PATH := "res://assets/animation_library.glb"

var _cc: Skeleton3D
var _src: Skeleton3D
var _ret: SkeletonRetargeter
var _cc_thigh := -1
var _src_thigh := -1
var _cc_rest: Quaternion
var _frame := 0
var _fail := 0
var _done := false
var _moved := 0.0
var _idle_dev := 0.0


func _initialize() -> void:
	var cc_model: Node = (load(CC_PATH) as PackedScene).instantiate()
	get_root().add_child(cc_model)
	_cc = _skel(cc_model)
	_cc_thigh = _cc.find_bone("CC_Base_L_Thigh")

	var lib: Node = (load(LIB_PATH) as PackedScene).instantiate()
	get_root().add_child(lib)
	_src = _skel(lib)
	_src_thigh = _src.find_bone("thigh_l")
	_ret = SkeletonRetargeter.new(_src, _cc)


func _process(_dt: float) -> bool:
	_frame += 1
	if _frame < 2:
		return false
	if not _done:
		_done = true
		_cc_rest = _cc.get_bone_pose_rotation(_cc_thigh)

		# Source at rest -> CC should stay at rest.
		_ret.apply()
		_idle_dev = _cc_rest.angle_to(_cc.get_bone_pose_rotation(_cc_thigh))

		# Rotate the source thigh; the CC thigh must follow.
		var src_rest: Quaternion = Quaternion(_src.get_bone_rest(_src_thigh).basis.orthonormalized())
		_src.set_bone_pose_rotation(_src_thigh, src_rest * Quaternion(Vector3(1, 0, 0), 0.6))
		_ret.apply()
		_moved = _cc_rest.angle_to(_cc.get_bone_pose_rotation(_cc_thigh))

		_run()
		if _fail == 0:
			print("SKELETON_RETARGET_TEST: ALL PASS")
		else:
			print("SKELETON_RETARGET_TEST: %d FAILURE(S)" % _fail)
		quit(_fail)
	return true


func _run() -> void:
	_check("CC skeleton found", _cc != null)
	_check("source (mannequin) skeleton found", _src != null)
	_check("mannequin thigh_l + CC thigh exist", _src_thigh >= 0 and _cc_thigh >= 0)
	_check("retargeter mapped the humanoid bones (20)", _ret.mapped_count() == 20)
	print("   idle dev=%.4f rad, moved=%.3f rad" % [_idle_dev, _moved])
	_check("source at rest leaves CC at rest (<0.02 rad)", _idle_dev < 0.02)
	_check("rotating the source thigh drives the CC thigh (>0.2 rad)", _moved > 0.2)


func _check(label: String, cond: bool) -> void:
	print(("  ok   " if cond else "  FAIL ") + label)
	if not cond:
		_fail += 1


func _skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _skel(c)
		if f != null:
			return f
	return null
