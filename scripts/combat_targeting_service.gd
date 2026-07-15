class_name CombatTargetingService

# Pure targeting rules for head-launch attacks (head-only and torso-only).
# No scene state: callers collect candidate positions themselves and map the
# returned index back to their own nodes.
#
# Why this exists: head-launch attacks used to aim down the player's MOVEMENT
# direction, so strafing around an enemy launched the head sideways into empty
# space. In torso-only mode a miss detaches the head from the torso, so bad aim
# while moving cost the player their head mid-fight.

# Enemies further than this are not auto-targeted. Keep it close to the actual
# lunge reach (torso_head_attack_lunge + the attack hitbox radius); acquiring a
# target further away than the head can travel would still whiff.
const DEFAULT_TARGET_RANGE: float = 1.9

# How much a target behind the player is penalised versus one straight ahead.
# 0.0 picks the plain nearest; 1.0 makes a target directly behind score as if it
# were twice as far. Enemies behind stay targetable, they just lose ties.
const DEFAULT_BEHIND_BIAS: float = 0.6


# Returns the index of the best candidate in `positions`, or -1 when none
# qualifies. `facing` may be ZERO, which falls back to plain nearest.
static func best_target_index(
	origin: Vector3,
	facing: Vector3,
	positions: Array,
	max_range: float = DEFAULT_TARGET_RANGE,
	behind_bias: float = DEFAULT_BEHIND_BIAS
) -> int:
	var best_index: int = -1
	var best_score: float = INF
	var flat_facing: Vector3 = Vector3(facing.x, 0.0, facing.z)
	var has_facing: bool = flat_facing.length() > 0.001
	if has_facing:
		flat_facing = flat_facing.normalized()

	for i in positions.size():
		var candidate: Variant = positions[i]
		if not (candidate is Vector3):
			continue
		var to_target: Vector3 = (candidate as Vector3) - origin
		to_target.y = 0.0
		var distance: float = to_target.length()
		if distance < 0.001 or distance > max_range:
			continue
		var score: float = distance
		if has_facing:
			# alignment: 1.0 straight ahead, -1.0 straight behind.
			var alignment: float = flat_facing.dot(to_target / distance)
			score *= 1.0 + behind_bias * (1.0 - alignment) * 0.5
		if score < best_score:
			best_score = score
			best_index = i
	return best_index


# Horizontal aim direction from origin to target. ZERO when they are stacked,
# so callers can keep their previous aim instead of snapping to a garbage value.
static func aim_direction(origin: Vector3, target_position: Vector3) -> Vector3:
	var to_target: Vector3 = target_position - origin
	to_target.y = 0.0
	if to_target.length() < 0.001:
		return Vector3.ZERO
	return to_target.normalized()
