class_name PlayerEquipmentComponent
extends Node

const EQUIPPED_BONE_SCENE: PackedScene = preload("res://scenes/equipped_bone.tscn")
const CORE_HEAD_BONE_ID := "head_bone"
const CORE_HEAD_SLOT := EquipmentRulesService.SLOT_HEAD
const CORE_TORSO_SLOT := EquipmentRulesService.SLOT_TORSO
const TORSO_REQUIRED_SLOTS := [
	EquipmentRulesService.SLOT_RIGHT_ARM,
	EquipmentRulesService.SLOT_LEFT_ARM,
	EquipmentRulesService.SLOT_RIGHT_LEG,
	EquipmentRulesService.SLOT_LEFT_LEG,
]

var owner_player: Node = null
var equipped: Dictionary = {}
var equipped_visuals: Dictionary = {}
var equip_swaps: int = 0


func setup(player: Node) -> void:
	owner_player = player
	name = "PlayerEquipmentComponent"


func equip_starting_core() -> void:
	if _equip_bone_in_slot(CORE_HEAD_BONE_ID, true):
		var rig: ModularSkeletonRig = _get_player_rig()
		if rig != null:
			rig.equip_bone(CORE_HEAD_BONE_ID, BoneRulesService.definition_for(CORE_HEAD_BONE_ID))
		_recalculate_owner_stats()


func equip_bone(bone_id: String, target_slot: String = "") -> void:
	if not _equip_bone_in_slot(bone_id, false, target_slot):
		return

	var slot: String = _slot_for_request(bone_id, target_slot)
	var rig: ModularSkeletonRig = _get_player_rig()
	if rig != null:
		rig.equip_bone(bone_id, _definition_for_slot(bone_id, slot))

	equip_swaps += 1
	_recalculate_owner_stats()
	_notify_equipment_changed()
	GameEvents.bone_equipped.emit(bone_id, slot, owner_player)
	print("Equipped ", BoneRulesService.display_name_with_slot(bone_id), " in slot ", slot)


func restore_detached_body(bone_id: String) -> void:
	if not EquipmentRulesService.can_equip_bone_in_slot(bone_id, CORE_TORSO_SLOT):
		return
	if not _equip_bone_in_slot(bone_id, true):
		return

	var rig: ModularSkeletonRig = _get_player_rig()
	if rig != null:
		rig.equip_bone(bone_id, _definition_for_slot(bone_id, CORE_TORSO_SLOT))

	_recalculate_owner_stats()
	_notify_equipment_changed()
	GameEvents.bone_equipped.emit(bone_id, CORE_TORSO_SLOT, owner_player)
	print("Reattached detached torso ", BoneRulesService.display_name_with_slot(bone_id))


func unequip_slot(slot: String) -> void:
	slot = EquipmentRulesService.normalize_slot_id(slot)
	if not equipped.has(slot):
		return
	if slot == CORE_HEAD_SLOT:
		print("The head is the fixed core. If it breaks, the player dies.")
		return
	if slot == CORE_TORSO_SLOT:
		for limb_slot in TORSO_REQUIRED_SLOTS:
			unequip_slot(str(limb_slot))

	var bone_id: String = equipped[slot]
	equipped.erase(slot)

	var rig: ModularSkeletonRig = _get_player_rig()
	if rig != null:
		rig.unequip_slot(slot)

	_clear_equipped_visual(slot)
	_recalculate_owner_stats()
	_notify_equipment_changed()
	GameEvents.bone_unequipped.emit(bone_id, slot, owner_player)
	print("Unequipped slot ", slot)


func get_equipped_bone_id() -> String:
	return str(equipped.get("right_arm", ""))


func get_equipped_bone_for_slot(slot: String) -> String:
	slot = EquipmentRulesService.normalize_slot_id(slot)
	return str(equipped.get(slot, ""))


func has_bone_equipped(bone_id: String) -> bool:
	return equipped.values().has(bone_id)


func get_equipment_state() -> Dictionary:
	return equipped.duplicate()


func get_equipped_bone_defs() -> Array:
	var defs: Array = []
	for slot_id in equipped:
		var bone_id: String = str(equipped[slot_id])
		var definition: Dictionary = BoneRulesService.definition_for(bone_id).duplicate(true)
		if definition.is_empty():
			continue
		if str(slot_id) == EquipmentRulesService.SLOT_TORSO:
			definition["slot"] = "body"
		else:
			definition["slot"] = str(slot_id)
		defs.append(definition)
	return defs


func get_swap_count() -> int:
	return equip_swaps


func _equip_bone_in_slot(bone_id: String, force_core: bool = false, target_slot: String = "") -> bool:
	var slot: String = _slot_for_request(bone_id, target_slot)
	if slot == "":
		print("Bone has no slot: ", bone_id)
		return false

	if not force_core and not _can_equip_slot(slot, bone_id):
		return false

	if equipped.get(slot, "") == bone_id:
		return false

	var rig: ModularSkeletonRig = _get_player_rig()
	if rig != null:
		equipped[slot] = bone_id
		_clear_equipped_visual(slot)
		return true

	var socket: Node3D = _get_socket_for_slot(slot)
	if socket == null:
		print("No socket for slot: ", slot)
		return false

	equipped[slot] = bone_id
	_clear_equipped_visual(slot)

	var visual: Node3D = EQUIPPED_BONE_SCENE.instantiate() as Node3D
	socket.add_child(visual)
	visual.position = Vector3.ZERO
	visual.rotation = Vector3.ZERO
	equipped_visuals[slot] = visual
	_tint_visual(visual, BoneRulesService.color_for(bone_id))
	return true


func _slot_for_request(bone_id: String, target_slot: String = "") -> String:
	var normalized_target := EquipmentRulesService.normalize_slot_id(target_slot)
	if normalized_target != "" and EquipmentRulesService.can_equip_bone_in_slot(bone_id, normalized_target):
		return normalized_target
	return EquipmentRulesService.slot_for_bone(bone_id)


func _can_equip_slot(slot: String, bone_id: String) -> bool:
	slot = EquipmentRulesService.normalize_slot_id(slot)
	if not EquipmentRulesService.can_equip_bone_in_slot(bone_id, slot):
		print("Bone ", bone_id, " cannot equip in slot ", slot)
		return false

	if slot == CORE_HEAD_SLOT:
		print("The head is fixed. Enemy heads cannot replace the player's core.")
		_emit_equipment_hint("head_fixed", "Your head is the fixed core. If it breaks, you die.")
		return false

	if TORSO_REQUIRED_SLOTS.has(slot) and not equipped.has(CORE_TORSO_SLOT):
		print("Equip a torso before attaching limbs.")
		_emit_equipment_hint("torso_required", "Recover a torso first. Arms and legs cannot attach to a head alone.")
		return false

	if slot == CORE_TORSO_SLOT and owner_player != null and owner_player.has_method("is_head_detached_from_torso") and bool(owner_player.call("is_head_detached_from_torso")):
		print("Return to the torso you left behind before equipping another torso.")
		_emit_equipment_hint("detached_torso_required", "Your head is detached. Return to your left-behind torso and hold Interact to reattach.")
		return false

	if slot == CORE_TORSO_SLOT and bone_id == "":
		return false

	return true


func _emit_equipment_hint(hint_id: String, text: String) -> void:
	if owner_player == null:
		return
	GameEvents.tutorial_hint_requested.emit(owner_player, hint_id, text, 3)


func _clear_equipped_visual(slot: String) -> void:
	if equipped_visuals.has(slot) and is_instance_valid(equipped_visuals[slot]):
		equipped_visuals[slot].queue_free()
	equipped_visuals.erase(slot)


func _get_socket_for_slot(slot: String) -> Node3D:
	if owner_player != null and owner_player.has_method("get_equipment_socket_for_slot"):
		return owner_player.call("get_equipment_socket_for_slot", slot) as Node3D
	return null


func _get_player_rig() -> ModularSkeletonRig:
	if owner_player == null:
		return null
	var rig_value: Variant = owner_player.get("rig")
	return rig_value as ModularSkeletonRig


func _recalculate_owner_stats() -> void:
	if owner_player != null and owner_player.has_method("recalculate_player_stats"):
		owner_player.call("recalculate_player_stats")


func _notify_equipment_changed() -> void:
	GameEvents.inventory_changed.emit(owner_player, _get_inventory_items(), _get_run_stats())


func _get_inventory_items() -> Array:
	if owner_player != null and owner_player.has_method("get_inventory_items"):
		return owner_player.call("get_inventory_items") as Array
	return []


func _get_run_stats() -> Dictionary:
	if owner_player != null and owner_player.has_method("get_run_stats"):
		return owner_player.call("get_run_stats") as Dictionary
	return {}


func _definition_for_slot(bone_id: String, slot: String) -> Dictionary:
	var definition: Dictionary = BoneRulesService.definition_for(bone_id).duplicate(true)
	if not definition.is_empty():
		definition["slot"] = slot
	return definition


func _tint_visual(visual: Node3D, color: Color) -> void:
	_tint_visual_mesh(visual, "BoneMesh", color)
	_tint_visual_mesh(visual, "JointMesh", color)


func _tint_visual_mesh(visual: Node3D, mesh_name: String, color: Color) -> void:
	var mesh: MeshInstance3D = visual.get_node_or_null(mesh_name) as MeshInstance3D
	if mesh == null:
		return

	var material: StandardMaterial3D = null
	var raw_material: Material = mesh.get_surface_override_material(0)
	if raw_material != null:
		material = raw_material.duplicate() as StandardMaterial3D

	if material == null:
		material = StandardMaterial3D.new()

	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.25
	mesh.set_surface_override_material(0, material)
