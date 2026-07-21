class_name RetargetedLocomotion
extends RefCounted

# Drives a CC skeleton from the mannequin animation library: an AnimationTree
# blends idle<->walk on the (hidden) source skeleton by speed, and a
# SkeletonRetargeter copies the blended pose onto the CC skeleton each frame.
#
# Reusable by any scene that has the CC skeleton — the demo and, later, the player.

var tree: AnimationTree
var retargeter: SkeletonRetargeter
var _blend := 0.0

# Natural arm swing. Walk_Carry holds a carry pose, so after retargeting we
# override the arms: hang them at the sides and swing fore/aft, synced to the
# stride read from the feet. CC skeleton faces +X (lateral = Z).
var natural_arms := true
var arm_swing := deg_to_rad(30.0)
var arm_down := deg_to_rad(88.0)
var elbow_bend := deg_to_rad(16.0)
var arm_swing_scale := 3.0
const _FWD := Vector3(1, 0, 0)
const _LAT := Vector3(0, 0, 1)
var _dst: Skeleton3D
var _arm: Dictionary = {}      # key -> {bone:int, rest:Basis}
var _foot_l := -1
var _foot_r := -1


func _init(source_model: Node, cc_skeleton: Skeleton3D, tree_parent: Node,
		idle_clip: String, walk_clip: String) -> void:
	var src := _skel(source_model)
	var ap := _find_ap(source_model)
	for clip in [idle_clip, walk_clip]:
		if ap != null and ap.has_animation(clip):
			ap.get_animation(clip).loop_mode = Animation.LOOP_LINEAR

	var blend := AnimationNodeBlendSpace1D.new()
	var idle_node := AnimationNodeAnimation.new()
	idle_node.animation = idle_clip
	var walk_node := AnimationNodeAnimation.new()
	walk_node.animation = walk_clip
	blend.add_blend_point(idle_node, 0.0)
	blend.add_blend_point(walk_node, 1.0)

	tree = AnimationTree.new()
	tree.tree_root = blend
	tree_parent.add_child(tree)
	tree.anim_player = tree.get_path_to(ap)
	tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	tree.active = true

	retargeter = SkeletonRetargeter.new(src, cc_skeleton)
	_cache_arms(cc_skeleton)


# Advance the animation for `delta` at the given 0..1 gait speed and copy the pose
# to the CC skeleton.
func update(delta: float, speed_ratio: float) -> void:
	_blend = clampf(speed_ratio, 0.0, 1.0)
	tree.set("parameters/blend_position", _blend)
	tree.advance(delta)
	# weight = speed: at rest the CC blends back to a stand, at full speed it's the
	# full walk (lets a single walk clip double as its own idle).
	retargeter.apply(_blend)
	if natural_arms and _blend > 0.02:
		_override_arms()


# ---- natural arm swing ----------------------------------------------------

func _cache_arms(cc_skeleton: Skeleton3D) -> void:
	_dst = cc_skeleton
	var names := {
		"l_arm": "CC_Base_L_Upperarm", "r_arm": "CC_Base_R_Upperarm",
		"l_fore": "CC_Base_L_Forearm", "r_fore": "CC_Base_R_Forearm",
	}
	for key in names:
		var b := _dst.find_bone(names[key])
		if b >= 0:
			_arm[key] = {"bone": b, "rest": _rest_gbasis(_dst, b)}
	_foot_l = _dst.find_bone("CC_Base_L_Foot")
	_foot_r = _dst.find_bone("CC_Base_R_Foot")


func _override_arms() -> void:
	if not (_arm.has("l_arm") and _arm.has("r_arm")):
		return
	# Stride phase from the feet's fore/aft (X) separation, -1..1.
	var phase := 0.0
	if _foot_l >= 0 and _foot_r >= 0:
		var sep: float = _dst.get_bone_global_pose(_foot_l).origin.x - _dst.get_bone_global_pose(_foot_r).origin.x
		phase = clampf(sep * arm_swing_scale, -1.0, 1.0)
	# Contralateral: left arm forward when the right foot (phase<0) is forward.
	_set_arm("l_arm", -arm_down, phase * arm_swing)
	_set_arm("r_arm", arm_down, -phase * arm_swing)
	# Forearms follow the (now-hanging) upper arm: reset to their rest LOCAL pose
	# (straight elbow) so they continue downward instead of keeping the T-pose
	# sideways direction.
	if _arm.has("l_fore"):
		_straighten("l_fore")
	if _arm.has("r_fore"):
		_straighten("r_fore")


# Hang the arm (rotate about forward by `down`) and swing it fore/aft (about
# lateral), fully replacing the retargeted carry pose.
func _set_arm(key: String, down: float, swing: float) -> void:
	var d: Dictionary = _arm[key]
	_write(d["bone"], Basis(_LAT, swing) * Basis(_FWD, down) * (d["rest"] as Basis))


func _straighten(key: String) -> void:
	var bone: int = _arm[key]["bone"]
	_dst.set_bone_pose_rotation(bone, Quaternion(_dst.get_bone_rest(bone).basis.orthonormalized()))


func _write(bone: int, desired: Basis) -> void:
	var par := _dst.get_bone_parent(bone)
	var pg: Basis = _dst.get_bone_global_pose(par).basis if par >= 0 else Basis()
	_dst.set_bone_pose_rotation(bone, (pg.inverse() * desired).get_rotation_quaternion())


func _rest_gbasis(skel: Skeleton3D, bone: int) -> Basis:
	var chain: Array = []
	var b := bone
	while b >= 0:
		chain.append(b)
		b = skel.get_bone_parent(b)
	var acc := Basis()
	for i in range(chain.size() - 1, -1, -1):
		acc = acc * skel.get_bone_rest(chain[i]).basis
	return acc.orthonormalized()


# Snap the character down so its lowest foot rests on `ground_y` (+ a small lift
# for the sole below the ankle). Retargeting copies only rotations, so with the
# CC skeleton's own leg length the feet would otherwise float; correcting the
# root each frame grounds them and produces a natural hip bob.
func ground(character_root: Node3D, ground_y: float = 0.0, foot_lift: float = 0.06) -> void:
	var skel := retargeter.dst_skel
	if skel == null or not skel.is_inside_tree():
		return
	var lowest := INF
	for bone_name in ["CC_Base_L_Foot", "CC_Base_R_Foot"]:
		var b := skel.find_bone(bone_name)
		if b < 0:
			continue
		var wy: float = (skel.global_transform * skel.get_bone_global_pose(b)).origin.y
		lowest = minf(lowest, wy)
	if lowest < INF:
		character_root.position.y -= (lowest - ground_y - foot_lift)


func _skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _skel(c)
		if f != null:
			return f
	return null


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null
