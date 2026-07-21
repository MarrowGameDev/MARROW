extends Node

# Global dev hotkeys (autoload): press 6 to open the procedural locomotion WALK
# demo, or 8 to open the LOCOMOTION LAB (live M2–M6 tuning menu) — so both are
# reachable from a running build instead of opening the scene in the editor.
#
# Uses _input + set_input_as_handled() so it takes precedence over per-scene key
# handling. The dummy testing environment's ranged-enemy spawn was on 6 and has
# moved to 7 (scripts/testing_environment.gd) so nothing is lost; 8 is otherwise
# unused. (The stance gallery, scenes/locomotion_gallery.tscn, is left unbound;
# add a case here if you want it on a hotkey.)

const WALK_DEMO := "res://scenes/locomotion_walk.tscn"
const LAB := "res://scenes/locomotion_lab.tscn"
const COMBAT := "res://scenes/locomotion_combat.tscn"


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_6:
		_open(WALK_DEMO)
	elif key.keycode == KEY_8:
		_open(LAB)
	elif key.keycode == KEY_9:
		_open(COMBAT)


func _open(path: String) -> void:
	var tree := get_tree()
	if tree == null:
		return
	# Already there? Don't reload on a repeated press.
	if tree.current_scene != null and tree.current_scene.scene_file_path == path:
		return
	get_viewport().set_input_as_handled()
	# Restore the cursor in case a gameplay scene had it captured.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	tree.change_scene_to_file(path)
