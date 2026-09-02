class_name LootTableDefinition
extends Resource

# One authored loot table: which bone types a container can hand out, how many,
# and how the piece quality is tilted.
#
# This Resource holds DATA ONLY. The rules that read it live in
# LootTableService, exactly like BoneDefinition holds bone data and
# BoneRulesService holds the rules for it.
#
# Deliberate design constraints:
#   * A table lists bone TYPES (bone_ids), never instances and never rolled
#     quality. Individual pieces come into existence at open time, so a table
#     can be reused by any number of chests without two of them sharing a piece.
#   * A table does not carry its own drop weights by default. The weight of a
#     bone already lives on the bone (`rarity_drop_weight`), which is what makes
#     rarity mean the same thing everywhere. weight_overrides exists for the
#     rare case where one table wants a different emphasis, and is the exception.
#   * difficulty_min/max are a FILTER for callers picking a table, not a
#     gate inside the roll. A chest that names a table by id always gets it.

@export_group("Identity")
@export var table_id: String = ""
@export var display_name: String = "Loot Table"
@export_multiline var description: String = ""

@export_group("Contents")
# Always handed out, ignoring weights. Use for the "this camp owes you an arm"
# case that the old DemoEnemyCamp.reward_bone_id covered.
@export var guaranteed_bone_ids: Array[String] = []
# The weighted pool. Entries with a drop weight of 0 can never be picked.
@export var entries: Array[String] = []
# bone_id -> weight. Overrides the bone's own rarity_drop_weight for this table.
@export var weight_overrides: Dictionary = {}
# How many WEIGHTED picks happen, on top of the guaranteed ids.
@export_range(0, 8, 1) var min_rolls: int = 1
@export_range(0, 8, 1) var max_rolls: int = 1
# When false a weighted pick that repeats an already-picked type is re-drawn,
# so a table with enough distinct entries hands out distinct types.
@export var allow_duplicates: bool = false

@export_group("Quality")
# Tilts the quality ladder for every piece this table produces. See
# BoneQualityService.roll_quality_id_biased -- +0.2 means each rung is 20% more
# likely than the one below it. The bone's own quality_drop_percent is added on
# top, so a table-wide tilt and a per-bone tilt compose.
@export_range(-0.75, 0.75, 0.01) var quality_bias: float = 0.0

@export_group("Progression")
@export_range(1, 10, 1) var difficulty_min: int = 1
@export_range(1, 10, 1) var difficulty_max: int = 10


func matches_difficulty(difficulty: int) -> bool:
	return difficulty >= difficulty_min and difficulty <= difficulty_max


func has_weight_override(bone_id: String) -> bool:
	return weight_overrides.has(bone_id)


func weight_override_for(bone_id: String) -> float:
	return float(weight_overrides.get(bone_id, 0.0))


func roll_count_range() -> Vector2i:
	# Authoring mistakes must not produce a negative span at runtime.
	var low: int = maxi(0, min_rolls)
	var high: int = maxi(low, max_rolls)
	return Vector2i(low, high)


# Everything that is wrong with this table as authored, in plain language.
# Empty means the table is usable. LootTableService calls this so a broken
# table fails loudly at load instead of silently handing out nothing, and
# tools/headless_loot_table_check.gd reports the same list.
#
# This is the ONLY definition of "valid table" in the project: the checker does
# not keep a second copy of these rules.
func validation_errors() -> Array[String]:
	var errors: Array[String] = []

	if table_id.strip_edges() == "":
		errors.append("table_id is empty.")

	if min_rolls > max_rolls:
		errors.append("min_rolls (%d) is greater than max_rolls (%d)." % [min_rolls, max_rolls])

	if difficulty_min > difficulty_max:
		errors.append("difficulty_min (%d) is greater than difficulty_max (%d)." % [difficulty_min, difficulty_max])

	if guaranteed_bone_ids.is_empty() and entries.is_empty():
		errors.append("Table has no guaranteed ids and no weighted entries; it can only ever produce nothing.")

	if max_rolls > 0 and entries.is_empty():
		errors.append("max_rolls is %d but the weighted pool is empty." % max_rolls)

	errors.append_array(_bone_id_errors(guaranteed_bone_ids, "guaranteed_bone_ids"))
	errors.append_array(_bone_id_errors(entries, "entries"))

	# An entry that can never be picked is almost always an authoring slip: it
	# reads as content but contributes nothing. head_bone is the built-in case
	# (rarity_drop_weight 0.0, because the fixed core must never drop).
	for bone_id in entries:
		if _resolved_weight(str(bone_id)) <= 0.0:
			errors.append("entries: '%s' has a drop weight of 0 and can never be picked." % str(bone_id))

	if not allow_duplicates and max_rolls > _distinct_entry_count():
		errors.append(
			"allow_duplicates is false but max_rolls (%d) exceeds the %d distinct pickable entries."
			% [max_rolls, _distinct_entry_count()]
		)

	for bone_id in weight_overrides:
		if not entries.has(str(bone_id)) and not guaranteed_bone_ids.has(str(bone_id)):
			errors.append("weight_overrides: '%s' is not in this table." % str(bone_id))
		elif weight_override_for(str(bone_id)) < 0.0:
			errors.append("weight_overrides: '%s' is negative." % str(bone_id))

	return errors


func _bone_id_errors(ids: Array[String], field_name: String) -> Array[String]:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	for raw_id in ids:
		var bone_id := str(raw_id)
		if bone_id.strip_edges() == "":
			errors.append("%s contains an empty id." % field_name)
			continue
		if seen.has(bone_id):
			errors.append("%s lists '%s' twice." % [field_name, bone_id])
			continue
		seen[bone_id] = true
		# Resolves hand-authored bones AND generated enemy limbs through the one
		# shared lookup, so a table may mix both without knowing the difference.
		if BoneRulesService.definition_for(bone_id).is_empty():
			errors.append("%s: '%s' does not resolve to any bone definition." % [field_name, bone_id])
	return errors


func _resolved_weight(bone_id: String) -> float:
	if has_weight_override(bone_id):
		return weight_override_for(bone_id)
	return BoneRulesService.rarity_drop_weight_for(bone_id)


func _distinct_entry_count() -> int:
	var count := 0
	var seen: Dictionary = {}
	for raw_id in entries:
		var bone_id := str(raw_id)
		if seen.has(bone_id):
			continue
		seen[bone_id] = true
		if _resolved_weight(bone_id) > 0.0:
			count += 1
	return count
