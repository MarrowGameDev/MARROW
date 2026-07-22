class_name DinosaurWalker
extends Node3D

# Procedural quadruped walk for the rigged dinosaur (dinosaur.glb). A diagonal
# gait schedules each foot's stance/swing; each foot's world target is solved with
# ChainIK (FABRIK over the 3-segment leg) and the leg bones are posed to match by
# a look-at chain. Front legs = leg2_*, back legs = leg1_*; the rig faces +Z.
#
# It drives ONLY the legs (+ a gentle body bob), so it composes with the enemy's
# own forward motion: set `move_speed` to how fast the body is actually travelling
# and the stride/cycle scale to it.

const MODEL: PackedScene = preload("res://assets/dinosaur.glb")

@export var cycle_hz: float = 1.4          # gait cycles per second at full speed
@export var stride: float = 0.14           # metres the foot travels fore/aft
@export var foot_lift: float = 0.07        # swing-arc height
@export var duty: float = 0.65             # fraction of the cycle a foot is planted
@export var body_bob: float = 0.015        # vertical body sway
@export var auto_advance: float = 0.0      # >0: also translate this node forward (demo)

# leg id -> {bones:[hip,j1,j2,foot], phase, side}. Diagonal gait: front-left pairs
# with back-right (phase 0); front-right with back-left (phase 0.5).
const LEGS := {
	"fl": {"names": ["leg2_hip_l", "leg2_joint_1_l", "leg2_joint_2_l", "leg2_foot_l"], "phase": 0.0, "side": 1.0},
	"fr": {"names": ["leg2_hip_r", "leg2_joint_1_r", "leg2_joint_2_r", "leg2_foot_r"], "phase": 0.5, "side": -1.0},
	"bl": {"names": ["leg1_hip_l", "leg1_joint_1_l", "leg1_joint_2_l", "leg1_foot_l"], "phase": 0.5, "side": 1.0},
	"br": {"names": ["leg1_hip_r", "leg1_joint_1_r", "leg1_joint_2_r", "leg1_foot_r"], "phase": 0.0, "side": -1.0},
}

var _skel: Skeleton3D
var _legs: Dictionary = {}          # id -> {bones, lengths, rest_foot, hip, phase, side}
var _root_bone := -1
var _root_rest_y := 0.0
var _t := 0.0
var _speed_ratio := 1.0             # 0..1, set by the owner (0 = stand)


func _ready() -> void:
	var model := MODEL.instantiate()
	add_child(model)
	_skel = _find_skeleton(model)
	if _skel == null:
		push_warning("DinosaurWalker: no skeleton")
		return
	_root_bone = _skel.find_bone("root")
	if _root_bone >= 0:
		_root_rest_y = _skel.get_bone_pose_position(_root_bone).y
	for id in LEGS:
		var spec: Dictionary = LEGS[id]
		var bones: Array = []
		for n in spec["names"]:
			bones.append(_skel.find_bone(n))
		if bones.has(-1):
			continue
		var lengths: Array = []
		for i in range(bones.size() - 1):
			lengths.append(_bpos(bones[i]).distance_to(_bpos(bones[i + 1])))
		_legs[id] = {
			"bones": bones, "lengths": lengths,
			"rest_foot": _bpos(bones[3]), "hip_rest": _bpos(bones[0]),
			"phase": spec["phase"], "side": spec["side"],
		}


func set_speed_ratio(r: float) -> void:
	_speed_ratio = clampf(r, 0.0, 1.0)


func _process(delta: float) -> void:
	if _skel == null or _legs.is_empty():
		return
	_t += delta * cycle_hz * _speed_ratio
	if auto_advance > 0.0:
		position += global_transform.basis.z * auto_advance * _speed_ratio * delta

	for id in _legs:
		_solve_leg(_legs[id])

	# Gentle body bob: two dips per stride, scaled by movement.
	if _root_bone >= 0 and body_bob > 0.0:
		var p := _skel.get_bone_pose_position(_root_bone)
		p.y = _root_rest_y + sin(_t * TAU * 2.0) * body_bob * _speed_ratio
		_skel.set_bone_pose_position(_root_bone, p)


func _solve_leg(leg: Dictionary) -> void:
	var bones: Array = leg["bones"]
	var lengths: Array = leg["lengths"]
	var rest_foot: Vector3 = leg["rest_foot"]
	var phase: float = leg["phase"]

	# Foot target = rest foot + fore/aft stride (planted moves back, swing arcs fwd).
	var ph := fposmod(_t + phase, 1.0)
	var z := 0.0
	var lift := 0.0
	if ph < duty:
		# Stance: plant slides from front (+) to back (-).
		var s := ph / duty
		z = lerpf(stride * 0.5, -stride * 0.5, s)
	else:
		# Swing: sweep back-to-front and lift in an arc.
		var s := (ph - duty) / (1.0 - duty)
		z = lerpf(-stride * 0.5, stride * 0.5, s)
		lift = sin(s * PI) * foot_lift
	z *= _speed_ratio
	lift *= _speed_ratio

	var target := rest_foot + Vector3(0.0, lift, z)
	var hip := _bpos(bones[0])
	# Pole: bend the knee outward + slightly forward so it resolves like a leg.
	var pole := hip + Vector3(leg["side"] * 0.4, -0.3, 0.25)
	var pts := ChainIK.solve(hip, lengths, target, pole)
	_pose_chain(bones, pts)


# Orient each leg bone so its child points along the solved segment (skeleton space).
func _pose_chain(bones: Array, pts: PackedVector3Array) -> void:
	for k in range(bones.size() - 1):
		var b: int = bones[k]
		var bpos := _bpos(b)
		var cur := _bpos(bones[k + 1]) - bpos
		var want := pts[k + 1] - pts[k]
		if cur.length() < 1e-5 or want.length() < 1e-5:
			continue
		var q := Quaternion(cur.normalized(), want.normalized())
		var gb := _skel.get_bone_global_pose(b).basis
		var new_gb := Basis(q) * gb
		var par := _skel.get_bone_parent(b)
		var parent_basis: Basis = _skel.get_bone_global_pose(par).basis if par >= 0 else Basis()
		_skel.set_bone_pose_rotation(b, (parent_basis.inverse() * new_gb).get_rotation_quaternion())


func _bpos(bone: int) -> Vector3:
	return _skel.get_bone_global_pose(bone).origin


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _find_skeleton(c)
		if f != null:
			return f
	return null
