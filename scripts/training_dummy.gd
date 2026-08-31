extends StaticBody3D

# A stationary TRAINING DUMMY to test attacks against. It never dies — when hit it FLASHES and TILTS
# away from the blow, then springs back like a punching bag — so there's always something to headbutt
# and you can read the impact. Its collider stays put (only the visual tilts) so aim/raycasts stay true.

@export var height: float = 1.2
@export var radius: float = 0.34
@export var knock_deg: float = 40.0    # how far it tips on a full-power hit
@export var stiffness: float = 85.0    # spring pulling it back upright
@export var damping: float = 10.0      # higher = settles faster
@export var full_damage: int = 3       # damage that yields a full-strength wobble

var _pivot: Node3D
var _mat: StandardMaterial3D
var _tilt := Vector2.ZERO       # x = pitch (front hits), y = roll (side hits)
var _tilt_vel := Vector2.ZERO
var _flash := 0.0
var _hits := 0

const BASE := Color(0.72, 0.68, 0.5)
const HIT := Color(1.0, 0.35, 0.25)


func _ready() -> void:
	collision_layer = 1   # so the headbutt raycast (mask 1) sees it
	collision_mask = 1
	add_to_group("attack_targets")

	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = radius
	cap.height = height
	col.shape = cap
	col.position.y = height * 0.5 + 0.1
	add_child(col)

	_pivot = Node3D.new()   # tilts on hit; the collider above stays upright so aim stays honest
	add_child(_pivot)
	var mi := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = radius
	cm.height = height
	mi.mesh = cm
	mi.position.y = height * 0.5 + 0.1
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = BASE
	mi.material_override = _mat
	_pivot.add_child(mi)


# Struck by an attack: flash + tip away from where the blow came from (`from_pos`).
func take_damage(amount: int, from_pos: Vector3, _source: Object = null) -> void:
	_hits += 1
	var away := global_position - from_pos
	away.y = 0.0
	away = away.normalized() if away.length() > 0.01 else Vector3.FORWARD
	var mag := deg_to_rad(knock_deg) * clampf(float(amount) / float(maxi(full_damage, 1)), 0.4, 1.0)
	# front hit (away +Z) tips it back (+pitch); side hit (away +X) rolls it (-roll)
	_tilt_vel += Vector2(away.z, -away.x) * mag * 14.0
	_flash = 1.0


func hits() -> int:
	return _hits


func _process(delta: float) -> void:
	# spring the wobble back to upright
	_tilt_vel -= _tilt * stiffness * delta
	_tilt_vel *= exp(-damping * delta)
	_tilt += _tilt_vel * delta
	_pivot.rotation.x = _tilt.x
	_pivot.rotation.z = _tilt.y
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 3.5)
		_mat.albedo_color = BASE.lerp(HIT, _flash)
