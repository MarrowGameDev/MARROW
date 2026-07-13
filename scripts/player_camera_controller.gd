class_name PlayerCameraController
extends Node3D

# Third-person mouse look component.
# The player owns gameplay state; this node owns camera orbit and mouse capture.

@export var camera_path: NodePath = NodePath("Camera3D")
@export_range(0.001, 0.02, 0.001) var mouse_sensitivity: float = 0.004
@export_range(-89.0, -5.0, 1.0) var min_pitch_degrees: float = -65.0
@export_range(-35.0, 35.0, 1.0) var max_pitch_degrees: float = 12.0
@export var capture_mouse_on_ready: bool = true

var look_enabled: bool = true
var yaw: float = 0.0
var pitch: float = 0.0
var camera: Camera3D = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	camera = get_node_or_null(camera_path) as Camera3D
	yaw = rotation.y
	if camera != null:
		pitch = camera.rotation.x
	if capture_mouse_on_ready:
		capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if not look_enabled:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		_apply_mouse_motion(motion.relative)


func capture_mouse() -> void:
	look_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func release_mouse() -> void:
	look_enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func set_look_enabled(enabled: bool) -> void:
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
	pitch = clampf(pitch, deg_to_rad(min_pitch_degrees), deg_to_rad(max_pitch_degrees))

	rotation.y = yaw
	if camera != null:
		camera.rotation.x = pitch
