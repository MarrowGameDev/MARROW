class_name ModularSkeletonRig
extends Node3D

# Code-only modular rig (Marrow rigging brief, Phase A/C).
# Builds empty Node3D sockets and hangs a grey-box "limb" on each so the figure
# is visible. The ProceduralAnimator animates the SOCKETS; equipped bones are
# children of sockets, so they inherit the motion automatically.

# Socket local positions, roughly a 1.6 m figure centered on the player capsule.
static var SOCKET_LAYOUT := {
	"body": Vector3(0.0, 0.0, 0.0),
	"head": Vector3(0.0, 0.62, 0.0),
	"right_arm": Vector3(0.28, 0.30, 0.0),
	"left_arm": Vector3(-0.28, 0.30, 0.0),
	"right_leg": Vector3(0.16, -0.35, 0.0),
	"left_leg": Vector3(-0.16, -0.35, 0.0),
}

# Feet are parented UNDER their leg socket, so they swing WITH the leg (they
# follow the legs instead of being planted independently). Positions are local
# to the leg socket.
static var FOOT_UNDER_LEG := {
	"left_foot": {"leg": "left_leg", "pos": Vector3(0.0, -0.58, 0.06)},
	"right_foot": {"leg": "right_leg", "pos": Vector3(0.0, -0.58, 0.06)},
}

# Grey-box geometry per socket: box size + local offset so arms/legs hang DOWN
# from the shoulder/hip socket (so rotating the socket swings them naturally).
static var LIMB_GEO := {
	"body": {"size": Vector3(0.5, 0.7, 0.28), "offset": Vector3(0.0, 0.0, 0.0)},
	"head": {"size": Vector3(0.32, 0.32, 0.32), "offset": Vector3(0.0, 0.02, 0.0)},
	"right_arm": {"size": Vector3(0.16, 0.58, 0.16), "offset": Vector3(0.0, -0.29, 0.0)},
	"left_arm": {"size": Vector3(0.16, 0.58, 0.16), "offset": Vector3(0.0, -0.29, 0.0)},
	"right_leg": {"size": Vector3(0.18, 0.62, 0.18), "offset": Vector3(0.0, -0.31, 0.0)},
	"left_leg": {"size": Vector3(0.18, 0.62, 0.18), "offset": Vector3(0.0, -0.31, 0.0)},
	"right_foot": {"size": Vector3(0.2, 0.12, 0.34), "offset": Vector3(0.0, 0.0, 0.05)},
	"left_foot": {"size": Vector3(0.2, 0.12, 0.34), "offset": Vector3(0.0, 0.0, 0.05)},
}

# Per-part placement for the rigged model's limb meshes: which socket, and the
# local scale + rotation to line each part up. Feet are smaller and turned
# forward (they came in big + sideways). Tune these values as needed.
static var RIGGED_LIMBS := {
	"right arm": {"socket": "right_arm", "scale": Vector3(2.3, 2.3, 2.3), "rot": Vector3(180.0, 0.0, 0.0)},
	"left arm": {"socket": "left_arm", "scale": Vector3(2.3, 2.3, 2.3), "rot": Vector3(180.0, 0.0, 0.0)},
	"right leg": {"socket": "right_leg", "scale": Vector3(2.3, 2.3, 2.3), "rot": Vector3(180.0, 0.0, 0.0)},
	"left leg": {"socket": "left_leg", "scale": Vector3(2.3, 2.3, 2.3), "rot": Vector3(180.0, 0.0, 0.0)},
	"left foot": {"socket": "left_foot", "scale": Vector3(0.25, 0.25, 0.25), "rot": Vector3(-90.0, 180.0, 0.0)},
	"right foot": {"socket": "right_foot", "scale": Vector3(0.25, 0.25, 0.25), "rot": Vector3(-90.0, 180.0, 0.0)},
}

const BASE_COLOR := Color(0.62, 0.62, 0.70)
const BODY_HITBOX_GROUP := "body_part_hitboxes"
const PLAYER_BODY_HITBOX_GROUP := "player_body_hurtboxes"
const ENEMY_BODY_HITBOX_GROUP := "enemy_body_hurtboxes"
const DAMAGE_HITBOX_GROUPS := [PLAYER_BODY_HITBOX_GROUP, ENEMY_BODY_HITBOX_GROUP]
const MIN_HITBOX_SIZE := Vector3(0.08, 0.08, 0.08)
const ENEMY_HITBOX_ACCURACY_SCALE := {
	"body": Vector3(0.90, 0.92, 0.90),
	"head": Vector3(0.88, 0.88, 0.88),
	"right_arm": Vector3(0.80, 0.96, 0.80),
	"left_arm": Vector3(0.80, 0.96, 0.80),
	"right_leg": Vector3(0.82, 0.96, 0.82),
	"left_leg": Vector3(0.82, 0.96, 0.82),
	"right_foot": Vector3(0.90, 0.84, 0.94),
	"left_foot": Vector3(0.90, 0.84, 0.94),
}

# Optional: show a real 3D model as the whole body instead of grey boxes.
# The model is a single un-rigged mesh, so it gets whole-body motion (the grey
# limbs are hidden). Adjust the transform to stand it up correctly.
@export var use_skeleton_model := false
@export var skeleton_model_scene: PackedScene
@export var skeleton_scale := 1.7
@export var skeleton_rotation_deg := Vector3(-90.0, 0.0, 0.0)
@export var skeleton_offset := Vector3.ZERO

# Optional: swap the head socket's grey box for a real mesh (assets/skull.glb).
# This applies to BOTH the base head box and the equipped head bone, because
# PlayerEquipmentComponent.equip_starting_core() equips `head_bone` on spawn,
# which hides the base visual — swapping only one of the two would look like
# nothing changed. Both are built by _make_limb(), so that is the single hook.
@export_group("Head model")
@export var head_model_scene: PackedScene
# skull.glb measures ~0.96 x 1.00 x 0.96 around its own origin, so 0.32 matches
# the grey head box it replaces (LIMB_GEO "head" size). Multiplies the bone's
# visual_scale rather than replacing it, so a Heavy head still reads as bigger.
@export var head_model_scale := 0.32
@export var head_model_offset := Vector3.ZERO
# The mesh is near-symmetric (0.959 vs 0.955 on X/Z), so its facing cannot be
# derived from its bounds — set this in the editor if the skull faces the wrong
# way. It has not been verified on screen.
@export var head_model_rotation_deg := Vector3.ZERO
# Keep the imported skull material instead of flat-tinting it with the bone
# colour the grey boxes use.
@export var head_model_keep_material := true

@export_group("")
# Show/hide body parts. Used for the "limbs only" placeholder while a real rigged
# skeleton is being made in Blender — leave the torso/head out, keep arms + legs.
@export var show_torso := true
@export var show_head := true

# Optional: use the REAL rigged model's separate limb meshes ON the sockets, so
# the actual arms/legs/feet swing with the procedural motion. Torso/head/hands
# are left out. Tune scale/rotation to line the parts up with the sockets.
@export var use_rigged_limbs := false
@export var rigged_model_scene: PackedScene
@export var rigged_limb_scale := 1.0
@export var rigged_limb_rotation_deg := Vector3(-90.0, 0.0, 0.0)

var _head_model_mesh: Mesh = null
var _head_model_mesh_loaded: bool = false

var sockets: Dictionary = {}         # socket key -> Node3D
var base_visuals: Dictionary = {}    # socket key -> MeshInstance3D (grey default)
var equipped_parts: Dictionary = {}  # slot id -> Array of Node3D
var equipped_ids: Dictionary = {}    # slot id -> bone_id
var limb_joints: Dictionary = {}     # socket key -> {skel, bone, rest_rot} for bending
var body_hitboxes: Dictionary = {}    # socket key -> Area3D
var body_hitbox_shapes: Dictionary = {} # socket key -> CollisionShape3D
var body_hitbox_configs: Dictionary = {} # socket key -> raw size/offset/rotation
var body_hitbox_owner: Node = null
var body_hitbox_damage_group: String = ""
var body_progression_enabled: bool = false


func _ready() -> void:
	for key in SOCKET_LAYOUT:
		var socket := Node3D.new()
		socket.name = String(key) + "_socket"
		socket.position = SOCKET_LAYOUT[key]
		add_child(socket)
		sockets[key] = socket

		# A default grey limb so there's a visible skeleton to animate.
		var limb := _make_limb(key, BASE_COLOR, Vector3.ONE)
		socket.add_child(limb)
		base_visuals[key] = limb

	# Feet hang UNDER the leg sockets, so they follow the leg swing.
	for foot_key in FOOT_UNDER_LEG:
		var info: Dictionary = FOOT_UNDER_LEG[foot_key]
		var leg: Node3D = sockets.get(info["leg"])
		if leg == null:
			continue
		var foot := Node3D.new()
		foot.name = String(foot_key) + "_socket"
		foot.position = info["pos"]
		leg.add_child(foot)
		sockets[foot_key] = foot
		var foot_limb := _make_limb(foot_key, BASE_COLOR, Vector3.ONE)
		foot.add_child(foot_limb)
		base_visuals[foot_key] = foot_limb

	_ensure_body_hitboxes()

	# Limbs-only placeholder: optionally hide the torso and head.
	if not show_torso and base_visuals.has("body"):
		base_visuals["body"].visible = false
	if not show_head and base_visuals.has("head"):
		base_visuals["head"].visible = false

	if use_rigged_limbs and rigged_model_scene != null:
		_apply_rigged_limbs()
	elif use_skeleton_model and skeleton_model_scene != null:
		_apply_skeleton_model()


func apply_gorilla_proportions() -> void:
	_set_socket_position("body", Vector3(0.0, -0.06, 0.0))
	_set_socket_position("head", Vector3(0.0, 0.48, -0.08))
	_set_socket_position("right_arm", Vector3(0.44, 0.22, -0.04))
	_set_socket_position("left_arm", Vector3(-0.44, 0.22, -0.04))
	_set_socket_position("right_leg", Vector3(0.18, -0.30, 0.05))
	_set_socket_position("left_leg", Vector3(-0.18, -0.30, 0.05))
	_set_socket_position("right_foot", Vector3(0.0, -0.44, 0.10))
	_set_socket_position("left_foot", Vector3(0.0, -0.44, 0.10))

	_set_base_limb_shape("body", Vector3(0.74, 0.72, 0.42), Vector3(0.0, -0.02, 0.0))
	_set_base_limb_shape("head", Vector3(0.38, 0.34, 0.38), Vector3(0.0, 0.0, 0.0))
	_set_base_limb_shape("right_arm", Vector3(0.26, 0.88, 0.25), Vector3(0.0, -0.44, 0.02))
	_set_base_limb_shape("left_arm", Vector3(0.26, 0.88, 0.25), Vector3(0.0, -0.44, 0.02))
	_set_base_limb_shape("right_leg", Vector3(0.24, 0.44, 0.24), Vector3(0.0, -0.22, 0.0))
	_set_base_limb_shape("left_leg", Vector3(0.24, 0.44, 0.24), Vector3(0.0, -0.22, 0.0))
	_set_base_limb_shape("right_foot", Vector3(0.32, 0.14, 0.46), Vector3(0.0, 0.0, 0.08))
	_set_base_limb_shape("left_foot", Vector3(0.32, 0.14, 0.46), Vector3(0.0, 0.0, 0.08))
	_apply_gorilla_body_hitboxes()


func apply_lizard_proportions() -> void:
	_set_socket_position("body", Vector3(0.0, -0.20, 0.0))
	_set_socket_position("head", Vector3(0.0, 0.12, -0.46))
	_set_socket_position("right_arm", Vector3(0.32, -0.16, -0.18))
	_set_socket_position("left_arm", Vector3(-0.32, -0.16, -0.18))
	_set_socket_position("right_leg", Vector3(0.28, -0.26, 0.22))
	_set_socket_position("left_leg", Vector3(-0.28, -0.26, 0.22))
	_set_socket_position("right_foot", Vector3(0.0, -0.24, 0.18))
	_set_socket_position("left_foot", Vector3(0.0, -0.24, 0.18))

	_set_base_limb_shape("body", Vector3(0.34, 0.24, 0.34), Vector3(0.0, -0.02, 0.02))
	_set_base_limb_shape("head", Vector3(0.28, 0.22, 0.42), Vector3(0.0, 0.0, -0.08))
	_set_base_limb_shape("right_arm", Vector3(0.13, 0.42, 0.13), Vector3(0.0, -0.20, 0.02))
	_set_base_limb_shape("left_arm", Vector3(0.13, 0.42, 0.13), Vector3(0.0, -0.20, 0.02))
	_set_base_limb_shape("right_leg", Vector3(0.14, 0.40, 0.14), Vector3(0.0, -0.18, 0.02))
	_set_base_limb_shape("left_leg", Vector3(0.14, 0.40, 0.14), Vector3(0.0, -0.18, 0.02))
	_set_base_limb_shape("right_foot", Vector3(0.22, 0.09, 0.38), Vector3(0.0, 0.0, 0.08))
	_set_base_limb_shape("left_foot", Vector3(0.22, 0.09, 0.38), Vector3(0.0, 0.0, 0.08))

	if base_visuals.has("body"):
		var body_visual := base_visuals["body"] as MeshInstance3D
		if body_visual != null:
			body_visual.visible = false
	_ensure_lizard_torso_block("LizardTorsoFront", Vector3(0.42, 0.30, 0.48), Vector3(0.0, -0.02, -0.20))
	_ensure_lizard_torso_block("LizardTorsoRear", Vector3(0.44, 0.32, 0.52), Vector3(0.0, -0.04, 0.28))

	var tail := get_node_or_null("LizardTail") as MeshInstance3D
	if tail == null:
		tail = MeshInstance3D.new()
		tail.name = "LizardTail"
		add_child(tail)
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.18, 0.16, 0.9)
		tail.mesh = mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = BASE_COLOR
		material.roughness = 0.82
		tail.material_override = material
	tail.position = Vector3(0.0, -0.22, 0.68)


func _ensure_lizard_torso_block(block_name: String, size: Vector3, local_position: Vector3) -> void:
	var body: Node3D = sockets.get("body") as Node3D
	if body == null:
		return

	var block := body.get_node_or_null(block_name) as MeshInstance3D
	if block == null:
		block = MeshInstance3D.new()
		block.name = block_name
		body.add_child(block)
		var material := StandardMaterial3D.new()
		material.albedo_color = BASE_COLOR
		material.roughness = 0.82
		block.material_override = material

	var mesh := block.mesh as BoxMesh
	if mesh == null:
		mesh = BoxMesh.new()
		block.mesh = mesh
	mesh.size = size
	block.position = local_position
	block.scale = Vector3.ONE
	block.visible = true


func _set_socket_position(socket_key: String, new_position: Vector3) -> void:
	var socket: Node3D = sockets.get(socket_key) as Node3D
	if socket == null:
		return

	socket.position = new_position


func _set_base_limb_shape(limb_key: String, new_size: Vector3, new_offset: Vector3) -> void:
	var limb: MeshInstance3D = base_visuals.get(limb_key) as MeshInstance3D
	if limb == null:
		return

	var box: BoxMesh = limb.mesh as BoxMesh
	if box == null:
		return

	box.size = new_size
	limb.position = new_offset
	limb.scale = Vector3.ONE
	_apply_body_hitbox(limb_key, new_size, new_offset, Vector3.ZERO)


func _apply_gorilla_body_hitboxes() -> void:
	_apply_body_hitbox("body", Vector3(0.92, 0.84, 0.56), Vector3(0.0, -0.02, 0.0), Vector3.ZERO)
	_apply_body_hitbox("head", Vector3(0.48, 0.44, 0.48), Vector3(0.0, 0.0, 0.0), Vector3.ZERO)
	_apply_body_hitbox("right_arm", Vector3(0.36, 0.98, 0.34), Vector3(0.0, -0.48, 0.02), Vector3.ZERO)
	_apply_body_hitbox("left_arm", Vector3(0.36, 0.98, 0.34), Vector3(0.0, -0.48, 0.02), Vector3.ZERO)
	_apply_body_hitbox("right_leg", Vector3(0.34, 0.54, 0.34), Vector3(0.0, -0.26, 0.0), Vector3.ZERO)
	_apply_body_hitbox("left_leg", Vector3(0.34, 0.54, 0.34), Vector3(0.0, -0.26, 0.0), Vector3.ZERO)
	_apply_body_hitbox("right_foot", Vector3(0.44, 0.20, 0.60), Vector3(0.0, 0.0, 0.10), Vector3.ZERO)
	_apply_body_hitbox("left_foot", Vector3(0.44, 0.20, 0.60), Vector3(0.0, 0.0, 0.10), Vector3.ZERO)


# Hides the grey-box limbs and shows the real model as one body under the torso
# socket, so it inherits the whole-body motion (bob / lean / sway / turn / attack).
func _apply_skeleton_model() -> void:
	for key in base_visuals:
		base_visuals[key].visible = false

	var body: Node3D = sockets.get("body")
	if body == null:
		return

	var wrapper := Node3D.new()
	wrapper.name = "SkeletonModel"
	wrapper.position = skeleton_offset
	wrapper.rotation_degrees = skeleton_rotation_deg
	wrapper.scale = Vector3.ONE * skeleton_scale
	body.add_child(wrapper)
	wrapper.add_child(skeleton_model_scene.instantiate())


# Attaches the rigged model's separate limb meshes onto the matching sockets, so
# the real arms/legs/feet swing with the rig. Torso/head/hands are dropped.
func _apply_rigged_limbs() -> void:
	# Hide only the grey limbs we replace with real ones. The torso/head grey
	# boxes stay (controlled by show_torso/show_head) — so we keep a square torso.
	for key in ["right_arm", "left_arm", "right_leg", "left_leg", "left_foot", "right_foot"]:
		if base_visuals.has(key):
			base_visuals[key].visible = false

	var model := rigged_model_scene.instantiate()
	add_child(model)

	for part_name in RIGGED_LIMBS:
		var cfg: Dictionary = RIGGED_LIMBS[part_name]
		var mesh := model.find_child(part_name, true, false)
		if mesh == null:
			continue
		var part := _top_ancestor_under(mesh, model) as Node3D
		var socket: Node3D = sockets.get(cfg["socket"])
		if part == null or socket == null:
			continue
		# Move the whole limb subtree (mesh + its skeleton) onto the socket.
		part.reparent(socket, false)

		var skel := _find_skeleton(part)
		var limb_scale: Vector3 = cfg["scale"] * rigged_limb_scale
		if skel != null and skel.get_bone_count() >= 2:
			# Procedural gravity + facing: measure the limb's real bone direction and
			# orient the part so it hangs straight DOWN and faces FORWARD.
			skel.force_update_all_bone_transforms()
			var dir_skel: Vector3 = skel.get_bone_global_pose(1).origin - skel.get_bone_global_pose(0).origin
			var length_axis := (skel.transform.basis * dir_skel).normalized()
			part.transform = Transform3D(_hang_basis(length_axis).scaled(limb_scale), Vector3.ZERO)
			# Remember the mid joint (elbow/knee = bone 1) so the animator bends it.
			limb_joints[cfg["socket"]] = {
				"skel": skel,
				"bone": 1,
				"rest_rot": skel.get_bone_rest(1).basis.get_rotation_quaternion(),
			}
		else:
			# Single-bone parts (feet) keep the manual rotation from the config.
			part.position = Vector3.ZERO
			part.rotation_degrees = cfg["rot"]
			part.scale = limb_scale

	# Whatever is left (torso, head, hands) is intentionally dropped.
	model.queue_free()


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var r := _find_skeleton(c)
		if r != null:
			return r
	return null


# Builds a rotation that points a limb (whose local length axis is `l`) straight
# DOWN, with its local +Z facing world FORWARD — so limbs hang AND face forward.
func _hang_basis(l: Vector3) -> Basis:
	if l.length() < 0.5:
		return Basis()

	# The limb's local "forward" reference (assume local +Z), made perpendicular to l.
	var fref := Vector3(0.0, 0.0, 1.0) - l * l.dot(Vector3(0.0, 0.0, 1.0))
	if fref.length() < 0.01:
		fref = Vector3(1.0, 0.0, 0.0) - l * l.dot(Vector3(1.0, 0.0, 0.0))
	fref = fref.normalized()
	var from_b := Basis(l.cross(fref).normalized(), l, fref)

	# Target: length -> world DOWN, forward -> world FORWARD.
	var tlen := Vector3.DOWN
	var tref := (Vector3.FORWARD - tlen * tlen.dot(Vector3.FORWARD)).normalized()
	var to_b := Basis(tlen.cross(tref).normalized(), tlen, tref)

	return to_b * from_b.inverse()


# Walks up from a node to the child directly under `ancestor`.
func _top_ancestor_under(node: Node, ancestor: Node) -> Node:
	var n := node
	while n.get_parent() != null and n.get_parent() != ancestor:
		n = n.get_parent()
	return n


func get_socket(socket_key: String) -> Node3D:
	return sockets.get(socket_key)


func set_body_progression_enabled(enabled: bool) -> void:
	body_progression_enabled = enabled
	_refresh_body_progression_visibility()


func set_body_hitbox_owner(owner_body: Node, damage_group: String = PLAYER_BODY_HITBOX_GROUP) -> void:
	body_hitbox_owner = owner_body
	body_hitbox_damage_group = damage_group
	for socket_key in body_hitboxes:
		_configure_body_hitbox_owner(str(socket_key))
	_refresh_body_hitbox_shapes()


func has_body_part_hitboxes() -> bool:
	return not body_hitboxes.is_empty()


func set_body_part_hitbox_enabled(socket_key: String, enabled: bool) -> void:
	var area: Area3D = body_hitboxes.get(socket_key) as Area3D
	var shape_node: CollisionShape3D = body_hitbox_shapes.get(socket_key) as CollisionShape3D
	if area == null or shape_node == null:
		return

	area.monitorable = enabled
	shape_node.disabled = not enabled


func set_head_only_visual_guard(enabled: bool) -> void:
	var head_socket: Node3D = sockets.get("head") as Node3D
	if head_socket == null:
		return

	var equipped_head_parts: Array = equipped_parts.get("head", [])
	var has_equipped_head := equipped_ids.has("head") and not equipped_head_parts.is_empty()
	for child in head_socket.get_children():
		var child_node := child as Node
		if child_node == null:
			continue
		if enabled and has_equipped_head:
			_set_mesh_visibility_recursive(child_node, equipped_head_parts.has(child_node))
		elif child_node == base_visuals.get("head"):
			_set_mesh_visibility_recursive(child_node, _base_socket_should_show("head"))


func _set_mesh_visibility_recursive(root: Node, is_visible: bool) -> void:
	if root is MeshInstance3D:
		var mesh_node := root as MeshInstance3D
		mesh_node.visible = is_visible
	for child in root.get_children():
		var child_node := child as Node
		if child_node != null:
			_set_mesh_visibility_recursive(child_node, is_visible)


func has_equipped_slot(slot_id: String) -> bool:
	return equipped_ids.has(slot_id)


# Builds one grey-box MeshInstance3D for a socket, offset so it hangs correctly.
func _make_limb(socket_key: String, color: Color, extra_scale: Vector3) -> MeshInstance3D:
	var geo: Dictionary = LIMB_GEO.get(socket_key, {"size": Vector3(0.2, 0.2, 0.2), "offset": Vector3.ZERO})
	var mi := MeshInstance3D.new()

	if socket_key == "head":
		var head_mesh: Mesh = _get_head_model_mesh()
		if head_mesh != null:
			mi.mesh = head_mesh
			mi.position = geo["offset"] + head_model_offset
			mi.rotation_degrees = head_model_rotation_deg
			mi.scale = extra_scale * head_model_scale
			if not head_model_keep_material:
				var head_material := StandardMaterial3D.new()
				head_material.albedo_color = color
				mi.material_override = head_material
			return mi

	var mesh := BoxMesh.new()
	mesh.size = geo["size"]
	mi.mesh = mesh
	mi.position = geo["offset"]
	mi.scale = extra_scale

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mi.material_override = mat
	return mi


# The head model's mesh, pulled out of its scene once and reused for every head
# built afterwards. Returns null when no model is assigned, which is the cue to
# fall back to the grey box.
func _get_head_model_mesh() -> Mesh:
	if _head_model_mesh_loaded:
		return _head_model_mesh
	_head_model_mesh_loaded = true
	if head_model_scene == null:
		return null

	var instance: Node = head_model_scene.instantiate()
	for node in instance.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance != null and mesh_instance.mesh != null:
			_head_model_mesh = mesh_instance.mesh
			break
	# Never entered the tree, so free() rather than queue_free().
	instance.free()
	if _head_model_mesh == null:
		push_warning("ModularSkeletonRig: head_model_scene has no MeshInstance3D; keeping the grey head box.")
	return _head_model_mesh


# Equip a bone: swap the target socket(s) grey limb for a bone-colored, bone-scaled
# part. bone_def comes from BoneRulesService.definition_for(bone_id).
func equip_bone(bone_id: String, bone_def: Dictionary) -> void:
	var slot_id: String = bone_def.get("slot", "")
	var socket_keys: Array = EquipmentRulesService.socket_keys_for_slot(slot_id)
	if socket_keys.is_empty():
		push_warning("ModularSkeletonRig: no sockets for slot '" + slot_id + "'")
		return

	unequip_slot(slot_id)

	var color: Color = bone_def.get("color", Color(1, 1, 1))
	var vis_scale: Vector3 = _as_vector3(bone_def.get("visual_scale", Vector3.ONE), Vector3.ONE)
	var vis_offset: Vector3 = _as_vector3(bone_def.get("visual_offset", Vector3.ZERO), Vector3.ZERO)
	var vis_rotation: Vector3 = _as_vector3(bone_def.get("visual_rotation", Vector3.ZERO), Vector3.ZERO)
	var hitbox_scale: Vector3 = _as_vector3(bone_def.get("hitbox_scale", vis_scale), vis_scale)
	var hitbox_size: Vector3 = _as_vector3(bone_def.get("hitbox_size", Vector3.ZERO), Vector3.ZERO)
	var hitbox_offset: Vector3 = _as_vector3(bone_def.get("hitbox_offset", vis_offset), vis_offset)
	var hitbox_rotation: Vector3 = _as_vector3(bone_def.get("hitbox_rotation", vis_rotation), vis_rotation)

	var parts: Array = []
	for key in socket_keys:
		var socket: Node3D = sockets.get(key)
		if socket == null:
			continue
		if base_visuals.has(key):
			base_visuals[key].visible = false

		var part := _make_limb(key, color, vis_scale)
		# Per-bone corrections on top of the natural hang offset. Both ADD rather
		# than assign: grey boxes leave _make_limb at rotation zero so the result is
		# unchanged for them, but the head model arrives already rotated by
		# head_model_rotation_deg, and assigning here would silently discard it.
		part.position += vis_offset
		part.rotation += vis_rotation
		socket.add_child(part)
		parts.append(part)
		_apply_equipped_body_hitbox(key, hitbox_size, hitbox_scale, hitbox_offset, hitbox_rotation)

	equipped_parts[slot_id] = parts
	equipped_ids[slot_id] = bone_id
	_refresh_body_progression_visibility()


func unequip_slot(slot_id: String) -> void:
	if equipped_parts.has(slot_id):
		for part in equipped_parts[slot_id]:
			if is_instance_valid(part):
				part.queue_free()
		equipped_parts.erase(slot_id)
	equipped_ids.erase(slot_id)

	# Show the grey base again for that slot's sockets.
	for key in EquipmentRulesService.socket_keys_for_slot(slot_id):
		if base_visuals.has(key):
			base_visuals[key].visible = true
		_apply_default_body_hitbox(str(key))
	_refresh_body_progression_visibility()


# The rig knows what's equipped; the animator uses these for weight response.
func get_equipped_bone_defs() -> Array:
	var defs: Array = []
	for slot_id in equipped_ids:
		var def := BoneRulesService.definition_for(equipped_ids[slot_id])
		if not def.is_empty():
			defs.append(def)
	return defs


func _refresh_body_progression_visibility() -> void:
	if not body_progression_enabled:
		return

	for key in base_visuals:
		var socket_key: String = str(key)
		var visual: MeshInstance3D = base_visuals[socket_key] as MeshInstance3D
		if visual == null:
			continue
		visual.visible = _base_socket_should_show(socket_key)
	if equipped_ids.has("head") and not equipped_ids.has("body"):
		set_head_only_visual_guard(true)
	_refresh_body_hitbox_enabled()


func _base_socket_should_show(socket_key: String) -> bool:
	if _socket_is_equipped(socket_key):
		return false
	if socket_key == "head":
		return true
	if socket_key == "body":
		return equipped_ids.has("body")
	if socket_key == "right_arm":
		return equipped_ids.has("right_arm")
	if socket_key == "left_arm":
		return equipped_ids.has("left_arm")
	if socket_key == "right_leg" or socket_key == "left_leg" or socket_key == "right_foot" or socket_key == "left_foot":
		return equipped_ids.has("legs")
	return true


func _socket_is_equipped(socket_key: String) -> bool:
	if socket_key == "right_foot" or socket_key == "left_foot":
		return equipped_ids.has("legs")
	for slot_id in equipped_ids:
		if EquipmentRulesService.socket_keys_for_slot(str(slot_id)).has(socket_key):
			return true
	return false


func _ensure_body_hitboxes() -> void:
	for socket_key in sockets:
		_make_body_hitbox(str(socket_key))
		_apply_default_body_hitbox(str(socket_key))
	_refresh_body_hitbox_enabled()


func _make_body_hitbox(socket_key: String) -> void:
	if body_hitboxes.has(socket_key):
		return

	var socket: Node3D = sockets.get(socket_key) as Node3D
	if socket == null:
		return

	var area := Area3D.new()
	area.name = _body_hitbox_name(socket_key)
	area.collision_layer = 1
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	area.add_to_group(BODY_HITBOX_GROUP)
	socket.add_child(area)

	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = BoxShape3D.new()
	area.add_child(shape_node)

	body_hitboxes[socket_key] = area
	body_hitbox_shapes[socket_key] = shape_node
	_configure_body_hitbox_owner(socket_key)


func _body_hitbox_name(socket_key: String) -> String:
	return "BodyPartHitbox_" + socket_key


func _configure_body_hitbox_owner(socket_key: String) -> void:
	var area: Area3D = body_hitboxes.get(socket_key) as Area3D
	if area == null:
		return

	area.set_meta("body_part", socket_key)
	area.set_meta("damage_owner", body_hitbox_owner)
	_clear_damage_hitbox_groups(area)
	if body_hitbox_owner != null:
		if body_hitbox_damage_group != "" and not area.is_in_group(body_hitbox_damage_group):
			area.add_to_group(body_hitbox_damage_group)


func _apply_default_body_hitbox(socket_key: String) -> void:
	var geo: Dictionary = _limb_geo_for(socket_key)
	var size_value: Vector3 = _as_vector3(geo.get("size", Vector3(0.2, 0.2, 0.2)), Vector3(0.2, 0.2, 0.2))
	var offset_value: Vector3 = _as_vector3(geo.get("offset", Vector3.ZERO), Vector3.ZERO)
	_apply_body_hitbox(socket_key, size_value, offset_value, Vector3.ZERO)


func _apply_equipped_body_hitbox(socket_key: String, explicit_size: Vector3, scale_value: Vector3, extra_offset: Vector3, rotation_value: Vector3) -> void:
	var geo: Dictionary = _limb_geo_for(socket_key)
	var base_size: Vector3 = _as_vector3(geo.get("size", Vector3(0.2, 0.2, 0.2)), Vector3(0.2, 0.2, 0.2))
	var base_offset: Vector3 = _as_vector3(geo.get("offset", Vector3.ZERO), Vector3.ZERO)
	var final_size: Vector3 = explicit_size
	if final_size == Vector3.ZERO:
		final_size = _scale_vector3(base_size, scale_value)
	_apply_body_hitbox(socket_key, final_size, base_offset + extra_offset, rotation_value)


func _apply_body_hitbox(socket_key: String, size_value: Vector3, offset_value: Vector3, rotation_value: Vector3) -> void:
	body_hitbox_configs[socket_key] = {
		"size": size_value,
		"offset": offset_value,
		"rotation": rotation_value,
	}
	_apply_body_hitbox_shape(socket_key, size_value, offset_value, rotation_value)


func _apply_body_hitbox_shape(socket_key: String, size_value: Vector3, offset_value: Vector3, rotation_value: Vector3) -> void:
	var shape_node: CollisionShape3D = body_hitbox_shapes.get(socket_key) as CollisionShape3D
	if shape_node == null:
		return

	var box: BoxShape3D = shape_node.shape as BoxShape3D
	if box == null:
		box = BoxShape3D.new()
		shape_node.shape = box

	box.size = _positive_vector3(_enemy_adjusted_hitbox_size(socket_key, size_value), MIN_HITBOX_SIZE)
	shape_node.position = offset_value
	shape_node.rotation = rotation_value


func _refresh_body_hitbox_shapes() -> void:
	for socket_key in body_hitbox_configs:
		var config: Dictionary = body_hitbox_configs.get(socket_key, {})
		_apply_body_hitbox_shape(
			str(socket_key),
			_as_vector3(config.get("size", Vector3.ZERO), Vector3.ZERO),
			_as_vector3(config.get("offset", Vector3.ZERO), Vector3.ZERO),
			_as_vector3(config.get("rotation", Vector3.ZERO), Vector3.ZERO)
		)


func _enemy_adjusted_hitbox_size(socket_key: String, size_value: Vector3) -> Vector3:
	if body_hitbox_damage_group != ENEMY_BODY_HITBOX_GROUP:
		return size_value
	var scale_value: Vector3 = _as_vector3(ENEMY_HITBOX_ACCURACY_SCALE.get(socket_key, Vector3(0.88, 0.92, 0.88)), Vector3(0.88, 0.92, 0.88))
	return _scale_vector3(size_value, scale_value)


func _refresh_body_hitbox_enabled() -> void:
	for socket_key in body_hitboxes:
		var area: Area3D = body_hitboxes[socket_key] as Area3D
		var shape_node: CollisionShape3D = body_hitbox_shapes.get(socket_key) as CollisionShape3D
		if area == null or shape_node == null:
			continue
		var enabled := _body_hitbox_should_be_enabled(str(socket_key))
		area.monitorable = enabled
		shape_node.disabled = not enabled


func _body_hitbox_should_be_enabled(socket_key: String) -> bool:
	if not body_progression_enabled:
		return true
	if _socket_is_equipped(socket_key):
		return true
	return _base_socket_should_show(socket_key)


func _clear_damage_hitbox_groups(area: Area3D) -> void:
	for group_name in DAMAGE_HITBOX_GROUPS:
		if area.is_in_group(group_name):
			area.remove_from_group(group_name)


func _limb_geo_for(socket_key: String) -> Dictionary:
	return LIMB_GEO.get(socket_key, {"size": Vector3(0.2, 0.2, 0.2), "offset": Vector3.ZERO})


func _as_vector3(value: Variant, fallback: Vector3) -> Vector3:
	if value is Vector3:
		var vector_value: Vector3 = value
		return vector_value
	if value is float or value is int:
		var f := float(value)
		return Vector3(f, f, f)
	return fallback


func _scale_vector3(size_value: Vector3, scale_value: Vector3) -> Vector3:
	return Vector3(size_value.x * scale_value.x, size_value.y * scale_value.y, size_value.z * scale_value.z)


func _positive_vector3(value: Vector3, fallback: Vector3) -> Vector3:
	return Vector3(maxf(value.x, fallback.x), maxf(value.y, fallback.y), maxf(value.z, fallback.z))
