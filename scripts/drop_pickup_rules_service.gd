class_name DropPickupRulesService

const PICKUP_ACTION: String = "interact"
const DETACHABLE_LIMBS: Array[String] = ["right_arm", "left_arm", "right_leg", "left_leg", "body", "head"]
const PICKUP_ELIGIBLE_LIMBS: Array[String] = ["right_arm", "left_arm", "right_leg", "left_leg", "body", "head"]
const CORE_FALL_ORDER: Array[String] = ["body", "head"]


static func detachable_limb_keys() -> Array[String]:
	return _copy_string_array(DETACHABLE_LIMBS)


static func pickup_eligible_limb_keys() -> Array[String]:
	return _copy_string_array(PICKUP_ELIGIBLE_LIMBS)


static func core_fall_order() -> Array[String]:
	return _copy_string_array(CORE_FALL_ORDER)


static func is_core_limb(limb_key: String) -> bool:
	return CORE_FALL_ORDER.has(limb_key)


static func is_pickup_eligible_limb(limb_key: String) -> bool:
	return PICKUP_ELIGIBLE_LIMBS.has(limb_key)


static func pickup_bone_id_for_limb(limb_key: String, source_profile: String = "normal") -> String:
	return EquipmentRulesService.pickup_bone_id_for_limb(limb_key, source_profile)


static func pickup_bone_id_is_valid(limb_key: String, source_profile: String = "normal") -> bool:
	return pickup_bone_id_for_limb(limb_key, source_profile) != ""


static func next_pickup_hold_progress(current_progress: float, delta: float, is_holding: bool) -> float:
	if is_holding:
		return current_progress + delta
	return 0.0


static func pickup_hold_is_complete(hold_progress: float, pickup_hold_time: float) -> bool:
	return hold_progress >= maxf(0.01, pickup_hold_time)


static func pickup_prompt_text(bone_id: String, hold_progress: float, pickup_hold_time: float, player_is_in_range: bool) -> String:
	var display_name: String = pickup_display_name(bone_id)
	if not player_is_in_range:
		return display_name

	var percent: int = int((hold_progress / maxf(0.01, pickup_hold_time)) * 100.0)
	percent = clampi(percent, 0, 100)
	return "Hold " + action_binding_text(PICKUP_ACTION) + ": " + display_name + " " + str(percent) + "%"


static func pickup_display_name(bone_id: String) -> String:
	var definition: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not definition.is_empty():
		return str(definition.get("display_name", "Enemy Bone"))
	return BoneRulesService.display_name_with_slot(bone_id)


static func action_binding_text(action: String) -> String:
	if not InputMap.has_action(action):
		return action
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return action
	var event := events[0]
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var key_name := OS.get_keycode_string(key_event.keycode)
		if key_name != "":
			return key_name
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		match mouse_event.button_index:
			MOUSE_BUTTON_LEFT:
				return "Left Click"
			MOUSE_BUTTON_RIGHT:
				return "Right Click"
			MOUSE_BUTTON_MIDDLE:
				return "Middle Click"
			_:
				return "Mouse " + str(mouse_event.button_index)
	return action


static func detachable_priority_for_bone(bone_id: String) -> Array[String]:
	var keys: Array[String] = []
	var slot_id: String = EquipmentRulesService.slot_for_bone(bone_id)
	for limb_key in EquipmentRulesService.primary_limb_keys_for_slot(slot_id):
		if is_core_limb(limb_key):
			continue
		if not keys.has(limb_key):
			keys.append(limb_key)
	for limb_key in DETACHABLE_LIMBS:
		if is_core_limb(limb_key):
			continue
		if not keys.has(limb_key):
			keys.append(limb_key)
	for core_key in CORE_FALL_ORDER:
		if not keys.has(core_key):
			keys.append(core_key)
	return keys


static func pickup_limb_candidates_for_bone(_bone_id: String) -> Array[String]:
	return _copy_string_array(PICKUP_ELIGIBLE_LIMBS)


static func drop_slot_matches_limb(bone_id: String, limb_key: String) -> bool:
	for slot_id in EquipmentRulesService.compatible_slots_for_bone(bone_id):
		if EquipmentRulesService.primary_limb_keys_for_slot(str(slot_id)).has(limb_key):
			return true
	return false


static func first_available_pickup_limb(detached_limb_keys: Array[String], source_profile: String = "normal") -> String:
	for limb_key in PICKUP_ELIGIBLE_LIMBS:
		if detached_limb_keys.has(limb_key):
			continue
		if pickup_bone_id_is_valid(limb_key, source_profile):
			return limb_key
	return ""


static func choose_death_pickup_limb(priority_limb_keys: Array[String], detached_limb_keys: Array[String], source_profile: String = "normal") -> String:
	var candidates: Array[String] = []
	for limb_key in priority_limb_keys:
		if detached_limb_keys.has(limb_key):
			continue
		if not is_pickup_eligible_limb(limb_key):
			continue
		if not pickup_bone_id_is_valid(limb_key, source_profile):
			continue
		candidates.append(limb_key)

	if candidates.is_empty():
		return ""
	return str(candidates[randi_range(0, candidates.size() - 1)])


static func _copy_string_array(values: Array[String]) -> Array[String]:
	var copy: Array[String] = []
	for value in values:
		copy.append(value)
	return copy
