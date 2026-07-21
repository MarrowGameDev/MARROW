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

const _ONESHOTS := ["turn_l", "turn_r", "turn180", "jump", "attack"]
const _LOOPING := ["idle", "walk", "run", "backward"]

var tree: AnimationTree
var retargeter: SkeletonRetargeter
var _dst: Skeleton3D
var _foot_l := -1
var _foot_r := -1
var _states: Dictionary = {}     # state -> true if present
var _loco_param := "parameters/move/blend_amount"
var _has_backward := false
# "Lightness" knobs (weight, not speed): jump a touch floatier, and unhunch the
# spine/head toward upright so a light skeleton doesn't carry the mutant's weight.
var time_scale := 1.0
var jump_lift_scale := 1.0
var uprightness := 0.0                # 0 = raw clip, 1 = fully upright spine
const _SPINE := ["CC_Base_Waist", "CC_Base_Spine01", "CC_Base_Spine02",
	"CC_Base_NeckTwist01", "CC_Base_Head"]

# Normal idle: when standing (and not mid one-shot), straighten the legs+spine+head
# toward the character's own rest and add a subtle breathe, so the hunched mutant
# idle reads as a plain stand. 0 = off.
var idle_normalize := 0.0
var _idle_time := 0.0
const _IDLE_BONES := ["CC_Base_L_Thigh", "CC_Base_R_Thigh", "CC_Base_L_Calf",
	"CC_Base_R_Calf", "CC_Base_Waist", "CC_Base_Spine01", "CC_Base_Spine02",
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
	_foot_l = _fb(cc_skeleton, "CC_Base_L_Foot")
	_foot_r = _fb(cc_skeleton, "CC_Base_R_Foot")
	_src = src["skel"]
	_src_hips = _src.find_bone("mixamorig_Hips")
	if _src_hips >= 0:
		_src_hips_rest_y = _rest_y(_src, _src_hips)
		var cc_hips := _fb(cc_skeleton, "CC_Base_Hip")
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
		if state in ["walk", "run", "backward"]:
			anim = _make_loopable(anim)   # these locomotion clips aren't authored as loops
		anim.loop_mode = Animation.LOOP_LINEAR if state in _LOOPING else Animation.LOOP_NONE
		moves.add_animation(state, anim)
		if state == "jump":
			_jump_dur = anim.length
		if state != "idle":
			model.free()
	ap.add_animation_library("moves", moves)
	return {"skel": _skel(idle_model), "ap": ap}


func _build_tree(ap: AnimationPlayer, tree_parent: Node) -> void:
	var bt := AnimationNodeBlendTree.new()

	# Base locomotion: idle -> walk -> run by speed (or idle<->walk if no run clip).
	if _states.has("run"):
		var bs := AnimationNodeBlendSpace1D.new()
		bs.add_blend_point(_clip("idle"), 0.0)
		bs.add_blend_point(_clip("walk"), 0.5)
		bs.add_blend_point(_clip("run"), 1.0)
		bt.add_node("loco", bs)
		_loco_param = "parameters/loco/blend_position"
	else:
		bt.add_node("idle", _clip("idle"))
		bt.add_node("walk", _clip("walk"))
		var move := AnimationNodeBlend2.new()
		bt.add_node("loco", move)
		bt.connect_node("loco", 0, "idle")
		bt.connect_node("loco", 1, "walk")
		_loco_param = "parameters/loco/blend_amount"

	# Backward blends over the forward locomotion.
	var base := "loco"
	if _states.has("backward"):
		bt.add_node("back_clip", _clip("backward"))
		var back := AnimationNodeBlend2.new()
		bt.add_node("back", back)
		bt.connect_node("back", 0, "loco")
		bt.connect_node("back", 1, "back_clip")
		base = "back"
		_has_backward = true

	# Chain the one-shots on top of the base.
	for shot in _ONESHOTS:
		if not _states.has(shot):
			continue
		bt.add_node("clip_" + shot, _clip(shot))
		var os := AnimationNodeOneShot.new()
		# Jump crossfades longer so walk->jump->walk is smooth (no snap to a
		# neutral pose); turns/attacks stay snappy.
		if shot == "jump":
			os.fadein_time = 0.22
			os.fadeout_time = 0.3
		else:
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
	if state in _LOOPING:
		n.loop_mode = Animation.LOOP_LINEAR
	return n


# ---- per-frame + triggers -------------------------------------------------

func update(delta: float, speed_ratio: float, backward: float = 0.0) -> void:
	tree.set(_loco_param, clampf(speed_ratio, 0.0, 1.0))
	if _has_backward:
		tree.set("parameters/back/blend_amount", clampf(backward, 0.0, 1.0))
	tree.advance(delta * time_scale)
	retargeter.apply()
	if uprightness > 0.0:
		_lighten_posture()
	_idle_time += delta
	if idle_normalize > 0.0:
		var amt := clampf(1.0 - speed_ratio * 1.6, 0.0, 1.0)
		if _oneshot_active():
			amt = 0.0
		if amt > 0.0:
			_normalize_idle(amt * idle_normalize)
	if _jump_timer > 0.0:
		_jump_timer = maxf(0.0, _jump_timer - delta * time_scale)


func _oneshot_active() -> bool:
	for shot in _ONESHOTS:
		if _states.has(shot) and bool(tree.get("parameters/os_%s/active" % shot)):
			return true
	return false


# Blend the legs/spine/head toward rest (a plain upright stand) and add a subtle
# chest breathe.
func _normalize_idle(w: float) -> void:
	for bone_name in _IDLE_BONES:
		var b := _fb(_dst, bone_name)
		if b < 0:
			continue
		var rest := Quaternion(_dst.get_bone_rest(b).basis.orthonormalized())
		_dst.set_bone_pose_rotation(b, _dst.get_bone_pose_rotation(b).slerp(rest, w))
	var chest := _fb(_dst, "CC_Base_Spine01")
	if chest >= 0:
		var breathe := sin(_idle_time * 1.6) * deg_to_rad(2.2) * w
		var cur := _dst.get_bone_pose_rotation(chest)
		_dst.set_bone_pose_rotation(chest, cur * Quaternion(Vector3(1, 0, 0), breathe))


# Blend the spine/head toward their upright rest, taking the "carrying weight"
# hunch out of the clip without changing its timing.
func _lighten_posture() -> void:
	for bone_name in _SPINE:
		var b := _fb(_dst, bone_name)
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


func trigger_turn180() -> void:
	_fire("turn180")


func is_busy() -> bool:
	for shot in ["jump", "attack"]:
		if _states.has(shot) and bool(tree.get("parameters/os_%s/active" % shot)):
			return true
	return false


func is_jumping() -> bool:
	return _states.has("jump") and bool(tree.get("parameters/os_jump/active"))


func _fire(shot: String) -> void:
	if _states.has(shot):
		tree.set("parameters/os_%s/request" % shot, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


# Snap the character down so its lowest foot rests on the floor (+ small lift).
func ground(character_root: Node3D, delta: float = 0.0166667, ground_y: float = 0.0, foot_lift: float = 0.06) -> void:
	if _dst == null or not _dst.is_inside_tree():
		return
	var target_y := character_root.position.y
	if _jump_timer > 0.0 and _src_hips >= 0:
		# Airborne: lift by the source hips' root motion instead of pinning a foot.
		var lift: float = (_src.get_bone_global_pose(_src_hips).origin.y - _src_hips_rest_y) * _root_scale
		target_y = ground_y + maxf(0.0, lift) * jump_lift_scale
	else:
		var lowest := INF
		for b in [_foot_l, _foot_r]:
			if b < 0:
				continue
			var wy: float = (_dst.global_transform * _dst.get_bone_global_pose(b)).origin.y
			lowest = minf(lowest, wy)
		if lowest < INF:
			target_y = character_root.position.y - (lowest - ground_y - foot_lift)
	# Ease toward the target so the airborne<->grounded handoff (takeoff/landing)
	# blends instead of snapping.
	character_root.position.y = lerpf(character_root.position.y, target_y, 1.0 - exp(-22.0 * delta))


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


# Resolve a CC bone name with or without the "CC_Base_" prefix.
func _fb(skel: Skeleton3D, name: String) -> int:
	var b := skel.find_bone(name)
	if b < 0:
		b = skel.find_bone(name.trim_prefix("CC_Base_"))
	return b


# Turn a clip that isn't authored as a loop (start pose != end pose) into a clean
# loop: find the time where the whole-body pose recurs (its natural stride
# period), trim to [0, period], and force the last key to equal the first.
func _make_loopable(anim: Animation) -> Animation:
	var length := anim.length
	if length <= 0.1:
		return anim
	var best_t := length
	var best_err := INF
	var t := 0.45
	while t <= length + 0.001:
		var err := _pose_diff(anim, 0.0, t)
		if err < best_err:
			best_err = err
			best_t = t
		t += 1.0 / 30.0
	print("loop-ify walk: period=%.3fs (residual %.3f rad) from %.2fs clip" % [best_t, best_err, length])

	var out := Animation.new()
	out.length = best_t
	out.loop_mode = Animation.LOOP_LINEAR
	var steps := maxi(2, int(round(best_t * 30.0)))
	for ti in range(anim.get_track_count()):
		var type := anim.track_get_type(ti)
		if not (type == Animation.TYPE_ROTATION_3D or type == Animation.TYPE_POSITION_3D or type == Animation.TYPE_SCALE_3D):
			continue
		var tr := out.add_track(type)
		out.track_set_path(tr, anim.track_get_path(ti))
		for k in range(steps + 1):
			var kt := best_t * float(k) / float(steps)
			var st := 0.0 if k == steps else kt   # last key == first key -> exact loop
			match type:
				Animation.TYPE_ROTATION_3D:
					out.rotation_track_insert_key(tr, kt, anim.rotation_track_interpolate(ti, st))
				Animation.TYPE_POSITION_3D:
					out.position_track_insert_key(tr, kt, anim.position_track_interpolate(ti, st))
				Animation.TYPE_SCALE_3D:
					out.scale_track_insert_key(tr, kt, anim.scale_track_interpolate(ti, st))
	return out


# Summed rotation difference between two times across all bone rotation tracks.
func _pose_diff(anim: Animation, t0: float, t1: float) -> float:
	var s := 0.0
	for ti in range(anim.get_track_count()):
		if anim.track_get_type(ti) == Animation.TYPE_ROTATION_3D:
			s += anim.rotation_track_interpolate(ti, t0).angle_to(anim.rotation_track_interpolate(ti, t1))
	return s


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
