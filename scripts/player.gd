extends CharacterBody3D

# Tier 1D: the short-lived, visible attack box we spawn in front of the player.
const ATTACK_HITBOX_SCENE: PackedScene = preload("res://scenes/attack_hitbox.tscn")
const ARROW_PROJECTILE_SCRIPT: Script = preload("res://scripts/arrow_projectile.gd")

# These are the player's normal stats before any bones are equipped.
# The @export tag means you can tune these values in the Godot editor later.
@export var base_move_speed: float = 6.0
@export var sprint_multiplier: float = 1.55
@export var jump_velocity: float = 8.5
@export var base_attack_range: float = 2.0
@export var base_attack_damage: int = 1

# Player survivability. Enemies deal contact_damage; invuln_time is a brief mercy
# window after each hit so a crowd can't drain you in a single frame.
@export var max_health: int = 1
@export var damage_invuln_time: float = 0.7
@export var damage_knockback_strength: float = 5.0

# Tier 1E: each bone's stat effect now lives in one place — scripts/bone_database.gd.

# This is the downward pull that keeps the capsule on the ground.
# Godot has project-wide gravity settings too, but keeping this here makes the first lesson easier to read.
@export var gravity: float = 24.0

# Tier 1D combat-feel tuning.
# attack_cooldown stops repeated clicks from blurring the test (plan suggests 0.35-0.6s).
# forward_offset/height place the swing box just in front of and slightly above the player.
# Must stay ABOVE attack_overlay_duration * 1.15 (the finisher / arm-sword length),
# or the next click restarts the swing before it finishes and you only ever see the
# windup. This is the ceiling on how long a swing can be, so the two move together.
@export var attack_cooldown: float = 0.85
# Extra breathing room after a head-launch attack has fully resolved, on top of
# waiting for the animation itself. Head-launch animations run longer than
# attack_cooldown (torso launch 0.56s, recoils 0.58-0.66s), so the cooldown alone
# let a new jump start before the previous one landed and the poses stacked.
@export var head_launch_attack_recovery: float = 0.12
# Commit the player in place for the duration of a head-only attack, so the body's
# velocity cannot stack on top of the head's launch. Turn off to restore free
# movement while attacking.
@export var head_only_attack_locks_movement: bool = true
@export var attack_forward_offset: float = 1.15
@export var attack_height: float = 0.65
@export_group("Stealth noise")
# Distance in metres at which an enemy can hear the player while noise_timer is
# running. Sprinting must be the louder of the two.
@export var noise_radius_normal: float = 6.5
@export var noise_radius_sprinting: float = 9.0

@export_group("")
# Auto-target range for head-launch attacks. Keep it near the actual lunge reach
# (torso_head_attack_lunge 1.05 + head_only_attack_hitbox_radius 0.28); acquiring
# an enemy further away than the head can travel would still whiff and, in
# torso-only mode, still detach the head.
@export var head_launch_target_range: float = 1.9
@export var head_only_attack_hitbox_lifetime: float = 0.42
@export var head_only_attack_hitbox_height: float = 0.02
@export var head_only_attack_hitbox_radius: float = 0.28
@export var head_only_attack_hitbox_size: Vector3 = Vector3(0.56, 0.56, 0.56)
@export var torso_head_attack_hitbox_lifetime: float = 0.62
@export var detached_head_reattach_range: float = 1.45
@export var detached_head_reattach_hold_time: float = 0.8
@export var detached_head_fallback_launch_distance: float = 1.05
@export var detached_torso_ground_probe_height: float = 2.0
@export var detached_torso_ground_probe_depth: float = 5.0
@export var stealth_prompt_scan_range: float = 3.0
@export_group("Backstab Execution")
@export var backstab_execution_duration: float = 0.75
@export var backstab_execution_impact_time: float = 0.36
@export var backstab_execution_recovery_time: float = 0.20
@export_group("")
@export_group("Bow")
@export var bow_enabled: bool = true
@export var start_with_bow_equipped: bool = false
@export var bow_damage: int = 1
@export var bow_cooldown: float = 0.75
@export var bow_arrow_speed: float = 18.0
@export var bow_arrow_gravity: float = 4.0
@export var bow_arrow_spawn_height: float = 0.85
@export var bow_aim_zoom_distance: float = 2.6
@export var bow_aim_ray_distance: float = 90.0
@export var bow_hand_offset: Vector3 = Vector3(0.02, -0.58, -0.04)
@export var bow_hand_rotation_degrees: Vector3 = Vector3(0.0, 0.0, 18.0)
@export var bow_full_charge_time: float = 1.25
@export var bow_min_charge_multiplier: float = 1.0
@export var bow_max_charge_multiplier: float = 2.5
@export_group("Finger Bones")
@export var finger_bone_damage: int = 1
@export var finger_bone_cooldown: float = 0.55
@export var finger_bone_throw_speed: float = 12.0
@export var finger_bone_throw_gravity: float = 8.0
@export_group("")

# These are the active stats the movement and attack code actually use.
# They start from the base stats, then equipped bones can modify them.
var move_speed: float = 0.0
var attack_range: float = 0.0
var attack_damage: int = 0

# Pressing Tab toggles the inventory screen (which also pauses the game).
var inventory_open: bool = false
var inventory_ui: PlayerInventoryUI = null
var inventory_component: PlayerInventoryComponent = null
var equipment_component: PlayerEquipmentComponent = null
var stats_component: PlayerStatsComponent = null

# This counts nearby world interactions that use the Interact action.
# When it is above 0, that action is reserved for the world prompt.
var nearby_bone_pickups: int = 0

# Tier 1D attack state.
# can_attack is flipped off during the cooldown, then back on when it ends.
# last_facing_direction remembers where to aim the swing when standing still.
var can_attack: bool = true
var can_shoot_bow: bool = true
var last_facing_direction: Vector3 = Vector3.FORWARD
var current_move_direction: Vector3 = Vector3.ZERO
var combo_animation_step: int = 0
var combo_animation_timer: float = 0.0
var bow_visual: Node3D = null
var bow_equipped: bool = false
var bow_aiming: bool = false
var bow_charge_time: float = 0.0
var aim_reticle_layer: CanvasLayer = null
var aim_reticle_root: Control = null
var aim_reticle_dot: ColorRect = null
var aim_reticle_bars: Array[ColorRect] = []
var aim_reticle_charge_label: Label = null

# Survivability state.
var health: int = 0
var is_dead: bool = false
var invuln_timer: float = 0.0
var damage_knockback: Vector3 = Vector3.ZERO
var health_hud_label: Label
var stealth_prompt_label: Label
var stealth_target: Node3D = null
var noise_timer: float = 0.0
var sprinting_this_frame: bool = false
var backstab_execution_target: Node3D = null
var backstab_execution_damage: int = 0
var backstab_execution_hit_from: Vector3 = Vector3.ZERO
var backstab_execution_impact_timer: float = 0.0
var backstab_execution_recovery_timer: float = 0.0
var backstab_execution_damage_applied: bool = false

# Enemy the current head-launch attack is aimed at, if any.
var head_launch_target: Node3D = null
# Counts down only once the head-launch animation has fully resolved.
var head_launch_recovery_timer: float = 0.0
var head_detached_from_torso: bool = false
var detached_torso_bone_id: String = ""
var detached_torso_marker: Node3D = null
var detached_torso_reattach_progress: float = 0.0
var detached_torso_reattaching: bool = false
var detached_camera_offset_carry: Vector3 = Vector3.ZERO
var detached_camera_offset_carry_timer: float = 0.0

# Sockets are empty Node3D children on the player, one per equip slot.
# Adding a visible bone as a child of a socket makes it move with the player.
@onready var socket_arm_right: Node3D = $SocketArmRight
@onready var socket_arm_left: Node3D = $SocketArmLeft
@onready var socket_legs: Node3D = $SocketLegs
@onready var socket_body: Node3D = $SocketBody
@onready var visual_root: Node3D = $VisualRoot
@onready var rig: ModularSkeletonRig = $VisualRoot/ModularSkeletonRig
@onready var animator: ProceduralPlayerAnimator = $VisualRoot/ProceduralAnimator
@onready var camera_controller: PlayerCameraController = $CameraPivot


# _ready runs once when the player enters the running scene.
func _ready() -> void:
	add_to_group("player")
	# Keep processing while the tree is paused, so the inventory screen (which
	# pauses the game) can still be closed and browsed.
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	inventory_open = false
	health = max_health
	bow_equipped = false
	stats_component = PlayerStatsComponent.new()
	add_child(stats_component)
	stats_component.setup(base_move_speed, base_attack_range, base_attack_damage, max_health)
	equipment_component = PlayerEquipmentComponent.new()
	add_child(equipment_component)
	equipment_component.setup(self)
	if rig != null and rig.has_method("set_body_progression_enabled"):
		rig.set_body_progression_enabled(true)
	equipment_component.equip_starting_core()
	inventory_component = PlayerInventoryComponent.new()
	add_child(inventory_component)
	inventory_component.setup(self, equipment_component)
	_recalculate_stats()
	if start_with_bow_equipped:
		_set_bow_equipped(true)
	inventory_ui = PlayerInventoryUI.new()
	add_child(inventory_ui)
	inventory_ui.setup(self)
	_build_health_ui()
	_build_stealth_ui()
	_build_aim_reticle_ui()
	_build_bow_visual()
	if inventory_component != null:
		GameEvents.inventory_changed.emit(self, inventory_component.get_inventory_items(), inventory_component.get_run_stats())
	_setup_procedural_character()
	_update_mouse_mode()


func _input(event: InputEvent) -> void:
	if inventory_ui != null:
		inventory_ui.handle_input(event)


# Godot calls _physics_process many times per second on a steady physics clock.
# Movement and collision code belongs here because it needs consistent timing.
func _physics_process(delta: float) -> void:

	# The inventory toggle and equipping work even while paused, so you can open
	# the inventory, study your build, and rearrange it with the game frozen.
	if inventory_open and Input.is_action_just_pressed("ui_cancel") and not is_dead and not _is_backstab_executing():
		_toggle_inventory()
	elif _input_just_pressed("inventory") and not is_dead and not _is_backstab_executing():
		_toggle_inventory()

	if inventory_open and Input.is_action_just_pressed("ui_focus_next") and not Input.is_action_just_pressed("inventory") and not is_dead:
		if inventory_ui != null:
			inventory_ui.cycle_category()

	if _input_just_pressed("equip") and not is_dead and not _is_backstab_executing():
		_equip_next_bone()

	# While the inventory is open (paused) or the player is dead, stop here:
	# no movement, no attacking.
	if get_tree().paused or is_dead:
		_cancel_bow_aim()
		_set_stealth_prompt("")
		return

	if _update_detached_torso_reattach(delta):
		pass
	elif _is_backstab_executing():
		_set_stealth_prompt("Executing stealth finish...")
	else:
		_update_stealth_finish_prompt()
	_update_backstab_execution(delta)
	if _input_just_pressed("stealth_finish") and not detached_torso_reattaching and not _is_backstab_executing():
		_try_stealth_finish()
	if _input_just_pressed("toggle_bow") and not detached_torso_reattaching and not _is_backstab_executing():
		_toggle_bow_equipped()
	_update_head_launch_recovery(delta)
	if bow_aiming:
		bow_charge_time = minf(bow_charge_time + delta, maxf(bow_full_charge_time, 0.01))
		_update_aim_reticle_ui()

	# Count down the mercy window after taking a hit.
	if invuln_timer > 0.0:
		invuln_timer -= delta
	if noise_timer > 0.0:
		noise_timer = maxf(noise_timer - delta, 0.0)
	if combo_animation_timer > 0.0:
		combo_animation_timer = maxf(combo_animation_timer - delta, 0.0)
	elif combo_animation_step != 0:
		combo_animation_step = 0
	if detached_camera_offset_carry_timer > 0.0:
		detached_camera_offset_carry_timer = maxf(detached_camera_offset_carry_timer - delta, 0.0)

	if _input_just_pressed("attack") and not detached_torso_reattaching and not _is_backstab_executing():
		if bow_equipped:
			_start_bow_aim()
		else:
			_try_attack()
	if _input_just_released("attack") and bow_aiming and not detached_torso_reattaching and not _is_backstab_executing():
		_release_bow_shot()
	if _input_just_pressed("ranged_attack") and not bow_equipped and not detached_torso_reattaching and not _is_backstab_executing():
		_try_bow_shot()

	# Space gives the player a clean hop. The floor check prevents air-jumping.
	if _input_just_pressed("jump") and is_on_floor() and not _is_backstab_executing():
		velocity.y = jump_velocity

	# If the player is in the air, build up downward speed over time.
	# delta means "how much time passed since the last physics frame."
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif not _input_just_pressed("jump"):
		velocity.y = 0.0

	# Input.get_vector reads four named input actions from project.godot.
	# W makes the y value negative, S makes it positive, A makes x negative, and D makes x positive.
	var input_vector := _get_move_input_vector()
	if detached_torso_reattaching or _is_head_only_attack_locking_movement() or _is_backstab_executing():
		input_vector = Vector2.ZERO

	var direction := _get_camera_relative_move_direction(input_vector)
	current_move_direction = direction

	# Keep diagonal movement from being faster than straight movement.
	if direction.length() > 1.0:
		direction = direction.normalized()

	# Tier 1D: remember the last direction we actually moved, so an attack while
	# standing still still swings the way we were last heading.
	if bow_aiming:
		var aim_forward: Vector3 = _get_camera_forward_direction()
		aim_forward.y = 0.0
		if aim_forward.length() > 0.01:
			last_facing_direction = aim_forward.normalized()
	elif direction.length() > 0.01:
		last_facing_direction = direction

	var current_move_speed := move_speed
	sprinting_this_frame = _input_pressed("sprint") and direction.length() > 0.01
	if sprinting_this_frame:
		current_move_speed *= sprint_multiplier
		noise_timer = maxf(noise_timer, 0.18)

	# Fading knockback from taking a hit rides on top of normal movement.
	damage_knockback = damage_knockback.move_toward(Vector3.ZERO, damage_knockback_strength * 4.0 * delta)

	# CharacterBody3D already has a velocity variable.
	# We keep horizontal control direct so the player stops without sliding.
	velocity.x = direction.x * current_move_speed + damage_knockback.x
	velocity.z = direction.z * current_move_speed + damage_knockback.z

	# move_and_slide moves the body, checks collisions, and slides along walls/floors instead of passing through them.
	move_and_slide()
	_update_procedural_animation(delta, current_move_speed)


func _get_camera_relative_move_direction(input_vector: Vector2) -> Vector3:
	if camera_controller == null:
		return Vector3(input_vector.x, 0.0, input_vector.y)

	var forward := camera_controller.get_flat_forward()
	var right := camera_controller.get_flat_right()
	var direction := right * input_vector.x + forward * -input_vector.y
	direction.y = 0.0
	if direction.length() > 1.0:
		return direction.normalized()
	return direction


# These read the InputMap and nothing else. There used to be a second layer that
# OR'd in hardcoded physical keys (KEY_W, KEY_E, ...), which meant the rebinding
# UI in player_inventory_ui.gd could never unbind a default: rebinding Move
# Forward off W left W walking forever. Every action it shadowed is declared in
# project.godot, so the layer was pure redundancy.
func _input_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)


func _input_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)


func _input_just_released(action: String) -> bool:
	return Input.is_action_just_released(action)


func _get_move_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")


func _get_camera_forward_direction() -> Vector3:
	if camera_controller == null:
		return Vector3.FORWARD
	return camera_controller.get_flat_forward()


# Tier 1D combat: instead of instantly zapping the nearest enemy, we spawn a
# short-lived, VISIBLE attack box in front of the player. Only enemies that
# overlap that box take damage, so hits and misses are easy to read.
func _try_attack() -> void:
	# Respect the cooldown so holding or mashing left click does not blur the test.
	if not can_attack:
		return
	if _is_backstab_executing():
		return
	# Head-launch jumps outlast attack_cooldown, so they get their own gate: the
	# previous jump must finish and recover before another can start.
	if _head_launch_attack_input_blocked():
		return
	can_attack = false
	noise_timer = maxf(noise_timer, 0.55)
	if _is_head_only_combat_mode():
		_force_head_only_single_visual()
	# Head-launch attacks auto-aim at a nearby enemy BEFORE the animator is
	# triggered, so the launch starts aimed instead of correcting a frame later.
	_acquire_head_launch_target()
	_push_head_launch_attack_aim()
	var combo_step: int = _next_combo_animation_step()
	if animator != null:
		animator.trigger_attack(combo_step)

	# Aim the swing in the direction the player last moved.
	var forward := current_move_direction
	if forward.length() < 0.01:
		forward = _get_camera_forward_direction()
	forward.y = 0.0
	forward = forward.normalized()
	# ...unless an enemy was acquired, in which case aim at it.
	var target_aim := _head_launch_target_aim()
	if target_aim != Vector3.ZERO:
		forward = target_aim

	# Create the attack box and hand it this attack's damage. attack_damage
	# already includes bone bonuses, so the Heavy Bone really does hit harder.
	var hitbox := ATTACK_HITBOX_SCENE.instantiate()
	hitbox.damage = attack_damage
	hitbox.owner_player = self
	var head_only_attack := _is_head_only_combat_mode()
	var torso_head_attack := _is_torso_head_launch_combat_mode()
	var head_launch_attack := head_only_attack or torso_head_attack
	hitbox.visual_enabled = not head_launch_attack
	if head_launch_attack:
		hitbox.lifetime = torso_head_attack_hitbox_lifetime if torso_head_attack else head_only_attack_hitbox_lifetime
		hitbox.override_shape_type = "Sphere"
		hitbox.override_sphere_radius = head_only_attack_hitbox_radius
		hitbox.override_shape_size = head_only_attack_hitbox_size
		hitbox.follow_target = _get_head_only_hitbox_follow_target()
		hitbox.follow_direction = forward
		hitbox.follow_forward_offset = 0.0
		hitbox.follow_height = head_only_attack_hitbox_height
	if hitbox.has_signal("hit_confirmed"):
		hitbox.hit_confirmed.connect(_on_attack_hit_confirmed)

	# Add it to the world (not as a child of the player) so it stays where it was
	# swung and cleans itself up after its brief lifetime.
	get_tree().current_scene.add_child(hitbox)

	if not head_launch_attack:
		# Place the box a bit in front of the player and slightly above the floor...
		hitbox.global_position = global_position + forward * attack_forward_offset + Vector3.UP * attack_height
		# ...then aim its depth in the attack direction. (look_at points -Z at the target.)
		hitbox.look_at(hitbox.global_position + forward, Vector3.UP)

	# Arm Bone reach: a bigger attack_range grows the whole swing box. We set
	# scale AFTER look_at, because look_at rewrites the box's rotation.
	var reach_ratio := 1.0
	if base_attack_range > 0.0 and not head_launch_attack:
		reach_ratio = attack_range / base_attack_range
	hitbox.scale = Vector3.ONE * reach_ratio

	# A quick flash on the player body so it's obvious YOU just attacked.
	if not _is_head_only_combat_mode():
		_flash_player_attack()

	# Wait out the cooldown, then allow attacking again.
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_attack_hit_confirmed(_target: Node) -> void:
	if animator != null and animator.has_method("confirm_head_only_attack_contact"):
		animator.confirm_head_only_attack_contact()


# --- Head-launch auto-target ---------------------------------------------------
# Head-only and torso-only attacks launch the head off the body. They used to aim
# down current_move_direction, so strafing around an enemy threw the head into
# empty space; in torso-only mode a miss detaches the head from the torso, which
# cost the player their head mid-fight. Picking the nearest enemy keeps the launch
# pointed at what the player is actually fighting.
func _acquire_head_launch_target() -> void:
	head_launch_target = null
	if not _is_head_launch_combat_mode():
		return
	var candidates: Array[Node] = []
	var positions: Array = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not (enemy is Node3D) or not is_instance_valid(enemy):
			continue
		# A missing `alive` property means the node does not model death, so it
		# stays targetable rather than being silently skipped.
		var alive_value: Variant = enemy.get("alive")
		if alive_value is bool and not bool(alive_value):
			continue
		candidates.append(enemy)
		positions.append((enemy as Node3D).global_position)
	if candidates.is_empty():
		return
	var best: int = CombatTargetingService.best_target_index(
		global_position,
		last_facing_direction,
		positions,
		head_launch_target_range
	)
	if best >= 0:
		head_launch_target = candidates[best] as Node3D


# Live aim at the acquired target, or ZERO when there is none to aim at.
func _head_launch_target_aim() -> Vector3:
	if head_launch_target == null or not is_instance_valid(head_launch_target):
		return Vector3.ZERO
	var alive_value: Variant = head_launch_target.get("alive")
	if alive_value is bool and not bool(alive_value):
		return Vector3.ZERO
	return CombatTargetingService.aim_direction(global_position, head_launch_target.global_position)


# Re-pushed every frame so an enemy that moves mid-attack is still tracked.
func _push_head_launch_attack_aim() -> void:
	if animator == null or not animator.has_method("set_head_launch_attack_aim"):
		return
	var aim := _head_launch_target_aim()
	animator.call("set_head_launch_attack_aim", aim, aim != Vector3.ZERO)


func _is_head_launch_combat_mode() -> bool:
	return _is_head_only_combat_mode() or _is_torso_head_launch_combat_mode()


# Head-only attacks launch the head off the ground. The launch is applied as an
# offset ON TOP of the body's motion, so a body still running at move_speed added
# its velocity to the launch and the head read as teleporting. Committing the
# player in place for the attack keeps the head's world speed equal to the
# animation's own speed, whatever the player was doing beforehand.
# Knockback still applies: only steering input is dropped, not velocity.
func _is_head_only_attack_locking_movement() -> bool:
	if not head_only_attack_locks_movement:
		return false
	if not _is_head_only_combat_mode():
		return false
	return _is_head_launch_attack_busy()


func _is_head_launch_attack_busy() -> bool:
	if animator == null or not animator.has_method("is_head_launch_attack_busy"):
		return false
	return bool(animator.call("is_head_launch_attack_busy"))


func _is_head_launch_attack_blocked() -> bool:
	return _is_head_launch_attack_busy() or head_launch_recovery_timer > 0.0


# Single gate for every path that fires an attack animation. A launch in flight
# owns the head socket: triggering anything else would snap it back to the ground
# mid-air. Every trigger_attack() caller goes through this, so a future change to
# one cooldown (attack_cooldown, bow_cooldown) cannot reopen the stacking hole.
func _head_launch_attack_input_blocked() -> bool:
	return _is_head_launch_combat_mode() and _is_head_launch_attack_blocked()


# Held at full while the jump is resolving, then counts down. Keeping the reset
# here (rather than starting a timer on landing) means a miss, a hit recoil and a
# clean landing all get the same recovery without tracking how the attack ended.
func _update_head_launch_recovery(delta: float) -> void:
	if _is_head_launch_attack_busy():
		head_launch_recovery_timer = maxf(head_launch_attack_recovery, 0.0)
		return
	if head_launch_recovery_timer > 0.0:
		head_launch_recovery_timer = maxf(head_launch_recovery_timer - delta, 0.0)


func _get_head_only_hitbox_follow_target() -> Node3D:
	if rig != null and rig.has_method("get_socket"):
		var head_socket := rig.get_socket("head")
		if head_socket != null:
			return head_socket
	return self


func _is_head_only_combat_mode() -> bool:
	return rig != null and rig.has_method("has_equipped_slot") and not bool(rig.call("has_equipped_slot", "body"))


func _is_slot_equipped(slot: String) -> bool:
	return rig != null and rig.has_method("has_equipped_slot") and bool(rig.call("has_equipped_slot", slot))


# One arm is enough to punch with.
func _has_any_arm_equipped() -> bool:
	return _is_slot_equipped("right_arm") or _is_slot_equipped("left_arm")


# A legless torso throws its head ONLY when it has no arm to swing. With an arm
# equipped the animator plays the arm combo instead, so this must go false in
# lockstep: it routes the hitbox (head-following sphere vs normal melee box), the
# movement lock, the anti-stacking gate, and the miss-detach. Leaving it true
# would aim the hitbox at the head while the arm does the swinging.
func _is_torso_head_launch_combat_mode() -> bool:
	return (
		_is_slot_equipped("body")
		and not _is_slot_equipped("legs")
		and not _has_any_arm_equipped()
	)


func _force_head_only_single_visual() -> void:
	if rig != null and rig.has_method("set_head_only_visual_guard"):
		rig.call("set_head_only_visual_guard", true)


func _try_bow_shot(charge_multiplier: float = 1.0, charge_ratio: float = 0.0) -> void:
	if not bow_enabled or not can_shoot_bow:
		return
	if _head_launch_attack_input_blocked():
		return
	if bow_equipped and not _can_use_bow():
		_set_bow_equipped(false)
		_set_stealth_prompt("Attach both arms before using the bow.")
		return

	can_shoot_bow = false
	noise_timer = maxf(noise_timer, 0.45)
	if animator != null:
		# Feedback only: a ranged shot must not throw the head off the body.
		animator.trigger_attack(0, false)

	var forward: Vector3 = _get_camera_forward_direction()
	if not bow_equipped and current_move_direction.length() > 0.01:
		forward = current_move_direction
	forward.y = 0.0
	if forward.length() <= 0.01:
		forward = last_facing_direction
	forward = forward.normalized()
	last_facing_direction = forward

	var shot_cooldown: float = bow_cooldown
	if bow_equipped:
		var charged_damage: int = maxi(1, int(round(float(bow_damage) * charge_multiplier)))
		var charged_speed: float = bow_arrow_speed * lerpf(0.9, 1.15, clampf(charge_ratio, 0.0, 1.0))
		_fire_player_projectile(forward, charged_damage, charged_speed, bow_arrow_gravity, "arrow")
	else:
		shot_cooldown = finger_bone_cooldown
		_fire_player_projectile(forward, finger_bone_damage, finger_bone_throw_speed, finger_bone_throw_gravity, "finger_bone")

	_flash_player_attack()
	await get_tree().create_timer(shot_cooldown).timeout
	can_shoot_bow = true


func _start_bow_aim() -> void:
	if not bow_enabled or not can_shoot_bow:
		return
	if not _can_use_bow():
		_set_bow_equipped(false)
		_set_stealth_prompt("Attach both arms before using the bow.")
		return

	bow_aiming = true
	bow_charge_time = 0.0
	_set_aim_reticle_visible(true)
	_update_aim_reticle_ui()
	if animator != null and animator.has_method("set_aiming"):
		animator.set_aiming(true)
	if camera_controller != null and camera_controller.has_method("set_aim_zoom"):
		camera_controller.set_aim_zoom(true, bow_aim_zoom_distance)


func _release_bow_shot() -> void:
	if not bow_aiming:
		return

	var charge_multiplier: float = _get_bow_charge_multiplier()
	var charge_ratio: float = _get_bow_charge_ratio()
	_cancel_bow_aim()
	_try_bow_shot(charge_multiplier, charge_ratio)


func _cancel_bow_aim() -> void:
	if not bow_aiming:
		return

	bow_aiming = false
	bow_charge_time = 0.0
	_set_aim_reticle_visible(false)
	if animator != null and animator.has_method("set_aiming"):
		animator.set_aiming(false)
	if camera_controller != null and camera_controller.has_method("set_aim_zoom"):
		camera_controller.set_aim_zoom(false)


func _toggle_bow_equipped() -> void:
	if not bow_enabled:
		return
	if not bow_equipped and not _can_use_bow():
		_cancel_bow_aim()
		_set_bow_equipped(false)
		_set_stealth_prompt("Attach both arms before using the bow.")
		return

	_cancel_bow_aim()

	_set_bow_equipped(not bow_equipped)


func _set_bow_equipped(enabled: bool) -> void:
	bow_equipped = enabled and _can_use_bow()
	if bow_visual != null:
		bow_visual.visible = bow_equipped


func _can_use_bow() -> bool:
	var equipment_state: Dictionary = get_equipment_state()
	return equipment_state.has("right_arm") and equipment_state.has("left_arm")


func _fire_player_projectile(forward: Vector3, projectile_damage: int, projectile_speed: float, projectile_gravity: float, projectile_style: String) -> void:
	var projectile: Area3D = ARROW_PROJECTILE_SCRIPT.new() as Area3D
	if projectile == null or get_tree().current_scene == null:
		return

	var muzzle_forward: Vector3 = forward
	muzzle_forward.y = 0.0
	if muzzle_forward.length() <= 0.01:
		muzzle_forward = last_facing_direction
	muzzle_forward = muzzle_forward.normalized()

	var start_position: Vector3 = global_position + Vector3.UP * bow_arrow_spawn_height + muzzle_forward * 0.7
	if projectile_style == "arrow" and bow_equipped and bow_visual != null:
		start_position = bow_visual.global_position
	var launch_velocity: Vector3 = forward.normalized() * projectile_speed
	if projectile_style != "arrow":
		# Finger bones are a short underhand lob with no reticle promising anything,
		# so they keep their flat loft rather than gaining a solve.
		launch_velocity.y = 0.65
	elif bow_equipped:
		# The reticle is a fixed dot the aim ray is cast through — it promises the
		# arrow lands on the crosshair. Firing straight down that ray while gravity
		# pulls the arrow down broke that promise by 0.64 m at 10 m, and the miss
		# grew with range and shrank with charge, so no hold-over was learnable.
		# Solve the ANGLE, not the vertical speed: charge must keep meaning speed.
		var aim_point: Vector3 = _get_pointer_aim_point(start_position, muzzle_forward)
		var solved: Vector3 = BallisticsService.solve_launch_velocity_fixed_speed(
			start_position,
			aim_point,
			projectile_speed,
			projectile_gravity,
			BallisticsService.physics_step()
		)
		if solved != Vector3.ZERO:
			launch_velocity = solved
		else:
			# Out of ballistic reach (open sky, or too far/too steep to arc onto).
			# Fire straight down the aim line rather than inventing energy.
			launch_velocity = _aim_direction_to(start_position, aim_point, muzzle_forward) * projectile_speed
	if projectile.has_method("configure"):
		projectile.call("configure", start_position, launch_velocity, projectile_damage, self, false, projectile_gravity, projectile_style)
	get_tree().current_scene.add_child(projectile)


# Where the centre-screen ray lands: a real surface hit, or ray_end when it hits
# nothing. The ballistic solve needs the POINT, not just a direction, because a
# direction carries no distance and therefore no time of flight.
func _get_pointer_aim_point(start_position: Vector3, fallback_direction: Vector3) -> Vector3:
	if camera_controller != null and camera_controller.has_method("get_center_aim_point"):
		var exclude: Array[RID] = []
		var player_collision: CollisionObject3D = self as CollisionObject3D
		if player_collision != null:
			exclude.append(player_collision.get_rid())
		var aim_point: Vector3 = camera_controller.get_center_aim_point(bow_aim_ray_distance, exclude)
		if start_position.distance_to(aim_point) > 0.01:
			return aim_point

	if fallback_direction.length() > 0.01:
		return start_position + fallback_direction.normalized() * bow_aim_ray_distance
	return start_position + Vector3.FORWARD * bow_aim_ray_distance


func _aim_direction_to(start_position: Vector3, aim_point: Vector3, fallback_direction: Vector3) -> Vector3:
	var aim_direction: Vector3 = aim_point - start_position
	if aim_direction.length() > 0.01:
		return aim_direction.normalized()
	if fallback_direction.length() > 0.01:
		return fallback_direction.normalized()
	return Vector3.FORWARD


func _try_stealth_finish() -> void:
	if stealth_target == null or not is_instance_valid(stealth_target):
		return
	if not can_attack:
		return
	if _is_backstab_executing():
		return
	if _head_launch_attack_input_blocked():
		return
	if not stealth_target.has_method("try_stealth_finish"):
		return

	can_attack = false
	_cancel_bow_aim()
	noise_timer = maxf(noise_timer, 0.35)
	_face_backstab_target(stealth_target)
	if animator != null:
		# Feedback only: the finisher must not throw the head off the body.
		animator.trigger_attack(3, false)
	_flash_player_attack()
	var finished := bool(stealth_target.call("try_stealth_finish", self, attack_damage, global_position))
	if not finished:
		stealth_target = null
		can_attack = true
		return
	_start_backstab_execution(stealth_target, attack_damage, global_position)
	_set_stealth_prompt("")

func _start_backstab_execution(target: Node3D, damage: int, hit_from: Vector3) -> void:
	backstab_execution_target = target
	backstab_execution_damage = damage
	backstab_execution_hit_from = hit_from
	backstab_execution_impact_timer = clampf(backstab_execution_impact_time, 0.0, maxf(backstab_execution_duration, 0.01))
	backstab_execution_recovery_timer = maxf(backstab_execution_duration + backstab_execution_recovery_time, attack_cooldown)
	backstab_execution_damage_applied = false


func _update_backstab_execution(delta: float) -> void:
	if not _is_backstab_executing():
		return
	if backstab_execution_target == null or not is_instance_valid(backstab_execution_target):
		_cancel_backstab_execution()
		return
	if is_dead:
		_cancel_backstab_execution()
		return

	_face_backstab_target(backstab_execution_target)
	backstab_execution_impact_timer = maxf(backstab_execution_impact_timer - delta, 0.0)
	backstab_execution_recovery_timer = maxf(backstab_execution_recovery_timer - delta, 0.0)

	if not backstab_execution_damage_applied and backstab_execution_impact_timer <= 0.0:
		backstab_execution_damage_applied = true
		if backstab_execution_target.has_method("apply_stealth_finish_impact"):
			backstab_execution_target.call(
				"apply_stealth_finish_impact",
				self,
				backstab_execution_damage,
				backstab_execution_hit_from
			)
		elif backstab_execution_target.has_method("take_damage"):
			backstab_execution_target.call("take_damage", backstab_execution_damage, backstab_execution_hit_from, self, "backstab")

	if backstab_execution_recovery_timer <= 0.0:
		_finish_backstab_execution()


func _finish_backstab_execution() -> void:
	if backstab_execution_target != null and is_instance_valid(backstab_execution_target):
		if backstab_execution_target.has_method("finish_stealth_execution"):
			backstab_execution_target.call("finish_stealth_execution", self)
	_clear_backstab_execution_state()
	can_attack = true


func _cancel_backstab_execution() -> void:
	if backstab_execution_target != null and is_instance_valid(backstab_execution_target):
		if backstab_execution_target.has_method("cancel_stealth_execution"):
			backstab_execution_target.call("cancel_stealth_execution", self)
	_clear_backstab_execution_state()
	can_attack = true


func _clear_backstab_execution_state() -> void:
	backstab_execution_target = null
	backstab_execution_damage = 0
	backstab_execution_hit_from = Vector3.ZERO
	backstab_execution_impact_timer = 0.0
	backstab_execution_recovery_timer = 0.0
	backstab_execution_damage_applied = false


func _is_backstab_executing() -> bool:
	return backstab_execution_target != null


func _face_backstab_target(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		return
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() <= 0.01:
		return
	last_facing_direction = to_target.normalized()


# right arm -> left arm -> both -> tear the left arm off and swing it.
# The fourth step only joins the cycle with BOTH arms equipped: with one arm there
# is nothing to grab, and the animator would pose a hidden socket.
const COMBO_STEP_ARM_SWORD := 4


func _next_combo_animation_step() -> int:
	# While the arm is off, every attack keeps swinging it: the combo does not
	# advance until it has landed its swings and gone back on.
	if _is_arm_sword_held():
		combo_animation_step = COMBO_STEP_ARM_SWORD
		combo_animation_timer = _combo_animation_window()
		return COMBO_STEP_ARM_SWORD

	if combo_animation_timer <= 0.0:
		combo_animation_step = 0
	var step_count: int = COMBO_STEP_ARM_SWORD if _has_both_arms_equipped() else 3
	combo_animation_step = (combo_animation_step % step_count) + 1
	combo_animation_timer = _combo_animation_window()
	return combo_animation_step


func _is_arm_sword_held() -> bool:
	if animator == null or not animator.has_method("is_arm_sword_held"):
		return false
	return bool(animator.call("is_arm_sword_held"))


func _has_both_arms_equipped() -> bool:
	return _is_slot_equipped("right_arm") and _is_slot_equipped("left_arm")


func _combo_animation_window() -> float:
	var window: float = attack_cooldown + 0.25
	var equipment_state: Dictionary = get_equipment_state()
	for slot in equipment_state:
		var bone_id := str(equipment_state[slot])
		if bone_id == "":
			continue
		window = maxf(window, BoneRulesService.combo_window_for(bone_id) + attack_cooldown)
	return window


# Tier 1D: briefly brighten the player's own mesh on attack, then restore it.
func _flash_player_attack() -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh == null:
		return

	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color(1.0, 1.0, 1.0)
	flash_material.emission_enabled = true
	flash_material.emission = Color(1.0, 1.0, 1.0)
	flash_material.emission_energy_multiplier = 0.6
	# material_override temporarily replaces the look without touching the real material.
	mesh.material_override = flash_material

	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(mesh):
		mesh.material_override = null


func _setup_procedural_character() -> void:
	if animator == null or rig == null:
		return

	animator.rig = rig
	animator.turn_target = visual_root
	if animator.has_method("set_player_body_progression_enabled"):
		animator.set_player_body_progression_enabled(true)
	if rig.has_method("set_body_hitbox_owner"):
		rig.set_body_hitbox_owner(self)


func _build_bow_visual() -> void:
	if bow_visual != null:
		return

	var bow_parent: Node3D = _get_bow_visual_parent()
	if bow_parent == null:
		return

	bow_visual = Node3D.new()
	bow_visual.name = "DemoBow"
	bow_parent.add_child(bow_visual)
	bow_visual.position = bow_hand_offset
	bow_visual.rotation_degrees = bow_hand_rotation_degrees

	var upper: MeshInstance3D = _make_bow_piece("BowUpper", Vector3(0.055, 0.52, 0.055), Vector3(0.0, 0.22, 0.0), Color(0.45, 0.25, 0.08, 1.0))
	var lower: MeshInstance3D = _make_bow_piece("BowLower", Vector3(0.055, 0.52, 0.055), Vector3(0.0, -0.22, 0.0), Color(0.45, 0.25, 0.08, 1.0))
	var string_piece: MeshInstance3D = _make_bow_piece("BowString", Vector3(0.018, 1.0, 0.018), Vector3(0.07, 0.0, 0.0), Color(0.92, 0.86, 0.68, 1.0))
	bow_visual.add_child(upper)
	bow_visual.add_child(lower)
	bow_visual.add_child(string_piece)
	bow_visual.visible = bow_equipped


func _get_bow_visual_parent() -> Node3D:
	if rig != null:
		var left_arm_socket: Node3D = rig.get_socket("left_arm")
		if left_arm_socket != null:
			return left_arm_socket
	return socket_arm_left


func _build_aim_reticle_ui() -> void:
	if aim_reticle_layer != null:
		return

	aim_reticle_layer = CanvasLayer.new()
	aim_reticle_layer.name = "AimReticleLayer"
	add_child(aim_reticle_layer)

	aim_reticle_root = Control.new()
	aim_reticle_root.name = "AimReticle"
	aim_reticle_root.anchor_right = 1.0
	aim_reticle_root.anchor_bottom = 1.0
	aim_reticle_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aim_reticle_root.visible = false
	aim_reticle_layer.add_child(aim_reticle_root)

	aim_reticle_dot = _make_reticle_rect("Dot", -3.0, -3.0, 3.0, 3.0, Color(0.0, 0.9, 1.0, 0.95))
	aim_reticle_root.add_child(aim_reticle_dot)
	aim_reticle_bars.append(_make_reticle_rect("Left", -30.0, -1.5, -10.0, 1.5, Color.WHITE))
	aim_reticle_bars.append(_make_reticle_rect("Right", 10.0, -1.5, 30.0, 1.5, Color.WHITE))
	aim_reticle_bars.append(_make_reticle_rect("Top", -1.5, -30.0, 1.5, -10.0, Color.WHITE))
	aim_reticle_bars.append(_make_reticle_rect("Bottom", -1.5, 10.0, 1.5, 30.0, Color.WHITE))
	for bar_node in aim_reticle_bars:
		var bar: ColorRect = bar_node as ColorRect
		if bar == null:
			continue
		aim_reticle_root.add_child(bar)

	aim_reticle_charge_label = Label.new()
	aim_reticle_charge_label.name = "ChargeLabel"
	aim_reticle_charge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aim_reticle_charge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	aim_reticle_charge_label.add_theme_font_size_override("font_size", 16)
	aim_reticle_charge_label.add_theme_color_override("font_color", Color(0.0, 0.85, 1.0, 0.9))
	aim_reticle_charge_label.anchor_left = 0.5
	aim_reticle_charge_label.anchor_right = 0.5
	aim_reticle_charge_label.anchor_top = 0.5
	aim_reticle_charge_label.anchor_bottom = 0.5
	aim_reticle_charge_label.offset_left = -45.0
	aim_reticle_charge_label.offset_right = 45.0
	aim_reticle_charge_label.offset_top = 30.0
	aim_reticle_charge_label.offset_bottom = 54.0
	aim_reticle_root.add_child(aim_reticle_charge_label)


func _make_reticle_rect(rect_name: String, left: float, top: float, right: float, bottom: float, color: Color) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.name = rect_name
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.anchor_left = 0.5
	rect.anchor_right = 0.5
	rect.anchor_top = 0.5
	rect.anchor_bottom = 0.5
	rect.offset_left = left
	rect.offset_top = top
	rect.offset_right = right
	rect.offset_bottom = bottom
	return rect


func _set_aim_reticle_visible(visible: bool) -> void:
	if aim_reticle_root != null:
		aim_reticle_root.visible = visible


func _update_aim_reticle_ui() -> void:
	if aim_reticle_root == null:
		return

	var ratio: float = _get_bow_charge_ratio()
	var reticle_color: Color = Color(0.0, 0.85, 1.0, 0.82).lerp(Color(1.0, 0.78, 0.18, 0.96), ratio)
	if aim_reticle_dot != null:
		aim_reticle_dot.color = reticle_color
	for bar_node in aim_reticle_bars:
		var bar: ColorRect = bar_node as ColorRect
		if bar == null:
			continue
		bar.color = reticle_color
	if aim_reticle_charge_label != null:
		var multiplier: float = _get_bow_charge_multiplier()
		aim_reticle_charge_label.text = "x%.1f" % multiplier
		aim_reticle_charge_label.add_theme_color_override("font_color", reticle_color)


func _get_bow_charge_ratio() -> float:
	var full_charge_time: float = maxf(bow_full_charge_time, 0.01)
	return clampf(bow_charge_time / full_charge_time, 0.0, 1.0)


func _get_bow_charge_multiplier() -> float:
	var min_multiplier: float = maxf(bow_min_charge_multiplier, 0.1)
	var max_multiplier: float = maxf(bow_max_charge_multiplier, min_multiplier)
	return lerpf(min_multiplier, max_multiplier, _get_bow_charge_ratio())


func _make_bow_piece(piece_name: String, size: Vector3, local_position: Vector3, color: Color) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var piece: MeshInstance3D = MeshInstance3D.new()
	piece.name = piece_name
	piece.mesh = mesh
	piece.position = local_position
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	piece.material_override = material
	return piece


func _update_procedural_animation(delta: float, max_speed: float) -> void:
	if animator == null or rig == null:
		return

	# Refresh the aim before the animator runs, so an in-flight launch steers
	# toward an enemy that moved since the attack started.
	_push_head_launch_attack_aim()
	animator.update_from_player(delta, velocity, max_speed, last_facing_direction, rig.get_equipped_bone_defs())
	# Same frame as the request, so the head stays where the launch left it and the
	# capsule arrives underneath instead of the head snapping.
	if (
		animator.has_method("has_head_only_body_catch_up_request")
		and bool(animator.call("has_head_only_body_catch_up_request"))
		and animator.has_method("consume_head_only_body_catch_up_offset")
	):
		var catch_up_value: Variant = animator.call("consume_head_only_body_catch_up_offset")
		if catch_up_value is Vector3:
			_apply_head_only_lunge_displacement(catch_up_value)
	if (
		animator.has_method("has_torso_head_miss_detach_request")
		and bool(animator.call("has_torso_head_miss_detach_request"))
		and animator.has_method("consume_torso_head_miss_detach_offset")
	):
		var body_transform: Transform3D = Transform3D.IDENTITY
		var has_body_transform: bool = false
		if animator.has_method("get_torso_head_miss_detach_body_transform"):
			var body_transform_value: Variant = animator.call("get_torso_head_miss_detach_body_transform")
			if body_transform_value is Transform3D:
				body_transform = body_transform_value
				has_body_transform = true
		var detach_offset_value: Variant = animator.call("consume_torso_head_miss_detach_offset")
		if detach_offset_value is Vector3:
			_detach_head_from_torso_after_miss(detach_offset_value, body_transform, has_body_transform)
	_update_camera_animation_follow_offset()


# Brings the capsule to where the head-only lunge landed. Uses move_and_collide
# rather than writing global_position directly, so a lunge into a wall stops at
# the wall instead of tunnelling through it; the head lands short with the body.
func _apply_head_only_lunge_displacement(offset: Vector3) -> void:
	var flat := Vector3(offset.x, 0.0, offset.z)
	if flat.length() < 0.001:
		return
	move_and_collide(flat)


func _update_camera_animation_follow_offset() -> void:
	if camera_controller == null or animator == null:
		return
	var animation_offset := Vector3.ZERO
	if animator.has_method("get_head_launch_attack_world_offset"):
		var launch_offset_value: Variant = animator.call("get_head_launch_attack_world_offset")
		if launch_offset_value is Vector3:
			animation_offset = launch_offset_value
	elif animator.has_method("get_head_only_attack_world_offset"):
		var offset_value: Variant = animator.call("get_head_only_attack_world_offset")
		if offset_value is Vector3:
			animation_offset = offset_value
	elif animator.has_method("get_head_only_attack_forward_offset"):
		var forward_offset := float(animator.call("get_head_only_attack_forward_offset"))
		var follow_direction := last_facing_direction
		follow_direction.y = 0.0
		if follow_direction.length() < 0.01:
			follow_direction = _get_camera_forward_direction()
		follow_direction.y = 0.0
		if follow_direction.length() > 0.01:
			follow_direction = follow_direction.normalized()
		animation_offset = follow_direction * forward_offset
	if detached_camera_offset_carry_timer > 0.0:
		var carry_t: float = clampf(detached_camera_offset_carry_timer / 0.16, 0.0, 1.0)
		animation_offset = animation_offset.lerp(detached_camera_offset_carry, carry_t)
	if camera_controller.has_method("set_animation_follow_offset"):
		camera_controller.set_animation_follow_offset(animation_offset)


# Bone pickups call this when the player walks into them.
func collect_bone(bone_id: String) -> void:
	if inventory_component != null:
		inventory_component.collect_bone(bone_id)


# Kept so arena objects can still detect "this body is the player." With multi-slot
# equipping, trials should use has_bone_equipped() instead of a single active id.
func get_equipped_bone_id() -> String:
	if equipment_component == null:
		return ""
	return equipment_component.get_equipped_bone_id()


# True if the given bone is worn in ANY slot. Trials check this now.
func has_bone_equipped(bone_id: String) -> bool:
	return equipment_component != null and equipment_component.has_bone_equipped(bone_id)


# Tier 1F: the arena goal manager reads this to fill in the win screen.
func get_run_stats() -> Dictionary:
	if inventory_component == null:
		return {"collected": [], "swaps": 0}
	return inventory_component.get_run_stats()


func get_inventory_items() -> Array:
	if inventory_component == null:
		return []
	return inventory_component.get_inventory_items()


func get_equipment_state() -> Dictionary:
	if equipment_component == null:
		return {}
	return equipment_component.get_equipment_state()


func get_equipped_bone_for_slot(slot: String) -> String:
	if equipment_component == null:
		return ""
	return equipment_component.get_equipped_bone_for_slot(slot)


func get_inventory_stats_snapshot() -> Dictionary:
	return {
		"move_speed": move_speed,
		"attack_range": attack_range,
		"attack_damage": attack_damage,
		"health": health,
		"max_health": max_health,
	}


# Enemies call this when they land a contact hit on the player.
func take_player_damage(amount: int, from_position: Vector3 = Vector3.ZERO) -> void:
	if is_dead or invuln_timer > 0.0:
		return

	health = max(health - amount, 0)
	invuln_timer = damage_invuln_time
	_flash_player_damage()
	_update_health_ui()

	# Shove the player away from the attacker so a hit is felt.
	if from_position != Vector3.ZERO:
		var away := global_position - from_position
		away.y = 0.0
		if away.length() > 0.01:
			damage_knockback = away.normalized() * damage_knockback_strength

	if health <= 0:
		_die_player()


func take_player_body_part_damage(body_part: String, amount: int, from_position: Vector3 = Vector3.ZERO) -> void:
	take_player_damage(amount, from_position)


func has_body_part_hitboxes() -> bool:
	return rig != null and rig.has_method("has_body_part_hitboxes") and bool(rig.call("has_body_part_hitboxes"))


# Enemies check this so they stop attacking a dead player.
func is_player_dead() -> bool:
	return is_dead


# Enemies hear the player when their distance is <= this radius, so a BIGGER
# radius means louder. Sprinting used to return the SMALLER value, which made
# sprinting quieter than walking.
func get_noise_radius() -> float:
	if is_dead:
		return 0.0
	if noise_timer <= 0.0:
		return 0.0
	if sprinting_this_frame:
		return noise_radius_sprinting
	return noise_radius_normal


func _die_player() -> void:
	is_dead = true
	velocity = Vector3.ZERO
	_update_health_ui()
	_update_mouse_mode()
	GameEvents.player_died.emit(self)


# A quick red flash on the player body when hurt.
func _flash_player_damage() -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh == null:
		return

	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color(1.0, 0.25, 0.2)
	flash_material.emission_enabled = true
	flash_material.emission = Color(1.0, 0.1, 0.1)
	flash_material.emission_energy_multiplier = 0.7
	mesh.material_override = flash_material

	await get_tree().create_timer(0.14).timeout
	# Keep the red look if we died on this hit; otherwise restore.
	if is_instance_valid(mesh) and not is_dead:
		mesh.material_override = null


func _equip_next_bone() -> void:
	if inventory_component != null:
		inventory_component.equip_next_bone()


func equip_bone(bone_id: String) -> void:
	if equipment_component != null:
		equipment_component.equip_bone(bone_id)


func unequip_slot(slot: String) -> void:
	if equipment_component != null:
		equipment_component.unequip_slot(slot)


# Shows a bone's stats in the hover-info area (called by tiles/slots on mouse-over).
func show_bone_info(bone_id: String) -> void:
	if inventory_ui != null:
		inventory_ui.show_bone_info(bone_id)


func clear_bone_info() -> void:
	if inventory_ui != null:
		inventory_ui.clear_bone_info()


func get_equipment_socket_for_slot(slot: String) -> Node3D:
	match slot:
		"right_arm":
			return socket_arm_right
		"left_arm":
			return socket_arm_left
		"legs":
			return socket_legs
		"body":
			return socket_body
		"head":
			if rig != null:
				return rig.get_socket("head")
			return null
		_:
			return null


func recalculate_player_stats() -> void:
	_recalculate_stats()


func recalculate_inventory_stats() -> void:
	recalculate_player_stats()


# Recalculates gameplay stats by stacking every bone currently worn.
func _recalculate_stats() -> void:
	if stats_component == null:
		return
	var equipment_state: Dictionary = get_equipment_state()
	var calculated_stats: Dictionary = stats_component.calculate(equipment_state, health, max_health)
	move_speed = float(calculated_stats["move_speed"])
	attack_range = float(calculated_stats["attack_range"])
	attack_damage = int(calculated_stats["attack_damage"])
	max_health = int(calculated_stats["max_health"])
	health = int(calculated_stats["health"])
	if bow_equipped and not _can_use_bow():
		_cancel_bow_aim()
		bow_equipped = false
	if bow_visual != null:
		bow_visual.visible = bow_equipped
	_update_health_ui()


func _update_stealth_finish_prompt() -> void:
	stealth_target = _find_stealth_target()
	if stealth_target == null:
		_set_stealth_prompt("")
		return

	if stealth_target.has_method("get_stealth_prompt_text"):
		_set_stealth_prompt(str(stealth_target.call("get_stealth_prompt_text")))
	else:
		_set_stealth_prompt("F: Stealth finish")


func is_head_detached_from_torso() -> bool:
	return head_detached_from_torso


func _detach_head_from_torso_after_miss(detach_offset: Vector3, detached_body_transform: Transform3D = Transform3D.IDENTITY, use_detached_body_transform: bool = false) -> void:
	if head_detached_from_torso or equipment_component == null:
		return
	if not _is_torso_head_launch_combat_mode():
		return

	var body_bone_id: String = equipment_component.get_equipped_bone_for_slot("body")
	if body_bone_id == "":
		return

	var launch_offset := Vector3(detach_offset.x, 0.0, detach_offset.z)
	if launch_offset.length() <= 0.01:
		var fallback_direction := last_facing_direction
		fallback_direction.y = 0.0
		if fallback_direction.length() <= 0.01:
			fallback_direction = _get_camera_forward_direction()
		fallback_direction.y = 0.0
		if fallback_direction.length() > 0.01:
			launch_offset = fallback_direction.normalized() * detached_head_fallback_launch_distance

	detached_torso_bone_id = body_bone_id
	head_detached_from_torso = true
	detached_torso_reattach_progress = 0.0
	detached_camera_offset_carry = launch_offset
	detached_camera_offset_carry_timer = 0.16
	_spawn_detached_torso_marker(body_bone_id, detached_body_transform, use_detached_body_transform)
	equipment_component.unequip_slot("body")
	global_position += launch_offset
	if animator != null and animator.has_method("enter_detached_head_state"):
		var head_ground_position := _detached_head_ground_local_position(launch_offset)
		animator.call("enter_detached_head_state", head_ground_position, true)
	_set_stealth_prompt("Head detached. Hold E near your torso to reattach.")


func _detached_head_ground_local_position(launch_offset: Vector3) -> Vector3:
	if rig == null:
		return Vector3.ZERO
	var head_socket := rig.get_socket("head")
	if head_socket == null:
		return Vector3.ZERO
	var world_position := head_socket.global_position
	world_position.y = global_position.y + head_socket.position.y
	return rig.to_local(world_position - launch_offset)


func _spawn_detached_torso_marker(body_bone_id: String, detached_body_transform: Transform3D = Transform3D.IDENTITY, use_detached_body_transform: bool = false) -> void:
	_clear_detached_torso_marker()
	var marker := Node3D.new()
	marker.name = "DetachedTorsoMarker"
	var marker_position: Vector3 = global_position
	var marker_rotation: Vector3 = Vector3.ZERO
	var intended_marker_transform: Transform3D = Transform3D(Basis.IDENTITY, marker_position)
	if visual_root != null and rig != null:
		intended_marker_transform = visual_root.global_transform * Transform3D(Basis.IDENTITY, rig.position)
	elif rig != null and rig.has_method("get_socket"):
		var body_socket: Node3D = rig.get_socket("body")
		if body_socket != null:
			intended_marker_transform = body_socket.global_transform
	elif use_detached_body_transform:
		marker_position = detached_body_transform.origin
		marker_rotation = detached_body_transform.basis.get_euler()
		intended_marker_transform = Transform3D(Basis.from_euler(marker_rotation), marker_position)

	var definition: Dictionary = BoneRulesService.definition_for(body_bone_id)
	var color: Color = definition.get("color", Color(0.82, 0.92, 1.0, 1.0))
	var visual_scale: Vector3 = _as_vector3(definition.get("visual_scale", Vector3.ONE), Vector3.ONE)
	var mesh_size: Vector3 = Vector3(0.5, 0.7, 0.28) * visual_scale
	intended_marker_transform.origin = _grounded_detached_torso_marker_position(intended_marker_transform.origin, mesh_size.y)

	var mesh := BoxMesh.new()
	mesh.size = mesh_size
	var body_mesh := MeshInstance3D.new()
	body_mesh.name = "DetachedTorsoMesh"
	body_mesh.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.12
	body_mesh.material_override = material
	marker.add_child(body_mesh)

	var label := Label3D.new()
	label.name = "DetachedTorsoPrompt"
	label.text = "Hold E to reattach head"
	label.position = Vector3(0.0, 0.72, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.visible = false
	marker.add_child(label)

	get_tree().current_scene.add_child(marker)
	marker.global_transform = intended_marker_transform
	detached_torso_marker = marker


func _grounded_detached_torso_marker_position(anchor_position: Vector3, torso_height: float) -> Vector3:
	var grounded_position := anchor_position
	var world := get_world_3d()
	if world == null:
		return grounded_position

	var from: Vector3 = anchor_position + Vector3.UP * detached_torso_ground_probe_height
	var to: Vector3 = anchor_position - Vector3.UP * detached_torso_ground_probe_depth
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var exclude: Array[RID] = []
	var player_collision: CollisionObject3D = self as CollisionObject3D
	if player_collision != null:
		exclude.append(player_collision.get_rid())
	query.exclude = exclude

	var result: Dictionary = world.direct_space_state.intersect_ray(query)
	if result.has("position"):
		var position_value: Variant = result.get("position", anchor_position)
		if position_value is Vector3:
			var hit_position: Vector3 = position_value
			grounded_position.y = hit_position.y + maxf(torso_height * 0.5, 0.05)
	return grounded_position


func _update_detached_torso_reattach(delta: float) -> bool:
	if not head_detached_from_torso:
		return false
	if detached_torso_marker == null or not is_instance_valid(detached_torso_marker):
		_set_stealth_prompt("Find your torso to reattach.")
		return true

	var to_torso: Vector3 = detached_torso_marker.global_position - global_position
	to_torso.y = 0.0
	var in_range := to_torso.length() <= detached_head_reattach_range
	_set_detached_torso_marker_prompt_visible(in_range)
	if not in_range:
		if detached_torso_reattaching:
			_cancel_detached_torso_reattach_animation()
		detached_torso_reattach_progress = 0.0
		_set_stealth_prompt("Return to your torso to reattach your head.")
		return true

	var holding := _input_pressed("interact")
	detached_torso_reattach_progress = DropPickupRulesService.next_pickup_hold_progress(detached_torso_reattach_progress, delta, holding)
	if holding:
		if not detached_torso_reattaching:
			_begin_detached_torso_reattach_animation()
		_update_detached_torso_reattach_animation()
		var percent := int((detached_torso_reattach_progress / maxf(detached_head_reattach_hold_time, 0.01)) * 100.0)
		_set_stealth_prompt("Reattaching head... " + str(clampi(percent, 0, 100)) + "%")
		if DropPickupRulesService.pickup_hold_is_complete(detached_torso_reattach_progress, detached_head_reattach_hold_time):
			_finish_reattach_head_to_detached_torso()
	else:
		if detached_torso_reattaching:
			_cancel_detached_torso_reattach_animation()
		_set_detached_torso_marker_prompt_visible(true)
		_set_stealth_prompt("Hold E to reattach your head.")
	return true


func _begin_detached_torso_reattach_animation() -> void:
	if not head_detached_from_torso or equipment_component == null:
		return
	if detached_torso_reattaching:
		return
	detached_torso_reattaching = true
	_set_detached_torso_marker_prompt_visible(false)
	_set_stealth_prompt("Reattaching head...")

	var head_world_position: Vector3 = _current_head_world_position()
	if animator != null and animator.has_method("enter_detached_head_state") and rig != null:
		animator.call("enter_detached_head_state", rig.to_local(head_world_position), true)
	_update_detached_torso_reattach_animation()


func _update_detached_torso_reattach_animation() -> void:
	if animator != null and animator.has_method("start_detached_head_reattach_tornado") and detached_torso_marker != null and is_instance_valid(detached_torso_marker):
		var body_world_position: Vector3 = detached_torso_marker.global_position
		var body_world_rotation: Vector3 = detached_torso_marker.global_rotation
		var target_world_position: Vector3 = body_world_position + (detached_torso_marker.global_transform.basis * _detached_torso_head_attach_offset())
		var progress_ratio: float = detached_torso_reattach_progress / maxf(detached_head_reattach_hold_time, 0.01)
		if animator.has_method("set_detached_head_reattach_tornado_progress"):
			animator.call("set_detached_head_reattach_tornado_progress", progress_ratio, body_world_position, target_world_position, body_world_rotation)
		else:
			animator.call("start_detached_head_reattach_tornado", body_world_position, target_world_position, body_world_rotation)


func _cancel_detached_torso_reattach_animation() -> void:
	if animator != null and animator.has_method("cancel_detached_head_reattach_tornado_to_ground"):
		animator.call("cancel_detached_head_reattach_tornado_to_ground")
	detached_torso_reattach_progress = 0.0
	detached_torso_reattaching = false


func _finish_reattach_head_to_detached_torso() -> void:
	if not head_detached_from_torso or equipment_component == null:
		return
	_update_detached_torso_reattach_animation()
	var head_world_position: Vector3 = _current_head_world_position()
	_align_player_body_pose_to_detached_torso_marker()
	if animator != null and animator.has_method("enter_detached_head_state") and rig != null:
		animator.call("enter_detached_head_state", rig.to_local(head_world_position), true)
	_update_detached_torso_reattach_animation()
	if detached_torso_bone_id != "":
		if equipment_component.has_method("restore_detached_body"):
			equipment_component.call("restore_detached_body", detached_torso_bone_id)
		else:
			equipment_component.equip_bone(detached_torso_bone_id)
	_update_detached_torso_reattach_animation()
	if animator != null and animator.has_method("play_detached_head_reattach_finish_blend"):
		animator.call("play_detached_head_reattach_finish_blend")
	head_detached_from_torso = false
	detached_torso_bone_id = ""
	detached_torso_reattach_progress = 0.0
	detached_torso_reattaching = false
	_clear_detached_torso_marker()
	_set_stealth_prompt("")


func _current_head_world_position() -> Vector3:
	if rig != null and rig.has_method("get_socket"):
		var head_socket: Node3D = rig.get_socket("head")
		if head_socket != null:
			return head_socket.global_position
	return global_position


func _align_player_body_pose_to_detached_torso_marker() -> void:
	if detached_torso_marker == null or not is_instance_valid(detached_torso_marker):
		return
	if rig == null:
		return

	if visual_root != null:
		var root_rotation: Vector3 = visual_root.global_rotation
		root_rotation.y = detached_torso_marker.global_rotation.y
		visual_root.global_rotation = root_rotation

	var marker_facing: Vector3 = detached_torso_marker.global_transform.basis.z
	marker_facing.y = 0.0
	if marker_facing.length() > 0.01:
		last_facing_direction = marker_facing.normalized()

	var stable_body_local_position := Vector3.ZERO
	if animator != null and animator.has_method("get_stable_body_attach_local_position"):
		var stable_value: Variant = animator.call("get_stable_body_attach_local_position")
		if stable_value is Vector3:
			stable_body_local_position = stable_value
	elif rig.has_method("get_socket"):
		var body_socket: Node3D = rig.get_socket("body")
		if body_socket != null:
			stable_body_local_position = body_socket.position

	var stable_body_world_position: Vector3 = rig.to_global(stable_body_local_position)
	var delta: Vector3 = detached_torso_marker.global_position - stable_body_world_position
	delta.y = 0.0
	global_position += delta


func _detached_torso_head_attach_offset() -> Vector3:
	var fallback := Vector3(0.0, 0.42, 0.0)
	if detached_torso_bone_id == "":
		return fallback
	var definition: Dictionary = BoneRulesService.definition_for(detached_torso_bone_id)
	return _as_vector3(definition.get("head_socket_offset", definition.get("head_origin_offset", fallback)), fallback)


func _clear_detached_torso_marker() -> void:
	if detached_torso_marker != null and is_instance_valid(detached_torso_marker):
		detached_torso_marker.queue_free()
	detached_torso_marker = null


func _set_detached_torso_marker_prompt_visible(is_visible: bool) -> void:
	if detached_torso_marker == null or not is_instance_valid(detached_torso_marker):
		return
	var label := detached_torso_marker.get_node_or_null("DetachedTorsoPrompt") as Label3D
	if label != null:
		label.visible = is_visible


func _as_vector3(value: Variant, fallback: Vector3) -> Vector3:
	if value is Vector3:
		var vector_value: Vector3 = value
		return vector_value
	return fallback


func _find_stealth_target() -> Node3D:
	var best: Node3D = null
	var best_distance := stealth_prompt_scan_range
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_body := enemy as Node3D
		if enemy_body == null or not enemy_body.has_method("can_be_stealth_finished_by"):
			continue
		if not enemy_body.call("can_be_stealth_finished_by", self):
			continue

		var to_enemy := enemy_body.global_position - global_position
		to_enemy.y = 0.0
		var distance := to_enemy.length()
		if distance > best_distance:
			continue

		best = enemy_body
		best_distance = distance
	return best


func enter_interact_range() -> void:
	nearby_bone_pickups += 1


func exit_interact_range() -> void:
	nearby_bone_pickups = max(nearby_bone_pickups - 1, 0)


# Bone pickups use the older method names; keep them as wrappers so current
# pickup scenes and new camp chests share the same E-key reservation.
func enter_bone_pickup_range() -> void:
	enter_interact_range()


func exit_bone_pickup_range() -> void:
	exit_interact_range()


func get_inventory_tile_size() -> Vector2:
	if inventory_ui != null:
		return inventory_ui.get_inventory_tile_size()
	return Vector2(96, 86)


# An always-visible health readout in the top-right corner.
func _build_health_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HealthCanvas"
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "HealthPanel"
	panel.position = Vector2(1040, 24)
	panel.custom_minimum_size = Vector2(200, 0)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	health_hud_label = Label.new()
	health_hud_label.name = "HealthLabel"
	health_hud_label.add_theme_font_size_override("font_size", 20)
	margin.add_child(health_hud_label)
	_update_health_ui()


func _update_health_ui() -> void:
	if health_hud_label == null:
		return

	if is_dead:
		health_hud_label.text = "HP: 0 / %d  (dead)" % max_health
	else:
		health_hud_label.text = "HP: %d / %d" % [health, max_health]


func _build_stealth_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "StealthCanvas"
	canvas.layer = 7
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "StealthPromptPanel"
	panel.position = Vector2(430, 590)
	panel.custom_minimum_size = Vector2(420, 0)
	panel.visible = false
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	stealth_prompt_label = Label.new()
	stealth_prompt_label.name = "StealthPromptLabel"
	stealth_prompt_label.add_theme_font_size_override("font_size", 20)
	stealth_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(stealth_prompt_label)


func _set_stealth_prompt(text: String) -> void:
	if stealth_prompt_label == null:
		return

	var panel := stealth_prompt_label.get_parent().get_parent() as Control
	if panel == null:
		return

	stealth_prompt_label.text = text
	panel.visible = text != ""


# Shows or hides the inventory screen — and pauses the whole game while it is open.
func _toggle_inventory() -> void:
	inventory_open = not inventory_open
	if inventory_ui != null:
		inventory_ui.set_open(inventory_open)
	GameEvents.inventory_open_changed.emit(self, inventory_open)
	get_tree().paused = inventory_open
	_update_mouse_mode()


func _update_mouse_mode() -> void:
	if camera_controller == null:
		return
	camera_controller.set_look_enabled(not inventory_open and not is_dead)


# Tier 1E: bone names, colors, stat bonuses, and effect text used to live here as
# a stack of match statements. They now live in one shared table that every script
# reads from: scripts/bone_database.gd.
