extends CharacterBody3D

# preload loads the Bone scene once so this enemy can create one instantly when it dies.
const BONE_SCENE: PackedScene = preload("res://scenes/bone.tscn")
const LIMB_BONE_PICKUP_SCRIPT: Script = preload("res://scripts/limb_bone_pickup.gd")
const ROCK_PROJECTILE_SCRIPT: Script = preload("res://scripts/enemy_rock_projectile.gd")
const ARROW_PROJECTILE_SCRIPT: Script = preload("res://scripts/arrow_projectile.gd")

# --- Combat / AI tuning (all editable per-enemy in the Inspector) -------------
@export var max_health: int = 3
@export var move_speed: float = 3.0          # slower than the player, so you can kite
@export var detection_range: float = 11.0    # how close before it starts chasing
@export_range(20.0, 180.0, 1.0) var vision_angle_degrees: float = 90.0
@export var use_line_of_sight: bool = true
@export var vision_check_interval: float = 0.15
@export_range(6, 24, 1) var vision_cone_segments: int = 12
@export var attack_range: float = 1.7        # how close before it can hit you
@export var contact_damage: int = 1
@export var attack_cooldown: float = 1.1      # seconds between its hits
@export var search_duration: float = 20.0
@export var search_stop_distance: float = 0.75
@export var search_turn_speed: float = 0.9
@export var search_rotation_smoothing: float = 5.0
@export_range(10.0, 120.0, 1.0) var search_sweep_angle_degrees: float = 28.0
@export var arrow_hit_search_duration: float = 20.0
@export var idle_wander_enabled: bool = true
@export var idle_wander_radius: float = 2.8
@export var idle_wander_interval: float = 2.4
@export var hearing_investigation_time: float = 5.0
@export var ally_alert_range: float = 7.0
@export_group("Ranged Enemy")
@export var ranged_attacker_enabled: bool = false
@export var ranged_attack_min_range: float = 3.2
@export var ranged_attack_range: float = 13.0
@export var ranged_attack_cooldown: float = 2.2
@export var ranged_attack_windup: float = 0.35
@export var ranged_arrow_damage: int = 1
@export var ranged_arrow_speed: float = 13.0
@export var ranged_arrow_gravity: float = 5.0
@export_group("")
@export_range(0.0, 1.0, 0.05) var low_health_flee_chance: float = 0.45
@export_range(0.05, 0.75, 0.05) var low_health_flee_ratio: float = 0.35
@export var low_health_flee_duration: float = 4.0
@export var flee_speed_multiplier: float = 1.35
@export var flee_recover_distance: float = 8.0
@export_range(0.1, 1.0, 0.05) var crawl_speed_multiplier: float = 0.38
@export_group("Gorilla Profile")
@export_enum("Auto", "Always", "Never") var gorilla_profile_mode: String = "Auto"
@export var gorilla_profile_min_health: int = 5
@export var gorilla_profile_min_damage: int = 2
@export_range(0.3, 1.0, 0.05) var gorilla_move_speed_multiplier: float = 0.68
@export_range(1.0, 2.5, 0.05) var gorilla_attack_cooldown_multiplier: float = 1.25
@export var gorilla_health_bonus: int = 2
@export var gorilla_damage_bonus: int = 1
@export var gorilla_attack_range_bonus: float = 0.25
@export var gorilla_knockback_bonus: float = 1.5
@export var gorilla_can_throw_rocks: bool = true
@export var gorilla_rock_throw_min_range: float = 3.0
@export var gorilla_rock_throw_range: float = 10.0
@export var gorilla_rock_throw_cooldown: float = 3.5
@export var gorilla_rock_throw_windup: float = 0.55
@export var gorilla_rock_throw_speed: float = 10.5
@export var gorilla_rock_throw_upward_boost: float = 2.6
@export var gorilla_rock_gravity: float = 24.0
@export var gorilla_rock_damage: int = 1
@export_group("")
@export_group("Bone Recovery")
@export var bone_recovery_enabled: bool = true
@export var bone_recovery_safe_delay: float = 10.0
@export var bone_recovery_pickup_range: float = 1.15
@export var bone_recovery_heal_per_part: int = 1
@export var bone_recovery_move_speed_multiplier: float = 0.65
@export var bone_recovery_safe_range: float = 0.0
@export var bone_recovery_part_lifetime: float = 45.0
@export_group("")
@export var return_home_stop_distance: float = 0.8
@export var obstacle_probe_distance: float = 1.25
@export_range(15.0, 85.0, 1.0) var obstacle_side_probe_angle_degrees: float = 48.0
@export var obstacle_avoidance_hold_time: float = 0.65
@export var gravity: float = 24.0
@export var knockback_strength: float = 6.0   # how hard OUR hit shoves it back
@export var limb_detach_impulse: float = 4.5
@export var detached_limb_lifetime: float = 8.0
@export var death_limb_fall_spacing: float = 0.06
@export_range(0.0, 1.0, 0.05) var limb_pickup_drop_chance: float = 0.35
@export_range(3, 8, 1) var target_limb_loss_steps: int = 5
@export var guarantee_limb_pickup_on_death: bool = true
@export var stealth_finish_max_health: int = 3
@export var stealth_finish_range: float = 2.2
@export_range(0.0, 1.0, 0.05) var stealth_behind_dot: float = 0.45
@export var failed_stealth_damage_multiplier: int = 2
@export var respawn_enabled: bool = true
@export var near_respawn_delay: float = 120.0
@export var far_respawn_delay: float = 30.0
@export var near_respawn_distance: float = 18.0
@export var respawn_visibility_check_interval: float = 1.0

# This is the pickup label the player receives after collecting the dropped bone.
@export var dropped_bone_id: String = "dummy_bone"

# The enemy starts alive.
var alive: bool = true
var health: int = 0
var attack_timer: float = 0.0                 # counts down; can attack when <= 0
var hit_flash_time_remaining: float = 0.0
var knockback_velocity: Vector3 = Vector3.ZERO
var enemy_material: StandardMaterial3D = null
var vision_material: StandardMaterial3D = null
var normal_color: Color = Color(0.85, 0.18, 0.16, 1)
var facing_direction: Vector3 = Vector3.BACK
var player_visible: bool = false
var vision_check_timer: float = 0.0
var cached_player: Node3D = null
var search_timer: float = 0.0
var search_look_time: float = 0.0
var returning_to_spawn: bool = false
var avoidance_timer: float = 0.0
var avoidance_direction: Vector3 = Vector3.ZERO
var idle_wander_timer: float = 0.0
var idle_wander_target: Vector3 = Vector3.ZERO
var fleeing_timer: float = 0.0
var flees_when_low_health: bool = false
var has_fled_low_health: bool = false
var last_known_player_position: Vector3 = Vector3.ZERO
var spawn_transform: Transform3D
var spawn_scale: Vector3 = Vector3.ONE
var spawn_facing_direction: Vector3 = Vector3.BACK
var detached_limb_keys: Array[String] = []
var last_hit_from_position: Vector3 = Vector3.ZERO
var limb_pickup_spawned: bool = false
var crawling_due_to_leg_loss: bool = false
var gorilla_profile_active: bool = false
var rock_throw_timer: float = 0.0
var rock_throw_windup_timer: float = 0.0
var rock_throw_target_position: Vector3 = Vector3.ZERO
var held_rock_visual: MeshInstance3D = null
var ranged_attack_timer: float = 0.0
var ranged_attack_windup_timer: float = 0.0
var ranged_attack_target_position: Vector3 = Vector3.ZERO
var ranged_bow_visual: Node3D = null
var bone_recovery_safe_timer: float = 0.0
var recovering_limb_key: String = ""
var detached_limb_bodies: Dictionary = {}
var limb_detach_damage_progress: float = 0.0

# Tier 1D polish: one reusable tween so hit-squash, attack-lunge, and death-pop
# never fight over the scale, plus a procedurally built placeholder "hit" sound.
var _scale_tween: Tween = null
var _hit_sound: AudioStreamWAV = null

const HIT_COLOR: Color = Color(1, 0.95, 0.45, 1)
const DETACHABLE_LIMBS: Array[String] = ["right_arm", "left_arm", "right_leg", "left_leg", "body", "head"]
const PICKUP_ELIGIBLE_LIMBS: Array[String] = ["right_arm", "left_arm", "right_leg", "left_leg", "body"]
const CORE_FALL_ORDER: Array[String] = ["body", "head"]

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var health_label: Label3D = $HealthLabel
@onready var vision_mesh: MeshInstance3D = $VisionMesh
@onready var visual_root: Node3D = $VisualRoot
@onready var rig: ModularSkeletonRig = $VisualRoot/ModularSkeletonRig
@onready var animator: ProceduralPlayerAnimator = $VisualRoot/ProceduralAnimator


# _ready runs once when this enemy enters the running scene.
func _ready() -> void:
	# Groups let other scripts find this enemy without needing an exact node path.
	add_to_group("enemies")
	spawn_transform = global_transform
	spawn_scale = scale
	spawn_facing_direction = _facing_from_rotation()
	facing_direction = spawn_facing_direction
	_apply_bone_identity()
	_apply_gorilla_profile()
	health = max_health
	_roll_low_health_personality()
	idle_wander_target = spawn_transform.origin
	idle_wander_timer = randf_range(0.2, idle_wander_interval)

	# Duplicate the material so this enemy can flash without changing every enemy at once.
	var raw_material := mesh_instance.get_surface_override_material(0)
	if raw_material != null:
		enemy_material = raw_material.duplicate() as StandardMaterial3D
	if enemy_material == null:
		enemy_material = StandardMaterial3D.new()
	mesh_instance.set_surface_override_material(0, enemy_material)
	_setup_procedural_character()

	# Preview the dropped bone's color. Unknown drops fall back to the enemy's red.
	normal_color = BoneRulesService.color_for(dropped_bone_id, Color(0.85, 0.18, 0.16, 1.0))
	_set_enemy_color(normal_color)
	_update_health_label()
	_build_vision_cone()
	_set_player_visible(false, true)
	vision_check_timer = fposmod(float(get_instance_id()) * 0.017, maxf(0.01, vision_check_interval))

	# Build the placeholder hit sound once, up front.
	_hit_sound = _make_hit_blip()


# _process runs every rendered frame. Here it only handles the short color flash.
func _process(delta: float) -> void:
	if hit_flash_time_remaining <= 0.0:
		return

	hit_flash_time_remaining -= delta
	if hit_flash_time_remaining <= 0.0 and alive:
		_set_enemy_color(normal_color)


# _physics_process drives movement, chasing, and attacking on the physics clock.
func _physics_process(delta: float) -> void:
	# Gravity keeps the box resting on the ground instead of floating.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Knockback from being hit fades out over a moment.
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_strength * 4.0 * delta)

	# While dying, stop hunting but still settle under gravity + any leftover shove.
	if not alive:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		move_and_slide()
		return

	if attack_timer > 0.0:
		attack_timer -= delta
	if rock_throw_timer > 0.0:
		rock_throw_timer = maxf(rock_throw_timer - delta, 0.0)
	if ranged_attack_timer > 0.0:
		ranged_attack_timer = maxf(ranged_attack_timer - delta, 0.0)

	if vision_check_timer > 0.0:
		vision_check_timer -= delta
	if avoidance_timer > 0.0:
		avoidance_timer = maxf(avoidance_timer - delta, 0.0)
	var was_fleeing := fleeing_timer > 0.0
	if fleeing_timer > 0.0:
		fleeing_timer = maxf(fleeing_timer - delta, 0.0)
	if was_fleeing and fleeing_timer <= 0.0:
		_update_health_label()
	var was_searching := search_timer > 0.0
	if search_timer > 0.0:
		search_timer = maxf(search_timer - delta, 0.0)
		search_look_time += delta
	if was_searching and search_timer <= 0.0:
		returning_to_spawn = true

	# Decide where to move this frame.
	var move := Vector3.ZERO
	var effective_move_speed: float = _get_effective_move_speed()
	var player := _get_player()
	if player != null and not _player_is_dead(player):
		var to_player: Vector3 = player.global_position - global_position
		to_player.y = 0.0
		var dist := to_player.length()

		if dist > detection_range or dist <= 0.01:
			_set_player_visible(false)
			vision_check_timer = 0.0
		elif vision_check_timer <= 0.0:
			vision_check_timer = maxf(0.01, vision_check_interval)
			var can_see := _can_see_player(player, to_player, dist)
			if can_see and not player_visible:
				_alert_nearby_allies(player.global_position)
			_set_player_visible(can_see)

		if not player_visible and _can_hear_player(player, dist):
			_investigate_position(player.global_position, hearing_investigation_time)

		_update_bone_recovery_safety(delta, player, dist)

		if player_visible and dist > 0.01:
			last_known_player_position = player.global_position
			search_timer = search_duration
			search_look_time = 0.0
			returning_to_spawn = false
			_turn_toward(to_player.normalized())

		if ranged_attack_windup_timer > 0.0:
			_update_ranged_attack_windup(delta, player)
		elif rock_throw_windup_timer > 0.0:
			_update_rock_throw_windup(delta, player)
		elif fleeing_timer > 0.0:
			move = _get_flee_move(player, dist)
		elif player_visible and dist <= attack_range:
			# Close enough to strike: hold position and attack on cooldown.
			_try_attack_player(player)
		elif _can_start_rock_throw(player, dist):
			_start_rock_throw(player)
		elif _can_start_ranged_attack(player, dist):
			_start_ranged_attack(player)
		elif _can_recover_bone_part():
			move = _get_bone_recovery_move()
		elif player_visible and dist <= detection_range and dist > 0.01:
			# Chase: move toward the player, but steer around blocking walls.
			move = _steer_around_obstacles(to_player.normalized()) * effective_move_speed
		elif search_timer > 0.0:
			move = _get_search_move(delta)
		elif returning_to_spawn:
			move = _get_return_home_move()
		elif idle_wander_enabled:
			move = _get_idle_wander_move(delta)
	else:
		_set_player_visible(false)
		search_timer = 0.0
		ranged_attack_windup_timer = 0.0
		rock_throw_windup_timer = 0.0
		_cancel_held_rock()
		_update_bone_recovery_safety(delta, null, INF)
		if _can_recover_bone_part():
			move = _get_bone_recovery_move()
		elif idle_wander_enabled:
			move = _get_idle_wander_move(delta)

	velocity.x = move.x + knockback_velocity.x
	velocity.z = move.z + knockback_velocity.z
	move_and_slide()
	_update_procedural_animation(delta)


# Finds the player node (added to the "player" group in player.gd).
func _get_player() -> Node3D:
	if is_instance_valid(cached_player):
		return cached_player

	cached_player = get_tree().get_first_node_in_group("player") as Node3D
	return cached_player


func _player_is_dead(player: Node) -> bool:
	return player.has_method("is_player_dead") and player.is_player_dead()


# Damages the player when in range, on a cooldown, with a quick "chomp" tell.
func _try_attack_player(player: Node) -> void:
	if attack_timer > 0.0:
		return

	attack_timer = attack_cooldown
	_lunge()
	if animator != null:
		animator.trigger_attack()
	if player.has_method("take_player_damage"):
		player.take_player_damage(contact_damage, global_position)


func _can_start_ranged_attack(player: Node3D, distance_to_player: float) -> bool:
	if not ranged_attacker_enabled:
		return false
	if player == null or not player_visible:
		return false
	if ranged_attack_timer > 0.0 or ranged_attack_windup_timer > 0.0:
		return false
	if distance_to_player < ranged_attack_min_range or distance_to_player > ranged_attack_range:
		return false
	if detached_limb_keys.has("right_arm") and detached_limb_keys.has("left_arm"):
		return false
	return true


func _start_ranged_attack(player: Node3D) -> void:
	ranged_attack_timer = ranged_attack_cooldown
	ranged_attack_windup_timer = ranged_attack_windup
	ranged_attack_target_position = player.global_position
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > 0.01:
		_turn_toward(to_player.normalized())


func _update_ranged_attack_windup(delta: float, player: Node3D) -> void:
	if player != null and not _player_is_dead(player):
		ranged_attack_target_position = player.global_position
		var to_player: Vector3 = player.global_position - global_position
		to_player.y = 0.0
		if to_player.length() > 0.01:
			_turn_toward(to_player.normalized())

	ranged_attack_windup_timer = maxf(ranged_attack_windup_timer - delta, 0.0)
	if ranged_attack_windup_timer <= 0.0:
		_fire_enemy_arrow()


func _fire_enemy_arrow() -> void:
	var world: Node = get_parent()
	if world == null:
		return

	var start_position: Vector3 = global_position + Vector3.UP * 0.85 + facing_direction.normalized() * 0.55
	var target_position: Vector3 = ranged_attack_target_position + Vector3.UP * 0.65
	var to_target: Vector3 = target_position - start_position
	var horizontal: Vector3 = Vector3(to_target.x, 0.0, to_target.z)
	if horizontal.length() < 0.1:
		return

	var travel_time: float = horizontal.length() / maxf(ranged_arrow_speed, 0.1)
	var launch_velocity: Vector3 = horizontal.normalized() * ranged_arrow_speed
	launch_velocity.y = (to_target.y / maxf(travel_time, 0.1)) + (ranged_arrow_gravity * 0.5 * travel_time)

	var arrow: Area3D = ARROW_PROJECTILE_SCRIPT.new() as Area3D
	if arrow == null:
		return
	if arrow.has_method("configure"):
		arrow.call("configure", start_position, launch_velocity, ranged_arrow_damage, self, true, ranged_arrow_gravity)
	world.add_child(arrow)


func _can_start_rock_throw(player: Node3D, distance_to_player: float) -> bool:
	if not gorilla_profile_active or not gorilla_can_throw_rocks:
		return false
	if player == null or not player_visible:
		return false
	if rock_throw_timer > 0.0 or rock_throw_windup_timer > 0.0:
		return false
	if distance_to_player < gorilla_rock_throw_min_range or distance_to_player > gorilla_rock_throw_range:
		return false
	if detached_limb_keys.has("right_arm") and detached_limb_keys.has("left_arm"):
		return false
	return true


func _start_rock_throw(player: Node3D) -> void:
	rock_throw_timer = gorilla_rock_throw_cooldown
	rock_throw_windup_timer = gorilla_rock_throw_windup
	rock_throw_target_position = player.global_position
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > 0.01:
		_turn_toward(to_player.normalized())
	_show_held_rock()


func _update_rock_throw_windup(delta: float, player: Node3D) -> void:
	if player != null and not _player_is_dead(player):
		rock_throw_target_position = player.global_position
		var to_player: Vector3 = player.global_position - global_position
		to_player.y = 0.0
		if to_player.length() > 0.01:
			_turn_toward(to_player.normalized())

	rock_throw_windup_timer = maxf(rock_throw_windup_timer - delta, 0.0)
	if rock_throw_windup_timer <= 0.0:
		_throw_held_rock()


func _throw_held_rock() -> void:
	var world: Node = get_parent()
	if world == null:
		_cancel_held_rock()
		return

	var start_position: Vector3 = _get_held_rock_world_position()
	_cancel_held_rock()

	var target_position: Vector3 = rock_throw_target_position + Vector3.UP * 0.65
	var to_target: Vector3 = target_position - start_position
	var horizontal: Vector3 = Vector3(to_target.x, 0.0, to_target.z)
	if horizontal.length() < 0.1:
		return

	var travel_time: float = horizontal.length() / maxf(gorilla_rock_throw_speed, 0.1)
	var launch_velocity: Vector3 = horizontal.normalized() * gorilla_rock_throw_speed
	launch_velocity.y = (to_target.y / maxf(travel_time, 0.1)) + gorilla_rock_throw_upward_boost + (gorilla_rock_gravity * 0.5 * travel_time)

	var rock: Area3D = ROCK_PROJECTILE_SCRIPT.new() as Area3D
	if rock == null:
		return
	if rock.has_method("configure"):
		rock.call("configure", start_position, launch_velocity, maxi(gorilla_rock_damage, contact_damage), self, gorilla_rock_gravity)
	world.add_child(rock)


func _show_held_rock() -> void:
	_cancel_held_rock()
	held_rock_visual = MeshInstance3D.new()
	held_rock_visual.name = "HeldRock"
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.36
	held_rock_visual.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.32, 0.28, 0.24, 1.0)
	material.roughness = 0.9
	held_rock_visual.material_override = material

	var socket: Node3D = _get_rock_throw_socket()
	if socket != null:
		socket.add_child(held_rock_visual)
		held_rock_visual.position = Vector3(0.0, -0.18, 0.18)
	else:
		add_child(held_rock_visual)
		held_rock_visual.position = Vector3(0.35, 0.9, 0.15)


func _cancel_held_rock() -> void:
	if held_rock_visual != null and is_instance_valid(held_rock_visual):
		held_rock_visual.queue_free()
	held_rock_visual = null


func _get_held_rock_world_position() -> Vector3:
	if held_rock_visual != null and is_instance_valid(held_rock_visual):
		return held_rock_visual.global_position
	return global_position + Vector3.UP * 0.8 + facing_direction.normalized() * 0.35


func _get_rock_throw_socket() -> Node3D:
	if rig == null:
		return null
	if not detached_limb_keys.has("right_arm"):
		return rig.get_socket("right_arm")
	if not detached_limb_keys.has("left_arm"):
		return rig.get_socket("left_arm")
	return null


func can_be_stealth_finished_by(player: Node3D) -> bool:
	if not alive or player == null:
		return false
	if returning_to_spawn:
		return false
	if global_position.distance_to(player.global_position) > stealth_finish_range:
		return false
	return _is_player_behind(player)


func get_stealth_prompt_text() -> String:
	var bone_name: String = BoneRulesService.display_name_with_slot(dropped_bone_id)
	if health <= stealth_finish_max_health:
		return "F: Finish " + bone_name + " enemy"
	return "F: Ambush " + bone_name + " enemy"


func get_drop_display_name() -> String:
	return BoneRulesService.display_name_with_slot(dropped_bone_id)


func _is_player_behind(player: Node3D) -> bool:
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() <= 0.01:
		return false

	var enemy_forward := facing_direction
	enemy_forward.y = 0.0
	if enemy_forward.length() <= 0.01:
		enemy_forward = _facing_from_rotation()

	return enemy_forward.normalized().dot(to_player.normalized()) <= -stealth_behind_dot


func try_stealth_finish(player: Node3D, player_damage: int, hit_from: Vector3) -> bool:
	if not can_be_stealth_finished_by(player):
		return false

	last_hit_from_position = hit_from
	if health <= stealth_finish_max_health:
		health = 0
		_update_health_label()
		_play_hit_sound()
		die()
		return true

	var ambush_damage := maxi(player_damage * failed_stealth_damage_multiplier, player_damage + 1)
	_apply_knockback(hit_from)
	take_hit(ambush_damage)
	if alive:
		last_known_player_position = player.global_position
		search_timer = search_duration
		search_look_time = 0.0
		returning_to_spawn = false
		_set_player_visible(true)
		_turn_toward((player.global_position - global_position).normalized())
		attack_timer = 0.0
		_try_attack_player(player)
	return false


# Vision check: player must be inside the enemy's cone, inside detection range,
# and not hidden behind world collision if line of sight is enabled.
func _can_see_player(player: Node3D, to_player: Vector3, dist: float) -> bool:
	if dist > detection_range or dist <= 0.01:
		return false

	var direction_to_player := to_player.normalized()
	var half_angle := deg_to_rad(vision_angle_degrees * 0.5)
	var minimum_dot := cos(half_angle)
	if facing_direction.normalized().dot(direction_to_player) < minimum_dot:
		return false

	if not use_line_of_sight:
		return true

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.65,
		player.global_position + Vector3.UP * 0.65
	)
	query.exclude = [get_rid()]
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true

	return result.get("collider") == player


func _can_hear_player(player: Node, dist: float) -> bool:
	if player_visible or search_timer > 0.0:
		return false
	if not player.has_method("get_noise_radius"):
		return false

	var noise_radius := float(player.call("get_noise_radius"))
	return noise_radius > 0.0 and dist <= noise_radius


func _investigate_position(position: Vector3, duration: float) -> void:
	last_known_player_position = position
	search_timer = maxf(search_timer, duration)
	search_look_time = 0.0
	returning_to_spawn = false


func receive_alert(position: Vector3) -> void:
	if not alive or player_visible:
		return
	_investigate_position(position, hearing_investigation_time)


func _alert_nearby_allies(position: Vector3) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self or not enemy.has_method("receive_alert"):
			continue
		var enemy_body := enemy as Node3D
		if enemy_body == null:
			continue
		if global_position.distance_to(enemy_body.global_position) <= ally_alert_range:
			enemy.call("receive_alert", position)


# Face the enemy and its visual cone toward the active direction.
func _turn_toward(direction: Vector3) -> void:
	if direction.length() <= 0.01:
		return

	facing_direction = direction.normalized()
	rotation.y = atan2(facing_direction.x, facing_direction.z)


# Builds a flat triangular fan that previews the enemy's vision field.
func _build_vision_cone() -> void:
	if vision_mesh == null:
		return

	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var local_ground_y := -0.55
	var half_angle := deg_to_rad(vision_angle_degrees * 0.5)
	var segments := maxi(6, vision_cone_segments)

	for i in range(segments):
		var a0 := -half_angle + (float(i) / float(segments)) * vision_angle_degrees * PI / 180.0
		var a1 := -half_angle + (float(i + 1) / float(segments)) * vision_angle_degrees * PI / 180.0
		vertices.append(Vector3(0.0, local_ground_y, 0.0))
		vertices.append(Vector3(sin(a0) * detection_range, local_ground_y, cos(a0) * detection_range))
		vertices.append(Vector3(sin(a1) * detection_range, local_ground_y, cos(a1) * detection_range))

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	vision_mesh.mesh = mesh

	vision_material = StandardMaterial3D.new()
	vision_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vision_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	vision_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	vision_mesh.set_surface_override_material(0, vision_material)


func _set_player_visible(new_value: bool, force_visual: bool = false) -> void:
	if player_visible == new_value and not force_visual:
		return

	var was_visible := player_visible
	player_visible = new_value
	if was_visible and not player_visible:
		search_timer = search_duration
		search_look_time = 0.0
		returning_to_spawn = false
	_update_vision_visual(player_visible)


func _get_search_move(delta: float) -> Vector3:
	var to_last_known := last_known_player_position - global_position
	to_last_known.y = 0.0
	var distance := to_last_known.length()
	if distance <= search_stop_distance:
		_scan_while_searching(facing_direction, delta)
		return Vector3.ZERO

	var direction := to_last_known.normalized()
	var move_direction := _steer_around_obstacles(direction)
	_scan_while_searching(move_direction, delta)
	return move_direction * _get_effective_move_speed()


func _scan_while_searching(base_direction: Vector3, delta: float) -> void:
	if base_direction.length() <= 0.01:
		base_direction = _facing_from_rotation()

	var base_yaw := atan2(base_direction.x, base_direction.z)
	var sweep := sin(search_look_time * search_turn_speed) * deg_to_rad(search_sweep_angle_degrees)
	var target_yaw := base_yaw + sweep
	var turn_weight := 1.0 - exp(-search_rotation_smoothing * delta)
	rotation.y = lerp_angle(rotation.y, target_yaw, turn_weight)
	facing_direction = _facing_from_rotation()


func _get_return_home_move() -> Vector3:
	var to_spawn := spawn_transform.origin - global_position
	to_spawn.y = 0.0
	if to_spawn.length() <= return_home_stop_distance:
		returning_to_spawn = false
		rotation.y = spawn_transform.basis.get_euler().y
		facing_direction = spawn_facing_direction
		return Vector3.ZERO

	var direction := to_spawn.normalized()
	var move_direction := _steer_around_obstacles(direction)
	if move_direction.length() > 0.01:
		_turn_toward(move_direction)
	return move_direction * _get_effective_move_speed()


func _get_idle_wander_move(delta: float) -> Vector3:
	idle_wander_timer -= delta
	var to_target := idle_wander_target - global_position
	to_target.y = 0.0

	if idle_wander_timer <= 0.0 or to_target.length() <= 0.4:
		idle_wander_timer = idle_wander_interval + randf_range(-0.6, 0.8)
		var angle := randf() * TAU
		var distance := randf_range(0.4, idle_wander_radius)
		idle_wander_target = spawn_transform.origin + Vector3(sin(angle) * distance, 0.0, cos(angle) * distance)
		to_target = idle_wander_target - global_position
		to_target.y = 0.0

	if to_target.length() <= 0.4:
		_scan_while_searching(facing_direction, delta)
		return Vector3.ZERO

	var move_direction := _steer_around_obstacles(to_target.normalized())
	if move_direction.length() > 0.01:
		_turn_toward(move_direction)
	return move_direction * (_get_effective_move_speed() * 0.45)


func _get_flee_move(player: Node3D, dist: float) -> Vector3:
	if player == null:
		return Vector3.ZERO

	if dist >= flee_recover_distance:
		fleeing_timer = 0.0
		returning_to_spawn = true
		_update_health_label()
		return Vector3.ZERO

	var away := global_position - player.global_position
	away.y = 0.0
	if away.length() <= 0.01:
		away = -facing_direction

	var move_direction := _steer_around_obstacles(away.normalized())
	if move_direction.length() <= 0.01:
		return Vector3.ZERO
	_turn_toward(move_direction)
	return move_direction * _get_effective_move_speed() * flee_speed_multiplier


func _update_bone_recovery_safety(delta: float, player: Node3D, distance_to_player: float) -> void:
	var was_recovery_ready: bool = bone_recovery_safe_timer >= bone_recovery_safe_delay
	if not bone_recovery_enabled:
		bone_recovery_safe_timer = 0.0
		recovering_limb_key = ""
		if was_recovery_ready:
			_update_health_label()
		return

	var safe_range: float = bone_recovery_safe_range
	if safe_range <= 0.0:
		safe_range = detection_range

	var player_too_close: bool = player != null and distance_to_player <= safe_range
	if player_visible or player_too_close:
		bone_recovery_safe_timer = 0.0
		recovering_limb_key = ""
		if was_recovery_ready:
			_update_health_label()
		return

	bone_recovery_safe_timer += delta
	if not was_recovery_ready and bone_recovery_safe_timer >= bone_recovery_safe_delay:
		_update_health_label()


func _can_recover_bone_part() -> bool:
	if not bone_recovery_enabled or not alive:
		return false
	if player_visible or bone_recovery_safe_timer < bone_recovery_safe_delay:
		return false
	return _get_recovering_limb_key() != ""


func _get_bone_recovery_move() -> Vector3:
	var limb_key: String = _get_recovering_limb_key()
	if limb_key == "":
		return Vector3.ZERO

	var limb_body: Node3D = detached_limb_bodies.get(limb_key) as Node3D
	if limb_body == null or not is_instance_valid(limb_body):
		_forget_detached_limb_body(limb_key)
		return Vector3.ZERO

	var to_limb: Vector3 = limb_body.global_position - global_position
	to_limb.y = 0.0
	if to_limb.length() <= bone_recovery_pickup_range:
		_recover_detached_limb(limb_key)
		return Vector3.ZERO

	var move_direction: Vector3 = _steer_around_obstacles(to_limb.normalized())
	if move_direction.length() <= 0.01:
		return Vector3.ZERO

	_turn_toward(move_direction)
	return move_direction * _get_effective_move_speed() * bone_recovery_move_speed_multiplier


func _get_recovering_limb_key() -> String:
	if _is_detached_limb_body_valid(recovering_limb_key):
		return recovering_limb_key

	recovering_limb_key = ""
	var best_key: String = ""
	var best_distance: float = INF
	for limb_key in detached_limb_bodies.keys():
		var key_string: String = _recovery_group_key(str(limb_key))
		if key_string == "" or key_string != str(limb_key):
			continue
		if not _is_detached_limb_body_valid(key_string):
			_forget_detached_limb_body(key_string)
			continue
		var limb_body: Node3D = detached_limb_bodies[key_string] as Node3D
		var distance: float = global_position.distance_squared_to(limb_body.global_position)
		if distance < best_distance:
			best_distance = distance
			best_key = key_string

	recovering_limb_key = best_key
	return recovering_limb_key


func _is_detached_limb_body_valid(limb_key: String) -> bool:
	if limb_key == "" or not detached_limb_bodies.has(limb_key):
		return false
	var limb_body: Node3D = detached_limb_bodies[limb_key] as Node3D
	return limb_body != null and is_instance_valid(limb_body)


func _recover_detached_limb(limb_key: String) -> void:
	limb_key = _recovery_group_key(limb_key)
	if limb_key == "":
		return

	for key in _limb_recovery_group(limb_key):
		var limb_body: Node3D = detached_limb_bodies.get(key) as Node3D
		if limb_body != null and is_instance_valid(limb_body):
			limb_body.queue_free()

		_forget_detached_limb_body(key)
		detached_limb_keys.erase(key)
		_set_rig_limb_visible(key, true)

	if not _has_active_limb_pickup():
		limb_pickup_spawned = false
	health = mini(max_health, health + bone_recovery_heal_per_part)
	_update_crawl_state(true)
	_update_health_label()


func _recovery_group_key(limb_key: String) -> String:
	match limb_key:
		"right_foot":
			return "right_leg"
		"left_foot":
			return "left_leg"
		_:
			return limb_key


func _limb_recovery_group(limb_key: String) -> Array[String]:
	match limb_key:
		"right_leg":
			return ["right_leg", "right_foot"]
		"left_leg":
			return ["left_leg", "left_foot"]
		_:
			return [limb_key]


func _has_active_limb_pickup() -> bool:
	for limb_key in detached_limb_bodies.keys():
		var limb_body: Node = detached_limb_bodies[limb_key] as Node
		if limb_body == null or not is_instance_valid(limb_body):
			continue
		if limb_body.get_node_or_null("LimbBonePickup") != null:
			return true
	return false


func _forget_detached_limb_body(limb_key: String) -> void:
	if limb_key == "":
		return
	detached_limb_bodies.erase(limb_key)
	if recovering_limb_key == limb_key:
		recovering_limb_key = ""


func _steer_around_obstacles(desired_direction: Vector3) -> Vector3:
	if desired_direction.length() <= 0.01:
		return Vector3.ZERO

	desired_direction = desired_direction.normalized()
	if avoidance_timer > 0.0 and avoidance_direction.length() > 0.01 and not _movement_blocked(avoidance_direction):
		return avoidance_direction

	if not _movement_blocked(desired_direction):
		avoidance_timer = 0.0
		avoidance_direction = Vector3.ZERO
		return desired_direction

	var slide_direction := _get_slide_around_obstacle(desired_direction)
	if slide_direction.length() > 0.01 and not _movement_blocked(slide_direction):
		avoidance_direction = slide_direction
		avoidance_timer = obstacle_avoidance_hold_time
		return avoidance_direction

	var side_angle := deg_to_rad(obstacle_side_probe_angle_degrees)
	var candidate_angles: Array[float] = [
		side_angle,
		-side_angle,
		PI * 0.5,
		-PI * 0.5,
		PI * 0.75,
		-PI * 0.75,
		PI
	]
	var best_direction := Vector3.ZERO
	var best_score := -10.0
	for angle in candidate_angles:
		var candidate: Vector3 = desired_direction.rotated(Vector3.UP, angle).normalized()
		if _movement_blocked(candidate):
			continue
		var score := candidate.dot(desired_direction)
		if score > best_score:
			best_score = score
			best_direction = candidate

	if best_direction.length() > 0.01:
		avoidance_direction = best_direction
		avoidance_timer = obstacle_avoidance_hold_time
		return avoidance_direction

	return Vector3.ZERO


func _movement_blocked(direction: Vector3) -> bool:
	if direction.length() <= 0.01:
		return true

	var motion := direction.normalized() * obstacle_probe_distance
	return test_move(global_transform, motion)


func _get_slide_around_obstacle(desired_direction: Vector3) -> Vector3:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var slide_direction := desired_direction.slide(collision.get_normal())
		slide_direction.y = 0.0
		if slide_direction.length() > 0.01:
			return slide_direction.normalized()

	return Vector3.ZERO


func _update_vision_visual(can_see_player: bool) -> void:
	if vision_material == null:
		return

	if can_see_player:
		vision_material.albedo_color = Color(1.0, 0.18, 0.12, 0.32)
		vision_material.emission_enabled = true
		vision_material.emission = Color(1.0, 0.18, 0.12, 1.0)
		vision_material.emission_energy_multiplier = 0.35
	else:
		vision_material.albedo_color = Color(1.0, 0.9, 0.25, 0.18)
		vision_material.emission_enabled = false


# --- Taking damage from the player's attack -----------------------------------

# Tier 1D: the attack hitbox calls this. It adds knockback on top of the normal
# damage so a landed hit is obvious. hit_from is the attack box's world position.
func take_damage(amount: int, hit_from: Vector3 = Vector3.ZERO, attacker: Node = null, damage_source: String = "") -> void:
	if not alive:
		return

	last_hit_from_position = hit_from
	_apply_knockback(hit_from)
	take_hit(amount)
	if alive and damage_source == "arrow":
		_react_to_arrow_hit(attacker, hit_from)


func _react_to_arrow_hit(attacker: Node, hit_from: Vector3) -> void:
	var attacker_body: Node3D = attacker as Node3D
	if attacker_body == null or not is_instance_valid(attacker_body):
		if hit_from != Vector3.ZERO:
			_investigate_position(hit_from, arrow_hit_search_duration)
		return

	last_known_player_position = attacker_body.global_position
	search_timer = maxf(search_timer, arrow_hit_search_duration)
	search_look_time = 0.0
	returning_to_spawn = false
	recovering_limb_key = ""
	bone_recovery_safe_timer = 0.0
	_alert_nearby_allies(attacker_body.global_position)

	var to_attacker: Vector3 = attacker_body.global_position - global_position
	to_attacker.y = 0.0
	if to_attacker.length() > 0.01:
		_turn_toward(to_attacker.normalized())


# Turns a hit into a fading push instead of a teleport (works with move_and_slide).
func _apply_knockback(hit_from: Vector3) -> void:
	if hit_from == Vector3.ZERO:
		return

	var push_direction := global_position - hit_from
	push_direction.y = 0.0
	if push_direction.length() > 0.01:
		knockback_velocity = push_direction.normalized() * knockback_strength


# Applies damage, feedback, and death.
func take_hit(damage: int) -> void:
	if not alive:
		return

	var health_before := health
	health = max(health - damage, 0)
	_update_health_label()
	_play_hit_sound()
	_detach_limbs_for_damage(maxi(health_before - health, 1), health <= 0)

	if health <= 0:
		die()
	else:
		_maybe_start_low_health_flee()
		# Only juice a surviving hit; a killing blow gets the death pop instead.
		_flash_hit()
		_punch_scale()


func _maybe_start_low_health_flee() -> void:
	if crawling_due_to_leg_loss:
		return
	if has_fled_low_health or not flees_when_low_health:
		return
	if max_health <= 0:
		return

	var health_ratio := float(health) / float(max_health)
	if health_ratio > low_health_flee_ratio:
		return

	has_fled_low_health = true
	fleeing_timer = low_health_flee_duration
	search_timer = 0.0
	search_look_time = 0.0
	returning_to_spawn = false
	attack_timer = maxf(attack_timer, 0.6)
	_update_health_label()


func _detach_limbs_for_damage(damage_taken: int, killing_hit: bool = false) -> void:
	if rig == null:
		return

	var limbs_to_detach: int = _limb_detach_count_for_damage(damage_taken, killing_hit)
	for i in range(limbs_to_detach):
		var limb_key := _next_attached_limb_key()
		if limb_key == "":
			return
		_detach_limb_group(limb_key)


func _limb_detach_count_for_damage(damage_taken: int, killing_hit: bool) -> int:
	if killing_hit:
		return 0

	var damage_per_limb: float = maxf(1.0, float(max_health) / float(maxi(target_limb_loss_steps, 1)))
	if gorilla_profile_active:
		damage_per_limb *= 1.35

	limb_detach_damage_progress += float(maxi(damage_taken, 1))
	var detach_count: int = int(floor(limb_detach_damage_progress / damage_per_limb))
	if detach_count > 0:
		limb_detach_damage_progress -= float(detach_count) * damage_per_limb

	var remaining_non_core: int = 0
	for limb_key in DETACHABLE_LIMBS:
		if CORE_FALL_ORDER.has(limb_key):
			continue
		if not detached_limb_keys.has(limb_key):
			remaining_non_core += 1

	return mini(detach_count, remaining_non_core)


func _next_attached_limb_key() -> String:
	for limb_key in _preferred_detach_keys():
		if not detached_limb_keys.has(limb_key):
			return limb_key
	return ""


func _preferred_detach_keys() -> Array[String]:
	return BoneRulesService.detachable_priority_for_bone(dropped_bone_id, DETACHABLE_LIMBS, CORE_FALL_ORDER)


func _detach_limb_group(limb_key: String, force_pickup: bool = false) -> void:
	var keys: Array[String] = []
	keys.append(limb_key)
	if limb_key == "right_leg":
		keys.append("right_foot")
	elif limb_key == "left_leg":
		keys.append("left_foot")

	for key in keys:
		if detached_limb_keys.has(key):
			continue
		detached_limb_keys.append(key)
		_spawn_detached_limb_piece(key, force_pickup and key == limb_key)
		_set_rig_limb_visible(key, false)
	_update_crawl_state()


func _spawn_detached_limb_piece(limb_key: String, force_pickup: bool = false) -> void:
	if rig == null or not rig.base_visuals.has(limb_key):
		return

	var source := rig.base_visuals[limb_key] as MeshInstance3D
	if source == null or source.mesh == null:
		return

	var world := get_tree().current_scene
	if world == null:
		world = get_parent()
	if world == null:
		return

	var body := RigidBody3D.new()
	body.name = "Detached_" + limb_key
	body.mass = 0.35
	body.collision_layer = 0
	body.collision_mask = 1
	body.global_transform = source.global_transform
	world.add_child(body)
	detached_limb_bodies[limb_key] = body

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = source.mesh.duplicate() as Mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = normal_color
	material.roughness = 0.85
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = source.mesh.get_aabb().size
	collision.shape = shape
	body.add_child(collision)

	var knock_direction := global_position - last_hit_from_position
	knock_direction.y = 0.2
	if last_hit_from_position == Vector3.ZERO or knock_direction.length() <= 0.01:
		knock_direction = -facing_direction + Vector3.UP * 0.25
	body.apply_impulse(knock_direction.normalized() * limb_detach_impulse)
	body.angular_velocity = Vector3(randf_range(-4.0, 4.0), randf_range(-6.0, 6.0), randf_range(-4.0, 4.0))

	var can_be_pickup := PICKUP_ELIGIBLE_LIMBS.has(limb_key) and dropped_bone_id != ""
	var should_be_pickup := force_pickup or randf() <= limb_pickup_drop_chance
	if not limb_pickup_spawned and can_be_pickup and should_be_pickup:
		_attach_pickup_to_detached_limb(body)
		limb_pickup_spawned = true
	else:
		var cleanup_delay: float = detached_limb_lifetime
		if bone_recovery_enabled:
			cleanup_delay = maxf(detached_limb_lifetime, bone_recovery_part_lifetime)
		var cleanup := body.create_tween()
		cleanup.tween_interval(cleanup_delay)
		cleanup.tween_property(body, "scale", Vector3.ZERO, 0.25)
		cleanup.tween_callback(Callable(self, "_forget_detached_limb_body").bind(limb_key))
		cleanup.tween_callback(Callable(body, "queue_free"))


func _attach_pickup_to_detached_limb(body: RigidBody3D) -> void:
	var pickup_area := Area3D.new()
	pickup_area.name = "LimbBonePickup"
	pickup_area.collision_layer = 0
	pickup_area.collision_mask = 1
	pickup_area.set_script(LIMB_BONE_PICKUP_SCRIPT)
	pickup_area.set("bone_id", dropped_bone_id)

	var pickup_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.15
	pickup_shape.shape = sphere
	pickup_area.add_child(pickup_shape)

	var label := Label3D.new()
	label.name = "PromptLabel"
	label.position = Vector3(0.0, 1.25, 0.0)
	label.text = BoneRulesService.display_name_with_slot(dropped_bone_id)
	label.font_size = 42
	label.outline_size = 8
	label.outline_modulate = Color(0.08, 0.07, 0.02, 1.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pickup_area.add_child(label)
	body.add_child(pickup_area)


func _set_rig_limb_visible(limb_key: String, is_visible: bool) -> void:
	if rig == null or not rig.base_visuals.has(limb_key):
		return

	var limb := rig.base_visuals[limb_key] as MeshInstance3D
	if limb != null:
		limb.visible = is_visible


func _restore_attached_limbs() -> void:
	for limb_key in detached_limb_bodies.keys():
		var limb_body: Node3D = detached_limb_bodies[limb_key] as Node3D
		if limb_body != null and is_instance_valid(limb_body):
			limb_body.queue_free()
	detached_limb_bodies.clear()
	recovering_limb_key = ""
	bone_recovery_safe_timer = 0.0

	for limb_key in detached_limb_keys:
		_set_rig_limb_visible(limb_key, true)
	detached_limb_keys.clear()
	last_hit_from_position = Vector3.ZERO
	limb_pickup_spawned = false
	limb_detach_damage_progress = 0.0
	_update_crawl_state(true)


func _update_crawl_state(force_refresh: bool = false) -> void:
	var should_crawl: bool = detached_limb_keys.has("right_leg") and detached_limb_keys.has("left_leg")
	if not force_refresh and should_crawl == crawling_due_to_leg_loss:
		return

	crawling_due_to_leg_loss = should_crawl
	if animator != null and animator.has_method("set_crawl_mode"):
		animator.set_crawl_mode(crawling_due_to_leg_loss)
	if crawling_due_to_leg_loss:
		fleeing_timer = 0.0
		attack_timer = maxf(attack_timer, 0.35)
	_update_health_label()


func die() -> void:
	if not alive:
		return

	alive = false
	search_timer = 0.0
	search_look_time = 0.0
	returning_to_spawn = false
	avoidance_timer = 0.0
	avoidance_direction = Vector3.ZERO
	ranged_attack_windup_timer = 0.0
	rock_throw_windup_timer = 0.0
	_cancel_held_rock()
	var respawn_delay := _get_respawn_delay()
	# Leave the group right away so nothing counts a dying enemy as still alive.
	remove_from_group("enemies")
	_set_collision_enabled(false)
	_set_player_visible(false)
	search_timer = 0.0
	search_look_time = 0.0
	returning_to_spawn = false
	avoidance_timer = 0.0
	avoidance_direction = Vector3.ZERO
	ranged_attack_windup_timer = 0.0
	rock_throw_windup_timer = 0.0
	_cancel_held_rock()
	_drop_bone()
	await _drop_remaining_limbs_on_death()
	if not limb_pickup_spawned:
		_drop_standard_bone_pickup()

	# Polish: play a short death pop, then keep the enemy hidden until it respawns.
	await _death_pop()
	if respawn_enabled:
		_hide_until_respawn()
		await _respawn_after_delay(respawn_delay)
	else:
		queue_free()


# Polish: flash, then shrink and spin the enemy out so its death is unmistakable.
func _death_pop() -> void:
	_set_enemy_color(HIT_COLOR)
	if health_label != null:
		health_label.visible = false

	_kill_scale_tween()
	_scale_tween = create_tween()
	_scale_tween.set_parallel(true)
	_scale_tween.tween_property(self, "scale", Vector3.ZERO, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_scale_tween.tween_property(self, "rotation:y", rotation.y + PI, 0.16)
	await _scale_tween.finished


func _hide_until_respawn() -> void:
	visible = false
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	search_timer = 0.0
	search_look_time = 0.0
	returning_to_spawn = false
	avoidance_timer = 0.0
	avoidance_direction = Vector3.ZERO
	fleeing_timer = 0.0
	ranged_attack_windup_timer = 0.0
	rock_throw_windup_timer = 0.0
	_cancel_held_rock()
	set_physics_process(false)


func _respawn_after_delay(delay_seconds: float) -> void:
	await get_tree().create_timer(delay_seconds).timeout

	while is_inside_tree() and not _spawn_is_out_of_perspective():
		await get_tree().create_timer(respawn_visibility_check_interval).timeout

	if is_inside_tree():
		_respawn()


func _respawn() -> void:
	global_transform = spawn_transform
	scale = spawn_scale
	rotation = spawn_transform.basis.get_euler()
	facing_direction = spawn_facing_direction
	alive = true
	health = max_health
	limb_detach_damage_progress = 0.0
	attack_timer = 0.0
	hit_flash_time_remaining = 0.0
	search_timer = 0.0
	search_look_time = 0.0
	returning_to_spawn = false
	avoidance_timer = 0.0
	avoidance_direction = Vector3.ZERO
	fleeing_timer = 0.0
	ranged_attack_timer = 0.0
	ranged_attack_windup_timer = 0.0
	rock_throw_timer = 0.0
	rock_throw_windup_timer = 0.0
	_cancel_held_rock()
	has_fled_low_health = false
	_roll_low_health_personality()
	last_known_player_position = spawn_transform.origin
	knockback_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	visible = true
	set_physics_process(true)
	_set_collision_enabled(true)
	if not is_in_group("enemies"):
		add_to_group("enemies")
	if health_label != null:
		health_label.visible = true
	_update_health_label()
	_restore_attached_limbs()
	_set_enemy_color(normal_color)
	_set_player_visible(false, true)
	vision_check_timer = fposmod(float(get_instance_id()) * 0.017, maxf(0.01, vision_check_interval))


func _get_respawn_delay() -> float:
	var player := _get_player()
	if player == null:
		return far_respawn_delay

	var distance_to_player := global_position.distance_to(player.global_position)
	if distance_to_player <= near_respawn_distance:
		return near_respawn_delay
	return far_respawn_delay


func _spawn_is_out_of_perspective() -> bool:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return true

	var spawn_center := spawn_transform.origin + Vector3.UP * 0.65
	return not camera.is_position_in_frustum(spawn_center)


func _set_collision_enabled(enabled: bool) -> void:
	if collision_shape == null:
		return

	collision_shape.set_deferred("disabled", not enabled)


func _facing_from_rotation() -> Vector3:
	return Vector3(sin(rotation.y), 0.0, cos(rotation.y)).normalized()


# Polish: a quick squash-and-recover so a surviving hit has some weight.
func _punch_scale() -> void:
	_kill_scale_tween()
	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", Vector3(1.18, 0.86, 1.18), 0.06)
	_scale_tween.tween_property(self, "scale", Vector3.ONE, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# Polish: a forward "chomp" scale pop that reads as the enemy attacking.
func _lunge() -> void:
	_kill_scale_tween()
	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", Vector3(1.25, 0.8, 1.25), 0.08)
	_scale_tween.tween_property(self, "scale", Vector3.ONE, 0.12)


# Stop any running scale tween so squash / lunge / death-pop never fight over scale.
func _kill_scale_tween() -> void:
	if _scale_tween != null:
		_scale_tween.kill()


# This creates a bone pickup in the same parent scene as the enemy.
func _drop_bone() -> void:
	if limb_pickup_spawned:
		return

	var drop_slot: String = BoneRulesService.slot_for(dropped_bone_id)
	if drop_slot == "body" and not detached_limb_keys.has("body"):
		return

	if guarantee_limb_pickup_on_death and _force_limb_pickup_drop():
		return

	_drop_standard_bone_pickup()


func _drop_standard_bone_pickup() -> void:
	if limb_pickup_spawned:
		return

	var world := get_parent()
	if world == null:
		return

	var bone := BONE_SCENE.instantiate()
	world.add_child(bone)

	var bone_node := bone as Node3D
	if bone_node != null:
		# Drop the pickup at ground height under wherever the enemy died.
		bone_node.global_position = Vector3(global_position.x, 0.05, global_position.z)

	if bone.has_method("set_bone_id"):
		bone.call("set_bone_id", dropped_bone_id)
	limb_pickup_spawned = true


func _force_limb_pickup_drop() -> bool:
	var limb_key := _next_pickup_limb_key()
	if limb_key == "":
		return false

	_detach_limb_group(limb_key, true)
	return limb_pickup_spawned


func _next_pickup_limb_key() -> String:
	var candidates: Array[String] = BoneRulesService.pickup_limb_candidates_for_bone(dropped_bone_id)

	for limb_key in candidates:
		if not detached_limb_keys.has(limb_key):
			return limb_key
	return ""


func _drop_remaining_limbs_on_death() -> void:
	if rig == null:
		return

	for limb_key in _preferred_detach_keys():
		if detached_limb_keys.has(limb_key):
			continue
		var should_force_pickup := guarantee_limb_pickup_on_death and not limb_pickup_spawned and _drop_slot_matches_limb(limb_key)
		_detach_limb_group(limb_key, should_force_pickup)
		if death_limb_fall_spacing > 0.0:
			await get_tree().create_timer(death_limb_fall_spacing).timeout


func _drop_slot_matches_limb(limb_key: String) -> bool:
	return BoneRulesService.drop_slot_matches_limb(dropped_bone_id, limb_key)


# This updates the floating HP text above the enemy.
func _update_health_label() -> void:
	if health_label == null:
		return

	var state_text := ""
	if crawling_due_to_leg_loss:
		state_text = "\nCRAWLING"
	elif fleeing_timer > 0.0:
		state_text = "\nFLEEING"
	elif _can_recover_bone_part():
		state_text = "\nRECOVERING"
	health_label.text = BoneRulesService.quality_for(dropped_bone_id) + " " + BoneRulesService.display_name_with_slot(dropped_bone_id) + "\nHP: " + str(health) + state_text


# This gives a clear visual response every time the enemy is hit.
func _flash_hit() -> void:
	hit_flash_time_remaining = 0.18
	_set_enemy_color(HIT_COLOR)


# This changes the enemy's material color.
func _set_enemy_color(new_color: Color) -> void:
	if enemy_material == null:
		return

	enemy_material.albedo_color = new_color
	_set_rig_color(new_color)


func _setup_procedural_character() -> void:
	if animator == null or rig == null:
		return

	if gorilla_profile_active and rig.has_method("apply_gorilla_proportions"):
		rig.apply_gorilla_proportions()
	animator.rig = rig
	animator.turn_target = null
	if animator.has_method("set_crawl_mode"):
		animator.set_crawl_mode(crawling_due_to_leg_loss)
	_setup_ranged_bow_visual()


func _update_procedural_animation(delta: float) -> void:
	if animator == null or rig == null:
		return

	animator.update_from_player(delta, velocity, _get_effective_move_speed(), facing_direction, [])


func _get_effective_move_speed() -> float:
	if crawling_due_to_leg_loss:
		return move_speed * crawl_speed_multiplier
	return move_speed


func _setup_ranged_bow_visual() -> void:
	if not ranged_attacker_enabled or rig == null or ranged_bow_visual != null:
		return

	var socket: Node3D = rig.get_socket("left_arm")
	if socket == null:
		return

	ranged_bow_visual = Node3D.new()
	ranged_bow_visual.name = "EnemyBow"
	socket.add_child(ranged_bow_visual)
	ranged_bow_visual.position = Vector3(-0.08, -0.22, 0.14)
	ranged_bow_visual.rotation_degrees = Vector3(0.0, 0.0, -18.0)

	ranged_bow_visual.add_child(_make_bow_piece("EnemyBowUpper", Vector3(0.05, 0.48, 0.05), Vector3(0.0, 0.2, 0.0), Color(0.38, 0.20, 0.08, 1.0)))
	ranged_bow_visual.add_child(_make_bow_piece("EnemyBowLower", Vector3(0.05, 0.48, 0.05), Vector3(0.0, -0.2, 0.0), Color(0.38, 0.20, 0.08, 1.0)))
	ranged_bow_visual.add_child(_make_bow_piece("EnemyBowString", Vector3(0.014, 0.92, 0.014), Vector3(0.06, 0.0, 0.0), Color(0.88, 0.82, 0.62, 1.0)))


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


func _set_rig_color(new_color: Color) -> void:
	if rig == null:
		return

	for key in rig.base_visuals:
		var limb := rig.base_visuals[key] as MeshInstance3D
		if limb == null:
			continue
		var material := limb.material_override as StandardMaterial3D
		if material != null:
			material.albedo_color = new_color


func _apply_bone_identity() -> void:
	var profile: Dictionary = BoneRulesService.enemy_profile_for(dropped_bone_id, low_health_flee_chance)
	if not bool(profile["is_defined"]):
		return

	move_speed += float(profile["move_speed_bonus"])
	attack_range += float(profile["attack_range_bonus"])
	contact_damage += int(profile["contact_damage_bonus"])
	max_health += int(profile["max_health_bonus"])
	detection_range += float(profile["detection_range_bonus"])
	low_health_flee_chance = float(profile["flee_chance"])
	stealth_finish_max_health = maxi(stealth_finish_max_health, max_health - 1)

	var enemy_scale: float = float(profile["visual_scale"])
	if visual_root != null:
		visual_root.scale = Vector3.ONE * enemy_scale


func _apply_gorilla_profile() -> void:
	gorilla_profile_active = _should_use_gorilla_profile()
	if not gorilla_profile_active:
		return

	move_speed *= gorilla_move_speed_multiplier
	attack_cooldown *= gorilla_attack_cooldown_multiplier
	max_health += gorilla_health_bonus
	contact_damage += gorilla_damage_bonus
	attack_range += gorilla_attack_range_bonus
	knockback_strength += gorilla_knockback_bonus


func _should_use_gorilla_profile() -> bool:
	match gorilla_profile_mode:
		"Always":
			return true
		"Never":
			return false
		_:
			return max_health >= gorilla_profile_min_health or contact_damage >= gorilla_profile_min_damage


func _roll_low_health_personality() -> void:
	flees_when_low_health = randf() <= low_health_flee_chance


# Tier 1D: a tiny procedurally generated "thud" so a hit is audible. This is a
# placeholder (no audio files needed) and can be swapped for a real sound later.
func _make_hit_blip() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.09
	var sample_count := int(mix_rate * duration)

	var data := PackedByteArray()
	data.resize(sample_count * 2) # 16-bit samples take 2 bytes each.

	for i in range(sample_count):
		var t := float(i) / float(mix_rate)
		var progress := float(i) / float(sample_count)
		var envelope := pow(1.0 - progress, 2.0) # fast fade so it reads as a tap.
		var wave := sin(TAU * 180.0 * t) * 0.7 + sin(TAU * 90.0 * t) * 0.3
		var value := int(clamp(wave * envelope, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, value)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream


# Play the hit blip as a one-shot under the scene root, so it keeps playing even
# if this enemy is removed by its death pop a moment later.
func _play_hit_sound() -> void:
	if _hit_sound == null:
		return

	var host := get_tree().current_scene
	if host == null:
		return

	var sound_player := AudioStreamPlayer.new()
	sound_player.stream = _hit_sound
	sound_player.volume_db = -8.0
	host.add_child(sound_player)
	sound_player.play()
	sound_player.finished.connect(Callable(sound_player, "queue_free"))
