class_name BackstabRulesService

# Pure geometry for stealth finish / backstab checks. Callers provide scene
# positions and facing vectors; the service keeps the cone rule out of Enemy.

const MIN_BACKSTAB_VECTOR_LENGTH: float = 0.01


static func is_attacker_behind_target(
	target_position: Vector3,
	target_forward: Vector3,
	attacker_position: Vector3,
	behind_dot: float
) -> bool:
	var to_attacker: Vector3 = attacker_position - target_position
	to_attacker.y = 0.0
	if to_attacker.length() <= MIN_BACKSTAB_VECTOR_LENGTH:
		return false

	var flat_forward: Vector3 = target_forward
	flat_forward.y = 0.0
	if flat_forward.length() <= MIN_BACKSTAB_VECTOR_LENGTH:
		return false

	return flat_forward.normalized().dot(to_attacker.normalized()) <= -behind_dot
