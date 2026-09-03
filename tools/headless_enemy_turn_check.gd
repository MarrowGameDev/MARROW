extends SceneTree

# Pins two enemy fixes that were only visible at runtime:
#
#   1. Turning is rate-limited. A 180 degree change of intent must take about
#      turn_speed_degrees to complete, not one frame. The old code wrote
#      rotation.y outright, so an enemy could face backwards instantly.
#   2. Reading a freed limb body must not error. detached_limb_bodies keeps a
#      key after its body is freed, and `freed as Node3D` is itself an error
#      ("Trying to cast a freed object") -- so validity has to be tested before
#      any cast. The recovery AI hit this every frame.
#
#   godot --headless --path . --script tools/headless_enemy_turn_check.gd
#
# Dynamic loading throughout, for the reason documented in
# tools/headless_chest_check.gd.

var _world: Node3D = null
var _enemy_scene: PackedScene = null


func _initialize() -> void:
	_enemy_scene = load("res://scenes/enemy.tscn") as PackedScene
	if _enemy_scene == null:
		print("ENEMY TURN CHECK: FAIL\n  - scenes/enemy.tscn did not load")
		quit(1)
		return

	_world = Node3D.new()
	root.add_child(_world)
	await process_frame

	var failures: Array[String] = []
	failures.append_array(await _check_turn_is_rate_limited())
	failures.append_array(await _check_turn_takes_the_short_way())
	failures.append_array(await _check_profiles_turn_differently())
	failures.append_array(await _check_freed_limb_body_is_survivable())

	print("")
	if failures.is_empty():
		print("ENEMY TURN CHECK: PASS")
	else:
		print("ENEMY TURN CHECK: FAIL")
		for failure in failures:
			print("  - ", failure)

	_world.free()
	quit(0 if failures.is_empty() else 1)


func _check_turn_is_rate_limited() -> Array[String]:
	var failures: Array[String] = []
	var enemy = await _make_enemy()
	enemy.turn_speed_degrees = 240.0

	enemy.rotation.y = 0.0
	var step: float = enemy.get_physics_process_delta_time()
	var expected_step: float = deg_to_rad(240.0) * step

	# One call must move at most one step, however far away the target is.
	enemy._turn_toward(Vector3(0, 0, -1))  # a full 180 away from +Z
	var moved: float = absf(wrapf(enemy.rotation.y, -PI, PI))
	if moved > expected_step + 0.0001:
		failures.append("a single turn moved %.4f rad, more than the %.4f rad cap" % [moved, expected_step])
	if is_zero_approx(moved):
		failures.append("the enemy did not turn at all")

	# facing_direction must follow the ACTUAL rotation, not the target: an
	# enemy still turning has not seen you yet.
	var facing_yaw: float = atan2(enemy.facing_direction.x, enemy.facing_direction.z)
	if absf(wrapf(facing_yaw - enemy.rotation.y, -PI, PI)) > 0.001:
		failures.append("facing_direction ran ahead of the body (%.4f vs %.4f)" % [facing_yaw, enemy.rotation.y])

	# Repeated calls converge, and take roughly the time the rate implies.
	var steps := 0
	while absf(wrapf(PI - enemy.rotation.y, -PI, PI)) > 0.01 and steps < 10000:
		enemy._turn_toward(Vector3(0, 0, -1))
		steps += 1
	var seconds: float = float(steps) * step
	var expected_seconds: float = 180.0 / 240.0
	print("180 degree turn took %d steps (%.3fs simulated, expected ~%.3fs)" % [steps, seconds, expected_seconds])
	if absf(seconds - expected_seconds) > expected_seconds * 0.15:
		failures.append("a 180 turn took %.3fs, expected about %.3fs" % [seconds, expected_seconds])

	# Zero means "no limit", so an instant facing is still reachable on purpose.
	enemy.turn_speed_degrees = 0.0
	enemy.rotation.y = 0.0
	enemy._turn_toward(Vector3(0, 0, -1))
	if absf(absf(wrapf(enemy.rotation.y, -PI, PI)) - PI) > 0.001:
		failures.append("turn_speed_degrees = 0 did not restore an instant turn")

	_teardown([enemy])
	return failures


# Agility is part of what tells the variants apart: a Gorilla you can flank, a
# Lizard you cannot, a legless one that drags itself round.
func _check_profiles_turn_differently() -> Array[String]:
	var failures: Array[String] = []
	var enemy = await _make_enemy()

	var plain: float = enemy._get_effective_turn_speed_degrees()

	enemy.gorilla_profile_active = true
	var gorilla: float = enemy._get_effective_turn_speed_degrees()

	# Lizard wins when both are somehow set, matching _pickup_source_profile.
	enemy.lizard_profile_active = true
	var lizard: float = enemy._get_effective_turn_speed_degrees()

	enemy.gorilla_profile_active = false
	enemy.crawling_due_to_leg_loss = true
	var lizard_crawling: float = enemy._get_effective_turn_speed_degrees()

	print("turn rates: plain %.0f, gorilla %.0f, lizard %.0f, lizard crawling %.0f (deg/s)" % [
		plain, gorilla, lizard, lizard_crawling,
	])

	if not (gorilla < plain):
		failures.append("the gorilla does not turn slower than a plain enemy (%.0f vs %.0f)" % [gorilla, plain])
	if not (lizard > plain):
		failures.append("the lizard does not turn faster than a plain enemy (%.0f vs %.0f)" % [lizard, plain])
	if not (lizard_crawling < lizard):
		failures.append("crawling did not slow the turn (%.0f vs %.0f)" % [lizard_crawling, lizard])

	# "Instant" must survive both the profile lookup and the crawl multiplier:
	# scaling a 0 keeps it 0, but it must not be read back as a real rate.
	enemy.lizard_profile_active = false
	enemy.turn_speed_degrees = 0.0
	if enemy._get_effective_turn_speed_degrees() != 0.0:
		failures.append("a turn rate of 0 stopped meaning instant once crawling")

	_teardown([enemy])
	return failures


# A turn across the +-PI seam must not take the long way around.
func _check_turn_takes_the_short_way() -> Array[String]:
	var failures: Array[String] = []
	var enemy = await _make_enemy()
	enemy.turn_speed_degrees = 240.0
	var step: float = enemy.get_physics_process_delta_time()
	var expected_step: float = deg_to_rad(240.0) * step

	# Facing just short of +PI, asked to face just past it: 0.2 rad away the
	# short way, 6.08 rad the long way.
	enemy.rotation.y = PI - 0.1
	var target := Vector3(sin(-PI + 0.1), 0.0, cos(-PI + 0.1))
	enemy._turn_toward(target)

	var delta_applied: float = absf(wrapf(enemy.rotation.y - (PI - 0.1), -PI, PI))
	if delta_applied > expected_step + 0.0001:
		failures.append("seam turn moved %.4f rad in one step, more than the cap" % delta_applied)
	# Moving the short way means the yaw increases past PI (and wraps), never
	# decreases toward 0.
	var remaining: float = absf(wrapf((-PI + 0.1) - enemy.rotation.y, -PI, PI))
	if remaining >= 0.2:
		failures.append("the turn went the long way around the +-PI seam (remaining %.4f)" % remaining)
	print("seam turn: closed to %.4f rad remaining" % remaining)

	_teardown([enemy])
	return failures


# The regression that produced tens of thousands of "Trying to cast a freed
# object" errors.
func _check_freed_limb_body_is_survivable() -> Array[String]:
	var failures: Array[String] = []
	var enemy = await _make_enemy()

	var limb := Node3D.new()
	_world.add_child(limb)
	await process_frame
	enemy.detached_limb_bodies["right_arm"] = limb

	if not enemy._is_detached_limb_body_valid("right_arm"):
		failures.append("a live limb body was reported invalid")
	if enemy._valid_limb_body("right_arm") == null:
		failures.append("_valid_limb_body did not return a live body")

	# Free it WITHOUT telling the enemy, which is exactly the state the bug
	# needed: a stale key pointing at a freed object.
	limb.free()

	if enemy._is_detached_limb_body_valid("right_arm"):
		failures.append("a freed limb body was reported valid")
	if enemy._valid_limb_body("right_arm") != null:
		failures.append("_valid_limb_body handed back a freed body")

	# Every reader must cope. Each of these used to cast before checking.
	enemy._has_active_limb_pickup()
	enemy._get_recovering_limb_key()
	enemy._get_bone_recovery_move()
	enemy._recover_detached_limb("right_arm")

	# A null in the dictionary, and an unknown key, must be just as safe.
	enemy.detached_limb_bodies["left_arm"] = null
	if enemy._valid_limb_body("left_arm") != null:
		failures.append("a null entry was treated as a live body")
	if enemy._valid_limb_body("no_such_limb") != null:
		failures.append("an unknown key returned a body")
	if enemy._valid_limb_body("") != null:
		failures.append("an empty key returned a body")
	enemy._has_active_limb_pickup()

	print("freed limb body: detected without casting, all readers survived")
	_teardown([enemy])
	return failures


func _make_enemy():
	var enemy = _enemy_scene.instantiate()
	# Keep the AI from wandering off mid-assertion; this check drives turning
	# and limb bookkeeping directly.
	enemy.idle_wander_enabled = false
	enemy.respawn_enabled = false
	enemy.bone_recovery_enabled = true
	# Pin the variant so the rate under test is the plain one, not whatever
	# "Auto" infers from this enemy's health.
	enemy.gorilla_profile_mode = "Never"
	enemy.lizard_profile_mode = "Never"
	_world.add_child(enemy)
	await process_frame
	return enemy


func _teardown(nodes: Array) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			node.free()
