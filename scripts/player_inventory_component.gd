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


func collect_bone(bone_id: String) -> void:
	bone_inventory.append(bone_id)
	_notify_inventory_changed()
	GameEvents.bone_collected.emit(bone_id, owner_player)
	print("Collected bone: ", BoneRulesService.display_name_with_slot(bone_id))


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
	if owner_player == null:
		return
	var inventory_ui_value: Variant = owner_player.get("inventory_ui")
	var inventory_ui: Node = inventory_ui_value as Node
	if inventory_ui != null and inventory_ui.has_method("notify_inventory_changed"):
		inventory_ui.call("notify_inventory_changed")
