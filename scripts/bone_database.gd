class_name BoneDatabase

# -----------------------------------------------------------------------------
# Tier 1E: the single source of truth for every bone type.
#
# Player, pickup, enemy, and trial gate all read display names, colors, slots,
# and stat effects from HERE instead of each keeping their own copy.
#
# To add a new bone type:
#   1. Add one entry to BONES below.
#   2. Set some enemy's `dropped_bone_id` to its key (in the editor or scene).
# No other script needs to change. That is the whole point of this file.
# -----------------------------------------------------------------------------

# Color used for any bone id that is not listed below (kept neutral/cream).
const UNKNOWN_COLOR := Color(1.0, 0.94, 0.68, 1.0)

# Each bone definition carries everything the rest of the game needs to know.
# slot is planned ahead: only "right_arm" is fully wired up in Tier 1E, but the
# data is already here for legs / body so later tiers can support real slots.
static var BONES := {
	"arm_bone": {
		"display_name": "Arm Bone",
		"quality": "Normal",
		"color": Color(1.0, 0.85, 0.18, 1.0),
		"slot": "right_arm",
		"move_speed_bonus": 0.0,
		"attack_range_bonus": 2.5,
		"attack_damage_bonus": 0,
		"max_health_bonus": 0,
		"enemy_move_speed_bonus": 0.0,
		"enemy_attack_range_bonus": 1.0,
		"enemy_contact_damage_bonus": 0,
		"enemy_max_health_bonus": 0,
		"enemy_detection_range_bonus": 1.0,
		"enemy_visual_scale": 1.05,
		"enemy_flee_chance": 0.35,
		"tags": ["reach"],
		"description": "Longer reach on your swing.",
	},
	"leg_bone": {
		"display_name": "Leg Bone",
		"quality": "Normal",
		"color": Color(0.25, 0.95, 0.55, 1.0),
		"slot": "legs",
		"move_speed_bonus": 3.0,
		"attack_range_bonus": 0.0,
		"attack_damage_bonus": 0,
		"max_health_bonus": 0,
		"enemy_move_speed_bonus": 1.4,
		"enemy_attack_range_bonus": 0.0,
		"enemy_contact_damage_bonus": 0,
		"enemy_max_health_bonus": 0,
		"enemy_detection_range_bonus": 2.0,
		"enemy_visual_scale": 0.95,
		"enemy_flee_chance": 1.0,
		"tags": ["speed"],
		"description": "Faster movement.",
	},
	"heavy_bone": {
		"display_name": "Heavy Bone",
		"quality": "Strong",
		"color": Color(0.65, 0.35, 1.0, 1.0),
		"slot": "body",
		"weight": 2.0,
		"visual_scale": Vector3(1.3, 1.3, 1.3),
		"move_speed_bonus": -1.5,
		"attack_range_bonus": 0.0,
		"attack_damage_bonus": 2,
		"max_health_bonus": 2,
		"enemy_move_speed_bonus": -0.5,
		"enemy_attack_range_bonus": 0.2,
		"enemy_contact_damage_bonus": 1,
		"enemy_max_health_bonus": 2,
		"enemy_detection_range_bonus": 0.0,
		"enemy_visual_scale": 1.22,
		"enemy_flee_chance": 0.15,
		"tags": ["power"],
		"description": "More health and harder hits, but slows you down.",
	},
	"dummy_bone": {
		"display_name": "Training Bone",
		"quality": "Cracked",
		"color": Color(1.0, 0.94, 0.68, 1.0),
		"slot": "right_arm",
		"move_speed_bonus": 0.0,
		"attack_range_bonus": 0.0,
		"attack_damage_bonus": 0,
		"max_health_bonus": 0,
		"enemy_move_speed_bonus": 0.0,
		"enemy_attack_range_bonus": 0.0,
		"enemy_contact_damage_bonus": 0,
		"enemy_max_health_bonus": 0,
		"enemy_detection_range_bonus": 0.0,
		"enemy_visual_scale": 1.0,
		"enemy_flee_chance": 0.45,
		"tags": [],
		"description": "A plain practice bone with no special effect.",
	},
	# Tier 1F bonus: an optional hybrid bone dropped by the off-route enemy. Adding
	# it took exactly one entry here — that is the Tier 1E payoff in action.
	"rib_bone": {
		"display_name": "Rib Bone",
		"quality": "Strong",
		"color": Color(0.35, 0.85, 0.95, 1.0),
		"slot": "body",
		"move_speed_bonus": 1.5,
		"attack_range_bonus": 1.0,
		"attack_damage_bonus": 0,
		"max_health_bonus": 1,
		"enemy_move_speed_bonus": 0.7,
		"enemy_attack_range_bonus": 0.4,
		"enemy_contact_damage_bonus": 0,
		"enemy_max_health_bonus": 1,
		"enemy_detection_range_bonus": 1.0,
		"enemy_visual_scale": 1.08,
		"enemy_flee_chance": 0.55,
		"tags": ["hybrid", "bonus"],
		"description": "A bit of everything: some extra reach and speed.",
	},
}


# True if the given id is a defined bone type.
static func has_bone(id: String) -> bool:
	return BONES.has(id)


# Every defined bone id, e.g. for iterating in tools or tests.
static func all_ids() -> Array:
	return BONES.keys()


# The full definition dictionary for an id, or an empty one if unknown.
static func get_def(id: String) -> Dictionary:
	if BONES.has(id):
		return BONES[id]
	return {}


static func display_name(id: String) -> String:
	if BONES.has(id):
		return BONES[id]["display_name"]
	return "Unknown Bone"


# The bone's color. Callers that want a different miss color (e.g. an enemy's
# natural red) can pass their own fallback for ids that are not defined.
static func color(id: String, fallback: Color = UNKNOWN_COLOR) -> Color:
	if BONES.has(id):
		return BONES[id]["color"]
	return fallback


static func slot(id: String) -> String:
	if BONES.has(id):
		return BONES[id]["slot"]
	return ""


static func move_speed_bonus(id: String) -> float:
	if BONES.has(id):
		return BONES[id]["move_speed_bonus"]
	return 0.0


static func attack_range_bonus(id: String) -> float:
	if BONES.has(id):
		return BONES[id]["attack_range_bonus"]
	return 0.0


static func attack_damage_bonus(id: String) -> int:
	if BONES.has(id):
		return BONES[id]["attack_damage_bonus"]
	return 0


static func max_health_bonus(id: String) -> int:
	if BONES.has(id):
		return int(BONES[id].get("max_health_bonus", 0))
	return 0


static func quality(id: String) -> String:
	if BONES.has(id):
		return BONES[id].get("quality", "Normal")
	return "Unknown"


static func enemy_float_bonus(id: String, key: String, fallback: float = 0.0) -> float:
	if BONES.has(id):
		return float(BONES[id].get(key, fallback))
	return fallback


static func enemy_int_bonus(id: String, key: String, fallback: int = 0) -> int:
	if BONES.has(id):
		return int(BONES[id].get(key, fallback))
	return fallback


static func description(id: String) -> String:
	if BONES.has(id):
		return BONES[id]["description"]
	return ""


# Builds the "- +X move speed" style lines the inventory UI shows for a bone.
static func effect_text(id: String) -> String:
	var text := ""
	var move_bonus := move_speed_bonus(id)
	var range_bonus := attack_range_bonus(id)
	var damage_bonus := attack_damage_bonus(id)
	var health_bonus := max_health_bonus(id)

	if move_bonus != 0.0:
		text += "- " + _format_signed_float(move_bonus) + " move speed\n"
	if range_bonus != 0.0:
		text += "- " + _format_signed_float(range_bonus) + " attack range\n"
	if damage_bonus != 0:
		text += "- " + _format_signed_int(damage_bonus) + " attack damage\n"
	if health_bonus != 0:
		text += "- " + _format_signed_int(health_bonus) + " max health\n"

	if text == "":
		text = "- No effect\n"

	return text


static func _format_signed_float(value: float) -> String:
	if value > 0.0:
		return "+" + str(value)
	return str(value)


static func _format_signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)
