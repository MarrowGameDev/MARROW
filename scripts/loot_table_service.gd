class_name LootTableService

# Rules for turning a loot table into a concrete list of pieces.
#
# This service is PURE in the sense the other *RulesService files are: it reads
# data, rolls, and returns descriptions. It never creates an instance, never
# touches a node and never puts anything in an inventory. The caller does:
#
#   for entry in LootTableService.roll_loot("field_cache"):
#       var instance_id := BoneInstanceService.create_instance(entry["bone_id"], entry["quality_id"])
#
# That split is what keeps "a piece came into existence" a single event owned by
# BoneInstanceService, which is where the once-only quality contract lives.
#
# Weights come from the BONE, not from the table (rarity_drop_weight, resolved
# through BoneRulesService so hand-authored bones and generated enemy limbs work
# the same way). This is the first consumer of that field: until now rarity was
# authored data with nothing reading it.

const TABLE_PATHS := {
	"starter_cache": "res://data/loot_tables/starter_cache.tres",
	"field_cache": "res://data/loot_tables/field_cache.tres",
	"reach_cache": "res://data/loot_tables/reach_cache.tres",
	"quickroot_cache": "res://data/loot_tables/quickroot_cache.tres",
	"heavy_cache": "res://data/loot_tables/heavy_cache.tres",
	"ribfen_cache": "res://data/loot_tables/ribfen_cache.tres",
	"elder_cache": "res://data/loot_tables/elder_cache.tres",
}

# Roll order must be stable for a seed to replay a sequence, so tables are
# iterated through this list rather than TABLE_PATHS.keys(). Same reason
# BoneQualityService keeps QUALITY_ORDER.
const TABLE_ORDER: Array[String] = [
	"starter_cache",
	"field_cache",
	"reach_cache",
	"quickroot_cache",
	"heavy_cache",
	"ribfen_cache",
	"elder_cache",
]

# Guard against an authoring mistake (all weights zero, duplicates disallowed
# with too few entries) spinning the re-draw loop forever.
const MAX_PICK_ATTEMPTS := 32

static var _tables: Dictionary = {}
static var _rng: RandomNumberGenerator = null


# --- table access ---------------------------------------------------------

static func table_ids() -> Array[String]:
	var ids: Array[String] = []
	for table_id in TABLE_ORDER:
		ids.append(str(table_id))
	return ids


static func has_table(table_id: String) -> bool:
	return table_for(table_id) != null


# Returns null for an unknown id. Callers decide whether that is fatal; a chest
# treats it as "this chest gives nothing" and says so, rather than crashing a
# level because one exported string has a typo.
static func table_for(table_id: String) -> LootTableDefinition:
	if _tables.has(table_id):
		return _tables[table_id] as LootTableDefinition
	if not TABLE_PATHS.has(table_id):
		return null

	var resource: Resource = load(str(TABLE_PATHS[table_id]))
	var table := resource as LootTableDefinition
	if table == null:
		push_warning("LootTableService: '%s' did not load as a LootTableDefinition." % table_id)
		return null

	var errors := table.validation_errors()
	if not errors.is_empty():
		# Loud but not fatal: a broken table still loads so the rest of the
		# level runs, and the message names the table and the exact problem.
		push_warning("LootTableService: table '%s' has %d problem(s): %s" % [table_id, errors.size(), ", ".join(errors)])

	_tables[table_id] = table
	return table


static func tables_for_difficulty(difficulty: int) -> Array[String]:
	var ids: Array[String] = []
	for table_id in TABLE_ORDER:
		var table := table_for(str(table_id))
		if table != null and table.matches_difficulty(difficulty):
			ids.append(str(table_id))
	return ids


static func display_name_for(table_id: String) -> String:
	var table := table_for(table_id)
	if table == null:
		return table_id
	return table.display_name


# Builds a one-item table in memory. This is how a container that only knows a
# single reward id (the pre-existing DemoEnemyCamp.reward_bone_id) reaches the
# same roll path as a real table, instead of keeping a second hand-rolled way to
# hand out a bone.
static func single_bone_table(bone_id: String, quality_bias: float = 0.0) -> LootTableDefinition:
	var table := LootTableDefinition.new()
	table.table_id = "inline_" + bone_id
	table.display_name = BoneRulesService.display_name_with_slot(bone_id)
	table.guaranteed_bone_ids = [bone_id]
	table.min_rolls = 0
	table.max_rolls = 0
	table.quality_bias = quality_bias
	return table


static func reset_cache() -> void:
	_tables.clear()


# --- rolling --------------------------------------------------------------

# Deterministic rolls for tests and for save/restore: the same seed replays the
# same sequence. Quality rolls run on BoneQualityService's own RNG, so seeding
# reproducible loot means seeding both (see seed_all).
static func set_seed(seed_value: int) -> void:
	_ensure_rng()
	_rng.seed = seed_value


static func randomize_seed() -> void:
	_ensure_rng()
	_rng.randomize()


static func seed_all(seed_value: int) -> void:
	set_seed(seed_value)
	BoneQualityService.set_seed(seed_value)


# Opaque RNG position, so a save can resume the sequence instead of restarting
# it and handing out the same loot again after every load.
static func rng_state() -> int:
	_ensure_rng()
	return int(_rng.state)


static func set_rng_state(state: int) -> void:
	_ensure_rng()
	_rng.state = state


# What one open of this table produces: an ordered list of
# {"bone_id": String, "quality_id": String}. Empty when the table is unknown or
# authored empty -- never null, so callers can loop without a guard.
static func roll_loot(table_id: String) -> Array[Dictionary]:
	return roll_loot_from(table_for(table_id))


static func roll_loot_from(table: LootTableDefinition) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if table == null:
		return results

	for bone_id in table.guaranteed_bone_ids:
		results.append(_describe_piece(str(bone_id), table))

	for bone_id in roll_bone_ids_from(table):
		results.append(_describe_piece(bone_id, table))

	return results


# The weighted picks only, without quality. Split out because it is the part
# worth checking on its own: a distribution test can run thousands of these
# without creating pieces.
static func roll_bone_ids(table_id: String) -> Array[String]:
	return roll_bone_ids_from(table_for(table_id))


static func roll_bone_ids_from(table: LootTableDefinition) -> Array[String]:
	var picked: Array[String] = []
	if table == null or table.entries.is_empty():
		return picked

	var span := table.roll_count_range()
	var count: int = span.x
	if span.y > span.x:
		_ensure_rng()
		count = _rng.randi_range(span.x, span.y)

	for i in range(count):
		var bone_id := _pick_weighted(table, picked)
		if bone_id == "":
			break
		picked.append(bone_id)

	return picked


# The weight this table gives one bone: its own rarity_drop_weight unless the
# table deliberately overrides it.
static func drop_weight_for(bone_id: String, table: LootTableDefinition = null) -> float:
	if table != null and table.has_weight_override(bone_id):
		return maxf(0.0, table.weight_override_for(bone_id))
	return maxf(0.0, BoneRulesService.rarity_drop_weight_for(bone_id))


# A piece's quality tilt is the table's intent plus the bone's own. This is the
# first consumer of quality_drop_percent, which until now was authored on every
# bone and read by nothing.
static func quality_bias_for(bone_id: String, table: LootTableDefinition = null) -> float:
	var bias: float = BoneRulesService.quality_drop_percent_for(bone_id)
	if table != null:
		bias += table.quality_bias
	return bias


static func roll_quality_for(bone_id: String, table: LootTableDefinition = null) -> String:
	return BoneQualityService.roll_quality_id_biased(quality_bias_for(bone_id, table))


# --- validation -----------------------------------------------------------

# table_id -> Array[String] of problems, for every authored table. Only tables
# with problems appear. Used by tools/headless_loot_table_check.gd; the rules
# themselves live in LootTableDefinition.validation_errors().
static func validation_report() -> Dictionary:
	var report: Dictionary = {}
	for table_id in TABLE_ORDER:
		var id := str(table_id)
		if not TABLE_PATHS.has(id):
			report[id] = ["Listed in TABLE_ORDER but missing from TABLE_PATHS."]
			continue
		var table := table_for(id)
		if table == null:
			report[id] = ["Failed to load from " + str(TABLE_PATHS[id]) + "."]
			continue
		var errors := table.validation_errors()
		if table.table_id != id:
			errors.append("table_id is '%s' but the file is registered as '%s'." % [table.table_id, id])
		if not errors.is_empty():
			report[id] = errors

	for table_id in TABLE_PATHS:
		if not TABLE_ORDER.has(str(table_id)):
			report[str(table_id)] = ["Present in TABLE_PATHS but missing from TABLE_ORDER, so it never rolls."]

	return report


# --- internals ------------------------------------------------------------

static func _ensure_rng() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()


static func _describe_piece(bone_id: String, table: LootTableDefinition) -> Dictionary:
	return {
		"bone_id": bone_id,
		"quality_id": roll_quality_for(bone_id, table),
	}


static func _pick_weighted(table: LootTableDefinition, already_picked: Array[String]) -> String:
	_ensure_rng()
	for attempt in range(MAX_PICK_ATTEMPTS):
		var bone_id := _weighted_draw(table)
		if bone_id == "":
			return ""
		if table.allow_duplicates or not already_picked.has(bone_id):
			return bone_id
	# Every draw collided with something already picked. Falling back to the
	# first unpicked entry keeps a slightly over-ambitious max_rolls from
	# silently shortening the reward.
	for raw_id in table.entries:
		var bone_id := str(raw_id)
		if not already_picked.has(bone_id) and drop_weight_for(bone_id, table) > 0.0:
			return bone_id
	return ""


static func _weighted_draw(table: LootTableDefinition) -> String:
	var total := 0.0
	for raw_id in table.entries:
		total += drop_weight_for(str(raw_id), table)
	if total <= 0.0:
		return ""

	var roll: float = _rng.randf() * total
	var cumulative := 0.0
	for raw_id in table.entries:
		var bone_id := str(raw_id)
		cumulative += drop_weight_for(bone_id, table)
		if roll < cumulative:
			return bone_id
	# Only reachable through float error at the very top of the range.
	return str(table.entries[table.entries.size() - 1])
