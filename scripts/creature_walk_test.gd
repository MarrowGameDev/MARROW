extends Node3D

# PLAYABLE TEST for the procedural creature walker (crab-head character).
# Run this scene and drive with W / A / S / D — watch the procedural walk.
# The Crab + CreatureWalker live in the scene tree, so you can SELECT the
# CreatureWalker node in the Scene dock and tune its exports live
# (swing_axis, foot_swing_deg, hand_swing_deg, hip_swing_deg, ...).

@export var move_speed: float = 2.0
@export var sprint_multiplier: float = 2.0   # hold Shift (sprint) to RUN
@export var crouch_speed_mult: float = 0.45  # hold Ctrl (crouch) to sneak slower
@export var gravity: float = 24.0
@export var reattach_range: float = 3.0      # how close the head must be to the body to reattach (prompt + R)

@onready var _crab: CharacterBody3D = $Crab
var _head: Node
var _cam: Camera3D              # the game's Camera3D (under the PlayerCameraController spring arm)
var _cam_ctrl: Node3D           # the PlayerCameraController pivot (for camera-relative movement)
var _dock: Node3D               # the headless body waiting on the map (press R to return + reattach)
var _orbiting := false          # the head is spiralling into the body's socket to reattach
var _detaching := false         # the head is leaping off the neck back to head-only
var _reattached := false
var _r_prev := false            # edge-detect the R key so a hold doesn't toggle repeatedly
var _reattach_prompt: Label     # on-screen "Press R to reattach" hint
var _hp_fill: ColorRect         # player health bar fill (top-left)
var _dmg_flash: ColorRect       # full-screen red flash when the player is hit


func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.46, 0.6, 0.74)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.85, 0.85)
	env.ambient_light_energy = 0.6
	var we := WorldEnvironment.new(); we.environment = env; add_child(we)

	var l := DirectionalLight3D.new()
	l.rotation_degrees = Vector3(-50, -35, 0)
	l.light_energy = 2.0; l.shadow_enabled = true; add_child(l)

	# ground
	var gb := StaticBody3D.new(); add_child(gb)
	var gm := MeshInstance3D.new(); var pm := PlaneMesh.new(); pm.size = Vector2(60, 60); gm.mesh = pm
	var mat := StandardMaterial3D.new(); mat.albedo_color = Color(0.5, 0.6, 0.42); gm.material_override = mat
	gb.add_child(gm)
	var cs := CollisionShape3D.new(); var bs := BoxShape3D.new(); bs.size = Vector3(60, 0.2, 60)
	cs.shape = bs; cs.position.y = -0.1; gb.add_child(cs)

	# Use the SAME third-person camera as the main game: PlayerCameraController on a pivot that is
	# a child of the character, with a SpringArm3D + Camera3D. It stays fixed to the character
	# (smoothed follow + collision) and orbits with the mouse. Build the children BEFORE adding the
	# pivot to the tree so the controller's _ready finds them and picks up the Crab as its target.
	var pivot := Node3D.new()
	pivot.name = "CameraPivot"
	pivot.set_script(load("res://scripts/player_camera_controller.gd"))
	var arm := SpringArm3D.new()
	arm.name = "SpringArm3D"
	arm.spring_length = 4.0
	arm.margin = 0.25
	arm.collision_mask = 1
	pivot.add_child(arm)
	_cam = Camera3D.new()
	_cam.name = "Camera3D"
	_cam.fov = 52.0
	_cam.current = true
	arm.add_child(_cam)
	pivot.set("pivot_height", 0.5)            # lower pivot to frame the small head
	pivot.set("initial_zoom_distance", 4.0)
	_crab.add_child(pivot)
	_cam_ctrl = pivot                          # for camera-relative movement

	_head = find_child("HeadOnlyController", true, false)
	if _head != null and _head.has_signal("orbit_finished"):
		_head.orbit_finished.connect(_reattach)   # head seated in the socket -> form the character
	if _head != null and _head.has_signal("detach_finished"):
		_head.detach_finished.connect(_on_detach_done)   # head landed -> head-only resumes

	# the player's headless BODY, left standing somewhere on the map — press R to run back and reattach
	_dock = load("res://scripts/body_dock.gd").new()
	add_child(_dock)
	_dock.global_position = Vector3(2.0, 0.0, -6.0)

	# charge meter — a 2/5-circle arc gauge, shown right of screen centre while holding Left-click
	var layer := CanvasLayer.new(); add_child(layer)

	# full-screen red flash when the player takes a hit (added first so the HUD draws over it)
	_dmg_flash = ColorRect.new()
	_dmg_flash.color = Color(0.8, 0.05, 0.05, 0.0)
	_dmg_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dmg_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_dmg_flash)

	# player health bar (top-left): dark backing + coloured fill (green full -> red low)
	var hp_bg := ColorRect.new()
	hp_bg.color = Color(0, 0, 0, 0.5)
	hp_bg.position = Vector2(24, 22); hp_bg.size = Vector2(264, 26)
	hp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hp_bg)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.3, 0.85, 0.35)
	_hp_fill.position = Vector2(28, 26); _hp_fill.size = Vector2(256, 18)
	_hp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_hp_fill)

	# listen on the GameEvents bus for the player's combat state (HUD / flash / respawn)
	GameEvents.player_health_changed.connect(_on_player_health)
	GameEvents.player_damaged.connect(_on_player_damaged)
	GameEvents.player_died.connect(_on_player_died)

	# "Press R to reattach" hint — shown until the head is back on the body
	_reattach_prompt = Label.new()
	_reattach_prompt.text = "Press R to reattach"
	_reattach_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reattach_prompt.add_theme_font_size_override("font_size", 26)
	_reattach_prompt.add_theme_color_override("font_color", Color(1, 1, 1))
	_reattach_prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_reattach_prompt.add_theme_constant_override("outline_size", 7)
	_reattach_prompt.visible = false
	layer.add_child(_reattach_prompt)


func _physics_process(delta: float) -> void:
	if not _crab.is_on_floor():
		_crab.velocity.y -= gravity * delta
	else:
		_crab.velocity.y = 0.0
	# R is edge-triggered (a press, not a hold) and TOGGLES: attach when off the body & in range,
	# hop off when on the body.
	var r_now := Input.is_physical_key_pressed(KEY_R)
	var r_pressed := r_now and not _r_prev
	_r_prev = r_now

	# while the head is spiralling in / hopping off it drives itself — the body just stays put
	if _orbiting or _detaching:
		_crab.velocity.x = 0.0
		_crab.velocity.z = 0.0
		_crab.move_and_slide()
		return

	if r_pressed and _dock != null:
		if _reattached:
			_detach()                                         # on the body -> hop off, back to head mode
		elif _crab_to_dock().length() < reattach_range and _dock.is_free() and _head != null and _head.has_method("trigger_orbit_return"):
			_orbiting = true                                  # off the body, in range & unclaimed -> orbit in
			_head.trigger_orbit_return(_dock.global_position, _dock.socket_world(), _dock.global_rotation.y)

	var iv := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# camera-relative: W goes where the camera faces, D is the camera's right (same length as iv)
	var dir := Vector3(iv.x, 0.0, iv.y)
	if _cam_ctrl != null and _cam_ctrl.has_method("get_flat_forward"):
		dir = _cam_ctrl.get_flat_forward() * (-iv.y) + _cam_ctrl.get_flat_right() * iv.x
	var sprinting := Input.is_action_pressed("sprint")

	var spd := move_speed
	if _head != null and _head.has_method("is_crouching") and _head.is_crouching():
		spd *= crouch_speed_mult   # crouch: sneak slower (and the wobble slows to match)
	elif sprinting:
		spd *= sprint_multiplier   # hold Shift to run

	# Hop-synced locomotion: tell the head how fast we WANT to move, and only translate the
	# body by the gate it hands back — so the head glides forward while airborne and sits still
	# (recoiling in place) while planted on the floor.
	var gate := 1.0
	if _head != null:
		if _head.has_method("set_move_intent"):
			_head.set_move_intent(dir.length() * spd)
		if _head.has_method("move_gate"):
			gate = _head.move_gate()
	_crab.velocity.x = dir.x * spd * gate
	_crab.velocity.z = dir.z * spd * gate
	if dir.length() > 0.1:
		_crab.rotation.y = lerp_angle(_crab.rotation.y, atan2(dir.x, dir.z), 10.0 * delta)
	_crab.move_and_slide()


func _process(_delta: float) -> void:
	# The camera follows the character on its own (PlayerCameraController). Here we only drive
	# the on-screen UI (charge meter + R prompt).

	# (the headbutt charge meter is now drawn by the head controller itself, so it shows in
	# every scene — not just this harness)

	# R prompt — "hop off" when on the body, "reattach" when off it and in range
	if _reattach_prompt != null:
		var show := false
		if _dock != null and not _orbiting and not _detaching:
			if _reattached:
				_reattach_prompt.text = "Press R to hop off"
				show = true
			elif _crab_to_dock().length() < reattach_range:
				if _dock.is_free():
					_reattach_prompt.text = "Press R to reattach"
					show = true
				elif _dock.is_enemy_held():
					_reattach_prompt.text = "An enemy took your body — defeat it to reclaim it!"
					show = true
		_reattach_prompt.visible = show
		if show:
			var vp := get_viewport().get_visible_rect().size
			_reattach_prompt.size = Vector2(vp.x, 44)
			_reattach_prompt.position = Vector2(0, vp.y - 76)


func _on_player_health(_player: Node, hp: int, max_hp: int) -> void:
	if _hp_fill == null:
		return
	var ratio := float(hp) / float(maxi(max_hp, 1))
	_hp_fill.size.x = 256.0 * ratio
	_hp_fill.color = Color(0.85, 0.28, 0.28).lerp(Color(0.3, 0.85, 0.35), ratio)


func _on_player_damaged(_player: Node, _amount: int, _source: Node) -> void:
	if _dmg_flash == null:
		return
	_dmg_flash.color.a = 0.45
	var t := create_tween()
	t.tween_property(_dmg_flash, "color:a", 0.0, 0.35)


func _on_player_died(_player: Node) -> void:
	# simple respawn: back to the start, full health, cleanly in head-only mode
	_orbiting = false
	_detaching = false
	if _reattached and _dock != null and _dock.has_method("detach"):
		_dock.detach()
	_reattached = false
	var vr := _crab.get_node_or_null("VisualRoot")
	if vr != null:
		(vr as Node3D).visible = true
	_crab.velocity = Vector3.ZERO
	_crab.global_position = Vector3(0, 0.2, 0)
	if _crab.has_method("heal_full"):
		_crab.heal_full()


# Horizontal (XZ) offset from the head to its waiting body.
func _crab_to_dock() -> Vector3:
	if _dock == null or _crab == null:
		return Vector3(1e9, 0, 0)
	var to := _dock.global_position - _crab.global_position
	to.y = 0.0
	return to


func _reattach() -> void:
	# the head seated in the socket — reveal the body's head (full character) and hide the
	# travelling head so it reads as the head snapping back on.
	_orbiting = false
	_reattached = true
	if _dock != null and _dock.has_method("reattach"):
		_dock.reattach()
	var vr := _crab.get_node_or_null("VisualRoot")
	if vr != null:
		(vr as Node3D).visible = false


func _detach() -> void:
	# hop the head OFF the body: strip the body's head (headless again), show the travelling head,
	# drop the body onto the ground beside itself, and leap the head off the neck.
	_reattached = false
	_detaching = true
	if _dock != null and _dock.has_method("detach"):
		_dock.detach()
	var vr := _crab.get_node_or_null("VisualRoot")
	if vr != null:
		(vr as Node3D).visible = true
	# land the head on the ground a little in front of the body
	var land := _dock.global_position + Vector3(0.0, 0.0, 2.0)
	_crab.global_position = Vector3(land.x, 0.2, land.z)
	# face the head AWAY from the body (toward where it's leaping), so at the end of the hop it
	# isn't looking back at the body it just left
	var away := land - _dock.global_position
	_crab.rotation.y = atan2(away.x, away.z)
	if _head != null and _head.has_method("trigger_detach"):
		_head.trigger_detach(_dock.socket_world())


func _on_detach_done() -> void:
	_detaching = false   # head-only takes over from here
