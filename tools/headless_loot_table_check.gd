extends SceneTree

# Verifies the loot table layer: that every authored table is valid, that the
# weighted pick actually follows rarity_drop_weight, that the quality tilt moves
# the ladder in the right direction, and that a seed replays a run exactly.
#
# There is deliberately no second Python validator for tables. The rules for
# "valid table" live in LootTableDefinition.validation_errors(); duplicating
# them in a parser that cannot resolve generated enemy limbs would be a second
# source of truth that drifts.
#
#   godot --headless --path . --script tools/headless_loot_table_check.gd

const SAMPLE_SIZE := 4000


func _initialize() -> void:
	var failures: Array[String] = []

	failures.append_array(_check_authored_tables())
	failures.append_array(_check_unbiased_roll_is_unchanged())
	failures.append_array(_check_quality_bias_direction())
	failures.append_array(_check_bias_is_clamped())
	failures.append_array(_check_weights_follow_rarity())
	failures.append_array(_check_table_contracts())
	failures.append_array(_check_determinism())
	failures.append_array(_check_edge_cases())

	print("")
	if failures.is_empty():
		print("LOOT TABLE CHECK: PASS")
	else:
		print("LOOT TABLE CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)
	quit(0 if failures.is_empty() else 1)


# --- every authored table loads and validates -----------------------------

func _check_authored_tables() -> Array[String]:
	var failures: Array[String] = []
	var report: Dictionary = LootTableService.validation_report()
	for table_id in report:
		for problem in (report[table_id] as Array):
			failures.append("table '%s': %s" % [str(table_id), str(problem)])

	print("authored tables: ", LootTableService.table_ids())
	for table_id in LootTableService.table_ids():
		var table := LootTableService.table_for(str(table_id))
		if table == null:
			failures.append("table '%s' failed to load" % str(table_id))
			continue
		print("  %-16s difficulty %d-%d  guaranteed %d  pool %d  rolls %d-%d  bias %+.2f" % [
			table.table_id,
			table.difficulty_min,
			table.difficulty_max,
			table.guaranteed_bone_ids.size(),
			table.entries.size(),
			table.min_rolls,
			table.max_rolls,
			table.quality_bias,
		])

	# The difficulty bands must actually cover the seven map regions, or a stage
	# could end up with no table to offer.
	for difficulty in [1, 2, 3, 4, 5, 6, 7]:
		if LootTableService.tables_for_difficulty(difficulty).is_empty():
			failures.append("no table matches difficulty %d" % difficulty)

	return failures


# --- a zero bias must not change the existing drop behaviour --------------

func _check_unbiased_roll_is_unchanged() -> Array[String]:
	var failures: Array[String] = []

	BoneQualityService.set_seed(4242)
	var plain: Array[String] = []
	for i in range(200):
		plain.append(BoneQualityService.roll_quality_id())

	BoneQualityService.set_seed(4242)
	var biased_zero: Array[String] = []
	for i in range(200):
		biased_zero.append(BoneQualityService.roll_quality_id_biased(0.0))

	if plain != biased_zero:
		failures.append("roll_quality_id_biased(0.0) diverged from roll_quality_id(); existing drops would change")
	else:
		print("zero bias replays roll_quality_id() exactly over 200 rolls")

	# The weight table at zero bias must equal the authored probability column.
	var weights: Dictionary = BoneQualityService.biased_probabilities(0.0)
	for quality_id in BoneQualityService.QUALITY_ORDER:
		var expected: float = BoneQualityService.probability_for(str(quality_id))
		if absf(float(weights[quality_id]) - expected) > 0.0001:
			failures.append("zero-bias weight for %s is %.4f, expected %.4f" % [str(quality_id), float(weights[quality_id]), expected])

	return failures


# --- a positive bias must favour the good end, a negative one the bad ------

func _check_quality_bias_direction() -> Array[String]:
	var failures: Array[String] = []

	var base := _quality_distribution(0.0)
	var good := _quality_distribution(0.5)
	var bad := _quality_distribution(-0.5)

	print("quality share (pristine / normal / frail):")
	print("  bias  0.0 : %.3f / %.3f / %.3f" % [base["pristine"], base["normal"], base["frail"]])
	print("  bias +0.5 : %.3f / %.3f / %.3f" % [good["pristine"], good["normal"], good["frail"]])
	print("  bias -0.5 : %.3f / %.3f / %.3f" % [bad["pristine"], bad["normal"], bad["frail"]])

	if float(good["pristine"]) <= float(base["pristine"]):
		failures.append("a positive bias did not increase the Pristine share")
	if float(good["frail"]) >= float(base["frail"]):
		failures.append("a positive bias did not decrease the Frail share")
	if float(bad["pristine"]) >= float(base["pristine"]):
		failures.append("a negative bias did not decrease the Pristine share")
	if float(bad["frail"]) <= float(base["frail"]):
		failures.append("a negative bias did not increase the Frail share")

	# The ladder must stay a ladder: no tilt may make a rung unreachable.
	for bias in [-0.75, -0.3, 0.3, 0.75]:
		var weights: Dictionary = BoneQualityService.biased_probabilities(float(bias))
		for quality_id in BoneQualityService.QUALITY_ORDER:
			if float(weights[quality_id]) <= 0.0:
				failures.append("bias %+.2f made %s unreachable" % [float(bias), str(quality_id)])

	return failures


func _check_bias_is_clamped() -> Array[String]:
	var failures: Array[String] = []
	var at_limit: Dictionary = BoneQualityService.biased_probabilities(BoneQualityService.QUALITY_BIAS_LIMIT)
	var way_over: Dictionary = BoneQualityService.biased_probabilities(50.0)
	for quality_id in BoneQualityService.QUALITY_ORDER:
		if absf(float(at_limit[quality_id]) - float(way_over[quality_id])) > 0.0001:
			failures.append("bias was not clamped to +-%.2f" % BoneQualityService.QUALITY_BIAS_LIMIT)
			break
	print("bias clamped at +-%.2f" % BoneQualityService.QUALITY_BIAS_LIMIT)
	return failures


# --- weighted picks follow rarity_drop_weight -----------------------------

func _check_weights_follow_rarity() -> Array[String]:
	var failures: Array[String] = []

	# heavy_bone (especial, weight 0.4) against dummy_bone (comun, weight 1.2):
	# a 3x weight gap has to show up as a clear frequency gap.
	var table := LootTableDefinition.new()
	table.table_id = "weight_probe"
	table.entries = ["dummy_bone", "heavy_bone"]
	table.min_rolls = 1
	table.max_rolls = 1
	table.allow_duplicates = true

	LootTableService.set_seed(31337)
	var counts: Dictionary = {}
	for i in range(SAMPLE_SIZE):
		for bone_id in LootTableService.roll_bone_ids_from(table):
			counts[bone_id] = int(counts.get(bone_id, 0)) + 1

	var common: float = float(counts.get("dummy_bone", 0)) / float(SAMPLE_SIZE)
	var special: float = float(counts.get("heavy_bone", 0)) / float(SAMPLE_SIZE)
	print("weighted draw over %d rolls: dummy %.3f vs heavy %.3f (weights %.2f / %.2f)" % [
		SAMPLE_SIZE,
		common,
		special,
		LootTableService.drop_weight_for("dummy_bone"),
		LootTableService.drop_weight_for("heavy_bone"),
	])
	# Expected share is 1.2/1.6 = 0.75 against 0.4/1.6 = 0.25.
	if absf(common - 0.75) > 0.03:
		failures.append("common share %.3f is far from the weighted expectation 0.75" % common)

	# A weight override has to beat the bone's own weight.
	table.weight_overrides = {"heavy_bone": 9.0}
	LootTableService.set_seed(31337)
	var override_hits := 0
	for i in range(500):
		if LootTableService.roll_bone_ids_from(table).has("heavy_bone"):
			override_hits += 1
	if float(override_hits) / 500.0 < 0.6:
		failures.append("weight_overrides did not raise heavy_bone's frequency (%d/500)" % override_hits)
	else:
		print("weight override lifted heavy_bone to %d/500" % override_hits)

	# The fixed core has weight 0 and must never be handed out by any table.
	if LootTableService.drop_weight_for("head_bone") != 0.0:
		failures.append("head_bone has a non-zero drop weight; the fixed core could drop")

	return failures


# --- guaranteed ids, roll counts and duplicate policy ---------------------

func _check_table_contracts() -> Array[String]:
	var failures: Array[String] = []

	LootTableService.seed_all(777)
	for table_id in LootTableService.table_ids():
		var table := LootTableService.table_for(str(table_id))
		if table == null:
			continue
		var span := table.roll_count_range()

		for attempt in range(200):
			var loot: Array[Dictionary] = LootTableService.roll_loot(str(table_id))
			var bone_ids: Array[String] = []
			for entry in loot:
				bone_ids.append(str(entry["bone_id"]))
				if not BoneQualityService.is_quality_id(str(entry["quality_id"])):
					failures.append("%s produced an invalid quality id '%s'" % [str(table_id), str(entry["quality_id"])])
				if str(entry["bone_id"]) == "head_bone":
					failures.append("%s handed out the fixed head core" % str(table_id))

			for guaranteed in table.guaranteed_bone_ids:
				if not bone_ids.has(str(guaranteed)):
					failures.append("%s did not include guaranteed '%s'" % [str(table_id), str(guaranteed)])

			var weighted_count: int = bone_ids.size() - table.guaranteed_bone_ids.size()
			if weighted_count < span.x or weighted_count > span.y:
				failures.append("%s rolled %d weighted pieces, outside %d-%d" % [str(table_id), weighted_count, span.x, span.y])

			if not table.allow_duplicates:
				var seen: Dictionary = {}
				for i in range(table.guaranteed_bone_ids.size(), bone_ids.size()):
					var bone_id := bone_ids[i]
					if seen.has(bone_id):
						failures.append("%s repeated '%s' with allow_duplicates off" % [str(table_id), bone_id])
					seen[bone_id] = true

	if failures.is_empty():
		print("all tables honoured guaranteed ids, roll counts and duplicate policy over 200 opens each")
	return failures


# --- a seed replays a run exactly -----------------------------------------

func _check_determinism() -> Array[String]:
	var failures: Array[String] = []

	var first := _loot_sequence(5150, 30)
	var second := _loot_sequence(5150, 30)
	var different := _loot_sequence(5151, 30)

	if first != second:
		failures.append("the same seed did not replay the same loot")
	if first == different:
		failures.append("two different seeds produced identical loot (RNG likely ignored)")
	print("seed 5150 first open: ", first.slice(0, 3))

	# Resuming from a saved RNG position must continue the sequence rather than
	# restart it -- this is what stops every load handing out the same loot.
	LootTableService.seed_all(2024)
	LootTableService.roll_loot("field_cache")
	var resume_state: int = LootTableService.rng_state()
	var after_a := LootTableService.roll_bone_ids("field_cache")
	LootTableService.set_rng_state(resume_state)
	var after_b := LootTableService.roll_bone_ids("field_cache")
	if after_a != after_b:
		failures.append("restoring rng_state did not resume the same sequence")
	else:
		print("rng_state round-trip resumed the sequence")

	return failures


func _check_edge_cases() -> Array[String]:
	var failures: Array[String] = []

	# An unknown table is a content mistake, not a crash.
	if not LootTableService.roll_loot("no_such_table").is_empty():
		failures.append("an unknown table id produced loot")
	if LootTableService.has_table("no_such_table"):
		failures.append("has_table returned true for an unknown id")
	if not LootTableService.roll_loot_from(null).is_empty():
		failures.append("a null table produced loot")

	# The single-bone compatibility path used by DemoEnemyCamp.reward_bone_id.
	var inline := LootTableService.single_bone_table("dummy_bone")
	if not inline.validation_errors().is_empty():
		failures.append("single_bone_table produced an invalid table: " + ", ".join(inline.validation_errors()))
	var inline_loot: Array[Dictionary] = LootTableService.roll_loot_from(inline)
	if inline_loot.size() != 1 or str(inline_loot[0]["bone_id"]) != "dummy_bone":
		failures.append("single_bone_table did not produce exactly its one bone")
	else:
		print("single_bone_table('dummy_bone') -> %s [%s]" % [str(inline_loot[0]["bone_id"]), str(inline_loot[0]["quality_id"])])

	# A table authored with real problems must report them rather than roll.
	var broken := LootTableDefinition.new()
	broken.entries = ["not_a_real_bone"]
	broken.min_rolls = 3
	broken.max_rolls = 1
	var broken_errors := broken.validation_errors()
	for expected in ["table_id is empty.", "min_rolls"]:
		var found := false
		for error in broken_errors:
			if error.contains(str(expected)):
				found = true
				break
		if not found:
			failures.append("validation missed '%s'; got: %s" % [str(expected), ", ".join(broken_errors)])
	if broken_errors.size() < 3:
		failures.append("a table with three separate faults reported only %d error(s)" % broken_errors.size())
	else:
		print("broken table reported %d problems, including: %s" % [broken_errors.size(), broken_errors[0]])

	return failures


# --- helpers --------------------------------------------------------------

func _quality_distribution(bias: float) -> Dictionary:
	BoneQualityService.set_seed(90210)
	var counts: Dictionary = {}
	for i in range(SAMPLE_SIZE):
		var quality_id := BoneQualityService.roll_quality_id_biased(bias)
		counts[quality_id] = int(counts.get(quality_id, 0)) + 1

	var shares: Dictionary = {}
	for quality_id in BoneQualityService.QUALITY_ORDER:
		shares[str(quality_id)] = float(counts.get(str(quality_id), 0)) / float(SAMPLE_SIZE)
	return shares


func _loot_sequence(seed_value: int, opens: int) -> Array[String]:
	LootTableService.seed_all(seed_value)
	var out: Array[String] = []
	for i in range(opens):
		for entry in LootTableService.roll_loot("elder_cache"):
			out.append("%s:%s" % [str(entry["bone_id"]), str(entry["quality_id"])])
	return out
