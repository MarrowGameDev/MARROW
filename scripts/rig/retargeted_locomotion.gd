class_name RetargetedLocomotion
extends RefCounted

# Drives the CC skeleton from a set of Mixamo clips (all on the mixamorig rig).
# Clips are merged into one AnimationLibrary on a single hidden source skeleton
# and wired into an AnimationTree:
#   move = Blend2(idle, walk)                     — blended by speed
#   then One-Shot overlays chained on top: turn_l, turn_r, jump, attack.
# A SkeletonRetargeter copies the resulting pose onto the CC skeleton each frame.
#
# clip_paths: { state -> "res://...fbx" } with states among:
#   idle, walk (looping base) and turn_l, turn_r, jump, attack (one-shots).

const _ONESHOTS := ["turn_l", "turn_r", "jump", "attack"]

var tree: AnimationTree
var retargeter: SkeletonRetargeter
var _dst: Skeleton3D
var _foot_l := -1
var _foot_r := -1
var _states: Dictionary = {}     # state -> true if present
# "Lightness" knobs (weight, not speed): jump a touch floatier, and unhunch the
# spine/head toward upright so a light skeleton doesn't carry the mutant's weight.
var time_scale := 1.0
var jump_lift_scale := 1.0
var uprightness := 0.0                # 0 = raw clip, 1 = fully upright spine
const _SPINE := ["CC_Base_Waist", "CC_Base_Spine01", "CC_Base_Spine02",
	"CC_Base_NeckTwist01", "CC_Base_Head"]

# Jump vertical: the retarget copies only rotations, so the hop is taken from the
# source hips' own root motion (Y), scaled to the CC's hip height.
var _jump_dur := 0.0
var _jump_timer := 0.0
var _src: Skeleton3D
var _src_hips := -1
var _src_hips_rest_y := 0.0
var _root_scale := 1.0


func _init(clip_paths: Dictionary, cc_skeleton: Skeleton3D, tree_parent: Node) -> void:
	_dst = cc_skeleton
	var src := _build_source(clip_paths, tree_parent)
	var ap: AnimationPlayer = src["ap"]
	_build_tree(ap, tree_parent)
	retargeter = SkeletonRetargeter.new(src["skel"], cc_skeleton)
	_foot_l = cc_skeleton.find_bone("CC_Base_L_Foot")
	_foot_r = cc_skeleton.find_bone("CC_Base_R_Foot")
	_src = src["skel"]
	_src_hips = _src.find_bone("mixamorig_Hips")
	if _src_hips >= 0:
		_src_hips_rest_y = _rest_y(_src, _src_hips)
		var cc_hips := cc_skeleton.find_bone("CC_Base_Hip")
		var cc_y := _rest_y(cc_skeleton, cc_hips) if cc_hips >= 0 else _src_hips_rest_y
		_root_scale = cc_y / _src_hips_rest_y if absf(_src_hips_rest_y) > 0.0001 else 1.0


# Merge every clip into one fresh AnimationLibrary on the idle model's player.
func _build_source(clip_paths: Dictionary, tree_parent: Node) -> Dictionary:
	var idle_model: Node = (load(clip_paths["idle"]) as PackedScene).instantiate()
	tree_parent.add_child(idle_model)
	for mi in _meshes(idle_model):
		mi.visible = false
	var ap := _find_ap(idle_model)

	var moves := AnimationLibrary.new()
	for state in clip_paths:
		_states[state] = true
		var model: Node = idle_model if state == "idle" else (load(clip_paths[state]) as PackedScene).instantiate()
		var mp := _find_ap(model)
		var anim: Animation = mp.get_animation(mp.get_animation_list()[0]).duplicate(true)
		anim.loop_mode = Animation.LOOP_LINEAR if state in ["idle", "walk"] else Animation.LOOP_NONE
		moves.add_animation(state, anim)
		if state == "jump":
			_jump_dur = anim.length
		if state != "idle":
			model.free()
	ap.add_animation_library("moves", moves)
	return {"skel": _skel(idle_model), "ap": ap}


func _build_tree(ap: AnimationPlayer, tree_parent: Node) -> void:
	var bt := AnimationNodeBlendTree.new()

	# Base: blend idle<->walk by speed.
	bt.add_node("idle", _clip("idle"))
	bt.add_node("walk", _clip("walk"))
	var move := AnimationNodeBlend2.new()
	bt.add_node("move", move)
	bt.connect_node("move", 0, "idle")
	bt.connect_node("move", 1, "walk")

	# Chain the one-shots on top of the base.
	var base := "move"
	for shot in _ONESHOTS:
		if not _states.has(shot):
			continue
		bt.add_node("clip_" + shot, _clip(shot))
		var os := AnimationNodeOneShot.new()
		os.fadein_time = 0.07
		os.fadeout_time = 0.12
		bt.add_node("os_" + shot, os)
		bt.connect_node("os_" + shot, 0, base)
		bt.connect_node("os_" + shot, 1, "clip_" + shot)
		base = "os_" + shot
	bt.connect_node("output", 0, base)

	tree = AnimationTree.new()
	tree.tree_root = bt
	tree_parent.add_child(tree)
	tree.anim_player = tree.get_path_to(ap)
	tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	tree.active = true


func _clip(state: String) -> AnimationNodeAnimation:
	var n := AnimationNodeAnimation.new()
	n.animation = "moves/" + state
	if state in ["idle", "walk"]:
		n.loop_mode = Animation.LOOP_LINEAR
	return n


# ---- per-frame + triggers -------------------------------------------------

func update(delta: float, speed_ratio: float) -> void:
	tree.set("parameters/move/blend_amount", clampf(speed_ratio, 0.0, 1.0))
	tree.advance(delta * time_scale)
	retargeter.apply()
	if uprightness > 0.0:
		_lighten_posture()
	if _jump_timer > 0.0:
		_jump_timer = maxf(0.0, _jump_timer - delta * time_scale)


# Blend the spine/head toward their upright rest, taking the "carrying weight"
# hunch out of the clip without changing its timing.
func _lighten_posture() -> void:
	for bone_name in _SPINE:
		var b := _dst.find_bone(bone_name)
		if b < 0:
			continue
		var rest := Quaternion(_dst.get_bone_rest(b).basis.orthonormalized())
		_dst.set_bone_pose_rotation(b, _dst.get_bone_pose_rotation(b).slerp(rest, uprightness))


func trigger_jump() -> void:
	if _states.has("jump"):
		_jump_timer = _jump_dur
	_fire("jump")


func trigger_attack() -> void:
	_fire("attack")


func trigger_turn(left: bool) -> void:
	_fire("turn_l" if left else "turn_r")


func is_busy() -> bool:
	for shot in ["jump", "attack"]:
		if _states.has(shot) and bool(tree.get("parameters/os_%s/active" % shot)):
			return true
	return false


func _fire(shot: String) -> void:
	if _states.has(shot):
		tree.set("parameters/os_%s/request" % shot, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


# Snap the character down so its lowest foot rests on the floor (+ small lift).
func ground(character_root: Node3D, ground_y: float = 0.0, foot_lift: float = 0.06) -> void:
	if _dst == null or not _dst.is_inside_tree():
		return
	# Airborne during a jump: lift by the source hips' root motion instead of
	# pinning a foot to the floor.
	if _jump_timer > 0.0 and _src_hips >= 0:
		var lift: float = (_src.get_bone_global_pose(_src_hips).origin.y - _src_hips_rest_y) * _root_scale
		character_root.position.y = ground_y + maxf(0.0, lift) * jump_lift_scale
		return
	var lowest := INF
	for b in [_foot_l, _foot_r]:
		if b < 0:
			continue
		var wy: float = (_dst.global_transform * _dst.get_bone_global_pose(b)).origin.y
		lowest = minf(lowest, wy)
	if lowest < INF:
		character_root.position.y -= (lowest - ground_y - foot_lift)


# ---- helpers --------------------------------------------------------------

func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out


func _skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _skel(c)
		if f != null:
			return f
	return null


func _rest_y(skel: Skeleton3D, bone: int) -> float:
	var xf := Transform3D()
	var b := bone
	var chain: Array = []
	while b >= 0:
		chain.append(b)
		b = skel.get_bone_parent(b)
	for i in range(chain.size() - 1, -1, -1):
		xf = xf * skel.get_bone_rest(chain[i])
	return xf.origin.y


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null
