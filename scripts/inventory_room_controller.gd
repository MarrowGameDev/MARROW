extends Node
class_name InventoryRoomController
## Takes the player to the INVENTORY ROOM and back. Opening: a stand-in camera lifts off from
## the hand's camera and tilts up to the sky while the screen snaps to black; at black the
## player is seated in the room (equipped parts and all), the room camera takes over and the
## inventory book opens on the left as the black lifts. Closing plays it backwards: black,
## the player is put back, the sky camera lowers onto the hand's camera and the black lifts.
## The tree stays paused from open() until the closing transition has finished.

signal opened
signal closed

const ROOM_OFFSET := Vector3(0.0, -300.0, 0.0)   # the room lives far below the level, in the dark

@export var rise_time: float = 0.55        # camera tilting up to the sky
@export var rise_height: float = 1.2       # metres the camera climbs while tilting
@export var rise_pitch_deg: float = 65.0   # how far it tilts up
@export var black_in_time: float = 0.28    # snap to black (overlaps the end of the rise)
@export var black_out_time: float = 0.25   # black lifting off the room / the world

var _player: Node3D
var _ui: Node                      # PlayerInventoryUI: set_open(bool)
var _room: Node3D = null           # InventoryRoom, created on first use
var _overlay: ColorRect
var _sky_cam: Camera3D = null      # the stand-in camera used for the rise / descent
var _open := false
var _busy := false
var _tw: Tween = null


func setup(player: Node3D, inventory_ui: Node) -> void:
	_player = player
	_ui = inventory_ui


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.name = "InventoryBlack"
	layer.layer = 95                          # above the inventory book (layer 5)
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_overlay)


func is_open() -> bool:
	return _open

func is_busy() -> bool:
	return _busy

func room() -> Node3D:
	return _room


func set_open(open: bool) -> void:
	if open:
		_enter()
	else:
		_leave()


# ---- entering ---------------------------------------------------------------------
func _enter() -> void:
	if _open or _busy or _player == null:
		return
	_busy = true
	_open = true
	get_tree().paused = true
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		_at_black_enter()
		return
	# lift off from the hand's camera: same pose, then up and toward the sky
	_sky_cam = Camera3D.new()
	_sky_cam.name = "SkyCamera"
	_sky_cam.fov = cam.fov
	_scene_root().add_child(_sky_cam)
	_sky_cam.global_transform = cam.global_transform
	_sky_cam.current = true
	var up_basis: Basis = Basis(cam.global_transform.basis.x.normalized(), deg_to_rad(rise_pitch_deg)) * cam.global_transform.basis
	var sky_xf := Transform3D(up_basis, cam.global_position + Vector3.UP * rise_height)
	_kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_sky_cam, "global_transform", sky_xf, rise_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tw.tween_property(_overlay, "color:a", 1.0, black_in_time).set_delay(maxf(rise_time - black_in_time, 0.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tw.chain().tween_callback(_at_black_enter)


func _at_black_enter() -> void:
	if _room == null:
		_room = InventoryRoom.new()
		_room.name = "InventoryRoom"
		_scene_root().add_child(_room)
		_room.global_position = _player.global_position + ROOM_OFFSET
	_room.enter(_player)                      # seats the player, room camera takes over
	if _ui != null:
		_ui.set_open(true)
	opened.emit()
	_kill()
	_tw = create_tween()
	_tw.tween_property(_overlay, "color:a", 0.0, black_out_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tw.tween_callback(func() -> void: _busy = false)


# ---- leaving ----------------------------------------------------------------------
func _leave() -> void:
	if not _open or _busy:
		return
	_busy = true
	_kill()
	_tw = create_tween()
	_tw.tween_property(_overlay, "color:a", 1.0, black_in_time * 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tw.tween_callback(_at_black_leave)


func _at_black_leave() -> void:
	if _ui != null:
		_ui.set_open(false)
	if _room != null:
		_room.leave()                         # player back where it stood; the sky camera is current again
	var hand_cam: Camera3D = _player_camera()
	_kill()
	_tw = create_tween().set_parallel(true)
	if _sky_cam != null and hand_cam != null:
		_sky_cam.current = true
		# the sky camera lowers back onto the hand's camera while the black lifts
		_tw.tween_property(_sky_cam, "global_transform", hand_cam.global_transform, rise_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tw.tween_property(_overlay, "color:a", 0.0, black_out_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tw.chain().tween_callback(_finish_leave)


func _finish_leave() -> void:
	var hand_cam: Camera3D = _player_camera()
	if hand_cam != null:
		hand_cam.current = true
	if _sky_cam != null:
		_sky_cam.queue_free()
		_sky_cam = null
	_open = false
	_busy = false
	get_tree().paused = false
	closed.emit()


# ---- helpers ----------------------------------------------------------------------
## The hand's own camera (the one that was current before the sky camera took over).
func _player_camera() -> Camera3D:
	if _player == null:
		return null
	var ctl: Node = _player.get("camera_controller")
	if ctl != null and ctl.get("camera") is Camera3D:
		return ctl.get("camera") as Camera3D
	return _player.find_child("Camera3D", true, false) as Camera3D

func _scene_root() -> Node:
	return get_tree().current_scene if get_tree().current_scene != null else get_tree().root

func _kill() -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = null
