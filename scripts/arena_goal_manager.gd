extends Node

# Tier 1C asks a simple question:
# can the arena make you swap bones for different reasons?
@export var required_trials: int = 3

var completed_trials: Dictionary = {}
var exit_open: bool = false
var goal_label: Label

# Tier 1F: run timing + outcome (win OR lose) screen state.
var ended: bool = false
var run_start_ms: int = 0
var help_label: Label
var win_root: Control
var win_label: Label


func _ready() -> void:
	add_to_group("arena_goal_managers")
	run_start_ms = Time.get_ticks_msec()
	GameEvents.trial_completed.connect(_on_trial_completed)
	GameEvents.exit_reached.connect(_on_exit_reached)
	GameEvents.player_died.connect(_on_player_died)
	_build_goal_ui()
	_build_help_ui()
	_build_win_ui()
	_update_goal_ui()


# Tier 1F: R restarts the whole run at any time, so repeated testing is fast.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()


# Trial gates call this when the player solves them with the right equipped bone.
func register_trial_complete(trial_id: String, trial_name: String) -> void:
	if completed_trials.has(trial_id):
		return

	completed_trials[trial_id] = trial_name
	_update_goal_ui()

	if completed_trials.size() >= required_trials:
		_open_exit()


# Exit portals ask this before letting the player finish the test course.
func is_exit_open() -> bool:
	return exit_open


func _open_exit() -> void:
	if exit_open:
		return

	exit_open = true
	for portal in get_tree().get_nodes_in_group("exit_portals"):
		if portal.has_method("open_exit"):
			portal.call("open_exit")

	_update_goal_ui()
	print("All bone trials complete. Exit opened.")


func _build_goal_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "GoalCanvas"
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "GoalPanel"
	panel.position = Vector2(24, 210)
	panel.custom_minimum_size = Vector2(320, 120)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	goal_label = Label.new()
	goal_label.name = "GoalLabel"
	margin.add_child(goal_label)


func _update_goal_ui() -> void:
	if goal_label == null:
		return

	var text := "Bone Trials\n\n"
	text += "Completed: " + str(completed_trials.size()) + " / " + str(required_trials) + "\n"

	if completed_trials.is_empty():
		text += "- None yet\n"
	else:
		for trial_name in completed_trials.values():
			text += "- " + str(trial_name) + "\n"

	if exit_open:
		text += "\nExit: open"
	else:
		text += "\nExit: locked"

	goal_label.text = text


# Tier 1F: called by the exit portal when the player steps through an open exit.
func complete_level(player: Node) -> void:
	if ended:
		return
	ended = true
	_show_win_screen(player, Time.get_ticks_msec() - run_start_ms)


# Tier: the player died — show a game-over screen (reuses the same overlay).
func game_over(_player: Node = null) -> void:
	if ended:
		return
	ended = true
	win_label.text = "YOU DIED\n\nThe enemies got you.\n\nPress R to try again"
	win_root.visible = true


func _on_trial_completed(trial_id: String, trial_name: String) -> void:
	register_trial_complete(trial_id, trial_name)


func _on_exit_reached(player: Node) -> void:
	complete_level(player)


func _on_player_died(player: Node) -> void:
	game_over(player)


func _show_win_screen(player: Node, elapsed_ms: int) -> void:
	var minutes := int(elapsed_ms / 60000)
	var seconds := int((elapsed_ms % 60000) / 1000)

	var collected: Array = []
	var swaps := 0
	if player != null and player.has_method("get_run_stats"):
		var stats: Dictionary = player.call("get_run_stats")
		collected = stats.get("collected", [])
		swaps = int(stats.get("swaps", 0))

	# Build the "(Arm Bone, Leg Bone, ...)" list by hand (no join type surprises).
	var names_text := ""
	for id in collected:
		if names_text != "":
			names_text += ", "
		names_text += BoneRulesService.display_name_with_slot(id)

	var text := "DEMO COMPLETE!\n\n"
	text += "Time: %d:%02d\n" % [minutes, seconds]
	text += "Trials cleared: %d / %d\n" % [completed_trials.size(), required_trials]
	text += "Bones collected: %d\n" % collected.size()
	if names_text != "":
		text += "(" + names_text + ")\n"
	text += "Bone swaps: %d\n\n" % swaps
	text += "Press R to play again"

	win_label.text = text
	win_root.visible = true


# A small always-on panel so a first-time player knows the controls and the goal.
func _build_help_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HelpCanvas"
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "HelpPanel"
	panel.position = Vector2(24, 470)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	help_label = Label.new()
	var t := "Marrow — Demo Island\n"
	t += "Move: WASD     Sprint: Shift     Jump: Space     Attack: Left Click\n"
	t += "Stealth finish: F     Pick up bone: hold E     Equip next: Q     Inventory: E\n\n"
	t += "Defeat enemies and harvest their bones, then equip the\n"
	t += "matching bone at each colored trial gate.\n"
	t += "Clear all 3 trials to open the exit, then step through it.\n"
	t += "R: restart"
	help_label.text = t
	margin.add_child(help_label)


# The full-screen win overlay, hidden until the player finishes the course.
func _build_win_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "WinCanvas"
	canvas.layer = 10
	add_child(canvas)

	win_root = Control.new()
	win_root.name = "WinRoot"
	win_root.anchor_right = 1.0
	win_root.anchor_bottom = 1.0
	win_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win_root.visible = false
	canvas.add_child(win_root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.55)
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win_root.add_child(backdrop)

	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win_root.add_child(center)

	var panel := PanelContainer.new()
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	win_label = Label.new()
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 22)
	margin.add_child(win_label)
