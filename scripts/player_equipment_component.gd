class_name PlayerEquipmentComponent
extends Node

const EQUIPPED_BONE_SCENE: PackedScene = preload("res://scenes/equipped_bone.tscn")

var owner_player: Node = null
var equipped: Dictionary = {}
var equipped_visuals: Dictionary = {}
var equip_swaps: int = 0


func setup(player: Node) -> void:
	owner_player = player
	name = "PlayerEquipmentComponent"


func equip_bone(bone_id: String) -> void:
	if not _equip_bone_in_slot(bone_id):
		return

	var rig: ModularSkeletonRig = _get_player_rig()
	if rig != null:
		rig.equip_bone(bone_id, BoneRulesService.definition_for(bone_id))

	equip_swaps += 1
	_recalculate_owner_stats()
	_notify_equipment_changed()
	GameEvents.bone_equipped.emit(bone_id, BoneRulesService.slot_for(bone_id), owner_player)
	print("Equipped ", BoneRulesService.display_name_with_slot(bone_id), " in slot ", BoneRulesService.slot_for(bone_id))


func unequip_slot(slot: String) -> void:
	if not equipped.has(slot):
		return

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
	return str(equipped.get(slot, ""))


func has_bone_equipped(bone_id: String) -> bool:
	return equipped.values().has(bone_id)


func get_equipment_state() -> Dictionary:
	return equipped.duplicate()


func get_swap_count() -> int:
	return equip_swaps


func _equip_bone_in_slot(bone_id: String) -> bool:
	var slot: String = BoneRulesService.slot_for(bone_id)
	if slot == "":
		print("Bone has no slot: ", bone_id)
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
	if owner_player == null:
		return
	var inventory_ui_value: Variant = owner_player.get("inventory_ui")
	var inventory_ui: Node = inventory_ui_value as Node
	if inventory_ui != null and inventory_ui.has_method("notify_equipment_changed"):
		inventory_ui.call("notify_equipment_changed")


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
