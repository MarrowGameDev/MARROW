class_name ProceduralPlayerAnimator
extends Node3D

# Velocity-driven procedural animation (Marrow rigging brief, Phases B/D/E/F).
# Reads ACTUAL velocity (not raw input) so it reacts to slopes, knockback, and
# speed bonuses, and moves the rig's sockets. Bones parented to sockets follow.

@export var rig: ModularSkeletonRig
@export var turn_target: Node3D            # usually VisualRoot; rotates toward facing
@export var player_body_progression_enabled := false

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
@export var head_only_hop_amount := 0.0
@export var head_only_roll_amount := 0.42
@export var head_only_roll_radius := 0.16
@export var head_only_ground_socket_y := -0.85
@export var torso_spring_hop_amount := 0.34
@export var torso_spring_compress_amount := 0.16
@export var torso_spring_forward_offset := 0.18
@export var torso_spring_tilt_amount := 0.24
@export var torso_spring_ground_socket_y := -0.58
@export var torso_spring_head_offset := Vector3(0.0, 0.42, 0.0)
@export var torso_spring_head_pop_amount := 0.28
@export var torso_spring_head_pop_delay := 0.38

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
@export var head_only_attack_duration := 0.34
@export var head_only_attack_charge_portion := 0.28
@export var head_only_attack_lunge := 0.85
@export var head_only_attack_arc := 0.68
@export var head_only_attack_charge_squash := 0.22
@export var head_only_attack_roll := 1.4
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
var _head_only_attack_contacted := true
var _head_only_attack_landed := true
var _head_only_base_world_offset := Vector3.ZERO
var _head_only_attack_world_offset := Vector3.ZERO
var _head_only_attack_direction := Vector3.FORWARD
var _head_only_last_facing_direction := Vector3.FORWARD
var _aim_requested := false
var _aim_blend := 0.0
var _lizard_wall_climb_blend := 0.0
var _head_only_roll_angle := 0.0

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
	_update_head_only_facing_direction(facing_direction)

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var target_ratio: float = clamp(horizontal.length() / max(max_speed, 0.001), 0.0, 1.0)
	speed_ratio = lerp(speed_ratio, target_ratio, 1.0 - exp(-speed_smoothing * delta))
	if _is_head_only():
		var roll_radius: float = maxf(head_only_roll_radius, 0.01)
		_head_only_roll_angle += horizontal.length() * delta / roll_radius

	total_equipped_weight = _calculate_weight(equipped_defs)
	var weight_slowdown: float = clamp(1.0 / max(total_equipped_weight, 1.0), heavy_weight_swing_slowdown, 1.0)

	walk_time += delta * walk_cycle_speed * speed_ratio * weight_slowdown
	_animate_facing(delta, facing_direction)

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
	_head_only_attack_world_offset = Vector3.ZERO
	_apply_attack_overlay()
	if foot_placement_enabled:
		_animate_feet(delta)


# The player calls this when an attack fires (Phase E).
func trigger_attack(combo_step: int = 0) -> void:
	if combo_step <= 0:
		_attack_combo_step = (_attack_combo_step % 3) + 1
	else:
		_attack_combo_step = clampi(combo_step, 1, 3)
	if _is_head_only():
		_attack_duration_current = head_only_attack_duration
		_head_only_attack_contacted = false
		_head_only_attack_landed = false
		_head_only_attack_direction = _head_only_last_facing_direction
	else:
		_attack_duration_current = attack_overlay_duration
		_head_only_attack_contacted = true
		_head_only_attack_landed = true
	if _attack_combo_step == 3 and not _is_head_only():
		_attack_duration_current *= 1.15
	_attack_timer = _attack_duration_current
	_attack_blend = maxf(_attack_blend, 0.25)


func set_aiming(enabled: bool) -> void:
	_aim_requested = enabled


func confirm_head_only_attack_contact() -> void:
	if _is_head_only() and _attack_blend > 0.001:
		_head_only_attack_contacted = true


func get_head_only_attack_forward_offset() -> float:
	if not _is_head_only():
		return 0.0
	return get_head_only_attack_world_offset().length()


func get_head_only_attack_world_offset() -> Vector3:
	if not _is_head_only():
		return Vector3.ZERO
	return _head_only_base_world_offset + _head_only_attack_world_offset


func _update_head_only_facing_direction(facing_direction: Vector3) -> void:
	var flat: Vector3 = Vector3(facing_direction.x, 0.0, facing_direction.z)
	if flat.length() > 0.01:
		_head_only_last_facing_direction = flat.normalized()


func _world_horizontal_offset_to_local(world_offset: Vector3) -> Vector3:
	if rig == null:
		return Vector3.ZERO
	var flat: Vector3 = Vector3(world_offset.x, 0.0, world_offset.z)
	var local_offset: Vector3 = rig.global_transform.basis.inverse() * flat
	local_offset.y = 0.0
	return local_offset


func set_crawl_mode(enabled: bool) -> void:
	crawl_mode = enabled


func set_lizard_wall_climb_blend(blend: float) -> void:
	_lizard_wall_climb_blend = clampf(blend, 0.0, 1.0)


func set_player_body_progression_enabled(enabled: bool) -> void:
	player_body_progression_enabled = enabled
	if not enabled:
		_head_only_roll_angle = 0.0


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
	if _is_torso_spring_only():
		_animate_torso_spring(sway, breath)
		return

	var body := rig.get_socket("body")
	if body != null and _rest_pos.has("body"):
		body.scale = Vector3.ONE
		body.position = _get_rest_pos("body") + Vector3(sway, bob + breath + lizard_wall_climb_lift * _lizard_wall_climb_blend, -0.08 * _lizard_wall_climb_blend)
		body.rotation = _get_rest_rot("body") + Vector3(torso_lean_amount * speed_ratio + lizard_wall_climb_pitch * _lizard_wall_climb_blend, 0.0, -sway * 0.6)

	var head := rig.get_socket("head")
	if head != null and _rest_pos.has("head"):
		head.position = _get_rest_pos("head") + Vector3(0.0, breath * 0.6 + lizard_wall_climb_head_lift * _lizard_wall_climb_blend, -0.10 * _lizard_wall_climb_blend)
		head.rotation = _get_rest_rot("head") + Vector3(-lizard_wall_climb_pitch * 0.35 * _lizard_wall_climb_blend, 0.0, sway * 0.3)
	_animate_lizard_torso_blocks(sway, breath, 0.0)


func _is_head_only() -> bool:
	return player_body_progression_enabled and rig != null and rig.has_method("has_equipped_slot") and not bool(rig.call("has_equipped_slot", "body"))


func _is_torso_spring_only() -> bool:
	return (
		player_body_progression_enabled
		and rig != null
		and rig.has_method("has_equipped_slot")
		and bool(rig.call("has_equipped_slot", "body"))
		and not bool(rig.call("has_equipped_slot", "legs"))
	)


func _animate_head_only(sway: float, breath: float) -> void:
	var head := rig.get_socket("head")
	if head == null or not _rest_pos.has("head"):
		return

	var hop: float = absf(sin(walk_time)) * head_only_hop_amount * speed_ratio
	var rest: Vector3 = _get_rest_pos("head")
	var base_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_base_world_offset)
	head.scale = Vector3.ONE
	head.position = Vector3(rest.x + sway * 0.8, head_only_ground_socket_y + hop, rest.z) + base_local_offset
	head.rotation = _get_rest_rot("head") + Vector3(_head_only_roll_angle, 0.0, sway * head_only_roll_amount)


func _animate_torso_spring(sway: float, breath: float) -> void:
	var body := rig.get_socket("body")
	var head := rig.get_socket("head")
	if body == null or not _rest_pos.has("body"):
		return

	var phase := fposmod(walk_time, TAU)
	var airborne: float = maxf(sin(phase), 0.0) * speed_ratio
	var contact: float = pow(1.0 - airborne, 2.0) * speed_ratio
	var hop: float = airborne * torso_spring_hop_amount
	var compression: float = contact * torso_spring_compress_amount
	var forward_shove: float = airborne * torso_spring_forward_offset
	var spring_tilt: float = sin(phase) * torso_spring_tilt_amount * speed_ratio

	var body_rest: Vector3 = _get_rest_pos("body")
	body.position = Vector3(body_rest.x + sway * 0.45, torso_spring_ground_socket_y + hop + breath - compression * 0.45, body_rest.z - forward_shove)
	body.rotation = _get_rest_rot("body") + Vector3(torso_lean_amount * 0.35 * speed_ratio + spring_tilt, 0.0, -sway * 0.45)
	body.scale = Vector3(1.0 + compression * 0.45 - airborne * 0.04, 1.0 - compression + airborne * 0.10, 1.0 + compression * 0.35 - airborne * 0.04)

	if head != null and _rest_pos.has("head"):
		var head_phase := fposmod(phase - torso_spring_head_pop_delay, TAU)
		var head_pop: float = maxf(sin(head_phase), 0.0) * torso_spring_head_pop_amount * speed_ratio
		head.position = body.position + torso_spring_head_offset + Vector3(sway * 0.38, compression * 0.32 + head_pop, forward_shove * 0.45)
		head.rotation = _get_rest_rot("head") + Vector3(-spring_tilt * 0.55, 0.0, sway * 0.42)


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
		body.scale = Vector3.ONE
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
		if (_is_head_only() or _is_torso_spring_only()) and key == "head":
			continue

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
	if _is_head_only() and not _head_only_attack_contacted:
		target = 1.0
	_attack_blend = lerp(_attack_blend, target, 1.0 - exp(-attack_overlay_blend_speed * delta))


# Adds a combo pose ON TOP of the walk pose, so attacks read clearly whether idle
# or moving.
func _apply_attack_overlay() -> void:
	if _attack_blend <= 0.001:
		return
	if _is_head_only():
		_apply_head_only_attack_pose()
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
	var phase: float = _attack_phase()
	var snap: float = sin(phase * PI)
	return maxf(_attack_blend * 0.35, snap * _attack_blend)


func _attack_phase() -> float:
	if _attack_duration_current <= 0.001:
		return 1.0
	return 1.0 - clampf(_attack_timer / _attack_duration_current, 0.0, 1.0)


func _apply_head_only_attack_pose() -> void:
	var head := rig.get_socket("head")
	if head == null:
		return

	var phase: float = _attack_phase()
	if phase >= 0.999 and not _head_only_attack_landed:
		_head_only_base_world_offset += _head_only_attack_direction * head_only_attack_lunge
		_head_only_attack_world_offset = Vector3.ZERO
		_head_only_attack_landed = true
		_head_only_attack_contacted = true
		head.scale = Vector3.ONE
		return
	if _head_only_attack_landed:
		_head_only_attack_world_offset = Vector3.ZERO
		head.scale = Vector3.ONE
		return

	var charge_end: float = clampf(head_only_attack_charge_portion, 0.05, 0.75)
	if phase < charge_end:
		var charge_t: float = phase / charge_end
		var charge: float = sin(charge_t * PI * 0.5) * _attack_blend
		_head_only_attack_world_offset = _head_only_attack_direction * (-head_only_attack_lunge * 0.14 * charge)
		var charge_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_attack_world_offset)
		head.position.y -= head_only_attack_charge_squash * charge
		head.position += charge_local_offset
		head.rotation.x -= head_only_attack_roll * 0.22 * charge
		head.scale = Vector3(
			1.0 + head_only_attack_charge_squash * 0.55 * charge,
			1.0 - head_only_attack_charge_squash * 0.75 * charge,
			1.0 + head_only_attack_charge_squash * 0.45 * charge
		)
		return

	var jump_t: float = (phase - charge_end) / maxf(1.0 - charge_end, 0.001)
	var arc: float = sin(jump_t * PI) * _attack_blend
	var commit: float = sin(jump_t * PI * 0.5) * _attack_blend
	_head_only_attack_world_offset = _head_only_attack_direction * (head_only_attack_lunge * commit)
	var jump_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_attack_world_offset)
	head.position += jump_local_offset
	head.position.y += head_only_attack_arc * arc
	head.rotation.x += head_only_attack_roll * commit
	var stretch: float = arc * 0.12
	head.scale = Vector3(1.0 - stretch * 0.5, 1.0 + stretch, 1.0 - stretch * 0.35)


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
