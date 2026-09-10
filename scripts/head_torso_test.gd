extends Node3D

# PLAYABLE TEST for the HEAD+TORSO procedural creature — the assembly stage after head-only.
# It reuses the SAME squash/hop controller (head_only_controller.gd), just shown as the trunk
# (head + neck + torso + hips, no arms/legs) and tuned for a HEAVIER hop: bigger squash, slower
# cadence, and the torso weight dragging the arc down.
#
# Drive with W/A/S/D (camera-relative) · Shift sprint · Space jump · Left-click headbutt.

@export var head_move_speed: float = 2.6     # a lone head is LIGHT and quick
@export var body_move_speed: float = 1.7     # once the torso is on, it's a heavier amble
@export var sprint_multiplier: float = 1.9
@export var gravity: float = 24.0
@export var scatter_speed: float = 2.6       # crouch: how hard the parts burst outward so they spread apart
@export var scatter_pop: float = 2.0         # crouch: upward kick on the burst so they arc out and land scattered

@onready var _body: CharacterBody3D = $Body
var move_speed := 2.6         # active walk speed — starts nimble, drops to body_move_speed once assembled
var _ctrl: Node
var _cam_ctrl: Node3D
var _crawling := false        # crouch-crawl: head-only + detached parts rolling behind
var _standing := false        # crouch released: the parts are flying back up into the body
var _trail_parts: Array = []  # the detached parts trailing the head


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

	# same third-person camera as the main game, fixed to the character
	var pivot := Node3D.new()
	pivot.name = "CameraPivot"
	pivot.set_script(load("res://scripts/player_camera_controller.gd"))
	var arm := SpringArm3D.new()
	arm.name = "SpringArm3D"; arm.spring_length = 4.5; arm.margin = 0.25; arm.collision_mask = 1
	pivot.add_child(arm)
	var cam := Camera3D.new(); cam.name = "Camera3D"; cam.fov = 52.0; cam.current = true
	arm.add_child(cam)
	pivot.set("pivot_height", 0.7)            # a touch higher to frame the taller body
	pivot.set("initial_zoom_distance", 4.5)
	_body.add_child(pivot)
	_cam_ctrl = pivot

	_ctrl = find_child("HeadTorso", true, false)
	# start already ASSEMBLED (head + torso), no parts to collect
	_on_body_complete()

	# HUD: player life — a row of bones that break then empty right -> left (self-wired to GameEvents)
	var layer := CanvasLayer.new(); add_child(layer)
	var bones := Control.new()
	bones.set_script(load("res://scripts/bone_health_hud.gd"))
	bones.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bones)

	# training dummies to headbutt (they flash + wobble on hit, never die)
	for dp in [Vector3(2.4, 0.0, -3.4), Vector3(-3.6, 0.0, -2.2)]:
		var d = load("res://scripts/training_dummy.gd").new()
		add_child(d)
		d.global_position = dp


func _process(delta: float) -> void:
	if _ctrl == null:
		return
	# crouch-crawl: the head goes head-only and the detached parts roll along behind it. When crouch is
	# released the parts fly back up into the body (stand-up) instead of just popping away.
	var crawling: bool = _ctrl.has_method("is_crouch_crawling") and _ctrl.is_crouch_crawling()
	var crouching: bool = _ctrl.has_method("is_crouching") and _ctrl.is_crouching()
	if crawling and not _crawling:
		_start_crawl()
	elif not crawling and _crawling:
		_end_crawl()
	if _crawling:
		if crouching:
			_standing = false
			_update_crawl(delta)          # on the ground, chasing/rolling behind the head
		else:
			if not _standing:
				_standing = true
				_begin_standup()          # crouch released -> reassemble: parts fly home to their seats
			_update_standup()


# --- crouch-crawl: detach the torso/hips/neck and roll them behind the head-only head ------------
func _start_crawl() -> void:
	_crawling = true
	_standing = false
	_trail_parts = []
	var parts: Array = _ctrl.crouch_trail_parts()   # [neck socket, torso, hips] — chain order
	var n: int = parts.size()
	var brot: Quaternion = _ctrl.global_transform.basis.get_rotation_quaternion()   # the body's facing
	for idx in range(n):
		var pn: String = parts[idx]
		var tp = load("res://scripts/trailing_part.gd").new()
		tp.set("part_name", pn)
		add_child(tp)
		tp.global_position = _ctrl.part_socket_world(pn)   # spawn at the seat ON the body...
		tp.call("face_body", brot)                         # ...matching its orientation (no swap pop)...
		# ...then burst outward in a spread direction so they scatter instead of piling up as they fall
		var a: float = float(idx) * TAU / float(maxi(n, 1)) + randf_range(-0.6, 0.6)
		tp.call("launch_scatter", Vector3(cos(a), 0.0, sin(a)) * scatter_speed, scatter_pop)
		_trail_parts.append(tp)
	_ctrl.call("set_body_hidden", true)   # hide the body NOW that the parts exist -> seamless swap


func _update_crawl(_delta: float) -> void:
	var leader: Vector3 = _ctrl.part_socket_world("head")
	leader.y = 0.15
	for tp in _trail_parts:
		if is_instance_valid(tp):
			tp.follow(leader, _delta)
			leader = tp.global_position   # each part trails the one in front


func _end_crawl() -> void:
	_crawling = false
	_standing = false
	_ctrl.call("set_body_hidden", false)   # show the body the same frame the parts (now home) despawn
	for tp in _trail_parts:
		if is_instance_valid(tp):
			tp.queue_free()
	_trail_parts = []


# crouch released -> record where each part lies so it can arc home to its body seat
func _begin_standup() -> void:
	for tp in _trail_parts:
		if is_instance_valid(tp) and tp.has_method("begin_return"):
			tp.begin_return()


# fly each part from the ground back up into its seat on the body, timed to the head's rise
func _update_standup() -> void:
	var t: float = 1.0 - _ctrl.crouch_phase()   # 0 at release .. 1 fully home/standing
	var brot: Quaternion = _ctrl.global_transform.basis.get_rotation_quaternion()   # land facing the body
	for tp in _trail_parts:
		if is_instance_valid(tp) and tp.has_method("return_to"):
			tp.return_to(_ctrl.part_socket_world(tp.part()), brot, t)


# Body fully assembled: keep the SAME walk speed AND hop/fall cadence as the lone head (don't lumber).
# We deliberately leave the controller's hop params (hop_rate, rise_frac, hop_height, ...) at the
# head-only defaults so the walk and the falling rate match the head exactly.
func _on_body_complete() -> void:
	move_speed = head_move_speed
	# turn the hips skirt into verlet cloth now that the body is on
	var cloth = load("res://scripts/cloth_verlet.gd").new()
	add_child(cloth)
	cloth.call("setup", _ctrl)
	_ctrl.call("request_settle")   # seat the hips on the floor once it settles (stop levitating)


func _physics_process(delta: float) -> void:
	if not _body.is_on_floor():
		_body.velocity.y -= gravity * delta
	else:
		_body.velocity.y = 0.0

	var iv := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# camera-relative: W goes where the camera faces
	var dir := Vector3(iv.x, 0.0, iv.y)
	if _cam_ctrl != null and _cam_ctrl.has_method("get_flat_forward"):
		dir = _cam_ctrl.get_flat_forward() * (-iv.y) + _cam_ctrl.get_flat_right() * iv.x

	var spd := move_speed
	if Input.is_action_pressed("sprint"):
		spd *= sprint_multiplier

	# hop-synced locomotion (the controller hands back how far it'll travel this frame)
	var gate := 1.0
	if _ctrl != null:
		if _ctrl.has_method("set_move_intent"):
			_ctrl.set_move_intent(dir.length() * spd)
		if _ctrl.has_method("move_gate"):
			gate = _ctrl.move_gate()
	_body.velocity.x = dir.x * spd * gate
	_body.velocity.z = dir.z * spd * gate
	# don't fight the headbutt's aim-steer during the CHARGE windup; once the head has detached the body
	# is free to walk/turn normally (the head fights on its own at its anchor)
	var charging: bool = _ctrl != null and _ctrl.has_method("is_charging") and _ctrl.is_charging()
	if dir.length() > 0.1 and not charging:
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(dir.x, dir.z), 9.0 * delta)
	_body.move_and_slide()
