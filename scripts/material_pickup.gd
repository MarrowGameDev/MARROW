extends Area3D
class_name MaterialPickup
## A crafting material lying on the ground: a small white-grey sphere that glows with a
## fire-like light — ramps up on spawn, then flickers and gently bobs. Walk over it to
## collect: it darts to the player, adds itself to CraftingSystem, floats a "+N Name" label
## and disappears. Spawn with MaterialPickup.spawn(host, id, qty, from, to): it hops in an
## arc from `from` (top of the box/pile) to `to` (a spot on the floor).

const SCENE_PATH := "res://scenes/material_pickup.tscn"

@export var material_id: String = "wood_plank"
@export var quantity: int = 1
@export var radius: float = 0.12          # sphere size (world m)
@export var collect_radius: float = 0.7   # how close the player has to come
@export var light_range: float = 2.5
@export var light_energy: float = 1.6

var _mesh: MeshInstance3D
var _mat: StandardMaterial3D
var _light: OmniLight3D
var _t := 0.0
var _age := 0.0
var _seed := 0.0
var _collected := false
var _hopping := false


static func spawn(host: Node, id: String, qty: int, from: Vector3, to: Vector3) -> MaterialPickup:
	var p: MaterialPickup = (load(SCENE_PATH) as PackedScene).instantiate() as MaterialPickup
	p.material_id = id
	p.quantity = qty
	host.add_child(p)
	p.global_position = from
	p.hop_to(to)
	return p


func _ready() -> void:
	add_to_group("material_pickups")
	_seed = randf() * 100.0
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = collect_radius
	cs.shape = sh
	add_child(cs)

	_mesh = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = 16
	sm.rings = 8
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = GlowFX.COLOR
	_mat.roughness = 0.6
	_mat.emission_enabled = true
	_mat.emission = GlowFX.COLOR
	_mat.emission_energy_multiplier = 0.0     # ramps up in _process
	sm.material = _mat
	_mesh.mesh = sm
	_mesh.position.y = radius
	add_child(_mesh)

	_light = OmniLight3D.new()
	_light.light_color = GlowFX.LIGHT_COLOR
	_light.light_energy = 0.0                 # ramps up in _process
	_light.omni_range = light_range
	_light.omni_attenuation = 1.3
	_light.position.y = radius * 1.5
	add_child(_light)

	body_entered.connect(_on_body_entered)


## Arc from the current position to `to` (a parabolic hop), then settle.
func hop_to(to: Vector3) -> void:
	_hopping = true
	var from := global_position
	var tw := create_tween()
	tw.tween_method(func(t: float): global_position = from.lerp(to, t) + Vector3.UP * sin(t * PI) * 0.6, 0.0, 1.0, 0.55) \
		.set_ease(Tween.EASE_OUT)
	tw.finished.connect(func(): _hopping = false)


func _process(delta: float) -> void:
	_t += delta
	_age += delta
	# fades up like a fire being lit, then flickers
	var k: float = GlowFX.rise(_age) * GlowFX.fire(_t, _seed)
	_mat.emission_energy_multiplier = 2.2 * k
	_light.light_energy = light_energy * k
	if not _hopping and not _collected:
		_mesh.position.y = radius + sin(_t * 2.0 + _seed) * 0.03   # gentle bob


func _on_body_entered(body: Node3D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	set_deferred("monitoring", false)
	var sys = get_tree().root.get_node_or_null("CraftingSystem")
	if sys != null:
		sys.add_material(material_id, quantity)
	var shown: String = sys.material_name(material_id) if sys != null else material_id.capitalize()
	_float_label("+%d %s" % [quantity, shown])
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "global_position", body.global_position + Vector3.UP * 0.6, 0.22).set_ease(Tween.EASE_IN)
	tw.tween_property(_mesh, "scale", Vector3.ZERO, 0.22)
	tw.tween_property(_light, "light_energy", 0.0, 0.22)
	tw.chain().tween_callback(queue_free)


func _float_label(text: String) -> void:
	var host := get_parent()
	if host == null:
		return
	var l := Label3D.new()
	l.text = text
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.font_size = 40
	l.pixel_size = 0.004
	l.outline_size = 8
	l.modulate = Color(0.97, 0.95, 0.90)
	l.outline_modulate = Color(0.22, 0.13, 0.05)
	host.add_child(l)
	l.global_position = global_position + Vector3.UP * 0.5
	var tw := l.create_tween().set_parallel(true)
	tw.tween_property(l, "global_position", l.global_position + Vector3.UP * 0.9, 1.0)
	tw.tween_property(l, "modulate:a", 0.0, 1.0).set_delay(0.3)
	tw.chain().tween_callback(l.queue_free)
