class_name BoneInstanceService

# Per-piece identity for bones. A bone_id ("arm_bone") names a TYPE; an
# instance_id ("bone#7") names one individual piece and is the source of truth
# for that piece's quality.
#
# Quality is rolled exactly once, when a piece is created (a drop, a reward, a
# newly granted piece). Picking it up, equipping it, opening the inventory,
# applying a build or refreshing the preview all resolve the SAME instance and
# never re-roll.
#
# Deliberate design constraints:
#   * The instance_id carries no meaning. It is "bone#N", never
#     "arm_bone_strong" -- identity, definition and quality stay separate.
#   * The multiplier is not copied onto the instance. Only quality_id is
#     stored; the number comes from BoneQualityService's table, so retuning
#     the table retunes every existing piece.
#   * Legacy plain bone_id Strings keep working through an explicit
#     compatibility path (see resolve). They are never rolled: a String that
#     is not an instance keeps its authored quality, or Normal when it has
#     none. Existing Strings do not silently change meaning.
#
# This service owns instance state only. Quality RULES live in
# BoneQualityService; bone DEFINITIONS live in BoneDatabase / BoneDefinition.

const INSTANCE_PREFIX := "bone#"

# instance_id -> {"bone_id": String, "quality_id": String}
static var _instances: Dictionary = {}
static var _next_index: int = 1


static func is_instance_id(value: String) -> bool:
	return value.begins_with(INSTANCE_PREFIX)


static func has_instance(instance_id: String) -> bool:
	return _instances.has(instance_id)


# Creates a brand new piece and rolls its quality ONCE. Pass quality_id only
# when the caller already knows it (splitting a stack, restoring saved data);
# leaving it empty is the normal "a new piece just came into existence" path.
static func create_instance(bone_id: String, quality_id: String = "") -> String:
	var resolved_quality := quality_id
	if resolved_quality == "":
		resolved_quality = BoneQualityService.roll_quality_id()
	else:
		resolved_quality = BoneQualityService.normalize_quality_id(resolved_quality)

	var instance_id := INSTANCE_PREFIX + str(_next_index)
	_next_index += 1
	_instances[instance_id] = {
		"bone_id": _bone_id_of_raw(bone_id),
		"quality_id": resolved_quality,
		"favorite": false,
		"locked": false,
	}
	return instance_id


# Full metadata for anything a caller might hold: an instance_id, or a legacy
# bone_id String. Always returns bone_id and quality_id; instance_id is "" for
# the legacy path, which is how callers can tell the two apart.
static func resolve(value: String) -> Dictionary:
	if is_instance_id(value) and _instances.has(value):
		var record: Dictionary = _instances[value]
		return {
			"instance_id": value,
			"bone_id": str(record["bone_id"]),
			"quality_id": str(record["quality_id"]),
		}
	# Explicit legacy compatibility path. An instance_id we no longer know
	# about also lands here rather than inventing a piece.
	return {
		"instance_id": "",
		"bone_id": _bone_id_of_raw(value),
		"quality_id": _legacy_quality_id_for(value),
	}


# The choke point every bone_id-keyed API funnels through: hands back the type
# id for an instance, and passes a legacy String through untouched.
static func bone_id_of(value: String) -> String:
	if is_instance_id(value) and _instances.has(value):
		return str((_instances[value] as Dictionary)["bone_id"])
	return _bone_id_of_raw(value)


static func quality_id_of(value: String) -> String:
	if is_instance_id(value) and _instances.has(value):
		return str((_instances[value] as Dictionary)["quality_id"])
	return _legacy_quality_id_for(value)


# An unknown instance_id must not resolve to a real bone type.
static func _bone_id_of_raw(value: String) -> String:
	return "" if is_instance_id(value) else value


# Legacy pieces keep the quality their DEFINITION was authored with -- several
# handcrafted bones ship as non-default (dummy_bone, heavy_bone, rib_bone), so
# defaulting all of them to Normal would silently rebalance existing content.
# A definition with no quality at all becomes Normal. Never rolled.
static func _legacy_quality_id_for(value: String) -> String:
	var bone_id := _bone_id_of_raw(value)
	if bone_id == "":
		return BoneQualityService.QUALITY_NORMAL

	var generated: Dictionary = EquipmentRulesService.generated_limb_definition_for(bone_id)
	if not generated.is_empty():
		return BoneQualityService.normalize_quality_id(str(generated.get("quality", "")))

	return BoneQualityService.normalize_quality_id(BoneDatabase.quality(bone_id))


# --- per-piece marks ------------------------------------------------------
# Favourite is a handling preference (sorts first, shows a star); locked is a
# protection contract: any future drop/destroy path must refuse a locked
# piece (see PlayerInventoryComponent.can_remove_bone). Both live on the
# instance and persist with the registry. Legacy plain bone_id Strings have
# no instance to mark, so they always read false and toggles are no-ops.

static func is_favorite(value: String) -> bool:
	if is_instance_id(value) and _instances.has(value):
		return bool((_instances[value] as Dictionary).get("favorite", false))
	return false


static func is_locked(value: String) -> bool:
	if is_instance_id(value) and _instances.has(value):
		return bool((_instances[value] as Dictionary).get("locked", false))
	return false


static func toggle_favorite(value: String) -> bool:
	if is_instance_id(value) and _instances.has(value):
		var record: Dictionary = _instances[value]
		record["favorite"] = not bool(record.get("favorite", false))
		return bool(record["favorite"])
	return false


static func toggle_locked(value: String) -> bool:
	if is_instance_id(value) and _instances.has(value):
		var record: Dictionary = _instances[value]
		record["locked"] = not bool(record.get("locked", false))
		return bool(record["locked"])
	return false


# Key used to decide whether two carried pieces stack together. Pieces only
# stack when they are the same type AND the same quality AND the same mutation
# -- otherwise a stack would hide the fact that its members have different
# effective stats, and splitting one off could hand back the wrong piece.
static func stack_key_for(value: String) -> String:
	var data := resolve(value)
	var bone_id := str(data["bone_id"])
	# Every field that changes how the piece behaves has to be in the key.
	# Two pieces that stack must be interchangeable: if a Normal and a Strong
	# arm shared a tile, the stack would hide that they roll different
	# effective stats and pulling one out could hand back either.
	# Favourite/locked separate stacks too: pulling a piece out of a stack
	# must never silently hand back (or hide) a marked one.
	return "%s|%s|%s|%d|%d|%d" % [
		bone_id,
		str(data["quality_id"]),
		BoneRulesService.mutation_id_for(bone_id),
		1 if is_favorite(value) else 0,
		1 if is_locked(value) else 0,
		# Durability/condition. Per-instance wear does not exist yet (the
		# durability fields are authored per type), so this currently varies
		# only by type -- but keying on it now means adding per-instance wear
		# later cannot silently merge a pristine-condition piece with a
		# cracked one.
		BoneRulesService.durability_start_for(bone_id),
	]


# --- serialisation -------------------------------------------------------
# Enough to restore identity and quality. The multiplier is intentionally not
# serialised: it is derived from quality_id through BoneQualityService.

static func serialize() -> Dictionary:
	return {
		"next_index": _next_index,
		"instances": _instances.duplicate(true),
	}


static func restore(data: Dictionary) -> void:
	_instances.clear()
	var raw: Dictionary = data.get("instances", {})
	for instance_id in raw:
		var record: Dictionary = raw[instance_id]
		_instances[str(instance_id)] = {
			"bone_id": str(record.get("bone_id", "")),
			# Restored, never re-rolled.
			"quality_id": BoneQualityService.normalize_quality_id(str(record.get("quality_id", ""))),
			"favorite": bool(record.get("favorite", false)),
			"locked": bool(record.get("locked", false)),
		}
	_next_index = maxi(1, int(data.get("next_index", _instances.size() + 1)))


# Test hook: wipe the registry so a seeded run starts from a known state.
static func reset(seed_value: int = -1) -> void:
	_instances.clear()
	_next_index = 1
	if seed_value >= 0:
		BoneQualityService.set_seed(seed_value)


static func instance_count() -> int:
	return _instances.size()
