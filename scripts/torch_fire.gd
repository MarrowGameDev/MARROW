extends Node3D
## Stylized torch fire: soft painterly flame particles + drifting embers + a flickering warm light.
## Drop torch_fire.tscn as a CHILD of a torch and move it to the flame tip. Tune the exports per torch.

@export var flame_height: float = 0.35     # world units; size to your torch model
@export var flame_width: float = 0.18
@export var light_energy: float = 2.2
@export var light_range: float = 6.0
@export var light_color: Color = Color(1.0, 0.62, 0.25)
@export var cast_shadows: bool = true       # turn off if you have many torches (shadows cost)
@export_range(0.0, 1.0) var flicker_amount: float = 0.35
@export var flicker_speed: float = 14.0

var _light: OmniLight3D
var _t := 0.0
var _seed := 0.0


func _ready() -> void:
	_seed = randf() * 100.0
	_build_flame()
	_build_embers()
	_build_light()


# --- soft radial sprite used by both flame and embers (procedural, no texture file needed) ----
func _soft_sprite() -> Texture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.45, Color(1, 1, 1, 0.7))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	t.width = 64
	t.height = 64
	return t


func _particle_material(size: Vector2) -> QuadMesh:
	var quad := QuadMesh.new()
	quad.size = size
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD        # glowing, painterly
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.vertex_color_use_as_albedo = true                  # lets the color ramp tint it
	mat.albedo_texture = _soft_sprite()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = mat
	return quad


# --- the flame body: rising, shrinking, yellow core -> orange -> red -> gone -----------------
func _build_flame() -> void:
	var p := GPUParticles3D.new()
	p.name = "Flame"
	p.amount = 24
	p.lifetime = 0.7
	p.randomness = 0.6
	p.local_coords = true
	p.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH

	var m := ParticleProcessMaterial.new()
	m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	m.emission_sphere_radius = flame_width * 0.35
	m.direction = Vector3(0, 1, 0)
	m.spread = 12.0
	m.initial_velocity_min = flame_height * 1.4
	m.initial_velocity_max = flame_height * 2.2
	m.gravity = Vector3(0, 1.2, 0)          # buoyant: flames accelerate upward
	m.damping_min = 0.5
	m.damping_max = 1.5
	m.scale_min = 0.7
	m.scale_max = 1.2
	# shrink over life so the tip tapers
	var c := Curve.new()
	c.add_point(Vector2(0.0, 1.0))
	c.add_point(Vector2(0.35, 0.85))
	c.add_point(Vector2(1.0, 0.0))
	var sc := CurveTexture.new()
	sc.curve = c
	m.scale_curve = sc
	# colour over life
	var g := Gradient.new()
	g.set_color(0, Color(1.0, 0.95, 0.55, 1.0))   # bright yellow core
	g.set_color(1, Color(0.85, 0.15, 0.02, 0.0))  # fades out deep red
	g.add_point(0.35, Color(1.0, 0.55, 0.12, 0.95))
	g.add_point(0.7, Color(0.95, 0.25, 0.05, 0.6))
	var gt := GradientTexture1D.new()
	gt.gradient = g
	m.color_ramp = gt
	p.process_material = m
	p.draw_pass_1 = _particle_material(Vector2(flame_width, flame_height))
	add_child(p)


# --- a few embers drifting up and out ------------------------------------------------------
func _build_embers() -> void:
	var p := GPUParticles3D.new()
	p.name = "Embers"
	p.amount = 8
	p.lifetime = 1.4
	p.randomness = 0.8
	p.local_coords = true

	var m := ParticleProcessMaterial.new()
	m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	m.emission_sphere_radius = flame_width * 0.3
	m.direction = Vector3(0, 1, 0)
	m.spread = 35.0
	m.initial_velocity_min = flame_height * 1.0
	m.initial_velocity_max = flame_height * 2.5
	m.gravity = Vector3(0, 0.6, 0)
	m.scale_min = 0.15
	m.scale_max = 0.35
	var g := Gradient.new()
	g.set_color(0, Color(1.0, 0.8, 0.3, 1.0))
	g.set_color(1, Color(0.8, 0.2, 0.0, 0.0))
	var gt := GradientTexture1D.new()
	gt.gradient = g
	m.color_ramp = gt
	p.process_material = m
	p.draw_pass_1 = _particle_material(Vector2(flame_width * 0.25, flame_width * 0.25))
	add_child(p)


# --- the light that actually lights the room ---------------------------------------------
func _build_light() -> void:
	_light = OmniLight3D.new()
	_light.name = "FlameLight"
	_light.light_color = light_color
	_light.light_energy = light_energy
	_light.omni_range = light_range
	_light.omni_attenuation = 1.4
	_light.shadow_enabled = cast_shadows
	_light.position = Vector3(0, flame_height * 0.4, 0)
	add_child(_light)


func _process(delta: float) -> void:
	if _light == null:
		return
	_t += delta * flicker_speed
	# layered sines = organic flicker without per-frame random popping
	var f := sin(_t) * 0.5 + sin(_t * 2.3 + _seed) * 0.3 + sin(_t * 5.1 + _seed * 0.5) * 0.2
	_light.light_energy = light_energy * (1.0 + f * flicker_amount)
	_light.position.x = f * 0.01     # tiny wander sells the movement
	_light.position.z = f * 0.008
