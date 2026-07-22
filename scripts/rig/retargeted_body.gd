class_name RetargetedBody
extends Node3D

# Drop-in VISIBLE body for the player and normal enemies: shows the new main
# character (main_character.glb) driven by the retargeted Mixamo locomotion,
# replacing the procedural ModularSkeletonRig's visual. It is added UNDER
# VisualRoot, so it inherits the facing rotation the animator already applies;
# the old rig + procedural animator stay alive (just hidden) so every gameplay
# system (combat, equipment, head-launch, detachment) keeps working untouched.
#
# Locomotion is derived from the owning CharacterBody3D's velocity each frame;
# attack / jump are forwarded from the body via trigger_attack()/trigger_jump().

const CHARACTER: PackedScene = preload("res://assets/main_character.glb")
const CLIPS := {
	"idle": "res://assets/breathing_idle.fbx",
	"walk": "res://assets/walking.fbx",
	"run": "res://assets/running.fbx",
	"backward": "res://assets/running_backward.fbx",
	"jump": "res://assets/running_jump.fbx",
	"attack": "res://assets/mutant_swiping.fbx",
}

# The skeleton is ~0.9 m; scale it up to fill the ~1.6 m capsule and drop it so
# the feet sit near the capsule bottom. Tunable per-scene.
@export var character_scale: float = 1.9
@export var foot_offset_y: float = -0.92
@export var run_speed: float = 3.4        # velocity that maps to a full run
@export var hide_sibling_rig: bool = true
@export var body_tint: Color = Color(1, 1, 1, 1)   # enemies can tint to read apart
# Aim pose (raise the finger-shooting arm). The finger lives on the LEFT hand.
@export var aim_arm_left: bool = true
@export var aim_upper_deg: float = 88.0    # lift the upper arm to point forward
@export var aim_fore_deg: float = 0.0      # forearm straighten

var _loco: RetargetedLocomotion
var _body: Node3D
var _model: Node3D
var _speed := 0.0
var _backward := 0.0
var _aiming := false
var _aim_weight := 0.0


func _ready() -> void:
	var model := CHARACTER.instantiate()
	add_child(model)
	_model = model
	var skel := _find_skeleton(model)
	if skel == null:
		push_warning("RetargetedBody: no Skeleton3D in main_character.glb")
		return
	scale = Vector3.ONE * character_scale
	position.y = foot_offset_y
	if body_tint != Color(1, 1, 1, 1):
		_apply_tint(model, body_tint)

	_loco = RetargetedLocomotion.new(CLIPS, skel, self, 0.40)
	_loco.uprightness = 0.2
	_loco.jump_lift_scale = 0.0   # the CharacterBody3D owns vertical motion

	_body = _find_body(self)
	if hide_sibling_rig:
		_hide_old_rig()


func _process(delta: float) -> void:
	if _loco == null:
		return
	var v := Vector3.ZERO
	if _body != null:
		var vv: Variant = _body.get("velocity")
		if vv is Vector3:
			v = vv
	var flat := Vector3(v.x, 0.0, v.z)
	var target := clampf(flat.length() / maxf(run_speed, 0.01), 0.0, 1.0)

	# Backpedal: moving opposite to the way we face (only happens while aiming, when
	# facing is locked to the aim instead of the movement direction).
	var back := 0.0
	var parent := get_parent() as Node3D
	if parent != null and flat.length() > 0.05:
		var fwd := parent.global_transform.basis.z    # character faces +Z of VisualRoot
		fwd.y = 0.0
		if fwd.length() > 0.01 and fwd.normalized().dot(flat.normalized()) < -0.25:
			back = clampf(-fwd.normalized().dot(flat.normalized()), 0.0, 1.0)
			target = 0.0

	_speed = lerpf(_speed, target, 1.0 - exp(-9.0 * delta))
	_backward = lerpf(_backward, back, 1.0 - exp(-9.0 * delta))
	_loco.update(delta, _speed, _backward)

	# Raise-the-arm aim overlay (finger shooting). Applied after the gait pose so it
	# reads over walk/idle. Eased in/out.
	_aim_weight = lerpf(_aim_weight, 1.0 if _aiming else 0.0, 1.0 - exp(-14.0 * delta))
	if _aim_weight > 0.001:
		_apply_aim_pose(_aim_weight)


# ---- hooks forwarded from the owning body -------------------------------------

func trigger_attack() -> void:
	if _loco != null:
		_loco.trigger_attack()


func trigger_jump() -> void:
	if _loco != null:
		_loco.trigger_jump()


func set_aiming(enabled: bool) -> void:
	_aiming = enabled


func skeleton() -> Skeleton3D:
	return _find_skeleton(_model) if _model != null else null


# Blend the shooting arm up toward a forward point, by aim weight w.
func _apply_aim_pose(w: float) -> void:
	var skel := skeleton()
	if skel == null:
		return
	var side := "L" if aim_arm_left else "R"
	var ua := _bone(skel, "CC_Base_%s_Upperarm" % side)
	if ua >= 0:
		var cur := skel.get_bone_pose_rotation(ua)
		var lift := Quaternion(Vector3(1, 0, 0), deg_to_rad(aim_upper_deg))
		skel.set_bone_pose_rotation(ua, cur.slerp(cur * lift, w))
	var fa := _bone(skel, "CC_Base_%s_Forearm" % side)
	if fa >= 0:
		var cur2 := skel.get_bone_pose_rotation(fa)
		var straight := Quaternion(Vector3(1, 0, 0), deg_to_rad(aim_fore_deg))
		skel.set_bone_pose_rotation(fa, cur2.slerp(cur2 * straight, w))


func _bone(skel: Skeleton3D, name: String) -> int:
	var b := skel.find_bone(name)
	if b < 0:
		b = skel.find_bone(name.trim_prefix("CC_Base_"))
	return b


# ---- helpers ------------------------------------------------------------------

func _hide_old_rig() -> void:
	var vr := get_parent()
	if vr == null:
		return
	for c in vr.get_children():
		if c == self:
			continue
		if c is Node3D and c.name != "ProceduralAnimator":
			(c as Node3D).visible = false


func _apply_tint(n: Node, c: Color) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		mi.material_override = m
	for ch in n.get_children():
		_apply_tint(ch, c)


func _find_body(n: Node) -> Node3D:
	var p := n.get_parent()
	while p != null:
		if p is CharacterBody3D:
			return p as Node3D
		p = p.get_parent()
	return null


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _find_skeleton(c)
		if f != null:
			return f
	return null
