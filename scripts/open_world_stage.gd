extends Node3D

# Open-world stage region.
#
# Art/layout workflow:
#   Replace the mesh on StageBody/StageMesh to change the visible stage shape.
#   This script copies that mesh into StageCollision at runtime, so the mesh is
#   the only thing that must change for the playable surface.
#
# Metadata workflow:
#   Edit the exported name/difficulty fields to tune progression and labels.

@export var stage_id: String = "stage"
@export var stage_name: String = "Stage"
@export_range(1, 10, 1) var difficulty: int = 1
@export var recommended_bone: String = "none"
@export_multiline var description: String = ""
@export var stage_color: Color = Color(0.35, 0.55, 0.35, 1.0)
@export var trigger_size: Vector3 = Vector3(12, 4, 12)

var stage_material: StandardMaterial3D = null

@onready var stage_mesh: MeshInstance3D = $StageBody/StageMesh
@onready var stage_collision: CollisionShape3D = $StageBody/StageCollision
@onready var stage_trigger_shape: CollisionShape3D = $StageTrigger/StageTriggerShape
@onready var stage_label: Label3D = $StageLabel


func _ready() -> void:
	add_to_group("open_world_stages")
	$StageTrigger.body_entered.connect(_on_body_entered)
	$StageTrigger.body_exited.connect(_on_body_exited)
	_prepare_material()
	_refresh_stage_from_mesh()
	_update_label()


# Use this after changing StageMesh.mesh in code. In the editor, just replacing
# the StageMesh mesh and pressing Play is enough because _ready runs again.
func refresh_runtime_mesh() -> void:
	_refresh_stage_from_mesh()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	for manager in get_tree().get_nodes_in_group("world_map_managers"):
		if manager.has_method("enter_stage"):
			manager.call("enter_stage", self)


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	for manager in get_tree().get_nodes_in_group("world_map_managers"):
		if manager.has_method("exit_stage"):
			manager.call("exit_stage", self)


func get_stage_summary() -> String:
	var text := stage_name + "\n"
	text += "Difficulty " + str(difficulty) + " / 10\n"
	if recommended_bone != "":
		text += "Recommended: " + recommended_bone + "\n"
	if description != "":
		text += description
	return text


func _refresh_stage_from_mesh() -> void:
	if stage_mesh == null or stage_mesh.mesh == null:
		return

	stage_collision.shape = stage_mesh.mesh.create_trimesh_shape()

	var trigger_shape := BoxShape3D.new()
	trigger_shape.size = trigger_size
	stage_trigger_shape.shape = trigger_shape


func _prepare_material() -> void:
	var raw_material := stage_mesh.get_surface_override_material(0)
	if raw_material != null:
		stage_material = raw_material.duplicate() as StandardMaterial3D
	if stage_material == null:
		stage_material = StandardMaterial3D.new()

	stage_material.albedo_color = stage_color
	stage_material.roughness = 0.85
	stage_mesh.set_surface_override_material(0, stage_material)


func _update_label() -> void:
	if stage_label == null:
		return

	stage_label.text = stage_name + "\nDifficulty " + str(difficulty)
	stage_label.modulate = stage_color
