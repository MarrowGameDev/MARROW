class_name MarionetteHandCharacter
extends Node3D

const IDLE: StringName = &"Idle"
const AFK_CLIPS: Array[StringName] = [&"AFK Rock", &"AFK Paper", &"AFK Scissors"]
const WALK: StringName = &"Walking Forward"
const RUN: StringName = &"Running"
const JUMP: StringName = &"Jumping"

@export var autoplay_idle: bool = true
@export var turn_speed: float = 12.0
@export var afk_animation_delay: float = 30.0

var _animation_player: AnimationPlayer
var _jump_clip: StringName
var _afk_clip: StringName
var _jumping: bool = false
var _moving: bool = false
var _sprinting: bool = false
var _disabled: bool = false
var _inactive_time: float = 0.0
var _playing_afk: bool = false


func _ready() -> void:
	_animation_player = _find_animation_player(self)
	if _animation_player == null:
		push_warning("MarionetteHandCharacter: the imported GLB has no AnimationPlayer")
		return

	_set_loop_mode(IDLE, Animation.LOOP_LINEAR)
	for clip in AFK_CLIPS:
		_set_loop_mode(clip, Animation.LOOP_NONE)
	_set_loop_mode(WALK, Animation.LOOP_LINEAR)
	_set_loop_mode(RUN, Animation.LOOP_LINEAR)
	_set_loop_mode(JUMP, Animation.LOOP_NONE)
	_animation_player.animation_finished.connect(_on_animation_finished)

	if autoplay_idle:
		play_idle()


func play_idle(blend: float = 0.15) -> void:
	_play(IDLE, blend)


func play_afk_idle(blend: float = 0.2) -> void:
	_playing_afk = true
	_afk_clip = _resolve_clip(AFK_CLIPS.pick_random())
	_play(_afk_clip, blend)


func play_walk(blend: float = 0.15) -> void:
	_play(WALK, blend)


func play_run(blend: float = 0.12) -> void:
	_play(RUN, blend)


func play_jump(blend: float = 0.08) -> void:
	_register_activity()
	_jumping = true
	_jump_clip = _resolve_clip(JUMP)
	_play(JUMP, blend, 2.5)


func trigger_jump() -> void:
	play_jump()


func trigger_attack() -> void:
	# No attack clip exists yet, so keep the current locomotion pose.
	_register_activity()


func update_from_player(delta: float, body_velocity: Vector3, sprinting: bool, _grounded: bool) -> void:
	if _disabled:
		return
	var horizontal_velocity := Vector3(body_velocity.x, 0.0, body_velocity.z)
	_moving = horizontal_velocity.length_squared() > 0.0025
	_sprinting = sprinting and _moving
	if _moving:
		_inactive_time = 0.0
		_playing_afk = false
		var target_yaw := atan2(-horizontal_velocity.x, -horizontal_velocity.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(turn_speed * delta, 0.0, 1.0))
	elif not _jumping:
		_inactive_time += delta
		if _inactive_time >= afk_animation_delay and not _playing_afk:
			play_afk_idle()
	if not _jumping and not _playing_afk:
		_apply_locomotion()


func set_aiming(_enabled: bool) -> void:
	_register_activity()


func show_only_head() -> void:
	visible = true


func reveal_torso() -> void:
	visible = true


func show_all_parts() -> void:
	visible = true


func disable() -> void:
	_disabled = true
	visible = false


func is_disabled() -> bool:
	return _disabled


func animation_player() -> AnimationPlayer:
	return _animation_player


func _play(requested: StringName, blend: float, speed: float = 1.0) -> void:
	if _animation_player == null:
		return
	var clip := _resolve_clip(requested)
	if clip == &"":
		push_warning("MarionetteHandCharacter: missing animation '%s'" % requested)
		return
	if _animation_player.current_animation == clip and _animation_player.is_playing():
		return
	_animation_player.play(clip, blend, speed)


func _apply_locomotion() -> void:
	if _sprinting:
		play_run()
	elif _moving:
		play_walk()
	else:
		play_idle()


func _input(event: InputEvent) -> void:
	if _disabled:
		return
	var active := false
	if event is InputEventMouseMotion:
		active = event.relative.length_squared() > 1.0
	elif event is InputEventKey:
		active = event.pressed and not event.echo
	elif event is InputEventMouseButton:
		active = event.pressed
	elif event is InputEventJoypadButton:
		active = event.pressed
	elif event is InputEventJoypadMotion:
		active = absf(event.axis_value) > 0.2
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		active = true
	if active:
		_register_activity()


func _register_activity() -> void:
	_inactive_time = 0.0
	if not _playing_afk:
		return
	_playing_afk = false
	if not _jumping:
		_apply_locomotion()


func _set_loop_mode(requested: StringName, mode: Animation.LoopMode) -> void:
	var clip := _resolve_clip(requested)
	if clip == &"":
		return
	var animation := _animation_player.get_animation(clip)
	if animation != null:
		animation.loop_mode = mode


func _resolve_clip(requested: StringName) -> StringName:
	if _animation_player == null:
		return &""
	if _animation_player.has_animation(requested):
		return requested
	var wanted := String(requested).to_lower()
	for candidate in _animation_player.get_animation_list():
		var candidate_text := String(candidate).to_lower()
		if candidate_text == wanted or candidate_text.ends_with("/" + wanted):
			return candidate
	return &""


func _on_animation_finished(clip: StringName) -> void:
	if clip == _jump_clip:
		_jump_clip = &""
		_jumping = false
		_apply_locomotion()
	elif clip == _afk_clip:
		_afk_clip = &""
		_playing_afk = false
		_inactive_time = 0.0
		_apply_locomotion()


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
