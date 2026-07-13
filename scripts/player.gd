extends CharacterBody3D

# This is the visible bone piece that gets attached to a player socket.
const EQUIPPED_BONE_SCENE: PackedScene = preload("res://scenes/equipped_bone.tscn")

# Tier 1D: the short-lived, visible attack box we spawn in front of the player.
const ATTACK_HITBOX_SCENE: PackedScene = preload("res://scenes/attack_hitbox.tscn")

# These are the player's normal stats before any bones are equipped.
# The @export tag means you can tune these values in the Godot editor later.
@export var base_move_speed: float = 6.0
@export var sprint_multiplier: float = 1.55
@export var jump_velocity: float = 8.5
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

# These are the active stats the movement and attack code actually use.
# They start from the base stats, then equipped bones can modify them.
var move_speed: float = 0.0
var attack_range: float = 0.0
var attack_damage: int = 0
var base_max_health: int = 0

# This is the player's first tiny inventory.
# For now it only stores bone names, which is enough to prove pickup works.
var bone_inventory: Array[String] = []

# Pressing E toggles the inventory screen (which also pauses the game).
var inventory_open: bool = false
var inventory_root: Control
var inventory_label: Label
var hover_info_label: Label
var inventory_status_label: Label
var inventory_category: String = "all"
var inventory_tab_buttons: Dictionary = {}
var inventory_preview_rig: ModularSkeletonRig = null
var inventory_preview_root: Node3D = null

# Drag-and-drop inventory widgets.
var slot_widgets: Dictionary = {}    # slot name -> BoneSlotWidget on the paper doll
var items_grid: GridContainer = null # holds a draggable BoneItemTile per collected bone

# Multi-slot equipment: each body slot ("right_arm","left_arm","legs","body")
# can hold one bone id, and each keeps its own attached visual. Wearing bones in
# different slots stacks their stats — your body is your build.
var equipped: Dictionary = {}          # slot -> bone_id
var equipped_visuals: Dictionary = {}  # slot -> Node3D
var equip_cursor: int = 0              # which collected bone Q equips next

# This counts nearby world interactions that use E.
# When it is above 0, E is reserved for the world prompt instead of inventory.
var nearby_bone_pickups: int = 0

# Tier 1D attack state.
# can_attack is flipped off during the cooldown, then back on when it ends.
# last_facing_direction remembers where to aim the swing when standing still.
var can_attack: bool = true
var last_facing_direction: Vector3 = Vector3.FORWARD

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


# _ready runs once when the player enters the running scene.
func _ready() -> void:
	add_to_group("player")
	# Keep processing while the tree is paused, so the inventory screen (which
	# pauses the game) can still be closed and browsed with Q/E.
	process_mode = Node.PROCESS_MODE_ALWAYS
	base_max_health = max_health
	health = max_health
	_recalculate_stats()
	_build_inventory_ui()
	_build_health_ui()
	_build_stealth_ui()
	_rebuild_item_tiles()
	_update_inventory_ui()
	_setup_procedural_character()


# Godot calls _physics_process many times per second on a steady physics clock.
# Movement and collision code belongs here because it needs consistent timing.
func _physics_process(delta: float) -> void:
	# The inventory toggle and equipping work even while paused, so you can open
	# the inventory, study your build, and rearrange it with the game frozen.
	if inventory_open and Input.is_action_just_pressed("ui_cancel") and not is_dead:
		_toggle_inventory()
	elif Input.is_action_just_pressed("inventory") and nearby_bone_pickups == 0 and not is_dead:
		_toggle_inventory()

	if inventory_open and Input.is_action_just_pressed("ui_focus_next") and not is_dead:
		_cycle_inventory_category()

	if Input.is_action_just_pressed("equip") and not is_dead:
		_equip_next_bone()

	# While the inventory is open (paused) or the player is dead, stop here:
	# no movement, no attacking.
	if get_tree().paused or is_dead:
		_set_stealth_prompt("")
		return

	_update_stealth_finish_prompt()
	if Input.is_action_just_pressed("stealth_finish"):
		_try_stealth_finish()

	# Count down the mercy window after taking a hit.
	if invuln_timer > 0.0:
		invuln_timer -= delta
	if noise_timer > 0.0:
		noise_timer = maxf(noise_timer - delta, 0.0)

	if Input.is_action_just_pressed("attack"):
		_try_attack()

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

	# Godot's 3D world uses X for left/right, Y for up/down, and Z for forward/back.
	# Forward is negative Z, so the input vector can become a 3D ground direction directly.
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)

	# Keep diagonal movement from being faster than straight movement.
	if direction.length() > 1.0:
		direction = direction.normalized()

	# Tier 1D: remember the last direction we actually moved, so an attack while
	# standing still still swings the way we were last heading.
	if direction.length() > 0.01:
		last_facing_direction = direction

	var current_move_speed := move_speed
	sprinting_this_frame = Input.is_action_pressed("sprint") and direction.length() > 0.01
	if sprinting_this_frame:
		current_move_speed *= sprint_multiplier
		noise_timer = maxf(noise_timer, 0.18)

	# Fading knockback from taking a hit rides on top of normal movement.
	damage_knockback = damage_knockback.move_toward(Vector3.ZERO, damage_knockback_strength * 4.0 * delta)

	# CharacterBody3D already has a velocity variable.
	# We set the sideways parts from input, while the Y part is handled by gravity above.
	velocity.x = direction.x * current_move_speed + damage_knockback.x
	velocity.z = direction.z * current_move_speed + damage_knockback.z

	# move_and_slide moves the body, checks collisions, and slides along walls/floors instead of passing through them.
	move_and_slide()
	_update_procedural_animation(delta, current_move_speed)


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
	var forward := last_facing_direction
	forward.y = 0.0
	if forward.length() < 0.01:
		forward = Vector3.FORWARD
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
	stealth_target.call("try_stealth_finish", self, attack_damage, global_position)
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


func _update_procedural_animation(delta: float, max_speed: float) -> void:
	if animator == null or rig == null:
		return

	animator.update_from_player(delta, velocity, max_speed, last_facing_direction, rig.get_equipped_bone_defs())


# Bone pickups call this when the player walks into them.
func collect_bone(bone_id: String) -> void:
	# Tier 1E duplicate policy: collecting a bone you already own does nothing
	# except say so — no duplicate entries pile up in the inventory.
	if bone_inventory.has(bone_id):
		print("Already have ", BoneDatabase.display_name(bone_id))
		return

	bone_inventory.append(bone_id)
	_rebuild_item_tiles()
	_update_inventory_ui()
	print("Collected bone: ", BoneDatabase.display_name(bone_id))


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

	# Tell the arena to show the game-over screen.
	var manager := get_tree().get_first_node_in_group("arena_goal_managers")
	if manager != null and manager.has_method("game_over"):
		manager.call("game_over", self)


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
	_equip_bone_in_slot(bone_id)
	if rig != null:
		rig.equip_bone(bone_id, BoneDatabase.get_def(bone_id))
	equip_swaps += 1
	_recalculate_stats()
	_update_inventory_ui()
	_sync_inventory_preview()
	# The equipped bone's tile leaves the grid — rebuild AFTER the drop callback
	# finishes (deferred), so we never free a tile that's mid-drop.
	call_deferred("_rebuild_item_tiles")
	print("Equipped ", BoneDatabase.display_name(bone_id), " in slot ", BoneDatabase.slot(bone_id))


# Public: clear a slot. Used by dragging a worn bone out, or right-clicking a slot.
func unequip_slot(slot: String) -> void:
	if not equipped.has(slot):
		return

	equipped.erase(slot)
	if rig != null:
		rig.unequip_slot(slot)
	if equipped_visuals.has(slot) and is_instance_valid(equipped_visuals[slot]):
		equipped_visuals[slot].queue_free()
	equipped_visuals.erase(slot)

	_recalculate_stats()
	_update_inventory_ui()
	_sync_inventory_preview()
	# The bone's tile returns to the grid — deferred, so an in-progress drop is safe.
	call_deferred("_rebuild_item_tiles")
	print("Unequipped slot ", slot)


# Shows a bone's stats in the hover-info area (called by tiles/slots on mouse-over).
func show_bone_info(bone_id: String) -> void:
	if hover_info_label == null:
		return
	var t := BoneDatabase.quality(bone_id) + " " + BoneDatabase.display_name(bone_id) + "  [slot: " + BoneDatabase.slot(bone_id) + "]\n"
	t += BoneDatabase.effect_text(bone_id)
	t += BoneDatabase.description(bone_id)
	hover_info_label.text = t


func clear_bone_info() -> void:
	if hover_info_label == null:
		return
	hover_info_label.text = "Select an item to view details."


# Attaches one bone into the slot the database assigns it, replacing whatever
# was already in that slot and rebuilding its visual.
func _equip_bone_in_slot(bone_id: String) -> void:
	var slot := BoneDatabase.slot(bone_id)
	if slot == "":
		print("Bone has no slot: ", bone_id)
		return

	var socket := _get_socket_for_slot(slot)
	if socket == null:
		print("No socket for slot: ", slot)
		return

	# Already wearing this exact bone in that slot? Nothing to do.
	if equipped.get(slot, "") == bone_id:
		return

	equipped[slot] = bone_id

	# Remove the old visual in this slot, if any.
	if equipped_visuals.has(slot) and is_instance_valid(equipped_visuals[slot]):
		equipped_visuals[slot].queue_free()
	equipped_visuals.erase(slot)

	if rig != null:
		return

	# Build and attach the new visual, tinted to the bone's color.
	var visual := EQUIPPED_BONE_SCENE.instantiate() as Node3D
	socket.add_child(visual)
	visual.position = Vector3.ZERO
	visual.rotation = Vector3.ZERO
	equipped_visuals[slot] = visual
	_tint_visual(visual, BoneDatabase.color(bone_id))


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
		if to_enemy.length() > 0.01 and last_facing_direction.normalized().dot(to_enemy.normalized()) < -0.2:
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


# Builds the real functional inventory UI: blurred world behind it, a readable
# ornate panel, real tab buttons, real item slots, and a live character preview.
func _build_inventory_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "InventoryCanvas"
	canvas.layer = 5
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	inventory_root = Control.new()
	inventory_root.name = "InventoryRoot"
	inventory_root.anchor_right = 1.0
	inventory_root.anchor_bottom = 1.0
	inventory_root.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_root.visible = false
	canvas.add_child(inventory_root)

	inventory_root.add_child(_build_inventory_blur_layer())

	var safe_area := MarginContainer.new()
	safe_area.anchor_right = 1.0
	safe_area.anchor_bottom = 1.0
	safe_area.process_mode = Node.PROCESS_MODE_ALWAYS
	safe_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe_area.add_theme_constant_override("margin_left", 34)
	safe_area.add_theme_constant_override("margin_top", 18)
	safe_area.add_theme_constant_override("margin_right", 34)
	safe_area.add_theme_constant_override("margin_bottom", 18)
	inventory_root.add_child(safe_area)

	var panel := PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(0.99, 0.985, 0.955, 0.86), Color(0.87, 0.63, 0.19, 0.96), 2, 0))
	safe_area.add_child(panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 24)
	panel_margin.add_theme_constant_override("margin_top", 16)
	panel_margin.add_theme_constant_override("margin_right", 24)
	panel_margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(panel_margin)

	var root := VBoxContainer.new()
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_theme_constant_override("separation", 9)
	panel_margin.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	root.add_child(header)

	var left_rule := _make_rule()
	header.add_child(left_rule)

	var title := Label.new()
	title.text = "Inventory"
	title.custom_minimum_size = Vector2(260, 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	header.add_child(title)

	var right_rule := _make_rule()
	header.add_child(right_rule)

	inventory_status_label = Label.new()
	inventory_status_label.custom_minimum_size = Vector2(140, 48)
	inventory_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	inventory_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_status_label.add_theme_font_size_override("font_size", 20)
	inventory_status_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	header.add_child(inventory_status_label)

	_build_inventory_tabs(root)

	var divider := ColorRect.new()
	divider.color = Color(0.87, 0.63, 0.19, 0.70)
	divider.custom_minimum_size = Vector2(0, 1)
	root.add_child(divider)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	var left_panel := VBoxContainer.new()
	left_panel.custom_minimum_size = Vector2(650, 0)
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_theme_constant_override("separation", 8)
	body.add_child(left_panel)

	var grid_panel := PanelContainer.new()
	grid_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.28), Color(0.87, 0.63, 0.19, 0.75), 1, 0))
	left_panel.add_child(grid_panel)

	var grid_margin := MarginContainer.new()
	grid_margin.add_theme_constant_override("margin_left", 14)
	grid_margin.add_theme_constant_override("margin_top", 14)
	grid_margin.add_theme_constant_override("margin_right", 14)
	grid_margin.add_theme_constant_override("margin_bottom", 14)
	grid_panel.add_child(grid_margin)

	items_grid = GridContainer.new()
	items_grid.process_mode = Node.PROCESS_MODE_ALWAYS
	items_grid.columns = 6
	items_grid.add_theme_constant_override("h_separation", 12)
	items_grid.add_theme_constant_override("v_separation", 12)
	grid_margin.add_child(items_grid)

	var sort_label := Label.new()
	sort_label.text = "Sort: Newest    Empty slots show room for new pieces"
	sort_label.add_theme_font_size_override("font_size", 16)
	sort_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	left_panel.add_child(sort_label)

	var right_panel := VBoxContainer.new()
	right_panel.custom_minimum_size = Vector2(430, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_constant_override("separation", 10)
	body.add_child(right_panel)

	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(430, 330)
	preview_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.18), Color(0.87, 0.63, 0.19, 0.88), 1, 0))
	right_panel.add_child(preview_panel)

	var preview_area := MarginContainer.new()
	preview_area.add_theme_constant_override("margin_left", 12)
	preview_area.add_theme_constant_override("margin_top", 12)
	preview_area.add_theme_constant_override("margin_right", 12)
	preview_area.add_theme_constant_override("margin_bottom", 12)
	preview_panel.add_child(preview_area)
	preview_area.add_child(_build_paper_doll())

	var details_panel := PanelContainer.new()
	details_panel.custom_minimum_size = Vector2(430, 96)
	details_panel.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.32), Color(0.87, 0.63, 0.19, 0.85), 1, 0))
	right_panel.add_child(details_panel)

	var details_margin := MarginContainer.new()
	details_margin.add_theme_constant_override("margin_left", 18)
	details_margin.add_theme_constant_override("margin_top", 12)
	details_margin.add_theme_constant_override("margin_right", 18)
	details_margin.add_theme_constant_override("margin_bottom", 12)
	details_panel.add_child(details_margin)

	hover_info_label = Label.new()
	hover_info_label.name = "HoverInfoLabel"
	hover_info_label.custom_minimum_size = Vector2(390, 66)
	hover_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hover_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hover_info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hover_info_label.add_theme_font_size_override("font_size", 16)
	hover_info_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	details_margin.add_child(hover_info_label)

	inventory_label = Label.new()
	inventory_label.name = "InventoryLabel"
	inventory_label.custom_minimum_size = Vector2(430, 44)
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.add_theme_font_size_override("font_size", 13)
	inventory_label.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_panel.add_child(inventory_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 16)
	root.add_child(footer)
	_add_footer_hint(footer, "Tab", "Category")
	_add_footer_hint(footer, "Q", "Equip Next")
	_add_footer_hint(footer, "Right Click", "Unequip")
	_add_footer_hint(footer, "Esc / E", "Back")

	clear_bone_info()


func _build_inventory_blur_layer() -> ColorRect:
	var blur := ColorRect.new()
	blur.name = "InventoryWorldBlur"
	blur.color = Color.WHITE
	blur.anchor_right = 1.0
	blur.anchor_bottom = 1.0
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float blur_strength = 1.0;
uniform vec4 veil_color : source_color = vec4(0.96, 0.95, 0.90, 0.24);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 p = vec2(0.0022, 0.0039) * blur_strength;
	vec4 c = texture(screen_texture, uv) * 0.20;
	c += texture(screen_texture, uv + vec2(p.x, 0.0)) * 0.10;
	c += texture(screen_texture, uv - vec2(p.x, 0.0)) * 0.10;
	c += texture(screen_texture, uv + vec2(0.0, p.y)) * 0.10;
	c += texture(screen_texture, uv - vec2(0.0, p.y)) * 0.10;
	c += texture(screen_texture, uv + p) * 0.10;
	c += texture(screen_texture, uv - p) * 0.10;
	c += texture(screen_texture, uv + vec2(p.x, -p.y)) * 0.10;
	c += texture(screen_texture, uv + vec2(-p.x, p.y)) * 0.10;
	vec3 tinted = mix(c.rgb, veil_color.rgb, veil_color.a);
	COLOR = vec4(tinted, 0.62);
}
"""

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("blur_strength", 1.0)
	material.set_shader_parameter("veil_color", Color(0.96, 0.95, 0.90, 0.24))
	blur.material = material
	return blur


func _build_inventory_tabs(parent: VBoxContainer) -> void:
	var tabs := HBoxContainer.new()
	tabs.process_mode = Node.PROCESS_MODE_ALWAYS
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 42)
	parent.add_child(tabs)

	_add_inventory_tab(tabs, "all", "All")
	_add_inventory_tab(tabs, "right_arm", "Arms")
	_add_inventory_tab(tabs, "legs", "Legs")
	_add_inventory_tab(tabs, "body", "Torsos")
	_add_inventory_tab(tabs, "head", "Heads")
	_refresh_inventory_tabs()


func _add_inventory_tab(parent: HBoxContainer, category: String, text: String) -> void:
	var button := Button.new()
	button.text = text
	button.flat = true
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(108, 48)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.0), Color(0.87, 0.63, 0.19, 0.0), 0, 0))
	button.add_theme_stylebox_override("hover", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.32), Color(0.0, 0.78, 0.78, 0.65), 1, 0))
	button.pressed.connect(Callable(self, "_select_inventory_category").bind(category))
	parent.add_child(button)
	inventory_tab_buttons[category] = button


func _select_inventory_category(category: String) -> void:
	inventory_category = category
	_refresh_inventory_tabs()
	_rebuild_item_tiles()
	_update_inventory_ui()


func _cycle_inventory_category() -> void:
	var categories: Array[String] = ["all", "right_arm", "legs", "body", "head"]
	var index: int = categories.find(inventory_category)
	if index < 0:
		index = 0
	index = (index + 1) % categories.size()
	_select_inventory_category(categories[index])


func _refresh_inventory_tabs() -> void:
	for category in inventory_tab_buttons:
		var category_name: String = str(category)
		var button := inventory_tab_buttons[category_name] as Button
		if button == null:
			continue
		var selected: bool = category_name == inventory_category
		if selected:
			button.add_theme_color_override("font_color", Color(0.0, 0.78, 0.78, 1.0))
			button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.34), Color(0.0, 0.78, 0.78, 0.85), 1, 0))
		else:
			button.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
			button.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.0), Color(0.87, 0.63, 0.19, 0.0), 0, 0))


func _add_footer_hint(parent: HBoxContainer, key_text: String, action_text: String) -> void:
	var key := Label.new()
	key.text = key_text
	key.add_theme_font_size_override("font_size", 15)
	key.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	key.add_theme_stylebox_override("normal", _make_inventory_style(Color(1.0, 0.99, 0.95, 0.6), Color(0.03, 0.33, 0.38, 1.0), 1, 3))
	parent.add_child(key)

	var action := Label.new()
	action.text = action_text
	action.add_theme_font_size_override("font_size", 16)
	action.add_theme_color_override("font_color", Color(0.03, 0.33, 0.38, 1.0))
	parent.add_child(action)


func _make_rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = Color(0.87, 0.63, 0.19, 0.82)
	rule.custom_minimum_size = Vector2(80, 1)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


func _make_inventory_style(bg: Color, border: Color, border_width: int = 1, radius: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	style.shadow_color = Color(0.21, 0.13, 0.04, 0.10)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	return style


func _make_empty_inventory_slot() -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = Vector2(96, 86)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var frame := PanelContainer.new()
	frame.position = Vector2(0, 0)
	frame.size = Vector2(96, 86)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.58), 1, 0))
	slot.add_child(frame)

	var diamond := ColorRect.new()
	diamond.color = Color(0.87, 0.63, 0.19, 0.16)
	diamond.position = Vector2(39, 31)
	diamond.size = Vector2(18, 18)
	diamond.rotation = PI / 4.0
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(diamond)

	var diamond_inner := ColorRect.new()
	diamond_inner.color = Color(0.98, 0.975, 0.955, 0.92)
	diamond_inner.position = Vector2(43, 35)
	diamond_inner.size = Vector2(10, 10)
	diamond_inner.rotation = PI / 4.0
	diamond_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(diamond_inner)
	return slot


func _build_character_preview_panel() -> Control:
	var container := SubViewportContainer.new()
	container.name = "CharacterPreview"
	container.position = Vector2(98.0, 15.0)
	container.size = Vector2(210.0, 276.0)
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var viewport := SubViewport.new()
	viewport.size = Vector2i(210, 276)
	viewport.transparent_bg = true
	container.add_child(viewport)

	var preview_scene := Node3D.new()
	preview_scene.name = "PreviewScene"
	viewport.add_child(preview_scene)
	inventory_preview_root = preview_scene

	var light := DirectionalLight3D.new()
	light.name = "PreviewLight"
	light.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
	light.light_energy = 1.6
	preview_scene.add_child(light)

	var rig_holder := Node3D.new()
	rig_holder.name = "PreviewRigHolder"
	rig_holder.position = Vector3(0.0, -0.26, 0.0)
	rig_holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	rig_holder.scale = Vector3.ONE * 1.48
	preview_scene.add_child(rig_holder)

	inventory_preview_rig = ModularSkeletonRig.new()
	inventory_preview_rig.name = "PreviewModularSkeletonRig"
	rig_holder.add_child(inventory_preview_rig)

	var camera := Camera3D.new()
	camera.name = "PreviewCamera"
	camera.position = Vector3(0.0, 0.68, 2.85)
	camera.look_at(Vector3(0.0, 0.05, 0.0), Vector3.UP)
	camera.current = true
	preview_scene.add_child(camera)

	call_deferred("_sync_inventory_preview")
	return container


func _sync_inventory_preview() -> void:
	if inventory_preview_rig == null or not is_instance_valid(inventory_preview_rig):
		return

	var current_slots: Array = inventory_preview_rig.equipped_ids.keys()
	for slot_id in current_slots:
		inventory_preview_rig.unequip_slot(str(slot_id))

	for slot in equipped:
		var bone_id: String = str(equipped[slot])
		var bone_def: Dictionary = BoneDatabase.get_def(bone_id)
		if bone_def.is_empty():
			continue
		inventory_preview_rig.equip_bone(bone_id, bone_def)


# Builds the right-side equipped-bone frame. The center is decorative for now;
# the functional slots around it still handle drag/drop and right-click unequip.
func _build_paper_doll() -> Control:
	var doll := Control.new()
	doll.custom_minimum_size = Vector2(406, 306)
	doll.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center_frame := PanelContainer.new()
	center_frame.position = Vector2(88, 0)
	center_frame.size = Vector2(230, 306)
	center_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_frame.add_theme_stylebox_override("panel", _make_inventory_style(Color(1.0, 1.0, 1.0, 0.12), Color(0.87, 0.63, 0.19, 0.46), 1, 0))
	doll.add_child(center_frame)

	var ring := ColorRect.new()
	ring.position = Vector2(171, 96)
	ring.size = Vector2(64, 64)
	ring.rotation = PI / 4.0
	ring.color = Color(0.87, 0.63, 0.19, 0.16)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	doll.add_child(ring)

	var ring_inner := ColorRect.new()
	ring_inner.position = Vector2(182, 107)
	ring_inner.size = Vector2(42, 42)
	ring_inner.rotation = PI / 4.0
	ring_inner.color = Color(0.99, 0.985, 0.955, 0.78)
	ring_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	doll.add_child(ring_inner)

	doll.add_child(_build_character_preview_panel())
	_place_slot(doll, "left_arm", "L. Arm", Vector2(0, 18))
	_place_slot(doll, "right_arm", "R. Arm", Vector2(324, 18))
	_place_slot(doll, "body", "Torso", Vector2(0, 116))
	_place_slot(doll, "legs", "Legs", Vector2(324, 116))

	return doll


# Creates a droppable BoneSlotWidget on the paper doll and remembers it.
func _place_slot(doll: Control, slot: String, short_name: String, pos: Vector2) -> void:
	var widget := BoneSlotWidget.new()
	widget.position = pos
	widget.setup(slot, short_name, self)
	doll.add_child(widget)
	slot_widgets[slot] = widget


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
	if inventory_open:
		_update_inventory_ui()
		_sync_inventory_preview()
	inventory_root.visible = inventory_open
	get_tree().paused = inventory_open


# (Re)creates the draggable bone tiles. Called only when the collected set changes
# (a new bone), NOT on equip/unequip — so we never free a tile that's mid-drop.
func _rebuild_item_tiles() -> void:
	if items_grid == null:
		return

	for child in items_grid.get_children():
		child.free()

	# Only UNEQUIPPED bones appear as tiles — equipped ones have moved onto the body.
	var shown := 0
	for bone_id in bone_inventory:
		if not _bone_matches_inventory_category(bone_id):
			continue
		if has_bone_equipped(bone_id):
			continue
		var tile := BoneItemTile.new()
		tile.setup(bone_id, self)
		items_grid.add_child(tile)
		shown += 1

	var target_slots: int = 24
	for i in range(shown, target_slots):
		items_grid.add_child(_make_empty_inventory_slot())


func _bone_matches_inventory_category(bone_id: String) -> bool:
	if inventory_category == "all":
		return true
	var slot := BoneDatabase.slot(bone_id)
	if inventory_category == "right_arm":
		return slot == "right_arm" or slot == "left_arm"
	return slot == inventory_category


# Refreshes the paper-doll slots and each tile's tag, and updates the stats text.
func _update_inventory_ui() -> void:
	# Recolor each slot square from the current build.
	for slot in slot_widgets:
		var widget = slot_widgets[slot]
		if is_instance_valid(widget):
			widget.refresh()

	# Refresh each tile's "(worn)" tag. Tiles are only rebuilt when a NEW bone is
	# collected — never on equip/unequip — so we never free a tile mid-drop.
	if items_grid != null:
		for tile in items_grid.get_children():
			if tile.has_method("refresh"):
				tile.refresh()

	if inventory_label == null:
		return

	if inventory_status_label != null:
		inventory_status_label.text = "Bones " + str(bone_inventory.size())

	var text := "Stats: "
	text += "Speed " + str(move_speed)
	text += "   Reach " + str(attack_range)
	text += "   Damage " + str(attack_damage)
	text += "   HP " + str(health) + "/" + str(max_health) + "\n"
	text += "Drag a bone onto a matching slot. Right-click a worn bone slot to remove."
	inventory_label.text = text


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
