extends CharacterBody3D

# Minimal controller for the ISOLATED rig test scene (Marrow rigging brief).
# It only does movement + drives the procedural animator. It deliberately does
# NOT include the real player's combat/inventory — this is a rig sandbox.
# Controls: WASD move, Q cycles equipping Arm -> Leg -> Heavy bones.

@export var move_speed := 6.0
@export var gravity := 24.0

var facing_direction := Vector3.FORWARD
var equipped_ids: Array[String] = []
var _equip_cycle: Array[String] = ["arm_bone", "leg_bone", "heavy_bone"]
var _equip_index := 0

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


func _cycle_equip() -> void:
	var bone_id := _equip_cycle[_equip_index]
	_equip_index = (_equip_index + 1) % _equip_cycle.size()
	rig.equip_bone(bone_id, BoneRulesService.definition_for(bone_id))
	if not equipped_ids.has(bone_id):
		equipped_ids.append(bone_id)
	print("Rig test equipped: ", BoneRulesService.display_name_with_slot(bone_id))
