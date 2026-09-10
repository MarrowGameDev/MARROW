extends Node
class_name BenchFocusFX
## "Everything but the bench disappears." Every mesh in the scene except the bench's own
## meshes gets a shared WHITE overlay pass and a shared BLACK inverted-hull OUTLINE:
##   ink   — textures ease to flat white with black outlines; the sky eases to white
##   hold  — a beat of pure line art
##   void  — the outlines ease away: white on white, the world is gone, only the bench remains;
##           particles / labels / scavenge glows are switched off (render layers = 0, so
##           nothing that toggles `visible` each frame can bring them back)
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

@export var ink_time: float = 1.1      # colour -> white + outlines
@export var hold_time: float = 0.25    # a beat of pure line art
@export var fade_time: float = 0.75    # outlines -> gone
@export var outline_width: float = 0.04

var _overlay: ShaderMaterial
var _outline_mat: ShaderMaterial
var _targets: Array = []      # MeshInstance3D that got the overlay
var _outlines: Array = []     # their black outline children
var _hidden: Dictionary = {}  # VisualInstance3D -> original render layers (switched off in the void)
var _env: Environment = null
var _env_mode: int = 0
var _env_color: Color = Color.WHITE
var _tw: Tween = null
var _in_void := false


func total_time() -> float:
	return ink_time + hold_time + fade_time


func begin(scene_root: Node, keep_root: Node) -> void:
	_overlay = ShaderMaterial.new()
	_overlay.shader = _shader(OVERLAY_SHADER)
	_overlay.set_shader_parameter("ink", 0.0)
	_outline_mat = ShaderMaterial.new()
	_outline_mat.shader = _shader(OUTLINE_SHADER)
	_outline_mat.set_shader_parameter("alpha", 0.0)
	_outline_mat.set_shader_parameter("width", outline_width)

	for vi in scene_root.find_children("*", "VisualInstance3D", true, false):
		if _is_kept(vi, keep_root) or is_ancestor_of(vi) or vi is Light3D:
			continue
		if vi is OutlineGlow:
			# a scavenge glow: whiten it with everyone else, then switch it off in the void
			(vi as MeshInstance3D).material_overlay = _overlay
			_targets.append(vi)
			_hidden[vi] = (vi as VisualInstance3D).layers
		elif vi is MeshInstance3D:
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
		else:
			_hidden[vi] = (vi as VisualInstance3D).layers   # particles, labels, sprites

	var world: World3D = scene_root.get_viewport().find_world_3d() if scene_root.get_viewport() != null else null
	if world != null and world.environment != null:
		_env = world.environment
		_env_mode = _env.background_mode
		_env_color = _env.background_color
		_env.background_mode = Environment.BG_COLOR

	_tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tw.set_parallel(true)
	_tw.tween_method(_set_ink, 0.0, 1.0, ink_time)
	_tw.tween_method(_set_outline, 0.0, 1.0, ink_time)
	if _env != null:
		_tw.tween_property(_env, "background_color", Color.WHITE, ink_time)
	_tw.chain().tween_interval(hold_time)
	_tw.chain().tween_method(_set_outline, 1.0, 0.0, fade_time)
	_tw.chain().tween_callback(_enter_void)


func end() -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_leave_void()
	_tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
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

func hidden_count() -> int:
	return _hidden.size()


# ---- internals -------------------------------------------------------------------
## Only the bench's OWN imported meshes are kept — nodes the user nests under the bench
## (a crate dragged under it) belong to their own scene instance and vanish like the rest.
static func _is_kept(vi: Node, keep_root: Node) -> bool:
	if vi == keep_root:
		return true
	if not keep_root.is_ancestor_of(vi):
		return false
	return vi.owner == keep_root or vi.owner == null and vi.get_parent() == keep_root

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
			(n as VisualInstance3D).layers = 0     # off, no matter who toggles `visible`
	finished.emit()

func _leave_void() -> void:
	if not _in_void:
		return
	_in_void = false
	for n in _hidden:
		if is_instance_valid(n):
			(n as VisualInstance3D).layers = int(_hidden[n])

func _restore() -> void:
	for mi in _targets:
		if is_instance_valid(mi):
			mi.material_overlay = null
	for o in _outlines:
		if is_instance_valid(o):
			o.queue_free()
	_targets.clear()
	_outlines.clear()
	_hidden.clear()
	if _env != null:
		_env.background_color = _env_color
		_env.background_mode = _env_mode
	restored.emit()
	queue_free()

static func _shader(code: String) -> Shader:
	var sh := Shader.new()
	sh.code = code
	return sh
