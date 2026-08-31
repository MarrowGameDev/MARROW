extends Node3D

# Procedural WALK for the crab-head character — a real IK solver in Godot.
#
# The rig is a full IK rig, but glTF export drops Blender's IK solver (only bones +
# baked keyframes survive). So we recreate the IK here:
#
#   * Each leg runs analytic TWO-BONE IK. A walk cycle drives a foot TARGET (step
#     forward, plant, push back, lifting during the swing). The solver places the
#     knee (law of cosines) so thigh + shin reach the target, then the separate
#     `IK BONE leg -> Foot` chain is moved onto the target so the foot mesh lands there.
#   * Skeleton axes (up / side / forward) are derived from the rest pose (hips + ankles),
#     so we don't have to guess the model's orientation. Sign dials flip step / knee
#     direction if they come out reversed.
#   * Arms are a gentle rigid swing about the shoulder (keeps the IK claws attached).
#
# Standing still -> authored `armature idle`. Moving -> this gait.

const GLB: PackedScene = preload("res://assets/crab_head_character_optimized.glb")
const SKEL_PATH := "Armature/Skeleton3D"
const IDLE_CLIP := "armature idle"

@export var character_scale: float = 0.18
@export var run_speed: float = 4.0
@export var step_rate: float = 1.5            # gait cycles/sec at full speed
@export var stride_frac: float = 0.35         # foot fore/aft travel, as a fraction of leg length
@export var lift_frac: float = 0.22           # foot lift height, as a fraction of leg length
@export var forward_sign: float = 1.0         # flip to -1 if feet step backward
@export var knee_pole_sign: float = 1.0       # flip to -1 if the knee bends the wrong way
@export var arm_swing_deg: float = 8.0        # gentle arm swing (0 disables)
@export var body_bob: float = 0.05            # metres, local space
@export var head_bob_deg: float = 4.0         # head nod on each footfall (0 disables)
@export var head_sway_deg: float = 3.0        # gentle head side-sway

const L_ARM := "ARM. L"
const R_ARM := "ARM. R"
const L_HAND := "IK Hand. L"
const R_HAND := "IK Hand. R"
const NECK := "neck"

# The idle animates legs/arms/feet/claws + the Armature root, but NOT head/neck/spine.
# While walking the gait owns those, so strip them from the idle we keep running; what's
# left (the small secondary arms + target bones) keeps its authored life. Head motion is
# added procedurally since the idle never touched it.
const IDLE_STRIP := [
	"Armature",
	"Shoulder. L", "ARM. L", "fore arm. L", "Shoulder. R", "ARM. R", "fore arm. R",
	"Upper leg. L", "Lower leg.L", "Upper leg. R", "Lower leg.R",
	"IK BONE leg. L", "IK BONE leg. R", "Foot. L", "Foot. R", "heel. L", "heel. R",
	"Big Toe. L", "Big Toe. R", "Small Toe. L", "Small Toe. R",
	"IK Hand. L", "IK Hand. R", "Hand. L", "Hand. R",
	"CALW 1. L", "CALW 2. L", "CALW 1. R", "CALW 2. R",
	"Lower Claw 1. L", "lower CLaw 2. L", "Lower Claw 1. R", "lower CLaw 2. R",
]

var _model: Node3D
var _skel: Skeleton3D
var _ap: AnimationPlayer
var _body: Node3D
var _phase := 0.0
var _speed := 0.0
var _base_y := 0.0

var _leg_l: Dictionary = {}
var _leg_r: Dictionary = {}
var _up := Vector3.UP
var _side := Vector3.RIGHT
var _forward := Vector3.FORWARD
var _stride := 1.0
var _step_h := 0.5

# arm rigid-swing data
var _idx: Dictionary = {}
var _restg: Dictionary = {}
var _restgp: Dictionary = {}
var _pivot_l_arm: Vector3
var _pivot_r_arm: Vector3
var _neck_pivot: Vector3
var _upper_clip := ""     # masked idle (non-driven bones) played while walking


func _ready() -> void:
	_model = GLB.instantiate()
	add_child(_model)
	scale = Vector3.ONE * character_scale
	_base_y = position.y
	_skel = _model.get_node_or_null(SKEL_PATH)
	if _skel == null:
		push_warning("creature_walker: no skeleton at " + SKEL_PATH)
		return
	_ap = _find_ap(_model)

	_leg_l = _make_leg("Upper leg. L", "Lower leg.L", "IK BONE leg. L", "Foot. L")
	_leg_r = _make_leg("Upper leg. R", "Lower leg.R", "IK BONE leg. R", "Foot. R")

	# derive skeleton-space axes from the rest pose
	var hip_l: Vector3 = _leg_l["H"]
	var hip_r: Vector3 = _leg_r["H"]
	var ank_l: Vector3 = _leg_l["A"]
	var ank_r: Vector3 = _leg_r["A"]
	_up = ((hip_l + hip_r) * 0.5 - (ank_l + ank_r) * 0.5).normalized()
	_side = (hip_r - hip_l).normalized()
	_forward = _up.cross(_side).normalized()
	var leg_len: float = _leg_l["L1"] + _leg_l["L2"]
	_stride = stride_frac * leg_len
	_step_h = lift_frac * leg_len

	# arm rigid-swing + procedural head setup
	for n in [L_ARM, R_ARM, L_HAND, R_HAND, NECK]:
		var b := _skel.find_bone(n)
		_idx[n] = b
		if b >= 0:
			_restg[b] = _skel.get_bone_global_rest(b)
			var p := _skel.get_bone_parent(b)
			_restgp[b] = (_skel.get_bone_global_rest(p) if p >= 0 else Transform3D.IDENTITY)
	_pivot_l_arm = _rest_origin(L_ARM)
	_pivot_r_arm = _rest_origin(R_ARM)
	_neck_pivot = _rest_origin(NECK)

	if _ap != null and _ap.has_animation(IDLE_CLIP):
		_ap.get_animation(IDLE_CLIP).loop_mode = Animation.LOOP_LINEAR
		_build_upper_idle()
		_ap.play(IDLE_CLIP)
	_body = _find_body(self)


func _build_upper_idle() -> void:
	# Duplicate the idle and strip every track except the head/neck/spine bones, so it can
	# play WHILE walking without touching the legs/arms the gait drives (disjoint bone sets).
	var src: Animation = _ap.get_animation(IDLE_CLIP)
	var copy: Animation = src.duplicate()
	for ti in range(copy.get_track_count() - 1, -1, -1):
		var p := str(copy.track_get_path(ti))
		var colon := p.rfind(":")
		var bone := (p.substr(colon + 1) if colon >= 0 else p)
		if IDLE_STRIP.has(bone):
			copy.remove_track(ti)
	copy.loop_mode = Animation.LOOP_LINEAR
	var lib_name := _ap.find_animation_library(src)
	var lib := _ap.get_animation_library(lib_name)
	if lib == null:
		return
	if lib.has_animation("walk_upper"):
		lib.remove_animation("walk_upper")
	lib.add_animation("walk_upper", copy)
	_upper_clip = "walk_upper" if str(lib_name) == "" else str(lib_name) + "/walk_upper"


func _make_leg(upper: String, lower: String, ikbone: String, foot: String) -> Dictionary:
	var ui := _skel.find_bone(upper)
	var li := _skel.find_bone(lower)
	var ii := _skel.find_bone(ikbone)
	var fi := _skel.find_bone(foot)
	var upper_rg := _skel.get_bone_global_rest(ui)
	var lower_rg := _skel.get_bone_global_rest(li)
	var ik_rg := _skel.get_bone_global_rest(ii)
	var h := upper_rg.origin
	var k := lower_rg.origin
	var a := _skel.get_bone_global_rest(fi).origin
	return {
		"ui": ui, "li": li, "ii": ii, "fi": fi,
		"upper_rg": upper_rg, "lower_rg": lower_rg, "ik_rg": ik_rg,
		"H": h, "K": k, "A": a,
		"L1": h.distance_to(k), "L2": k.distance_to(a),
		"hip_parent_rg": _skel.get_bone_global_rest(_skel.get_bone_parent(ui)),
		"ik_parent_rg": _skel.get_bone_global_rest(_skel.get_bone_parent(ii)),
	}


func _process(delta: float) -> void:
	if _skel == null:
		return
	var v := Vector3.ZERO
	if _body != null:
		var vv: Variant = _body.get("velocity")
		if vv is Vector3:
			v = vv
	var spd := Vector3(v.x, 0.0, v.z).length()
	_speed = lerpf(_speed, spd, 1.0 - exp(-10.0 * delta))
	var moving := _speed > 0.2

	if moving:
		# keep the authored idle alive on head/neck/spine (masked clip); legs stay procedural
		if _ap != null and _upper_clip != "" and _ap.current_animation != _upper_clip:
			_ap.play(_upper_clip)
		var norm := clampf(_speed / run_speed, 0.2, 1.0)
		_phase += delta * step_rate * TAU * norm
		_apply_gait(clampf(_speed / (run_speed * 0.5), 0.0, 1.0))
	else:
		if _ap != null and _ap.has_animation(IDLE_CLIP) and _ap.current_animation != IDLE_CLIP:
			_ap.play(IDLE_CLIP)
		position.y = _base_y


func _apply_gait(amt: float) -> void:
	_drive_leg(_leg_l, _phase, amt)
	_drive_leg(_leg_r, _phase + PI, amt)

	# arms: gentle rigid counter-swing about the shoulder, claws follow
	if arm_swing_deg > 0.0:
		var arm := deg_to_rad(arm_swing_deg) * amt
		var sl := sin(_phase)
		var sr := sin(_phase + PI)
		_rotate_about(_idx.get(L_ARM, -1), _pivot_l_arm, _side, arm * sr)
		_rotate_about(_idx.get(L_HAND, -1), _pivot_l_arm, _side, arm * sr)
		_rotate_about(_idx.get(R_ARM, -1), _pivot_r_arm, _side, arm * sl)
		_rotate_about(_idx.get(R_HAND, -1), _pivot_r_arm, _side, arm * sl)

	# head: gentle nod on each footfall + slow side-sway, so it stays alive while walking
	var ni: int = _idx.get(NECK, -1)
	if ni >= 0 and (head_bob_deg > 0.0 or head_sway_deg > 0.0):
		var nod := Basis(_side, deg_to_rad(head_bob_deg) * sin(_phase * 2.0) * amt)
		var sway := Basis(_forward, deg_to_rad(head_sway_deg) * sin(_phase) * amt)
		_rotate_about_basis(ni, _neck_pivot, nod * sway)

	position.y = _base_y + body_bob * absf(sin(_phase)) * amt


func _drive_leg(leg: Dictionary, phase: float, amt: float) -> void:
	var fwd := _stride * cos(phase) * forward_sign * amt
	var lift := maxf(0.0, -sin(phase)) * _step_h * amt
	var target: Vector3 = (leg["A"] as Vector3) + _forward * fwd + _up * lift

	var h: Vector3 = leg["H"]
	var sol := _solve_knee(h, target, leg["L1"], leg["L2"], _forward * knee_pole_sign)
	var knee: Vector3 = sol[0]
	var tc: Vector3 = sol[1]

	# aim upper leg  H -> knee
	var upper_local := _aim(leg["upper_rg"], ((leg["K"] as Vector3) - h).normalized(),
			(knee - h).normalized(), leg["hip_parent_rg"], h)
	_set_pose(leg["ui"], upper_local)
	var upper_new_global: Transform3D = (leg["hip_parent_rg"] as Transform3D) * upper_local

	# aim lower leg  knee -> foot
	var lower_local := _aim(leg["lower_rg"], ((leg["A"] as Vector3) - (leg["K"] as Vector3)).normalized(),
			(tc - knee).normalized(), upper_new_global, knee)
	_set_pose(leg["li"], lower_local)

	# move the IK foot chain so the Foot mesh lands on the target
	var delta := tc - (leg["A"] as Vector3)
	var ik_rg: Transform3D = leg["ik_rg"]
	var ik_global := Transform3D(ik_rg.basis, ik_rg.origin + delta)
	var ik_local := (leg["ik_parent_rg"] as Transform3D).affine_inverse() * ik_global
	_set_pose(leg["ii"], ik_local)


# Two-bone IK: given root H, target T, bone lengths L1/L2 and a pole direction,
# returns [knee_position, clamped_target].
func _solve_knee(h: Vector3, t: Vector3, l1: float, l2: float, pole: Vector3) -> Array:
	var to_t := t - h
	var d := clampf(to_t.length(), absf(l1 - l2) + 0.001, l1 + l2 - 0.001)
	var dir := to_t.normalized()
	var tc := h + dir * d
	var a := (l1 * l1 - l2 * l2 + d * d) / (2.0 * d)
	var hgt := sqrt(maxf(0.0, l1 * l1 - a * a))
	var foot_perp := h + dir * a
	var perp := pole - dir * pole.dot(dir)
	if perp.length() < 0.0001:
		perp = dir.cross(Vector3.UP)
		if perp.length() < 0.0001:
			perp = dir.cross(Vector3.RIGHT)
	perp = perp.normalized()
	return [foot_perp + perp * hgt, tc]


# Pose a bone so its GLOBAL frame is its rest frame rotated to aim rest_dir->new_dir,
# relocated to new_origin. Returns the LOCAL transform (relative to parent_global).
func _aim(rest_global: Transform3D, rest_dir: Vector3, new_dir: Vector3, parent_global: Transform3D, new_origin: Vector3) -> Transform3D:
	var q := Quaternion(rest_dir, new_dir)
	var new_global := Transform3D(Basis(q) * rest_global.basis, new_origin)
	return parent_global.affine_inverse() * new_global


func _set_pose(idx: int, local: Transform3D) -> void:
	if idx < 0:
		return
	_skel.set_bone_pose_rotation(idx, local.basis.get_rotation_quaternion())
	_skel.set_bone_pose_position(idx, local.origin)


# Rigid rotation of a bone about a skeleton-space pivot+axis (used for the arms).
func _rotate_about(b: int, pivot: Vector3, axis: Vector3, angle: float) -> void:
	if b < 0:
		return
	_rotate_about_basis(b, pivot, Basis(axis.normalized(), angle))


# Same, but with a pre-composed rotation Basis (used for the head nod+sway).
func _rotate_about_basis(b: int, pivot: Vector3, rot: Basis) -> void:
	if b < 0:
		return
	var about := Transform3D(rot, pivot - rot * pivot)
	var world: Transform3D = about * (_restg[b] as Transform3D)
	var local: Transform3D = (_restgp[b] as Transform3D).affine_inverse() * world
	_skel.set_bone_pose_rotation(b, local.basis.get_rotation_quaternion())
	_skel.set_bone_pose_position(b, local.origin)


func _rest_origin(name: String) -> Vector3:
	var b: int = _idx.get(name, -1)
	if b < 0:
		return Vector3.ZERO
	return (_restg[b] as Transform3D).origin


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null


func _find_body(n: Node) -> Node3D:
	var p := n.get_parent()
	while p != null:
		if p is CharacterBody3D:
			return p as Node3D
		p = p.get_parent()
	return null
