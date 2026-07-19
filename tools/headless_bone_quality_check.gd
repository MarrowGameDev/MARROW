extends SceneTree

# Runs the six verifications required for the bone-quality core, plus the
# invariants that keep quality separate from the other bone fields.

const SAMPLE_SIZE := 4000


func _initialize() -> void:
	var failures: Array[String] = []

	# --- table invariants ------------------------------------------------
	var total: float = BoneQualityService.total_probability()
	if absf(total - 100.0) > 0.0001:
		failures.append("probabilities total %.4f, expected exactly 100" % total)
	print("probability total: %.4f" % total)

	# 2. multipliers stay inside the specified band.
	for quality_id in BoneQualityService.QUALITY_ORDER:
		var m: float = BoneQualityService.multiplier_for(str(quality_id))
		if m < 0.85 - 0.0001 or m > 1.15 + 0.0001:
			failures.append("%s multiplier %.4f outside 0.85..1.15" % [str(quality_id), m])
	print("multipliers: ", _multiplier_map())

	# --- 1. Normal is clearly the most common ----------------------------
	BoneInstanceService.reset(12345)
	var counts: Dictionary = {}
	for i in range(SAMPLE_SIZE):
		var id := BoneInstanceService.create_instance("arm_bone")
		var q := BoneInstanceService.quality_id_of(id)
		counts[q] = int(counts.get(q, 0)) + 1
	print("distribution over %d rolls: %s" % [SAMPLE_SIZE, str(counts)])
	var normal_count: int = int(counts.get(BoneQualityService.QUALITY_NORMAL, 0))
	var normal_share: float = float(normal_count) / float(SAMPLE_SIZE)
	if normal_share < 0.6 or normal_share > 0.8:
		failures.append("Normal share %.3f is far from the specified 0.70" % normal_share)
	for quality_id in BoneQualityService.QUALITY_ORDER:
		if int(counts.get(str(quality_id), 0)) >= normal_count and str(quality_id) != BoneQualityService.QUALITY_NORMAL:
			failures.append("%s is not rarer than Normal" % str(quality_id))

	# --- 3. same seed twice -> same sequence -----------------------------
	var first := _sequence_with_seed(999, 40)
	var second := _sequence_with_seed(999, 40)
	var different := _sequence_with_seed(1000, 40)
	if first != second:
		failures.append("seeded sequence not reproducible")
	if first == different:
		failures.append("different seeds produced an identical sequence (RNG likely ignored)")
	print("seed 999 first 8: ", first.slice(0, 8))

	# --- 4. same type, different quality -> different effective stats ----
	BoneInstanceService.reset(7)
	var frail := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_FRAIL)
	var pristine := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_PRISTINE)
	var base: Dictionary = BoneRulesService.player_bonus_for("arm_bone")
	var frail_stats: Dictionary = BoneRulesService.adjusted_player_bonus_for(frail)
	var pristine_stats: Dictionary = BoneRulesService.adjusted_player_bonus_for(pristine)
	print("base      : ", base)
	print("frail     : ", frail_stats)
	print("pristine  : ", pristine_stats)
	var moved := false
	for key in ["move_speed", "attack_range", "attack_damage", "max_health"]:
		if absf(float(frail_stats[key]) - float(pristine_stats[key])) > 0.0001:
			moved = true
		# effective = base * multiplier, exactly.
		var expected_frail: float = float(base[key]) * 0.85
		if absf(float(frail_stats[key]) - expected_frail) > 0.0001:
			failures.append("frail %s = %.4f, expected base*0.85 = %.4f" % [key, float(frail_stats[key]), expected_frail])
	if not moved:
		failures.append("frail and pristine produced identical stats")

	# quality must not touch categorical data
	if BoneRulesService.slot_for(frail) != BoneRulesService.slot_for("arm_bone"):
		failures.append("quality changed the slot")
	if EquipmentRulesService.compatible_slots_for_bone(frail) != EquipmentRulesService.compatible_slots_for_bone("arm_bone"):
		failures.append("quality changed slot compatibility")
	if BoneInstanceService.bone_id_of(frail) != "arm_bone":
		failures.append("instance does not resolve back to its bone_id")

	# --- 5. legacy piece loads as its authored quality, never rolled -----
	# A plain bone_id String is the legacy path: no instance, no roll.
	var legacy_quality := BoneInstanceService.quality_id_of("arm_bone")
	if legacy_quality != BoneQualityService.QUALITY_NORMAL:
		failures.append("legacy arm_bone resolved to %s, expected normal" % legacy_quality)
	var legacy_repeat := BoneInstanceService.quality_id_of("arm_bone")
	if legacy_repeat != legacy_quality:
		failures.append("legacy quality is not stable across reads (it is being rolled)")
	# An unknown/blank definition must still land on Normal.
	if BoneQualityService.normalize_quality_id("") != BoneQualityService.QUALITY_NORMAL:
		failures.append("empty quality did not normalise to normal")
	if BoneQualityService.normalize_quality_id("nonsense") != BoneQualityService.QUALITY_NORMAL:
		failures.append("unknown quality did not normalise to normal")
	# Pre-rename ids keep their rung.
	var alias_expectations := {
		"chatarra": BoneQualityService.QUALITY_FRAIL,
		"fragil": BoneQualityService.QUALITY_WORN,
		"comun": BoneQualityService.QUALITY_NORMAL,
		"fuerte": BoneQualityService.QUALITY_STRONG,
		"legendario": BoneQualityService.QUALITY_PRISTINE,
	}
	for legacy_id in alias_expectations:
		var got := BoneQualityService.normalize_quality_id(str(legacy_id))
		if got != str(alias_expectations[legacy_id]):
			failures.append("legacy quality %s mapped to %s, expected %s" % [str(legacy_id), got, str(alias_expectations[legacy_id])])

	# --- 6. resolving an existing piece never changes its quality --------
	BoneInstanceService.reset(4242)
	var piece := BoneInstanceService.create_instance("leg_bone")
	var original := BoneInstanceService.quality_id_of(piece)
	for i in range(50):
		# Everything a piece goes through: inspect, equip, preview, build.
		BoneRulesService.adjusted_player_bonus_for(piece)
		BoneRulesService.display_name_with_slot(piece)
		BoneRulesService.quality_multiplier_for(piece)
		EquipmentRulesService.compatible_slots_for_bone(piece)
		BoneInstanceService.resolve(piece)
	if BoneInstanceService.quality_id_of(piece) != original:
		failures.append("quality changed after repeated resolution")
	print("piece %s stayed %s across 50 resolutions" % [piece, original])

	# --- serialisation round-trip ---------------------------------------
	var snapshot: Dictionary = BoneInstanceService.serialize()
	var before := BoneInstanceService.quality_id_of(piece)
	BoneInstanceService.reset(-1)
	BoneInstanceService.restore(snapshot)
	if BoneInstanceService.quality_id_of(piece) != before:
		failures.append("quality did not survive serialize/restore")
	# The multiplier must NOT be baked into the saved record.
	var record: Dictionary = (snapshot["instances"] as Dictionary)[piece]
	if record.has("multiplier") or record.has("quality_multiplier"):
		failures.append("multiplier was serialised onto the instance; it must come from the table")

	# --- stack key separates qualities ------------------------------------
	var a := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_STRONG)
	var b := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_STRONG)
	var c := BoneInstanceService.create_instance("arm_bone", BoneQualityService.QUALITY_FRAIL)
	if BoneInstanceService.stack_key_for(a) != BoneInstanceService.stack_key_for(b):
		failures.append("same type+quality did not share a stack key")
	if BoneInstanceService.stack_key_for(a) == BoneInstanceService.stack_key_for(c):
		failures.append("different qualities collapsed into one stack key")
	print("stack keys: strong=%s frail=%s" % [BoneInstanceService.stack_key_for(a), BoneInstanceService.stack_key_for(c)])

	print("")
	if failures.is_empty():
		print("BONE QUALITY CHECK: PASS")
	else:
		print("BONE QUALITY CHECK: FAIL")
		for f in failures:
			print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _multiplier_map() -> Dictionary:
	var out: Dictionary = {}
	for quality_id in BoneQualityService.QUALITY_ORDER:
		out[str(quality_id)] = BoneQualityService.multiplier_for(str(quality_id))
	return out


func _sequence_with_seed(seed_value: int, count: int) -> Array:
	BoneInstanceService.reset(seed_value)
	var out: Array = []
	for i in range(count):
		out.append(BoneInstanceService.quality_id_of(BoneInstanceService.create_instance("arm_bone")))
	return out
