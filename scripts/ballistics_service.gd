class_name BallisticsService

# Pure launch-solving for thrown/spat projectiles. No scene state: callers pass
# world positions and tuning, and get a launch velocity back.
#
# Why this exists: the same solve was copy-pasted into three call sites — the
# lizard saliva (enemy.gd), the enemy ranged arrow (enemy.gd) and the gorilla
# rock (enemy.gd). The copies drifted. The rock's grew a `+ upward_boost` term
# that added vertical speed ON TOP of the solution, which left it about 2.3 m
# high at the 10 m throw range — the gorilla threw over the player's head every
# time — while the other two stayed correct. One rule, one place.


# Time the projectile spends covering the horizontal leg.
# `arc` lofts the shot by lengthening the FLIGHT (0.15 = 15% longer, so it hangs
# higher and lands slower). Loft must never be added as extra vertical speed:
# the solve below derives from this time, so anything added on top misses by
# exactly (added_speed * travel_time).
static func travel_time_for(horizontal_distance: float, horizontal_speed: float, arc: float = 0.0) -> float:
	var arc_scale: float = 1.0 + maxf(arc, 0.0)
	return maxf((horizontal_distance / maxf(horizontal_speed, 0.1)) * arc_scale, 0.1)


# Launch velocity that lands a projectile exactly on `to`.
#
# `physics_step` compensates for the discrete integrator. Projectiles here run
#     velocity.y -= gravity * dt
#     position   += velocity * dt
# in that order (semi-implicit Euler), which loses 0.5 * gravity * T * dt of
# height compared with the closed-form parabola. Pass physics_step() to land on
# target; pass 0.0 for the continuous-time solution. The error scales with
# gravity: ~1 cm for the saliva (gravity 1.5) but ~22 cm for the rock (gravity 32).
static func solve_launch_velocity(
	from: Vector3,
	to: Vector3,
	horizontal_speed: float,
	gravity: float,
	arc: float = 0.0,
	physics_step_seconds: float = 0.0
) -> Vector3:
	var to_target: Vector3 = to - from
	var horizontal: Vector3 = Vector3(to_target.x, 0.0, to_target.z)
	var distance: float = horizontal.length()
	if distance < 0.001:
		return Vector3.ZERO

	var travel_time: float = travel_time_for(distance, horizontal_speed, arc)
	var launch: Vector3 = horizontal.normalized() * (distance / travel_time)
	launch.y = (to_target.y / travel_time) + (gravity * 0.5 * (travel_time + maxf(physics_step_seconds, 0.0)))
	return launch


# Launch velocity for a projectile whose SPEED is fixed and whose ANGLE is the
# free variable — a bow, where draw strength sets speed and aim sets elevation.
#
# Use this instead of solve_launch_velocity() whenever the speed carries meaning.
# The player's bow scales speed with charge (0.9x..1.15x), so solving for vertical
# speed the way the enemies do would quietly hand a half-drawn shot the energy of
# a full draw to reach a distant target.
#
# Returns ZERO when the target is out of ballistic reach at this speed. That is a
# real answer, not a failure: it tells the caller to fire straight rather than
# invent energy. It is also what keeps an aim at open sky (which raycasts out to
# ray_end ~90 m) from turning into an absurd lob.
static func solve_launch_velocity_fixed_speed(
	from: Vector3,
	to: Vector3,
	speed: float,
	gravity: float,
	physics_step_seconds: float = 0.0
) -> Vector3:
	var to_target: Vector3 = to - from
	var horizontal: Vector3 = Vector3(to_target.x, 0.0, to_target.z)
	var distance: float = horizontal.length()
	if distance < 0.001 or speed <= 0.001:
		return Vector3.ZERO
	if gravity <= 0.0:
		return to_target.normalized() * speed

	var height: float = to_target.y
	var angle: float = _flat_launch_angle(distance, height, speed, gravity)
	if is_nan(angle):
		return Vector3.ZERO

	# One refinement pass. The projectile integrates with semi-implicit Euler,
	# which drops 0.5*g*T*step more than the parabola this angle assumes. Folding
	# that loss into an effective gravity and re-solving converges immediately,
	# because the flight time barely moves between the two passes.
	if physics_step_seconds > 0.0:
		var flight: float = distance / maxf(speed * cos(angle), 0.001)
		var effective_gravity: float = gravity * (1.0 + physics_step_seconds / maxf(flight, 0.001))
		var refined: float = _flat_launch_angle(distance, height, speed, effective_gravity)
		if not is_nan(refined):
			angle = refined

	return (horizontal / distance) * (speed * cos(angle)) + Vector3.UP * (speed * sin(angle))


# The flatter of the two launch angles that reach (distance, height) at `speed`,
# or NAN when the target is beyond reach. Both roots hit; the flat one is the
# direct shot a bow should look like, the steep one is a mortar lob.
static func _flat_launch_angle(distance: float, height: float, speed: float, gravity: float) -> float:
	var speed_sq: float = speed * speed
	var discriminant: float = speed_sq * speed_sq - gravity * (gravity * distance * distance + 2.0 * height * speed_sq)
	if discriminant < 0.0:
		return NAN
	return atan((speed_sq - sqrt(discriminant)) / (gravity * distance))


# The fixed step the projectiles' _physics_process actually integrates at.
static func physics_step() -> float:
	return 1.0 / maxf(float(Engine.physics_ticks_per_second), 1.0)
