extends InteractStation
class_name CraftStation
## The workbench station: E opens the crafting dashboard, wired to the CraftingSystem autoload
## so Craft / Improve actually consume materials and produce / level up items.
##
## ENTERING (in parallel): a bench camera starts exactly where the hand's camera is and flies
## down close onto the bench; meanwhile the whole world except the bench INKS OUT — textures
## fade to white with black outlines — then the outlines fade too, leaving only the bench on
## a white void. The dashboard opens once both are done. LEAVING plays it all backwards.
## Auto-attached to every puppet_workshop by workbench_root.gd; also droppable by hand.

const CRAFTING_UI: PackedScene = preload("res://scenes/crafting_ui.tscn")

@export var camera_transition: bool = true
@export var camera_transition_time: float = 2.0   # matched to the ink -> hold -> void fx (~2.1s)
@export var camera_return_time: float = 1.2       # leaving is a little snappier
## A steep view looking DOWN at the tools on the tabletop (centred) with the cabinet fronts at
## the top of the frame: `camera_distance` metres from the tabletop centre along a line tilted
## `camera_pitch_deg` down. Same pose from any approach.
@export var camera_distance: float = 3.0          # METRES from the tabletop centre (lower = closer; tools leave the frame below ~2.8)
@export var camera_pitch_deg: float = 75.0        # how far the view tilts down (75 = near top-down)
@export var camera_focus_height: float = 0.6      # where the tabletop is, as a fraction of the bench's height
## The dashboard is a panel on the RIGHT of the screen, so the view is shifted (Camera3D.h_offset,
## metres) to put the tabletop in the open area on the left. Tweened in with the flight.
@export var camera_side_shift: float = 1.7
## Bench-local horizontal direction the camera sits toward. Fixed, so the landing pose is
## identical no matter where the hand's camera started. Flip Z if it lands behind the bench.
@export var camera_front: Vector3 = Vector3(0, 0, 1)
@export var focus_fx: bool = true            # the ink-out / void transition
@export var blueprint: bool = true           # a blueprint unrolls on the tabletop once the camera locks in

var _layer: CanvasLayer = null
var _ui: CraftingUI = null
var _blueprint: BlueprintProp = null
var _prev_cam: Camera3D = null
var _bench_cam: Camera3D = null
var _fx: BenchFocusFX = null
var _transitioning := false
var _pending_enter := 0


func _init() -> void:
	prompt_text = "Press E to craft"
	require_camera_facing = true   # the bench only takes E when the camera is looking at it


func _can_interact() -> bool:
	return _ui == null and not _transitioning

func _prompt_allowed() -> bool:
	return _ui == null and not _transitioning

func _on_interact() -> void:
	open_menu()


func open_menu() -> void:
	if _ui != null or _transitioning:
		return
	_prompt.visible = false
	_transitioning = true
	_pending_enter = 0
	if camera_transition and get_viewport().get_camera_3d() != null:
		_pending_enter += 1
		_fly_to_bench()
	if focus_fx:
		_pending_enter += 1
		_start_fx()
	if _pending_enter == 0:
		_transitioning = false
		_show_ui()


## Each entering effect (camera flight, focus fx) calls this when done; the last one unrolls the
## blueprint on the tabletop, and the dashboard opens once it's open.
func _on_enter_part_done() -> void:
	_pending_enter -= 1
	if _pending_enter <= 0:
		_transitioning = false
		if blueprint:
			_show_blueprint()
		else:
			_show_ui()


func _scene_root() -> Node:
	return get_tree().current_scene if get_tree().current_scene != null else get_tree().root


# ---- blueprint ---------------------------------------------------------------------
## The actual tabletop height under the bench centre (raycast), so the sheet lies on the surface.
func tabletop_surface() -> Vector3:
	var bench_h: float = trigger_size.y / 1.6
	var focus: Vector3 = global_position + Vector3.UP * (bench_h * camera_focus_height)
	var space := get_world_3d().direct_space_state
	if space != null:
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(focus + Vector3.UP * bench_h, focus - Vector3.UP * bench_h))
		if not hit.is_empty():
			return Vector3(focus.x, hit.position.y, focus.z)
	return focus


func _show_blueprint() -> void:
	if _blueprint != null and is_instance_valid(_blueprint):
		_blueprint.queue_free()
	var front: Vector3 = global_transform.basis * camera_front
	front.y = 0.0
	front = front.normalized() if front.length() > 0.001 else Vector3.BACK
	var depth: float = (absf(camera_front.x) * trigger_size.x + absf(camera_front.z) * trigger_size.z) / 1.5
	_blueprint = BlueprintProp.new()
	_blueprint.name = "Blueprint"
	_blueprint.length = depth * 0.45
	_blueprint.width = depth * 0.35
	_scene_root().add_child(_blueprint)
	# origin = near edge; centre the sheet on the tabletop and unroll it away from the viewer (+Z = -front)
	var surface: Vector3 = tabletop_surface() + Vector3.UP * 0.01
	_blueprint.global_transform = Transform3D(Basis.looking_at(front, Vector3.UP), surface + front * (_blueprint.length * 0.5))
	_blueprint.unrolled.connect(_show_ui, CONNECT_ONE_SHOT)
	_blueprint.unroll()


func _on_selection_changed(recipe: Dictionary) -> void:
	if _blueprint != null and is_instance_valid(_blueprint):
		_blueprint.set_title(str(recipe.get("name", "")) if not recipe.is_empty() else "")


# ---- focus fx ---------------------------------------------------------------------
func _start_fx() -> void:
	_fx = BenchFocusFX.new()
	_fx.name = "BenchFocusFX"
	_scene_root().add_child(_fx)
	_fx.finished.connect(_on_enter_part_done)
	_fx.begin(_scene_root(), get_parent() if get_parent() != null else self)   # keep the bench (our parent)


# ---- camera -----------------------------------------------------------------------
## Where the bench camera ends up: a FIXED pose — `dist` from the bench's work surface, on the
## bench's own front side (camera_front), at a fixed down-tilt, looking at the surface centre.
## Independent of where the hand's camera started, so it's always centred the same way.
func bench_view_transform() -> Transform3D:
	var bench_h: float = trigger_size.y / 1.6                       # trigger = bench bounds x1.6 tall
	var front: Vector3 = global_transform.basis * camera_front
	front.y = 0.0
	front = front.normalized() if front.length() > 0.001 else Vector3.BACK
	var tabletop: Vector3 = global_position + Vector3.UP * (bench_h * camera_focus_height)
	# `camera_distance` out from the tabletop centre along a line tilted `camera_pitch_deg` down,
	# on the bench's front side, looking back down at the tabletop centre
	var pitch: float = deg_to_rad(camera_pitch_deg)
	var pos: Vector3 = tabletop + front * (camera_distance * cos(pitch)) + Vector3.UP * (camera_distance * sin(pitch))
	pos = _clear_of_clutter(tabletop, pos)
	return Transform3D(Basis.looking_at(tabletop - pos, Vector3.UP), pos)


## If bench clutter sits between the tabletop and the ideal spot, stop just in front of it.
func _clear_of_clutter(focus: Vector3, pos: Vector3) -> Vector3:
	var space := get_world_3d().direct_space_state
	if space == null:
		return pos
	var q := PhysicsRayQueryParameters3D.create(focus + Vector3.UP * 0.05, pos)
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return pos
	var dir: Vector3 = (pos - focus).normalized()
	var d: float = maxf(hit.position.distance_to(focus) - 0.15, 0.3)
	return focus + dir * d


func _fly_to_bench() -> void:
	_prev_cam = get_viewport().get_camera_3d()
	_bench_cam = Camera3D.new()
	_bench_cam.name = "BenchCamera"
	_bench_cam.fov = _prev_cam.fov
	_scene_root().add_child(_bench_cam)          # scene root: no inherited scale from the bench
	_bench_cam.global_transform = _prev_cam.global_transform
	_bench_cam.current = true
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.set_parallel(true)
	tw.tween_property(_bench_cam, "global_transform", bench_view_transform(), camera_transition_time)
	tw.tween_property(_bench_cam, "h_offset", camera_side_shift, camera_transition_time)   # make room for the panel
	tw.finished.connect(_on_enter_part_done)


func _fly_back() -> void:
	if _bench_cam == null or _prev_cam == null or not is_instance_valid(_prev_cam):
		_restore_camera()
		return
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.set_parallel(true)
	tw.tween_property(_bench_cam, "global_transform", _prev_cam.global_transform, camera_return_time)
	tw.tween_property(_bench_cam, "h_offset", 0.0, camera_return_time)
	tw.finished.connect(_restore_camera)


func _restore_camera() -> void:
	if _prev_cam != null and is_instance_valid(_prev_cam):
		_prev_cam.current = true
	if _bench_cam != null and is_instance_valid(_bench_cam):
		_bench_cam.queue_free()
	_bench_cam = null
	_prev_cam = null
	_transitioning = false
	_update_prompt_visibility()


# ---- dashboard --------------------------------------------------------------------
func _show_ui() -> void:
	if _ui != null:
		return
	_layer = CanvasLayer.new()
	_layer.layer = 50
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_layer)
	_ui = CRAFTING_UI.instantiate() as CraftingUI
	_layer.add_child(_ui)
	_ui.closed.connect(_on_menu_closed)
	_ui.craft_requested.connect(_on_craft)
	_ui.improve_requested.connect(_on_improve)
	_ui.selection_changed.connect(_on_selection_changed)   # the blueprint shows the selected recipe
	var sys = system()
	if sys == null:
		_ui.show_message("No crafting system loaded.", false)
	else:
		_ui.material_names = sys.MATERIAL_NAMES
		_ui.set_recipes(sys.recipes)
		_sync_state()
	_ui.open()


## Push the system's current materials + crafted items into the UI (keeps the selection).
func _sync_state() -> void:
	var sys = system()
	if sys == null or _ui == null:
		return
	_ui.set_owned(sys.items)
	_ui.set_inventory(sys.materials)


func _on_craft(recipe_id: String) -> void:
	var sys = system()
	if sys == null:
		return
	var item: Dictionary = sys.craft(recipe_id)
	_sync_state()
	if item.is_empty():
		_ui.show_message("Not enough materials.", false)
	else:
		_ui.show_message("Crafted %s!" % item.get("name", recipe_id), true)


func _on_improve(recipe_id: String) -> void:
	var sys = system()
	if sys == null:
		return
	var item: Dictionary = sys.improve(recipe_id)
	_sync_state()
	if item.is_empty():
		_ui.show_message("Can't improve that yet.", false)
	else:
		_ui.show_message("%s improved to Lv %d!" % [item.get("name", recipe_id), int(item.get("level", 1))], true)


func _on_menu_closed() -> void:
	if _layer != null:
		_layer.queue_free()
	_layer = null
	_ui = null
	_transitioning = true
	if _blueprint != null and is_instance_valid(_blueprint):
		var bp := _blueprint
		bp.rolled_up.connect(bp.queue_free, CONNECT_ONE_SHOT)
		bp.roll_up()       # the sheet rolls back up as the world returns
		_blueprint = null
	if _fx != null and is_instance_valid(_fx):
		_fx.end()          # world comes back (frees itself when restored)
		_fx = null
	_fly_back()            # the dashboard already unpaused the tree, so the tweens can run
