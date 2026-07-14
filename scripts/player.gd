extends CharacterBody3D

# This is the visible bone piece that gets attached to a player socket.
const EQUIPPED_BONE_SCENE: PackedScene = preload("res://scenes/equipped_bone.tscn")

# Tier 1D: the short-lived, visible attack box we spawn in front of the player.
const ATTACK_HITBOX_SCENE: PackedScene = preload("res://scenes/attack_hitbox.tscn")
const ARROW_PROJECTILE_SCRIPT: Script = preload("res://scripts/arrow_projectile.gd")

# These are the player's normal stats before any bones are equipped.
# The @export tag means you can tune these values in the Godot editor later.
@export var base_move_speed: float = 6.0
@export var sprint_multiplier: float = 1.55
@export var jump_velocity: float = 8.5
@export_range(0.0, 0.25, 0.01) var movement_deadzone: float = 0.08
@export var base_attack_range: float = 2.0
@export var base_attack_damage: int = 1

# Player survivability. Enemies deal contact_damage; invuln_time is a brief mercy
# window after each hit so a crowd can't drain you in a single frame.
@export var max_health: int = 5
@export var damage_invuln_time: float = 0.7
@export var damage_knockback_strength: float = 5.0

# Tier 1E: each bone's stat effect now lives in one place — scripts/bone_database.gd.

# This is the downward pull that keeps the capsule on the ground.
# Godot has project-wide gravity settings too, but keeping this here makes the first lesson easier to read.
@export var gravity: float = 24.0

# Tier 1D combat-feel tuning.
# attack_cooldown stops repeated clicks from blurring the test (plan suggests 0.35-0.6s).
# forward_offset/height place the swing box just in front of and slightly above the player.
@export var attack_cooldown: float = 0.45
@export var attack_forward_offset: float = 1.15
@export var attack_height: float = 0.65
@export var stealth_prompt_scan_range: float = 3.0
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
var base_max_health: int = 0

# This is the player's first tiny inventory.
# For now it only stores bone names, which is enough to prove pickup works.
var bone_inventory: Array[String] = []

# Pressing Tab toggles the inventory screen (which also pauses the game).
var inventory_open: bool = false
var inventory_ui: PlayerInventoryUI = null

# Multi-slot equipment: each body slot ("right_arm","left_arm","legs","body")
# can hold one bone id, and each keeps its own attached visual. Wearing bones in
# different slots stacks their stats — your body is your build.
var equipped: Dictionary = {}          # slot -> bone_id
var equipped_visuals: Dictionary = {}  # slot -> Node3D
var equip_cursor: int = 0              # which collected bone Q equips next

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
var bow_visual: Node3D = null
var bow_equipped: bool = false
var bow_aiming: bool = false
var bow_charge_time: float = 0.0
var aim_reticle_layer: CanvasLayer = null
var aim_reticle_root: Control = null
var aim_reticle_dot: ColorRect = null
var aim_reticle_bars: Array[ColorRect] = []
var aim_reticle_charge_label: Label = null

# Tier 1F: how many times a bone was equipped this run (shown on the win screen).
var equip_swaps: int = 0

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
	base_max_health = max_health
	health = max_health
	bow_equipped = start_with_bow_equipped
	_recalculate_stats()
	inventory_ui = PlayerInventoryUI.new()
	add_child(inventory_ui)
	inventory_ui.setup(self)
	_build_health_ui()
	_build_stealth_ui()
	_build_aim_reticle_ui()
	_build_bow_visual()
	inventory_ui.notify_inventory_changed()
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
	if inventory_open and Input.is_action_just_pressed("ui_cancel") and not is_dead:
		_toggle_inventory()
	elif Input.is_action_just_pressed("inventory") and nearby_bone_pickups == 0 and not is_dead:
		_toggle_inventory()

	if inventory_open and Input.is_action_just_pressed("ui_focus_next") and not Input.is_action_just_pressed("inventory") and not is_dead:
		if inventory_ui != null:
			inventory_ui.cycle_category()

	if Input.is_action_just_pressed("equip") and not is_dead:
		_equip_next_bone()

	# While the inventory is open (paused) or the player is dead, stop here:
	# no movement, no attacking.
	if get_tree().paused or is_dead:
		_cancel_bow_aim()
		_set_stealth_prompt("")
		return

	_update_stealth_finish_prompt()
	if Input.is_action_just_pressed("stealth_finish"):
		_try_stealth_finish()
	if Input.is_action_just_pressed("toggle_bow"):
		_toggle_bow_equipped()
	if bow_aiming:
		bow_charge_time = minf(bow_charge_time + delta, maxf(bow_full_charge_time, 0.01))
		_update_aim_reticle_ui()

	# Count down the mercy window after taking a hit.
	if invuln_timer > 0.0:
		invuln_timer -= delta
	if noise_timer > 0.0:
		noise_timer = maxf(noise_timer - delta, 0.0)

	if Input.is_action_just_pressed("attack"):
		if bow_equipped:
			_start_bow_aim()
		else:
			_try_attack()
	if Input.is_action_just_released("attack") and bow_aiming:
		_release_bow_shot()
	if Input.is_action_just_pressed("ranged_attack") and not bow_equipped:
		_try_bow_shot()

	# Space gives the player a clean hop. The floor check prevents air-jumping.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# If the player is in the air, build up downward speed over time.
	# delta means "how much time passed since the last physics frame."
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif not Input.is_action_just_pressed("jump"):
		velocity.y = 0.0

	# Input.get_vector reads four named input actions from project.godot.
	# W makes the y value negative, S makes it positive, A makes x negative, and D makes x positive.
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_vector.length() < movement_deadzone:
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
	sprinting_this_frame = Input.is_action_pressed("sprint") and direction.length() > 0.01
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
	can_attack = false
	noise_timer = maxf(noise_timer, 0.55)
	if animator != null:
		animator.trigger_attack()

	# Aim the swing in the direction the player last moved.
	var forward := current_move_direction
	if forward.length() < 0.01:
		forward = _get_camera_forward_direction()
	forward.y = 0.0
	forward = forward.normalized()

	# Create the attack box and hand it this attack's damage. attack_damage
	# already includes bone bonuses, so the Heavy Bone really does hit harder.
	var hitbox := ATTACK_HITBOX_SCENE.instantiate()
	hitbox.damage = attack_damage
	hitbox.owner_player = self

	# Add it to the world (not as a child of the player) so it stays where it was
	# swung and cleans itself up after its brief lifetime.
	get_tree().current_scene.add_child(hitbox)

	# Place the box a bit in front of the player and slightly above the floor...
	hitbox.global_position = global_position + forward * attack_forward_offset + Vector3.UP * attack_height
	# ...then aim its depth in the attack direction. (look_at points -Z at the target.)
	hitbox.look_at(hitbox.global_position + forward, Vector3.UP)

	# Arm Bone reach: a bigger attack_range grows the whole swing box. We set
	# scale AFTER look_at, because look_at rewrites the box's rotation.
	var reach_ratio := 1.0
	if base_attack_range > 0.0:
		reach_ratio = attack_range / base_attack_range
	hitbox.scale = Vector3.ONE * reach_ratio

	# A quick flash on the player body so it's obvious YOU just attacked.
	_flash_player_attack()

	# Wait out the cooldown, then allow attacking again.
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _try_bow_shot(charge_multiplier: float = 1.0, charge_ratio: float = 0.0) -> void:
	if not bow_enabled or not can_shoot_bow:
		return

	can_shoot_bow = false
	noise_timer = maxf(noise_timer, 0.45)
	if animator != null:
		animator.trigger_attack()

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

	_cancel_bow_aim()

	bow_equipped = not bow_equipped
	if bow_visual != null:
		bow_visual.visible = bow_equipped


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
	var launch_direction: Vector3 = forward.normalized()
	if projectile_style == "arrow" and bow_equipped:
		launch_direction = _get_pointer_aim_direction(start_position, muzzle_forward)
	var launch_velocity: Vector3 = launch_direction * projectile_speed
	if projectile_style != "arrow":
		launch_velocity.y = 0.65
	if projectile.has_method("configure"):
		projectile.call("configure", start_position, launch_velocity, projectile_damage, self, false, projectile_gravity, projectile_style)
	get_tree().current_scene.add_child(projectile)


func _get_pointer_aim_direction(start_position: Vector3, fallback_direction: Vector3) -> Vector3:
	if camera_controller != null and camera_controller.has_method("get_center_aim_point"):
		var exclude: Array[RID] = []
		var player_collision: CollisionObject3D = self as CollisionObject3D
		if player_collision != null:
			exclude.append(player_collision.get_rid())
		var aim_point: Vector3 = camera_controller.get_center_aim_point(bow_aim_ray_distance, exclude)
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
	if not stealth_target.has_method("try_stealth_finish"):
		return

	can_attack = false
	noise_timer = maxf(noise_timer, 0.35)
	if animator != null:
		animator.trigger_attack()
	_flash_player_attack()
	var finished := bool(stealth_target.call("try_stealth_finish", self, attack_damage, global_position))
	if not finished:
		stealth_target = null
	_set_stealth_prompt("")

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


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

	animator.update_from_player(delta, velocity, max_speed, last_facing_direction, rig.get_equipped_bone_defs())


# Bone pickups call this when the player walks into them.
func collect_bone(bone_id: String) -> void:
	bone_inventory.append(bone_id)
	if inventory_ui != null:
		inventory_ui.notify_inventory_changed()
	GameEvents.bone_collected.emit(bone_id, self)
	print("Collected bone: ", BoneDatabase.display_name_with_slot(bone_id))


# Kept so arena objects can still detect "this body is the player." With multi-slot
# equipping, trials should use has_bone_equipped() instead of a single active id.
func get_equipped_bone_id() -> String:
	return equipped.get("right_arm", "")


# True if the given bone is worn in ANY slot. Trials check this now.
func has_bone_equipped(bone_id: String) -> bool:
	return equipped.values().has(bone_id)


# Tier 1F: the arena goal manager reads this to fill in the win screen.
func get_run_stats() -> Dictionary:
	return {
		"collected": bone_inventory.duplicate(),
		"swaps": equip_swaps,
	}


func get_inventory_items() -> Array:
	return bone_inventory.duplicate()


func get_equipment_state() -> Dictionary:
	return equipped.duplicate()


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


# Enemies check this so they stop attacking a dead player.
func is_player_dead() -> bool:
	return is_dead


func get_noise_radius() -> float:
	if is_dead:
		return 0.0
	if noise_timer <= 0.0:
		return 0.0
	if sprinting_this_frame:
		return 6.5
	return 9.0


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


# Equipping is a build: Q steps through your collected bones and snaps each one
# into ITS slot (from the bone database). Different slots coexist, so you end up
# wearing several at once; a new bone in a filled slot replaces that slot.
func _equip_next_bone() -> void:
	if bone_inventory.is_empty():
		print("No bones to equip yet.")
		return

	if equip_cursor >= bone_inventory.size():
		equip_cursor = 0

	var bone_id := bone_inventory[equip_cursor]
	equip_cursor = (equip_cursor + 1) % bone_inventory.size()
	equip_bone(bone_id)


# Public: equip a specific bone into its slot. Used by Q and by drag-and-drop.
func equip_bone(bone_id: String) -> void:
	if not _equip_bone_in_slot(bone_id):
		return
	if rig != null:
		rig.equip_bone(bone_id, BoneDatabase.get_def(bone_id))
	equip_swaps += 1
	_recalculate_stats()
	if inventory_ui != null:
		inventory_ui.notify_equipment_changed()
	GameEvents.bone_equipped.emit(bone_id, BoneDatabase.slot(bone_id), self)
	print("Equipped ", BoneDatabase.display_name_with_slot(bone_id), " in slot ", BoneDatabase.slot(bone_id))


# Public: clear a slot. Used by dragging a worn bone out, or right-clicking a slot.
func unequip_slot(slot: String) -> void:
	if not equipped.has(slot):
		return

	var bone_id: String = equipped[slot]
	equipped.erase(slot)
	if rig != null:
		rig.unequip_slot(slot)
	if equipped_visuals.has(slot) and is_instance_valid(equipped_visuals[slot]):
		equipped_visuals[slot].queue_free()
	equipped_visuals.erase(slot)

	_recalculate_stats()
	if inventory_ui != null:
		inventory_ui.notify_equipment_changed()
	GameEvents.bone_unequipped.emit(bone_id, slot, self)
	print("Unequipped slot ", slot)


# Shows a bone's stats in the hover-info area (called by tiles/slots on mouse-over).
func show_bone_info(bone_id: String) -> void:
	if inventory_ui != null:
		inventory_ui.show_bone_info(bone_id)


func clear_bone_info() -> void:
	if inventory_ui != null:
		inventory_ui.clear_bone_info()


# Attaches one bone into the slot the database assigns it, replacing whatever
# was already in that slot and rebuilding its visual.
func _equip_bone_in_slot(bone_id: String) -> bool:
	var slot := BoneDatabase.slot(bone_id)
	if slot == "":
		print("Bone has no slot: ", bone_id)
		return false

	var socket := _get_socket_for_slot(slot)
	if socket == null:
		print("No socket for slot: ", slot)
		return false

	# Already wearing this exact bone in that slot? Nothing to do.
	if equipped.get(slot, "") == bone_id:
		return false

	equipped[slot] = bone_id

	# Remove the old visual in this slot, if any.
	if equipped_visuals.has(slot) and is_instance_valid(equipped_visuals[slot]):
		equipped_visuals[slot].queue_free()
	equipped_visuals.erase(slot)

	if rig != null:
		return true

	# Build and attach the new visual, tinted to the bone's color.
	var visual := EQUIPPED_BONE_SCENE.instantiate() as Node3D
	socket.add_child(visual)
	visual.position = Vector3.ZERO
	visual.rotation = Vector3.ZERO
	equipped_visuals[slot] = visual
	_tint_visual(visual, BoneDatabase.color(bone_id))
	return true


# Maps a slot name to the socket node the bone attaches to.
func _get_socket_for_slot(slot: String) -> Node3D:
	match slot:
		"right_arm":
			return socket_arm_right
		"left_arm":
			return socket_arm_left
		"legs":
			return socket_legs
		"body":
			return socket_body
		_:
			return null


# Recalculates gameplay stats by stacking every bone currently worn.
func _recalculate_stats() -> void:
	var old_max_health := max_health
	move_speed = base_move_speed
	attack_range = base_attack_range
	attack_damage = base_attack_damage
	max_health = base_max_health

	for slot in equipped:
		var bone_id: String = equipped[slot]
		move_speed += BoneDatabase.move_speed_bonus(bone_id)
		attack_range += BoneDatabase.attack_range_bonus(bone_id)
		attack_damage += BoneDatabase.attack_damage_bonus(bone_id)
		max_health += BoneDatabase.max_health_bonus(bone_id)

	if old_max_health > 0 and max_health > old_max_health:
		health += max_health - old_max_health
	health = clampi(health, 0, max_health)
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
	get_tree().paused = inventory_open
	_update_mouse_mode()


func _update_mouse_mode() -> void:
	if camera_controller == null:
		return
	camera_controller.set_look_enabled(not inventory_open and not is_dead)


# Tier 1E: bone names, colors, stat bonuses, and effect text used to live here as
# a stack of match statements. They now live in one shared table that every script
# reads from: scripts/bone_database.gd.


# Tints one bone visual so its bone type is readable on the player's body.
func _tint_visual(visual: Node3D, color: Color) -> void:
	_tint_visual_mesh(visual, "BoneMesh", color)
	_tint_visual_mesh(visual, "JointMesh", color)


func _tint_visual_mesh(visual: Node3D, mesh_name: String, color: Color) -> void:
	var mesh := visual.get_node_or_null(mesh_name) as MeshInstance3D
	if mesh == null:
		return

	var material: StandardMaterial3D = null
	var raw_material := mesh.get_surface_override_material(0)
	if raw_material != null:
		material = raw_material.duplicate() as StandardMaterial3D

	if material == null:
		material = StandardMaterial3D.new()

	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.25
	mesh.set_surface_override_material(0, material)
