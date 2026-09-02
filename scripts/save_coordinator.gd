class_name SaveCoordinator
extends Node

# Decides WHEN a save happens, and gives the player the two buttons that make
# saving a choice: SAVE and NEW GAME. What a save contains, and the order it is
# rebuilt in, belongs to SaveService.
#
# Saving is MANUAL by default. Autosaving on every chest and trial meant a demo
# run could never be replayed from a clean slate -- you kept your progress but
# the enemies came back, which reads as the world being inconsistent rather than
# as a feature. A fresh launch now starts fresh unless the player asked to
# continue.
#
# Place one of these in a playable scene. Test scenes leave it out, so a sandbox
# run can never overwrite a real save.

# Set by the main menu's CONTINUE button, consumed by the next coordinator that
# starts. Static because it has to survive change_scene_to_file, which throws
# away every node including whoever made the request.
static var load_requested_on_start: bool = false

# Off by default: see the note above. Turn it on for a build where losing
# progress to a crash matters more than a repeatable demo.
@export var autosave_enabled: bool = false
@export var show_save_buttons: bool = true
# Leave empty to find the player through the "player" group, which is how every
# other system in the project locates it.
@export var player_path: NodePath
# The subtree searched for chests, trials and enemies. Empty means the whole scene.
@export var world_root_path: NodePath

var last_report: Dictionary = {}

# Enemies that died and were freed before the next save. A non-respawning enemy
# queue_frees itself, so it cannot be asked for its state later; without this it
# would come back alive on load. Keyed exactly as SaveService keys a live one.
var _defeated_keys: Array[String] = []

var _player: Node = null
var _world_root: Node = null
var _status_label: Label = null
var _status_timer: float = 0.0


func _ready() -> void:
	add_to_group("save_coordinators")
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	GameEvents.chest_opened.connect(_on_chest_opened)
	GameEvents.trial_completed.connect(_on_trial_completed)

	if show_save_buttons:
		_build_ui()

	# One frame of grace: the world builders (tutorial_island_builder, camps)
	# create their nodes during _ready, so nothing is in the chest, trial or
	# enemy groups at this point.
	await get_tree().process_frame

	if load_requested_on_start:
		load_requested_on_start = false
		if SaveService.has_save():
			load_game()
		else:
			_set_status("No save to continue from.")


func _process(delta: float) -> void:
	if _status_timer <= 0.0:
		return
	_status_timer -= delta
	if _status_timer <= 0.0 and _status_label != null:
		_status_label.text = ""


# --- player-facing actions ------------------------------------------------

func save_game() -> bool:
	var data := SaveService.capture(_resolve_player(), _resolve_world_root(), _defeated_keys)
	var saved := SaveService.save_to_disk(data)
	if saved:
		var world: Dictionary = data.get("world", {})
		_set_status("Saved. %d carried, %d enemies, %d chests." % [
			(data.get("inventory", []) as Array).size(),
			(world.get("enemies", []) as Array).size(),
			(world.get("chests", []) as Array).size(),
		])
	else:
		push_warning("SaveCoordinator: the save could not be written.")
		_set_status("Save failed.")
	return saved


func load_game() -> Dictionary:
	var data := SaveService.load_from_disk()
	if data.is_empty():
		last_report = {}
		_set_status("No usable save.")
		return last_report

	last_report = SaveService.apply(data, _resolve_player(), _resolve_world_root())
	# The restored world already accounts for these; keeping them would re-report
	# deaths that this session did not cause.
	_defeated_keys.clear()
	_report_load(last_report)
	return last_report


# Wipes the save and restarts the scene, so "new game" means the same thing as
# a first launch rather than "keep playing but forget the file".
func new_game() -> void:
	SaveService.delete_save()
	_defeated_keys.clear()
	load_requested_on_start = false
	get_tree().reload_current_scene()


func autosave(reason: String) -> void:
	if not autosave_enabled:
		return
	if save_game():
		print("Autosaved (", reason, ")")


# --- triggers -------------------------------------------------------------

# Recorded ALWAYS, autosave or not: this is the only moment a freed enemy can
# still be identified.
func _on_enemy_defeated(enemy: Node, _dropped_bone_id: String) -> void:
	var key := SaveService.enemy_save_key(_resolve_world_root(), enemy)
	if key != "" and not _defeated_keys.has(key):
		_defeated_keys.append(key)


func _on_chest_opened(_chest: Node, chest_id: String, _contents: Array, _player: Node) -> void:
	autosave("chest " + chest_id)


func _on_trial_completed(trial_id: String, _trial_name: String) -> void:
	autosave("trial " + trial_id)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and autosave_enabled:
		save_game()


# --- ui -------------------------------------------------------------------

# Built in code, matching how ArenaGoalManager and the testing environment build
# their overlays. Bottom-left, out of the way of the goal panel (top-left) and
# the health readout (top-right).
func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "SaveUI"
	add_child(canvas)

	var root := VBoxContainer.new()
	root.name = "SaveButtons"
	root.anchor_left = 0.0
	root.anchor_top = 1.0
	root.anchor_right = 0.0
	root.anchor_bottom = 1.0
	root.offset_left = 18.0
	root.offset_top = -104.0
	root.offset_right = 260.0
	root.offset_bottom = -18.0
	root.add_theme_constant_override("separation", 6)
	canvas.add_child(root)

	_status_label = Label.new()
	_status_label.name = "SaveStatus"
	_status_label.add_theme_font_size_override("font_size", 14)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	root.add_child(row)
	row.add_child(_make_button("SAVE", Callable(self, "save_game")))
	row.add_child(_make_button("NEW GAME", Callable(self, "new_game")))


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(112.0, 34.0)
	button.add_theme_font_size_override("font_size", 14)
	button.focus_mode = Control.FOCUS_NONE  # never steal WASD from the player
	button.pressed.connect(callback)
	return button


func _set_status(text: String) -> void:
	print("SaveCoordinator: ", text)
	if _status_label == null:
		return
	_status_label.text = text
	_status_timer = 4.0


# --- wiring ---------------------------------------------------------------

func _resolve_player() -> Node:
	if _player != null and is_instance_valid(_player):
		return _player

	if not player_path.is_empty():
		_player = get_node_or_null(player_path)
	if _player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			_player = players[0]
	if _player == null:
		push_warning("SaveCoordinator: no player found; the save will have no inventory or equipment.")
	return _player


func _resolve_world_root() -> Node:
	if _world_root != null and is_instance_valid(_world_root):
		return _world_root

	if not world_root_path.is_empty():
		_world_root = get_node_or_null(world_root_path)
	if _world_root == null:
		_world_root = get_tree().current_scene
	if _world_root == null:
		_world_root = self
	return _world_root


func _report_load(report: Dictionary) -> void:
	if not bool(report.get("applied", false)):
		return

	var world: Dictionary = report.get("world", {})
	_set_status("Loaded: %d carried, %d enemies, %d chests, %d trials." % [
		int(report.get("inventory", 0)),
		int(world.get("enemies", 0)),
		int(world.get("chests", 0)),
		int(world.get("trials", 0)),
	])

	# Both of these mean the save no longer matches the content it was written
	# against. Silence would look like a working load with missing gear.
	var dropped: Array = report.get("dropped", [])
	if not dropped.is_empty():
		push_warning("SaveCoordinator: %d saved piece(s) no longer exist and were dropped from the inventory." % dropped.size())
	if not bool(report.get("equipment_complete", true)):
		push_warning("SaveCoordinator: the saved equipment could not be fully re-equipped; see the equipment report.")
