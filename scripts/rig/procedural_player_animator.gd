class_name ProceduralPlayerAnimator
extends Node3D

# Velocity-driven procedural animation (Marrow rigging brief, Phases B/D/E/F).
# Reads ACTUAL velocity (not raw input) so it reacts to slopes, knockback, and
# speed bonuses, and moves the rig's sockets. Bones parented to sockets follow.

@export var rig: ModularSkeletonRig
@export var turn_target: Node3D            # usually VisualRoot; rotates toward facing

# --- Tuning (from the brief's suggested values) -------------------------------
@export var walk_cycle_speed := 9.0
@export var body_bob_amount := 0.12
@export var body_sway_amount := 0.05
@export var torso_lean_amount := 0.14
@export var arm_swing_amount := 0.75
@export var leg_swing_amount := 0.6
@export var turn_smoothing := 12.0
@export var idle_breath_amount := 0.025
@export var speed_smoothing := 12.0
@export var heavy_weight_swing_slowdown := 0.65

@export_group("Crawl")
@export var crawl_mode := false
@export var crawl_body_drop := 0.46
@export var crawl_body_pitch := 1.08
@export var crawl_pull_amount := 1.35
@export var crawl_arm_drop := 0.42
@export var crawl_head_lift := 0.48
@export var crawl_forward_offset := 0.18
@export var crawl_arm_reach := 0.18
@export var crawl_leg_tuck := 0.72
@export var crawl_shoulder_roll := 0.42
@export var lizard_torso_flex_amount := 0.12
@export var lizard_wall_climb_lift := 0.18
@export var lizard_wall_climb_pitch := 0.42
@export var lizard_wall_climb_head_lift := 0.16
@export var lizard_wall_climb_limb_reach := 0.34
@export var head_only_hop_amount := 0.18
@export var head_only_roll_amount := 0.42

# Bend at the limb mid-joint (elbow/knee) so limbs flex instead of staying stiff.
@export var joint_bend_base := 0.12    # radians always bent a little (never a stick)
@export var joint_bend_swing := 0.7    # extra bend through the walk cycle

# Loose-skeleton wobble: each bone jiggles and slides in/out of its socket, so it
# rattles like a skeleton (always on, even standing still).
@export_group("Skeleton wobble")
@export var wobble_enabled := true
@export var wobble_rotation := 0.035   # radians of GENTLE idle jiggle
@export var wobble_slide := 0.012      # meters the bone slides in/out of its socket
@export var wobble_speed := 2.5        # slow, coherent sway (not chaotic)

# Environment reaction: the figure leans to match the floor slope and tips away
# from nearby objects/walls.
@export_group("Environment reaction")
@export var env_reaction_enabled := true
@export var slope_influence := 0.7
@export var object_lean := 0.15
@export var object_range := 1.2
@export var env_smoothing := 8.0

@export_group("Attack overlay")
@export var attack_overlay_duration := 0.16
@export var attack_overlay_blend_speed := 18.0
@export var attack_arm_forward := 1.1       # radians the right arm swings forward
@export var attack_torso_twist := 0.35      # radians the torso twists into the swing
@export var attack_lunge := 0.22            # radians the body leans into the swing
@export var combo_left_arm_forward := 1.0
@export var combo_finisher_arm_forward := 0.85
@export var combo_finisher_torso_twist := 0.5
@export var combo_finisher_lunge := 0.34

@export_group("Aim overlay")
@export var aim_overlay_blend_speed := 14.0
@export var aim_right_arm_forward := 0.82
@export var aim_left_arm_forward := 1.18
@export var aim_right_arm_draw := 0.38
@export var aim_left_arm_brace := 0.26
@export var aim_torso_lean := 0.12
@export var aim_head_dip := 0.08

# Foot placement is superseded by feet-follow-legs (feet are parented under the
# legs now), so this is OFF by default. Turn on for independent ground planting.
@export_group("Foot placement")
@export var foot_placement_enabled := false
@export var foot_raycast_up := 0.6
@export var foot_raycast_down := 1.4
@export var foot_lift := 0.06
@export var foot_smoothing := 14.0
@export var foot_align_to_normal := true

var walk_time := 0.0
var _time := 0.0
var speed_ratio := 0.0
var total_equipped_weight := 1.0

var _attack_timer := 0.0
var _attack_blend := 0.0
var _attack_duration_current := 0.16
var _attack_combo_step := 1
var _aim_requested := false
var _aim_blend := 0.0
var _lizard_wall_climb_blend := 0.0

var _rest_pos: Dictionary = {}
var _rest_rot: Dictionary = {}
var _captured := false
var _body: Node3D = null

const ANIMATED_KEYS := ["body", "head", "right_arm", "left_arm", "right_leg", "left_leg"]
const FOOT_KEYS := ["left_foot", "right_foot"]


# Called by the player AFTER move_and_slide(), so velocity is the resolved motion.
func update_from_player(delta: float, velocity: Vector3, max_speed: float, facing_direction: Vector3, equipped_defs: Array) -> void:
	if rig == null:
		return
	if not _captured:
		_capture_rest()

	_time += delta

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var target_ratio: float = clamp(horizontal.length() / max(max_speed, 0.001), 0.0, 1.0)
	speed_ratio = lerp(speed_ratio, target_ratio, 1.0 - exp(-speed_smoothing * delta))

	total_equipped_weight = _calculate_weight(equipped_defs)
	var weight_slowdown: float = clamp(1.0 / max(total_equipped_weight, 1.0), heavy_weight_swing_slowdown, 1.0)

	walk_time += delta * walk_cycle_speed * speed_ratio * weight_slowdown

	if crawl_mode:
		_animate_crawl_body()
		_animate_crawl_limbs()
	else:
		_animate_body()
		_animate_limbs()
		_animate_joints()
	_animate_wobble()
	_apply_lizard_wall_climb_limb_pose()
	_update_aim_overlay(delta)
	_apply_aim_overlay()
	_update_attack_overlay(delta)
	_apply_attack_overlay()
	_animate_facing(delta, facing_direction)
	if foot_placement_enabled:
		_animate_feet(delta)


# The player calls this when an attack fires (Phase E).
func trigger_attack(combo_step: int = 0) -> void:
	if combo_step <= 0:
		_attack_combo_step = (_attack_combo_step % 3) + 1
	else:
		_attack_combo_step = clampi(combo_step, 1, 3)
	_attack_duration_current = attack_overlay_duration
	if _attack_combo_step == 3:
		_attack_duration_current *= 1.15
	_attack_timer = _attack_duration_current
	_attack_blend = maxf(_attack_blend, 0.25)


func set_aiming(enabled: bool) -> void:
	_aim_requested = enabled


func set_crawl_mode(enabled: bool) -> void:
	crawl_mode = enabled


func set_lizard_wall_climb_blend(blend: float) -> void:
	_lizard_wall_climb_blend = clampf(blend, 0.0, 1.0)


func _capture_rest() -> void:
	# Capture EVERY socket's rest pose (body/limbs animate; feet get placed).
	for key in rig.sockets:
		var s := rig.get_socket(key)
		if s != null:
			_rest_pos[key] = s.position
			_rest_rot[key] = s.rotation
	_captured = true


func _get_rest_pos(key: String) -> Vector3:
	var value = _rest_pos.get(key, Vector3.ZERO)
	if value is Vector3:
		return value
	return Vector3.ZERO


func _get_rest_rot(key: String) -> Vector3:
	var value = _rest_rot.get(key, Vector3.ZERO)
	if value is Vector3:
		return value
	return Vector3.ZERO


func _calculate_weight(equipped_defs: Array) -> float:
	var w := 1.0
	for def in equipped_defs:
		if def is Dictionary:
			w += float(def.get("weight", 1.0)) - 1.0
	return max(w, 1.0)


func _animate_body() -> void:
	var sway := sin(walk_time) * body_sway_amount * total_equipped_weight * speed_ratio
	var bob := absf(sin(walk_time)) * body_bob_amount * speed_ratio
	var breath := sin(_time * 1.8) * idle_breath_amount * (1.0 - speed_ratio)
	if _is_head_only():
		_animate_head_only(sway, breath)
		return

	var body := rig.get_socket("body")
	if body != null and _rest_pos.has("body"):
		body.position = _get_rest_pos("body") + Vector3(sway, bob + breath + lizard_wall_climb_lift * _lizard_wall_climb_blend, -0.08 * _lizard_wall_climb_blend)
		body.rotation = _get_rest_rot("body") + Vector3(torso_lean_amount * speed_ratio + lizard_wall_climb_pitch * _lizard_wall_climb_blend, 0.0, -sway * 0.6)

	var head := rig.get_socket("head")
	if head != null and _rest_pos.has("head"):
		head.position = _get_rest_pos("head") + Vector3(0.0, breath * 0.6 + lizard_wall_climb_head_lift * _lizard_wall_climb_blend, -0.10 * _lizard_wall_climb_blend)
		head.rotation = _get_rest_rot("head") + Vector3(-lizard_wall_climb_pitch * 0.35 * _lizard_wall_climb_blend, 0.0, sway * 0.3)
	_animate_lizard_torso_blocks(sway, breath, 0.0)


func _is_head_only() -> bool:
	return rig != null and rig.has_method("has_equipped_slot") and not bool(rig.call("has_equipped_slot", "body"))


func _animate_head_only(sway: float, breath: float) -> void:
	var head := rig.get_socket("head")
	if head == null or not _rest_pos.has("head"):
		return

	var hop: float = absf(sin(walk_time)) * head_only_hop_amount * speed_ratio
	var idle: float = breath * 0.6
	head.position = _get_rest_pos("head") + Vector3(sway * 0.8, hop + idle - 0.22, 0.0)
	head.rotation = _get_rest_rot("head") + Vector3(0.0, 0.0, -sin(walk_time) * head_only_roll_amount * speed_ratio)


func _animate_limbs() -> void:
	var swing := sin(walk_time) * speed_ratio
	# Arms swing opposite to the legs (right arm forward with left leg) and forward
	# with movement — flipped from before, which sent them backward.
	_swing("right_arm", -swing * arm_swing_amount)
	_swing("left_arm", swing * arm_swing_amount)
	_swing("right_leg", -swing * leg_swing_amount)
	_swing("left_leg", swing * leg_swing_amount)


func _animate_crawl_body() -> void:
	var pull := sin(walk_time)
	var shove := absf(pull) * body_bob_amount * 0.65 * speed_ratio
	var breath := sin(_time * 1.8) * idle_breath_amount * (1.0 - speed_ratio)
	var forward_shove := absf(pull) * crawl_forward_offset * speed_ratio

	var body := rig.get_socket("body")
	if body != null and _rest_pos.has("body"):
		body.position = _get_rest_pos("body") + Vector3(pull * body_sway_amount * 0.65 * speed_ratio, -crawl_body_drop + shove + breath + lizard_wall_climb_lift * _lizard_wall_climb_blend, -forward_shove - 0.08 * _lizard_wall_climb_blend)
		body.rotation = _get_rest_rot("body") + Vector3(crawl_body_pitch + lizard_wall_climb_pitch * 0.45 * _lizard_wall_climb_blend, pull * 0.10 * speed_ratio, -pull * 0.16 * speed_ratio)

	var head := rig.get_socket("head")
	if head != null and _rest_pos.has("head"):
		head.position = _get_rest_pos("head") + Vector3(0.0, -crawl_body_drop - 0.12 + breath + lizard_wall_climb_head_lift * _lizard_wall_climb_blend, -0.22 - forward_shove * 0.35 - 0.08 * _lizard_wall_climb_blend)
		head.rotation = _get_rest_rot("head") + Vector3(-crawl_head_lift, pull * 0.06 * speed_ratio, pull * 0.10 * speed_ratio)
	_animate_lizard_torso_blocks(pull * body_sway_amount * speed_ratio, breath, crawl_body_pitch)


func _animate_crawl_limbs() -> void:
	var pull := sin(walk_time) * speed_ratio
	var right_pull := maxf(pull, 0.0)
	var left_pull := maxf(-pull, 0.0)

	_swing("right_arm", -0.45 - right_pull * crawl_pull_amount + left_pull * 0.35)
	_swing("left_arm", -0.45 - left_pull * crawl_pull_amount + right_pull * 0.35)

	var right_arm := rig.get_socket("right_arm")
	if right_arm != null:
		right_arm.position = _get_rest_pos("right_arm") + Vector3(0.06 * right_pull, -crawl_arm_drop, 0.08 - right_pull * crawl_arm_reach)
		right_arm.rotation.z += right_pull * crawl_shoulder_roll - left_pull * 0.18
	var left_arm := rig.get_socket("left_arm")
	if left_arm != null:
		left_arm.position = _get_rest_pos("left_arm") + Vector3(-0.06 * left_pull, -crawl_arm_drop, 0.08 - left_pull * crawl_arm_reach)
		left_arm.rotation.z -= left_pull * crawl_shoulder_roll - right_pull * 0.18

	_swing("right_leg", crawl_leg_tuck)
	_swing("left_leg", crawl_leg_tuck)
	var right_leg := rig.get_socket("right_leg")
	if right_leg != null:
		right_leg.position = _get_rest_pos("right_leg") + Vector3(0.03, -0.10, 0.16)
	var left_leg := rig.get_socket("left_leg")
	if left_leg != null:
		left_leg.position = _get_rest_pos("left_leg") + Vector3(-0.03, -0.10, 0.16)
	var right_foot := rig.get_socket("right_foot")
	if right_foot != null:
		right_foot.position = _get_rest_pos("right_foot") + Vector3(0.0, 0.02, 0.12)
		right_foot.rotation = _get_rest_rot("right_foot") + Vector3(crawl_leg_tuck * 0.5, 0.0, 0.0)
	var left_foot := rig.get_socket("left_foot")
	if left_foot != null:
		left_foot.position = _get_rest_pos("left_foot") + Vector3(0.0, 0.02, 0.12)
		left_foot.rotation = _get_rest_rot("left_foot") + Vector3(crawl_leg_tuck * 0.5, 0.0, 0.0)


func _apply_lizard_wall_climb_limb_pose() -> void:
	if _lizard_wall_climb_blend <= 0.001:
		return

	var reach: float = lizard_wall_climb_limb_reach * _lizard_wall_climb_blend
	var right_arm: Node3D = rig.get_socket("right_arm")
	if right_arm != null:
		right_arm.position = right_arm.position + Vector3(0.04, reach * 0.35, -reach)
		right_arm.rotation.x -= reach * 1.8
		right_arm.rotation.z += reach * 0.55
	var left_arm: Node3D = rig.get_socket("left_arm")
	if left_arm != null:
		left_arm.position = left_arm.position + Vector3(-0.04, reach * 0.35, -reach)
		left_arm.rotation.x -= reach * 1.8
		left_arm.rotation.z -= reach * 0.55

	var right_leg: Node3D = rig.get_socket("right_leg")
	if right_leg != null:
		right_leg.position = right_leg.position + Vector3(0.02, -reach * 0.12, reach * 0.35)
		right_leg.rotation.x += reach * 0.9
	var left_leg: Node3D = rig.get_socket("left_leg")
	if left_leg != null:
		left_leg.position = left_leg.position + Vector3(-0.02, -reach * 0.12, reach * 0.35)
		left_leg.rotation.x += reach * 0.9


func _animate_lizard_torso_blocks(sway: float, breath: float, base_pitch: float) -> void:
	if rig == null:
		return

	var body: Node3D = rig.get_socket("body")
	if body == null:
		return

	var front: Node3D = body.get_node_or_null("LizardTorsoFront") as Node3D
	var rear: Node3D = body.get_node_or_null("LizardTorsoRear") as Node3D
	if front == null or rear == null:
		return

	var flex: float = sin(walk_time) * lizard_torso_flex_amount * speed_ratio
	var idle_flex: float = sin(_time * 1.6) * lizard_torso_flex_amount * 0.25 * (1.0 - speed_ratio)
	var total_flex: float = flex + idle_flex + sway * 0.45
	var wall_pitch: float = lizard_wall_climb_pitch * _lizard_wall_climb_blend
	front.rotation = Vector3(base_pitch * 0.18 + wall_pitch * 0.55, total_flex, -total_flex * 0.35)
	rear.rotation = Vector3(-base_pitch * 0.10 - wall_pitch * 0.25, -total_flex * 0.8, total_flex * 0.25)
	front.position.y = -0.02 + breath * 0.4 + lizard_wall_climb_lift * 0.35 * _lizard_wall_climb_blend
	rear.position.y = -0.04 - breath * 0.2 - lizard_wall_climb_lift * 0.12 * _lizard_wall_climb_blend


func _swing(key: String, angle: float) -> void:
	var s := rig.get_socket(key)
	if s != null and _rest_rot.has(key):
		s.rotation = _get_rest_rot(key) + Vector3(angle, 0.0, 0.0)


# Bends each limb's mid joint (elbow/knee) so the limb flexes during the walk
# instead of swinging as one rigid stick. Poses the skinned bone directly.
func _animate_joints() -> void:
	if rig == null:
		return
	for key in rig.limb_joints:
		var info: Dictionary = rig.limb_joints[key]
		var skel: Skeleton3D = info["skel"]
		if skel == null or not is_instance_valid(skel):
			continue
		var bone: int = info["bone"]
		var rest_rot: Quaternion = info["rest_rot"]
		var wave := 0.5 + 0.5 * sin(walk_time + _joint_phase(key))
		var bend := joint_bend_base + joint_bend_swing * speed_ratio * wave
		# Elbows bend forward, knees bend backward — flip the arm direction.
		var bend_sign := -1.0 if ("arm" in key) else 1.0
		skel.set_bone_pose_rotation(bone, rest_rot * Quaternion(Vector3(1.0, 0.0, 0.0), bend * bend_sign))


func _joint_phase(key: String) -> float:
	match key:
		"left_leg":
			return PI
		"right_arm":
			return PI
		_:
			return 0.0


# Loose-skeleton rattle: adds a small jiggle rotation on top of the swing and
# slides each bone slightly in and out of its socket, each with its own phase.
func _animate_wobble() -> void:
	if not wobble_enabled or rig == null:
		return

	for key in ["right_arm", "left_arm", "right_leg", "left_leg", "left_foot", "right_foot", "head"]:
		var s := rig.get_socket(key)
		if s == null or not _rest_pos.has(key):
			continue

		var ph := _wobble_phase(key)
		var wx := sin(_time * wobble_speed + ph) * wobble_rotation
		var wz := sin(_time * wobble_speed * 1.4 + ph * 1.6) * wobble_rotation

		# Arms/legs already got a swing this frame — add the jiggle on top. Feet and
		# head have no swing, so set their rotation from rest + jiggle.
		if _rest_rot.has(key) and (key == "left_foot" or key == "right_foot" or key == "head"):
			s.rotation = _get_rest_rot(key) + Vector3(wx, 0.0, wz)
		else:
			s.rotation += Vector3(wx, 0.0, wz)

		# Slide the bone in and out along its outward direction from the body.
		var rest_pos: Vector3 = _get_rest_pos(key)
		var base_pos: Vector3 = rest_pos
		if crawl_mode and (key == "head" or key == "right_arm" or key == "left_arm"):
			base_pos = s.position
		var out_dir: Vector3 = rest_pos
		if out_dir.length() > 0.01:
			out_dir = out_dir.normalized()
		else:
			out_dir = Vector3.DOWN
		s.position = base_pos + out_dir * (sin(_time * wobble_speed * 0.8 + ph) * wobble_slide)


func _wobble_phase(key: String) -> float:
	match key:
		"right_arm": return 0.0
		"left_arm": return 1.7
		"right_leg": return 3.1
		"left_leg": return 4.6
		"left_foot": return 2.2
		"right_foot": return 5.0
		"head": return 0.8
		_: return 0.0


# --- Phase E: aim and attack overlays -----------------------------------------

func _update_aim_overlay(delta: float) -> void:
	var target: float = 1.0 if _aim_requested else 0.0
	_aim_blend = lerp(_aim_blend, target, 1.0 - exp(-aim_overlay_blend_speed * delta))


func _apply_aim_overlay() -> void:
	if _aim_blend <= 0.001:
		return

	var right_arm: Node3D = rig.get_socket("right_arm")
	if right_arm != null:
		right_arm.rotation.x -= aim_right_arm_forward * _aim_blend
		right_arm.rotation.z -= aim_right_arm_draw * _aim_blend

	var left_arm: Node3D = rig.get_socket("left_arm")
	if left_arm != null:
		left_arm.rotation.x -= aim_left_arm_forward * _aim_blend
		left_arm.rotation.z += aim_left_arm_brace * _aim_blend

	var body: Node3D = rig.get_socket("body")
	if body != null:
		body.rotation.x -= aim_torso_lean * _aim_blend

	var head: Node3D = rig.get_socket("head")
	if head != null:
		head.rotation.x -= aim_head_dip * _aim_blend


func _update_attack_overlay(delta: float) -> void:
	_attack_timer = max(_attack_timer - delta, 0.0)
	var target := 1.0 if _attack_timer > 0.0 else 0.0
	_attack_blend = lerp(_attack_blend, target, 1.0 - exp(-attack_overlay_blend_speed * delta))


# Adds a combo pose ON TOP of the walk pose, so attacks read clearly whether idle
# or moving.
func _apply_attack_overlay() -> void:
	if _attack_blend <= 0.001:
		return
	var punch: float = _attack_pose_strength()
	match _attack_combo_step:
		2:
			_apply_left_combo_pose(punch)
		3:
			_apply_finisher_combo_pose(punch)
		_:
			_apply_right_combo_pose(punch)


func _attack_pose_strength() -> float:
	if _attack_duration_current <= 0.001:
		return _attack_blend
	var phase: float = 1.0 - clampf(_attack_timer / _attack_duration_current, 0.0, 1.0)
	var snap: float = sin(phase * PI)
	return maxf(_attack_blend * 0.35, snap * _attack_blend)


func _apply_right_combo_pose(strength: float) -> void:
	var arm := rig.get_socket("right_arm")
	if arm != null:
		arm.rotation.x -= attack_arm_forward * strength
		arm.rotation.z -= 0.18 * strength
	var body := rig.get_socket("body")
	if body != null:
		body.rotation.y += attack_torso_twist * strength
		body.rotation.x -= attack_lunge * strength


func _apply_left_combo_pose(strength: float) -> void:
	var arm := rig.get_socket("left_arm")
	if arm != null:
		arm.rotation.x -= combo_left_arm_forward * strength
		arm.rotation.z += 0.22 * strength
	var counter_arm := rig.get_socket("right_arm")
	if counter_arm != null:
		counter_arm.rotation.x += attack_arm_forward * 0.25 * strength
	var body := rig.get_socket("body")
	if body != null:
		body.rotation.y -= attack_torso_twist * 0.9 * strength
		body.rotation.x -= attack_lunge * 0.8 * strength


func _apply_finisher_combo_pose(strength: float) -> void:
	var right_arm := rig.get_socket("right_arm")
	if right_arm != null:
		right_arm.rotation.x -= combo_finisher_arm_forward * strength
		right_arm.rotation.z -= 0.28 * strength
	var left_arm := rig.get_socket("left_arm")
	if left_arm != null:
		left_arm.rotation.x -= combo_finisher_arm_forward * strength
		left_arm.rotation.z += 0.28 * strength
	var body := rig.get_socket("body")
	if body != null:
		body.rotation.y += combo_finisher_torso_twist * strength
		body.rotation.x -= combo_finisher_lunge * strength
	var head := rig.get_socket("head")
	if head != null:
		head.rotation.x -= 0.12 * strength


# --- Phase F: foot placement ---------------------------------------------------

func _animate_feet(delta: float) -> void:
	if _body == null:
		_body = _find_body()
	var world := get_world_3d()
	if world == null:
		return
	var space := world.direct_space_state
	if space == null:
		return
	for key in FOOT_KEYS:
		_place_foot(space, key, delta)


func _place_foot(space: PhysicsDirectSpaceState3D, key: String, delta: float) -> void:
	var foot := rig.get_socket(key)
	if foot == null or not _rest_pos.has(key):
		return

	var rest: Vector3 = _get_rest_pos(key)
	# World XZ under the foot's rest spot (accounts for the body's yaw).
	var foot_world := rig.to_global(rest)
	var base_y := rig.global_position.y

	var query := PhysicsRayQueryParameters3D.create(
		Vector3(foot_world.x, base_y + foot_raycast_up, foot_world.z),
		Vector3(foot_world.x, base_y - foot_raycast_down, foot_world.z))
	if _body != null:
		query.exclude = [_body.get_rid()]

	var hit := space.intersect_ray(query)

	var target := rest
	if not hit.is_empty():
		# Ground world-Y -> local-Y under the rig (yaw doesn't change Y).
		target.y = (hit.position.y + foot_lift) - base_y

	# Smoothly step the foot toward the target so it doesn't snap.
	foot.position = foot.position.lerp(target, 1.0 - exp(-foot_smoothing * delta))

	# Tilt the foot to the floor slope.
	if foot_align_to_normal and not hit.is_empty():
		var n: Vector3 = hit.normal
		var target_rot := Vector3(atan2(n.z, n.y), foot.rotation.y, -atan2(n.x, n.y))
		foot.rotation = foot.rotation.lerp(target_rot, 1.0 - exp(-foot_smoothing * delta))
	elif _rest_rot.has(key):
		foot.rotation = _get_rest_rot(key)


func _find_body() -> Node3D:
	var n := get_parent()
	while n != null:
		if n is CharacterBody3D:
			return n
		n = n.get_parent()
	return null


func _animate_facing(delta: float, facing_direction: Vector3) -> void:
	if turn_target == null:
		return
	var flat := Vector3(facing_direction.x, 0.0, facing_direction.z)
	if flat.length() < 0.01:
		return
	var target_yaw := atan2(flat.x, flat.z)
	turn_target.rotation.y = lerp_angle(turn_target.rotation.y, target_yaw, 1.0 - exp(-turn_smoothing * delta))
