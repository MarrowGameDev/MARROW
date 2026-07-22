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
# Assembly: start showing only the head, then reveal the torso (ribs+spine+hips)
# when it's picked up. Limbs stay hidden until later. Each partial state drops the
# body so the visible bottom sits near the ground (a head on the floor, then the
# ribcage building up), instead of floating at full standing height.
@export var start_as_head: bool = false
@export var head_only_y: float = -2.05     # skull rests near the floor
@export var head_torso_y: float = -1.5     # hips near the floor, head above

var _loco: RetargetedLocomotion
var _body: Node3D
var _model: Node3D
var _speed := 0.0
var _backward := 0.0
var _aiming := false
var _aim_weight := 0.0
var _disabled := false
var _head_meshes: Array = []
var _torso_meshes: Array = []
var _limb_meshes: Array = []
var _head_follower_active := false
@export var swirl_radius: float = 0.3      # base orbit radius of the tornado (model space)
var _swirl_meshes: Array = []
var _swirl_rest: Array = []
var _swirl_angle: Array = []   # each part's base angle around the tornado
var _swirl_rad: Array = []     # each part's orbit radius
var _swirl_lift: Array = []    # each part's vertical rise


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

	_categorize_parts(model)
	if start_as_head:
		show_only_head()


func _process(delta: float) -> void:
	if _loco == null or _disabled or _head_follower_active:
		return   # while a detached head is driving the visual, skip gait posing
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
	if _loco != null and not _disabled:
		_loco.trigger_attack()


func trigger_jump() -> void:
	if _loco != null and not _disabled:
		_loco.trigger_jump()


func set_aiming(enabled: bool) -> void:
	_aiming = enabled


func skeleton() -> Skeleton3D:
	return _find_skeleton(_model) if _model != null else null


# ---- body-part assembly (head -> +torso) --------------------------------------

# Sort the character's authored part-meshes into head / torso / limbs by name.
func _categorize_parts(model: Node) -> void:
	_head_meshes.clear(); _torso_meshes.clear(); _limb_meshes.clear()
	for mi in _all_meshes(model):
		var n := String(mi.name).to_lower()
		# Torso first: the neck/spine vertebrae belong to the body, not the skull
		# (e.g. the "upper spine(neck" mesh), so they only appear with the torso.
		if "rib" in n or "spine" in n or "hip" in n or "solar" in n or "shoulder" in n or "pelvis" in n or "neck" in n:
			_torso_meshes.append(mi)
		elif "skull" in n or "teeth" in n or "head" in n or "jaw" in n:
			_head_meshes.append(mi)
		else:
			_limb_meshes.append(mi)
	_build_body_swirl()


# Cache every head + torso part so they can whirl apart in a cartoon tornado and
# spiral back into place. Each part gets a base angle around the column, an orbit
# radius, and a lift (higher parts rise more), so at full whirl they circle the
# body and, as the whirl eases off, they spiral back to rest.
func _build_body_swirl() -> void:
	_swirl_meshes.clear(); _swirl_rest.clear(); _swirl_angle.clear(); _swirl_rad.clear(); _swirl_lift.clear()
	var parts: Array = _head_meshes + _torso_meshes
	const GOLDEN := 2.399963   # spreads the parts evenly around the tornado
	for i in range(parts.size()):
		var mi := parts[i] as MeshInstance3D
		_swirl_meshes.append(mi)
		_swirl_rest.append(mi.position)
		_swirl_angle.append(float(i) * GOLDEN)
		_swirl_rad.append(swirl_radius * (0.6 + 0.55 * fmod(float(i) * 0.37, 1.0)))
		var cy := mi.mesh.get_aabb().get_center().y if mi.mesh != null else 0.0
		_swirl_lift.append(cy * 0.55 + 0.08)   # head/upper parts fly higher


# w = 0 assembled .. 1 fully whirling; phase = the tornado spin angle (advances over
# time). Each part orbits its base angle+phase at radius*w and rises by lift*w.
func set_body_swirl(w: float, phase: float) -> void:
	var ww := clampf(w, 0.0, 1.0)
	for i in range(_swirl_meshes.size()):
		var mi := _swirl_meshes[i] as MeshInstance3D
		if not is_instance_valid(mi):
			continue
		var a: float = (_swirl_angle[i] as float) + phase
		var r: float = (_swirl_rad[i] as float) * ww
		var lift: float = (_swirl_lift[i] as float) * ww
		mi.position = (_swirl_rest[i] as Vector3) + Vector3(cos(a) * r, lift + sin(a * 1.6) * r * 0.25, sin(a) * r * 0.6)


func show_only_head() -> void:
	_set_visible(_head_meshes, true)
	_set_visible(_torso_meshes, false)
	_set_visible(_limb_meshes, false)
	position.y = head_only_y


func reveal_torso() -> void:
	_set_visible(_torso_meshes, true)
	position.y = head_torso_y


func show_all_parts() -> void:
	_set_visible(_head_meshes, true)
	_set_visible(_torso_meshes, true)
	_set_visible(_limb_meshes, true)
	position.y = foot_offset_y


# Head-only mode: hide the skinned body and hand back a RIGID copy of the head
# meshes, centred on their own centre so a caller can roll it like a ball by
# driving its transform from the old rig's rolling head socket.
func enter_head_follower_mode(follower_scale: float = 1.0) -> Node3D:
	_head_follower_active = true
	if _model != null:
		_model.visible = false
	var follower := Node3D.new()
	follower.name = "HeadFollower"
	# Centre offset: the head meshes' combined bind-pose centre (mesh-local space).
	var combined := AABB()
	var seeded := false
	for mi in _head_meshes:
		var m := (mi as MeshInstance3D).mesh
		if m == null:
			continue
		var a := m.get_aabb()
		combined = a if not seeded else combined.merge(a)
		seeded = true
	var center := combined.position + combined.size * 0.5 if seeded else Vector3.ZERO
	for mi in _head_meshes:
		var src := mi as MeshInstance3D
		var dup := MeshInstance3D.new()
		dup.mesh = src.mesh
		dup.material_override = src.material_override
		dup.scale = Vector3.ONE * follower_scale
		dup.position = -center * follower_scale   # centre the skull on the follower origin
		follower.add_child(dup)
	return follower


func exit_head_follower_mode() -> void:
	_head_follower_active = false
	if _model != null:
		_model.visible = true


# The head/torso meshes only (used to build the floor pickup's visual).
func head_mesh_names() -> Array:
	return _head_meshes.map(func(m): return String(m.name))


func torso_mesh_names() -> Array:
	return _torso_meshes.map(func(m): return String(m.name))


func _set_visible(meshes: Array, v: bool) -> void:
	for m in meshes:
		if is_instance_valid(m):
			(m as MeshInstance3D).visible = v


func _all_meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_all_meshes(c))
	return out


# Turn this body OFF and restore the original procedural rig — used for enemy
# variants (lizard, gorilla) that keep their own visual.
func disable() -> void:
	_disabled = true
	set_process(false)
	if _model != null:
		_model.queue_free()
		_model = null
	var vr := get_parent()
	if vr != null:
		for c in vr.get_children():
			if c != self and c is Node3D and c.name != "ProceduralAnimator":
				(c as Node3D).visible = true


func is_disabled() -> bool:
	return _disabled


# Re-tint at runtime (enemies color their skeleton to read as hostile).
func set_body_tint(c: Color) -> void:
	body_tint = c
	if _model != null:
		_apply_tint(_model, c)


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
