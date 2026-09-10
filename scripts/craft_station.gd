extends InteractStation
class_name CraftStation
## The workbench station: E opens the crafting dashboard, wired to the CraftingSystem autoload
## so Craft / Improve actually consume materials and produce / level up items. Auto-attached to
## every puppet_workshop by workbench_root.gd; also droppable by hand as craft_station.tscn.

const CRAFTING_UI: PackedScene = preload("res://scenes/crafting_ui.tscn")

var _layer: CanvasLayer = null
var _ui: CraftingUI = null


func _init() -> void:
	prompt_text = "Press E to craft"
	require_camera_facing = true   # the bench only takes E when the camera is looking at it


func _can_interact() -> bool:
	return _ui == null

func _prompt_allowed() -> bool:
	return _ui == null

func _on_interact() -> void:
	open_menu()


func open_menu() -> void:
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
	_prompt.visible = false


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
	_prompt.visible = _player != null
