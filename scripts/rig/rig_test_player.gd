extends CharacterBody3D

# Minimal controller for the ISOLATED rig test scene (Marrow rigging brief).
# It only does movement + drives the procedural animator. It deliberately does
# NOT include the real player's combat/inventory — this is a rig sandbox.
# Controls: WASD move, Q cycles equipping Arm -> Leg -> Heavy bones,
# 2 and 3 play the animation A/B demo (see docs/rig_notes.md).

@export var move_speed := 6.0
@export var gravity := 24.0

# Animation demo target: orbits the player so the lunge has something moving to
# chase. Radius sits just past head_only_attack_lunge, so a tracked lunge lands
# near the ball and a stale one clearly does not.
const DEMO_TARGET_ORBIT_RADIUS := 1.2
const DEMO_TARGET_ORBIT_SPEED := 2.0
const DEMO_TARGET_HEIGHT := 0.7
const DEMO_TARGET_SIZE := 0.16

var facing_direction := Vector3.FORWARD
var equipped_ids: Array[String] = []
var _equip_cycle: Array[String] = ["arm_bone", "leg_bone", "heavy_bone"]
var _equip_index := 0
var _demo_target_marker: Node3D = null
var _demo_target_time := 0.0

@onready var rig: ModularSkeletonRig = $VisualRoot/ModularSkeletonRig
@onready var animator: ProceduralPlayerAnimator = $VisualRoot/ProceduralAnimator


func _ready() -> void:
	animator.rig = rig
	animator.turn_target = $VisualRoot


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("equip"):
		_cycle_equip()

	if Input.is_action_just_pressed("attack"):
		animator.trigger_attack()

	_update_demo_target(delta)
	if Input.is_action_just_pressed("anim_demo_procedural"):
		_trigger_animation_demo(false)
	if Input.is_action_just_pressed("anim_demo_tween"):
		_trigger_animation_demo(true)

	# Movement (gravity + WASD), mirroring the real player's feel.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	if direction.length() > 0.01:
		facing_direction = direction

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()

	# Animate AFTER movement, from the resolved velocity.
	if animator != null:
		animator.update_from_player(delta, velocity, move_speed, facing_direction, rig.get_equipped_bone_defs())


# Animation A/B harness: key 2 plays the hand-rolled version of the head lunge,
# key 3 plays the Tween version of the same motion. Both aim at an orbiting
# target, which is what separates them: key 2 re-aims mid-flight, key 3 commits
# to wherever the target was when the tween was built.
func _trigger_animation_demo(use_tween: bool) -> void:
	if animator == null:
		return
	_ensure_demo_target()
	# Place the target before triggering, so the tween bakes a current aim.
	_update_demo_target(0.0)
	var method: String = "trigger_demo_attack_tween" if use_tween else "trigger_demo_attack_procedural"
	if animator.has_method(method):
		animator.call(method)


func _ensure_demo_target() -> void:
	if _demo_target_marker != null and is_instance_valid(_demo_target_marker):
		return
	var marker := Node3D.new()
	marker.name = "AnimationDemoTarget"
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = DEMO_TARGET_SIZE
	sphere.height = DEMO_TARGET_SIZE * 2.0
	mesh.mesh = sphere
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.35, 0.18, 1.0)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.35, 0.18, 1.0)
	material.emission_energy_multiplier = 1.6
	mesh.material_override = material
	marker.add_child(mesh)
	get_tree().current_scene.add_child(marker)
	_demo_target_marker = marker


func _update_demo_target(delta: float) -> void:
	if _demo_target_marker == null or not is_instance_valid(_demo_target_marker):
		return
	_demo_target_time += delta
	var angle: float = _demo_target_time * DEMO_TARGET_ORBIT_SPEED
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * DEMO_TARGET_ORBIT_RADIUS
	_demo_target_marker.global_position = global_position + offset + Vector3(0.0, DEMO_TARGET_HEIGHT, 0.0)
	if animator != null and animator.has_method("set_demo_target_world_position"):
		animator.call("set_demo_target_world_position", _demo_target_marker.global_position)


func _cycle_equip() -> void:
	var bone_id := _equip_cycle[_equip_index]
	_equip_index = (_equip_index + 1) % _equip_cycle.size()
	rig.equip_bone(bone_id, BoneRulesService.definition_for(bone_id))
	if not equipped_ids.has(bone_id):
		equipped_ids.append(bone_id)
	print("Rig test equipped: ", BoneRulesService.display_name_with_slot(bone_id))
