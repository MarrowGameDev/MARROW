extends CharacterBody3D

# Heavy bipedal crab ENEMY (assets/heavy_crab.glb — rigged, 41 bones).
#
# It ships an IDLE animation but NO walk clip, so it plays IDLE and travels via code
# (wander when the player is far, chase when close) with a procedural step-bob for life.
# It contact-damages the player and dies to the player's attacks. Matches the beach-crab
# enemy conventions: group "enemies", take_damage()/die(), take_player_damage() on contact.

const GLB: PackedScene = preload("res://assets/heavy_crab.glb")
const IDLE_CLIP := "IDLE animation"

@export var character_scale: float = 0.15
@export var max_health: int = 6
@export var contact_damage: int = 1
@export var move_speed: float = 1.8
@export var aggro_range: float = 6.0
@export var contact_range: float = 1.6
@export var wander_radius: float = 6.0
@export var turn_rate_deg: float = 150.0
@export var gravity: float = 24.0
@export var facing_offset_deg: float = 0.0     # set 180 if the crab faces away from travel
@export var step_bob: float = 0.10             # procedural body bob while moving (no walk clip)
@export var step_rate: float = 2.6
@export var tint: Color = Color(0.55, 0.4, 0.3, 1.0)

var alive := true
var health := 0
var _origin: Vector3
var _wander_off := Vector3.ZERO
var _repath := 0.0
var _model: Node3D
var _ap: AnimationPlayer
var _phase := 0.0
var _base_y := 0.0
var _grounded := false
var _gframe := 0
var _mats: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	# traverse uneven/unstable terrain
	floor_snap_length = 0.8
	floor_max_angle = deg_to_rad(55.0)
	floor_block_on_wall = false
	_origin = global_position
	_rng.seed = int(hash(name))
	_model = GLB.instantiate()
	add_child(_model)
	_model.scale = Vector3.ONE * character_scale
	_base_y = _model.position.y
	_apply_tint(_model)
	_ap = _find_ap(_model)
	if _ap != null and _ap.has_animation(IDLE_CLIP):
		_ap.get_animation(IDLE_CLIP).loop_mode = Animation.LOOP_LINEAR
		_ap.play(IDLE_CLIP)
		_ap.seek(_rng.randf() * _ap.get_animation(IDLE_CLIP).length, true)
	_pick_wander()


func _physics_process(delta: float) -> void:
	# skinned transforms are invalid on frame 0 — ground the model once they settle
	if not _grounded:
		_gframe += 1
		if _gframe >= 3:
			_ground_model()
			_grounded = true

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if not alive:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# target: the player when in aggro range, else a wander point
	var target: Vector3
	var player := _find_player()
	if player != null and global_position.distance_to(player.global_position) <= aggro_range:
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
	var moving := false
	if to_t.length() > 0.4:
		moving = true
		var dir := to_t.normalized()
		var target_yaw := atan2(dir.x, dir.z) + deg_to_rad(facing_offset_deg)
		rotation.y = _approach_angle(rotation.y, target_yaw, deg_to_rad(turn_rate_deg) * delta)
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# procedural step-bob for life (there's no walk clip to play)
	if moving:
		_phase += delta * step_rate * TAU
		_model.position.y = _base_y + step_bob * absf(sin(_phase))
	else:
		_model.position.y = lerpf(_model.position.y, _base_y, 0.15)

	move_and_slide()


func _pick_wander() -> void:
	var a := _rng.randf() * TAU
	var r := _rng.randf_range(1.5, wander_radius)
	_wander_off = Vector3(cos(a) * r, 0.0, sin(a) * r)
	_repath = _rng.randf_range(2.5, 5.0)


# --- combat -------------------------------------------------------------------

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

# Shift the model so its lowest point sits at this body's origin (the crab floats high in
# its own file), so it stands on the floor once the capsule lands. Measures the TRUE skinned
# geometry, not get_aabb() (the bind-pose box sits above where the rest pose actually is).
func _ground_model() -> void:
	var skel := _find_skel(_model)
	if skel == null:
		return
	var min_y := INF
	for m in _all_meshes(_model):
		var mi := m as MeshInstance3D
		if mi.skin == null or mi.mesh == null:
			continue
		min_y = minf(min_y, _skinned_min_y(mi, skel))
	if min_y != INF:
		_model.position.y -= min_y
		_base_y = _model.position.y


func _skinned_min_y(mi: MeshInstance3D, skel: Skeleton3D) -> float:
	var arr := mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var wts: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var skin := mi.skin
	if verts.is_empty() or bones.is_empty() or skin == null:
		return INF
	var mats: Array[Transform3D] = []
	for bi in skin.get_bind_count():
		var bone_idx := skin.get_bind_bone(bi)
		if bone_idx < 0:
			bone_idx = bi
		mats.append(skel.get_bone_global_pose(bone_idx) * skin.get_bind_pose(bi))
	var xf := global_transform.affine_inverse() * skel.global_transform
	var min_y := INF
	for vi in verts.size():
		var v := verts[vi]
		var sk := Vector3.ZERO
		var per := bones.size() / maxi(verts.size(), 1)   # this rig is 8 bones/vertex, not 4
		for j in per:
			var w := wts[vi * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[vi * per + j]] * v)
		min_y = minf(min_y, (xf * sk).y)
	return min_y


func _find_skel(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var r := _find_skel(c)
		if r != null:
			return r
	return null


func _apply_tint(n: Node) -> void:
	if n is MeshInstance3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = tint
		m.roughness = 0.8
		(n as MeshInstance3D).material_override = m
		_mats.append(m)
	for ch in n.get_children():
		_apply_tint(ch)


func _all_meshes(n: Node) -> Array:
	var out := []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out += _all_meshes(c)
	return out


func _find_player() -> Node3D:
	for p in get_tree().get_nodes_in_group("player"):
		if p is Node3D and is_instance_valid(p):
			return p as Node3D
	return null


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
