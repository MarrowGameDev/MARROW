class_name SkeletonPoseAnimator
extends RefCounted

# Full skeleton-driven procedural locomotion for a rigged humanoid Skeleton3D
# (the CC skeleton). Phase 1: reproduces the core of ProceduralPlayerAnimator —
# idle breathing, a walk cycle (leg stride, contralateral arm swing, knee/elbow
# flex), body bob/sway/lean, and turn-to-face — but on the REAL bones instead of
# the grey-box sockets.
#
# Retargeting: a socket rotates about its own axis-aligned X; a CC bone has an
# arbitrary rest orientation, so we can't just add to a local angle. Instead each
# driven bone gets a rotation about a SKELETON-SPACE axis composed onto its rest
# global basis, then converted back to a parent-local pose. Bones are posed
# parent→child so a child (knee/elbow) sees its parent's (thigh/shoulder) updated
# global pose — the chain stays rigid the way a real limb does.

# --- tuning (mirrors ProceduralPlayerAnimator defaults) --------------------
var walk_cycle_speed := 9.0
var body_bob_amount := 0.12
var body_sway_amount := 0.05
var torso_lean_amount := 0.14
var arm_swing_amount := 0.75
var leg_swing_amount := 0.6
var idle_breath_amount := 0.025
var speed_smoothing := 12.0
var turn_smoothing := 12.0
var joint_bend_base := 0.12
var joint_bend_swing := 0.7
var arm_elbow_scale := 0.4   # elbows flex far less than knees

# Sign flips per rig so a swing/bend goes the intuitive way. Tunable if a limb
# bends the wrong direction on a differently-authored skeleton.
var leg_swing_sign := 1.0
var arm_swing_sign := 1.0
var knee_bend_sign := 1.0
var elbow_bend_sign := 1.0
# The CC rest pose is a T-pose; drop the arms to the sides before swinging.
# Left upper-arm points -Z, right +Z, so left drops with -X rotation, right +X.
var arm_down_angle := deg_to_rad(80.0)
var arm_down_sign := -1.0

const BONES := {
	"l_thigh": "CC_Base_L_Thigh", "r_thigh": "CC_Base_R_Thigh",
	"l_calf": "CC_Base_L_Calf", "r_calf": "CC_Base_R_Calf",
	"l_arm": "CC_Base_L_Upperarm", "r_arm": "CC_Base_R_Upperarm",
	"l_fore": "CC_Base_L_Forearm", "r_fore": "CC_Base_R_Forearm",
	"spine": "CC_Base_Waist", "head": "CC_Base_Head",
}
# This CC skeleton faces +X, up +Y, so its lateral (left-right) axis is Z. Limbs
# stride / flex / lean about the LATERAL axis; sway/roll is about the FORWARD one.
const AXIS_FWD := Vector3(1.0, 0.0, 0.0)
const AXIS_LAT := Vector3(0.0, 0.0, 1.0)

var skeleton: Skeleton3D
var root: Node3D                 # moved for bob; rotated for facing

var speed_ratio := 0.0
var walk_time := 0.0
var _time := 0.0
var _captured := false
var _idx: Dictionary = {}         # key -> bone index
var _rest_basis: Dictionary = {}  # bone index -> rest global basis
var _root_rest_y := 0.0
var _yaw := 0.0


func _init(skel: Skeleton3D, root_node: Node3D) -> void:
	skeleton = skel
	root = root_node


# Cache bone indices + rest global bases (call once, in-tree, at the rest pose).
func _capture() -> void:
	for key in BONES:
		var b := skeleton.find_bone(BONES[key])
		_idx[key] = b
		if b >= 0:
			_rest_basis[b] = skeleton.get_bone_global_pose(b).basis.orthonormalized()
	if root != null:
		_root_rest_y = root.position.y
		_yaw = root.rotation.y
	_captured = true


# Drive one frame. `velocity`/`max_speed` set the gait speed; `facing` (a
# horizontal direction, may be zero) turns the body.
func update(delta: float, velocity: Vector3, max_speed: float, facing: Vector3) -> void:
	if skeleton == null:
		return
	if not _captured:
		_capture()

	_time += delta
	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	var target := clampf(horiz.length() / maxf(max_speed, 0.001), 0.0, 1.0)
	speed_ratio = lerpf(speed_ratio, target, 1.0 - exp(-speed_smoothing * delta))
	walk_time += delta * walk_cycle_speed * speed_ratio

	var swing := sin(walk_time) * speed_ratio

	# Legs stride fore/aft about the lateral axis; arms swing contralaterally
	# (right arm forward with left leg).
	_pose("l_thigh", Basis(AXIS_LAT, swing * leg_swing_amount * leg_swing_sign))
	_pose("r_thigh", Basis(AXIS_LAT, -swing * leg_swing_amount * leg_swing_sign))

	# Knees / elbows flex on a phase-shifted wave (left leg & right arm lead by PI).
	_pose("l_calf", Basis(AXIS_LAT, _bend_angle(PI) * knee_bend_sign))
	_pose("r_calf", Basis(AXIS_LAT, _bend_angle(0.0) * knee_bend_sign))

	# Arms: first drop from the T-pose to hang at the sides (rotate about the
	# forward axis), THEN swing fore/aft about the lateral axis.
	var ld := arm_down_angle * arm_down_sign
	_pose("l_arm", Basis(AXIS_LAT, -swing * arm_swing_amount * arm_swing_sign) * Basis(AXIS_FWD, ld))
	_pose("r_arm", Basis(AXIS_LAT, swing * arm_swing_amount * arm_swing_sign) * Basis(AXIS_FWD, -ld))
	_pose("l_fore", Basis(AXIS_LAT, _bend_angle(0.0) * elbow_bend_sign * arm_elbow_scale))
	_pose("r_fore", Basis(AXIS_LAT, _bend_angle(PI) * elbow_bend_sign * arm_elbow_scale))

	# Torso lean into movement + walk sway; head counters the sway a little.
	var lean := torso_lean_amount * speed_ratio
	var sway := sin(walk_time) * body_sway_amount * speed_ratio
	_pose("spine", Basis(AXIS_LAT, lean) * Basis(AXIS_FWD, -sway * 0.6))
	_pose("head", Basis(AXIS_FWD, sway * 0.3))

	# Bob + idle breath ride the root node; facing turns it.
	if root != null:
		var bob := absf(sin(walk_time)) * body_bob_amount * speed_ratio
		var breath := sin(_time * 1.8) * idle_breath_amount * (1.0 - speed_ratio)
		root.position.y = _root_rest_y + bob + breath
		_turn_toward(facing, delta)


# --- pose helpers ----------------------------------------------------------

func _bend_angle(phase: float) -> float:
	var wave := 0.5 + 0.5 * sin(walk_time + phase)
	return joint_bend_base + joint_bend_swing * speed_ratio * wave


# Rotate a bone by `delta_skeleton` (a skeleton-space rotation) applied to its
# rest orientation, written back as a parent-local pose.
func _pose(key: String, delta_skeleton: Basis) -> void:
	var b: int = _idx.get(key, -1)
	if b < 0 or not _rest_basis.has(b):
		return
	var rest_basis: Basis = _rest_basis[b]
	var desired: Basis = delta_skeleton * rest_basis
	var parent := skeleton.get_bone_parent(b)
	var parent_basis: Basis = skeleton.get_bone_global_pose(parent).basis if parent >= 0 else Basis()
	var local: Basis = parent_basis.inverse() * desired
	skeleton.set_bone_pose_rotation(b, local.get_rotation_quaternion())


func _turn_toward(facing: Vector3, delta: float) -> void:
	var flat := Vector3(facing.x, 0.0, facing.z)
	if flat.length() < 0.01:
		return
	var target_yaw := atan2(flat.x, flat.z)
	_yaw = lerp_angle(_yaw, target_yaw, 1.0 - exp(-turn_smoothing * delta))
	root.rotation.y = _yaw
