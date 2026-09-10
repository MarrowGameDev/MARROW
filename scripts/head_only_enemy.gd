extends CharacterBody3D

# A head-only ENEMY: the SAME procedural head animation as the player (head_only_controller.gd),
# but AI-driven. It wanders around its spawn point with the walk-hop, and can be headbutted —
# this replaces the old plain TargetBox dummies. Sits in the "enemies" group so the player's
# attack finds it; flashes + flinches on hit; pops out of existence at 0 HP.

const CONTROLLER: GDScript = preload("res://scripts/head_only_controller.gd")

@export var health: int = 3
@export var move_speed: float = 1.4            # slow amble (well under the player's walk)
@export var wander_radius: float = 3.5         # how far it strays from its spawn point
@export var pause_min: float = 0.8             # idle time between strolls (s)
@export var pause_max: float = 2.4
@export var character_scale: float = 0.18
@export var tint: Color = Color(0.85, 0.32, 0.30)   # ruddy enemy hue (player keeps its own look)
@export var gravity: float = 24.0

@export_group("Combat (fight back)")
@export var aggro_range: float = 6.5           # spots the player within this and gives chase
@export var attack_range: float = 1.6          # close enough to headbutt (stops + lunges)
@export var chase_speed: float = 2.3           # faster than the amble when hunting (player can still outrun by sprinting)
@export var attack_cooldown: float = 1.5       # min time between its headbutts (s)
@export var attack_power: int = 1              # damage per headbutt landed on the player

@export_group("Take command of the body")
@export var body_seek_range: float = 10.0      # will go hijack the player's body if this close to it & it's free
@export var takeover_dist: float = 2.4         # close enough to the body to start the orbit-in takeover

var _ctrl: Node3D                # the head_only_controller driving the look + animation
var _head_mat: StandardMaterial3D
var _alive := true
var _home := Vector3.ZERO
var _target := Vector3.ZERO
var _pausing := true
var _pause_t := 0.0
var _atk_cd := 0.0               # remaining cooldown before it can headbutt again
var _dock: Node3D                # the player's body (a claimable prize)
var _seeking := false            # heading for the free body to hijack it
var _taking_over := false        # orbiting into the neck socket right now (head controller drives)


func _ready() -> void:
	add_to_group(GameGroups.ENEMIES)
	collision_layer = 1
	collision_mask = 1
	floor_snap_length = 0.6

	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new(); cap.radius = 0.4; cap.height = 1.0
	cs.shape = cap; cs.position.y = 0.5
	add_child(cs)

	# same procedural head as the player, but deaf to the player's keys
	var vr := Node3D.new(); vr.name = "VisualRoot"; add_child(vr)
	_ctrl = CONTROLLER.new()
	_ctrl.name = "HeadOnlyController"
	_ctrl.set("character_scale", character_scale)
	_ctrl.set("read_attack_input", false)      # AI drives the headbutt via trigger_attack()
	_ctrl.set("read_jump_input", false)
	_ctrl.set("read_crouch_input", false)
	_ctrl.set("attack_damage", attack_power)   # its bite is gentler than the player's
	vr.add_child(_ctrl)
	_ctrl.connect("orbit_finished", _on_took_over)   # our head seated on the body -> hand it over

	_home = global_position
	_target = _home
	_pausing = true
	_pause_t = randf_range(pause_min, pause_max)
	call_deferred("_tint_head")


func _tint_head() -> void:
	var head := _find_mesh(_ctrl, "head")
	if head == null:
		return
	_head_mat = StandardMaterial3D.new()
	_head_mat.albedo_color = tint
	_head_mat.roughness = 0.8
	head.material_override = _head_mat


func _physics_process(delta: float) -> void:
	if not _alive:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	_atk_cd = maxf(0.0, _atk_cd - delta)

	# TAKEOVER: orbiting into the body's neck socket — the head controller owns the motion; freeze
	if _taking_over:
		velocity.x = 0.0; velocity.z = 0.0
		move_and_slide()
		return

	_update_seek()          # decide whether to go hijack the player's body

	# how far the player is (horizontal), if there is one
	var player := _get_player()
	var to_player := Vector3.ZERO
	var pdist := INF
	if player != null:
		to_player = player.global_position - global_position; to_player.y = 0.0
		pdist = to_player.length()

	var dir := Vector3.ZERO          # travel direction this frame
	var spd := move_speed
	var face := Vector3.ZERO          # where to turn (may differ from travel while planted-attacking)
	var attacking: bool = _ctrl != null and bool(_ctrl.get("_attack_active"))

	if attacking:
		# planted mid-headbutt: the lunge is driven by the controller — keep the body still but keep
		# aiming at the player so the ram connects
		face = to_player if pdist > 0.01 else Vector3.ZERO
	elif _seeking:
		# SEEK THE BODY: make for the neck socket, then start the orbit-in takeover once close
		var sock: Vector3 = _dock.global_position
		var to_body := Vector3(sock.x - global_position.x, 0.0, sock.z - global_position.z)
		face = to_body
		if to_body.length() <= takeover_dist:
			_begin_takeover()
			velocity.x = 0.0; velocity.z = 0.0
			move_and_slide()
			return
		dir = to_body.normalized()
		spd = chase_speed
	elif player != null and pdist < aggro_range:
		# AGGRO: hunt the player, then headbutt once in range
		face = to_player if pdist > 0.01 else Vector3.ZERO
		if pdist <= attack_range:
			if _atk_cd <= 0.0 and _ctrl != null and _ctrl.has_method("trigger_attack"):
				_ctrl.trigger_attack(1.0)      # same headbutt the player uses
				_atk_cd = attack_cooldown
		else:
			dir = to_player.normalized()
			spd = chase_speed
	else:
		# WANDER: stroll to a random point near home, idle a moment, pick a new one
		if _pausing:
			_pause_t -= delta
			if _pause_t <= 0.0:
				_pausing = false
				var ang := randf() * TAU
				var rad := sqrt(randf()) * wander_radius     # uniform over the disc
				_target = _home + Vector3(cos(ang) * rad, 0.0, sin(ang) * rad)
		else:
			var to := _target - global_position; to.y = 0.0
			if to.length() < 0.35:
				_pausing = true
				_pause_t = randf_range(pause_min, pause_max)
			else:
				dir = to.normalized()
		face = dir

	# drive the head-only animation exactly like the player does (hop-synced locomotion)
	var gate := 1.0
	if _ctrl != null:
		if _ctrl.has_method("set_move_intent"):
			_ctrl.set_move_intent(dir.length() * spd)
		if _ctrl.has_method("move_gate"):
			gate = _ctrl.move_gate()
	velocity.x = dir.x * spd * gate
	velocity.z = dir.z * spd * gate
	if face.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(face.x, face.z), 8.0 * delta)
	move_and_slide()


func _get_player() -> Node3D:
	var p := get_tree().get_first_node_in_group(GameGroups.PLAYER)
	return p as Node3D if p is Node3D else null


# Decide whether to go steal the player's body. Only ONE enemy claims at a time (the "body_claimant"
# group is the reservation), and only while the body is actually free.
func _update_seek() -> void:
	if _dock == null or not is_instance_valid(_dock):
		_dock = get_tree().get_first_node_in_group(GameGroups.PLAYER_BODY) as Node3D
	if _seeking:
		# keep seeking only while the body is still grabbable
		if _dock == null or not _dock.is_free():
			_stop_seeking()
		return
	if _dock == null or not _dock.is_free():
		return
	if not get_tree().get_nodes_in_group(GameGroups.BODY_CLAIMANT).is_empty():
		return   # someone else is already going for it
	var d := Vector3(_dock.global_position.x - global_position.x, 0.0, _dock.global_position.z - global_position.z).length()
	if d > body_seek_range:
		return
	# fair play: only snatch the body if we're closer to it than the player — they get first dibs
	var pl := _get_player()
	if pl != null:
		var pd := Vector3(_dock.global_position.x - pl.global_position.x, 0.0, _dock.global_position.z - pl.global_position.z).length()
		if d >= pd:
			return
	_seeking = true
	add_to_group(GameGroups.BODY_CLAIMANT)


func _begin_takeover() -> void:
	_seeking = false
	_taking_over = true
	if _dock != null and _dock.has_method("reserve"):
		_dock.reserve()                 # lock the player out while we orbit in
	if _ctrl != null and _ctrl.has_method("trigger_orbit_return"):
		_ctrl.trigger_orbit_return(_dock.global_position, _dock.socket_world(), _dock.global_rotation.y)


func _on_took_over() -> void:
	# our head seated on the neck — hand the body over to the enemy side and vanish (we ARE the body now)
	if _dock != null and is_instance_valid(_dock) and _dock.has_method("enemy_claim"):
		_dock.enemy_claim(self)
	if is_in_group(GameGroups.BODY_CLAIMANT):
		remove_from_group(GameGroups.BODY_CLAIMANT)
	queue_free()


func _stop_seeking() -> void:
	_seeking = false
	if is_in_group(GameGroups.BODY_CLAIMANT):
		remove_from_group(GameGroups.BODY_CLAIMANT)


# matches the box / enemy signature; the player's headbutt calls this on contact
func take_damage(amount: int, _from: Vector3 = Vector3.ZERO, _attacker: Node = null, _src: String = "") -> void:
	if not _alive:
		return
	health -= amount
	_flash()
	# flinch: freeze mid-stroll for a beat so the hit reads
	_pausing = true
	_pause_t = maxf(_pause_t, 0.3)
	if health <= 0:
		_die()


func _flash() -> void:
	if _head_mat == null:
		return
	_head_mat.albedo_color = Color(1, 1, 1)
	await get_tree().create_timer(0.10).timeout
	if is_instance_valid(self) and _alive and _head_mat != null:
		_head_mat.albedo_color = tint


func _die() -> void:
	_alive = false
	# give up any claim on the body so another enemy (or the player) can take it
	if is_in_group(GameGroups.BODY_CLAIMANT):
		remove_from_group(GameGroups.BODY_CLAIMANT)
	if _taking_over and _dock != null and is_instance_valid(_dock) and _dock.has_method("reservation_active") and _dock.reservation_active():
		_dock.release()
	remove_from_group(GameGroups.ENEMIES)
	collision_layer = 0
	collision_mask = 0
	GameEvents.enemy_defeated.emit(self, "")   # announce on the bus (no bone drop in this prototype)
	if _ctrl != null:
		_ctrl.set_process(false)   # stop the procedural squash so the pop tween owns the scale
		var t := create_tween()
		t.tween_property(_ctrl, "scale", Vector3.ZERO, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await t.finished
	queue_free()


func _find_mesh(n: Node, want: String) -> MeshInstance3D:
	if n is MeshInstance3D and (n as MeshInstance3D).name == want:
		return n as MeshInstance3D
	for c in n.get_children():
		var r := _find_mesh(c, want)
		if r != null:
			return r
	return null
