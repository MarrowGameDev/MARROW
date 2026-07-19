class_name PlayerInventoryComponent
extends Node

var owner_player: Node = null
var equipment_component: PlayerEquipmentComponent = null
var bone_inventory: Array[String] = []
var equip_cursor: int = 0


func setup(player: Node, equipment: PlayerEquipmentComponent = null) -> void:
	owner_player = player
	equipment_component = equipment
	name = "PlayerInventoryComponent"


# Accepts either an instance_id (a piece that already exists in the world --
# the normal path from a drop) or a plain bone_id. A plain bone_id means the
# piece is being brought into existence right here (a reward, a granted
# starter piece, test seeding), so it gets an instance and one quality roll.
# Collecting an existing piece never re-rolls: its instance_id passes through
# untouched.
func collect_bone(bone_id: String) -> void:
	var instance_id := bone_id
	if not BoneInstanceService.is_instance_id(bone_id):
		instance_id = BoneInstanceService.create_instance(bone_id)
	bone_inventory.append(instance_id)
	_notify_inventory_changed()
	GameEvents.bone_collected.emit(instance_id, owner_player)
	print("Collected bone: ", BoneRulesService.display_name_with_slot(instance_id),
		" [", BoneRulesService.quality_display_name_for(instance_id), "]")


func equip_next_bone() -> void:
	if bone_inventory.is_empty():
		print("No bones to equip yet.")
		return

	if equip_cursor >= bone_inventory.size():
		equip_cursor = 0

	var bone_id: String = bone_inventory[equip_cursor]
	equip_cursor = (equip_cursor + 1) % bone_inventory.size()
	if equipment_component != null:
		equipment_component.equip_bone(bone_id)


func get_run_stats() -> Dictionary:
	return {
		"collected": bone_inventory.duplicate(),
		"swaps": _get_equipment_swap_count(),
	}


func get_inventory_items() -> Array:
	return bone_inventory.duplicate()


func _get_equipment_swap_count() -> int:
	if equipment_component == null:
		return 0
	return equipment_component.get_swap_count()


func _notify_inventory_changed() -> void:
	GameEvents.inventory_changed.emit(owner_player, get_inventory_items(), get_run_stats())
