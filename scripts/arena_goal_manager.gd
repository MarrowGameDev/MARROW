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
var current_tutorial_priority: int = -1
var active_tutorial_hint: String = ""
var control_tutorial_done: Dictionary = {}

const CONTROL_TUTORIAL_STEPS := [
	"move",
	"sprint",
	"jump",
	"attack",
	"bow",
	"pickup",
	"inventory",
	"equip",
]


func _ready() -> void:
	add_to_group("arena_goal_managers")
	run_start_ms = Time.get_ticks_msec()
	GameEvents.trial_completed.connect(_on_trial_completed)
	GameEvents.exit_reached.connect(_on_exit_reached)
	GameEvents.player_died.connect(_on_player_died)
	GameEvents.objective_updated.connect(_on_objective_updated)
	GameEvents.tutorial_hint_requested.connect(_on_tutorial_hint_requested)
	GameEvents.bone_collected.connect(_on_bone_collected)
	GameEvents.bone_equipped.connect(_on_bone_equipped)
	GameEvents.inventory_open_changed.connect(_on_inventory_open_changed)
	GameEvents.camp_state_changed.connect(_on_camp_state_changed)
	_reset_control_tutorial()
	_build_goal_ui()
	_build_help_ui()
	_build_win_ui()
	_emit_objective_updated()
	GameEvents.tutorial_hint_requested.emit(self, "demo_start", _default_help_text(), 0)


func _process(_delta: float) -> void:
	if ended:
		return

	var is_moving := (
		Input.is_action_pressed("move_forward")
		or Input.is_action_pressed("move_back")
		or Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
	)
	if is_moving:
		_complete_control_tutorial_step("move")
	if is_moving and Input.is_action_pressed("sprint"):
		_complete_control_tutorial_step("sprint")
	if Input.is_action_just_pressed("jump"):
		_complete_control_tutorial_step("jump")
	if Input.is_action_just_pressed("attack"):
		_complete_control_tutorial_step("attack")
	if Input.is_action_just_pressed("toggle_bow"):
		_complete_control_tutorial_step("bow")


# Tier 1F: R restarts the whole run at any time, so repeated testing is fast.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()


# Trial gates call this when the player solves them with the right equipped bone.
func register_trial_complete(trial_id: String, trial_name: String) -> void:
	if completed_trials.has(trial_id):
		return

	completed_trials[trial_id] = trial_name
	_emit_objective_updated()

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

	_emit_objective_updated()
	GameEvents.tutorial_hint_requested.emit(self, "exit_open", "All trials are clear. Find the open exit portal and step through it.", 2)
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

	goal_label.text = "Bone Trials\n\n" + _objective_body()


func _emit_objective_updated() -> void:
	GameEvents.objective_updated.emit(self, "bone_trials", "Bone Trials", _objective_body())


func _objective_body() -> String:
	var text := "Completed: " + str(completed_trials.size()) + " / " + str(required_trials) + "\n"

	if completed_trials.is_empty():
		text += "- None yet\n"
	else:
		for trial_name in completed_trials.values():
			text += "- " + str(trial_name) + "\n"

	if exit_open:
		text += "\nExit: open"
	else:
		text += "\nExit: locked"

	return text


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


func _on_objective_updated(source: Node, _objective_id: String, title: String, body: String) -> void:
	if source != self or goal_label == null:
		return
	goal_label.text = title + "\n\n" + body


func _on_tutorial_hint_requested(_source: Node, _hint_id: String, text: String, _priority: int) -> void:
	if help_label != null:
		if _priority < current_tutorial_priority:
			return
		current_tutorial_priority = _priority
		active_tutorial_hint = text
		_refresh_help_ui()


func _on_bone_collected(bone_id: String, _collector: Node) -> void:
	_complete_control_tutorial_step("pickup")
	GameEvents.tutorial_hint_requested.emit(self, "bone_collected", "Bone collected: " + BoneRulesService.display_name_with_slot(bone_id) + "\nOpen inventory with Tab to equip body parts and inspect stats.", 1)


func _on_bone_equipped(_bone_id: String, _slot: String, _player: Node) -> void:
	_complete_control_tutorial_step("equip")


func _on_inventory_open_changed(_player: Node, is_open: bool) -> void:
	if is_open:
		_complete_control_tutorial_step("inventory")


func _on_camp_state_changed(camp: Node, unlocked: bool, opened: bool, _remaining_enemies: int) -> void:
	if opened:
		return
	if unlocked:
		GameEvents.tutorial_hint_requested.emit(camp, "camp_unlocked", "Camp cleared. Hold " + DropPickupRulesService.action_binding_text(DropPickupRulesService.PICKUP_ACTION) + " at the chest to claim the reward.", 1)


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
	help_label.text = _full_help_text()
	margin.add_child(help_label)


func _default_help_text() -> String:
	var text := "Marrow - Demo Island\n"
	text += "Defeat enemies and harvest their bones, then equip the\n"
	text += "matching bone at each colored trial gate.\n"
	text += "Clear all 3 trials to open the exit, then step through it.\n"
	text += "R: restart"
	return text


func _full_help_text() -> String:
	var text := active_tutorial_hint
	if text == "":
		text = _default_help_text()
	text += "\n\n" + _control_tutorial_text()
	return text


func _refresh_help_ui() -> void:
	if help_label == null:
		return
	help_label.text = _full_help_text()


func _reset_control_tutorial() -> void:
	control_tutorial_done.clear()
	for step_id in CONTROL_TUTORIAL_STEPS:
		control_tutorial_done[str(step_id)] = false


func _complete_control_tutorial_step(step_id: String) -> void:
	if not control_tutorial_done.has(step_id):
		return
	if bool(control_tutorial_done[step_id]):
		return
	control_tutorial_done[step_id] = true
	_refresh_help_ui()


func _control_tutorial_text() -> String:
	var text := "Controls Tutorial\n"
	for step_id in CONTROL_TUTORIAL_STEPS:
		text += _control_tutorial_line(str(step_id)) + "\n"
	return text.strip_edges()


func _control_tutorial_line(step_id: String) -> String:
	var marker := "[ ]"
	if bool(control_tutorial_done.get(step_id, false)):
		marker = "[x]"
	return marker + " " + _control_tutorial_label(step_id)


func _control_tutorial_label(step_id: String) -> String:
	match step_id:
		"move":
			return "Move: " + _movement_binding_text()
		"sprint":
			return "Sprint: hold " + _action_binding_text("sprint") + " while moving"
		"jump":
			return "Jump: " + _action_binding_text("jump")
		"attack":
			return "Attack: " + _action_binding_text("attack")
		"bow":
			return "Bow: " + _action_binding_text("toggle_bow") + " to equip, hold/release " + _action_binding_text("attack") + " to shoot"
		"pickup":
			return "Pick up bones: hold " + _action_binding_text(DropPickupRulesService.PICKUP_ACTION)
		"inventory":
			return "Inventory: " + _action_binding_text("inventory")
		"equip":
			return "Equip a bone: drag in Inventory or press " + _action_binding_text("equip")
		_:
			return step_id


func _movement_binding_text() -> String:
	return (
		_action_binding_text("move_forward")
		+ "/"
		+ _action_binding_text("move_left")
		+ "/"
		+ _action_binding_text("move_back")
		+ "/"
		+ _action_binding_text("move_right")
	)


func _action_binding_text(action: String) -> String:
	return DropPickupRulesService.action_binding_text(action)


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
