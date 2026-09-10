extends Node
class_name BenchFocusFX
## "Everything but the bench disappears." Every mesh in the scene except the kept subtree
## gets a shared WHITE overlay pass and a shared BLACK inverted-hull OUTLINE:
##   phase 1 (ink)  — textures fade to flat white with black outlines; sky fades to white.
##   phase 2 (void) — the outlines fade out: white on white, so the world vanishes and only
##                    the bench is left. Particles / labels / glows are hidden at that point.
## end() plays it backwards and restores every material, outline, visual and the sky.
## Attach to the scene root, then call begin(scene_root, keep_root).

signal finished     # the void is complete (entering)
signal restored     # everything is back (leaving)

const OVERLAY_SHADER := """
shader_type spatial;
render_mode unshaded, blend_mix, cull_back;
uniform float ink : hint_range(0.0, 1.0) = 0.0;
uniform vec3 paper : source_color = vec3(1.0, 1.0, 1.0);
void fragment() { ALBEDO = paper; ALPHA = ink; }
"""
const OUTLINE_SHADER := """
shader_type spatial;
render_mode unshaded, blend_mix, cull_front, depth_draw_opaque;
uniform float alpha : hint_range(0.0, 1.0) = 0.0;
uniform float width = 0.04;   // world metres, independent of the object's scale
void vertex() {
	float s = length(MODEL_MATRIX[0].xyz);
	VERTEX += NORMAL * (width / max(s, 0.0001));
}
void fragment() { ALBEDO = vec3(0.0); ALPHA = alpha; }
"""

@export var ink_time: float = 0.7
@export var fade_time: float = 0.5
@export var outline_width: float = 0.04

var _overlay: ShaderMaterial
var _outline_mat: ShaderMaterial
var _targets: Array = []      # MeshInstance3D that got the overlay
var _outlines: Array = []     # their outline children
var _hidden: Array = []       # non-mesh visuals hidden while in the void
var _env: Environment = null
var _env_mode: int = 0
var _env_color: Color = Color.WHITE
var _tw: Tween = null
var _in_void := false


func begin(scene_root: Node, keep_root: Node) -> void:
	_overlay = ShaderMaterial.new()
	_overlay.shader = _shader(OVERLAY_SHADER)
	_overlay.set_shader_parameter("ink", 0.0)
	_outline_mat = ShaderMaterial.new()
	_outline_mat.shader = _shader(OUTLINE_SHADER)
	_outline_mat.set_shader_parameter("alpha", 0.0)
	_outline_mat.set_shader_parameter("width", outline_width)

	for vi in scene_root.find_children("*", "VisualInstance3D", true, false):
		if vi == keep_root or keep_root.is_ancestor_of(vi) or is_ancestor_of(vi) or vi is Light3D:
			continue
		if vi is MeshInstance3D and not (vi is OutlineGlow):
			var mi := vi as MeshInstance3D
			if mi.mesh == null:
				continue
			mi.material_overlay = _overlay
			_targets.append(mi)
			var o := MeshInstance3D.new()
			o.name = "FocusOutline"
			o.mesh = mi.mesh
			o.material_override = _outline_mat
			o.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			o.visible = false
			if mi.skin != null:
				o.skin = mi.skin
			mi.add_child(o)
			if mi.skeleton != NodePath("") and mi.get_node_or_null(mi.skeleton) != null:
				o.skeleton = o.get_path_to(mi.get_node(mi.skeleton))
			_outlines.append(o)
		elif vi.visible:
			_hidden.append(vi)   # particles, labels, glows: gone once the void completes

	var world: World3D = scene_root.get_viewport().find_world_3d() if scene_root.get_viewport() != null else null
	if world != null and world.environment != null:
		_env = world.environment
		_env_mode = _env.background_mode
		_env_color = _env.background_color
		_env.background_mode = Environment.BG_COLOR

	_tw = create_tween()
	_tw.set_parallel(true)
	_tw.tween_method(_set_ink, 0.0, 1.0, ink_time)
	_tw.tween_method(_set_outline, 0.0, 1.0, ink_time)
	if _env != null:
		_tw.tween_property(_env, "background_color", Color.WHITE, ink_time)
	_tw.chain().tween_method(_set_outline, 1.0, 0.0, fade_time)
	_tw.chain().tween_callback(_enter_void)


func end() -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_leave_void()
	_tw = create_tween()
	_tw.tween_method(_set_outline, 0.0, 1.0, fade_time * 0.6)           # lines come back
	_tw.chain().set_parallel(true)
	_tw.tween_method(_set_ink, 1.0, 0.0, ink_time * 0.7)                # colour returns
	_tw.tween_method(_set_outline, 1.0, 0.0, ink_time * 0.7)
	if _env != null:
		_tw.tween_property(_env, "background_color", _env_color, ink_time * 0.7)
	_tw.chain().tween_callback(_restore)


# ---- state readouts (for tests / tuning) ------------------------------------------
func ink() -> float:
	return float(_overlay.get_shader_parameter("ink")) if _overlay != null else 0.0

func outline_alpha() -> float:
	return float(_outline_mat.get_shader_parameter("alpha")) if _outline_mat != null else 0.0

func in_void() -> bool:
	return _in_void

func target_count() -> int:
	return _targets.size()


# ---- internals -------------------------------------------------------------------
func _set_ink(v: float) -> void:
	_overlay.set_shader_parameter("ink", v)

func _set_outline(v: float) -> void:
	_outline_mat.set_shader_parameter("alpha", v)
	var show := v > 0.001
	for o in _outlines:
		if is_instance_valid(o):
			o.visible = show

func _enter_void() -> void:
	_in_void = true
	for n in _hidden:
		if is_instance_valid(n):
			n.visible = false
	finished.emit()

func _leave_void() -> void:
	if not _in_void:
		return
	_in_void = false
	for n in _hidden:
		if is_instance_valid(n):
			n.visible = true

func _restore() -> void:
	for mi in _targets:
		if is_instance_valid(mi):
			mi.material_overlay = null
	for o in _outlines:
		if is_instance_valid(o):
			o.queue_free()
	_targets.clear()
	_outlines.clear()
	if _env != null:
		_env.background_color = _env_color
		_env.background_mode = _env_mode
	restored.emit()
	queue_free()

static func _shader(code: String) -> Shader:
	var sh := Shader.new()
	sh.code = code
	return sh
