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
@export var head_only_roll_amount := 0.24
@export var head_only_roll_radius := 0.16
@export var head_only_roll_speed_scale := 0.42
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
@export var head_only_attack_arc := 0.92
@export var head_only_attack_charge_squash := 0.22
@export var head_only_attack_roll := 1.4
# Fraction of the jump over which the charge compression unwinds. Lower is a
# snappier spring; 0 would restore the old one-frame snap.
@export var head_only_attack_release_portion := 0.25
# How much of the rolling spin survives while the head is airborne mid-attack.
# 1.0 restores the old behaviour (attack roll buried under locomotion spin).
@export var head_only_attack_roll_damping := 0.2
@export var head_only_hit_recoil_duration := 0.58
@export var head_only_hit_recoil_hold := 0.14
@export var head_only_hit_recoil_arc := 0.64
@export var head_only_hit_recoil_lift := 0.46
@export var head_only_hit_recoil_horizontal_push := 0.18
@export var head_only_hit_recoil_roll := 0.95
@export var head_only_hit_recoil_settle := 0.16
@export var torso_head_attack_duration := 0.56
@export var torso_head_attack_charge_portion := 0.34
@export var torso_head_attack_lunge := 1.05
@export var torso_head_attack_arc := 0.42
@export var torso_head_attack_coil := 0.24
@export var torso_head_attack_recoil_duration := 0.66
@export var torso_head_attack_recoil_arc := 1.25
@export var torso_head_attack_recoil_pullback := 0.18
@export var torso_head_attack_roll := 1.15
@export var detached_head_landing_duration := 0.18
@export var detached_head_landing_bounce := 0.03
@export var detached_head_landing_roll := 0.25
@export var detached_head_mode_blend_duration := 0.08
@export var detached_head_reattach_tornado_duration := 0.78
@export var detached_head_reattach_tornado_radius := 0.82
@export var detached_head_reattach_tornado_turns := 2.1
@export var detached_head_reattach_tornado_lift := 0.36
@export var detached_head_reattach_finish_blend_duration := 0.18
@export var combo_left_arm_forward := 1.0
@export var combo_finisher_arm_forward := 0.85
@export var combo_finisher_torso_twist := 0.5
@export var combo_finisher_lunge := 0.34

@export_group("Animation demo")
# A/B harness: keys 2 and 3 play the SAME head lunge, authored two different ways.
# Both read the head_only_attack_* tuning above, so retuning moves them together
# and any difference you see is the authoring style, not the numbers.
@export var demo_settle_time := 0.12

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
var _head_only_hit_recoil_timer := 0.0
var _head_only_hit_recoil_start_offset := Vector3.ZERO
var _head_only_hit_recoil_end_offset := Vector3.ZERO
var _head_only_hit_recoil_start_local_position := Vector3.ZERO
var _head_only_hit_recoil_end_local_position := Vector3.ZERO
var _torso_head_attack_contacted := true
var _torso_head_attack_landed := true
var _torso_head_attack_world_offset := Vector3.ZERO
var _torso_head_attack_direction := Vector3.FORWARD
var _torso_head_recoil_timer := 0.0
var _torso_head_recoil_start_local_position := Vector3.ZERO
var _torso_head_recoil_end_local_position := Vector3.ZERO
var _torso_head_socket_local_position := Vector3.ZERO
var _torso_head_socket_offset := Vector3(0.0, 0.42, 0.0)
var _torso_head_miss_detach_requested := false
var _torso_head_detach_world_offset := Vector3.ZERO
var _torso_head_miss_fall_active := false
var _torso_head_miss_fall_timer := 0.0
var _torso_head_miss_fall_start_position := Vector3.ZERO
var _torso_head_miss_fall_start_rotation := Vector3.ZERO
var _torso_head_miss_fall_start_scale := Vector3.ONE
var _torso_head_miss_body_hold_global_transform := Transform3D.IDENTITY
var _torso_head_detach_body_global_transform := Transform3D.IDENTITY
var _torso_head_miss_body_hold_transform_ready := false
var _detached_head_landing_timer := 0.0
var _detached_head_landing_start_position := Vector3.ZERO
var _detached_head_landing_start_rotation := Vector3.ZERO
var _detached_head_landing_start_scale := Vector3.ONE
var _reattach_tornado_active := false
var _reattach_tornado_timer := 0.0
var _reattach_tornado_progress := 0.0
var _reattach_tornado_start_position := Vector3.ZERO
var _reattach_tornado_start_rotation := Vector3.ZERO
var _reattach_tornado_body_position := Vector3.ZERO
var _reattach_tornado_body_rotation := Vector3.ZERO
var _reattach_tornado_target_position := Vector3.ZERO
var _reattach_finish_blend_timer := 0.0
var _reattach_finish_blend_duration := 0.0
var _reattach_finish_head_start_position := Vector3.ZERO
var _reattach_finish_head_start_rotation := Vector3.ZERO
var _aim_requested := false
var _aim_blend := 0.0
var _lizard_wall_climb_blend := 0.0
var _head_only_roll_angle := 0.0

var _rest_pos: Dictionary = {}
var _rest_rot: Dictionary = {}
var _captured := false
var _body: Node3D = null

enum DemoMode {OFF, PROCEDURAL, TWEEN}

var _demo_mode: DemoMode = DemoMode.OFF
var _demo_timer := 0.0
var _demo_tween: Tween = null
var _demo_forward := Vector3.FORWARD
var _demo_start_position := Vector3.ZERO
var _demo_start_rotation := Vector3.ZERO
# The demo writes these; _apply_demo_pose() is the single place they reach the
# socket. The Tween cannot touch head.position directly because _animate_body()
# rebuilds it from rest every frame and would overwrite the tween mid-flight.
var _demo_head_position := Vector3.ZERO
var _demo_head_rotation := Vector3.ZERO
var _demo_head_scale := Vector3.ONE
var _demo_target_world_position := Vector3.ZERO
var _demo_target_valid := false

# Auto-aim for head-launch attacks. The Player owns enemy lookup and pushes a
# world-space direction here every frame; the animator just steers the launch.
var _head_launch_aim_direction := Vector3.ZERO
var _head_launch_aim_valid := false

# Pending body displacement from a landed head-only lunge. The Player consumes
# this and moves the capsule, so the head and the body stay together.
var _head_only_body_catch_up_offset := Vector3.ZERO
var _head_only_body_catch_up_requested := false

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
		var roll_scale: float = head_only_roll_speed_scale
		# Mid-lunge the head is off the ground, so it should not keep winding up
		# ground roll on top of the attack's own roll. Without this, attacking at
		# full speed spun the head ~671 degrees in a 0.34 s attack instead of ~189.
		if _head_only_attack_airborne():
			roll_scale *= head_only_attack_roll_damping
		_head_only_roll_angle += (horizontal.length() * delta / roll_radius) * roll_scale
	if _detached_head_landing_timer > 0.0:
		_detached_head_landing_timer = maxf(_detached_head_landing_timer - delta, 0.0)
	if _torso_head_miss_fall_timer > 0.0:
		_torso_head_miss_fall_timer = maxf(_torso_head_miss_fall_timer - delta, 0.0)
	if _reattach_finish_blend_timer > 0.0:
		_reattach_finish_blend_timer = maxf(_reattach_finish_blend_timer - delta, 0.0)

	total_equipped_weight = _calculate_weight(equipped_defs)
	_update_torso_head_socket_offset(equipped_defs)
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
	_update_head_launch_attack_aim()
	_head_only_attack_world_offset = Vector3.ZERO
	_torso_head_attack_world_offset = Vector3.ZERO
	_apply_attack_overlay()
	if foot_placement_enabled:
		_animate_feet(delta)
	# Runs last so the demo wins the head socket for its duration. The tween
	# variant has already advanced its own values by the time we get here.
	if _demo_mode == DemoMode.PROCEDURAL:
		_update_demo_procedural(delta)
	if _demo_mode != DemoMode.OFF:
		_apply_demo_pose()


# --- Animation demo: same lunge, two authoring styles -------------------------
# Key 2 -> trigger_demo_attack_procedural(): per-frame math, easing by hand.
# Key 3 -> trigger_demo_attack_tween(): declarative steps, easing by name.
# Shared beats: charge (squash back) -> rise to apex -> fall to landing ->
# settle back to the start pose so the demo can be replayed from one spot.

func trigger_demo_attack_procedural() -> void:
	var head: Node3D = _demo_begin()
	if head == null:
		return
	_demo_mode = DemoMode.PROCEDURAL


func trigger_demo_attack_tween() -> void:
	var head: Node3D = _demo_begin()
	if head == null:
		return
	_demo_mode = DemoMode.TWEEN

	var k: Dictionary = _demo_keyframes()
	var charge_time: float = _demo_charge_time()
	var air_time: float = _demo_air_time()
	var rise: float = air_time * 0.5
	var fall: float = air_time * 0.5
	var settle: float = maxf(demo_settle_time, 0.01)

	_demo_tween = create_tween()
	# Physics mode keeps the tween stepping in lockstep with update_from_player,
	# which is driven from the player's _physics_process.
	_demo_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	# 1. Charge: squash down and pull back.
	_demo_tween.tween_property(self, "_demo_head_position", k["charge_pos"], charge_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_demo_tween.parallel().tween_property(self, "_demo_head_rotation", k["charge_rot"], charge_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_demo_tween.parallel().tween_property(self, "_demo_head_scale", k["charge_scale"], charge_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# 2. Rise: launch toward the apex, decelerating into it.
	_demo_tween.tween_property(self, "_demo_head_position", k["apex_pos"], rise).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_demo_tween.parallel().tween_property(self, "_demo_head_rotation", k["apex_rot"], rise).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_demo_tween.parallel().tween_property(self, "_demo_head_scale", k["apex_scale"], rise).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 3. Fall: accelerate into the landing.
	_demo_tween.tween_property(self, "_demo_head_position", k["land_pos"], fall).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_demo_tween.parallel().tween_property(self, "_demo_head_rotation", k["land_rot"], fall).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_demo_tween.parallel().tween_property(self, "_demo_head_scale", Vector3.ONE, fall).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# 4. Settle back to the start pose.
	_demo_tween.tween_property(self, "_demo_head_position", _demo_start_position, settle).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_demo_tween.parallel().tween_property(self, "_demo_head_rotation", _demo_start_rotation, settle).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_demo_tween.tween_callback(_demo_on_tween_finished)


# The procedural twin of the tween chain above. Same four beats, but the phase
# bookkeeping and the easing curves are spelled out by hand.
func _update_demo_procedural(delta: float) -> void:
	_demo_timer += delta
	# The one thing the tween cannot do: re-aim at a target that moved after the
	# animation started. Every keyframe below is derived from _demo_forward, so
	# refreshing it here swings the whole trajectory to follow.
	_demo_forward = _demo_local_forward()
	var k: Dictionary = _demo_keyframes()
	var charge_time: float = _demo_charge_time()
	var air_time: float = _demo_air_time()
	var rise: float = air_time * 0.5
	var fall: float = air_time * 0.5
	var settle: float = maxf(demo_settle_time, 0.01)
	var t: float = _demo_timer

	if t < charge_time:
		var p: float = _ease_out_sine(t / charge_time)
		_demo_head_position = _demo_start_position.lerp(k["charge_pos"], p)
		_demo_head_rotation = _demo_start_rotation.lerp(k["charge_rot"], p)
		_demo_head_scale = Vector3.ONE.lerp(k["charge_scale"], p)
		return
	t -= charge_time

	if t < rise:
		var p: float = _ease_out_quad(t / rise)
		_demo_head_position = (k["charge_pos"] as Vector3).lerp(k["apex_pos"], p)
		_demo_head_rotation = (k["charge_rot"] as Vector3).lerp(k["apex_rot"], p)
		_demo_head_scale = (k["charge_scale"] as Vector3).lerp(k["apex_scale"], p)
		return
	t -= rise

	if t < fall:
		var p: float = _ease_in_quad(t / fall)
		_demo_head_position = (k["apex_pos"] as Vector3).lerp(k["land_pos"], p)
		_demo_head_rotation = (k["apex_rot"] as Vector3).lerp(k["land_rot"], p)
		_demo_head_scale = (k["apex_scale"] as Vector3).lerp(Vector3.ONE, p)
		return
	t -= fall

	if t < settle:
		var p: float = _ease_in_out_sine(t / settle)
		_demo_head_position = (k["land_pos"] as Vector3).lerp(_demo_start_position, p)
		_demo_head_rotation = (k["land_rot"] as Vector3).lerp(_demo_start_rotation, p)
		_demo_head_scale = Vector3.ONE
		return

	_demo_stop()


# Both styles converge here: the demo owns the head socket while it runs.
func _apply_demo_pose() -> void:
	if rig == null:
		return
	var head: Node3D = rig.get_socket("head")
	if head == null:
		return
	head.position = _demo_head_position
	head.rotation = _demo_head_rotation
	head.scale = _demo_head_scale


# Targets are baked once at trigger time so the two styles stay comparable. The
# procedural version could recompute these live against a moving target; the
# tween cannot, because its steps are authored up front.
func _demo_keyframes() -> Dictionary:
	var lunge: float = head_only_attack_lunge
	var squash: float = head_only_attack_charge_squash
	var roll: float = head_only_attack_roll
	# Peak stretch matches _apply_head_only_attack_pose()'s arc * 0.12 at apex.
	var stretch: float = 0.12
	return {
		"charge_pos": _demo_start_position - _demo_forward * lunge * 0.14 + Vector3(0.0, -squash, 0.0),
		"charge_rot": _demo_start_rotation + Vector3(-roll * 0.22, 0.0, 0.0),
		"charge_scale": Vector3(1.0 + squash * 0.55, 1.0 - squash * 0.75, 1.0 + squash * 0.45),
		"apex_pos": _demo_start_position + _demo_forward * lunge * 0.5 + Vector3(0.0, head_only_attack_arc, 0.0),
		"apex_rot": _demo_start_rotation + Vector3(roll * 0.5, 0.0, 0.0),
		"apex_scale": Vector3(1.0 - stretch * 0.5, 1.0 + stretch, 1.0 - stretch * 0.35),
		"land_pos": _demo_start_position + _demo_forward * lunge,
		"land_rot": _demo_start_rotation + Vector3(roll, 0.0, 0.0),
	}


func _demo_charge_time() -> float:
	return maxf(head_only_attack_duration * clampf(head_only_attack_charge_portion, 0.05, 0.75), 0.01)


func _demo_air_time() -> float:
	return maxf(head_only_attack_duration - _demo_charge_time(), 0.02)


func _demo_begin() -> Node3D:
	if rig == null:
		return null
	var head: Node3D = rig.get_socket("head")
	if head == null:
		return null
	_demo_stop()
	_demo_start_position = head.position
	_demo_start_rotation = head.rotation
	_demo_head_position = _demo_start_position
	_demo_head_rotation = _demo_start_rotation
	_demo_head_scale = Vector3.ONE
	_demo_forward = _demo_local_forward()
	_demo_timer = 0.0
	return head


# Aims at the demo target when the player supplies one, else at current facing.
func _demo_local_forward() -> Vector3:
	if _demo_target_valid and rig != null:
		var to_target: Vector3 = rig.to_local(_demo_target_world_position) - _demo_start_position
		to_target.y = 0.0
		if to_target.length() > 0.001:
			return to_target.normalized()
	var local: Vector3 = _world_horizontal_offset_to_local(_head_only_last_facing_direction)
	if local.length() > 0.001:
		return local.normalized()
	return Vector3.FORWARD


# The player pushes the orbiting demo target here every frame.
func set_demo_target_world_position(world_position: Vector3) -> void:
	_demo_target_world_position = world_position
	_demo_target_valid = true


# Releases the head socket back to the normal animator on the next frame.
# Cancels an in-flight tween, so it must not be used as the tween's own callback.
func _demo_stop() -> void:
	if _demo_tween != null and _demo_tween.is_valid():
		_demo_tween.kill()
	_demo_tween = null
	_demo_mode = DemoMode.OFF
	_demo_timer = 0.0


# Runs from inside the tween's final step, where killing it would be re-entrant.
func _demo_on_tween_finished() -> void:
	_demo_tween = null
	_demo_mode = DemoMode.OFF
	_demo_timer = 0.0


# Hand-written equivalents of Tween's TRANS_*/EASE_* pairs, so both styles trace
# the exact same curve.
func _ease_out_sine(t: float) -> float:
	return sin(clampf(t, 0.0, 1.0) * PI * 0.5)


func _ease_out_quad(t: float) -> float:
	var c: float = clampf(t, 0.0, 1.0)
	return 1.0 - (1.0 - c) * (1.0 - c)


func _ease_in_quad(t: float) -> float:
	var c: float = clampf(t, 0.0, 1.0)
	return c * c


func _ease_in_out_sine(t: float) -> float:
	return -(cos(PI * clampf(t, 0.0, 1.0)) - 1.0) * 0.5


# True while a head-launch attack is still resolving: in flight, in hit recoil,
# falling after a miss, or waiting for the Player to consume a detach request.
# The Player gates new attacks on this, because `attack_cooldown` alone is shorter
# than these animations and a new trigger would restart the pose mid-air.
func is_head_launch_attack_busy() -> bool:
	if _is_head_only():
		return not _head_only_attack_landed or _head_only_hit_recoil_timer > 0.0
	if _is_torso_spring_only():
		return (
			not _torso_head_attack_landed
			or _torso_head_recoil_timer > 0.0
			or _torso_head_miss_fall_active
			or _torso_head_miss_detach_requested
		)
	return false


# Auto-aim for head-launch attacks, pushed by the Player every frame. Passing
# valid = false (no enemy in range) falls back to the player's facing direction,
# which is the original behaviour.
func set_head_launch_attack_aim(direction: Vector3, valid: bool) -> void:
	var flat: Vector3 = Vector3(direction.x, 0.0, direction.z)
	if not valid or flat.length() < 0.001:
		_head_launch_aim_valid = false
		_head_launch_aim_direction = Vector3.ZERO
		return
	_head_launch_aim_valid = true
	_head_launch_aim_direction = flat.normalized()


func _head_launch_aim_or(fallback: Vector3) -> Vector3:
	if _head_launch_aim_valid:
		return _head_launch_aim_direction
	return fallback


# Steers an in-flight launch toward the target. This is the whole reason the
# launch is procedural rather than a baked clip: the direction is re-read every
# frame, so an enemy that moves mid-attack is still tracked. Once the attack has
# landed the direction is frozen, so the landing offset stays consistent with the
# offset the pose actually reached.
func _update_head_launch_attack_aim() -> void:
	if not _head_launch_aim_valid:
		return
	if _is_head_only() and not _head_only_attack_landed:
		_head_only_attack_direction = _head_launch_aim_direction
	elif _is_torso_spring_only() and not _torso_head_attack_landed:
		_torso_head_attack_direction = _head_launch_aim_direction


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
		_head_only_attack_direction = _head_launch_aim_or(_head_only_last_facing_direction)
		_head_only_hit_recoil_timer = 0.0
		_torso_head_attack_contacted = true
		_torso_head_attack_landed = true
		_torso_head_recoil_timer = 0.0
		_torso_head_miss_detach_requested = false
		_torso_head_miss_fall_active = false
		_torso_head_miss_fall_timer = 0.0
		_torso_head_miss_body_hold_transform_ready = false
	elif _is_torso_spring_only():
		_attack_duration_current = torso_head_attack_duration
		_head_only_attack_contacted = true
		_head_only_attack_landed = true
		_head_only_hit_recoil_timer = 0.0
		_torso_head_attack_contacted = false
		_torso_head_attack_landed = false
		_torso_head_attack_direction = _head_launch_aim_or(_head_only_last_facing_direction)
		_torso_head_recoil_timer = 0.0
		_torso_head_miss_detach_requested = false
		_torso_head_detach_world_offset = Vector3.ZERO
		_torso_head_miss_fall_active = false
		_torso_head_miss_fall_timer = 0.0
		_torso_head_miss_body_hold_transform_ready = false
	else:
		_attack_duration_current = attack_overlay_duration
		_head_only_attack_contacted = true
		_head_only_attack_landed = true
		_head_only_hit_recoil_timer = 0.0
		_torso_head_attack_contacted = true
		_torso_head_attack_landed = true
		_torso_head_recoil_timer = 0.0
		_torso_head_miss_detach_requested = false
		_torso_head_miss_fall_active = false
		_torso_head_miss_fall_timer = 0.0
		_torso_head_miss_body_hold_transform_ready = false
	if _attack_combo_step == 3 and not _is_head_only() and not _is_torso_spring_only():
		_attack_duration_current *= 1.15
	_attack_timer = _attack_duration_current
	_attack_blend = maxf(_attack_blend, 0.25)


func _capture_torso_head_miss_body_hold_transform() -> void:
	_torso_head_miss_body_hold_transform_ready = false
	if rig == null:
		return
	var body: Node3D = rig.get_socket("body")
	if body == null:
		return
	_torso_head_miss_body_hold_global_transform = body.global_transform
	_torso_head_detach_body_global_transform = _torso_head_miss_body_hold_global_transform
	_torso_head_miss_body_hold_transform_ready = true


func set_aiming(enabled: bool) -> void:
	_aim_requested = enabled


func confirm_head_only_attack_contact() -> void:
	if _is_head_only() and _attack_blend > 0.001:
		_head_only_attack_contacted = true
		_head_only_attack_landed = true
		_head_only_hit_recoil_start_offset = _head_only_base_world_offset + _head_only_attack_world_offset
		_head_only_hit_recoil_end_offset = _head_only_base_world_offset
		_head_only_hit_recoil_start_local_position = _capture_head_only_recoil_start_local_position()
		_head_only_hit_recoil_end_local_position = _get_head_only_grounded_local_position()
		_head_only_hit_recoil_timer = head_only_hit_recoil_duration
	elif _is_torso_spring_only() and _attack_blend > 0.001:
		_torso_head_attack_contacted = true
		_torso_head_attack_landed = true
		_torso_head_miss_detach_requested = false
		_torso_head_miss_fall_active = false
		_torso_head_miss_fall_timer = 0.0
		_torso_head_recoil_start_local_position = _capture_socket_local_position("head")
		_torso_head_recoil_end_local_position = _torso_head_socket_local_position
		_torso_head_recoil_timer = torso_head_attack_recoil_duration


func get_head_only_attack_forward_offset() -> float:
	if not _is_head_only():
		return 0.0
	return get_head_only_attack_world_offset().length()


func get_head_only_attack_world_offset() -> Vector3:
	if not _is_head_only():
		return Vector3.ZERO
	return _head_only_base_world_offset + _head_only_attack_world_offset


func get_head_launch_attack_world_offset() -> Vector3:
	if _is_head_only():
		return _head_only_base_world_offset + _head_only_attack_world_offset
	if _is_torso_spring_only():
		return _torso_head_attack_world_offset
	return Vector3.ZERO


# A landed head-only lunge asks the Player to bring the capsule to the head.
# Consumed the same frame it is raised (see Player._update_procedural_animation).
func has_head_only_body_catch_up_request() -> bool:
	return _head_only_body_catch_up_requested


func consume_head_only_body_catch_up_offset() -> Vector3:
	if not _head_only_body_catch_up_requested:
		return Vector3.ZERO
	_head_only_body_catch_up_requested = false
	var offset: Vector3 = _head_only_body_catch_up_offset
	_head_only_body_catch_up_offset = Vector3.ZERO
	return offset


func has_torso_head_miss_detach_request() -> bool:
	return _torso_head_miss_detach_requested


func consume_torso_head_miss_detach_offset() -> Vector3:
	if not _torso_head_miss_detach_requested:
		return Vector3.ZERO
	_torso_head_miss_detach_requested = false
	return _torso_head_detach_world_offset


func get_torso_head_miss_detach_body_transform() -> Transform3D:
	return _torso_head_detach_body_global_transform


func enter_detached_head_state(start_local_position: Vector3 = Vector3.ZERO, use_start_position: bool = false) -> void:
	_attack_timer = 0.0
	_attack_blend = 0.0
	_head_only_attack_contacted = true
	_head_only_attack_landed = true
	_head_only_base_world_offset = Vector3.ZERO
	_head_only_attack_world_offset = Vector3.ZERO
	_head_only_hit_recoil_timer = 0.0
	_torso_head_attack_contacted = true
	_torso_head_attack_landed = true
	_torso_head_attack_world_offset = Vector3.ZERO
	_torso_head_recoil_timer = 0.0
	_torso_head_miss_detach_requested = false
	_torso_head_detach_world_offset = Vector3.ZERO
	_torso_head_miss_fall_active = false
	_torso_head_miss_fall_timer = 0.0
	if use_start_position:
		_detached_head_landing_start_position = start_local_position
		_detached_head_landing_start_rotation = _capture_socket_local_rotation("head")
		_detached_head_landing_start_scale = _capture_socket_local_scale("head")
		var head: Node3D = null
		if rig != null:
			head = rig.get_socket("head")
		if head != null:
			head.position = start_local_position
		_detached_head_landing_timer = maxf(detached_head_mode_blend_duration, 0.01)
	else:
		_detached_head_landing_timer = 0.0


func start_detached_head_reattach_tornado(body_world_position: Vector3, target_world_position: Vector3, body_world_rotation: Vector3 = Vector3.ZERO) -> void:
	if rig == null:
		return
	var head: Node3D = rig.get_socket("head")
	if head == null:
		return
	_reattach_tornado_active = true
	_reattach_tornado_timer = maxf(detached_head_reattach_tornado_duration, 0.01)
	_reattach_tornado_progress = 0.0
	_reattach_tornado_start_position = head.position
	_reattach_tornado_start_rotation = head.rotation
	_reattach_tornado_body_position = rig.to_local(body_world_position)
	_reattach_tornado_body_rotation = _world_rotation_to_rig_local(body_world_rotation)
	_reattach_tornado_target_position = rig.to_local(target_world_position)
	_detached_head_landing_timer = 0.0


func set_detached_head_reattach_tornado_progress(progress: float, body_world_position: Vector3, target_world_position: Vector3, body_world_rotation: Vector3 = Vector3.ZERO) -> void:
	if rig == null:
		return
	if not _reattach_tornado_active:
		start_detached_head_reattach_tornado(body_world_position, target_world_position, body_world_rotation)
	_reattach_tornado_progress = clampf(progress, 0.0, 1.0)
	_reattach_tornado_body_position = rig.to_local(body_world_position)
	_reattach_tornado_body_rotation = _world_rotation_to_rig_local(body_world_rotation)
	_reattach_tornado_target_position = rig.to_local(target_world_position)


func cancel_detached_head_reattach_tornado_to_ground() -> void:
	if rig == null or not _reattach_tornado_active:
		return
	var head: Node3D = rig.get_socket("head")
	if head == null:
		return
	_reattach_tornado_active = false
	_reattach_tornado_timer = 0.0
	_reattach_tornado_progress = 0.0
	_detached_head_landing_start_position = head.position
	_detached_head_landing_start_rotation = head.rotation
	_detached_head_landing_start_scale = head.scale
	_detached_head_landing_timer = maxf(detached_head_landing_duration, 0.01)


func play_detached_head_reattach_finish_blend() -> void:
	if rig == null:
		return
	var head: Node3D = rig.get_socket("head")
	if head == null:
		return
	_reattach_tornado_active = false
	_reattach_tornado_timer = 0.0
	_reattach_tornado_progress = 1.0
	_reattach_finish_blend_duration = maxf(detached_head_reattach_finish_blend_duration, 0.01)
	_reattach_finish_blend_timer = _reattach_finish_blend_duration
	_reattach_finish_head_start_position = head.position
	_reattach_finish_head_start_rotation = head.rotation
	head.scale = Vector3.ONE


func get_detached_head_reattach_tornado_duration() -> float:
	return maxf(detached_head_reattach_tornado_duration, 0.01)


func get_stable_body_attach_local_position() -> Vector3:
	var rest: Vector3 = _get_rest_pos("body")
	if _is_torso_spring_only():
		return Vector3(rest.x, torso_spring_ground_socket_y, rest.z)
	return rest


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


func _world_rotation_to_rig_local(world_rotation: Vector3) -> Vector3:
	if rig == null:
		return world_rotation
	var world_basis: Basis = Basis.from_euler(world_rotation)
	var local_basis: Basis = rig.global_transform.basis.inverse() * world_basis
	return local_basis.get_euler()


func _capture_head_only_recoil_start_local_position() -> Vector3:
	if rig != null:
		var head: Node3D = rig.get_socket("head")
		if head != null:
			return head.position
	return _get_head_only_grounded_local_position() + _world_horizontal_offset_to_local(_head_only_attack_world_offset)


func _capture_socket_local_position(socket_key: String) -> Vector3:
	if rig != null:
		var socket: Node3D = rig.get_socket(socket_key)
		if socket != null:
			return socket.position
	return _get_rest_pos(socket_key)


func _capture_socket_local_rotation(socket_key: String) -> Vector3:
	if rig != null:
		var socket: Node3D = rig.get_socket(socket_key)
		if socket != null:
			return socket.rotation
	return _get_rest_rot(socket_key)


func _capture_socket_local_scale(socket_key: String) -> Vector3:
	if rig != null:
		var socket: Node3D = rig.get_socket(socket_key)
		if socket != null:
			return socket.scale
	return Vector3.ONE


func _get_head_only_grounded_local_position() -> Vector3:
	var rest: Vector3 = _get_rest_pos("head")
	var base_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_base_world_offset)
	return Vector3(rest.x, head_only_ground_socket_y, rest.z) + base_local_offset


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


func _update_torso_head_socket_offset(equipped_defs: Array) -> void:
	var fallback: Vector3 = torso_spring_head_offset
	_torso_head_socket_offset = fallback
	for raw_def in equipped_defs:
		if not raw_def is Dictionary:
			continue
		var definition: Dictionary = raw_def
		if str(definition.get("slot", "")) != "body":
			continue
		var socket_value: Variant = definition.get("head_socket_offset", definition.get("head_origin_offset", fallback))
		_torso_head_socket_offset = _as_vector3(socket_value, fallback)
		return


func _as_vector3(value: Variant, fallback: Vector3) -> Vector3:
	if value is Vector3:
		var vector_value: Vector3 = value
		return vector_value
	return fallback


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
	_apply_detached_head_reattach_finish_blend(body, head)
	_animate_lizard_torso_blocks(sway, breath, 0.0)


func _is_head_only() -> bool:
	return player_body_progression_enabled and rig != null and rig.has_method("has_equipped_slot") and not bool(rig.call("has_equipped_slot", "body"))


# True from the moment a head-only attack fires until the head is back down,
# including the hit recoil, which is also played in the air.
func _head_only_attack_airborne() -> bool:
	if not _is_head_only():
		return false
	return not _head_only_attack_landed or _head_only_hit_recoil_timer > 0.0


func _is_torso_spring_only() -> bool:
	return (
		player_body_progression_enabled
		and rig != null
		and rig.has_method("has_equipped_slot")
		and bool(rig.call("has_equipped_slot", "body"))
		and not bool(rig.call("has_equipped_slot", "legs"))
	)


func _animate_head_only(sway: float, breath: float) -> void:
	var head: Node3D = rig.get_socket("head")
	if head == null or not _rest_pos.has("head"):
		return
	if rig.has_method("set_head_only_visual_guard"):
		rig.call("set_head_only_visual_guard", true)

	if _reattach_tornado_active:
		_apply_detached_head_reattach_tornado(head)
		return

	var hop: float = absf(sin(walk_time)) * head_only_hop_amount * speed_ratio
	var rest: Vector3 = _get_rest_pos("head")
	var base_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_base_world_offset)
	var target_position: Vector3 = Vector3(rest.x + sway * 0.8, head_only_ground_socket_y + hop, rest.z) + base_local_offset
	var target_rotation: Vector3 = _get_rest_rot("head") + Vector3(_head_only_roll_angle, 0.0, sway * head_only_roll_amount)
	head.scale = Vector3.ONE
	if _detached_head_landing_timer > 0.0:
		var duration: float = maxf(detached_head_mode_blend_duration, 0.01)
		var t: float = 1.0 - clampf(_detached_head_landing_timer / duration, 0.0, 1.0)
		var eased: float = 1.0 - pow(1.0 - t, 1.65)
		head.position = _detached_head_landing_start_position.lerp(target_position, eased)
		head.rotation = _detached_head_landing_start_rotation.lerp(target_rotation, eased)
		head.scale = _detached_head_landing_start_scale.lerp(Vector3.ONE, eased)
		return
	head.position = target_position
	head.rotation = target_rotation


func _apply_detached_head_reattach_tornado(head: Node3D) -> void:
	var t: float = clampf(_reattach_tornado_progress, 0.0, 1.0)
	var eased: float = t * t * (3.0 - 2.0 * t)
	var angle: float = TAU * detached_head_reattach_tornado_turns * t
	var radius: float = detached_head_reattach_tornado_radius * (1.0 - eased)
	var spiral_offset: Vector3 = Vector3(
		cos(angle) * radius,
		sin(t * PI) * detached_head_reattach_tornado_lift + sin(angle) * radius * 0.28,
		sin(angle) * radius * 0.62
	)
	var path_position: Vector3 = _reattach_tornado_start_position.lerp(_reattach_tornado_target_position, eased)
	var body_pull: Vector3 = _reattach_tornado_body_position.lerp(_reattach_tornado_target_position, eased)
	head.position = path_position.lerp(body_pull, 0.35 * sin(t * PI)) + spiral_offset
	head.rotation = _reattach_tornado_start_rotation.lerp(_get_rest_rot("head"), eased)
	head.rotation.x += angle * 0.18
	head.rotation.z += sin(angle) * 0.35 * (1.0 - eased)
	head.scale = Vector3.ONE
	if t >= 0.999:
		head.position = _reattach_tornado_target_position
		head.rotation = _get_rest_rot("head")
		_reattach_tornado_active = false
		_reattach_tornado_timer = 0.0
		_reattach_tornado_progress = 1.0


func _apply_detached_head_reattach_finish_blend(_body: Node3D, head: Node3D) -> void:
	if _reattach_finish_blend_timer <= 0.0:
		return
	var duration: float = maxf(_reattach_finish_blend_duration, 0.01)
	var t: float = 1.0 - clampf(_reattach_finish_blend_timer / duration, 0.0, 1.0)
	var eased: float = t * t * (3.0 - 2.0 * t)
	if head != null:
		head.position = _reattach_finish_head_start_position.lerp(head.position, eased)
		head.rotation = _reattach_finish_head_start_rotation.lerp(head.rotation, eased)
		head.scale = Vector3.ONE.lerp(head.scale, eased)


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
		head.position = body.position + _torso_head_socket_offset + Vector3(sway * 0.38, compression * 0.32 + head_pop, forward_shove * 0.45)
		_torso_head_socket_local_position = head.position
		head.rotation = _get_rest_rot("head") + Vector3(-spring_tilt * 0.55, 0.0, sway * 0.42)
	_apply_detached_head_reattach_finish_blend(body, head)


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
	_apply_detached_head_reattach_finish_blend(body, head)
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
	if _head_only_hit_recoil_timer > 0.0:
		_head_only_hit_recoil_timer = maxf(_head_only_hit_recoil_timer - delta, 0.0)
	var target := 1.0 if _attack_timer > 0.0 else 0.0
	if _head_only_hit_recoil_timer > 0.0:
		target = 1.0
	if _torso_head_recoil_timer > 0.0:
		_torso_head_recoil_timer = maxf(_torso_head_recoil_timer - delta, 0.0)
		target = 1.0
	if _torso_head_miss_fall_active:
		target = 1.0
	if _torso_head_miss_detach_requested:
		target = 1.0
	if _is_head_only() and not _head_only_attack_contacted:
		target = 1.0
	if _is_torso_spring_only() and not _torso_head_attack_contacted:
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
	if _is_torso_spring_only():
		_apply_torso_head_attack_pose()
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

	if _head_only_hit_recoil_timer > 0.0:
		_apply_head_only_hit_recoil_pose(head)
		return

	var phase: float = _attack_phase()
	if phase >= 0.999 and not _head_only_attack_landed:
		# The lunge has to move the PLAYER, not just the head visual. Accumulating
		# it into _head_only_base_world_offset instead left the head drifting
		# 0.85 m further from the capsule on every attack, forever. The Player
		# consumes this request in the same frame, so the head does not pop: it
		# stays where the launch left it and the body arrives underneath it.
		_head_only_body_catch_up_offset += _head_only_attack_direction * head_only_attack_lunge
		_head_only_body_catch_up_requested = true
		_head_only_attack_world_offset = Vector3.ZERO
		_head_only_attack_landed = true
		_head_only_attack_contacted = true
		var rest: Vector3 = _get_rest_pos("head")
		var landed_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_base_world_offset)
		head.position = Vector3(rest.x, head_only_ground_socket_y, rest.z) + landed_local_offset
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
	# The charge compression has to unwind INTO the launch. Reading the launch
	# straight off the rest pose snapped the squash/pullback off in a single
	# frame, which teleported the head ~0.23 m and read as a speed spike.
	var release_t: float = clampf(jump_t / maxf(head_only_attack_release_portion, 0.001), 0.0, 1.0)
	var release: float = (1.0 - release_t) * _attack_blend
	_head_only_attack_world_offset = _head_only_attack_direction * head_only_attack_lunge * (commit - 0.14 * release)
	var jump_local_offset: Vector3 = _world_horizontal_offset_to_local(_head_only_attack_world_offset)
	head.position += jump_local_offset
	head.position.y += head_only_attack_arc * arc - head_only_attack_charge_squash * release
	head.rotation.x += head_only_attack_roll * (commit - 0.22 * release)
	var stretch: float = arc * 0.12
	var launch_scale := Vector3(1.0 - stretch * 0.5, 1.0 + stretch, 1.0 - stretch * 0.35)
	var charge_scale := Vector3(
		1.0 + head_only_attack_charge_squash * 0.55 * _attack_blend,
		1.0 - head_only_attack_charge_squash * 0.75 * _attack_blend,
		1.0 + head_only_attack_charge_squash * 0.45 * _attack_blend
	)
	head.scale = charge_scale.lerp(launch_scale, release_t)


func _apply_head_only_hit_recoil_pose(head: Node3D) -> void:
	var duration: float = maxf(head_only_hit_recoil_duration, 0.001)
	var t: float = 1.0 - clampf(_head_only_hit_recoil_timer / duration, 0.0, 1.0)
	var hold_ratio: float = clampf(head_only_hit_recoil_hold / duration, 0.0, 0.65)
	var move_t: float = 0.0
	if hold_ratio < 0.999:
		move_t = clampf((t - hold_ratio) / maxf(1.0 - hold_ratio, 0.001), 0.0, 1.0)
	var eased: float = move_t * move_t * (3.0 - 2.0 * move_t)
	var impact_t: float = 1.0
	if hold_ratio > 0.001:
		impact_t = clampf(t / hold_ratio, 0.0, 1.0)
	var impact_weight: float = 1.0 - impact_t
	var settle_wave: float = sin(move_t * TAU) * (1.0 - move_t) * head_only_hit_recoil_settle
	var recoil_direction: Vector3 = _head_only_hit_recoil_end_offset - _head_only_hit_recoil_start_offset
	recoil_direction.y = 0.0
	if recoil_direction.length() <= 0.001:
		recoil_direction = -_head_only_attack_direction
	else:
		recoil_direction = recoil_direction.normalized()
	var horizontal_push: float = sin(move_t * PI) * (1.0 - move_t * 0.25)
	var horizontal_recoil: Vector3 = recoil_direction * head_only_hit_recoil_horizontal_push * horizontal_push
	horizontal_recoil += recoil_direction * settle_wave
	var world_offset: Vector3 = _head_only_hit_recoil_start_offset.lerp(_head_only_hit_recoil_end_offset, eased)
	world_offset += horizontal_recoil
	_head_only_attack_world_offset = world_offset - _head_only_base_world_offset

	var local_recoil: Vector3 = _world_horizontal_offset_to_local(horizontal_recoil)
	var local_position: Vector3 = _head_only_hit_recoil_start_local_position.lerp(_head_only_hit_recoil_end_local_position, eased)
	var bounce_height: float = maxf(head_only_hit_recoil_arc, head_only_hit_recoil_lift)
	var bounce: float = sin(move_t * PI) * bounce_height * (1.0 - move_t * 0.25)
	head.position = local_position + local_recoil + Vector3(0.0, bounce, 0.0)
	var roll: float = impact_weight * head_only_hit_recoil_roll * 0.65
	roll += sin(move_t * PI) * head_only_hit_recoil_roll + settle_wave * 1.8
	head.rotation = _get_rest_rot("head") + Vector3(_head_only_roll_angle - roll, 0.0, settle_wave * 0.35)
	var squash: float = impact_weight * 0.13 + sin(move_t * PI) * 0.075
	head.scale = Vector3(1.0 + squash * 0.7, 1.0 - squash, 1.0 + squash * 0.35)


func _apply_torso_head_attack_pose() -> void:
	var body := rig.get_socket("body")
	var head := rig.get_socket("head")
	if body == null or head == null:
		return

	if _torso_head_recoil_timer > 0.0:
		_apply_torso_head_recoil_pose(body, head)
		return

	if _torso_head_miss_fall_active:
		_apply_torso_head_miss_fall_pose(body, head)
		return

	if _torso_head_miss_detach_requested:
		_apply_torso_head_miss_body_hold_pose(body)
		head.position = _future_head_only_ground_position()
		head.rotation = _get_rest_rot("head")
		head.scale = Vector3.ONE
		return

	if _torso_head_attack_landed:
		_torso_head_attack_world_offset = Vector3.ZERO
		head.position = _torso_head_socket_local_position
		head.rotation = _get_rest_rot("head")
		head.scale = Vector3.ONE
		return

	var phase: float = _attack_phase()
	var charge_end: float = clampf(torso_head_attack_charge_portion, 0.05, 0.75)
	var coil: float = 0.0
	if phase < charge_end:
		var charge_t: float = phase / charge_end
		coil = sin(charge_t * PI * 0.5) * _attack_blend
		_torso_head_attack_world_offset = _torso_head_attack_direction * (-torso_head_attack_lunge * 0.10 * coil)
		var charge_local_offset: Vector3 = _world_horizontal_offset_to_local(_torso_head_attack_world_offset)
		body.position.y -= torso_head_attack_coil * coil
		body.rotation.x += torso_head_attack_coil * 0.85 * coil
		body.scale = Vector3(1.0 + coil * 0.16, 1.0 - coil * 0.20, 1.0 + coil * 0.12)
		head.position += charge_local_offset
		head.position.y -= torso_head_attack_coil * 0.35 * coil
		head.rotation.x -= torso_head_attack_roll * 0.18 * coil
		_capture_torso_head_miss_body_hold_transform()
		return

	var launch_t: float = (phase - charge_end) / maxf(1.0 - charge_end, 0.001)
	var commit: float = sin(launch_t * PI * 0.5) * _attack_blend
	var arc: float = sin(launch_t * PI) * _attack_blend
	_torso_head_attack_world_offset = _torso_head_attack_direction * (torso_head_attack_lunge * commit)
	_torso_head_socket_local_position = _capture_socket_local_position("head")
	var launch_local_offset: Vector3 = _world_horizontal_offset_to_local(_torso_head_attack_world_offset)
	head.position += launch_local_offset
	head.position.y += torso_head_attack_arc * arc
	head.rotation.x += torso_head_attack_roll * commit
	body.rotation.x -= torso_head_attack_coil * 0.30 * arc
	body.scale = Vector3(1.0 - arc * 0.04, 1.0 + arc * 0.08, 1.0 - arc * 0.03)
	if not _torso_head_miss_body_hold_transform_ready:
		_capture_torso_head_miss_body_hold_transform()

	if phase >= 0.999 and not _torso_head_attack_landed:
		_torso_head_detach_world_offset = _torso_head_attack_direction * torso_head_attack_lunge
		_torso_head_attack_world_offset = _torso_head_detach_world_offset
		_torso_head_attack_landed = true
		_torso_head_attack_contacted = true
		_torso_head_miss_fall_active = true
		_torso_head_miss_fall_timer = maxf(detached_head_landing_duration, 0.01)
		_torso_head_miss_fall_start_position = _capture_socket_local_position("head")
		_torso_head_miss_fall_start_rotation = _capture_socket_local_rotation("head")
		_torso_head_miss_fall_start_scale = _capture_socket_local_scale("head")
		if not _torso_head_miss_body_hold_transform_ready:
			_capture_torso_head_miss_body_hold_transform()


func _apply_torso_head_miss_fall_pose(body: Node3D, head: Node3D) -> void:
	_apply_torso_head_miss_body_hold_pose(body)
	var duration: float = maxf(detached_head_landing_duration, 0.01)
	var t: float = 1.0 - clampf(_torso_head_miss_fall_timer / duration, 0.0, 1.0)
	var eased: float = 1.0 - pow(1.0 - t, 1.45)
	var target_position: Vector3 = _future_head_only_ground_position()
	var target_rotation: Vector3 = _get_rest_rot("head")
	var bounce: float = sin(t * PI) * detached_head_landing_bounce * (1.0 - t)
	head.position = _torso_head_miss_fall_start_position.lerp(target_position, eased) + Vector3(0.0, bounce, 0.0)
	head.rotation = _torso_head_miss_fall_start_rotation.lerp(target_rotation, eased)
	head.rotation.x += detached_head_landing_roll * sin(t * PI) * (1.0 - t * 0.35)
	head.scale = _torso_head_miss_fall_start_scale.lerp(Vector3.ONE, eased)
	_torso_head_attack_world_offset = _torso_head_detach_world_offset

	if t >= 0.999:
		head.position = target_position
		head.rotation = target_rotation
		head.scale = Vector3.ONE
		_torso_head_miss_fall_active = false
		_torso_head_miss_fall_timer = 0.0
		_torso_head_miss_detach_requested = true


func _apply_torso_head_miss_body_hold_pose(body: Node3D) -> void:
	if body == null:
		return
	body.scale = Vector3.ONE


func _future_head_only_ground_position() -> Vector3:
	var rest: Vector3 = _get_rest_pos("head")
	var launch_local_offset: Vector3 = _world_horizontal_offset_to_local(_torso_head_detach_world_offset)
	return Vector3(rest.x, head_only_ground_socket_y, rest.z) + launch_local_offset


func _apply_torso_head_recoil_pose(body: Node3D, head: Node3D) -> void:
	var duration: float = maxf(torso_head_attack_recoil_duration, 0.001)
	var t: float = 1.0 - clampf(_torso_head_recoil_timer / duration, 0.0, 1.0)
	var eased: float = t * t * (3.0 - 2.0 * t)
	var arc: float = sin(t * PI)
	var pullback: Vector3 = _world_horizontal_offset_to_local(-_torso_head_attack_direction * torso_head_attack_recoil_pullback * arc)
	var current_socket_position: Vector3 = _torso_head_socket_local_position
	if current_socket_position == Vector3.ZERO:
		current_socket_position = _torso_head_recoil_end_local_position
	var local_position: Vector3 = _torso_head_recoil_start_local_position.lerp(current_socket_position, eased)
	head.position = local_position + pullback + Vector3(0.0, torso_head_attack_recoil_arc * arc, 0.0)
	head.rotation = _get_rest_rot("head") + Vector3(-torso_head_attack_roll * arc, 0.0, torso_head_attack_roll * 0.25 * sin(t * TAU))
	body.scale = Vector3(1.0 + arc * 0.06, 1.0 - arc * 0.08, 1.0 + arc * 0.04)
	body.rotation.x += torso_head_attack_coil * 0.22 * arc
	_torso_head_attack_world_offset = _torso_head_attack_direction * torso_head_attack_lunge * (1.0 - eased)


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
