extends CharacterBody3D

# Health / hurtbox for the player Crab. The test harness drives MOVEMENT; this script only owns
# HP, so an enemy headbutt (which calls take_damage on the collider it rams) lands on the player.
# It announces state on the GameEvents bus (AGENTS: "Usar senales/eventos para comunicar sistemas
# desacoplados"): the HUD, flash, and respawn listen there rather than reaching into this node.

@export var max_health: int = 4       # 4 bones, one hit each (full -> outline)
@export var invuln_time: float = 0.5    # brief i-frames after a hit so a single headbutt = one hit

var _hp := 0
var _invuln := 0.0


func _ready() -> void:
	add_to_group(GameGroups.PLAYER)      # enemies find the player through this group
	_hp = max_health
	call_deferred("_announce")           # emit initial HP after listeners have connected


func _announce() -> void:
	GameEvents.player_health_changed.emit(self, _hp, max_health)


func _process(delta: float) -> void:
	if _invuln > 0.0:
		_invuln -= delta


func take_damage(amount: int, _from: Vector3 = Vector3.ZERO, attacker: Node = null, _src: String = "") -> void:
	if _invuln > 0.0 or _hp <= 0:
		return
	_hp = maxi(0, _hp - amount)
	_invuln = invuln_time
	GameEvents.player_damaged.emit(self, amount, attacker)
	GameEvents.player_health_changed.emit(self, _hp, max_health)
	if _hp <= 0:
		GameEvents.player_died.emit(self)


func heal_full() -> void:
	_hp = max_health
	_invuln = maxf(_invuln, 0.6)
	GameEvents.player_health_changed.emit(self, _hp, max_health)
