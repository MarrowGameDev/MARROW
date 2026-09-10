extends MeshInstance3D
class_name OutlineGlow
## Inverted-hull outline: a copy of the target mesh drawn back-faces-only, pushed out along
## the normals and unshaded in the glow colour — reads as a lit rim around the silhouette.
## Marks a box / pile / group as "contains materials". Drive set_intensity() each frame with
## the fire flicker; fade it to 0 when the thing is picked clean.

const SHADER_CODE := """
shader_type spatial;
render_mode cull_front, unshaded, depth_draw_opaque;
uniform vec4 color : source_color = vec4(0.86, 0.86, 0.82, 1.0);
uniform float width = 0.02;
uniform float intensity = 1.0;
void vertex() { VERTEX += NORMAL * width; }
void fragment() { ALBEDO = color.rgb * intensity; EMISSION = color.rgb * intensity * 1.5; }
"""

var _mat: ShaderMaterial


## Attach an outline to `target` (as its child, so it follows transform and scale).
## `width_ratio` is the rim thickness as a fraction of the mesh's largest dimension.
static func attach(target: MeshInstance3D, color: Color = GlowFX.COLOR, width_ratio: float = 0.015) -> OutlineGlow:
	var o := OutlineGlow.new()
	o.name = "OutlineGlow"
	o.mesh = target.mesh
	var sh := Shader.new()
	sh.code = SHADER_CODE
	o._mat = ShaderMaterial.new()
	o._mat.shader = sh
	o._mat.set_shader_parameter("color", color)
	var aabb := target.get_aabb()
	o._mat.set_shader_parameter("width", maxf(aabb.size.x, maxf(aabb.size.y, aabb.size.z)) * width_ratio)
	o._mat.set_shader_parameter("intensity", 0.0)
	o.material_override = o._mat
	o.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	target.add_child(o)
	return o


func set_intensity(v: float) -> void:
	_mat.set_shader_parameter("intensity", v)
	visible = v > 0.01


func intensity() -> float:
	return float(_mat.get_shader_parameter("intensity"))
