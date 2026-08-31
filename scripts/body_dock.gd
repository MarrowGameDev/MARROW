extends StaticBody3D

# A headless CRAB BODY left standing somewhere on the map. It is a CONTESTED RESOURCE:
#   - the PLAYER travels back and REATTACHES (reveal the head -> the full character stands here);
#   - an ENEMY head can also TAKE COMMAND of it (orbits in, seats its head) and turn it into a
#     full-body enemy sentinel that guards the spot and chomps the player who comes near.
#
# Responsibilities kept here: the body VISUAL (parts/head/tint), the neck SOCKET, GROUNDING, and
# OWNERSHIP. The possessed-body COMBAT (health + chomp decision) lives in BodySentinel, so this
# class stays single-purpose (AGENTS: "una responsabilidad", "separar deteccion, decision, feedback").
#
# NOTE: the whole-body-reassembles-from-pieces clip is a SEPARATE feature (enemies hiding in the
# environment and popping into being) — not this.

const GLB: PackedScene = preload("res://assets/crab_head_character_optimized.glb")
# everything the body has EXCEPT the head (the head is whoever seats it)
const BODY_PARTS := ["hips", "torso", "left arm", "right arm", "left leg", "right leg", "neck socket"]

enum Owner { NONE, PLAYER, CLAIMING, ENEMY }

@export var character_scale: float = 0.18
@export var tint: Color = Color(1, 1, 1, 1)

@export_group("When an enemy possesses the body")
@export var enemy_tint: Color = Color(0.85, 0.32, 0.30)   # its head shows this hue once hijacked
@export var body_health: int = 6                          # tougher than a lone head
@export var body_attack_range: float = 2.3                # chomps the player within this
@export var body_attack_cd: float = 1.8                   # seconds between chomps
@export var body_attack_power: int = 2                    # damage per chomp

var _model: Node3D
var _grounded := false
var _gframe := 0
var _base_y := 0.0
var _owner: Owner = Owner.NONE
var _head_mi: MeshInstance3D
var _head_mat: StandardMaterial3D    # override used to tint the head while enemy-possessed
var _sentinel: BodySentinel          # combat brain, present only while enemy-possessed


func _ready() -> void:
	add_to_group(GameGroups.PLAYER_BODY)     # enemies find the body through this group
	_model = GLB.instantiate()
	add_child(_model)
	scale = Vector3.ONE * character_scale
	_base_y = position.y
	var ap := _find_ap(_model)
	if ap != null and ap.is_playing():
		ap.stop()
	if tint != Color(1, 1, 1, 1):
		_apply_tint(_model)
	_head_mi = _find_mesh(_model, "head")
	_apply_visibility(_model)

	# Hurtbox — a valid target ONLY while an enemy is in the body (layer toggled in claim/release).
	# The root is scaled by character_scale, so the shape is sized in local units (÷ scale) to end
	# up ~0.45 m radius in world.
	collision_layer = 0
	collision_mask = 0
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.45 / character_scale
	cap.height = 1.7 / character_scale
	cs.shape = cap
	cs.position.y = 0.85 / character_scale
	add_child(cs)


func _process(_delta: float) -> void:
	# skinned transforms are invalid on frame 0 — ground the body (feet on floor) once they settle
	if not _grounded:
		_gframe += 1
		if _gframe < 3:
			return
		_ground_body()
		_grounded = true


# --- ownership API ------------------------------------------------------------------------------
func is_free() -> bool:
	return _owner == Owner.NONE


func is_enemy_held() -> bool:
	return _owner == Owner.ENEMY


# kept for compatibility with older callers / tests
func has_reattached() -> bool:
	return _owner == Owner.PLAYER


# The PLAYER seats its head — reveal the head, forming the whole character.
func reattach() -> void:
	_owner = Owner.PLAYER
	_untint_head()
	_apply_visibility(_model)


# The PLAYER hops back off — headless body again (only clears a player claim).
func detach() -> void:
	if _owner == Owner.PLAYER:
		_owner = Owner.NONE
	_apply_visibility(_model)


# An enemy has COMMITTED to taking the body (walking / orbiting in) — locks the player out.
func reserve() -> void:
	if _owner == Owner.NONE:
		_owner = Owner.CLAIMING


func reservation_active() -> bool:
	return _owner == Owner.CLAIMING


# An enemy seated its head — the body becomes an ENEMY sentinel (combat handed to BodySentinel).
func enemy_claim(by: Node = null) -> void:
	_owner = Owner.ENEMY
	_tint_head(enemy_tint)
	_apply_visibility(_model)
	collision_layer = 1                # now a valid attack target
	if not is_in_group(GameGroups.ENEMIES):
		add_to_group(GameGroups.ENEMIES)
	_sentinel = BodySentinel.new()
	_sentinel.name = "BodySentinel"
	add_child(_sentinel)
	_sentinel.setup(self, body_health, body_attack_range, body_attack_cd, body_attack_power)
	GameEvents.body_possessed.emit(self, by)


# Release the body back to "free" (possessor killed, or an aborted claim).
func release() -> void:
	_owner = Owner.NONE
	_untint_head()
	_apply_visibility(_model)
	collision_layer = 0
	if is_in_group(GameGroups.ENEMIES):
		remove_from_group(GameGroups.ENEMIES)
	if _sentinel != null and is_instance_valid(_sentinel):
		_sentinel.queue_free()
	_sentinel = null
	GameEvents.body_freed.emit(self)


# The player's headbutt lands here while an enemy holds the body — forward it to the combat brain.
func take_damage(amount: int, _from: Vector3 = Vector3.ZERO, _attacker: Node = null, _src: String = "") -> void:
	if _owner != Owner.ENEMY or _sentinel == null:
		return
	_sentinel.take_hit(amount)


# World point where the head seats (head mesh rest position on the body): centred horizontally,
# at the head's lowest point vertically. Used as the orbit's endpoint (player OR enemy).
func socket_world() -> Vector3:
	var skel := _find_skel(_model)
	if skel == null or _head_mi == null or _head_mi.skin == null or _head_mi.mesh == null:
		return global_position + Vector3(0.0, 1.3, 0.0)
	var arr := _head_mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var wts: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var skin := _head_mi.skin
	var mats: Array[Transform3D] = []
	for bi in skin.get_bind_count():
		var b := skin.get_bind_bone(bi)
		if b < 0:
			b = bi
		mats.append(skel.get_bone_global_pose(b) * skin.get_bind_pose(bi))
	var gt := skel.global_transform
	var sum := Vector3.ZERO
	var n := 0
	var min_y := INF
	var step := maxi(1, verts.size() / 400)   # sample for speed
	var i := 0
	while i < verts.size():
		var sk := Vector3.ZERO
		var per := bones.size() / maxi(verts.size(), 1)   # this rig is 8 bones/vertex, not 4
		for j in per:
			var w := wts[i * per + j]
			if w > 0.0001:
				sk += w * (mats[bones[i * per + j]] * verts[i])
		var wpos := gt * sk
		sum += wpos
		min_y = minf(min_y, wpos.y)
		n += 1
		i += step
	var c := sum / maxf(n, 1)
	return Vector3(c.x, min_y, c.z)


# --- visuals (feedback the BodySentinel asks for) -----------------------------------------------
func play_hit_flash() -> void:
	if _head_mat == null:
		return
	_head_mat.albedo_color = Color(1, 1, 1)
	await get_tree().create_timer(0.10).timeout
	if is_instance_valid(self) and _owner == Owner.ENEMY and _head_mat != null:
		_head_mat.albedo_color = enemy_tint


func play_chomp() -> void:
	# quick body squash-pulse as the attack tell
	var t := create_tween()
	t.tween_property(self, "scale", Vector3(character_scale * 1.1, character_scale * 0.85, character_scale * 1.1), 0.08)
	t.tween_property(self, "scale", Vector3.ONE * character_scale, 0.16)


func _apply_visibility(n: Node) -> void:
	var head_on := _owner == Owner.PLAYER or _owner == Owner.ENEMY
	if n is MeshInstance3D:
		var m := n as MeshInstance3D
		m.visible = BODY_PARTS.has(m.name) or (head_on and m.name == "head")
	for c in n.get_children():
		_apply_visibility(c)


func _tint_head(col: Color) -> void:
	if _head_mi == null:
		return
	if _head_mat == null:
		_head_mat = StandardMaterial3D.new()
		_head_mat.roughness = 0.8
	_head_mat.albedo_color = col
	_head_mi.material_override = _head_mat


func _untint_head() -> void:
	if _head_mi != null:
		_head_mi.material_override = null


# --- grounding: put the body's LOWEST skinned point (its feet) on the floor ---------------------
func _ground_body() -> void:
	var skel := _find_skel(_model)
	if skel == null:
		return
	var min_y := INF
	for m in _all_meshes(_model):
		var mi := m as MeshInstance3D
		if mi.skin == null or mi.mesh == null or not BODY_PARTS.has(mi.name):
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


func _find_mesh(n: Node, want: String) -> MeshInstance3D:
	if n is MeshInstance3D and (n as MeshInstance3D).name == want:
		return n as MeshInstance3D
	for c in n.get_children():
		var r := _find_mesh(c, want)
		if r != null:
			return r
	return null


func _all_meshes(n: Node) -> Array:
	var out := []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out += _all_meshes(c)
	return out


func _apply_tint(n: Node) -> void:
	if n is MeshInstance3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = tint
		m.roughness = 0.8
		(n as MeshInstance3D).material_override = m
	for c in n.get_children():
		_apply_tint(c)


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null
