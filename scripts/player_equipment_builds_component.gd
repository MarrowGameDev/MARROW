class_name PlayerEquipmentBuildsComponent
extends Node

const BUILD_SETTINGS_PATH := "user://equipment_builds.cfg"
const BUILD_SECTION := "builds"
const INSTANCE_SECTION := "instances"
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
	var record: Dictionary = builds.get(index, {"name": "Build " + str(index)})
	record["slots"] = state
	builds[index] = record
	_save_builds()
	return _result(true, "Saved " + build_display_name(index) + ".", state)


func apply_build(index: int) -> Dictionary:
	if not _valid_index(index):
		return _result(false, "Unknown build slot.")
	if equipment_component == null:
		return _result(false, "Equipment is not ready.")
	if not builds.has(index):
		return _result(false, "Build " + str(index) + " is empty.")

	var validation := validate_build_state(build_slots(index), _inventory_items())
	if not bool(validation.get("ok", false)):
		return validation

	var target_state: Dictionary = validation.get("state", {})
	# Resolve to the exact saved pieces. An incomplete result means something is
	# no longer carried, and a build must never apply partially.
	var resolved_state := _resolve_build_to_instances(target_state)
	if resolved_state.size() != target_state.size():
		return _result(false, "Missing carried pieces for build " + str(index) + ".", target_state)

	# Snapshot before mutating anything, so a failed apply can be rolled
	# back to exactly what was equipped a moment ago.
	var previous_state := equipment_component.get_equipment_state()

	_apply_validated_state(resolved_state)

	if _matches_equipment_state(resolved_state):
		return _result(true, "Applied build " + str(index) + ".", resolved_state)

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

	# A build requires each saved piece's TYPE, not its exact instance or
	# quality: resolve_build_snapshot prefers the exact saved piece and falls
	# back to the best-quality carried copy of the same bone. Only a type with
	# no carried copy at all counts as missing.
	var availability := resolve_build_snapshot(state, inventory_items)
	if int(availability["missing_count"]) > 0:
		var missing: Array[String] = []
		for slot_key in (availability["slots"] as Dictionary):
			var entry: Dictionary = (availability["slots"] as Dictionary)[slot_key]
			if not bool(entry.get("found", false)):
				missing.append(BoneRulesService.display_name_with_slot(str(entry.get("instance_id", ""))))
		return _result(false, "Missing %d piece(s): %s" % [missing.size(), ", ".join(missing)], state)

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
	for index in build_indices():
		var state: Dictionary = build_slots(index)
		summaries.append({
			"index": index,
			"is_empty": state.is_empty(),
			"summary": _summary_for_state(state),
		})
	return summaries


# Floats that differ by less than this are the same number. Centralised so the
# panel cannot invent a "+0.00" delta out of accumulated decimal error.
const STAT_EPSILON := 0.005

const STATE_EMPTY := "Empty"
const STATE_SAVED := "Saved"
const STATE_EQUIPPED := "Currently Equipped"
const STATE_MISSING := "Missing parts"


# A build is Currently Equipped only when every slot it names holds the exact
# same INSTANCE that is worn right now, and the worn set has nothing extra.
# Comparing by bone_id would call a Frail arm and a Pristine arm the same
# loadout even though their effective stats differ.
func matches_current_equipment(snapshot: Dictionary) -> bool:
	if equipment_component == null or bool(snapshot.get("is_empty", true)):
		return false
	if int(snapshot.get("missing_count", 0)) > 0:
		return false

	var current := equipment_component.get_equipment_state()
	var build_state: Dictionary = snapshot.get("equipment_state", {})
	for slot_id in build_state:
		if str(current.get(slot_id, "")) != str(build_state[slot_id]):
			return false
	# Anything worn beyond what the build names means the build is not what is
	# currently on the player.
	for slot_id in current:
		var worn := str(current[slot_id])
		if worn == "" or str(slot_id) == EquipmentRulesService.SLOT_HEAD:
			continue
		if not build_state.has(slot_id):
			return false
	return true


func build_state_label(index: int) -> String:
	if not builds.has(index):
		return STATE_EMPTY
	var snapshot := resolve_build_snapshot(build_slots(index))
	if bool(snapshot["is_empty"]):
		return STATE_EMPTY
	if int(snapshot["missing_count"]) > 0:
		return STATE_MISSING
	if matches_current_equipment(snapshot):
		return STATE_EQUIPPED
	return STATE_SAVED


func get_build_report(index: int) -> Dictionary:
	var report := {
		"ok": false,
		"name": build_display_name(index),
		"state": STATE_EMPTY,
		"slots": {},
		"stats": {},
		"quality_counts": {},
		"effects": [],
		"comparison": {},
		"missing_count": 0,
		"matches_current": false,
		"message": "Empty",
	}
	if not _valid_index(index) or not builds.has(index) or equipment_component == null:
		return report

	# One snapshot, consumed by every field below: the piece table, the stats,
	# the composition, the effects and the match state all describe the SAME
	# resolved pieces.
	var snapshot := resolve_build_snapshot(build_slots(index))
	report["slots"] = snapshot["slots"]
	report["missing_count"] = int(snapshot["missing_count"])
	if bool(snapshot["is_empty"]):
		return report

	# Composition describes the SAVED build: a piece that is temporarily
	# missing still counts here (availability is reported separately), so the
	# breakdown does not shrink just because an instance is mislaid.
	var saved_counts: Dictionary = {}
	for slot_key in (snapshot["slots"] as Dictionary):
		var slot_quality := str(((snapshot["slots"] as Dictionary)[slot_key] as Dictionary).get("quality_id", ""))
		saved_counts[slot_quality] = int(saved_counts.get(slot_quality, 0)) + 1
	report["quality_counts"] = saved_counts

	# Effects and composition describe the pieces that ACTUALLY RESOLVE, plus
	# the worn head -- the same state the stats below are computed from, so a
	# panel can never show a synergy the stat pipeline did not apply. A piece
	# that is no longer carried contributes to nothing; `effects_partial` says
	# so explicitly rather than letting a shorter list read as "no synergy".
	# The head matters here beyond bookkeeping: it is a real piece with a real
	# rolled quality, so it can be the fourth member of High-Quality Assembly.
	var current_equipment := equipment_component.get_equipment_state()
	var resolved_state: Dictionary = _with_current_head(snapshot["equipment_state"], current_equipment)
	report["effects"] = _effects_for_state(resolved_state)
	report["composition"] = _composition_for_state(resolved_state)
	report["effects_partial"] = int(snapshot["missing_count"]) > 0

	if int(snapshot["missing_count"]) > 0:
		report["state"] = STATE_MISSING
		report["message"] = "%d piece(s) no longer carried." % int(snapshot["missing_count"])
		return report

	var build_state: Dictionary = snapshot["equipment_state"]
	var matches := matches_current_equipment(snapshot)
	report["matches_current"] = matches
	report["state"] = STATE_EQUIPPED if matches else STATE_SAVED
	report["message"] = "Matches current equipment" if matches else ""

	# Both sides go through the same central stat function, so effective is
	# always compared against effective -- and both sides must describe the
	# same body. A build never stores the head (it is the fixed core that
	# builds cannot replace), but the worn state always has one, so comparing
	# them raw reported the head's weight as a permanent phantom delta on a
	# build that was otherwise identical to the current gear. Applying a build
	# leaves the head in place, so the build's stats include it too.
	var build_stats := _stats_for_state(_with_current_head(build_state, current_equipment))
	var current_stats := _stats_for_state(current_equipment)
	var comparison: Dictionary = {}
	for key in build_stats:
		var delta: float = float(build_stats[key]) - float(current_stats.get(key, 0.0))
		# Anything inside the tolerance is not a difference. A build that is
		# currently equipped must never report one.
		comparison[key] = 0.0 if absf(delta) < STAT_EPSILON else delta

	report["ok"] = true
	report["stats"] = build_stats
	report["current_stats"] = current_stats
	report["comparison"] = comparison
	# The worn loadout's own synergies, so a panel can show both sides of the
	# comparison without evaluating anything itself. A build that matches the
	# current equipment produces an identical list by construction: both go
	# through the same evaluator over the same resolved state.
	report["current_effects"] = _effects_for_state(current_equipment)
	return report


# Builds carry no user-entered name: there is no text-entry control anywhere in
# this panel, and _sanitize_build_state would drop a non-slot key anyway. This
# is the single place a rename would hook into once that control exists.
func build_display_name(index: int) -> String:
	var record: Dictionary = builds.get(index, {})
	return str(record.get("name", "Build " + str(index)))


func _stats_for_state(state: Dictionary) -> Dictionary:
	# Bases come from PlayerStatsComponent, which stored them ONCE at setup,
	# before any equipment math ran. Reading player.max_health here is a trap:
	# the player overwrites that property with the equipment-DERIVED maximum
	# on every recalculation, so using it as a base fed the result back into
	# the formula and double-counted every equipped HP bonus -- a worn set
	# showed Health 22 on this screen while the real in-game maximum was 10.
	# (Speed/damage/reach never had the bug: their base_* properties are
	# separate variables the recalculation does not touch.)
	var stats: Dictionary = BoneRulesService.player_stats_with_equipment(
		_true_base("base_move_speed", 0.0),
		_true_base("base_attack_range", 0.0),
		int(_true_base("base_attack_damage", 0.0)),
		int(_true_base("base_max_health", 1.0)),
		state
	)
	return {
		"health": float(stats.get("max_health", 0)),
		"damage": float(stats.get("attack_damage", 0)),
		"speed": float(stats.get("move_speed", 0.0)),
		"reach": float(stats.get("attack_range", 0.0)),
		"weight": float(stats.get("equipment_weight", 0.0)),
	}


func _true_base(property: String, fallback: float) -> float:
	if owner_player == null:
		return fallback
	var stats_component: Variant = owner_player.get("stats_component")
	if stats_component != null:
		var stored: Variant = stats_component.get(property)
		if stored != null:
			return float(stored)
	return fallback


func _quality_counts_for(state: Dictionary) -> Dictionary:
	var counts: Dictionary = {}
	for slot_id in state:
		var piece := str(state[slot_id])
		if piece == "":
			continue
		var quality_id := BoneInstanceService.quality_id_of(piece)
		counts[quality_id] = int(counts.get(quality_id, 0)) + 1
	return counts


# The synergies this state actually grants, straight from the central
# evaluator -- the SAME call the stat pipeline makes inside
# BoneRulesService.aggregate_player_bonuses_exact. Nothing here decides whether
# a rule is active, so a panel and the player's real stats cannot disagree.
#
# Entries are SynergyRulesService's render-ready shape:
#   {id, label, category, tier, pieces, bonuses: [{stat, value, is_percent, text}]}
func _effects_for_state(state: Dictionary) -> Array:
	return BoneRulesService.active_synergies_for(state)


# Descriptive breakdown for the composition panel: which families are present
# and how many pieces each has, which mirror pairs are matched, and how many
# worn pieces clear the high-quality bar. Counts only -- the bonuses these do
# or do not trigger come from _effects_for_state, so the two panels can never
# tell different stories.
func _composition_for_state(state: Dictionary) -> Dictionary:
	var pairs: Dictionary = SynergyRulesService.symmetric_pairs(state)
	var matched: Array = []
	if str(pairs.get(SynergyRulesService.PAIR_ARMS, "")) != "":
		matched.append(str((SynergyRulesService.SYMMETRY_RULES[SynergyRulesService.PAIR_ARMS] as Dictionary)["label"]))
	if str(pairs.get(SynergyRulesService.PAIR_LEGS, "")) != "":
		matched.append(str((SynergyRulesService.SYMMETRY_RULES[SynergyRulesService.PAIR_LEGS] as Dictionary)["label"]))

	return {
		"families": SynergyRulesService.family_composition(state),
		"matched_pairs": matched,
		"high_quality_count": SynergyRulesService.high_quality_piece_count(state),
		# Denominator is every worn slot including the fixed head, because the
		# head's rolled quality does count toward the high-quality threshold.
		"worn_count": state.size(),
	}


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
		# Builds remember the EXACT piece per slot (its instance_id), not just
		# its type. Storing only the type made a freshly saved build fail to
		# match the gear it was saved from: re-resolving picked the best-quality
		# copy rather than the worn one, so the panel showed phantom deltas like
		# "Speed +0.32" against equipment that had not changed. Identity is also
		# what lets a missing piece be reported instead of silently swapped for
		# a different-quality copy of the same bone.
		state[slot_id] = bone_id
	return state


# Counted by TYPE, so any carried copy satisfies a build's requirement
# regardless of its quality.
func _bone_counts(items: Array) -> Dictionary:
	var counts: Dictionary = {}
	for item in items:
		var bone_id := BoneInstanceService.bone_id_of(str(item))
		if bone_id == "":
			continue
		counts[bone_id] = int(counts.get(bone_id, 0)) + 1
	return counts


# THE single resolution point for a build. Everything that describes a build --
# the piece table, the stats, the composition, the effects, the preview and the
# match state -- must consume this, so no two widgets can disagree about what
# the build contains.
#
# Resolution is by EXACT instance: the piece a build was saved with is the
# piece it refers to. A piece that is no longer carried is reported missing
# rather than swapped for another copy of the same bone, because a different
# copy can carry a different quality and therefore different effective stats.
#
# Returns per slot:
#   {"instance_id", "bone_id", "quality_id", "found": bool}
func resolve_build_snapshot(raw_state: Dictionary, items: Variant = null) -> Dictionary:
	var state := _sanitize_build_state(raw_state)
	var source: Array = items if items is Array else _inventory_items()
	var carried: Dictionary = {}
	for item in source:
		carried[str(item)] = true

	# Pass 1: exact saved instances that are still carried keep their claim,
	# so a freshly saved build always resolves to the very pieces it was
	# saved from (no phantom deltas).
	var claimed: Dictionary = {}
	var exact: Dictionary = {}
	for slot_id in APPLY_ORDER:
		var piece := str(state.get(slot_id, ""))
		if piece != "" and carried.has(piece) and not claimed.has(piece):
			exact[slot_id] = piece
			claimed[piece] = true

	# Pass 2: a slot whose exact piece is gone takes the best-quality carried
	# copy of the SAME TYPE instead (frail < worn < normal < strong <
	# pristine). Only the piece TYPE is a build's requirement -- quality is
	# not -- because the inventory does not persist across sessions, so
	# demanding the exact instance left every build permanently unappliable.
	# The substitution is surfaced per slot ("substituted"), never silent.
	var slots: Dictionary = {}
	var missing := 0
	for slot_id in APPLY_ORDER:
		var piece := str(state.get(slot_id, ""))
		if piece == "":
			continue
		if exact.has(slot_id):
			slots[slot_id] = {
				"instance_id": piece,
				"saved_instance_id": piece,
				"bone_id": BoneInstanceService.bone_id_of(piece),
				"quality_id": BoneInstanceService.quality_id_of(piece),
				"found": true,
				"substituted": false,
			}
			continue

		var wanted_type := BoneInstanceService.bone_id_of(piece)
		var substitute := ""
		var best_rank := -1
		if wanted_type != "":
			for item in source:
				var candidate := str(item)
				if claimed.has(candidate):
					continue
				if BoneInstanceService.bone_id_of(candidate) != wanted_type:
					continue
				var rank := BoneQualityService.rank_for(BoneInstanceService.quality_id_of(candidate))
				if rank > best_rank:
					best_rank = rank
					substitute = candidate

		if substitute == "":
			missing += 1
			slots[slot_id] = {
				"instance_id": piece,
				"saved_instance_id": piece,
				"bone_id": wanted_type,
				"quality_id": BoneInstanceService.quality_id_of(piece),
				"found": false,
				"substituted": false,
			}
		else:
			claimed[substitute] = true
			slots[slot_id] = {
				"instance_id": substitute,
				"saved_instance_id": piece,
				"bone_id": wanted_type,
				"quality_id": BoneInstanceService.quality_id_of(substitute),
				"found": true,
				"substituted": true,
			}

	return {
		"slots": slots,
		"missing_count": missing,
		"is_empty": slots.is_empty(),
		# Only the pieces that actually resolved, in the shape the stat and
		# synergy services expect (slot -> instance id).
		"equipment_state": _equipment_state_from_slots(slots),
	}


# The head is the fixed core: builds never store it and applying one never
# changes it, so any stat comparison has to credit both sides with the head
# that is actually worn.
func _with_current_head(build_state: Dictionary, current_equipment: Dictionary) -> Dictionary:
	var combined := build_state.duplicate()
	var head := str(current_equipment.get(EquipmentRulesService.SLOT_HEAD, ""))
	if head != "":
		combined[EquipmentRulesService.SLOT_HEAD] = head
	return combined


func _equipment_state_from_slots(slots: Dictionary) -> Dictionary:
	var state: Dictionary = {}
	for slot_id in slots:
		var entry: Dictionary = slots[slot_id]
		if bool(entry.get("found", false)):
			state[slot_id] = str(entry["instance_id"])
	return state


# Kept as the apply path's view of the same snapshot: the exact pieces to equip,
# or an incomplete dictionary when something is missing (which apply_build
# treats as a refusal rather than a partial application).
func _resolve_build_to_instances(state: Dictionary) -> Dictionary:
	var snapshot := resolve_build_snapshot(state)
	if int(snapshot["missing_count"]) > 0:
		return {}
	return snapshot["equipment_state"]


func _inventory_items() -> Array:
	if owner_player != null and owner_player.has_method("get_inventory_items"):
		return owner_player.call("get_inventory_items") as Array
	return []


# A build record is {"name": String, "slots": {slot_id: instance_id}}. Files
# written before names existed hold a bare slot dictionary, so they are read
# through _as_record() and given a default name instead of being discarded.
func _load_builds() -> void:
	builds.clear()
	var config := ConfigFile.new()
	if config.load(BUILD_SETTINGS_PATH) != OK:
		_ensure_minimum_builds()
		return
	# Restore the instance registry FIRST. Builds reference pieces by
	# instance_id, and those ids are minted per session: without restoring the
	# registry, a build saved in an earlier run would resolve its ids against
	# whatever pieces happen to hold those ids now -- silently pointing at the
	# wrong bone, which is exactly what instance-exact builds exist to prevent.
	if config.has_section_key(INSTANCE_SECTION, "registry"):
		var registry: Variant = config.get_value(INSTANCE_SECTION, "registry", {})
		if typeof(registry) == TYPE_DICTIONARY:
			BoneInstanceService.restore(registry as Dictionary)

	for key in config.get_section_keys(BUILD_SECTION):
		var index := int(str(key))
		if index <= 0:
			continue
		var value: Variant = config.get_value(BUILD_SECTION, str(key), {})
		if typeof(value) == TYPE_DICTIONARY:
			builds[index] = _as_record(value as Dictionary, index)
	_ensure_minimum_builds()


# The panel always shows at least the original three slots, so an empty save
# file still offers somewhere to store a build.
func _ensure_minimum_builds() -> void:
	for index in range(1, BUILD_SLOT_COUNT + 1):
		if not builds.has(index):
			builds[index] = {"name": "Build " + str(index), "slots": {}}


func _as_record(raw: Dictionary, index: int) -> Dictionary:
	if raw.has("slots"):
		return {
			"name": str(raw.get("name", "Build " + str(index))),
			"slots": _sanitize_build_state(raw.get("slots", {})),
		}
	# Legacy shape: the dictionary IS the slot map.
	return {
		"name": "Build " + str(index),
		"slots": _sanitize_build_state(raw),
	}


func _save_builds() -> void:
	var config := ConfigFile.new()
	for index in builds:
		config.set_value(BUILD_SECTION, str(index), builds[index])
	# Saved alongside the builds so the ids they reference still mean the same
	# pieces next session.
	config.set_value(INSTANCE_SECTION, "registry", BoneInstanceService.serialize())
	config.save(BUILD_SETTINGS_PATH)


# --- build management -----------------------------------------------------

func build_indices() -> Array:
	var indices: Array = builds.keys()
	indices.sort()
	return indices


func create_build() -> int:
	var next_index := 1
	for index in builds:
		next_index = maxi(next_index, int(index) + 1)
	builds[next_index] = {"name": "Build " + str(next_index), "slots": {}}
	_save_builds()
	return next_index


func delete_build(index: int) -> Dictionary:
	if not builds.has(index):
		return _result(false, "Unknown build slot.")
	builds.erase(index)
	# Deleting a build never touches worn equipment.
	_ensure_minimum_builds()
	_save_builds()
	return _result(true, "Deleted build.")


func rename_build(index: int, new_name: String) -> Dictionary:
	if not builds.has(index):
		return _result(false, "Unknown build slot.")
	var clean := new_name.strip_edges()
	if clean == "":
		return _result(false, "Name cannot be empty.")
	# Only the label changes; slots are left exactly as they were.
	var record: Dictionary = builds[index]
	record["name"] = clean
	builds[index] = record
	_save_builds()
	return _result(true, "Renamed to " + clean + ".")


func build_slots(index: int) -> Dictionary:
	var record: Dictionary = builds.get(index, {})
	return record.get("slots", {})


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
	return builds.has(index)


func _result(ok: bool, message: String, state: Dictionary = {}) -> Dictionary:
	return {
		"ok": ok,
		"message": message,
		"state": state,
	}
