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

# Which physical sockets a gameplay slot maps to (a "legs" bone shows on both legs).
static var SLOT_TO_SOCKETS := {
	"right_arm": ["right_arm"],
	"left_arm": ["left_arm"],
	"legs": ["left_leg", "right_leg"],
	"body": ["body"],
	"head": ["head"],
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

# Optional: show a real 3D model as the whole body instead of grey boxes.
# The model is a single un-rigged mesh, so it gets whole-body motion (the grey
# limbs are hidden). Adjust the transform to stand it up correctly.
@export var use_skeleton_model := false
@export var skeleton_model_scene: PackedScene
@export var skeleton_scale := 1.7
@export var skeleton_rotation_deg := Vector3(-90.0, 0.0, 0.0)
@export var skeleton_offset := Vector3.ZERO

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

var sockets: Dictionary = {}         # socket key -> Node3D
var base_visuals: Dictionary = {}    # socket key -> MeshInstance3D (grey default)
var equipped_parts: Dictionary = {}  # slot id -> Array of Node3D
var equipped_ids: Dictionary = {}    # slot id -> bone_id
var limb_joints: Dictionary = {}     # socket key -> {skel, bone, rest_rot} for bending


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


# Builds one grey-box MeshInstance3D for a socket, offset so it hangs correctly.
func _make_limb(socket_key: String, color: Color, extra_scale: Vector3) -> MeshInstance3D:
	var geo: Dictionary = LIMB_GEO.get(socket_key, {"size": Vector3(0.2, 0.2, 0.2), "offset": Vector3.ZERO})
	var mesh := BoxMesh.new()
	mesh.size = geo["size"]

	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = geo["offset"]
	mi.scale = extra_scale

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mi.material_override = mat
	return mi


# Equip a bone: swap the target socket(s) grey limb for a bone-colored, bone-scaled
# part. bone_def comes from BoneRulesService.definition_for(bone_id).
func equip_bone(bone_id: String, bone_def: Dictionary) -> void:
	var slot_id: String = bone_def.get("slot", "")
	var socket_keys: Array = SLOT_TO_SOCKETS.get(slot_id, [])
	if socket_keys.is_empty():
		push_warning("ModularSkeletonRig: no sockets for slot '" + slot_id + "'")
		return

	unequip_slot(slot_id)

	var color: Color = bone_def.get("color", Color(1, 1, 1))
	var vis_scale: Vector3 = bone_def.get("visual_scale", Vector3.ONE)
	var vis_offset: Vector3 = bone_def.get("visual_offset", Vector3.ZERO)
	var vis_rotation: Vector3 = bone_def.get("visual_rotation", Vector3.ZERO)

	var parts: Array = []
	for key in socket_keys:
		var socket: Node3D = sockets.get(key)
		if socket == null:
			continue
		if base_visuals.has(key):
			base_visuals[key].visible = false

		var part := _make_limb(key, color, vis_scale)
		# Per-bone corrections on top of the natural hang offset.
		part.position += vis_offset
		part.rotation = vis_rotation
		socket.add_child(part)
		parts.append(part)

	equipped_parts[slot_id] = parts
	equipped_ids[slot_id] = bone_id


func unequip_slot(slot_id: String) -> void:
	if equipped_parts.has(slot_id):
		for part in equipped_parts[slot_id]:
			if is_instance_valid(part):
				part.queue_free()
		equipped_parts.erase(slot_id)
	equipped_ids.erase(slot_id)

	# Show the grey base again for that slot's sockets.
	for key in SLOT_TO_SOCKETS.get(slot_id, []):
		if base_visuals.has(key):
			base_visuals[key].visible = true


# The rig knows what's equipped; the animator uses these for weight response.
func get_equipped_bone_defs() -> Array:
	var defs: Array = []
	for slot_id in equipped_ids:
		var def := BoneRulesService.definition_for(equipped_ids[slot_id])
		if not def.is_empty():
			defs.append(def)
	return defs
