class_name PlayerEquipmentBuildsComponent
extends Node

const BUILD_SETTINGS_PATH := "user://equipment_builds.cfg"
const BUILD_SECTION := "builds"
const BUILD_SLOT_COUNT := 3

const APPLY_ORDER := [
	EquipmentRulesService.SLOT_TORSO,
	EquipmentRulesService.SLOT_LEFT_ARM,
	EquipmentRulesService.SLOT_RIGHT_ARM,
	EquipmentRulesService.SLOT_LEFT_LEG,
	EquipmentRulesService.SLOT_RIGHT_LEG,
]

var owner_player: Node = null
var equipment_component: PlayerEquipmentComponent = null
var builds: Dictionary = {}


func setup(player: Node, equipment: PlayerEquipmentComponent) -> void:
	owner_player = player
	equipment_component = equipment
	name = "PlayerEquipmentBuildsComponent"
	_load_builds()


func save_current_build(index: int) -> Dictionary:
	if not _valid_index(index):
		return _result(false, "Unknown build slot.")
	if equipment_component == null:
		return _result(false, "Equipment is not ready.")

	var state := _sanitize_build_state(equipment_component.get_equipment_state())
	builds[index] = state
	_save_builds()
	return _result(true, "Saved build " + str(index) + ".", state)


func apply_build(index: int) -> Dictionary:
	if not _valid_index(index):
		return _result(false, "Unknown build slot.")
	if equipment_component == null:
		return _result(false, "Equipment is not ready.")
	if not builds.has(index):
		return _result(false, "Build " + str(index) + " is empty.")

	var validation := validate_build_state(builds[index], _inventory_items())
	if not bool(validation.get("ok", false)):
		return validation

	var target_state: Dictionary = validation.get("state", {})
	# Snapshot before mutating anything, so a failed apply can be rolled
	# back to exactly what was equipped a moment ago.
	var previous_state := equipment_component.get_equipment_state()

	_apply_validated_state(target_state)

	if _matches_equipment_state(target_state):
		return _result(true, "Applied build " + str(index) + ".", target_state)

	# Apply did not fully take (e.g. a late equip rejection not caught by
	# pre-validation). Restore the pre-apply state instead of leaving the
	# player with a mix of old and new gear.
	_apply_validated_state(previous_state)
	if _matches_equipment_state(previous_state):
		return _result(
			false,
			"Build " + str(index) + " could not be fully applied. Equipment was rolled back to what you had equipped before.",
			previous_state
		)
	return _result(
		false,
		"Build " + str(index) + " could not be applied, and restoring your previous equipment also failed. Check your equipped gear.",
		equipment_component.get_equipment_state()
	)


func validate_build_state(raw_state: Dictionary, inventory_items: Array) -> Dictionary:
	var state := _sanitize_build_state(raw_state)
	if owner_player != null and owner_player.has_method("is_head_detached_from_torso") and bool(owner_player.call("is_head_detached_from_torso")):
		return _result(false, "Return to your detached torso before applying builds.", state)

	var required_counts := _bone_counts(state.values())
	var inventory_counts := _bone_counts(inventory_items)

	for bone_id in required_counts:
		if int(required_counts[bone_id]) > int(inventory_counts.get(bone_id, 0)):
			return _result(false, "Missing carried copies for " + BoneRulesService.display_name_with_slot(str(bone_id)) + ".", state)

	for slot in state:
		var slot_id := str(slot)
		var bone_id := str(state[slot])
		if not EquipmentRulesService.CANONICAL_BODY_SLOTS.has(slot_id):
			return _result(false, "Unknown slot in build: " + slot_id, state)
		if slot_id == EquipmentRulesService.SLOT_HEAD:
			return _result(false, "Builds cannot replace the fixed head.", state)
		if not EquipmentRulesService.can_equip_bone_in_slot(bone_id, slot_id):
			return _result(false, BoneRulesService.display_name_with_slot(bone_id) + " cannot equip in " + EquipmentRulesService.slot_display_name(slot_id) + ".", state)

	var has_limb := false
	for limb_slot in PlayerEquipmentComponent.TORSO_REQUIRED_SLOTS:
		if state.has(str(limb_slot)):
			has_limb = true
			break
	if has_limb and not state.has(EquipmentRulesService.SLOT_TORSO):
		return _result(false, "Builds with limbs must include a torso.", state)

	return _result(true, "Build is valid.", state)


func get_build_summaries() -> Array:
	var summaries: Array = []
	for index in range(1, BUILD_SLOT_COUNT + 1):
		var state: Dictionary = builds.get(index, {})
		summaries.append({
			"index": index,
			"is_empty": state.is_empty(),
			"summary": _summary_for_state(state),
		})
	return summaries


func _apply_validated_state(target_state: Dictionary) -> void:
	var current_state := equipment_component.get_equipment_state()
	for slot in current_state.keys():
		var slot_id := EquipmentRulesService.normalize_slot_id(str(slot))
		if slot_id == "" or slot_id == EquipmentRulesService.SLOT_HEAD:
			continue
		if not target_state.has(slot_id):
			equipment_component.unequip_slot(slot_id)

	for slot_id in APPLY_ORDER:
		var bone_id := str(target_state.get(slot_id, ""))
		if bone_id == "":
			continue
		if equipment_component.get_equipped_bone_for_slot(slot_id) == bone_id:
			continue
		equipment_component.equip_bone(bone_id, slot_id)


func _matches_equipment_state(target_state: Dictionary) -> bool:
	for slot_id in APPLY_ORDER:
		var expected := str(target_state.get(slot_id, ""))
		var actual := equipment_component.get_equipped_bone_for_slot(slot_id)
		if expected != actual:
			return false
	return true


func _sanitize_build_state(raw_state: Dictionary) -> Dictionary:
	var state: Dictionary = {}
	for raw_slot in raw_state:
		var slot_id := EquipmentRulesService.normalize_slot_id(str(raw_slot))
		var bone_id := str(raw_state[raw_slot])
		if slot_id == "" or bone_id == "":
			continue
		if slot_id == EquipmentRulesService.SLOT_HEAD:
			continue
		state[slot_id] = bone_id
	return state


func _bone_counts(items: Array) -> Dictionary:
	var counts: Dictionary = {}
	for item in items:
		var bone_id := str(item)
		if bone_id == "":
			continue
		counts[bone_id] = int(counts.get(bone_id, 0)) + 1
	return counts


func _inventory_items() -> Array:
	if owner_player != null and owner_player.has_method("get_inventory_items"):
		return owner_player.call("get_inventory_items") as Array
	return []


func _load_builds() -> void:
	builds.clear()
	var config := ConfigFile.new()
	if config.load(BUILD_SETTINGS_PATH) != OK:
		return
	for index in range(1, BUILD_SLOT_COUNT + 1):
		var value: Variant = config.get_value(BUILD_SECTION, str(index), {})
		if typeof(value) == TYPE_DICTIONARY:
			builds[index] = _sanitize_build_state(value as Dictionary)


func _save_builds() -> void:
	var config := ConfigFile.new()
	for index in range(1, BUILD_SLOT_COUNT + 1):
		config.set_value(BUILD_SECTION, str(index), builds.get(index, {}))
	config.save(BUILD_SETTINGS_PATH)


func _summary_for_state(state: Dictionary) -> String:
	if state.is_empty():
		return "Empty"
	var parts: Array[String] = []
	for slot_id in APPLY_ORDER:
		var bone_id := str(state.get(slot_id, ""))
		if bone_id == "":
			continue
		parts.append(EquipmentRulesService.slot_display_name(slot_id) + ": " + BoneRulesService.display_name_with_slot(bone_id))
	var text := ""
	for part in parts:
		if text != "":
			text += ", "
		text += part
	return text


func _valid_index(index: int) -> bool:
	return index >= 1 and index <= BUILD_SLOT_COUNT


func _result(ok: bool, message: String, state: Dictionary = {}) -> Dictionary:
	return {
		"ok": ok,
		"message": message,
		"state": state,
	}
