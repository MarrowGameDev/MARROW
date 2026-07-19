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

# Visual profile per quality, applied on top of whatever the base material
# already is. Normal is deliberately all-neutral (x1 colour, no offsets, no
# emission) so a Normal piece -- and any legacy piece, which resolves to Normal
# -- renders byte-for-byte as it did before quality visuals existed.
#
# These are OFFSETS and MULTIPLIERS, never absolute values: the base material
# keeps owning the look, quality only nudges it. That is what keeps quality
# separable from rarity, mutation, corruption, durability and hit feedback,
# which layer on afterwards (see apply_to_material).
const QUALITY_VISUALS := {
	QUALITY_FRAIL: {
		# Grey, desaturated and dry. No emission: it must read as brittle,
		# never as broken or as glowing.
		"color_multiplier": Color(0.82, 0.80, 0.78, 1.0),
		"saturation": 0.45,
		"roughness_offset": 0.12,
		"specular_offset": -0.06,
		"emission_color": Color(0, 0, 0, 1),
		"emission_energy": 0.0,
	},
	QUALITY_WORN: {
		# Beige/ochre with a touch more roughness than Normal.
		"color_multiplier": Color(0.94, 0.87, 0.72, 1.0),
		"saturation": 0.85,
		"roughness_offset": 0.06,
		"specular_offset": -0.02,
		"emission_color": Color(0, 0, 0, 1),
		"emission_energy": 0.0,
	},
	QUALITY_NORMAL: {
		"color_multiplier": Color(1, 1, 1, 1),
		"saturation": 1.0,
		"roughness_offset": 0.0,
		"specular_offset": 0.0,
		"emission_color": Color(0, 0, 0, 1),
		"emission_energy": 0.0,
	},
	QUALITY_STRONG: {
		# Cool blue-grey, tighter highlight. Solid, not enchanted: no emission.
		"color_multiplier": Color(0.88, 0.95, 1.0, 1.0),
		# Left at 1.0 deliberately: the bone palette is warm, so boosting
		# saturation amplifies the existing yellow and cancels out the cool
		# shift. The contrast for this tier comes from roughness/specular.
		"saturation": 1.0,
		"roughness_offset": -0.10,
		"specular_offset": 0.10,
		"emission_color": Color(0, 0, 0, 1),
		"emission_energy": 0.0,
	},
	QUALITY_PRISTINE: {
		# Clean ivory with a restrained gold accent. The only tier with
		# emission, and kept very low so it reads as well-kept rather than
		# magical.
		"color_multiplier": Color(1.03, 1.0, 0.94, 1.0),
		"saturation": 1.05,
		"roughness_offset": -0.16,
		"specular_offset": 0.16,
		"emission_color": Color(1.0, 0.86, 0.55, 1.0),
		"emission_energy": 0.07,
	},
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


static func visual_profile_for(quality_id: String) -> Dictionary:
	return QUALITY_VISUALS[normalize_quality_id(quality_id)]


# Tints a material the CALLER owns. Never pass a shared/imported material in:
# every call site duplicates or news up its own (see bone.gd _prepare_materials
# and ModularSkeletonRig's material_override), so one piece changing quality
# can never touch another piece that happens to share a base material.
#
# Composition order: this is step 2. The base material (step 1) must already be
# applied; mutation/corruption (3), durability (4) and temporary hit feedback
# (5) layer on afterwards and must not be folded in here -- keeping them in
# separate passes is what lets a player tell them apart.
#
# Call this only when the instance, its quality, or the visual context changes.
# It allocates nothing, but it is not free, and nothing here belongs in
# _process.
static func apply_to_material(material: StandardMaterial3D, quality_id: String) -> void:
	if material == null:
		return
	var profile: Dictionary = visual_profile_for(quality_id)

	var tint: Color = profile["color_multiplier"]
	var base_color: Color = material.albedo_color
	var tinted := Color(
		base_color.r * tint.r,
		base_color.g * tint.g,
		base_color.b * tint.b,
		base_color.a
	)
	# Saturation is pulled toward/away from the colour's own luminance, so a
	# desaturated tier greys out without shifting hue.
	var saturation := float(profile["saturation"])
	if absf(saturation - 1.0) > 0.001:
		var luminance: float = tinted.r * 0.2126 + tinted.g * 0.7152 + tinted.b * 0.0722
		tinted = Color(
			lerpf(luminance, tinted.r, saturation),
			lerpf(luminance, tinted.g, saturation),
			lerpf(luminance, tinted.b, saturation),
			tinted.a
		)
	material.albedo_color = Color(
		clampf(tinted.r, 0.0, 1.0),
		clampf(tinted.g, 0.0, 1.0),
		clampf(tinted.b, 0.0, 1.0),
		clampf(tinted.a, 0.0, 1.0)
	)

	material.roughness = clampf(material.roughness + float(profile["roughness_offset"]), 0.0, 1.0)
	material.metallic_specular = clampf(material.metallic_specular + float(profile["specular_offset"]), 0.0, 1.0)

	var emission_energy := float(profile["emission_energy"])
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = profile["emission_color"]
		material.emission_energy_multiplier = emission_energy
	# No else: a tier with no emission of its own must not switch off emission
	# the base material or another system (a pickup's glow) deliberately set.


# Convenience for the common case: resolve the instance's quality and tint.
static func apply_instance_to_material(material: StandardMaterial3D, instance_or_bone_id: String) -> void:
	apply_to_material(material, BoneInstanceService.quality_id_of(instance_or_bone_id))
