class_name PlayerCameraController
extends Node3D

# Third-person orbit camera component.
# The player owns gameplay state; this node owns camera orbit, zoom, and mouse capture.

@export var spring_arm_path: NodePath = NodePath("SpringArm3D")
@export var camera_path: NodePath = NodePath("SpringArm3D/Camera3D")
@export_range(0.001, 0.02, 0.001) var mouse_sensitivity: float = 0.003
@export_range(-80.0, 0.0, 1.0) var min_vertical_angle: float = -35.0
@export_range(0.0, 80.0, 1.0) var max_vertical_angle: float = 60.0
@export_range(1.0, 10.0, 0.1) var min_zoom_distance: float = 2.5
@export_range(2.0, 15.0, 0.1) var max_zoom_distance: float = 7.0
@export_range(1.0, 10.0, 0.1) var initial_zoom_distance: float = 4.5
@export_range(0.1, 2.0, 0.05) var zoom_step: float = 0.45
@export_range(1.0, 30.0, 0.5) var zoom_smoothing: float = 14.0
@export_range(1.0, 30.0, 0.5) var follow_smoothing: float = 18.0
@export_range(0.0, 2.5, 0.05) var pivot_height: float = 0.75
@export_range(0.0, 1.0, 0.05) var spring_arm_margin: float = 0.25
@export_flags_3d_physics var spring_arm_collision_mask: int = 1
@export var capture_mouse_on_ready: bool = true

var look_enabled: bool = true
var yaw: float = 0.0
var pitch: float = 0.0
var target_zoom_distance: float = 4.5
var camera: Camera3D = null
var spring_arm: SpringArm3D = null
var target: Node3D = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	target = get_parent() as Node3D
	top_level = true
	spring_arm = get_node_or_null(spring_arm_path) as SpringArm3D
	camera = get_node_or_null(camera_path) as Camera3D
	yaw = rotation.y
	pitch = rotation.x
	target_zoom_distance = clampf(initial_zoom_distance, min_zoom_distance, max_zoom_distance)

	if spring_arm == null:
		push_error("PlayerCameraController requires a SpringArm3D at '%s'." % spring_arm_path)
	else:
		spring_arm.spring_length = target_zoom_distance
		spring_arm.margin = spring_arm_margin
		spring_arm.collision_mask = spring_arm_collision_mask
		var collision_target := target as CollisionObject3D
		if collision_target != null:
			spring_arm.add_excluded_object(collision_target.get_rid())

	if camera == null:
		push_error("PlayerCameraController requires a Camera3D at '%s'." % camera_path)
	else:
		camera.current = true

	if target == null:
		push_error("PlayerCameraController needs a Node3D parent to follow.")
	else:
		global_position = _target_pivot_position()
	_apply_orbit_rotation()
	if capture_mouse_on_ready:
		capture_mouse()


func _process(delta: float) -> void:
	if target != null:
		var follow_alpha := 1.0 - exp(-follow_smoothing * delta)
		global_position = global_position.lerp(_target_pivot_position(), follow_alpha)

	if spring_arm == null:
		return

	var alpha := 1.0 - exp(-zoom_smoothing * delta)
	spring_arm.spring_length = lerpf(spring_arm.spring_length, target_zoom_distance, alpha)


func _unhandled_input(event: InputEvent) -> void:
	if not look_enabled:
		return

	if event.is_action_pressed("ui_cancel"):
		release_mouse()
		return

	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			capture_mouse()
			return
		if button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-zoom_step)
			return
		if button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(zoom_step)
			return

	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		var motion := event as InputEventMouseMotion
		_apply_mouse_motion(motion.relative)


func capture_mouse() -> void:
	look_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func set_look_enabled(enabled: bool) -> void:
	look_enabled = enabled
	if enabled:
		capture_mouse()
	else:
		release_mouse()


func get_flat_forward() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return Vector3.FORWARD
	return forward.normalized()


func get_flat_right() -> Vector3:
	var right := global_transform.basis.x
	right.y = 0.0
	if right.length() < 0.01:
		return Vector3.RIGHT
	return right.normalized()


func _apply_mouse_motion(relative: Vector2) -> void:
	yaw -= relative.x * mouse_sensitivity
	pitch -= relative.y * mouse_sensitivity
	pitch = clampf(pitch, deg_to_rad(min_vertical_angle), deg_to_rad(max_vertical_angle))
	_apply_orbit_rotation()


func _zoom(amount: float) -> void:
	target_zoom_distance = clampf(target_zoom_distance + amount, min_zoom_distance, max_zoom_distance)


func _target_pivot_position() -> Vector3:
	return target.global_position + Vector3.UP * pivot_height


func _apply_orbit_rotation() -> void:
	# Keep roll at zero so character lean, slopes, or animation never tilt the camera.
	rotation = Vector3(pitch, yaw, 0.0)
