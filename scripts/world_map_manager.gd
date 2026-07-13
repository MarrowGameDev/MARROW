extends Node

# Tracks which demo island region the player is standing in.

var current_stage: Node = null
var map_label: Label


func _ready() -> void:
	add_to_group("world_map_managers")
	GameEvents.stage_entered.connect(_on_stage_entered)
	GameEvents.stage_exited.connect(_on_stage_exited)
	_build_map_ui()
	_update_map_ui()


func enter_stage(stage: Node) -> void:
	current_stage = stage
	_update_map_ui()


func exit_stage(stage: Node) -> void:
	if current_stage == stage:
		current_stage = null
		_update_map_ui()


func _on_stage_entered(stage: Node) -> void:
	enter_stage(stage)


func _on_stage_exited(stage: Node) -> void:
	exit_stage(stage)


func _build_map_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "WorldMapCanvas"
	canvas.layer = 3
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "WorldMapPanel"
	panel.position = Vector2(24, 360)
	panel.custom_minimum_size = Vector2(320, 96)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	map_label = Label.new()
	map_label.name = "WorldMapLabel"
	map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(map_label)


func _update_map_ui() -> void:
	if map_label == null:
		return

	if current_stage != null and current_stage.has_method("get_stage_summary"):
		map_label.text = "Demo Island Region\n\n" + current_stage.call("get_stage_summary")
	else:
		map_label.text = "Demo Island Region\n\nCliffside Start\nDifficulty 1 / 10\nFollow the river paths to test the full demo loop."
