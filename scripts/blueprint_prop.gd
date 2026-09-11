extends Node3D
class_name BlueprintProp
## A blueprint that appears on the tabletop and UNROLLS once the bench camera has locked in:
## a blue sheet with a procedural ink grid that extends out from a paper roll travelling along
## it, the selected recipe's SCHEMATIC drawn on it (BlueprintArt, rendered by a SubViewport),
## and its name floating over the near edge. roll_up() reverses it.
## Picking a different recipe rolls the sheet back up, swaps the drawing, and unrolls it again.
## Local +Z is the unroll direction (viewer's left -> right); the origin is the left end.
## Local +X is the far edge of the bench (the top of the drawing).

signal unrolled
signal rolled_up
signal picture_changed(recipe_id: String)   # a new drawing is on the sheet (after a swap)

const SHEET_SHADER := """
shader_type spatial;
render_mode cull_disabled;
uniform vec4 paper : source_color = vec4(0.10, 0.30, 0.62, 1.0);   // blueprint blue
uniform vec4 ink : source_color = vec4(0.86, 0.93, 1.0, 1.0);      // pale white-blue lines
uniform sampler2D art : hint_default_black, filter_linear, repeat_disable;   // the schematic (alpha = ink)
uniform float grid = 12.0;
uniform float length = 1.0;
uniform float reveal : hint_range(0.0, 1.0) = 0.0;   // fraction of the length unrolled
varying float along;                                   // 0 at the left end .. 1 at the right end
void vertex() { along = (VERTEX.z + length * 0.5) / length; }
void fragment() {
	if (along > reveal) { discard; }
	vec2 g = abs(fract(UV * grid) - 0.5);
	float line = 1.0 - smoothstep(0.0, 0.06, min(g.x, g.y));
	float border = step(UV.x, 0.025) + step(0.975, UV.x) + step(along, 0.025) + step(0.975, along);
	float pic = texture(art, vec2(along, 1.0 - UV.x)).a;   // image left->right along the sheet, top at the far edge
	float k = clamp(line * 0.35 + border + pic, 0.0, 1.0);
	ALBEDO = mix(paper.rgb, ink.rgb, k);
	ROUGHNESS = 0.9;
}
"""
const ART_WIDTH := 1024                # the drawing's pixel width; its height follows the sheet's shape

@export var length: float = 1.0        # world metres along +Z (viewer's left -> right)
@export var width: float = 0.8         # front -> back of the bench
@export var unroll_time: float = 0.7
@export var roll_radius: float = 0.035
@export var hover_bob: float = 0.012   # metres: it floats, so it breathes up and down a little
@export var paper_color: Color = Color(0.10, 0.30, 0.62)   # blueprint blue
@export var line_color: Color = Color(0.86, 0.93, 1.0)     # pale white-blue grid, border, drawing and title

var _body: Node3D                      # sheet + roll + title, bobbed together
var _sheet: MeshInstance3D
var _mat: ShaderMaterial
var _roll: MeshInstance3D
var _title: Label3D
var _viewport: SubViewport
var _art: BlueprintArt
var _reveal := 0.0
var _tw: Tween = null
var _t := 0.0
var _shown_id := ""                    # recipe currently drawn on the sheet
var _next: Dictionary = {}             # the latest pick while a swap is in flight
var _swapping := false


func _process(delta: float) -> void:
	_t += delta
	if _body != null:
		_body.position.y = (sin(_t * 1.3) * 0.5 + 0.5) * hover_bob


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # the dashboard pauses the tree; the sheet keeps swapping and bobbing
	_body = Node3D.new()
	add_child(_body)
	var plane := PlaneMesh.new()
	plane.size = Vector2(width, length)
	_sheet = MeshInstance3D.new()
	_sheet.mesh = plane
	_sheet.position = Vector3(0.0, 0.004, length * 0.5)   # left end at the origin, a hair above the table
	var sh := Shader.new()
	sh.code = SHEET_SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.set_shader_parameter("length", length)
	_mat.set_shader_parameter("reveal", 0.0)
	_mat.set_shader_parameter("paper", paper_color)
	_mat.set_shader_parameter("ink", line_color)
	_sheet.material_override = _mat
	_sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_body.add_child(_sheet)

	# the drawing: a Control painting the schematic, rendered off-screen into the sheet
	# same proportions as the sheet, so nothing in the drawing is stretched
	var art_size := Vector2i(ART_WIDTH, clampi(roundi(ART_WIDTH * width / maxf(length, 0.01)), 128, ART_WIDTH))
	_viewport = SubViewport.new()
	_viewport.size = art_size
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS   # only lives while at the bench; a redraw is never missed
	add_child(_viewport)
	_art = BlueprintArt.new()
	_art.size = Vector2(art_size)
	_viewport.add_child(_art)
	_mat.set_shader_parameter("art", _viewport.get_texture())

	var cyl := CylinderMesh.new()
	cyl.top_radius = roll_radius
	cyl.bottom_radius = roll_radius
	cyl.height = width * 1.02
	_roll = MeshInstance3D.new()
	_roll.mesh = cyl
	_roll.rotation.z = PI * 0.5                            # lie across the sheet
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(0.16, 0.36, 0.68)              # rolled blueprint paper
	rm.roughness = 0.95
	_roll.material_override = rm
	_body.add_child(_roll)

	_title = Label3D.new()
	_title.text = ""
	_title.font_size = 64
	_title.pixel_size = length / 900.0
	_title.modulate = Color(line_color.r, line_color.g, line_color.b, 0.0)   # fades in with the sheet
	_title.outline_size = 0
	_title.billboard = BaseMaterial3D.BILLBOARD_ENABLED     # always readable from the bench camera
	_title.no_depth_test = true
	_title.position = Vector3(-width * 0.36, 0.05, length * 0.5)   # over the near edge, under the drawing
	_body.add_child(_title)
	_set_reveal(0.0)


func set_title(text: String) -> void:
	_title.text = text


func reveal() -> float:
	return _reveal


func shown_recipe_id() -> String:
	return _shown_id


func is_swapping() -> bool:
	return _swapping


## Put a recipe on the sheet. While the sheet is still rolled it is simply drawn (the unroll
## comes later); once open, a NEW recipe rolls the sheet back up, swaps the drawing and unrolls
## it again. Picks landing during a swap fold into it — the latest one wins.
func show_recipe(recipe: Dictionary) -> void:
	var id := str(recipe.get("id", ""))
	if _swapping:
		_next = recipe
		return
	if id == _shown_id:
		return
	if _reveal < 0.001 and (_tw == null or not _tw.is_valid()):
		_apply(recipe)
		return
	_swapping = true
	_next = recipe
	_animate(0.0, unroll_time * 0.6, Tween.EASE_IN, _swap_middle)


func unroll() -> void:
	_animate(1.0, unroll_time, Tween.EASE_OUT, func() -> void: unrolled.emit())

func roll_up() -> void:
	_swapping = false
	_next = {}
	_animate(0.0, unroll_time * 0.6, Tween.EASE_IN, func() -> void: rolled_up.emit())


# ---- internals -------------------------------------------------------------------
func _swap_middle() -> void:
	_apply(_next)
	_animate(1.0, unroll_time, Tween.EASE_OUT, _swap_done)

func _swap_done() -> void:
	_swapping = false
	var latest := _next
	_next = {}
	if str(latest.get("id", "")) != _shown_id:   # another pick landed mid-swap
		show_recipe(latest)


func _apply(recipe: Dictionary) -> void:
	_shown_id = str(recipe.get("id", ""))
	_title.text = str(recipe.get("name", "")) if not recipe.is_empty() else ""
	_art.recipe = recipe
	_art.queue_redraw()
	picture_changed.emit(_shown_id)


func _animate(to: float, seconds: float, ease: Tween.EaseType, done: Callable) -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(ease)
	_tw.tween_method(_set_reveal, _reveal, to, seconds)
	_tw.tween_callback(done)


func _set_reveal(v: float) -> void:
	_reveal = v
	_mat.set_shader_parameter("reveal", v)
	var r: float = lerpf(roll_radius, roll_radius * 0.45, v)   # the roll thins as the paper comes off it
	(_roll.mesh as CylinderMesh).top_radius = r
	(_roll.mesh as CylinderMesh).bottom_radius = r
	_roll.position = Vector3(0.0, r, v * length)
	_roll.visible = v < 0.999
	_title.modulate.a = clampf((v - 0.55) / 0.35, 0.0, 1.0)   # the name fades in as the sheet opens
