extends InteractStation
class_name CraftStation
## The workbench station: E opens the crafting dashboard, wired to the CraftingSystem autoload
## so Craft / Improve actually consume materials and produce / level up items.
##
## ENTERING: a bench camera starts exactly where the hand's camera is, flies up and tilts
## down onto the bench (ease-in-out), and the dashboard opens when it lands. LEAVING: it
## flies back to the hand's camera, which takes over again. Auto-attached to every
## puppet_workshop by workbench_root.gd; also droppable by hand as craft_station.tscn.

const CRAFTING_UI: PackedScene = preload("res://scenes/crafting_ui.tscn")

@export var camera_transition: bool = true
@export var camera_transition_time: float = 0.8
@export var camera_height: float = 1.2       # extra world metres above the bench top

var _layer: CanvasLayer = null
var _ui: CraftingUI = null
var _prev_cam: Camera3D = null
var _bench_cam: Camera3D = null
var _transitioning := false


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
	if camera_transition and get_viewport().get_camera_3d() != null:
		_fly_to_bench()      # opens the dashboard when the camera lands
	else:
		_show_ui()


# ---- camera ----------------------------------------------------------------------
## Where the bench camera ends up: above the bench, pulled slightly toward the side the
## hand's camera was on, looking down at the bench centre.
func bench_view_transform() -> Transform3D:
	var bench_h: float = trigger_size.y / 1.6                       # trigger = bench bounds x1.6 tall
	var bench_d: float = maxf(trigger_size.x, trigger_size.z) / 1.5  # ... x1.5 wide
	var center: Vector3 = global_position + Vector3.UP * (bench_h * 0.5)
	var side: Vector3 = Vector3.BACK
	if _prev_cam != null:
		var from_cam: Vector3 = _prev_cam.global_position - center
		from_cam.y = 0.0
		if from_cam.length() > 0.01:
			side = from_cam.normalized()
	var pos: Vector3 = center + side * (bench_d * 0.55) + Vector3.UP * (bench_h * 0.5 + camera_height + bench_d * 0.35)
	return Transform3D(Basis.looking_at(center - pos, Vector3.UP), pos)


func _fly_to_bench() -> void:
	_transitioning = true
	_prev_cam = get_viewport().get_camera_3d()
	var host: Node = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	_bench_cam = Camera3D.new()
	_bench_cam.name = "BenchCamera"
	_bench_cam.fov = _prev_cam.fov
	host.add_child(_bench_cam)                  # scene root: no inherited scale from the bench
	_bench_cam.global_transform = _prev_cam.global_transform
	_bench_cam.current = true
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_bench_cam, "global_transform", bench_view_transform(), camera_transition_time)
	tw.finished.connect(func() -> void:
		_transitioning = false
		_show_ui())


func _fly_back() -> void:
	if _bench_cam == null or _prev_cam == null or not is_instance_valid(_prev_cam):
		_restore_camera()
		return
	_transitioning = true
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_bench_cam, "global_transform", _prev_cam.global_transform, camera_transition_time)
	tw.finished.connect(_restore_camera)


func _restore_camera() -> void:
	_transitioning = false
	if _prev_cam != null and is_instance_valid(_prev_cam):
		_prev_cam.current = true
	if _bench_cam != null and is_instance_valid(_bench_cam):
		_bench_cam.queue_free()
	_bench_cam = null
	_prev_cam = null
	_update_prompt_visibility()


# ---- dashboard -------------------------------------------------------------------
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
	_fly_back()   # the dashboard already unpaused the tree, so the tween can run
