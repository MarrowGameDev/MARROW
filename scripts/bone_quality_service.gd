class_name BoneQualityService

# Single source of truth for bone QUALITY: the canonical ids, their stat
# multiplier, their roll probability and their display name.
#
# Quality is the condition/potency of one individual piece. It is deliberately
# NOT rarity, NOT mutation and NOT durability -- those are separate fields with
# separate vocabularies (see docs/bone_data_structure.md). Nothing in here may
# touch slot, compatibility, ids, tags or any other categorical value: quality
# only ever scales the numeric stats a bone already has.
#
# The rolled quality of a piece lives on its instance (BoneInstanceService).
# This service holds the rules; it stores no per-piece state.

const QUALITY_FRAIL := "frail"
const QUALITY_WORN := "worn"
const QUALITY_NORMAL := "normal"
const QUALITY_STRONG := "strong"
const QUALITY_PRISTINE := "pristine"

# rank orders the ladder (0 = worst). probability is a percentage and the
# column must total exactly 100.0 -- assert_probabilities_total() enforces it
# and tools/validate_bone_quality.py checks it without running the engine.
const QUALITY_TABLE := {
	QUALITY_FRAIL: {
		"multiplier": 0.85,
		"probability": 2.5,
		"rank": 0,
		"display_name": "Frail",
		"color": Color(0.62, 0.42, 0.40, 1.0),
	},
	QUALITY_WORN: {
		"multiplier": 0.925,
		"probability": 12.5,
		"rank": 1,
		"display_name": "Worn",
		"color": Color(0.72, 0.66, 0.52, 1.0),
	},
	QUALITY_NORMAL: {
		"multiplier": 1.0,
		"probability": 70.0,
		"rank": 2,
		"display_name": "Normal",
		"color": Color(1.0, 0.94, 0.68, 1.0),
	},
	QUALITY_STRONG: {
		"multiplier": 1.075,
		"probability": 12.5,
		"rank": 3,
		"display_name": "Strong",
		"color": Color(0.55, 0.78, 0.52, 1.0),
	},
	QUALITY_PRISTINE: {
		"multiplier": 1.15,
		"probability": 2.5,
		"rank": 4,
		"display_name": "Pristine",
		"color": Color(0.45, 0.80, 0.86, 1.0),
	},
}

# The ladder in rank order. Roll order must be stable for a seed to reproduce
# a sequence, so this is an explicit list rather than QUALITY_TABLE.keys().
const QUALITY_ORDER: Array = [
	QUALITY_FRAIL,
	QUALITY_WORN,
	QUALITY_NORMAL,
	QUALITY_STRONG,
	QUALITY_PRISTINE,
]

# Pre-rename ids, kept so authored .tres files and any saved data written
# before the rename keep resolving to the same rung of the ladder. Mapping is
# by RANK, which is what drives stats -- "chatarra" was the bottom rung and
# stays the bottom rung.
const LEGACY_QUALITY_ALIASES := {
	"chatarra": QUALITY_FRAIL,
	"fragil": QUALITY_WORN,
	"comun": QUALITY_NORMAL,
	"fuerte": QUALITY_STRONG,
	"legendario": QUALITY_PRISTINE,
}

static var _rng: RandomNumberGenerator = null


# Deterministic rolls for tests: the same seed replays the same sequence.
static func set_seed(seed_value: int) -> void:
	_ensure_rng()
	_rng.seed = seed_value


static func randomize_seed() -> void:
	_ensure_rng()
	_rng.randomize()


static func _ensure_rng() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()


# Weighted pick over QUALITY_TABLE's probability column.
static func roll_quality_id() -> String:
	_ensure_rng()
	var roll: float = _rng.randf() * total_probability()
	var cumulative := 0.0
	for quality_id in QUALITY_ORDER:
		cumulative += float(QUALITY_TABLE[quality_id]["probability"])
		if roll < cumulative:
			return str(quality_id)
	# Only reachable through float error at the very top of the range.
	return QUALITY_NORMAL


static func total_probability() -> float:
	var total := 0.0
	for quality_id in QUALITY_ORDER:
		total += float(QUALITY_TABLE[quality_id]["probability"])
	return total


static func is_quality_id(value: String) -> bool:
	return QUALITY_TABLE.has(value)


# Accepts a canonical id, a pre-rename Spanish id, or junk. Anything that is
# not recognised -- including "" -- resolves to Normal. This is the ONLY place
# an unknown quality is decided, and it never rolls: legacy data keeps a
# deterministic identity instead of being randomised on load.
static func normalize_quality_id(raw_quality: String) -> String:
	if QUALITY_TABLE.has(raw_quality):
		return raw_quality
	if LEGACY_QUALITY_ALIASES.has(raw_quality):
		return str(LEGACY_QUALITY_ALIASES[raw_quality])
	return QUALITY_NORMAL


static func multiplier_for(quality_id: String) -> float:
	return float(QUALITY_TABLE[normalize_quality_id(quality_id)]["multiplier"])


static func rank_for(quality_id: String) -> int:
	return int(QUALITY_TABLE[normalize_quality_id(quality_id)]["rank"])


static func display_name_for(quality_id: String) -> String:
	return str(QUALITY_TABLE[normalize_quality_id(quality_id)]["display_name"])


static func color_for(quality_id: String) -> Color:
	return QUALITY_TABLE[normalize_quality_id(quality_id)]["color"]


static func probability_for(quality_id: String) -> float:
	return float(QUALITY_TABLE[normalize_quality_id(quality_id)]["probability"])
