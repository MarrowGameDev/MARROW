extends CharacterBody3D

# Crab creature-enemy (crab_walk.fbx + its rigged "sideways walk" clip). The clip is
# authored to travel along +X, so we play it FORWARD when the crab moves +X and
# REVERSED (negative speed_scale) when it moves -X — the crab scuttles both ways
# without spinning around. It patrols, chases + contact-damages the player when near,
# and dies to the player's attacks (in the "enemies" group, hittable on layer 1).

# The FBX was rigged with several armatures, so the walk is split into per-armature
# clips named "... |crab walk (sideways)". The single top-level "sideways walk" is
# only a static 1-key pose, so we merge the real per-part walk clips into one.
const WALK_SUBSTR := "crab walk"

static var _walk_anim: Animation = null   # merged full-body walk, shared by all crabs

@export var max_health: int = 2
@export var contact_damage: int = 1
@export var walk_speed: float = 1.1
@export var aggro_range: float = 3.5        # only chases when the player is close; otherwise wanders
@export var contact_range: float = 1.0
@export var wander_radius: float = 5.0
@export var turn_rate_deg: float = 120.0     # how fast it yaws to aim its side at the target
@export var gravity: float = 24.0
@export var tint: Color = Color(0.74, 0.34, 0.26, 1.0)

var alive: bool = true
var health: int = 0
var _origin: Vector3
var _dir: float = 1.0                         # +1 = travel +localX (fwd anim), -1 = -localX (reversed)
var _wander_off: Vector3 = Vector3.ZERO
var _repath: float = 0.0
var _ap: AnimationPlayer
var _mats: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_origin = global_position
	_rng.seed = int(hash(name))
	_apply_tint(self)
	_ap = _find_ap(self)
	if _ap != null:
		var clip := _build_walk(_ap)
		if clip != "":
			_ap.play(clip)
			_ap.seek(_rng.randf() * _ap.get_animation(clip).length, true)
	_pick_wander()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if not alive:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# Pick a target: the player when in aggro range, otherwise a wander point.
	var target: Vector3
	var player := _find_player()
	var chasing := false
	if player != null and global_position.distance_to(player.global_position) <= aggro_range:
		chasing = true
		target = player.global_position
		if global_position.distance_to(player.global_position) <= contact_range and player.has_method("take_player_damage"):
			player.take_player_damage(contact_damage, global_position)
	else:
		_repath -= delta
		if _repath <= 0.0 or global_position.distance_to(_origin + _wander_off) < 0.6:
			_pick_wander()
		target = _origin + _wander_off

	var to_t := target - global_position
	to_t.y = 0.0
	if to_t.length() > 0.1:
		var dir := to_t.normalized()
		var xaxis := global_transform.basis.x
		xaxis.y = 0.0
		if xaxis.length() > 0.01:
			xaxis = xaxis.normalized()
		# Choose which side (+X/-X) to scuttle with, with hysteresis so it doesn't flip-flop.
		var d := dir.dot(xaxis)
		if d > 0.25:
			_dir = 1.0
		elif d < -0.25:
			_dir = -1.0
		# Aim so (_dir * local X) points along dir; rotate gradually.
		var face := dir * _dir
		var target_yaw := atan2(-face.z, face.x)
		rotation.y = _approach_angle(rotation.y, target_yaw, deg_to_rad(turn_rate_deg) * delta)
		var move := global_transform.basis.x * (_dir * walk_speed)
		velocity.x = move.x
		velocity.z = move.z
		if _ap != null:
			_ap.speed_scale = _dir           # +1 forward, -1 reversed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func _pick_wander() -> void:
	var a := _rng.randf() * TAU
	var r := _rng.randf_range(1.5, wander_radius)
	_wander_off = Vector3(cos(a) * r, 0.0, sin(a) * r)
	_repath = _rng.randf_range(2.5, 5.0)


# --- combat -------------------------------------------------------------------

# Called by the player's attack hitbox (body.take_damage(amount, pos, attacker)).
func take_damage(amount: int, _hit_from: Vector3 = Vector3.ZERO, _attacker: Node = null, _damage_source: String = "") -> void:
	if not alive:
		return
	health -= amount
	_flash()
	if health <= 0:
		die()


func die() -> void:
	if not alive:
		return
	alive = false
	remove_from_group("enemies")
	if _ap != null:
		_ap.stop()
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _flash() -> void:
	for m in _mats:
		(m as StandardMaterial3D).albedo_color = Color(1, 1, 1)
	await get_tree().create_timer(0.08).timeout
	if not is_instance_valid(self):
		return
	for m in _mats:
		(m as StandardMaterial3D).albedo_color = tint


# --- helpers ------------------------------------------------------------------

func _apply_tint(n: Node) -> void:
	if n is MeshInstance3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = tint
		m.roughness = 0.75
		(n as MeshInstance3D).material_override = m
		_mats.append(m)
	for ch in n.get_children():
		_apply_tint(ch)


func _find_player() -> Node3D:
	var players := get_tree().get_nodes_in_group("player")
	for p in players:
		if p is Node3D and is_instance_valid(p):
			return p as Node3D
	return null


# Merge the per-armature "crab walk (sideways)" clips into one full-body looping
# animation and register it on this crab's player. Cached across all crabs.
func _build_walk(ap: AnimationPlayer) -> String:
	if _walk_anim == null:
		var sources: Array = []
		for n in ap.get_animation_list():
			if WALK_SUBSTR in n:
				sources.append(n)
		if sources.is_empty():
			return "sideways walk" if ap.has_animation("sideways walk") else ""
		var merged := Animation.new()
		var maxlen := 0.0
		for sn in sources:
			var src: Animation = ap.get_animation(sn)
			maxlen = maxf(maxlen, src.length)
			for i in range(src.get_track_count()):
				var ttype := src.track_get_type(i)
				var t := merged.add_track(ttype)
				merged.track_set_path(t, src.track_get_path(i))
				merged.track_set_interpolation_type(t, src.track_get_interpolation_type(i))
				for k in range(src.track_get_key_count(i)):
					var time := src.track_get_key_time(i, k)
					var val = src.track_get_key_value(i, k)
					# 3D transform tracks need typed inserts; track_insert_key ignores them.
					match ttype:
						Animation.TYPE_POSITION_3D:
							merged.position_track_insert_key(t, time, val)
						Animation.TYPE_ROTATION_3D:
							merged.rotation_track_insert_key(t, time, val)
						Animation.TYPE_SCALE_3D:
							merged.scale_track_insert_key(t, time, val)
						_:
							merged.track_insert_key(t, time, val)
		merged.length = maxlen
		merged.loop_mode = Animation.LOOP_LINEAR
		_walk_anim = merged
	var lib := AnimationLibrary.new()
	lib.add_animation("walk_full", _walk_anim)
	ap.add_animation_library("crabgen", lib)
	return "crabgen/walk_full"


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null


func _approach_angle(cur: float, target: float, max_step: float) -> float:
	var diff := wrapf(target - cur, -PI, PI)
	if absf(diff) <= max_step:
		return target
	return cur + signf(diff) * max_step
