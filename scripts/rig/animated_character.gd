class_name AnimatedCharacter
extends Node3D

# Drop-in VISIBLE body for the player and enemies. Mounts main_character.glb and plays
# the CHARACTER'S OWN animation clips if the exported model ships an AnimationPlayer
# (like the crab does). There is NO procedural posing or retargeting here — if the
# model has no animations it simply stands in its rest pose until an animated export
# is provided. Part-mesh visibility (head-only -> +torso -> limbs) is kept for the
# detachment/equipment system, and jump/attack are forwarded as clip triggers.

const CHARACTER: PackedScene = preload("res://assets/main_character.glb")

@export var character_scale: float = 1.9
@export var foot_offset_y: float = -0.92
@export var hide_sibling_rig: bool = true
@export var body_tint: Color = Color(1, 1, 1, 1)
# Assembly: start showing only the head, then reveal the torso when it's picked up.
@export var start_as_head: bool = false
@export var head_only_y: float = -2.05
@export var head_torso_y: float = -1.5

var _model: Node3D
var _skel: Skeleton3D
var _ap: AnimationPlayer            # the model's OWN player, if it ships one
var _body: Node3D
var _disabled := false
var _head_meshes: Array = []
var _torso_meshes: Array = []
var _limb_meshes: Array = []


func _ready() -> void:
	var model := CHARACTER.instantiate()
	add_child(model)
	_model = model
	_skel = _find_skeleton(model)
	if _skel == null:
		push_warning("AnimatedCharacter: no Skeleton3D in main_character.glb")
		return
	scale = Vector3.ONE * character_scale
	position.y = foot_offset_y
	if body_tint != Color(1, 1, 1, 1):
		_apply_tint(model, body_tint)

	# Play the model's own looping locomotion clip if the export ships one.
	_ap = _find_ap(model)
	if _ap != null:
		var clip := _native_clip(["walk", "idle", "loop"])
		if clip == "" and not _ap.get_animation_list().is_empty():
			clip = _ap.get_animation_list()[0]
		if clip != "":
			var a := _ap.get_animation(clip)
			if a != null:
				a.loop_mode = Animation.LOOP_LINEAR
			_ap.play(clip)

	_body = _find_body(self)
	if hide_sibling_rig:
		_hide_old_rig()
	_categorize_parts(model)
	if start_as_head:
		show_only_head()


# ---- hooks forwarded from the owning body -------------------------------------

func trigger_jump() -> void:
	_play_once(["jump"])


func trigger_attack() -> void:
	_play_once(["attack", "swipe", "hit", "melee"])


func set_aiming(_enabled: bool) -> void:
	pass


func skeleton() -> Skeleton3D:
	return _skel


# Play a one-off clip (jump/attack) if the model provides a matching one.
func _play_once(names: Array) -> void:
	if _ap == null or _disabled:
		return
	var clip := _native_clip(names)
	if clip != "":
		_ap.play(clip)


# First native animation whose name contains any of `names` (case-insensitive).
func _native_clip(names: Array) -> String:
	if _ap == null:
		return ""
	for a in _ap.get_animation_list():
		var low := String(a).to_lower()
		for want in names:
			if String(want).to_lower() in low:
				return a
	return ""


func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for c in n.get_children():
		var f := _find_ap(c)
		if f != null:
			return f
	return null


# ---- body-part assembly (head -> +torso) --------------------------------------

func _categorize_parts(model: Node) -> void:
	_head_meshes.clear(); _torso_meshes.clear(); _limb_meshes.clear()
	for mi in _all_meshes(model):
		var n := String(mi.name).to_lower()
		if "rib" in n or "spine" in n or "hip" in n or "solar" in n or "shoulder" in n or "pelvis" in n or "neck" in n:
			_torso_meshes.append(mi)
		elif "skull" in n or "teeth" in n or "head" in n or "jaw" in n:
			_head_meshes.append(mi)
		else:
			_limb_meshes.append(mi)


func show_only_head() -> void:
	_set_visible(_head_meshes, true)
	_set_visible(_torso_meshes, false)
	_set_visible(_limb_meshes, false)
	position.y = head_only_y


func reveal_torso() -> void:
	_set_visible(_torso_meshes, true)
	position.y = head_torso_y


func show_all_parts() -> void:
	_set_visible(_head_meshes, true)
	_set_visible(_torso_meshes, true)
	_set_visible(_limb_meshes, true)
	position.y = foot_offset_y


func head_mesh_names() -> Array:
	return _head_meshes.map(func(m): return String(m.name))


func torso_mesh_names() -> Array:
	return _torso_meshes.map(func(m): return String(m.name))


func _set_visible(meshes: Array, v: bool) -> void:
	for m in meshes:
		if is_instance_valid(m):
			(m as MeshInstance3D).visible = v


func _all_meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_all_meshes(c))
	return out


# ---- enemy variants that keep their own visual -------------------------------

func disable() -> void:
	_disabled = true
	set_process(false)
	if _model != null:
		_model.queue_free()
		_model = null
	var vr := get_parent()
	if vr != null:
		for c in vr.get_children():
			if c != self and c is Node3D:
				(c as Node3D).visible = true


func is_disabled() -> bool:
	return _disabled


func set_body_tint(c: Color) -> void:
	body_tint = c
	if _model != null:
		_apply_tint(_model, c)


# ---- helpers ------------------------------------------------------------------

func _hide_old_rig() -> void:
	var vr := get_parent()
	if vr == null:
		return
	for c in vr.get_children():
		if c == self:
			continue
		if c is Node3D:
			(c as Node3D).visible = false


func _apply_tint(n: Node, c: Color) -> void:
	if n is MeshInstance3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		(n as MeshInstance3D).material_override = m
	for ch in n.get_children():
		_apply_tint(ch, c)


func _find_body(n: Node) -> Node3D:
	var p := n.get_parent()
	while p != null:
		if p is CharacterBody3D:
			return p as Node3D
		p = p.get_parent()
	return null


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for c in n.get_children():
		var f := _find_skeleton(c)
		if f != null:
			return f
	return null
