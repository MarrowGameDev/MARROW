class_name BodySentinel
extends Node

# Combat brain for a body an ENEMY has possessed. It owns HEALTH and the DECISION to chomp; the
# body node it lives under owns the VISUALS (flash/chomp) and the ownership state. Splitting this
# out of body_dock keeps each to one responsibility and separates detection/decision from feedback
# (AGENTS: "una responsabilidad", "Separar deteccion, decision y feedback").

var _body: Node3D            # the possessed body (its parent) — asked for visuals + position
var _health := 0
var _atk_range := 2.3
var _atk_cd_max := 1.8
var _atk_power := 2
var _atk_cd := 0.0


# Called by the body the moment an enemy seats its head.
func setup(body: Node3D, health: int, atk_range: float, atk_cd: float, atk_power: int) -> void:
	_body = body
	_health = health
	_atk_range = atk_range
	_atk_cd_max = atk_cd
	_atk_power = atk_power
	_atk_cd = 0.6


# The player's headbutt lands on the body, which forwards it here.
func take_hit(amount: int) -> void:
	_health -= amount
	if _body != null and _body.has_method("play_hit_flash"):
		_body.play_hit_flash()
	if _health <= 0 and _body != null and _body.has_method("release"):
		_body.release()   # dies -> the body frees itself and drops this component


func _process(delta: float) -> void:
	if _body == null:
		return
	_atk_cd = maxf(0.0, _atk_cd - delta)
	if _atk_cd > 0.0:
		return
	# DECISION: chomp the player if they wander into range
	var pl := get_tree().get_first_node_in_group(GameGroups.PLAYER)
	if pl is Node3D and pl.has_method("take_damage"):
		var to := (pl as Node3D).global_position - _body.global_position; to.y = 0.0
		if to.length() <= _atk_range:
			pl.take_damage(_atk_power, _body.global_position, _body)
			_atk_cd = _atk_cd_max
			if _body.has_method("play_chomp"):
				_body.play_chomp()   # FEEDBACK lives on the body
