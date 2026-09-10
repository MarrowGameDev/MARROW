extends Node3D
class_name BlueprintProp
## A blueprint that appears on the tabletop and UNROLLS once the bench camera has locked in:
## a parchment sheet with a procedural ink grid that extends out from a paper roll travelling
## along it, plus the selected recipe's name written on the sheet. roll_up() reverses it.
## Local +Z is the unroll direction (away from the viewer); the origin is the near edge.

signal unrolled
signal rolled_up

const SHEET_SHADER := """
shader_type spatial;
render_mode cull_disabled;
uniform vec4 paper : source_color = vec4(0.93, 0.89, 0.80, 1.0);
uniform vec4 ink : source_color = vec4(0.30, 0.20, 0.10, 1.0);
uniform float grid = 12.0;
uniform float length = 1.0;
uniform float reveal : hint_range(0.0, 1.0) = 0.0;   // fraction of the length unrolled
varying float along;                                   // 0 at the near edge .. 1 at the far edge
void vertex() { along = (VERTEX.z + length * 0.5) / length; }
void fragment() {
	if (along > reveal) { discard; }
	vec2 g = abs(fract(UV * grid) - 0.5);
	float line = 1.0 - smoothstep(0.0, 0.06, min(g.x, g.y));
	float border = step(UV.x, 0.025) + step(0.975, UV.x) + step(along, 0.025) + step(0.975, along);
	float k = clamp(line * 0.35 + border, 0.0, 1.0);
	ALBEDO = mix(paper.rgb, ink.rgb, k);
	ROUGHNESS = 0.9;
}
"""

@export var length: float = 1.0        # world metres along +Z (front -> back of the bench)
@export var width: float = 0.8
@export var unroll_time: float = 0.7
@export var roll_radius: float = 0.035

var _sheet: MeshInstance3D
var _mat: ShaderMaterial
var _roll: MeshInstance3D
var _title: Label3D
var _reveal := 0.0
var _tw: Tween = null


func _ready() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(width, length)
	_sheet = MeshInstance3D.new()
	_sheet.mesh = plane
	_sheet.position = Vector3(0.0, 0.004, length * 0.5)   # near edge at the origin, a hair above the table
	var sh := Shader.new()
	sh.code = SHEET_SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.set_shader_parameter("length", length)
	_mat.set_shader_parameter("reveal", 0.0)
	_sheet.material_override = _mat
	_sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_sheet)

	var cyl := CylinderMesh.new()
	cyl.top_radius = roll_radius
	cyl.bottom_radius = roll_radius
	cyl.height = width * 1.02
	_roll = MeshInstance3D.new()
	_roll.mesh = cyl
	_roll.rotation.z = PI * 0.5                            # lie across the sheet
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(0.90, 0.85, 0.74)
	rm.roughness = 0.95
	_roll.material_override = rm
	add_child(_roll)

	_title = Label3D.new()
	_title.text = ""
	_title.font_size = 64
	_title.pixel_size = width / 700.0
	_title.modulate = Color(0.30, 0.20, 0.10, 0.0)
	_title.outline_size = 0
	_title.rotation.x = -PI * 0.5                          # lie flat on the sheet, readable from above
	_title.position = Vector3(0.0, 0.01, length * 0.5)
	add_child(_title)
	_set_reveal(0.0)


func set_title(text: String) -> void:
	_title.text = text


func reveal() -> float:
	return _reveal


func unroll() -> void:
	_animate(1.0, unroll_time, Tween.EASE_OUT, unrolled)

func roll_up() -> void:
	_animate(0.0, unroll_time * 0.6, Tween.EASE_IN, rolled_up)


func _animate(to: float, seconds: float, ease: Tween.EaseType, done: Signal) -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(ease)
	_tw.tween_method(_set_reveal, _reveal, to, seconds)
	_tw.tween_callback(func() -> void: done.emit())


func _set_reveal(v: float) -> void:
	_reveal = v
	_mat.set_shader_parameter("reveal", v)
	var r: float = lerpf(roll_radius, roll_radius * 0.45, v)   # the roll thins as the paper comes off it
	(_roll.mesh as CylinderMesh).top_radius = r
	(_roll.mesh as CylinderMesh).bottom_radius = r
	_roll.position = Vector3(0.0, r, v * length)
	_roll.visible = v < 0.999
	_title.modulate.a = clampf((v - 0.55) / 0.35, 0.0, 1.0)   # the name fades in as the sheet opens
